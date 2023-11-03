// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqArrow;

interface

uses
    InterfaceBase, LMessages, LCLType,
    Classes, Types, SysUtils, Controls, Graphics, ExtCtrls, StdCtrls, ComCtrls,
    vqUtils, vqThemes;

type
    
    TvqUDChangingEvent = procedure (Sender: TObject; var AllowChange: Boolean;
        var NewValue: Integer; Forward: Boolean) of object;
    TvqUDArrowEvent = procedure (Sender: TObject; Pos: Integer; Forward: Boolean) of object;
    
    TvqArrow = class(TvqCustomControl)
    private
        FAlignButton: TUDAlignButton;
        FOrientation: TUDOrientation;
        
        FIncrement: Integer;
        FPosition: Integer;
        FMin: Integer;
        FMax: Integer;
        FWrap: Boolean;
        FUnlimited: Boolean;
        FThousands: Boolean;
        FArrowKeys: Boolean;
        FPageSize: Integer;
        FAssociate: TWinControl;
        
        FOnChanging: TvqUDChangingEvent;
        FOnArrow: TvqUDArrowEvent;
        
        FPressed: Boolean;
        FMouseOver: Boolean;
        
        FSynchronize: TvqArrow;
        FDirection: TUpDownDirection;
        
        FMoving: Boolean;
        procedure SetDirection(Value: TUpDownDirection);
        procedure SetSynchronize(Value: TvqArrow);
        
        procedure SetAlignButton(Value: TUDAlignButton);
        procedure SetArrowKeys(Value: Boolean);
        procedure SetIncrement(Value: Integer);
        procedure SetPosition(Value: Integer);
        procedure SetMin(Value: Integer);
        procedure SetMax(Value: Integer);
        procedure SetPageSize(Value: Integer);
        procedure SetOrientation(Value: TUDOrientation);
        procedure SetThousands(Value: Boolean);
        procedure SetWrap(Value: Boolean);
        procedure SetUnlimited(Value: Boolean);
        function GetPosition: Integer;
        
        procedure UpdateButtonBounds;
    strict protected
        FTimer: TTimer;
    protected
        procedure OnAssociateEnabledChanged(Sender: TObject);
        procedure OnAssociateVisibleChanged(Sender: TObject);
        procedure OnAssociateChangeBounds(Sender: TObject);
        procedure OnAssociateMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
            MousePos: TPoint; var Handled: Boolean);
        procedure OnAssociateKeyDown(Sender: TObject; var Key: Word; ShiftState : TShiftState);
	protected
        procedure UpdateAssociateValue;
        procedure InternalSetAssociate(Value: TWinControl);
        procedure FinishMove; virtual;
        procedure MovePosition(Forward: Boolean); virtual;
		procedure OnTimer(Sender: TObject); virtual;
        procedure SynchronizeValues; virtual;
        procedure SetAssociate(Value: TWinControl); virtual;
        
        procedure EnabledChanged; override;
        procedure ColorChanged; override;
        procedure VisibleChanged; override;
        
        procedure Changing(var AllowChange: Boolean; NewValue: Integer; AForward: Boolean); virtual;
		procedure DoArrow(Pos: Integer; Forward: Boolean); virtual;
        procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    
        class function GetControlClassDefaultSize: TSize; override;
		procedure Paint; override;
		procedure UpdateMetrics; override;
        
    	procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure MouseEnter; override;
		procedure MouseLeave; override;
		procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure SetPositionParam(var APos: Integer);
        procedure SetParams(APos, AMin, AMax, APageSize: Integer);
        function IsEmpty: Boolean;
    published
        property AlignButton: TUDAlignButton read FAlignButton write SetAlignButton default udRight;
        property ArrowKeys: Boolean read FArrowKeys write SetArrowKeys default True;
        property Associate: TWinControl read FAssociate write SetAssociate;
        property Increment: Integer read FIncrement write SetIncrement default 1;
		property Position: Integer read GetPosition write SetPosition;
		property Min: Integer read FMin write SetMin default 0;
		property Max: Integer read FMax write SetMax default 100;
        property PageSize: Integer read FPageSize write SetPageSize default 0;
		property Orientation: TUDOrientation read FOrientation write SetOrientation default udVertical;
        property Thousands: Boolean read FThousands write SetThousands default True;
        property Wrap: Boolean read FWrap write SetWrap default False;
        property Unlimited: Boolean read FUnlimited write SetUnlimited default False;
        property OnChanging: TvqUDChangingEvent read FOnChanging write FOnChanging;
        property OnArrow: TvqUDArrowEvent read FOnArrow write FOnArrow;
        
        property Direction: TUpDownDirection read FDirection write SetDirection default updUp;
        property Synchronize: TvqArrow read FSynchronize write SetSynchronize;
        
        property PopupMenu;
        property TabOrder;
        property TabStop;
        
        property OnChange;
        property OnContextPopup;
        property OnEnter;
        property OnExit;
        property OnKeyDown;
        property OnKeyPress;
        property OnKeyUp;
    end;
    
    TvqUDPart = (vqudpNone, vqudpArrowUp, vqudpArrowDown, vqudpSpacer);
    
    TvqControlArrow = class(TvqArrow)
    private
        procedure CMDesignHitTest(var Message: TCMDesignHitTest); message CM_DESIGNHITTEST;
    protected
        procedure WndProc(var Message: TLMessage); override;
    end;
    
const
    
    vqSpinSlower        = 400;
    vqSpinFaster        = 60;
    
implementation

{ TvqArrow }

constructor TvqArrow.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
    ControlStyle := ControlStyle + [csNoFocus];
	FTimer := TTimer.Create(nil);
	FTimer.Enabled := False;
	FTimer.Interval := vqSpinSlower;
	FTimer.OnTimer := @OnTimer;
    FPosition := 0;
    FMin := 0;
    FMax := 100;
    FIncrement := 1;
    FOrientation := udVertical;
    FAlignButton := udRight;
    FArrowKeys := True;
    FThousands := True;
    FWrap := False;
    FUnlimited := False;
    TabStop := False;
    
    FPressed := False;
    FMouseOver := False;
    
    FDirection := updUp;
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
end;

destructor TvqArrow.Destroy;
begin
    FAssociate := nil;
	FTimer.Free;
	inherited;
end;

procedure TvqArrow.SetPositionParam(var APos: Integer);
begin
    SetParams(APos, FMin, FMax, FPageSize);
    APos := FPosition;
end;

procedure TvqArrow.SetParams(APos, AMin, AMax, APageSize: Integer);
var
    PrevPos: Integer;
begin
	if AMax < AMin then begin
		if AMax = FMax then AMin := AMax
		else AMax := AMin;
	end;
	if not FUnlimited then begin
        if APageSize < 0 then APageSize := 0
        else if APageSize > 0 then begin
            if APos > AMax - APageSize + 1 then
                APos := AMax - APageSize + 1;
        end;
        if APos < AMin then APos := AMin;
        if APos > AMax then APos := AMax;
    end;
	if (AMin <> FMin) or (AMax <> FMax) or (APos <> FPosition) or
        (APageSize <> FPageSize) then begin
		PrevPos := FPosition;
        FPageSize := APageSize;
        FMin := AMin;
		FMax := AMax;
        FPosition := APos;
        SynchronizeValues;
        UpdateAssociateValue;
        if PrevPos <> FPosition then Changed;
	end;
end;

function TvqArrow.IsEmpty: Boolean;
begin
    Result := (FPageSize > (FMax - FMin)) or ((FPageSize = 0) and (FMax = FMin));
end;

class function TvqArrow.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 17;
    Result.cy := 17;
end;

procedure TvqArrow.UpdateMetrics;
begin
    inherited;
end;

procedure TvqArrow.EnabledChanged;
begin
    inherited;
    FinishMove;
    Invalidate;
end;

procedure TvqArrow.ColorChanged;
begin
    inherited;
    Invalidate;
end;

procedure TvqArrow.VisibleChanged;
begin
    inherited;
    FinishMove;
end;

procedure TvqArrow.Changing(var AllowChange: Boolean; NewValue: Integer; AForward: Boolean);
begin
    if Assigned(FOnChanging) then FOnChanging(Self, AllowChange, NewValue, AForward);
end;

procedure TvqArrow.DoArrow(Pos: Integer; Forward: Boolean);
begin
    if Assigned(FOnArrow) then FOnArrow(Self, Pos, Forward);
end;

procedure TvqArrow.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if Assigned(FAssociate) and (AComponent = FAssociate) and (Operation = opRemove) then
        SetAssociate(nil);
end;

procedure TvqArrow.UpdateAssociateValue;
begin
    if Assigned(FAssociate) then begin
        if FThousands then FAssociate.Caption := FloatToStrF(FPosition, ffNumber, 0, 0)
        else FAssociate.Caption := IntToStr(FPosition);
    end;
end;

procedure TvqArrow.SynchronizeValues;
begin
    if Assigned(FSynchronize) then begin
        FSynchronize.FIncrement := FIncrement;
        FSynchronize.FPosition  := FPosition ;
        FSynchronize.FMin       := FMin      ;
        FSynchronize.FMax       := FMax      ;
        FSynchronize.FPageSize  := FPageSize ;
        FSynchronize.FWrap      := FWrap     ;
        FSynchronize.FUnlimited := FUnlimited;
        FSynchronize.FThousands := FThousands;
        FSynchronize.FArrowKeys := FArrowKeys;
    end;
end;

procedure TvqArrow.MovePosition(Forward: Boolean);
var
    APos: Integer;
    AllowChange: Boolean;
begin
    if FMoving then Exit;
    FMoving := True;
    
    //------------
    
    APos := FPosition;
    AllowChange := True;
    if Forward then begin
        APos := APos + FIncrement;
        if FWrap then
            APos := FMin + EuclidMod(APos - FMin, FMax - FMin + 1)
        else if not FUnlimited and (APos > FMax) then
            APos := FMax;
    end 
    else begin
        APos := APos - FIncrement;
        if FWrap then
            APos := FMin + EuclidMod(APos - FMin, FMax - FMin + 1)
        else if not FUnlimited and (APos < FMin) then
            APos := FMin;
    end;
    if not FUnlimited and (FPageSize > 0) then begin
        if APos > FMax - FPageSize + 1 then
            APos := FMax - FPageSize + 1;
    end;
    if APos <> FPosition then begin
        Changing(AllowChange, APos, Forward);
        if not AllowChange then Exit;
        FPosition := APos;
        UpdateAssociateValue;
    end;
    DoArrow(FPosition, Forward);
    
    //-------------
    
    if Assigned(FSynchronize) then
        FSynchronize.MovePosition(Forward);
    FMoving := False;
end;

procedure TvqArrow.FinishMove;
begin
    FTimer.Enabled := False;
    FTimer.Interval := vqSpinSlower;
end;

procedure TvqArrow.UpdateButtonBounds;
begin
    if Assigned(FAssociate) then
        case FAlignButton of
            udLeft: SetBounds(FAssociate.Left - Width, FAssociate.Top, Width, FAssociate.Height);
            udTop: SetBounds(FAssociate.Left, FAssociate.Top - Height, FAssociate.Width, Height);
            udRight: SetBounds(FAssociate.Left + FAssociate.Width, FAssociate.Top, Width, FAssociate.Height);
            udBottom: SetBounds(FAssociate.Left, FAssociate.Top + FAssociate.Height, FAssociate.Width, Height);
        end;
end;

procedure TvqArrow.OnAssociateEnabledChanged(Sender: TObject);
begin
    if Assigned(FAssociate) then
        SetEnabled(FAssociate.Enabled);
end;

procedure TvqArrow.OnAssociateVisibleChanged(Sender: TObject);
begin
    if Assigned(FAssociate) then
        SetVisible(FAssociate.Visible);
end;

procedure TvqArrow.OnAssociateChangeBounds(Sender: TObject);
begin
    if Assigned(FAssociate) then
        UpdateButtonBounds;
end;

procedure TvqArrow.OnAssociateMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
    MousePos: TPoint; var Handled: Boolean);
begin
    if WheelDelta <> 0 then begin
        if FOrientation = udHorizontal then
            MovePosition(WheelDelta < 0)
        else
            MovePosition(WheelDelta > 0);
        Handled := True;
    end;
end;

procedure TvqArrow.OnAssociateKeyDown(Sender: TObject; var Key: Word; ShiftState : TShiftState);
begin
    if FArrowKeys and (ShiftState = []) then
        case FOrientation of
            udVertical:
                case Key of
                    VK_UP: begin
                        MovePosition(True);
                        Key := 0;
                    end;
                    VK_DOWN: begin
                        MovePosition(False);
                        Key := 0;
                    end;
                end;
            udHorizontal:
                case Key of
                    VK_LEFT: begin
                        MovePosition(False);
                        Key := 0;
                    end;
                    VK_RIGHT: begin
                        MovePosition(True);
                        Key := 0;
                    end;
                end;
        end;
end;

procedure TvqArrow.SetAlignButton(Value: TUDAlignButton);
begin
    if FAlignButton <> Value then begin
        FAlignButton := Value;
        UpdateButtonBounds;
    end;
end;

procedure TvqArrow.InternalSetAssociate(Value: TWinControl);
begin
    if FAssociate <> Value then begin
        if FAssociate <> nil then
            FAssociate.RemoveAllHandlersOfObject(Self);
        FAssociate := Value;
        UpdateAssociateValue;
        UpdateButtonBounds;
        if (FAssociate <> nil) and (FAssociate.Parent = Parent) then begin
            FAssociate.AddHandlerOnEnabledChanged(@OnAssociateEnabledChanged, True);
            FAssociate.AddHandlerOnVisibleChanged(@OnAssociateVisibleChanged, True);
            FAssociate.AddHandlerOnChangeBounds  (@OnAssociateChangeBounds  , True);
            FAssociate.AddHandlerOnMouseWheel    (@OnAssociateMouseWheel    , True);
            FAssociate.AddHandlerOnKeyDown       (@OnAssociateKeyDown       , True);
        end;
    end;
end;

procedure TvqArrow.SetDirection(Value: TUpDownDirection);
begin
    if FDirection <> Value then begin
        FDirection := Value;
        Invalidate;
    end;
end;

procedure TvqArrow.SetSynchronize(Value: TvqArrow);
begin
    if FSynchronize <> Value then begin
        if FSynchronize <> nil then
            FSynchronize.InternalSetAssociate(nil);
        FSynchronize := Value;
        if FSynchronize <> nil then begin
            SynchronizeValues;
            if FAssociate <> nil then
                FSynchronize.InternalSetAssociate(FAssociate)
            else
                InternalSetAssociate(FSynchronize.FAssociate);
            FSynchronize.FSynchronize := Self;
        end;
    end;
end;

procedure TvqArrow.SetAssociate(Value: TWinControl);
begin
    InternalSetAssociate(Value);
    if Assigned(FSynchronize) then FSynchronize.InternalSetAssociate(Value);
end;

procedure TvqArrow.SetArrowKeys(Value: Boolean);        
begin
    FArrowKeys := Value;
    SynchronizeValues;
end;

procedure TvqArrow.SetIncrement(Value: Integer);         
begin
    FIncrement := Value;
    SynchronizeValues;
end;

procedure TvqArrow.SetPosition(Value: Integer);
begin
	SetParams(Value, FMin, FMax, FPageSize);
end;

procedure TvqArrow.SetMin(Value: Integer);
begin
	SetParams(FPosition, Value, FMax, FPageSize);
end;

procedure TvqArrow.SetMax(Value: Integer);
begin
	SetParams(FPosition, FMin, Value, FPageSize);
end;

procedure TvqArrow.SetPageSize(Value: Integer);
begin
    SetParams(FPosition, FMin, FMax, Value);
end;

procedure TvqArrow.SetOrientation(Value: TUDOrientation);   
begin
    if FOrientation <> Value then begin
        FOrientation := Value;
        if not (csLoading in ComponentState) then
			SetBounds(Left, Top, Height, Width)
        else
            UpdateMetrics;
        if Assigned(FAssociate) then
            UpdateButtonBounds;
    end;
end;

procedure TvqArrow.SetThousands(Value: Boolean);             
begin
    if FThousands <> Value then begin
        FThousands := Value;
        SynchronizeValues;
    end;
end;

procedure TvqArrow.SetWrap(Value: Boolean);
begin
    if FWrap <> Value then begin
        FWrap := Value;
        SynchronizeValues;
        SetParams(FPosition, FMin, FMax, FPageSize);
    end;
end;

procedure TvqArrow.SetUnlimited(Value: Boolean);
begin
    if FUnlimited <> Value then begin
        FUnlimited := Value;
        SynchronizeValues;
        SetParams(FPosition, FMin, FMax, FPageSize);
    end;
end;

function TvqArrow.GetPosition: Integer;
var
    N: Integer;
    Str: string;                  
begin
    if Assigned(FAssociate) then begin
        Str := StringReplace(Trim(FAssociate.Caption),
            DefaultFormatSettings.ThousandSeparator, '', [rfReplaceAll]);
        if TryStrToInt(Str, N) and (N <> FPosition) then
            SetPosition(N);
    end;
    Result := FPosition;
end;

procedure TvqArrow.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	inherited;
    if Button = mbLeft then begin
        FPressed := True;
        Repaint;
        if FDirection <> updNone then begin
            MovePosition(FDirection = updUp);
            FTimer.Interval := vqSpinSlower;
            FTimer.Enabled := True;
        end;
    end;
end;

procedure TvqArrow.MouseEnter;
begin
    inherited;
    FMouseOver := True;
    Repaint;
end;

procedure TvqArrow.MouseLeave;
begin
    inherited;
    FMouseOver := False;
    Repaint;
end;

procedure TvqArrow.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
    inherited;
    if FPressed then
        FTimer.Enabled := PtInRect(ClientRect, Point(X, Y));
end;

procedure TvqArrow.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    inherited;
    FinishMove;
    FPressed := False;
    Repaint;
end;

function TvqArrow.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
    Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
    if (not Result) and (WheelDelta <> 0) then begin
        if FOrientation = udHorizontal then
            MovePosition(WheelDelta < 0)
        else
            MovePosition(WheelDelta > 0);
        Result := True;
    end;
end;

procedure TvqArrow.OnTimer(Sender: TObject);
var
    P: TPoint;
    CanMove: Boolean;
begin
    if FDirection <> updNone then 
        MovePosition(FDirection = updUp);
    CanMove := False;
    case FDirection of
        updUp:
            if not FUnlimited and not FWrap then
                CanMove := FPosition < FMax;
        updDown:
            if not FUnlimited and not FWrap then
                CanMove := FPosition > FMin;
    end;                                
    WidgetSet.GetCursorPos(P);
    CanMove := CanMove and PtInRect(ClientRect, ScreenToClient(P));
    FTimer.Interval := vqSpinFaster;
    FTimer.Enabled := CanMove;
end;

procedure TvqArrow.Paint;
var
    Client: TRect;
    AState: TvqThemeState;
begin
    Client := ClientRect;
    if not Enabled then AState := [vqthDisabled]
    else if FPressed then AState := [vqthPressed]
    else if FMouseOver then AState := [vqthHot]
    else AState := [vqthNormal];
    if FDirection = updUp then begin
        if FOrientation = udHorizontal then
            vqThemeManager.DrawArrowHorzUp(Self, Canvas, Client, AState)
        else
            vqThemeManager.DrawArrowVertUp(Self, Canvas, Client, AState);
    end
    else if FDirection = updDown then begin
        if FOrientation = udHorizontal then
            vqThemeManager.DrawArrowHorzDown(Self, Canvas, Client, AState)
        else
            vqThemeManager.DrawArrowVertDown(Self, Canvas, Client, AState);
    end
    else begin
        Canvas.Brush.Color := Color;
        Canvas.FillRect(ClientRect);
    end;
    inherited;
end;

{ TvqControlArrow }

procedure TvqControlArrow.CMDesignHitTest(var Message: TCMDesignHitTest);
begin
    Message.Result := 1;
end;

procedure TvqControlArrow.WndProc(var Message: TLMessage);
begin
    if (Message.Msg = LM_LBUTTONDOWN) and
        (Parent is TCustomControl) and 
        Parent.CanFocus and
        not (csNoFocus in Parent.ControlStyle) then
        Parent.SetFocus;
    inherited;
end;

end.
