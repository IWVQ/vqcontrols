// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqNotifier;

interface
            
uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Types, Classes, SysUtils, Graphics, Forms, Controls, StdCtrls, Buttons,
    ImgList, ActnList, Dialogs, ExtCtrls, Math,
    vqUtils, vqThemes, vqQuickButton, vqButtons, vqMarkLabel;

type

    TvqNotifierKind = (vqnkCustom, vqnkWarning, vqnkError, vqnkInformation,
        vqnkShield, vqnkQuestion);

    TvqNotifier = class;

    TvqNotifierButton = class(TCollectionItem)
    private
        FControl: TvqButton;
        function GetCaption: TCaption;
        function GetImageIndex: TImageIndex;
        function GetDefault: Boolean;
        function GetAction: TBasicAction;
        function GetOnClick: TNotifyEvent;
        procedure SetCaption(Value: TCaption);
        procedure SetImageIndex(Value: TImageIndex);
        procedure SetDefault(Value: Boolean);
        procedure SetAction(Value: TBasicAction);
        procedure SetOnClick(Value: TNotifyEvent);
    protected
        function Notifier: TvqNotifier;
    public
        constructor Create(ACollection: TCollection); override;
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        
        property Control: TvqButton read FControl;
    published
        property Caption: TCaption read GetCaption write SetCaption;
        property ImageIndex: TImageIndex read GetImageIndex write SetImageIndex default -1;
        property Default: Boolean read GetDefault write SetDefault default False;
        property Action: TBasicAction read GetAction write SetAction;
        property OnClick: TNotifyEvent read GetOnClick write SetOnClick;
    end;
    
    TvqNotifierButtons = class(TCollection)
    private
        FOwner: TPersistent;
    protected
        procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
        procedure SetItem(Index: Integer; Value: TvqNotifierButton);
        function GetItem(Index: Integer): TvqNotifierButton;
        procedure Update(Item: TCollectionItem); override;
        function GetOwner: TPersistent; override;
        procedure SetOwner(Value: TPersistent); virtual;
    public
        constructor Create(AOwner: TPersistent); virtual;
        procedure Assign(Source: TPersistent); override;
        property Items[Index: Integer]: TvqNotifierButton read GetItem write SetItem; default;
    end;
    
    { TvqNotifier }

    TvqNotifier = class(TvqCustomControl)
    private
        FLabel: TvqMarkLabel;
        FIcon: TImage;
        FCloseButton: TvqCustomQuickButton;
        
        FImageChangeLink: TChangeLink;
        FImageList: TImageList;
        FKind: TvqNotifierKind;
        FPicture: TPicture;
        FShowing: Boolean;
        
        FSingleLineCentered: Boolean;
        FFixedCloseBtn: Boolean;
        
        FButtons: TvqNotifierButtons;
        
        FKindColors: array[TvqNotifierKind] of TColor;
        FKindImages: array[TvqNotifierKind] of Integer;
                             
        FOnCloseBtnClick: TNotifyEvent;
        FOnShow: TNotifyEvent;
        FOnHide: TNotifyEvent;

        function GetEnableCloseBtn: Boolean;
        function GetKindColor(AKind: TvqNotifierKind): TColor;
        function GetKindImage(AKind: TvqNotifierKind): Integer;
        function GetText: string;
        function GetWordWrap: Boolean;
        procedure SetKindColor(AKind: TvqNotifierKind; Value: TColor);
        procedure SetKindImage(AKind: TvqNotifierKind; Value: Integer);
        procedure SetImageList(Value: TImageList);
        procedure SetKind(Value: TvqNotifierKind);
        procedure SetOnCloseBtnClick(AValue: TNotifyEvent);
        procedure SetSingleLineCentered(Value: Boolean);
        procedure SetFixedCloseBtn(Value: Boolean);
        procedure SetEnableCloseBtn(Value: Boolean);
        procedure SetText(Value: string);
        procedure SetPicture(Value: TPicture);
        procedure SetWordWrap(Value: Boolean);
        procedure SetButtons(Value: TvqNotifierButtons);

        procedure OnImagesChange(Sender: TObject);
        procedure OnPictureChange(Sender: TObject);
        procedure OnTextChange(Sender: TObject);
        procedure UpdateIcon;
        procedure UpdateLayout;

    protected
        class function GetControlClassDefaultSize: TSize; override;
        
        function IsInternalControl(AControl: TControl): Boolean; override;
        
        procedure DoShow; virtual;
        procedure DoHide; virtual;
        
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        procedure AdjustClientRect(var ARect: TRect); override;
        procedure UpdateMetrics; override;
        procedure TextChanged; override;
        procedure ColorChanged; override;
        procedure BorderChanged; override;
        procedure Resize; override;
        procedure Paint; override;
        
        property CloseButton: TvqCustomQuickButton read FCloseButton;
        property _Label: TvqMarkLabel read FLabel;
        property Icon: TImage read FIcon;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Show;
        procedure Hide;
        procedure ShowMessage(AKind: TvqNotifierKind; AMsg: string); overload;
        procedure ShowMessage(AMsg: string); overload;
        property Showing: Boolean read FShowing;
        property Caption;
        property KindColor[AKind: TvqNotifierKind]: TColor read GetKindColor write SetKindColor;
        property KindImage[AKind: TvqNotifierKind]: Integer read GetKindImage write SetKindImage;
    published
        property ImageList: TImageList read FImageList write SetImageList;
        property Kind: TvqNotifierKind read FKind write SetKind;
        property SingleLineCentered: Boolean read FSingleLineCentered write SetSingleLineCentered;
        property FixedCloseBtn: Boolean read FFixedCloseBtn write SetFixedCloseBtn;
        property BorderWidth;
        property EnableCloseBtn: Boolean read GetEnableCloseBtn write SetEnableCloseBtn;
        property Text: string read GetText write SetText;
        property Picture: TPicture read FPicture write SetPicture;
        property WordWrap: Boolean read GetWordWrap write SetWordWrap;
        property Buttons: TvqNotifierButtons read FButtons write SetButtons;

        property OnCloseBtnClick: TNotifyEvent read FOnCloseBtnClick write SetOnCloseBtnClick;
        property OnShow: TNotifyEvent read FOnShow write FOnShow;
        property OnHide: TNotifyEvent read FOnHide write FOnHide;
    end;
    
implementation

type
    
    TvqNotifierButtonControl = class(TvqButton)
    end;

{ TvqNotifierButton }

constructor TvqNotifierButton.Create(ACollection: TCollection); 
begin
    inherited Create(ACollection);
    FControl := TvqNotifierButtonControl.Create(Notifier);
    FControl.Parent := Notifier;
    FControl.Visible := False;
end;

destructor TvqNotifierButton.Destroy;                           
begin
    FControl.Free;
    inherited;
end;

procedure TvqNotifierButton.Assign(Source: TPersistent);
begin
    if (Source is TvqNotifierButton) and (Source <> Self) then begin
        Caption := TvqNotifierButton(Source).Caption; 
        ImageIndex := TvqNotifierButton(Source).ImageIndex; 
        Changed(True);
    end
    else inherited;
end;

function TvqNotifierButton.Notifier: TvqNotifier;               
begin
    Result := TvqNotifier(TvqNotifierButtons(Collection).FOwner);
end;

function TvqNotifierButton.GetCaption: TCaption;                
begin
    Result := Control.Caption;
end;

function TvqNotifierButton.GetImageIndex: TImageIndex;          
begin
    Result := Control.Glyph.ImageIndex;
end;

function TvqNotifierButton.GetDefault: Boolean;                 
begin
    Result := Control.Default;
end;

function TvqNotifierButton.GetAction: TBasicAction;             
begin
    Result := Control.Action;
end;

function TvqNotifierButton.GetOnClick: TNotifyEvent;            
begin
    Result := Control.OnClick;
end;

procedure TvqNotifierButton.SetCaption(Value: TCaption);        
begin
    Control.Caption := Value;
end;

procedure TvqNotifierButton.SetImageIndex(Value: TImageIndex);  
begin
    Control.Glyph.ImageIndex := Value;
end;

procedure TvqNotifierButton.SetDefault(Value: Boolean);         
begin
    Control.Default := Value;
end;

procedure TvqNotifierButton.SetAction(Value: TBasicAction);     
begin
    Control.Action := Value;
end;

procedure TvqNotifierButton.SetOnClick(Value: TNotifyEvent);
begin
    Control.OnClick := Value;
end;

{ TvqNotifierButtons }

constructor TvqNotifierButtons.Create(AOwner: TPersistent); 
begin
    inherited Create(TvqNotifierButton);
    FOwner := AOwner;
end;

procedure TvqNotifierButtons.Assign(Source: TPersistent);
begin
    inherited;
end;

procedure TvqNotifierButtons.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
    Update(Item);
end;

procedure TvqNotifierButtons.SetItem(Index: Integer; Value: TvqNotifierButton);
begin
    inherited SetItem(Index, Value);
end;

function TvqNotifierButtons.GetItem(Index: Integer): TvqNotifierButton;
begin
    Result := TvqNotifierButton(inherited GetItem(Index));
end;    

function TvqNotifierButtons.GetOwner: TPersistent; 
begin
    Result := FOwner;
end;

procedure TvqNotifierButtons.SetOwner(Value: TPersistent); 
begin
    FOwner := Value;
end;

procedure TvqNotifierButtons.Update(Item: TCollectionItem);
begin
    //TvqNotifier(Owner).UpdateLayout;
end;

{ TvqNotifier }

constructor TvqNotifier.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FLabel := TvqMarkLabel.Create(Self);
    FLabel.Parent := Self;
    FIcon := TImage.Create(Self);
    FIcon.Parent := Self;
    FCloseButton := TvqCustomQuickButton.Create(Self);
    FCloseButton.Parent := Self;
    
    FImageList := nil;
    FImageChangeLink := TChangeLink.Create;
    FImageChangeLink.OnChange := @OnImagesChange;
    
    FButtons := TvqNotifierButtons.Create(Self);
    
    FPicture := TPicture.Create;
    
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
    
    FLabel.AutoSize := True;
    FLabel.Align := alClient;
    
    FIcon.AutoSize := True;
    FIcon.Align := alLeft;
    
    FCloseButton.Align := alCustom;
    FCloseButton.Kind := vqqbkClose;
    
    FKind := vqnkCustom;
    FShowing := False;
    FSingleLineCentered := False;
    FFixedCloseBtn := False;
    
    FKindColors[vqnkCustom     ] := clInfobk;
    FKindColors[vqnkWarning    ] := clInfobk;
    FKindColors[vqnkError      ] := clRed;
    FKindColors[vqnkInformation] := clHighlight;
    FKindColors[vqnkShield     ] := clInfobk;
    FKindColors[vqnkQuestion   ] := clInfobk;
        
    FKindImages[vqnkCustom     ] := -1;
    FKindImages[vqnkWarning    ] := -1;
    FKindImages[vqnkError      ] := -1;
    FKindImages[vqnkInformation] := -1;
    FKindImages[vqnkShield     ] := -1;
    FKindImages[vqnkQuestion   ] := -1;
    
end;

destructor TvqNotifier.Destroy;
begin
    FLabel.Free;
    FIcon.Free;
    FCloseButton.Free;
    
    FButtons.Free;
    FImageChangeLink.Free;
    FPicture.Free;
    inherited;
end;

procedure TvqNotifier.Show;
begin
    if FShowing then Exit;
    Visible := True;
    FShowing := True;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqNotifier.Hide;
begin
    if not FShowing then Exit;
    Visible := False;
    FShowing := False;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqNotifier.ShowMessage(AKind: TvqNotifierKind; AMsg: string);
begin
    Kind := AKind;
    Text := AMsg;
    Show;
end;

procedure TvqNotifier.ShowMessage(AMsg: string);
begin
    ShowMessage(vqnkCustom, AMsg);
end;

class function TvqNotifier.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 120;
    Result.cy := 100;
end;

procedure TvqNotifier.DoShow;
begin
    if Assigned(FOnShow) then FOnShow(Self);
end;

procedure TvqNotifier.DoHide;
begin
    if Assigned(FOnHide) then FOnHide(Self);
end;

function TvqNotifier.GetKindColor(AKind: TvqNotifierKind): TColor;
begin
    Result := FKindColors[AKind];
end;

function TvqNotifier.GetKindImage(AKind: TvqNotifierKind): Integer;
begin
    Result := FKindImages[AKind];
end;

function TvqNotifier.GetText: string;
begin
    Result := FLabel.Caption;
end;

function TvqNotifier.GetWordWrap: Boolean;
begin
    Result := FLabel.TextFormat.WordBreak;
end;

function TvqNotifier.GetEnableCloseBtn: Boolean;
begin
    Result := FCloseButton.Visible;
end;

procedure TvqNotifier.SetKindColor(AKind: TvqNotifierKind; Value: TColor);
begin
    if FKindColors[AKind] <> Value then begin
        FKindColors[AKind] := Value;
        if FKind = AKind then 
            Repaint;
    end;
end;

procedure TvqNotifier.SetKindImage(AKind: TvqNotifierKind; Value: Integer);
begin
    if FKindImages[AKind] <> Value then begin
        FKindImages[AKind] := Value;
        if FKind = AKind then begin
            UpdateIcon;
            InvalidatePreferredSize;
            AdjustSize;
        end;
    end;
end;

procedure TvqNotifier.SetImageList(Value: TImageList);
begin
    if FImageList <> Value then begin
        if FImageList <> nil then begin
            FImageList.UnRegisterChanges(FImageChangeLink);
            FImageList.RemoveFreeNotification(Self);
        end;
        FImageList := Value;
        if FImageList <> nil then begin
            FImageList.FreeNotification(Self);
            FImageList.RegisterChanges(FImageChangeLink);
        end;
        UpdateIcon;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqNotifier.SetKind(Value: TvqNotifierKind);        
begin
    if FKind <> Value then begin
        FKind := Value;
        Invalidate;
        UpdateIcon;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqNotifier.SetOnCloseBtnClick(AValue: TNotifyEvent);
begin
    FOnCloseBtnClick := AValue;
    if FCloseButton <> nil then
        FCloseButton.OnClick := AValue;
end;

procedure TvqNotifier.SetSingleLineCentered(Value: Boolean);  
begin
    if FSingleLineCentered <> Value then begin
        FSingleLineCentered := Value;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqNotifier.SetFixedCloseBtn(Value: Boolean);       
begin
    if FFixedCloseBtn <> Value then begin
        FFixedCloseBtn := Value;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqNotifier.SetEnableCloseBtn(Value: Boolean);      
begin
    if EnableCloseBtn <> Value then begin
        FCloseButton.Visible := Value;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqNotifier.SetText(Value: string);                 
begin
    FLabel.Caption := Value;
end;

procedure TvqNotifier.SetPicture(Value: TPicture);               
begin
    FPicture.Assign(Value);
end;

procedure TvqNotifier.SetWordWrap(Value: Boolean);            
begin
    if WordWrap <> Value then begin
        FLabel.TextFormat.WordBreak := Value;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqNotifier.SetButtons(Value: TvqNotifierButtons);
begin
    FButtons.Assign(Value);
end;

procedure TvqNotifier.OnImagesChange(Sender: TObject);
begin
    if Sender = FImageList then begin
        UpdateIcon;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqNotifier.OnPictureChange(Sender: TObject);
begin
    UpdateIcon;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqNotifier.OnTextChange(Sender: TObject);
begin
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqNotifier.UpdateIcon;
begin
    FIcon.Picture.Clear;
    if FPicture.Graphic <> nil then
        FIcon.Picture := FPicture
    else if (FImageList <> nil) and (FKindImages[FKind] >= 0) and (FKindImages[FKind] < FImageList.Count) then
        FImageList.GetBitmap(FKindImages[FKind], FIcon.Picture.Bitmap);
end;

procedure TvqNotifier.UpdateLayout;
var
    Client, Content, Footer: TRect;
    TxtSz: TSize;
    WrapWidth, 
    ButtonsHeight, ButtonsWidth, I, LabelRightSpacing: Integer;
begin
    // --
    Client := ClientRect;
    Content := vqThemeManager.NotifierContentRect(Client);
    
    ButtonsHeight := 0;
    ButtonsWidth := 0;
    for I := 0 to FButtons.Count - 1 do begin
        Inc(ButtonsWidth, FButtons[I].Control.Width);
        ButtonsHeight := Max(ButtonsHeight, FButtons[I].Control.Height);
    end;
    if FButtons.Count > 0 then
        Inc(ButtonsWidth, (FButtons.Count- 1)*Spacing);
    
    if WidthIsAnchored and WordWrap then
        WrapWidth := Client.Width
    else WrapWidth := 10000;
    WrapWidth := Constraints.MinMaxWidth(WrapWidth);
    
    Dec(WrapWidth, Client.Width - Content.Width);
    
    Dec(WrapWidth, 2*BorderWidth);
    
    if FIcon.Picture.Graphic <> nil then
        Dec(WrapWidth, FIcon.Picture.Width + Spacing);
    if EnableCloseBtn then
        Dec(WrapWidth, FCloseButton.Width + Spacing);
    if FButtons.Count > 0 then
        Dec(WrapWidth, ButtonsWidth + Spacing);
    
    TxtSz := FLabel.TextExtentFor(WrapWidth);
    
    // --
    
    Content.Inflate(-BorderWidth, -BorderWidth);
    
    if (TxtSz.cx < WrapWidth) and (FLabel.LinesCount <= 1) then begin
        // single line
        FIcon.BorderSpacing.Bottom := 0;
        if FIcon.Picture.Graphic <> nil then
            FLabel.BorderSpacing.Left := Spacing;
        FLabel.BorderSpacing.Bottom := 0;
        LabelRightSpacing := 0;
        
        if FSingleLineCentered then
            FLabel.TextFormat.Layout := tlCenter
        else
            FLabel.TextFormat.Layout := tlTop;
        if FSingleLineCentered then
            FIcon.Center := True
        else
            FIcon.Center := False;
        
        if EnableCloseBtn then begin
            Inc(LabelRightSpacing, FCloseButton.Width + Spacing);
            
            FCloseButton.Left := Content.Right - FCloseButton.Width;
            if FSingleLineCentered then
                FCloseButton.Top := (Content.Top + Content.Bottom - FCloseButton.Height) div 2
            else
                FCloseButton.Top := Content.Top;
            
            Dec(Content.Right, FCloseButton.Width + Spacing);
        end;
        
        if FButtons.Count > 0 then begin
            Inc(LabelRightSpacing, ButtonsWidth + Spacing);
            
            for I := 0 to FButtons.Count - 1 do
                with FButtons[I].Control do begin
                    Visible := True;
                    Left := Content.Right - Width;
                    if FSingleLineCentered then
                        Top := (Content.Top + Content.Bottom - Height) div 2
                    else
                        Top := Content.Top;
                    Dec(Content.Right, Width + Spacing);
                end;
        end;
        FLabel.BorderSpacing.Right := LabelRightSpacing;
        
    end
    else begin
        // multiline
        
        Footer := Content;
        
        if EnableCloseBtn and not FixedCloseBtn then begin
            Footer.Top := Footer.Bottom - Max(ButtonsHeight, FCloseButton.Height);
            Dec(Footer.Top, Spacing);
        end
        else if FButtons.Count > 0 then begin
            Footer.Top := Footer.Bottom - ButtonsHeight;
            Dec(Footer.Top, Spacing);
        end
        else 
            Footer.Top := Footer.Bottom;
        
        FIcon.BorderSpacing.Bottom := Footer.Height;
        if FIcon.Picture.Graphic <> nil then
            FLabel.BorderSpacing.Left := Spacing;
        FLabel.BorderSpacing.Bottom := Footer.Height;
        FLabel.TextFormat.Layout := tlTop;
        FIcon.Center := False;
        
        if EnableCloseBtn then begin
            if FixedCloseBtn then begin
                FLabel.BorderSpacing.Right := FCloseButton.Width + Spacing;
                FCloseButton.Left := Content.Right - FCloseButton.Width;
                FCloseButton.Top := Content.Top;
                Dec(Content.Right, FCloseButton.Width + Spacing);
            end
            else begin
                FLabel.BorderSpacing.Right := 0;
                FCloseButton.Left := Footer.Right - FCloseButton.Width;
                FCloseButton.Top := Footer.Top + Spacing;
                Dec(Content.Right, FCloseButton.Width + Spacing);
            end;
        end;
        
        Footer.Right := Content.Right;
        if FButtons.Count > 0 then begin
            for I := 0 to FButtons.Count - 1 do
                with FButtons[I].Control do begin
                    Visible := True;
                    Left := Footer.Right - Width;
                    Top := Footer.Top;
                    Dec(Footer.Right, Width + Spacing);
                end;
        end;
    end;
    
end;

procedure TvqNotifier.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
var
    Client, Content: TRect;
    TxtSz: TSize;
    WrapWidth, 
    ButtonsHeight, ButtonsWidth, I: Integer;
begin
    // inherited CalculatePreferredSize(PreferredWidth, PreferredHeight, WithThemeSpace);
    // Exit;

    // --
    Client := ClientRect;
    Content := vqThemeManager.NotifierContentRect(Client);
    
    ButtonsHeight := 0;
    ButtonsWidth := 0;
    for I := 0 to FButtons.Count - 1 do begin
        Inc(ButtonsWidth, FButtons[I].Control.Width);
        ButtonsHeight := Max(ButtonsHeight, FButtons[I].Control.Height);
    end;
    if FButtons.Count > 0 then
        Inc(ButtonsWidth, (FButtons.Count- 1)*Spacing);
    
    if WidthIsAnchored and WordWrap then
        WrapWidth := Client.Width
    else WrapWidth := 10000;
    WrapWidth := Constraints.MinMaxWidth(WrapWidth);
    
    Dec(WrapWidth, Client.Width - Content.Width);
    
    Dec(WrapWidth, 2*BorderWidth);
    
    if FIcon.Picture.Graphic <> nil then
        Dec(WrapWidth, FIcon.Picture.Width + Spacing);
    if EnableCloseBtn then
        Dec(WrapWidth, FCloseButton.Width + Spacing);
    if FButtons.Count > 0 then
        Dec(WrapWidth, ButtonsWidth + Spacing);
    
    TxtSz := FLabel.TextExtentFor(WrapWidth);
    
    // --
    
    PreferredWidth := TxtSz.cx;
    PreferredHeight := TxtSz.cy;
    if (TxtSz.cx < WrapWidth) and (FLabel.LinesCount <= 1) then begin
        // single line
        if FButtons.Count > 0 then begin
            Inc(PreferredWidth, ButtonsWidth + Spacing);
            PreferredHeight := Max(PreferredHeight, ButtonsHeight);
        end;
        if EnableCloseBtn then begin
            Inc(PreferredWidth, FCloseButton.Width + Spacing);
            PreferredHeight := Max(PreferredHeight, FCloseButton.Height);
        end;
        if FIcon.Picture.Graphic <> nil then begin
            Inc(PreferredWidth, FIcon.Picture.Width + Spacing);
            PreferredHeight := Max(PreferredHeight, FIcon.Picture.Height);
        end;
    end
    else begin
        // multiline
        if FIcon.Picture.Graphic <> nil then begin
            Inc(PreferredWidth, FIcon.Picture.Width + Spacing);
            PreferredHeight := Max(PreferredHeight, FIcon.Picture.Height);
        end;
        if EnableCloseBtn then begin
            if FixedCloseBtn then begin
                Inc(PreferredWidth, FCloseButton.Width + Spacing);
                PreferredHeight := Max(PreferredHeight, FCloseButton.Height);
            end
            else begin
                Inc(ButtonsWidth, FCloseButton.Width + Spacing);
                ButtonsHeight := Max(ButtonsHeight, FCloseButton.Height);
            end;
        end;
        if FButtons.Count > 0 then
            Inc(PreferredHeight, Spacing);
        
        Inc(PreferredHeight, ButtonsHeight);
        PreferredWidth := Max(PreferredWidth, ButtonsWidth);
    end;
    Inc(PreferredWidth, 2*BorderWidth);
    Inc(PreferredWidth, Client.Width - Content.Width);
    
    Inc(PreferredHeight, 2*BorderWidth);
    Inc(PreferredHeight, Client.Height - Content.Height);
    
end;

procedure TvqNotifier.AdjustClientRect(var ARect: TRect);
begin
    inherited AdjustClientRect(ARect);
    ARect := vqThemeManager.NotifierContentRect(ARect);
    ARect.Inflate(-BorderWidth, -BorderWidth);
end;

procedure TvqNotifier.UpdateMetrics;
begin
    InvalidatePreferredSize;
    AdjustSize;
    inherited;
end;

procedure TvqNotifier.TextChanged;
begin
    inherited;
end;

procedure TvqNotifier.ColorChanged;
begin
    inherited;
    Repaint;
end;

procedure TvqNotifier.BorderChanged;
begin
    inherited;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqNotifier.Resize;
begin
    inherited;
    UpdateLayout;
end;

function TvqNotifier.IsInternalControl(AControl: TControl): Boolean;
begin
    if AControl = nil then Exit(False);
    Result := (AControl = FLabel) or (AControl = FIcon) or 
        (AControl = FCloseButton);
    if not Result then 
        Result := (AControl is TvqNotifierButtonControl) and (AControl.Parent = Self);
end;

procedure TvqNotifier.Paint;
var
    Client: TRect;
begin
    Client := ClientRect;
    vqThemeManager.DrawNotifier(Self, Canvas, Client, FKindColors[FKind], [vqthNormal]);
    inherited;
end;

end.
