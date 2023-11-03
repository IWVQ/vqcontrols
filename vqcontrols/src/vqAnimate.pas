// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqAnimate;

interface
         
uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Types, Classes, SysUtils, Graphics, Forms, Controls, StdCtrls, Buttons,
    ImgList, ActnList, Dialogs, ExtCtrls, Math,
    BGRABitmap, BGRABitmapTypes, BGRACanvas2D,
    vqUtils, vqThemes, vqAnimationPlayer, vqAnimatedImages, vqAPNG,
    vqGIF, vqAnimation;

type
    
    TvqAnimate = class(TvqGraphicControl)
    private
        FSaveRefreshBitmap: TBGRABitmap;
        FSaveRefreshCanvas: TCanvas;
        FSaveRefreshRect: TRect;
        FSaveRefreshIndex: Integer;
        
        FArea: TRect;
        FPlayer: TAnimationPlayer;
        FAnimation: TvqAnimation;
        
        FCenter: Boolean;
        FProportional: Boolean;
        FStretch: Boolean;
        
        FImages: TImageList;
        FImageChangeLink: TChangeLink;
        FImageInterval: Cardinal;
        
        FOnPlaying      : TNotifyEvent;
        FOnStop         : TNotifyEvent;
        FOnPause        : TNotifyEvent;
        FOnResume       : TNotifyEvent;
        FOnFrameRendered: TNotifyEvent;
        
        function GetPaused: Boolean;
        function GetPlayable: Boolean;
        function GetPausable: Boolean;
        function GetPlaying: Boolean;
        
        procedure SetImages(Value: TImageList);
        procedure SetImageInterval(Value: Cardinal);
        procedure SetCenter(Value: Boolean);
        procedure SetProportional(Value: Boolean);
        procedure SetStretch(Value: Boolean);
        
        function GetStep: Integer;
        function GetActive: Boolean;
        procedure SetStep(Value: Integer);
        procedure SetActive(Value: Boolean);
        procedure SetAnimation(Value: TvqAnimation);
        
        procedure OnPlayerPlaying(Sender: TObject);
        procedure OnPlayerStop(Sender: TObject);
        procedure OnPlayerPause(Sender: TObject);
        procedure OnPlayerResume(Sender: TObject);
        procedure OnPlayerFrameRendered(Sender: TObject);
        
        procedure OnImagesChange(Sender: TObject);
        procedure OnAnimationChange(Sender: TObject);
        
        procedure CalculateMetrics;
        function OnPlayerRefresh(Sender: TObject; ABitmap: TBGRABitmap; ACanvas: TCanvas; ARect: TRect): Boolean;
    protected
        procedure ChangePlayer; virtual;
        
        class function GetControlClassDefaultSize: TSize; override;
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        
        procedure DoPlaying; virtual;
        procedure DoStop; virtual;
        procedure DoPause; virtual;
        procedure DoResume; virtual;
        procedure DoFrameRendered; virtual;
        
        procedure UpdateMetrics; override;
        procedure ColorChanged; override;
        procedure EnabledChanged; override;
        procedure VisibleChanged; override;
        procedure Resize; override;
        procedure Paint; override;
        
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        
        procedure Play;
        procedure Stop;
        procedure Pause;
        procedure Resume;
        procedure NextFrame;
        
        property Paused: Boolean read GetPaused;
        property Playable: Boolean read GetPlayable;
        property Pausable: Boolean read GetPausable;
        property Playing: Boolean read GetPlaying;
        
        property Player: TAnimationPlayer read FPlayer;
    published
        property Images: TImageList read FImages write SetImages;
        property ImageInterval: Cardinal read FImageInterval write SetImageInterval;
        
        property Center: Boolean read FCenter write SetCenter;
        property Proportional: Boolean read FProportional write SetProportional;
        property Stretch: Boolean read FStretch write SetStretch;
        
        property Step: Integer read GetStep write SetStep;
        property Active: Boolean read GetActive write SetActive;
        property Animation: TvqAnimation read FAnimation write SetAnimation;
        
        property OnPlaying: TNotifyEvent read FOnPlaying write FOnPlaying;
        property OnStop: TNotifyEvent read FOnStop write FOnStop;
        property OnPause: TNotifyEvent read FOnPause write FOnPause;
        property OnResume: TNotifyEvent read FOnResume write FOnResume;
        property OnFrameRendered: TNotifyEvent read FOnFrameRendered write FOnFrameRendered;
    end;
    
implementation

{ TvqAnimate }

constructor TvqAnimate.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    ControlStyle := ControlStyle + [csAutoSize0x0];
    FAnimation := TvqAnimation.Create;
    FAnimation.OnChange := @OnAnimationChange;
    FPlayer := nil;
    FImages := nil;
    FImageInterval := 100;
    FImageChangeLink := TChangeLink.Create;
    FImageChangeLink.OnChange := @OnImagesChange;
    
    FSaveRefreshBitmap := nil;
    FSaveRefreshCanvas := nil;
    FSaveRefreshRect := TRect.Empty;
    FSaveRefreshIndex := -1;
    
    CalculateMetrics;
end;

destructor TvqAnimate.Destroy;
begin
    if FPlayer <> nil then FPlayer.Free;
    FAnimation.Free;
    FImageChangeLink.Free;
    
    inherited;
end;

procedure TvqAnimate.Play;
begin
    if FPlayer <> nil then FPlayer.Play;
end;

procedure TvqAnimate.Stop;
begin
    if FPlayer <> nil then FPlayer.Stop;
end;

procedure TvqAnimate.Pause;
begin
    if FPlayer <> nil then FPlayer.Pause;
end;

procedure TvqAnimate.Resume;
begin
    if FPlayer <> nil then FPlayer.Resume;
end;

procedure TvqAnimate.NextFrame;
begin
    if FPlayer <> nil then FPlayer.NextFrame;
end;

function TvqAnimate.GetPaused: Boolean;
begin
    if FPlayer <> nil then Result := FPlayer.Paused
    else Result := False;
end;

function TvqAnimate.GetPlayable: Boolean;
begin
    if FPlayer <> nil then Result := FPlayer.Playable
    else Result := False;
end;

function TvqAnimate.GetPausable: Boolean;
begin
    if FPlayer <> nil then Result := FPlayer.Pausable
    else Result := False;
end;

function TvqAnimate.GetPlaying: Boolean;
begin
    if FPlayer <> nil then Result := FPlayer.Playing
    else Result := False;
end;

procedure TvqAnimate.SetImages(Value: TImageList);
begin
    if FImages <> Value then begin
        if FImages <> nil then begin
            FImages.UnRegisterChanges(FImageChangeLink);
            FImages.RemoveFreeNotification(Self);
        end;
        FImages := Value;
        if FImages <> nil then begin
            FImages.FreeNotification(Self);
            FImages.RegisterChanges(FImageChangeLink);
        end;
        ChangePlayer;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqAnimate.SetImageInterval(Value: Cardinal);
begin
    if FImageInterval <> Value then begin
        FImageInterval := Value;
        if  (FPlayer <> nil) and 
            (FPlayer is TAnimatedImagesPlayer) then
            TAnimatedImagesPlayer(FPlayer).Interval := FImageInterval;
    end;
end;

procedure TvqAnimate.SetCenter(Value: Boolean);
begin
    if FCenter <> Value then begin
        FCenter := Value;
        CalculateMetrics;
        Repaint;
    end;
end;

procedure TvqAnimate.SetProportional(Value: Boolean);
begin
    if FProportional <> Value then begin
        FProportional := Value;
        CalculateMetrics;
        Repaint;
    end;
end;

procedure TvqAnimate.SetStretch(Value: Boolean);
begin
    if FStretch <> Value then begin
        FStretch := Value;
        CalculateMetrics;
        Repaint;
    end;
end;

function TvqAnimate.GetStep: Integer;
begin
    if FPlayer <> nil then Result := FPlayer.Step
    else Result := 0;
end;

procedure TvqAnimate.SetStep(Value: Integer);
begin
    if FPlayer <> nil then FPlayer.Step := Value;
end;

function TvqAnimate.GetActive: Boolean;
begin
    Result := Playing and not Paused;
end;

procedure TvqAnimate.SetActive(Value: Boolean);
begin
    if GetActive <> Value then begin
        if Playing then
            Resume
        else
            Play;
    end;
end;

procedure TvqAnimate.SetAnimation(Value: TvqAnimation);
begin
    FAnimation.Assign(Value);
end;

procedure TvqAnimate.OnPlayerPlaying(Sender: TObject);
begin
    DoPlaying;
end;

procedure TvqAnimate.OnPlayerStop(Sender: TObject);
begin
    DoStop;
end;

procedure TvqAnimate.OnPlayerPause(Sender: TObject);
begin
    DoPause;
end;

procedure TvqAnimate.OnPlayerResume(Sender: TObject);
begin
    DoResume;
end;

procedure TvqAnimate.OnPlayerFrameRendered(Sender: TObject);
begin
    DoFrameRendered;
end;

procedure TvqAnimate.OnImagesChange(Sender: TObject);
begin
    if Sender = FImages then begin
        ChangePlayer;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqAnimate.OnAnimationChange(Sender: TObject);
begin
    ChangePlayer;
    InvalidatePreferredSize;
    AdjustSize;
end;

class function TvqAnimate.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 50;
    Result.cy := 50;
end;

procedure TvqAnimate.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
begin
    if FAnimation.Graphic <> nil then begin
        PreferredWidth := FAnimation.Width;
        PreferredHeight := FAnimation.Height;
    end
    else if FImages <> nil then begin
        PreferredWidth := FImages.Width;
        PreferredHeight := FImages.Height;
    end
    else begin
        PreferredWidth := 0;
        PreferredHeight := 0;
    end;
end;

procedure TvqAnimate.DoPlaying;
begin
    if Assigned(FOnPlaying) then FOnPlaying(Self);
end;

procedure TvqAnimate.DoStop;
begin
    if Assigned(FOnStop) then FOnStop(Self);
end;

procedure TvqAnimate.DoPause;
begin
    if Assigned(FOnPause) then FOnPause(Self);
end;

procedure TvqAnimate.DoResume;
begin
    if Assigned(FOnResume) then FOnResume(Self);
end;

procedure TvqAnimate.DoFrameRendered;
begin
    if Assigned(FOnFrameRendered) then FOnFrameRendered(Self);
end;

procedure TvqAnimate.UpdateMetrics;
begin
    InvalidatePreferredSize;
    AdjustSize;
    inherited;
end;

procedure TvqAnimate.ColorChanged;
begin
    inherited;
    Repaint;
end;

procedure TvqAnimate.EnabledChanged;
begin
    inherited;
    if not Enabled then Active := False;
    Repaint;
end;

procedure TvqAnimate.VisibleChanged;
begin
    inherited;
    if not Visible then Stop;
end;

procedure TvqAnimate.Resize;
begin
    inherited;
    CalculateMetrics;
end;

procedure TvqAnimate.CalculateMetrics;
var
    W, H, X, Y, pW, pH: Integer;
    Client: TRect;
begin
    Client := ClientRect;
    if FAnimation.Graphic <> nil then begin
        W := FAnimation.Width;
        H := FAnimation.Height;
    end
    else if FImages <> nil then begin
        W := FImages.Width;
        H := FImages.Height;
    end
    else begin
        W := 0;
        H := 0;
    end;
    if FStretch then begin
        FArea := Client;
        if FProportional then begin
            pW := MulDiv(H, FArea.Width, FArea.Height);
            if pW <= FArea.Width then FArea.Width := pW
            else begin
                pH := MulDiv(W, FArea.Height, FArea.Width);
                FArea.Height := pH;
            end;
        end;
    end
    else
        FArea := Bounds(Client.Left, Client.Top, W, H);
    if FCenter then begin
        X := (Client.Left + Client.Right - FArea.Width) div 2;
        Y := (Client.Top + Client.Bottom - FArea.Height) div 2;
        FArea.SetLocation(X, Y);
    end;
    
    if FPlayer <> nil then 
        FPlayer.Area := FArea;
end;

procedure TvqAnimate.ChangePlayer;
var
    PlayerClass: TAnimationPlayerClass;
begin
    FSaveRefreshCanvas := nil;
    FSaveRefreshRect := TRect.Empty;
    
    if FPlayer <> nil then FreeAndNil(FPlayer);
    if FAnimation.Graphic <> nil then begin
        if FAnimation.Graphic.ClassType.InheritsFrom(TGraphic) then
            PlayerClass := TvqAnimation.PlayerClass(TGraphicClass(FAnimation.Graphic.ClassType))
        else
            PlayerClass := nil;

        if PlayerClass <> nil then
            FPlayer := PlayerClass.Create(FAnimation.Graphic)
        else
            FPlayer := nil;
    end
    else if FImages <> nil then begin
        FPlayer := TAnimatedImagesPlayer.Create(FImages);
        TAnimatedImagesPlayer(FPlayer).Interval := FImageInterval;
    end;
    if FPlayer <> nil then begin
        FPlayer.Area := FArea;
        FPlayer.Canvas := Canvas;
        FPlayer.OnPlaying := @OnPlayerPlaying;
        FPlayer.OnStop := @OnPlayerStop;
        FPlayer.OnPause := @OnPlayerPause;
        FPlayer.OnResume := @OnPlayerResume;
        FPlayer.OnFrameRendered := @OnPlayerFrameRendered;
        
        FPlayer.OnRefresh := @OnPlayerRefresh;
    end;
    Repaint;
end;

function TvqAnimate.OnPlayerRefresh(Sender: TObject; ABitmap: TBGRABitmap; ACanvas: TCanvas; ARect: TRect): Boolean;
begin
    if FPlayer is TAnimatedImagesPlayer then 
        FSaveRefreshIndex := TAnimatedImagesPlayer(FPlayer).Step;
    
    FSaveRefreshBitmap := ABitmap;
    FSaveRefreshCanvas := ACanvas;
    FSaveRefreshRect := ARect;
    
    Result := True;
    Repaint;
end;

procedure TvqAnimate.Paint;
begin
    if FPlayer <> nil then begin
        if FPlayer is TAnimatedImagesPlayer then
            FImages.StretchDraw(FSaveRefreshCanvas, FSaveRefreshIndex, FSaveRefreshRect, Enabled)
        else
            if FSaveRefreshBitmap <> nil then
                FSaveRefreshBitmap.Draw(FSaveRefreshCanvas, FSaveRefreshRect, False);
    end;
    inherited;
end;

end.
