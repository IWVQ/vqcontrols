// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqButtons;

interface

uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Types, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
    ImgList, ActnList,
    vqUtils, vqThemes;

type
    
    { TvqPushControl }
    
    TvqPushControl = class(TvqCustomControl)
    private
        FFocusable: Boolean;
        FOwnerDraw: Boolean;
        procedure SetFocusable(Value: Boolean);
        procedure SetOwnerDraw(Value: Boolean);
        
        procedure WMDefaultClicked(var Message: TLMessage); message LM_CLICKED;
    strict protected
        FPressed: Boolean;
        FMouseOver: Boolean;
    protected
        procedure KeyDown(var Key: Word; Shift: TShiftState); override;
        procedure KeyUp(var Key: Word; Shift: TShiftState); override;
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        procedure MouseEnter; override;
        procedure MouseLeave; override;
        
        function GetActionLinkClass: TControlActionLinkClass; override;
        function GetChecked: Boolean; virtual;
        procedure SetChecked(Value: Boolean); virtual;
        
        procedure WndProc(var Message: TLMessage); override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        
        procedure Toggle;
        
        function CanFocus: Boolean; override;
        
        property OwnerDraw: Boolean read FOwnerDraw write SetOwnerDraw;
        property Checked: Boolean read GetChecked write SetChecked default False;
        property Focusable: Boolean read FFocusable write SetFocusable default True;
    end;
    
    { TvqPushActionLink }
    
    TvqPushActionLink = class(TControlActionLink)
    protected
        procedure SetChecked(Value: Boolean); override;
    public
        function IsCheckedLinked: Boolean; override;
    end;
    
    { TvqButtonControl }

    TvqButtonControl = class(TvqPushControl)
    private
        FDefault: Boolean;
        FCancel: Boolean;
        FModalResult: Integer;
        FActive: Boolean;
        FUpdatingDefaultCancel: Boolean;
        
        FGlyph: TvqGlyph;
        FLayout: TvqGlyphLayout;
        FFlat: Boolean;
        FTextFormat: TvqTextFormat;
        FChecked: Boolean;
        FCheckable: Boolean;
        
        procedure OnGlyphChange(Sender: TObject);
        procedure SetGlyph(Value: TvqGlyph);
        procedure SetDefault(Value: Boolean);
        procedure SetCancel(Value: Boolean);
        procedure SetModalResult(Value: Integer);
        procedure SetTextFormat(Value: TvqTextFormat);
        procedure SetLayout(Value: TvqGlyphLayout);
        procedure SetFlat(Value: Boolean);
        procedure SetCheckable(Value: Boolean);
        procedure OnTextFormatChange(Sender: TObject);
        
        procedure UpdateDefaultCancel;
        
        procedure CMUIActivate(var Message: TLMessage); message CM_UIACTIVATE;

        function RendererGlyphSize(AArea: TRect): TSize;
        procedure RendererDrawGlyph(AArea, ARect: TRect);
    strict protected
        FCaptionRenderer: TvqCaptionRenderer;
    protected
        class function GetControlClassDefaultSize: TSize; override;
        function DialogChar(var Message: TLMKey): Boolean; override;
        function GlyphSize(AArea: TRect): TSize; virtual;
        function CaptionArea: TRect; virtual;
        procedure DrawGlyph(AArea, ARect: TRect); virtual;
        
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        procedure BorderChanged; override;
        procedure EnabledChanged; override;
        procedure ColorChanged; override;
        procedure FontChanged; override;
        procedure TextChanged; override;
        procedure FocusChanged(AFocused: Boolean); override;
        function GetChecked: Boolean; override;
        procedure SetChecked(Value: Boolean); override;
        
        procedure Click; override;
        procedure Resize; override;
        procedure Loaded; override;
        procedure Paint; override;
        procedure UpdateMetrics; override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure ExecuteDefaultAction; override;
        procedure ExecuteCancelAction; override;
        procedure ActiveDefaultControlChanged(NewControl: TControl); override;
        procedure UpdateRolesForForm; override;
        property Active: Boolean read FActive;
        property Checkable: Boolean read FCheckable write SetCheckable;
    published
        property Spacing;
        property Glyph: TvqGlyph read FGlyph write SetGlyph;
        property ModalResult: Integer read FModalResult write SetModalResult default 0;
        property Default: Boolean read FDefault write SetDefault default False;
        property Cancel: Boolean read FCancel write SetCancel default False;
        property TextFormat: TvqTextFormat read FTextFormat write SetTextFormat;
        property Layout: TvqGlyphLayout read FLayout write SetLayout default blGlyphTop;
        property Flat: Boolean read FFlat write SetFlat default False;
        property BorderWidth;
        
        property AutoSize default False;
        property BidiMode;
        property Caption;
        property DragCursor;
        property DragKind;
        property DragMode;
        property Font;
        property ParentBidiMode;
        property ParentFont;
        property PopupMenu;
        property TabOrder;
        property TabStop;
        
        property OnChange;
        property OnContextPopup;
        property OnDragDrop;
        property OnDragOver;
        property OnEndDrag;
        property OnStartDrag;
        property OnUTF8KeyPress;
    end;
    
    TvqButton = class(TvqButtonControl)
    published
        property Checkable;
        property Checked;
    end;
    
implementation

{ TvqPushControl }

constructor TvqPushControl.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FFocusable := True;
    FOwnerDraw := False;
    
    ControlStyle := ControlStyle + [csParentBackground] - [csOpaque];
    FPressed := False;
    FMouseOver := False;
    
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
    
    TabStop := True;
end;

destructor TvqPushControl.Destroy;
begin
    inherited;
end;

procedure TvqPushControl.Toggle;
begin
    Checked := not Checked;
end;

function TvqPushControl.CanFocus: Boolean;
begin
    if FFocusable then Result := inherited CanFocus
    else Result := False;
end;

procedure TvqPushControl.WndProc(var Message: TLMessage);
begin
    if (Message.Msg = LM_LBUTTONDOWN) and CanFocus and not (csNoFocus in ControlStyle) then
        SetFocus;
    inherited WndProc(Message);
end;

procedure TvqPushControl.KeyDown(var Key: Word; Shift: TShiftState);
begin
    if Key = VK_SPACE then begin
       FPressed := True;
       Repaint;
    end
    else if Key = VK_RETURN then begin
       FPressed := True;
    end;
    inherited KeyDown(Key, Shift);
end;

procedure TvqPushControl.KeyUp(var Key: Word; Shift: TShiftState);
begin
    if Key in [VK_SPACE, VK_RETURN] then begin
        FPressed := False;
        Repaint;
        Click;
    end;
    inherited KeyUp(Key, Shift);
end;

procedure TvqPushControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); 
begin
    FPressed := True;
    Repaint;
    inherited;
end;

procedure TvqPushControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);   
begin
    FPressed := False;
    Repaint;
    inherited;
end;

procedure TvqPushControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseMove(Shift, X, Y);
end;

procedure TvqPushControl.MouseEnter;                                                         
begin
    inherited;
    FMouseOver := True;
    Repaint;
end;

procedure TvqPushControl.MouseLeave;                                                         
begin
    inherited;
    FMouseOver := False;
    Repaint;
end;

function TvqPushControl.GetActionLinkClass: TControlActionLinkClass;
begin
    Result := TvqPushActionLink;
end;

function TvqPushControl.GetChecked: Boolean;
begin
    Result := False;
end;

procedure TvqPushControl.SetChecked(Value: Boolean);
begin
end;

procedure TvqPushControl.SetFocusable(Value: Boolean);
begin
    if FFocusable <> Value then begin
        FFocusable := Value;
        TabStop := FFocusable;
        if FFocusable then ControlStyle := ControlStyle - [csNoFocus]
        else ControlStyle := ControlStyle + [csNoFocus];
        Invalidate;
    end;
end;

procedure TvqPushControl.SetOwnerDraw(Value: Boolean);
begin
    if FOwnerDraw <> Value then begin
        FOwnerDraw := Value;
        Repaint;
    end;
end;

procedure TvqPushControl.WMDefaultClicked(var Message: TLMessage);
begin
    if not ((csClickEvents in ControlStyle) and (csClicked in ControlState)) then
        Click; 
end;

{ TvqPushActionLink }

function TvqPushActionLink.IsCheckedLinked: Boolean;
begin
    Result := inherited IsCheckedLinked
        and (TvqPushControl(FClient).Checked = 
            (Action as TCustomAction).Checked);
end;

procedure TvqPushActionLink.SetChecked(Value: Boolean);
begin
    if IsCheckedLinked then
        TvqPushControl(FClient).Checked := Value;
end;

{ TvqButtonControl }

constructor TvqButtonControl.Create(AOwner: TComponent);                                       
begin
    inherited Create(AOwner);        
    FGlyph := TvqGlyph.Create(AOwner);
    FGlyph.OnChange := @OnGlyphChange;
    
    FLayout := blGlyphTop;
    FFlat := False;
    FTextFormat := TvqTextFormat.Create(Self);
    FTextFormat.Alignment := taCenter;
    FTextFormat.Layout := tlCenter;
    FTextFormat.Clipping := True;

    FCaptionRenderer := TvqCaptionRenderer.Create;
    FCaptionRenderer.Format := FTextFormat;
    FCaptionRenderer.Font := Font;
    FCaptionRenderer.Canvas := Canvas;
                                                      
    FCaptionRenderer.OwnerDraw := False;
    FCaptionRenderer.DrawGlyphMethod := @RendererDrawGlyph;
    FCaptionRenderer.GlyphSizeMethod := @RendererGlyphSize;
    
end;

destructor TvqButtonControl.Destroy;                                                           
begin
    FGlyph.Free;
    FTextFormat.Free;
    FCaptionRenderer.Free;
    inherited;
end;

class function TvqButtonControl.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 70;
    Result.cy := 25;
end;

procedure TvqButtonControl.Resize;
begin
    inherited;
end;

procedure TvqButtonControl.UpdateMetrics;
begin
    InvalidatePreferredSize;
    AdjustSize;
    inherited;
end;

procedure TvqButtonControl.Loaded;
begin
    inherited;
    UpdateDefaultCancel;
end;

procedure TvqButtonControl.UpdateDefaultCancel;
var
    Form: TCustomForm;
begin
    FUpdatingDefaultCancel := True;
    Form := GetParentForm(Self);
    if Assigned(Form) then begin
        if FDefault then Form.DefaultControl := Self;
        if FCancel then Form.CancelControl := Self;
    end;
    FUpdatingDefaultCancel := False;
end;

procedure TvqButtonControl.ExecuteDefaultAction;
begin
    if FActive or FDefault then Click;
end;

procedure TvqButtonControl.ExecuteCancelAction;
begin
    if FCancel then Click;
end;

procedure TvqButtonControl.ActiveDefaultControlChanged(NewControl: TControl);
var
    Form: TCustomForm;
begin
    Form := GetParentForm(Self);
    if NewControl = Self then begin
        FActive := True;
        if Assigned(Form) then Form.DefaultControl := Self;
    end
    else if NewControl <> nil then
        FActive := False
    else begin
        FActive := FDefault;
        if Assigned(Form) then
            if Form.DefaultControl = Self then Form.DefaultControl := nil;
    end;    
end;

procedure TvqButtonControl.UpdateRolesForForm;
var
    Form: TCustomForm;
    Roles: TControlRolesForForm;
begin
    if FUpdatingDefaultCancel then Exit;
    Form := GetParentForm(Self);
    if Assigned(Form) then begin
        Roles := Form.GetRolesForControl(Self);
        Default := crffDefault in Roles;
        Cancel := crffCancel in Roles;
    end;
end;

procedure TvqButtonControl.OnGlyphChange(Sender: TObject);
begin
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqButtonControl.SetGlyph(Value: TvqGlyph);
begin
    FGlyph.Assign(Value);
end;

procedure TvqButtonControl.SetFlat(Value: Boolean);                                            
begin
    if FFlat <> Value then begin
        FFlat := Value;
        Invalidate;
    end;
end;

procedure TvqButtonControl.SetTextFormat(Value: TvqTextFormat);
begin
    FTextFormat.Assign(Value);
end;

procedure TvqButtonControl.SetLayout(Value: TvqGlyphLayout);
begin
    if FLayout <> Value then begin
        FLayout := Value;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqButtonControl.SetDefault(Value: Boolean);
var
    Form: TCustomForm;
begin
    if FDefault <> Value then begin
        FDefault := Value;
        Form := GetParentForm(Self);
        if Assigned(Form) then
            if FDefault then Form.DefaultControl := Self
            else if Form.DefaultControl = Self then Form.DefaultControl := nil;
    end;
end;

procedure TvqButtonControl.SetCancel(Value: Boolean);
var
    Form: TCustomForm;
begin
    if FCancel <> Value then begin
        FCancel := Value;
        Form := GetParentForm(Self);
        if Assigned(Form) then
            if FCancel then Form.CancelControl := Self
            else Form.CancelControl := nil;
    end;
end;

procedure TvqButtonControl.SetModalResult(Value: Integer);
begin
    FModalResult := Value;
end;

function TvqButtonControl.GetChecked: Boolean;
begin
    Result := FChecked;
end;

procedure TvqButtonControl.SetChecked(Value: Boolean);
begin
    if not FCheckable then Value := False;
    if FChecked <> Value then begin
        FChecked := Value;
        Invalidate;
    end;
end;

procedure TvqButtonControl.SetCheckable(Value: Boolean);
begin
    if FCheckable <> Value then begin
        FCheckable := Value;
        if not FCheckable then
            SetChecked(False);
    end;
end;

procedure TvqButtonControl.BorderChanged;
begin
    inherited;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqButtonControl.EnabledChanged;                                                     
begin
    inherited;
    Invalidate;
end;

procedure TvqButtonControl.ColorChanged;                                                       
begin
    inherited;
    Invalidate;
end;

procedure TvqButtonControl.FontChanged;                                                        
begin
    inherited;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqButtonControl.TextChanged;                                                        
begin
    inherited;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqButtonControl.FocusChanged(AFocused: Boolean);
var
    Form: TCustomForm;
begin
    inherited;
    Form := GetParentForm(Self);
    if Form <> nil then begin
        if AFocused then
            ActiveDefaultControlChanged(Form.ActiveControl)
        else
            ActiveDefaultControlChanged(nil);
    end;
    Invalidate;
end;

procedure TvqButtonControl.CMUIActivate(var Message: TLMessage);
var
    Form: TCustomForm;
begin
    Form := GetParentForm(Self);
    if Form <> nil then
        ActiveDefaultControlChanged(Form.ActiveControl);
end;

procedure TvqButtonControl.OnTextFormatChange(Sender: TObject);
begin
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqButtonControl.Click;    
var
    Form: TCustomForm;
begin
    if FModalResult <> mrNone then begin
        Form := GetParentForm(Self);
        if Assigned(Form) then Form.ModalResult := FModalResult;
    end;
    if FCheckable then
        Toggle;
    inherited Click;
end;

function TvqButtonControl.DialogChar(var Message: TLMKey): Boolean;
begin
    Result := False;
    if (Message.msg <> LM_SYSCHAR) then Exit;
    if Enabled and FTextFormat.ShowPrefix and IsAccel(Message.CharCode, Caption) then begin
        Click;
        Result := True;
    end
    else Result := inherited DialogChar(Message);
end;

function TvqButtonControl.RendererGlyphSize(AArea: TRect): TSize;
begin
    Result := GlyphSize(AArea);
end;

procedure TvqButtonControl.RendererDrawGlyph(AArea, ARect: TRect);
begin
    DrawGlyph(AArea, ARect);
end;

function TvqButtonControl.GlyphSize(AArea: TRect): TSize;
begin
    Result := TSize.Create(0, 0);
end;

function TvqButtonControl.CaptionArea: TRect;
begin
    Result := vqThemeManager.ButtonContentRect(ClientRect);
    Result.Inflate(-BorderWidth, -BorderWidth);
end;

procedure TvqButtonControl.DrawGlyph(AArea, ARect: TRect);
begin
end;

procedure TvqButtonControl.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
var
    Client: TRect;
    Dx, Dy: Integer;
    TxtR: TRect;
    Sz: TSize;
begin
    TxtR := CaptionArea;
    Dx := Width - TxtR.Width;
    Dy := Height - TxtR.Height;
    FCaptionRenderer.Area := TxtR;
    Sz := FCaptionRenderer.TextExtent(Caption, Glyph, FLayout, Spacing, vqTextHorizontal);
    Inc(Sz.cx, Dx);
    Inc(Sz.cy, Dy);
    PreferredWidth := Sz.cx;
    PreferredHeight := Sz.cy;
end;

procedure TvqButtonControl.Paint;
var
    Client: TRect;
    AState: TvqThemeState;
begin
    if not FOwnerDraw then with Canvas do begin
        Client := ClientRect;
        if not Enabled then AState := [vqthDisabled]
        else if FPressed then AState := [vqthPressed]
        else if FMouseOver then AState := [vqthHot]
        else AState := [vqthNormal];
        if Default then Include(AState, vqthDefaulted);
        if Focused then Include(AState, vqthFocused);
        if (Color <> clNone) and (Color <> clDefault) then begin
            FullBrush(Color);
            FillRect(Client);
        end;
        
        if FFlat then 
            if FChecked then
                vqThemeManager.DrawFlatButtonChecked(Self, Canvas, Client, AState)
            else
                vqThemeManager.DrawFlatButton(Self, Canvas, Client, AState)
        else
            if FChecked then
                vqThemeManager.DrawButtonChecked(Self, Canvas, Client, AState)
            else
                vqThemeManager.DrawButton(Self, Canvas, Client, AState);
        
        Glyph.TransparentGlyph := True; //!
        
        FCaptionRenderer.DisabledColor := vqThemeManager.DisabledFore;
        FCaptionRenderer.Area := CaptionArea;
        FCaptionRenderer.Render(Caption, Glyph, FLayout, Enabled, Spacing, vqTextHorizontal);
        
    end;
    inherited Paint;
end;

end.
