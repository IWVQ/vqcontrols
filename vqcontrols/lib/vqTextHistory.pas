// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqTextHistory;

interface

uses
    Types, SysUtils, Classes, Graphics, Controls,
    vqUtils, vqEdition;

type
	
    TActionType = (aStartAction, aInsertAction, aRemoveAction);
    TAction = record
        ActionType: TActionType;
        Position: Integer;
        Data: TString;
        LenData: Integer;
        MayCoalesce: Boolean;
    end;
    
    TvqTextHistory = class
    protected
        FActions: array of TAction;
        FMaxAction: Integer;
        FCurrent: Integer;
        procedure UpdateRoom;
    public
		constructor Create;
		destructor Destroy; override;
		procedure AppendAction(AType: TActionType; Pos, Len: Integer; Data: TString);
		procedure Clear;
		
		function CanUndo: Boolean;
		function StartUndo: Integer;
		function GetUndoStep: TAction;
		procedure CompletedUndoStep;
		function CanRedo: Boolean;
		function StartRedo: Integer;
		function GetRedoStep: TAction;
		procedure CompletedRedoStep;
        procedure ForceNewSequence;

        function ActionsCount: Integer;

		property Current: Integer read FCurrent;
    end;
    
procedure MakeAction(var ADest: TAction; AType: TActionType; APos: Integer = 0;
    AData: TString = nil; ALenData: Integer = 0; AMayCoalesce: Boolean = True);
    
implementation

const
    GROWSIZE = 532;

procedure MakeAction(var ADest: TAction; AType: TActionType; APos: Integer = 0;
    AData: TString = nil; ALenData: Integer = 0; AMayCoalesce: Boolean = True);
begin
    with ADest do begin
        ActionType := AType;
        Position := APos;
        SetLength(Data, ALenData);
        if ALenData > 0 then
            System.Move(AData[0], Data[0], ALenData*SizeOf(TChar));
        LenData := ALenData;
        MayCoalesce := AMayCoalesce;
    end;
end;

{ TvqTextHistory }

constructor TvqTextHistory.Create;
begin
    Clear;
end;

destructor TvqTextHistory.Destroy;
begin
    FActions := nil;
    inherited;
end;

procedure TvqTextHistory.Clear;
begin
    SetLength(FActions, GROWSIZE);
    FMaxAction := 0;
    FCurrent := 0;
    MakeAction(FActions[0], aStartAction);
end;

procedure TvqTextHistory.UpdateRoom;
var
    L: Integer;
begin
    L := (((FCurrent + 2) div GROWSIZE) + 1)*GROWSIZE;
    if L <> Length(FActions) then
        SetLength(FActions, L);
end;

function TvqTextHistory.ActionsCount: Integer; //$
begin
    Result := System.Length(FActions);
end;

procedure TvqTextHistory.AppendAction(AType: TActionType; Pos, Len: Integer; Data: TString);
var
    ActPrevious: Integer;
begin
    UpdateRoom;
    FMaxAction := FCurrent;
    if AType = aStartAction then Exit;
    if FCurrent >= 1 then begin
        ActPrevious := FCurrent - 1;
        if not FActions[FCurrent].MayCoalesce then
            Inc(FCurrent)
        else begin
            case AType of
                aInsertAction:
                    case FActions[ActPrevious].ActionType of
                        aInsertAction:
                            if (Pos <> FActions[ActPrevious].Position + FActions[ActPrevious].LenData) then
                                Inc(FCurrent);
                        aRemoveAction:
                            Inc(FCurrent);
                    end;
                aRemoveAction:
                    case FActions[ActPrevious].ActionType of
                        aInsertAction:
                            Inc(FCurrent);
                        aRemoveAction:
                            if (Len = 1) or (Len = 2) then begin
                                if Pos + Len = FActions[ActPrevious].Position then begin end
                                else if Pos = FActions[ActPrevious].Position then begin end
                                else Inc(FCurrent);
                            end
                            else
                                Inc(FCurrent);
                    end;
            end;
        end;
    end
    else Inc(FCurrent);
    MakeAction(FActions[FCurrent], AType, Pos, Data, Len);
    Inc(FCurrent);
    MakeAction(FActions[FCurrent], aStartAction);
    FMaxAction := FCurrent;
end;

function TvqTextHistory.CanUndo: Boolean;
begin
    Result := (FCurrent > 0) and (FMaxAction > 0);
end;

function TvqTextHistory.StartUndo: Integer;
var
	Act: Integer;
begin
	if (FActions[FCurrent].ActionType = aStartAction) and (FCurrent > 0) then
		Dec(FCurrent);
	Act := FCurrent;
	while (FActions[Act].ActionType <> aStartAction) and (Act > 0) do Dec(Act);
	Result := FCurrent - Act;
end;

function TvqTextHistory.GetUndoStep: TAction;
begin
	Result := FActions[FCurrent];
end;

procedure TvqTextHistory.CompletedUndoStep;
begin
	Dec(FCurrent);
end;

procedure TvqTextHistory.ForceNewSequence;
begin
	FActions[FCurrent].MayCoalesce := False;
end;

function TvqTextHistory.CanRedo: Boolean;
begin
	Result := FMaxAction > FCurrent;
end;

function TvqTextHistory.StartRedo: Integer;
var
	Act: Integer;
begin
	if (FActions[FCurrent].ActionType = aStartAction) and (FCurrent < FMaxAction) then
		Inc(FCurrent);
	Act := FCurrent;
	while (FActions[Act].ActionType <> aStartAction) and (Act < FMaxAction) do Inc(Act);
	Result := Act - FCurrent;
end;

function TvqTextHistory.GetRedoStep: TAction;
begin
	Result := FActions[FCurrent];
end;

procedure TvqTextHistory.CompletedRedoStep;
begin
	Inc(FCurrent);
end;

end.
