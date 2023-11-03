// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqColorMap;

interface

uses
    Types, Classes, Graphics, StdCtrls, Math,
    BGRABitmap, BGRACanvas, BGRABitmapTypes,
    vqUtils, vqThemes;

type

    TvqColorModel = (vqcmRGB, vqcmCMY, vqcmHSV, vqcmHSL);
    
    TvqColorElement = (
        vqceAlpha,
        vqceRGBRed,
        vqceRGBGreen,
        vqceRGBBlue,
        vqceCMYCyan,
        vqceCMYMagenta,
        vqceCMYYellow,
        vqceHSVHue,
        vqceHSVSaturation,
        vqceHSVValue,
        vqceHSLHue,
        vqceHSLSaturation,
        vqceHSLLightness);
        
const
    
    ModelOfElement: array [TvqColorElement] of TvqColorModel = (
        vqcmRGB, // undefined for alpha
        vqcmRGB, vqcmRGB, vqcmRGB,
        vqcmCMY, vqcmCMY, vqcmCMY, 
        vqcmHSV, vqcmHSV, vqcmHSV, 
        vqcmHSL, vqcmHSL, vqcmHSL
    );
    
    FirstElementOfModel: array [TvqColorModel] of TvqColorElement = (
        vqceRGBRed,
        vqceCMYCyan,
        vqceHSVHue,
        vqceHSLHue
    );
    
type
    
    TvqModeledColor = class(TPersistent)
    private
        FAlpha: Double;
        FRGBBlue: Double;
        FRGBGreen: Double;
        FRGBRed: Double;
        FHSLHue: Double;
        FHSLSaturation: Double;
        FHSLLightness: Double;
        FHSVHue: Double;
        FHSVSaturation: Double;
        FHSVValue: Double;

        FOnChange: TNotifyEvent;
        FOnChangeHandlers: array of TNotifyEvent;
        FOnChangeHandlersCount: Integer;
        function GetCMYCyan: Double;
        function GetCMYMagenta: Double;
        function GetCMYYellow: Double;
        function GetColor: TColor;
        procedure SetAlpha(Value: Double);
        procedure SetCMYCyan(Value: Double);
        procedure SetCMYMagenta(Value: Double);
        procedure SetCMYYellow(Value: Double);
        procedure SetColor(Value: TColor);
        procedure SetHSLHue(Value: Double);
        procedure SetHSLLightness(Value: Double);
        procedure SetHSLSaturation(Value: Double);
        procedure SetHSVHue(Value: Double);
        procedure SetHSVSaturation(Value: Double);
        procedure SetHSVValue(Value: Double);
        procedure SetRGBBlue(Value: Double);
        procedure SetRGBGreen(Value: Double);
        procedure SetRGBRed(Value: Double);
        
        procedure SynchronizeModels(AChangeModel: TvqColorModel);
        procedure UpdateRoom;
    protected
        procedure Changed;
    public
        constructor Create(AColor: TColor; AAlpha: Double); overload;
        constructor Create; overload;
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        procedure GetRGBA(var R, G, B, A: Byte);
        procedure SetColorAlpha(AColor: TColor; AAlpha: Double);
        procedure SetRGB(R, G, B: Double);
        procedure SetCMY(C, M, Y: Double);
        procedure SetHSV(H, S, V: Double);
        procedure SetHSL(H, S, L: Double);
        function IsTransparentBlack: Boolean;
        procedure AddChangeHandler(AOnChange: TNotifyEvent);
        procedure RemoveChangeHandler(AOnChange: TNotifyEvent);
    published
        property Color: TColor read GetColor write SetColor;
        property Alpha: Double read FAlpha write SetAlpha;
        property RGBRed: Double read FRGBRed write SetRGBRed;
        property RGBGreen: Double read FRGBGreen write SetRGBGreen;
        property RGBBlue: Double read FRGBBlue write SetRGBBlue;
        property CMYCyan: Double read GetCMYCyan write SetCMYCyan;
        property CMYMagenta: Double read GetCMYMagenta write SetCMYMagenta;
        property CMYYellow: Double read GetCMYYellow write SetCMYYellow;
        property HSVHue: Double read FHSVHue write SetHSVHue;
        property HSVSaturation: Double read FHSVSaturation write SetHSVSaturation;
        property HSVValue: Double read FHSVValue write SetHSVValue;
        property HSLHue: Double read FHSLHue write SetHSLHue;
        property HSLSaturation: Double read FHSLSaturation write SetHSLSaturation;
        property HSLLightness: Double read FHSLLightness write SetHSLLightness;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
    end;
    { a: 0-255 }
    { rgb: 0-255 }
    { cmy: 0-255 }
    { hsl: 0-360, 0-100 }
    { hsv: 0-360, 0-100 }
    
    
    TvqCalculateRGBProc = procedure() of object;
    
    TvqColorMapScanner = class(TBGRACustomScanner)
    public
        A, R, G, B, C, M, Y, H, S, L, V: Double;
        CalculateRGB: TvqCalculateRGBProc;
        
        constructor Create(ModelColor: TvqModeledColor; Fixed: Boolean;
            Model: TvqColorModel);
        function ScanAt(X, _Y: Single): TBGRAPixel; override;
        procedure RGB_CalculateRGB;
        procedure CMY_CalculateRGB;
        procedure HSV_CalculateRGB;
        procedure HSL_CalculateRGB;
    end;
    
    TvqColorBarScanner = class(TvqColorMapScanner)
    public
        Width, Height: Integer;
        Value: PDouble;
        ValueMax: Double;
        constructor Create(AWidth, AHeight: Integer; 
            ModelColor: TvqModeledColor; Fixed: Boolean; Model: TvqColorModel;
            Element: TvqColorElement);
        function CalculateCaretColor(Param: Double): TColor;
    end;
    
    TvqColorHorzScanner = class(TvqColorBarScanner)
    public
        function ScanAt(X, _Y: Single): TBGRAPixel; override;
    end;
    
    TvqColorVertScanner = class(TvqColorBarScanner)
    public
        function ScanAt(X, _Y: Single): TBGRAPixel; override;
    end;
    
    TvqColorPanelScanner = class(TvqColorMapScanner)
    public
        Width, Height: Integer;
        ValueX, ValueY: PDouble;
        ValueMaxX, ValueMaxY: Double;
        
        constructor Create(AWidth, AHeight: Integer; 
            ModelColor: TvqModeledColor; Fixed: Boolean; Model: TvqColorModel;
            ElementX, ElementY: TvqColorElement);
        function ScanAt(X, _Y: Single): TBGRAPixel; override;
        function CalculateCaretColor(ParamX, ParamY: Double): TColor;
    end;
    
    TvqColorWheelScanner = class(TvqColorMapScanner)
    public
        Center: TPoint;
        Inner, Outer: Integer;
        Angle: Double;
        constructor Create(ACenter: TPoint;
            AInner, AOuter: Integer; AAngle: Double;
            ModelColor: TvqModeledColor; Fixed: Boolean; Model: TvqColorModel);
        function ScanAt(X, _Y: Single): TBGRAPixel; override;
        function CalculateCaretColor(Param: Double): TColor;
    end;
    
    TvqColorTriangleScanner = class(TBGRACustomScanner)
    public
        H, S, V, R, G, B: Double;
        TriA, TriB, TriC: TDoublePoint;
        Inner: Integer;
        constructor Create(AInner: Integer;
            ATriA, ATriB, ATriC: TDoublePoint; Hue: Double);
        function ScanAt(X, _Y: Single): TBGRAPixel; override;
        function CalculateCaretColor(ParamH, ParamS, ParamV: Double): TColor;
    end;
    
    TvqColorCircleScanner = class(TvqColorMapScanner)
    public
        Center: TPoint;
        Radius: Integer;
        constructor Create(ACenter: TPoint;
            ARadius: Integer;
            ModelColor: TvqModeledColor; Fixed: Boolean; Model: TvqColorModel);
        function ScanAt(X, _Y: Single): TBGRAPixel; override;
        function CalculateCaretColor(ParamH, ParamS: Double): TColor;
    end;
    
    TvqAlphaPatternScanner = class(TBGRACustomScanner)
    public
        Size: Integer;
        White: TBGRAPixel;
        Black: TBGRAPixel;
        constructor Create;
        function ScanAt(X, _Y: Single): TBGRAPixel; override;
    end;
    
function RGBToHSL(RR, GG, BB: Double; var HH, SS, LL: Double): Boolean;
function HSLToRGB(HH, SS, LL: Double; var RR, GG, BB: Double): Boolean;
function RGBToHSV(RR, GG, BB: Double; var HH, SS, VV: Double): Boolean;
function HSVToRGB(HH, SS, VV: Double; var RR, GG, BB: Double): Boolean;
function CMYToRGB(CC, MM, YY: Double; var RR, GG, BB: Double): Boolean;
function RGBToCMY(RR, GG, BB: Double; var CC, MM, YY: Double): Boolean;

procedure RenderHCaret(Bitmap: TBGRABitmap; Height, CaretX, Thickness: Integer; Color: TColor);
procedure RenderVCaret(Bitmap: TBGRABitmap; Width, CaretY, Thickness: Integer; Color: TColor);
procedure RenderDotCaret(Bitmap: TBGRABitmap; CaretX, CaretY, Size, Thickness: Integer; Color: TColor);
procedure RenderHandCaret(Bitmap: TBGRABitmap; Center: TPoint; Angle: Double; Start, Stop: Integer; Thickness: Integer; Color: TColor);
procedure RenderPaletteCaret(Bitmap: TBGRABitmap; Width, Height: Integer; Black, White: TColor);
procedure RenderColorPattern(Bitmap: TBGRABitmap; Width, Height: Integer; Color: TColor; Alpha: Byte; TransparentNone: Boolean);
procedure RenderColorPatternBox(Bitmap: TBGRABitmap; Width, Height: Integer; Color: TColor; Alpha: Byte; TransparentNone: Boolean;
    ABlack: TColor = clBlack; AWhite: TColor = clWhite);

procedure RenderColor(Canvas: TCanvas; R: TRect; Color: TColor; TransparentNone: Boolean);
procedure RenderColorBox(Canvas: TCanvas; R: TRect; Color: TColor; TransparentNone: Boolean);

implementation

function RGBToHSL(RR, GG, BB: Double; var HH, SS, LL: Double): Boolean;
var 
    Mx, Mn, r, g, b, d, h, s, l: Double;
begin
    Result := True;
    
    r := RR/255;
    g := GG/255;
    b := BB/255;
    
    //
    
    Mx := Max3(r, g, b);
    Mn := Min3(r, g, b);
    l := (Mx + Mn)/2;
    if Mx = Mn then begin
        s := 0;
        h := 0;
    end
    else begin
        d := Mx - Mn;
        if l <= 0.5 then s := d/(Mx + Mn)
        else s := d/(2 - Mx - Mn);
        if Mx = r then 
            h := (g - b)/d
        else if Mx = g then
            h := 2 + (b - r)/d
        else if Mx = b then 
            h := 4 + (r - g)/d;
        h := 60*h;
        if h < 0 then h := h + 360;
    end;
    
    //
    
    SS := s*100;
    LL := l*100;
    HH := h;
end;

function HSLToRGB(HH, SS, LL: Double; var RR, GG, BB: Double): Boolean;
var
    sextant: Cardinal;
    l, s, h, r, g, b: Double;
    v, Mn, sv, fract, vsf, mid1, mid2: Double;
begin
    Result := True;
    
    s := SS/100;
    l := LL/100;
    h := HH;
    
    //
    
    if s = 0 then begin
        r := l;
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
                    r := v;
                    g := Mid1;
                    b := Mn;
                end;
                1: begin
                    r := Mid2;
                    g := v;
                    b := Mn;
                end;
                2: begin
                    r := Mn;
                    g := v;
                    b := Mid1;
                end;
                3: begin
                    r := Mn;
                    g := Mid2;
                    b := v;
                end;
                4: begin
                    r := Mid1;
                    g := Mn;
                    b := v;
                end;
                5: begin
                    r := v;
                    g := Mn;
                    b := Mid2;
                end;
            end;
        end;
    end;
    
    // 
    
    RR := r*255;
    GG := g*255;
    BB := b*255;
    
end;

function RGBToHSV(RR, GG, BB: Double; var HH, SS, VV: Double): Boolean;
var
    mx, mn, d, r, g, b, h, s, v: Double;
    
begin
    Result := True;
    
    r := RR/255;
    g := GG/255;
    b := BB/255;
    
    //
    
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
    
    //
    
    SS := s*100;
    VV := v*100;
    HH := h;
end;

function HSVToRGB(HH, SS, VV: Double; var RR, GG, BB: Double): Boolean;
var
    r, g, b, h, s, v: Double;
    
    fr, p, q, t: Double;
    sx: Integer; 
begin
    Result := True;
    
    h := HH;
    s := SS/100;
    v := VV/100;
    
    //
    
    if s = 0 then begin
        r := v;
        g := v;
        b := v;
        Result := False; // is h undefined?
    end
    else begin
        if h = 360 then h := 0
        else h := h/60;
        sx := Floor(h);
        fr := h - sx;
        p := v*(1 - s);
        q := v*(1 - (s*fr));
        t := v*(1 - (s*(1 - fr)));
        case sx of
            0: begin
                r := v;
                g := t;
                b := p;
            end;
            1: begin
                r := q;
                g := v;
                b := p;
            end;
            2: begin
                r := p;
                g := v;
                b := t;
            end;
            3: begin
                r := p;
                g := q;
                b := v;
            end;
            4: begin
                r := t;
                g := p;
                b := v;
            end;
            5: begin
                r := v;
                g := p;
                b := q;
            end;
        end;    
    end;
    
    //
    
    RR := r*255;
    GG := g*255;
    BB := b*255; 
end;

function CMYToRGB(CC, MM, YY: Double; var RR, GG, BB: Double): Boolean;
begin
    Result := True;
    
    RR := 255 - CC;
    GG := 255 - MM;
    BB := 255 - YY;
end;

function RGBToCMY(RR, GG, BB: Double; var CC, MM, YY: Double): Boolean;
begin
    Result := True;
    CC := 255 - RR;
    MM := 255 - GG;
    YY := 255 - BB;
end;

procedure RenderHCaret(Bitmap: TBGRABitmap; Height, CaretX, Thickness: Integer; Color: TColor);
begin
    Bitmap.DrawLineAntialias(CaretX, 0, CaretX, Height, Color, Thickness);
end;

procedure RenderVCaret(Bitmap: TBGRABitmap; Width, CaretY, Thickness: Integer; Color: TColor);
begin
    Bitmap.DrawLineAntialias(0, CaretY, Width, CaretY, Color, Thickness);
end;

procedure RenderDotCaret(Bitmap: TBGRABitmap; CaretX, CaretY, Size, Thickness: Integer; Color: TColor);
begin
    Bitmap.EllipseAntialias(CaretX, CaretY, Size/2, Size/2, Color, Thickness, clNone);
end;

procedure RenderHandCaret(Bitmap: TBGRABitmap; Center: TPoint; Angle: Double; Start, Stop: Integer; Thickness: Integer; Color: TColor);
var
    P, Q: TDoublePoint;
begin
    P := Center + TDoublePoint.CreateNormArg(Start, Angle);
    Q := Center + TDoublePoint.CreateNormArg(Stop, Angle);
    Bitmap.DrawLineAntialias(P.X, P.Y, Q.X, Q.Y, Color, Thickness);
end;

procedure RenderPaletteCaret(Bitmap: TBGRABitmap; Width, Height: Integer; Black, White: TColor);
begin
    Bitmap.RectangleAntialias(0, 0, Width, Height, Black, 1);
    Bitmap.RectangleAntialias(1, 1, Width - 1, Height - 1, White, 1);
end;

procedure RenderColorPattern(Bitmap: TBGRABitmap; Width, Height: Integer; Color: TColor; Alpha: Byte; TransparentNone: Boolean);
const
    NoneBack = clWhite;
    NoneFore = clMaroon;

var
    AlphaScanner: TvqAlphaPatternScanner;
    P: TBGRAPixel;
    R, G, B: Byte;
begin
    if Color = clNone then begin
        if TransparentNone then Exit;
        
        Bitmap.FillRect(0, 0, Width, Height, NoneBack, dmSet);
        Bitmap.DrawLineAntialias(0, 0, Width - 1, Height - 1, NoneFore, 1);
        Bitmap.DrawLineAntialias(0, Height - 1, Width - 1, 0, NoneFore, 1);
    end
    else begin
        if Alpha <> 255 then begin
            AlphaScanner := TvqAlphaPatternScanner.Create;
            Bitmap.FillRect(0, 0, Width, Height, AlphaScanner, dmSet);
            AlphaScanner.Free;
        end;
        Color := ColorToRGB(Color);
        GetRGB(Color, P.red, P.green, P.blue);
        P.alpha := Alpha;
        Bitmap.FillRect(0, 0, Width, Height, P, dmLinearBlend);
    end;
end;

procedure RenderColorPatternBox(Bitmap: TBGRABitmap; Width, Height: Integer; 
    Color: TColor; Alpha: Byte; TransparentNone: Boolean;
    ABlack: TColor = clBlack; AWhite: TColor = clWhite);
begin
    RenderColorPattern(Bitmap, Width, Height, Color, Alpha, TransparentNone);
    Bitmap.RectangleAntialias(0, 0, Width, Height, ABlack, 1, clNone);
    Bitmap.RectangleAntialias(1, 1, Width - 2, Height - 2, AWhite, 1, clNone);
end;

procedure RenderColor(Canvas: TCanvas; R: TRect; Color: TColor; TransparentNone: Boolean);
const
    NoneBack = clWhite;
    NoneFore = clMaroon;

begin
    with Canvas do
    if Color = clNone then begin
        if not TransparentNone then begin
            FullBrush(clWhite);
            FillRect(R);
            
            ThinPen(NoneFore);
            MoveTo(R.TopLeft);
            LineTo(R.BottomRight);
            MoveTo(R.Left, R.Bottom - 1);
            LineTo(R.Right + 1, R.Top - 1);
        end;
    end
    else begin
        Canvas.FullBrush(Color);
        Canvas.FillRect(R);
    end;
end;

procedure RenderColorBox(Canvas: TCanvas; R: TRect; Color: TColor; TransparentNone: Boolean);
begin
    Canvas.Brush.Style := bsClear;
    Canvas.ThinPen(clBlack);
    Canvas.Rectangle(R);
    R.Inflate(-1, -1);
    Canvas.Pen.Color := clWhite;
    Canvas.Rectangle(R);
    R.Inflate(-1, -1);
    RenderColor(Canvas, R, Color, TransparentNone);
end;

procedure Bound100(var A: Double); inline;
begin
    if A < 0 then A := 0
    else if A > 100 then A := 100;
end;

procedure Bound360(var A: Double); inline;
begin
    if A < 0 then A := 0
    else if A > 360 then A := 360;
end;

procedure Bound255(var A: Double); inline;
begin
    if A < 0 then A := 0
    else if A > 255 then A := 255;
end;

{ TvqModeledColor }

constructor TvqModeledColor.Create(AColor: TColor; AAlpha: Double);
begin
    inherited Create;
    SetColorAlpha(AColor, AAlpha);
end;

constructor TvqModeledColor.Create;
begin
    inherited Create;
    // all zero (transparent black)
end;

destructor TvqModeledColor.Destroy;
begin
    FOnChangeHandlers := nil;
    inherited;
end;

procedure TvqModeledColor.Assign(Source: TPersistent);
var
    Other: TvqModeledColor;
begin
    if (Source is TvqModeledColor) and (Source <> Self) then begin
        Other := TvqModeledColor(Source);
        FAlpha          := Other.FAlpha        ;
        FRGBBlue        := Other.FRGBBlue      ;
        FRGBGreen       := Other.FRGBGreen     ;
        FRGBRed         := Other.FRGBRed       ;
        FHSLHue         := Other.FHSLHue       ;
        FHSLSaturation  := Other.FHSLSaturation;
        FHSLLightness   := Other.FHSLLightness ;
        FHSVHue         := Other.FHSVHue       ;
        FHSVSaturation  := Other.FHSVSaturation;
        FHSVValue       := Other.FHSVValue     ;
        Changed;
    end
    else inherited;
end;

procedure TvqModeledColor.UpdateRoom;
var
    L: Integer;
begin
    L := ((FOnChangeHandlersCount div 8) + 1)*8;
    if L <> Length(FOnChangeHandlers) then
        SetLength(FOnChangeHandlers, L);
end;

procedure TvqModeledColor.AddChangeHandler(AOnChange: TNotifyEvent);
begin
    if Assigned(AOnChange) then begin
        UpdateRoom;
        FOnChangeHandlers[FOnChangeHandlersCount] := AOnChange;
        Inc(FOnChangeHandlersCount);
    end;
end;

procedure TvqModeledColor.RemoveChangeHandler(AOnChange: TNotifyEvent);
var
    Index, I: Integer;
begin
    if Assigned(AOnChange) then begin
        Index := 0;
        while (Index < FOnChangeHandlersCount) do begin
            if FOnChangeHandlers[Index] = AOnChange then
                Break;
            Inc(Index);
        end;
        if Index < FOnChangeHandlersCount then begin
            FOnChangeHandlers[Index] := nil;
            for I := Index + 1 to FOnChangeHandlersCount - 1 do
                FOnChangeHandlers[I - 1] := FOnChangeHandlers[I];
            Dec(FOnChangeHandlersCount);
            UpdateRoom;
        end;
    end;
end;

procedure TvqModeledColor.GetRGBA(var R, G, B, A: Byte);
begin
    R := Trunc(RGBRed*255 + 0.5);
    G := Trunc(RGBGreen*255 + 0.5);
    B := Trunc(RGBBlue*255 + 0.5);     
    A := Trunc(Alpha*255 + 0.5);
end;

procedure TvqModeledColor.SetColorAlpha(AColor: TColor; AAlpha: Double);
var 
    R, G, B, A: Byte;
begin
    Bound255(AAlpha);
    if GetRGB(AColor, R, G, B) then
        A := Trunc(AAlpha)
    else begin
        R := 0; G := 0; B := 0; A := 0;
    end;
    if (FRGBRed <> R) or (FRGBGreen <> G) or (FRGBBlue <> B) or (FAlpha <> A) then begin
        FRGBRed := R;
        FRGBGreen := G;
        FRGBBlue := B;
        FAlpha := A;
        
        SynchronizeModels(vqcmRGB);
        Changed;
    end;
end;

procedure TvqModeledColor.SetRGB(R, G, B: Double);
begin
    Bound255(R);
    Bound255(G);
    Bound255(B);
    if (FRGBRed <> R) or (FRGBGreen <> G) or (FRGBBlue <> B) then begin
        FRGBRed := R;
        FRGBGreen := G;
        FRGBBlue := B;
        SynchronizeModels(vqcmRGB);
        Changed;
    end;
end;

procedure TvqModeledColor.SetCMY(C, M, Y: Double);
begin
    Bound255(C);
    Bound255(M);
    Bound255(Y);
    if (CMYCyan <> C) or (CMYMagenta <> M) or (CMYYellow <> Y) then begin
        FRGBRed := 255 - C;
        FRGBGreen := 255 - M;
        FRGBBlue := 255 - Y;
        SynchronizeModels(vqcmCMY);
        Changed;
    end;
end;

procedure TvqModeledColor.SetHSV(H, S, V: Double);
begin
    Bound360(H);
    Bound100(S);
    Bound100(V);
    if (FHSVHue <> H) or (FHSVSaturation <> S) or (FHSVValue <> V) then begin
        FHSVHue := H;
        FHSVSaturation := S;
        FHSVValue := V;
        SynchronizeModels(vqcmHSV);
        Changed;
    end;
end;

procedure TvqModeledColor.SetHSL(H, S, L: Double);
begin
    Bound360(H);
    Bound100(S);
    Bound100(L);
    if (FHSLHue <> H) or (FHSLSaturation <> S) or (FHSLLightness <> L) then begin
        FHSLHue := H;
        FHSLSaturation := S;
        FHSLLightness := L;
        SynchronizeModels(vqcmHSL);
        Changed;
    end;
end;

function TvqModeledColor.IsTransparentBlack: Boolean;
begin
    Result := (FAlpha = 0) and (
        ((FRGBRed = 0) and (RGBGreen = 0) and (RGBBlue = 0)) or
        ((FHSVValue = 0)) or
        ((FHSLLightness = 0))
        );
end;

procedure TvqModeledColor.Changed;
var
    I: Integer;
begin
    if Assigned(FOnChange) then FOnChange(Self);
    for I := 0 to FOnChangeHandlersCount - 1 do
        if Assigned(FOnChangeHandlers[I]) then FOnChangeHandlers[I](Self);
end;

function TvqModeledColor.GetColor: TColor;
var 
    R, G, B: Byte;
begin
    R := Trunc(FRGBRed);
    G := Trunc(FRGBGreen);
    B := Trunc(FRGBBlue);
    Result := RGBColor(R, G, B);
end;

procedure TvqModeledColor.SetColor(Value: TColor);
begin
    SetColorAlpha(Value, FAlpha);
end;

function TvqModeledColor.GetCMYCyan: Double;
begin
    Result := 255 - FRGBRed;
end;

function TvqModeledColor.GetCMYMagenta: Double;
begin
    Result := 255 - FRGBGreen;
end;

function TvqModeledColor.GetCMYYellow: Double;
begin
    Result := 255 - FRGBBlue;
end;

procedure TvqModeledColor.SetAlpha(Value: Double);
begin
    Bound255(Value);
    if FAlpha <> Value then begin
        FAlpha := Value;
        Changed;
    end;
end;

procedure TvqModeledColor.SetCMYCyan(Value: Double);
begin
    Bound255(Value);
    if CMYCyan <> Value then begin
        FRGBRed := 255 - Value;
        SynchronizeModels(vqcmCMY);
        Changed;
    end;
end;

procedure TvqModeledColor.SetCMYMagenta(Value: Double);
begin
    Bound255(Value);
    if CMYMagenta <> Value then begin
        FRGBGreen := 255 - Value;
        SynchronizeModels(vqcmCMY);
        Changed;
    end;
end;

procedure TvqModeledColor.SetCMYYellow(Value: Double);
begin
    Bound255(Value);
    if CMYYellow <> Value then begin
        FRGBBlue := 255 - Value;
        SynchronizeModels(vqcmCMY);
        Changed;
    end;
end;

procedure TvqModeledColor.SetHSLHue(Value: Double);
begin
    Bound360(Value);
    if FHSLHue <> Value then begin
        FHSLHue := Value;
        SynchronizeModels(vqcmHSL);
        Changed;
    end;
end;

procedure TvqModeledColor.SetHSLLightness(Value: Double);
begin
    Bound100(Value);
    if FHSLLightness <> Value then begin
        FHSLLightness := Value;
        SynchronizeModels(vqcmHSL);
        Changed;
    end;
end;

procedure TvqModeledColor.SetHSLSaturation(Value: Double);
begin
    Bound100(Value);
    if FHSLSaturation <> Value then begin
        FHSLSaturation := Value;
        SynchronizeModels(vqcmHSL);
        Changed;
    end;
end;

procedure TvqModeledColor.SetHSVHue(Value: Double);
begin
    Bound360(Value);
    if FHSVHue <> Value then begin
        FHSVHue := Value;
        SynchronizeModels(vqcmHSV);
        Changed;
    end;
end;

procedure TvqModeledColor.SetHSVSaturation(Value: Double);
begin
    Bound100(Value);
    if FHSVSaturation <> Value then begin
        FHSVSaturation := Value;
        SynchronizeModels(vqcmHSV);
        Changed;
    end;
end;

procedure TvqModeledColor.SetHSVValue(Value: Double);
begin
    Bound100(Value);
    if FHSVValue <> Value then begin
        FHSVValue := Value;
        SynchronizeModels(vqcmHSV);
        Changed;
    end;
end;

procedure TvqModeledColor.SetRGBBlue(Value: Double);
begin
    Bound255(Value);
    if FRGBBlue <> Value then begin
        FRGBBlue := Value;
        SynchronizeModels(vqcmRGB);
        Changed;
    end;
end;

procedure TvqModeledColor.SetRGBGreen(Value: Double);
begin
    Bound255(Value);
    if FRGBGreen <> Value then begin
        FRGBGreen := Value;
        SynchronizeModels(vqcmRGB);
        Changed;
    end;
end;

procedure TvqModeledColor.SetRGBRed(Value: Double);
begin
    Bound255(Value);
    if FRGBRed <> Value then begin
        FRGBRed := Value;
        SynchronizeModels(vqcmRGB);
        Changed;
    end;
end;

procedure TvqModeledColor.SynchronizeModels(AChangeModel: TvqColorModel);
begin
    case AChangeModel of
        vqcmRGB: begin
            RGBToHSL(FRGBRed, FRGBGreen, FRGBBlue, FHSLHue, FHSLSaturation, FHSLLightness);
            RGBToHSV(FRGBRed, FRGBGreen, FRGBBlue, FHSVHue, FHSVSaturation, FHSVValue);
        end;
        vqcmCMY: begin
            RGBToHSL(FRGBRed, FRGBGreen, FRGBBlue, FHSLHue, FHSLSaturation, FHSLLightness);
            RGBToHSV(FRGBRed, FRGBGreen, FRGBBlue, FHSVHue, FHSVSaturation, FHSVValue);
        end;
        vqcmHSV: begin
            HSVToRGB(FHSVHue, FHSVSaturation, FHSVValue, FRGBRed, FRGBGreen, FRGBBlue);
            RGBToHSL(FRGBRed, FRGBGreen, FRGBBlue, FHSLHue, FHSLSaturation, FHSLLightness);
        end;
        vqcmHSL: begin
            HSLToRGB(FHSLHue, FHSLSaturation, FHSLLightness, FRGBRed, FRGBGreen, FRGBBlue);
            RGBToHSV(FRGBRed, FRGBGreen, FRGBBlue, FHSVHue, FHSVSaturation, FHSVValue);
        end;
    end;
    
end;

{ TvqColorMapScanner }

constructor TvqColorMapScanner.Create(ModelColor: TvqModeledColor; Fixed: Boolean;
    Model: TvqColorModel);
begin
    A := 255;
    if Fixed or (ModelColor = nil) then begin
        R := 0; G := 0; B := 0; C := 0; M := 0; Y := 0;
        H := 0; S := 100; L := 50; V := 100;
    end
    else begin
        R := ModelColor.RGBRed;
        G := ModelColor.RGBGreen;
        B := ModelColor.RGBBlue;
        C := ModelColor.CMYCyan;
        M := ModelColor.CMYMagenta;
        Y := ModelColor.CMYYellow;
        H := ModelColor.HSVHue;
        S := ModelColor.HSVSaturation;
        V := ModelColor.HSVValue;
        H := ModelColor.HSLHue;
        S := ModelColor.HSLSaturation; 
        L := ModelColor.HSLLightness;
    end;
    
    case Model of
        vqcmRGB: CalculateRGB := @RGB_CalculateRGB;
        vqcmCMY: CalculateRGB := @CMY_CalculateRGB;
        vqcmHSV: CalculateRGB := @HSV_CalculateRGB;
        vqcmHSL: CalculateRGB := @HSL_CalculateRGB;
    end;
    
end;

function TvqColorMapScanner.ScanAt(X, _Y: Single): TBGRAPixel;
begin
end;

procedure TvqColorMapScanner.RGB_CalculateRGB;
begin
    // do nothing
end;

procedure TvqColorMapScanner.CMY_CalculateRGB;
begin
    CMYToRGB(C, M, Y, R, G, B);
end;

procedure TvqColorMapScanner.HSV_CalculateRGB;
begin
    HSVToRGB(H, S, V, R, G, B);
end;

procedure TvqColorMapScanner.HSL_CalculateRGB;
begin
    HSLToRGB(H, S, L, R, G, B);
end;

{ TvqColorBarScanner }

constructor TvqColorBarScanner.Create(AWidth, AHeight: Integer; 
    ModelColor: TvqModeledColor; Fixed: Boolean; Model: TvqColorModel;
    Element: TvqColorElement);
begin
    inherited Create(ModelColor, Fixed, Model);
    Width := AWidth;
    Height := AHeight;
    
    if (Fixed or (ModelColor = nil)) and (Element in [vqceHSVValue, vqceHSLLightness]) then
        S := 0;
    
    // referencing
    
    case Element of
        vqceAlpha         : begin Value := @A; ValueMax := 255; end;
        vqceRGBRed        : begin Value := @R; ValueMax := 255; end;
        vqceRGBGreen      : begin Value := @G; ValueMax := 255; end;
        vqceRGBBlue       : begin Value := @B; ValueMax := 255; end;
        vqceCMYCyan       : begin Value := @C; ValueMax := 255; end;
        vqceCMYMagenta    : begin Value := @M; ValueMax := 255; end;
        vqceCMYYellow     : begin Value := @Y; ValueMax := 255; end;
        vqceHSVHue        : begin Value := @H; ValueMax := 360; end;
        vqceHSVSaturation : begin Value := @S; ValueMax := 100; end;
        vqceHSVValue      : begin Value := @V; ValueMax := 100; end;
        vqceHSLHue        : begin Value := @H; ValueMax := 360; end;
        vqceHSLSaturation : begin Value := @S; ValueMax := 100; end;
        vqceHSLLightness  : begin Value := @L; ValueMax := 100; end;
    end;
end;

function TvqColorBarScanner.CalculateCaretColor(Param: Double): TColor;
begin
    Value^ := Param;
    CalculateRGB();
    Result := BlackWhiteFromColor(RGBToColor(Trunc(R), Trunc(G), Trunc(B)));
end;

{ TvqColorHorzScanner }

function TvqColorHorzScanner.ScanAt(X, _Y: Single): TBGRAPixel;
begin
    if Width <= 1 then Value^ := 0
    else Value^ := X*ValueMax/(Width - 1);
    CalculateRGB();
    with Result do begin
        red := Trunc(R);
        green := Trunc(G);
        blue := Trunc(B);
        alpha := Trunc(A);
    end;
end;

{ TvqColorVertScanner }

function TvqColorVertScanner.ScanAt(X, _Y: Single): TBGRAPixel;
begin
    if Height <= 1 then Value^ := 0
    else Value^ := _Y*ValueMax/(Height - 1);
    CalculateRGB();
    with Result do begin
        red := Trunc(R);
        green := Trunc(G);
        blue := Trunc(B);
        alpha := Trunc(A);
    end;
end;

{ TvqColorPanelScanner }

constructor TvqColorPanelScanner.Create(AWidth, AHeight: Integer; 
    ModelColor: TvqModeledColor; Fixed: Boolean; Model: TvqColorModel;
    ElementX, ElementY: TvqColorElement);
begin
    inherited Create(ModelColor, Fixed, Model);
    Width := AWidth;
    Height := AHeight;
    
    // referencing
    
    case ElementX of
        vqceAlpha         : begin ValueX := @A; ValueMaxX := 255; end;
        vqceRGBRed        : begin ValueX := @R; ValueMaxX := 255; end;
        vqceRGBGreen      : begin ValueX := @G; ValueMaxX := 255; end;
        vqceRGBBlue       : begin ValueX := @B; ValueMaxX := 255; end;
        vqceCMYCyan       : begin ValueX := @C; ValueMaxX := 255; end;
        vqceCMYMagenta    : begin ValueX := @M; ValueMaxX := 255; end;
        vqceCMYYellow     : begin ValueX := @Y; ValueMaxX := 255; end;
        vqceHSVHue        : begin ValueX := @H; ValueMaxX := 360; end;
        vqceHSVSaturation : begin ValueX := @S; ValueMaxX := 100; end;
        vqceHSVValue      : begin ValueX := @V; ValueMaxX := 100; end;
        vqceHSLHue        : begin ValueX := @H; ValueMaxX := 360; end;
        vqceHSLSaturation : begin ValueX := @S; ValueMaxX := 100; end;
        vqceHSLLightness  : begin ValueX := @L; ValueMaxX := 100; end;
    end;
    
    case ElementY of
        vqceAlpha         : begin ValueY := @A; ValueMaxY := 255; end;
        vqceRGBRed        : begin ValueY := @R; ValueMaxY := 255; end;
        vqceRGBGreen      : begin ValueY := @G; ValueMaxY := 255; end;
        vqceRGBBlue       : begin ValueY := @B; ValueMaxY := 255; end;
        vqceCMYCyan       : begin ValueY := @C; ValueMaxY := 255; end;
        vqceCMYMagenta    : begin ValueY := @M; ValueMaxY := 255; end;
        vqceCMYYellow     : begin ValueY := @Y; ValueMaxY := 255; end;
        vqceHSVHue        : begin ValueY := @H; ValueMaxY := 360; end;
        vqceHSVSaturation : begin ValueY := @S; ValueMaxY := 100; end;
        vqceHSVValue      : begin ValueY := @V; ValueMaxY := 100; end;
        vqceHSLHue        : begin ValueY := @H; ValueMaxY := 360; end;
        vqceHSLSaturation : begin ValueY := @S; ValueMaxY := 100; end;
        vqceHSLLightness  : begin ValueY := @L; ValueMaxY := 100; end;
    end;
    
end;

function TvqColorPanelScanner.ScanAt(X, _Y: Single): TBGRAPixel;
begin
    
    if Width <= 1 then ValueX^ := 0
    else ValueX^ := X*ValueMaxX/(Width - 1);
    
    if Height <= 1 then ValueY^ := 0
    else ValueY^ := _Y*ValueMaxY/(Height - 1);
    
    CalculateRGB();
    with Result do begin
        red := Trunc(R);
        green := Trunc(G);
        blue := Trunc(B);
        alpha := 255;
    end;
    
end;

function TvqColorPanelScanner.CalculateCaretColor(ParamX, ParamY: Double): TColor;
begin
    ValueX^ := ParamX;
    ValueY^ := ParamY;
    CalculateRGB();
    Result := BlackWhiteFromColor(RGBToColor(Trunc(R), Trunc(G), Trunc(B)));
end;

{ TvqColorWheelScanner }

constructor TvqColorWheelScanner.Create(ACenter: TPoint;
    AInner, AOuter: Integer; AAngle: Double;
    ModelColor: TvqModeledColor; Fixed: Boolean; Model: TvqColorModel);
begin
    inherited Create(ModelColor, Fixed, vqcmHSV);
    Center := ACenter;
    Inner := AInner;
    Outer := AOuter;
    Angle := AAngle;
end;

function TvqColorWheelScanner.ScanAt(X, _Y: Single): TBGRAPixel;
var        
    Vx, Vy: Double;   
    
begin               
    Vx := X - Center.X;
    Vy := _Y - Center.Y;
    
    if Vy < 0 then H := 180*(2*Pi - ArcTan2(-Vy, Vx))/Pi
    else H := 180*ArcTan2(Vy, Vx)/Pi;
    H := 360 - H;
    
    CalculateRGB();
    with Result do begin
        red := Trunc(R);
        green := Trunc(G);
        blue := Trunc(B);
        alpha := 255;
    end;
end;

function TvqColorWheelScanner.CalculateCaretColor(Param: Double): TColor;
begin
    H := Param;
    CalculateRGB();
    Result := BlackWhiteFromColor(RGBToColor(Trunc(R), Trunc(G), Trunc(B)));
end;

{ TvqColorTriangleScanner }

constructor TvqColorTriangleScanner.Create(AInner: Integer;
    ATriA, ATriB, ATriC: TDoublePoint; Hue: Double);
begin
    H := Hue;
    AInner := Inner;
    TriA := ATriA;
    TriB := ATriB;
    TriC := ATriC;
end;

function TvqColorTriangleScanner.ScanAt(X, _Y: Single): TBGRAPixel;
var
    tH, N, tauN, tauD: Double;
    TriY, P: TDoublePoint;
begin
    
    P := TDoublePoint.Create(X, _Y);
    tH := Inner*3/2; // triangle height
    TriY := (TriA + TriB)/2; // middle point in segment [A, B]
    N := ((P - TriC)*(TriY - TriC))/tH; // proportion for value
    
    V := N/tH; // value in interval [0, 1]
    
    tauN := (X - TriC.X)*(TriB.Y - TriC.Y) - (_Y - TriC.Y)*(TriB.X - TriC.X);
    tauD := (_Y - TriC.Y)*(TriA.X - TriB.X) - (X - TriC.X)*(TriA.Y - TriB.Y);
    if tauD = 0 then S := 0
    else
        S := tauN/tauD; // saturation in interval [0, 1] 
    
    V := V*100; // value in interval [0, 100]
    S := S*100; // saturation in interval [0, 100] 
    
    if V < 0   then V := 0  ;
    if V > 100 then V := 100;
    if S < 0   then S := 0  ;
    if S > 100 then S := 100;
    
    HSVToRGB(H, S, V, R, G, B);
    with Result do begin
        red := Trunc(R);
        green := Trunc(G);
        blue := Trunc(B);
        alpha := 255;
    end;
end;

function TvqColorTriangleScanner.CalculateCaretColor(ParamH, ParamS, ParamV: Double): TColor;
begin
    H := ParamH;
    S := ParamS;
    V := ParamV;
    HSVToRGB(H, S, V, R, G, B);
    Result := BlackWhiteFromColor(RGBToColor(Trunc(R), Trunc(G), Trunc(B)));
end;

{ TvqColorCircleScanner }

constructor TvqColorCircleScanner.Create(ACenter: TPoint;
    ARadius: Integer;
    ModelColor: TvqModeledColor; Fixed: Boolean; Model: TvqColorModel);
begin
    inherited Create(ModelColor, Fixed, Model);
    Center := ACenter;
    Radius := ARadius;
end;

function TvqColorCircleScanner.ScanAt(X, _Y: Single): TBGRAPixel;
var
    Vx, Vy: Double;
begin    
    Vx := X - Center.X;
    Vy := _Y - Center.Y;
    
    if Vy < 0 then H := 180*(2*Pi - ArcTan2(-Vy, Vx))/Pi
    else H := 180*ArcTan2(Vy, Vx)/Pi;
    H := 360 - H;
    
    if Radius = 0 then S := 0
    else S := 100*Sqrt(Vx*Vx + Vy*Vy)/Radius;  
    if S > 100 then S := 100;
    if S < 0   then S := 0  ; 
    
    CalculateRGB();
    with Result do begin
        red := Trunc(R);
        green := Trunc(G);
        blue := Trunc(B);
        alpha := 255;
    end;
    
end;

function TvqColorCircleScanner.CalculateCaretColor(ParamH, ParamS: Double): TColor;
begin
    H := ParamH;
    S := ParamS;
    CalculateRGB();
    Result := BlackWhiteFromColor(RGBToColor(Trunc(R), Trunc(G), Trunc(B)));
end;

{ TvqAlphaPatternScanner }

constructor TvqAlphaPatternScanner.Create;
begin
    Size := vqThemeManager.AlphaSize;
    White := vqThemeManager.AlphaWhite;
    Black := vqThemeManager.AlphaBlack;
    White.alpha := 255;
    Black.alpha := 255;
end;

function TvqAlphaPatternScanner.ScanAt(X, _Y: Single): TBGRAPixel;
var
    A, B: Integer;
begin
    A := Trunc(X) div Size;
    B := Trunc(_Y) div Size;
    if (A mod 2) = (B mod 2) then
        Result := Black
    else
        Result := White;
end;

end.
