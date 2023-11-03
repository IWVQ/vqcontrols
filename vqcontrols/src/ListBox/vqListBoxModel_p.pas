// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqListBoxModel_p;

interface
                   
uses
    Types, SysUtils, Classes, Graphics, Dialogs,
    vqUtils, vqStringList, vqListBoxUtils, vqListBoxBuffer;

type
    
    TvqListBoxModel = class(TvqListBoxStrings)
    protected
        procedure SetTopItem(Value: Integer);
        procedure SetMultiSelect(Value: Boolean);
        
        function CorrectSelectionAwning(ARemoveIndex: Integer; var AStart, AEnd: Integer): Boolean;
        procedure InternalGetSelectedItems(var ASel: TIntArray; AIncludeCaret: Boolean);
        function CalculatePageWidth: Integer;
        procedure SetTopOffset(Value: Integer);
        function GetTopOffset: Integer;
    protected
        procedure WorkRepaintAll;
        procedure WorkRepaintFrom(AFrom: Integer);
        procedure WorkUpdateScroll;
        procedure WorkRepaintRange(AStart, AEnd: Integer);
        procedure BeginWork;
        procedure EndWork;
        function InactiveItem(Index: Integer): Boolean;
    public
		FTopItem: Integer;
		FLongestItem: Integer;
		FPressedItem: Integer;
        FHoveredItem: Integer;
		FLowSelection: TIntArray;
		FSelAwning: TvqSelAwningRange;
        FMultiSelect: Boolean;
        
        FSelectionDepth: Byte;
        FSelectionModified: Boolean;
        FPageHeight: Integer;
        FPageWidth: Integer;
        
        procedure ItemSizeChanged(Index: Integer; DeltaX, DeltaY: Integer); override;
        procedure Changed; override;
        procedure Changing; override;
        procedure SelChanged;
        procedure BeginSelection;
        procedure EndSelection(AModified: Boolean = False);

        property SelAwning: TvqSelAwningRange read FSelAwning;
    public
        constructor Create(AListBox: IvqListBoxListener; AItemClass: TvqStringItemClass); virtual;
        destructor Destroy; override;
        
        procedure Clear; override;
        procedure Insert(Index: Integer; const S: string); override;
        function Remove(Index: Integer): TvqListBoxItem; override;
        procedure Delete(Index: Integer); override;
        procedure Exchange(Index1, Index2: Integer); override;
        procedure Move(CurIndex, NewIndex: Integer); override;
        procedure Fill(const AValue: string; AStart, AEnd : Integer); override;
        procedure Sort; override;
        
        procedure CoalesceAwningSel(AIncludeCaret: Boolean = True);
        procedure SetSelectionAwning(AAnchor, ACaret: Integer);
        procedure GetSelectionAwning(var AAnchor, ACaret: Integer);
        procedure EraseLowSelection;
        procedure CollapseSelection;
        procedure GetSelectedItems(var ASel: TIntArray);
        procedure SetSelectedItems(const ASel: array of Integer);
        procedure ClearSelection;
        function IsItemSelected(Index: Integer): Boolean;
        
        procedure Measure(AStart, AEnd: Integer); override;
        procedure SetHoveredItem(Index: Integer);
        procedure SetPressedItem(Index: Integer);


        property TopItem: Integer read FTopItem write SetTopItem;
        property MultiSelect: Boolean read FMultiSelect write SetMultiSelect;
    end;
    
implementation

type
    TvqListBoxItemAccess = class(TvqListBoxItem);

{ TvqListBoxModel }

constructor TvqListBoxModel.Create(AListBox: IvqListBoxListener; AItemClass: TvqStringItemClass);
begin
    inherited Create(AItemClass);
    ListBox := AListBox;
    
    FTopItem := vqInvalidValue;
	FPressedItem := vqInvalidValue;
	FLongestItem := vqInvalidValue;
    FHoveredItem := vqInvalidValue;
    FLowSelection := nil;
    FSelAwning.Invalidate;
    FMultiSelect := True;
    
    FPageWidth := 0;
    FPageHeight := 0;
end;

destructor TvqListBoxModel.Destroy;
begin
	FLowSelection := nil;
    inherited;
end;

procedure TvqListBoxModel.Clear;
begin
    if Count > 0 then begin
        BeginSelection;
        BeginUpdate;
        BeginWork;
        inherited Clear;
        FLongestItem := vqInvalidValue;
        FPressedItem := vqInvalidValue;
        FHoveredItem := vqInvalidValue;
        FTopItem := vqInvalidValue;
        SetTopOffset(0);
        FLowSelection := nil;
        FSelAwning.Invalidate;
        FPageHeight := 0;
        FPageWidth := 0;
        WorkRepaintAll;
        WorkUpdateScroll;
        EndWork;
        EndUpdate;
        EndSelection(True);
    end;
end;

procedure TvqListBoxModel.Insert(Index: Integer; const S: string);
var
    PrevSelAwningLen, Delta, I: Integer;
    SelModified: Boolean;
begin
    if (Index >= 0) and (Index <= Count) then begin
        BeginSelection;
        BeginUpdate;
        BeginWork;
        inherited Insert(Index, S);
        if Count = 1 then
            FTopItem := 0;
        if FTopItem > Index then begin
            Delta := Items[Index].Height;
            Inc(FTopItem);
            SetTopOffset(GetTopOffset + Delta);
        end;
        SelModified := False;
        PrevSelAwningLen := FSelAwning.Length;
        if FSelAwning.Anchor >= Index then
            Inc(FSelAwning.Anchor);
        if FSelAwning.Caret >= Index then
            Inc(FSelAwning.Caret);
        SelModified := PrevSelAwningLen <> FSelAwning.Length;

        if FLongestItem >= Index then Inc(FLongestItem);
        if FPressedItem >= Index then Inc(FPressedItem);
        if FHoveredItem >= Index then Inc(FHoveredItem);
        for I := 0 to Length(FLowSelection) - 1 do
            if FLowSelection[I] >= Index then Inc(FLowSelection[I]);
        if FLongestItem = vqInvalidValue then FLongestItem := 0;
        if Items[FLongestItem].Width < Items[Index].Width then
            FLongestItem := Index;
        Inc(FPageHeight, Items[Index].Height);
        FPageWidth := CalculatePageWidth;
        
        WorkRepaintFrom(Index);
        WorkUpdateScroll;
        EndWork;
        EndUpdate;
        EndSelection(SelModified);
    end;
end;

function TvqListBoxModel.Remove(Index: Integer): TvqListBoxItem; 
var
    SelModified: Boolean;
	I, J, sL, Delta, PrevVirtualTop: Integer;
	ANewLowSel: TIntArray;
begin
    if (Index >= 0) and (Index < Count) then begin
        BeginSelection;
        BeginUpdate;
        BeginWork;
        Delta := Items[Index].Height;
        PrevVirtualTop := TvqListBoxItemAccess(Items[FTopItem]).VirtualTop;
        Result := (inherited Remove(Index));
        
        if FLongestItem = Index then
            FLongestItem := vqInvalidValue
        else if FLongestItem > Index then
            Dec(FLongestItem);
        if FPressedItem = Index then
            FPressedItem := vqInvalidValue
        else if FPressedItem > Index then
            Dec(FPressedItem);
        if FHoveredItem = Index then
            FHoveredItem := vqInvalidValue
        else if FHoveredItem > Index then
            Dec(FHoveredItem);
        
        if FTopItem = Index then begin
            if Index = Count - 1 then
                FTopItem := Index - 1
            else
                FTopItem := Index;
            SetTopOffset(PrevVirtualTop);
        end
        else if FTopItem > Index then begin
            Dec(FTopItem);
            SetTopOffset(GetTopOffset - Delta);
        end;
        
        SelModified := False;
        if FSelAwning.Anchor <= FSelAwning.Caret then 
            SelModified := CorrectSelectionAwning(Index, FSelAwning.Anchor, FSelAwning.Caret)
        else 
            SelModified := CorrectSelectionAwning(Index, FSelAwning.Caret, FSelAwning.Anchor);
        
        J := 0;
        sL := Length(FLowSelection);
        SetLength(ANewLowSel, sL);
        for I := 0 to sL - 1 do
            if (FLowSelection[I] < Index) then begin
                ANewLowSel[J] := FLowSelection[I];
                Inc(J);
            end
            else if (FLowSelection[I] > Index) then begin
                ANewLowSel[J] := FLowSelection[I] - 1;
                Inc(J);
            end;
        SetLength(ANewLowSel, J);
        FLowSelection := ANewLowSel;
        ANewLowSel := nil;
        if J <> sL then SelModified := True;
        
        Dec(FPageHeight, Delta);
        FPageWidth := CalculatePageWidth;
        
        WorkRepaintFrom(Index);
        WorkUpdateScroll;
        EndWork;
        EndUpdate;
        EndSelection(SelModified);
    end
    else Result := nil;
end;

procedure TvqListBoxModel.Delete(Index: Integer);
var
    SelModified: Boolean;
	I, J, sL, Delta: Integer;
	ANewLowSel: TIntArray;
    PrevVirtualTop: Integer;
begin
    if (Index >= 0) and (Index < Count) then begin
        BeginSelection;
        BeginUpdate;
        BeginWork;
        Delta := Items[Index].Height;
        PrevVirtualTop := TvqListBoxItemAccess(Items[FTopItem]).VirtualTop;
        inherited Delete(Index);
        
        if FLongestItem = Index then
            FLongestItem := vqInvalidValue
        else if FLongestItem > Index then
            Dec(FLongestItem);
        if FPressedItem = Index then
            FPressedItem := vqInvalidValue
        else if FPressedItem > Index then
            Dec(FPressedItem);
        if FHoveredItem = Index then
            FHoveredItem := vqInvalidValue
        else if FHoveredItem > Index then
            Dec(FHoveredItem);
        
        if FTopItem = Index then begin
            if Index = Count - 1 then
                FTopItem := Index - 1
            else
                FTopItem := Index;
            SetTopOffset(PrevVirtualTop);
        end
        else if FTopItem > Index then begin
            Dec(FTopItem);
            SetTopOffset(GetTopOffset - Delta);
        end;
        
        SelModified := False;
        if FSelAwning.Anchor <= FSelAwning.Caret then 
            SelModified := CorrectSelectionAwning(Index, FSelAwning.Anchor, FSelAwning.Caret)
        else 
            SelModified := CorrectSelectionAwning(Index, FSelAwning.Caret, FSelAwning.Anchor);
        
        J := 0;
        sL := Length(FLowSelection);
        SetLength(ANewLowSel, sL);
        for I := 0 to sL - 1 do
            if (FLowSelection[I] < Index) then begin
                ANewLowSel[J] := FLowSelection[I];
                Inc(J);
            end
            else if (FLowSelection[I] > Index) then begin
                ANewLowSel[J] := FLowSelection[I] - 1;
                Inc(J);
            end;
        SetLength(ANewLowSel, J);
        FLowSelection := ANewLowSel;
        ANewLowSel := nil;
        if J <> sL then SelModified := True;
        
        Dec(FPageHeight, Delta);
        FPageWidth := CalculatePageWidth;
        
        WorkRepaintFrom(Index);
        WorkUpdateScroll;
        EndWork;
        EndUpdate;
        EndSelection(SelModified);
    end;
end;

procedure TvqListBoxModel.Exchange(Index1, Index2: Integer);
var
    I: Integer;
    SelModified: Boolean;
    AItem1, AItem2: TvqListBoxItem;
begin
    if  (Index1 <> Index2) and
        (Index1 >= 0) and (Index1 < Count) and
        (Index2 >= 0) and (Index2 < Count) then begin
        AItem1 := Items[Index1];
        AItem2 := Items[Index2];
        BeginSelection;
        BeginUpdate;
        BeginWork;
        if FSelAwning.Length > 1 then begin
            CoalesceAwningSel(False);
            SetSelectionAwning(FSelAwning.Caret, FSelAwning.Caret);
        end;
        inherited Exchange(Index1, Index2);
        if FLongestItem = Index1 then FLongestItem := Index2
        else if FLongestItem = Index2 then FLongestItem := Index1;
        // FPressedItem, FHoveredItem & FTopItem not changes
        
        SelModified := False;
        if FSelAwning.Valid then begin
            if FSelAwning.Caret = Index1 then begin
                FSelAwning.Caret := Index2;
                SelModified := True;
            end
            else if FSelAwning.Caret = Index2 then begin
                FSelAwning.Caret := Index1;
                SelModified := True;
            end;
            FSelAwning.Anchor := FSelAwning.Caret;
        end;
        
        if  TvqListBoxItemAccess(AItem1).GetLowSelected or 
            TvqListBoxItemAccess(AItem2).GetLowSelected then begin
            for I := 0 to Length(FLowSelection) - 1 do
                if FLowSelection[I] = Index1 then
                    FLowSelection[I] := Index2
                else if FLowSelection[I] = Index2 then
                    FLowSelection[I] := Index1;
            SelModified := True;
        end;
        
        WorkRepaintAll;
        WorkUpdateScroll;
        EndWork;
        EndUpdate;
        EndSelection(SelModified);
    end;
end;

procedure TvqListBoxModel.Move(CurIndex, NewIndex: Integer);
var
    SelModified: Boolean;
    I: Integer;
begin
    if  (CurIndex <> NewIndex) and
        (CurIndex >= 0) and (CurIndex < Count) and
        (NewIndex >= 0) and (NewIndex < Count) then begin
        BeginSelection;
        BeginUpdate;
        BeginWork;
        if (FSelAwning.Length > 1) then begin
            CoalesceAwningSel(False);
            SetSelectionAwning(FSelAwning.Caret, FSelAwning.Caret);
        end;
        inherited Move(CurIndex, NewIndex);
        // FPressedRow, FHoveredRow & FTopRow not changes
        
        SelModified := False;
        if CurIndex < NewIndex then begin
            if (FLongestItem >= CurIndex) and (FLongestItem <= NewIndex) then begin
                if FLongestItem = CurIndex then FLongestItem := NewIndex
                else Dec(FLongestItem);
            end;
            for I := 0 to Length(FLowSelection) - 1 do begin
                if (FLowSelection[I] >= CurIndex) and (FLowSelection[I] <= NewIndex) then begin
                    if FLowSelection[I] = CurIndex then FLowSelection[I] := NewIndex
                    else Dec(FLowSelection[I]);
                    SelModified := True;
                end;
            end;
            if (FSelAwning.Valid) and (FSelAwning.Caret >= CurIndex) and (FSelAwning.Caret <= NewIndex) then begin
                if FSelAwning.Caret = CurIndex then FSelAwning.Caret := NewIndex
                else Dec(FSelAwning.Caret);
                FSelAwning.Anchor := FSelAwning.Caret;
                SelModified := True;
            end;
        end
        else begin
            if (FLongestItem >= NewIndex) and (FLongestItem <= CurIndex) then begin
                if FLongestItem = CurIndex then FLongestItem := NewIndex
                else Inc(FLongestItem);
            end;
            for I := 0 to Length(FLowSelection) - 1 do begin
                if (FLowSelection[I] >= NewIndex) and (FLowSelection[I] <= CurIndex) then begin
                    if FLowSelection[I] = CurIndex then FLowSelection[I] := NewIndex
                    else Inc(FLowSelection[I]);
                    SelModified := True;
                end;
            end;
            if (FSelAwning.Valid) and (FSelAwning.Caret >= NewIndex) and (FSelAwning.Caret <= CurIndex) then begin
                if FSelAwning.Caret = CurIndex then FSelAwning.Caret := NewIndex
                else Inc(FSelAwning.Caret);
                FSelAwning.Anchor := FSelAwning.Caret;
                SelModified := True;
            end;
        end;
        
        WorkRepaintAll;
        WorkUpdateScroll;
        EndWork;
        EndUpdate;
        EndSelection(SelModified);
    end;
end;

procedure TvqListBoxModel.Fill(const AValue: string; AStart, AEnd: Integer);
begin
    if (AStart <= AEnd) and (AStart >= 0) and (AEnd < Count) then begin
        BeginUpdate;
        BeginWork;
        inherited Fill(AValue, AStart, AEnd);
        FLongestItem := vqInvalidValue;
        FPageWidth := CalculatePageWidth;
        
        WorkRepaintAll;
        WorkUpdateScroll;
        EndWork;
        EndUpdate;
    end;
end;

procedure TvqListBoxModel.Sort;
var
    ALongestItem: TvqListBoxItemAccess;
    ACaretItem: TvqListBoxItemAccess;
    ALowItems: array of TvqListBoxItemAccess;
    L, I: Integer;
begin
    if Count > 1 then begin
        BeginSelection;
        BeginUpdate;
        BeginWork;
        if FLongestItem <> vqInvalidValue then
            ALongestItem := TvqListBoxItemAccess(Items[FLongestItem])
        else
            ALongestItem := nil;
        
        if FSelAwning.Valid then begin
            CoalesceAwningSel(False);
            SetSelectionAwning(FSelAwning.Caret, FSelAwning.Caret);
            ACaretItem := TvqListBoxItemAccess(Items[FSelAwning.Caret]);
        end
        else ACaretItem := nil;
        
        L := Length(FLowSelection);
        SetLength(ALowItems, L);
        for I := 0 to L - 1 do
            ALowItems[I] := TvqListBoxItemAccess(Items[FLowSelection[I]]);
        
        inherited Sort;
        
        FPressedItem := vqInvalidValue;
        FHoveredItem := vqInvalidValue;
        FLongestItem := vqInvalidValue;
        if ALongestItem <> nil then FLongestItem := ALongestItem.Index;
        if ACaretItem <> nil then begin
            FSelAwning.Caret := ACaretItem.Index;
            FSelAwning.Anchor := FSelAwning.Caret;
        end;
        for I := 0 to L - 1 do
            if ALowItems[I] <> nil then
                FLowSelection[I] := ALowItems[I].Index;
        
        WorkRepaintAll;
        WorkUpdateScroll;
        EndWork;
        EndUpdate;
        EndSelection(FSelAwning.Valid or (FLowSelection <> nil));
    end;
end;

procedure TvqListBoxModel.CoalesceAwningSel(AIncludeCaret: Boolean = True);
var
    IsCaretSelected: Boolean;
    NewSel: TIntArray;
    I, L: Integer;
begin
    IsCaretSelected := (FSelAwning.Caret <> vqInvalidValue) and IsItemSelected(FSelAwning.Caret);
    InternalGetSelectedItems(NewSel, AIncludeCaret);
    for I := 0 to Length(FLowSelection) - 1 do
        TvqListBoxItemAccess(Items[FLowSelection[I]]).SetLowSelected(False);
	FLowSelection := NewSel;
    L := Length(FLowSelection);
	for I := 0 to L - 1 do
        TvqListBoxItemAccess(Items[FLowSelection[I]]).SetLowSelected(True);
	if not AIncludeCaret and not IsCaretSelected then begin
        SetLength(FLowSelection, L + 1);
        FLowSelection[L] := FSelAwning.Caret;
    end;
    NewSel := nil;
end;

procedure TvqListBoxModel.SetSelectionAwning(AAnchor, ACaret: Integer);
var
    SelModified: Boolean;
begin
    BeginSelection;
    BeginWork;
    with FSelAwning do begin
        SelModified := False;
        if not FMultiSelect then
            AAnchor := ACaret;
        
        if AAnchor < 0 then AAnchor := 0;
        if AAnchor >= Count then AAnchor := Count - 1;
        if ACaret < 0 then ACaret := 0;
        if ACaret >= Count then ACaret := Count - 1;
        
        if InactiveItem(AAnchor) then AAnchor := Anchor;
        if InactiveItem(ACaret) then ACaret := Caret;
        
		if (Anchor = vqInvalidValue) or (Caret = vqInvalidValue) then begin
			Anchor := AAnchor;
			Caret := ACaret;
            SelModified := True;
			if Anchor < Caret then
                WorkRepaintRange(Anchor, Caret)
			else 
                WorkRepaintRange(Caret, Anchor);
		end
		else begin
			if Anchor <= Caret then
                WorkRepaintRange(Anchor, Caret)
			else
                WorkRepaintRange(Caret, Anchor);
			Anchor := AAnchor;
			Caret := ACaret;
            SelModified := True;
			if Anchor <= Caret then
                WorkRepaintRange(Anchor, Caret)
			else
                WorkRepaintRange(Caret, Anchor);
		end;
    end;
    EndWork;
    EndSelection(SelModified);
end;

procedure TvqListBoxModel.GetSelectionAwning(var AAnchor, ACaret: Integer);
begin
    AAnchor := FSelAwning.Anchor;
    ACaret := FSelAwning.Caret;
end;

procedure TvqListBoxModel.EraseLowSelection;
var
	I, L, Index: Integer;
    Flags: Word;
begin
    if FLowSelection = nil then Exit;
    BeginSelection;
    BeginWork;
	L := Length(FLowSelection);
	for I := 0 to L - 1 do begin
        Index := FLowSelection[I];
        TvqListBoxItemAccess(Items[Index]).SetLowSelected(False);
        WorkRepaintRange(Index, Index);
    end;
	FLowSelection := nil;
    EndWork;
    EndSelection(True);
end;

procedure TvqListBoxModel.CollapseSelection;
begin
    BeginSelection;
    BeginWork;
    if FSelAwning.Valid then
        SetSelectionAwning(FSelAwning.Caret, FSelAwning.Caret);
    EraseLowSelection;
    EndWork;
    EndSelection(False);
end;

procedure TvqListBoxModel.GetSelectedItems(var ASel: TIntArray);
begin
    InternalGetSelectedItems(ASel, True);
end;

procedure TvqListBoxModel.SetSelectedItems(const ASel: array of Integer);
var
    I, L: Integer;
begin
    if Length(ASel) = 0 then begin
        ClearSelection;
        Exit;
    end;
    BeginSelection;
    BeginWork;
    L := Length(ASel);
    if L = 0 then begin
        FLowSelection := nil;
        FSelAwning.Invalidate;
    end
    else if L = 1 then
        SetSelectionAwning(ASel[0], ASel[0])
    else begin
        SetLength(FLowSelection, Length(ASel));
        for I := 0 to Length(ASel) - 2 do
            if (ASel[I] >= 0) and (ASel[I] < Count) and 
                not InactiveItem(ASel[I]) then
                FLowSelection[I] := ASel[I];
        SetSelectionAwning(ASel[L - 1], ASel[L - 1]);
    end;
    EndWork;
    EndSelection(False);
end;

procedure TvqListBoxModel.ClearSelection;
var
    SelModified: Boolean;
begin
    BeginSelection;
    BeginWork;
    SelModified := False;
    if FSelAwning.Valid then begin
        SelModified := True;
        FSelAwning.Invalidate;
    end;
    EraseLowSelection;
    EndWork;
    EndSelection(SelModified);
end;

function TvqListBoxModel.CorrectSelectionAwning(ARemoveIndex: Integer;
    var AStart, AEnd: Integer): Boolean;
begin
    Result := False;
	if AStart > ARemoveIndex then begin
		Dec(AStart);
		Dec(AEnd);
	end
	else if AStart = ARemoveIndex then begin
		if AEnd > ARemoveIndex then begin
			Dec(AEnd);
			AStart := ARemoveIndex;
            Result := True;
		end
		else begin
			AStart := vqInvalidValue;
			AEnd := vqInvalidValue;
            Result := True;
		end;
	end
	else begin
		if AEnd >= ARemoveIndex then begin
            Dec(AEnd);
            Result := True;
        end;
	end;
end;

procedure TvqListBoxModel.InternalGetSelectedItems(var ASel: TIntArray; AIncludeCaret: Boolean);
var 
	I, J, L, nL, Mn, Mx: Integer;
begin
	L := Length(FLowSelection);
	nL := L;
	J := 0;
	SetLength(ASel, nL);
	with FSelAwning do begin
        if not Valid then begin
            for I := 0 to L - 1 do
                ASel[I] := FLowSelection[I];
            Exit;
        end
		else if Anchor <= Caret then begin
			Mn := Anchor;
			Mx := Caret;
		end
		else begin
			Mn := Caret;
			Mx := Anchor;
		end;
		for I := 0 to L - 1 do
			if (FLowSelection[I] >= Mn) and (FLowSelection[I] <= Mx) then
				Dec(nL)
			else begin
				ASel[J] := FLowSelection[I];
				Inc(J);
			end;
		if not TvqListBoxItemAccess(Items[Anchor]).GetLowSelected then begin
			Inc(nL, Mx - Mn + 1);
			SetLength(ASel, nL);
			for I := Mn to Mx do begin
                if InactiveItem(I) then
                    Continue;
                if not AIncludeCaret and (I = Caret) then
                    Continue;
				ASel[J] := I;
				Inc(J);
			end;
		end
		else
			SetLength(ASel, nL);
	end;
end;

function TvqListBoxModel.IsItemSelected(Index: Integer): Boolean;
begin
    if InactiveItem(Index) then
        Result := False
    else if FSelAwning.Selected(Index) then 
        Result := not TvqListBoxItemAccess(Items[Index]).GetLowSelected
    else if (Index >= 0) and (Index < Count) then
        Result := TvqListBoxItemAccess(Items[Index]).GetLowSelected
    else Result := False;
end;

procedure TvqListBoxModel.SetHoveredItem(Index: Integer);
begin
    if InactiveItem(Index) then
        Index := -1;
    if FHoveredItem <> Index then begin
        BeginWork;
        FHoveredItem := Index;
        WorkRepaintRange(FHoveredItem, FHoveredItem);
        EndWork;
    end;    
end;

procedure TvqListBoxModel.SetPressedItem(Index: Integer);
begin
    if InactiveItem(Index) then
        Index := -1;
    if FPressedItem <> Index then begin
        BeginWork;
        FPressedItem := Index;
        WorkRepaintRange(FPressedItem, FPressedItem);
        EndWork;
    end;    
end;

procedure TvqListBoxModel.SetTopItem(Value: Integer);
begin
    if Count = 0 then Value := -1
    else if Value < 0 then Value := 0
    else if Value >= Count then Value := Count - 1;
    if (FTopItem <> Value) then begin
        BeginWork;
        FTopItem := Value;
        SetTopOffset(TvqListBoxItemAccess(Items[FTopItem]).VirtualTop);
        WorkUpdateScroll;
        EndWork;
    end;
end;

procedure TvqListBoxModel.SetMultiSelect(Value: Boolean);
begin
    if FMultiSelect <> Value then begin
        FMultiSelect := Value;
        if not FMultiSelect then
            CollapseSelection;
    end;
end;

function TvqListBoxModel.CalculatePageWidth: Integer;
var
    I: Integer;
begin
    if Count = 0 then
        Exit(0);
    if FLongestItem = vqInvalidValue then begin
        FLongestItem := 0;
        for I := 1 to Count - 1 do
            if Items[I].Width > Items[FLongestItem].Width then
                FLongestItem := I;
    end;
    Result := Items[FLongestItem].Width;
end;

procedure TvqListBoxModel.ItemSizeChanged(Index: Integer; DeltaX, DeltaY: Integer);
begin
    if Inserting then Exit;
    if (Index >= 0) and (Index < Count) then begin
        inherited ItemSizeChanged(Index, DeltaX, DeltaY);
        if DeltaY <> 0 then WorkRepaintFrom(Index);
        Inc(FPageHeight, DeltaY);
        if FLongestItem = Index then
            if DeltaX < 0 then
                FLongestItem := vqInvalidValue;
        FPageWidth := CalculatePageWidth;
        WorkUpdateScroll;
    end;
end;

procedure TvqListBoxModel.Measure(AStart, AEnd: Integer); 
var
    I, Delta: Integer;
begin
    if (AEnd >= AStart) and (AStart >= 0) and (AEnd < Count - 1) then begin
        BeginWork;
        inherited Measure(AStart, AEnd);
        FLongestItem := vqInvalidValue;
        FPageHeight := 0;
        for I := 0 to Count - 1 do
            Inc(FPageHeight, Items[I].Height);
        FPageWidth := CalculatePageWidth;
        WorkRepaintAll;
        WorkUpdateScroll;
        EndWork;
    end;
end;

procedure TvqListBoxModel.BeginSelection;
begin
    if FSelectionDepth = 0 then FSelectionModified := False;
    Inc(FSelectionDepth);
end;

procedure TvqListBoxModel.EndSelection(AModified: Boolean);
begin
    FSelectionModified := FSelectionModified or AModified;
    Dec(FSelectionDepth);
    if FSelectionDepth = 0 then begin
        SelChanged;
        FSelectionModified := False;
    end;
end;

procedure TvqListBoxModel.SelChanged;
begin
    if FSelectionDepth = 0 then
        if FSelectionModified then
            ListBox._NotifySelChanged;
end;

procedure TvqListBoxModel.Changed;
begin
    inherited;
    if UpdateCount = 0 then
        ListBox._NotifyChanged;
end;

procedure TvqListBoxModel.Changing;
begin
    inherited;
    if UpdateCount = 0 then
        ListBox._NotifyChanging;
end;

procedure TvqListBoxModel.WorkRepaintAll;
begin
    FListBox.WorkRepaintAll;
end;

procedure TvqListBoxModel.WorkRepaintFrom(AFrom: Integer);
begin
    FListBox.WorkRepaintFrom(AFrom);
end;

procedure TvqListBoxModel.WorkUpdateScroll;
begin
    FListBox.WorkUpdateScroll;
end;

procedure TvqListBoxModel.WorkRepaintRange(AStart, AEnd: Integer);
begin
    FListBox.WorkRepaintRange(AStart, AEnd);
end;

procedure TvqListBoxModel.BeginWork;
begin
    FListBox.BeginWork;
end;

procedure TvqListBoxModel.EndWork;
begin
    FListBox.EndWork;
end;

function TvqListBoxModel.InactiveItem(Index: Integer): Boolean;
begin
    Result := FListBox.InactiveItem(Index);
end;

procedure TvqListBoxModel.SetTopOffset(Value: Integer);
begin
    FListBox._ModifyTopOffset(Value);
end;

function TvqListBoxModel.GetTopOffset: Integer;
begin
    FListBox._RetrieveTopOffset(Result);
end;

end.
