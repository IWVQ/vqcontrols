// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqPageControl;

interface

uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Classes, Types, SysUtils, Controls, Graphics, Math, ExtCtrls,
    ComCtrls, Menus, ImgList, ActnList, Dialogs, Forms, Buttons,
    vqUtils, vqThemes, vqArrow, vqQuickButton;
    
type
    
    TvqPageSheet = class;
    TvqPageControl = class;
    
    TvqStateColorMethod = function(Sender: TObject; APage: TvqPageSheet; AState: Integer): TColor of object;
    TvqTabOption = (vqtoShowAddButton, vqtoShowCloseButtons,
        vqtoShowDropList, vqtoShowArrows, vqtoSeparateArrows, vqtoDragDrop);
    TvqTabOptions = set of TvqTabOption;
    
    TvqClosePageEvent = procedure(Sender: TObject; APage: TvqPageSheet; var ACanClose: Boolean) of object;
    TvqPageEvent = procedure(Sender: TObject; APage: TvqPageSheet) of object;
    TvqDrawTabEvent = procedure(Sender: TObject; ACanvas: TCanvas; ARect: TRect; APage: TvqPageSheet) of object;
    TvqTabPosition = tpTop .. tpBottom;
    
    
    
    TvqPageSheet = class(TvqCustomControl)
    private
        FVirtualTabRect: TRect;
        
        FOnStateChange: TNotifyEvent;
        FOnHide: TNotifyEvent;
        FOnShow: TNotifyEvent;
        FImageIndex: Integer;
        FState: Cardinal;
        FTabVisible: Boolean;
        
        FTabSize: TSize;
        
        FIndex: Integer;
        Flags: TPageFlags;
        procedure SetState(Value: Cardinal);
        procedure SetImageIndex(Value: Integer);
        procedure SetIndex(Value: Integer);
        procedure SetTabVisible(Value: Boolean);
        
        function GetTabWidth: Integer;
        function GetTabHeight: Integer;
    protected                          
        procedure UpdateMetrics; override;
        procedure CalculateTabSize;
        procedure CMHitTest(var Message: TLMNCHITTEST); message CM_HITTEST;
        function DialogChar(var Message: TLMKey): Boolean; override;
        procedure SetParent(AParent: TWinControl); override;
        procedure ColorChanged; override;
        procedure TextChanged; override;
        procedure FontChanged; override;
        procedure EnabledChanged; override;
        procedure VisibleChanged; override;
        procedure Paint; override;
        procedure DoHide; virtual;
        procedure DoShow; virtual;
        procedure DoStateChanged; virtual;  
        function TabPadding: TRect;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        property Controls;
        property Index: Integer read FIndex write SetIndex;
        property Visible;
        property State: Cardinal read FState write SetState;
        property TabWidth: Integer read GetTabWidth;
        property TabHeight: Integer read GetTabHeight;
    published
        property Color;
        property Caption;
        property TabVisible: Boolean read FTabVisible write SetTabVisible;
        property ImageIndex: Integer read FImageIndex write SetImageIndex;
        property Enabled;
        property Font;
        property Left stored False;
        property Top stored False;
        property Width stored False;
        property Height stored False;
        property TabOrder stored False;
        
        property OnStateChange: TNotifyEvent read FOnStateChange write FOnStateChange;
        property OnShow: TNotifyEvent read FOnShow write FOnShow;
        property OnHide: TNotifyEvent read FOnHide write FOnHide;
    end;
    
    TvqPageList = class
    private
        FPageControl: TvqPageControl;
        FList: TObjectArray;
        FCount :Integer;
        
        FMaxTabHeight: Integer;
        FVirtualAddTabRect: TRect;
        function GetItem(AIndex: Integer): TvqPageSheet;
        procedure UpdateRoom;
        procedure MoveSublist(AFrom, ATo, ACount: Integer);
    protected
        procedure CalculateMetrics;
    public
        constructor Create(APageControl: TvqPageControl); virtual;
        destructor Destroy; override;
        
        procedure Insert(APage: TvqPageSheet; AIndex: Integer);
        procedure Remove(var APage: TvqPageSheet; AIndex: Integer);
        procedure Move(APage: TvqPageSheet; AIndex: Integer);
        procedure Clear;
        property Count: Integer read FCount;
        property Item[AIndex: Integer]: TvqPageSheet read GetItem; default;
    end;
    
const
    VQ_PAGECONTROL_ADD_BUTTON_TAB = -2;
    VQ_PAGECONTROL_INVALID_TAB = -1;
    
type
    
    { TvqPageControl }

    TvqPageControl = class(TvqCustomControl)
    private
        FCanDrawFocus: Boolean;
        FBackBmp: TBitmap;
        FItems: TvqPageList;
        
        FLastVisibleTab: Integer;
        FFirstVisibleTab: Integer;
        FMaxFirstVisibleTab: Integer;
        FHotTab: Integer;
        FPressedTab: Integer;
        FMouseInClose: Boolean;
        
        FArrowUp, FArrowDown: TvqControlArrow;
        FDropButton: TvqCustomQuickButton;
        FCanStartDrag: Boolean;
        FDraggingTab: Boolean;
        FDragStartPoint: TPoint;
        FDropListMenu: TPopupMenu;
        
        FPageIndex: Integer;
        FTabPosition: TvqTabPosition;
        FTextFormat: TvqTextFormat;
        FLayout: TvqGlyphLayout;
        FImages: TImageList;
        FImageChangeLink: TChangeLink;
        FLeftSpacing: Integer;
        FRightSpacing: Integer;
        FOptions: TvqTabOptions;
        FTabWidth: Integer;
        FTabHeight: Integer;
        FStateColor: TvqStateColorMethod;
        
        FOnSelChange: TNotifyEvent;
        FOnAddBtnClick: TNotifyEvent;
        FOnCloseBtnClick: TvqPageEvent;
        FOnDrawTab: TvqDrawTabEvent;
        
        FHeaderArea: TRect;
        FBodyArea: TRect;
        FTabArea: TRect;
        procedure SetPage(AIndex: Integer; Value: TvqPageSheet);
        function GetPage(AIndex: Integer): TvqPageSheet;
        function GetActivePage: TvqPageSheet;
        procedure SetActivePage(Value: TvqPageSheet);
        procedure SetPageIndex(Value: Integer);
        procedure SetFirstVisibleTab(Value: Integer);
        procedure SetLayout(Value: TvqGlyphLayout);
        procedure SetFormat(Value: TvqTextFormat);
        procedure SetStateColor(Value: TvqStateColorMethod);
        procedure SetImages(Value: TImageList);
        procedure SetLeftSpacing(Value: Integer);
        procedure SetRightSpacing(Value: Integer);
        procedure SetTabPosition(Value: TvqTabPosition);
        procedure SetTabWidth(Value: Integer);
        procedure SetTabHeight(Value: Integer);
        procedure SetOptions(Value: TvqTabOptions);
        
        procedure InternalSetPageIndex(Value: Integer);
        procedure InternalSetFirstVisibleTab(Value: Integer);
        procedure SetControlState(APressedTab, AHotTab: Integer; AMouseInClose: Boolean);
                                                    
        procedure OnTextFormatChange(Sender: TObject);
        procedure OnImagesChange(Sender: TObject);
        procedure OnArrow(Sender: TObject; Pos: Integer; Forward: Boolean);
        
        procedure CNKeyDown(var Message: TLMKeyDown); message CN_KEYDOWN;
		procedure CNKeyUp(var Message: TLMKeyUp); message CN_KEYUP;
        
        function CalculateFirstVisibleTab(AActiveIndex: Integer): Integer;
        function CalculateLastVisibleTab(AFirstIndex: Integer): Integer;
        
        procedure DropListPrepare(Sender: TObject; var Caller: TControl);
        procedure DropListCloseUp(Sender: TObject);


        procedure CloseDropListMenu;
    protected
        FCaptionRenderer: TvqCaptionRenderer;
    protected
        FCaptionRenderingPage: TvqPageSheet;
        function GlyphSize(AArea: TRect): TSize; virtual;
        function CaptionArea(APage: TvqPageSheet; ATabRect: TRect): TRect; virtual;
        procedure DrawGlyph(AArea, ARect: TRect); virtual;
        function IsInternalControl(AControl: TControl): Boolean; override;
    protected
        const DefaultTabOptions = [vqtoShowAddButton, vqtoShowCloseButtons,
            vqtoShowArrows, vqtoShowDropList];
        
        procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
        procedure DragDrop(Source: TObject; X, Y: Integer); override;
        
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure MouseEnter; override;
		procedure MouseLeave; override;
		procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure KeyUp(var Key: Word; Shift: TShiftState); override;
        function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
       
        procedure DoCloseButtonClick(APage: TvqPageSheet); virtual;
        procedure DoAddButtonClick; virtual;
        procedure DoSelChange; virtual;
        procedure DoDrawTab(ACanvas: TCanvas; ARect: TRect; APage: TvqPageSheet); virtual;
        function DoStateColor(APage: TvqPageSheet): TColor; virtual;

        procedure CNDropDownClosed(var Message: TLMessage); message CN_DROPDOWNCLOSED;
        procedure Notification(AComponent: TComponent; Operation: TOperation); override;
        procedure ColorChanged; override;
        procedure FocusChanged(AFocused: Boolean); override;
        procedure EnabledChanged; override;
        procedure VisibleChanged; override;
        procedure CancelMode; override;
        procedure FontChanged; override;
		procedure Resize; override;
        procedure UpdateMetrics; override;
        procedure Paint; override;
        
        procedure UpdateScroll; virtual;
        function NextTab(ATab: Integer): Integer;
        function PrevTab(ATab: Integer): Integer;
        function FirstTab: Integer;
        function LastTab: Integer;
        function ArrowButtonSize: TSize; virtual;
        function DropButtonSize: TSize; virtual;
        function AddTabSize: TSize; virtual;

        function PageBoundsRect(AIndex: Integer): TRect;
        function PageTabRect(AIndex: Integer): TRect;
        function PageCloseRect(AIndex: Integer): TRect;
        function AddTabRect: TRect;
        
        class function GetControlClassDefaultSize: TSize; override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure MovePage(APage: TvqPageSheet; AIndex: Integer);
        procedure InsertPage(APage: TvqPageSheet; AIndex: Integer);
        function RemovePage(AIndex: Integer): TvqPageSheet;
        procedure CloseAll;
        
        procedure ClosePage(AIndex: Integer);
        function AddPage(AActive: Boolean = False): TvqPageSheet;
        function PageCount: Integer;
        
        function TabFromPoint(P: TPoint): Integer;
        property Page[AIndex: Integer]: TvqPageSheet read GetPage write SetPage;
        property FirstVisibleTab: Integer read FFirstVisibleTab write SetFirstVisibleTab;
    published
        property ActivePage: TvqPageSheet read GetActivePage write SetActivePage;
        property PageIndex: Integer read FPageIndex write SetPageIndex;
        property Options: TvqTabOptions read FOptions write SetOptions;
        property TextFormat: TvqTextFormat read FTextFormat write SetFormat;
        property Layout: TvqGlyphLayout read FLayout write SetLayout;
        property Images: TImageList read FImages write SetImages;
        property LeftSpacing: Integer read FLeftSpacing write SetLeftSpacing;
        property RightSpacing: Integer read FRightSpacing write SetRightSpacing;
        property TabPosition: TvqTabPosition read FTabPosition write SetTabPosition;
        property TabWidth: Integer read FTabWidth write SetTabWidth;
        property TabHeight: Integer read FTabHeight write SetTabHeight;
        
        property StateColor: TvqStateColorMethod read FStateColor write SetStateColor;
        property OnSelChange: TNotifyEvent read FOnSelChange write FOnSelChange;

        property OnCloseBtnClick: TvqPageEvent read FOnCloseBtnClick write FOnCloseBtnClick;
        property OnAddBtnClick: TNotifyEvent read FOnAddBtnClick write FOnAddBtnClick;

        property OnDrawTab: TvqDrawTabEvent read FOnDrawTab write FOnDrawTab;
    end;

const
    WPARAM_DROP_LIST_MENU = 1;
    
implementation

{ TvqPageSheet }

constructor TvqPageSheet.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    ControlStyle := ControlStyle + [csAcceptsControls, csReplicatable{//#}, csNoFocus,
        csParentBackground, csCaptureMouse, csClickEvents, csDoubleClicks]
        - [csOpaque];
    FImageIndex := -1;
    FState := 0;
    FIndex := -1;
    Flags := [];
    FTabSize := TSize.Zero;
    FTabVisible := True;
    Visible := False;
end;

destructor TvqPageSheet.Destroy;
begin
    inherited Destroy;
end;

procedure TvqPageSheet.SetState(Value: Cardinal);
begin
    if FState <> Value then begin
        FState := Value;
        DoStateChanged;
    end;
end;

procedure TvqPageSheet.SetIndex(Value: Integer);
begin
    if Parent is TvqPageControl then
        TvqPageControl(Parent).MovePage(Self, Value);
end;

procedure TvqPageSheet.SetImageIndex(Value: Integer);
begin
    if FImageIndex <> Value then begin
        FImageIndex := Value;
        UpdateMetrics;
    end;
end;

procedure TvqPageSheet.ColorChanged;
begin
    inherited;
    Invalidate;
end;

procedure TvqPageSheet.TextChanged;
begin
    inherited;
    UpdateMetrics;
end;

procedure TvqPageSheet.FontChanged;
begin
    inherited;
    UpdateMetrics;
end;

procedure TvqPageSheet.EnabledChanged;
begin
    inherited;
    if Parent is TvqPageControl then begin
        if TvqPageControl(Parent).PageIndex = Index then
            TvqPageControl(Parent).PageIndex := VQ_PAGECONTROL_INVALID_TAB;
        TvqPageControl(Parent).Invalidate;
    end;
end;

procedure TvqPageSheet.VisibleChanged;
begin
    inherited;
end;

procedure TvqPageSheet.SetTabVisible(Value: Boolean);
begin
    if FTabVisible <> Value then begin
        FTabVisible := Value;
        UpdateMetrics;
    end;
end;

procedure TvqPageSheet.DoHide;
begin
    if Assigned(FOnHide) then FOnHide(Self);
end;

procedure TvqPageSheet.DoShow;
begin
    if Assigned(FOnShow) then FOnShow(Self);
end;

procedure TvqPageSheet.CMHitTest(var Message: TLMNCHITTEST);
begin
    if Parent is TvqPageControl and (TvqPageControl(Parent).ActivePage <> Self) then
        Message.Result := 0
    else inherited CMHitTest(Message);
end;

function TvqPageSheet.DialogChar(var Message: TLMKey): Boolean;
begin
    if not (csDesigning in ComponentState) and IsAccel(Message.CharCode, Caption)
        then begin
        Result := True;
        if Parent is TvqPageControl then
            TvqPageControl(Parent).PageIndex := Index
    end
    else Result := inherited DialogChar(Message);
end;

procedure TvqPageSheet.SetParent(AParent: TWinControl);
var
    PrevParent: TWinControl;
begin //#
    if Parent = AParent then Exit;
    PrevParent := Parent;
    if (Parent <> AParent) and (Parent is TvqPageControl) and
        not (pfRemoving in Flags) then
        TvqPageControl(Parent).RemovePage(FIndex);
    inherited SetParent(AParent);
    if (PrevParent <> Parent) and (Parent is TvqPageControl)and
        not (pfInserting in Flags) then
        TvqPageControl(Parent).InsertPage(Self, FIndex);
end;

function TvqPageSheet.TabPadding: TRect;  
var
    APageControl: TvqPageControl;
begin
    Result := Rect(0, 0, 10000, 10000); // so big rect
    if Parent is TvqPageControl then begin
        APageControl := TvqPageControl(Parent);
        Result := vqThemeManager.TabContentRect(Self,
            vqtoShowCloseButtons in APageControl.Options, Result);
    end;
    Result.Right := 10000 - Result.Right;
    Result.Bottom := 10000 - Result.Bottom;
end;

procedure TvqPageSheet.CalculateTabSize;
var
    APageControl: TvqPageControl;
    Sz: TSize;
    Padding: TRect;
begin
    if Parent is TvqPageControl then begin
        APageControl := TvqPageControl(Parent);
        
        APageControl.FCaptionRenderingPage := Self;
        APageControl.FCaptionRenderer.Area := Rect(0, 0, 1000, 1);
        
        Sz := APageControl.FCaptionRenderer.
            TextExtent(Caption, nil, APageControl.Images, FImageIndex, APageControl.Layout, 
                APageControl.Spacing, vqTextHorizontal);
        APageControl.FCaptionRenderingPage := nil;
        
        Padding := TabPadding;
        with Padding do begin
            FTabSize.cx := Left + Sz.cx + Right;
            FTabSize.cy := Top + Sz.cy + Bottom;
        end;
    end
    else
        FTabSize := TSize.Zero;
end;

function TvqPageSheet.GetTabWidth: Integer;
var
    PageControl: TvqPageControl;
begin
    if Parent is TvqPageControl then
        Result := FVirtualTabRect.Width
    else Result := 0;
end;

function TvqPageSheet.GetTabHeight: Integer;
var
    PageControl: TvqPageControl;
begin
    if Parent is TvqPageControl then
        Result := FVirtualTabRect.Height
    else Result := 0;
end;

procedure TvqPageSheet.DoStateChanged;
begin
    if Assigned(FOnStateChange) then FOnStateChange(Self);
end;

procedure TvqPageSheet.UpdateMetrics;
begin
    CalculateTabSize;
    if Parent is TvqPageControl then
        TvqPageControl(Parent).UpdateMetrics;
    inherited;
end;

procedure TvqPageSheet.Paint;
begin
    with Canvas do begin
        if Color = clDefault then
            FullBrush(clNone)
        else
            FullBrush(Color);
        FillRect(ClientRect);
    end;
    inherited;
end;

{ TvqPageList }

constructor TvqPageList.Create(APageControl: TvqPageControl);
begin
    FPageControl := APageControl;
    FCount := 0;
    FList := nil;
end;

destructor TvqPageList.Destroy;
begin
    Clear;
    inherited;
end;

procedure TvqPageList.MoveSublist(AFrom, ATo: Integer; ACount: Integer);
var
    I: Integer;
begin
    if AFrom < ATo then
        for I := ACount - 1 downto 0 do begin
            FList[I + ATo] := FList[I + AFrom];
            TvqPageSheet(FList[I + ATo]).FIndex := I + ATo;
        end
    else
        for I := 0 to ACount - 1 do begin
            FList[I + ATo] := FList[I + AFrom];
            TvqPageSheet(FList[I + ATo]).FIndex := I + ATo;
        end;
end;

procedure TvqPageList.Insert(APage: TvqPageSheet; AIndex: Integer);
begin
    if not((AIndex >= 0) and (AIndex <= FCount) and (APage <> nil)) then Exit;
    UpdateRoom;
    
    if AIndex < FCount then
        MoveSublist(AIndex, AIndex + 1, FCount - AIndex);
    FList[AIndex] := APage;
    APage.FIndex := AIndex;
    Inc(FCount);     
    APage.CalculateTabSize;
    
    CalculateMetrics;
end;

procedure TvqPageList.Remove(var APage: TvqPageSheet; AIndex: Integer);
begin
    APage := nil;
    if (AIndex >= 0) and (AIndex < FCount) then begin
        
        if FList[AIndex] <> nil then begin
            APage := TvqPageSheet(FList[AIndex]);
            APage.FIndex := -1;
        end;
        FList[AIndex] := nil;
        if AIndex < FCount - 1 then
            MoveSublist(AIndex + 1, AIndex, FCount - AIndex - 1);
        Dec(FCount);
        
        UpdateRoom;
        
        CalculateMetrics;
    end;
end;

procedure TvqPageList.Move(APage: TvqPageSheet; AIndex: Integer);
var
    I: Integer;
begin
    if (APage <> nil) and (AIndex >= 0) and (AIndex <= FCount) and 
        (APage.Parent = FPageControl) and (APage.Index <> AIndex) then begin
        
        I := APage.Index;
        FList[I] := nil;
        if AIndex > I then 
            MoveSublist(I + 1, I, AIndex - I)
        else
            MoveSublist(AIndex, AIndex + 1, I - AIndex);
        FList[AIndex] := APage;
        APage.FIndex := AIndex;
        
        CalculateMetrics;
    end;
end;

procedure TvqPageList.Clear;
var
    I: Integer;
begin
    for I := 0 to FCount - 1 do
        if FList[I] <> nil then FList[I].Free;
    FList := nil;
    FCount := 0;
end;

function TvqPageList.GetItem(AIndex: Integer): TvqPageSheet;
begin
    if (AIndex >= 0) and (AIndex < FCount) then
        Result := TvqPageSheet(FList[AIndex])
    else
        Result := nil;
end;

procedure TvqPageList.UpdateRoom;
var
    L: Integer;
begin
    L := ((FCount div 8) + 1)*8;
    if L <> Length(FList) then
        SetLength(FList, L);
end;

procedure TvqPageList.CalculateMetrics;
var
    APage: TvqPageSheet;
    X, TabW, TabH, I: Integer;
begin
    FMaxTabHeight := 0;
    for I := 0 to FCount - 1 do begin
        APage := TvqPageSheet(FList[I]);
        if APage.TabVisible then
            TabH := APage.FTabSize.cy
        else
            TabH := 0;
        FMaxTabHeight := Max(FMaxTabHeight, TabH);
    end;
    if FPageControl.TabHeight > 0 then
        FMaxTabHeight := FPageControl.TabHeight;
    
    X := 0;
    for I := 0 to FCount - 1 do begin
        APage := TvqPageSheet(FList[I]);
        if APage.TabVisible then begin
            if FPageControl.TabWidth > 0 then
                TabW := FPageControl.TabWidth
            else
                TabW := APage.FTabSize.cx
        end
        else
            TabW := 0;
        APage.FVirtualTabRect := Classes.Bounds(X, 0, TabW, FMaxTabHeight);
        Inc(X, TabW);
    end;

    FVirtualAddTabRect := Classes.Bounds(X, 0, 
        FPageControl.AddTabSize.cx, FMaxTabHeight);
end;

{ TvqPageControl }

constructor TvqPageControl.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FBackBmp := TBitmap.Create;
    FBackBmp.Width := 10;
    FBackBmp.Height := 10;

    FItems := TvqPageList.Create(Self);
    FCanDrawFocus := False;
    
    FTabPosition := tpTop;
    FTextFormat := TvqTextFormat.Create(Self);
    FTextFormat.Alignment := taLeftJustify;
    FTextFormat.Layout := tlCenter;
    FTextFormat.Clipping := True;
    FTextFormat.OnChange := @OnTextFormatChange;
    
    FLayout := blGlyphLeft;
    FLeftSpacing := 0;
    FRightSpacing := 0;
    FPageIndex := -1;
    FOptions := DefaultTabOptions;
    FStateColor := nil;

    FCaptionRenderer := TvqCaptionRenderer.Create;
    FCaptionRenderer.Format := FTextFormat;
    FCaptionRenderer.Font := Font;
    FCaptionRenderer.Canvas := FBackBmp.Canvas;
    
    FCaptionRenderer.DrawGlyphMethod := @DrawGlyph;
    FCaptionRenderer.GlyphSizeMethod := @GlyphSize;
    FCaptionRenderer.OwnerDraw := False;
    FCaptionRenderingPage := nil;
    
    FTabWidth := 0;
    FTabHeight := 21;
    
    FImageChangeLink := TChangeLink.Create;
    FImageChangeLink.OnChange := @OnImagesChange;
    
    FArrowUp := TvqControlArrow.Create(Self);
    FArrowUp.Parent := Self;
    FArrowDown := TvqControlArrow.Create(Self);
    FArrowDown.Parent := Self;
    FDropButton := TvqCustomQuickButton.Create(Self);
    FDropButton.Parent := Self;
                                
    FDropListMenu := nil;
    FDropButton.OnPrepareDropDown := @DropListPrepare;
    FDropButton.OnCloseUp := @DropListCloseUp;
    FDropButton.Kind := vqqbkArrowBottom;

    FArrowUp.Visible := False;
    FArrowDown.Visible := False;
    FDropButton.Visible := False;     
    FArrowDown.Synchronize := FArrowUp;
    FArrowDown.OnArrow := @OnArrow;   
    FArrowDown.Direction := updDown;
    FArrowDown.Orientation := udHorizontal;
    FArrowUp.Direction := updUp;
    FArrowUp.Orientation := udHorizontal;
    
    FLastVisibleTab := 0;
    FFirstVisibleTab := 0;
    FMaxFirstVisibleTab := 0;
    FHotTab := -1;
    FPressedTab := -1;
    FMouseInClose := False;
    
    UpdateScroll;
end;

destructor TvqPageControl.Destroy;
var
    I: Integer;
    APage: TvqPageSheet;
begin
    for I := PageCount - 1 downto 0 do begin
        FItems.Remove(APage, I);
        APage.Flags := APage.Flags + [pfRemoving];
        APage.Parent := nil;
        APage.Flags := APage.Flags - [pfRemoving];
        APage := nil;
    end;
    FItems.Free;
    FTextFormat.Free;

    if FDropListMenu <> nil then 
        FreeAndNil(FDropListMenu);
    FreeAndNil(FArrowUp);
    FreeAndNil(FArrowDown);
    FreeAndNil(FDropButton);
    FImageChangeLink.Free;
    FCaptionRenderer.Free;
    inherited;
end;

class function TvqPageControl.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 200;
    Result.cy := 200;
end;

procedure TvqPageControl.MovePage(APage: TvqPageSheet; AIndex: Integer);
var
    PrevIndex: Integer;
begin
    if APage = nil then Exit;
    if (APage.Parent = Self) and (AIndex >= 0) and (AIndex <= PageCount) then begin
        PrevIndex := APage.Index;
        FItems.Move(APage, AIndex);
        if FPageIndex = PrevIndex then 
            InternalSetPageIndex(AIndex);
        UpdateScroll;
    end;
end;

function TvqPageControl.RemovePage(AIndex: Integer): TvqPageSheet;
var
    APage, AActivePage: TvqPageSheet;
begin
    if (AIndex >= 0) and (AIndex < PageCount) then begin

        AActivePage := ActivePage;

        FItems.Remove(APage, AIndex);
        APage.Flags := APage.Flags + [pfRemoving];
        APage.Parent := nil;
        APage.Flags := APage.Flags - [pfRemoving];
                            
        UpdateScroll;

        if APage = AActivePage then begin
            InternalSetPageIndex(PageCount - 1);
            Invalidate;
        end
        else begin
            FPageIndex := AActivePage.Index;
            Invalidate;
        end;

        Result := APage;
    end
    else Result := nil;
end;

procedure TvqPageControl.InsertPage(APage: TvqPageSheet; AIndex: Integer);
var
    AActivePage: TvqPageSheet;
begin
    if APage = nil then Exit;
    if (AIndex >= 0) and (AIndex <= PageCount) then begin
        AActivePage := ActivePage;

        APage.Flags := APage.Flags + [pfInserting];  
        APage.Parent := Self;
        APage.Visible := False;
        FItems.Insert(APage, AIndex);
        APage.Flags := APage.Flags - [pfInserting];
                                            
        UpdateScroll;

        if (AActivePage = nil) or (pfAdding in APage.Flags) then begin
            InternalSetPageIndex(AIndex);
            Invalidate;
        end
        else begin
            FPageIndex := AActivePage.Index;
            Invalidate;
        end;

    end;
end;

procedure TvqPageControl.CloseAll;
var
    APage: TvqPageSheet;
    I: Integer;
    ACanClose: Boolean;
begin //#
    if PageCount = 0 then Exit;
    for I := PageCount - 1 downto 0 do begin
        FItems.Remove(APage, I);
        APage.Flags := APage.Flags + [pfRemoving];
        APage.Parent := nil;
        APage.Flags := APage.Flags - [pfRemoving];
        APage.Free;
    end;
    
    FHotTab := -1;
    FPressedTab := -1;
    FPageIndex := -1;
    UpdateScroll;
end;

procedure TvqPageControl.ClosePage(AIndex: Integer);
var
    APage: TvqPageSheet;
    ACanClose: Boolean;
begin
    if (AIndex >= 0) and (AIndex < PageCount) then begin
        APage := RemovePage(AIndex);
        APage.Free;
    end;
end;

function TvqPageControl.AddPage(AActive: Boolean = False): TvqPageSheet;
var
    NewPage: TvqPageSheet;
begin
    NewPage := TvqPageSheet.Create(Owner);
    if AActive then NewPage.Flags := NewPage.Flags + [pfAdding];
    InsertPage(NewPage, PageCount);
    if AActive then NewPage.Flags := NewPage.Flags - [pfAdding];
    Result := NewPage;
end;

function TvqPageControl.PageCount: Integer;
begin
    Result := FItems.Count;
end;

procedure TvqPageControl.InternalSetPageIndex(Value: Integer);
var
    PrevPageIndex: Integer;
    R: TRect;
begin
    if (Value >= 0) and (Value < PageCount) and
        ((not FItems[Value].TabVisible) or (not FItems[Value].Enabled)) then
        Exit; // no changes
    if PageCount = 0 then Value := VQ_PAGECONTROL_INVALID_TAB;
    if (Value < VQ_PAGECONTROL_INVALID_TAB) or (Value >= PageCount) then
        Exit;
    
    PrevPageIndex := FPageIndex;
    FPageIndex := Value;
    if (PrevPageIndex <> VQ_PAGECONTROL_INVALID_TAB) and
        (PrevPageIndex < PageCount) then begin
        FItems[PrevPageIndex].Visible := False;
        FItems[PrevPageIndex].DoHide;
    end;
    if FPageIndex <> VQ_PAGECONTROL_INVALID_TAB then begin
        FItems[FPageIndex].BoundsRect := PageBoundsRect(FPageIndex);
        FItems[FPageIndex].Visible := True;
        FItems[FPageIndex].DoShow;
    end;
    InternalSetFirstVisibleTab(CalculateFirstVisibleTab(FPageIndex));
end;

procedure TvqPageControl.InternalSetFirstVisibleTab(Value: Integer);
begin
    if Value < 0 then Value := 0;
    if Value > FMaxFirstVisibleTab then Value := FMaxFirstVisibleTab;
    FFirstVisibleTab := Value;
    FLastVisibleTab := CalculateLastVisibleTab(FFirstVisibleTab);
    if (vqtoShowArrows in FOptions) and (PageCount > 0) then
        FArrowDown.SetParams(FFirstVisibleTab, 0, FMaxFirstVisibleTab, 0);
end;

procedure TvqPageControl.SetPageIndex(Value: Integer);
begin
    if Value < -1 then Value := -1;
    if Value >= PageCount then Value := PageCount - 1;
    if FPageIndex <> Value then begin
        InternalSetPageIndex(Value);
        Invalidate;
    end;
end;

procedure TvqPageControl.SetFirstVisibleTab(Value: Integer);
begin
    if FFirstVisibleTab <> Value then begin
        InternalSetFirstVisibleTab(Value);
        Repaint;
    end;
end;

procedure TvqPageControl.SetOptions(Value: TvqTabOptions);
begin
    if FOptions <> Value then begin
        FOptions := Value;
        UpdateMetrics;
    end;
end;    

function TvqPageControl.GetActivePage: TvqPageSheet;
begin
    if FPageIndex >= 0 then Result := FItems[FPageIndex]
    else Result := nil;
end;

procedure TvqPageControl.SetActivePage(Value: TvqPageSheet);
begin
    if Value = nil then SetPageIndex(-1)
    else if Value.Parent = Self then SetPageIndex(Value.Index);
end;

procedure TvqPageControl.SetLayout(Value: TvqGlyphLayout);
begin
    if FLayout <> Value then begin
        FLayout := Value;
        UpdateMetrics;
    end;
end;

procedure TvqPageControl.SetFormat(Value: TvqTextFormat);
begin
    FTextFormat.Assign(Value);
end;

procedure TvqPageControl.SetStateColor(Value: TvqStateColorMethod);
begin
    FStateColor := Value;
    UpdateMetrics;
end;

procedure TvqPageControl.SetImages(Value: TImageList);
begin
    if FImages <> Value then begin
        if FImages <> nil then begin
            FImages.UnRegisterChanges(FImageChangeLink);
            FImages.RemoveFreeNotification(Self);
        end;
        FImages := Value;
        if FImages <> nil then begin
            FImages.FreeNotification(Self);
            FImages.RegisterChanges(FImageChangeLink);
        end;
        UpdateMetrics;
    end;
end;

procedure TvqPageControl.SetLeftSpacing(Value: Integer);
begin
    if FLeftSpacing <> Value then begin
        FLeftSpacing := Value;
        UpdateMetrics;
    end;
end;

procedure TvqPageControl.SetRightSpacing(Value: Integer);
begin
    if FRightSpacing <> Value then begin
        FRightSpacing := Value;
        UpdateMetrics;
    end;
end;

procedure TvqPageControl.SetTabPosition(Value: TvqTabPosition);
begin
    if FTabPosition <> Value then begin
        FTabPosition := Value;
        UpdateMetrics;
    end;
end;

procedure TvqPageControl.SetTabWidth(Value: Integer);
begin
    if FTabWidth <> Value then begin
        FTabWidth := Value;
        UpdateMetrics;
    end;
end;

procedure TvqPageControl.SetTabHeight(Value: Integer);
begin
    if FTabHeight <> Value then begin
        FTabHeight := Value;
        UpdateMetrics;
    end;
end;

function TvqPageControl.GetPage(AIndex: Integer): TvqPageSheet;
begin
    Result := FItems[AIndex];
end;

procedure TvqPageControl.SetPage(AIndex: Integer; Value: TvqPageSheet);
begin //# experimental
    if Value = nil then Exit;
    if (AIndex >= 0) and (AIndex < PageCount) then begin
        if Value.Parent = Self then
            MovePage(Value, AIndex)
        else begin
            RemovePage(AIndex);
            InsertPage(Value, AIndex);
        end;
    end;
end;

procedure TvqPageControl.OnImagesChange(Sender: TObject);
begin
    if Sender = FImages then UpdateMetrics;
end;

procedure TvqPageControl.OnArrow(Sender: TObject; Pos: Integer; Forward: Boolean);
begin
    SetFirstVisibleTab(Pos);
end;

procedure TvqPageControl.OnTextFormatChange(Sender: TObject);
begin
    UpdateMetrics;
end;

procedure TvqPageControl.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
    Tab: Integer;
begin
    inherited DragOver(Source, X, Y, State, Accept);
    if Source is TvqPageControl then begin
        Accept := True;
        Tab := TabFromPoint(Point(X, Y));
        if Source = Self then MovePage(ActivePage, Tab);
    end;
end;

procedure TvqPageControl.DragDrop(Source: TObject; X, Y: Integer);
var
    Other: TvqPageControl;
    Tab: Integer;
begin
    if Source is TvqPageControl then begin
        Other := TvqPageControl(Source);
        Tab := TabFromPoint(Point(X, Y));
        if Other = Self then MovePage(ActivePage, Tab)
        else InsertPage(Other.ActivePage, Tab);
    end;
    inherited DragDrop(Source, X, Y);
end;

procedure TvqPageControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    P: TPoint;
    DragDropEnabled, InClose: Boolean;
    Tab: Integer;
begin
    inherited MouseDown(Button, Shift, X, Y);
    if Button = mbLeft then begin
        P := Point(X, Y);
        Tab := TabFromPoint(P);
        FCanDrawFocus := False;
        if (Tab <> VQ_PAGECONTROL_INVALID_TAB) then begin
            InClose := (Tab >= 0) and PtInRect(PageCloseRect(Tab), P);
            SetControlState(Tab, Tab, InClose);
            DragDropEnabled := True;
            if FMouseInClose or (Tab = VQ_PAGECONTROL_ADD_BUTTON_TAB) then
                DragDropEnabled := False
            else if (not FItems[Tab].Enabled) or (not FItems[Tab].TabVisible) then
                DragDropEnabled := False
            else
                SetPageIndex(Tab);
            if (vqtoDragDrop in FOptions) and DragDropEnabled then begin
                FCanStartDrag := True;
                FDragStartPoint := P;
            end;
        end
        else begin
            FMouseInClose := False;
            FCanStartDrag := False;
        end;
    end;
end;

procedure TvqPageControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    P: TPoint;
    Tab: Integer;
    InClose: Boolean;
begin
    inherited MouseUp(Button, Shift, X, Y);
    if Button = mbLeft then begin
        P := Point(X, Y);

        FCanStartDrag := False;
        FDraggingTab := False;
        
        if FPressedTab = VQ_PAGECONTROL_ADD_BUTTON_TAB then
            DoAddButtonClick;
        if (FPressedTab <> VQ_PAGECONTROL_INVALID_TAB) and FMouseInClose then
            DoCloseButtonClick(FItems[FPressedTab]);

        Tab := TabFromPoint(P);
        InClose := (Tab >= 0) and PtInRect(PageCloseRect(Tab), P);
        SetControlState(VQ_PAGECONTROL_INVALID_TAB, Tab, InClose);
    end;
end;

procedure TvqPageControl.MouseEnter;
begin
    inherited;
end;

procedure TvqPageControl.MouseLeave;
begin
    inherited;
    FCanStartDrag := False;
    FDraggingTab := False;
    SetControlState(VQ_PAGECONTROL_INVALID_TAB, VQ_PAGECONTROL_INVALID_TAB, False);
end;

procedure TvqPageControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
    P: TPoint;
    Tab: Integer;
    InClose: Boolean;
begin
    inherited MouseMove(Shift, X, Y);
    
    P := Point(X, Y);
    if Dragging then begin end
    else if FCanStartDrag and (ssLeft in Shift) and
        ((Abs(FDragStartPoint.X - X) > 5) or (Abs(FDragStartPoint.Y - Y) > 5)) then begin
        FDraggingTab := True;
        BeginDrag(True);
    end
    else if FPressedTab = VQ_PAGECONTROL_INVALID_TAB then begin
        Tab := TabFromPoint(P);
        InClose := (Tab >= 0) and PtInRect(PageCloseRect(Tab), P);
        SetControlState(VQ_PAGECONTROL_INVALID_TAB, Tab, InClose);
    end;
end;

procedure TvqPageControl.KeyDown(var Key: Word; Shift: TShiftState);
begin
    if FPageIndex <> VQ_PAGECONTROL_INVALID_TAB then begin
        FCanDrawFocus := True;
        case Key of
            VK_LEFT: 
                if FTabPosition in [tpTop, tpBottom] then
                    SetPageIndex(PrevTab(FPageIndex));
            VK_RIGHT:
                if FTabPosition in [tpTop, tpBottom] then
                    SetPageIndex(NextTab(FPageIndex));
            VK_UP:
                {if FTabPosition in [tpLeft, tpRight] then
                    SetPageIndex(PrevTab(FPageIndex))};
            VK_DOWN:
                {if FTabPosition in [tpLeft, tpRight] then
                    SetPageIndex(NextTab(FPageControl))};
            VK_END: 
                SetPageIndex(LastTab);
            VK_HOME:
                SetPageIndex(FirstTab);
        end;
    end;
    inherited KeyDown(Key, Shift);
    case Key of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN, VK_END, VK_HOME: 
            Key := 0;
	end;
end;

procedure TvqPageControl.KeyUp(var Key: Word; Shift: TShiftState);
begin
    inherited KeyUp(Key, Shift);
	case Key of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN, VK_END, VK_HOME:
            Key := 0;
	end;
end;

function TvqPageControl.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
    Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
    if not Result then begin
        FCanDrawFocus := False;
        case Sign(WheelDelta) of
            -1: SetPageIndex(NextTab(FPageIndex));
            0:;
            1: SetPageIndex(PrevTab(FPageIndex));
        end;
        Result := True;
    end;
end;

procedure TvqPageControl.CNKeyDown(var Message: TLMKeyDown);
begin
    case Message.CharCode of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN:;
		else inherited;
	end;
end;

procedure TvqPageControl.CNKeyUp(var Message: TLMKeyUp);
begin
    case Message.CharCode of
		VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN:;
		else inherited;
	end;
end;

procedure TvqPageControl.DoCloseButtonClick(APage: TvqPageSheet);
begin
    if Assigned(FOnCloseBtnClick) then FOnCloseBtnClick(Self, APage);
end;

procedure TvqPageControl.DoAddButtonClick;
begin
    if Assigned(FOnAddBtnClick) then FOnAddBtnClick(Self);
end;

procedure TvqPageControl.DoSelChange;
begin
    if Assigned(FOnSelChange) then FOnSelChange(Self);
end;

procedure TvqPageControl.DoDrawTab(ACanvas: TCanvas; ARect: TRect; APage: TvqPageSheet);
begin
    if Assigned(FOnDrawTab) then FOnDrawTab(Self, ACanvas, ARect, APage);
end;

function TvqPageControl.DoStateColor(APage: TvqPageSheet): TColor;
begin
    if Assigned(FStateColor) then Result := FStateColor(Self, APage, APage.State)
    else Result := clNone;
end;

procedure TvqPageControl.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if (AComponent is TvqPageSheet) and (TvqPageSheet(AComponent).Parent = Self) and (Operation = opRemove) then
        RemovePage(TvqPageSheet(AComponent).FIndex);
end;

procedure TvqPageControl.ColorChanged;
begin
    inherited;
    Invalidate;
end;

procedure TvqPageControl.FocusChanged(AFocused: Boolean);
begin
    inherited;
    if not AFocused then
        FCanDrawFocus := False;
    Invalidate;
end;

procedure TvqPageControl.EnabledChanged;
begin
    inherited;
    Invalidate;
end;

procedure TvqPageControl.VisibleChanged;
begin
    inherited;
end;

procedure TvqPageControl.CancelMode;
begin
    inherited;
end;

procedure TvqPageControl.FontChanged;
begin
    inherited;
    UpdateMetrics;
end;

procedure TvqPageControl.Resize;
begin
    inherited;
    if Parent <> nil then begin
        FBackBmp.Width := ClientWidth;
        FBackBmp.Height := ClientHeight;
        UpdateScroll;
    end;
end;

procedure TvqPageControl.UpdateMetrics;
begin
    FItems.CalculateMetrics;
    UpdateScroll;
    inherited;
end;

procedure TvqPageControl.DropListPrepare(Sender: TObject; var Caller: TControl);
var
    ItemCount, I: Integer;
    APage: TvqPageSheet;
    AItem: TMenuItem;
begin
    
    FDropListMenu := TPopupMenu.Create(Self);
    FDropListMenu.Images := Self.Images;
    
    ItemCount := PageCount;
    for I := 0 to ItemCount - 1 do begin
        APage := Page[I];
        
        AItem := TMenuItem.Create(FDropListMenu);
        with AItem do begin
            Caption := APage.Caption;
            Default := APage = ActivePage;
            Checked := APage = ActivePage;
            Enabled := APage.Enabled;
            Visible := APage.TabVisible;
            Hint    := APage.Hint;
            ImageIndex := APage.ImageIndex;

            GroupIndex := 1;
            RadioItem := True;
            AutoCheck := True;
            ShowAlwaysCheckable := True;
        end;
        FDropListMenu.Items.Add(AItem);
    end;
    FDropButton.DropDownMenu := FDropListMenu;
end;

procedure TvqPageControl.DropListCloseUp(Sender: TObject);
begin
    if FDropListMenu <> nil then
        PostMessage(Handle, CN_DROPDOWNCLOSED, WPARAM_DROP_LIST_MENU, 0);
end;
                           
procedure TvqPageControl.CNDropDownClosed(var Message: TLMessage);
begin
    if Message.WParam = WPARAM_DROP_LIST_MENU then
        CloseDropListMenu;
end;

procedure TvqPageControl.CloseDropListMenu;
var
    I: Integer;
begin
    for I := 0 to PageCount - 1 do begin
        if FDropListMenu.Items[I].Checked then
            SetPageIndex(I);
    end;
    FreeAndNil(FDropListMenu);
end;

procedure TvqPageControl.SetControlState(APressedTab, AHotTab: Integer; AMouseInClose: Boolean);
begin
    if (APressedTab <> FPressedTab) or (AHotTab <> FHotTab) or (AMouseInClose <> FMouseInClose) then begin
        if (APressedTab >= 0) and 
            ((not FItems[APressedTab].TabVisible) or (not FItems[APressedTab].Enabled)) then
            APressedTab := VQ_PAGECONTROL_INVALID_TAB;
        if (AHotTab >= 0) and 
            ((not FItems[AHotTab].TabVisible) or (not FItems[AHotTab].Enabled)) then
            AHotTab := VQ_PAGECONTROL_INVALID_TAB;
        if APressedTab <> VQ_PAGECONTROL_INVALID_TAB then
            AHotTab := APressedTab;
        if AHotTab = VQ_PAGECONTROL_INVALID_TAB then
            FMouseInClose := False;
        
        FPressedTab := APressedTab;
        FHotTab := AHotTab;
        FMouseInClose := AMouseInClose;
        Invalidate;
    end;
end;

procedure TvqPageControl.UpdateScroll;
var
    Client: TRect;
    ATotalWidth, AVisibleCount, I, ATotalHeight, WidthSum: Integer;
begin   
    
    if PageCount = 0 then begin
        FBodyArea := ClientRect;
        FHeaderArea := FBodyArea;
        if TabPosition = tpTop then
            FHeaderArea.Bottom := FBodyArea.Top
        else
            FHeaderArea.Top := FBodyArea.Bottom;
        FTabArea := FHeaderArea;
        FDropButton.Visible := False;
        FArrowDown.Visible := False;
        FArrowUp.Visible := False;
        FMaxFirstVisibleTab := 0;
        FFirstVisibleTab := 0;
        FLastVisibleTab := 0;
        Exit;
    end;
    
    // calculate the sum of tabwidth
    ATotalWidth := 0;
    AVisibleCount := 0;
    for I := 0 to PageCount - 1 do
        if Page[I].TabVisible then begin
            Inc(ATotalWidth, Page[I].TabWidth);
            Inc(AVisibleCount);
        end;
    if vqtoShowAddButton in FOptions then
        Inc(ATotalWidth, FItems.FVirtualAddTabRect.Width);
    
    // calculate HeaderArea, BodyArea and extended TabArea
    
    if TabHeight = 0 then
        ATotalHeight := FItems.FMaxTabHeight
    else
        ATotalHeight := TabHeight;
    Client := ClientRect;
    FBodyArea := Client;
    FHeaderArea := Client;
    if FTabPosition = tpTop then begin
        Inc(FBodyArea.Top, ATotalHeight);
        FHeaderArea.Bottom := FBodyArea.Top;
    end
    else begin
        Dec(FBodyArea.Bottom, ATotalHeight);
        FHeaderArea.Top := FBodyArea.Bottom;
    end;
    FTabArea := FHeaderArea;
    Inc(FTabArea.Left, FLeftSpacing);
    Dec(FTabArea.Right, FRightSpacing);
    
    // 
    
    if (AVisibleCount > 0) and (vqtoShowDropList in FOptions) then begin
        // show drop down button
        FDropButton.Visible := True;
        with FTabArea do begin
            FDropButton.SetBounds(Right - DropButtonSize.cx, Top, 
                DropButtonSize.cx, Height);
            Dec(Right, DropButtonSize.cx);
        end;
    end
    else
        FDropButton.Visible := False;
    
    if (ATotalWidth > FTabArea.Width) and (vqtoShowArrows in FOptions) then begin
        // show arrow buttons
        FArrowDown.Visible := True;
        FArrowUp.Visible := True;
        with FTabArea do
            if vqtoSeparateArrows in FOptions then begin
                FArrowUp.SetBounds(Right - ArrowButtonSize.cx, Top, ArrowButtonSize.cx, Height);
                FArrowDown.SetBounds(Left, Top, ArrowButtonSize.cx, Height);
                Inc(Left, ArrowButtonSize.cx);
                Dec(Right, ArrowButtonSize.cx);
            end
            else begin
                FArrowUp.SetBounds(Right - ArrowButtonSize.cx, Top, ArrowButtonSize.cx, Height);
                FArrowDown.SetBounds(Right - 2*ArrowButtonSize.cx, Top, ArrowButtonSize.cx, Height);
                Dec(Right, ArrowButtonSize.cx);
                Dec(Right, ArrowButtonSize.cx);
            end;
    end
    else begin
        FArrowDown.Visible := False;
        FArrowUp.Visible := False;
    end;
    
    // calculate max first visible tab
    
    FMaxFirstVisibleTab := PageCount;
    WidthSum := 0;
    if vqtoShowAddButton in Options then
        Inc(WidthSum, AddTabSize.cx);
    while (FMaxFirstVisibleTab >= 0) and (WidthSum <= FTabArea.Width) do begin
        Dec(FMaxFirstVisibleTab);
        if (FMaxFirstVisibleTab >= 0) and Page[FMaxFirstVisibleTab].TabVisible then
            Inc(WidthSum, Page[FMaxFirstVisibleTab].TabWidth);
    end;
    if FMaxFirstVisibleTab < 0 then FMaxFirstVisibleTab := 0
    else Inc(FMaxFirstVisibleTab);
    if (FMaxFirstVisibleTab = PageCount) and (PageCount > 0) then
        FMaxFirstVisibleTab := PageCount - 1;
    
    // calculate visible tabs range
    
    if FFirstVisibleTab > FMaxFirstVisibleTab then
        FFirstVisibleTab := CalculateFirstVisibleTab(FPageIndex);
    FLastVisibleTab := CalculateLastVisibleTab(FFirstVisibleTab);

    Invalidate;
end;

function TvqPageControl.CalculateFirstVisibleTab(AActiveIndex: Integer): Integer;
var
    WidthSum: Integer;
begin
    if PageCount = 0 then begin
        Result := 0;
        Exit;
    end;
    
    if (AActiveIndex < 0) or (AActiveIndex >= PageCount) then
        Result := FFirstVisibleTab // current first
    else if AActiveIndex < FFirstVisibleTab then
        Result := AActiveIndex
    else if AActiveIndex < FLastVisibleTab then
        Result := FFirstVisibleTab
    else if not Page[AActiveIndex].TabVisible then
        Result := FFirstVisibleTab
    else begin
        Result := AActiveIndex;
        WidthSum := Page[Result].Width;
        while (Result >= 0) and (WidthSum <= FTabArea.Width) do begin
            Dec(Result);

            if (Result >= 0) and Page[Result].TabVisible then
                Inc(WidthSum, Page[Result].TabWidth);
        end;
        if Result < 0 then Result := 0
        else if Result = AActiveIndex then
            begin end
        else Inc(Result);
    end;
    
end;

function TvqPageControl.CalculateLastVisibleTab(AFirstIndex: Integer): Integer;
var
    WidthTo: Integer;
begin
    if PageCount = 0 then begin
        Result := 0;
        Exit;
    end;
    
    Result := AFirstIndex;
    if Page[Result].TabVisible then
        WidthTo := Page[Result].TabWidth
    else
        WidthTo := 0;
    while (Result < PageCount) and (WidthTo <= FTabArea.Width) do begin
        Inc(Result);
        if Result < PageCount then
            if Page[Result].TabVisible then
                Inc(WidthTo, Page[Result].TabWidth);
    end;
    if Result = PageCount then
        Dec(Result);
end;

function TvqPageControl.TabFromPoint(P: TPoint): Integer;
var
    I: Integer;
begin
    Result := VQ_PAGECONTROL_INVALID_TAB;
    if PtInRect(AddTabRect, P) then
        Result := VQ_PAGECONTROL_ADD_BUTTON_TAB
    else if PtInRect(FTabArea, P) then
        for I := FFirstVisibleTab to FLastVisibleTab do
            if PtInRect(PageTabRect(I), P) then begin
                Result := I;
                Break;
            end;
end;

function TvqPageControl.NextTab(ATab: Integer): Integer;
begin
    if ATab <= 0 then Result := 0
    else if ATab >= PageCount then Result := PageCount
    else begin
        Result := ATab + 1;
        while (Result < PageCount) and 
            (not (FItems[Result].TabVisible and FItems[Result].Enabled)) do
            Inc(Result);
        if Result = PageCount then Result := ATab;
    end;
end;

function TvqPageControl.PrevTab(ATab: Integer): Integer;
begin
    if ATab <= 0 then Result := 0
    else if ATab >= PageCount then Result := PageCount
    else begin
        Result := ATab - 1;
        while (Result >= 0) and 
            (not (FItems[Result].TabVisible and FItems[Result].Enabled)) do
            Dec(Result);
        if Result = -1 then Result := ATab;
    end;
end;

function TvqPageControl.FirstTab: Integer;
begin
    Result := 0;
    while (Result < PageCount) and
        (not (FItems[Result].TabVisible and FItems[Result].Enabled)) do
        Inc(Result);
    if Result = PageCount then Result := 0;
end;

function TvqPageControl.LastTab: Integer;
begin
    Result := PageCount - 1;
    while (Result >= 0) and 
        (not (FItems[Result].TabVisible and FItems[Result].Enabled)) do
        Dec(Result);
    if Result = -1 then Result := PageCount - 1;
end;

function TvqPageControl.ArrowButtonSize: TSize;
begin
    Result.cx := 17;
    Result.cy := 17;
end;

function TvqPageControl.DropButtonSize: TSize;
begin
    Result.cx := 17;
    Result.cy := 17;
end;

function TvqPageControl.AddTabSize: TSize;
begin
    Result.cx := 21;
    Result.cy := 21;
end;

function TvqPageControl.PageBoundsRect(AIndex: Integer): TRect;
begin
    Result := vqThemeManager.TabBodyContentRect(FBodyArea);
end;

function TvqPageControl.PageTabRect(AIndex: Integer): TRect;
begin
    if (AIndex >= 0) and (AIndex < PageCount) then begin
        Result := FItems[AIndex].FVirtualTabRect;
        Result.Top := FTabArea.Top;
        Result.Bottom := FTabArea.Bottom;
        Inc(Result.Left, FLeftSpacing - FItems[FFirstVisibleTab].FVirtualTabRect.Left);
        Inc(Result.Right, FLeftSpacing - FItems[FFirstVisibleTab].FVirtualTabRect.Left);
    end
    else Result := TRect.Empty;
end;

function TvqPageControl.PageCloseRect(AIndex: Integer): TRect;
begin
    Result := PageTabRect(AIndex);
    if Result.IsEmpty then 
        Result := TRect.Empty
    else
        Result := vqThemeManager.TabCloseRect(Result);
end;

function TvqPageControl.AddTabRect: TRect;
begin
    if vqtoShowAddButton in Options then begin
        Result := FItems.FVirtualAddTabRect;
        Result.Top := FTabArea.Top;
        Result.Bottom := FTabArea.Bottom;
        if PageCount = 0 then begin
            // do nothing

        end
        else begin
            Inc(Result.Left, FLeftSpacing - FItems[FFirstVisibleTab].FVirtualTabRect.Left);
            Inc(Result.Right, FLeftSpacing - FItems[FFirstVisibleTab].FVirtualTabRect.Left);
        end;
    end
    else
        Result := TRect.Empty;
end;

function TvqPageControl.GlyphSize(AArea: TRect): TSize;
begin
    Result := TSize.Create(0, 0);
end;

function TvqPageControl.CaptionArea(APage: TvqPageSheet; ATabRect: TRect): TRect;
begin
    Result := vqThemeManager.TabContentRect(APage,
        vqtoShowCloseButtons in Options, ATabRect);
end;

procedure TvqPageControl.DrawGlyph(AArea, ARect: TRect);
begin
end;

procedure TvqPageControl.Paint;
var
    Client: TRect;
    AState, ACloseState: TvqThemeState;
    TabR, CloseR: TRect;
    I: Integer;
    APage: TvqPageSheet;
begin
    Client := ClientRect;
    if not Enabled then AState := [vqthDisabled]
    else AState := [vqthNormal];
    if Color = clDefault then
        FBackBmp.Canvas.FullBrush(clBtnFace)
    else
        FBackBmp.Canvas.FullBrush(Color);
    FBackBmp.Canvas.FillRect(Client);
    // body
    if FPageIndex <> VQ_PAGECONTROL_INVALID_TAB then begin
        if not Enabled then AState := [vqthDisabled]
        else if not ActivePage.Enabled then AState := [vqthDisabled]
        else AState := [vqthNormal];
        Include(AState, vqthSelected);

        vqThemeManager.DrawTabBody(ActivePage, FBackBmp.Canvas,
            FBodyArea, PageTabRect(FPageIndex), AState);
    end;

    // tabs
    // FBackBmp.Canvas.SelectClipRect(FTabArea);
    if PageCount > 0 then begin
        for I := FFirstVisibleTab to FLastVisibleTab do begin
            APage := Page[I];
            if not APage.TabVisible then Continue;
            if not Enabled then begin
                AState := [vqthDisabled];
                ACloseState := [vqthDisabled];
            end
            else if not APage.Enabled then begin
                AState := [vqthDisabled];
                ACloseState := [vqthDisabled];
            end
            else if I = FPressedTab then
                if FMouseInClose then begin
                    ACloseState := [vqthPressed];
                    AState := [vqthHovered];
                end
                else begin
                    AState := [vqthPressed];
                    ACloseState := [vqthHovered];
                end
            else if I = FHotTab then
                if FMouseInClose then begin
                    AState := [vqthHovered];
                    ACloseState := [vqthHot];
                end
                else begin
                    AState := [vqthHot];
                    ACloseState := [vqthHovered];
                end
            else begin
                AState := [vqthNormal];
                ACloseState := [vqthNormal];
            end;
            if FPageIndex = I then begin
                Include(AState, vqthSelected);
                if Focused and FCanDrawFocus then
                    Include(AState, vqthFocused);
            end;
            
            TabR := PageTabRect(I);
            vqThemeManager.DrawTab(APage, FBackBmp.Canvas, TabR, FBodyArea, AState);

            if vqtoShowCloseButtons in FOptions then begin
                CloseR := vqThemeManager.TabCloseRect(TabR);
                vqThemeManager.DrawTabClose(APage, FBackBmp.Canvas, CloseR, ACloseState);
            end;

            // caption
            
            FCaptionRenderingPage := APage;
            FCaptionRenderer.DisabledColor := vqThemeManager.DisabledFore;
            FCaptionRenderer.Area := CaptionArea(APage, TabR);
            FCaptionRenderer.Render(APage.Caption, nil, FImages, APage.ImageIndex, FLayout, Enabled and APage.Enabled, APage.Spacing, vqTextHorizontal);
            FCaptionRenderingPage := nil;
            
            //
            
            DoDrawTab(FBackBmp.Canvas, TabR, APage);
        end;
    end;
    // add tab
    if vqtoShowAddButton in FOptions then begin
        if not Enabled then
            AState := [vqthDisabled]
        else if VQ_PAGECONTROL_ADD_BUTTON_TAB = FPressedTab then
            AState := [vqthPressed]
        else if VQ_PAGECONTROL_ADD_BUTTON_TAB = FHotTab then
            AState := [vqthHot]
        else
            AState := [vqthNormal];
        TabR := AddTabRect;
        vqThemeManager.DrawAddTab(Self, FBackBmp.Canvas, TabR, AState);
    end;
    // FBackBmp.Canvas.SelectClipRect(Client);
                                                              
    Canvas.CopyRect(FTabArea, FBackBmp.Canvas, FTabArea);
    Canvas.CopyRect(FBodyArea, FBackBmp.Canvas, FBodyArea);
    inherited Paint;
end;

function TvqPageControl.IsInternalControl(AControl: TControl): Boolean;
begin
    if AControl = nil then Exit(False);
    
    Result := (AControl = FArrowDown) or (AControl = FArrowUp) or
         (AControl = FDropButton);
    if not Result then
        Result := (AControl is TvqPageSheet) and (AControl.Parent = Self);
end;

end.
