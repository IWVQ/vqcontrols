// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqSplitVector;

interface

uses
    Types, SysUtils, Classes, Math,
    vqUtils;


type
    
	generic TSplitVector<T> = class
	private
		procedure FillValue(Pos, Len: Integer; Value: T);
		function Get(Index: Integer): T;
		procedure Put(Index: Integer; const Value: T);
	protected
        FEmptyValue: T;
		FBody: array of T;
		FSize: Integer;
		FLengthBody: Integer;
		FPart1Length: Integer;
		FGapLength: Integer;
		FGrowSize: Integer;
		procedure GapTo(Position: Integer);
		procedure RoomFor(InsertionLength: Integer);
		procedure Init;
	public
        type
        	TTArray = array of T;
		constructor Create(AEmptyValue: T);
		destructor Destroy; override;
		procedure ReAllocate(NewSize: Integer);
		procedure Insert(Pos, Len: Integer; Value: T);
		procedure FillRange(Pos, Len: Integer; Value: T);
		procedure FillFromArray(Pos: Integer; Values: TTArray; PosFrom, Len: Integer);
		procedure InsertFromArray(Pos: Integer; Values: TTArray; PosFrom, Len: Integer);
		procedure Delete(Pos, Len: Integer);
		procedure Clear;
		procedure GetRange(var Buffer: TTArray; Pos, Len: Integer);
		function BufferPointer: TTArray;
		function RangePointer(Pos, Len: Integer): TTArray;
		property GrowSize: Integer read FGrowSize write FGrowSize;
		property ValueAt[Index: Integer]: T read Get write Put; default;
		property Length: Integer read FLengthBody;
		property GapPosition: Integer read FPart1Length;
	end;
    
    TCharSplitVector = specialize TSplitVector<Char>;
    TIntSplitVector = specialize TSplitVector<Integer>;
    TByteSplitVector = specialize TSplitVector<Byte>;
    
implementation

{ TSplitVector<T> }

constructor TSplitVector.Create(AEmptyValue: T);
begin
	Init;
    FEmptyValue := AEmptyValue;
end;

destructor TSplitVector.Destroy;
begin
	FBody := nil;
	inherited;
end;

procedure TSplitVector.GapTo(Position: Integer);
begin
	if Position <> FPart1Length then begin
		if Position < FPart1Length then
            System.Move(FBody[Position], FBody[Position + FGapLength],
                SizeOf(T)*(FPart1Length - Position))
		else
            System.Move(FBody[FPart1Length + FGapLength], FBody[FPart1Length],
                SizeOf(T)*(Position - FPart1Length));
		FPart1Length := Position;
	end
end;

procedure TSplitVector.RoomFor(InsertionLength: Integer);
begin
	if FGapLength <= InsertionLength then begin
		if FGrowSize < FSize / 8 then
			FGrowSize := 1 shl (Ceil(Ln(FSize)/Ln2) - 3);
		ReAllocate(FSize + InsertionLength + FGrowSize);
	end;
end;

procedure TSplitVector.Init;
begin
	FBody := nil;
	FGrowSize := 8;
	FSize := 0;
	FLengthBody := 0;
	FPart1Length := 0;
	FGapLength := 0;
end;

procedure TSplitVector.ReAllocate(NewSize: Integer);
begin
	if NewSize > FSize then begin
		GapTo(FLengthBody);
		SetLength(FBody, NewSize);
		Inc(FGapLength, NewSize - FSize);
		FSize := NewSize;
	end;
end;

procedure TSplitVector.FillValue(Pos, Len: Integer; Value: T);
var
	I: Integer;
begin
	for I := Pos to Pos + Len - 1 do FBody[I] := Value;
end;

function TSplitVector.Get(Index: Integer): T;
begin
	if Index < FPart1Length then begin
		if Index < 0 then Result := FEmptyValue
		else Result := FBody[Index];
	end
	else begin
		if Index >= FLengthBody then Result := FEmptyValue
		else Result := FBody[FGapLength + Index];
	end
end;

procedure TSplitVector.Put(Index: Integer; const Value: T);
begin
	if Index < FPart1Length then begin
		if Index >= 0 then FBody[Index] := Value
	end
	else begin
		if Index < FLengthBody then FBody[FGapLength + Index] := Value;
	end
end;

procedure TSplitVector.Insert(Pos, Len: Integer; Value: T);
begin
	if Len > 0 then begin
		RoomFor(Len);
		GapTo(Pos);
		FillValue(FPart1Length, Len, Value);
		Inc(FLengthBody, Len);
		Inc(FPart1Length, Len);
		Dec(FGapLength, Len);
	end;
end;

procedure TSplitVector.FillRange(Pos, Len: Integer; Value: T);
var
	FillLen, Part1Left: Integer;
begin
	FillLen := Len;
	Part1Left := FPart1Length - Pos;
	if Part1Left < 0 then Part1Left := 0;
	if FillLen > Part1Left then
		FillLen := Part1Left;
	FillValue(Pos, FillLen, Value);
	FillValue(Pos + FGapLength + FillLen, Len - FillLen, Value);
end;

procedure TSplitVector.FillFromArray(Pos: Integer; Values: TTArray; PosFrom, Len: Integer);
var
	FillLen, Part1Left: Integer;
begin
	FillLen := Len;
	Part1Left := FPart1Length - Pos;
	if Part1Left < 0 then Part1Left := 0;
	if FillLen > Part1Left then
		FillLen := Part1Left;
	if FillLen > 0 then
		System.Move(Values[PosFrom], FBody[Pos], SizeOf(T)*FillLen);
	Inc(PosFrom, FillLen);
	Inc(Pos, FillLen + FGapLength);
	FillLen := Len - FillLen;
	if FillLen > 0 then
		System.Move(Values[PosFrom], FBody[Pos], SizeOf(T)*FillLen);
end;

procedure TSplitVector.InsertFromArray(Pos: Integer; Values: TTArray; PosFrom, Len: Integer);
begin
	if Len > 0 then begin
		RoomFor(Len);
		GapTo(Pos);
		System.Move(Values[PosFrom], FBody[FPart1Length], SizeOf(T)*Len);
		Inc(FLengthBody, Len);
		Inc(FPart1Length, Len);
		Dec(FGapLength, Len);
	end;
end;

procedure TSplitVector.Delete(Pos, Len: Integer);
begin
	if (Pos = 0) and (Len = FLengthBody) then
		Init
	else if Len > 0 then begin
		GapTo(Pos);
		Dec(FLengthBody, Len);
		Inc(FGapLength, Len);
	end;
end;

procedure TSplitVector.Clear;
begin
	Delete(0, FLengthBody);
end;

procedure TSplitVector.GetRange(var Buffer: TTArray; Pos, Len: Integer);
var
	Range1Length, Part1AfterPosition, Range2Length: Integer;
begin
	Range1Length := 0;
	if Pos < FPart1Length then begin
		Part1AfterPosition := FPart1Length - Pos;
		Range1Length := Len;
		if Range1Length > Part1AfterPosition then
			Range1Length := Part1AfterPosition;
	end;
	Range2Length := Len - Range1Length;
	SetLength(Buffer, Len);
    if Len > 0 then begin
        Move(FBody[Pos], Buffer[0], SizeOf(T)*Range1Length);
        Pos := Pos + Range1Length + FGapLength;
        Move(FBody[Pos], Buffer[Range1Length], SizeOf(T)*Range2Length);
    end;
end;

function TSplitVector.BufferPointer: TTArray;
begin
	RoomFor(1);
	GapTo(FLengthBody);
	FBody[FLengthBody] := FEmptyValue;
	Result := TTArray(@FBody[0]);
end;

function TSplitVector.RangePointer(Pos, Len: Integer): TTArray;
begin
	if Pos < FPart1Length then begin
		if Pos + Len > FPart1Length then begin
			GapTo(Pos);
			Result := TTArray(@FBody[Pos + FGapLength]);
		end
		else
			Result := TTArray(@FBody[Pos])
	end
	else
		Result := TTArray(@FBody[Pos + FGapLength]);
end;

end.
