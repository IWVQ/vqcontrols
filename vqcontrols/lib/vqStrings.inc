// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqStrings.inc             }
{ included in vqUtils.pas   }

function GetFirstWord(var Str: string): string;
var
    Len, I, K: Integer;
begin
    Len := Length(Str);
    I := 1;
    while (I <= Len) and IsSpaceChar(Str[I]) do
        Inc(I);
    K := I;
    while (I <= Len) and not IsSpaceChar(Str[I]) do
        Inc(I);
    Result := Copy(Str, K, I - K);
end;

procedure GetLineStarts(Str: string; var Starts: TIntArray; var Lines: Integer);
var
    StrLen, I: Integer;
begin
    StrLen := Length(Str);
    if StrLen = 0 then begin
        Starts := nil;
        Lines := 0;
    end;
    SetLength(Starts, StrLen + 1);
    Lines := 1;
    I := 1;
    Starts[0] := 0;
    while I <= StrLen do begin
        if Str[I] = LF then begin
            Starts[Lines] := I + 1;
            Inc(Lines);
        end
        else if Str[I] = CR then begin
            if (I < StrLen) and (Str[I + 1] = LF) then
                Inc(I);
            Starts[Lines] := I + 1;
            Inc(Lines);
        end;
        Inc(I);
    end;
    SetLength(Starts, Lines);
end;

function NextLine(var Str: string; I: Integer): Integer;
var
    L: Integer;
begin
    L := Length(Str);
    Result := I;
    while Result <= L do begin
        if Str[Result] = CR then begin
            Inc(Result);
            if Str[Result] = LF then
                Inc(Result);
            Break;
        end
        else if Str[Result] = LF then begin
            Inc(Result);
            Break;
        end
        else Inc(Result);
    end;
end;

function IsControlChar(Ch: Char): Boolean;
begin
    Result := (Ch < #32) or (Ch = #127);
end;

function IsEoLChar(Ch: Char): Boolean;
begin
    Result := Ch in [CR, LF];
end;

function IsSpaceChar(Ch: Char): Boolean;
begin
    Result := Ch in [' ', #9];
end;

function IsWhiteChar(Ch: Char): Boolean;
begin
    Result := IsEoLChar(Ch) or IsSpaceChar(Ch);
end;

function IsNumeralChar(Ch: Char): Boolean;
begin
    Result := Ch in ['0'..'9'];
end;

function IsAlphaNumChar(Ch: Char): Boolean;
begin
    Result := IsAlphaChar(Ch) or IsNumeralChar(Ch);
end;

function IsAlphaChar(Ch: Char): Boolean;
begin
    Result := Ch in ['a'..'z', 'A'..'Z'];
end;

function IsUpperAlphaChar(Ch: Char): Boolean;
begin
    Result := Ch in ['A'..'Z'];
end;

function IsLowerAlphaChar(Ch: Char): Boolean;
begin
    Result := Ch in ['a'..'z'];
end;

function IsHexadecimalChar(Ch: Char): Boolean;
begin
    Result := Ch in ['0'..'9', 'A'..'F', 'a'..'z'];
end;

function IsOctalChar(Ch: Char): Boolean;
begin
    Result := Ch in ['0'..'7'];
end;

function IsIdentifierChar(Ch: Char): Boolean;
begin
    Result := Ch in ['0'..'9', 'A'..'F', 'a'..'z', '_'];
end;

function HexNibble(Ch: Char): Byte;
begin
    case Ch of
        'A'..'F': Result := Byte(Ord(Ch) - 55);
        'a'..'f': Result := Byte(Ord(Ch) - 87);
        '0'..'9': Result := Byte(Ord(Ch) - 48);
        else Result := 0;
    end;
end;

function DecDigit(Ch: Char): Byte;
begin
    if Ch in ['0'..'9'] then Result := Byte(Ord(Ch) - 48)
    else Result := 0;
end;

function OctalDigit(Ch: Char): Byte;
begin
    if Ch in ['0'..'7'] then Result := Byte(Ord(Ch) - 48)
    else Result := 0;
end;

function NibbleToChar(H: Byte): Char;
begin
    case H and $0F of
        $0: Result := '0';
        $1: Result := '1';
        $2: Result := '2';
        $3: Result := '3';
        $4: Result := '4';
        $5: Result := '5';
        $6: Result := '6';
        $7: Result := '7';
        $8: Result := '8';
        $9: Result := '9';
        $A: Result := 'A';
        $B: Result := 'B';
        $C: Result := 'C'; 
        $D: Result := 'D'; 
        $E: Result := 'E'; 
        $F: Result := 'F';
        else Result := '0';
    end;
end;

function DigitToChar(D: Byte): Char;
begin
    case D and $0F of
        0: Result := '0';
        1: Result := '1';
        2: Result := '2';
        3: Result := '3';
        4: Result := '4';
        5: Result := '5';
        6: Result := '6';
        7: Result := '7';
        8: Result := '8';
        9: Result := '9';
        else Result := '0';
    end;
end;

procedure ConsumeSpace(var S: string; var I: Integer);
var
    L: Integer;
begin
    L := Length(S);
    while (I <= L) and IsSpaceChar(S[I]) do
        Inc(I);
end;

function RGBToHtml(R, G, B: Byte; Compress: Boolean = False): string;
begin
    if Compress then begin
        if (R = G) and (G = B) then begin
            if (R shr 4) = (R and $0F) then
                Result := NibbleToChar(R)
            else
                Result := IntToHex(R, 2);
        end
        else if ((R shr 4) = (R and $0F)) and
                ((G shr 4) = (G and $0F)) and 
                ((B shr 4) = (B and $0F)) then
            Result := NibbleToChar(R) + NibbleToChar(G) + NibbleToChar(B)
        else if (B shr 4) = (B and $0F) then
            Result := IntToHex(R, 2) + IntToHex(G, 2) + NibbleToChar(B)
        else
            Result := IntToHex(R, 2) + IntToHex(G, 2) + IntToHex(B, 2);
    end
    else
        Result := IntToHex(R, 2) + IntToHex(G, 2) + IntToHex(B, 2);
end;

function RGBAToHtml(R, G, B, A: Byte; Compress: Boolean = False): string;
begin
    if Compress then begin
        if A = $FF then
            Result := RGBToHtml(R, G, B, True)
        else if (A shr 4) = (A and $0F) then begin
            if ((R shr 4) = (R and $0F)) and
                    ((G shr 4) = (G and $0F)) and 
                    ((B shr 4) = (B and $0F)) then
                Result := NibbleToChar(R) + NibbleToChar(G) + NibbleToChar(B) + NibbleToChar(A)
            else
                Result := IntToHex(R, 2) + IntToHex(G, 2) + IntToHex(B, 2) + NibbleToChar(A);
        end
        else
            Result := IntToHex(R, 2) + IntToHex(G, 2) + IntToHex(B, 2) + IntToHex(A, 2);
    end
    else
        Result := IntToHex(R, 2) + IntToHex(G, 2) + IntToHex(B, 2) + IntToHex(A, 2);
end;

function HtmlToRGBA(S: String; var R, G, B, A: Byte): Boolean;
var
    L, K, I: Integer;
    H: array of Byte;
begin
    Result := False;
    L := Length(S);
    I := 1;
    ConsumeSpace(S, I);
    if I <= L then begin
        if S[I] = '#' then Inc(I);
        K := 0;
        SetLength(H, L);
        while (I <= L) and IsHexadecimalChar(S[I]) do begin
            H[K] := HexNibble(S[I]);
            Inc(I);
            Inc(K)
        end;
        A := $FF;
        case K of
            0: ;
            1: begin
                R := (H[0] shl 4) or H[0]; 
                G := R;
                B := R;
            end;
            2: begin
                R := (H[0] shl 4) or H[1]; 
                G := R;
                B := G;
            end;
            3: begin
                R := (H[0] shl 4) or H[0];
                G := (H[1] shl 4) or H[1];
                B := (H[2] shl 4) or H[2];
            end;
            4: begin
                R := (H[0] shl 4) or H[0];
                G := (H[1] shl 4) or H[1];
                B := (H[2] shl 4) or H[2];
                A := (H[3] shl 4) or H[3];
            end;
            5: begin
                R := (H[0] shl 4) or H[1];
                G := (H[2] shl 4) or H[3];
                B := (H[4] shl 4) or H[4];
            end;
            6: begin
                R := (H[0] shl 4) or H[1];
                G := (H[2] shl 4) or H[3];
                B := (H[4] shl 4) or H[5];
            end;
            7: begin
                R := (H[0] shl 4) or H[1];
                G := (H[2] shl 4) or H[3];
                B := (H[4] shl 4) or H[5];
                A := (H[6] shl 4) or H[6];
            end;
            8: begin
                R := (H[0] shl 4) or H[1];
                G := (H[2] shl 4) or H[3];
                B := (H[4] shl 4) or H[5];
                A := (H[6] shl 4) or H[7];
            end;
            else begin //!
                R := (H[0] shl 4) or H[1];
                G := (H[2] shl 4) or H[3];
                B := (H[4] shl 4) or H[5];
                A := (H[6] shl 4) or H[7];
            end;
        end;
        if K > 0 then begin
            ConsumeSpace(S, I);
            if I > L then Result := True;
        end;
    end;
end;

{ TvqStringText }

constructor TvqStringText.CreatePointer(var Str: string);
begin
    PS := @Str;
end;

constructor TvqStringText.CreateConst(Str: string);
begin
    S := Str;
    PS := @S;
end;

destructor TvqStringText.Destroy;
begin
    PS := nil;
    S := '';
end;

function TvqStringText._GetChar(Pos: Integer): Char;
begin
    Result := PS^[Pos + 1];
end;

function TvqStringText._GetString(Pos, Len: Integer): ansistring;
begin
    Result := Copy(PS^, Pos + 1, Len);
end;

function TvqStringText._GetArray(Pos, Len: Integer; var Txt: TCharArray): Boolean;
var
    I, L: Integer;
begin
    L := Min(Len, _TextLength - Pos);
    if L < 0 then L := 0;
    SetLength(Txt, L);
    for I := Pos to Pos + Len - 1 do
        Txt[I] := PS^[Pos + 1];
    Result := L > 0;
end;

function TvqStringText._TextLength: Integer;
begin
    Result := Length(PS^);
end;

function TvqStringText._WholeWordAt(PosFrom, PosTo: Integer): Boolean;
begin
    Result := True;
end;

{ TvqCharArrayText }

constructor TvqCharArrayText.Create(Str: TCharArray);
begin
    S := Str;
end;

destructor TvqCharArrayText.Destroy;
begin
    S := nil;
    inherited
end;

function TvqCharArrayText._GetChar(Pos: Integer): Char;
begin
    Result := S[Pos];
end;

function TvqCharArrayText._GetString(Pos, Len: Integer): ansistring;
var
    I, L: Integer;
begin
    L := Min(Len, _TextLength - Pos);
    if L < 0 then L := 0;
    SetLength(Result, L);
    for I := Pos to Pos + Len - 1 do
        Result[I + 1] := S[Pos];
end;

function TvqCharArrayText._GetArray(Pos, Len: Integer; var Txt: TCharArray): Boolean;
var
    I, L: Integer;
begin
    L := Min(Len, _TextLength - Pos);
    if L < 0 then L := 0;
    SetLength(Txt, L);
    for I := Pos to Pos + Len - 1 do
        Txt[I] := S[Pos];
    Result := L > 0;
end;

function TvqCharArrayText._TextLength: Integer;
begin
    Result := System.Length(S);
end;

function TvqCharArrayText._WholeWordAt(PosFrom, PosTo: Integer): Boolean;
begin
    Result := True;
end;



