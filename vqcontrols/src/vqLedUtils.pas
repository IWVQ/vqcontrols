// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqLedUtils;

interface

uses
    Types, Classes, SysUtils, Math,  Graphics,
    BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
    vqUtils, vqThemes;

const

    LED_SPEC_MASK   = $F000;
    
    LED_SPEC_EMPTY  = $1000;
    LED_SPEC_DOT    = $2000;
    LED_SPEC_UPDOT  = $3000;
    LED_SPEC_COLON  = $4000;
    
    LED_7S_O        = $0000;
    LED_7S_A        = $0001;
    LED_7S_B        = $0002;
    LED_7S_C        = $0004;
    LED_7S_D        = $0008;
    LED_7S_E        = $0010;
    LED_7S_F        = $0020;
    LED_7S_G        = $0040;
    
    LED_12S_O       = $0000;
    LED_12S_A1      = $0001;
    LED_12S_A2      = $0002;
    LED_12S_B       = $0004;
    LED_12S_C       = $0008;
    LED_12S_D1      = $0010;
    LED_12S_D2      = $0020;
    LED_12S_E       = $0040;
    LED_12S_F       = $0080;
    LED_12S_G1      = $0100;
    LED_12S_G2      = $0200;
    LED_12S_H       = $0400;
    LED_12S_I       = $0800;
    
{

.,':

7 segment leds:
    0123456789
    ABCDEF P
    abcdef p
    E
    SPACE
    -
    
12 segment leds:
    0123456789
    abcdefghijklmnopqrstuvwxyz
    ABCDEFGHIJKLMNOPQRSTUVWXYZ
    SPACE
    -+
}

function Parse7SegmentLeds(Text: IvqTextBuffer; var Leds: TWordArray; DigitCount: Integer; Alignment: TLeftRight): Boolean;
function Parse12SegmentLeds(Text: IvqTextBuffer; var Leds: TWordArray; DigitCount: Integer; Alignment: TLeftRight): Boolean;

procedure Render7SegmentLeds(Bitmap: TBGRABitmap; Rect: TRect; X, Y: Integer; Leds: TWordArray; 
    ColorOn, ColorOff: TColor;
    LedWidth, LedHeight, LedThickness, LedSpacing: Integer);
procedure Render12SegmentLeds(Bitmap: TBGRABitmap; Rect: TRect; X, Y: Integer; Leds: TWordArray; 
    ColorOn, ColorOff: TColor;
    LedWidth, LedHeight, LedThickness, LedSpacing: Integer);

implementation

function Parse7SegmentLeds(Text: IvqTextBuffer; var Leds: TWordArray;
    DigitCount: Integer; Alignment: TLeftRight): Boolean;
var
    I, K, S, Len: Integer;
begin
    Result := False;
    Len := Text._TextLength;
    SetLength(Leds, DigitCount);
    
    if Len >= DigitCount then begin
        S := 0;
        Len := DigitCount;
    end
    else if Alignment = taLeftJustify then S := 0
    else S := DigitCount - Len;
    
    K := 0;
    while K < S do begin
        Leds[K] := LED_7S_O;
        Inc(K);
    end;
    
    I := 0;
    while I < Len do begin
        case Text[I] of
            '0' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_C or LED_7S_D or LED_7S_E or LED_7S_F;
            '1' : Leds[K] := LED_7S_B or LED_7S_C;
            '2' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_D or LED_7S_E or LED_7S_G;
            '3' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_C or LED_7S_D or LED_7S_G;
            '4' : Leds[K] := LED_7S_B or LED_7S_C or LED_7S_F or LED_7S_G;
            '5' : Leds[K] := LED_7S_A or LED_7S_C or LED_7S_D or LED_7S_F or LED_7S_G;
            '6' : Leds[K] := LED_7S_A or LED_7S_C or LED_7S_D or LED_7S_E or LED_7S_F or LED_7S_G;
            '7' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_C;
            '8' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_C or LED_7S_D or LED_7S_E or LED_7S_F or LED_7S_G;
            '9' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_C or LED_7S_D or LED_7S_F or LED_7S_G;
            'A' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_C or LED_7S_E or LED_7S_F or LED_7S_G;
            'B' : Leds[K] := LED_7S_C or LED_7S_D or LED_7S_E or LED_7S_F or LED_7S_G;
            'C' : Leds[K] := LED_7S_A or LED_7S_D or LED_7S_E or LED_7S_F;
            'D' : Leds[K] := LED_7S_B or LED_7S_C or LED_7S_D or LED_7S_E or LED_7S_G;
            'E' : Leds[K] := LED_7S_A or LED_7S_D or LED_7S_E or LED_7S_F or LED_7S_G;
            'F' : Leds[K] := LED_7S_A or LED_7S_E or LED_7S_F or LED_7S_G;
            'a' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_C or LED_7S_D or LED_7S_E or LED_7S_G;
            'b' : Leds[K] := LED_7S_C or LED_7S_D or LED_7S_E or LED_7S_F or LED_7S_G;
            'c' : Leds[K] := LED_7S_D or LED_7S_E or LED_7S_G;
            'd' : Leds[K] := LED_7S_B or LED_7S_C or LED_7S_D or LED_7S_E or LED_7S_G;
            'e' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_D or LED_7S_E or LED_7S_F or LED_7S_G;
            'f' : Leds[K] := LED_7S_A or LED_7S_E or LED_7S_F or LED_7S_G;
            'P' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_E or LED_7S_F or LED_7S_G;
            'p' : Leds[K] := LED_7S_A or LED_7S_B or LED_7S_E or LED_7S_F or LED_7S_G;
            ' ' : Leds[K] := LED_7S_O;
            '-' : Leds[K] := LED_7S_G;
            
            '.' : Leds[K] := LED_SPEC_DOT;
            ',' : Leds[K] := LED_SPEC_DOT;
            '''': Leds[K] := LED_SPEC_UPDOT;
            ':' : Leds[K] := LED_SPEC_COLON;
            else  Leds[K] := LED_SPEC_EMPTY;
        end;
        Inc(I);
        Inc(K);
    end;
    Result := True;
end;

function Parse12SegmentLeds(Text: IvqTextBuffer; var Leds: TWordArray;
    DigitCount: Integer; Alignment: TLeftRight): Boolean;
var 
    I, K, S, Len: Integer;
begin
    Result := False;
    Len := Text._TextLength;
    SetLength(Leds, DigitCount);
    
    if Len >= DigitCount then begin
        S := 0;
        Len := DigitCount;
    end
    else if Alignment = taLeftJustify then S := 0
    else S := DigitCount - Len;
    
    K := 0;
    while K < S do begin
        Leds[K] := LED_12S_O;
        Inc(K);
    end;
    
    I := 0;
    while I < Len do begin
        case Text[I] of
            '0' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            '1' : Leds[K] := LED_12S_B or LED_12S_C;
            '2' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_D1 or LED_12S_D2;
            '3' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            '4' : Leds[K] := LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_C;
            '5' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_G1 or LED_12S_G2 or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            '6' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            '7' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_B or LED_12S_C;
            '8' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            '9' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            'A' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_C;
            'B' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_H or LED_12S_B or LED_12S_G2 or LED_12S_I or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            'C' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_E or LED_12S_D1 or LED_12S_D2;
            'D' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_H or LED_12S_B or LED_12S_I or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            'E' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_D1 or LED_12S_D2;
            'F' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_G1 or LED_12S_G2 or LED_12S_E;
            'G' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_G2 or LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            'H' : Leds[K] := LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_C; 
            'I' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_H or LED_12S_I or LED_12S_D1 or LED_12S_D2; 
            'J' : Leds[K] := LED_12S_B or LED_12S_C or LED_12S_D1 or LED_12S_D2; 
            'K' : Leds[K] := LED_12S_A2 or LED_12S_F or LED_12S_H or LED_12S_G1 or LED_12S_E or LED_12S_I or LED_12S_D2; 
            'L' : Leds[K] := LED_12S_F or LED_12S_E or LED_12S_D1 or LED_12S_D2;
            'M' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_H or LED_12S_B or LED_12S_E or LED_12S_C; 
            'N' : Leds[K] := LED_12S_A1 or LED_12S_F or LED_12S_H or LED_12S_B or LED_12S_E or LED_12S_I or LED_12S_C or LED_12S_D2; 
            'O' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2; 
            'P' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E; 
            'Q' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_E or LED_12S_I or LED_12S_C or LED_12S_D1 or LED_12S_D2; 
            'R' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_I or LED_12S_D2; 
            'S' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_G1 or LED_12S_G2 or LED_12S_C or LED_12S_D1 or LED_12S_D2; 
            'T' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_H or LED_12S_I; 
            'U' : Leds[K] := LED_12S_F or LED_12S_B or LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2; 
            'V' : Leds[K] := LED_12S_F or LED_12S_B or LED_12S_G2 or LED_12S_E or LED_12S_I or LED_12S_D1; 
            'W' : Leds[K] := LED_12S_F or LED_12S_B or LED_12S_E or LED_12S_I or LED_12S_C or LED_12S_D1 or LED_12S_D2; 
            'X' : Leds[K] := LED_12S_F or LED_12S_H or LED_12S_G1 or LED_12S_G2 or LED_12S_I or LED_12S_C; 
            'Y' : Leds[K] := LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_C or LED_12S_D1 or LED_12S_D2; 
            'Z' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_D1 or LED_12S_D2; 
            'a' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            'b' : Leds[K] := LED_12S_F or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            'c' : Leds[K] := LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_D1 or LED_12S_D2;
            'd' : Leds[K] := LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            'e' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_D1 or LED_12S_D2;
            'f' : Leds[K] := LED_12S_A2 or LED_12S_H or LED_12S_G1 or LED_12S_G2 or LED_12S_I;
            'g' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_C or LED_12S_D1 or LED_12S_D2;
            'h' : Leds[K] := LED_12S_F or LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_C; 
            'i' : Leds[K] := LED_12S_H or LED_12S_I; 
            'j' : Leds[K] := LED_12S_H or LED_12S_I or LED_12S_D1; 
            'k' : Leds[K] := LED_12S_G2 or LED_12S_E or LED_12S_I or LED_12S_D1 or LED_12S_D2; 
            'l' : Leds[K] := LED_12S_A1 or LED_12S_H or LED_12S_I or LED_12S_D1 or LED_12S_D2;
            'm' : Leds[K] := LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_I or LED_12S_C; 
            'n' : Leds[K] := LED_12S_G1 or LED_12S_E or LED_12S_I or LED_12S_C or LED_12S_D2; 
            'o' : Leds[K] := LED_12S_G1 or LED_12S_G2 or LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2; 
            'p' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_E; 
            'q' : Leds[K] := LED_12S_A1 or LED_12S_A2 or LED_12S_F or LED_12S_B or LED_12S_G1 or LED_12S_G2 or LED_12S_C; 
            'r' : Leds[K] := LED_12S_G1 or LED_12S_G2 or LED_12S_E; 
            's' : Leds[K] := LED_12S_A2 or LED_12S_H or LED_12S_G2 or LED_12S_C or LED_12S_D2; 
            't' : Leds[K] := LED_12S_H or LED_12S_G1 or LED_12S_G2 or LED_12S_I or LED_12S_D2; 
            'u' : Leds[K] := LED_12S_E or LED_12S_C or LED_12S_D1 or LED_12S_D2; 
            'v' : Leds[K] := LED_12S_G2 or LED_12S_E or LED_12S_I or LED_12S_D1; 
            'w' : Leds[K] := LED_12S_E or LED_12S_I or LED_12S_C or LED_12S_D1 or LED_12S_D2; 
            'x' : Leds[K] := LED_12S_F or LED_12S_H or LED_12S_G1 or LED_12S_G2 or LED_12S_I or LED_12S_C; 
            'y' : Leds[K] := LED_12S_H or LED_12S_B or LED_12S_G2 or LED_12S_C or LED_12S_D2; 
            'z' : Leds[K] := LED_12S_A1 or LED_12S_H or LED_12S_I or LED_12S_D2;
            
            ' ' : Leds[K] := LED_12S_O;
            '-' : Leds[K] := LED_12S_G1 or LED_12S_G2;
            '+' : Leds[K] := LED_12S_G1 or LED_12S_G2 or LED_12S_H or LED_12S_I;
            
            '.' : Leds[K] := LED_SPEC_DOT;
            ',' : Leds[K] := LED_SPEC_DOT;
            '''': Leds[K] := LED_SPEC_UPDOT;
            ':' : Leds[K] := LED_SPEC_COLON;
            else  Leds[K] := LED_SPEC_EMPTY;
        end;
        Inc(I);
        Inc(K);
    end;
    Result := True;
end;

procedure RenderSpecialLed(Bitmap: TBGRABitmap; var X, Y: Integer; Led: Word;
    Color: TColor;
    LedWidth, LedHeight, LedThickness, LedSpacing: Integer);
var
    D: Integer;
    R: TRect;
begin
    case Led and LED_SPEC_MASK of
        LED_SPEC_EMPTY: Inc(X, LedWidth + LedSpacing);
        LED_SPEC_DOT: with R do begin
            Left := X;
            Right := X + LedThickness;
            Bottom := Y + LedHeight;
            Top := Bottom - LedThickness;
            Bitmap.FillRect(Left, Top, Right, Bottom, Color, dmSet);
            Inc(X, LedThickness + LedSpacing);
        end;
        LED_SPEC_UPDOT: with R do begin
            Left := X;
            Right := X + LedThickness;
            Top := Y;
            Bottom := Top + LedThickness;
            Bitmap.FillRect(Left, Top, Right, Bottom, Color, dmSet);
            Inc(X, LedThickness + LedSpacing);
        end;
        LED_SPEC_COLON: with R do begin
            Left := X;
            Right := X + LedThickness;
            
            D := (LedHeight - LedThickness) div 3;
            Top := Y + D;
            Bottom := Top + LedThickness;
            Bitmap.FillRect(Left, Top, Right, Bottom, Color, dmSet);
            
            Bottom := Y + LedHeight - D;
            Top := Bottom - LedThickness;
            Bitmap.FillRect(Left, Top, Right, Bottom, Color, dmSet);
            Inc(X, LedThickness + LedSpacing);
        end;
    end;
end;

procedure Render7SegmentLeds(Bitmap: TBGRABitmap; Rect: TRect; X, Y: Integer; Leds: TWordArray; 
    ColorOn, ColorOff: TColor;
    LedWidth, LedHeight, LedThickness, LedSpacing: Integer);
var
    I, D: Integer;
    R: TRect;
begin
    with R do begin
        
        D := Y + (LedHeight - LedThickness) div 2;
        for I := 0 to Length(Leds) - 1 do begin
            if (Leds[I] and LED_SPEC_MASK) <> 0 then
                RenderSpecialLed(Bitmap, X, Y, Leds[I], ColorOn,
                    LedWidth, LedHeight, LedThickness, LedSpacing)
            else begin
                // track
                    // A 
                Left := X;
                Right := X + LedWidth;
                Top := Y;
                Bottom := Top + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // B 
                Right := X + LedWidth;
                Left := Right - LedThickness;
                Top := Y;
                Bottom := D + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // C 
                Right := X + LedWidth;
                Left := Right - LedThickness;
                Top := D;
                Bottom := Y + LedHeight;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // D 
                Left := X;
                Right := X + LedWidth;
                Bottom := Y + LedHeight;
                Top := Bottom - LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // E 
                Left := X;
                Right := Left + LedThickness;
                Top := D;
                Bottom := Y + LedHeight;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // F 
                Left := X;
                Right := X + LedThickness;
                Top := Y;
                Bottom := D + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // G 
                Left := X;
                Right := X + LedWidth;
                Top := D;
                Bottom := Top + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                // led
                // A 
                if (Leds[I] and LED_7S_A) <> 0 then begin
                    Left := X;
                    Right := X + LedWidth;
                    Top := Y;
                    Bottom := Top + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // B 
                if (Leds[I] and LED_7S_B) <> 0 then begin
                    Right := X + LedWidth;
                    Left := Right - LedThickness;
                    Top := Y;
                    Bottom := D + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // C 
                if (Leds[I] and LED_7S_C) <> 0 then begin
                    Right := X + LedWidth;
                    Left := Right - LedThickness;
                    Top := D;
                    Bottom := Y + LedHeight;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // D 
                if (Leds[I] and LED_7S_D) <> 0 then begin
                    Left := X;
                    Right := X + LedWidth;
                    Bottom := Y + LedHeight;
                    Top := Bottom - LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // E 
                if (Leds[I] and LED_7S_E) <> 0 then begin
                    Left := X;
                    Right := Left + LedThickness;
                    Top := D;
                    Bottom := Y + LedHeight;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // F 
                if (Leds[I] and LED_7S_F) <> 0 then begin
                    Left := X;
                    Right := X + LedThickness;
                    Top := Y;
                    Bottom := D + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // G
                if (Leds[I] and LED_7S_G) <> 0 then begin
                    Left := X;
                    Right := X + LedWidth;
                    Top := D;
                    Bottom := Top + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                //
                
                Inc(X, LedWidth + LedSpacing);
            end;
            
        end;
        
        // 
        
    end;
end;

procedure Render12SegmentLeds(Bitmap: TBGRABitmap; Rect: TRect; X, Y: Integer; Leds: TWordArray; 
    ColorOn, ColorOff: TColor;
    LedWidth, LedHeight, LedThickness, LedSpacing: Integer);
var
    I, D, F: Integer;
    R: TRect;
begin
    with R do begin
        
        D := Y + (LedHeight - LedThickness) div 2;
        for I := 0 to Length(Leds) - 1 do begin
            if (Leds[I] and LED_SPEC_MASK) <> 0 then
                RenderSpecialLed(Bitmap, X, Y, Leds[I], ColorOn,
                    LedWidth, LedHeight, LedThickness, LedSpacing)
            else begin
                F := X + (LedWidth - LedThickness) div 2;
                    // A1 
                Left := X;
                Right := F + LedThickness;
                Top := Y;
                Bottom := Top + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // A2 
                Left := F;
                Right := X + LedWidth;
                Top := Y;
                Bottom := Top + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // B 
                Right := X + LedWidth;
                Left := Right - LedThickness;
                Top := Y;
                Bottom := D + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // C 
                Right := X + LedWidth;
                Left := Right - LedThickness;
                Top := D;
                Bottom := Y + LedHeight;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // D1 
                Left := X;
                Right := F + LedThickness;
                Bottom := Y + LedHeight;
                Top := Bottom - LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // D2 
                Left := F;
                Right := X + LedWidth;
                Bottom := Y + LedHeight;
                Top := Bottom - LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // E 
                Left := X;
                Right := Left + LedThickness;
                Top := D;
                Bottom := Y + LedHeight;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // F 
                Left := X;
                Right := X + LedThickness;
                Top := Y;
                Bottom := D + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // G1 
                Left := X;
                Right := F + LedThickness;
                Top := D;
                Bottom := Top + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // G2 
                Left := F;
                Right := X + LedWidth;
                Top := D;
                Bottom := Top + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                    
                    // H 
                Left := F;
                Right := Left + LedThickness;
                Top := Y;
                Bottom := D + LedThickness;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                    // I 
                Left := F;
                Right := Left + LedThickness;
                Top := D;
                Bottom := Y + LedHeight;
                Bitmap.FillRect(Left, Top, Right, Bottom, ColorOff, dmSet);
                
                // led
                // A1 
                if (Leds[I] and LED_12S_A1) <> 0 then begin
                    Left := X;
                    Right := F + LedThickness;
                    Top := Y;
                    Bottom := Top + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // A2 
                if (Leds[I] and LED_12S_A2) <> 0 then begin
                    Left := F;
                    Right := X + LedWidth;
                    Top := Y;
                    Bottom := Top + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // B 
                if (Leds[I] and LED_12S_B) <> 0 then begin
                    Right := X + LedWidth;
                    Left := Right - LedThickness;
                    Top := Y;
                    Bottom := D + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // C 
                if (Leds[I] and LED_12S_C) <> 0 then begin
                    Right := X + LedWidth;
                    Left := Right - LedThickness;
                    Top := D;
                    Bottom := Y + LedHeight;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // D1 
                if (Leds[I] and LED_12S_D1) <> 0 then begin
                    Left := X;
                    Right := F + LedThickness;
                    Bottom := Y + LedHeight;
                    Top := Bottom - LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // D2 
                if (Leds[I] and LED_12S_D2) <> 0 then begin
                    Left := F;
                    Right := X + LedWidth;
                    Bottom := Y + LedHeight;
                    Top := Bottom - LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // E 
                if (Leds[I] and LED_12S_E) <> 0 then begin
                    Left := X;
                    Right := Left + LedThickness;
                    Top := D;
                    Bottom := Y + LedHeight;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // F 
                if (Leds[I] and LED_12S_F) <> 0 then begin
                    Left := X;
                    Right := X + LedThickness;
                    Top := Y;
                    Bottom := D + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // G1
                if (Leds[I] and LED_12S_G1) <> 0 then begin
                    Left := X;
                    Right := F + LedThickness;
                    Top := D;
                    Bottom := Top + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // G2
                if (Leds[I] and LED_12S_G2) <> 0 then begin
                    Left := F;
                    Right := X + LedWidth;
                    Top := D;
                    Bottom := Top + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // H 
                if (Leds[I] and LED_12S_H) <> 0 then begin
                    Left := F;
                    Right := Left + LedThickness;
                    Top := Y;
                    Bottom := D + LedThickness;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                // I 
                if (Leds[I] and LED_12S_I) <> 0 then begin
                    Left := F;
                    Right := Left + LedThickness;
                    Top := D;
                    Bottom := Y + LedHeight;
                    Bitmap.FillRect(Left, Top, Right, Bottom, ColorOn, dmSet);
                end;
                
                //
                
                Inc(X, LedWidth + LedSpacing);
            end;
            
        end;
        
        // 
        
    end;
end;

end.
