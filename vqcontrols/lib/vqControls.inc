// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqControls.inc            }
{ included in vqUtils.pas   }

{ TvqCaret }

constructor TvqCaret.Create(AOwner: TControl);
begin
    FOwner := AOwner;
	FShowing := True;
	FAtFront := True;
	FTimer := TTimer.Create(nil);
	FTimer.Enabled := False;
	FTimer.OnTimer := @OnTimer;
	FTimer.Interval := 500;
	FClientRect := TRect.Empty;
	FColor := clBlack;
end;

destructor TvqCaret.Destroy;
begin
    FTimer.Free;
    inherited;
end;

procedure TvqCaret.Assign(Source: TPersistent);
begin
    if not (Source is TvqCaret) then inherited
    else if Source <> Self then begin
        Color := TvqCaret(Source).Color;
    end;
end;

procedure TvqCaret.Show;
begin
    BringToFront;
    FShowing := True;
end;

procedure TvqCaret.Hide;
begin
    FTimer.Enabled := False;
	CarryToBack;
	FShowing := False;
end;

procedure TvqCaret.Pause;
begin
	FTimer.Enabled := False;
	if FShowing then BringToFront
	else CarryToBack;
end;

procedure TvqCaret.Blink;
begin
    if FShowing then begin
		CarryToBack;
		FTimer.Enabled := True;
    end
    else begin
        BringToFront;
        FShowing := True;
		FTimer.Enabled := True;
    end;
end;

procedure TvqCaret.Invalidate; 
begin
	if FShowing and FAtFront then
		Paint;
end;

procedure TvqCaret.Paint; 
begin
end;

procedure TvqCaret.DrawArrow(Canvas: TCanvas; Position: TvqPosition);
var
    A, B, C, P: TPoint;
    D: Integer;
    R: TRect;
begin
    R := ClientRect;
    with Canvas do begin
        P := R.CenterPoint;
        Pen.Style := psSolid;
        Pen.Mode := pmCopy;
        Pen.Color := ColorToRGB(Color);
        Pen.Width := 1;
        Brush.Style := bsSolid;
        Brush.Color := ColorToRGB(Color);
        case Position of
            vqLeft: begin
                D := Min(R.Width - 1, (R.Height - 1) div 2);
                A := Point(R.Right - 1, P.Y);
                B := Point(A.X - D, A.Y - D);
                C := Point(A.X - D, A.Y + D);
            end;
            vqTop: begin
                D := Min(R.Height - 1, (R.Width - 1) div 2);
                A := Point(P.X, R.Bottom - 1);
                B := Point(A.X - D, A.Y - D);
                C := Point(A.X + D, A.Y - D);
            end;
            vqRight: begin
                D := Min(R.Width - 1, (R.Height - 1) div 2);
                A := Point(R.Left, P.Y);
                B := Point(A.X + D, A.Y - D);
                C := Point(A.X + D, A.Y + D);
            end;
            vqBottom: begin
                D := Min(R.Height - 1, (R.Width - 1) div 2);
                A := Point(P.X, R.Top);
                B := Point(A.X - D, A.Y + D);
                C := Point(A.X + D, A.Y + D);
            end;
        end;
        Polygon([A, B, C]);
    end;
end;

procedure TvqCaret.DrawLine(Canvas: TCanvas; Orientation: TvqOrientation);
var
    R: TRect;
begin
    with Canvas do begin
        R := ClientRect;
        Pen.Mode := pmCopy;
        Pen.Style := psSolid;
        Pen.Width := 1;
        Pen.Color := Color;
        if Orientation = vqHorizontal then begin
            MoveTo(R.Left, R.Top);
            LineTo(R.Left, R.Bottom);
        end     
        else begin
            MoveTo(R.Left, R.Top);
            LineTo(R.Right, R.Top);
        end;
    end;
end;

procedure TvqCaret.DrawDot(Canvas: TCanvas; Orientation: TvqOrientation);
var
    R: TRect;
begin
    with Canvas do begin
        R := ClientRect;
        Pen.Mode := pmCopy;
        Pen.Style := psDot;
        Pen.Width := 1;
        Pen.Color := Color;
        Brush.Style := bsClear;
        if Orientation = vqHorizontal then begin
            MoveTo(R.Left, R.Top);
            LineTo(R.Left, R.Bottom);
        end     
        else begin
            MoveTo(R.Left, R.Top);
            LineTo(R.Right, R.Top);
        end;
    end;
end;

procedure TvqCaret.DrawBlock(Canvas: TCanvas);
var
    R: TRect;
begin
    with Canvas do begin
        R := ClientRect;
        Brush.Style := bsSolid;
        Brush.Color := Color;
        FillRect(R);
    end;
end;

procedure TvqCaret.DrawBlock(Canvas: TCanvas; ACh: string; AFace: TFontName; 
    ASize: Integer; AStyle: TFontStyles; AFore: TColor);
var
    R: TRect;
begin
    with Canvas do begin
        R := ClientRect;
        Brush.Style := bsSolid;
        Brush.Color := Color;
        FillRect(R);    
        Brush.Style := bsClear;
        
        Font.Name := AFace;
        Font.Size := ASize;
        Font.Style := AStyle;
        Font.Color := AFore;

        WidgetSet.ExtUTF8Out(Handle, R.Left, R.Top, ETO_CLIPPED, nil, PChar(ACh), Length(ACh), nil);

    end;
end;

procedure TvqCaret.DrawBox(Canvas: TCanvas);
var
    R: TRect;
begin
    with Canvas do begin
        R := ClientRect;
        Pen.Mode := pmCopy;
        Pen.Style := psSolid;
        Pen.Width := 1;
        Pen.Color := Color;
        Brush.Style := bsClear;
        Rectangle(R);
    end;
end;

procedure TvqCaret.DrawInvert(Canvas: TCanvas);
var
    R: TRect;
begin
    with Canvas do begin
        R := ClientRect;
        CopyMode := cmDstInvert;
        CopyRect(R, Canvas, R);
        CopyMode := cmSrcCopy;
    end;
end;

procedure TvqCaret.DrawSubline(Canvas: TCanvas);
var
    R: TRect;
begin
    with Canvas do begin
        R := ClientRect;
        Brush.Style := bsSolid;
        Brush.Color := Color;
        R.Top := R.Bottom - 2;
        FillRect(R);
    end;
end;

procedure TvqCaret.DrawLine(Canvas: TCanvas);
var
    R: TRect;
begin
    with Canvas do begin
        R := ClientRect;
        Brush.Style := bsSolid;
        Brush.Color := Color;
        R.Right := R.Left + 1;
        FillRect(R);
    end;
end;

procedure TvqCaret.DrawBack; 
begin
    if Assigned(FHideMethod) then FHideMethod(Self);
end;

procedure TvqCaret.OnTimer(Sender: TObject);
begin
	if FAtFront then CarryToBack
	else BringToFront;
end;

function TvqCaret.GetInterval: Integer;
begin
    Result := FTimer.Interval;
end;

function TvqCaret.GetBlinking: Boolean;
begin
    Result := FTimer.Enabled;
end;

procedure TvqCaret.SetBlinking(Value: Boolean);
begin
    if FTimer.Enabled <> Value then begin
        if Value then Blink
        else Hide;
    end;
end;

procedure TvqCaret.SetInterval(Value: Integer);
begin
    FTimer.Interval := Value;
end;

procedure TvqCaret.SetColor(Value: TColor);
begin
    if FColor <> Value then begin
        FColor := Value;
        Invalidate;
    end;    
end;

procedure TvqCaret.SetClientRect(Value: TRect);
var
	PrevTimerEnabled: Boolean;
begin
    if FClientRect <> Value then begin
        PrevTimerEnabled := FTimer.Enabled;
        if FShowing then begin
            FTimer.Enabled := False;
            CarryToBack;
        end;
        FClientRect := Value;
        if FShowing then begin
            BringToFront;
            FTimer.Enabled := PrevTimerEnabled;
        end;
        Change;
    end;
end;

procedure TvqCaret.Change;
begin
end;

procedure TvqCaret.BringToFront;
begin
	Paint;
	FAtFront := True;
end;

procedure TvqCaret.CarryToBack;
begin
	DrawBack;
	FAtFront := False;
end;

{ TvqCustomControl }

constructor TvqCustomControl.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
end;

destructor TvqCustomControl.Destroy;
begin
    inherited;
end;

procedure TvqCustomControl.CMBorderChanged(var Message: TLMessage);
begin
    inherited;
    BorderChanged;
end;

procedure TvqCustomControl.CMChanged(var Message: TLMessage);
begin
    inherited;
    DoChange;
end;

procedure TvqCustomControl.CMColorChanged(var Message: TLMessage);
begin
    inherited;
    ColorChanged;
end;

procedure TvqCustomControl.WMSetFocus(var Message: TLMSetFocus);
begin
    inherited;
    FocusChanged(True);
end;

procedure TvqCustomControl.WMKillFocus(var Message: TLMKillFocus);
begin
    inherited;
    if Message.FocusedWnd <> Handle then
        FocusChanged(False);
end;

procedure TvqCustomControl.CMFontChanged(var Message: TLMessage);
begin
    inherited;
    FontChanged;
end;

procedure TvqCustomControl.CMControlListChange(var Message: TLMessage);
begin
    inherited;
    ControlListChanged;
end;

procedure TvqCustomControl.WMCancelMode(var Message: TLMessage);
begin
    inherited;
    CancelMode;
end;

procedure TvqCustomControl.WMEraseBkgnd(var Message: TLMEraseBkgnd);
begin
    Message.Result := 1;
end;

function TvqCustomControl.IsInternalControl(AControl: TControl): Boolean;
begin
    Result := False;
end;

procedure TvqCustomControl.DoOnShowHint(HintInfo: PHintInfo);
begin
    inherited DoOnShowHint(HintInfo);
end;

procedure TvqCustomControl.DoChange;
begin
    if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TvqCustomControl.ColorChanged;
begin
end;

procedure TvqCustomControl.FocusChanged(AFocused: Boolean);
begin
end;

procedure TvqCustomControl.FontChanged;
begin
end;

procedure TvqCustomControl.BorderChanged;
begin
end;

procedure TvqCustomControl.ControlListChanged;
begin
end;

procedure TvqCustomControl.CancelMode;
begin
end;

procedure TvqCustomControl.OldCalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
begin
    inherited CalculatePreferredSize(PreferredWidth, PreferredHeight, WithThemeSpace);
end;

procedure TvqCustomControl.OldPaint;
begin
    inherited Paint;
end;

procedure TvqCustomControl.OldKeyDown(var Key: Word; Shift: TShiftState);
begin
    inherited KeyDown(Key, Shift);
end;

procedure TvqCustomControl.OldKeyUp(var Key: Word; Shift: TShiftState);
begin
    inherited KeyUp(Key, Shift);
end;

procedure TvqCustomControl.OldMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseDown(Button, Shift, X, Y);
end;

procedure TvqCustomControl.OldMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseUp(Button, Shift, X, Y);
end;

procedure TvqCustomControl.OldMouseMove(Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseMove(Shift, X, Y);
end;

procedure TvqCustomControl.OldMouseEnter;
begin
    inherited MouseEnter;
end;

procedure TvqCustomControl.OldMouseLeave;
begin
    inherited MouseLeave;
end;

procedure TvqCustomControl.OldClick;
begin
    inherited Click;
end;

procedure TvqCustomControl.SetShape(AShape: TvqRegion);
begin
    WidgetSet.SetWindowRgn(Handle, AShape.Handle, False);
end;

procedure TvqCustomControl.UpdateMetrics;
begin
    Invalidate;
end;

procedure TvqCustomControl.SetSpacing(Value: Integer);
begin
    if FSpacing <> Value then begin
        FSpacing := Value;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

{ TvqGraphicControl }

constructor TvqGraphicControl.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    ControlStyle := ControlStyle - [csOpaque]; 
end;

destructor TvqGraphicControl.Destroy;
begin
    inherited;
end;

procedure TvqGraphicControl.CMChanged(var Message: TLMessage);
begin
    inherited;
    DoChange;
end;

procedure TvqGraphicControl.CMColorChanged(var Message: TLMessage);
begin
    inherited;
    ColorChanged;
end;

procedure TvqGraphicControl.CMFontChanged(var Message: TLMessage);
begin
    inherited;
    FontChanged;
end;

procedure TvqGraphicControl.DoOnShowHint(HintInfo: PHintInfo);
begin
    inherited DoOnShowHint(HintInfo);
end;

procedure TvqGraphicControl.ColorChanged;
begin
end;

procedure TvqGraphicControl.FontChanged;
begin
end;

procedure TvqGraphicControl.DoChange;
begin
    if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TvqGraphicControl.UpdateMetrics;
begin
    Invalidate;
end;

procedure TvqGraphicControl.SetSpacing(Value: Integer);
begin
    if FSpacing <> Value then begin
        FSpacing := Value;
        UpdateMetrics;
    end;
end;

{ TvqPopupForm }

constructor TvqPopupForm.CreateNew(AOwner: TComponent; Num: Integer = 0);
begin
    inherited CreateNew(AOwner, Num);
    BorderStyle := bsNone;
    FClosed := False;
    OnDeactivate := @FormDeactivate;
    OnClose := @FormClose;
    Application.AddOnDeactivateHandler(@FormDeactivate); 
    PopupMode := pmAuto;                                  
    FBeveled := True;
    FFreeOnClose := True;  
end;

destructor TvqPopupForm.Destroy;
begin
    inherited;
end;

procedure TvqPopupForm.CMChanged(var Message: TLMessage);
begin
    inherited;
    DoChange;
end;

procedure TvqPopupForm.CMColorChanged(var Message: TLMessage);
begin
    inherited;
    ColorChanged;
end;

procedure TvqPopupForm.CMFontChanged(var Message: TLMessage);
begin
    inherited;
    FontChanged;
end;

procedure TvqPopupForm.DoChange;
begin
    if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TvqPopupForm.ColorChanged;
begin
end;

procedure TvqPopupForm.FontChanged;
begin
end;

procedure TvqPopupForm.FormDeactivate(Sender: TObject);
begin
    Hide;
    if not FClosed then Close;
end;

procedure TvqPopupForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    FClosed := True;
    Application.RemoveOnDeactivateHandler(@FormDeactivate);
    if FFreeOnClose then CloseAction := caFree;
    DoCloseUp;
end;

procedure TvqPopupForm.DoShow;
begin
    inherited;
    DoPopup;
end;

procedure TvqPopupForm.Initialize;
begin
    // Return event
    // Show Hide events
    // FreeOnClose
    // Width, Height
    // Controls
    // Values
    // and Others
end;

procedure TvqPopupForm.Return;
begin
    if Assigned(FOnReturn) then FOnReturn(Self);
    if not FClosed then Close;
end;

procedure TvqPopupForm.DropDown(ACaller: TControl; AAlignment: TAlignment; ALayout: TTextLayout; AOrientation: TvqOrientation = vqHorizontal);
var
    P: TPoint;
    WorkArea: TRect;
begin
    FCaller := ACaller;
    if FCaller = nil then Exit;
    Initialize;
    
    Show;
    
    P := Point(FCaller.Width, FCaller.Height);
    if AOrientation = vqHorizontal then
        case AAlignment of
            taLeftJustify: P.X := 0;
            taCenter: P.X := (FCaller.Width - Width) div 2;
            taRightJustify: P.X := FCaller.Width - Width;
        end
    else
        case ALayout of
            tlTop: P.Y := 0;
            tlCenter: P.Y := (FCaller.Height - Height) div 2;
            tlBottom: P.Y := FCaller.Height - Height;
        end;
    
    P := FCaller.ControlToScreen(P);
    WorkArea := Screen.MonitorFromPoint(P).WorkAreaRect;
    if P.Y + Height > WorkArea.Bottom then
        if AOrientation = vqHorizontal then
            Dec(P.Y, FCaller.Height + Height)
        else
            P.Y := WorkArea.Bottom - Height;
    if P.Y < WorkArea.Top then
        P.Y := WorkArea.Top;
    if P.X + Width > WorkArea.Right then
        if AOrientation = vqHorizontal then
            P.X := WorkArea.Right - Width
        else
            Dec(P.X, FCaller.Width + Width);
    if P.X < WorkArea.Left then
        P.X := WorkArea.Left;
    
    Self.Left := P.X;
    Self.Top := P.Y;
end;

procedure TvqPopupForm.DropDown(ACaller: TControl; X, Y: Integer);
var
    P: TPoint;
    WorkArea: TRect;
begin
    FCaller := ACaller;
    if FCaller = nil then Exit;
    Initialize;
    
    Show;
    
    P := Point(X, Y);
    P := FCaller.ControlToScreen(P);
    WorkArea := Screen.MonitorFromPoint(P).WorkAreaRect;
    if P.Y + Height > WorkArea.Bottom then
        P.Y := WorkArea.Bottom - Height;
    if P.Y < WorkArea.Top then P.Y := WorkArea.Top;
    if P.X + Width > WorkArea.Right then
        P.X := WorkArea.Right - Width;
    if P.X < WorkArea.Left then P.X := WorkArea.Left;
    
    Self.Left := P.X;
    Self.Top := P.Y;
end;

procedure TvqPopupForm.PopUp(X, Y: Integer; AAlignment: TAlignment = taLeftJustify; ALayout: TTextLayout = tlTop);
var
    P: TPoint;
    WorkArea: TRect;
begin
    Show;
    
    case AAlignment of
        taLeftJustify: X := X;
        taCenter: X := X - (Width div 2);
        taRightJustify: X := X - Width;
    end;
    
    case ALayout of
        tlTop: Y := Y;
        tlCenter: Y := Y - (Height div 2);
        tlBottom: Y := Y - Height;
    end;
    
    P := Point(X, Y);
    WorkArea := Screen.MonitorFromPoint(P).WorkAreaRect;
    if P.Y + Self.Height > WorkArea.Bottom then
        P.Y := WorkArea.Bottom - Height;
    if P.Y < WorkArea.Top then P.Y := WorkArea.Top;
    if P.X + Self.Width > WorkArea.Right then
        P.X := WorkArea.Right - Width;
    if P.X < WorkArea.Left then P.X := WorkArea.Left;
    
    Self.Left := P.X;
    Self.Top := P.Y;
end;

procedure TvqPopupForm.AdjustClientRect(var Rect: TRect);
begin
    inherited AdjustClientRect(Rect);
    if FBeveled then Rect.Inflate(-1, -1);
end;

function TvqPopupForm.GetBevelColor: TColor;
begin
    Result := clLead;
end;

procedure TvqPopupForm.SetBeveled(Value: Boolean);
begin
    if FBeveled <> Value then begin
        FBeveled := Value;
        Perform(CM_BORDERCHANGED, 0, 0);
        Invalidate;
    end;
end;

procedure TvqPopupForm.RepaintBevel;
var
    R: TRect;
begin
    if FBeveled then
        with Canvas do begin
            ThinPen(GetBevelColor);
            Brush.Style := bsClear;
            R := ClientRect;
            Rectangle(R);
        end;
end;

procedure TvqPopupForm.Paint;
begin
    RepaintBevel;
    inherited;
end;

procedure TvqPopupForm.WMActivate(var Message: TLMActivate);
var
    ParentHandle: HWND;
begin
    inherited;
    ParentHandle := GetParent(Handle);
    if ParentHandle <> 0 then
        SendMessage(ParentHandle, LM_NCACTIVATE, Ord(Message.Active <> WA_INACTIVE), 0);
end;

procedure TvqPopupForm.DoPopup;
begin
    if Assigned(FOnPopup) then FOnPopup(Self);
end;

procedure TvqPopupForm.DoCloseUp;
begin
    if Assigned(FOnCloseUp) then FOnCloseUp(Self);
end;

{ TvqPopupMenuHelper }

procedure TvqPopupMenuHelper.DropDown(ACaller: TControl; AAlignment: TAlignment; ALayout: TTextLayout; AOrientation: TvqOrientation = vqHorizontal);
var
    P: TPoint;
begin
    if ACaller = nil then Exit;
    
    P := Point(ACaller.Width, ACaller.Height);
    if AOrientation = vqHorizontal then begin
        case AAlignment of
            taLeftJustify: P.X := 0;
            taCenter: P.X := ACaller.Width div 2;
            taRightJustify: P.X := ACaller.Width;
        end;
        Alignment := TPopupAlignment(Ord(AAlignment));
    end
    else begin
        case ALayout of
            tlTop: P.Y := 0;
            tlCenter: P.Y := 0;
            tlBottom: P.Y := 0;
        end;
        Alignment := paLeft;
    end;
    
    P := ACaller.ControlToScreen(P);
    
    Popup(P.X, P.Y);
end;

procedure TvqPopupMenuHelper.DropDown(ACaller: TControl; X, Y: Integer);
var
    P: TPoint;
begin
    if ACaller = nil then Exit;
    
    P := Point(X, Y);
    P := ACaller.ControlToScreen(P);
    
    Popup(X, Y);
end;

{ TvqCustomDialog }

procedure TvqCustomDialog.InitializeDialog;
begin
end;

function TvqCustomDialog.DialogFormClass: TCustomFormClass;
begin
    Result := TCustomForm;
end;

procedure TvqCustomDialog.OnMessageFormShow(Sender: TObject);
begin
    DoShow;
end;

procedure TvqCustomDialog.OnMessageFormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    DoClose;
end;

procedure TvqCustomDialog.OnMessageFormCloseQuery(Sender: TObject; var CanClose: Boolean); 
begin
    UserChoice := DlgForm.ModalResult;
    DoCanClose(CanClose);
end;

function TvqCustomDialog.Execute: Boolean;
var
    SaveDlgForm: TCustomForm;
    
    procedure SaveTopLeft;
    begin
        SaveDlgForm := DlgForm;
        DlgForm := nil;
        Left := SaveDlgForm.Left;
        Top := SaveDlgForm.Top;
        DlgForm := SaveDlgForm;
    end;
    
begin
    DlgForm := DialogFormClass.Create(Application);
    try
        ResetShowCloseFlags;
        
        DlgForm.Caption := Self.Caption;
        if csDesigning in ComponentState then
            DlgForm.Position := poScreenCenter
        else
            DlgForm.Position := DialogPosition;
        if DlgForm.Position = poDesigned then begin
            DlgForm.Left := Left;
            DlgForm.Top := Top;
        end 
        else
            SaveTopLeft;
        
        DlgForm.BorderStyle := bsDialog;
        DlgForm.AutoScroll := False;
        
        DlgForm.OnShow := @OnMessageFormShow;
        DlgForm.OnClose := @OnMessageFormClose;
        DlgForm.OnCloseQuery := @OnMessageFormCloseQuery;
        
        InitializeDialog;
        
        Result := DlgForm.ShowModal = mrOK;
        
        SaveTopLeft;
        
        SetHeight(DlgForm.Height);
        SetWidth(DlgForm.Width);
        
    finally
        DlgForm.Free;
        DlgForm := nil;
    end;
end;
