// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqListBoxBuffer;

interface
                   
uses
    Types, SysUtils, Classes, Graphics, Dialogs,
    vqUtils, vqStringList, vqListBoxUtils;

type
    
    TvqListBoxStrings = class;
    
	TvqListBoxItem = class(TvqStringItem)
	private
        FLowSelected: Boolean;
        
		FWidth: Integer;
        FHeight: Integer;
        FImageIndex: Integer;
        
		FListBox: IvqListBoxListener;
        FVirtualTop: Integer;
        procedure SetImageIndex(Value: Integer);
    protected                              
        procedure Measure;
        procedure SetLowSelected(Value: Boolean);
        function GetLowSelected: Boolean;
        
        procedure Update; override;
        procedure Changed; override;
        
        property VirtualTop: Integer read FVirtualTop;
        property ListBox: IvqListBoxListener read FListBox write FListBox;
    public
        constructor Create(AStrings: TvqStringList; AIndex: Integer); override;
		destructor Destroy; override;
		procedure Assign(Source: TPersistent); override;
		function Selected: Boolean;
		property Width: Integer read FWidth;
	    property Height: Integer read FHeight;
    published
        property ImageIndex: Integer read FImageIndex write SetImageIndex;
    end;
    
    TvqListBoxStrings = class(TvqStringList)
    protected
        FInserting: Boolean;
        FListBox: IvqListBoxListener;
        function GetItem(Index: Integer): TvqListBoxItem;
        procedure SetItem(Index: Integer; Value: TvqListBoxItem);
        procedure ItemSizeChanged(Index: Integer; DeltaX, DeltaY: Integer); virtual;
        property ListBox: IvqListBoxListener read FListBox write FListBox;
    protected
        property Inserting: Boolean read FInserting;
    public
        constructor Create(AItemClass: TvqStringItemClass); override;
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        
        function Remove(Index: Integer): TvqListBoxItem; override;
        procedure Insert(Index: Integer; const S: string); override;
        procedure Delete(Index: Integer); override;
        procedure Exchange(Index1, Index2: Integer); override;
        procedure Move(CurIndex, NewIndex: Integer); override;
        procedure Sort; override;
        
        procedure Measure(AStart, AEnd: Integer); virtual;
        
        property Items[Index: Integer]: TvqListBoxItem read GetItem write SetItem;
    end;
    
implementation

{ TvqListBoxItem }

constructor TvqListBoxItem.Create(AStrings: TvqStringList; AIndex: Integer);
begin
	inherited Create(AStrings, AIndex);
    if AStrings is TvqListBoxStrings then
        FListBox := TvqListBoxStrings(AStrings).FListBox
    else
        FListBox := nil;
    
	FWidth := 0;
    FHeight := 15;
    FImageIndex := -1;
end;

destructor TvqListBoxItem.Destroy;
begin
    FListBox := nil;
	inherited;
end;

procedure TvqListBoxItem.Assign(Source: TPersistent);
begin
	if (Source is TvqListBoxItem) and (Source <> Self) then begin
        if Strings <> nil then Strings.BeginUpdate;
        FImageIndex := TvqListBoxItem(Source).FImageIndex;
        inherited Assign(Source);
        if Strings <> nil then Strings.EndUpdate;
    end
    else
        inherited Assign(Source);
end;

function TvqListBoxItem.Selected: Boolean;
begin
    if FListBox <> nil then
        Result := FListBox._ItemSelected(Index)
    else
        Result := False;
end;

procedure TvqListBoxItem.SetImageIndex(Value: Integer);
begin
    if FImageIndex <> Value then begin
        if Strings <> nil then Strings.BeginUpdate;
        FImageIndex := Value;
        Update;
        Changed;
        if Strings <> nil then Strings.EndUpdate;
    end;
end;

procedure TvqListBoxItem.Update;
var
    PrevWidth, PrevHeight: Integer;
    DeltaX, DeltaY: Integer;
begin
    if FListBox <> nil then begin
        FListBox.BeginWork;
        
        PrevWidth := FWidth;
        PrevHeight := FHeight;
        // calculate metrics
        Measure;
        
        if (PrevWidth <> FWidth) or (PrevHeight <> FHeight) then begin
            DeltaX := PrevWidth - FWidth;
            DeltaY := PrevHeight - FHeight;
            
            if Strings <> nil then
                if Strings is TvqListBoxStrings then
                    TvqListBoxStrings(Strings).ItemSizeChanged(Index, DeltaX, DeltaY);
        end;
        
        // repaint
        FListBox.WorkRepaintItem(Index);
        FListBox.EndWork;
    end;
end;

procedure TvqListBoxItem.Changed;
begin
    if FListBox <> nil then FListBox._NotifyItemChange(Index);
end;

procedure TvqListBoxItem.Measure;
begin // measure only
    FListBox._MeasureItem(Index, FWidth, FHeight);
    if FWidth < 0 then FWidth := 0;
    if FHeight < 0 then FHeight := 0;
end;

procedure TvqListBoxItem.SetLowSelected(Value: Boolean);
begin
    FLowSelected := Value;
end;

function TvqListBoxItem.GetLowSelected: Boolean;
begin
    Result := FLowSelected;
end;

{ TvqListBoxStrings }

constructor TvqListBoxStrings.Create(AItemClass: TvqStringItemClass);
begin
    inherited Create(AItemClass);
    FListBox := nil;
end;

destructor TvqListBoxStrings.Destroy;
begin
    inherited;
end;

procedure TvqListBoxStrings.Assign(Source: TPersistent);
begin
    inherited Assign(Source);
end;

function TvqListBoxStrings.Remove(Index: Integer): TvqListBoxItem;
var
    I: Integer;
    Delta: Integer;
begin
    if (Index >= 0) and (Index < Count) then begin
        BeginUpdate;
        Result := TvqListBoxItem(inherited Remove(Index));
        Delta := Result.Height;
        for I := Index to Count - 1 do
            Dec(Items[I].FVirtualTop, Delta);
        Result.FLowSelected := False;
        Result.FVirtualTop := 0;
        Result.FListBox := nil;
        EndUpdate;
    end
    else Result := nil;
end;

procedure TvqListBoxStrings.Insert(Index: Integer; const S: string);
var
    PrevItem: TvqListBoxItem;
    I, Delta: Integer;
begin
    if (Index >= 0) and (Index <= Count) then begin
        BeginUpdate;
        FInserting := True;
        inherited Insert(Index, S);
        if Index = 0 then
            Items[Index].FVirtualTop := 0
        else begin
            PrevItem := Items[Index - 1];
            Items[Index].FVirtualTop := PrevItem.FVirtualTop + 
                                        PrevItem.Height;
        end;
        Delta := Items[Index].Height;
        for I := Index + 1 to Count - 1 do
            Inc(Items[I].FVirtualTop, Delta);
        FInserting := False;
        EndUpdate;
    end;
end;

procedure TvqListBoxStrings.Delete(Index: Integer);
var
    I: Integer;
    Delta: Integer;
begin
    if (Index >= 0) and (Index < Count) then begin
        BeginUpdate;
        Delta := Items[Index].Height;
        inherited Delete(Index);
        for I := Index to Count - 1 do
            Dec(Items[I].FVirtualTop, Delta);
        EndUpdate;
    end;
end;

procedure TvqListBoxStrings.Exchange(Index1, Index2: Integer);
var
    I, Y, First, Last: Integer;
begin
    if  (Index1 <> Index2) and
        (Index1 >= 0) and (Index1 < Count) and
        (Index2 >= 0) and (Index2 < Count) then begin
        BeginUpdate;
        if Index1 < Index2 then begin
            First := Index1;
            Last := Index2;
        end
        else begin
            First := Index2;
            Last := Index1;
        end;
        Y := Items[First].FVirtualTop;
        inherited Exchange(Index1, Index2);
        for I := First to Last do begin
            Items[I].FVirtualTop := Y;
            Inc(Y, Items[I].Height);
        end;
        EndUpdate;
    end;
end;

procedure TvqListBoxStrings.Move(CurIndex, NewIndex: Integer);
var
    I, Y, First, Last: Integer;
begin
    if  (CurIndex <> NewIndex) and
        (CurIndex >= 0) and (CurIndex < Count) and
        (NewIndex >= 0) and (NewIndex < Count) then begin
        BeginUpdate;
        if CurIndex < NewIndex then begin
            First := CurIndex;
            Last := NewIndex;
        end
        else begin
            First := NewIndex;
            Last := CurIndex;
        end;
        Y := Items[First].FVirtualTop;
        inherited Move(CurIndex, NewIndex);
        for I := First to Last do begin
            Items[I].FVirtualTop := Y;
            Inc(Y, Items[I].Height);
        end;
        EndUpdate;
    end;
end;

procedure TvqListBoxStrings.Sort;
var
    Y, I: Integer;
begin
    BeginUpdate;
    inherited Sort;
    Y := 0;
    for I := 0 to Count - 1 do begin
        Items[I].FVirtualTop := Y;
        Inc(Y, Items[I].Height);
    end;
    EndUpdate;
end;

procedure TvqListBoxStrings.ItemSizeChanged(Index: Integer; DeltaX, DeltaY: Integer);
var
    I: Integer;
begin
    if Inserting then Exit;
    if (Index >= 0) and (Index < Count) then begin
        for I := Index + 1 to Count - 1 do
            Inc(Items[I].FVirtualTop, DeltaY);
    end;
end;

procedure TvqListBoxStrings.Measure(AStart, AEnd: Integer);
var
    I, Y: Integer;
begin
    if (AEnd >= AStart) and (AStart >= 0) and (AEnd < Count) then begin
        for I := AStart to AEnd do
            Items[I].Measure;
        Y := Items[AStart].FVirtualTop;
        for I := AStart to Count - 1 do begin
            Items[I].FVirtualTop := Y;
            Inc(Y, Items[I].Height);
        end;
    end;
end;

function TvqListBoxStrings.GetItem(Index: Integer): TvqListBoxItem;
begin
    Result := TvqListBoxItem(inherited GetItem(Index));
end;

procedure TvqListBoxStrings.SetItem(Index: Integer; Value: TvqListBoxItem);
begin
    inherited SetItem(Index, Value);
end;

end.
