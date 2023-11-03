// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqGraphicsH.inc           }
{ included in vqUtils.pas   }

{ Graphics }
// c, m, y, r, g, b, a: byte 0..255
// h: degree 0_360
// s, l, v: 0_100

function HTMLToColor(S: string): TColor;
function ColorToHtml(Cl: TColor): string;
function HTMLToColorAlpha(S: string; var A: Byte): TColor;
function ColorAlphaToHtml(Cl: TColor; A: Byte): string;

function CMYColor(C, M, Y: Byte): TColor;
function CMYCyan(Cl: TColor): Byte;
function CMYMagenta(Cl: TColor): Byte;
function CMYYellow(Cl: TColor): Byte;
function GetCMY(Cl: TColor; var C, M, Y: Byte): Boolean;
function HSLColor(H, S, L: Double): TColor;
function HSLHue(Cl: TColor): Double;
function HSLSaturation(Cl: TColor): Double;
function HSLLightness(Cl: TColor): Double;
function GetHSL(Cl: TColor; var H, S, L: Double): Boolean;
function HSVColor(H, S, V: Double): TColor;
function HSVHue(Cl: TColor): Double;
function HSVSaturation(Cl: TColor): Double;
function HSVValue(Cl: TColor): Double;
function GetHSV(Cl: TColor; var H, S, V: Double): Boolean;
function RGBColor(R, G, B: Byte): TColor;
function RGBRed(Cl: TColor): Byte;
function RGBGreen(Cl: TColor): Byte;
function RGBBlue(Cl: TColor): Byte;
function GetRGB(Cl: TColor; var R, G, B: Byte): Boolean;
function SetAlpha(Cl: Cardinal; A: Byte): Cardinal;
function GetAlpha(Cl: Cardinal): Byte;

function ByteToUnit(A: Byte): Double;
function SetFloatRGB(R, G, B: Double): TColor;
function GetFloatRGB(Cl: TColor; var R, G, B: Double): Boolean;
function NegativeColor(Cl: TColor): TColor;
function BlackWhiteFromColor(Cl: TColor; Alpha: Byte = 255; Back: TColor = clNone): TColor;
function ColorPairMean(ClA, ClB: TColor): TColor;
function AlphaBlendColor(Background, Foreground: TColor; Alpha: Byte): TColor;
function GradientColor(Start, Stop: TColor; Pos: Double): TColor;
function CalculateDiferentColor256(const C: array of TColor): TColor;
function CalculateDiferentColor2(ALeft, ARight: TColor): TColor;
function TextRectExtent(DC: HDC; R: TRect; const Text: string; Style: TTextStyle): TSize;
function LineTextStyle(ExpandTabs: Boolean = True): TTextStyle;
function TranslucentColor(const Colors: array of TColor): TColor;

const
    vqTranslucentOpacity: array[Boolean] of Byte = (255, 127);
    
    vqHorzTextLeftToRight   = 0;
    vqVertTextDownToUp      = 900;
    vqVertTextUpToDown      = 2700;
    vqHorzTextReversed      = 1800;
    
type
    
    TvqRegion = class
    private
        FHandle: HRGN;
    public
        constructor Create(AHandle: HRGN); overload; virtual;
        constructor Create; overload; virtual;
        constructor CreateRect(ALeft, ATop, ARight, ABottom: Integer); overload;
        constructor CreateRect(R: TRect); overload;
        constructor CreateRoundRect(ALeft, ATop, ARight, ABottom, RX, RY: Integer); overload;
        constructor CreateRoundRect(R: TRect; RX, RY: Integer); overload;
        constructor CreatePolygon(const Points: array of TPoint);
        constructor CreateEllipse(ALeft, ATop, ARight, ABottom: Integer); overload;
        constructor CreateEllipse(R: TRect); overload;
        destructor Destroy; override;
        procedure Combine(var Region: TvqRegion; Mode: TRegionCombineMode; CanDestroy: Boolean = True);
        procedure Offset(DX, DY: Integer);
        function PtInRegion(X, Y: Integer): Boolean;
        function RectInRegion(R: TRect): Boolean;
        function IsEmpty: Boolean;
        property Handle: HRGN read FHandle;
    end;
    
    TvqTextFormat = class(TPersistent)
    private
        FOwner: TControl;
        FOnChange: TNotifyEvent;
        procedure SetAlignment  (Value: TAlignment);
        procedure SetLayout     (Value: TTextLayout);
        procedure SetSingleLine (Value: Boolean);
        procedure SetExpandTabs (Value: Boolean);
        procedure SetShowPrefix (Value: Boolean);
        procedure SetWordBreak  (Value: Boolean);
        procedure SetEndEllipsis(Value: Boolean);
        procedure SetStyle  (Value: TTextStyle);
        procedure SetClipping(Value: Boolean);
        procedure SetOpaque(Value: Boolean);
        procedure SetSystemFont(Value: Boolean);
        function GetClipping: Boolean;
        function GetOpaque: Boolean;
        function GetSystemFont: Boolean;
        function GetAlignment  : TAlignment;
        function GetLayout     : TTextLayout;
        function GetSingleLine : Boolean;
        function GetExpandTabs : Boolean;
        function GetShowPrefix : Boolean;
        function GetWordBreak  : Boolean;
        function GetEndEllipsis: Boolean;
    protected
        FStyle: TTextStyle;
        procedure Change; virtual;
    public
        constructor Create(AOwner: TControl); virtual;
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        property Owner: TControl read FOwner write FOwner;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
        property Style: TTextStyle read FStyle write SetStyle;
        property Clipping: Boolean read GetClipping write SetClipping;
        property Opaque: Boolean read GetOpaque write SetOpaque;
        property SystemFont: Boolean read GetSystemFont write SetSystemFont;
    published
        property Alignment  : TAlignment  read GetAlignment   write SetAlignment   default taLeftJustify;
        property Layout     : TTextLayout read GetLayout      write SetLayout      default tlTop;
        property SingleLine : Boolean     read GetSingleLine  write SetSingleLine  default False;
        property ExpandTabs : Boolean     read GetExpandTabs  write SetExpandTabs  default True;
        property ShowPrefix : Boolean     read GetShowPrefix  write SetShowPrefix  default True;
        property WordBreak  : Boolean     read GetWordBreak   write SetWordBreak   default False;
        property EndEllipsis: Boolean     read GetEndEllipsis write SetEndEllipsis default False;
    end;
    
    TvqGlyph = class(TPersistent)
    private
        FComponent: TComponent;
        FGlyph: TBitmap;
        FImages: TImageList;
        FImageIndex: TImageIndex;
        FImageChangeLink: TChangeLink;
        FOnChange: TNotifyEvent;
        procedure OnGlyphChange(Sender: TObject);
        procedure OnImagesChange(Sender: TObject);
        function GetTransparentGlyph: Boolean;
        procedure SetTransparentGlyph(Value: Boolean);
        procedure SetGlyph(Value: TBitmap);
        procedure SetImages(Value: TImageList);
        procedure SetImageIndex(Value: TImageIndex);
    protected
        procedure Changed; virtual;
    public
        constructor Create(AComponent: TComponent);
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        procedure SetParams(AGlyph: TBitmap; AImages: TImageList; AIndex: TImageIndex);
        function DrawBounds: TRect;
        function UseBitmap: Boolean;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
        property Bitmap: TBitmap read FGlyph write SetGlyph;
    published
        property TransparentGlyph: Boolean read GetTransparentGlyph write SetTransparentGlyph default False;
        property Glyph: TBitmap read FGlyph write SetGlyph;
        property Images: TImageList read FImages write SetImages;
        property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default (-1);
    end;
    
    TvqCanvasHelper = class helper for TCanvas
        procedure FullBrush(AColor: TColor);
        procedure ThinPen(AColor: TColor);
        function RectVisible(const R: TRect): Boolean;
        procedure SelectClipRect(const R: TRect);
        procedure SelectClipRegion(R: TvqRegion);
        
        procedure TextOutHorz(ARect: TRect; AText: string; AAlignment: TAlignment; ALayout: TTextLayout);
        procedure TextOutVertLeft(ARect: TRect; AText: string; AAlignment: TAlignment; ALayout: TTextLayout);
        procedure TextOutVertRight(ARect: TRect; AText: string; AAlignment: TAlignment; ALayout: TTextLayout);
        
        procedure InvertRect(R: TRect);
        procedure ReflectRect(R: TRect; Horizontal: Boolean);
        procedure DotFill(R: TRect);
        procedure TranslucentFill(R: TRect; const Colors: array of TColor);
        procedure Squiggle(R: TRect);
    end;
    
    TvqFontHelper = class helper for TFont
        procedure DoScale(AScale: Double);
    end;
    
    TvqSmoothPainter = class
    private
        Foreground: TColor;
        Background: TColor;
        
        FBitmap: TBGRABitmap;
        FArea: TRect;
        FCanvas: TCanvas;
        
        function GetPixel(X, Y: Integer): TColor;
        function GetPen: TPen;
        function GetBrush: TBrush;
        procedure SetBrush(Value: TBrush);
        procedure SetPen(Value: TPen);
        procedure SetPixel(X, Y: Integer; Value: TColor);
        procedure SetCanvas(Value: TCanvas);
        procedure SetArea(Value: TRect);
        
        procedure BeginDraw;
        procedure EndDraw;
    public
        constructor Create(ACanvas: TCanvas; AArea: TRect); virtual;
        destructor Destroy; override;
        
        procedure ThinPen(Cl: TColor);
        procedure FullBrush(Cl: TColor);
        
        procedure Arc(R: TRect; A1, A2: Double; Clockwise: Boolean = True); overload;
        procedure Arc(O: TPoint; R1, R2: Integer; A1, A2: Double; Clockwise: Boolean = True); overload;
        procedure Arc(X, Y, R1, R2: Double; A1, A2: Double; Clockwise: Boolean = True); overload;
        procedure Chord(R: TRect; A1, A2: Double; Clockwise: Boolean = True); overload;
        procedure Chord(O: TPoint; R1, R2: Integer; A1, A2: Double; Clockwise: Boolean = True); overload;
        procedure Chord(X, Y, R1, R2: Double; A1, A2: Double; Clockwise: Boolean = True); overload;
        procedure Pie(R: TRect; A1, A2: Double; Clockwise: Boolean = True); overload;
        procedure Pie(O: TPoint; R1, R2: Integer; A1, A2: Double; Clockwise: Boolean = True); overload;
        procedure Pie(X, Y, R1, R2: Double; A1, A2: Double; Clockwise: Boolean = True); overload;
        procedure Ellipse(R: TRect); overload;
        procedure Ellipse(O: TPoint; R1, R2: Integer); overload;
        procedure Ellipse(X, Y, R1, R2: Double); overload;
        procedure Line(P, Q: TPoint); overload;
        procedure Line(X1, Y1, X2, Y2: Double); overload;
        procedure Polygon(const Points: array of TPoint);
        procedure Polyline(const Points: array of TPoint);
        procedure PolyBezier(const Points: array of TPoint; Close: Boolean = False);
        procedure Rectangle(R: TRect); overload;
        procedure Rectangle(X1, Y1, X2, Y2: Double); overload;
        procedure RoundRect(R: TRect; RX, RY: Double); overload;
        procedure RoundRect(X1, Y1, X2, Y2, RX, RY: Double); overload;
        procedure Circle(O: TPoint; R: Integer); overload;
        procedure Circle(X, Y, R: Double); overload;
        procedure Star(X1, Y1, X2, Y2: Integer; Down: Boolean = False); overload;
        procedure Star(R: TRect; Down: Boolean = False); overload;
        procedure Hand(O: TPoint; A: Double; Start, Stop: Integer); overload;
        procedure Hand(X, Y: Double; A: Double; Start, Stop: Double); overload;
        
        property Pixel[X, Y: Integer]: TColor read GetPixel write SetPixel;
        property Pen: TPen read GetPen write SetPen;
        property Brush: TBrush read GetBrush write SetBrush;
        property Canvas: TCanvas read FCanvas write SetCanvas;
        property Area: TRect read FArea write SetArea;
        
        function Renderer: string;
    end;
    
    TvqGlyphDrawMethod = procedure (AArea, ARect: TRect) of object;
    TvqGlyphSizeMethod = function (AArea: TRect): TSize of object;
    
    { TvqCaptionRenderer }

    TvqCaptionRenderer = class
    public
        Canvas: TCanvas;
        Font: TFont;
        Format: TvqTextFormat;
        
        DisabledColor: TColor;
        Area: TRect;
        OwnerDraw: Boolean;
        DrawGlyphMethod: TvqGlyphDrawMethod;
        GlyphSizeMethod: TvqGlyphSizeMethod;
        
        constructor Create; virtual;
        
        function GetHandle: HDC;
        function TextExtent(const Text: string; Bitmap: TBitmap;
            Images: TImageList; Index: Integer; GlyphLayout: TvqGlyphLayout;
            Spacing: Integer; Orientation: TvqTextOrientation = vqTextHorizontal): TSize;
        function TextExtent(const Text: string; Glyph: TvqGlyph;
            GlyphLayout: TvqGlyphLayout;
            Spacing: Integer; Orientation: TvqTextOrientation = vqTextHorizontal): TSize;
        procedure Render(const Text: string; Bitmap: TBitmap;
            Images: TImageList; Index: Integer; GlyphLayout: TvqGlyphLayout; 
            Enabled: Boolean; Spacing: Integer; Orientation: TvqTextOrientation = vqTextHorizontal);
        procedure Render(const Text: string; Glyph: TvqGlyph; GlyphLayout: TvqGlyphLayout; 
            Enabled: Boolean; Spacing: Integer; Orientation: TvqTextOrientation = vqTextHorizontal);
        
        property Handle: HDC read GetHandle;
    end;

procedure DrawLineCaption(Canvas: TCanvas; R: TRect; Str: string; 
    Bitmap: TBitmap; Images: TImageList; Index: Integer; 
    Alignment: TAlignment; GlyphLayout: TvqGlyphLayout; Spacing: Integer; Enabled: Boolean;
    DisabledColor: TColor);
    
procedure DrawGlyph(Canvas: TCanvas; X, Y: Integer;
    Bitmap: TBitmap; Images: TImageList; Index: Integer;
    Effect: TGraphicsDrawEffect; Alignment: TAlignment; Layout: TTextLayout);
    







