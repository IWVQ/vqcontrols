// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqAnimatedImages;

interface

uses
    SysUtils, Classes, FPImage,
    IntfGraphics, GraphType, Graphics, StdCtrls, Dialogs, ImgList, Controls,
    ExtCtrls,
    vqUtils, vqAnimationPlayer;

type

    TAnimatedImagesPlayer = class(TAnimationPlayer)
    private
        FStep: Integer;
        FImages: TImageList;
        FInterval: Cardinal;
        FTimer: TTimer;
        FPlaying: Boolean;
        FPaused: Boolean;
        FArea: TRect;
        FCanvas: TCanvas;
        procedure SetImages(Value: TImageList);
    protected
        procedure RenderFrame(ARefresh: Boolean);
        procedure RenderDefault;
        procedure Refresh(ACanvas: TCanvas; ARect: TRect);
        procedure Restart;
        procedure OnTimer(Sender: TObject);
    protected
        function GetFrameCount: Integer;
        
        function GetStep: Integer; override;
        function GetArea: TRect; override;
        function GetCanvas: TCanvas; override;
        function GetPausable: Boolean; override;
        function GetPaused  : Boolean; override;
        function GetPlayable: Boolean; override;
        function GetPlaying : Boolean; override;
        procedure SetStep(Value: Integer); override;
        procedure SetArea(Value: TRect); override;
        procedure SetCanvas(Value: TCanvas); override;
    public
        constructor Create(AImages: TImageList); virtual;
        destructor Destroy; override;
        
        procedure Play; override;
        procedure Stop; override;
        procedure Pause; override;
        procedure Resume; override;
        procedure NextFrame; override;
        procedure Erase; override;
        
        property FrameCount: Integer read GetFrameCount;
        property Interval: Cardinal read FInterval write FInterval;
        property Images: TImageList read FImages write SetImages;
    end;
    
implementation

{ TAnimatedImagesPlayer }

constructor TAnimatedImagesPlayer.Create(AImages: TImageList);
begin
    inherited Create(nil);
    FStep := -1;
    FImages := AImages;
    FInterval := 100;
    FTimer := TTimer.Create(nil);
    FTimer.Enabled := False;
    FTimer.OnTimer := @OnTimer;
    FPlaying := False;
    FPaused := False;
    FArea := TRect.Empty;
    FCanvas := nil;
end;

destructor TAnimatedImagesPlayer.Destroy;
begin
    FImages := nil;
    FTimer.Free;
    inherited;
end;

function TAnimatedImagesPlayer.GetStep: Integer;
begin
    Result := FStep;
end;

function TAnimatedImagesPlayer.GetArea: TRect;
begin
    Result := FArea;
end;

function TAnimatedImagesPlayer.GetCanvas: TCanvas;
begin
    Result := FCanvas;
end;

function TAnimatedImagesPlayer.GetPausable: Boolean;
begin
    Result := (FImages <> nil) and FPlaying and (not FPaused);
end;

function TAnimatedImagesPlayer.GetPaused  : Boolean;
begin
    Result := FPaused;
end;

function TAnimatedImagesPlayer.GetPlayable: Boolean;
begin
    Result := (FImages <> nil) and (not FPlaying);
end;

function TAnimatedImagesPlayer.GetPlaying : Boolean;
begin
    Result := FPlaying;
end;

procedure TAnimatedImagesPlayer.Play;
begin
    if Playable then begin
        FPlaying := True;
        FPaused := False;
        DoPlaying;
        RenderFrame(True);
        FTimer.Interval := FInterval;
        FTimer.Enabled := True;
    end;
end;

procedure TAnimatedImagesPlayer.Stop;
begin
    if FPlaying then begin
        FTimer.Enabled := False;
        FPlaying := False;
        FPaused := False;
        RenderDefault;
        DoStop;
    end;
end;

procedure TAnimatedImagesPlayer.Pause;
begin
    if Pausable then begin
        FTimer.Enabled := False;
        FPaused := True;
        DoPause;
    end;
end;

procedure TAnimatedImagesPlayer.Resume;
begin
    if FPlaying and FPaused then begin
        FPaused := False;
        FTimer.Enabled := True;
        DoResume;
    end;
end;

procedure TAnimatedImagesPlayer.NextFrame;
var
    PrevTimerEnabled:  Boolean;
begin
    if {Animated} True then begin
        PrevTimerEnabled := FTimer.Enabled;
        FTimer.Enabled := False;
        RenderFrame(True);
        FTimer.Enabled := PrevTimerEnabled;
    end;
end;

procedure TAnimatedImagesPlayer.Erase;
begin
    DoErase;
end;

function TAnimatedImagesPlayer.GetFrameCount: Integer;
begin
    if FImages <> nil then
        Result := FImages.Count
    else
        Result := 0;
end;

procedure TAnimatedImagesPlayer.SetStep(Value: Integer);
begin
    if Value <> FStep then begin
        if Value < 0 then
            Restart
        else begin
            FStep := Value - 1;
            RenderFrame(True);
        end;
    end;
end;

procedure TAnimatedImagesPlayer.SetArea(Value: TRect);
var
    PrevTimerEnabled: Boolean;
begin
    if FArea <> Value then begin
        PrevTimerEnabled := FTimer.Enabled;
        FTimer.Enabled := False;
        
        Erase;
        FArea := Value;
        Refresh(FCanvas, FArea);
        
        FTimer.Enabled := PrevTimerEnabled;
    end;
end;

procedure TAnimatedImagesPlayer.SetCanvas(Value: TCanvas);
begin
    if FCanvas <> Value then begin
        FCanvas := Value;
        Refresh(FCanvas, FArea);
    end;
end;

procedure TAnimatedImagesPlayer.SetImages(Value: TImageList);
begin
    if FImages <> Value then begin
        FImages := Value;
        FTimer.Enabled := False;
        Restart;
    end;
end;    

procedure TAnimatedImagesPlayer.RenderFrame(ARefresh: Boolean);
begin
    if (FImages <> nil) then begin
        Inc(FStep);
        if FStep = FrameCount then
            FStep := 0;
        if ARefresh then
            Refresh(FCanvas, FArea);
    end;
end;

procedure TAnimatedImagesPlayer.RenderDefault;
begin
    if FImages <> nil then
        FImages.StretchDraw(FCanvas, 0, FArea, True);
end;

procedure TAnimatedImagesPlayer.Refresh(ACanvas: TCanvas; ARect: TRect);

    procedure DrawFrame;
    begin
        if FImages <> nil then
            FImages.StretchDraw(ACanvas, FStep, ARect, True);
    end;
    
begin
    if Assigned(FOnRefresh) then
        if FOnRefresh(Self, nil, ACanvas, ARect) then
            begin end
        else
            DrawFrame
    else
        DrawFrame;
    DoFrameRendered;
end;

procedure TAnimatedImagesPlayer.Restart;
begin
    Stop;
    FStep := -1;
end;

procedure TAnimatedImagesPlayer.OnTimer(Sender: TObject);
begin
    RenderFrame(True);
end;

end.
