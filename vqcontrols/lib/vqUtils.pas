// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqUtils;
{ TODO
- specialize TExchanger for int, char, double, etc
}

{$mode objfpc}{$H+}             
{$MODESWITCH ADVANCEDRECORDS}

interface

uses
    InterfaceBase, LclIntf, LclType, LMessages, LResources,
    Types, SysUtils, Classes, Graphics, Forms, Controls, GraphType,
    ImgList, Dialogs, StdCtrls, ExtCtrls, Buttons, Math, DateUtils, StrUtils,
    Menus, ExtDlgs,
    BGRABitmap, BGRACanvas, BGRABitmapTypes;

const

    VK_C = 67;
    VK_V = 86;
    VK_X = 88;
    VK_S = 83;
    VK_A = 65;
    VK_Z = 90;
    VK_Y = 89;
    VK_R = 82;
	VK_F = 70;

    CR       = #13;
    LF       = #10;
    CRLF     = #13#10;
    STR_EOL  = CRLF;

    clCoffee        = TColor($0B1F59);
    clChestnut      = TColor($253577);
    clBistre        = TColor($187196);
    clBeige         = TColor($DCF5F5);
    clKhaki         = TColor($8CE6F0);
    clBrown         = TColor($2A2AA5);
    clOcher         = TColor($5A93B9);
    clSepia         = TColor($2A3B66);
    clSienna        = TColor($2D52A0);
    clDun           = TColor($4781AC);
    clCinnamon      = TColor($3E8ABD);
    clLion          = TColor($4886BC);
    clCosmicLatte   = TColor($E7F8FF);
    clRusset        = TColor($202CD2);
    clVermilion     = TColor($002EE6);
    clWine          = TColor($0C0756);
    clCrimson       = TColor($301CA5);
    clCarmine       = TColor($4F1CD3);
    clScarlet       = TColor($3200E3);
    clGarnet        = TColor($4836B0);
    clAmber         = TColor($00BFFF);
    clOrange        = TColor($0080FF);
    clVanilla       = TColor($ABE5F3);
    clGolden        = TColor($00D7FF);
    clSalmon        = TColor($7387F2);
    clSkin          = TColor($99CCFF);
    clMustard       = TColor($58DBFF);
    clLemon         = TColor($00FFBF);
    clStdGreen      = TColor($469800);
    clEsmerald      = TColor($719D00);
    clJade          = TColor($6BA800);
    clMint          = TColor($98FF98);
    clTurquoise     = TColor($D0E040);
    clAquamarine    = TColor($D1D59F);
    clLightBlue     = TColor($E6D8AD);
    clCerulean      = TColor($D59800);
    clAzure         = TColor($FF9900);
    clIndigo        = TColor($964726);
    clSapphire      = TColor($BA520F);
    clAmethyst      = TColor($CC6699);
    clLavender      = TColor($DC7EB5);
    clLilac         = TColor($D365B7);
    clMauve         = TColor($FFB0E0);
    clViolet        = TColor($A449A3);
    clViolin        = TColor($8406A1);
    clPink          = TColor($CBC0FF);
    clBone          = TColor($E0EAED);
    clShell         = TColor($EEF5FF);
    clLead          = TColor($404040);
    clLinen         = TColor($B7D0D7);
    clXanadu        = TColor($788673);
    clJet           = TColor($1C1B1F);
    clEbony         = TColor($2B3137);
    clGreenYellow   = TColor($00CEC6);
    clMayaBlue      = TColor($FBC273);
    clDiffuseSky    = TColor($EAD9BB);
    clTirePurple    = TColor($6D237B);
    clHanPurple     = TColor($FA1852);
    clPlatinum      = TColor($DCDCDC);
    clLightPlatinum = TColor($F0F0F0);
    clUltraPlatinum = TColor($F7F7F7);
    
    crSpin          = 51;
    crPan           = 53;
    crZoomIn        = 54;
    crZoomOut       = 55;
    crRotate        = 56;
    crTarget        = 58;
    crKiteNESW      = 58;
    crKiteNS        = 59;
    crKiteWE        = 60;
    crKiteNW        = 61;
    crKiteN         = 62;
    crKiteNE        = 63;
    crKiteW         = 64;
    crKiteE         = 65;
    crKiteSW        = 66;
    crKiteS         = 67;
    crKiteSE        = 68;
    
    BeamCursorThreshold = 2;
    
type
    
    TCharSet = set of AnsiChar;
    BYTEFILE = file of Byte;
    ANSIFILE = file of AnsiChar;//!
    UTF8CHARFILE = ANSIFILE;
    TRGBAColor = type Cardinal;//!
    TDigit = 0..9;
    TDegree = type Double; // sexagesimal degree
    
    TPointArray = array of TPoint;
    TRectArray = array of TRect;
    TByteArray = array of Byte;
    TCharArray = array of AnsiChar;
    TWordArray = array of Word;
    TIntArray = array of Integer;
    TDblArray = array of Double;
    TCardArray = array of Cardinal;
    TObjectArray = array of TObject;
    TBoolArray = array of Boolean;
    TStrArray = array of string;
    TColorArray = array of TColor;
    TDigitArray = array of TDigit;
    TAnsiArray = array of AnsiChar;//!
    TColorMatrix = array of TColorArray;
    TCardMatrix = array of TCardArray;
    TIntMatrix = array of TIntArray;
    TDblMatrix = array of TDblArray;
    TWordMatrix = array of TWordArray;
    TSizeArray = array of TSize;
    TAmPm = (AM, PM);
    
    TDoublePoint = record
    public
        X: Double;
        Y: Double;
        constructor CreateNormArg(ANorm, AArg: Double);
        constructor Create(AX, AY: Double);
        class function Zero: TDoublePoint; static;
        class operator = (const P, Q : TDoublePoint) : Boolean; overload;
        class operator <> (const P, Q : TDoublePoint): Boolean; overload;
        class operator + (const P, Q : TDoublePoint): TDoublePoint; overload;
        class operator - (const P, Q : TDoublePoint): TDoublePoint; overload;
        class operator * (const L: Double; const P: TDoublePoint): TDoublePoint; overload;
        class operator * (const P: TDoublePoint; const L: Double): TDoublePoint; overload;
        class operator * (const P: TDoublePoint; const Q: TDoublePoint): Double; overload;
        class operator / (const P: TDoublePoint; const L: Double): TDoublePoint; overload;
        class operator := (const P : TPoint) : TDoublePoint; overload;
        class operator Explicit (const P : TDoublePoint) : TPoint; overload;
        function Distance(P: TDoublePoint): Double;
        function IsZero: Boolean;
        function Norm: Double;
        function Ort: TDoublePoint;
        function Arg: Double;
        function Neg: TDoublePoint;
        function Cross(P: TDoublePoint): Double;
        function Rev: TDoublePoint;
        function Sqr: Double;
        function Rotate(ARotation: Double): TDoublePoint;
        function Discretize: TPoint;
        procedure Offset(DX, DY: Double);
    end;
    
    TDoubleRect = packed record
    private
        procedure SetWidth(Value: Double);
        procedure SetHeight(Value: Double);
        function GetWidth: Double;
        function GetHeight: Double;
    public
        constructor Create(ALeft, ATop, ARight, ABottom: Double; ANormalize: Boolean = False);
        class function Empty: TDoubleRect; static;
        function IsEmpty: Boolean;
        function Contains(P: TDoublePoint): Boolean;
        function Center: TDoublePoint;
        function Discretize: TRect;
        function IsNormalRect: Boolean;
        procedure Offset(DX, DY: Double);
        procedure Inflate(DX, DY: Double);
        procedure Normalize;
        
        class operator = (L, R: TDoubleRect): Boolean;
        class operator <> (L, R: TDoubleRect): Boolean;
        class operator + (L, R: TDoubleRect): TDoubleRect; // union
        class operator * (L, R: TDoubleRect): TDoubleRect; // intersection
        class operator := (const R: TRect): TDoubleRect; overload;
        class operator Explicit (const R: TDoubleRect): TRect; overload;
        property Width: Double read GetWidth write SetWidth;
        property Height: Double read GetWidth write SetWidth;
        case Byte of
            0: (Left, Top, Right, Bottom: Double);
            1: (TopLeft, BottomRight: TDoublePoint);
    end;
    
    TRange = record
    public
        Start: Integer;
        Stop: Integer;
        constructor Create(AStart, AStop: Integer);
        class function Zero: TRange; static;
        function IsSingle: Boolean;
        procedure Normalize;
        procedure Offset(D: Integer);
        procedure Swap;
        function Contains(AValue: Integer; Full: Boolean = False): Boolean;
        function Length(Full: Boolean = False): Integer;
        function Intersects(Other: TRange; Full: Boolean = False): Boolean;
        class operator = (const A, B: TRange): Boolean;
        class operator <> (const A, B: TRange): Boolean;
    end;
    
    TDoubleRange = record
    public
        Start: Double;
        Stop: Double;
        constructor Create(AStart, AStop: Double);
        class function Zero: TRange; static;
        function IsSingle: Boolean;
        procedure Normalize;
        procedure Offset(D: Double);
        procedure Swap;
        function Contains(AValue: Double; Full: Boolean = False): Boolean;
        function Length: Double;
        function Intersects(Other: TDoubleRange; Full: Boolean = False): Boolean;
        function Discretize: TRange;
        class operator = (const A, B : TDoubleRange) : Boolean;
        class operator <> (const A, B : TDoubleRange): Boolean;
    end;
    
    generic TExchanger<T> = class
    public
        class procedure Exchange(var ALeft, ARight: T);
    end;

    generic TSorter<T> = class
    public
        type
            TTArray = array of T;
            TComparerFunction = function(const ALeft, ARight: T): Integer;
            { 
                L > R -> 1
                L = R -> 0
                L < R -> -1
            }
    private
        type TTExchanger = specialize TExchanger<T>;
        class function Divide(var L: TTArray; StartPos, EndPos: Integer; Compare: TComparerFunction; LowestToHighest: Boolean): Integer;
        class procedure QuickSort(var L: TTArray; StartPos, EndPos: Integer; Compare: TComparerFunction; LowestToHighest: Boolean);
    public
        class procedure Sort(var L: TTArray; Compare: TComparerFunction; LowestToHighest: Boolean; Len: Integer = -1);
    end;
    
var
    
    MsgLabel: TLabel;
    
{ Utils }
type
    
    TvqArrowDirection = (vqArrowLeft, vqArrowTop, vqArrowRight, vqArrowBottom);
    TvqTextOrientation = (vqTextHorizontal, vqTextVerticalLeft, vqTextVerticalRight);
    TvqGlyphLayout = type TButtonLayout;
    TvqOrientation = (vqHorizontal, vqVertical);
    TvqPosition = (vqLeft, vqTop, vqRight, vqBottom);
    TvqCellIndex = record
    public
        Row, Col: Integer;
        constructor Create(ARow, ACol: Integer);
        class function Invalid: TvqCellIndex; static;
        function Valid: Boolean;
        procedure Invalidate;
        procedure Offset(DR, DC: Integer);
        procedure Locate(ARow, ACol: Integer);
        class operator = (const A, B : TvqCellIndex) : Boolean;
        class operator <> (const A, B : TvqCellIndex): Boolean;
    end;

    TvqObject = class(TPersistent, IInterface)
    protected
        { IInterface }
        function QueryInterface({$IFDEF FPC_HAS_CONSTREF} constref {$ELSE} const {$ENDIF}
            IID: TGUID; out Obj): Longint; {$IFNDEF WINDOWS} cdecl {$ELSE} stdcall {$ENDIF};
        function _AddRef: Longint; {$IFNDEF WINDOWS} cdecl {$ELSE} stdcall {$ENDIF};
        function _Release: Longint; {$IFNDEF WINDOWS} cdecl {$ELSE} stdcall {$ENDIF};
    end;
    
const
    
    vqInvalidValue = -1;
    
{ Utils }

procedure ShowMessageOnLabel(Msg: string);
procedure UndefinedRoutine(const Name: string);
procedure ExchangePointer(var Left, Right: Pointer);
procedure Exchange(var X, Y: Integer);  overload;
procedure Exchange(var X, Y: Double);   overload;
procedure Exchange(var X, Y: Byte);     overload;
procedure Exchange(var X, Y: Char);     overload;
procedure Exchange(var R, S: TRect);    overload;
function IfThenElse(Cond: Boolean; A, B: Integer): Integer;         overload;
function IfThenElse(Cond: Boolean; A, B: Double): Double;           overload;
function IfThenElse(Cond: Boolean; A, B: Byte): Byte;               overload;
function IfThenElse(Cond: Boolean; A, B: Boolean): Boolean;         overload;
function IfThenElse(Cond: Boolean; A, B: Char): Char;               overload;
function IfThenElse(Cond: Boolean; A, B: TFontStyles): TFontStyles; overload;
function IfThenElse(Cond: Boolean; A, B: TColor): TColor;           overload;
function IfThenElse(Cond: Boolean; A, B: string): string;           overload;
procedure FillArray(Arr: TCharArray; PosFrom, Len: Integer; Value: Char);    overload;
procedure FillArray(Arr: TIntArray; PosFrom, Len: Integer; Value: Integer);  overload;
procedure FillArray(Arr: TByteArray; PosFrom, Len: Integer; Value: Byte);    overload;
procedure FillArray(Arr: TDblArray; PosFrom, Len: Integer; Value: Double);   overload;
function MultiplyChar(Ch: Char; Count: Integer): string;
procedure StringToCharArray(StrIn: string; var StrOut: TCharArray);
procedure CharArrayToString(StrIn: TCharArray; var StrOut: string);
function EoLStr: string;
function AlignRect(Rect, Client: TRect; Alignment: TAlignment; Layout: TTextLayout): TRect;
function ToCellIndex(Row, Col: Integer): TvqCellIndex;
procedure ToPointArray(const InPoints: array of TPoint; var OutPoints: TPointArray);
procedure CopyPoints(InPoints: TPointArray; var OutPoints: TPointArray);
procedure OffsetPoints(var Points: TPointArray; DX, DY: Integer);

function CompareByte(Left, Right: Byte): Integer;
function CompareInteger(Left, Right: Integer): Integer;
function CompareDouble(Left, Right: Double): Integer;
function CompareChar(Left, Right: Char): Integer;
function CompareString(Left, Right: string): Integer;
function CompareCharArray(Left, Right: TCharArray): Integer;

function IsNormalRect(R: TRect): Boolean;

{$I vqMathUtilsH.inc}
{$I vqStringsH.inc}
{$I vqUTF8H.inc}
{$I vqGraphicsH.inc}
{$I vqControlsH.inc}

implementation

procedure ShowMessageOnLabel(Msg: string);
begin
    if MsgLabel <> nil then begin
        MsgLabel.Caption := Msg;
        MsgLabel.Repaint;
    end;
end;

procedure UndefinedRoutine(const Name: string);
begin
    raise Exception.Create('Undefined routine: "' + Name +'"');
end;

procedure ExchangePointer(var Left, Right: Pointer);
var
    Aux: Pointer;
begin
    Aux := Left;
    Left := Right;
    Right := Aux;
end;

procedure Exchange(var X, Y: Integer);
var
    Z: Integer;
begin
    Z := X;
    X := Y;
    Y := Z;
end;

procedure Exchange(var X, Y: Double);
var
    Z: Double;
begin
    Z := X;
    X := Y;
    Y := Z;
end;

procedure Exchange(var X, Y: Byte);
var
    Z: Byte;
begin
    Z := X;
    X := Y;
    Y := Z;
end;

procedure Exchange(var X, Y: Char);
var
    Z: Char;
begin
    Z := X;
    X := Y;
    Y := Z;
end;

procedure Exchange(var R, S: TRect);
var
    T: TRect;
begin
    T := R;
    R := S;
    S := T;
end;

function IfThenElse(Cond: Boolean; A, B: Integer): Integer;
begin
    if Cond then Result := A else Result := B;
end;

function IfThenElse(Cond: Boolean; A, B: Double): Double;
begin
    if Cond then Result := A else Result := B;
end;

function IfThenElse(Cond: Boolean; A, B: Byte): Byte;
begin
    if Cond then Result := A else Result := B;
end;

function IfThenElse(Cond: Boolean; A, B: Boolean): Boolean;
begin
    if Cond then Result := A else Result := B;
end;

function IfThenElse(Cond: Boolean; A, B: Char): Char;
begin
    if Cond then Result := A else Result := B;
end;

function IfThenElse(Cond: Boolean; A, B: TFontStyles): TFontStyles;
begin
    if Cond then Result := A else Result := B;
end;

function IfThenElse(Cond: Boolean; A, B: TColor): TColor;
begin
    if Cond then Result := A else Result := B;
end;

function IfThenElse(Cond: Boolean; A, B: string): string;
begin
    if Cond then Result := A else Result := B;
end;

procedure FillArray(Arr: TCharArray; PosFrom, Len: Integer; Value: Char);
var
    I: Integer;
begin
    for I := PosFrom to PosFrom + Len - 1 do
        Arr[I] := Value;
end;

procedure FillArray(Arr: TIntArray; PosFrom, Len: Integer; Value: Integer);
var
    I: Integer;
begin
    for I := PosFrom to PosFrom + Len - 1 do
        Arr[I] := Value;
end;

procedure FillArray(Arr: TByteArray; PosFrom, Len: Integer; Value: Byte);
var
    I: Integer;
begin
    for I := PosFrom to PosFrom + Len - 1 do
        Arr[I] := Value;
end;

procedure FillArray(Arr: TDblArray; PosFrom, Len: Integer; Value: Double);
var
    I: Integer;
begin
    for I := PosFrom to PosFrom + Len - 1 do
        Arr[I] := Value;
end;

function MultiplyChar(Ch: Char; Count: Integer): string;
var
    I: Integer;
begin
    Result := '';
    if Count <= 0 then Exit;
    SetLength(Result, Count);
    for I := 1 to Count do Result[I] := Ch;
end;

procedure StringToCharArray(StrIn: string; var StrOut: TCharArray);
var
    I, L: Integer;
begin
    L := Length(StrIn);
    SetLength(StrOut, L);
    for I := 1 to L do StrOut[I - 1] := StrIn[I];
end;

procedure CharArrayToString(StrIn: TCharArray; var StrOut: string);
var
    I, L: Integer;
begin
    L := Length(StrIn);
    SetLength(StrOut, L);
    for I := 1 to L do StrOut[I] := StrIn[I - 1];
end;

function EoLStr: string;
begin //#
    Result := CRLF;
end;

function AlignRect(Rect, Client: TRect; Alignment: TAlignment; Layout: TTextLayout): TRect;
begin
    case Alignment of
        taLeftJustify: Result.Left := Client.Left;
        taCenter: Result.Left := (Client.Left + Client.Right - Rect.Width) div 2;
        taRightJustify: Result.Left := Client.Right - Rect.Width;
    end;
    case Layout of
        tlTop: Result.Top := Client.Top;
        tlCenter: Result.Top := (Client.Top + Client.Bottom - Rect.Height) div 2;
        tlBottom: Result.Top := Client.Bottom - Rect.Height;
    end;
    Result.Width := Rect.Width;
    Result.Height := Rect.Height;
end;

function ToCellIndex(Row, Col: Integer): TvqCellIndex;
begin
    Result.Row := Row;
    Result.Col := Col;
end;

procedure ToPointArray(const InPoints: array of TPoint; var OutPoints: TPointArray);
var
    I, L: Integer;
begin
    L := Length(InPoints);
    SetLength(OutPoints, L);
    for I := 0 to L - 1 do OutPoints[I] := InPoints[I];
end;

procedure CopyPoints(InPoints: TPointArray; var OutPoints: TPointArray);
var
    I, L: Integer;
begin
    L := Length(InPoints);
    SetLength(OutPoints, L);
    for I := 0 to L - 1 do OutPoints[I] := InPoints[I];
end;

procedure OffsetPoints(var Points: TPointArray; DX, DY: Integer);
var
    I: Integer;
begin
    for I := 0 to Length(Points) - 1 do Points[I].Offset(DX, DY);
end;

function CompareByte(Left, Right: Byte): Integer;
begin
    if Left < Right then Result := LessThanValue
    else if Left > Right then Result := GreaterThanValue
    else Result := 0;
end;

function CompareInteger(Left, Right: Integer): Integer;
begin
    Result := Math.CompareValue(Left, Right);
end;

function CompareDouble(Left, Right: Double): Integer;
begin
    Result := Math.CompareValue(Left, Right);
end;

function CompareChar(Left, Right: Char): Integer;
begin
    Result := Math.CompareValue(Ord(Left), Ord(Right));
end;

function CompareString(Left, Right: string): Integer;
begin
    Result := SysUtils.CompareStr(Left, Right);
end;

function CompareCharArray(Left, Right: TCharArray): Integer;
var
    Len, I: Integer;
begin
    Len := Min(Length(Left), Length(Right));
    Result := 0;
    I := 0;
    while I < Len do begin
        Result := Sign(Ord(Left[I]) - Ord(Right[I]));
        Inc(I);
        if Result <> 0 then Break;
    end;
    if Result = 0 then begin
        if Len < Length(Left) then Result := 1
        else if Len < Length(Right) then Result := -1;
    end;
end;

function IsNormalRect(R: TRect): Boolean;
begin
    Result := (R.Right >= R.Left) and (R.Bottom >= R.Top);
end;

{ TDoublePoint }

constructor TDoublePoint.CreateNormArg(ANorm, AArg: Double);
begin
    X := Cos(AArg)*ANorm;
    Y := Sin(AArg)*ANorm;
end;

constructor TDoublePoint.Create(AX, AY: Double);
begin
    X := AX;
    Y := AY;
end;

class function TDoublePoint.Zero: TDoublePoint;
begin
    Result.X := 0;
    Result.Y := 0;
end;

class operator TDoublePoint.= (const P, Q : TDoublePoint) : Boolean;
begin
    Result := SameValue(P.X, Q.X) and SameValue(P.Y, Q.Y);
end;

class operator TDoublePoint.<> (const P, Q : TDoublePoint): Boolean;
begin
    Result := not(SameValue(P.X, Q.X) and SameValue(P.Y, Q.Y));
end;

class operator TDoublePoint.+ (const P, Q : TDoublePoint): TDoublePoint;
begin
    Result.X := P.X + Q.X;
    Result.Y := P.Y + Q.Y;
end;

class operator TDoublePoint.- (const P, Q : TDoublePoint): TDoublePoint;
begin
    Result.X := P.X - Q.X;
    Result.Y := P.Y - Q.Y;
end;

class operator TDoublePoint.* (const L: Double; const P: TDoublePoint): TDoublePoint;
begin
    Result.X := L*P.X;
    Result.Y := L*P.Y;
end;

class operator TDoublePoint.* (const P: TDoublePoint; const L: Double): TDoublePoint;
begin
    Result.X := L*P.X;
    Result.Y := L*P.Y;
end;

class operator TDoublePoint.* (const P: TDoublePoint; const Q: TDoublePoint): Double; 
begin
    Result := P.X*Q.X + P.Y*Q.Y;
end;

class operator TDoublePoint./ (const P: TDoublePoint; const L: Double): TDoublePoint;
begin
    Result.X := P.X/L;
    Result.Y := P.Y/L;
end;

class operator TDoublePoint.:= (const P : TPoint) : TDoublePoint; 
begin
    Result.X := P.X;
    Result.Y := P.Y;
end;

class operator TDoublePoint.Explicit (const P : TDoublePoint) : TPoint; 
begin
    Result.X := Trunc(P.X);
    Result.Y := Trunc(P.Y);
end;

function TDoublePoint.Distance(P: TDoublePoint): Double;
begin
    Result := (Self - P).Norm;
end;

function TDoublePoint.IsZero: Boolean;
begin
    Result := Math.IsZero(X) and Math.IsZero(Y);
end;

function TDoublePoint.Norm: Double;
begin
    Result := Sqrt(Abs(X*X + Y*Y));
end;

function TDoublePoint.Ort: TDoublePoint;
begin
    Result.X := -Y;
    Result.Y := X;
end;

function TDoublePoint.Arg: Double;
begin
    Result := ArcTan2(Y, X);
    CorrectRadian(Result);
end;

function TDoublePoint.Neg: TDoublePoint;
begin
    Result.X := -X;
    Result.Y := -Y;
end;

function TDoublePoint.Cross(P: TDoublePoint): Double;
begin
    Result := X*P.Y - P.X*Y;
end;

function TDoublePoint.Rev: TDoublePoint;
begin
    Result.X := Y;
    Result.Y := X;
end;

function TDoublePoint.Sqr: Double;
begin
    Result := X*X + Y*Y;
end;

function TDoublePoint.Rotate(ARotation: Double): TDoublePoint;
begin
    Result.X := X*Cos(ARotation) - Y*Sin(ARotation);
    Result.Y := X*Sin(ARotation) + Y*Cos(ARotation);
end;

function TDoublePoint.Discretize: TPoint;
begin
    Result.X := MathRound(X);
    Result.Y := MathRound(Y);
end;

procedure TDoublePoint.Offset(DX, DY: Double);
begin
    X := X + DX;
    Y := Y + DY;
end;

{ TDoubleRect }

constructor TDoubleRect.Create(ALeft, ATop, ARight, ABottom: Double; ANormalize: Boolean = False);
begin
    Left := ALeft;
    Top := ATop;
    Right := ARight;
    Bottom := ABottom;
    if ANormalize then Normalize;
end;

class function TDoubleRect.Empty: TDoubleRect;
begin
    Result.Left := 0;
    Result.Top := 0;
    Result.Right := 0;
    Result.Bottom := 0;
end;

function TDoubleRect.IsEmpty: Boolean;
begin
    Result := LessOrEqual(Right, Left) or LessOrEqual(Bottom, Top);
end;

function TDoubleRect.Contains(P: TDoublePoint): Boolean;
begin
    Result := LessOrEqual(Left, P.X) and LessOrEqual(P.X, Right) and
              LessOrEqual(Top, P.Y) and LessOrEqual(P.Y, Bottom);
        
end;

function TDoubleRect.Center: TDoublePoint;
begin
    Result.X := (Left + Right)/2;
    Result.Y := (Top + Bottom)/2;
end;

function TDoubleRect.Discretize: TRect;
begin
    Result.TopLeft := TopLeft.Discretize;
    Result.BottomRight := BottomRight.Discretize;
end;

procedure TDoubleRect.Offset(DX, DY: Double);
begin
    TopLeft.Offset(DX, DY);
    BottomRight.Offset(DX, DY);
end;

procedure TDoubleRect.Inflate(DX, DY: Double);
begin
    TopLeft.Offset(-DX, -DY);
    BottomRight.Offset(DX, DY);
end;

procedure TDoubleRect.Normalize;
begin
    if Less(Right, Left) then
        Exchange(Right, Left);
    if Less(Bottom, Top) then
        Exchange(Bottom, Top);
end;

function TDoubleRect.IsNormalRect: Boolean;
begin
    Result := GreaterOrEqual(Right, Left) and GreaterOrEqual(Bottom, Top);
end;

class operator TDoubleRect.= (L, R: TDoubleRect): Boolean;
begin
    Result := (L.TopLeft = R.TopLeft) and (L.BottomRight = R.BottomRight);
end;

class operator TDoubleRect.<> (L, R: TDoubleRect): Boolean;
begin
    Result := (L.TopLeft <> R.TopLeft) or (L.BottomRight <> R.BottomRight);
end;

class operator TDoubleRect.+ (L, R: TDoubleRect): TDoubleRect;
begin
    Result.Left := Min(L.Left, R.Left);
    Result.Top := Min(L.Top, R.Top);
    Result.Right := Max(L.Right, R.Right);
    Result.Bottom := Max(L.Bottom, R.Bottom);
end;

class operator TDoubleRect.* (L, R: TDoubleRect): TDoubleRect;
begin
    Result.Left := Max(L.Left, R.Left);
    Result.Top := Max(L.Top, R.Top);
    Result.Right := Min(L.Right, R.Right);
    Result.Bottom := Min(L.Bottom, R.Bottom);
end;

class operator TDoubleRect.:= (const R: TRect): TDoubleRect;
begin
    Result.Left := R.Left;
    Result.Top := R.Top;
    Result.Right := R.Right;
    Result.Bottom := R.Bottom;
end;

class operator TDoubleRect.Explicit (const R: TDoubleRect): TRect;
begin
    Result.TopLeft := R.TopLeft.Discretize;
    Result.BottomRight := R.BottomRight.Discretize;
end;

function TDoubleRect.GetWidth: Double;
begin
    Result := Right - Left;
end;

function TDoubleRect.GetHeight: Double;
begin
    Result := Bottom - Top;
end;

procedure TDoubleRect.SetWidth(Value: Double);
begin
    Right := Left + Value;
end;

procedure TDoubleRect.SetHeight(Value: Double);
begin
    Bottom := Top + Value;
end;

{ TRange }

constructor TRange.Create(AStart, AStop: Integer);
begin
    Start := AStart;
    Stop := AStop;
end;

class function TRange.Zero: TRange; static;
begin
    Result.Start := 0;
    Result.Stop := 0;
end;

function TRange.IsSingle: Boolean;
begin
    Result := (Start = Stop);
end;

procedure TRange.Normalize;
begin
    if Start > Stop then Swap;
end;

procedure TRange.Offset(D: Integer);
begin
    Inc(Start, D);
    Inc(Stop, D);
end;

procedure TRange.Swap;
begin
    Exchange(Start, Stop);
end;

function TRange.Contains(AValue: Integer; Full: Boolean = False): Boolean;
begin
    if Start > Stop then begin
        if Full then Result := (Stop <= AValue) and (AValue <= Start)
        else Result := (Stop <= AValue) and (AValue < Start);
    end
    else begin
        if Full then Result := (Start <= AValue) and (AValue <= Stop)
        else Result := (Start <= AValue) and (AValue < Stop);
    end;
end;

function TRange.Length(Full: Boolean = False): Integer;
begin
    if Start > Stop then begin
        Result := Start - Stop;
    end
    else begin
        Result := Stop - Start;
    end;
    if Full then Inc(Result);
end;

function TRange.Intersects(Other: TRange; Full: Boolean = False): Boolean;
begin
    Result :=   Contains(Other.Start, Full) or
                Contains(Other.Stop, Full) or
                Other.Contains(Start, Full) or
                Other.Contains(Stop, Full);
end;

class operator TRange.= (const A, B: TRange): Boolean;
begin
    Result := ((A.Start = B.Start) and (A.Stop = B.Stop)) or
              ((A.Start = B.Stop) and (A.Stop = B.Start));
end;

class operator TRange.<> (const A, B: TRange): Boolean;
begin
    Result := not (A = B);
end;

{ TDoubleRange }

constructor TDoubleRange.Create(AStart, AStop: Double);
begin
    Start := AStart;
    Stop := AStop;
end;

class function TDoubleRange.Zero: TRange; static;
begin
    IsZero(Result.Start);
    IsZero(Result.Stop );
end;

function TDoubleRange.IsSingle: Boolean;
begin
    Result := SameValue(Start, Stop);
end;

procedure TDoubleRange.Normalize;
begin
    if Start > Stop then Swap;
end;

procedure TDoubleRange.Offset(D: Double);
begin
    Start := Start + D;
    Stop := Stop + D;
end;

procedure TDoubleRange.Swap;
begin
    Exchange(Start, Stop);
end;

function TDoubleRange.Contains(AValue: Double; Full: Boolean = False): Boolean;
begin
    if Start > Stop then begin
        if Full then Result := LessOrEqual(Stop, AValue) and LessOrEqual(AValue, Start)
        else Result := LessOrEqual(Stop, AValue) and (AValue < Start);
    end
    else begin
        if Full then Result := LessOrEqual(Start, AValue) and LessOrEqual(AValue, Stop)
        else Result := LessOrEqual(Start, AValue) and (AValue < Stop);
    end;
end;

function TDoubleRange.Length: Double;
begin
    if Start > Stop then Result := Start - Stop
    else Result := Stop - Start;
end;

function TDoubleRange.Intersects(Other: TDoubleRange; Full: Boolean = False): Boolean;
begin
    Result :=   Contains(Other.Start, Full) or
                Contains(Other.Stop, Full) or
                Other.Contains(Start, Full) or
                Other.Contains(Stop, Full);
end;

function TDoubleRange.Discretize: TRange;
begin
    Result.Start := MathRound(Start);
    Result.Stop := MathRound(Stop);
end;

class operator TDoubleRange.= (const A, B : TDoubleRange) : Boolean;
begin
    Result := (SameValue(A.Start, B.Start) and SameValue(A.Stop, B.Stop)) or
              (SameValue(A.Start, B.Stop) and SameValue(A.Stop, B.Start));
end;

class operator TDoubleRange.<> (const A, B : TDoubleRange): Boolean;
begin
    Result := not (A = B);
end;

{ TExchanger }

class procedure TExchanger.Exchange(var ALeft, ARight: T);
var
    Aux: T;
begin
    Aux := ALeft;
    ALeft := ARight;
    ARight := Aux;
end;

{ TSorter }

class function TSorter.Divide(var L: TTArray; StartPos, EndPos: Integer; Compare: TComparerFunction;
    LowestToHighest: Boolean): Integer;
var
    Pivot: T;
    Left, Right: Integer;
begin
    Left := StartPos;
    Right := EndPos;
    if LowestToHighest then begin
        Pivot := L[StartPos];
        while (Left < Right) do begin
            while (Right > Left) and (Compare(L[Right], Pivot) > 0) do
                Dec(Right);
            while (Left < Right) and (Compare(L[Left], Pivot) <= 0) do
                Inc(Left);
            if Left < Right then
                TTExchanger.Exchange(L[Left], L[Right]);
        end;
        TTExchanger.Exchange(L[Right], L[StartPos]);
        Result := Right;
    end
    else begin
        Pivot := L[EndPos];
        while (Left < Right) do begin
            while (Right > Left) and (Compare(L[Right], Pivot) <= 0) do
                Dec(Right);
            while (Left < Right) and (Compare(L[Left], Pivot) > 0) do
                Inc(Left);
            if Left < Right then
                TTExchanger.Exchange(L[Left], L[Right]);
        end;
        TTExchanger.Exchange(L[Left], L[EndPos]);
        Result := Left;
    end;
end;

class procedure TSorter.QuickSort(var L: TTArray; StartPos, EndPos: Integer; Compare: TComparerFunction;
    LowestToHighest: Boolean);
var
    PivotPos: Integer;
begin
    if StartPos < EndPos then begin
        PivotPos := Divide(L, StartPos, EndPos, Compare, LowestToHighest);
        QuickSort(L, StartPos, PivotPos - 1, Compare, LowestToHighest);
        QuickSort(L, PivotPos + 1, EndPos, Compare, LowestToHighest);
    end;
end;

class procedure TSorter.Sort(var L: TTArray; Compare: TComparerFunction; LowestToHighest: Boolean;
    Len: Integer = -1);
begin
    if Len < 0 then Len := Length(L);
    QuickSort(L, 0, Len - 1, Compare, LowestToHighest);
end;

{ TvqCellIndex }

constructor TvqCellIndex.Create(ARow, ACol: Integer);
begin
    Row := ARow;
    Col := ACol;
end;

class function TvqCellIndex.Invalid: TvqCellIndex;
begin
    Result.Row := vqInvalidValue;
    Result.Col := vqInvalidValue;
end;

function TvqCellIndex.Valid: Boolean;
begin
    Result := (Row <> vqInvalidValue) and (Col <> vqInvalidValue);
end;

procedure TvqCellIndex.Invalidate;
begin
    Row := vqInvalidValue;
    Col := vqInvalidValue;
end;

procedure TvqCellIndex.Offset(DR, DC: Integer);
begin
    Inc(Row, DR);
    Inc(Col, DC);
end;

procedure TvqCellIndex.Locate(ARow, ACol: Integer);
begin
    Row := ARow;
    Col := ACol;
end;

class operator TvqCellIndex. = (const A, B : TvqCellIndex) : Boolean;
begin
    Result := (A.Row = B.Row) and (A.Col = B.Col);
end;

class operator TvqCellIndex. <> (const A, B : TvqCellIndex): Boolean;
begin
    Result := not(A = B);
end;

{ TvqObject }

function TvqObject.QueryInterface({$IFDEF FPC_HAS_CONSTREF} constref {$ELSE} const {$ENDIF}
    IID: TGUID; out Obj): Longint; {$IFNDEF WINDOWS} cdecl {$ELSE} stdcall {$ENDIF};
begin
	if GetInterface(IID, Obj) then Result := S_OK
	else Result := E_NOINTERFACE;
end;

function TvqObject._AddRef: Longint; {$IFNDEF WINDOWS} cdecl {$ELSE} stdcall {$ENDIF};
begin
    Result := -1;
end;

function TvqObject._Release: Longint; {$IFNDEF WINDOWS} cdecl {$ELSE} stdcall {$ENDIF};
begin
    Result := -1;
end;


{$I vqMathUtils.inc}
{$I vqStrings.inc}
{$I vqUTF8.inc}
{$I vqGraphics.inc}
{$I vqControls.inc}

var
    CursorImage: TCursorImage;
    Picture: TPicture;
    
procedure LoadNewCursor(Cur: TCursor; X, Y: Integer; const Name: string);
begin
    Picture.LoadFromLazarusResource(Name);
    CursorImage.assign(Picture.png);
    CursorImage.HotSpot := Point(X, Y);
    Screen.Cursors[Cur] := CursorImage.ReleaseHandle; 
end;

initialization
    
    {$I vqCursors.lrs}
    
    Picture := TPicture.Create;
    CursorImage := TCursorImage.Create;
    
    LoadNewCursor(crSpin    , 04, 00, 'cursor_spin'     );
    LoadNewCursor(crPan     , 09, 09, 'cursor_pan'      );
    LoadNewCursor(crZoomIn  , 06, 07, 'cursor_zoomin'   );
    LoadNewCursor(crZoomOut , 06, 07, 'cursor_zoomout'  );
    LoadNewCursor(crRotate  , 11, 11, 'cursor_rotate'   );
    LoadNewCursor(crTarget  , 14, 14, 'cursor_target'   );
    LoadNewCursor(crKiteNESW, 11, 11, 'cursor_kitenesw' );
    LoadNewCursor(crKiteNS  , 06, 11, 'cursor_kitens'   );
    LoadNewCursor(crKiteWE  , 11, 06, 'cursor_kitewe'   );
    LoadNewCursor(crKiteNW  , 08, 08, 'cursor_kitenw'   );
    LoadNewCursor(crKiteN   , 06, 11, 'cursor_kiten'    );
    LoadNewCursor(crKiteNE  , 03, 08, 'cursor_kitene'   );
    LoadNewCursor(crKiteW   , 11, 06, 'cursor_kitew'    );
    LoadNewCursor(crKiteE   , 03, 06, 'cursor_kitee'    );
    LoadNewCursor(crKiteSW  , 08, 03, 'cursor_kitesw'   );
    LoadNewCursor(crKiteS   , 06, 03, 'cursor_kites'    );
    LoadNewCursor(crKiteSE  , 03, 03, 'cursor_kitese'   );
    
    CursorImage.Free;
    Picture.Free;

    InitializeCharClasses;
    
end.

