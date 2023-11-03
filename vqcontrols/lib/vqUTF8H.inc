// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqUTF8H.inc               }
{ included in vqUtils.pas   }

type
    TvqCharClass = (ccUnknown, ccWord, ccSpace, ccEoL, ccPunctuation);
    
    TvqUTF8Bytes = packed record
        function Get: TUTF8Char;
        procedure Put(Ch: TUTF8Char);
        case Byte of
            {$IFDEF ENDIAN_LITTLE}
            0: (S3, S2, S1, S0: AnsiChar);
            {$ELSE} // big endian or unknown
            0: (S0, S1, S2, S3: AnsiChar);
            {$ENDIF}
            1: (S: Cardinal);
    end;
    PvqUTF8Bytes = ^TvqUTF8Bytes;
    
const
    UNiReplacementChar: TUTF8Char = '�'; // unicode: FFFD utf8: 11101111101111111011110100000000
    
function SameUTF8(A: TUTF8Char; B: AnsiChar): Boolean; overload; 
function SameUTF8(A: TUTF8Char; B: TUTF8Char): Boolean; overload;

function ScanSpace(Text: IvqTextBuffer; I: Integer): Integer;
function ScanEscapeSequence(Text: IvqTextBuffer; AExtended: Boolean; var I: Integer; 
    var Ch: TUTF8Char): Boolean;
function ScanCharToEscapeSequence(Text: IvqTextBuffer; var I: Integer;
    AEncodeUTF8: Boolean = False): ansistring;
function EscStringToString(S: ansistring; AExtended: Boolean): ansistring;
function StringToEscString(S: ansistring; AEncodeUTF8: Boolean = False): ansistring;

function GetClassOfChar(Ch: Char): TvqCharClass;
function GetClassOfUnicode(U: Integer): TvqCharClass;

function ScanUTF8(Text: IvqTextBuffer; var I: Integer; var Ch: TUTF8Char): Boolean;
function DecodeUTF8(Text: IvqTextBuffer; var I: Integer; var U: Integer): Boolean; overload;
function DecodeUTF8Back(Text: IvqTextBuffer; var I: Integer; var U: Integer): Boolean; overload;
function EncodeUTF8(U: Integer): TUTF8Char;
function DecodeUTF8(Ch: TUTF8Char): Integer; overload;

function UTF8IsTrailByte(B: Byte): Boolean; overload;
function UTF8IsTrailByte(C: Char): Boolean; overload;
function NextUTF8(Text: IvqTextBuffer; I: Integer): Integer;
function PrevUTF8(Text: IvqTextBuffer; I: Integer): Integer;
function UTF8Length(Text: IvqTextBuffer): Integer;

function CaseSensitiveSameText(TextA: IvqTextBuffer; PosA: Integer;
    TextB: IvqTextBuffer; PosB: Integer; Len: Integer): Boolean;
function CaseInsensitiveSameText(TextA: IvqTextBuffer; PosA: Integer;
    TextB: IvqTextBuffer; PosB: Integer; Len: Integer): Boolean;
function SameText(TextA: IvqTextBuffer; PosA: Integer;
    TextB: IvqTextBuffer; PosB: Integer; Len: Integer; CaseSensitive: Boolean = True): Boolean;

function FindUpperCase(M: Integer): Integer;
function FindLowerCase(M: Integer): Integer;
function UnicodeIsLowerCase(M: Integer): Boolean;
function UnicodeIsUpperCase(M: Integer): Boolean;
function UnicodeUpperCase(M: Integer): Integer;
function UnicodeLowerCase(M: Integer): Integer;
function UTF8CharUpperCase(MCh: TUTF8Char): TUTF8Char;
function UTF8CharLowerCase(MCh: TUTF8Char): TUTF8Char;

function UTF8StringUpperCase(MixedStr: ansistring): ansistring;
function UTF8StringLowerCase(MixedStr: ansistring): ansistring;
function UTF8ArrayUpperCase(MixedStr: TCharArray; var CaseStr: TCharArray): Boolean;
function UTF8ArrayLowerCase(MixedStr: TCharArray; var CaseStr: TCharArray): Boolean;
function UTF8TextUpperCase(Text: IvqTextBuffer; Pos, Len: Integer;
    var CaseStr: TCharArray): Boolean;
function UTF8TextLowerCase(Text: IvqTextBuffer; Pos, Len: Integer;
    var CaseStr: TCharArray): Boolean;

function EqualUTF8Char(TextA: IvqTextBuffer; var TextAI: Integer;
    TextB: IvqTextBuffer; var TextBI: Integer): Boolean;
function UTF8Search(Text: IvqTextBuffer; Search: TCharArray; PosFrom, PosTo: Integer;
    CaseSensitive, WholeWord: Boolean): Integer;
    
function UTF8CharExtent(Canvas: TCanvas; S: TUTF8Char; ExpandTabs: Boolean): TSize;

const
    
    CONVERTION_RANGE_COUNT = 41;
    CONVERTION_MAP_COUNT = 132;
    
    UpperCaseConvertionRanges: array[0..CONVERTION_RANGE_COUNT - 1, 0..3] of Word = (
    //   lower, upper, length, pitch
        ($0061, $0041, 26, 1), 
        ($00E0, $00C0, 23, 1), 
        ($00F8, $00D8, 7,  1), 
        ($0101, $0100, 24, 2), 
        ($013A, $0139, 8,  2), 
        ($014B, $014A, 23, 2), 
        ($01CE, $01CD, 8,  2), 
        ($01DF, $01DE, 9,  2), 
        ($01F9, $01F8, 20, 2), 
        ($0223, $0222, 9,  2), 
        ($0247, $0246, 5,  2), 
        ($03B1, $0391, 17, 1), 
        ($03C3, $03A3, 9,  1), 
        ($03D9, $03D8, 12, 2), 
        ($0430, $0410, 32, 1), 
        ($0450, $0400, 16, 1), 
        ($0461, $0460, 17, 2), 
        ($048B, $048A, 27, 2), 
        ($04C2, $04C1, 7,  2), 
        ($04D1, $04D0, 44, 2), 
        ($0561, $0531, 38, 1), 
        ($1E01, $1E00, 75, 2), 
        ($1EA1, $1EA0, 48, 2), 
        ($1F00, $1F08, 8,  1), 
        ($1F10, $1F18, 6,  1), 
        ($1F20, $1F28, 8,  1), 
        ($1F30, $1F38, 8,  1), 
        ($1F40, $1F48, 6,  1), 
        ($1F60, $1F68, 8,  1), 
        ($2170, $2160, 16, 1), 
        ($24D0, $24B6, 26, 1), 
        ($2C30, $2C00, 47, 1), 
        ($2C81, $2C80, 50, 2), 
        ($2D00, $10A0, 38, 1),
        ($A641, $A640, 23, 2), 
        ($A681, $A680, 12, 2), 
        ($A723, $A722, 7,  2), 
        ($A733, $A732, 31, 2), 
        ($A77F, $A77E, 5,  2), 
        ($A7A1, $A7A0, 5,  2), 
        ($FF41, $FF21, 26, 1)
    );
    
    LowerCaseConvertionRanges: array[0..CONVERTION_RANGE_COUNT - 1, 0..3] of Word = (
    //   upper, lower, length, pitch
        ($0041, $0061, 26, 1), 
        ($00C0, $00E0, 23, 1), 
        ($00D8, $00F8, 7,  1), 
        ($0100, $0101, 24, 2), 
        ($0139, $013A, 8,  2), 
        ($014A, $014B, 23, 2), 
        ($01CD, $01CE, 8,  2), 
        ($01DE, $01DF, 9,  2), 
        ($01F8, $01F9, 20, 2), 
        ($0222, $0223, 9,  2), 
        ($0246, $0247, 5,  2), 
        ($0391, $03B1, 17, 1), 
        ($03A3, $03C3, 9,  1), 
        ($03D8, $03D9, 12, 2), 
        ($0410, $0430, 32, 1), 
        ($0400, $0450, 16, 1), 
        ($0460, $0461, 17, 2), 
        ($048A, $048B, 27, 2), 
        ($04C1, $04C2, 7,  2), 
        ($04D0, $04D1, 44, 2), 
        ($0531, $0561, 38, 1), 
        ($10A0, $2D00, 38, 1),
        ($1E00, $1E01, 75, 2), 
        ($1EA0, $1EA1, 48, 2), 
        ($1F08, $1F00, 8,  1), 
        ($1F18, $1F10, 6,  1), 
        ($1F28, $1F20, 8,  1), 
        ($1F38, $1F30, 8,  1), 
        ($1F48, $1F40, 6,  1), 
        ($1F68, $1F60, 8,  1), 
        ($2160, $2170, 16, 1), 
        ($24B6, $24D0, 26, 1), 
        ($2C00, $2C30, 47, 1), 
        ($2C80, $2C81, 50, 2), 
        ($A640, $A641, 23, 2), 
        ($A680, $A681, 12, 2), 
        ($A722, $A723, 7,  2), 
        ($A732, $A733, 31, 2), 
        ($A77E, $A77F, 5,  2), 
        ($A7A0, $A7A1, 5,  2), 
        ($FF21, $FF41, 26, 1)
    );
    
    UpperCaseConvertions: array[0..CONVERTION_MAP_COUNT - 1, 0..1] of Word = (
    //   lower, upper
        ($00FF, $0178),  
        ($0133, $0132),  
        ($0135, $0134),  
        ($0137, $0136),  
        ($017A, $0179),  
        ($017C, $017B),  
        ($017E, $017D),  
        ($0180, $0243),  
        ($0183, $0182),  
        ($0185, $0184),  
        ($0188, $0187),  
        ($018C, $018B),  
        ($0192, $0191),  
        ($0195, $01F6),  
        ($0199, $0198),  
        ($019A, $023D),  
        ($019E, $0220),  
        ($01A1, $01A0),  
        ($01A3, $01A2),  
        ($01A5, $01A4),  
        ($01A8, $01A7),  
        ($01AD, $01AC),  
        ($01B0, $01AF),  
        ($01B4, $01B3),  
        ($01B6, $01B5),  
        ($01B9, $01B8),  
        ($01BD, $01BC),  
        ($01BF, $01F7),  
        ($01C6, $01C4),  
        ($01C9, $01C7),  
        ($01CC, $01CA),  
        ($01DD, $018E),  
        ($01F3, $01F1),  
        ($01F5, $01F4),  
        ($023C, $023B),  
        ($023F, $2C7E),  
        ($0240, $2C7F),  
        ($0242, $0241),  
        ($0250, $2C6F),  
        ($0251, $2C6D),  
        ($0252, $2C70),  
        ($0253, $0181),  
        ($0254, $0186),  
        ($0256, $0189),  
        ($0257, $018A),  
        ($0259, $018F),  
        ($025B, $0190),  
        ($0260, $0193),  
        ($0263, $0194),  
        ($0265, $A78D),  
        ($0266, $A7AA),  
        ($0268, $0197),  
        ($0269, $0196),  
        ($026B, $2C62),  
        ($026F, $019C),  
        ($0271, $2C6E),  
        ($0272, $019D),  
        ($0275, $019F),  
        ($027D, $2C64),  
        ($0280, $01A6),  
        ($0283, $01A9),  
        ($0288, $01AE),  
        ($0289, $0244),  
        ($028A, $01B1),  
        ($028B, $01B2),  
        ($028C, $0245),  
        ($0292, $01B7),  
        ($0371, $0370),  
        ($0373, $0372),  
        ($0377, $0376),  
        ($037B, $03FD),  
        ($037C, $03FE),  
        ($037D, $03FF),  
        ($03AC, $0386),  
        ($03AD, $0388),  
        ($03AE, $0389),  
        ($03AF, $038A),  
        ($03CC, $038C),  
        ($03CD, $038E),  
        ($03CE, $038F),  
        ($03D7, $03CF),  
        ($03F2, $03F9),  
        ($03F8, $03F7),  
        ($03FB, $03FA),  
        ($04CF, $04C0),  
        ($1D79, $A77D),  
        ($1D7D, $2C63),  
        ($1F51, $1F59),  
        ($1F53, $1F5B),  
        ($1F55, $1F5D),  
        ($1F57, $1F5F),  
        ($1F70, $1FBA),  
        ($1F71, $1FBB),  
        ($1F72, $1FC8),  
        ($1F73, $1FC9),  
        ($1F74, $1FCA),  
        ($1F75, $1FCB),  
        ($1F76, $1FDA),  
        ($1F77, $1FDB),  
        ($1F78, $1FF8),  
        ($1F79, $1FF9),  
        ($1F7A, $1FEA),  
        ($1F7B, $1FEB),  
        ($1F7C, $1FFA),  
        ($1F7D, $1FFB),  
        ($1FB0, $1FB8),  
        ($1FB1, $1FB9),  
        ($1FD0, $1FD8),  
        ($1FD1, $1FD9),  
        ($1FE0, $1FE8),  
        ($1FE1, $1FE9),  
        ($1FE5, $1FEC),  
        ($214E, $2132),  
        ($2184, $2183),  
        ($2C61, $2C60),  
        ($2C65, $023A),  
        ($2C66, $023E),  
        ($2C68, $2C67),  
        ($2C6A, $2C69),  
        ($2C6C, $2C6B),  
        ($2C73, $2C72),  
        ($2C76, $2C75),  
        ($2CEC, $2CEB),  
        ($2CEE, $2CED),  
        ($2CF3, $2CF2),  
        ($2D27, $10C7),  
        ($2D2D, $10CD),  
        ($A77A, $A779),  
        ($A77C, $A77B),  
        ($A78C, $A78B),  
        ($A791, $A790),  
        ($A793, $A792)
    );

    LowerCaseConvertions: array[0..CONVERTION_MAP_COUNT - 1, 0..1] of Word = (
    //   upper, lower 
        ($0132, $0133),
        ($0134, $0135),
        ($0136, $0137),
        ($0178, $00FF),
        ($0179, $017A),
        ($017B, $017C),
        ($017D, $017E),
        ($0181, $0253),
        ($0182, $0183),
        ($0184, $0185),
        ($0186, $0254),
        ($0187, $0188),
        ($0189, $0256),
        ($018A, $0257),
        ($018B, $018C),
        ($018E, $01DD),
        ($018F, $0259),
        ($0190, $025B),
        ($0191, $0192),
        ($0193, $0260),
        ($0194, $0263),
        ($0196, $0269),
        ($0197, $0268),
        ($0198, $0199),
        ($019C, $026F),
        ($019D, $0272),
        ($019F, $0275),
        ($01A0, $01A1),
        ($01A2, $01A3),
        ($01A4, $01A5),
        ($01A6, $0280),
        ($01A7, $01A8),
        ($01A9, $0283),
        ($01AC, $01AD),
        ($01AE, $0288),
        ($01AF, $01B0),
        ($01B1, $028A),
        ($01B2, $028B),
        ($01B3, $01B4),
        ($01B5, $01B6),
        ($01B7, $0292),
        ($01B8, $01B9),
        ($01BC, $01BD),
        ($01C4, $01C6),
        ($01C7, $01C9),
        ($01CA, $01CC),
        ($01F1, $01F3),
        ($01F4, $01F5),
        ($01F6, $0195),
        ($01F7, $01BF),
        ($0220, $019E),
        ($023A, $2C65),
        ($023B, $023C),
        ($023D, $019A),
        ($023E, $2C66),
        ($0241, $0242),
        ($0243, $0180),
        ($0244, $0289),
        ($0245, $028C),
        ($0370, $0371),
        ($0372, $0373),
        ($0376, $0377),
        ($0386, $03AC),
        ($0388, $03AD),
        ($0389, $03AE),
        ($038A, $03AF),
        ($038C, $03CC),
        ($038E, $03CD),
        ($038F, $03CE),
        ($03CF, $03D7),
        ($03F7, $03F8),
        ($03F9, $03F2),
        ($03FA, $03FB),
        ($03FD, $037B),
        ($03FE, $037C),
        ($03FF, $037D),
        ($04C0, $04CF),
        ($10C7, $2D27),
        ($10CD, $2D2D),
        ($1F59, $1F51),
        ($1F5B, $1F53),
        ($1F5D, $1F55),
        ($1F5F, $1F57),
        ($1FB8, $1FB0),
        ($1FB9, $1FB1),
        ($1FBA, $1F70),
        ($1FBB, $1F71),
        ($1FC8, $1F72),
        ($1FC9, $1F73),
        ($1FCA, $1F74),
        ($1FCB, $1F75),
        ($1FD8, $1FD0),
        ($1FD9, $1FD1),
        ($1FDA, $1F76),
        ($1FDB, $1F77),
        ($1FE8, $1FE0),
        ($1FE9, $1FE1),
        ($1FEA, $1F7A),
        ($1FEB, $1F7B),
        ($1FEC, $1FE5),
        ($1FF8, $1F78),
        ($1FF9, $1F79),
        ($1FFA, $1F7C),
        ($1FFB, $1F7D),
        ($2132, $214E),
        ($2183, $2184),
        ($2C60, $2C61),
        ($2C62, $026B),
        ($2C63, $1D7D),
        ($2C64, $027D),
        ($2C67, $2C68),
        ($2C69, $2C6A),
        ($2C6B, $2C6C),
        ($2C6D, $0251),
        ($2C6E, $0271),
        ($2C6F, $0250),
        ($2C70, $0252),
        ($2C72, $2C73),
        ($2C75, $2C76),
        ($2C7E, $023F),
        ($2C7F, $0240),
        ($2CEB, $2CEC),
        ($2CED, $2CEE),
        ($2CF2, $2CF3),
        ($A779, $A77A),
        ($A77B, $A77C),
        ($A77D, $1D79),
        ($A78B, $A78C),
        ($A78D, $0265),
        ($A790, $A791),
        ($A792, $A793),
        ($A7AA, $0266));
    
