// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqMarkLabel;

interface

uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Classes, Types, SysUtils, Controls, Graphics, Math, ExtCtrls, ComCtrls,
    Dialogs,
    vqUtils, vqThemes, vqMDMarker;

type
    
    TvqMarkLabel = class(TvqGraphicControl)
    private
        FMarkStyle: TvqMarkStyle;
        FMarkedText: TvqMarkedText;
        FUpdatingBuffer: Boolean;
        FPlainCaption: Boolean;
        
        FOptions: TvqMarkOptions;
        FTextFormat: TvqTextFormat;
        FAutoOpenURL: Boolean;
        
        FOnHyperlink: TvqHyperlinkEvent;
        FOnImageRequest: TvqImageRequestEvent;
        
        function GetMarkAt(Index: Integer): Byte;
        function GetCharAt(Index: Integer): Char;
        function GetLink(Index: Integer): TvqMarkLink;
        
        function GetLinesCount: Integer;
        function GetRowCount: Integer;
        function GetTextLength: Integer;
        
        procedure SetOptions(Value: TvqMarkOptions);
        procedure SetTextFormat(Value: TvqTextFormat);
        procedure SetMarkStyle(Value: TvqMarkStyle);
        
        function GetText: string;
        
        procedure OnTextHyperlink(Sender: TObject; ALabel, AAddress, AHint: string; AIndex: Integer; var Opened: Boolean);
        procedure OnTextImageRequest(Sender: TObject; URI: string; Picture: TPicture; var Handled: Boolean);
        procedure OnMarkStyleUpdateMetrics(Sender: TObject);
        procedure OnTextFormatChange(Sender: TObject);

        procedure UpdateMark;
    protected
        const DefaultOptions = [vqmoAutoURLDetect, vqmoCodeFenceAutoURL, vqmoCopyright];
        class function GetControlClassDefaultSize: TSize; override;
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        
        procedure DoHyperlink(ALabel, AAddress, AHint: string; AIndex: Integer; var Opened: Boolean); virtual;
        procedure DoImageRequest(URI: string; Picture: TPicture; var Handled: Boolean); virtual;
        
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseEnter; override;
        procedure MouseLeave; override;
        
        procedure UpdateMetrics; override;
        procedure TextChanged; override;
        procedure ColorChanged; override;
        procedure FontChanged; override;
        procedure Resize; override;
        procedure Paint; override;
        
        property MarkedText: TvqMarkedText read FMarkedText;
    public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;

        function TextExtentFor(WrapWidth: Integer): TSize;
        
        property MarkAt[Index: Integer]: Byte read GetMarkAt;
        property CharAt[Index: Integer]: Char read GetCharAt;
        property Link[Index: Integer]: TvqMarkLink read GetLink;
        
        property LinesCount: Integer read GetLinesCount;
        property RowCount: Integer read GetRowCount;
        property TextLength: Integer read GetTextLength;
        property Text: string read GetText;
    published
        property Options: TvqMarkOptions read FOptions write SetOptions;
        property TextFormat: TvqTextFormat read FTextFormat write SetTextFormat;
        property MarkStyle: TvqMarkStyle read FMarkStyle write SetMarkStyle;
        property AutoOpenURL: Boolean read FAutoOpenURL write FAutoOpenURL;
        property Caption;
        property Autosize;
        property OnHyperlink: TvqHyperlinkEvent read FOnHyperlink write FOnHyperlink;
        property OnImageRequest: TvqImageRequestEvent read FOnImageRequest write FOnImageRequest;
    end;
    
implementation

{ TvqMarkLabel }

constructor TvqMarkLabel.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FTextFormat := TvqTextFormat.Create(Self);
    FTextFormat.OnChange := @OnTextFormatChange;
    
    FOptions := DefaultOptions;
    FMarkStyle := TvqMarkStyle.Create(Self);
    FMarkStyle.OnUpdateMetrics := @OnMarkStyleUpdateMetrics;
    FMarkedText := TvqMarkedText.Create(FMarkStyle, Font);
    FMarkedText.OnRequestEvent := @OnTextImageRequest;
    FMarkedText.OnHyperlinkEvent := @OnTextHyperlink;
    
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
    AutoSize := True;
end;

destructor TvqMarkLabel.Destroy;
begin
    FTextFormat.Free;
    FMarkedText.Free;
    FMarkStyle.Free;
    inherited;
end;

class function TvqMarkLabel.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 120;
    Result.cy := 17;
end;

function TvqMarkLabel.GetMarkAt(Index: Integer): Byte;
begin
    Result := FMarkedText.Mark[Index];
end;

function TvqMarkLabel.GetCharAt(Index: Integer): Char;
begin
    Result := FMarkedText.Ch[Index];
end;

function TvqMarkLabel.GetLink(Index: Integer): TvqMarkLink;
begin
    Result := FMarkedText.Link[Index];
end;

function TvqMarkLabel.GetLinesCount: Integer;
begin
    Result := FMarkedText.LinesCount;
end;

function TvqMarkLabel.GetRowCount: Integer;
begin
    Result := FMarkedText.RowCount;
end;

function TvqMarkLabel.GetTextLength: Integer;
begin
    Result := FMarkedText.TextLength;
end;

procedure TvqMarkLabel.SetOptions(Value: TvqMarkOptions);
begin
    if FOptions <> Value then begin
        FOptions := Value;
        UpdateMark;
    end;    
end;

procedure TvqMarkLabel.SetTextFormat(Value: TvqTextFormat);
begin
    FTextFormat.Assign(Value);
end;

procedure TvqMarkLabel.SetMarkStyle(Value: TvqMarkStyle);
begin
    FMarkStyle.Assign(Value);
end;

function TvqMarkLabel.GetText: string;
begin
    Result := FMarkedText._GetString(0, TextLength);
end;

procedure TvqMarkLabel.OnTextHyperlink(Sender: TObject; ALabel, AAddress, AHint: string; AIndex: Integer; var Opened: Boolean);
begin
    DoHyperlink(ALabel, AAddress, AHint, AIndex, Opened);
end;

procedure TvqMarkLabel.OnTextImageRequest(Sender: TObject; URI: string; Picture: TPicture; var Handled: Boolean);
begin
    DoImageRequest(URI, Picture, Handled);
end;

procedure TvqMarkLabel.OnMarkStyleUpdateMetrics(Sender: TObject);
begin
    UpdateMetrics;
end;

procedure TvqMarkLabel.OnTextFormatChange(Sender: TObject);
begin   
    UpdateMetrics;
end;

procedure TvqMarkLabel.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
var
    Sz: TSize;
    WrapWidth: Integer;
begin
    if WidthIsAnchored and FTextFormat.WordBreak then WrapWidth := ClientRect.Width
    else WrapWidth := 10000;
    WrapWidth := Constraints.MinMaxWidth(WrapWidth);
    
    Sz := FMarkedText.TextExtentFor(FTextFormat.Style, WrapWidth);
    PreferredWidth := Sz.Width;
    PreferredHeight := Sz.Height;
end;

function TvqMarkLabel.TextExtentFor(WrapWidth: Integer): TSize;
begin
    Result := FMarkedText.TextExtentFor(FTextFormat.Style, WrapWidth);
end;

procedure TvqMarkLabel.DoHyperlink(ALabel, AAddress, AHint: string; AIndex: Integer; var Opened: Boolean);
begin
    if Assigned(FOnHyperlink) then FOnHyperlink(Self, ALabel, AAddress, AHint, AIndex, Opened);
end;

procedure TvqMarkLabel.DoImageRequest(URI: string; Picture: TPicture; var Handled: Boolean);
begin
    if Assigned(FOnImageRequest) then FOnImageRequest(Self, URI, Picture, Handled);
end;

procedure TvqMarkLabel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    inherited;
    if PtInRect(ClientRect, Point(X, Y)) and (Button = mbLeft) then
        if FMarkedText.Perform(Self, MARK_CMD_DOWN, X, Y) then
            Repaint;
end;

procedure TvqMarkLabel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
    inherited;
    if (not(ssLeft in Shift)) and PtInRect(ClientRect, Point(X, Y)) then
        if FMarkedText.Perform(Self, MARK_CMD_MOVE, X, Y) then
            Repaint;
end;

procedure TvqMarkLabel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Cmd: Word;
begin
    inherited;
    if (Button = mbLeft) then begin
        Cmd := MARK_CMD_UP;
        if FAutoOpenURL then
            Cmd := Cmd or MARK_CMD_AUTOOPENURL;
        if FMarkedText.Perform(Self, Cmd, X, Y) then
            Repaint;
    end;
end;

procedure TvqMarkLabel.MouseEnter;
begin
    inherited;
    if FMarkedText.Perform(Self, MARK_CMD_ENTER, 0, 0) then
        Repaint;
end;

procedure TvqMarkLabel.MouseLeave;
begin
    inherited;
    if FMarkedText.Perform(Self, MARK_CMD_LEAVE, 0, 0) then
        Repaint;
end;

procedure TvqMarkLabel.UpdateMark;
var
    InputText: TvqStringText;
begin
    if FUpdatingBuffer then Exit;
    FUpdatingBuffer := True;
    
    InputText := TvqStringText.CreateConst(Caption);
    try
        if FMarkedText.Parse(InputText, FOptions) then begin
            FMarkedText.Locate(ClientRect, TextFormat.Style);
            InvalidatePreferredSize;
            AdjustSize;
        end;
    finally
        InputText.Free;
        FUpdatingBuffer := False;
    end;
end;

procedure TvqMarkLabel.UpdateMetrics;
begin
    if FUpdatingBuffer then begin
        inherited;
        Exit;
    end
    else begin
        FUpdatingBuffer := True;
        FMarkedText.Locate(ClientRect, TextFormat.Style);
        InvalidatePreferredSize;
        AdjustSize;
        FUpdatingBuffer := False;
        inherited;
    end;
end;

procedure TvqMarkLabel.TextChanged;
begin
    inherited;
    if not FPlainCaption then 
        UpdateMark;
end;

procedure TvqMarkLabel.ColorChanged;
begin
    inherited;
    Repaint;
end;

procedure TvqMarkLabel.FontChanged;
begin
    inherited;
    UpdateMetrics;
end;

procedure TvqMarkLabel.Resize;
begin
    inherited;
    if Parent <> nil then
        FMarkedText.Locate(ClientRect, TextFormat.Style);
end;

procedure TvqMarkLabel.Paint;
begin
    if Color = clDefault then
        Canvas.FullBrush(clNone)
    else
        Canvas.FullBrush(Color);
    FMarkedText.Render(Canvas, Enabled);
    inherited;
end;

end.
