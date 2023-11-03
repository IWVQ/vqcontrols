// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqMathUtils.inc                           }
{ Included in vqUtils.pas                   }

{ helpers }

{ TSize }

procedure TvqSizeHelper.Resize(ax, ay: Longint);
begin
    SetSize(ax, ay);
end;

procedure TvqSizeHelper.SetSize(ax, ay: Longint);
begin
    cx := ax;
    cy := ay;
end;

function TvqSizeHelper.Swap: TSize;
begin
    Result.cx := cy;
    Result.cy := cx;
end;

function TvqSizeHelper.Neg: TSize;
begin
    Result.cx := -cx;
    Result.cy := -cy;
end;

class function TvqSizeHelper.Zero: TSize;
begin
    Result.cx := 0;
    Result.cy := 0;
end;


{ TPoint }

function TvqPointHelper.Mul(P: TPoint): Integer;
begin
    Result := X*P.X + Y*P.Y;
end;

function TvqPointHelper.Mul(L: Integer): TPoint;
begin
    Result.X := L*X;
    Result.Y := L*Y;
end;
               
function TvqPointHelper.Divide(L: Integer): TPoint;
begin
    Result.X := X div L;
    Result.Y := Y div L;
end;

function TvqPointHelper.Norm: Double;
begin
    Result := Sqrt(Abs(X*X + Y*Y));
end;

function TvqPointHelper.Ort: TPoint;
begin
    Result.X := -Y;
    Result.Y := X;
end;

function TvqPointHelper.Arg: Double;
begin
    Result := ArcTan2(Y, X);
    CorrectRadian(Result);
end;

function TvqPointHelper.Neg: TPoint;
begin
    Result.X := -X;
    Result.Y := -Y;
end;

function TvqPointHelper.Cross(P: TPoint): Integer;
begin
    Result := X*P.Y - P.X*Y;
end;

function TvqPointHelper.Rev: TPoint;
begin
    Result.X := Y;
    Result.Y := X;
end;

function TvqPointHelper.Sqr: Integer;
begin
    Result := X*X + Y*Y;
end;

function TvqPointHelper.Rotate(ARotation: Double): TPoint;
begin
    Result.X := MathRound(X*Cos(ARotation) - Y*Sin(ARotation));
    Result.Y := MathRound(X*Sin(ARotation) + Y*Cos(ARotation));
end;

function TvqPointHelper.MaxDist(P: TPoint): Integer;
begin
    Result := MaxDist(P.X, P.Y);
end;

function TvqPointHelper.MaxDist(AX, AY: Integer): Integer;
begin
    Result := Max(Abs(X - AX), Abs(Y - AY));
end;

{ TRect }

procedure TvqRectHelper.Normalize;
begin
    NormalizeRect;
end;

function TvqRectHelper.IsNormalRect: Boolean;
begin
    Result := (Right >= Left) and (Bottom >= Top);
end;

procedure TvqRectHelper.Resize(W, H: Longint);
begin
    Width := W;
    Height := H;
end;

procedure TvqRectHelper.ApplyPadding(APadding: TRect);
begin
    Inc(Left, APadding.Left);
    Inc(Top, APadding.Top);
    Dec(Right, APadding.Right);
    Dec(Bottom, APadding.Bottom);
end;

{ misc }

function Next(C: Pointer): Pointer;
begin // faster algorithm
    Result := C;
    Inc(Result);
end;

function Prev(C: Pointer): Pointer;
begin // faster algorithm
    Result := C;
    Dec(Result);
end;
       
function Next(C: PByte): PByte;
begin
    Result := C;
    Inc(Result);
end;

function Prev(C: PByte): PByte;
begin
    Result := C;
    Dec(Result);
end;

function Next(C: Integer): Integer;
begin
    Result := C;
    Inc(Result);
end;

function Prev(C: Integer): Integer;
begin
    Result := C;
    Dec(Result);
end;

{ discrete functions }

function Min3(A, B, C: Byte): Byte;
begin
    if b < c then begin
        if a < b then Result := a
        else Result := b
    end
    else if a < c then Result := a
    else Result := c;
end;

function Min3(A, B, C: Cardinal): Cardinal;
begin
    if b < c then begin
        if a < b then Result := a
        else Result := b
    end
    else if a < c then Result := a
    else Result := c;
end;

function Min3(A, B, C: Integer): Integer;
begin
    if b < c then begin
        if a < b then Result := a
        else Result := b
    end
    else if a < c then Result := a
    else Result := c;
end;

function Min3(A, B, C: Double): Double;
begin
    if b < c then begin
        if a < b then Result := a
        else Result := b
    end
    else if a < c then Result := a
    else Result := c;
end;

function Max3(A, B, C: Byte): Byte;
begin
    if a < b then begin
        if b < c then Result := c
        else Result := b
    end
    else if a < c then Result := c
    else Result := a;
end;

function Max3(A, B, C: Cardinal): Cardinal;
begin
    if a < b then begin
        if b < c then Result := c
        else Result := b
    end
    else if a < c then Result := c
    else Result := a;
end;

function Max3(A, B, C: Integer): Integer;
begin
    if a < b then begin
        if b < c then Result := c
        else Result := b
    end
    else if a < c then Result := c
    else Result := a;
end;

function Max3(A, B, C: Double): Double;
begin
    if a < b then begin
        if b < c then Result := c
        else Result := b
    end
    else if a < c then Result := c
    else Result := a;
end;

function MathRound(E: Double): Integer;
begin
    if E >= 0 then Result := Trunc(E + 0.5)
    else Result := Trunc(E - 0.5);
end;

function EuclidMod(A, B: Integer): Integer;
var
    Q: Integer;
begin
    EuclidModDiv(A, B, Q, Result);
end;

function EuclidDiv(A, B: Integer): Integer;
var
    R: Integer;
begin
    EuclidModDiv(A, B, Result, R);
end;

procedure EuclidModDiv(A, B: Integer; var Q, R: Integer);
begin
    //A = QB + R; 0 <= R < |B|
    R := A mod B;
    if R < 0 then R := abs(B) + R;
    Q := (A - R) div B;
end;

function DigitsCount(N: Integer; Base: Word = 10): Integer;
begin
    Result := Trunc(Ln(N)/Ln(Base)) + 1;
end;

{ units }

function CorrectUnit(R: Double): Double;
begin
    if R > 1 then R := 1
    else if R < 0 then R := 0;
    Result := R;
end;

function CorrectDegree(Degree: Double): Double;
begin
    if (Degree > 360) or (Degree < 0) then
        Result := Degree - 360*Floor(Degree/360)
    else
        Result := Degree;
end;

function CorrectRadian(Rad: Double): Double;
begin
    if (Rad > 2*Pi) or (Rad < 0) then
        Result := Rad - 2*Pi*Floor(Rad/2*Pi)
    else
        Result := Rad;
end;

function DegreeFromFont(F: TFont): TDegree;
begin
    Result := 360 - F.Orientation/10;
end;

{ discrete vectors }

function CartesianToScreen(O, P: TPoint): TPoint;
begin
    Result.X := O.X + P.X;
    Result.Y := O.Y - P.Y;
end;

function ScreenToCartesian(O, P: TPoint): TPoint;
begin
    Result.X := P.X - O.X;
    Result.Y := -(P.Y - O.Y);
end;

procedure RotateOnScreen(var P: TPoint; Center: TPoint; Rotation: Integer; Radius: Double = -1);
var
    V: TPoint;
    Angle: Double;
begin
    Rotation := EuclidMod(Rotation, 3600);
    V := Point(P.X - Center.X, -(P.Y - Center.Y));
    if Radius < 0 then
        Radius := V.Norm;
    Angle := ArcTan2(V.Y, V.X) + DegToRad(Rotation/10);
    P.X := MathRound(Center.X + Radius*Cos(Angle));
    P.Y := MathRound(Center.Y - Radius*Sin(Angle));
end;

function VectorFromNormArg(Norm, Arg: Double): TPoint;
begin
    Result.X := MathRound(Cos(Arg)*Norm);
    Result.Y := MathRound(Sin(Arg)*Norm);
end;

function VectorRotation(A: TPoint): Double;
begin                  
    if A.Y < 0 then Result := 2*Pi - ArcTan2(-A.Y, A.X)
    else Result := ArcTan2(A.Y, A.X);
end;

function VectorAngle(From, _To: TPoint): Double;
begin
    Result := ArcCos(From.Mul(_To)/(From.Norm*_To.Norm));
    if From.Ort.Mul(_To) >= 0 then
        Result := Result
    else Result := 2*Pi - Result;
end;

function AngleSub(From, _To: Double): Double;
begin
    From := CorrectRadian(From);
    _To := CorrectRadian(_To);
    if From < _To then Result := _To - From
    else Result := 2*Pi + _To - From;
end;

function MinAngle(A, B: Double): Double;
begin
    A := CorrectRadian(A);
    B := CorrectRadian(B);
    if A < B then Result := Min(B - A, 2*Pi - (B - A))
    else Result := Min(A - B, 2*Pi - (A - B));
end;

{ points }

//m = Subset count
//n = element count
//
//        |           m  |
// g(i) = | (i + 0.5)--- | // Subset from element
//        |_          n _|
//
//        |¯ n         ¯|
// f(g) = | --- g - 0.5 | // Subset start element
//        |  m          |

function UniformSubsetFromElement(SubsetCount, Count, Element: Integer): Integer;
begin
    Result := Floor((Element + 0.5)*SubsetCount/Count);
end;

function UniformSubsetStart(SubsetCount, Count, Subset: Integer): Integer;
begin
    Result := Ceil((Subset*Count/SubsetCount) - 0.5);
end;

function IntervalIntersects(A1, A2, B1, B2: Integer; Strict: Boolean = False): Boolean;
begin
    Result := (A1 <= A2) and (B1 <= B2);
    if Strict then
        Result := Result and (Max(A1, B1) < Min(A2, B2))
    else
        Result := Result and (Max(A1, B1) <= Min(A2, B2));
end;

function IntervalContains(Ia, Ib, C: Integer; Strict: Boolean = False): Boolean;
begin
    if Strict then
        Result := (Ia < C) and (C < Ib)
    else
        Result := (Ia <= C) and (C <= Ib);
end;

function SegmentIntersects(A, B, P, Q: TPoint; Strict: Boolean = False): Boolean;
var
    V, W, R: TPoint;
begin
    Result := False;
    V := A - B; 
    W := Q - P; 
    R := Q - B;
    if V.Ort.Mul(W) = 0 then begin // segmentos paralelos
        if V.Ort.Mul(R) = 0 then begin // segmentos en la misma recta
            if W.Mul(V) >= 0 then begin
                if Strict then
                    Result := (0 < R.Mul(V)) and
                              (R.Mul(V) < V.Sqr + W.Mul(V))
                else
                    Result := (0 <= R.Mul(V)) and
                              (R.Mul(V) <= V.Sqr + W.Mul(V));
            end
            else begin
                if Strict then
                    Result := (W.Mul(V) < R.Mul(V)) and
                              (R.Mul(V) < V.Mul(V))
                else
                    Result := (W.Mul(V) <= R.Mul(V)) and
                              (R.Mul(V) <= V.Mul(V));
            end;
        end;
    end
    else begin
        if Strict then
            Result := (0 < R.Ort.Mul(W)) and
                      (R.Ort.Mul(W) < V.Ort.Mul(W)) and
                      (0 < R.Ort.Mul(V)) and
                      (R.Ort.Mul(V) < W.Ort.Mul(V))
        else
            Result := (0 <= R.Ort.Mul(W)) and
                      (R.Ort.Mul(W) <= V.Ort.Mul(W)) and
                      (0 <= R.Ort.Mul(V)) and
                      (R.Ort.Mul(V) <= W.Ort.Mul(V));
    end;
end;

function SameSegment(A, B, P, Q: TPoint): Boolean;
begin
    Result := ((A = P) and (B = Q)) or ((B = P) and (A = Q));
end;

function IsConvexPolygon(const Points: array of TPoint): Boolean;
var
    LstV, NwV: TPoint;
    Len, I, LstSgn, NwSgn: Integer;
begin
    Len := Length(Points);
    Result := True;
    if Len > 1 then begin
        LstV := Points[0] - Points[Len - 1];
        LstSgn := 0;
        for I := 1 to Len - 1 do begin
            NwV := Points[I] - Points[I - 1];
            NwSgn := Sign(LstV.Cross(NwV));
            if LstSgn = 0 then LstSgn := NwSgn
            else if NwSgn*LstSgn < 0 then begin
                Result := False;
                Break;
            end;
            LstV := NwV;
        end;
        NwV := Points[0] - Points[Len - 1];
        NwSgn := Sign(LstV.Cross(NwV));
        if NwSgn*LstSgn < 0 then//NwSgn*0 = 0
            Result := False;
    end;
end;

function SegmentClipping(var P, Q: TPoint; R: TRect): Boolean;
// Liang-Barsky line clipping algorithm
    procedure Findt(Denom, Num: Double; var T0, T1: Double; var More: Boolean);
    var
        _r: Double;
    begin
        More := True;
        if Denom < 0 then begin
            _r := Num/Denom;
            if _r > T1 then More := False
            else if _r > T0 then T0 := _r;
        end
        else if Denom > 0 then begin
            _r := Num/Denom;
            if _r < T0 then More := False
            else if _r < T1 then T1 := _r;
        end
        else if Num < 0 then More := False;
    end;

var
    T0, T1, dx, dy, YMn, YMx, XMn, Xmx: Double;
    Dir: Integer;
begin
    R.Normalize;
    Result := not R.IsEmpty;
    if not Result then Exit;
    XMn := R.Left;
    XMx := R.Right - 1;
    YMn := R.Top;
    YMx := R.Bottom - 1;
    dx := Q.X - P.X;
    dy := Q.Y - P.Y;
    begin
        if dx >= 0 then begin
            if dy >= 0 then begin
                if dy <= dx then Dir := 0
                else Dir := 1;
            end
            else begin
                if -dy <= dx then Dir := 7
                else Dir := 6;
            end;
        end
        else begin
            if dy >= 0 then begin
                if dy <= -dx then Dir := 3
                else Dir := 2;
            end
            else begin
                if -dy <= -dx then Dir := 4
                else Dir := 5;
            end;
        end;
    end;
    T0 := 0;
    T1 := 1;
    //Result = More
    Findt(-dx, P.X - XMn, T0, T1, Result);
    if Result then begin
        Findt(dx, XMx - P.X, T0, T1, Result);
        if Result then begin
            Findt(-dy, P.Y - YMn, T0, T1, Result);
            if Result then begin
                Findt(dy, YMx - P.Y, T0, T1, Result);
                if Result then begin
                    if T1 < 1 then
                        Q := Point(MathRound(P.X + T1*dx), MathRound(P.Y + T1*dy));
                    if T0 > 0 then
                        P := Point(MathRound(P.X + T0*dx), MathRound(P.Y + T0*dy));
                end;
            end;
        end;
    end;
end;

function PolygonClipping(InPts: TPointArray; var OutPts: TPointArray; R: TRect): Boolean;
// Sutherland-Hodgman polygon clipping algorithm
type
    TEdge = array[0..1] of TPoint;

    function Inside(P: TPoint; E: TEdge): Boolean;
    begin
        Result := (E[1].X - E[0].X)*(P.Y - E[0].Y) > (E[1].Y - E[0].Y)*(P.X - E[0].X)
    end;

    function Intersection(P1, P2: TPoint; E: TEdge): TPoint;
    var
        Dex, Dey, Dpx, Dpy,
        N1, N2, N3: Integer;
    begin
        Dex := E[0].X - E[1].X;
        Dey := E[0].Y - E[1].Y;
        Dpx := P1.X - P2.X;
        Dpy := P1.Y - P2.Y;
        N1 := E[0].X*E[1].Y - E[0].Y*E[1].X;
        N2 := P1.X*P2.Y - P1.Y*P2.X;
        N3 := Dex*Dpy - Dey*Dpx;
        Result := Point(MathRound((N1*Dpx - N2*Dex)/N3), MathRound((N1*Dpy - N2*Dey)/N3));
    end;

var
    ClipPts: array[0..3] of TPoint;
    Edge: TEdge;
    A, Lst, I, B, NumIn, NumOut: Integer;

    procedure AddToOutPts(P: TPoint);
    begin
        SetLength(OutPts, NumOut + 1);
        OutPts[NumOut] := P;
        Inc(NumOut);
    end;

begin
    Result := False;

    OutPts := nil;
    NumOut := 0;
    R.NormalizeRect;
    if R.IsEmpty then Exit;
    ClipPts[0] := Point(R.Left, R.Top);
    ClipPts[1] := Point(R.Right - 1, R.Top);
    ClipPts[2] := Point(R.Right - 1, R.Bottom - 1);
    ClipPts[3] := Point(R.Left, R.Bottom - 1);
    NumIn := Length(InPts);
    if NumIn = 0 then Exit;
    OutPts := InPts;
    NumOut := NumIn;
    B := 3;
    for A := 0 to 3 do begin
        Edge[0] := ClipPts[B];
        Edge[1] := ClipPts[A];
        InPts := OutPts;
        NumIn := NumOut;
        OutPts := nil;
        NumOut := 0;
        Lst := NumIn - 1;
        for I := 0 to NumIn - 1 do begin
            if Inside(InPts[I], Edge) then begin
                if not Inside(InPts[Lst], Edge) then
                    AddToOutPts(Intersection(InPts[Lst], InPts[I], Edge));
                AddToOutPts(InPts[I]);
            end
            else if Inside(InPts[Lst], Edge) then
                AddToOutPts(Intersection(InPts[Lst], InPts[I], Edge));
            Lst := I;
        end;
        B := A;
    end;
    Result := NumOut > 0;
end;
 
function EraseRedundantPoints(InPts: TPointArray; var OutPts: TPointArray; EraseFirstLast: Boolean): Boolean;
var
    I, J, Len: Integer;
begin
    Len := Length(InPts);
    SetLength(OutPts, Len);
    J := 1;
    if Len > 0 then begin
        OutPts[0] := InPts[0];
        for I := 1 to Len - 1 do
            if not (InPts[J - 1] = InPts[I]) then begin
                OutPts[J] := InPts[I];
                Inc(J);
            end;
        if EraseFirstLast and (J > 1) and (OutPts[0] = OutPts[J - 1]) then Dec(J);
        SetLength(OutPts, J);
        InPts := OutPts;
        OutPts := nil;
    end;
    Result := J < Len;
end;

function PartitionFromPoint(X, Width, PartitionsCount: Integer): Integer;
begin
    {
    W = Size
    C = PartitionsCount
    n = Partition
    x = X
    
    [nW/C] <= x < [(n+1)W/C] &
    x is Z                   &
    [(n+1)W/C] <= (n+1)W/C   &
    [nW/C] <= nW/C
    
    ==> nW/C <= x < (n+1)W/C | ([nW/C] = x & x < nW/C)
    ==> n <= xC/W < n + 1 | (x < nW/C < x + 1)
    ==> n = [xC/W] | (xC/W < n < xC/W + C/W)
    ==> n = [xC/W] | n = k + 1 IF [kW/C] < x & [(k + 1)W/C] = x ; where k = [xC/W]
    }
    Result := X*PartitionsCount div Width;
    while (Result + 1)*Width div PartitionsCount = X do
        Inc(Result);
end;

function PointFromPartition(Partition, Width, PartitionsCount: Integer): Integer;
begin
    Result := MulDiv(Partition, Width, PartitionsCount);
end;

{ real numbers }

var
    FPUMask: TFPUExceptionMask;
    UsingHyperreal: Boolean = False;

procedure BeginHyperreal;
begin
    FPUMask := SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,
        exOverflow, exUnderflow, exPrecision]);
    UsingHyperreal := True;
end;

procedure EndHyperreal;
begin
    UsingHyperreal := False;
    SetExceptionMask(FPUMask);
end;

function Pow(A, B: Double): Double;
begin
    if IsZero(Frac(B)) then
        Result := IntPower(A, Trunc(B))
    else
        Result := Power(A, B);
end;

function ExpPow(A: Double): Double;
begin
    if UsingHyperreal then begin
        if IsNaN(A) then Result := NaN
        else if IsInfinite(A) then begin
            if Sign(A) = 1 then Result := Infinity
            else if Sign(A) = -1 then Result := 0
            else Result := NaN;
        end
        else
            Result := Exp(A);
    end
    else
        Result := Exp(A);
end;

function HyperRound(A: Double): Double;
begin
    if UsingHyperreal then begin
        if IsNaN(A) or IsInfinite(A) then Result := A
        else Result := MathRound(A);
    end
    else Result := MathRound(A);
end;

function Equal(A, B: Double): Boolean;
begin
    if UsingHyperreal then begin
        if IsNaN(A) or IsNaN(B) then
            Result := False // NaN no se puede comparar(ni para patrones)
        else if IsInfinite(A) then begin
            if IsInfinite(B) then
                Result := Sign(A) = Sign(B)
            else
                Result := False;
        end
        else begin
            if IsInfinite(B) then
                Result := False
            else
                Result := SameValue(A, B);
        end;
    end
    else Result := SameValue(A, B)
end;

function Unequal(A, B: Double): Boolean;
begin
    Result := not Equal(A, B);
end;

function Less(A, B: Double): Boolean;
begin
    if UsingHyperreal then begin
        if IsNaN(A) or IsNaN(B) then
            Result := False // NaN no se puede comparar
        else if IsInfinite(A) and IsInfinite(B) then
            Result := Sign(A) < Sign(B)
        else
            Result := CompareValue(A, B) = LessThanValue;
    end
    else
        Result := CompareValue(A, B) = LessThanValue;
end;

function Greater(A, B: Double): Boolean;
begin
    if UsingHyperreal then begin
        if IsNaN(A) or IsNaN(B) then
            Result := False // NaN no se puede comparar
        else if IsInfinite(A) and IsInfinite(B) then
            Result := Sign(A) > Sign(B)
        else
            Result := CompareValue(A, B) = GreaterThanValue;
    end
    else
        Result := CompareValue(A, B) = GreaterThanValue;
end;

function LessOrEqual(A, B: Double): Boolean;
begin
    Result := Less(A, B) or Equal(A, B);
end;

function GreaterOrEqual(A, B: Double): Boolean;
begin
    Result := Greater(A, B) or Equal(A, B);
end;

function IsNegInfinity(A: Double): Boolean;
begin
    Result := IsInfinite(A) and (Sign(A) = -1);
end;

function IsPosInfinity(A: Double): Boolean;
begin
    Result := IsInfinite(A) and (Sign(A) = 1);
end;

{ real vectors }

function DoubleSingularTriangle(A, B, C: TDoublePoint): Boolean;
begin
    Result := (B.X - A.X)*(C.Y - A.Y) = (B.Y - A.Y)*(C.X - A.X);
end;

function DoublePointInTriangle(P: TDoublePoint; A, B, C: TDoublePoint): Boolean;
var
    APx, APy: Double;    
    alpha, beta, gamma: Double;
begin
    APx := P.X - A.X;
    APy := P.Y - A.Y;
    
    alpha := ((B.X - A.X)*APy - (B.Y - A.Y)*APx);  
    beta := ((C.X - A.X)*APy - (C.Y - A.Y)*APx);
    gamma := ((C.X - B.X)*(P.Y - B.Y) - (C.Y - B.Y)*(P.X - B.X));
         
    Result := ((alpha <= 0) and (beta >= 0) and (gamma <= 0)) or 
              ((alpha >= 0) and (beta <= 0) and (gamma >= 0));
    
end;

function DoubleSegmentIntersects(A, B, P, Q: TDoublePoint; var s, t: Double): Boolean;
var
    tN, tD, sN, sD: Double;
begin
    sN := (Q.X - P.X)*(A.Y - P.Y) - (Q.Y - P.Y)*(A.X - P.X);
    sD := (Q.Y - P.Y)*(B.X - A.X) - (Q.X - P.X)*(B.Y - A.Y);
    
    tN := (B.X - A.X)*(P.Y - A.Y) - (B.Y - A.Y)*(P.X - A.X);
    tD := (B.Y - A.Y)*(Q.X - P.X) - (B.X - A.X)*(Q.Y - P.Y);
    
    if ((tN = 0) and (tD = 0)) or ((sN = 0) and (sD = 0)) then begin
        Result := True;
        s := NAN;
        t := NAN;
    end
    else if (tD = 0) or (sD = 0) then begin
        Result := False;
        s := Infinity;
        t := Infinity;
    end
    else begin
        s := sN/sD;
        t := tN/tD;
        Result := (0 <= s) and (s <= 1) and (0 <= t) and (t <= 1);
    end;
end;


