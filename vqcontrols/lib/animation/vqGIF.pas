// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqGIF;

interface

uses
    SysUtils, Classes, FPImage,
    IntfGraphics, GraphType, Graphics, StdCtrls, Dialogs, ImgList, Controls,
    ExtCtrls,                                               
    BGRABitmap, BGRACanvas, BGRABitmapTypes, BGRAAnimatedGif,
    vqUtils, vqAnimationPlayer;

type

    { TAnimatedGIF }

    TAnimatedGIF = class(TBGRAAnimatedGIF)
    public
        class function IsFileExtensionSupported(Ext: string): Boolean; virtual;
    end;
    
    TAnimatedGIFPlayer = class(TAnimationPlayer)
    private
        FTimer: TTimer;
        FSaveCurrImage: Integer;
        FPlaying: Boolean;
        FPaused: Boolean;
        FArea: TRect;
        FCanvas: TCanvas;
        FBackBmp: TBGRABitmap;
        FGIF: TAnimatedGIF;

        function GetLocation: TPoint;
        function GetSize: TSize;
        procedure SetLocation(Value: TPoint);
        procedure SetSize(Value: TSize);
        
        procedure SetGIF(Value: TAnimatedGIF);
    protected
        procedure RenderFrame(ARefresh: Boolean); virtual;
        procedure Refresh(ABitmap: TBGRABitmap; ACanvas: TCanvas; ARect: TRect); virtual;
        procedure OnTimer(Sender: TObject); virtual;
    protected
        function GetStep: Integer; override;
        function GetArea: TRect; override;
        function GetCanvas: TCanvas; override;
        procedure SetStep(Value: Integer); override;
        procedure SetArea(Value: TRect); override;
        procedure SetCanvas(Value: TCanvas); override;
        
        function GetPausable: Boolean; override;
        function GetPlayable: Boolean; override;
        function GetPaused: Boolean; override;
        function GetPlaying: Boolean; override;
    public
        constructor Create(AGraphic: TGraphic); override;
        destructor Destroy; override;
        
        procedure Play; override;
        procedure Stop; override;
        procedure Pause; override;
        procedure Resume; override;
        procedure NextFrame; override;
        procedure Erase; override;
        
        property Location: TPoint read GetLocation write SetLocation;
        property Size: TSize read GetSize write SetSize;
        property GIF: TAnimatedGIF read FGIF write SetGIF;
    end;
    
implementation

{ TAnimatedGIF }

class function TAnimatedGIF.IsFileExtensionSupported(Ext: string): Boolean;
begin
    Result := False;
    if Ext = '' then Exit;
    if Ext[1] = '.' then
        Delete(Ext, 1, 1);
    if Ext = '' then Exit;
    Result := LowerCase(Ext) = 'gif';
end;

{ TAnimatedGIFPlayer }

constructor TAnimatedGIFPlayer.Create(AGraphic: TGraphic);
begin
    inherited Create(AGraphic);
    if AGraphic is TAnimatedGIF then
        FGIF := TAnimatedGIF(AGraphic)
    else
        FGIF := nil;
    FBackBmp := nil;
    FArea := TRect.Empty;
    FTimer := TTimer.Create(nil);
    FTimer.Enabled := False;
    FTimer.Interval := 15;
    FTimer.OnTimer := @OnTimer;
    FPlaying := False;
    FPaused := False;
end;

destructor TAnimatedGIFPlayer.Destroy;
begin
    FGIF := nil;
    if FBackBmp <> nil then FBackBmp.Free;
    FTimer.Free;
    inherited;
end;

procedure TAnimatedGIFPlayer.RenderFrame(ARefresh: Boolean);
begin
    if GIF <> nil then begin
        if FBackBmp = nil then
            FBackBmp := TBGRABitmap.Create(GIF.Width, GIF.Height, clNone);
        FBackBmp.PutImage(0, 0, GIF.MemBitmap, dmDrawWithTransparency);
        if ARefresh then
            Refresh(FBackBmp, FCanvas, FArea);
    end;
end;

procedure TAnimatedGIFPlayer.Refresh(ABitmap: TBGRABitmap; ACanvas: TCanvas; ARect: TRect);
begin
    if Assigned(FOnRefresh) then begin
        if FOnRefresh(Self, ABitmap, ACanvas, ARect) then
            begin end
        else
            if (ABitmap <> nil) and (ACanvas <> nil) then
                ABitmap.Draw(ACanvas, ARect, False)
    end
    else 
        if (ABitmap <> nil) and (ACanvas <> nil) then
                ABitmap.Draw(ACanvas, ARect, False);
    DoFrameRendered;
end;

procedure TAnimatedGIFPlayer.OnTimer(Sender: TObject);
begin
    if GIF.TimeUntilNextImageMs <= 0 then
        RenderFrame(True);
end;

function TAnimatedGIFPlayer.GetPausable: Boolean;
begin
    Result := (GIF <> nil) and (FPlaying) and (not FPaused);
end;

function TAnimatedGIFPlayer.GetPlayable: Boolean;
begin
    Result := (GIF <> nil) and (not FPlaying);
end;

function TAnimatedGIFPlayer.GetPaused: Boolean;
begin
    Result := FPaused;
end;

function TAnimatedGIFPlayer.GetPlaying: Boolean;
begin
    Result := FPlaying;
end;

procedure TAnimatedGIFPlayer.Play;
begin
    if Playable then begin
        FPlaying := True;
        FPaused := False;
        DoPlaying;
        GIF.CurrentImage := 0;
        FTimer.Enabled := True;
    end;
end;

procedure TAnimatedGIFPlayer.Stop;
begin
    if FPlaying then begin
        FTimer.Enabled := False;
        GIF.CurrentImage := 0;
        FSaveCurrImage := 0;
        FPlaying := False;
        FPaused := False;
        RenderFrame(True);
        DoStop;
    end;
end;

procedure TAnimatedGIFPlayer.Pause;
begin
    if Pausable then begin
        FTimer.Enabled := False;
        GIF.Pause;
        FSaveCurrImage := GIF.CurrentImage;
        DoPause;
    end;
end;

procedure TAnimatedGIFPlayer.Resume;
begin
    if FPaused then begin
        GIF.CurrentImage := FSaveCurrImage;
        GIF.Resume;
        FTimer.Enabled := True;
        DoResume;
    end;
end;

procedure TAnimatedGIFPlayer.NextFrame;
begin
    if GIF <> nil then begin
        if FTimer.Enabled then begin // playing and not paused
            if GIF.CurrentImage >= GIF.Count - 1 then
                GIF.CurrentImage := 0
            else
                GIF.CurrentImage := GIF.CurrentImage + 1;
        end
        else begin
            if FSaveCurrImage >= GIF.Count - 1 then
                FSaveCurrImage := 0
            else
                Inc(FSaveCurrImage);
            GIF.CurrentImage := FSaveCurrImage;
            RenderFrame(True);
        end;
    end;
end;

procedure TAnimatedGIFPlayer.Erase;
begin
    DoErase;
end;

function TAnimatedGIFPlayer.GetStep: Integer;
begin
    if GIF <> nil then Result := GIF.CurrentImage
    else Result := 0;
end;

function TAnimatedGIFPlayer.GetArea: TRect;
begin
    Result := FArea;
end;

function TAnimatedGIFPlayer.GetCanvas: TCanvas;
begin
    Result := FCanvas;
end;

function TAnimatedGIFPlayer.GetLocation: TPoint;
begin
    Result := FArea.TopLeft;
end;

function TAnimatedGIFPlayer.GetSize: TSize;
begin
    Result := FArea.Size;
end;

procedure TAnimatedGIFPlayer.SetLocation(Value: TPoint);
begin
    SetArea(Rect(Value.X, Value.Y, Size.cx, Size.cy));
end;

procedure TAnimatedGIFPlayer.SetSize(Value: TSize);
begin
    SetArea(Rect(Location.X, Location.Y, Value.cx, Value.cy));
end;

procedure TAnimatedGIFPlayer.SetArea(Value: TRect);
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

procedure TAnimatedGIFPlayer.SetCanvas(Value: TCanvas);
begin
    if FCanvas <> Value then begin
        FCanvas := Value;
        Refresh(FBackBmp, FCanvas, FArea);
    end;
end;

procedure TAnimatedGIFPlayer.SetStep(Value: Integer);
begin
    if Value < 0 then Value := 0;
    if FTimer.Enabled then
        GIF.CurrentImage := Value
    else begin
        FSaveCurrImage := Value;
        GIF.CurrentImage := FSaveCurrImage;
        RenderFrame(True);
    end;
end;

procedure TAnimatedGIFPlayer.SetGIF(Value: TAnimatedGIF);
begin
    if FGIF <> Value then begin
        Stop;
        if FBackBmp <> nil then FreeAndNil(FBackBmp);
        
        FGIF := Value;
        
        if FGIF <> nil then begin
            GIF.CurrentImage := 0;
            RenderFrame(True);
        end;
    end;
end;

end.
