// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqListBox;

interface

uses
    InterfaceBase, LCLType, LMessages,
    Classes, Types, SysUtils, Controls, Graphics, Math, ExtCtrls,
    ComCtrls, Menus, ImgList, ActnList, Dialogs, Forms, Buttons, StdCtrls,
    vqUtils, vqThemes, vqScrollingControl, vqToolTip,
    vqStringList, vqListBoxUtils, vqListBoxBuffer, vqListBoxModel_p;
    
type

    TvqListBox = class;
    
    TvqListBoxItems = class(TPersistent)
    private
        FListBox: TvqListBox;
        function GetItem(Index: Integer): TvqListBoxItem;
        procedure SetItem(Index: Integer; Value: TvqListBoxItem);
    public
        constructor Create(AOwner: TvqListBox);
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        function Count: Integer;
        property Item[Index: Integer]: TvqListBoxItem read GetItem write SetItem; default;
    end;
    
    TvqListBoxItemEvent = procedure (Sender: TObject; AIndex: Integer) of object;
    TvqListBoxDrawItemEvent = procedure(Sender: TObject; ACanvas: TCanvas; 
        ARect: TRect; AIndex: Integer; AState: TvqThemeState) of object; 
    TvqListBoxMeasureItemEvent = procedure (Sender: TObject; Index: Integer; ACanvas: TCanvas;
        var AWidth, AHeight: Integer) of object;
    
    { TvqListBox }

 TvqListBox = class(TvqScrollingControl, IvqListBoxListener)
	private
        FBackBmp: TBitmap;
        
        FPrevImgSize: TSize;
        FImages: TImageList;
        FImageChangeLink: TChangeLink;
        FListHintFont: TFont;
        
        FClipping: Boolean;
        FToolTip: TvqToolTip;
        
        FModel: TvqListBoxModel;
        FItems: TvqListBoxItems;
        
        FListHintFormat: TvqTextFormat;
        FListHint: string;
        
        FOwnerDraw: Boolean;
        FOwnerMeasure: Boolean;
        
        FContentRectCache: TRect;
        FScrollWork: Boolean;
        FRepaintWorks: TvqRepaintWorkList;
        FWorkDepth: Byte;
        
		FOnItemClick: TvqListBoxItemEvent;
		FOnSelChange: TNotifyEvent;
		FOnItemChange: TvqListBoxItemEvent;
		FOnDrawItem: TvqListBoxDrawItemEvent;
        FOnMeasureItem: TvqListBoxMeasureItemEvent;
        function GetCount: Integer;
        function GetItemIndex: Integer;
        function GetLines: TStrings;
        function GetMultiSelect: Boolean;
        procedure SetItems(Value: TvqListBoxItems);
        procedure SetLines(Value: TStrings);
        procedure SetMultiSelect(Value: Boolean);
        procedure SetClipping(Value: Boolean);
        procedure SetListHintFormat(Value: TvqTextFormat);
        procedure SetListHint(Value: string);
        procedure SetItemIndex(Value: Integer);
        procedure SetOwnerDraw(Value: Boolean);
        procedure SetOwnerMeasure(Value: Boolean);
        procedure SetListHintFont(Value: TFont);
        procedure SetImages(Value: TImageList);
        
        procedure OnImagesChange(Sender: TObject);
        procedure ListHintFontChange(Sender: TObject);
	private
        procedure SetHoveredItem(Value: Integer);
        procedure SetPressedItem(Value: Integer);
    strict protected
        function GetPage: TRect;
        function GetAwning: TvqSelAwningRange;
        function GetPressedItem: Integer;
        function GetHoveredItem: Integer;
        function GetFirstVisibleItem: Integer;
        function ItemFromVirtualY(Y: Integer): Integer;

        function _ListBoxControl: TControl;
        procedure _MeasureItem(Index: Integer; var AWidth, AHeight: Integer);
        function _ItemSelected(Index: Integer): Boolean;
        procedure _ModifyTopOffset(Value: Integer);
        procedure _RetrieveTopOffset(var Value: Integer);
        procedure _NotifyItemChange(Index: Integer);
        procedure _NotifyChanged;
        procedure _NotifyChanging;
        procedure _NotifySelChanged;
        procedure BeginWork;
        procedure EndWork;
        procedure WorkUpdateScroll;
        procedure WorkRepaintAll;
        procedure WorkRepaintItem(Index: Integer);
        procedure WorkRepaintFrom(Index: Integer);
        procedure WorkRepaintRange(AStart, AEnd: Integer);
        
        function DrawAll: TRect; virtual;
        function DrawFrom(From: Integer): TRect; virtual;
        function DrawItem(Index: Integer): TRect; virtual;
        procedure Measure(Index: Integer; var AWidth, AHeight: Integer); virtual;
        procedure DrawGlyphText(Item: TvqListBoxItem; ARect: TRect); virtual;

        property Page: TRect read GetPage;
        property Model: TvqListBoxModel read FModel;
        property Awning: TvqSelAwningRange read GetAwning;
        property BackBmp: TBitmap read FBackBmp;
    protected
        function FirstActiveItem: Integer;
        function LastActiveItem: Integer;
        function NextActiveItem(I: Integer): Integer;
        function PrevActiveItem(I: Integer): Integer;
        function ItemFromPoint(P: TPoint): Integer;
        function ItemFromPointEx(P: TPoint): Integer;
		function ItemRect(AIndex: Integer): TRect;
        function ItemVisible(AIndex: Integer; Fully: Boolean): Boolean;
        function ItemSelected(AIndex: Integer): Boolean;
        procedure EnsureCaretVisible;
        function CalculateLastVisibleItem: Integer;
        function CalculateFirstVisibleItem: Integer;
        
        property PressedItem: Integer read GetPressedItem;
        property HoveredItem: Integer read GetHoveredItem;
        property FirstVisibleItem: Integer read GetFirstVisibleItem;
    protected
        function ScrollDocSize: TSize; override;
        procedure ChangingOffset; override;
        procedure OffsetChanged; override;
        
		procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure MouseEnter; override;
		procedure MouseLeave; override;
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		procedure KeyUp(var Key: Word; Shift: TShiftState); override;
        
        procedure UpdateMetrics; override;
        procedure FocusChanged(AFocused: Boolean); override;
        procedure FontChanged; override;
        procedure ColorChanged; override;
        procedure EnabledChanged; override;
		procedure Resize; override;
        procedure TextChanged; override;
        
		procedure Paint; override;
        
    protected
        function InactiveItem(Index: Integer): Boolean; virtual;
        function GetItemState(Index: Integer): TvqThemeState; virtual;
        procedure DoItemClick(AIndex: Integer); virtual;
        procedure DoItemChange(AIndex: Integer); virtual;
        procedure DoDrawItem(ACanvas: TCanvas; ARect: TRect; AIndex: Integer; AState: TvqThemeState); virtual;
        procedure DoMeasureItem(AIndex: Integer; ACanvas: TCanvas; var AWidth, AHeight: Integer); virtual;
        procedure SelChanged; virtual;
    public
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;
		procedure Assign(Source: TPersistent); override;
        
        procedure AddSelection(AAnchor, ACaret: Integer; Display: Boolean);
        procedure SetSelection(AAnchor, ACaret: Integer; Display: Boolean);
        procedure SelectAll; virtual;
        procedure DeleteSelected; virtual;
        procedure Clear;
        procedure ClearSelection;
        function GetSelectedText: string;
        class function ItemClass: TvqStringItemClass; virtual;
		
        property Count: Integer read GetCount;
	published
        property Items: TvqListBoxItems read FItems write SetItems;
        property Lines: TStrings read GetLines write SetLines;
        
        property Images: TImageList read FImages write SetImages;
        property ListHintFont: TFont read FListHintFont write SetListHintFont;
        property MultiSelect: Boolean read GetMultiSelect write SetMultiSelect;
		property Clipping: Boolean read FClipping write SetClipping;
        property ToolTip: TvqToolTip read FToolTip write FToolTip;
        property ListHintFormat: TvqTextFormat read FListHintFormat write SetListHintFormat;
		property ListHint: string read FListHint write SetListHint;
        property ItemIndex: Integer read GetItemIndex write SetItemIndex;
        property OwnerDraw: Boolean read FOwnerDraw write SetOwnerDraw;
        property OwnerMeasure: Boolean read FOwnerMeasure write SetOwnerMeasure;
        property Color;
		property Font;
        
		property OnChange;
		property OnItemClick: TvqListBoxItemEvent read FOnItemClick write FOnItemClick;
		property OnSelChange: TNotifyEvent read FOnSelChange write FOnSelChange;
        property OnItemChange: TvqListBoxItemEvent read FOnItemChange write FOnItemChange;
        property OnDrawItem: TvqListBoxDrawItemEvent read FOnDrawItem write FOnDrawItem;
        property OnMeasureItem: TvqListBoxMeasureItemEvent read FOnMeasureItem write FOnMeasureItem;
    end;

implementation

type
    TvqListBoxItemAccess = class(TvqListBoxItem);

{ TvqListBoxItems } 

constructor TvqListBoxItems.Create(AOwner: TvqListBox);
begin
    FListBox := AOwner;
end;

destructor TvqListBoxItems.Destroy;
begin
    FListBox := nil;
    inherited;
end;

procedure TvqListBoxItems.Assign(Source: TPersistent);
begin
    if (Source is TvqListBox) and (Source <> Self) then
        FListBox.Assign(TvqListBoxItems(Source).FListBox)
    else inherited;
end;

function TvqListBoxItems.Count: Integer;
begin
    Result := FListBox.Count;
end;

function TvqListBoxItems.GetItem(Index: Integer): TvqListBoxItem;
begin
    Result := FListBox.FModel.Items[Index];
end;

procedure TvqListBoxItems.SetItem(Index: Integer; Value: TvqListBoxItem);
begin
    FListBox.FModel.Items[Index] := Value;
end;

{ TvqListBox }

constructor TvqListBox.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
    FBackBmp := TBitmap.Create;
    with GetControlClassDefaultSize do begin
        FBackBmp.Width := cx;
        FBackBmp.Height := cy;
    end;
    
    FModel := TvqListBoxModel.Create(Self, ItemClass);
    FItems := TvqListBoxItems.Create(Self);
    
    FClipping := False;
    FToolTip := nil;
    
    FImages := nil;
    FImageChangeLink := TChangeLink.Create;
    FImageChangeLink.OnChange := @OnImagesChange;
    
    FPrevImgSize := Size(0, 0);
    
    FListHintFormat := TvqTextFormat.Create(Self);
    FListHint := '';
    
    FListHintFont := TFont.Create;
    FListHintFont.OnChange := @ListHintFontChange;
    
    FWorkDepth := 0;
    FScrollWork := False;
    FRepaintWorks := TvqRepaintWorkList.Create;
    
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
end;

destructor TvqListBox.Destroy;
begin
    FImageChangeLink.Free;
    FItems.Free;
    FModel.Free;
    FBackBmp.Free;
    FListHintFormat.Free;
    FRepaintWorks.Free;
    FListHintFont.Free;
	inherited;
end;

procedure TvqListBox.Assign(Source: TPersistent);
begin
	if (Source is TvqListBox) and (Source <> Self) then
        FModel.Assign(TvqListBox(Source).Lines)
    else if Source is TListBox then
        FModel.Assign(TListBox(Source).Items)
	else inherited;
end;

procedure TvqListBox.AddSelection(AAnchor, ACaret: Integer; Display: Boolean);
begin
    BeginWork;          
    Model.BeginSelection;
    FModel.CoalesceAwningSel;
    FModel.SetSelectionAwning(AAnchor, ACaret);
    if Display then EnsureCaretVisible; 
    Model.EndSelection;
    EndWork;
end;

procedure TvqListBox.SetSelection(AAnchor, ACaret: Integer; Display: Boolean);
begin
    BeginWork;          
    Model.BeginSelection;
    FModel.SetSelectionAwning(AAnchor, ACaret);
    FModel.EraseLowSelection;
    if Display then EnsureCaretVisible;  
    Model.EndSelection;
    EndWork;
end;

procedure TvqListBox.SelectAll;
begin
    SetSelection(0, Count - 1, False);
end;

procedure TvqListBox.DeleteSelected;
var
    I: Integer;
begin
    if MultiSelect then begin
        I := Count - 1;
        while I >= 0 do begin
            if Items[I].Selected then
                FModel.Delete(I);
            Dec(I);
        end;
    end
    else if ItemIndex >= 0 then
        FModel.Delete(ItemIndex);
end;

procedure TvqListBox.Clear;
begin
    FModel.Clear;
end;

procedure TvqListBox.ClearSelection;
begin
    FModel.ClearSelection;
end;

function TvqListBox.GetSelectedText: string;
var
    I: Integer;
begin
    Result := '';
    if MultiSelect then begin
        for I := 0 to Count - 1 do
            if Items[I].Selected then
                if Result = '' then 
                    Result := Result + Items[I].Text
                else
                    Result := Result + LineEnding + Items[I].Text;
    end
    else if ItemIndex >= 0 then
        Result := Items[ItemIndex].Text;
end;

class function TvqListBox.ItemClass: TvqStringItemClass;
begin
    Result := TvqListBoxItem;
end;

function TvqListBox.GetCount: Integer;
begin
    Result := FModel.Count;
end;

function TvqListBox.GetItemIndex: Integer;
begin
    // in MultiSelect mode ItemIndex can be -1 even if there are selected items
    if FModel.SelAwning.Valid then begin
        Result := Awning.Caret;
        if not Items[Result].Selected then
            Result := -1;
    end
    else Result := -1;
end;

function TvqListBox.GetMultiSelect: Boolean;
begin
    Result := FModel.MultiSelect;
end;

function TvqListBox.GetLines: TStrings;
begin
    Result := TStrings(FModel);
end;

procedure TvqListBox.SetItems(Value: TvqListBoxItems);
begin
    FItems.Assign(Value);
end;

procedure TvqListBox.SetLines(Value: TStrings);
begin
    FModel.Assign(Value);
end;

procedure TvqListBox.SetMultiSelect(Value: Boolean);
begin
    FModel.MultiSelect := Value;
end;

procedure TvqListBox.SetClipping(Value: Boolean);
begin
    if FClipping then begin
        BeginWork;
        FClipping := Value;
        WorkUpdateScroll;
        EndWork;
    end;
end;

procedure TvqListBox.SetListHintFormat(Value: TvqTextFormat);
begin
    FListHintFormat.Assign(Value);
end;

procedure TvqListBox.SetListHint(Value: string);
begin
    if FListHint <> Value then begin
        FListHint := Value;
        if Count = 0 then 
            Invalidate;
    end;
end;

procedure TvqListBox.SetItemIndex(Value: Integer);
begin
    if GetItemIndex <> Value then begin
        if Value = -1 then
            ClearSelection
        else
            SetSelection(Value, Value, False);
    end;
end;

procedure TvqListBox.SetOwnerDraw(Value: Boolean);
begin
    if FOwnerDraw <> Value then begin
        FOwnerDraw := Value;
        Invalidate;
    end;
end;

procedure TvqListBox.SetOwnerMeasure(Value: Boolean);
begin
    if FOwnerMeasure <> Value then begin
        FOwnerMeasure := Value;
        UpdateMetrics;
    end;
end;

procedure TvqListBox.SetListHintFont(Value: TFont);
begin
    FListHintFont.Assign(Value);
end;

procedure TvqListBox.OnImagesChange(Sender: TObject);
begin
    if Sender = FImages then begin
        if FPrevImgSize <> Size(FImages.Width, FImages.Height) then begin
            UpdateMetrics;
            FPrevImgSize := Size(FImages.Width, FImages.Height);
        end
        else
            Invalidate;
    end;
end;

procedure TvqListBox.SetImages(Value: TImageList);   
begin
    if FImages <> Value then begin
        if FImages <> nil then begin
            FImages.UnRegisterChanges(FImageChangeLink);
            FImages.RemoveFreeNotification(Self);
            FPrevImgSize := Size(0, 0);
        end;
        FImages := Value;
        if FImages <> nil then begin
            FImages.FreeNotification(Self);
            FImages.RegisterChanges(FImageChangeLink);
            FPrevImgSize := Size(FImages.Width, FImages.Height);
        end;
        UpdateMetrics;
    end;
end;

procedure TvqListBox.ListHintFontChange(Sender: TObject);
begin
    Invalidate;
end;

procedure TvqListBox.DoItemClick(AIndex: Integer);
begin
    if Assigned(FOnItemClick) then FOnItemClick(Self, AIndex);
end;

procedure TvqListBox.DoItemChange(AIndex: Integer);
begin
    if Assigned(FOnItemChange) then FOnItemChange(Self, AIndex);
end;

procedure TvqListBox.DoDrawItem(ACanvas: TCanvas; ARect: TRect; AIndex: Integer; AState: TvqThemeState);
begin
    if Assigned(FOnDrawItem) then FOnDrawItem(Self, ACanvas, ARect, AIndex, AState);
end;

procedure TvqListBox.DoMeasureItem(AIndex: Integer; ACanvas: TCanvas; var AWidth, AHeight: Integer);
begin
    if Assigned(FOnMeasureItem) then FOnMeasureItem(Self, AIndex, ACanvas, AWidth, AHeight);
end;

procedure TvqListBox.SelChanged;
begin
    if Assigned(FOnSelChange) then FOnSelChange(Self);
end;

function TvqListBox.InactiveItem(Index: Integer): Boolean;
begin
    Result := False;
end;

function TvqListBox.GetItemState(Index: Integer): TvqThemeState;
begin
    Result := [];
    if (Index >= 0) and (Index < Count) then begin
        if not Enabled then 
            Include(Result, vqthDisabled);
        if FModel.FPressedItem = Index then
            Include(Result, vqthPressed);
        if FModel.FHoveredItem = Index then
            Include(Result, vqthHot);
        if FModel.Items[Index].Selected then
            Include(Result, vqthSelected);
        if FModel.SelAwning.Caret = Index then
            Include(Result, vqthFocused);
    end;
end;

procedure TvqListBox.UpdateMetrics;
begin
    BeginWork;
    FModel.Measure(0, Count - 1);
    inherited;
    EndWork;
end;

procedure TvqListBox.FocusChanged(AFocused: Boolean); 
begin
    inherited;
    BeginWork;
    if FModel.SelAwning.Valid then
        WorkRepaintItem(FModel.SelAwning.Caret);
    EndWork;
end;

procedure TvqListBox.FontChanged; 
begin
    inherited;
   UpdateMetrics;
end;

procedure TvqListBox.ColorChanged; 
begin
    inherited;
    Invalidate;
end;

procedure TvqListBox.EnabledChanged; 
begin
    inherited;
    Invalidate;
end;

procedure TvqListBox.Resize; 
begin
    //BeginWork;
    inherited;
    FBackBmp.Width := ClientWidth;
    FBackBmp.Height := ClientHeight;
    if Parent <> nil then
        UpdateScrollBars;
    //EndWork;
end;

procedure TvqListBox.TextChanged;
begin
    inherited;
    if Count = 0 then
        Invalidate;
end;

procedure TvqListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
	MouseItem: Integer;
	P: TPoint;
begin
    if Count > 0 then begin
        BeginWork;
        P := Point(X, Y);
        MouseItem := ItemFromPointEx(P);
        if PtInRect(ClientRect, P) then
            SetHoveredItem(MouseItem)
        else
            SetHoveredItem(-1);
        
        if ssLeft in Shift then begin
            if not ItemVisible(MouseItem, True) then begin
                Model.SetSelectionAwning(Awning.Anchor, MouseItem);
                EnsureCaretVisible;
            end
            else Model.SetSelectionAwning(Awning.Anchor, MouseItem);
        end;
        
        EndWork;
    end;
	inherited MouseMove(Shift, X, Y);
end;

procedure TvqListBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	MouseItem: Integer;
	P: TPoint;
begin
	if PtInRect(ClientRect, Point(X, Y)) then begin
        BeginWork;
		if Button = mbLeft then begin
			P := Point(X, Y);
			MouseItem := ItemFromPointEx(P);
            SetPressedItem(MouseItem);
			if MouseItem <> vqInvalidValue then begin
				if ssAlt in Shift then Model.CoalesceAwningSel;
				if ssShift in Shift then Model.SetSelectionAwning(Awning.Anchor, MouseItem)
				else Model.SetSelectionAwning(MouseItem, MouseItem);
				if not (ssAlt in Shift) then Model.EraseLowSelection;
                EnsureCaretVisible;
			end;
		end
		else if Button = mbRight then begin
            //
		end;
        EndWork;
	end;
	inherited MouseDown(Button, Shift, X, Y);
end;

procedure TvqListBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	P: TPoint;
	MouseItem: Integer;
begin
    BeginWork;
    if Button = mbLeft then begin
        P := Point(X, Y);
        if PtInRect(ClientRect, P) then begin
            MouseItem := ItemFromPointEx(P);
            if (PressedItem <> vqInvalidValue) and (MouseItem = PressedItem) then begin
                DoItemClick(PressedItem);
            end;
        end
        else MouseItem := vqInvalidValue;
        SetPressedItem(-1);
        SetHoveredItem(MouseItem);
    end;
    EndWork;
	inherited MouseUp(Button, Shift, X, Y);
end;

procedure TvqListBox.MouseEnter;
begin
	inherited;
end;

procedure TvqListBox.MouseLeave;
begin
	inherited;
    SetHoveredItem(vqInvalidValue);
end;

function TvqListBox.PrevActiveItem(I: Integer): Integer;
begin
    Result := I - 1;
    while (Result > 0) and InactiveItem(Result) do
        Dec(Result);
    if InactiveItem(Result) then Result := I;
end;

function TvqListBox.NextActiveItem(I: Integer): Integer;
begin
    Result := I + 1;
    while (Result < Count) and InactiveItem(Result) do
        Inc(Result);
    if Result = Count then Result := I
    else if InactiveItem(Result) then Result := I;
end;

function TvqListBox.FirstActiveItem: Integer;
begin
    Result := 0;
    while (Result < Count) and InactiveItem(Result) do
        Inc(Result);
    if Result = Count then Result := 0
    else if InactiveItem(Result) then Result := 0;
end;

function TvqListBox.LastActiveItem: Integer;
begin
    Result := Count - 1;
    while (Result > 0) and InactiveItem(Result) do
        Dec(Result);
    if InactiveItem(Result) then Result := Count - 1;
end;

procedure TvqListBox.KeyDown(var Key: Word; Shift: TShiftState);
var
	A, C, ADelta, ViewH, H: Integer;
    
begin      
	inherited KeyDown(Key, Shift);
    BeginWork;
	with Awning do
		if (Anchor <> vqInvalidValue) and (Caret <> vqInvalidValue) and
        (Count > 0) then
			case Key of
				VK_RIGHT: begin
                    SetOffset(LeftOffset + 5, TopOffset);
                    Key := VK_UNKNOWN;
                end;
                VK_LEFT: begin
                    SetOffset(LeftOffset - 5, TopOffset);
                    Key := VK_UNKNOWN;
                end;
                VK_UP: begin
                    if Caret > 0 then begin
                        C := PrevActiveItem(Caret);
					    if ssShift in Shift then A := Anchor
					    else A := C;
                        Model.SetSelectionAwning(A, C);
                        EnsureCaretVisible;
				    end;                    
                    Key := VK_UNKNOWN;
                end;
                VK_DOWN: begin
                    if Caret < Count - 1 then begin
					    C := NextActiveItem(Caret);
					    if ssShift in Shift then A := Anchor
					    else A := C;
                        Model.SetSelectionAwning(A, C);
                        EnsureCaretVisible;
				    end;              
                    Key := VK_UNKNOWN;
                end;
                VK_PRIOR: begin
                    if Caret > 0 then begin
                        ViewH := ClientRect.Height;
                        C := Caret;
                        H := 0;
                        while (C > 0) and (H < ViewH) do begin
                            Inc(H, Items[C].Height);
                            Dec(C);
                        end;
                        if C = Caret then Dec(C);
                        if InactiveItem(C) then
                            C := PrevActiveItem(C);

					    if ssShift in Shift then A := Anchor
					    else A := C;
                        Model.SetSelectionAwning(A, C);
                        EnsureCaretVisible;
                    end;
                    Key := VK_UNKNOWN;
				end;
				VK_NEXT: begin
                    if Caret < Count - 1 then begin
                        ViewH := ClientRect.Height;
                        C := Caret;
                        H := 0;
                        while (C < Count - 1) and (H < ViewH) do begin
                            Inc(H, Items[C].Height);
                            Inc(C);
                        end;
                        if C = Caret then Inc(C);
                        if InactiveItem(C) then
                            C := NextActiveItem(C);

					    if ssShift in Shift then A := Anchor
					    else A := C;
                        Model.SetSelectionAwning(A, C);
                        EnsureCaretVisible;
				    end;         
                    Key := VK_UNKNOWN;
                end;
                VK_END: begin
                    if Caret < Count - 1 then begin
					    C := LastActiveItem;
					    if ssShift in Shift then A := Anchor
					    else A := C;
                        Model.SetSelectionAwning(A, C);
                        EnsureCaretVisible;
                    end;
                    Key := VK_UNKNOWN;
				end;
				VK_HOME: begin
                    if Caret > 0 then begin
					    C := FirstActiveItem;
					    if ssShift in Shift then A := Anchor
					    else A := C;
                        Model.SetSelectionAwning(A, C);
                        EnsureCaretVisible;
                    end;
                    Key := VK_UNKNOWN;
				end;
				VK_SPACE: begin
                    SetPressedItem(Caret);
                    Key := VK_UNKNOWN;
                end;
            end;
    EndWork;
end;

procedure TvqListBox.KeyUp(var Key: Word; Shift: TShiftState);
begin              
	inherited KeyUp(Key, Shift);
    BeginWork;
	if (PressedItem <> vqInvalidValue) and (Key = VK_SPACE) then begin
		DoItemClick(PressedItem);
        SetPressedItem(vqInvalidValue);
	end;
    EndWork;
end;

function TvqListBox.ScrollDocSize: TSize;
begin
    Result.cy := Model.FPageHeight;
    if FClipping then
        Result.cx := 0
    else
        Result.cx := Model.FPageWidth;
end;

procedure TvqListBox.ChangingOffset;
begin
end;

procedure TvqListBox.OffsetChanged;
begin
    Model.FTopItem := CalculateFirstVisibleItem; 
end;

procedure TvqListBox.SetHoveredItem(Value: Integer);
begin
    FModel.SetHoveredItem(Value);
end;

procedure TvqListBox.SetPressedItem(Value: Integer);
begin
    Model.SetPressedItem(Value);
end;

function TvqListBox.GetPage: TRect;
begin
    Result.TopLeft := TPoint.Zero;
    Result.BottomRight := Point(FModel.FPageWidth, FModel.FPageHeight);
end;

function TvqListBox.GetAwning: TvqSelAwningRange;
begin
    Result := Model.SelAwning;
end;

function TvqListBox.GetPressedItem: Integer;
begin
    Result := Model.FPressedItem;
end;

function TvqListBox.GetHoveredItem: Integer;
begin
    Result := Model.FHoveredItem;
end;

function TvqListBox.GetFirstVisibleItem: Integer;
begin
    Result := Model.TopItem;
end;

procedure TvqListBox._MeasureItem(Index: Integer; var AWidth, AHeight: Integer);
begin
    Measure(Index, AWidth, AHeight);
end;

function TvqListBox._ItemSelected(Index: Integer): Boolean;
begin
    Result := ItemSelected(Index);
end;

procedure TvqListBox._ModifyTopOffset(Value: Integer);
begin
    FTopOffset := Value;
end;

procedure TvqListBox._RetrieveTopOffset(var Value: Integer);
begin
    Value := FTopOffset;
end;

procedure TvqListBox._NotifyItemChange(Index: Integer);
begin
    DoItemChange(Index);
end;

procedure TvqListBox._NotifyChanged;
begin
    Changed;
end;

procedure TvqListBox._NotifyChanging;
begin
    // do nothing
end;

procedure TvqListBox._NotifySelChanged;
begin
    SelChanged;
end;

procedure TvqListBox.BeginWork;
begin
    if FWorkDepth = 0 then begin
        FScrollWork := False;
        FRepaintWorks.Clear;
    end;
    Inc(FWorkDepth);
end;

procedure TvqListBox.EndWork;
label
    LBL_END_DRAW;
var
    ARedrawAll: Boolean;
    R: TRect;
    I, ADrawFrom, K, L, Row, TopRow, BottomRow: Integer;
    RowsToDraw: array of Boolean;
begin
    Dec(FWorkDepth);
    if (FWorkDepth = 0) then begin
        if (not FScrollWork) and (FRepaintWorks.Count = 0) then Exit;

        // make update scroll
        
        ARedrawAll := False;
        if FScrollWork then begin 
            UpdateScrollBars;
            ARedrawAll := True;
        end;
        
        // make repaint

        if ARedrawAll then begin
            Repaint;
            goto LBL_END_DRAW;
        end;

        FPainting := True;
        
        for I := 0 to FRepaintWorks.Count - 1 do
            if FRepaintWorks[I].Kind = LB_WORK_REPAINT_ALL then begin
                Repaint;
                goto LBL_END_DRAW;
            end;
        
        FContentRectCache := ClientRect;
        
        ADrawFrom := Count;
        for I := 0 to FRepaintWorks.Count - 1 do
            if FRepaintWorks[I].Kind = LB_WORK_REPAINT_FROM then
                ADrawFrom := Min(FRepaintWorks[I].First, ADrawFrom);
        if ADrawFrom < Count then begin
            R := DrawFrom(ADrawFrom);
            Canvas.CopyRect(R, FBackBmp.Canvas, R);
            if ADrawFrom = 0 then goto LBL_END_DRAW;
        end;
        
        TopRow := FirstVisibleItem;
        BottomRow := CalculateLastVisibleItem;
        L := BottomRow - TopRow + 1;
    
        SetLength(RowsToDraw, L);
        for K := 0 to L - 1 do RowsToDraw[K] := False;
        for I := 0 to FRepaintWorks.Count - 1 do
            if FRepaintWorks[I].Kind = LB_WORK_REPAINT_RANGE then begin
                for K := Max(FRepaintWorks[I].First, TopRow) to 
                    Min(FRepaintWorks[I].Last, BottomRow) do
                    RowsToDraw[K - TopRow] := True;
            end;
        for K := ADrawFrom to BottomRow do
            RowsToDraw[K - TopRow] := False;
        for K := 0 to L - 1 do
            if RowsToDraw[K] then begin
                R := DrawItem(K + TopRow);
                Canvas.CopyRect(R, FBackBmp.Canvas, R);
            end;
        
        LBL_END_DRAW:
        
        // release
        
        FScrollWork := False;
        FRepaintWorks.Clear;

        FPainting := False;
    end;
end;

procedure TvqListBox.WorkUpdateScroll;
begin
    FScrollWork := True;
end;

procedure TvqListBox.WorkRepaintAll;
begin
    FRepaintWorks.Add(LB_WORK_REPAINT_ALL, 0, 0);
end;

procedure TvqListBox.WorkRepaintItem(Index: Integer);
begin
    FRepaintWorks.Add(LB_WORK_REPAINT_RANGE, Index, Index);
end;

procedure TvqListBox.WorkRepaintFrom(Index: Integer);
begin
    FRepaintWorks.Add(LB_WORK_REPAINT_FROM, Index, 0);
end;

procedure TvqListBox.WorkRepaintRange(AStart, AEnd: Integer);
begin
    FRepaintWorks.Add(LB_WORK_REPAINT_RANGE, AStart, AEnd);
end;

function TvqListBox.ItemFromPoint(P: TPoint): Integer;
begin
    if PtInRect(ClientRect, P) then
        Result := ItemFromPointEx(P)
    else
        Result := -1;
end;

function TvqListBox.ItemFromPointEx(P: TPoint): Integer;
var
    Y: Integer;
    Content: TRect;
begin
    if Count = 0 then Exit(-1);
    Content := ClientRect;
    Result := FirstVisibleItem;
    Y := TvqListBoxItemAccess(Items[Result]).VirtualTop + Content.Top - TopOffset;
    if P.Y < Y then begin
        while (P.Y < Y) and (Result > 0) do begin
            Dec(Result);
            Dec(Y, Items[Result].Height);
        end;
    end 
    else begin
        Inc(Y, Items[Result].Height);
        while (P.Y >= Y) and (Result < Count - 1) do begin
            Inc(Result);
            Inc(Y, Items[Result].Height);
        end;
    end;
end;

function TvqListBox.ItemRect(AIndex: Integer): TRect;
var
    Content: TRect;
begin
    if (AIndex >= 0) and (AIndex < Count) then begin
        Content := ClientRect;
        with Result do begin
            if FClipping then
                Left := Content.Left
            else
                Left := Content.Left - LeftOffset;
            Top := Content.Top + TvqListBoxItemAccess(Items[AIndex]).VirtualTop - TopOffset;
            Bottom := Top + Items[AIndex].Height;
            if FClipping then
                Right := Content.Right
            else 
                Right := Left + FModel.FPageWidth;
        end;
    end
    else Result := TRect.Empty;
end;

function TvqListBox.ItemVisible(AIndex: Integer; Fully: Boolean): Boolean;
var
    Y, B: Integer;
    Content: TRect;
begin
    Content := ClientRect;
    Y := Content.Top + TvqListBoxItemAccess(Items[AIndex]).VirtualTop - TopOffset;
    B := Top + Items[AIndex].Height;
    if Fully then begin
        Result := (Y >= Content.Top) and (B <= Content.Bottom);
    end
    else begin
        Result := (B >= Content.Top) and (Y <= Content.Bottom);
    end;
end;

function TvqListBox.ItemSelected(AIndex: Integer): Boolean;
begin
    Result := Model.IsItemSelected(AIndex);
end;

procedure TvqListBox.EnsureCaretVisible;
var
    Caret: Integer;
begin
    if Awning.Valid then begin
        if Awning.Caret <= FirstVisibleItem then
            SetOffset(LeftOffset, TvqListBoxItemAccess(Items[Awning.Caret]).VirtualTop)
        else if Awning.Caret >= CalculateLastVisibleItem then
            SetOffset(LeftOffset, 
                TvqListBoxItemAccess(Items[Awning.Caret]).VirtualTop +
                Items[Awning.Caret].Height - ClientRect.Height);
    end;
end;

function TvqListBox.CalculateFirstVisibleItem: Integer;
begin
    Result := ItemFromVirtualY(TopOffset);
end;

function TvqListBox.CalculateLastVisibleItem: Integer;
var
    Y: Integer;
    Content: TRect;
begin
    if Count = 0 then Exit(-1);
    Content := ClientRect;
    Result := FirstVisibleItem;
    Y := Content.Top + TvqListBoxItemAccess(Items[Result]).VirtualTop - TopOffset;
    while (Result < Count) and (Y < Content.Bottom) do begin
        Inc(Y, Items[Result].Height);
        Inc(Result);
    end;
    if Result = Count then Dec(Result);
end;

function TvqListBox.ItemFromVirtualY(Y: Integer): Integer;
var
    AMiddle, AUpper, ALower: Integer;
begin
    if Y <= 0 then Exit(0);
    if Y >= Model.FPageHeight then Exit(Count - 1);
    
    ALower := 0;
    AUpper := Count - 1;
    repeat
        AMiddle := (ALower + AUpper + 1) div 2;
        if Y < TvqListBoxItemAccess(Items[AMiddle]).VirtualTop then AUpper := AMiddle - 1
        else ALower := AMiddle;
    until ALower >= AUpper;
    Result := ALower;
end;

function TvqListBox._ListBoxControl: TControl;
begin
    Result := Self;
end;

procedure TvqListBox.Measure(Index: Integer; var AWidth, AHeight: Integer);
var
    Str: string;
    SzG, SzT: TSize;
begin
    if FOwnerMeasure then begin
        AWidth := 0;
        AHeight := 17;
        DoMeasureItem(Index, BackBmp.Canvas, AWidth, AHeight);
    end
    else 
        with FBackBmp.Canvas do begin
            Font := Self.Font;

            Str := Items[Index].Text;
            if (Images <> nil) and (Items[Index].ImageIndex >= 0) and
                (Items[Index].ImageIndex < Images.Count) then
                SzG := TSize.Create(Images.Width, Images.Height)
            else
                SzG := TSize.Zero;
            if Str = '' then
                SzT := TSize.Create(0, TextExtent('Qq').cy)
            else
                SzT := TextExtent(Str);
            
            AWidth := SzT.cx + SzG.cx;
            AHeight := Max(SzT.cy, SzG.cy);
        end;
end;

function TvqListBox.DrawAll: TRect;
var
    I: Integer;
begin
    with FBackBmp.Canvas do begin
        FullBrush(Color);
        FillRect(FContentRectCache);
        if Count > 0 then
            for I := FirstVisibleItem to CalculateLastVisibleItem do
                DrawItem(I)
        else begin
            Font := FListHintFont;
            if not Enabled then Font.Color := vqThemeManager.DisabledFore;
            TextRect(FContentRectCache, FContentRectCache.Left, FContentRectCache.Top,
                FListHint, FListHintFormat.Style);
        end;
        Result := FContentRectCache;
    end;
end;

function TvqListBox.DrawFrom(From: Integer): TRect;
var
    R: TRect;
    I, Y: Integer;
begin
    with FBackBmp.Canvas do begin
        Result := FContentRectCache; 
        Y := Result.Top;
        for I := From to CalculateLastVisibleItem do begin
            R := DrawItem(I);
            Y := R.Bottom;
            if I = From then Result.Top := R.Top;
        end;
        FullBrush(Color);
        R := FContentRectCache;
        R.Top := Y;
        FillRect(R);
    end;
end;

function TvqListBox.DrawItem(Index: Integer): TRect;
var
    R, ItemR, FocusR: TRect;
    ItemSt: TvqThemeState;
    AState: TvqThemeState;
begin

    with FBackBmp.Canvas do begin
        ItemR := ItemRect(Index);
        Result.Left := FContentRectCache.Left;
        Result.Right := FContentRectCache.Right;
        Result.Top := ItemR.Top;
        Result.Bottom := ItemR.Bottom;
        
        if Items[Index].Selected then
            FullBrush(vqThemeManager.HiliteBack)
        else
            FullBrush(Color);
        FillRect(Result);
        if FOwnerDraw then begin
            ItemSt := GetItemState(Index);
            DoDrawItem(FBackBmp.Canvas, ItemR, Index, ItemSt);
        end
        else begin
            AState := GetItemState(Index);
            vqThemeManager.DrawListItem(Self, FBackBmp.Canvas, ItemR, AState);
            DrawGlyphText(Items[Index], ItemR);
        end;
    end;
end;

procedure TvqListBox.DrawGlyphText(Item: TvqListBoxItem; ARect: TRect);
var
    Index: Integer;
    Str: string;
    SzG, SzT: TSize;
    GlXY, TxtXY: TPoint;
    DCIndex: Integer;
begin
    with FBackBmp.Canvas do begin
        Font := Self.Font;
        if not Enabled then Font.Color := vqThemeManager.DisabledFore
        else if Item.Selected then Font.Color := vqThemeManager.HiliteFore;
        Index := Item.ImageIndex;
        Str := Item.Text;
        if (Images <> nil) and (Item.ImageIndex >= 0) and (Item.ImageIndex < Images.Count) then
            SzG := TSize.Create(Images.Width, Images.Height)
        else
            SzG := TSize.Zero;
        if Str = '' then
            SzT := TSize.Create(0, TextExtent('Qq').cy)
        else
            SzT := TextExtent(Str);
        
        GlXY.Y := (ARect.Top + ARect.Bottom - SzG.cy) div 2;
        TxtXY.Y := (ARect.Top + ARect.Bottom - SzT.cy) div 2;
        
        GlXY.X := ARect.Left;
        TxtXY.X := GlXY.X + SzG.cx;
        
        DCIndex := WidgetSet.SaveDC(Handle);
        WidgetSet.IntersectClipRect(Handle, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);

        if (Images <> nil) and (Item.ImageIndex >= 0) and (Item.ImageIndex < Images.Count) then
            Images.Draw(FBackBmp.Canvas, GlXY.X, GlXY.Y, Item.ImageIndex, Enabled);
        FBackBmp.Canvas.TextRect(ARect, TxtXY.X, TxtXY.Y, Str, LineTextStyle);
        
        WidgetSet.RestoreDC(Handle, DCIndex);
    end;
end;

procedure TvqListBox.Paint;
var
    R: TRect;
begin
    FContentRectCache := ClientRect;
    R := DrawAll;
    Canvas.CopyRect(R, FBackBmp.Canvas, R);
    inherited Paint;
end;

end.

