// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqToolButton;

{
- add control dropdown to drop down a control inside a sheet
}

interface
                   
uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Types, Classes, SysUtils, Graphics, Forms, Controls, StdCtrls, Buttons,
    ImgList, ActnList, Dialogs, Menus,
    vqUtils, vqThemes, vqButtons;

type
    
    TvqToolButtonKind = (vqtbkButton, vqtbkButtonDrop, vqtbkDropDown);
    
    TvqToolButton = class(TvqButtonControl)
    private
        FArrowSize: Integer;
        FOrientation: TvqOrientation;
        FKind: TvqToolButtonKind;
        FArrow: TRect;
        FArrowDown: Boolean;
        FArrowHot: Boolean;
        
        FDropDownMenu: TPopupMenu;
        FDropDownForm: TvqPopupForm;
        FDropDownAlignment: TAlignment;
        FDropDownLayout: TTextLayout;
        FDropDownOrientation: TvqOrientation;

        FLastDropDownTick: Int64;

        FDroppedDown: Boolean;
        FOnPrepareDropDown: TvqDropDownEvent;
        FOnCloseUp: TNotifyEvent;
        FOnDropDown: TNotifyEvent;
        FOnArrowClick: TNotifyEvent;
        procedure SetArrowSize(Value: Integer);
        procedure SetDropDownMenu(Value: TPopupMenu);
        procedure SetDropDownForm(Value: TvqPopupForm);
        procedure SetOrientation(Value: TvqOrientation);
        procedure SetKind(Value: TvqToolButtonKind);
        procedure CalculateMetrics;
    protected
        function GlyphSize(AArea: TRect): TSize; override;
        function CaptionArea: TRect; override;
        procedure DrawGlyph(AArea, ARect: TRect); override;
        procedure DrawArrow(ARect: TRect); virtual;
        
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        procedure KeyDown(var Key: Word; Shift: TShiftState); override;
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        procedure MouseLeave; override;
        procedure Click; override;
        procedure Paint; override;
        
        procedure ExecuteCloseUp; virtual;
        procedure DoPrepareDropDown(var Caller: TControl); virtual;
        procedure DoCloseUp; virtual;
        procedure DoDropDown; virtual;
        procedure OnDropdownFormShow(Sender: TObject); virtual;
        procedure OnDropdownFormHide(Sender: TObject); virtual;
        procedure ExecuteDropDown(Caller: TControl); virtual;
        procedure SendMouseUpMsg;
        
        procedure Resize; override;
        procedure DoArrowClick; virtual;
        function MainRect: TRect;
        property ArrowRect: TRect read FArrow;
        property ArrowHot: Boolean read FArrowHot;
        property ArrowDown: Boolean read FArrowDown;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        function CanFocus: Boolean; override;
        property DroppedDown: Boolean read FDroppedDown;
    published
        property ArrowSize: Integer read FArrowSize write SetArrowSize default 17;
        property DropDownAlignment: TAlignment read FDropDownAlignment write FDropDownAlignment;
        property DropDownLayout: TTextLayout read FDropDownLayout write FDropDownLayout;
        property DropDownOrientation: TvqOrientation read FDropDownOrientation write FDropDownOrientation;
        property DropDownForm: TvqPopupForm read FDropDownForm write SetDropDownForm;
        property DropDownMenu: TPopupMenu read FDropDownMenu write SetDropDownMenu;
        property Orientation: TvqOrientation read FOrientation write SetOrientation;
        
        property Kind: TvqToolButtonKind read FKind write SetKind;
        property OnPrepareDropDown: TvqDropDownEvent read FOnPrepareDropDown write FOnPrepareDropDown;
        property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
        property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
        property OnArrowClick: TNotifyEvent read FOnArrowClick write FOnArrowClick;
    end;
    
implementation

{ TvqToolButton }

constructor TvqToolButton.Create(AOwner: TComponent);                                       
begin
    inherited Create(AOwner);     
    FArrowSize := 17; 
    FOrientation := vqHorizontal;
    FDropDownOrientation := vqHorizontal;
    FKind := vqtbkDropDown;
    FDropDownAlignment := taLeftJustify;
    FDropDownLayout := tlTop;
    
    CalculateMetrics;
end;

destructor TvqToolButton.Destroy;                                                           
begin
    inherited;
end;

function TvqToolButton.CanFocus: Boolean;
begin
    Result := inherited;
end;

procedure TvqToolButton.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
begin 
    inherited CalculatePreferredSize(PreferredWidth, PreferredHeight, WithThemeSpace);
end;

procedure TvqToolButton.SetArrowSize(Value: Integer);
begin
    if FArrowSize <> Value then begin
        FArrowSize := Value;
        CalculateMetrics;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqToolButton.SetOrientation(Value: TvqOrientation);
begin
    if FOrientation <> Value  then begin
        FOrientation := Value;
        CalculateMetrics;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqToolButton.SetKind(Value: TvqToolButtonKind);
begin
    if FKind <> Value then begin
        FKind := Value;
        CalculateMetrics;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqToolButton.SetDropDownForm(Value: TvqPopupForm);
begin
    if FDroppedDown then Exit;
    FDropDownForm := Value;
end;

procedure TvqToolButton.SetDropDownMenu(Value: TPopupMenu);
begin
    if FDroppedDown then Exit;
    FDropDownMenu := Value;
end;

procedure TvqToolButton.ExecuteCloseUp;
begin
    if FDroppedDown then begin
        if FDropDownForm <> nil then 
            FDropDownForm.Return
        else if FDropDownMenu <> nil then
            FDropDownMenu.Close;
    end;
end;

procedure TvqToolButton.DoPrepareDropDown(var Caller: TControl);
begin
    if Assigned(FOnPrepareDropDown) then FOnPrepareDropDown(Self, Caller);
end;

procedure TvqToolButton.DoCloseUp;
begin
    if Assigned(FOnCloseUp) then FOnCloseUp(Self);
end;

procedure TvqToolButton.DoDropDown;
begin
    if Assigned(FOnDropDown) then FOnDropDown(Self);
end;

procedure TvqToolButton.OnDropdownFormShow(Sender: TObject);
begin
    FDroppedDown := True;
    DoDropDown;
end;

procedure TvqToolButton.OnDropdownFormHide(Sender: TObject);
begin
    DoCloseUp;
    FDroppedDown := False;
    FLastDropDownTick := GetTickCount64;
end;

procedure TvqToolButton.ExecuteDropDown(Caller: TControl);
var
    V, P: TPoint;
    X, Y, W, H: Integer;
begin
    if FDroppedDown then Exit;
    DoPrepareDropDown(Caller);
    if FDropDownForm <> nil then begin
        FDropDownForm.OnShow := @OnDropDownFormShow;
        FDropDownForm.OnHide := @OnDropDownFormHide;
        FDropDownForm.DropDown(Caller, FDropDownAlignment, FDropDownLayout, FDropDownOrientation);
    end
    else if Assigned(FDropDownMenu) then begin
        FDroppedDown := True;
        DoDropDown;
        FDropDownMenu.DropDown(Caller, FDropDownAlignment, FDropDownLayout, FDropDownOrientation);
        DoCloseUp;
        FLastDropDownTick := GetTickCount64;
        FDroppedDown := False;
        SendMouseUpMsg;
        Repaint;
    end;
end;

procedure TvqToolButton.SendMouseUpMsg;
var
    Msg: TLMMouse;
    P: TPoint;
begin
    FillChar(Msg, SizeOf(Msg), 0);
    Msg.Msg := LM_LBUTTONUP;
    P := ScreenToClient(Mouse.CursorPos);
    Msg.XPos := P.X;
    Msg.YPos := P.Y;
    WndProc(TLMessage(Msg));
end;

procedure TvqToolButton.KeyDown(var Key: Word; Shift: TShiftState);
var
    _DropDown: Boolean;
    _CloseUp: Boolean;
begin
    _DropDown := False;
    _CloseUp := False;
    if FKind = vqtbkButton then begin end
    else if FKind in [vqtbkButtonDrop] then begin
        if (Key = VK_SPACE) or (Key = VK_RETURN)
            or (Key = VK_DOWN) then _DropDown := True
        else if Key = VK_UP then _CloseUp := True;
    end
    else if FKind = vqtbkDropDown then begin
        if Key = VK_DOWN then _DropDown := True
        else if Key = VK_UP then _CloseUp := True;
    end;
    inherited KeyDown(Key, Shift);
    if _DropDown then
        ExecuteDropDown(Self)
    else if _CloseUp then
        ExecuteCloseUp;
end;

procedure TvqToolButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); 
begin
    inherited;
    if Button = mbLeft then begin
        if FKind in [vqtbkButtonDrop] then begin
            if (GetTickCount64 < FLastDropDownTick + 100) and FPressed then begin
                FPressed := False;
                FMouseOver := PtInRect(ClientRect, Point(X, Y));
            end;
            FLastDropDownTick := 0;
            if FPressed then
                ExecuteDropDown(Self);
        end
        else if (FKind = vqtbkDropDown) and PtInRect(FArrow, Point(X, Y)) then begin
            FArrowDown := True;
            FArrowHot := True;
            if (GetTickCount64 < FLastDropDownTick + 100) and FPressed then begin
                FPressed := False;
                FMouseOver := PtInRect(ClientRect, Point(X, Y));
                FArrowDown := False;
            end;
            FLastDropDownTick := 0;
            if FArrowDown and FPressed then
                ExecuteDropDown(Self);
        end;
    end;
end;

procedure TvqToolButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);   
begin
    inherited;
    if Button = mbLeft then begin
        if (FKind = vqtbkDropDown) and FArrowDown then begin
            if PtInRect(FArrow, Point(X, Y)) then
                DoArrowClick;
        end
        else if (FKind in [vqtbkButtonDrop]) then begin
            if PtInRect(ClientRect, Point(X, Y)) then
                DoArrowClick;
        end;
    end;
    FArrowDown := False;
    FArrowHot := False;
end;

procedure TvqToolButton.MouseMove(Shift: TShiftState; X, Y: Integer);   
begin
    inherited;
    FArrowHot := PtInRect(FArrow, Point(X, Y)) or FArrowDown;
end;

procedure TvqToolButton.MouseLeave;                                                         
begin
    inherited;
    FArrowHot := FArrowDown;
end;

procedure TvqToolButton.Click;       
var
    P: TPoint;
begin
    if FKind = vqtbkButton then inherited
    else if FKind in [vqtbkButtonDrop] then begin end //!
    else if FKind = vqtbkDropDown then begin
        WidgetSet.GetCursorPos(P);
        P := ScreenToClient(P);
        if not FArrowDown and PtInRect(MainRect, P) then inherited;
    end;
end;

procedure TvqToolButton.Resize;
begin
    inherited;
    CalculateMetrics;
end;

procedure TvqToolButton.DoArrowClick;
begin
    if Assigned(FOnArrowClick) then FOnArrowClick(Self);
end;

procedure TvqToolButton.CalculateMetrics;
begin
    FArrow := ClientRect;
    if FKind = vqtbkButton then begin
        if FOrientation = vqHorizontal then
            FArrow.Left := FArrow.Right
        else
            FArrow.Top := FArrow.Bottom;
    end
    else begin
        if FOrientation = vqHorizontal then
            FArrow.Left := FArrow.Right - ArrowSize
        else
            FArrow.Top := FArrow.Bottom - ArrowSize;
    end;
end;

function TvqToolButton.MainRect: TRect;
begin
    Result := ClientRect;
    if FKind = vqtbkButton then begin end
    else begin
        if FOrientation = vqHorizontal then
            Result.Right := FArrow.Left
        else
            Result.Bottom := FArrow.Top;
    end;
end;

function TvqToolButton.GlyphSize(AArea: TRect): TSize;
begin
    Result := inherited GlyphSize(AArea);
end;

function TvqToolButton.CaptionArea: TRect;
begin
    Result := inherited CaptionArea;
    case FKind of 
        vqtbkButton:;
        vqtbkButtonDrop, vqtbkDropDown: begin
            if FOrientation = vqHorizontal then
                Dec(Result.Right, ArrowSize)
            else
                Dec(Result.Bottom, ArrowSize);
        end;
    end;
end;

procedure TvqToolButton.DrawGlyph(AArea, ARect: TRect);
begin
end;

procedure TvqToolButton.DrawArrow(ARect: TRect);
begin
    vqThemeManager.DrawArrowGlyph(Self, Canvas, ARect, vqArrowBottom, Enabled);
end;

procedure TvqToolButton.Paint;
var
    Client, FocusR: TRect;
    AState, AArrowState: TvqThemeState;
begin
    if not OwnerDraw then begin
        Client := ClientRect;

        if Color = clDefault then
            Canvas.FullBrush(clNone)
        else
            Canvas.FullBrush(Color);
        Canvas.FillRect(Client);
        
        // backs
        if FKind = vqtbkDropDown then begin
            // arrow
            if not Enabled then 
                AArrowState := [vqthDisabled]
            else if (FPressed and FArrowDown) or (FDroppedDown) then
                AArrowState := [vqthPressed]
            else if FMouseOver and FArrowHot then 
                AArrowState := [vqthHot]
            else if FMouseOver or FPressed then
                AArrowState := [vqthHovered]
            else 
                AArrowState := [vqthNormal];
            
            // main
            if not Enabled then 
                AState := [vqthDisabled]
            else if (FPressed and FArrowDown) or (FMouseOver and FArrowHot) then
                AState := [vqthHovered]
            else if FPressed then
                AState := [vqthPressed]
            else if FMouseOver then 
                AState := [vqthHot]
            else 
                AState := [vqthNormal];
            if Default then Include(AState, vqthDefaulted);
            if Focused then Include(AState, vqthFocused);
            
            // draw
            if Flat then 
                if FOrientation = vqHorizontal then
                    vqThemeManager.DrawHorzFlatDropDownButton(Self, Canvas, Client, FArrow, AState, AArrowState)
                else
                    vqThemeManager.DrawVertFlatDropDownButton(Self, Canvas, Client, FArrow, AState, AArrowState)
            else
                if FOrientation = vqHorizontal then
                    vqThemeManager.DrawHorzDropDownButton(Self, Canvas, Client, FArrow, AState, AArrowState)
                else
                    vqThemeManager.DrawVertDropDownButton(Self, Canvas, Client, FArrow, AState, AArrowState);
        end
        else begin
            if not Enabled then 
                AState := [vqthDisabled]
            else if FPressed then
                AState := [vqthPressed]
            else if FMouseOver then 
                AState := [vqthHot]
            else 
                AState := [vqthNormal];
            if Default then Include(AState, vqthDefaulted);
            if Focused then Include(AState, vqthFocused);
            if Flat then
                vqThemeManager.DrawFlatButton(Self, Canvas, Client, AState)
            else
                vqThemeManager.DrawButton(Self, Canvas, Client, AState)
        end;
        
        // caption
        
        Glyph.TransparentGlyph := True; //!
        
        FCaptionRenderer.DisabledColor := vqThemeManager.DisabledFore;
        FCaptionRenderer.Area := CaptionArea;
        FCaptionRenderer.Render(Caption, Glyph, Layout, Enabled, Spacing, vqTextHorizontal);
        
        // arrow
        
        if FKind <> vqtbkButton then
            DrawArrow(FArrow);
        
        // focus
        
    end;
    if Assigned(OnPaint) then OnPaint(Self); // restore event
end;

end.
