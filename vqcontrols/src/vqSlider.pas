// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqSlider;

interface

uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Classes, Types, SysUtils, Controls, Graphics, Math, ExtCtrls, ComCtrls,
    Dialogs,
    vqUtils, vqThemes, vqToolTip;
    
type
    
    TvqSliderTipPosition = (vqsTipNone, vqsTipLeft, vqsTipTop, vqsTipRight, vqsTipBottom);

    TvqTickOption = (vqtoTopLeft, vqtoBottomRight);
    TvqTickOptions = set of TvqTickOption;
    
	TvqSliderPart = (vqspNone, vqspKnob, vqspTrack);
	
    TvqDrawSliderTickEvent = procedure (Sender: TObject; ACanvas: TCanvas; X, Y: Integer;
        AValue: Double; APosition: TvqPosition) of object;
    
	TvqSlider = class(TvqCustomControl)
	private
        FBackBmp: TBitmap;
        
		FOrientation: TvqOrientation;
		FTickOptions: TvqTickOptions;
        
		FMin: Double;
		FMax: Double;
		FPosition: Double;
		FFrequency: Double;
        FReverse: Boolean;
        FIncrement: Double;
        FCustomTicks: TDblArray;
        
        FMargin: Integer;
        FPadding: Integer;
        FKnobSize: Integer;
        FDiscrete: Boolean;
        FMagnetic: Boolean;
        
        FToolTip: TvqToolTip;
        FTipPosition: TvqSliderTipPosition;
        
		FKnob: TRect;
		FTrack: TRect;
        FPageUp: TRect;
        FPageDown: TRect;
        FHotPart: TvqSliderPart;
        FPressedPart: TvqSliderPart;
        
        FOnDrawTick: TvqDrawSliderTickEvent;
        
		procedure SetOrientation(Value: TvqOrientation);
		procedure SetTickOptions(Value: TvqTickOptions);
		procedure SetMin(Value: Double);
		procedure SetMax(Value: Double);
		procedure SetPosition(Value: Double);
		procedure SetFrequency(Value: Double);
        procedure SetReverse(Value: Boolean);
        procedure SetMargin(Value: Integer);
        procedure SetPadding(Value: Integer);
        procedure SetKnobSize(Value: Integer);
        procedure SetDiscrete(Value: Boolean);
        
		procedure CNKeyDown(var Message: TLMKeyDown); message CN_KEYDOWN;
		procedure CNKeyUp(var Message: TLMKeyUp); message CN_KEYUP;
        
        procedure SetState(APressedPart, AHotPart: TvqSliderPart);
        
        procedure CalculateMetrics;
        procedure CalculateTrackMetrics;
        procedure CalculateTicks;
		procedure FinishSliding;
        procedure ActivateToolTip;
        
    strict protected type
        TTick = record
            Pix: Integer;
            Value: Double;
        end;
    strict protected
        FTickBuffer: array of TTick;
    protected
        procedure DrawLeftTicks(ACanvas: TCanvas); virtual;
        procedure DrawTopTicks(ACanvas: TCanvas); virtual;
        procedure DrawRightTicks(ACanvas: TCanvas); virtual;
        procedure DrawBottomTicks(ACanvas: TCanvas); virtual;
	protected
        
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure MouseEnter; override;
		procedure MouseLeave; override;
		procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure KeyUp(var Key: Word; Shift: TShiftState); override;
        
        procedure UpdateMetrics; override;
        procedure ColorChanged; override;
        procedure FocusChanged(AFocused: Boolean); override;
        procedure EnabledChanged; override;
        procedure VisibleChanged; override;
        procedure CancelMode; override;
        procedure FontChanged; override;
		procedure Resize; override;
        
        procedure DoDrawTick(ACanvas: TCanvas; X, Y: Integer; AValue: Double; APosition: TvqPosition); virtual;
		procedure Paint; override;
        
        class function GetControlClassDefaultSize: TSize; override;
    public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
        procedure SetParams(AMin, AMax, APos: Double);
        
        function DiscreteValue: Integer;
        function MagneticPositionFromPoint(P: TPoint): Double;
        function PointFromPosition(Pos: Double): TPoint;
		function PositionFromPoint(P: TPoint): Double;
        function PartFromPoint(P: TPoint): TvqSliderPart;
        
        procedure ClearCustomTicks;
        procedure AddCustomTick(ATick: Double);
        function CustomTicksCount: Integer;
        function CustomTickAt(AIndex: Integer): Double;
        property ToolTip: TvqToolTip read FToolTip write FToolTip;
	published
        property Orientation: TvqOrientation read FOrientation write SetOrientation;
		property TickOptions: TvqTickOptions read FTickOptions write SetTickOptions;
		property Min: Double read FMin write SetMin;
		property Max: Double read FMax write SetMax;
		property Frequency: Double read FFrequency write SetFrequency;
		property Position: Double read FPosition write SetPosition;
		property Increment: Double read FIncrement write FIncrement;
        property Reverse: Boolean read FReverse write SetReverse;
        property Margin: Integer read FMargin write SetMargin;
        property Padding: Integer read FPadding write SetPadding;
        property Discrete: Boolean read FDiscrete write SetDiscrete;
        property Magnetic: Boolean read FMagnetic write FMagnetic;
        property KnobSize: Integer read FKnobSize write SetKnobSize;
        property TipPosition: TvqSliderTipPosition read FTipPosition write FTipPosition;
        property OnDrawTick: TvqDrawSliderTickEvent read FOnDrawTick write FOnDrawTick;
        
        property Font;
        property ParentFont;
        property PopupMenu;
        property TabOrder;
        property TabStop;
        property OnChange;
        property OnContextPopup;
    end;
    
implementation

function HorizontalPointFromValue(ATrack: TRect; APadding: Integer;
    AMin, AMax, AValue: Double; AReverse: Boolean): TPoint;
var
    XY: Integer;
begin
    Result.Y := (ATrack.Top + ATrack.Bottom) div 2;
    if SameValue(AMin, AMax) then XY := 0
    else XY := MathRound((AValue - AMin)*(ATrack.Width - 2*APadding - 1)/(AMax - AMin));
    if AReverse then Result.X := ATrack.Right - APadding - XY - 1
    else Result.X := ATrack.Left + APadding + XY;
end;

function VerticalPointFromValue(ATrack: TRect; APadding: Integer;
    AMin, AMax, AValue: Double; AReverse: Boolean): TPoint;
var
    XY: Integer;
begin
    Result.X := (ATrack.Left + ATrack.Right) div 2;
    if SameValue(AMax, AMin) then XY := 0
    else XY := MathRound((AValue - AMin)*(ATrack.Height - 2*APadding - 1)/(AMax - AMin));
    if AReverse then Result.Y := ATrack.Top + APadding + XY
    else Result.Y := ATrack.Bottom - APadding - XY - 1;
end;

function HorizontalValueFromPoint(AMin, AMax: Double; APoint: TPoint;
    ATrack: TRect; APadding: Integer; AReverse: Boolean): Double;
var
    D: Integer;
begin
    if ATrack.Width - 2*APadding - 1 <= 0 then Result := AMin
    else begin
        if AReverse then D := ATrack.Right - APadding - 1 - APoint.X
        else D := APoint.X - ATrack.Left - APadding;
        Result := AMin + D*(AMax - AMin)/(ATrack.Width - 2*APadding - 1);
    end;
    if Result < AMin then Result := AMin;
	if Result > AMax then Result := AMax;
end;

function VerticalValueFromPoint(AMin, AMax: Double; APoint: TPoint;
    ATrack: TRect; APadding: Integer; AReverse: Boolean): Double;
var
    D: Integer;
begin
    if ATrack.Height - 2*APadding - 1 <= 0 then Result := AMin
    else begin
        if AReverse then D := APoint.Y - ATrack.Top - APadding
        else D := ATrack.Bottom - APadding - 1 - APoint.Y;
        Result := AMin + D*(AMax - AMin)/(ATrack.Height - 2*APadding - 1);
    end;
    if Result < AMin then Result := AMin;
	if Result > AMax then Result := AMax;
end;

{ TvqSlider }

constructor TvqSlider.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FBackBmp := TBitmap.Create;
    with GetControlClassDefaultSize do begin
        FBackBmp.Width := cx;
        FBackBmp.Height := cy;
    end;
    
	FOrientation := vqHorizontal;
    FTickOptions := [];
    
    FReverse := False;
	FMin := 0;
	FMax := 10;
	FPosition := 0;
	FFrequency := 1;
    FIncrement := 1;
    FCustomTicks := nil;
    FToolTip := nil;
    FTipPosition := vqsTipTop;
    
    FMargin := 20;
    FPadding := 5;
    FKnobSize := 10;
    FDiscrete := True;
    
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
    
    CalculateMetrics;
end;

destructor TvqSlider.Destroy;
begin
    FBackBmp.Free;
    inherited;
end;

class function TvqSlider.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 150;
    Result.cy := 70;
end;

procedure TvqSlider.SetParams(AMin, AMax, APos: Double);
var
    PrevPos: Double;
    NeedNewTicks: Boolean;
begin
    if FDiscrete then begin
        AMax := Floor(AMax);
        AMin := Ceil(AMin);
        APos := MathRound(APos);
    end;
    if AMax < AMin then begin
        if AMax = FMax then AMin := AMax
        else AMax := AMin;
    end;
    if APos < AMin then APos := AMin;
    if APos > AMax then APos := AMax;
    NeedNewTicks := (FMin <> AMin) or (FMax <> AMax);
    if (FPosition <> APos) or (FMin <> AMin) or (FMax <> AMax) then begin
        PrevPos := FPosition;
        FPosition := APos;
        FMin := AMin;
        FMax := AMax;
        if NeedNewTicks then
            CalculateMetrics
        else
            CalculateTrackMetrics;
        Repaint;
        if PrevPos <> FPosition then
            Changed;
    end;
end;

function TvqSlider.DiscreteValue: Integer;
var
    MinD, MaxD: Integer;
begin
    if Discrete then Result := Trunc(FPosition) 
    else begin
        MinD := Ceil(FMin);
        MaxD := Floor(FMax);
        Result := MathRound(FPosition);
        if Result < MinD then Result := MinD;
        if Result > MaxD then Result := MaxD;
    end;
end;

function TvqSlider.MagneticPositionFromPoint(P: TPoint): Double;
label LBL_CUSTOM;
var
    M, N, I, ValuePix: Integer;
    Threshold: Integer;
begin
    Result := PositionFromPoint(P);
    Threshold := FKnobSize div 2;
    
    if FOrientation = vqHorizontal then
        ValuePix := P.X
    else
        ValuePix := P.Y;
        
    if SameValue(FFrequency, 0) then goto LBL_CUSTOM;
    
    // default ticks
    M := Floor((FMax - FMin)/FFrequency);
    N := MathRound((Result - FMin)/FFrequency);
    if M < N then Dec(N);
    if Abs(ValuePix - FTickBuffer[N].Pix) <= Threshold then begin
        Result := FTickBuffer[N].Value;
        Exit;
    end;
    
LBL_CUSTOM:
    // custom ticks
    for I := M + 1 to Length(FTickBuffer) - 1 do begin
        if Abs(ValuePix - FTickBuffer[I].Pix) <= Threshold then begin
            Result := FTickBuffer[I].Value;
            Break;
        end;
    end;
end;

function TvqSlider.PointFromPosition(Pos: Double): TPoint;
begin
    if FOrientation = vqHorizontal then
        Result := HorizontalPointFromValue(FTrack, FPadding, FMin, FMax, Pos, FReverse)
    else
        Result := VerticalPointFromValue(FTrack, FPadding, FMin, FMax, Pos, FReverse);
end;

function TvqSlider.PositionFromPoint(P: TPoint): Double;
begin
    if FOrientation = vqHorizontal then
        Result := HorizontalValueFromPoint(FMin, FMax, P, FTrack, FPadding, FReverse)
    else
        Result := VerticalValueFromPoint(FMin, FMax, P, FTrack, FPadding, FReverse)
end;

function TvqSlider.PartFromPoint(P: TPoint): TvqSliderPart;
begin
    if PtInRect(FKnob, P) then Result := vqspKnob
    else if PtInRect(FTrack, P) then Result := vqspTrack
    else Result := vqspNone;
end;

procedure TvqSlider.ClearCustomTicks;
begin
    if FCustomTicks <> nil then begin
        FCustomTicks := nil;
        CalculateMetrics;
        Invalidate;
    end;
end;

procedure TvqSlider.AddCustomTick(ATick: Double);
var
    L: Integer;
begin
    L := Length(FCustomTicks);
    SetLength(FCustomTicks, L + 1);
    FCustomTicks[L] := ATick;
    CalculateMetrics;
    Invalidate;
end;

function TvqSlider.CustomTicksCount: Integer;
begin
    Result := System.Length(FCustomTicks);
end;

function TvqSlider.CustomTickAt(AIndex: Integer): Double;
begin
    if (AIndex >= 0) and (AIndex < CustomTicksCount) then
        Result := FCustomTicks[AIndex]
    else
        Result := NAN;
end;

procedure TvqSlider.SetOrientation(Value: TvqOrientation);
begin
	if FOrientation <> Value then begin
		FOrientation := Value;
		if not (csLoading in ComponentState) then
			SetBounds(Left, Top, Height, Width)
		else 
			CalculateMetrics;
		Invalidate;
	end;
end;

procedure TvqSlider.SetTickOptions(Value: TvqTickOptions);
begin
    if FTickOptions <> Value then begin
        FTickOptions := Value;
        CalculateMetrics;
        Invalidate;
    end;
end;

procedure TvqSlider.SetMin(Value: Double);
begin
    SetParams(Value, FMax, FPosition);
end;

procedure TvqSlider.SetMax(Value: Double);
begin
    SetParams(FMin, Value, FPosition);
end;

procedure TvqSlider.SetPosition(Value: Double);
begin
    SetParams(FMin, FMax, Value);
end;

procedure TvqSlider.SetFrequency(Value: Double);
begin
    if FDiscrete then Value := Trunc(Value);
	if FFrequency <> Value then begin
		FFrequency := Value;
        CalculateMetrics;
		Invalidate;
	end;
end;

procedure TvqSlider.SetReverse(Value: Boolean);
begin
    if FReverse <> Value then begin
        FReverse := Value;
        CalculateMetrics;
        Invalidate;
    end;
end;

procedure TvqSlider.SetMargin(Value: Integer);
begin
    if FMargin <> Value then begin
        FMargin := Value;
        CalculateMetrics;
        Invalidate;
    end;
end;

procedure TvqSlider.SetPadding(Value: Integer);
begin
    if FPadding <> Value then begin
        FPadding := Value;
        CalculateMetrics;
        Invalidate;
    end;
end;

procedure TvqSlider.SetKnobSize(Value: Integer);
begin
    if FKnobSize <> Value then begin
        FKnobSize := Value;
        CalculateMetrics;
        Invalidate;
    end;
end;

procedure TvqSlider.SetDiscrete(Value: Boolean);
begin
    if FDiscrete <> Value then begin
        FDiscrete := Value;
        FFrequency := Trunc(FFrequency);
        SetParams(FMin, FMax, FPosition);
    end;
end;

procedure TvqSlider.CNKeyDown(var Message: TLMKeyDown);
begin
    case Message.CharCode of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN:;
		else inherited;
	end;
end;

procedure TvqSlider.CNKeyUp(var Message: TLMKeyUp);
begin
	case Message.CharCode of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN:;
		else inherited;
	end;
end;

procedure TvqSlider.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Part: TvqSliderPart;
begin
    inherited MouseDown(Button, Shift, X, Y);
    if Button = mbLeft then begin
        Part := PartFromPoint(Point(X, Y));
        if Part = vqspTrack then begin
            if FMagnetic then
                SetPosition(MagneticPositionFromPoint(Point(X, Y)))
            else
                SetPosition(PositionFromPoint(Point(X, Y)));
            Part := vqspKnob;
        end;
        if Part = vqspKnob then begin
            ActivateToolTip;
        end;
        SetState(Part, FHotPart);
    end;
end;

procedure TvqSlider.MouseEnter;
begin
    inherited;
end;

procedure TvqSlider.MouseLeave;
begin
    inherited;
    SetState(vqspNone, vqspNone);
end;

procedure TvqSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
var
    Part: TvqSliderPart;
    P: TPoint;
begin
    inherited MouseMove(Shift, X, Y);
    P := Point(X, Y);
    Part := PartFromPoint(P);
    if FPressedPart = vqspKnob then begin
        if FMagnetic then
            Position := MagneticPositionFromPoint(P)
        else
            Position := PositionFromPoint(P);
        ActivateToolTip;
    end
    else
        SetState(vqspNone, Part);
end;

procedure TvqSlider.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseUp(Button, Shift, X, Y);  
    FinishSliding;
    SetState(vqspNone, PartFromPoint(Point(X, Y)));
end;

procedure TvqSlider.KeyDown(var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_RIGHT: if FOrientation = vqHorizontal then Position := Position + FIncrement;
		VK_LEFT: if FOrientation = vqHorizontal then Position := Position - FIncrement;
		VK_UP: if FOrientation = vqVertical then Position := Position + FIncrement;
		VK_DOWN: if FOrientation = vqVertical then Position := Position - FIncrement;
		VK_PRIOR: Position := Position - FIncrement;
		VK_NEXT: Position := Position + FIncrement;
		VK_END: Position := FMax;
		VK_HOME: Position := FMin;
	end;
	inherited;
	case Key of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_END, VK_HOME, VK_SPACE: Key := 0;
	end;
end;

procedure TvqSlider.KeyUp(var Key: Word; Shift: TShiftState);
begin
	inherited;
	case Key of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_END, VK_HOME, VK_SPACE: Key := 0;
	end;
end;

procedure TvqSlider.SetState(APressedPart, AHotPart: TvqSliderPart);
begin
    if APressedPart <> vqspNone then
        AHotPart := FPressedPart;
    if (FPressedPart <> APressedPart) or (FHotPart <> AHotPart) then begin
        FPressedPart := APressedPart;
        FHotPart := AHotPart;
        Repaint;
    end;
end;

procedure TvqSlider.UpdateMetrics;
begin
    CalculateMetrics;
    inherited;
end;

procedure TvqSlider.ColorChanged;   
begin
    inherited;
    Invalidate;
end;

procedure TvqSlider.FocusChanged(AFocused: Boolean);   
begin
    inherited;
    Invalidate;
end;

procedure TvqSlider.EnabledChanged; 
begin
    inherited;
    FinishSliding;
    Invalidate;
end;

procedure TvqSlider.VisibleChanged; 
begin
    inherited;
    FinishSliding;
end;

procedure TvqSlider.CancelMode;
begin
    inherited;
    FinishSliding;
end;

procedure TvqSlider.FontChanged;
begin
    inherited;
    CalculateMetrics;
    Invalidate;
end;

procedure TvqSlider.Resize;
begin
    inherited;
    FBackBmp.Width := Width;
    FBackBmp.Height := Height;
    
    CalculateMetrics;
end;

procedure TvqSlider.CalculateMetrics;
begin
    CalculateTrackMetrics;
    CalculateTicks;
end;

procedure TvqSlider.CalculateTrackMetrics;
var
    P: TPoint;
    Client: TRect;
begin
    Client := ClientRect;
    P := PointFromPosition(FPosition);
    FTrack := Client;
    if FOrientation = vqHorizontal then begin
        if vqtoBottomRight in FTickOptions then
            Dec(FTrack.Bottom, FMargin);
        if vqtoTopLeft in FTickOptions then
            Inc(FTrack.Top, FMargin);
        FKnob.Left := P.X - FKnobSize div 2;
        FKnob.Top := FTrack.Top;
        FKnob.Right := FKnob.Left + FKnobSize;
        FKnob.Bottom := FTrack.Bottom;
        FPageDown := FTrack;
        FPageDown.Right := FKnob.Left;
        FPageUp := FTrack;
        FPageUp.Left := FKnob.Right;
    end
    else begin
        if vqtoBottomRight in FTickOptions then
            Dec(FTrack.Right, FMargin);
        if vqtoTopLeft in FTickOptions then
            Inc(FTrack.Left, FMargin);
        FKnob.Top := P.Y - FKnobSize div 2;
        FKnob.Left := FTrack.Left;
        FKnob.Bottom := FKnob.Top + FKnobSize;
        FKnob.Right := FTrack.Right;
        FPageUp := FTrack;
        FPageUp.Bottom := FKnob.Top;
        FPageDown := FTrack;
        FPageDown.Top := FKnob.Bottom;
    end;
end;

procedure TvqSlider.CalculateTicks;
var
    L, K, I: Integer;
begin
    if FFrequency = 0 then L := 0
    else L := Trunc((FMax - FMin)/FFrequency) + 1;
    SetLength(FTickBuffer, L + Length(FCustomTicks));
    for K := 0 to L - 1 do
        FTickBuffer[K].Value := FMin + K*FFrequency;
    for I := 0 to Length(FCustomTicks) - 1 do
        FTickBuffer[I + L].Value := FCustomTicks[I];
    L := Length(FTickBuffer);
    if FOrientation = vqHorizontal then begin
        for I := 0 to L - 1 do
            FTickBuffer[I].Pix := HorizontalPointFromValue(FTrack, FPadding, 
                FMin, FMax, FTickBuffer[I].Value, FReverse).X;
    end
    else begin
        for I := 0 to L - 1 do
            FTickBuffer[I].Pix := VerticalPointFromValue(FTrack, FPadding, 
                FMin, FMax, FTickBuffer[I].Value, FReverse).Y;
    end;
end;

procedure TvqSlider.FinishSliding;
begin
    if (FPressedPart = vqspKnob) and (FToolTip <> nil) and (FToolTip.TipActive) then begin
        FToolTip.HideTip;
    end;
    CalculateTrackMetrics;
    Repaint;
end;

procedure TvqSlider.ActivateToolTip;
var
    Str: string;
    Sz: TSize;
    TipR, Client: TRect;
    P: TPoint;
begin
    if (FToolTip <> nil) and (FTipPosition <> vqsTipNone) then begin
        Client := ClientRect;
        Str := FloatToStr(Position);
        Sz := FToolTip.CalculateExtent(Str);
        P := FKnob.CenterPoint;
        if FOrientation = vqHorizontal then
            case FTipPosition of
                vqsTipLeft: begin
                    TipR.Left := Client.Left - Sz.cx;
                    TipR.Top := (FTrack.Top + FTrack.Bottom - Sz.cy) div 2;
                end;
                vqsTipTop: begin
                    TipR.Left := P.X - Sz.cx div 2;
                    TipR.Top := Client.Top - Sz.cy;
                end;
                vqsTipRight: begin
                    TipR.Left := Client.Right;
                    TipR.Top := (FTrack.Top + FTrack.Bottom - Sz.cy) div 2;
                end;
                vqsTipBottom: begin
                    TipR.Top := Client.Bottom;
                    TipR.Left := P.X - Sz.cx div 2;
                end;
            end
        else
            case FTipPosition of
                vqsTipLeft: begin
                    TipR.Left := Client.Left - Sz.cx;
                    TipR.Top := P.Y - Sz.cy div 2;
                end;
                vqsTipTop: begin
                    TipR.Left := (FTrack.Left + FTrack.Right - Sz.cx) div 2;
                    TipR.Top := Client.Top - Sz.cy;
                end;
                vqsTipRight: begin
                    TipR.Left := Client.Right;
                    TipR.Top := P.Y - Sz.cy div 2;
                end;
                vqsTipBottom: begin
                    TipR.Top := Client.Bottom;
                    TipR.Left := (FTrack.Left + FTrack.Right - Sz.cx) div 2;
                end;
            end;
        TipR.TopLeft := ClientToScreen(TipR.TopLeft);
        TipR.Size := Sz;
        FToolTip.ShowTip(TipR, Str);
    end;
end;

procedure TvqSlider.DoDrawTick(ACanvas: TCanvas; X, Y: Integer; AValue: Double; APosition: TvqPosition);
begin
    if Assigned(FOnDrawTick) then FOnDrawTick(Self, ACanvas, X, Y, AValue, APosition);
end;

procedure TvqSlider.DrawLeftTicks(ACanvas: TCanvas);
var
    Xf, Xt, Y, I: Integer;
begin
    ACanvas.ThinPen(vqThemeManager.TickColor);
    for I := 0 to Length(FTickBuffer) - 1 do begin
        Y := FTickBuffer[I].Pix;
        Xf := FTrack.Left - 1;
        Xt := Xf - 5;
        ACanvas.MoveTo(Xf, Y);
        ACanvas.LineTo(Xt, Y);
        DoDrawTick(ACanvas, Xf, Y, FTickBuffer[I].Value, vqLeft);
    end;
end;

procedure TvqSlider.DrawTopTicks(ACanvas: TCanvas);
var
    Yf, Yt, X, I: Integer;
begin
    ACanvas.ThinPen(vqThemeManager.TickColor);
    for I := 0 to Length(FTickBuffer) - 1 do begin
        X := FTickBuffer[I].Pix;
        Yf := FTrack.Top - 1;
        Yt := Yf - 5;
        ACanvas.MoveTo(X, Yf);
        ACanvas.LineTo(X, Yt);
        DoDrawTick(ACanvas, X, Yf, FTickBuffer[I].Value, vqTop);
    end;
end;

procedure TvqSlider.DrawRightTicks(ACanvas: TCanvas);
var
    Xf, Xt, Y, I: Integer;
begin
    ACanvas.ThinPen(vqThemeManager.TickColor);
    for I := 0 to Length(FTickBuffer) - 1 do begin
        Y := FTickBuffer[I].Pix;
        Xf := FTrack.Right;
        Xt := Xf + 5;
        ACanvas.MoveTo(Xf, Y);
        ACanvas.LineTo(Xt, Y);
        DoDrawTick(ACanvas, Xf, Y, FTickBuffer[I].Value, vqRight);
    end;
end;

procedure TvqSlider.DrawBottomTicks(ACanvas: TCanvas);
var
    Yf, Yt, X, I: Integer;
begin
    ACanvas.ThinPen(vqThemeManager.TickColor);
    for I := 0 to Length(FTickBuffer) - 1 do begin
        X := FTickBuffer[I].Pix;
        Yf := FTrack.Bottom;
        Yt := Yf + 5;
        ACanvas.MoveTo(X, Yf);
        ACanvas.LineTo(X, Yt);
        DoDrawTick(ACanvas, X, Yf, FTickBuffer[I].Value, vqBottom);
    end;
end;

procedure TvqSlider.Paint;
var
    Client: TRect;
    AState, AKnobState: TvqThemeState;
begin
    Client := ClientRect;
    if not Enabled then AState := [vqthDisabled]
    else if FHotPart = vqspKnob then AState := [vqthHovered]
    else if FHotPart = vqspTrack then AState := [vqthHot]
    else AState := [vqthNormal];
    
    if not Enabled then AKnobState := [vqthDisabled]
    else if FHotPart = vqspTrack then AKnobState := [vqthHovered]
    else if FHotPart = vqspKnob then AKnobState := [vqthHot]
    else if FPressedPart = vqspKnob then AKnobState := [vqthPressed]
    else AKnobState := [vqthNormal];
    if Focused then Include(AKnobState, vqthFocused);

    if (Color = clDefault) or (Color = clNone) then
        FBackBmp.Canvas.CopyRect(Client, Canvas, Client)
    else begin
        FBackBmp.Canvas.FullBrush(Color);
        FBackBmp.Canvas.FillRect(Client);
    end;

    if FOrientation = vqHorizontal then begin
        vqThemeManager.DrawHorzSlider(Self, FBackBmp.Canvas, FTrack, FKnob,
            vqtoTopLeft in TickOptions, vqtoBottomRight in TickOptions,
            AState, AKnobState);
        
        if vqtoBottomRight in FTickOptions then
            DrawBottomTicks(FBackBmp.Canvas);
        if vqtoTopLeft in FTickOptions then
            DrawTopTicks(FBackBmp.Canvas);
    end
    else begin
        vqThemeManager.DrawVertSlider(Self, FBackBmp.Canvas, FTrack, FKnob, 
            vqtoTopLeft in TickOptions, vqtoBottomRight in TickOptions, 
            AState, AKnobState);
        
        if vqtoBottomRight in FTickOptions then
            DrawRightTicks(FBackBmp.Canvas);
        if vqtoTopLeft in FTickOptions then
            DrawLeftTicks(FBackBmp.Canvas);
    end;
    
    Canvas.CopyRect(Client, FBackBmp.Canvas, Client);
    inherited;
end;

end.
