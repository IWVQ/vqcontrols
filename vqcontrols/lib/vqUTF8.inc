// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqUTF8.inc                }
{ included in vqUtils.pas   }

function TvqUTF8Bytes.Get: TUTF8Char;
begin
    if True { S0 <> #0 } { always add cero char } then begin
        Result[1] := S0;
        if S1 <> #0 then begin
            Result[2] := S1;
            if S2 <> #0 then begin
                Result[3] := S2;
                if S3 <> #0 then begin
                    Result[4] := S3;
    
                    Result[5] := #0;
                    Result[0] := #4;
                end
                else begin
                    Result[4] := #0;
                    Result[0] := #3;
                end;
            end
            else begin
                Result[3] := #0;
                Result[0] := #2;
            end;
        end
        else begin
            Result[2] := #0;
            Result[0] := #1;
        end;
    end
    else begin
        Result[1] := #0;
        Result[0] := #0
    end;
end;

procedure TvqUTF8Bytes.Put(Ch: TUTF8Char);
begin
    S0 := (Ch[1]);
    S1 := (Ch[2]);
    S2 := (Ch[3]);
    S3 := (Ch[4]);
end;

function SameUTF8(A: TUTF8Char; B: AnsiChar): Boolean;
begin
    Result := (A[0] = #1) and (A[1] = B);
end;

function SameUTF8(A: TUTF8Char; B: TUTF8Char): Boolean;
var
    I: Integer;
begin
    Result := A[0] = B[0];
    if Result then
        for I := 1 to Byte(A[1]) do
            if A[I] <> B[I] then begin
                Result := False;
                Break;
            end;
end;

// 

function ScanSpace(Text: IvqTextBuffer; I: Integer): Integer;
var
    L: Integer;
begin
    L := Text._TextLength;
    Result := I;
    while (I < L) and IsSpaceChar(Text[I]) do Inc(I);
    Result := I - Result;
end;

function ScanEscapeSequence(Text: IvqTextBuffer; AExtended: Boolean; var I: Integer; 
    var Ch: TUTF8Char): Boolean;
var
    H, B: Byte;
    U, D, TD, O, L: Integer;
    IsCode: Boolean;
begin //! posiblemente se cambie \DDD por octal
    Ch := #0#0#0#0#0#0#0;
    Ch[0] := #0;
    
    Result := False;
    L := Text._TextLength;
    Inc(I); // I was at '\'
    if I < L then begin
        IsCode := False;
        case Text[I] of
            '"' : Ch := '"';
            '''': Ch :='''';
            '\' : Ch := '\';
            'a' : Ch :=  #7;  
            'b' : Ch :=  #8; 
            'f' : Ch := #12;
            'n' : Ch := #10; 
            'r' : Ch := #13; 
            't' : Ch :=  #9; 
            'v' : Ch := #11; 
            'x', 'X': { \xHH } begin
                Inc(I);
                H := 0;
                if (I < L) and IsHexadecimalChar(Text[I]) then begin
                    H := HexNibble(Text[I]);
                    Inc(I);
                    if (I < L) and IsHexadecimalChar(Text[I]) then begin
                        H := (H shl 4) or HexNibble(Text[I]);
                        Inc(I);
                    end;
                end;
                Ch := Chr(H);
                IsCode := True;
            end;
            'o', 'O': { \oBBB } begin
                Inc(I);
                O := 0;
                if (I < L) and IsOctalChar(Text[I]) then begin
                    B := OctalDigit(Text[I]);
                    Inc(I);
                    if (I < L) and IsOctalChar(Text[I]) then begin
                        B := (B shl 3) or OctalDigit(Text[I]);
                        Inc(I);
                        if (I < L) and IsOctalChar(Text[I]) then begin
                            TD := (B shl 3) or OctalDigit(Text[I]);
                            if TD <= $FF then begin
                                B := TD;
                                Inc(I);
                            end;
                        end;
                    end;
                end;
                Ch := Chr(B);
                IsCode := True;
            end;
            'u', 'U': { \uHHHHHHHH } begin
                Inc(I);
                U := 0;
                while (I < L) and IsHexadecimalChar(Text[I]) and
                    (U < $200000) do begin
                    U := (U shl 4) or HexNibble(Text[I]);
                    Inc(I);
                end;
                Ch := EncodeUTF8(U);
                IsCode := True;
            end;
            else if IsNumeralChar(Text[I]) then { \DDD } begin
                D := DecDigit(Text[I]);
                Inc(I);
                if (I < L) and IsNumeralChar(Text[I]) then begin
                    D := (D*10) + DecDigit(Text[I]);
                    Inc(I);
                    if (I < L) and IsNumeralChar(Text[I]) then begin
                        TD := (D*10) + DecDigit(Text[I]);
                        if TD <= $FF then begin
                            D := TD;
                            Inc(I);
                        end;
                    end;
                end;
                Ch := Chr(Byte(D));
                IsCode := True;
            end
            else if AExtended then begin
                ScanUTF8(Text, I, Ch);
                IsCode := True;
            end;
        end; { case }
        if not IsCode then Inc(I);
        Result := Ch[0] <> #0;
    end;
end;

function ScanCharToEscapeSequence(Text: IvqTextBuffer; var I: Integer; 
    AEncodeUTF8: Boolean = False): ansistring;
var
    U, T: Integer;
begin
    Result := '';
    case Text[I] of
        '''': Result := '\''';
        '"' : Result := '\"';
        '\' : Result := '\\';
        #7  : Result := '\a';
        #8  : Result := '\b';
        #12 : Result := '\f';
        #10 : Result := '\n';
        #13 : Result := '\r';
        #9  : Result := '\t';
        #11 : Result := '\v';
        else if Text[I] < #$80 then Result := Text[I]
        else if AEncodeUTF8 then begin
            T := I;
            if DecodeUTF8(Text, I, U) then begin
                if U <= $FF then Result := '\x'
                else Result := '\u';
                Result := Result + IntToHex(U, 2);
            end
            else
                while T < I do begin
                    Result := Result + '\x' + IntToHex(Byte(Text[T]), 2);
                    Inc(T);
                end;
        end
        else Result := Text[I];
    end
end;

function EscStringToString(S: ansistring; AExtended: Boolean): ansistring;
var
    Text: TvqStringText;
    I, L, K: Integer;
    Ch: TUTF8Char;
    
    procedure __WriteAnsiChar(C: AnsiChar);
    begin
        Result[K] := C;
        Inc(K);
    end;
    
var
    ChI: Integer;
    
begin
    Text := TvqStringText.CreatePointer(S);
    I := 0;
    K := 1;
    L := Text._TextLength;
    SetLength(Result, L);
    while I < L do begin
        if Text[I] = '\' then begin
            if ScanEscapeSequence(Text, AExtended, I, Ch) then
                for ChI := 1 to Byte(Ch[0]) do
                    __WriteAnsiChar(Ch[ChI])
            else
                __WriteAnsiChar('\');
        end
        else begin
            __WriteAnsiChar(Text[I]);
            Inc(I);
        end;
    end;
    SetLength(Result, K - 1);
    Text.Free;
end;

function StringToEscString(S: ansistring; AEncodeUTF8: Boolean = False): ansistring;
var
    Text: TvqStringText;
    I, L: Integer;
    Esc: ansistring;
begin
    Text := TvqStringText.CreatePointer(S);
    I := 0;
    L := Text._TextLength;
    Result := '';
    while I < L do begin
        Esc := ScanCharToEscapeSequence(Text, I, AEncodeUTF8);
        Result := Result + Esc;
    end;
    Text.Free;
end;

//

var
    CharClassArray: array[Char] of TvqCharClass;

procedure InitializeCharClasses;
var
    C: Char;
begin
    for C := #$00 to #$FF do
        if IsEoLChar(C) then
            CharClassArray[C] := ccEoL
        else if (C < #$20) or (C = ' ') then
            CharClassArray[C] := ccSpace
        else if IsAlphaNumChar(C) or (C = '_') then
            CharClassArray[C] := ccWord
            // DEL is punctuation
        else if C < #$80 then
            CharClassArray[C] := ccPunctuation
        // extended
        else if C <= #$A0 then
            CharClassArray[C] := ccSpace
        else if C <= #$A9 then
            CharClassArray[C] := ccPunctuation
        else if C <= #$AA then
            CharClassArray[C] := ccWord
        else if C <= #$AC then
            CharClassArray[C] := ccPunctuation
        else if C <= #$AD then
            CharClassArray[C] := ccSpace
        else if C <= #$B1 then
            CharClassArray[C] := ccPunctuation
        else if C <= #$B3 then
            CharClassArray[C] := ccWord
        else if C <= #$B4 then
            CharClassArray[C] := ccPunctuation
        else if C <= #$B5 then
            CharClassArray[C] := ccWord
        else if C <= #$B8 then
            CharClassArray[C] := ccPunctuation
        else if C <= #$BA then
            CharClassArray[C] := ccWord
        else if C <= #$BB then
            CharClassArray[C] := ccPunctuation
        else if C <= #$BE then
            CharClassArray[C] := ccWord
        else if C <= #$BF then
            CharClassArray[C] := ccPunctuation
        else if C <= #$D6 then
            CharClassArray[C] := ccWord
        else if C <= #$D7 then
            CharClassArray[C] := ccPunctuation
        else if C <= #$F6 then
            CharClassArray[C] := ccWord
        else if C <= #$F7 then
            CharClassArray[C] := ccPunctuation
        else if C <= #$FF then
            CharClassArray[C] := ccWord;
end;

function GetClassOfChar(Ch: Char): TvqCharClass;
begin
    if Ch < #$80 then Result := CharClassArray[Ch]
    else Result := ccWord;
end;

function GetClassOfUnicode(U: Integer): TvqCharClass;
begin

    // extended ascii

    if U < $100 then Result := CharClassArray[Char(U)]

    // words

    else if U < $2000 then Result := ccWord

    // punctuation

    else if U < $2070 then Result := ccPunctuation

    // superscripts and subscripts

    else if U < $207A then Result := ccWord
    else if U < $207F then Result := ccPunctuation
    else if U < $208A then Result := ccWord
    else if U < $2090 then Result := ccPunctuation
    else if U < $20A0 then Result := ccWord

    // punctuation and symbols

    else if ((U >= $20A0) and (U < $20D0)) or
            ((U >= $2100) and (U < $2460)) or
            ((U >= $2500) and (U < $2800)) or
            ((U >= $2900) and (U < $2C00)) or
            ((U >= $2E00) and (U < $2E80)) or
            ((U >= $3000) and (U < $3040)) or
            ((U >= $FFF0) and (U <= $FFFF)) then Result := ccPunctuation

    // words and others

    else Result := ccWord;
end;

//

function ScanUTF8(Text: IvqTextBuffer; var I: Integer; var Ch: TUTF8Char): Boolean;
var
    L, T: Integer;
    Sh: AnsiChar;
begin
    L := Text._TextLength;
    Result := False;
    Ch := #0#0#0#0#0#0#0;
    Ch[0] := #0;
    if I < L then begin
        Sh := Text[I];
        Ch[1] := Sh;
        T := I;
        Inc(I);
        if Sh < #$80 then
            Result := I - T = 1
        else if Sh < #$C0 then
            Result := False // isolated trailing byte
        else if Sh < #$E0 then begin
            if (I < L) and UTF8IsTrailByte((Text[I])) then begin
                Ch[2] := Text[I];
                Inc(I);
            end;
            Result := I - T = 2;
        end
        else if Sh < #$F0 then begin
            if (I < L) and UTF8IsTrailByte((Text[I])) then begin
                Ch[2] := Text[I];
                Inc(I);
                if (I < L) and UTF8IsTrailByte((Text[I])) then begin
                    Ch[3] := Text[I];
                    Inc(I);
                end;
            end;
            Result := I - T = 3;
        end
        else if Sh < #$F8 then begin
            if (I < L) and UTF8IsTrailByte((Text[I])) then begin
                Ch[2] := Text[I];
                Inc(I);
                if (I < L) and UTF8IsTrailByte((Text[I])) then begin
                    Ch[3] := Text[I];
                    Inc(I);
                    if (I < L) and UTF8IsTrailByte((Text[I])) then begin
                        Ch[4] := Text[I];
                        Inc(I);
                    end;
                end;
            end;
            Result := I - T = 4;
        end
        else
            Result := False;
        Ch[0] := Chr(I - T);
    end;
end;

function DecodeUTF8(Text: IvqTextBuffer; var I: Integer; var U: Integer): Boolean;
var
    L, S0, S1, S2, S3, T: Integer;
begin
    L := Text._TextLength;
    Result := False;
    U := 0;
    T := I;
    if I < L then begin
        if Text[I] < #$80 then begin
            S0 := Byte(Text[I]);
            Inc(I);
            Result := True;
        end
        else if Text[I] < #$C0 then
            Inc(I)
        else if Text[I] < #$E0 then begin
            S0 := Byte(Text[I]);
            Inc(I);
            if (I < L) and UTF8IsTrailByte(Text[I]) then begin
                S1 := Byte(Text[I]);
                Inc(I);
                Result := True;
            end;
        end
        else if Text[I] < #$F0 then begin
            S0 := Byte(Text[I]);
            Inc(I);
            if (I < L) and UTF8IsTrailByte(Text[I]) then begin
                S1 := Byte(Text[I]);
                Inc(I);
                if (I < L) and UTF8IsTrailByte(Text[I]) then begin
                    S2 := Byte(Text[I]);
                    Inc(I);
                    Result := True;
                end;
            end;
        end
        else if Text[I] < #$F8 then begin
            S0 := Byte(Text[I]);
            Inc(I);
            if (I < L) and UTF8IsTrailByte(Text[I]) then begin
                S1 := Byte(Text[I]);
                Inc(I);
                if (I < L) and UTF8IsTrailByte(Text[I]) then begin
                    S2 := Byte(Text[I]);
                    Inc(I);
                    if (I < L) and UTF8IsTrailByte(Text[I]) then begin
                        S3 := Byte(Text[I]);
                        Inc(I);
                        Result := True;
                    end;
                end;
            end;
        end
        else 
            Inc(I);
        if Result then
            case I - T of
                1: U := S0;
                2: U := ((S0 and $1F) shl 6) or
                        ((S1 and $3F));
                3: U := ((S0 and $0F) shl 12) or
                        ((S1 and $3F) shl 6) or
                        ((S2 and $3F));
                4: U := ((S0 and $07) shl 18) or
                        ((S1 and $3F) shl 12) or
                        ((S2 and $3F) shl 6) or
                        ((S3 and $3F));
            end;
    end;
end;

function DecodeUTF8Back(Text: IvqTextBuffer; var I: Integer; var U: Integer): Boolean;
var
    K: Integer;
begin
    Result := False;
    if I > 0 then begin
        K := PrevUTF8(Text, I);
        if Text[K] < #$80 then begin
            Result := True;
            U := Byte(Text[K]);
        end
        else if Text[K] < #$C0 then
            Result := False
        else if Text[K] < #$E0 then begin
            Result := I - K = 2;
            if Result then
                U := ((Byte(Text[K]) and $1F) shl 6) or
                     ((Byte(Text[K + 1]) and $3F));
        end
        else if Text[K] < #$F0 then begin
            Result := I - K = 3;
            if Result then
                U := ((Byte(Text[K]) and $0F) shl 12) or
                     ((Byte(Text[K + 1]) and $3F) shl 6) or
                     ((Byte(Text[K + 2]) and $3F));
        end
        else if Text[K] < #$F8 then begin
            Result := I - K = 4;
            if Result then
                U := ((Byte(Text[K]) and $07) shl 18) or
                     ((Byte(Text[K + 1]) and $3F) shl 12) or
                     ((Byte(Text[K + 2]) and $3F) shl 6) or
                     ((Byte(Text[K + 3]) and $3F));
        end
        else
            Result := False;
        I := K;
    end;
end;

function EncodeUTF8(U: Integer): TUTF8Char;
var 
    Utf8Bytes: TvqUTF8Bytes;
begin
    with Utf8Bytes do begin
        if U < $80 then begin
            S := $00000000 or 
                ((U and $0000007F) shl 24);
        end
        else if U < $0800 then begin
            S := $C0800000 or
                ((U and $000007C0) shl 18) or 
                ((U and $0000003F) shl 16);
        end
        else if U < $010000 then begin
            S := $E0808000 or
                ((U and $0000F000) shl 12) or 
                ((U and $00000FC0) shl 10) or 
                ((U and $0000003F) shl 8);
        end
        else if U < $200000 then begin
            S := $F0808080 or
                ((U and $001C0000) shl 6) or 
                ((U and $0003F000) shl 4) or 
                ((U and $00000FC0) shl 2) or 
                ((U and $0000003F) shl 0);
        end
        else
            S := $FFFFFFFF;
    end;
    Result := Utf8Bytes.Get;
end;

function DecodeUTF8(Ch: TUTF8Char): Integer;
var 
    Utf8Bytes: TvqUTF8Bytes;
    U, L: Integer;
begin
    if Ch[0] = #0 then Exit(-1);
    
    U := -1;
    Utf8Bytes.Put(Ch);
    with Utf8Bytes do begin
        L := 0;
        if S0 < #$80 then
            L := 1
        else if S0 < #$C0 then
            begin end
        else if S0 < #$E0 then begin
            if UTF8IsTrailByte(S1) then
                L := 2;
        end
        else if S0 < #$F0 then begin
            if UTF8IsTrailByte(S1) then
                if UTF8IsTrailByte(S2) then
                    L := 3;
        end
        else if S0 < #$F8 then begin
            if UTF8IsTrailByte(S1) then
                if UTF8IsTrailByte(S2) then
                    if UTF8IsTrailByte(S3) then
                        L := 4;
        end;
        
        if L > 0 then
            case L of
                1: U := Byte(S0);
                2: U := ((Byte(S0) and $1F) shl 6) or
                        ((Byte(S1) and $3F));
                3: U := ((Byte(S0) and $0F) shl 12) or
                        ((Byte(S1) and $3F) shl 6) or
                        ((Byte(S2) and $3F));
                4: U := ((Byte(S0) and $07) shl 18) or
                        ((Byte(S1) and $3F) shl 12) or
                        ((Byte(S2) and $3F) shl 6) or
                        ((Byte(S3) and $3F));
            end;
    end;
    Result := U;
end;

//

function UTF8IsTrailByte(B: Byte): Boolean;
begin
    Result := (B >= $80) and (B < $C0);
end;

function UTF8IsTrailByte(C: Char): Boolean;
begin
    Result := (C >= #$80) and (C < #$C0);
end;

function NextUTF8(Text: IvqTextBuffer; I: Integer): Integer;
var
    L: Integer;
begin
    L := Text._TextLength;
    if I < L then begin
        if Text[I] < #$80 then
            Inc(I)
        else if Text[I] < #$C0 then
            Inc(I)
        else if Text[I] < #$E0 then begin
            Inc(I);
            if (I < L) and UTF8IsTrailByte(Text[I]) then
                Inc(I);
        end
        else if Text[I] < #$F0 then begin
            Inc(I);
            if (I < L) and UTF8IsTrailByte(Text[I]) then begin
                Inc(I);
                if (I < L) and UTF8IsTrailByte(Text[I]) then
                    Inc(I);
            end;
        end
        else if Text[I] < #$F8 then begin
            Inc(I);
            if (I < L) and UTF8IsTrailByte(Text[I]) then begin
                Inc(I);
                if (I < L) and UTF8IsTrailByte(Text[I]) then begin
                    Inc(I);
                    if (I < L) and UTF8IsTrailByte(Text[I]) then
                        Inc(I);
                end;
            end;
        end
        else 
            Inc(I);
    end;
    Result := I;
end;

function PrevUTF8(Text: IvqTextBuffer; I: Integer): Integer;
var
    K: Integer;
begin
    if I > 0 then begin
        Dec(I);
        if Text[I] < #$80 then
            begin end
        else if Text[I] < #$C0 then begin
            K := I;
            Dec(I);
            if UTF8IsTrailByte(Text[I]) then begin
                Dec(I);
                if UTF8IsTrailByte(Text[I]) then begin
                    Dec(I);
                end;
            end;
            if Text[I] < #$C0 then I := K // isolated trailing byte
            else if Text[I] >= #$F8 then I := K; // unsupported utf-8
        end;
    end;
    Result := I;
end;

function UTF8Length(Text: IvqTextBuffer): Integer;
var
    L, I: Integer;
begin
    Result := 0;
    L := Text._TextLength;
    I := 0;
    while I < L do begin
        I := NextUTF8(Text, I);
        Inc(Result);
    end;
end;

//

function CaseSensitiveSameText(TextA: IvqTextBuffer; PosA: Integer;
    TextB: IvqTextBuffer; PosB: Integer; Len: Integer): Boolean;
var
    I: Integer;
begin
    Result := False;
    if PosA + Len > TextA._TextLength then Exit;
    if PosB + Len > TextB._TextLength then Exit;
    for I := 0 to Len - 1 do
        if TextA[PosA + I] <> TextB[PosB + I] then
            Exit;
    Result := True;
end;

function CaseInsensitiveSameText(TextA: IvqTextBuffer; PosA: Integer;
    TextB: IvqTextBuffer; PosB: Integer; Len: Integer): Boolean;
var
    Ia, Ib, LimitA, LimitB: Integer;
    DecA, DecB: Boolean;
    UniA, UniB: Integer;
begin
    Result := False;
    
    if PosA + Len > TextA._TextLength then Exit;
    if PosB + Len > TextB._TextLength then Exit;
    
    LimitA := PosA + Len;
    LimitB := PosB + Len;
    while (PosA < LimitA) and (PosB < LimitB) do begin
        Ia := PosA;
        Ib := PosB;
        DecA := DecodeUTF8(TextA, PosA, UniA);
        DecB := DecodeUTF8(TextB, PosB, UniB);
        if PosA > LimitA then DecA := False;
        if PosB > LimitB then DecB := False; //! 
        if DecA and DecB then begin
            UniA := UnicodeUpperCase(UniA);
            UniB := UnicodeUpperCase(UniB);
            if UniA <> UniB then Exit;
        end
        else if DecA then
            Exit
        else if DecB then 
            Exit
        else begin
            if (PosA - Ia) <> (PosB - Ib) then Exit
            else 
                while Ia < PosA do begin
                    if TextA[Ia] <> TextB[Ib] then Exit;
                    Inc(Ia);
                    Inc(Ib);
                end;
        end;
    end;
    Result := True;
end;

function SameText(TextA: IvqTextBuffer; PosA: Integer;
    TextB: IvqTextBuffer; PosB: Integer; Len: Integer; CaseSensitive: Boolean = True): Boolean;
begin
    if CaseSensitive then
        Result := CaseSensitiveSameText(TextA, PosA, TextB, PosB, Len)
    else
        Result := CaseInsensitiveSameText(TextA, PosA, TextB, PosB, Len)
end;

//

const
    CASE_CHAR   = 0;
    CASE_MAP    = 1;
    CASE_LENGTH = 2;
    CASE_PITCH  = 3;

function FindUpperCase(M: Integer): Integer;
var
    ALower, AUpper, AMiddle: Integer;
    ACharMiddle, Delta: Word;
    
begin
    Result := M;
    // find in ascii
    if M < $80 then begin
        if (M >= $0061) and (M < $0061 + 26) then
            Result := M - 32;
    end
    // find in ranges
    else begin
        ALower := 0;
        AUpper := CONVERTION_RANGE_COUNT - 1;
        repeat
            AMiddle := (AUpper - ALower + 1) div 2;
            ACharMiddle := UpperCaseConvertionRanges[AMiddle, CASE_CHAR];
            if M < ACharMiddle then AUpper := AMiddle - 1
            else ALower := AMiddle;
        until ALower >= AUpper;
        if UpperCaseConvertionRanges[ALower, CASE_PITCH] = 1 then begin
            if M < (UpperCaseConvertionRanges[ALower, CASE_CHAR] + 
                    UpperCaseConvertionRanges[ALower, CASE_LENGTH]) then
                Result := M - UpperCaseConvertionRanges[ALower, CASE_CHAR] + 
                    UpperCaseConvertionRanges[ALower, CASE_MAP];
        end
        else begin
            Delta := M - UpperCaseConvertionRanges[ALower, CASE_CHAR];
            if (Delta < (2*UpperCaseConvertionRanges[ALower, CASE_LENGTH])) and
                ((Delta mod 2) = 0) then
                Result := M - 1;
        end;
    end;
    
    // find in single mapping
    if Result = M then begin
        ALower := 0;
        AUpper := CONVERTION_MAP_COUNT - 1;
        repeat
            AMiddle := (AUpper - ALower + 1) div 2;
            ACharMiddle := UpperCaseConvertions[AMiddle, CASE_CHAR];
            if M < ACharMiddle then AUpper := AMiddle - 1
            else ALower := AMiddle;
        until ALower >= AUpper;
        if M = UpperCaseConvertions[AMiddle, CASE_CHAR] then
            Result := UpperCaseConvertions[AMiddle, CASE_MAP];
    end;
    
end;

function FindLowerCase(M: Integer): Integer;
var
    ALower, AUpper, AMiddle: Integer;
    ACharMiddle, Delta: Word;
    
begin
    Result := M;
    // find in ascii
    if M < $80 then begin
        if (M >= $0041) and (M < $0041 + 26) then
            Result := M + 32;
    end
    // find in ranges
    else begin
        ALower := 0;
        AUpper := CONVERTION_RANGE_COUNT - 1;
        repeat
            AMiddle := (AUpper - ALower + 1) div 2;
            ACharMiddle := LowerCaseConvertionRanges[AMiddle, CASE_CHAR];
            if M < ACharMiddle then AUpper := AMiddle - 1
            else ALower := AMiddle;
        until ALower >= AUpper;
        if LowerCaseConvertionRanges[ALower, CASE_PITCH] = 1 then begin
            if M < (LowerCaseConvertionRanges[ALower, CASE_CHAR] + 
                    LowerCaseConvertionRanges[ALower, CASE_LENGTH]) then
                Result := M - LowerCaseConvertionRanges[ALower, CASE_CHAR] + 
                    LowerCaseConvertionRanges[ALower, CASE_MAP];
        end
        else begin
            Delta := M - LowerCaseConvertionRanges[ALower, CASE_CHAR];
            if (Delta < (2*LowerCaseConvertionRanges[ALower, CASE_LENGTH])) and
                ((Delta mod 2) = 0) then
                Result := M + 1;
        end;
    end;
    // find in single mapping
    if Result = M then begin
        ALower := 0;
        AUpper := CONVERTION_MAP_COUNT - 1;
        repeat
            AMiddle := (AUpper - ALower + 1) div 2;
            ACharMiddle := LowerCaseConvertions[AMiddle, CASE_CHAR];
            if M < ACharMiddle then AUpper := AMiddle - 1
            else ALower := AMiddle;
        until ALower >= AUpper;
        if M = LowerCaseConvertions[AMiddle, CASE_CHAR] then
            Result := LowerCaseConvertions[AMiddle, CASE_MAP];
    end;
    
end;

function UnicodeIsLowerCase(M: Integer): Boolean;
begin
    Result := FindUpperCase(M) <> M;
end;

function UnicodeIsUpperCase(M: Integer): Boolean;
begin
    Result := FindLowerCase(M) <> M;
end;

function UnicodeUpperCase(M: Integer): Integer;
begin
    Result := FindUpperCase(M);
end;

function UnicodeLowerCase(M: Integer): Integer;
begin
    Result := FindLowerCase(M);
end;

function UTF8CharUpperCase(MCh: TUTF8Char): TUTF8Char;
var
    MixedU: Integer;
begin
    MixedU := DecodeUTF8(MCh);
    if MixedU > -1 then 
        Result := EncodeUTF8(UnicodeUpperCase(MixedU))
    else
        Result := MCh;
end;

function UTF8CharLowerCase(MCh: TUTF8Char): TUTF8Char;
var
    MixedU: Integer;
begin
    MixedU := DecodeUTF8(MCh);
    if MixedU > -1 then 
        Result := EncodeUTF8(UnicodeLowerCase(MixedU))
    else
        Result := MCh;
end;

//

function UTF8StringUpperCase(MixedStr: ansistring): ansistring;
var
    Text: TvqStringText;
    CaseStr: TCharArray;
begin
    Text := TvqStringText.CreatePointer(MixedStr);
    if UTF8TextUpperCase(Text, 0, Length(MixedStr), CaseStr) then
        CharArrayToString(CaseStr, Result)
    else
        Result := '';
    Text.Free;
end;

function UTF8StringLowerCase(MixedStr: ansistring): ansistring;
var
    Text: TvqStringText;
    CaseStr: TCharArray;
begin
    Text := TvqStringText.CreatePointer(MixedStr);
    if UTF8TextLowerCase(Text, 0, Length(MixedStr), CaseStr) then
        CharArrayToString(CaseStr, Result)
    else
        Result := '';
    Text.Free;
end;

function UTF8ArrayUpperCase(MixedStr: TCharArray; var CaseStr: TCharArray): Boolean;
var
    Text: TvqCharArrayText;
begin
    Result := False;
    Text := TvqCharArrayText.Create(MixedStr);
    if UTF8TextUpperCase(Text, 0, Length(MixedStr), CaseStr) then
        begin Result := True; end
    else 
        CaseStr := nil;
    Text.Free;
end;

function UTF8ArrayLowerCase(MixedStr: TCharArray; var CaseStr: TCharArray): Boolean;
var
    Text: TvqCharArrayText;
begin              
    Result := False;
    Text := TvqCharArrayText.Create(MixedStr);
    if UTF8TextLowerCase(Text, 0, Length(MixedStr), CaseStr) then
        begin Result := True; end
    else 
        CaseStr := nil;
    Text.Free;
end;

function UTF8TextUpperCase(Text: IvqTextBuffer; Pos, Len: Integer;
    var CaseStr: TCharArray): Boolean;
var
    Limit, K, I: Integer;
    MixedU: Integer;
    CaseChar: TUTF8Char;
begin
    Result := False;
    Limit := Min(Pos + Len, Text._TextLength);
    SetLength(CaseStr, Limit - Pos);
    while Pos < Limit do begin
        I := Pos;
        K := I;
        if DecodeUTF8(Text, Pos, MixedU) then begin
            CaseChar := EncodeUTF8(UnicodeUpperCase(MixedU));
            System.Move(CaseChar[1], CaseStr[I], Pos - I);
            I := Pos;
        end
        else
            while I < Pos do begin
                CaseStr[I] := Text[I];
                Inc(I);
            end;
    end;
    Result := True;
end;

function UTF8TextLowerCase(Text: IvqTextBuffer; Pos, Len: Integer;
    var CaseStr: TCharArray): Boolean;
var
    Limit, K, I: Integer;
    MixedU: Integer;
    CaseChar: TUTF8Char;
begin
    Result := False;
    Limit := Min(Pos + Len, Text._TextLength);
    SetLength(CaseStr, Limit - Pos);
    while Pos < Limit do begin
        I := Pos;
        K := I;
        if DecodeUTF8(Text, Pos, MixedU) then begin
            CaseChar := EncodeUTF8(UnicodeLowerCase(MixedU));
            System.Move(CaseChar[1], CaseStr[I], Pos - I);
            I := Pos;
        end
        else
            while I < Pos do begin
                CaseStr[I] := Text[I];
                Inc(I);
            end;
    end;
    Result := True;
end;

function EqualUTF8Char(TextA: IvqTextBuffer; var TextAI: Integer;
    TextB: IvqTextBuffer; var TextBI: Integer): Boolean;
var
    Limit: Integer;
begin
    Result := False;
    Limit := NextUTF8(TextB, TextBI);
    if TextAI + Limit - TextBI <= TextA._TextLength then
        case Limit - TextBI of
            1: Result := TextA[TextAI] = TextB[TextBI];
            2: Result := (TextA[TextAI + 0] = TextB[TextBI + 0]) and
                        (TextA[TextAI + 1] = TextB[TextBI + 1]);
            3: Result := (TextA[TextAI + 0] = TextB[TextBI + 0]) and
                        (TextA[TextAI + 1] = TextB[TextBI + 1]) and
                        (TextA[TextAI + 2] = TextB[TextBI + 2]);
            4: Result := (TextA[TextAI + 0] = TextB[TextBI + 0]) and
                        (TextA[TextAI + 1] = TextB[TextBI + 1]) and
                        (TextA[TextAI + 2] = TextB[TextBI + 2]) and
                        (TextA[TextAI + 3] = TextB[TextBI + 3]);
        end;
end;

function UTF8Search(Text: IvqTextBuffer; Search: TCharArray; PosFrom, PosTo: Integer;
    CaseSensitive, WholeWord: Boolean): Integer;

var
    AForward: Boolean;
    Delta, Len, Pos, I, PosLimit, Length: Integer;
    Found: Boolean;
    
    SearchUpper, SearchLower: TCharArray;
    SearchTextLower, SearchTextUpper: TvqCharArrayText;
    
    function CompareULUtf8Char(var K: Integer): Boolean;
    var
        P: Integer;
    begin
        Result := False;
        P := Pos + K;
        if EqualUTF8Char(Text, P, SearchTextUpper, K) then
            Result := True
        else if EqualUTF8Char(Text, P, SearchTextLower, K) then
            Result := True;
    end;
    
begin
    Result := -1;
    
    Len := System.Length(Search);
    Length := Text._TextLength;
    if PosFrom < 0 then PosFrom := 0;
    if PosFrom > Length then PosFrom := Length;
    if PosTo < 0 then PosTo := 0;
    if PosTo > Length then PosTo := Length;
    if (Len = 0) or (PosFrom = PosTo) then Exit;
    
    AForward := PosFrom <= PosTo;
    Delta := IfThenElse(AForward, 1, -1);
    Pos := IfThenElse(AForward, PosFrom, PosFrom - 1);
    PosLimit := Max(PosFrom, PosTo);
    
    Found := False;
    if CaseSensitive then begin
        while IfThenElse(AForward, Pos <= PosTo - Len, Pos >= PosTo) do begin
            Found := (Text[Pos] = Search[0]) and (Pos + Len <= PosLimit);
            if Found then begin
                for I :=  1 to Len - 1 do begin
                    Found := Text[Pos + I] = Search[I];
                    if not Found then Break;
                end;
                if Found then begin
                    if WholeWord then begin
                        if Text._WholeWordAt(Pos, Pos + Len) then
                            Break
                        else
                            Found := False;
                    end
                    else
                        Break;
                end;
            end;
            Inc(Pos, Delta);
        end;
    end
    else begin
        UTF8ArrayUpperCase(Search, SearchUpper);
        UTF8ArrayLowerCase(Search, SearchLower);
        SearchTextUpper := TvqCharArrayText.Create(SearchUpper);
        SearchTextLower := TvqCharArrayText.Create(SearchLower);
        
        while IfThenElse(AForward, Pos <= PosTo - Len, Pos >= PosTo) do begin
            I := 0;
            Found := CompareULUtf8Char(I) and (Pos + Len <= PosLimit);
            if Found then begin
                while I < Len do begin
                    Found := CompareULUtf8Char(I);
                    if not Found then Break;
                end;
                if Found then begin
                    if WholeWord then begin
                        if Text._WholeWordAt(Pos, Pos + Len) then
                            Break
                        else
                            Found := False;
                    end
                    else
                        Break;
                end;
            end;
            Inc(Pos, Delta);
        end;
        
        SearchTextUpper.Free;
        SearchTextLower.Free;
    end;
    if Found then Result := Pos;
end;

function UTF8CharExtent(Canvas: TCanvas; S: TUTF8Char; ExpandTabs: Boolean): TSize;
var
    R: TRect;
begin
    R := Rect(0, 0, 1, 1);
    Result := TextRectExtent(Canvas.Handle, R, S, LineTextStyle(ExpandTabs));
end;

