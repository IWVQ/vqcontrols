// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqGraphics.inc            }
{ included in vqUtils.pas   }

function HTMLToColor(S: string): TColor;
var
    R, G, B, A: Byte;
begin
    HTMLToRGBA(S, R, G, B, A);
    Result := RGBColor(R, G, B);
end;

function ColorToHtml(Cl: TColor): string;
var
    R, G, B: Byte;
begin
    GetRGB(Cl, R, G, B);
    Result := RGBToHtml(R, G, B);
end;

function HTMLToColorAlpha(S: string; var A: Byte): TColor;
var
    R, G, B: Byte;
begin
    HTMLToRGBA(S, R, G, B, A);
    Result := RGBColor(R, G, B);
end;

function ColorAlphaToHtml(Cl: TColor; A: Byte): string;
var
    R, G, B: Byte;
begin
    GetRGB(Cl, R, G, B);
    Result := RGBAToHtml(R, G, B, A);
end;

function CMYColor(C, M, Y: Byte): TColor;
begin
    Result := $00FFFFFF and
             ((Cardinal(255 - y) shl 16) or
              (Cardinal(255 - m) shl 8) or
              (Cardinal(255 - c) shl 0));
end;

function CMYCyan(Cl: TColor): Byte;
begin
    Result := 255 - Byte(Cl shr 0);
end;

function CMYMagenta(Cl: TColor): Byte;
begin
    Result := 255 - Byte(Cl shr 8);
end;

function CMYYellow(Cl: TColor): Byte;
begin
    Result := 255 - Byte(Cl shr 16);
end;

function GetCMY(Cl: TColor; var C, M, Y: Byte): Boolean;
begin
    c := 255 - Byte(Cl shr 0);
    m := 255 - Byte(Cl shr 8);
    y := 255 - Byte(Cl shr 16);
    Result := Cl <> clNone;
end;

function HSLColor(H, S, L: Double): TColor;
var
    r, g, b, sextant: Cardinal;
    v, Mn, sv, fract, vsf, mid1, mid2: Double;
begin
    S := S/100;
    L := L/100;
    
    if s = 0 then begin
        r := Trunc(255*l + 0.5);
        g := r;
        b := r;
    end
    else begin
        if l <= 0.5 then v := l*(1 + s)
        else v := l + s - l*s;
        if v = 0 then begin
            r := 0;
            g := 0;
            b := 0;
        end
        else begin
            Mn := 2*l - v;
            sv := (v - Mn)/v;
            if h = 360 then h := 0
            else h := h/60;
            sextant := Floor(h);
            fract := h - sextant;
            vsf := v*sv*fract;
            Mid1 := Mn + vsf;
            Mid2 := v - vsf;
            case sextant of
                0: begin
                    r := Trunc(255*v + 0.5);
                    g := Trunc(255*Mid1 + 0.5);
                    b := Trunc(255*Mn + 0.5);
                end;
                1: begin
                    r := Trunc(255*Mid2 + 0.5);
                    g := Trunc(255*v + 0.5);
                    b := Trunc(255*Mn + 0.5);
                end;
                2: begin
                    r := Trunc(255*Mn + 0.5);
                    g := Trunc(255*v + 0.5);
                    b := Trunc(255*Mid1 + 0.5);
                end;
                3: begin
                    r := Trunc(255*Mn + 0.5);
                    g := Trunc(255*Mid2 + 0.5);
                    b := Trunc(255*v + 0.5);
                end;
                4: begin
                    r := Trunc(255*Mid1 + 0.5);
                    g := Trunc(255*Mn + 0.5);
                    b := Trunc(255*v + 0.5);
                end;
                5: begin
                    r := Trunc(255*v + 0.5);
                    g := Trunc(255*Mn + 0.5);
                    b := Trunc(255*Mid2 + 0.5);
                end;
            end;
        end;
    end;
    Result := RGBColor(r, g ,b);
end;

function HSLHue(Cl: TColor): Double;
var 
    Mx, Mn, r, g, b: Cardinal;
begin
    r := (Cl shr 0) and $000000FF;
    g := (Cl shr 8) and $000000FF;
    b := (Cl shr 16) and $000000FF;
    Mx := Max3(r, g, b);
    Mn := Min3(r, g, b);
    if Mx = Mn then 
        Result := 0
    else if Mx = r then 
        Result := (g - b)/(Mx - Mn)
    else if Mx = g then
        Result := 2 + (b - r)/(Mx - Mn)
    else if Mx = b then 
        Result := 4 + (r - g)/(Mx - Mn);
    Result := 60*Result;
    if Result < 0 then Result := Result + 360;
end;

function HSLSaturation(Cl: TColor): Double;
var 
    Mx, Mn, r, g, b: Cardinal;
begin
    r := (Cl shr 0) and $000000FF;
    g := (Cl shr 8) and $000000FF;
    b := (Cl shr 16) and $000000FF;
    Mx := Max3(r, g, b);
    Mn := Min3(r, g, b);
    if Mx = Mn then 
        Result := 0
    else if Mx + Mn <= 1 then
        Result := (Mx - Mn)/(Mx + Mn)
    else
        Result := (Mx - Mn)/(2*255 - Mx - Mn);
    Result := Result*100;
end;

function HSLLightness(Cl: TColor): Double;
var 
    Mx, Mn, r, g, b: Cardinal;
begin
    r := (Cl shr 0) and $000000FF;
    g := (Cl shr 8) and $000000FF;
    b := (Cl shr 16) and $000000FF;
    Mx := Max3(r, g, b);
    Mn := Min3(r, g, b);
    Result := (Mx + Mn)/(2*255);
    Result := Result*100;
end;

function GetHSL(Cl: TColor; var H, S, L: Double): Boolean;
var 
    Mx, Mn, r, g, b: Cardinal;
begin
    r := (Cl shr 0) and $000000FF;
    g := (Cl shr 8) and $000000FF;
    b := (Cl shr 16) and $000000FF;
    Mx := Max3(r, g, b);
    Mn := Min3(r, g, b);
    l := (Mx + Mn)/(2*255);
    if Mx = Mn then begin
        s := 0;
        h := 0;
    end
    else begin
        if l <= 0.5 then s := (Mx - Mn)/(Mx + Mn)
        else s := (Mx + Mn)/(2*255 - Mx - Mn);
        if Mx = r then 
            h := (g - b)/(Mx - Mn)
        else if Mx = g then
            h := 2 + (b - r)/(Mx - Mn)
        else if Mx = b then 
            h := 4 + (r - g)/(Mx - Mn);
        h := 60*h;
        if h < 0 then h := h + 360;
    end;
    S := S*100;
    L := L*100;
    Result := Cl <> clNone;
end;

function HSVColor(H, S, V: Double): TColor;
var
    r, g, b, sextant: Cardinal;
    f, p, q, t: Double;
begin
    S := S/100;
    V := V/100;
    
    if S = 0 then begin
        r := Trunc(255*V + 0.5);
        g := r;
        b := r;
    end
    else begin
        if H = 360 then H := 0
        else H := H / 60;
        sextant := Floor(h);
        f := h - sextant;
        p := v*(1 - s);
        q := v*(1 - (s*f));
        t := v*(1 - (s*(1 - f)));
        case sextant of
            0: begin
                r := Trunc(255*v + 0.5);
                g := Trunc(255*t + 0.5);
                b := Trunc(255*p + 0.5);
            end;
            1: begin
                r := Trunc(255*q + 0.5);
                g := Trunc(255*v + 0.5);
                b := Trunc(255*p + 0.5);
            end;
            2: begin
                r := Trunc(255*p + 0.5);
                g := Trunc(255*v + 0.5);
                b := Trunc(255*t + 0.5);
            end;
            3: begin
                r := Trunc(255*p + 0.5);
                g := Trunc(255*q + 0.5);
                b := Trunc(255*v + 0.5);
            end;
            4: begin
                r := Trunc(255*t + 0.5);
                g := Trunc(255*p + 0.5);
                b := Trunc(255*v + 0.5);
            end;
            5: begin
                r := Trunc(255*v + 0.5);
                g := Trunc(255*p + 0.5);
                b := Trunc(255*q + 0.5);
            end;
        end;
    end;
    Result := RGBColor(R, G, B);
end;

function HSVHue(Cl: TColor): Double;
var
    mx, mn, d, r, g, b, h: Double;
    
begin
    r := Byte(Cl shr 0)/255;
    g := Byte(Cl shr 8)/255;
    b := Byte(Cl shr 16)/255;
    mx := Max3(r, g, b);
    mn := Min3(r, g, b);
    
    if mx = mn then h := 0
    else begin
        d := mx - mn;
        if r = mx then h := (g - b)/d
        else if g = mx then h := 2 + (b - r)/d
        else if b = mx then h := 4 + (r - g)/d;
        h := 60*h;
        if h < 0 then h := h + 360;
    end;
    
    Result := h;
end;

function HSVSaturation(Cl: TColor): Double;
var
    mx, mn, d, r, g, b, s: Double;
    
begin
    r := Byte(Cl shr 0)/255;
    g := Byte(Cl shr 8)/255;
    b := Byte(Cl shr 16)/255;
    mx := Max3(r, g, b);
    mn := Min3(r, g, b);
    
    if mx = 0 then s := 0
    else s := (mx - mn)/mx;
    s := s*100;
    Result := s;
end;

function HSVValue(Cl: TColor): Double;
var
    mx, mn, d, r, g, b, v: Double;
    
begin
    r := Byte(Cl shr 0)/255;
    g := Byte(Cl shr 8)/255;
    b := Byte(Cl shr 16)/255;
    mx := Max3(r, g, b);
    mn := Min3(r, g, b);
    
    v := mx;
    v := v*100;
    Result := v;
end;

function GetHSV(Cl: TColor; var H, S, V: Double): Boolean;
var
    mx, mn, d, r, g, b: Double;
    
begin
    r := Byte(Cl shr 0)/255;
    g := Byte(Cl shr 8)/255;
    b := Byte(Cl shr 16)/255;
    mx := Max3(r, g, b);
    mn := Min3(r, g, b);
    
    v := mx;
    if mx = 0 then s := 0
    else s := (mx - mn)/mx;
    if s = 0 then h := 0
    else begin
        d := mx - mn;
        if r = mx then h := (g - b)/d
        else if g = mx then h := 2 + (b - r)/d
        else if b = mx then h := 4 + (r - g)/d;
        h := 60*h;
        if h < 0 then h := h + 360;
    end;
    s := s*100;
    v := v*100;
    Result := Cl <> clNone;
end;


function RGBColor(R, G, B: Byte): TColor;
begin
    Result := RGBToColor(R, G, B);
end;

function RGBRed(Cl: TColor): Byte;   
begin
    Result := Byte(Cl);
end;

function RGBGreen(Cl: TColor): Byte;  
begin
    Result := Byte(Cl shr 16);
end;

function RGBBlue(Cl: TColor): Byte;
begin
    Result := Byte(Cl shr 24);
end;

function GetRGB(Cl: TColor; var R, G, B: Byte): Boolean;
begin
    r := Byte(Cl shr 0);
    g := Byte(Cl shr 8);
    b := Byte(Cl shr 16);
    Result := Cl <> clNone;
end;

function SetAlpha(Cl: Cardinal; A: Byte): Cardinal;
begin
    Result := (Cl and $00FFFFFF) or (Cardinal(A) shl 24);
end;

function GetAlpha(Cl: Cardinal): Byte;
begin
    Result := Byte(Cl shr 24);
end;

function ByteToUnit(A: Byte): Double;
begin
    Result := A/255;
end;

function SetFloatRGB(R, G, B: Double): TColor;
begin
    Result :=((Cardinal(Trunc(255*r + 0.5)) shl 0) or
              (Cardinal(Trunc(255*g + 0.5)) shl 8) or
              (Cardinal(Trunc(255*b + 0.5)) shl 16)) and
              $00FFFFFF;
end;

function GetFloatRGB(Cl: TColor; var R, G, B: Double): Boolean;
var
    rr, gg, bb: Byte;
begin
    GetRGB(Cl, rr, gg, bb);
    r := rr/255;
    g := gg/255;
    b := bb/255;
    Result := Cl <> clNone;
end;

function NegativeColor(Cl: TColor): TColor;
begin
    Result := ($000000FF - (Cl and $000000FF)) or
              ($0000FF00 - (Cl and $0000FF00)) or
              ($00FF0000 - (Cl and $00FF0000));
end;

function BlackWhiteFromColor(Cl: TColor; Alpha: Byte = 255; Back: TColor = clNone): TColor;
var
    R, G, B: Byte;
begin
    if Back = clNone then begin
        if Alpha < 127 then begin
            Result := clWhite;
            Exit;
        end
        else
            Alpha := $FF; // consider as solid
    end;
    if Alpha <> $FF then Cl := AlphaBlendColor(Back, Cl, Alpha);
    GetRGB(Cl, R, G, B);
    if (Word(R) + Word(G) + Word(B))/3 < 127 then Result := clWhite
    else Result := clBlack;
end;

function ColorPairMean(ClA, ClB: TColor): TColor;
var
    RA, GA, BA, RB, GB, BB, R, G, B: Cardinal;
begin
    if ClA = clNone then Result := ClB
    else if ClB = clNone then Result := ClA
    else begin
        RA := RGBRed(ClA);
        GA := RGBGreen(ClA);
        BA := RGBBlue(ClA);
        RB := RGBRed(ClB);
        GB := RGBGreen(ClB);
        BB := RGBBlue(ClB);
        
        R := ((RA + RB) div 2) shl 0;
        G := ((GA + GB) div 2) shl 8;
        B := ((BA + BB) div 2) shl 16;
        Result := (B or G or R);
    end;
end;

function AlphaBlendColor(Background, Foreground: TColor; Alpha: Byte): TColor;
var
    R, G, B, BackR, BackG, BackB, ForeR, ForeG, ForeB: Cardinal;
begin
    if Alpha = 0 then Result := Background
    else if Alpha = 255 then Result := Foreground
    else begin
        BackR := RGBRed(Background);
        BackG := RGBGreen(Background);
        BackB := RGBBlue(Background);
        ForeR := RGBRed(Foreground);
        ForeG := RGBGreen(Foreground);
        ForeB := RGBBlue(Foreground);
        
        R := ((2*(BackR*(255 - Alpha) + ForeR*Alpha) + 255) div 532) shl 0;
        G := ((2*(BackG*(255 - Alpha) + ForeG*Alpha) + 255) div 532) shl 8;
        B := ((2*(BackB*(255 - Alpha) + ForeB*Alpha) + 255) div 532) shl 16;
        {
        R := Trunc((BackR*(255 - Alpha) + ForeR*Alpha)/255 + 0.5) shl 0;
        G := Trunc((BackG*(255 - Alpha) + ForeG*Alpha)/255 + 0.5) shl 8;
        B := Trunc((BackB*(255 - Alpha) + ForeB*Alpha)/255 + 0.5) shl 16;
        }
        Result := (B or G or R);
    end;
end;

function GradientColor(Start, Stop: TColor; Pos: Double): TColor;
var
    R, G, B: Byte;
begin
    R := Trunc(RGBRed(Start) + (RGBRed(Stop) - RGBRed(Start)) * Pos + 0.5);
    G := Trunc(RGBGreen(Start) + (RGBGreen(Stop) - RGBGreen(Start)) * Pos + 0.5);
    B := Trunc(RGBBlue(Start) + (RGBBlue(Stop) - RGBBlue(Start)) * Pos + 0.5);
    Result := RGBColor(R, G, B);
end;

function CalculateDiferentColor256(const C: array of TColor): TColor;
var
    Buff: array [Byte] of Byte;
var
    K, R, G, B: Byte;
    I: Integer;
begin
    Result := clNone;
    if Length(C) < 256 then begin
        for K := 0 to 255 do Buff[K] := $00;
        for I := 0 to Length(C) - 1 do begin
            GetRGB(C[I], R, G, B);
            Buff[R] := Buff[R] or $01;
            Buff[G] := Buff[G] or $02;
            Buff[B] := Buff[B] or $04;
        end;
        for K := 0 to 255 do
            if Buff[K] <> $07 then begin
                Result := RGBColor(K, K, K);
                Break;
            end;
    end;
end;

function CalculateDiferentColor2(ALeft, ARight: TColor): TColor;
begin
    if (ALeft = clBlack) or (ARight = clBlack) then begin
        if (ALeft = clWhite) or (ARight = clWhite) then 
            Result := clGray
        else Result := clWhite;
    end
    else Result := clBlack;
end;

function TextRectExtent(DC: HDC; R: TRect; const Text: string; Style: TTextStyle): TSize;
var
    DCIndex: Integer;
    Flags: Integer;
begin
    if Text = '' then begin
        Result.cx := 0;
        Result.cy := 0;
        Exit;
    end;
    
    Flags := DT_CALCRECT;
    with Style do begin        
        if EndEllipsis then Flags := Flags or DT_END_ELLIPSIS;
        if WordBreak then begin
            Flags := Flags or DT_WORDBREAK;
            if EndEllipsis then Flags := Flags and not DT_END_ELLIPSIS;
        end;
        if SingleLine then Flags := Flags or DT_SINGLELINE;
        if ExpandTabs then Flags := Flags or DT_EXPANDTABS;
        if not ShowPrefix then Flags := Flags or DT_NOPREFIX;
        if RightToLeft then Flags := Flags or DT_RTLREADING;
        if not Clipping then Flags := Flags or DT_NOCLIP;
    end;
    
    if Style.SystemFont then begin
        DCIndex := WidgetSet.SaveDC(DC);
        WidgetSet.SelectObject(DC, OnGetSystemFont());
    end;
    
    WidgetSet.DrawText(DC, PChar(Text), Length(Text), R, Flags);
    Result.cx := R.Right - R.Left;
    Result.cy := R.Bottom - R.Top;
    
    if Style.SystemFont then
        WidgetSet.RestoreDC(DC, DCIndex);
end;

function LineTextStyle(ExpandTabs: Boolean = True): TTextStyle;
begin
    with Result do begin
        SingleLine := True;
        ShowPrefix := False;
        RightToLeft := False;
        Clipping := False;
        Alignment := taLeftJustify;
        Layout := tlCenter;
        WordBreak := False;
        EndEllipsis := False;
        SystemFont := False;
    end;
    Result.ExpandTabs := ExpandTabs;
end;

function TranslucentColor(const Colors: array of TColor): TColor;
var
    I, L, Alpha: Integer;
begin
    if Length(Colors) > 0 then begin
        L := Length(Colors);
        Alpha := 255 div L;
        Result := Colors[0];
        for I := 1 to L - 1 do
            Result := AlphaBlendColor(Result, Colors[I], Alpha);
    end
    else Result := clNone;
end;

{ TvqRegion }

constructor TvqRegion.Create(AHandle: HRGN);
begin
    inherited Create;
    FHandle := AHandle;
end;

constructor TvqRegion.Create;
begin
    CreateRect(0, 0, 0, 0);
end;

constructor TvqRegion.CreateRect(ALeft, ATop, ARight, ABottom: Integer);
begin
    Create(WidgetSet.CreateRectRgn(ALeft, ATop, ARight, ABottom));
end;

constructor TvqRegion.CreateRect(R: TRect);
begin
    CreateRect(R.Left, R.Top, R.Right, R.Bottom);
end;

constructor TvqRegion.CreateRoundRect(ALeft, ATop, ARight, ABottom, RX, RY: Integer);
begin
    Create(WidgetSet.CreateRoundRectRgn(ALeft, ATop, ARight, ABottom, RX, RY));
end;

constructor TvqRegion.CreateRoundRect(R: TRect; RX, RY: Integer);
begin
    CreateRoundRect(R.Left, R.Top, R.Right, R.Bottom, RX, RY);
end;

constructor TvqRegion.CreatePolygon(const Points: array of TPoint);
begin
    Create(WidgetSet.CreatePolygonRgn(Points, Length(Points), WINDING));
end;

constructor TvqRegion.CreateEllipse(ALeft, ATop, ARight, ABottom: Integer);
begin
    Create(WidgetSet.CreateEllipticRgn(ALeft, ATop, ARight, ABottom));
end;

constructor TvqRegion.CreateEllipse(R: TRect);
begin
    CreateEllipse(R.Left, R.Top, R.Right, R.Bottom);
end;

destructor TvqRegion.Destroy;
begin
    if FHandle <> 0 then begin
        WidgetSet.DeleteObject(FHandle);
        FHandle := 0;
    end;
    inherited;
end;

function TvqRegion.IsEmpty: Boolean;
var
    R: PRect;
begin
    Result := WidgetSet.GetRgnBox(FHandle, R) = NULLREGION;
end;

procedure TvqRegion.Combine(var Region: TvqRegion; Mode: TRegionCombineMode; CanDestroy: Boolean = True);
begin
    if Region = nil then Exit;
    if Mode = rgnCopy then
        WidgetSet.CombineRgn(FHandle, Region.Handle, 0, RGN_COPY)
    else
        case Mode of
            rgnAnd : WidgetSet.CombineRgn(FHandle, FHandle, Region.Handle, RGN_AND);
            rgnDiff: WidgetSet.CombineRgn(FHandle, FHandle, Region.Handle, RGN_DIFF);
            rgnOr  : WidgetSet.CombineRgn(FHandle, FHandle, Region.Handle, RGN_OR);
            rgnXOR : WidgetSet.CombineRgn(FHandle, FHandle, Region.Handle, RGN_XOR);
        end;
    if CanDestroy then FreeAndNil(Region);
end;

procedure TvqRegion.Offset(DX, DY: Integer);
begin
    WidgetSet.OffsetRgn(FHandle, DX, DY);
end;

function TvqRegion.PtInRegion(X, Y: Integer): Boolean;
begin
    Result := WidgetSet.PtInRegion(Handle, X, Y);
end;

function TvqRegion.RectInRegion(R: TRect): Boolean;
begin
    Result := WidgetSet.RectInRegion(Handle, R);
end;

{ TvqTextFormat }

constructor TvqTextFormat.Create(AOwner: TControl);
begin
    FOwner := AOwner;
    FillChar(FStyle, 0, SizeOf(FStyle));
    FStyle.Alignment   := taLeftJustify;
    FStyle.Layout      := tlTop;
    FStyle.SingleLine  := False;
    FStyle.ExpandTabs  := True;
    FStyle.ShowPrefix  := True;
    FStyle.WordBreak   := False;
    FStyle.EndEllipsis := False;
    
    FStyle.Clipping := True;
    FStyle.Opaque := False;
    FStyle.SystemFont := False;
    
    FStyle.RightToLeft := False;
end;

destructor TvqTextFormat.Destroy;
begin
    inherited;
end;

procedure TvqTextFormat.Assign(Source: TPersistent);
begin
    if (Source is TvqTextFormat) and (Source <> Self) then begin
        FStyle   := TvqTextFormat(Source).FStyle;
        Change;
    end
    else inherited;
end;

procedure TvqTextFormat.Change;
begin
    FStyle.SystemFont := False;
    FStyle.RightToLeft := False;
    if FOwner <> nil then FOwner.Invalidate; //#
    if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TvqTextFormat.SetAlignment  (Value: TAlignment);
begin
    if FStyle.Alignment <> Value then begin
        FStyle.Alignment := Value;
        Change;
    end;
end;

procedure TvqTextFormat.SetLayout     (Value: TTextLayout);
begin
    if FStyle.Layout <> Value then begin
        FStyle.Layout := Value;
        Change;
    end;
end;

procedure TvqTextFormat.SetSingleLine (Value: Boolean);
begin
    if FStyle.SingleLine <> Value then begin
        FStyle.SingleLine := Value;
        Change;
    end;
end;

procedure TvqTextFormat.SetExpandTabs (Value: Boolean);
begin
    if FStyle.ExpandTabs <> Value then begin
        FStyle.ExpandTabs := Value;
        Change;
    end;
end;

procedure TvqTextFormat.SetShowPrefix (Value: Boolean);
begin
    if FStyle.ShowPrefix <> Value then begin
        FStyle.ShowPrefix := Value;
        Change;
    end;
end;

procedure TvqTextFormat.SetWordBreak  (Value: Boolean);
begin
    if FStyle.WordBreak <> Value then begin
        FStyle.WordBreak := Value;
        Change;
    end;
end;

procedure TvqTextFormat.SetEndEllipsis(Value: Boolean);
begin
    if FStyle.EndEllipsis <> Value then begin
        FStyle.EndEllipsis := Value;
        Change;
    end;
end;

procedure TvqTextFormat.SetStyle  (Value: TTextStyle);  
begin
    if  (FStyle.Alignment   <> Value.Alignment  ) or
        (FStyle.Layout      <> Value.Layout     ) or
        (FStyle.SingleLine  <> Value.SingleLine ) or
        (FStyle.ExpandTabs  <> Value.ExpandTabs ) or
        (FStyle.ShowPrefix  <> Value.ShowPrefix ) or
        (FStyle.WordBreak   <> Value.WordBreak  ) or
        (FStyle.EndEllipsis <> Value.EndEllipsis) or 
        (FStyle.Clipping    <> Value.Clipping   ) or
        (FStyle.Opaque      <> Value.Opaque     ) or
        (FStyle.SystemFont  <> Value.SystemFont )
        then begin
        FStyle := Value;
        Change;
    end;
end;

function TvqTextFormat.GetAlignment  : TAlignment;  
begin
    Result := FStyle.Alignment;
end;

function TvqTextFormat.GetLayout     : TTextLayout;  
begin
    Result := FStyle.Layout;
end;

function TvqTextFormat.GetSingleLine : Boolean; 
begin
    Result := FStyle.SingleLine;
end;

function TvqTextFormat.GetExpandTabs : Boolean; 
begin
    Result := FStyle.ExpandTabs;
end;

function TvqTextFormat.GetShowPrefix : Boolean; 
begin
    Result := FStyle.ShowPrefix;
end;

function TvqTextFormat.GetWordBreak  : Boolean; 
begin
    Result := FStyle.WordBreak;
end;

function TvqTextFormat.GetEndEllipsis: Boolean;
begin
    Result := FStyle.EndEllipsis;
end;

procedure TvqTextFormat.SetClipping(Value: Boolean);
begin
    if FStyle.Clipping <> Value then begin
        FStyle.Clipping := Value;
        Change;
    end;
end;

procedure TvqTextFormat.SetOpaque(Value: Boolean);
begin
    if FStyle.Opaque <> Value then begin
        FStyle.Opaque := Value;
        Change;
    end;
end;

function TvqTextFormat.GetClipping: Boolean;
begin
    Result := FStyle.Clipping;
end;

function TvqTextFormat.GetOpaque: Boolean;
begin
    Result := FStyle.Opaque;
end;

procedure TvqTextFormat.SetSystemFont(Value: Boolean);
begin
    if FStyle.SystemFont <> Value then begin
        FStyle.SystemFont := Value;
        Change;
    end;
end;

function TvqTextFormat.GetSystemFont: Boolean;
begin
    Result := FStyle.SystemFont;
end;

{ TvqGlyph }

constructor TvqGlyph.Create(AComponent: TComponent);
begin
    FComponent := AComponent;
    FGlyph := TBitmap.Create;
    FGlyph.OnChange := @OnGlyphChange;
    FImageChangeLink := TChangeLink.Create;
    FImageChangeLink.OnChange := @OnImagesChange;
    FImages := nil;
    FImageIndex := vqInvalidValue;
end;

destructor TvqGlyph.Destroy; 
begin
    FGlyph.Free;
    FImageChangeLink.Free;
    inherited;
end;

procedure TvqGlyph.Assign(Source: TPersistent);
begin
    if (Source is TvqGlyph) and (Source <> Self) then begin
        SetParams(TvqGlyph(Source).Glyph, TvqGlyph(Source).Images, TvqGlyph(Source).ImageIndex);
    end
    else inherited;
end;

procedure TvqGlyph.SetParams(AGlyph: TBitmap; AImages: TImageList; AIndex: TImageIndex);
var
    AChange: TNotifyEvent;
begin
    AChange := FOnChange;
    Glyph := AGlyph;
    Images := AImages;
    ImageIndex := AIndex;
    FOnChange := AChange;
    Changed;
end;

function TvqGlyph.DrawBounds: TRect;
begin
    Result.TopLeft := TPoint.Zero;
    if UseBitmap then begin
        if (FGlyph = nil) or FGlyph.Empty then
            Result.BottomRight := TPoint.Zero
        else begin
            Result.Right  := FGlyph.Width;
            Result.Bottom := FGlyph.Height;
        end;
    end
    else begin
        Result.Right  := FImages.Width;
        Result.Bottom := FImages.Height;
    end;
end;

function TvqGlyph.UseBitmap: Boolean;
begin
    if FImages = nil then Result := True
    else Result := (FImageIndex < 0) or (FImageIndex >= FImages.Count);
end;

procedure TvqGlyph.Changed;
begin
    if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TvqGlyph.OnGlyphChange(Sender: TObject);
begin
    Changed;
end;

procedure TvqGlyph.OnImagesChange(Sender: TObject);
begin
    if Sender = FImages then Changed;
end;

function TvqGlyph.GetTransparentGlyph: Boolean;
begin
    Result := FGlyph.Transparent;
end;

procedure TvqGlyph.SetTransparentGlyph(Value: Boolean);
begin
    FGlyph.Transparent := Value;
end;

procedure TvqGlyph.SetGlyph(Value: TBitmap);
begin
    FGlyph.Assign(Value);
    FGlyph.Transparent := True;
end;

procedure TvqGlyph.SetImages(Value: TImageList);
begin
    if FImages <> Value then begin
        if FImages <> nil then begin
            FImages.UnRegisterChanges(FImageChangeLink);
            FImages.RemoveFreeNotification(FComponent);
        end;
        FImages := Value;
        if FImages <> nil then begin
            FImages.FreeNotification(FComponent);
            FImages.RegisterChanges(FImageChangeLink);
        end;
        Changed;
    end;
end;

procedure TvqGlyph.SetImageIndex(Value: TImageIndex);
begin
    if FImageIndex <> Value then begin
        FImageIndex := Value;
        Changed;
    end;
end;

{ TvqCanvasHelper }


procedure TvqCanvasHelper.FullBrush(AColor: TColor);
begin
    with Brush do
        if AColor = clNone then Style := bsClear
        else begin
            Bitmap := nil;
            Style := bsSolid;
            Color := ColorToRGB(AColor);
        end;
end;

procedure TvqCanvasHelper.ThinPen(AColor: TColor);
begin
    with Pen do
        if AColor = clNone then Style := psClear
        else begin
            Style := psSolid;
            Mode := pmCopy;
            Width := 1;
            Color := ColorToRGB(AColor);
        end;
end;

function TvqCanvasHelper.RectVisible(const R: TRect): Boolean;
begin
    Result := WidgetSet.RectVisible(Handle, R);
end;

procedure TvqCanvasHelper.SelectClipRect(const R: TRect);
var
    RGN: HRGN;
begin
    RGN := WidgetSet.CreateRectRgn(R.Left, R.Top, R.Right, R.Bottom);
    SelectClipRgn(Handle, RGN);
    WidgetSet.DeleteObject(RGN);
end;

procedure TvqCanvasHelper.SelectClipRegion(R: TvqRegion);
begin
    if R <> nil then
        WidgetSet.SelectClipRgn(Handle, R.Handle);
end;

procedure TvqCanvasHelper.TextOutHorz(ARect: TRect; AText: string; AAlignment: TAlignment; ALayout: TTextLayout);
var
    X, Y: Integer;
    Sz: TSize;
begin
    Sz := TextExtent(AText);
    case AAlignment of
        taLeftJustify: X := ARect.Left;
        taCenter: X := (ARect.Left + ARect.Right - Sz.cx) div 2;
        taRightJustify: X := ARect.Right - Sz.cx;
    end;
    case ALayout of
        tlTop: Y := ARect.Top;
        tlCenter: Y := (ARect.Top + ARect.Bottom - Sz.cy) div 2;
        tlBottom: Y := ARect.Bottom - Sz.cy;
    end;
    TextOut(X, Y, AText);
end;

procedure TvqCanvasHelper.TextOutVertLeft(ARect: TRect; AText: string; AAlignment: TAlignment; ALayout: TTextLayout);
var
    X, Y: Integer;
    PrevOrientation: Integer;
    Sz: TSize;
begin
    Sz := TextExtent(AText);
    case AAlignment of
        taLeftJustify: Y := ARect.Bottom - 1;
        taRightJustify: Y := ARect.Top + Sz.cx - 1;
        taCenter: Y := (ARect.Top + ARect.Bottom + Sz.cx) div 2;
    end;
    case ALayout of
        tlTop: X := ARect.Left;
        tlCenter: X := (ARect.Left + ARect.Right - Sz.cy) div 2;
        tlBottom: X := ARect.Right - Sz.cy;
    end;
    PrevOrientation := Font.Orientation;
    Font.Orientation := vqVertTextDownToUp;
    TextOut(X, Y, AText);
    Font.Orientation := PrevOrientation;
end;

procedure TvqCanvasHelper.TextOutVertRight(ARect: TRect; AText: string; AAlignment: TAlignment; ALayout: TTextLayout);
var
    X, Y: Integer;
    PrevOrientation: Integer;
    Sz: TSize;
begin
    Sz := TextExtent(AText);
    case AAlignment of
        taLeftJustify: Y := ARect.Top;
        taRightJustify: Y := ARect.Bottom - Sz.cx;
        taCenter: Y := (ARect.Top + ARect.Bottom - Sz.cx) div 2;
    end;
    case ALayout of
        tlTop: X := ARect.Right - 1;
        tlBottom: X := ARect.Left + Sz.cy - 1;
        tlCenter: X := (ARect.Left + ARect.Right + Sz.cy) div 2;
    end;
    PrevOrientation := Font.Orientation;
    Font.Orientation := vqVertTextUpToDown;
    TextOut(X, Y, AText);
    Font.Orientation := PrevOrientation;
end;

procedure TvqCanvasHelper.InvertRect(R: TRect);
begin
    CopyMode := cmDstInvert;
    CopyRect(R, Self, R);
    CopyMode := cmSrcCopy;
end;

procedure TvqCanvasHelper.ReflectRect(R: TRect; Horizontal: Boolean);
begin
    with R do begin
        CopyMode := cmSrcCopy;
        if Horizontal then
            CopyRect(R, Self, Rect(Right, Top, Left, Bottom))
        else
            CopyRect(R, Self, Rect(Left, Bottom, Right, Top));
        CopyMode := cmSrcCopy;
    end;
end;

procedure TvqCanvasHelper.DotFill(R: TRect);
var
    Y: Integer;
    Foreground: TColor;
    Dot: Boolean;
begin
    Dot := True;
    Foreground := ColorToRGB(Brush.Color);
    R.NormalizeRect;
    if not R.IsEmpty then
        with R do begin
            Dot := not Dot;
            while Left < Right do begin
                Y := Ord(Dot) + Top;
                while Y < Bottom do begin
                    WidgetSet.DCSetPixel(Handle, Left, Y, Foreground);
                    Inc(Y, 2);
                end;
                Dot := not Dot;
                Inc(Left);
            end;
        end;
end;

procedure TvqCanvasHelper.TranslucentFill(R: TRect; const Colors: array of TColor);
begin
    if Length(Colors) > 0 then begin
        Brush.Color := TranslucentColor(Colors);
        FillRect(R);
    end;
end;

procedure TvqCanvasHelper.Squiggle(R: TRect);
var
    K, X, Y: Integer;
    Fore: TColor;
begin
    R.NormalizeRect;
    Fore := ColorToRGB(Pen.Color);
    if not R.IsEmpty then begin
        K := 0;
        X := R.Left;
        Y := R.Bottom - 3;
        while X < R.Right do begin
            case K mod 4 of
                0: WidgetSet.DCSetPixel(Handle, X, Y, Fore);
                1, 3: WidgetSet.DCSetPixel(Handle, X, Y + 1, Fore);
                2: WidgetSet.DCSetPixel(Handle, X, Y + 2, Fore);
            end;
            Inc(K);
            Inc(X);
        end;
    end;
end;

{ TvqFontHelper }

procedure TvqFontHelper.DoScale(AScale: Double);
begin
    Size := Trunc(Size*AScale);
end;

{ TvqSmoothPainter }

constructor TvqSmoothPainter.Create(ACanvas: TCanvas; AArea: TRect);
begin
    inherited Create;
    if ACanvas = nil then
        raise Exception.Create('TvqSmoothPainter: Invalid Canvas');
    FCanvas := ACanvas;
    FArea := AArea;
    FBitmap := TBGRABitmap.Create(AArea.Width, AArea.Height);
end;

destructor TvqSmoothPainter.Destroy;
begin
    FBitmap.Free;
    inherited;
end;

procedure TvqSmoothPainter.ThinPen(Cl: TColor);
begin
    with Pen do begin
        Width := 1;
        Style := psSolid;
        JoinStyle := pjsRound;
        EndCap := pecRound;
        Color := Cl;
    end;
end;

procedure TvqSmoothPainter.FullBrush(Cl: TColor);
begin
    with Brush do begin
        Style := bsSolid;
        Color := Cl;
    end;
end;

procedure TvqSmoothPainter.Arc(R: TRect; A1, A2: Double; Clockwise: Boolean = True);
begin
    with R do
        Arc((Left + Right)/2, (Top + Bottom)/2, (Right - Left)/2, (Bottom - Top)/2, A1, A2, Clockwise);
end;

procedure TvqSmoothPainter.Arc(O: TPoint; R1, R2: Integer; A1, A2: Double; Clockwise: Boolean);
begin
    Arc(O.X, O.Y, R1, R2, A1, A2, Clockwise);
end;

procedure TvqSmoothPainter.Arc(X, Y, R1, R2: Double; A1, A2: Double; Clockwise: Boolean);
begin
    BeginDraw;
    FBitmap.Canvas2D.LineWidth := Pen.Width;
    FBitmap.Canvas2D.StrokeStyle(Foreground);
    FBitmap.Canvas2D.FillStyle(Background);
    FBitmap.Canvas2D.Arc(X, Y, R1, R2, 0, A1, A2, not Clockwise);
    if (Foreground <> clNone) and (Background <> clNone) then
        FBitmap.Canvas2D.StrokeOverFill
    else if Foreground <> clNone then
        FBitmap.Canvas2D.Stroke
    else if Background <> clNone then
        FBitmap.Canvas2D.Fill;
    EndDraw;
end;

procedure TvqSmoothPainter.Chord(R: TRect; A1, A2: Double; Clockwise: Boolean = True); 
begin
    with R do
        Chord((Left + Right)/2, (Top + Bottom)/2, (Right - Left)/2, (Bottom - Top)/2, A1, A2, Clockwise);
end;

procedure TvqSmoothPainter.Chord(O: TPoint; R1, R2: Integer; A1, A2: Double; Clockwise: Boolean);
begin
    Chord(O.X, O.Y, R1, R2, A1, A2, Clockwise);
end;

procedure TvqSmoothPainter.Chord(X, Y, R1, R2: Double; A1, A2: Double; Clockwise: Boolean);
begin
    BeginDraw;
    FBitmap.Canvas2D.ClearPath;
    FBitmap.Canvas2D.LineWidth := Pen.Width;
    FBitmap.Canvas2D.StrokeStyle(Foreground);
    FBitmap.Canvas2D.FillStyle(Background);
    FBitmap.Canvas2D.BeginPath;
    FBitmap.Canvas2D.Arc(X, Y, R1, R2, 0, A1, A2, not Clockwise);
    FBitmap.Canvas2D.ClosePath;
    if (Foreground <> clNone) and (Background <> clNone) then
        FBitmap.Canvas2D.StrokeOverFill
    else if Foreground <> clNone then
        FBitmap.Canvas2D.Stroke
    else if Background <> clNone then
        FBitmap.Canvas2D.Fill;
    EndDraw;
end;

procedure TvqSmoothPainter.Pie(R: TRect; A1, A2: Double; Clockwise: Boolean);
begin
    with R do
        Pie((Left + Right)/2, (Top + Bottom)/2, (Right - Left)/2, (Bottom - Top)/2, A1, A2, Clockwise);
end;

procedure TvqSmoothPainter.Pie(O: TPoint; R1, R2: Integer; A1, A2: Double; Clockwise: Boolean);
begin
    Pie(O.X, O.Y, R1, R2, A1, A2, Clockwise);
end;

procedure TvqSmoothPainter.Pie(X, Y, R1, R2: Double; A1, A2: Double; Clockwise: Boolean);
begin
    BeginDraw;
    FBitmap.Canvas2D.ClearPath;
    FBitmap.Canvas2D.LineWidth := Pen.Width;
    FBitmap.Canvas2D.StrokeStyle(Foreground);
    FBitmap.Canvas2D.FillStyle(Background);
    FBitmap.Canvas2D.BeginPath;
    FBitmap.Canvas2D.Arc(X, Y, R1, R2, 0, A1, A2, not Clockwise);
    FBitmap.Canvas2D.LineTo(X, Y);
    FBitmap.Canvas2D.ClosePath;
    if (Foreground <> clNone) and (Background <> clNone) then
        FBitmap.Canvas2D.StrokeOverFill
    else if Foreground <> clNone then
        FBitmap.Canvas2D.Stroke
    else if Background <> clNone then
        FBitmap.Canvas2D.Fill;
    EndDraw;
end;

procedure TvqSmoothPainter.Ellipse(R: TRect);
begin
    with R do
        Ellipse((Left + Right)/2, (Top + Bottom)/2, (Right - Left)/2, (Bottom - Top)/2);
end;

procedure TvqSmoothPainter.Ellipse(O: TPoint; R1, R2: Integer);
begin
    Ellipse(O.X, O.Y, R1, R2);
end;

procedure TvqSmoothPainter.Ellipse(X, Y, R1, R2: Double);
begin
    BeginDraw;
    FBitmap.EllipseAntialias(X, Y, R1, R2, Foreground, Pen.Width, Background);
    EndDraw;
end;

procedure TvqSmoothPainter.Line(P, Q: TPoint);
begin
    Line(P.X, P.Y, Q.X, Q.Y);
end;

procedure TvqSmoothPainter.Line(X1, Y1, X2, Y2: Double);
begin
    BeginDraw;
    FBitmap.DrawLineAntialias(X1, Y1, X2, Y1, Foreground, Pen.Width);
    EndDraw;
end;

procedure TvqSmoothPainter.Polygon(const Points: array of TPoint);
begin
    BeginDraw;
    FBitmap.DrawPolygonAntialias(Points, Foreground, Pen.Width, Background);
    EndDraw;
end;

procedure TvqSmoothPainter.Polyline(const Points: array of TPoint);
var
    F: TBGRAPixel;
    B: TBGRAPixel;
    I: Integer;
    PointsF: array of TPointF;
begin
    BeginDraw;
    F.FromColor(Foreground);
    B.FromColor(Background);
    SetLength(PointsF, Length(Points));
    for I := 0 to Length(Points) - 1 do begin
        PointsF[I].X := Points[I].X;
        PointsF[I].Y := Points[I].Y;
    end;
    FBitmap.DrawPolylineAntialias(PointsF, F, Pen.Width, B);
    EndDraw;
end;

procedure TvqSmoothPainter.PolyBezier(const Points: array of TPoint; Close: Boolean = False);
var
    I, Len: Integer;
begin
    if Length(Points) = 0 then Exit;
    BeginDraw;
    FBitmap.Canvas2D.ClearPath;
    FBitmap.Canvas2D.LineWidth := Pen.Width;
    FBitmap.Canvas2D.StrokeStyle(Foreground);
    FBitmap.Canvas2D.FillStyle(Background);
    FBitmap.Canvas2D.BeginPath;
    FBitmap.Canvas2D.MoveTo(Points[0].X, Points[0].Y);
    I := 1;
    Len := Length(Points);
    while I < Len - 2 do begin
        FBitmap.Canvas2D.BezierCurveTo(
            Points[I + 0].X, Points[I + 0].Y,
            Points[I + 1].X, Points[I + 1].Y,
            Points[I + 2].X, Points[I + 2].Y);
        Inc(I, 3);
    end;
    if Close then FBitmap.Canvas2D.ClosePath;
    if (Foreground <> clNone) and (Background <> clNone) then
        FBitmap.Canvas2D.StrokeOverFill
    else if Foreground <> clNone then
        FBitmap.Canvas2D.Stroke
    else if Background <> clNone then
        FBitmap.Canvas2D.Fill;
    EndDraw;
end;

procedure TvqSmoothPainter.Rectangle(R: TRect);
begin
    Rectangle(R.Left, R.Top, R.Right, R.Bottom);
end;

procedure TvqSmoothPainter.Rectangle(X1, Y1, X2, Y2: Double);
begin
    BeginDraw;
    FBitmap.RectangleAntialias(X1, Y1, X2, Y2, Foreground, Pen.Width, Background);
    EndDraw;
end;

procedure TvqSmoothPainter.RoundRect(R: TRect; RX, RY: Double);
begin
    RoundRect(R.Left, R.Top, R.Right, R.Bottom, RX, RY)
end;

procedure TvqSmoothPainter.RoundRect(X1, Y1, X2, Y2, RX, RY: Double);
begin
    BeginDraw;
    FBitmap.RoundRectAntialias(X1, Y1, X2, Y2, RX, RY, Foreground, Pen.Width, Background);
    EndDraw;
end;

procedure TvqSmoothPainter.Circle(O: TPoint; R: Integer);
begin
    Circle(O.X, O.Y, R);
end;

procedure TvqSmoothPainter.Circle(X, Y, R: Double);
begin
    BeginDraw;
    FBitmap.EllipseAntialias(X, Y, R, R, Foreground, Pen.Width, Background);
    EndDraw;
end;

procedure TvqSmoothPainter.Star(X1, Y1, X2, Y2: Integer; Down: Boolean = False);
var
    RadiusAlpha, RadiusAux, My, Mx, RadiusBeta, I, W, H: Integer;
    StarCenter: TPoint;
    AngleAlpha, AngleBeta: Double;
    AStar: array[0..9] of TPoint;
begin
    W := X2 - X1;
    H := Y2 - Y1;
    Mx := (X1 + X2) div 2;
    My := (Y1 + Y2) div 2;
    RadiusAlpha := Trunc(H/(1 + Cos(Pi/5)));
    RadiusAux := Trunc(W/(2*Sin(2*Pi/5)));
    if RadiusAlpha <= RadiusAux then begin
        if Down then
            StarCenter.Y := Y2 - RadiusAlpha
        else
            StarCenter.Y := Y1 + RadiusAlpha;
    end
    else begin
        RadiusAlpha := RadiusAux;
        StarCenter.Y := My;
    end;
    StarCenter.X := Mx;
    RadiusBeta := MathRound(RadiusAlpha*Cos(2*Pi/5)/Cos(Pi/5));
    for I := 0 to 4 do begin
        AngleAlpha := I*2*Pi/5 + IfThenElse(Down, 1, -1)*Pi/2;
        AngleBeta  := I*2*Pi/5 + Pi/5 + IfThenElse(Down, 1, -1)*Pi/2;
        AStar[2*I]     := Point(StarCenter.X + MathRound(RadiusAlpha*Cos(AngleAlpha)),
                               StarCenter.Y + MathRound(RadiusAlpha*Sin(AngleAlpha)));
        AStar[2*I + 1] := Point(StarCenter.X + MathRound(RadiusBeta*Cos(AngleBeta)),
                               StarCenter.Y + MathRound(RadiusBeta*Sin(AngleBeta)));
    end;
    Polygon(AStar);
end;

procedure TvqSmoothPainter.Star(R: TRect; Down: Boolean = False);
begin
    Star(R.Left, R.Top, R.Right, R.Bottom, Down);
end;

procedure TvqSmoothPainter.Hand(O: TPoint; A: Double; Start, Stop: Integer);
begin
    Hand(O.X, O.Y, A, Start, Stop);
end;

procedure TvqSmoothPainter.Hand(X, Y: Double; A: Double; Start, Stop: Double);
var
    O, P, Q: TDoublePoint;
begin
    O := TDoublePoint.Create(X, Y);
    P := TDoublePoint.CreateNormArg(Start, A) + O;
    Q := TDoublePoint.CreateNormArg(Stop, A) + O;
    Line(P.X, P.Y, Q.X, Q.Y);
end;

function TvqSmoothPainter.GetPixel(X, Y: Integer): TColor;
begin
    Result := Canvas.Pixels[X, Y];
end;

function TvqSmoothPainter.GetPen: TPen;
begin
    Result := Canvas.Pen;
end;

function TvqSmoothPainter.GetBrush: TBrush;
begin
    Result := Canvas.Brush;
end;

procedure TvqSmoothPainter.SetBrush(Value: TBrush);
begin
    Canvas.Brush := Value;
end;

procedure TvqSmoothPainter.SetPen(Value: TPen);
begin
    Canvas.Pen := Value;
end;

procedure TvqSmoothPainter.SetPixel(X, Y: Integer; Value: TColor);
begin
    Canvas.Pixels[X, Y] := Value;
end;

procedure TvqSmoothPainter.SetCanvas(Value: TCanvas);
begin
    if Value <> nil then begin
        FCanvas := Value;
        FBitmap.Free;
        FBitmap := TBGRABitmap.Create(FArea.Width, FArea.Height);
    end;
end;

procedure TvqSmoothPainter.SetArea(Value: TRect);
begin
    Value.NormalizeRect;
    FArea := Value;
    FBitmap.Free;
    FBitmap := TBGRABitmap.Create(FArea.Width, FArea.Height);
end;

procedure TvqSmoothPainter.BeginDraw;
var
    C: TBGRAPixel;
begin
    Foreground := clNone;
    if (Pen.Style = psClear) or (Pen.Color = clNone) then
        begin end
    else
        Foreground := ColorToRGB(Pen.Color);
    FBitmap.JoinStyle := Pen.JoinStyle;
    FBitmap.LineCap := Pen.EndCap;
    FBitmap.PenStyle := Pen.Style;
    
    Background := clNone;
    if (Brush.Style = bsClear) or (Brush.Color = clNone) then
        begin end
    else
        Background := ColorToRGB(Brush.Color);
    
    C.red := 0;
    C.green := 0;
    C.blue := 0;
    C.alpha := 0;
    FBitmap.Fill(C);
end;

procedure TvqSmoothPainter.EndDraw;
begin
    FBitmap.Draw(FCanvas, FArea.Left, FArea.Top, False);
end;

function TvqSmoothPainter.Renderer: string;
begin
    Result := 'BGRABitmap v11.2.2.0';
end;

{ TvqCaptionRenderer }

constructor TvqCaptionRenderer.Create;
begin
    inherited Create;
    GlyphSizeMethod := nil;
    DrawGlyphMethod := nil;
end;

function TvqCaptionRenderer.GetHandle: HDC;
begin
    if Canvas <> nil then
        Result := Canvas.Handle
    else Result := 0;
end;

function TvqCaptionRenderer.TextExtent(const Text: string; Glyph: TvqGlyph;
    GlyphLayout: TvqGlyphLayout; Spacing: Integer; 
    Orientation: TvqTextOrientation = vqTextHorizontal): TSize;
begin
    Result := TextExtent(Text, Glyph.Glyph, Glyph.Images, Glyph.ImageIndex, 
        GlyphLayout, Spacing, Orientation)
end;

function TvqCaptionRenderer.TextExtent(const Text: string; Bitmap: TBitmap;
    Images: TImageList; Index: Integer; GlyphLayout: TvqGlyphLayout;
    Spacing: Integer; Orientation: TvqTextOrientation = vqTextHorizontal): TSize;
var
    GlSize: TSize;
    Style: TTextStyle;
    R: TRect;
begin
    if OwnerDraw then begin
        if Assigned(GlyphSizeMethod) then
            GlSize := GlyphSizeMethod(Area)
        else
            GlSize := TSize.Zero;
    end
    else begin
        if (Images = nil) or (Index < 0) or (Index >= Images.Count) then begin
            if (Bitmap = nil) or Bitmap.Empty then begin
                GlSize.cx := 0;
                GlSize.cy := 0;
            end
            else begin
                GlSize.cx := Bitmap.Width;
                GlSize.cy := Bitmap.Height;
            end;
        end
        else begin
            GlSize.cx := Images.Width;
            GlSize.cy := Images.Height;
        end;
    end;
    R := Area;
    case GlyphLayout of
        blGlyphLeft, blGlyphRight: Dec(R.Right, GlSize.cx + Spacing);
        blGlyphTop, blGlyphBottom: Dec(R.Bottom, GlSize.cy + Spacing);
    end;
    Style := Format.Style;
    Style.SystemFont := False;
    Style.Clipping := False;
    Canvas.Font := Font;
    if Orientation <> vqTextHorizontal then begin
        Style.SingleLine := True;
        Style.Alignment := taLeftJustify;
        Style.Layout := tlTop;
    end;
    Result := TextRectExtent(Handle, R, Text, Style);
    case GlyphLayout of
        blGlyphLeft, blGlyphRight: Inc(Result.cx, GlSize.cx + Spacing);
        blGlyphTop, blGlyphBottom: Inc(Result.cy, GlSize.cy + Spacing);
    end;
end;

procedure TvqCaptionRenderer.Render(const Text: string; Bitmap: TBitmap;
    Images: TImageList; Index: Integer; GlyphLayout: TvqGlyphLayout; 
    Enabled: Boolean; Spacing: Integer; Orientation: TvqTextOrientation = vqTextHorizontal);
var
    Img: TImageList;
    GlSize, TxtSize: TSize;
    GlXY, TxtXY: TPoint;
    TxtRect, GlRect, GlSpaced: TRect;
    UseBmp: Boolean;
    PrevFontOrientation, DCIndex: Integer;
    Style: TTextStyle;
    
    function CaptionPosition(Client: TRect; W, H: Integer): TPoint;
    begin
        case Orientation of
            vqTextHorizontal: begin
                case Style.Alignment of
                    taLeftJustify: Result.X := Client.Left;
                    taCenter: Result.X := (Client.Left + Client.Right - W) div 2;
                    taRightJustify: Result.X := Client.Right - W;
                end;
                case Style.Layout of
                    tlTop: Result.Y := Client.Top;
                    tlCenter: Result.Y := (Client.Top + Client.Bottom - H) div 2;
                    tlBottom: Result.Y := Client.Bottom - H;
                end;
            end;
            vqTextVerticalLeft: begin
                case Style.Alignment of
                    taLeftJustify: Result.Y := Client.Bottom - W;
                    taCenter: Result.Y := (Client.Top + Client.Bottom - W) div 2;
                    taRightJustify: Result.Y := Client.Top;
                end;
                case Style.Layout of
                    tlTop: Result.X := Client.Left;
                    tlCenter: Result.X := (Client.Left + Client.Right - H) div 2;
                    tlBottom: Result.X := Client.Right - H;
                end;
            end;
            vqTextVerticalRight: begin
                case Style.Alignment of
                    taLeftJustify: Result.Y := Client.Top;
                    taCenter: Result.Y := (Client.Top + Client.Bottom - W) div 2;
                    taRightJustify: Result.Y := Client.Bottom - W;
                end;
                case Style.Layout of
                    tlTop: Result.X := Client.Right - H;
                    tlCenter: Result.X := (Client.Left + Client.Right - H) div 2;
                    tlBottom: Result.X := Client.Left;
                end;
            end;
        end;
    end;
    
begin
    if Area.IsEmpty then Exit; // not normal or empty

    // glyph size

    Img := nil;
    if OwnerDraw then begin
        if Assigned(GlyphSizeMethod) then
            GlSize := GlyphSizeMethod(Area)
        else
            GlSize := TSize.Zero;
    end
    else begin
        if Images = nil then UseBmp := True
        else UseBmp := (Index < 0) or (Index >= Images.Count);
        if UseBmp then begin
            if (Bitmap = nil) or Bitmap.Empty then begin
                GlSize.cx := 0;
                GlSize.cy := 0;
            end
            else begin
                GlSize.cx := Bitmap.Width;
                GlSize.cy := Bitmap.Height;
            end;
            if (not Enabled) and ((GlSize.cx <> 0) or (GlSize.cy <> 0)) then begin
                Img := TImageList.Create(nil);
                Img.Width := Bitmap.Width;
                Img.Height := Bitmap.Height;
                if Bitmap.Transparent then begin
                    if Bitmap.TransparentMode = tmFixed then
                        Img.AddMasked(Bitmap, Bitmap.TransparentColor)
                    else
                        Img.AddMasked(Bitmap, clDefault);
                end
                else
                    Img.AddMasked(Bitmap, clNone);
            end;
        end
        else begin
            GlSize.cx := Images.Width;
            GlSize.cy := Images.Height;
        end;
    end;

    // style
    
    Style := Format.Style;
    Style.SystemFont := False;
    Style.Clipping := False;
    if Orientation <> vqTextHorizontal then begin
        Style.SingleLine := True;
        Style.Alignment := taLeftJustify;
        Style.Layout := tlTop;
    end;
    PrevFontOrientation := Canvas.Font.Orientation;
    Canvas.Font := Font;
    
    // text rect
    
    TxtRect := Area;
    case Orientation of
        vqTextHorizontal:
            case GlyphLayout of
                blGlyphLeft: Inc(TxtRect.Left, GlSize.cx + Spacing);
                blGlyphTop: Inc(TxtRect.Top, GlSize.cy + Spacing);
                blGlyphRight: Dec(TxtRect.Right, GlSize.cx + Spacing);
                blGlyphBottom: Dec(TxtRect.Bottom, GlSize.cy + Spacing);
            end;
        vqTextVerticalLeft:
            case GlyphLayout of
                blGlyphLeft: Dec(TxtRect.Bottom, GlSize.cy + Spacing);
                blGlyphTop: Inc(TxtRect.Left, GlSize.cx + Spacing);
                blGlyphRight: Inc(TxtRect.Top, GlSize.cy + Spacing);
                blGlyphBottom: Dec(TxtRect.Right, GlSize.cx + Spacing);
            end;
        vqTextVerticalRight:
            case GlyphLayout of
                blGlyphLeft: Inc(TxtRect.Top, GlSize.cy + Spacing);
                blGlyphTop: Dec(TxtRect.Right, GlSize.cx + Spacing);
                blGlyphRight: Dec(TxtRect.Bottom, GlSize.cy + Spacing);
                blGlyphBottom: Inc(TxtRect.Left, GlSize.cx + Spacing);
            end;
    end;
    
    // text size
    
    TxtSize := TextRectExtent(Handle, TxtRect, Text, Style);
    
    // text top left
    
    TxtXY := CaptionPosition(TxtRect, TxtSize.cx, TxtSize.cy);
    
    // glyph rect
    
    case Orientation of
        vqTextHorizontal:
            case GlyphLayout of
                blGlyphLeft: GlRect := Bounds(-GlSize.cx - Spacing, 0, GlSize.cx, TxtSize.cy);
                blGlyphTop: GlRect := Bounds(0, -GlSize.cy - Spacing, TxtSize.cx, GlSize.cy);
                blGlyphRight: GlRect := Bounds(TxtSize.cx + Spacing, 0, GlSize.cx, TxtSize.cy);
                blGlyphBottom: GlRect := Bounds(0, TxtSize.cy + Spacing, TxtSize.cx, GlSize.cy);
            end;
        vqTextVerticalLeft:
            case GlyphLayout of
                blGlyphLeft: GlRect := Bounds(0, TxtSize.cx + Spacing, TxtSize.cy, GlSize.cy);
                blGlyphTop: GlRect := Bounds(-GlSize.cx - Spacing, 0, GlSize.cx, TxtSize.cx);
                blGlyphRight: GlRect := Bounds(0, -GlSize.cy - Spacing, TxtSize.cy, GlSize.cy);
                blGlyphBottom: GlRect := Bounds(0, TxtSize.cy + Spacing, TxtSize.cx, GlSize.cy);
            end;
        vqTextVerticalRight:
            case GlyphLayout of
                blGlyphLeft: GlRect := Bounds(0, -GlSize.cy - Spacing, TxtSize.cy, GlSize.cy);
                blGlyphTop: GlRect := Bounds(TxtSize.cy + Spacing, 0, GlSize.cx, TxtSize.cx);
                blGlyphRight: GlRect := Bounds(0, TxtSize.cx + Spacing, TxtSize.cy, GlSize.cy);
                blGlyphBottom: GlRect := Bounds(- GlSize.cx - Spacing, 0, GlSize.cx, TxtSize.cx);
            end;
    end;
    
    GlRect.Offset(TxtXY.X, TxtXY.Y);
    if Orientation = vqTextHorizontal then
        GlXY := CaptionPosition(GlRect, GlSize.cx, GlSize.cy)
    else
        GLXY := CaptionPosition(GlRect, GlSize.cy, GlSize.cx);
    
    // text origin
    
    case Orientation of
        vqTextHorizontal: TxtXY := TxtXY;
        vqTextVerticalLeft: TxtXY.Y := TxtXY.Y + TxtSize.cx;
        vqTextVerticalRight: TxtXY.X := TxtXY.X + TxtSize.cy;
    end;
    
    // clipping
    
    if Format.Clipping then begin
        DCIndex := WidgetSet.SaveDC(Handle);
        WidgetSet.IntersectClipRect(Handle, Area.Left, Area.Top, Area.Right, Area.Bottom);
    end;
    
    // opaque
    
    if Format.Opaque then begin
        Canvas.FillRect(Area);
        GlSpaced := Bounds(GlXY.X, GlXY.Y, GlSize.cx, GlSize.cy);
        case Orientation of
            vqTextHorizontal:
                case GlyphLayout of
                    blGlyphLeft: Inc(GlSpaced.Right, Spacing);
                    blGlyphTop: Inc(GlSpaced.Bottom, Spacing);
                    blGlyphBottom: Dec(GlSpaced.Top, Spacing);
                    blGlyphRight: Dec(GlSpaced.Left, Spacing);
                end;
            vqTextVerticalLeft: 
                case GlyphLayout of
                    blGlyphLeft: Dec(GlSpaced.Top, Spacing);
                    blGlyphTop: Inc(GlSpaced.Right, Spacing);
                    blGlyphBottom: Dec(GlSpaced.Left, Spacing);
                    blGlyphRight: Inc(GlSpaced.Bottom, Spacing);
                end;
            vqTextVerticalRight: 
                case GlyphLayout of
                    blGlyphLeft: Inc(GlSpaced.Bottom, Spacing);
                    blGlyphTop: Dec(GlSpaced.Left, Spacing);
                    blGlyphBottom: Inc(GlSpaced.Right, Spacing);
                    blGlyphRight: Dec(GlSpaced.Top, Spacing);
                end;
        end;
        Canvas.FillRect(GlSpaced);
    end;
    
    // draw caption

    if not TxtRect.IsEmpty then begin
        if not Enabled then Canvas.Font.Color := DisabledColor;
        case Orientation of
            vqTextHorizontal: begin
                Canvas.Font.Orientation := vqHorzTextLeftToRight;
                Canvas.TextRect(TxtRect, TxtRect.Left, TxtRect.Top, Text, Style);
            end;
            vqTextVerticalLeft: begin
                Canvas.Font.Orientation := vqVertTextDownToUp;
                Canvas.TextRect(TxtRect, TxtXY.X, TxtXY.Y, Text, Style);
            end;
            vqTextVerticalRight: begin
                Canvas.Font.Orientation := vqVertTextUpToDown;
                Canvas.TextRect(TxtRect, TxtXY.X, TxtXY.Y, Text, Style);
            end;
        end;
    end;
    
    // draw glyph
    
    if (GlSize.cx <> 0) or (GlSize.cy <> 0) then begin
        if OwnerDraw then begin
            if Assigned(DrawGlyphMethod) then
                DrawGlyphMethod(Area, Bounds(GlXY.X, GlXY.Y, GlSize.cx, GlSize.cy));
        end
        else if UseBmp then begin
            if Enabled then
                Canvas.Draw(GlXY.X, GlXY.Y, Bitmap)
            else
                Img.Draw(Canvas, GlXY.X, GlXY.Y, 0, gdeDisabled);
        end
        else
            if Enabled  then
                Images.Draw(Canvas, GlXY.X, GlXY.Y, Index, gdeNormal)
            else
                Images.Draw(Canvas, GlXY.X, GlXY.Y, Index, gdeDisabled);
    end;

    // restore
    
    if Format.Clipping then
        WidgetSet.RestoreDC(Handle, DCIndex);
    Canvas.Font.Orientation := PrevFontOrientation;

    if Img <> nil then Img.Free;
end;

procedure TvqCaptionRenderer.Render(const Text: string; Glyph: TvqGlyph; GlyphLayout: TvqGlyphLayout; 
    Enabled: Boolean; Spacing: Integer; Orientation: TvqTextOrientation = vqTextHorizontal);
begin
    Render(Text, Glyph.Glyph, Glyph.Images, Glyph.ImageIndex, GlyphLayout, Enabled,
        Spacing, Orientation);
end;

procedure DrawLineCaption(Canvas: TCanvas; R: TRect; Str: string; 
    Bitmap: TBitmap; Images: TImageList; Index: Integer; 
    Alignment: TAlignment; GlyphLayout: TvqGlyphLayout; Spacing: Integer; Enabled: Boolean;
    DisabledColor: TColor);

var
    Img: TImageList;
    GlSize, TxtSize: TSize;
    GlXY, TxtXY: TPoint;
    TxtRect, GlRect, GlSpaced: TRect;
    UseBmp: Boolean;
    DCIndex: Integer;
    Style: TTextStyle;
    
    function CaptionPosition(Client: TRect; W, H: Integer): TPoint;
    begin
        case Style.Alignment of
            taLeftJustify: Result.X := Client.Left;
            taCenter: Result.X := (Client.Left + Client.Right - W) div 2;
            taRightJustify: Result.X := Client.Right - W;
        end;
        Result.Y := (Client.Top + Client.Bottom - H) div 2;
    end;
    
begin
    if R.IsEmpty then Exit; // not normal or empty
    
    // glyph size
    
    Img := nil;
    if Images = nil then UseBmp := True
    else UseBmp := (Index < 0) or (Index >= Images.Count);
    if UseBmp then begin
        if (Bitmap = nil) or Bitmap.Empty then begin
            GlSize.cx := 0;
            GlSize.cy := 0;
        end
        else begin
            GlSize.cx := Bitmap.Width;
            GlSize.cy := Bitmap.Height;
        end;
        if (not Enabled) and ((GlSize.cx <> 0) or (GlSize.cy <> 0)) then begin
            Img := TImageList.Create(nil);
            Img.Width := Bitmap.Width;
            Img.Height := Bitmap.Height;
            if Bitmap.Transparent then begin
                if Bitmap.TransparentMode = tmFixed then
                    Img.AddMasked(Bitmap, Bitmap.TransparentColor)
                else
                    Img.AddMasked(Bitmap, clDefault);
            end
            else
                Img.AddMasked(Bitmap, clNone);
        end;
    end
    else begin
        GlSize.cx := Images.Width;
        GlSize.cy := Images.Height;
    end;
    
    // style
    
    Style := LineTextStyle;
    Style.Alignment := Alignment;
    Style.Layout := tlCenter;
    Style.SystemFont := False;
    Style.Clipping := False;
    
    // text rect
    
    TxtRect := R;
    case GlyphLayout of
        blGlyphLeft: Inc(TxtRect.Left, GlSize.cx + Spacing);
        blGlyphTop: Inc(TxtRect.Top, GlSize.cy + Spacing);
        blGlyphRight: Dec(TxtRect.Right, GlSize.cx + Spacing);
        blGlyphBottom: Dec(TxtRect.Bottom, GlSize.cy + Spacing);
    end;
    
    // text size
    
    TxtSize := TextRectExtent(Canvas.Handle, TxtRect, Str, Style);
    
    // text top left
    
    TxtXY := CaptionPosition(TxtRect, TxtSize.cx, TxtSize.cy);
    
    // glyph rect
    
    case GlyphLayout of
        blGlyphLeft: GlRect := Bounds(-GlSize.cx - Spacing, 0, GlSize.cx, TxtSize.cy);
        blGlyphTop: GlRect := Bounds(0, -GlSize.cy - Spacing, TxtSize.cx, GlSize.cy);
        blGlyphRight: GlRect := Bounds(TxtSize.cx + Spacing, 0, GlSize.cx, TxtSize.cy);
        blGlyphBottom: GlRect := Bounds(0, TxtSize.cy + Spacing, TxtSize.cx, GlSize.cy);
    end;
    
    GlRect.Offset(TxtXY.Y, TxtXY.Y);
    GlXY := CaptionPosition(GlRect, GlSize.cx, GlSize.cy);
    
    // text origin
    
    TxtXY := TxtXY;
    
    // clipping
    
    DCIndex := WidgetSet.SaveDC(Canvas.Handle);
    WidgetSet.IntersectClipRect(Canvas.Handle, R.Left, R.Top, R.Right, R.Bottom);
    
    // opaque
    
    // draw caption
    
    if not TxtRect.IsEmpty then begin
        if not Enabled then Canvas.Font.Color := DisabledColor;
        Canvas.TextRect(TxtRect, TxtRect.Left, TxtRect.Top, Str, Style);
    end;
    
    // draw glyph
    
    if (GlSize.cx <> 0) or (GlSize.cy <> 0) then begin
        if UseBmp then begin
            if Enabled then
                Canvas.Draw(GlXY.X, GlXY.Y, Bitmap)
            else
                Img.Draw(Canvas, GlXY.X, GlXY.Y, 0, gdeDisabled);
        end
        else
            if Enabled  then
                Images.Draw(Canvas, GlXY.X, GlXY.Y, Index, gdeNormal)
            else
                Images.Draw(Canvas, GlXY.X, GlXY.Y, Index, gdeDisabled);
    end;
    
    // restore
    
    WidgetSet.RestoreDC(Canvas.Handle, DCIndex);
    
    if Img <> nil then Img.Free;
end;


procedure DrawGlyph(Canvas: TCanvas; X, Y: Integer;
    Bitmap: TBitmap; Images: TImageList; Index: Integer;
    Effect: TGraphicsDrawEffect; Alignment: TAlignment; Layout: TTextLayout);
var
    Img: TImageList;
    UseBmp: Boolean;
begin
    if Images = nil then UseBmp := True
    else UseBmp := (Index < 0) or (Index >= Images.Count);
    if UseBmp then begin
        if (Bitmap <> nil) and not Bitmap.Empty then begin
            if Effect = gdeNormal then
                Canvas.Draw(X, Y, Bitmap)
            else begin
                Img := TImageList.Create(nil);
                Img.Width := Bitmap.Width;
                Img.Height := Bitmap.Height;
                if Bitmap.Transparent then begin
                    if Bitmap.TransparentMode = tmFixed then
                        Img.AddMasked(Bitmap, Bitmap.TransparentColor)
                    else
                        Img.AddMasked(Bitmap, clDefault);
                end
                else
                    Img.AddMasked(Bitmap, clNone);
                Img.Draw(Canvas, X, Y, 0, Effect);
                Img.Free;
            end;
        end;
    end
    else
        Images.Draw(Canvas, X, Y, Index, Effect);
end;
