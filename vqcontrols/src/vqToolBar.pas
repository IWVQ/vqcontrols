// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqToolBar;

interface

uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Types, Classes, SysUtils, Graphics, Forms, Controls, StdCtrls, Buttons,
    ImgList, ComCtrls, Menus, GraphType, ToolWin, Math, Dialogs,
    vqUtils, vqThemes, vqQuickButton;

{


- Correct for MenuItem drop down
- Chevron
- PopupToolBar
- Hide clipped
- repaint
- docking
}

type
    
    { TvqToolBar }
    
    TvqToolChevron = (vqtchNone, vqtchPopupMenu, vqtchPopupToolBar);
    
    TvqToolBar = class;
    
    TvqChevronButton = class(TvqControlQuickButton)
    protected
        function ToolBar: TvqToolBar;
        procedure UpdateState(InvalidateOnChange: Boolean); override;
        procedure Click; override;
    end;
    
    TvqToolBar = class(TToolBar)
    private
        // these two variables prevents to autoclose when clicking 
        // another toolbutton with menuitem(LCL ToolBar bug)
        FWhiteFlag: Boolean;
        FBlackFlag: Boolean;
        FFloating: Boolean;
        //
        FChevronBtn: TvqChevronButton;
        FObstacle: TGraphicControl;
        
        FLeftButtonDown: Boolean;
        
        FHideClippedButtons: Boolean;
        FChevronMode: TvqToolChevron;
        FMinFloatingSize: Integer;
        
        // popup support
        FChevronMenu: TPopupMenu;
        FChevronForm: TvqPopupForm;
        FChevronSrcMenuItems: array of TMenuItem;
        FChevronIndex: Integer;
        
        FSaveParent: TWinControl;
        FSaveBounds: TRect;
        FSaveAlign: TAlign;
        FSaveAutosize: Boolean;
        FSaveConstraints: TSize;
        //
        // FOnPaintButton: TToolBarOnPaintButton;
        procedure SetChevronMode(Value: TvqToolChevron);
        procedure SetHideClippedButtons(Value: Boolean);
        
        // procedure PaintToolButton(Sender: TToolButton; State: Integer);
        procedure ChevronPrepareDropDown(Sender: TObject; var Caller: TControl);
        procedure ChevronCloseUp(Sender: TObject);
        procedure SheetCloseUp(Sender: TObject);
        procedure MoveSubMenuItems(SrcItem, DestItem: TMenuItem);
        
        // chevron and obstacle alignment
        function CalculateLineSize: Integer;
        function UpdateObstacle: Boolean;
        function UpdateChevron: Boolean;
        function ShowChevron: Boolean;
        function HideChevron: Boolean;
        procedure LocateChevron;
        procedure LocateObstacle;
        procedure ChevronBtnPaint(Sender: TObject);
    protected
        function IsInternalControl(AControl: TControl): Boolean; virtual;
        
        procedure CloseFloating; virtual;
        procedure StartFloating; virtual;
        procedure CloseChevronMenu; virtual;
        procedure CreateChevronMenu; virtual;
    protected
        procedure WndProc(var Message: TLMessage); override;
        procedure CNDropDownClosed(var Message: TLMessage); message CN_DROPDOWNCLOSED;
        procedure AlignControls(AControl: TControl; var RemainingClientRect: TRect); override;
        function CheckMenuDropdown(Button: TToolButton): Boolean; override;
        procedure Resize; override;
        // procedure DrawBackground; virtual;
        procedure Paint; override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        property ToolBarFloating: Boolean read FFloating;
    published
        property HideClippedButtons: Boolean read FHideClippedButtons write SetHideClippedButtons;
        property ChevronMode: TvqToolChevron read FChevronMode write SetChevronMode;
        property MinFloatingSize: Integer read FMinFloatingSize write FMinFloatingSize;
        
        property OnPaint;
        // property OnPaintButton: TToolBarOnPaintButton read FOnPaintButton write FOnPaintButton;
    end;
    
const
    WPARAM_CHEVRON_MENU = 1;
    
implementation

type
    TToolButtonAccess = class(TToolButton);
    
{ TToolBarObstacle }

    TToolBarObstacle = class(TGraphicControl)

    protected
        function ToolBar: TvqToolBar;

        procedure Click; override;
        procedure DblClick; override;
        procedure TripleClick; override;
        procedure QuadClick; override;
        
        procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
        procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
        procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
        procedure MouseEnter; override;
        procedure MouseLeave; override;
    end;

function TToolBarObstacle.ToolBar: TvqToolBar;
begin
    Result := nil;
    if Parent <> nil then
        if Parent is TvqToolBar then
            Result := TvqToolBar(Parent);
end;

procedure TToolBarObstacle.Click;
begin
    if ToolBar <> nil then ToolBar.Click
	else inherited;
end;

procedure TToolBarObstacle.DblClick;
begin
	if ToolBar <> nil then ToolBar.DblClick
	else inherited;
end;

procedure TToolBarObstacle.TripleClick;
begin
	if ToolBar <> nil then ToolBar.TripleClick
	else inherited;
end;

procedure TToolBarObstacle.QuadClick;
begin
	if ToolBar <> nil then ToolBar.QuadClick
	else inherited;
end;

procedure TToolBarObstacle.MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
	if ToolBar <> nil then ToolBar.MouseDown(Button, Shift, X, Y)
	else inherited;
end;

procedure TToolBarObstacle.MouseMove(Shift: TShiftState; X,Y: Integer);
begin
	if ToolBar <> nil then ToolBar.MouseMove(Shift, X, Y)
	else inherited;
end;

procedure TToolBarObstacle.MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
	if ToolBar <> nil then ToolBar.MouseUp(Button, Shift, X, Y)
	else inherited;
end;

procedure TToolBarObstacle.MouseEnter;
begin
	if ToolBar <> nil then ToolBar.MouseEnter
	else inherited;
end;

procedure TToolBarObstacle.MouseLeave;
begin
	if ToolBar <> nil then ToolBar.MouseLeave
	else inherited;
end;

{ TvqChevronButton }

function TvqChevronButton.ToolBar: TvqToolBar;
begin
    Result := Parent as TvqToolBar;
end;

procedure TvqChevronButton.UpdateState(InvalidateOnChange: Boolean);
begin
    inherited UpdateState(InvalidateOnChange);
    if (Parent <> nil) and ToolBar.ToolBarFloating then
        FState := bsDown;
end;

procedure TvqChevronButton.Click;
var
    AToolBar: TvqToolBar;
begin
    inherited Click;
    AToolBar := ToolBar;
    if AToolBar.ChevronMode = vqtchPopupToolBar then begin
        if AToolBar.ToolBarFloating then
            AToolBar.CloseFloating
        else
            AToolBar.StartFloating;
    end;
end;

{ TvqToolBar }

constructor TvqToolBar.Create(AOwner: TComponent);
begin
    FBlackFlag := False;
    FWhiteFlag := True;
    inherited Create(AOwner);
    // (inherited OnPaintButton) := @PaintToolButton;
    FHideClippedButtons := False;
    FChevronMode := vqtchNone;
    
    FChevronBtn := nil;
    FObstacle := nil;
end;

destructor TvqToolBar.Destroy;
begin
    inherited;
end;

procedure TvqToolBar.WndProc(var Message: TLMessage); 
begin
    if Message.Msg = LM_LBUTTONDOWN then
        FLeftButtonDown := True
    else if Message.Msg = LM_LBUTTONUP then
        FLeftButtonDown := False
    else if Message.Msg = CN_DROPDOWNCLOSED then
        FLeftButtonDown := False;
    inherited WndProc(Message);
end;

procedure TvqToolBar.CNDropDownClosed(var Message: TLMessage);
begin
    if Message.WParam = WPARAM_CHEVRON_MENU then
        CloseChevronMenu
    else begin
        if FBlackFlag = FWhiteFlag then
            // close only if currentmenu is the same as the posted,
            // this prevents autoclose in multiple menuitems
            inherited CNDropDownClosed(Message);
        FWhiteFlag := not FWhiteFlag;
    end;
end;

procedure TvqToolBar.AlignControls(AControl: TControl; var RemainingClientRect: TRect);
var
    Area: TRect;
    LineSize: Integer;
    AModified: Boolean;
begin
    DisableAlign;
    try
        inherited AlignControls(AControl, RemainingClientRect);
        if not FFloating then begin
            AModified := UpdateChevron;
            if AModified then
                inherited AlignControls(AControl, RemainingClientRect); // realign
        end;
    finally
        EnableAlign;
    end;
end;

function TvqToolBar.CheckMenuDropdown(Button: TToolButton): Boolean;
var
    HasSubItems, HasMenu: Boolean;
begin
    HasMenu := False;
    HasSubItems := False;
    if Button <> nil then begin
        if Assigned(Button.DropDownMenu) then begin
            HasSubItems := Button.DropDownMenu.Items.Count > 0;
            HasMenu := True;
        end
        else if Assigned(Button.MenuItem) then begin
            HasSubItems := Button.MenuItem.Count > 0;
            HasMenu := True;
        end;
    end;
    if HasMenu then
        FBlackFlag := not FBlackFlag; // switch only if message will be posted
    
    Result := inherited CheckMenuDropdown(Button);
    
    Result := Result and HasSubItems;
end;

function TvqToolBar.CalculateLineSize: Integer;
var 
    I: Integer;
    CurrControl: TControl;
begin
    Result := 0;
    if IsVertical then
        for I := 0 to ControlCount - 1 do begin
            CurrControl := Controls[I];
            if  (CurrControl.Align = alNone) and
                (CurrControl.Visible) and 
                (CurrControl <> FChevronBtn) and
                (CurrControl <> FObstacle)
                then
                Inc(Result, Controls[I].Height);
        end
    else
        for I := 0 to ControlCount - 1 do begin
            CurrControl := Controls[I];
            if  (CurrControl.Align = alNone) and
                (CurrControl.Visible) and
                (CurrControl <> FChevronBtn) and
                (CurrControl <> FObstacle)
                then
                Inc(Result, Controls[I].Width);
        end;
end;

function TvqToolBar.ShowChevron: Boolean;
begin
    Result := False;
    if FChevronBtn = nil then begin
        FChevronBtn := TvqChevronButton.Create(Self);
        FChevronBtn.Parent := Self;
        FChevronBtn.OnPrepareDropDown := @ChevronPrepareDropDown;
        FChevronBtn.OnCloseUp := @ChevronCloseUp;   
        FChevronBtn.Align := alCustom;
        
        if FObstacle = nil then begin
            FObstacle := TToolBarObstacle.Create(Self);
            FObstacle.Parent := Self;
            FObstacle.Align := alCustom;
        end;

        Result := True;
    end;   
    LocateChevron;
    LocateObstacle;
end;

function TvqToolBar.HideChevron: Boolean;
begin
    Result := True;
    if FChevronBtn <> nil then begin
        FreeAndNil(FChevronBtn);
        if not FHideClippedButtons then
            FreeAndNil(FObstacle);
        Result := True;
    end;
    if FObstacle <> nil then
        LocateObstacle;
end;

procedure TvqToolBar.LocateChevron;
var
    Area: TRect;
    ChevronSize: TSize;
begin
    if FChevronBtn = nil then Exit;
    Area := ClientRect;
    AdjustClientRect(Area);
    ChevronSize := vqThemeManager.ToolBarChevronSize;
    if IsVertical then begin
        FChevronBtn.SetBounds(
            Area.Left,
            Area.Bottom - ChevronSize.cy,
            ButtonWidth,
            ChevronSize.cy
            );
        FChevronBtn.DropDownOrientation := vqVertical;
        FChevronBtn.OwnerDraw := True;
        FChevronBtn.OnPaint := @ChevronBtnPaint;
    end
    else begin
        FChevronBtn.SetBounds(
            Area.Right - ChevronSize.cx,
            Area.Top,
            ChevronSize.cx,
            ButtonHeight
            );
        FChevronBtn.DropDownOrientation := vqHorizontal;
        FChevronBtn.OwnerDraw := True;
        FChevronBtn.OnPaint := @ChevronBtnPaint;
    end;
end;

procedure TvqToolBar.ChevronBtnPaint(Sender: TObject);
var
    AState: TvqThemeState;
begin
    if Sender <> FChevronBtn then Exit;
    AState := [];
    case FChevronBtn.FState of
        bsUp: Include(AState, vqthNormal);
        bsDown: Include(AState, vqthPressed);
        bsHot: Include(AState, vqthHot);
        bsDisabled: Include(AState, vqthDisabled);
        bsExclusive: Include(AState, vqthSelected);
    end;
    if IsVertical then
        vqThemeManager.DrawVertToolBarChevron(FChevronBtn, FChevronBtn.Canvas, FChevronBtn.ClientRect, AState)
    else
        vqThemeManager.DrawHorzToolBarChevron(FChevronBtn, FChevronBtn.Canvas, FChevronBtn.ClientRect, AState);
end;

procedure TvqToolBar.LocateObstacle;
var
    Area: TRect;
    ChevronSize: TSize;
begin
    if FObstacle = nil then Exit;
    Area := ClientRect;
    AdjustClientRect(Area);
    ChevronSize := vqThemeManager.ToolBarChevronSize;
    if FChevronBtn <> nil then
        if IsVertical then
            FObstacle.SetBounds(
                FChevronBtn.Left + FChevronBtn.Width,
                FChevronBtn.Top,
                Max(0, Area.Width - ButtonWidth),
                ChevronSize.cy
                )
        else
            FObstacle.SetBounds(
                FChevronBtn.Left,
                FChevronBtn.Top + FChevronBtn.Height,
                ChevronSize.cx,
                Max(0, Area.Height - ButtonHeight)
                )
    else
        if IsVertical then
            FObstacle.SetBounds(Area.Left, Area.Bottom, Area.Width, 0)
        else
            FObstacle.SetBounds(Area.Right, Area.Top, 0, Area.Height);
end;

function TvqToolBar.UpdateChevron: Boolean;
var
    Area: TRect;
    LineSize: Integer;
begin
    Result := False;
    if FFloating then 
        Result := ShowChevron
    else if (FChevronMode <> vqtchNone) and (not Wrapable) then begin
        Area := ClientRect;
        AdjustClientRect(Area);
        LineSize := CalculateLineSize;
        if IsVertical then
            if LineSize > Area.Height then 
                Result := ShowChevron
            else
                Result := HideChevron
        else
            if LineSize > Area.Width then
                Result := ShowChevron
            else
                Result := HideChevron;
    end
    else
        Result := HideChevron;
end;

function TvqToolBar.UpdateObstacle: Boolean;
begin
    Result := True;
    if FChevronMode = vqtchNone then begin
        if FHideClippedButtons then begin
            if FObstacle = nil then begin
                FObstacle := TToolBarObstacle.Create(Self);
                FObstacle.Parent := Self;
                FObstacle.Align := alCustom;
            end;
            LocateObstacle;
        end
        else
            FreeAndNil(FObstacle);
    end;
end;

procedure TvqToolBar.ChevronPrepareDropDown(Sender: TObject; var Caller: TControl);
begin
    if FChevronMode = vqtchPopupMenu then begin
        CreateChevronMenu;
        FChevronBtn.DropDownMenu := FChevronMenu;
    end
    else begin
        FChevronBtn.DropDownForm := nil;
        FChevronBtn.DropDownMenu := nil;
    end;
end;

procedure TvqToolBar.ChevronCloseUp(Sender: TObject);
begin
    if FChevronMenu <> nil then
        PostMessage(Handle, CN_DROPDOWNCLOSED, WPARAM_CHEVRON_MENU, 0);
end;

procedure TvqToolBar.CreateChevronMenu;
var
    ItemCount, AGroup, I: Integer;
    AItem: TMenuItem;
    AButton: TToolButton;
    SrcMainMenu: TMenu;
    Area: TRect;
begin
    if FChevronMenu <> nil then Exit;
    FChevronMenu := nil;
    FChevronSrcMenuItems := nil;

    Area := ClientRect;
    AdjustClientRect(Area);
    FChevronIndex := 0;
    while FChevronIndex < ButtonCount do begin
        if  Buttons[FChevronIndex].Visible and 
            (Buttons[FChevronIndex].Left + Buttons[FChevronIndex].Width > Area.Right) then 
            Break;
        Inc(FChevronIndex);
    end;
    
    if FChevronIndex < ButtonCount then begin
        AGroup := 0;
        FChevronMenu := TPopupMenu.Create(Self);
        FChevronMenu.Images := Self.Images;
        
        ItemCount := ButtonCount - FChevronIndex;
        SetLength(FChevronSrcMenuItems, ItemCount);
        for I := 0 to ItemCount - 1 do begin
            AButton := Buttons[FChevronIndex + I];
            FChevronSrcMenuItems[I] := nil;
            
            AItem := TMenuItem.Create(FChevronMenu);
            with AItem do begin
                Action := AButton.Action;
                Caption := AButton.Caption;
                Default := AButton.Marked;
                Checked := AButton.Down and (AButton.Style = tbsCheck);
                Enabled := AButton.Enabled;
                Visible := AButton.Visible;
                Hint := AButton.Hint;
                HelpContext := AButton.HelpContext;
                ImageIndex := AButton.ImageIndex;
                OnClick := AButton.OnClick;
                
                // GroupIndex
                // RadioItem
                // AutoCheck
                // ShowAlwaysCheckable
                case AButton.Style of
                    tbsButton: ;
                    tbsCheck: begin
                        ShowAlwaysCheckable := True;
                        AutoCheck := True;
                        if AButton.Grouped then begin
                            RadioItem := True;
                            GroupIndex := AGroup;
                        end;
                    end;
                    tbsSeparator,
                    tbsDivider: begin
                        Caption := cLineCaption;
                        Inc(AGroup);
                    end;
                    tbsDropDown, tbsButtonDrop: ;
                end;
                // Items
                if Assigned(AButton.DropDownMenu) then begin
                    FChevronSrcMenuItems[I] := AButton.DropDownMenu.Items;
                    SubMenuImages := AButton.DropDownMenu.Images;
                    MoveSubMenuItems(FChevronSrcMenuItems[I], AItem);
                end
                else if Assigned(AButton.MenuItem) then begin
                    FChevronSrcMenuItems[I] := AButton.MenuItem;
                    SrcMainMenu := AButton.MenuItem.GetParentMenu;
                    if Assigned(SrcMainMenu) then
                        SubMenuImages := SrcMainMenu.Images;
                    MoveSubMenuItems(FChevronSrcMenuItems[I], AItem);
                end;
            end;
            FChevronMenu.Items.Add(AItem);
        end;
    end;
    
end;

procedure TvqToolBar.CloseChevronMenu;
var
    I, ItemCount: Integer;
    AButton: TToolButton;
    AItem: TMenuItem;
begin
    //FChevronMenu.Close;
    ItemCount := Length(FChevronSrcMenuItems);
    for I := 0 to ItemCount - 1 do begin
        AButton := Buttons[FChevronIndex + I];
        AItem := FChevronMenu.Items[I];
        
        if AButton.Style = tbsCheck then
            AButton.Down := AItem.Checked;
        
        MoveSubMenuItems(AItem, FChevronSrcMenuItems[I]);
    end;
    FreeAndNil(FChevronMenu);
end;

procedure TvqToolBar.MoveSubMenuItems(SrcItem, DestItem: TMenuItem);
var
    I: Integer;
    AItem: TMenuItem;
begin
    if (SrcItem <> nil) and (DestItem <> nil) and (SrcItem <> DestItem) then
        for I := SrcItem.Count - 1 downto 0 do begin
            AItem := SrcItem.Items[I];
            SrcItem.Delete(I);
            DestItem.Insert(0, AItem);
        end;
end;

procedure TvqToolBar.StartFloating;
var
    P: TPoint;
    FormAlignment: TAlignment;
    FormLayout: TTextLayout;
    NewWidth, NewHeight, Delta, SheetWidth: Integer;
begin
    if (ChevronMode = vqtchPopupToolBar) and (FChevronBtn <> nil) then begin

        FChevronForm := TvqPopupForm.CreateNew(nil);
        FChevronForm.FreeOnClose := True;

        if IsVertical then begin            
            P := ClientToScreen(Point(0, Height));   
            FormAlignment := taLeftJustify; 
            FormLayout := tlBottom;
        end
        else begin                          
            P := ClientToScreen(Point(Width, 0)); 
            FormAlignment := taRightJustify; 
            FormLayout := tlTop;
        end;
                   
        FSaveParent := Parent;
        FSaveBounds := BoundsRect;
        FSaveAlign := Align;
        FSaveAutosize := Autosize;
        FSaveConstraints.cx := Constraints.MinWidth;
        FSaveConstraints.cy := Constraints.MinHeight;

        Parent := FChevronForm;
        Wrapable := True; // no problem
        Align := alClient;              
        AutoSize := True;
        //FChevronForm.AutoSize := True;
        FChevronForm.OnCloseUp := @SheetCloseUp;

        if IsVertical then begin
            FChevronForm.Height := Max(FSaveBounds.Height, MinFloatingSize);
            //WrapButtons(Width, NewWidth, NewHeight, True);
        end
        else begin
            FChevronForm.Width := Max(FSaveBounds.Width, MinFloatingSize);
            SheetWidth := FChevronForm.Width;
            WrapButtons(SheetWidth - 2, NewWidth, NewHeight, True);
            FChevronForm.Height := NewHeight + 2;
        end;

        FFloating := True;
        FChevronForm.PopUp(P.X, P.Y, FormAlignment, FormLayout);

    end;
end;

function TvqToolBar.IsInternalControl(AControl: TControl): Boolean;
begin
    Result := (AControl <> nil) and 
        ((AControl = FChevronBtn) or (AControl = FObstacle));
end;

procedure TvqToolBar.CloseFloating;
begin
    if FChevronForm = nil then Exit;
    FChevronForm.Return;
    FChevronForm := nil; // no problem
end;

procedure TvqToolBar.SheetCloseUp(Sender: TObject);
begin
    Parent                := FSaveParent        ;
    BoundsRect            := FSaveBounds        ;
    Align                 := FSaveAlign         ;
    Autosize              := FSaveAutosize      ;
    Constraints.MinWidth  := FSaveConstraints.cx;
    Constraints.MinHeight := FSaveConstraints.cy;
    Wrapable              := False; // no problem

    FFloating := False;
    UpdateChevron;

end;

procedure TvqToolBar.Resize;
begin
    inherited;
    LocateChevron;
    LocateObstacle;
end;

procedure TvqToolBar.SetChevronMode(Value: TvqToolChevron);
begin
    if FChevronMode <> Value then begin
        FChevronMode := Value;
        if FChevronMenu <> nil then
            CloseChevronMenu;
        if FChevronForm <> nil then 
            CloseFloating;
        UpdateChevron;
    end;
end;

procedure TvqToolBar.SetHideClippedButtons(Value: Boolean);
begin
    if FHideClippedButtons <> Value then begin
        FHideClippedButtons := Value;
        if FChevronMenu <> nil then
            CloseChevronMenu;
        if FChevronForm <> nil then 
            CloseFloating;
        UpdateObstacle;
    end;
end;
{
procedure TvqToolBar.DrawBackground;
begin
end;
}
procedure TvqToolBar.Paint;
{
const
    EdgeStyles: array[TEdgeStyle, TEdgeStyle] of Integer = 
        ((0, BDR_RAISEDINNER, BDR_SUNKENINNER),
         (0, BDR_RAISEDOUTER, BDR_SUNKENOUTER));

var
    EdgeFlags: Cardinal;
}
begin
    inherited Paint;
    {
    DrawBackground;
    
    EdgeFlags := 0;
    if ebLeft   in EdgeBorders then EdgeFlags := EdgeFlags or Longint(BF_LEFT);
    if ebRight  in EdgeBorders then EdgeFlags := EdgeFlags or Longint(BF_RIGHT);
    if ebTop    in EdgeBorders then EdgeFlags := EdgeFlags or Longint(BF_TOP);
    if ebBottom in EdgeBorders then EdgeFlags := EdgeFlags or Longint(BF_BOTTOM);
    vqThemeManager.DrawEdge(Self, Canvas, ClientRect, EdgeStyles[EdgeInner, EdgeOuter], EdgeFlags);
    
    if Assigned(OnPaint) then OnPaint(Self);}
end;
(*
procedure TvqToolBar.PaintToolButton(Sender: TToolButton; State: Integer);
var
    Client, MainR, ArrR: TRect;
    Str: string;
    
    CImgs: TCustomImageList;
    Imgs: TImageList;
    ImgIndex: Integer;
    ImgEffect: TGraphicsDrawEffect;
    AState, AArrowState: TvqThemeState;
begin
    
    if Assigned(FOnPaintButton) then begin
        FOnPaintButton(Sender, State);
        Exit;
    end;
    
    Client := Sender.ClientRect;
    State := TToolButtonAccess(Sender).GetButtonDrawDetail.State;
    {
    state:
        1: normal
        2: hot
        3: pressed
        4: disabled
        5: checked
        6: checkedhot
    }
    
    Sender.GetCurrentIcon(CImgs, ImgIndex, ImgEffect);
    if CImgs is TImageList then Imgs := TImageList(CImgs)
    else Imgs := nil;
    
    MainR := Client;
    if Sender.Style in [tbsButtonDrop, tbsDropDown] then begin
        MainR.Right := R.Right - DropDownWidth;
        ArrR := R;
        ArrR.Left := MainR.Right;
    end;
    
    with Sender do begin
        AState := [];
        case State of
            1: Include(AState, vqthNormal);
            2: Include(AState, vqthHot);
            3: Include(AState, vqthPressed);
            4: Include(AState, vqthDisabled);
            5: Include(AState, vqthSelected);
            6: Include(AState, vqthSelected);
        end;
        
        if Style = tbsDivider then
            if Self.IsVertical then 
                vqThemeManager.DrawVertDivider(Self, Canvas, MainR, AState)
            else
                vqThemeManager.DrawHorzDivider(Self, Canvas, MainR, AState);
        else if Style = tbsSeparator then
            if Self.IsVertical then 
                vqThemeManager.DrawVertSpacer(Self, Canvas, MainR, AState)
            else
                vqThemeManager.DrawHorzSpacer(Self, Canvas, MainR, AState);
        else if Style = tbsDropDown then begin
            AArrowState := AState;
            P := ScreenToClient(Mouse.CursorPos);
            if State = 2 then begin
                if FLeftButtonDown then begin
                    AArrowState := [vqthPressed];
                    AState := [vqthHovered];
                end
                else if PointInArrow(P.X, P.Y) then
                    AState := [vqthHovered]
                else
                    AArrowState := [vqthHovered];
            end
            else if State = 4 then 
                AArrowState := [vqthHovered];
            
            if Self.Flat then
                vqThemeManager.DrawHorzFlatDropDownButton(Self, Canvas, MainR, ArrR, AState, AArrowState)
            else
                vqThemeManager.DrawHorzDropDownButton(Self, Canvas, MainR, ArrR, AState, AArrowState);
        end
        else { tbsbutton, tbscheck } begin
            if Self.Flat then
                vqThemeManager.DrawFlatButton(Self, Canvas, MainR, AState)
            else
                vqThemeManager.DrawButton(Self, Canvas, MainR, AState);
        end;
        
        // arrow
        if Style in [tbsButtonDrop, tbsDropDown] then
            vqThemeManager.DrawArrowGlyph(Self, Canvas, ArrR, vqArrowBottom, State <> 4);
        
        // caption
        if not (Sender.Style in [tbsDivider, tbsSeparator]) then begin 
            MainR := vqThemeManager.ButtonContentRect(MainR);
            
            Font := Sender.Font;
            
            if ShowCaptions then Str := Sender.Caption
            else Str := '';
            
            if List then
                vqThemeManager.DrawLineCaption(Canvas, MainR, Str, nil, Imgs, ImgIndex, 
                    taCenter, blGlyphLeft, State <> 4, vqThemeManager.DisabledFore)
            else  
                vqThemeManager.DrawLineCaption(Canvas, MainR, Str, nil, Imgs, ImgIndex, 
                    taCenter, blGlyphTop, State <> 4, vqThemeManager.DisabledFore);
        end;
    end;
end;
*)
end.
