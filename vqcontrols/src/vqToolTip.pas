// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqToolTip;

interface

uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Types, Classes, Controls, Graphics, Forms,
    vqUtils, vqThemes, vqMDMarker;
	
type
    
    { TvqMarkedHint }

    TvqMarkedHint = class(THintWindow)
    private

        FLayout: TTextLayout;
        FMarkStyle: TvqMarkStyle;
        FMarkedText: TvqMarkedText;
        FUpdatingBuffer: Boolean;
        
        FExpandTabs: Boolean;
        FOptions: TvqMarkOptions;
        FOnImageRequest: TvqImageRequestEvent;

        function GetText: string;

        procedure SetExpandTabs(Value: Boolean);
        procedure SetOptions(Value: TvqMarkOptions);
        procedure SetMarkStyle(Value: TvqMarkStyle);
        procedure SetLayout(Value: TTextLayout);
        
        procedure OnTextImageRequest(Sender: TObject; URI: string; Picture: TPicture; var Handled: Boolean);
        procedure OnMarkStyleUpdateMetrics(Sender: TObject);
        
        procedure UpdateMark;
    protected
        const DefaultOptions = [vqmoAutoURLDetect, vqmoCodeFenceAutoURL, vqmoCopyright];
        function TextStyle: TTextStyle; virtual;
        procedure DoImageRequest(URI: string; Picture: TPicture; var Handled: Boolean); virtual;
        property MarkedText: TvqMarkedText read FMarkedText;
        
        procedure UpdateMetrics; virtual;
        procedure TextChanged; override;
        procedure Resize; override;       
        procedure FontChanged(Sender: TObject); override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        
        function CharFormat(Index: Integer;
            var FontFore, FontBack: TColor; var FontStyle: TFontStyles; var FontFace: TFontName;
            var AddUnderline: Boolean): Boolean;
        function TextExtentFor(WrapWidth: Integer): TSize; overload;
        function TextExtentFor(Txt: string; WrapWidth: Integer): TSize; overload;
        
        function TextLength: Integer;
        property Text: string read GetText;
        
        property ExpandTabs: Boolean read FExpandTabs write SetExpandTabs;
        property MarkStyle: TvqMarkStyle read FMarkStyle write SetMarkStyle;
        property Options: TvqMarkOptions read FOptions write SetOptions;
        property Layout: TTextLayout read FLayout write SetLayout;
        
        property OnImageRequest: TvqImageRequestEvent read FOnImageRequest write FOnImageRequest;
    end;
    
    TvqToolTip = class(TvqMarkedHint)
    private
        FActivating: Boolean;
    protected
        procedure Paint; override;
        procedure FitHintRect;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        
        function CalcHintRect(MaxWidth: Integer; const AHint: String; AData: pointer): TRect; override;
        
        function CalculateExtent(S: string; MaxWidth: Integer = 0): TSize;
        procedure ShowTip(R: TRect; S: string); virtual;
        procedure MoveTip(R: TRect; S: string); virtual;
        procedure HideTip; virtual;
        function TipActive: Boolean;
    end;

implementation

{ TvqMarkedHint }

constructor TvqMarkedHint.Create(AOwner: TComponent);                         
begin
    inherited Create(AOwner);
    
    FExpandTabs := True;
    FOptions := DefaultOptions;
    
    FMarkStyle := TvqMarkStyle.Create(Self);
    FMarkStyle.OnUpdateMetrics := @OnMarkStyleUpdateMetrics;
    FMarkedText := TvqMarkedText.Create(FMarkStyle, Font);
    FMarkedText.OnRequestEvent := @OnTextImageRequest;
end;

destructor TvqMarkedHint.Destroy;                                             
begin
    FMarkedText.Free;
    FMarkStyle.Free;
    inherited;
end;

function TvqMarkedHint.CharFormat(Index: Integer;
    var FontFore, FontBack: TColor; var FontStyle: TFontStyles; var FontFace: TFontName;
    var AddUnderline: Boolean): Boolean;
begin
    Result := FMarkedText.CharFormat(Index, FontFore, FontBack, FontStyle, FontFace, AddUnderline);
end;

function TvqMarkedHint.TextExtentFor(WrapWidth: Integer): TSize;
begin
    Result := FMarkedText.TextExtentFor(TextStyle, WrapWidth);
end;

function TvqMarkedHint.TextExtentFor(Txt: string; WrapWidth: Integer): TSize;
var
    InputText: TvqStringText;
    MDText: TvqMarkedText;
begin
    Result := TSize.Create(0, 0);
    InputText := TvqStringText.CreateConst(Caption);
    MDText := TvqMarkedText.Create(FMarkStyle, Font);
    try
        if MDText.Parse(InputText, FOptions) then
            Result := MDText.TextExtentFor(TextStyle, WrapWidth);
    finally
        InputText.Free;
        MDText.Free;
    end;
end;

function TvqMarkedHint.TextLength: Integer;
begin
    Result := FMarkedText.TextLength;
end;

function TvqMarkedHint.GetText: string;
begin
    Result := FMarkedText._GetString(0, TextLength);
end;

procedure TvqMarkedHint.SetLayout(Value: TTextLayout);
begin
    if FLayout <> Value then begin
        FLayout := Value;
        UpdateMetrics;
    end;
end;

procedure TvqMarkedHint.SetExpandTabs(Value: Boolean);
begin
    if FExpandTabs <> Value then begin
        FExpandTabs := Value;
        UpdateMetrics;
    end;
end;

procedure TvqMarkedHint.SetOptions(Value: TvqMarkOptions);
begin
    if FOptions <> Value then begin
        FOptions := Value;
        UpdateMark;
    end;    
end;

procedure TvqMarkedHint.SetMarkStyle(Value: TvqMarkStyle);
begin
    FMarkStyle.Assign(Value);
end;

procedure TvqMarkedHint.DoImageRequest(URI: string; Picture: TPicture; var Handled: Boolean);
begin
    if Assigned(FOnImageRequest) then FOnImageRequest(Self, URI, Picture, Handled);
end;

procedure TvqMarkedHint.UpdateMetrics;
begin
    if FUpdatingBuffer then begin
        Invalidate;
        Exit;
    end
    else begin
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqMarkedHint.TextChanged;
begin
    inherited;
    UpdateMark;
end;

procedure TvqMarkedHint.FontChanged(Sender: TObject);
begin
    inherited FontChanged(Sender);
    UpdateMetrics;
end;

procedure TvqMarkedHint.Resize;
begin
    inherited;
end;

procedure TvqMarkedHint.OnTextImageRequest(Sender: TObject; URI: string; Picture: TPicture; var Handled: Boolean);
begin
    DoImageRequest(URI, Picture, Handled);
end;

procedure TvqMarkedHint.OnMarkStyleUpdateMetrics(Sender: TObject);
begin
    UpdateMetrics;
end;

function TvqMarkedHint.TextStyle: TTextStyle;
begin
    with Result do begin
        Alignment   := Self.Alignment;
        Layout      := FLayout;
        SingleLine  := False;
        Clipping    := True;
        ExpandTabs  := FExpandTabs;
        ShowPrefix  := False;
        Wordbreak   := True;
        Opaque      := False;
        SystemFont  := UseFGThemes;
        RightToLeft := False;
        EndEllipsis := False;
    end;
end;

procedure TvqMarkedHint.UpdateMark;
var
    InputText: TvqStringText;
begin
    if FUpdatingBuffer then Exit;
    FUpdatingBuffer := True;
    
    InputText := TvqStringText.CreateConst(Caption);
    try
        if FMarkedText.Parse(InputText, FOptions) then begin
            InvalidatePreferredSize;
            AdjustSize;
        end;
    finally
        InputText.Free;
        FUpdatingBuffer := False;
    end;
end;

{ TvqToolTip }

constructor TvqToolTip.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
end;

destructor TvqToolTip.Destroy;
begin
    inherited;
end;

function TvqToolTip.CalcHintRect(MaxWidth: Integer; const AHint: String; AData: pointer): TRect;
var 
    AMonitor: TMonitor;
    Sz: TSize;
    Dx, Dy: Integer;
begin
    if AHint = '' then
        Result := TRect.Empty
    else begin
        AMonitor := Screen.MonitorFromPoint(Point(Left, Top));
        if AMonitor = nil then 
            AMonitor := Screen.Monitors[0];
        if Application.Scaled and Scaled and 
            (AMonitor <> nil) and 
            (PixelsPerInch <> AMonitor.PixelsPerInch) then
            AutoAdjustLayout(lapAutoAdjustForDPI, PixelsPerInch, AMonitor.PixelsPerInch, 0, 0);
        if MaxWidth <= 0 then MaxWidth := AMonitor.Width;
        Result := vqThemeManager.ToolTipContentRect(Rect(0, 0, AMonitor.Width, AMonitor.Height));
        Dx := AMonitor.Width - Result.Width;
        Dy := AMonitor.Height - Result.Height;
        Sz := TextExtentFor(AHint, MaxWidth - Dx);
        Result := Rect(0, 0, Sz.cx + Dx, Sz.cy + Dy);
    end;
end;

function TvqToolTip.CalculateExtent(S: string; MaxWidth: Integer = 0): TSize;
begin
    Result := CalcHintRect(MaxWidth, S, nil).Size;
end;

procedure TvqToolTip.ShowTip(R: TRect; S: string);
begin
    if FActivating then Exit;
    if TipActive then begin
        MoveTip(R, S);
        Exit;
    end;
    HintRect := R;
    FitHintRect;
    if Visible and (Caption = S) and (HintRect = BoundsRect) then Exit;
    FActivating := True;
    try
        Caption := S;
        with HintRect do
            SetBounds(Left, Top, Width, Height);
        Visible := True;
    finally
        FActivating := False;
    end;
end;

procedure TvqToolTip.MoveTip(R: TRect; S: string);
begin
    if (not TipActive) or FActivating then Exit;
    HintRect := R;
    FitHintRect;
    if Visible and (Caption = S) and (HintRect = BoundsRect) then Exit;
    Caption := S;
    with HintRect do
        SetBounds(Left, Top, Width, Height);
    Update;
end;

procedure TvqToolTip.HideTip;
begin
    if FActivating or (not Visible) then Exit;
    Visible := False;
    HintRect := TRect.Empty;
end;

function TvqToolTip.TipActive: Boolean;
begin
    Result := Visible;
end;

procedure TvqToolTip.FitHintRect;
var
    OffsetX, OffsetY: Integer;
    HintR, Area: TRect;
begin
    Area := Screen.MonitorFromPoint(HintRect.TopLeft).WorkareaRect;
    HintR := HintRect;
    OffsetX := 0;
    OffsetY := 0;
    if HintR.Right > Area.Right then
        Inc(OffsetX, Area.Right - HintR.Right);
    if HintR.Left < Area.Left then
        Inc(OffsetX, Area.Left - HintR.Left);
    if HintR.Bottom > Area.Bottom then
        Inc(OffsetY, Area.Bottom - HintR.Bottom);
    if HintR.Top < Area.Top then
        Inc(OffsetY, Area.Top - HintR.Top);
    HintR.Offset(OffsetX, OffsetY);
    if HintR.Bottom > Area.Bottom then
        HintR.Bottom := Area.Bottom;
    if HintR.Right > Area.Right then
        HintR.Right := Area.Right;
    HintRect := HintR;
end;

procedure TvqToolTip.Paint;
var
    Client, TxtRect: TRect;
begin
    Client := ClientRect;
    vqThemeManager.DrawToolTip(Self, Canvas, Client, [vqthNormal]);
    TxtRect := vqThemeManager.ToolTipContentRect(Client);
    FMarkedText.Locate(TxtRect, TextStyle);
    FMarkedText.Render(Canvas, True);
    
    if Assigned(OnPaint) then OnPaint(Self);
end;

end.
