// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqQuickButton;

interface

uses
    InterfaceBase, LMessages, LCLType,
	Classes, Types, SysUtils, Controls, Graphics, ExtCtrls, StdCtrls, ComCtrls,
    Buttons, Menus, Dialogs,
	vqUtils, vqThemes;

type
    TvqQuickButtonKind = (
        vqqbkCustom,
        vqqbkClose,
        vqqbkArrowLeft, vqqbkArrowTop, vqqbkArrowRight, vqqbkArrowBottom
        );
    
    TvqCustomQuickButton = class(TCustomSpeedButton)
    private
        FKind: TvqQuickButtonKind;
        FDropDownMenu: TPopupMenu;
        FDropDownForm: TvqPopupForm;
        FDropDownOrientation: TvqOrientation;
        FDropDownAlignment: TAlignment;
        FDropDownLayout: TTextLayout;
        FOwnerDraw: Boolean;
        
        FDroppedDown: Boolean;
        FLastDropDownTick: QWord;
        
        FOnCloseUp: TNotifyEvent;
        FOnDropDown: TNotifyEvent;
        FOnPrepareDropDown: TvqDropDownEvent;
        procedure SetOwnerDraw(Value: Boolean);
        procedure SetKind(Value: TvqQuickButtonKind);
        procedure SetDropDownMenu(Value: TPopupMenu);
        procedure SetDropDownForm(Value: TvqPopupForm);
        
        procedure CMColorChanged(var Message: TLMessage); message CM_COLORCHANGED;
        procedure CMFontChanged(var Message: TLMessage); message CM_FONTCHANGED;
        
        procedure OnDropdownFormShow(Sender: TObject);
        procedure OnDropdownFormHide(Sender: TObject);
    protected

        procedure Paint; override;
        procedure ColorChanged; virtual;
        procedure FontChanged; virtual;
        procedure UpdateMetrics; virtual;
        
        procedure ExecuteCloseUp; virtual;
        procedure SendMouseUpMsg; //!
        procedure DoPrepareDropDown(var Caller: TControl); virtual;
        procedure DoCloseUp; virtual;
        procedure DoDropDown; virtual;
        procedure ExecuteDropDown(Caller: TControl); virtual;
        
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure UpdateState(InvalidateOnChange: Boolean); override;
        procedure PaintBackground(var PaintRect: TRect); override;
        
        class function GetControlClassDefaultSize: TSize; override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        
        property OwnerDraw: Boolean read FOwnerDraw write SetOwnerDraw;
        property Kind: TvqQuickButtonKind read FKind write SetKind default vqqbkCustom;
        property DropDownAlignment: TAlignment read FDropDownAlignment write FDropDownAlignment;
        property DropDownLayout: TTextLayout read FDropDownLayout write FDropDownLayout;
        property DropDownMenu: TPopupMenu read FDropDownMenu write SetDropDownMenu;
        property DropDownForm: TvqPopupForm read FDropDownForm write SetDropDownForm;
        property DropDownOrientation: TvqOrientation read FDropDownOrientation write FDropDownOrientation;
        property OnPrepareDropDown: TvqDropDownEvent read FOnPrepareDropDown write FOnPrepareDropDown;
        property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
        property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
    end;
    
    TvqQuickButton = class(TvqCustomQuickButton)
    published
        property Action;
        property Align;
        property AllowAllUp;
        property Anchors;
        property AutoSize;
        property BidiMode;
        property BorderSpacing;
        property Constraints;
        property Caption;
        property Color;
        property Down;
        property Enabled;
        property Flat;
        property Font;
        property Glyph;
        property GroupIndex;
        property Images;
        property ImageIndex;
        property ImageWidth;
        property Layout;
        property Margin;
        property NumGlyphs;
        property Spacing;
        property Transparent;
        property Visible;    
        property ShowCaption;
        property ShowHint;
        property ParentBidiMode;
        property ParentFont;
        property ParentShowHint;
        property PopupMenu;

        property OwnerDraw;
        property Kind;
        property DropDownMenu;
        property DropDownForm;
        property DropDownOrientation;
        property OnPrepareDropDown;

        property OnChangeBounds;
        property OnClick;
        property OnDblClick;
        property OnMouseDown;
        property OnMouseEnter;
        property OnMouseLeave;
        property OnMouseMove;
        property OnMouseUp;
        property OnResize;
        property OnPaint;
        property OnContextPopup;
    end;
    
    TvqControlQuickButton = class(TvqCustomQuickButton)
    private
        procedure CMDesignHitTest(var Message: TCMDesignHitTest); message CM_DESIGNHITTEST;
    end;
    
implementation

constructor TvqCustomQuickButton.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
    
    FDropDownAlignment := taLeftJustify;
    FDropDownLayout := tlTop;
    FDropDownOrientation := vqHorizontal;
    FKind := vqqbkCustom;
    FOwnerDraw := False;
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
end;

destructor TvqCustomQuickButton.Destroy;
begin
    inherited;
end;

class function TvqCustomQuickButton.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 17;
    Result.cy := 17;
end;

procedure TvqCustomQuickButton.SetOwnerDraw(Value: Boolean);
begin
    if FOwnerDraw <> Value then begin
        FOwnerDraw := Value;
        Repaint;
    end;
end;

procedure TvqCustomQuickButton.SetKind(Value: TvqQuickButtonKind);
begin
    if FKind <> Value then begin
        FKind := Value;
        Invalidate;
    end;
end;

procedure TvqCustomQuickButton.SetDropDownMenu(Value: TPopupMenu);
begin
    if FDroppedDown then Exit;
    FDropDownMenu := Value;
end;

procedure TvqCustomQuickButton.SetDropDownForm(Value: TvqPopupForm);
begin
    if FDroppedDown then Exit;
    FDropDownForm := Value;
end;

procedure TvqCustomQuickButton.ColorChanged;
begin
end;

procedure TvqCustomQuickButton.FontChanged;
begin
end;

procedure TvqCustomQuickButton.UpdateMetrics;
begin
    Invalidate;
end;

procedure TvqCustomQuickButton.CMColorChanged(var Message: TLMessage);
begin
    inherited;
    ColorChanged;
end;

procedure TvqCustomQuickButton.CMFontChanged(var Message: TLMessage);
begin
    inherited;
    FontChanged;
end;

procedure TvqCustomQuickButton.SendMouseUpMsg;
var
    Msg: TLMMouse;
    P: TPoint;
begin
    FillChar(Msg, SizeOf(Msg), 0);
    Msg.Msg := LM_LBUTTONUP;
    P := ScreenToClient(Mouse.CursorPos);
    Msg.XPos := P.X;
    Msg.YPos := P.Y;
    FState := bsUp;
    WndProc(TLMessage(Msg));
end;

procedure TvqCustomQuickButton.DoPrepareDropDown(var Caller: TControl);
begin
    if Assigned(FOnPrepareDropDown) then FOnPrepareDropDown(Self, Caller);
end;

procedure TvqCustomQuickButton.DoCloseUp;
begin
    if Assigned(FOnCloseUp) then FOnCloseUp(Self);
end;

procedure TvqCustomQuickButton.DoDropDown;
begin
    if Assigned(FOnDropDown) then FOnDropDown(Self);
end;

procedure TvqCustomQuickButton.OnDropdownFormShow(Sender: TObject);
begin
    FDroppedDown := True;
    DoDropDown;
end;

procedure TvqCustomQuickButton.OnDropdownFormHide(Sender: TObject);
begin
    DoCloseUp;
    FDroppedDown := False;
    FLastDropDownTick := GetTickCount64;
end;

procedure TvqCustomQuickButton.ExecuteDropDown(Caller: TControl);
begin
    if FDroppedDown then Exit;
    DoPrepareDropDown(Caller);
    if FDropDownForm <> nil then begin
        FDropDownForm.OnShow := @OnDropdownFormShow;
        FDropDownForm.OnHide := @OnDropdownFormHide;
        FDropDownForm.DropDown(Caller, FDropDownAlignment, FDropDownLayout, FDropDownOrientation);
    end
    else if (FDropDownMenu <> nil) and (FDropDownMenu.Items.Count > 0) then begin
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

procedure TvqCustomQuickButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	inherited;
    if Button = mbLeft then begin
        if (GetTickCount64 < FLastDropDownTick + 100) and (FState = bsDown) then begin
            if MouseInControl then
                FState := bsHot
            else
                FState := bsUp;
        end;
        FLastDropDownTick := 0;
        if FState = bsDown then
            ExecuteDropDown(Self);
    end;
end;

procedure TvqCustomQuickButton.ExecuteCloseUp;
begin
    if FDroppedDown then begin
        if FDropDownForm <> nil then 
            FDropDownForm.Return
        else if FDropDownMenu <> nil then
            FDropDownMenu.Close;
    end;
end;

procedure TvqCustomQuickButton.UpdateState(InvalidateOnChange: Boolean);
begin
    inherited UpdateState(InvalidateOnChange);
    if FDroppedDown and IsEnabled then
        FState := bsDown;
end;

procedure TvqCustomQuickButton.PaintBackground(var PaintRect: TRect);
var
    AState: TvqThemeState;
begin
    AState := [vqthNormal];
    case FState of
        bsUp: Include(AState, vqthNormal);
        bsDown: Include(AState, vqthPressed);
        bsHot: Include(AState, vqthHot);
        bsDisabled: Include(AState, vqthDisabled);
        bsExclusive: Include(AState, vqthSelected);
    end;

    if FKind = vqqbkClose then begin
        if Flat then
            vqThemeManager.DrawFlatCloseButton(Self, Canvas, PaintRect, AState)
        else
            vqThemeManager.DrawCloseButton(Self, Canvas, PaintRect, AState);
    end
    else begin
        if Flat then
            vqThemeManager.DrawFlatButton(Self, Canvas, PaintRect, AState)
        else
            vqThemeManager.DrawButton(Self, Canvas, PaintRect, AState);
        case FKind of
            vqqbkArrowLeft  : vqThemeManager.DrawArrowGlyph(Self, Canvas, PaintRect, vqArrowLeft  , Enabled);
            vqqbkArrowTop   : vqThemeManager.DrawArrowGlyph(Self, Canvas, PaintRect, vqArrowTop   , Enabled);
            vqqbkArrowRight : vqThemeManager.DrawArrowGlyph(Self, Canvas, PaintRect, vqArrowRight , Enabled);
            vqqbkArrowBottom: vqThemeManager.DrawArrowGlyph(Self, Canvas, PaintRect, vqArrowBottom, Enabled);
        end;
    end;
    PaintRect := vqThemeManager.ButtonContentRect(PaintRect);
end;

procedure TvqCustomQuickButton.Paint;
begin
    if OwnerDraw then begin
        if Assigned(OnPaint) then OnPaint(Self);
    end
    else
        inherited Paint;
end;

{ TvqControlQuickButton }

procedure TvqControlQuickButton.CMDesignHitTest(var Message: TCMDesignHitTest);
begin
    Message.Result := 1;
end;

end.
