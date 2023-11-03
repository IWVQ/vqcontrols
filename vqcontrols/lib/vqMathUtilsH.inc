// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqMathUtilsH.inc                          }
{ Included in vqUtils.pas                   }

//! todos los angulos usados son en radianes a menos que se diga lo contrario
//! o se trate de propiedades publicadas(en donde se usa angulos sexagesimales)

{ helpers }

type
    
    TvqSizeHelper = record helper for TSize
        procedure Resize(ax, ay: Longint);
        procedure SetSize(ax, ay: Longint);
        function Swap: TSize;
        function Neg: TSize;
        class function Zero: TSize; static;
    end;
    
    TvqPointHelper = record helper for TPoint
        function Mul(L: Integer): TPoint; overload;
        function Mul(P: TPoint): Integer; overload;
        function Divide(L: Integer): TPoint;

        function Norm: Double;
        function Ort: TPoint;
        function Arg: Double;
        function Neg: TPoint;
        function Cross(P: TPoint): Integer;
        function Rev: TPoint;
        function Sqr: Integer;
        function Rotate(ARotation: Double): TPoint;
        function MaxDist(P: TPoint): Integer; overload;
        function MaxDist(AX, AY: Integer): Integer; overload;
    end;
    
    TvqRectHelper = record helper for TRect
        procedure Normalize;
        function IsNormalRect: Boolean;
        procedure Resize(W, H: Longint);
        procedure ApplyPadding(APadding: TRect);
    end;
    
{ miscelanea }

const
    
    Ln2 = 0.693147180559945309417232121458;
    
    PowerOfTen: array[0..9] of Integer = (
        1,
        10,
        100,
        1000,
        10000,
        100000,
        1000000,
        10000000,
        100000000,
        1000000000
    );
    
    Log2OfPow2: array[1..32] of Byte = 
       (
       0, 
       1, 1, 
       2, 2, 2, 2, 
       3, 3, 3, 3, 3, 3, 3, 3, 
       4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 
       5);
    
function Next(C: Pointer): Pointer; inline; overload;
function Prev(C: Pointer): Pointer; inline; overload;
function Next(C: PByte): PByte; inline; overload;
function Prev(C: PByte): PByte; inline; overload;
function Next(C: Integer): Integer; inline; overload;
function Prev(C: Integer): Integer; inline; overload;

{ discrete functions }

function Min3(A, B, C: Byte): Byte; overload;
function Min3(A, B, C: Cardinal): Cardinal; overload;
function Min3(A, B, C: Integer): Integer; overload;
function Min3(A, B, C: Double): Double; overload;
function Max3(A, B, C: Byte): Byte; overload;
function Max3(A, B, C: Cardinal): Cardinal; overload;
function Max3(A, B, C: Integer): Integer; overload;
function Max3(A, B, C: Double): Double; overload;
function MathRound(E: Double): Integer;
function EuclidMod(A, B: Integer): Integer;
function EuclidDiv(A, B: Integer): Integer;
procedure EuclidModDiv(A, B: Integer; var Q, R: Integer);
function DigitsCount(N: Integer; Base: Word = 10): Integer;

{ units }

function CorrectUnit(R: Double): Double;
function CorrectRadian(Rad: Double): Double;
function DegreeFromFont(F: TFont): TDegree;

{ discrete vectors }

function CartesianToScreen(O, P: TPoint): TPoint;
function ScreenToCartesian(O, P: TPoint): TPoint;

function VectorFromNormArg(Norm, Arg: Double): TPoint;
function VectorRotation(A: TPoint): Double;
function VectorAngle(From, _To: TPoint): Double;
function AngleSub(From, _To: Double): Double;
function MinAngle(A, B: Double): Double;

{ points }

function UniformSubsetFromElement(SubsetCount, Count, Element: Integer): Integer;//!
function UniformSubsetStart(SubsetCount, Count, Subset: Integer): Integer;//!
function IntervalIntersects(A1, A2, B1, B2: Integer; Strict: Boolean = False): Boolean;
function IntervalContains(Ia, Ib, C: Integer; Strict: Boolean = False): Boolean;
function SegmentIntersects(A, B, P, Q: TPoint; Strict: Boolean = False): Boolean;
function SameSegment(A, B, P, Q: TPoint): Boolean;
function IsConvexPolygon(const Points: array of TPoint): Boolean;
function SegmentClipping(var P, Q: TPoint; R: TRect): Boolean;
function PolygonClipping(InPts: TPointArray; var OutPts: TPointArray; R: TRect): Boolean;
function EraseRedundantPoints(InPts: TPointArray; var OutPts: TPointArray; EraseFirstLast: Boolean): Boolean;
function PartitionFromPoint(X, Width, PartitionsCount: Integer): Integer;
function PointFromPartition(Partition, Width, PartitionsCount: Integer): Integer;

{ real numbers }

procedure BeginHyperreal;
procedure EndHyperreal;
function Pow(A, B: Double): Double;
function ExpPow(A: Double): Double;
function HyperRound(A: Double): Double;
function Equal(A, B: Double): Boolean;
function Unequal(A, B: Double): Boolean;
function Less(A, B: Double): Boolean;
function Greater(A, B: Double): Boolean;
function LessOrEqual(A, B: Double): Boolean;
function GreaterOrEqual(A, B: Double): Boolean;
function IsNegInfinity(A: Double): Boolean;
function IsPosInfinity(A: Double): Boolean;

{ real vectors }

function DoubleSingularTriangle(A, B, C: TDoublePoint): Boolean;
function DoublePointInTriangle(P: TDoublePoint; A, B, C: TDoublePoint): Boolean;
function DoubleSegmentIntersects(A, B, P, Q: TDoublePoint; var s, t: Double): Boolean;


