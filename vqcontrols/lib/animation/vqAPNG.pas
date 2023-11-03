// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqAPNG;

interface

uses
    SysUtils, Classes, FPImage, FPImgCmn, PNGComn, ZStream, FPReadPNG,
    IntfGraphics, Graphics, StdCtrls, ExtCtrls, Dialogs, DateUtils,
    vqAPNGReader, vqAnimationPlayer,
    BGRABitmap, BGRABitmapTypes, BGRACanvas2D;

type
    
    { TAnimatedPNG }
    
    TAnimatedPNG = class(TPortableNetworkGraphic)
    private
        FBounds: TRect;
        FDefaultImage: TFPCustomImage;
        FAnimated: Boolean; // if is APNG or PNG
        FAnimationControl: TAPNGAnimationControl;
        FDefaultControl: TAPNGFrameControl;
        FAnimateDefault: Boolean;
        FFrameImages: array of TFPCustomImage;
        FFrameControls: array of TAPNGFrameControl;
        procedure ClearFrames;
        function GetFrameCount: Integer;
        function GetPlayCount: Integer;
        function GetFrameImage(Index: Integer): TFPCustomImage;
        function GetFrameControl(Index: Integer): TAPNGFrameControl;
    protected
        procedure InitializeReader(AImage: TLazIntfImage; AReader: TFPCustomImageReader); override;
        procedure FinalizeReader(AReader: TFPCustomImageReader); override;
        class function GetReaderClass: TFPCustomImageReaderClass; override;
        procedure Changed(Sender: TObject); override;
    public
        constructor Create; override;
        destructor Destroy; override; 
        class function GetFileExtensions: string; override;
                                   
        procedure Assign(Source: TPersistent); override;
        procedure Clear; override;
        procedure FreeImage; override; 
    protected
        property AnimationControl: TAPNGAnimationControl read FAnimationControl;
        property DefaultControl: TAPNGFrameControl read FDefaultControl;
        property FrameControl[Index: Integer]: TAPNGFrameControl read GetFrameControl;
        
    public
        property Bounds: TRect read FBounds;
        property Animated: Boolean read FAnimated;
        property AnimateDefault: Boolean read FAnimateDefault;
        property FrameCount: Integer read GetFrameCount;
        property PlayCount: Integer read GetPlayCount;
        property FrameImage[Index: Integer]: TFPCustomImage read GetFrameImage;
    end;
    
    TAnimatedPNGRenderer = class(TAnimationPlayer)
    private
        FPlayStep: Integer;
        FStep: Integer;
        FBackCache: TBGRABitmap;
        FBackBmp: TBGRABitmap;
        FDisposeFrame: Byte;
        FResidualTime: Double;
        
        FAPNG: TAnimatedPNG;
        
        procedure SetPlayStep(Value: Integer);
        procedure SetAPNG(Value: TAnimatedPNG); 
        
    protected
        procedure SetPosition(APlayStep, AStep: Integer); virtual;
        procedure APNGChanged; virtual;
        procedure Refresh(ABmp: TBGRABitmap; ACanvas: TCanvas; ARect: TRect); virtual;
        procedure Restart; virtual; 
    protected
        
        function GetStep: Integer; override;
        procedure SetStep(Value: Integer); override;
        
    public
        constructor Create(AGraphic: TGraphic); override;
        destructor Destroy; override;
        
        function ReadFrame(var AImage: TFPCustomImage; var ABounds: TRect; var ADisposeOp, ABlendOp: Byte; 
            var AInterval: Cardinal): Boolean;
        function RenderFrame(ARefresh: Boolean; ACanvas: TCanvas; ARect: TRect; ATimer: TTimer): Boolean;
        function ReadAndRenderFrame(ARefresh: Boolean;
            var AImage: TFPCustomImage; var ABounds: TRect; var ADisposeOp, ABlendOp: Byte; var AInterval: Cardinal;
            ACanvas: TCanvas; ARect: TRect; ATimer: TTimer): Boolean;
        function RenderDefault(ACanvas: TCanvas; ARect: TRect): Boolean;
        
        property PlayStep: Integer read FPlayStep write SetPlayStep;
        property APNG: TAnimatedPNG read FAPNG write SetAPNG;
    end;
    
    TAnimatedPNGPlayer = class(TAnimatedPNGRenderer)
    private
        FTimer: TTimer;
        FPlaying: Boolean;
        FPaused: Boolean;
        FArea: TRect;
        FCanvas: TCanvas;
        
        function GetFrame(Index: Integer): TFPCustomImage;
        function GetFrameCount: Integer;
        function GetPlayCount: Integer;
        function GetAnimated: Boolean;
        function GetLocation: TPoint;
        function GetSize: TSize;
        procedure SetLocation(Value: TPoint);
        procedure SetSize(Value: TSize);
        
    protected
        procedure SetPosition(APlayStep, AStep: Integer); override;
        procedure APNGChanged; override;
        procedure Refresh(ABmp: TBGRABitmap; ACanvas: TCanvas; ARect: TRect); override;
        procedure Restart; override;
        procedure OnTimer(Sender: TObject);
    protected
        
        function GetArea: TRect; override;
        function GetCanvas: TCanvas; override;
        procedure SetArea(Value: TRect); override;
        procedure SetCanvas(Value: TCanvas); override;
    protected
        function GetPausable: Boolean; override;
        function GetPaused  : Boolean; override;
        function GetPlayable: Boolean; override;
        function GetPlaying : Boolean; override;
        
    public
        constructor Create(AGraphic: TGraphic); override;
        destructor Destroy; override;
        
        procedure Play; override;
        procedure Stop; override;
        procedure Pause; override;
        procedure Resume; override;
        procedure NextFrame; override;
        procedure Erase; override;
        
        property Frame[Index: Integer]: TFPCustomImage read GetFrame;
        property FrameCount: Integer read GetFrameCount;
        property PlayCount: Integer read GetPlayCount;
        property Animated: Boolean read GetAnimated;
        property Location: TPoint read GetLocation write SetLocation;
        property Size: TSize read GetSize write SetSize;
    end;
    
implementation

constructor TAnimatedPNG.Create;
begin
    inherited Create;
    FAnimated := False;
    FAnimateDefault := False;
    FFrameImages := nil;
    FFrameControls := nil;
    FDefaultImage := nil;
    FBounds := TRect.Empty;
end;

destructor TAnimatedPNG.Destroy;
begin
    ClearFrames;
    inherited;
end;

procedure TAnimatedPNG.ClearFrames;
var
    I: Integer;
begin
    for I := 0 to Length(FFrameImages) - 1 do
        FFrameImages[I].Free;
    FFrameImages := nil;
    FFrameControls := nil; 
    if FDefaultImage <> nil then 
        FDefaultImage.Free;
    FDefaultImage := nil;     
    FBounds := TRect.Empty;
end;

class function TAnimatedPNG.GetReaderClass: TFPCustomImageReaderClass;
begin
    Result := TAPNGReader;
end;

class function TAnimatedPNG.GetFileExtensions: string;
begin
    Result := 'png;apng';
end;

procedure TAnimatedPNG.Assign(Source: TPersistent);
var
    Other: TAnimatedPNG;
    I, L: Integer;
begin
    inherited Assign(Source);
    ClearFrames;
    if Source is TAnimatedPNG then begin  
        Other := TAnimatedPNG(Source);
        FAnimated := Other.FAnimated;
        FAnimationControl := Other.FAnimationControl;
        FDefaultControl := Other.FDefaultControl;
        FAnimateDefault := Other.FAnimateDefault;
        L := Length(Other.FFrameImages); 
        SetLength(FFrameImages, L);    
        SetLength(FFrameControls, L);  
        for I := 0 to L - 1 do begin
            FFrameImages[I] := TLazIntfImage.Create(0, 0, []);
            FFrameImages[I].Assign(Other.FFrameImages[I]);
            FFrameControls[I] := Other.FFrameControls[I];
        end;                                   
    end;
end;

procedure TAnimatedPNG.Clear;
begin
    inherited Clear;
    ClearFrames;
end;

procedure TAnimatedPNG.FreeImage;
begin
    inherited FreeImage;
end;

procedure TAnimatedPNG.InitializeReader(AImage: TLazIntfImage; AReader: TFPCustomImageReader);
begin
    ClearFrames;
    inherited;
end;

procedure TAnimatedPNG.FinalizeReader(AReader: TFPCustomImageReader);
var
    L, I: Integer;
begin
    inherited;        
    with TAPNGReader(AReader) do begin
        FAnimated := IsAPNG;
        FAnimationControl := AnimationControl;
        FDefaultControl := DefaultFrameControl;
        FAnimateDefault := AnimateDefault;
        if FAnimated then begin                    
            SetLength(FFrameControls, FrameArrayLength);
            SetLength(FFrameImages, FrameArrayLength);
            for I := 0 to FrameArrayLength - 1 do begin
                FFrameControls[I] := FrameArray[I].Control;
                FFrameImages[I] := FrameArray[I].Image;
                FrameArray[I].Image := nil;
            end;
        end
        else begin
            FFrameControls := nil;
            FFrameImages := nil;
        end;              
    end;                     
end;

function TAnimatedPNG.GetFrameCount: Integer;
begin
    Result := FAnimationControl.FrameCount;
end;

function TAnimatedPNG.GetPlayCount: Integer;
begin
    Result := FAnimationControl.PlayCount;
end;

function TAnimatedPNG.GetFrameImage(Index: Integer): TFPCustomImage;
begin                 
    if (Index >= 0) and (Index < FrameCount) then begin
        if FAnimateDefault then begin
            if Index = 0 then begin
                if FDefaultImage = nil then 
                    FDefaultImage := CreateIntfImage;
                Result := FDefaultImage;
            end 
            else
                Result := FFrameImages[Index - 1];
        end
        else
            Result := FFrameImages[Index];
    end
    else   
        Result := nil;    
end;

function TAnimatedPNG.GetFrameControl(Index: Integer): TAPNGFrameControl;
begin     
    if (Index >= 0) and (Index < FrameCount) then begin
        if FAnimateDefault then begin
            if Index = 0 then
                Result := FDefaultControl
            else
                Result := FFrameControls[Index - 1];
        end
        else
            Result := FFrameControls[Index];
    end
    else
        Result := FDefaultControl;    
end;

procedure TAnimatedPNG.Changed(Sender: TObject);
begin
    if FDefaultImage <> nil then
        FDefaultImage.Free;
    FDefaultImage := nil;     
    FBounds := Rect(0, 0, Width, Height);
    
end;

{ TAnimatedPNGRenderer }

constructor TAnimatedPNGRenderer.Create(AGraphic: TGraphic);
begin
    inherited Create(AGraphic);
    FStep := -1;
    FPlayStep := -1;
    if AGraphic is TAnimatedPNG then
        FAPNG := TAnimatedPNG(AGraphic)
    else
        FAPNG := nil;
    FBackBmp := nil;
    FBackCache := nil;
    FDisposeFrame := APNG_DISPOSE_OP_BACKGROUND;
    FResidualTime := 0;
end;

destructor TAnimatedPNGRenderer.Destroy;
begin
    FAPNG := nil;
    if FBackBmp <> nil then FBackBmp.Free;
    if FBackCache <> nil then FBackCache.Free;
    inherited;
end;

function TAnimatedPNGRenderer.ReadFrame(var AImage: TFPCustomImage; var ABounds: TRect;
    var ADisposeOp, ABlendOp: Byte; var AInterval: Cardinal): Boolean;
var
    Miliseconds: Double;
begin
    Result := False;
    if (FAPNG <> nil) and FAPNG.Animated then begin
        if FPlayStep = -1 then FPlayStep := 0;
        Inc(FStep);
        if FStep = FAPNG.FrameCount then begin
            FStep := 0;
            if FAPNG.PlayCount > 0 then begin
                Inc(FPlayStep);
                if FPlayStep = FAPNG.PlayCount then
                    Exit;
            end;
        end;
        AImage := FAPNG.FrameImage[FStep];
        with FAPNG.FrameControl[FStep] do begin
            ABounds := Classes.Bounds(XOffset, YOffset, Width, Height);
            if FStep = FAPNG.FrameCount - 1 then
                ADisposeOp := APNG_DISPOSE_OP_BACKGROUND
            else
                ADisposeOp := DisposalOperator;
            if FStep = 0 then
                ABlendOp := APNG_BLEND_OP_SOURCE
            else
                ABlendOp := BlendOperator;
            if DelayDenominator = 0 then
                Miliseconds := (1000*1)/100
            else
                Miliseconds := (1000*DelayNumerator)/DelayDenominator;
            //# slow animation, try to use DateTime or quit debugging code                 
            AInterval := Trunc(Miliseconds{ + FResidualTime});
            {FResidualTime := Frac(Miliseconds + FResidualTime);}
        end;                               
        Result := True;
    end;
end;

function TAnimatedPNGRenderer.RenderFrame(ARefresh: Boolean; ACanvas: TCanvas; ARect: TRect; ATimer: TTimer): Boolean;
var
    AImage: TFPCustomImage;
    ABounds: TRect;
    ADisposeOp, ABlendOp: Byte;
    AInterval: Cardinal;
begin
    Result := ReadAndRenderFrame(ARefresh, AImage, ABounds, ADisposeOp, ABlendOp, AInterval,
        ACanvas, ARect, ATimer);
    AImage := nil;
end;

function TAnimatedPNGRenderer.ReadAndRenderFrame(ARefresh: Boolean;
    var AImage: TFPCustomImage; var ABounds: TRect; var ADisposeOp, ABlendOp: Byte; var AInterval: Cardinal;
    ACanvas: TCanvas; ARect: TRect; ATimer: TTimer): Boolean;
var
    BGRAImg: TBGRABitmap;  
begin    
    Result := False;
    if ReadFrame(AImage, ABounds, ADisposeOp, ABlendOp, AInterval) then begin
        if FBackBmp = nil then 
            FBackBmp := TBGRABitmap.Create(FAPNG.Width, FAPNG.Height, clNone);
        case FDisposeFrame of
            APNG_DISPOSE_OP_NONE: ;
            APNG_DISPOSE_OP_BACKGROUND: 
                FBackBmp.Fill(clNone);
            APNG_DISPOSE_OP_PREVIOUS:
                FBackBmp.StretchPutImage(FAPNG.Bounds, FBackCache, dmSet);
        end;
        FDisposeFrame := ADisposeOp;
        if FDisposeFrame = APNG_DISPOSE_OP_PREVIOUS then begin
            if FBackCache = nil then 
                FBackCache := TBGRABitmap.Create(FAPNG.Width, FAPNG.Height, clNone);
            FBackCache.StretchPutImage(FAPNG.Bounds, FBackBmp, dmSet);
        end;
        ATimer.Interval := AInterval;
        
        BGRAImg := TBGRABitmap.Create(AImage);
        try                                  
            case ABlendOp of
                APNG_BLEND_OP_OVER: FBackBmp.StretchPutImage(ABounds, BGRAImg, dmLinearBlend);
                APNG_BLEND_OP_SOURCE: FBackBmp.StretchPutImage(ABounds, BGRAImg, dmSet);
            end;        
            if ARefresh then
                Refresh(FBackBmp, ACanvas, ARect);  
        finally
            BGRAImg.Free;
        end;                              
        
        Result := True;
    end;                                                                  
end;

procedure TAnimatedPNGRenderer.Refresh(ABmp: TBGRABitmap; ACanvas: TCanvas; ARect: TRect);
begin
    if (ABmp <> nil) and (ACanvas <> nil) then 
        ABmp.Draw(ACanvas, ARect, False);
end;

procedure TAnimatedPNGRenderer.Restart;
begin
    if FBackBmp <> nil then FreeAndNil(FBackBmp);
    if FBackCache <> nil then FreeAndNil(FBackCache);
    FDisposeFrame := APNG_DISPOSE_OP_BACKGROUND;
    FResidualTime := 0;
    FPlayStep := -1;
    FStep := -1;
end;

procedure TAnimatedPNGRenderer.APNGChanged;
begin
end;

function TAnimatedPNGRenderer.RenderDefault(ACanvas: TCanvas; ARect: TRect): Boolean;
begin
    Result := False;
    if (ACanvas <> nil) and (FAPNG <> nil) then begin
        ACanvas.StretchDraw(ARect, FAPNG);
        Result := True;
    end;
end;

function TAnimatedPNGRenderer.GetStep: Integer;
begin
    Result := FStep;
end;

procedure TAnimatedPNGRenderer.SetPlayStep(Value: Integer);
begin
    SetPosition(Value, FStep);
end;

procedure TAnimatedPNGRenderer.SetStep(Value: Integer);
begin
    SetPosition(FPlayStep, Value);
end;

procedure TAnimatedPNGRenderer.SetAPNG(Value: TAnimatedPNG);
begin   
    if FAPNG <> Value then begin
        FAPNG := Value;
        APNGChanged;
    end;
end;

procedure TAnimatedPNGRenderer.SetPosition(APlayStep, AStep: Integer);
begin
end;

{ TAnimatedPNGPlayer }

constructor TAnimatedPNGPlayer.Create(AGraphic: TGraphic);
begin
    inherited Create(AGraphic);
    FTimer := TTimer.Create(nil);
    FTimer.Enabled := False;
    FTimer.OnTimer := @OnTimer;
    FPlaying := False;
    FPaused := False;
    FArea := TRect.Empty;
    FCanvas := nil;            
end;

destructor TAnimatedPNGPlayer.Destroy;
begin
    FTimer.Free;
    inherited;
end;

procedure TAnimatedPNGPlayer.Restart;
begin
    Stop;
    inherited;
end;

procedure TAnimatedPNGPlayer.Refresh(ABmp: TBGRABitmap; ACanvas: TCanvas; ARect: TRect);
begin
    if Assigned(FOnRefresh) then
        if FOnRefresh(Self, ABmp, ACanvas, ARect) then
            begin end
        else
            inherited
    else
        inherited;
end;

procedure TAnimatedPNGPlayer.APNGChanged;
begin
    FTimer.Enabled := False;
    Restart;
end;

procedure TAnimatedPNGPlayer.OnTimer(Sender: TObject);
begin
    if RenderFrame(True, FCanvas, FArea, FTimer) then 
        DoFrameRendered;
end;

procedure TAnimatedPNGPlayer.SetPosition(APlayStep, AStep: Integer);
var               
    PrevTimerEnabled: Boolean;
begin
    if (APlayStep < -1) or (APlayStep >= PlayCount) then 
        Exit;
    if (AStep < -1) or (AStep >= FrameCount) then 
        Exit;
    if (FAPNG <> nil) and FAPNG.Animated then begin
        PrevTimerEnabled := FTimer.Enabled;
        FTimer.Enabled := False;
        
        if (APlayStep = -1) or (AStep = -1) then
            Restart
        else begin
            FPlayStep := APlayStep;
            FStep := -1;
            // composite until step
            while FStep < AStep do
                RenderFrame(False, FCanvas, FArea, FTimer);
            Refresh(FBackBmp, FCanvas, FArea);
            DoFrameRendered;
            // --
        end;
        
        FTimer.Enabled := PrevTimerEnabled;
    end;
end;

function TAnimatedPNGPlayer.GetPausable: Boolean;
begin
    Result := (APNG <> nil) and APNG.Animated and FPlaying and (not FPaused);
end;

function TAnimatedPNGPlayer.GetPaused: Boolean;
begin
    Result := FPaused;
end;

function TAnimatedPNGPlayer.GetPlayable: Boolean;
begin
    Result := (APNG <> nil) and APNG.Animated and (not FPlaying);
end;

function TAnimatedPNGPlayer.GetPlaying: Boolean;
begin
    Result := FPlaying;
end;

procedure TAnimatedPNGPlayer.Play;
begin
    if Playable then begin   
        FPlaying := True;
        FPaused := False;
        DoPlaying;
        if RenderFrame(True, FCanvas, FArea, FTimer) then
            DoFrameRendered;
        FTimer.Enabled := True;
    end;
end;

procedure TAnimatedPNGPlayer.Stop;
begin
    if FPlaying then begin
        FTimer.Enabled := False;
        FPlaying := False;
        FPaused := False;
        RenderDefault(FCanvas, FArea);
        DoStop;
    end;
end;

procedure TAnimatedPNGPlayer.Pause;
begin
    if Pausable then begin
        FTimer.Enabled := False;
        FPaused := True;
        DoPause;
    end;
end;

procedure TAnimatedPNGPlayer.Resume;
begin
    if FPlaying and FPaused then begin
        FPaused := False;
        FTimer.Enabled := True;
        DoResume;
    end;
end;

procedure TAnimatedPNGPlayer.NextFrame;
var
    PrevTimerEnabled:  Boolean;
begin
    if Animated then begin
        PrevTimerEnabled := FTimer.Enabled;
        FTimer.Enabled := False;
        if RenderFrame(True, FCanvas, FArea, FTimer) then
            DoFrameRendered;
        FTimer.Enabled := PrevTimerEnabled;
    end;
end;

procedure TAnimatedPNGPlayer.Erase;
begin
    DoErase;
end;

function TAnimatedPNGPlayer.GetFrame(Index: Integer): TFPCustomImage;
begin
    if APNG <> nil then Result := APNG.FrameImage[Index]
    else Result := nil;
end;

function TAnimatedPNGPlayer.GetFrameCount: Integer;
begin
    if APNG <> nil then Result := APNG.FrameCount
    else Result := 0;
end;

function TAnimatedPNGPlayer.GetPlayCount: Integer;
begin
    if APNG <> nil then Result := APNG.PlayCount
    else Result := 0;
end;

function TAnimatedPNGPlayer.GetAnimated: Boolean;
begin
    if APNG <> nil then
        Result := APNG.Animated
    else
        Result := False;
end;

function TAnimatedPNGPlayer.GetLocation: TPoint;
begin
    Result := FArea.TopLeft;
end;

function TAnimatedPNGPlayer.GetSize: TSize;
begin
    Result := FArea.Size;
end;

procedure TAnimatedPNGPlayer.SetLocation(Value: TPoint);
begin
    SetArea(Rect(Value.X, Value.Y, Size.cx, Size.cy));
end;

procedure TAnimatedPNGPlayer.SetSize(Value: TSize);
begin
    SetArea(Rect(Location.X, Location.Y, Value.cx, Value.cy));
end;

function TAnimatedPNGPlayer.GetArea: TRect;
begin
    Result := FArea;
end;

procedure TAnimatedPNGPlayer.SetArea(Value: TRect);
var
    PrevTimerEnabled: Boolean;
begin
    if FArea <> Value then begin
        PrevTimerEnabled := FTimer.Enabled;
        FTimer.Enabled := False;
        
        Erase;
        FArea := Value;
        Refresh(FBackBmp, FCanvas, FArea);
        
        FTimer.Enabled := PrevTimerEnabled;
    end;
end;

function TAnimatedPNGPlayer.GetCanvas: TCanvas;
begin
    Result := FCanvas;
end;

procedure TAnimatedPNGPlayer.SetCanvas(Value: TCanvas);
begin
    if FCanvas <> Value then begin
        FCanvas := Value;
        Refresh(FBackBmp, FCanvas, FArea);
    end;
end;

end.
