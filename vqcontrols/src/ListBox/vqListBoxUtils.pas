// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqListBoxUtils;

interface
          
{$MODESWITCH ADVANCEDRECORDS}

uses
    Types, SysUtils, Classes, Graphics, Controls,
    vqUtils;

const
    
    LB_WORK_NONE          = $0000;
    LB_WORK_REPAINT_ALL   = $0001;
    LB_WORK_REPAINT_FROM  = $0002;
    LB_WORK_REPAINT_RANGE = $0003;
    
type
	
    TvqRepaintWork = record
        Kind: Byte;
        First, Last: Integer;
    end;

    TvqSelAwningRange = record
    private      
        function GetStart: Integer;
        function GetEnd: Integer;
        procedure SetStart(Value: Integer);
        procedure SetEnd(Value: Integer);
    public
        Anchor: Integer;
        Caret: Integer;

        function Invalidate: Boolean;
        function Valid: Boolean;
        procedure Offset(Delta: Integer);
        function Length: Integer;
        function Selected(APos: Integer): Boolean;
        property Start: Integer read GetStart write SetStart;
        property _End: Integer read GetEnd write SetEnd;
    end;
           
    TvqRepaintWorkList = class
    private
        FList: array of TvqRepaintWork;
        FCount: Integer;
        function GetWork(Index: Integer): TvqRepaintWork;
        procedure SetWork(Index: Integer; Value: TvqRepaintWork);
    public
        constructor Create;
        destructor Destroy; override;
        procedure Clear;
        procedure Add(Kind: Byte; First, Last: Integer);
        property Count: Integer read FCount;
        property Work[Index: Integer]: TvqRepaintWork read GetWork write SetWork; default;
    end;

    { IvqListBoxListener }

    IvqListBoxListener = interface
        function _ListBoxControl: TControl;
        function _ItemSelected(Index: Integer): Boolean;
        procedure _ModifyTopOffset(Value: Integer);
        procedure _RetrieveTopOffset(var Value: Integer);
        procedure _NotifyItemChange(Index: Integer);
        procedure _NotifyChanged;
        procedure _NotifyChanging;
        procedure _NotifySelChanged;
        procedure _MeasureItem(Index: Integer; var AWidth, AHeight: Integer);
        
        procedure BeginWork;
        procedure EndWork;
        procedure WorkUpdateScroll;
        procedure WorkRepaintAll;
        procedure WorkRepaintItem(Index: Integer);
        procedure WorkRepaintFrom(Index: Integer);
        procedure WorkRepaintRange(AStart, AEnd: Integer);
        function InactiveItem(Index: Integer): Boolean;
    end;
    
implementation

const
    
    GROWSIZE = 64;
    
{ TvqSelAwningRange }

function TvqSelAwningRange.Invalidate: Boolean;
begin
    if (Anchor <> vqInvalidValue) or (Caret <> vqInvalidValue) then begin
        Anchor := vqInvalidValue;
        Caret := vqInvalidValue;
        Result := True;
    end
    else Result := False;
end;

function TvqSelAwningRange.Valid: Boolean;
begin
    Result := (Anchor <> vqInvalidValue) and (Caret <> vqInvalidValue);
end;

procedure TvqSelAwningRange.Offset(Delta: Integer);
begin
    if Valid then begin
        Inc(Anchor, Delta);
        Inc(Caret, Delta);
        if Anchor >= 0 then begin
            if Caret < 0 then Caret := 0;
        end
        else if Caret >= 0 then begin
            if Anchor < 0 then Anchor := 0;
        end
        else Invalidate;
    end;
end;

function TvqSelAwningRange.Length: Integer;
begin   
    if Valid then begin
        if Anchor < Caret then Result := Caret - Anchor + 1
        else Result := Anchor - Caret + 1;
    end
    else Result := 0;
end;    

function TvqSelAwningRange.Selected(APos: Integer): Boolean;
begin
    if Valid then begin
        if Anchor < Caret then Result := (Anchor <= APos) and (APos <= Caret)
        else Result := (Caret <= APos) and (APos <= Anchor);
    end
    else 
        Result := False;
end;

procedure TvqSelAwningRange.SetStart(Value: Integer);
begin
    if Valid then begin
        if Value < 0 then Value := 0;
        if Anchor < Caret then
            Anchor := Value
        else
            Caret := Value;
    end;
end;

procedure TvqSelAwningRange.SetEnd(Value: Integer);
begin
    if Valid then begin
        if Value < 0 then Invalidate
        else if Anchor < Caret then begin
            Caret := Value;
            if Caret < Anchor then Invalidate;
        end
        else begin
            Anchor := Value;
            if Anchor < Caret then Invalidate;
        end;
    end;
end;

function TvqSelAwningRange.GetStart: Integer;
begin
    if Valid then begin
        if Anchor < Caret then Result := Anchor
        else Result := Caret;
    end
    else 
        Result := vqInvalidValue; 
end;

function TvqSelAwningRange.GetEnd: Integer;
begin
    if Valid then begin
        if Anchor < Caret then Result := Caret
        else Result := Anchor;
    end
    else 
        Result := vqInvalidValue; 
end;

{ TvqRepaintWorkList }

constructor TvqRepaintWorkList.Create;
begin
    FList := nil;
    FCount := 0;
end;

destructor TvqRepaintWorkList.Destroy;
begin
    FList := nil;
    inherited;
end;

procedure TvqRepaintWorkList.Clear;
begin
    FList := nil;
    FCount := 0;
end;

procedure TvqRepaintWorkList.Add(Kind: Byte; First, Last: Integer);
begin
    if FCount >= Length(FList) then
        SetLength(FList, FCount + 8);
    FList[FCount].Kind := Kind;
    FList[FCount].First := First;
    FList[FCount].Last := Last;
    Inc(FCount);
end;

function TvqRepaintWorkList.GetWork(Index: Integer): TvqRepaintWork;
begin
    if (Index >= 0) and (Index < FCount) then
        Result := FList[Index]
    else
        Result.Kind := LB_WORK_NONE;
end;

procedure TvqRepaintWorkList.SetWork(Index: Integer; Value: TvqRepaintWork);
begin
    if (Index >= 0) and (Index < FCount) then
        FList[Index] := Value;
end;

end.
