// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqMenuBox;

interface

uses       
    InterfaceBase, LCLIntf, LCLType, LMessages, LCLProc,
    SysUtils, Types, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
    ImgList, ActnList, Menus, ExtCtrls, Math, Dialogs,
    vqUtils, vqThemes, vqStringList, vqListBoxUtils, vqListBoxBuffer, vqListBox;
    
type
    TvqMenuBox = class;
    TvqMenuItem = class;
    
    TvqMenuActionLink = class(TActionLink)
    protected
        FClient: TvqMenuItem;
        function AsCustomAction: TCustomAction;
        procedure AssignClient(AClient: TObject); override;
        
        procedure SetCaption(const Value: string); override;
        procedure SetChecked(Value: Boolean); override;
        procedure SetEnabled(Value: Boolean); override;
        procedure SetHelpContext(Value: THelpContext); override;
        procedure SetHint(const Value: string); override;
        procedure SetGroupIndex(Value: Integer); override;
        procedure SetImageIndex(Value: Integer); override;
        procedure SetVisible(Value: Boolean); override;
    public
        function IsCaptionLinked: Boolean; override;
        function IsCheckedLinked: Boolean; override;
        function IsEnabledLinked: Boolean; override;
        function IsHelpContextLinked: Boolean; override;
        function IsHintLinked: Boolean; override;
        function IsGroupIndexLinked: Boolean; override;
        function IsImageIndexLinked: Boolean; override;
        function IsVisibleLinked: Boolean; override;
    end;
    
    TvqMenuActionLinkClass = class of TvqMenuActionLink;
    
    TvqMenuItem = class(TComponent)
    private
        FActionLink: TvqMenuActionLink;
        FParent: TvqMenuItem;
        
        FCaption: TCaption;
        FChecked: Boolean;
        FDefault: Boolean;
        FEnabled: Boolean;
        FGroupIndex: Integer;
        FHint: string;
        FHelpContext: THelpContext;
        FImageIndex: TImageIndex;
        FCheckItem: Boolean;
        FRadioItem: Boolean;
        FVisible: Boolean;
        FMenuIndex: Integer;
        
        FItems: TList;
        
        FOnStayHovered: TNotifyEvent;
        FOnClick: TNotifyEvent;
        
        FSubMenuImagesCount: Integer;
        FSubMenuChecksCount: Integer;
        
        function GetCount: Integer;
        function GetMenuIndex: Integer;
        function GetVisibleIndex: Integer;
        function GetItem(Index: Integer): TvqMenuItem;
        procedure SetMenuIndex(Value: Integer);
        
        procedure SetCaption(Value: TCaption);
        procedure SetChecked(Value: Boolean);
        procedure SetDefault(Value: Boolean);
        procedure SetEnabled(Value: Boolean);
        procedure SetGroupIndex(Value: Integer);
        procedure SetHint(Value: string);
        procedure SetImageIndex(Value: TImageIndex);
        procedure SetCheckItem(Value: Boolean);
        procedure SetRadioItem(Value: Boolean);
        procedure SetVisible(Value: Boolean);
    protected
        FMenuBox: TvqMenuBox;
    protected
        
        procedure AssignTo(Dest: TPersistent); override;
        procedure Loaded; override;
        procedure Notification(AComponent: TComponent; Operation: TOperation); override;
        procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
        procedure SetChildOrder(Child: TComponent; Order: Integer); override;
        procedure SetParentComponent(AValue : TComponent); override;
        
        //
        
        procedure DoActionChange(Sender: TObject);
        function GetAction: TBasicAction; virtual;
        procedure SetAction(Value: TBasicAction); virtual;
        function GetActionLinkClass: TvqMenuActionLinkClass; virtual;
        procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); virtual;
        procedure InitiateActions;
        procedure InitiateAction; virtual;
        procedure UpdateMenuIndex;
        
        //
        procedure ApplyChecked;
        procedure ApplyKind;
        procedure MenuChanged;
        procedure DoFaceClick(Sender: TObject);
        
        function IsCaptionStored: Boolean;
        function IsCheckedStored: Boolean;
        function IsEnabledStored: Boolean;
        function IsHelpContextStored: Boolean;
        function IsHintStored: Boolean;
        function IsImageIndexStored: Boolean;
        function IsVisibleStored: Boolean;
        
    protected
        property ActionLink: TvqMenuActionLink read FActionLink write FActionLink;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        function Find(const ACaption: string): TvqMenuItem;
        function GetParentComponent: TComponent; override;
        
        procedure Copy(Source: TvqMenuItem);
        procedure CopyFromMenuItem(Source: TMenuItem);
        procedure CopyToMenuItem(Dest: TMenuItem);
        procedure Add(Item: TvqMenuItem);
        procedure Add(const AItems: array of TvqMenuItem);
        procedure AddSeparator;
        procedure Delete(Index: Integer);
        procedure Insert(Index: Integer; Item: TvqMenuItem);
        procedure Remove(Item: TvqMenuItem);
        procedure Move(AParent: TvqMenuItem; Index: Integer);
        procedure Clear;
        procedure Click; virtual;
        procedure Toggle;
        procedure StayHovered; virtual;
        
        function InBranch(Branch: TvqMenuItem): Boolean;
        function HasMenuParent: Boolean;
        function IsCheckable: Boolean;
        function IsSeparator: Boolean;
        function HasImage: Boolean;
        
        function IndexOf(Item: TvqMenuItem): Integer;
        function IndexOfCaption(const ACaption: string): Integer; virtual;
        function VisibleIndexOf(Item: TvqMenuItem): Integer;
        
        property Count: Integer read GetCount;
        property MenuIndex: Integer read GetMenuIndex write SetMenuIndex;
        property VisibleIndex: Integer read GetVisibleIndex;
        
        property MenuBox: TvqMenuBox read FMenuBox;
        
        property Items[Index: Integer]: TvqMenuItem read GetItem; default;
        property Parent: TvqMenuItem read FParent;
        
    published
        property Action: TBasicAction read GetAction write SetAction;
        property Caption: TCaption read FCaption write SetCaption
            stored IsCaptionStored;
        property Checked: Boolean read FChecked write SetChecked
            stored IsCheckedStored;
        property Default: Boolean read FDefault write SetDefault;
        property Enabled: Boolean read FEnabled write SetEnabled
            stored IsEnabledStored;
        property GroupIndex: Integer read FGroupIndex write SetGroupIndex;
        property Hint: string read FHint write SetHint
            stored IsHintStored;
        property HelpContext: THelpContext read FHelpContext write FHelpContext
            stored IsHelpContextStored;
        property ImageIndex: TImageIndex read FImageIndex write SetImageIndex
            stored IsImageIndexStored;
        property CheckItem: Boolean read FCheckItem write SetCheckItem;
        property RadioItem: Boolean read FRadioItem write SetRadioItem;
        property Visible: Boolean read FVisible write SetVisible 
            stored IsVisibleStored default True;
        property OnStayHovered: TNotifyEvent read FOnStayHovered write FOnStayHovered;
        property OnClick: TNotifyEvent read FOnClick write FOnClick;
    end;

    IvqMenuBoxListener = interface(IvqListBoxListener)
        function _CurrentMenuItem(Index: Integer): TvqMenuItem;
    end;
    
    TvqMenuListItem = class(TvqListBoxItem)
    protected
        FMenuItem: TvqMenuItem;
    public
        constructor Create(AStrings: TvqStringList; AIndex: Integer); override;
		procedure Assign(Source: TPersistent); override;
        property MenuItem: TvqMenuItem read FMenuItem;
    end;
    
    TvqMenuBoxEvent = procedure(Sender: TObject; Item: TvqMenuItem) of object;
    
    { TvqMenuBox }

    TvqMenuBox = class(TvqListBox, IvqMenuBoxListener)
    private
        FSeparatorFont: TFont;
        FTimer: TTimer;
        FItems: TvqMenuItem;
        FCurrent: TvqMenuItem;
        FSubMenu: TPopupMenu;
        FSubMenuPopup: Boolean;
        FSeparatorTitle: Boolean;
        
        FStayItem: TvqMenuItem;
        FSubMenuVisible: Boolean;
        FOnMenuChanged: TvqMenuBoxEvent;
        FOnLevelChange: TNotifyEvent;
        
        FRefreshDepth: Byte;
        FRecreateList: Boolean;
        FNewCurrent: TvqMenuItem;
        
        function GetListItem(Index: Integer): TvqMenuListItem;
        function GetMenuImages: TCustomImageList;
        procedure SeparatorFontChanged(Sender: TObject);
        procedure SetMenuImages(Value: TCustomImageList);
        procedure SetCurrent(Value: TvqMenuItem);
        procedure SetSeparatorFont(AValue: TFont);
        procedure SetSubMenuPopup(Value: Boolean);
        procedure SetSeparatorTitle(Value: Boolean);
        procedure OnTimer(Sender: TObject);
        procedure OnSubMenuClose(Sender: TObject);
        procedure OnSubMenuPopup(Sender: TObject);
        
        procedure CopyToSubMenu(Item: TvqMenuItem; Dest: TMenuItem);
    protected
        function CurrentHasCheckGutter: Boolean;
        function CurrentHasImageGutter: Boolean;
        
        function DrawItem(Index: Integer): TRect; override;
        procedure Measure(Index: Integer; var AWidth, AHeight: Integer); override;
        
        procedure BeginRefresh;
        procedure RefreshItem(Item: TvqMenuItem);
        procedure RefreshMenu(Item: TvqMenuItem);
        procedure ReleaseMenu(NewCurrent: TvqMenuItem);
        procedure EndRefresh;
        
        procedure DoLevelChange; virtual;
        procedure DoMenuChanged(Item: TvqMenuItem); virtual;
        procedure DoStayHovered(Item: TvqMenuItem); virtual;

        function _CurrentMenuItem(Index: Integer): TvqMenuItem;
        function InactiveItem(Index: Integer): Boolean; override;
        procedure DoItemClick(AIndex: Integer); override;
        procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        
        procedure SetChildOrder(Child: TComponent; Order: Integer); override;
        procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
        
        property Images;
        property Lines;
        property MultiSelect;
        property OnItemClick;
        property OnItemChange;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        class function ItemClass: TvqStringItemClass; override;
        
        property ListItems[Index: Integer]: TvqMenuListItem read GetListItem;
    published
        property ItemIndex;
        property Items: TvqMenuItem read FItems;
        property SeparatorFont: TFont read FSeparatorFont write SetSeparatorFont;
        property MenuImages: TCustomImageList read GetMenuImages write SetMenuImages;
        property Current: TvqMenuItem read FCurrent write SetCurrent;
        property SubMenuPopup: Boolean read FSubMenuPopup write SetSubMenuPopup;
        property SeparatorTitle: Boolean read FSeparatorTitle write SetSeparatorTitle;
        property OwnerMeasure;
        property OwnerDraw;
        property OnMenuChanged: TvqMenuBoxEvent read FOnMenuChanged write FOnMenuChanged;
        property OnLevelChange: TNotifyEvent read FOnLevelChange write FOnLevelChange;
        property OnChange;
        property OnDrawItem;
        property OnMeasureItem;
        property OnSelChange;
    end;
    
implementation

type TMenuItemArray = array of TMenuItem;

procedure PropageMenuBox(AItem: TvqMenuItem; ABox: TvqMenuBox);
var
    I: Integer;
begin
    AItem.FMenuBox := ABox;
    for I := 0 to AItem.Count - 1 do
        PropageMenuBox(AItem.Items[I], ABox);
end;

{ TvqMenuActionLink }

function TvqMenuActionLink.AsCustomAction: TCustomAction;
begin
    Result := Action as TCustomAction;
end;

procedure TvqMenuActionLink.AssignClient(AClient: TObject);
begin
    FClient := AClient as TvqMenuItem;
end;

procedure TvqMenuActionLink.SetCaption(const Value: string);
begin
    if IsCaptionLinked then FClient.Caption := Value;
end;

procedure TvqMenuActionLink.SetChecked(Value: Boolean);
begin
    if IsCheckedLinked then FClient.Checked := Value;
end;

procedure TvqMenuActionLink.SetEnabled(Value: Boolean);
begin
    if IsEnabledLinked then FClient.Enabled := Value;
end;

procedure TvqMenuActionLink.SetHelpContext(Value: THelpContext);
begin
    if IsHelpContextLinked then FClient.HelpContext := Value;
end;

procedure TvqMenuActionLink.SetHint(const Value: string);
begin
    if IsHintLinked then FClient.Hint := Value;
end;

procedure TvqMenuActionLink.SetGroupIndex(Value: Integer);
begin
    //# if IsGroupIndexLinked then FClient.GroupIndex := Value;
end;

procedure TvqMenuActionLink.SetImageIndex(Value: Integer);
begin
    if IsImageIndexLinked then FClient.ImageIndex := Value;
end;

procedure TvqMenuActionLink.SetVisible(Value: Boolean);
begin
    if IsVisibleLinked then FClient.Visible := Value;
end;

function TvqMenuActionLink.IsCaptionLinked: Boolean;
begin
    Result := inherited IsCaptionLinked 
        and (FClient.Caption = AsCustomAction.Caption);
end;

function TvqMenuActionLink.IsCheckedLinked: Boolean;
begin
    Result := inherited IsCheckedLinked 
        and (FClient.Checked = AsCustomAction.Checked);
end;

function TvqMenuActionLink.IsEnabledLinked: Boolean;
begin
    Result := inherited IsEnabledLinked 
        and (FClient.Enabled = AsCustomAction.Enabled);
end;

function TvqMenuActionLink.IsHelpContextLinked: Boolean;
begin
    Result := inherited IsHelpContextLinked 
        and (FClient.HelpContext = AsCustomAction.HelpContext);
end;

function TvqMenuActionLink.IsHintLinked: Boolean;
begin
    Result := inherited IsHintLinked 
        and (FClient.Hint = AsCustomAction.Hint);
end;

function TvqMenuActionLink.IsGroupIndexLinked: Boolean;
begin
    Result := inherited IsGroupIndexLinked 
        and (FClient.GroupIndex = AsCustomAction.GroupIndex);
end;

function TvqMenuActionLink.IsImageIndexLinked: Boolean;
begin
    Result := inherited IsImageIndexLinked 
        and (FClient.ImageIndex = AsCustomAction.ImageIndex);
end;

function TvqMenuActionLink.IsVisibleLinked: Boolean;
begin
    Result := inherited IsVisibleLinked 
        and (FClient.Visible = AsCustomAction.Visible);
end;


{ TvqMenuItem }

constructor TvqMenuItem.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    
    FCaption := '';
    FChecked := False;
    FDefault := False;
    FEnabled := True;
    FGroupIndex := 0;
    FHint := '';
    FHelpContext := 0;
    FImageIndex := -1;
    FCheckItem := False;
    FRadioItem := False;
    FVisible := True;
    
    FItems := TList.Create;
    FParent := nil;
    
    FMenuBox := nil;
    
    FSubMenuImagesCount := 0;
    FSubMenuChecksCount := 0;
end;

destructor TvqMenuItem.Destroy;
var
    I: Integer;
    ARelease: Boolean;
begin
    // <<-- 
    
    if MenuBox <> nil then 
        MenuBox.BeginRefresh;
        
    // -->>
    
    for I := Count - 1 downto 0 do begin
        Items[I].FParent := nil;
        Items[I].FMenuBox := nil;
        Items[I].Free;
    end;
    
    FreeAndNil(FItems);
    FreeAndNil(FActionLink);
    
    // <<--
    ARelease := False;
    if MenuBox <> nil then
        if MenuBox.Current.InBranch(Self) then
            ARelease := True;
    
    if FParent <> nil then begin
        FParent.FItems.Remove(Self);
        FParent.UpdateMenuIndex;
    end;
    
    if MenuBox <> nil then
        if ARelease then MenuBox.ReleaseMenu(MenuBox.Items)
        else MenuBox.RefreshMenu(FParent);
    
    if MenuBox <> nil then
        MenuBox.EndRefresh;
    // -->>
    
    inherited Destroy;
end;

procedure TvqMenuItem.AssignTo(Dest: TPersistent);
begin
    if Dest is TCustomAction then begin
        with TCustomAction(Dest) do begin
            Caption := Self.Caption;
            Enabled := Self.Enabled;
            HelpContext := Self.HelpContext;
            Hint := Self.Hint;
            ImageIndex := Self.ImageIndex;
            Visible := Self.Visible;
        end;
    end
    else if Dest is TvqMenuItem then
        TvqMenuItem(Dest).Copy(Self)
    else if Dest is TMenuItem then begin
        CopyToMenuItem(TMenuItem(Dest));
    end
    else inherited AssignTo(Dest);
end;

procedure TvqMenuItem.CopyFromMenuItem(Source: TMenuItem);
var
    AItem: TvqMenuItem;
    I: Integer;
begin
    if MenuBox <> nil then
        MenuBox.BeginRefresh;
    with Source do begin
        Self.Clear;

        Self.Action      := Action;

        Self.Caption     := Caption;

        Self.Checked     := Checked;

        Self.Default     := Default;
        Self.Enabled     := Enabled;
        Self.GroupIndex  := GroupIndex;
        Self.Hint        := Hint;
        Self.HelpContext := HelpContext;
        Self.ImageIndex  := ImageIndex;
        
        Self.CheckItem   := AutoCheck or ShowAlwaysCheckable;
        Self.RadioItem   := RadioItem;

        Self.Visible := Visible;
        Self.OnClick := OnClick;
        Self.Tag     := Tag;
        
        for I := 0 to Count - 1 do begin
            AItem := TvqMenuItem.Create(Owner);
            AItem.CopyFromMenuItem(Items[I]);
            Self.Add(AItem);
        end;
        
    end;
    if MenuBox <> nil then
        MenuBox.EndRefresh;
end;

procedure TvqMenuItem.CopyToMenuItem(Dest: TMenuItem);
var
    AMenuItem: TMenuItem;
    I: Integer;
begin
    with Dest do begin
        Clear;
        
        Action      := Self.Action;
        Caption     := Self.Caption;
        Checked     := Self.Checked;
        Default     := Self.Default;
        Enabled     := Self.Enabled;
        GroupIndex  := Self.GroupIndex;
        Hint        := Self.Hint;
        HelpContext := Self.HelpContext;
        ImageIndex  := Self.ImageIndex;
        
        AutoCheck   := Self.CheckItem or Self.RadioItem;
        ShowAlwaysCheckable := AutoCheck;
        RadioItem   := Self.RadioItem;
        
        Visible     := Self.Visible;
        OnClick     := Self.OnClick;
        Tag         := Self.Tag;
        
        for I := 0 to Count - 1 do begin
            AMenuItem := TMenuItem.Create(Owner);
            Self.Items[I].CopyToMenuItem(AMenuItem);
            Add(AMenuItem);
        end;
        
    end;
end;

procedure TvqMenuItem.Copy(Source: TvqMenuItem);
var
    Other: TvqMenuItem;
    I: Integer;
    AItem: TvqMenuItem;
begin
    if (Source <> Self) and (Source <> nil) then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
        Other := Source;
        
        Clear;
        
        Action      := Other.Action;
        Caption     := Other.Caption;
        Checked     := Other.Checked;
        Default     := Other.Default;
        Enabled     := Other.Enabled;
        GroupIndex  := Other.GroupIndex;
        Hint        := Other.Hint;
        HelpContext := Other.HelpContext;
        ImageIndex  := Other.ImageIndex;
        CheckItem   := Other.CheckItem;
        RadioItem   := Other.RadioItem;
        Visible     := Other.Visible;
        OnClick     := Other.OnClick;
        OnStayHovered := Other.OnStayHovered;
        Tag         := Other.Tag;
        
        for I := 0 to Other.Count - 1 do begin
            AItem := TvqMenuItem.Create(Other.Owner);
            AItem.Assign(Other.Items[I]);
            Add(AItem);
        end;
        if MenuBox <> nil then MenuBox.RefreshMenu(FParent);
        if MenuBox <> nil then MenuBox.EndRefresh;
    end;
end;

function TvqMenuItem.Find(const ACaption: string): TvqMenuItem;
var
    I: Integer;
begin
    I := IndexOfCaption(ACaption);
    if I <> -1 then Result := Items[I]
    else Result := nil;
end;

procedure TvqMenuItem.Add(Item: TvqMenuItem);
begin
    Insert(Count, Item);
end;

procedure TvqMenuItem.Add(const AItems: array of TvqMenuItem);
var
    I: Integer;
begin
    for I := 0 to Length(AItems) - 1 do
        Add(AItems[I]);
end;

procedure TvqMenuItem.AddSeparator;
var
    Item: TvqMenuItem;
begin
    Item := TvqMenuItem.Create(Self);
    Item.Caption := cLineCaption;
    Add(Item);
end;

procedure TvqMenuItem.Delete(Index: Integer);
var
    ARelease: Boolean;
    Item: TvqMenuItem;
begin
    if (Index >= 0) and (Index < Count) then begin
        if MenuBox <> nil then 
            MenuBox.BeginRefresh;
        Item := Items[Index];
        
        if Item.IsCheckable then
            Dec(FSubMenuChecksCount);
        if Item.ImageIndex >= 0 then
            Dec(FSubMenuImagesCount);
        
        ARelease := False;
        if MenuBox <> nil then
            if MenuBox.Current.InBranch(Item) then
                ARelease := True;
                
        FItems.Delete(Index);
        UpdateMenuIndex;
        Item.FParent := nil;
        Item.FMenuBox := nil;
        
        if MenuBox <> nil then 
            if ARelease then MenuBox.ReleaseMenu(MenuBox.Items)
            else MenuBox.RefreshMenu(Self);
        
        MenuChanged;
        if MenuBox <> nil then 
            MenuBox.EndRefresh;
    end;
end;

procedure TvqMenuItem.Insert(Index: Integer; Item: TvqMenuItem);
begin
    if (Index >= 0) and (Index <= Count) then begin
        if MenuBox <> nil then 
            MenuBox.BeginRefresh;
        Item.FParent := Self;
        PropageMenuBox(Item, FMenuBox);
        FItems.Insert(Index, Item);
        UpdateMenuIndex;
        
        if Item.IsCheckable then
            Inc(FSubMenuChecksCount);
        if Item.ImageIndex >= 0 then
            Inc(FSubMenuImagesCount);
        
        if MenuBox <> nil then MenuBox.RefreshMenu(Self);
        MenuChanged;
        if MenuBox <> nil then
            MenuBox.EndRefresh;
    end;
end;

procedure TvqMenuItem.Remove(Item: TvqMenuItem);
var
    I: Integer;
begin
    I := IndexOf(Item);
    if I <> -1 then
        Delete(I);
end;

procedure TvqMenuItem.Move(AParent: TvqMenuItem; Index: Integer);
var
    OldParent: TvqMenuItem;
begin
    if (AParent <> nil) then begin
        if (Index >= 0) and (Index < AParent.Count) then begin
            if MenuBox <> nil then
                MenuBox.BeginRefresh;
            OldParent := FParent;
            if OldParent <> nil then 
                OldParent.Remove(Self);
            AParent.Insert(Index, Self);
            if MenuBox <> nil then
                MenuBox.EndRefresh;
        end;
    end;
end;

procedure TvqMenuItem.Clear;
var
    I: Integer;
    ARelease: Boolean;
begin
    // <<--
    if Count = 0 then Exit;
    
    if MenuBox <> nil then
        MenuBox.BeginRefresh;
        
    // -->>
    
    for I := Count - 1 downto 0 do begin
        Items[I].FParent := nil;
        Items[I].FMenuBox := nil;
        Items[I].Free;
    end;
    
    // <<--
    
    FSubMenuChecksCount := 0;
    FSubMenuImagesCount := 0;
    
    ARelease := False;
    if MenuBox <> nil then
        if MenuBox.Current.InBranch(Self) then
            ARelease := True;
    
    if MenuBox <> nil then
        if ARelease then MenuBox.ReleaseMenu(MenuBox.Items)
        else MenuBox.RefreshMenu(Self);
        
    MenuChanged;
    
    if MenuBox <> nil then
        MenuBox.EndRefresh;
    // -->>
    
end;

procedure TvqMenuItem.Click;
    
    function OnClickIsActionExecute: Boolean;
    begin
        if (Action <> nil) and Assigned(Action.OnExecute) and Assigned(FOnClick) then
            Result := CompareMethods(TMethod(FOnClick), TMethod(Action.OnExecute))
        else
            Result := False;
    end;
    
begin
    if not (csDesigning in ComponentState) then begin
        InitiateActions;
        if not Enabled then Exit;
        if IsCheckable and not (Assigned(FActionLink) and FActionLink.IsCheckedLinked) then begin
            if Checked or CheckItem then // only for checkbox
                Toggle
            else if RadioItem and not Checked then
                Toggle;
        end;
        if Assigned(FOnClick) and not (Assigned(FActionLink) and
            OnClickIsActionExecute) then 
            FOnClick(Self);
        if Assigned(FActionLink) then
            FActionLink.Execute(Self);
    end;
end;

procedure TvqMenuItem.Toggle;
begin
    Checked := not Checked;
end;

procedure TvqMenuItem.StayHovered;
begin
    if not Enabled then Exit;
    if Assigned(FOnStayHovered) then FOnStayHovered(Self);
end;

function TvqMenuItem.InBranch(Branch: TvqMenuItem): Boolean;
var
    ANode: TvqMenuItem;
begin
    Result := False;
    ANode := Self;
    while ANode <> nil do begin
        if ANode = Branch then
            Exit(True);
        ANode := ANode.FParent;
    end;
end;

function TvqMenuItem.HasMenuParent: Boolean;
begin
    Result := FParent <> nil;
end;

function TvqMenuItem.IsCheckable: Boolean;
begin
    Result := Checked or RadioItem or CheckItem;
end;

function TvqMenuItem.IsSeparator: Boolean;
begin
    Result := Caption = cLineCaption;
end;

function TvqMenuItem.HasImage: Boolean;
begin
    Result := (MenuBox.MenuImages <> nil) and (ImageIndex >= 0) and
        (ImageIndex < MenuBox.MenuImages.Count);
end;

function TvqMenuItem.IndexOf(Item: TvqMenuItem): Integer;
begin
    if Item.FParent = Self then
        Result := Item.FMenuIndex
    else
        Result := -1;
end;

function TvqMenuItem.IndexOfCaption(const ACaption: string): Integer;
begin
    for Result := 0 to Count - 1 do
        if Items[Result].Caption = ACaption then Exit;
    Result := -1;
end;

function TvqMenuItem.VisibleIndexOf(Item: TvqMenuItem): Integer;
var
    I: Integer;
begin
    if (Item = nil) or not Item.Visible then Result := -1
    else begin
        Result := 0;
        for I := 0 to Count - 1 do
            if Items[I].Visible and (Items[I] = Item) then
                Exit
            else if Items[I].Visible then
                Inc(Result);
        Result := -1;
        if Item.Visible then
            raise Exception.Create('TvqMenuItem.VisibleIndexOf '+dbgsName(Item)+' inconsistent');
    end;
end;

procedure TvqMenuItem.Loaded;
begin
    inherited;
    if Action <> nil then ActionChange(Action, True);
end;

procedure TvqMenuItem.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if Operation = opRemove then
        if AComponent = Action then Action := nil;
end;

procedure TvqMenuItem.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
    I: Integer;
begin
    for I := 0 to Count - 1 do  
        Proc(TComponent(FItems[I]));
end;

procedure TvqMenuItem.SetChildOrder(Child: TComponent; Order: Integer);
begin
    (Child as TvqMenuItem).MenuIndex := Order;
end;

procedure TvqMenuItem.SetParentComponent(AValue : TComponent);
begin
    if FParent = AValue then Exit;
    
    if FParent <> nil then
        FParent.Remove(Self);
    
    if AValue <> nil then begin
        if AValue is TvqMenuBox then 
            TvqMenuBox(AValue).Items.Add(Self)
        else
            raise Exception.Create('TvqMenuBox.SetParentComponent: Invalid parent');
    end;
end;

function TvqMenuItem.GetParentComponent: TComponent;
begin
    if FParent = MenuBox.Items then
        Result := MenuBox
    else
        Result := FParent;
end;

//--

function TvqMenuItem.GetCount: Integer;
begin
    Result := FItems.Count;
end;

function TvqMenuItem.GetMenuIndex: Integer;
begin
    Result := -1;
    if FParent <> nil then Result := FParent.IndexOf(Self);
end;

function TvqMenuItem.GetVisibleIndex: Integer;
begin
    Result := -1;
    if FParent <> nil then
        Result := FParent.VisibleIndexOf(Self);
end;

function TvqMenuItem.GetItem(Index: Integer): TvqMenuItem;
begin
    Result := TvqMenuItem(FItems[Index]);
end;

procedure TvqMenuItem.SetMenuIndex(Value: Integer);
begin
    if FParent <> nil then begin
        if Value < 0 then Value := 0;
        if Value >= FParent.Count then 
            Value := FParent.Count - 1;
        Move(FParent, Value);
    end;
end;

//--

function TvqMenuItem.GetAction: TBasicAction;
begin
    if FActionLink <> nil then
        Result := FActionLink.Action
    else
        Result := nil;
end;

procedure TvqMenuItem.SetAction(Value: TBasicAction);
begin
    if Value = nil then begin
        FActionLink.Free;
        FActionLink := nil;
    end 
    else begin
        if FActionLink = nil then
            FActionLink := GetActionLinkClass.Create(Self);
        FActionLink.Action := Value;
        FActionLink.OnChange := @DoActionChange;
        ActionChange(Value, csLoading in Value.ComponentState);
        Value.FreeNotification(Self);
    end;
end;

procedure TvqMenuItem.SetCaption(Value: TCaption);
var
    PrevSeparator: Boolean;
begin
	if FCaption <> Value then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
        PrevSeparator := IsSeparator;
        FCaption := Value;
        if MenuBox <> nil then
            MenuBox.RefreshItem(Self);
        if MenuBox <> nil then MenuBox.EndRefresh;
	end;
end;

procedure TvqMenuItem.SetChecked(Value: Boolean);
begin
	if FChecked <> Value then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
        
        if FRadioItem or FCheckItem then
            begin end
        else if FParent <> nil then
            if Value then Inc(FParent.FSubMenuChecksCount)
            else Dec(FParent.FSubMenuChecksCount);
        
        FChecked := Value;
        ApplyChecked;
        if MenuBox <> nil then MenuBox.EndRefresh;
	end;
end;

procedure TvqMenuItem.SetDefault(Value: Boolean);
begin
	if FDefault <> Value then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
		FDefault := Value;
        if MenuBox <> nil then MenuBox.RefreshItem(Self);
        if MenuBox <> nil then MenuBox.EndRefresh;
	end;
end;

procedure TvqMenuItem.SetEnabled(Value: Boolean);
begin
	if FEnabled <> Value then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
		FEnabled := Value;
        if MenuBox <> nil then MenuBox.RefreshItem(Self);
        if MenuBox <> nil then MenuBox.EndRefresh;
	end;
end;

procedure TvqMenuItem.SetGroupIndex(Value: Integer);
begin
	if FGroupIndex <> Value then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
		FGroupIndex := Value;
        ApplyChecked;
        if MenuBox <> nil then MenuBox.EndRefresh;
	end;
end;

procedure TvqMenuItem.SetHint(Value: string);
begin
	if FHint <> Value then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
		FHint := Value;
        if IsSeparator and (MenuBox <> nil) then 
            MenuBox.RefreshItem(Self);
        if MenuBox <> nil then MenuBox.EndRefresh;
	end;
end;

procedure TvqMenuItem.SetImageIndex(Value: TImageIndex);
begin
    if Value < -1 then Value := -1;
	if FImageIndex <> Value then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
        
		FImageIndex := Value;
        
        if FParent <> nil then
            if FImageIndex = -1 then Dec(FParent.FSubMenuImagesCount)
            else Inc(FParent.FSubMenuImagesCount);
        
        if MenuBox <> nil then MenuBox.RefreshItem(Self);
        if MenuBox <> nil then MenuBox.EndRefresh;
	end;
end;

procedure TvqMenuItem.SetRadioItem(Value: Boolean);
begin
	if FRadioItem <> Value then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
        
        if FChecked or FCheckItem then
            begin end
        else if FParent <> nil then
            if Value then Inc(FParent.FSubMenuChecksCount)
            else Dec(FParent.FSubMenuChecksCount);
        
		FRadioItem := Value;
        if FRadioItem then FCheckItem := False;
        ApplyKind;
        ApplyChecked;
        if MenuBox <> nil then MenuBox.EndRefresh;
	end;
end;

procedure TvqMenuItem.SetCheckItem(Value: Boolean);
begin
    if FCheckItem <> Value then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
        
        if FChecked or FRadioItem then
            begin end
        else if FParent <> nil then
            if Value then Inc(FParent.FSubMenuChecksCount)
            else Dec(FParent.FSubMenuChecksCount);
        
        FCheckItem := Value;
        if FCheckItem then FRadioItem := False;
        ApplyKind;
        if MenuBox <> nil then MenuBox.RefreshItem(Self);
        if MenuBox <> nil then MenuBox.EndRefresh;
    end;
end;

procedure TvqMenuItem.SetVisible(Value: Boolean);
begin
	if FVisible <> Value then begin
        if MenuBox <> nil then MenuBox.BeginRefresh;
        if csDestroying in ComponentState then Exit;
        FVisible := Value;
        if MenuBox <> nil then
            MenuBox.RefreshItem(Self);
        if MenuBox <> nil then MenuBox.EndRefresh;
	end;
end;

function TvqMenuItem.IsCaptionStored: Boolean;
begin
    Result := (ActionLink = nil) or not FActionLink.IsCaptionLinked;
end;

function TvqMenuItem.IsCheckedStored: Boolean;
begin
    Result := (ActionLink = nil) or not FActionLink.IsCheckedLinked;
end;

function TvqMenuItem.IsEnabledStored: Boolean;
begin
    Result := (ActionLink = nil) or not FActionLink.IsEnabledLinked;
end;

function TvqMenuItem.IsHelpContextStored: Boolean;
begin
    Result := (ActionLink = nil) or not FActionLink.IsHelpContextLinked;
end;

function TvqMenuItem.IsHintStored: Boolean;
begin
    Result := (ActionLink = nil) or not FActionLink.IsHintLinked;
end;

function TvqMenuItem.IsImageIndexStored: Boolean;
begin
    Result := (ActionLink = nil) or not FActionLink.IsImageIndexLinked;
end;

function TvqMenuItem.IsVisibleStored: Boolean;
begin
    Result := (ActionLink = nil) or not FActionLink.IsVisibleLinked;
end;

//--

procedure TvqMenuItem.ApplyChecked;
var
    I: Integer;
    Item: TvqMenuItem;
begin
    if (FParent <> nil) and FRadioItem and FChecked
        and not (csLoading in ComponentState) then begin
        for I := 0 to FParent.Count - 1 do begin
            Item := FParent.Items[I];
            if (Item <> Self) and Item.RadioItem and 
                (Item.GroupIndex = FGroupIndex) then
                Item.Checked := False;
        end;
    end;
    if MenuBox <> nil then MenuBox.RefreshItem(Self);
end;

procedure TvqMenuItem.ApplyKind;
var
    I: Integer;
    Item: TvqMenuItem;
begin
    if (FGroupIndex <> 0) and (FParent <> nil) then
        for I := 0 to FParent.Count - 1 do begin
            Item := FParent.Items[I];
            if (Item <> Self) and (Item.GroupIndex = GroupIndex) then begin
                Item.FRadioItem := FRadioItem;
                Item.FCheckItem := FCheckItem;
                if MenuBox <> nil then MenuBox.RefreshItem(Item);
            end;
        end;
    if MenuBox <> nil then MenuBox.RefreshItem(Self);
end;

procedure TvqMenuItem.MenuChanged;
begin
    if MenuBox <> nil then
        MenuBox.DoMenuChanged(Self);
end;

procedure TvqMenuItem.DoFaceClick(Sender: TObject);
begin
    if Sender is TMenuItem then 
        Click;
end;

procedure TvqMenuItem.DoActionChange(Sender: TObject);
begin   
    if Sender = Action then ActionChange(Sender, False);
end;

function TvqMenuItem.GetActionLinkClass: TvqMenuActionLinkClass;
begin
    Result := TvqMenuActionLink;
end;

procedure TvqMenuItem.ActionChange(Sender: TObject; CheckDefaults: Boolean);
var
    NewAction: TCustomAction;
begin
    if Sender is TCustomAction then begin
        NewAction := TCustomAction(Sender);
        if not CheckDefaults or (Caption = '') then
            Caption := NewAction.Caption;
        if not CheckDefaults or (Checked = False) then
            Checked := NewAction.Checked;
        if not CheckDefaults or (Enabled = True) then
            Enabled := NewAction.Enabled;
        if (not CheckDefaults) or (HelpContext = 0) then
            HelpContext := NewAction.HelpContext;
        if not CheckDefaults or (Hint = '') then
            Hint := NewAction.Hint;
        if (RadioItem or CheckItem) and 
            (not CheckDefaults or (GroupIndex = 0)) then
            GroupIndex := NewAction.GroupIndex;
        if not CheckDefaults or (ImageIndex = -1) then
            ImageIndex := NewAction.ImageIndex;
        if not CheckDefaults or (Visible = True) then
            Visible := NewAction.Visible;
    end;
end;

procedure TvqMenuItem.InitiateActions;
var
    I: Integer;
begin
    for I := 0 to Count - 1 do Items[I].InitiateAction;
end;

procedure TvqMenuItem.InitiateAction;
begin
    if FActionLink <> nil then FActionLink.Update;
end;

procedure TvqMenuItem.UpdateMenuIndex;
var
    I: Integer;
begin
    for I := 0 to Count - 1 do 
        Items[I].FMenuIndex := I;
end;

{ TvqMenuListItem }

constructor TvqMenuListItem.Create(AStrings: TvqStringList; AIndex: Integer);
begin
    inherited Create(AStrings, AIndex);
    if ListBox <> nil then
        FMenuItem := TvqMenuBox(ListBox._ListBoxControl)._CurrentMenuItem(AIndex)
    else
        FMenuItem := nil;
end;

procedure TvqMenuListItem.Assign(Source: TPersistent);
begin
    if (Source is TvqMenuListItem) and (Source <> Self) then
        FMenuItem := TvqMenuListItem(Source).FMenuItem;
    inherited Assign(Source);
end;

{ TvqMenuBox }

constructor TvqMenuBox.Create(AOwner: TComponent); 
begin
    inherited Create(AOwner);
    FItems := TvqMenuItem.Create(Self);
    FItems.FMenuBox := Self;
    
    FCurrent := FItems;
    FSubMenu := TPopupMenu.Create(nil);
    FTimer := TTimer.Create(nil);
    FTimer.Enabled := False;
    FTimer.Interval := 3000;
    FTimer.OnTimer := @OnTimer;
    FSubMenuPopup := True;
    FSubMenu.OnClose := @OnSubMenuClose;
    FSubMenu.OnPopup := @OnSubMenuPopup;
    FSeparatorTitle := False;
    FSeparatorFont := TFont.Create;
    FSeparatorFont.OnChange := @SeparatorFontChanged;
end;

destructor TvqMenuBox.Destroy;
begin
    FSubMenu.Free;
    FTimer.Free;
    FreeAndNil(FItems);
    FSeparatorFont.Free;
    inherited;
end;

procedure TvqMenuBox.Assign(Source: TPersistent);
begin
    if (Source is TvqMenuBox) and (Source <> Self) then begin
        BeginRefresh;
        FSubMenu.Close;
        FSubMenu.Items.Clear;
        FItems.Assign(TvqMenuBox(Source).FItems);
        ReleaseMenu(FItems);
        EndRefresh;
    end
    else if Source is TPopupMenu then begin
        BeginRefresh;   
        FSubMenu.Close;
        FSubMenu.Items.Clear;
        FItems.CopyFromMenuItem(TPopupMenu(Source).Items);
        ReleaseMenu(FItems);
        EndRefresh;
    end
    else inherited;
end;

class function TvqMenuBox.ItemClass: TvqStringItemClass;
begin
    Result := TvqMenuListItem;
end;

procedure TvqMenuBox.BeginRefresh;
begin
    if FRefreshDepth = 0 then begin
        FRecreateList := False;
        FNewCurrent := nil;
    end;
    BeginWork;
    Lines.BeginUpdate;
    Inc(FRefreshDepth);
end;

procedure TvqMenuBox.RefreshItem(Item: TvqMenuItem);
begin
    if (Item <> FItems) and (Item.Parent = FCurrent) then begin
        TvqMenuListItem(inherited Items[Item.MenuIndex]).Update;
    end;
end;

procedure TvqMenuBox.ReleaseMenu(NewCurrent: TvqMenuItem);
begin
    if NewCurrent <> nil then
        if NewCurrent.InBranch(Items) then
            FNewCurrent := NewCurrent;
end;

procedure TvqMenuBox.RefreshMenu(Item: TvqMenuItem);
begin
    if Item = nil then
        FRecreateList := True
    else if Item = FCurrent then
        FRecreateList := True;
end;

procedure TvqMenuBox.EndRefresh;
label LBL_RECREATE;
var
    ASelItem: TvqMenuItem;
    AItem: TvqMenuItem;
    I, NewItemIndex: Integer;
begin
    Dec(FRefreshDepth);
    if FRefreshDepth = 0 then begin
        if FNewCurrent <> nil then begin

            if FNewCurrent = FCurrent then goto LBL_RECREATE;

            //# if FCurrent.InBranch(FNewCurrent) then
            //#     NewItemIndex := ;

            FCurrent := FNewCurrent;
            Lines.Clear;
            Lines.Capacity := FCurrent.Count;

            for I := 0 to FCurrent.Count - 1 do begin
                AItem := FCurrent[I];
                Lines.Add(AItem.Caption);
                TvqMenuListItem(inherited Items[I]).FMenuItem := AItem;
            end;
            ItemIndex := FirstActiveItem;
            DoLevelChange;
        end
        else if FRecreateList then begin
            
            LBL_RECREATE:
            
            if ItemIndex = -1 then 
                ASelItem := nil
            else 
                ASelItem := TvqMenuListItem(inherited Items[ItemIndex]).FMenuItem;

            Lines.Clear; // ItemIndex = -1
            Lines.Capacity := FCurrent.Count;
            for I := 0 to FCurrent.Count - 1 do begin
                AItem := FCurrent[I];                
                Lines.Add(AItem.Caption);
            end;
            
            for I := 0 to FCurrent.Count - 1 do
                if FCurrent[I] = ASelItem then begin
                    ItemIndex := I;
                    Break;
                end;
        end;                    
        FNewCurrent := nil;
        FRecreateList := False;
    end;
    Lines.EndUpdate;
    EndWork;
end;

procedure TvqMenuBox.DoLevelChange;
begin
    if Assigned(FOnLevelChange) then FOnLevelChange(Self);
end;

procedure TvqMenuBox.DoMenuChanged(Item: TvqMenuItem);
begin
    if Assigned(FOnMenuChanged) then FOnMenuChanged(Self, Item);
end;

procedure TvqMenuBox.DoStayHovered(Item: TvqMenuItem);
var
    AIndex: Integer;
    AItems: TMenuItemArray;
    I: Integer;
    P: TPoint;
begin
    if FSubMenu.Items.Count > 0 then Exit;
    if Item <> nil then begin
        if (Item.Count > 0) and FSubMenuPopup and (FCurrent = Item.Parent) then begin

            AIndex := Item.MenuIndex;

            FSubMenu.Items.Clear;
            FSubMenu.Images := MenuImages;
            SetLength(AItems, Item.Count);
            for I := 0 to Item.Count - 1 do begin
                AItems[I] := TMenuItem.Create(Self);
                Item.Items[I].CopyToMenuItem(AItems[I]);
            end;
            FSubMenu.Items.Add(AItems);
            
            P.X := ClientRect.Right;
            P.Y := ItemRect(AIndex).Top;
            P := ClientToScreen(P);
            
            FSubMenu.Popup(P.X, P.Y);
        end;
        Item.StayHovered;
    end;
end;

function TvqMenuBox._CurrentMenuItem(Index: Integer): TvqMenuItem;
begin
    if (Index >= 0) and (Index < FItems.Count) then
        Result := FItems[Index]
    else Result := nil;
end;

function TvqMenuBox.InactiveItem(Index: Integer): Boolean;
var
    AItem: TvqMenuItem;
begin
    if (Index >= 0) and (Index < Count) then begin
        AItem := ListItems[Index].MenuItem;
        Result := (not AItem.Enabled) or (not AItem.Visible) or (AItem.IsSeparator);
    end;
end;

procedure TvqMenuBox.DoItemClick(AIndex: Integer);
var
    AListItem: TvqMenuListItem;
    AMenuItem: TvqMenuItem;
begin
    AListItem := ListItems[AIndex];
    if AListItem <> nil then begin
        AMenuItem := AListItem.MenuItem;
        if AMenuItem.Count = 0 then AMenuItem.Click;
        if AMenuItem.Count > 0 then
            SetCurrent(AMenuItem);
    end;
    inherited DoItemClick(AIndex);
end;

procedure TvqMenuBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
    AIndex: Integer;
    NewStayItem: TvqMenuItem;
    P: TPoint;
begin
    FTimer.Enabled := False;
    inherited MouseMove(Shift, X, Y);
    P := Point(X, Y);
    if FSubMenuPopup and (Lines.Count > 0) and (PtInRect(ClientRect, P)) then begin
        AIndex := ItemFromPoint(P);
        if AIndex <> vqInvalidValue then begin
            NewStayItem := ListItems[AIndex].MenuItem;
            if (NewStayItem <> FStayItem) and FSubMenuVisible then
                FSubMenu.Close;
            FStayItem := NewStayItem;
            if FStayItem <> nil then 
                FTimer.Enabled := FStayItem.Enabled and not FStayItem.IsSeparator and
                    (FStayItem.Count > 0);
        end
        else FStayItem := nil;
    end
    else FStayItem := nil;
end;

procedure TvqMenuBox.SetChildOrder(Child: TComponent; Order: Integer);
begin
    TvqMenuItem(Child).MenuIndex := Order;
end;

procedure TvqMenuBox.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
    I: Integer;
begin
    for I := 0 to FItems.Count - 1 do
        Proc(TComponent(FItems[I]));
end;

function TvqMenuBox.GetListItem(Index: Integer): TvqMenuListItem;
begin
    Result := TvqMenuListItem(inherited Items[Index]);
end;

function TvqMenuBox.GetMenuImages: TCustomImageList;
begin
    Result := inherited Images;
end;

procedure TvqMenuBox.SetMenuImages(Value: TCustomImageList);
var
    AImages: TImageList;
begin
    if Value is TImageList then
        inherited Images := TImageList(Value);

end;

procedure TvqMenuBox.SetCurrent(Value: TvqMenuItem);
begin
    if (FCurrent <> Value) and (Value <> nil) then begin
        BeginRefresh;
        ReleaseMenu(Value);
        EndRefresh;
    end;
end;

procedure TvqMenuBox.SetSeparatorFont(AValue: TFont);
begin
    if FSeparatorFont = AValue then Exit;
    FSeparatorFont.Assign(AValue);
end;

procedure TvqMenuBox.SetSubMenuPopup(Value: Boolean);
begin
    if FSubMenuPopup <> Value then begin
        FTimer.Enabled := False;
        FStayItem := nil;
        FSubMenuPopup := Value;
    end;
end;

procedure TvqMenuBox.SetSeparatorTitle(Value: Boolean);
var
    I: Integer;
begin
    if FSeparatorTitle <> Value then begin
        BeginRefresh;
        FSeparatorTitle := Value;
        for I := 0 to FCurrent.Count - 1 do
            RefreshItem(FCurrent[I]);
        EndRefresh;
    end;
end;

procedure TvqMenuBox.SeparatorFontChanged(Sender: TObject);
begin
    UpdateMetrics;
end;

procedure TvqMenuBox.OnTimer(Sender: TObject);
begin
    DoStayHovered(FStayItem);
    FTimer.Enabled := False;
    FStayItem := nil;
end;

procedure TvqMenuBox.CopyToSubMenu(Item: TvqMenuItem; Dest: TMenuItem);
var
    AMenuItem: TMenuItem;
    I: Integer;
begin
    Dest.Clear;
    
    Dest.Action      := nil;
    Dest.Caption     := Item.Caption;
    Dest.Checked     := Item.Checked;
    Dest.Default     := Item.Default;
    Dest.Enabled     := Item.Enabled;
    Dest.GroupIndex  := Item.GroupIndex;
    Dest.Hint        := Item.Hint;
    Dest.HelpContext := Item.HelpContext;
    Dest.ImageIndex  := Item.ImageIndex;
    
    Dest.AutoCheck   := Item.CheckItem or Item.RadioItem;
    Dest.ShowAlwaysCheckable := Dest.AutoCheck;
    Dest.RadioItem   := Item.RadioItem;
    
    Dest.Visible     := Item.Visible;
    Dest.OnClick     := @Item.DoFaceClick;
    // Dest.Tag         := Item.Tag;
    
    for I := 0 to Item.Count - 1 do begin
        AMenuItem := TMenuItem.Create(Self);
        Item.Items[I].CopyToMenuItem(AMenuItem);
        Dest.Add(AMenuItem);
    end;
end;

procedure TvqMenuBox.OnSubMenuPopup(Sender: TObject);
begin
    FSubMenuVisible := True;
end;

procedure TvqMenuBox.OnSubMenuClose(Sender: TObject);
begin
    FSubMenuVisible := False;
    FSubMenu.Items.Clear;
end;

function TvqMenuBox.CurrentHasCheckGutter: Boolean;
begin
    Result := FCurrent.FSubMenuChecksCount > 0;
end;

function TvqMenuBox.CurrentHasImageGutter: Boolean;
begin
    Result := (MenuImages <> nil) and (FCurrent.FSubMenuImagesCount > 0);
end;

function TvqMenuBox.DrawItem(Index: Integer): TRect;
var
    AItem: TvqMenuItem;
    ItemR: TRect;
    AState: TvqThemeState;
    Str: string;
    ARect: TRect;
    DCIndex: Integer;
    TxtXY, GlXY: TPoint;
    SzG, SzT: TSize;
    R, ArrRect: TRect;
begin
    ItemR := ItemRect(Index);
    Result.Left := ClientRect.Left;
    Result.Right := ClientRect.Right;
    Result.Top := ItemR.Top;
    Result.Bottom := ItemR.Bottom;
    
    AItem := ListItems[Index].MenuItem;

    if not AItem.Visible then Exit;
    
    AState := GetItemState(Index);
    if not AItem.Enabled then Include(AState, vqthDisabled);
    
    with BackBmp.Canvas do begin
        if vqthSelected in AState then
            FullBrush(vqThemeManager.HiliteBack)
        else
            FullBrush(Color);
        FillRect(Result);
    end;

    if AItem = nil then Exit;
    
    if OwnerDraw then
        DoDrawItem(BackBmp.Canvas, ItemR, Index, AState)
    else with BackBmp.Canvas do begin
        
        ARect := Result;

        if AItem.IsSeparator then
            if FSeparatorTitle then begin
                vqThemeManager.DrawMenuHeader(Self, BackBmp.Canvas, Result, AState);
                
                if CurrentHasCheckGutter then
                    Inc(ARect.Left, vqThemeManager.MenuCheckSize.cx);
                // if FUsingImages then 
                //     Inc(ARect.Left, MenuImages.Width);
                Inc(ARect.Left, Spacing);
                
                Font := FSeparatorFont;
                if not Enabled then Font.Color := vqThemeManager.DisabledFore;
                Str := AItem.Hint;
                if Str = '' then
                    SzT := TSize.Create(0, TextExtent('Qq').cy)
                else
                    SzT := TextExtent(Str);
                TxtXY.Y := (ARect.Top + ARect.Bottom - SzT.cy) div 2;
                TxtXY.X := ARect.Left;
                
                DCIndex := WidgetSet.SaveDC(Handle);
                WidgetSet.IntersectClipRect(Handle, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
                
                TextRect(ARect, TxtXY.X, TxtXY.Y, Str, LineTextStyle);
                
                WidgetSet.RestoreDC(Handle, DCIndex);
            end
            else
                vqThemeManager.DrawMenuSeparator(Self, BackBmp.Canvas, Result, AState)
        else begin

            Font := Self.Font;

            vqThemeManager.DrawMenuItem(Self, BackBmp.Canvas, Result, AState);
            
            if CurrentHasCheckGutter then begin
                R := ARect;
                R.Right := R.Left + vqThemeManager.MenuCheckSize.cx;
                if AItem.RadioItem then
                    if AItem.Checked then
                        vqThemeManager.DrawMenuRadioOn(Self, BackBmp.Canvas, R, AState)
                    else
                        vqThemeManager.DrawMenuRadioOff(Self, BackBmp.Canvas, R, AState)
                else if AItem.Checked then //!
                    vqThemeManager.DrawMenuCheckOn(Self, BackBmp.Canvas, R, AState)
                else if AItem.CheckItem then
                    if AItem.Checked then
                        vqThemeManager.DrawMenuCheckOn(Self, BackBmp.Canvas, R, AState)
                    else
                        vqThemeManager.DrawMenuCheckOff(Self, BackBmp.Canvas, R, AState);
                
                ARect.Left := R.Right;
            end;

            ArrRect := ARect;
            DCIndex := WidgetSet.SaveDC(Handle);
            WidgetSet.IntersectClipRect(Handle, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
            
            if CurrentHasImageGutter then begin
                R := ARect;
                R.Right := R.Left + MenuImages.Width;
                
                if AItem.HasImage then begin
                    SzG := TSize.Create(MenuImages.Width, MenuImages.Height);
                    GlXY.Y := (ARect.Top + ARect.Bottom - SzG.cy) div 2;
                    GlXY.X := ARect.Left;
                    
                    MenuImages.Draw(BackBmp.Canvas, GlXY.X, GlXY.Y, AItem.ImageIndex, Enabled and AItem.Enabled);
                end;
                ARect.Left := R.Right;
            end;
            
            Inc(ARect.Left, Spacing);

            if not Enabled then Font.Color := vqThemeManager.DisabledFore
            else if ListItems[Index].Selected  then Font.Color := vqThemeManager.HiliteFore;
            
            Str := AItem.Caption;
            if Str = '' then
                SzT := TSize.Create(0, TextExtent('Qq').cy)
            else
                SzT := TextExtent(Str);
            TxtXY.Y := (ARect.Top + ARect.Bottom - SzT.cy) div 2;
            TxtXY.X := ARect.Left;
            TextRect(ARect, TxtXY.X, TxtXY.Y, Str, LineTextStyle);

            // submenu arrow

            if AItem.Count > 0 then begin
                ArrRect.Left := ArrRect.Right - 17;
                vqThemeManager.DrawArrowGlyph(Self, BackBmp.Canvas, ArrRect, vqArrowRight, Enabled and AItem.Enabled);
            end;

            //

            WidgetSet.RestoreDC(Handle, DCIndex);

        end;
    end;
end;

procedure TvqMenuBox.Measure(Index: Integer; var AWidth, AHeight: Integer);
var
    AItem: TvqMenuItem;
    SzG, SzT: TSize;
    Str: string;
begin
    if OwnerMeasure then begin
        AWidth := 0;
        AHeight := 17;
        DoMeasureItem(Index, BackBmp.Canvas, AWidth, AHeight);
    end
    else begin
        AItem := ListItems[Index].MenuItem;
        
        if not AItem.Visible then begin
            AWidth := 0;
            AHeight := 0;
        end
        else if AItem.IsSeparator then begin
            AWidth := 0;
            if FSeparatorTitle then begin
                if CurrentHasCheckGutter then
                    Inc(AWidth, vqThemeManager.MenuCheckSize.cx);
                // if CurrentHasImageGutter then
                //     Inc(AWidth, MenuImages.Width);
                Inc(AWidth, Spacing);
                with BackBmp.Canvas do begin
                    Font := FSeparatorFont;
                    Str := AItem.Caption;
                    if AItem.Caption = '' then
                        AHeight := TextHeight('Qq')
                    else
                        AHeight := TextHeight(Str);
                end;
            end
            else
                AHeight := vqThemeManager.MenuSeparatorThickness;
        end
        else with BackBmp.Canvas do begin
            Font := Self.Font;
            Str := AItem.Caption;
            
            if Str = '' then
                SzT := TSize.Create(0, TextExtent('Qq').cy)
            else
                SzT := TextExtent(Str);
            
            AWidth := SzT.cx;
            AHeight := SzT.cy;
            
            if CurrentHasCheckGutter then begin
                Inc(AWidth, vqThemeManager.MenuCheckSize.cx);
                AHeight := Max(AHeight, vqThemeManager.MenuCheckSize.cy);
            end;
            if CurrentHasImageGutter then begin
                Inc(AWidth, MenuImages.Width);
                AHeight := Max(AHeight, MenuImages.Height);
            end;
            Inc(AWidth, Spacing);
            
        end;
    end;
end;

end.
