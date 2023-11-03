// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqStringList;

interface
         
uses
    InterfaceBase, LclIntf, LclType, LMessages, LResources,
    Types, SysUtils, SysConst, Classes, Graphics, Controls, Math,
    Dialogs,
    vqUtils;

type

    TvqStringList = class;

    TvqStringItem = class(TPersistent)
    private
        FRemoving: Boolean;

        FIndex: Integer;
        FText: string;
        FData: Longint;
        FStrings: TvqStringList;
        procedure SetIndex(Value: Integer);
		procedure SetText(Value: string);
        procedure SetData(Value: Longint);
    protected
        procedure Update; virtual;
        procedure Changed; virtual;
        
        property Strings: TvqStringList read FStrings;
    public
        constructor Create(AStrings: TvqStringList; AIndex: Integer); virtual;
		destructor Destroy; override;
		procedure Assign(Source: TPersistent); override;
		property Index: Integer read FIndex write SetIndex;
    published
		property Text: string read FText write SetText;
        property Data: Longint read FData write SetData;
    end;
    
    TvqStringItemClass = class of TvqStringItem;
    TvqStringListSorter = specialize TSorter<TvqStringItem>;
    TvqStringListComparer = TvqStringListSorter.TComparerFunction;
    
    TvqStringList = class(TStrings)
    protected type
        TStringItemArray = array of TvqStringItem;
    private
        FList: TStringItemArray;
        FCount: Integer;
        
        FDuplicates: Boolean;
        FCaseSensitive: Boolean;
        FSorted: Boolean;
        FOnChange: TNotifyEvent;
        FOnChanging: TNotifyEvent;
        FCompareMethod: TvqStringListComparer;
        FItemClass: TvqStringItemClass;
        function GetData(Index: Integer): Longint;
        procedure SetData(Index: Integer; Value: Longint);
        procedure SetSorted(Value: Boolean);
        procedure SetCaseSensitive(Value: Boolean);
        procedure SetDuplicates(Value: Boolean);
        procedure SetCompareMethod(Value: TvqStringListComparer);
        
        procedure InternalClear(AFrom: Integer = 0);
    protected                                  
        procedure SetItem(Index: Integer; Value: TvqStringItem);
        function GetItem(Index: Integer): TvqStringItem;
        procedure Changed; virtual;
        procedure Changing; virtual;
        
        function Get(Index: Integer): string; override;
        function GetCapacity: Integer; override;
        function GetCount: Integer; override;
        function GetObject(Index: Integer): TObject; override;
        
        procedure Put(Index: Integer; const S: string); override;
        procedure PutObject(Index: Integer; AObject: TObject); override;
        procedure SetCapacity(NewCapacity: Integer); override;
        
        procedure SetUpdateState(Updating: Boolean); override;
        function DoCompareText(const S1, S2 : string): PtrInt; override;
    public
        function AddData(const S: string; const D: Longint): Integer; virtual;
        procedure InsertData(Index: Integer; const S: string; const D: Longint); virtual;
                                     
        constructor Create; virtual;
        constructor Create(AItemClass: TvqStringItemClass); virtual;
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        
        function Remove(Index: Integer): TvqStringItem; virtual;
        function Add(const S: string): Integer; override;
        procedure Insert(Index: Integer; const S: string); override;
        procedure Delete(Index: Integer); override;
        procedure Clear; override;
        procedure Exchange(Index1, Index2: Integer); override;
        procedure Move(CurIndex, NewIndex: Integer); override;
        procedure Fill(const AValue: String; AStart, AEnd : Integer); virtual;
        
        function IndexOfObject(AObject: TObject): Integer; override;
        function Find(const S: string; Out Index: Integer): Boolean; virtual;
        procedure Sort; virtual;
        
        property Datas[Index: Integer]: Longint read GetData write SetData;
        property Duplicates: Boolean read FDuplicates write FDuplicates;
        property Sorted: Boolean read FSorted write SetSorted;
        property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
        property Items[Index: Integer]: TvqStringItem read GetItem write SetItem;
        property CompareMethod: TvqStringListComparer read FCompareMethod write SetCompareMethod;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
        property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    end;
    
    TvqStringItems = class(TPersistent)
    private
        FStrings: TvqStringList;
        function GetItem(Index: Integer): TvqStringItem;
        procedure SetItem(Index: Integer; Value: TvqStringItem);
    public
        constructor Create(AStrings: TvqStringList);
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        function Count: Integer;
        property Item[Index: Integer]: TvqStringItem read GetItem write SetItem; default;
    end;
    
implementation

{ TvqStringItem }

constructor TvqStringItem.Create(AStrings: TvqStringList; AIndex: Integer);
begin
	inherited Create;
    FStrings := AStrings;
    
    FIndex := AIndex;
    FText := '';
    
    FRemoving := False;
end;

destructor TvqStringItem.Destroy;
begin
    FRemoving := True;
    //# if FStrings <> nil then FStrings.Remove(FIndex);
	inherited;
end;

procedure TvqStringItem.Assign(Source: TPersistent);
var
    Other: TvqStringItem;
begin
	if (Source is TvqStringItem) and (Source <> Self) then begin
        if FStrings <> nil then FStrings.BeginUpdate;
        Other := TvqStringItem(Source);
        FText := Other.FText;
        FData := Other.FData;
        Update;
        Changed;
        if FStrings <> nil then FStrings.EndUpdate;
    end
    else inherited;
end;

procedure TvqStringItem.SetIndex(Value: Integer);
begin
    if FIndex <> Value then begin
        if FStrings <> nil then
            FStrings.Move(FIndex, Value)
        else
            FIndex := Value;
    end;
end;

procedure TvqStringItem.SetText(Value: string);
begin
    if FText <> Value then begin
        if FStrings <> nil then FStrings.BeginUpdate;
        FText := Value;
        Update;
        Changed;
        if FStrings <> nil then FStrings.EndUpdate;
    end;
end;

procedure TvqStringItem.SetData(Value: Longint);
begin
    if FData <> Value then begin
        if FStrings <> nil then FStrings.BeginUpdate;
        FData := Value;
        Update;
        Changed;
        if FStrings <> nil then FStrings.EndUpdate;
    end;
end;

procedure TvqStringItem.Update;
begin
end;

procedure TvqStringItem.Changed;
begin
end;

{ TvqStringList }

constructor TvqStringList.Create;
begin
    Create(TvqStringItem);
end;

constructor TvqStringList.Create(AItemClass: TvqStringItemClass);
begin
    inherited Create;
    FItemClass := AItemClass;
    FCount := 0;
    FDuplicates := True;
    FCaseSensitive := False;
    FSorted := False;
    FList := nil;
end;

destructor TvqStringList.Destroy;
begin
    InternalClear;
    inherited;
end;

procedure TvqStringList.Assign(Source: TPersistent);
begin
    inherited Assign(Source);
end;

function TvqStringList.Remove(Index: Integer): TvqStringItem;
var
    I: Integer;
begin
    if (Index >= 0) and (Index < Count) then begin
        BeginUpdate;
        Result := FList[Index];
        FList[Index] := nil;
        for I := Index to Count - 2 do begin
            FList[I] := FList[I + 1];
            FList[I].FIndex := I;
        end;
        Result.FStrings := nil;
        Result.FIndex := -1;
        Dec(FCount);
        EndUpdate;
    end
    else Result := nil;
end;

function TvqStringList.Add(const S: string): Integer;
begin
    if not FDuplicates then
        if Find(S, Result) then
            Exit;
    Result := (inherited Add(S));
end;

procedure TvqStringList.Insert(Index: Integer; const S: string);
var
    I: Integer;
begin
    if (Index >= 0) and (Index <= FCount) then begin
        BeginUpdate;
        if FCount = Capacity then SetCapacity(FCount + 32);
        if Index < FCount then
            for I := FCount downto Index + 1 do begin
                FList[I] := FList[I - 1];
                FList[I].FIndex := I;
            end;                                      
        Inc(FCount);
        FList[Index] := FItemClass.Create(Self, Index);
        FList[Index].Text := S;
        EndUpdate;
    end;
end;

procedure TvqStringList.Delete(Index: Integer);
var
    I: Integer;
begin
    if (Index >= 0) and (Index < FCount) then begin
        BeginUpdate;
        if not FList[Index].FRemoving then begin
            FList[Index].FRemoving := True;
            FList[Index].Free;
            FList[Index] := nil;
        end;
        for I := Index to Count - 2 do begin
            FList[I] := FList[I + 1];
            FList[I].FIndex := I;
        end;
        Dec(FCount);
        EndUpdate;
    end;
end;

procedure TvqStringList.Clear;
begin
    if FCount > 0 then begin
        BeginUpdate;
        InternalClear;
        EndUpdate;
    end;
end;

procedure TvqStringList.Exchange(Index1, Index2: Integer);
var
    Aux: TvqStringItem;
begin
    if  (Index1 <> Index2) and
        (Index1 >= 0) and (Index1 < Count) and
        (Index2 >= 0) and (Index2 < Count) then begin
        BeginUpdate;
        Aux := FList[Index1];
        FList[Index1] := FList[Index2];
        FList[Index2] := Aux;
        EndUpdate;
    end;
end;

procedure TvqStringList.Move(CurIndex, NewIndex: Integer);
var
    AItem: TvqStringItem;
    I: Integer;
begin
    if  (CurIndex <> NewIndex) and
        (CurIndex >= 0) and (CurIndex < Count) and
        (NewIndex >= 0) and (NewIndex < Count) then begin
        BeginUpdate;
        AItem := FList[CurIndex];
        if (CurIndex < NewIndex) then
            for I := CurIndex to NewIndex - 1 do begin
                FList[I] := FList[I + 1];
                FList[I].FIndex := I;
            end
        else
            for I := CurIndex downto NewIndex + 1 do begin
                FList[I] := FList[I - 1];
                FList[I].FIndex := I;
            end;
        FList[NewIndex] := AItem;
        AItem.FIndex := NewIndex;
        EndUpdate;
    end;
end;

procedure TvqStringList.Fill(const AValue: String; AStart, AEnd : Integer);
begin
    if (AStart <= AEnd) and (AStart >= 0) and (AEnd < Count) then begin
        BeginUpdate;
        inherited Fill(AValue, AStart, AEnd);
        EndUpdate;
    end;
end;

function TvqStringList.IndexOfObject(AObject: TObject): Integer;
begin
    Result := -1;
    if AObject is TvqStringItem then
        if TvqStringItem(AObject).Strings = Self then
            Result := TvqStringItem(AObject).Index;
end;

function TvqStringList.Find(const S: string; Out Index: Integer): Boolean;
var
    I, AUpper, ALower, AMiddle, R: Integer;
begin //! use sorted
    Index := -1;{
    if Sorted then begin
        // binary search
        ALower := 0;
        AUpper := FCount - 1;
        repeat
            AMiddle := (ALower + AUpper + 1) div 2;
            R := DoCompareText(S, FList[AMiddle].Text);
            if R > 0 then ALower := AMiddle
            else AUpper := AMiddle;
        until ALower >= AUpper;
        Index := ALower;
    end
    else}
        for I := 0 to Count - 1 do
            if FList[I].Text = S then begin
                Index := I;
                Break;
            end;
    Result := Index <> -1;
end;

procedure TvqStringList.Sort;
begin //!
    BeginUpdate;
    TvqStringListSorter.Sort(TvqStringListSorter.TTArray(FList), 
        FCompareMethod,
        True, FCount);
    EndUpdate;
    FSorted := True;
end;

procedure TvqStringList.Changed;
begin
    if UpdateCount = 0 then begin
        FSorted := False;
        if Assigned(FOnChange) then FOnChange(Self);
    end;
end;

procedure TvqStringList.Changing;
begin
    if UpdateCount = 0 then
        if Assigned(FOnChanging) then FOnChanging(Self);
end;

function TvqStringList.Get(Index: Integer): string;
begin
    if (Index >= 0) and (Index < Count) then
        Result := FList[Index].Text
    else
        Result := '';
end;

function TvqStringList.GetCapacity: Integer; 
begin
    Result := Length(FList);
end;

function TvqStringList.GetCount: Integer; 
begin
    Result := FCount;
end;

function TvqStringList.GetObject(Index: Integer): TObject; 
begin
    if (Index >= 0) and (Index < FCount) then
        Result := FList[Index]
    else
        Result := nil;
end;

procedure TvqStringList.Put(Index: Integer; const S: string);
begin
    if (Index >= 0) and (Index < FCount) then
        FList[Index].Text := S;
end;

procedure TvqStringList.PutObject(Index: Integer; AObject: TObject);
begin
    if (Index >= 0) and (Index < FCount) then 
        if AObject is TPersistent then
            FList[Index].Assign(TPersistent(AObject));
end;

procedure TvqStringList.SetCapacity(NewCapacity: Integer);
begin
    if NewCapacity < 0 then
        Error(SListCapacityError, NewCapacity);
    if NewCapacity > Capacity then
        SetLength(FList, NewCapacity)
    else if NewCapacity < Capacity then begin
        if NewCapacity = 0 then begin
            if FCount > 0 then
                InternalClear;
            FList := nil;
        end
        else begin
            InternalClear(NewCapacity);
            SetLength(FList, NewCapacity);
        end;
    end;
end;

procedure TvqStringList.SetUpdateState(Updating: Boolean);
begin
    if Updating then 
        Changing
    else
        Changed;
end;

function TvqStringList.DoCompareText(const S1, S2 : string): PtrInt;
begin //!
    if FCaseSensitive then
        if UseLocale then
            Result := AnsiCompareStr(S1, S2)
        else
            Result := CompareStr(S1, S2)
    else
        if UseLocale then
            Result := AnsiCompareText(S1, S2)
        else
            Result := CompareText(S1, S2);
end;

function TvqStringList.GetItem(Index: Integer): TvqStringItem;
begin
    if (Index >= 0) and (Index < FCount) then
        Result := FList[Index]
    else
        Result := nil;
end;

procedure TvqStringList.SetItem(Index: Integer; Value: TvqStringItem);
begin
    if (Index >= 0) and (Index < FCount) then
        FList[Index].Assign(Value);
end;

procedure TvqStringList.SetSorted(Value: Boolean);
begin
    FSorted := Value;
end;

procedure TvqStringList.SetCaseSensitive(Value: Boolean);
begin
    if FCaseSensitive <> Value then begin
        FCaseSensitive := Value;
        FSorted := False;
    end;
end;

procedure TvqStringList.SetDuplicates(Value: Boolean);
begin
    if FDuplicates <> Value then begin
        FDuplicates := Value;
        FSorted := False;
    end;
end;

procedure TvqStringList.SetCompareMethod(Value: TvqStringListSorter.TComparerFunction);
begin //!
    if FCompareMethod <> Value then begin
        FCompareMethod := Value;
        FSorted := False;
    end;
end;

procedure TvqStringList.InternalClear(AFrom: Integer = 0);
var
    I: Integer;
begin
    for I := AFrom to FCount - 1 do
        FList[I].Free;
    FCount := AFrom;
    if AFrom = 0 then
        FList := nil;
end;

function TvqStringList.GetData(Index: Integer): Longint;
begin
    if (Index >= 0) and (Index < Count) then Result := Items[Index].Data
    else Result := 0;
end;

procedure TvqStringList.SetData(Index: Integer; Value: Longint);
begin
    if (Index >= 0) and (Index < Count) then 
        Items[Index].Data := Value;
end;

function TvqStringList.AddData(const S: string; const D: Longint): Integer;
begin
    if not FDuplicates then
        if Find(S, Result) then
            Exit;
    Result := Count;
    InsertData(Count, S, D);
end;

procedure TvqStringList.InsertData(Index: Integer; const S: string; const D: Longint);
var
    I: Integer;
begin
    if (Index >= 0) and (Index <= Count) then begin
        BeginUpdate;
        Insert(Index, S);
        SetData(Index, D);
        EndUpdate;
    end;
end;

{ TvqStringItems } 

constructor TvqStringItems.Create(AStrings: TvqStringList);
begin
    FStrings := AStrings;
end;

destructor TvqStringItems.Destroy;
begin
    FStrings := nil;
    inherited;
end;

procedure TvqStringItems.Assign(Source: TPersistent);
begin
    if (Source is TvqStringItems) and (Source <> Self) then
        FStrings.Assign(TvqStringItems(Source).FStrings)
    else inherited;
end;

function TvqStringItems.Count: Integer;
begin
    Result := FStrings.Count;
end;

function TvqStringItems.GetItem(Index: Integer): TvqStringItem;
begin
    Result := FStrings.Items[Index];
end;

procedure TvqStringItems.SetItem(Index: Integer; Value: TvqStringItem);
begin
    FStrings.Items[Index] := Value;
end;

end.
