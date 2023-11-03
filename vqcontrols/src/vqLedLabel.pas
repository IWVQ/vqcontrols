// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqLedLabel;

interface

uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Types, Classes, SysUtils, Graphics, Forms, Controls, StdCtrls, Buttons,
    ImgList, ActnList, Dialogs, ExtCtrls, Math,
    BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
    vqUtils, vqThemes, vqLedUtils;

type

    TvqLedLabel = class;
    
    TvqLedStyle = class(TPersistent)
    private
        FLabel: TvqLedLabel;
        
        FColorOnDisabled: TColor;
        FColorOffDisabled: TColor;
        FColorOn: TColor;
        FColorOff: TColor;
        FLedThickness: Integer;
        FLedWidth: Integer;
        FLedHeight: Integer;
        
        procedure SetColorOnDisabled(Value: TColor);
        procedure SetColorOffDisabled(Value: TColor);
        procedure SetColorOn(Value: TColor);
        procedure SetColorOff(Value: TColor);
        procedure SetLedThickness(Value: Integer);
        procedure SetLedWidth(Value: Integer);
        procedure SetLedHeight(Value: Integer);
    protected
        property _Label: TvqLedLabel read FLabel;
    public
        constructor Create(ALabel: TvqLedLabel); virtual;
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        procedure Invalidate;
        procedure UpdateMetrics;
    published
        property ColorOnDisabled: TColor read FColorOnDisabled write SetColorOnDisabled;
        property ColorOffDisabled: TColor read FColorOffDisabled write SetColorOffDisabled;
        property ColorOn: TColor read FColorOn write SetColorOn;
        property ColorOff: TColor read FColorOff write SetColorOff;
        property LedThickness: Integer read FLedThickness write SetLedThickness default 3;
        property LedWidth: Integer read FLedWidth write SetLedWidth default 10;
        property LedHeight: Integer read FLedHeight write SetLedHeight default 21;
    end;
    
    { TvqLedLabel }
    
    TvqLedKind = (vqlk7Segment, vqlk12Segment);
    
    TvqParseLedEvent = procedure (Sender: TObject; AText: IvqTextBuffer; var ALeds: TWordArray; var AHandled: Boolean);
    
    TvqLedLabel = class(TvqGraphicControl)
    private
        FStyle: TvqLedStyle;
        FBitmap: TBGRABitmap;
        FLeds: TWordArray;
        FDigitCount: Integer;
        FAlignment: TAlignment;
        FLayout: TTextLayout;
        FLedAlignment: TLeftRight;
        FKind: TvqLedKind;
        
        FOnParse: TvqParseLedEvent;
        function GetLed(Index: Integer): Word;
        procedure SetAlignment(AValue: TAlignment);
        procedure SetLayout(AValue: TTextLayout);
        procedure SetLed(Index: Integer; AValue: Word);
        procedure SetLedAlignment(AValue: TLeftRight);
        procedure SetDigitCount(AValue: Integer);
        procedure SetStyle(Value: TvqLedStyle); 
        procedure SetKind(Value: TvqLedKind);
        
        function CalculateExtent: TSize;
        function LedWidth(ALed: Word): Integer;
        
        procedure UpdateLeds;
    protected
        class function GetControlClassDefaultSize: TSize; override;
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        procedure TextChanged; override;
        procedure ColorChanged; override;
        procedure FontChanged; override;
        procedure Paint; override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        
        procedure SetNumberLeds(N: Double);
        procedure SetIntegerLeds(I: Integer);
        
        function Count: Integer;
        property Led[Index: Integer]: Word read GetLed write SetLed;
        property OnParse: TvqParseLedEvent read FOnParse write FOnParse;
    published
        property Spacing;
        property Style: TvqLedStyle read FStyle write SetStyle;
        property DigitCount: Integer read FDigitCount write SetDigitCount;
        property Alignment: TAlignment read FAlignment write SetAlignment;
        property Layout: TTextLayout read FLayout write SetLayout;
        property LedAlignment: TLeftRight read FLedAlignment write SetLedAlignment;
        property Kind: TvqLedKind read FKind write SetKind;
        property AutoSize default True;
        property BidiMode;
        property Caption;
        property Font;
        property ParentBidiMode;
        property ParentFont;
        property PopupMenu;
        property OnContextPopup;
    end;
    
implementation

{ TvqLedStyle }

constructor TvqLedStyle.Create(ALabel: TvqLedLabel);
begin
    inherited Create;
    FLabel := ALabel;
    FColorOnDisabled := clGrayText;
    FColorOffDisabled := clSilver;
    FColorOn := clRed;
    FColorOff := clSilver;
    FLedWidth := 10;
    FLedThickness := 3;
    FLedHeight := 21;
end;

destructor TvqLedStyle.Destroy;
begin
    inherited;
end;

procedure TvqLedStyle.Assign(Source: TPersistent);
begin
    inherited Assign(Source);
    if (Source is TvqLedStyle) and (Source <> Self) then begin
        FColorOnDisabled := TvqLedStyle(Source).FColorOnDisabled;
        FColorOffDisabled:= TvqLedStyle(Source).FColorOffDisabled;
        FColorOn         := TvqLedStyle(Source).FColorOn      ;
        FColorOff        := TvqLedStyle(Source).FColorOff     ;
        Invalidate;
    end;
end;

procedure TvqLedStyle.SetColorOnDisabled(Value: TColor);
begin
    if FColorOnDisabled <> Value then begin
        FColorOnDisabled := Value;
        Invalidate;
    end;
end;

procedure TvqLedStyle.SetColorOffDisabled(Value: TColor);
begin
    if FColorOffDisabled <> Value then begin
        FColorOffDisabled := Value;
        Invalidate;
    end;
end;

procedure TvqLedStyle.SetColorOn(Value: TColor);
begin
    if FColorOn <> Value then begin
        FColorOn := Value;
        Invalidate;
    end;
end;

procedure TvqLedStyle.SetColorOff(Value: TColor);
begin
    if FColorOff <> Value then begin
        FColorOff := Value;
        Invalidate;
    end;
end;

procedure TvqLedStyle.SetLedWidth(Value: Integer);
begin
    if FLedWidth <> Value then begin
        FLedWidth := Value;
        UpdateMetrics;
    end;
end;

procedure TvqLedStyle.SetLedThickness(Value: Integer);
begin
    if FLedThickness <> Value then begin
        FLedThickness := Value;
        UpdateMetrics;
    end;
end;

procedure TvqLedStyle.SetLedHeight(Value: Integer);
begin
    if FLedHeight <> Value then begin
        FLedHeight := Value;
        UpdateMetrics;
    end;
end;

procedure TvqLedStyle.UpdateMetrics;
begin
    if FLabel = nil then Exit;
    FLabel.InvalidatePreferredSize;
    FLabel.AdjustSize;
end;

procedure TvqLedStyle.Invalidate;
begin
    if FLabel <> nil then 
        FLabel.Invalidate;
end;

{ TvqLedLabel }

constructor TvqLedLabel.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FStyle := TvqLedStyle.Create(Self);
    
    FBitmap := TBGRABitmap.Create(1, 1, clNone);
    
    ControlStyle := ControlStyle - [csSetCaption];
    FDigitCount := 5;
    FAlignment := taLeftJustify;
    FLayout := tlCenter;
    FLedAlignment := taRightJustify;
    FKind := vqlk7Segment;
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
    Caption :=  '0';
    Spacing := 3;
    AutoSize := True;
end;

destructor TvqLedLabel.Destroy;
begin
    FBitmap.Free;
    FLeds := nil;
    FStyle.Free;
    inherited;
end;

class function TvqLedLabel.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 120;
    Result.cy := 17;
end;

function TvqLedLabel.Count: Integer;
begin
    Result := Length(FLeds);
end;

procedure TvqLedLabel.SetNumberLeds(N: Extended);
begin
    Caption := FloatToStr(N);
end;

procedure TvqLedLabel.SetIntegerLeds(I: Integer);
begin
    Caption := IntToStr(I);
end;

procedure TvqLedLabel.CalculatePreferredSize(var PreferredWidth,
    PreferredHeight: Integer; WithThemeSpace: Boolean);
var
    Sz: TSize;
begin
    Sz := CalculateExtent;
    PreferredWidth := Sz.cx + 1;
    PreferredHeight := Sz.cy;
end;

function TvqLedLabel.GetLed(Index: Integer): Word;
begin
    if (Index >= 0) and (Index < Count) then
        Result := FLeds[Index]
    else
        Result := LED_SPEC_EMPTY;
end;

procedure TvqLedLabel.SetAlignment(AValue: TAlignment);
begin
    if FAlignment <> AValue then begin
        FAlignment := AValue;
        Invalidate;
    end;
end;

procedure TvqLedLabel.SetLayout(AValue: TTextLayout);
begin
    if FLayout <> AValue then begin
        FLayout := AValue;
        Invalidate;
    end;
end;

procedure TvqLedLabel.SetLed(Index: Integer; AValue: Word);
begin
    if (Index >= 0) and (Index < Count) then begin
        FLeds[Index] := AValue;
        InvalidatePreferredSize;
        AdjustSize;
        Repaint;
    end;
end;

procedure TvqLedLabel.SetLedAlignment(AValue: TLeftRight);
begin
    if FLedAlignment <> AValue then begin
        FLedAlignment := AValue;
        UpdateLeds;
    end;
end;

procedure TvqLedLabel.SetDigitCount(AValue: Integer);
begin                     
    if AValue < 0 then AValue := 0;
    if FDigitCount <> AValue then begin
        FDigitCount := AValue;
        UpdateLeds;
    end;
end;

procedure TvqLedLabel.SetKind(Value: TvqLedKind);
begin
    if FKind <> Value then begin
        FKind := Value;
        UpdateLeds;
    end;
end;
 
procedure TvqLedLabel.SetStyle(Value: TvqLedStyle);
begin
    FStyle.Assign(Value);
end;

procedure TvqLedLabel.TextChanged; 
begin
    inherited;
    UpdateLeds;
end;

procedure TvqLedLabel.ColorChanged;
begin
    inherited;
    Invalidate;
end;

procedure TvqLedLabel.FontChanged; 
begin
    inherited;
    InvalidatePreferredSize;
    AdjustSize;
end;

function TvqLedLabel.CalculateExtent: TSize;
var
    I: Integer;
begin
    Result.cx := 0;
    for I := 0 to Count - 1 do begin
        if I > 0 then Inc(Result.cx, Spacing);
        Inc(Result.cx, LedWidth(FLeds[I]));
    end;
    Result.cy := Style.LedHeight;
end;

function TvqLedLabel.LedWidth(ALed: Word): Integer;
begin
    if (ALed and LED_SPEC_MASK) <> 0 then begin
        case ALed and LED_SPEC_MASK of
            LED_SPEC_EMPTY: Result := Style.LedWidth;
            LED_SPEC_DOT  : Result := Style.LedThickness;
            LED_SPEC_UPDOT: Result := Style.LedThickness;
            LED_SPEC_COLON: Result := Style.LedThickness;
            else Result := 0;
        end;
    end
    else Result := Style.LedWidth;
end;

procedure TvqLedLabel.UpdateLeds;
var
    NewLeds: TWordArray;
    Handled: Boolean;
    AText: TvqStringText;
begin
    AText := TvqStringText.CreateConst(Caption);
    try
        Handled := False;
        if Assigned(FOnParse) then begin
            NewLeds := nil;
            FOnParse(Self, AText, NewLeds, Handled);
        end;
        if not Handled then begin
            if FKind = vqlk7Segment then
                Handled := Parse7SegmentLeds(AText, NewLeds, DigitCount, LedAlignment)
            else
                Handled := Parse12SegmentLeds(AText, NewLeds, DigitCount, LedAlignment);
        end;
        if Handled then begin
            FLeds := NewLeds;
            NewLeds := nil;
            InvalidatePreferredSize;
            AdjustSize;
        end;
    finally
        AText.Free;
    end;
end;

procedure TvqLedLabel.Paint;
var
    Sz: TSize;       
    Client: TRect;
    ClOn, ClOff: TColor;
    X, Y: Integer;
begin
    Client := ClientRect;
    
    ClOn := IfThenElse(Enabled, Style.ColorOn, Style.ColorOnDisabled);
    ClOff := IfThenElse(Enabled, Style.ColorOff, Style.ColorOffDisabled);
    
    Sz := CalculateExtent;
    case FAlignment of
        taLeftJustify: X := Client.Left;
        taCenter: X := (Client.Left + Client.Right - Sz.cx) div 2;
        taRightJustify: X := Client.Right - Sz.cx;
    end;
    case FLayout of
        tlTop: Y := Client.Top;
        tlCenter: Y := (Client.Top + Client.Bottom - Sz.cy) div 2;
        tlBottom: Y := Client.Bottom - Sz.cy;
    end;
    
    FBitmap.SetSize(Client.Width, Client.Height);
    if Color = clDefault then
        FBitmap.Fill(clNone)
    else
        FBitmap.Fill(Color);
    
    if FKind = vqlk7Segment then
        Render7SegmentLeds(FBitmap, Client, X, Y, FLeds,
            ClOn, ClOff,
            Style.LedWidth, Style.LedHeight, Style.LedThickness, Spacing)
    else
        Render12SegmentLeds(FBitmap, Client, X, Y, FLeds,
            ClOn, ClOff,
            Style.LedWidth, Style.LedHeight, Style.LedThickness, Spacing);
    
    FBitmap.Draw(Canvas, 0, 0, False);
    inherited;
end;

end.
