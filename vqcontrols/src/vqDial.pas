// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqDial;

interface

uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Classes, Types, SysUtils, Controls, Graphics, Math, ExtCtrls, ComCtrls,
    Dialogs,                 
    BGRABitmap, BGRACanvas, BGRABitmapTypes,
    vqUtils, vqThemes, vqToolTip;

type
    
    TvqDialTipPosition = (vqdTipNone, vqdTipCenter, vqdTipAround);
    
    TvqDialPart = (vqdpNone, vqdpKnob, vqdpTrack);
    
    TvqDrawDialTickEvent = procedure (Sender: TObject; ACanvas: TCanvas; X, Y: Integer;
        AValue: Double; AAngle: Double{radian}) of object;
    
    TvqDial = class(TvqCustomControl)
    private
        FBackBmp: TBitmap;
        
        FShowTicks: Boolean;
        
        FMin: Double;
        FMax: Double;
        FPosition: Double;
        FFrequency: Double;
        FIncrement: Double;
        FReverse: Boolean;
        FCustomTicks: TDblArray;
        
        FMargin: Integer;
        FAperture: TDegree;
        FKnobSize: TDegree;
        FOrigin: TDegree;
        FDiscrete: Boolean;
        FMagnetic: Boolean;
        
        FTipPosition: TvqDialTipPosition;
        FToolTip: TvqToolTip;
        
        FCenter: TPoint;
        FRadius: Integer;
        FKnobAngle: Double; // radian
        
        FHotPart: TvqDialPart;
        FPressedPart: TvqDialPart;
        
        FOnDrawTick: TvqDrawDialTickEvent;
        
		procedure SetShowTicks(Value: Boolean);
		procedure SetMin(Value: Double);
		procedure SetMax(Value: Double);
		procedure SetPosition(Value: Double);
		procedure SetFrequency(Value: Double);
        procedure SetReverse(Value: Boolean);
        procedure SetMargin(Value: Integer);
        procedure SetKnobSize(Value: TDegree);
        procedure SetAperture(Value: TDegree);
        procedure SetOrigin(Value: TDegree);
        procedure SetDiscrete(Value: Boolean);
        
		procedure CNKeyDown(var Message: TLMKeyDown); message CN_KEYDOWN;
		procedure CNKeyUp(var Message: TLMKeyUp); message CN_KEYUP;
        
        procedure SetState(APressedPart, AHotPart: TvqDialPart);
        
        procedure CalculateMetrics;
        procedure CalculateTrackMetrics;
        procedure CalculateTicks;
        procedure FinishSliding;
		procedure ActivateToolTip;
        
        procedure DrawTicks(ACanvas: TCanvas);
    strict protected
        type TTick = record
            Rot: Double; // radian
            Value: Double;
            Pt: TPoint;
        end;
    strict protected
        FTickBuffer: array of TTick;
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
        
        procedure DoDrawTick(ACanvas: TCanvas; X, Y: Integer; AValue: Double; AAngle: Double{radian}); virtual;
        procedure Paint; override;
        
        class function GetControlClassDefaultSize: TSize; override;
    public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
        procedure SetParams(AMin, AMax, APos: Double);
        
        function DiscreteValue: Integer;
        function MagneticPositionFromPoint(P: TPoint): Double;
        function PositionFromPoint(P: TPoint): Double;
        function AngleFromPosition(Pos: Double): TDegree;
        function PositionFromAngle(Ang: TDegree): Double;
        function PartFromPoint(P: TPoint): TvqDialPart;
        
        procedure ClearCustomTicks;
        procedure AddCustomTick(ATick: Double);
        function CustomTicksCount: Integer;
        function CustomTickAt(AIndex: Integer): Double;

        property ToolTip: TvqToolTip read FToolTip write FToolTip;
    published
        property ShowTicks: Boolean read FShowTicks write SetShowTicks;
        property Min: Double read FMin write SetMin;
		property Max: Double read FMax write SetMax;
		property Position: Double read FPosition write SetPosition;
		property Frequency: Double read FFrequency write SetFrequency;
        property Increment: Double read FIncrement write FIncrement;
		property Reverse: Boolean read FReverse write SetReverse;
        property Margin: Integer read FMargin write SetMargin;
        property Aperture: TDegree read FAperture write SetAperture;
        property KnobSize: TDegree read FKnobSize write SetKnobSize;
        property Origin: TDegree read FOrigin write SetOrigin;
        property Discrete: Boolean read FDiscrete write SetDiscrete;
        property Magnetic: Boolean read FMagnetic write FMagnetic;
        property TipPosition: TvqDialTipPosition read FTipPosition write FTipPosition;
		property OnDrawTick: TvqDrawDialTickEvent read FOnDrawTick write FOnDrawTick;
        
        property Font;
        property ParentFont;
        property PopupMenu;
        property TabOrder;
        property TabStop;
        property OnChange;
        property OnContextPopup;
    end;
    
implementation

function ValueFromRotation(AOrigin, AAperture, AMin, AMax, AAngle: Double; AReverse: Boolean): Double;
var
    WO, WA, WS, WE: Double;
begin
    CorrectRadian(AAngle);
    WO := AOrigin;
    WA := AAperture;
    if AReverse then begin
        WS := WO - WA/2;
        WE := WO + WA/2;
        if (AAngle >= WS) and (AAngle <= WO) then Result := AMin
        else if (AAngle >= WO) and (AAngle <= WE) then Result := AMax
        else begin
            AAngle := (WS - AAngle);
            Result := AMin + AAngle*(AMax - AMin)/(2*Pi - WA);
        end;
    end
    else begin
        WS := WO + WA/2;
        WE := WO - WA/2;
        if (AAngle >= WO) and (AAngle <= WS) then Result := AMin
        else if (AAngle >= WE) and (AAngle <= WO) then Result := AMax
        else begin
            AAngle := (AAngle - WS);
            Result := AMin + AAngle*(AMax - AMin)/(2*Pi - WA);
        end;
    end;
    if Result < AMin then Result := AMin;
	if Result > AMax then Result := AMax;
end;

function RotationFromValue(AOrigin, AAperture, AMin, AMax, APos: Double; AReverse: Boolean): Double;
begin
    if SameValue(AMax, AMin) then
        Result := 0
    else
        Result := (APos - AMin)*(2*Pi - AAperture)/(AMax - AMin);
    if AReverse then Result := AOrigin - AAperture/2 - Result
    else Result := AOrigin + AAperture/2 + Result;
    CorrectRadian(Result);
end;

{ TvqDial }

constructor TvqDial.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FBackBmp := TBitmap.Create;
    with GetControlClassDefaultSize do begin
        FBackBmp.Width := cx;
        FBackBmp.Height := cy;
    end;
    
    FShowTicks := False;

	FIncrement := 1;
	FMin := 0;
	FMax := 10;
	FFrequency := 1;
	FPosition := 0;
    FReverse := False;
    FTipPosition := vqdTipAround;
    FToolTip := nil;
    FCustomTicks := nil;
    
    FMargin := 21;
    FOrigin   := 0;
    FAperture := 0;
    FDiscrete := True;
    FMagnetic := False;
    FKnobSize := 25;
    
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
    
    FHotPart := vqdpNone;
    FPressedPart := vqdpNone;
    
    CalculateMetrics;
end;

destructor TvqDial.Destroy;
begin
    FBackBmp.Free;
    inherited;
end;

class function TvqDial.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 50;
    Result.cy := 50;
end;

procedure TvqDial.SetParams(AMin, AMax, APos: Double);
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

function TvqDial.DiscreteValue: Integer;
var
    MinD, MaxD: Integer;
begin
    MinD := Ceil(FMin);
    MaxD := Floor(FMax);
    Result := MathRound(FPosition);
    if Result < MinD then Result := MinD;
    if Result > MaxD then Result := MaxD;
end;

function TvqDial.MagneticPositionFromPoint(P: TPoint): Double;
label LBL_CUSTOM;
var
    M, N, I: Integer;
    Threshold, ValueAng: Double;
begin
    Result := PositionFromPoint(P);
    Threshold := FKnobSize/2;
    ValueAng := VectorRotation(P - FCenter);
    
    if SameValue(FFrequency, 0) then goto LBL_CUSTOM;
    
    // default ticks
    M := Floor((FMax - FMin)/FFrequency);
    N := MathRound((Result - FMin)/FFrequency);
    if M < N then Dec(N);
    if Abs(ValueAng - FTickBuffer[N].Rot) <= Threshold then begin
        Result := FTickBuffer[N].Value;
        Exit;
    end;
    
LBL_CUSTOM:
    // custom ticks
    for I := M + 1 to Length(FTickBuffer) - 1 do
        if Abs(ValueAng - FTickBuffer[I].Rot) <= Threshold then begin
            Result := FTickBuffer[I].Value;
            Break;
        end;
end;

function TvqDial.PositionFromPoint(P: TPoint): Double;
begin
    Result := PositionFromAngle(RadToDeg(VectorRotation(P - FCenter)));
end;

function TvqDial.AngleFromPosition(Pos: Double): TDegree;
begin
    Result := RotationFromValue(DegToRad(FOrigin), DegToRad(FAperture),
        FMin, FMax, Pos, FReverse);
    Result := RadToDeg(Result);
end;

function TvqDial.PositionFromAngle(Ang: TDegree): Double;
begin
    Result := ValueFromRotation(DegToRad(FOrigin), DegToRad(FAperture),
        FMin, FMax, DegToRad(Ang), FReverse);
end;

function TvqDial.PartFromPoint(P: TPoint): TvqDialPart;
var
    Ang: Double;
begin
    if (P - FCenter).Norm <= FRadius then begin
        Result := vqdpTrack;
        Ang := VectorRotation(P);
        if Abs(Ang - FKnobAngle) <= FKnobSize/2 then
            Result := vqdpKnob;
    end
    else Result := vqdpNone;
end;

procedure TvqDial.ClearCustomTicks;
begin
    if FCustomTicks <> nil then begin
        FCustomTicks := nil;
        CalculateMetrics;
        Invalidate;
    end;
end;

procedure TvqDial.AddCustomTick(ATick: Double);
var
    L: Integer;
begin
    L := Length(FCustomTicks);
    SetLength(FCustomTicks, L + 1);
    FCustomTicks[L] := ATick;
    CalculateMetrics;
    Invalidate;
end;

function TvqDial.CustomTicksCount: Integer;
begin
    Result := System.Length(FCustomTicks);
end;

function TvqDial.CustomTickAt(AIndex: Integer): Double;
begin
    if (AIndex >= 0) and (AIndex < CustomTicksCount) then
        Result := FCustomTicks[AIndex]
    else
        Result := NAN;
end;

procedure TvqDial.SetShowTicks(Value: Boolean);
begin
    if FShowTicks <> Value then begin
        FShowTicks := Value;
        CalculateMetrics;
        Invalidate;
    end;
end;

procedure TvqDial.SetMin(Value: Double);
begin
    SetParams(Value, FMax, FPosition);
end;

procedure TvqDial.SetMax(Value: Double);
begin
    SetParams(FMin, Value, FPosition);
end;

procedure TvqDial.SetPosition(Value: Double);
begin
    SetParams(FMin, FMax, Value);
end;

procedure TvqDial.SetFrequency(Value: Double);
begin
    if FDiscrete then Value := Trunc(Value);
    if FFrequency <> Value then begin
        FFrequency := Value;
        CalculateMetrics;
        Invalidate;
    end;
end;

procedure TvqDial.SetReverse(Value: Boolean);
begin
    if FReverse <> Value then begin
        FReverse := Value;
        CalculateMetrics;
        Invalidate;
    end;
end;

procedure TvqDial.SetMargin(Value: Integer);
begin
    if FMargin <> Value then begin
        FMargin := Value;
        CalculateMetrics;
        Invalidate;
    end;    
end;

procedure TvqDial.SetKnobSize(Value: TDegree);
begin
    if FKnobSize <> Value then begin
        FKnobSize := Value;
        CalculateMetrics;
        Invalidate;
    end;    
end;

procedure TvqDial.SetAperture(Value: TDegree);
begin
    if FAperture <> Value then begin
        FAperture := Value;
        CalculateMetrics;
        Invalidate;
    end;    
end;

procedure TvqDial.SetOrigin(Value: TDegree);
begin
    if FOrigin <> Value then begin
        FOrigin := Value;
        CalculateMetrics;
        Invalidate;
    end;    
end;

procedure TvqDial.SetDiscrete(Value: Boolean);
begin
    if FDiscrete <> Value then begin
        FDiscrete := Value;
        FFrequency := Trunc(FFrequency);
        SetParams(FMin, FMax, FPosition);
    end;
end;

procedure TvqDial.CNKeyDown(var Message: TLMKeyDown);
begin
    case Message.CharCode of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN:;
		else inherited;
	end;
end;

procedure TvqDial.CNKeyUp(var Message: TLMKeyUp);
begin
	case Message.CharCode of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN:;
		else inherited;
	end;
end;

procedure TvqDial.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    Part: TvqDialPart;
begin
    inherited MouseDown(Button, Shift, X, Y);
    if Button = mbLeft then begin
        Part := PartFromPoint(Point(X, Y));
        if Part = vqdpTrack then begin
            if FMagnetic then
                SetPosition(MagneticPositionFromPoint(Point(X, Y)))
            else
                SetPosition(PositionFromPoint(Point(X, Y)));
            Part := vqdpKnob;
        end;
        if Part = vqdpKnob then begin
            ActivateToolTip;
        end;
        SetState(Part, FHotPart);
    end;
end;

procedure TvqDial.MouseEnter;
begin
    inherited;
end;

procedure TvqDial.MouseLeave;
begin
    inherited;
    SetState(vqdpNone, vqdpNone);
end;

procedure TvqDial.MouseMove(Shift: TShiftState; X, Y: Integer);
var
    Part: TvqDialPart;
    P: TPoint;
begin
    inherited MouseMove(Shift, X, Y);
    P := Point(X, Y);
    Part := PartFromPoint(P);
    if FPressedPart = vqdpKnob then begin
        if FMagnetic then
            Position := MagneticPositionFromPoint(P)
        else
            Position := PositionFromPoint(P);
        ActivateToolTip;
    end
    else
        SetState(vqdpNone, Part);
end;

procedure TvqDial.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseUp(Button, Shift, X, Y);  
    FinishSliding;
    SetState(vqdpNone, PartFromPoint(Point(X, Y)));
end;

procedure TvqDial.KeyDown(var Key: Word; Shift: TShiftState);
begin
	case Key of
        VK_RIGHT: begin
            if FReverse then Position := Position - FIncrement
            else Position := Position + FIncrement;
        end;
		VK_LEFT: begin
            if FReverse then Position := Position + FIncrement
            else Position := Position - FIncrement;
        end;
		VK_UP: begin
            Position := Position + FIncrement;
        end;
		VK_DOWN: begin
            Position := Position - FIncrement;
        end;
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

procedure TvqDial.KeyUp(var Key: Word; Shift: TShiftState);
begin
	inherited;
	case Key of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_END, VK_HOME, VK_SPACE: Key := 0;
	end;
end;

procedure TvqDial.SetState(APressedPart, AHotPart: TvqDialPart);
var
    PrevHotPart: TvqDialPart;
    PrevPressedPart: TvqDialPart;
begin
    if APressedPart <> vqdpNone then
        AHotPart := FPressedPart;
    if (FPressedPart <> APressedPart) or (FHotPart <> AHotPart) then begin
        FPressedPart := APressedPart;
        FHotPart := AHotPart;
        Repaint;
    end;
end;

procedure TvqDial.UpdateMetrics;
begin
    CalculateMetrics;
    inherited;
end;

procedure TvqDial.ColorChanged;
begin
    inherited;
    Invalidate;
end;

procedure TvqDial.FocusChanged(AFocused: Boolean);
begin
    inherited;
    Invalidate;
end;

procedure TvqDial.EnabledChanged;
begin
    inherited;
    FinishSliding;
    Invalidate;
end;

procedure TvqDial.VisibleChanged;
begin
    inherited;
    FinishSliding;
end;

procedure TvqDial.CancelMode;
begin
    inherited;
    FinishSliding;
end;

procedure TvqDial.FontChanged;
begin
    inherited;
    CalculateMetrics;
    Invalidate;
end;

procedure TvqDial.Resize;
begin
    inherited;
    FBackBmp.Width := Width;
    FBackBmp.Height := Height;
    
    CalculateMetrics;
end;

procedure TvqDial.CalculateMetrics;
begin
    CalculateTrackMetrics;
    CalculateTicks;
end;

procedure TvqDial.CalculateTrackMetrics;
var
    Client: TRect;
begin
    Client := ClientRect;
    FCenter := Client.CenterPoint;
    FRadius := Math.Min(Client.Width - 1, Client.Height - 1) div 2;
    if FShowTicks then
        Dec(FRadius, FMargin);
    FKnobAngle := DegToRad(AngleFromPosition(FPosition));
end;

procedure TvqDial.CalculateTicks;
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
    
    for I := 0 to L - 1 do 
        with FTickBuffer[I] do begin
            Rot := RotationFromValue(DegToRad(FOrigin), DegToRad(FAperture),
                FMin, FMax, FTickBuffer[I].Value, FReverse);
            Pt := VectorFromNormArg(FRadius, Rot) + FCenter;
        end;
end;

procedure TvqDial.FinishSliding;
begin
    if (FPressedPart = vqdpKnob) and (FToolTip <> nil) and (FToolTip.TipActive) then begin
        FToolTip.HideTip;
    end;
    CalculateMetrics;
    Repaint;
end;

procedure TvqDial.ActivateToolTip;
var
    Sz: TSize;
    TipR, Client: TRect;
    Radius: Integer;
    Angle: Double;
    P: TPoint;
    Str: string;
begin
    if (FToolTip <> nil) and (FTipPosition <> vqdTipNone) then begin
        Client := ClientRect;
        Str := FloatToStr(Position);
        Sz := FToolTip.CalculateExtent(Str);
        Angle := AngleFromPosition(Position);
        
        if FTipPosition = vqdTipAround then begin
            Radius := Math.Min(Client.Width - 1, Client.Height - 1) div 2;
            
            P := VectorFromNormArg(Radius, Angle) + FCenter;
            
            if SameValue(Angle, 0) then begin
                TipR.Left := P.X;
                TipR.Top := P.Y - Sz.cy div 2;
            end
            else if (Angle > 0) and (Angle < Pi/2) then begin
                TipR.Left := P.X;
                TipR.Top := P.Y;
            end
            else if SameValue(Angle, Pi/2) then begin
                TipR.Left := P.X - Sz.cx div 2;
                TipR.Top := P.Y;
            end
            else if (Angle > Pi/2) and (Angle < Pi) then begin
                TipR.Left := P.X - Sz.cx;
                TipR.Top := P.Y;
            end
            else if SameValue(Angle, Pi) then begin
                TipR.Left := P.X - Sz.cx;
                TipR.Top := P.Y - Sz.cy div 2;
            end
            else if (Angle > Pi) and (Angle < 3*Pi/2) then begin
                TipR.Left := P.X - Sz.cx;
                TipR.Top := P.Y - Sz.cy;
            end
            else if SameValue(Angle, 3*Pi/2) then begin
                TipR.Left := P.X - Sz.cx div 2;
                TipR.Top := P.Y - Sz.cy;
            end
            else if (Angle > 3*Pi/2) and (Angle < 2*Pi) then begin
                TipR.Left := P.X;
                TipR.Top := P.Y - Sz.cy;
            end
            else { Pi } begin
                TipR.Left := P.X;
                TipR.Top := P.Y - Sz.cy div 2;
            end;
        end
        else begin
            TipR.Left := (Client.Left + Client.Right - Sz.cx) div 2;
            TipR.Top := (Client.Top + Client.Bottom - Sz.cy) div 2;
        end;
        
        TipR.TopLeft := ClientToScreen(TipR.TopLeft);
        TipR.Size := Sz;
        FToolTip.ShowTip(TipR, Str);
    end;
end;

procedure TvqDial.DoDrawTick(ACanvas: TCanvas; X, Y: Integer; AValue: Double; AAngle: Double);
begin
    if Assigned(FOnDrawTick) then FOnDrawTick(Self, ACanvas, X, Y, AValue, AAngle);
end;

procedure TvqDial.DrawTicks(ACanvas: TCanvas);
var
    X, Y: Integer;
    Q: TPoint;
    Bitmap: TBGRABitmap;
    Ang: Double;
    IgnoreMax: Boolean;
    TickColor: TColor;
    I: Integer;
begin
    Bitmap := TBGRABitmap.Create(10, 10, clNone);
    TickColor := vqThemeManager.TickColor;
    try
        Acanvas.Pen.Color := TickColor;
        for I := 0 to Length(FTickBuffer) - 1 do begin
            X := FTickBuffer[I].Pt.X;
            Y := FTickBuffer[I].Pt.Y;
            Ang := FTickBuffer[I].Rot;
            if (FAperture = 0) and (FTickBuffer[I].Value = FMax) then
                Continue;
            Q := VectorFromNormArg(5, Ang);
            Bitmap.Fill(clNone);
            Bitmap.DrawLineAntialias(5, 5, 5 + Q.X, 5 + Q.Y, TickColor, 1);

            Bitmap.Draw(ACanvas, X - 5, Y - 5, False);
            DoDrawTick(ACanvas, X, Y, FTickBuffer[I].Value, Ang);
        end;
    finally
        Bitmap.Free;
    end;
end;

procedure TvqDial.Paint;
var
    Client: TRect;
    AState, AKnobState: TvqThemeState;
begin
    Client := ClientRect;
    
    if not Enabled then AState := [vqthDisabled]
    else if FHotPart = vqdpKnob then AState := [vqthHovered]
    else if FHotPart = vqdpTrack then AState := [vqthHot]
    else AState := [vqthNormal];
    
    if not Enabled then AKnobState := [vqthDisabled]
    else if FHotPart = vqdpTrack then AKnobState := [vqthHovered]
    else if FHotPart = vqdpKnob then AKnobState := [vqthHot]
    else if FPressedPart = vqdpKnob then AKnobState := [vqthPressed]
    else AKnobState := [vqthNormal];
    if Focused then Include(AKnobState, vqthFocused);

    if (Color = clNone) or (Color = clDefault) then
        FBackBmp.Canvas.CopyRect(Client, Canvas, Client)
    else begin
        FBackBmp.Canvas.FullBrush(Color);
        FBackBmp.Canvas.FillRect(Client);
    end;
    
    vqThemeManager.DrawDial(Self, FBackBmp.Canvas, FCenter, FRadius,
        FKnobAngle, DegToRad(FKnobSize), AState, AKnobState);

    if FShowTicks then
        DrawTicks(FBackBmp.Canvas);
    
    Canvas.CopyRect(Client, FBackBmp.Canvas, Client);
    inherited;
end;

end.
