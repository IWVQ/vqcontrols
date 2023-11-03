// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqStringsH.inc            }
{ included in vqUtils.pas   }

type
    
    IvqTextBuffer = interface
        // 0-Indexed
        function _GetChar(Pos: Integer): AnsiChar;
        function _GetString(Pos, Len: Integer): ansistring;
        function _GetArray(Pos, Len: Integer; var Txt: TCharArray): Boolean;
        function _TextLength: Integer;
        function _WholeWordAt(PosFrom, PosTo: Integer): Boolean;
        property _TextChar[Pos: Integer]: AnsiChar read _GetChar; default;
    end;
    
    TvqStringText = class(TvqObject, IvqTextBuffer)
    public
        PS: PString;
        S: string;
        constructor CreatePointer(var Str: string);
        constructor CreateConst(Str: string);
        destructor Destroy; override;
        
        function _GetChar(Pos: Integer): AnsiChar;
        function _GetString(Pos, Len: Integer): ansistring;
        function _GetArray(Pos, Len: Integer; var Txt: TCharArray): Boolean;
        function _TextLength: Integer;
        function _WholeWordAt(PosFrom, PosTo: Integer): Boolean;
        property _TextChar[Pos: Integer]: AnsiChar read _GetChar; default;
    end;
    
    TvqCharArrayText = class(TvqObject, IvqTextBuffer)
    public
        S: TCharArray;
        constructor Create(Str: TCharArray);
        destructor Destroy; override;
        function _GetChar(Pos: Integer): AnsiChar;
        function _GetString(Pos, Len: Integer): ansistring;
        function _GetArray(Pos, Len: Integer; var Txt: TCharArray): Boolean;
        function _TextLength: Integer;
        function _WholeWordAt(PosFrom, PosTo: Integer): Boolean;
        property _TextChar[Pos: Integer]: AnsiChar read _GetChar; default;
    end;
    
function GetFirstWord(var Str: string): string;
procedure GetLineStarts(Str: string; var Starts: TIntArray; var Lines: Integer);
function NextLine(var Str: string; I: Integer): Integer;

function IsControlChar(Ch: Char): Boolean;
function IsEoLChar(Ch: Char): Boolean;
function IsSpaceChar(Ch: Char): Boolean;
function IsWhiteChar(Ch: Char): Boolean;
function IsNumeralChar(Ch: Char): Boolean;
function IsAlphaNumChar(Ch: Char): Boolean;
function IsAlphaChar(Ch: Char): Boolean;
function IsUpperAlphaChar(Ch: Char): Boolean;
function IsLowerAlphaChar(Ch: Char): Boolean;
function IsHexadecimalChar(Ch: Char): Boolean;
function IsOctalChar(Ch: Char): Boolean;
function IsIdentifierChar(Ch: Char): Boolean;
function HexNibble(Ch: Char): Byte;
function DecDigit(Ch: Char): Byte;
function OctalDigit(Ch: Char): Byte;
function NibbleToChar(H: Byte): Char;
function DigitToChar(D: Byte): Char;

procedure ConsumeSpace(var S: string; var I: Integer);
function RGBToHtml(R, G, B: Byte; Compress: Boolean = False): string; 
function RGBAToHtml(R, G, B, A: Byte; Compress: Boolean = False): string; 
function HtmlToRGBA(S: string; var R, G, B, A: Byte): Boolean;



