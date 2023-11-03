// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqAnimationPlayer;

interface
    
uses
    SysUtils, Classes,
    IntfGraphics, Graphics, StdCtrls, ExtCtrls, Dialogs,
    BGRABitmap, BGRABitmapTypes, BGRACanvas2D;
    
type
    
    TAnimationRefreshEvent = function (Sender: TObject; ABitmap: TBGRABitmap; ACanvas: TCanvas;
        ARect: TRect): Boolean of object;
    
    TAnimationPlayer = class(TPersistent)
    strict protected
        FOnPlaying: TNotifyEvent;
        FOnStop: TNotifyEvent;
        FOnPause: TNotifyEvent;
        FOnResume: TNotifyEvent;
        FOnFrameRendered: TNotifyEvent;
        FOnRefresh: TAnimationRefreshEvent;
        FOnErase: TNotifyEvent;
    protected
        
        procedure DoPlaying; virtual;
        procedure DoStop; virtual;
        procedure DoPause; virtual;
        procedure DoResume; virtual;
        procedure DoErase; virtual;
        procedure DoFrameRendered; virtual;
        
        function GetStep: Integer; virtual;
        function GetArea: TRect; virtual;
        function GetCanvas: TCanvas; virtual;
        procedure SetStep(Value: Integer); virtual;
        procedure SetArea(Value: TRect); virtual;
        procedure SetCanvas(Value: TCanvas); virtual;
        
        function GetPausable: Boolean; virtual;
        function GetPaused  : Boolean; virtual;
        function GetPlayable: Boolean; virtual;
        function GetPlaying : Boolean; virtual;
        
    public
        constructor Create(AGraphic: TGraphic); virtual;
        destructor Destroy; override;
        
        procedure Play; virtual;
        procedure Stop; virtual;
        procedure Pause; virtual;
        procedure Resume; virtual;
        procedure NextFrame; virtual;
        procedure Erase; virtual;
        
        property Step: Integer read GetStep write SetStep;
        property Area: TRect read GetArea write SetArea;
        property Canvas: TCanvas read GetCanvas write SetCanvas;
        
        property Paused: Boolean read GetPaused;
        property Pausable: Boolean read GetPausable;
        property Playable: Boolean read GetPlayable;
        property Playing: Boolean read GetPlaying;
        
        property OnPlaying: TNotifyEvent read FOnPlaying write FOnPlaying;
        property OnStop: TNotifyEvent read FOnStop write FOnStop;
        property OnPause: TNotifyEvent read FOnPause write FOnPause;
        property OnResume: TNotifyEvent read FOnResume write FOnResume;
        property OnFrameRendered: TNotifyEvent read FOnFrameRendered write FOnFrameRendered;
        property OnRefresh: TAnimationRefreshEvent read FOnRefresh write FOnRefresh;
        property OnErase: TNotifyEvent read FOnErase write FOnErase;
    end;
    
    TAnimationPlayerClass = class of TAnimationPlayer;
    
implementation

{ TAnimationPlayer }

constructor TAnimationPlayer.Create(AGraphic: TGraphic);
begin
    inherited Create;
end;

destructor TAnimationPlayer.Destroy;
begin
    inherited;
end;

procedure TAnimationPlayer.DoPlaying;
begin
    if Assigned(FOnPlaying) then FOnPlaying(Self);
end;

procedure TAnimationPlayer.DoStop;
begin
    if Assigned(FOnStop) then FOnStop(Self);
end;

procedure TAnimationPlayer.DoPause;
begin
    if Assigned(FOnPause) then FOnPause(Self);
end;

procedure TAnimationPlayer.DoResume;
begin
    if Assigned(FOnResume) then FOnResume(Self);
end;

procedure TAnimationPlayer.DoErase;
begin
    if Assigned(FOnErase) then FOnErase(Self);
end;

procedure TAnimationPlayer.DoFrameRendered;
begin
    if Assigned(FOnFrameRendered) then FOnFrameRendered(Self);
end;

function TAnimationPlayer.GetStep: Integer;
begin
    Result := 0;
end;

function TAnimationPlayer.GetArea: TRect;
begin
    Result := TRect.Empty;
end;

function TAnimationPlayer.GetCanvas: TCanvas;
begin
    Result := nil;
end;

procedure TAnimationPlayer.SetStep(Value: Integer);
begin
end;

procedure TAnimationPlayer.SetArea(Value: TRect);
begin
end;

procedure TAnimationPlayer.SetCanvas(Value: TCanvas);
begin
end;

function TAnimationPlayer.GetPausable: Boolean;
begin
    Result := False;
end;

function TAnimationPlayer.GetPaused  : Boolean;
begin
    Result := False;
end;

function TAnimationPlayer.GetPlayable: Boolean;
begin
    Result := False;
end;

function TAnimationPlayer.GetPlaying : Boolean;
begin
    Result := False;
end;

procedure TAnimationPlayer.Play;
begin
end;

procedure TAnimationPlayer.Stop;
begin
end;

procedure TAnimationPlayer.Pause;
begin
end;

procedure TAnimationPlayer.Resume;
begin
end;

procedure TAnimationPlayer.NextFrame;
begin
end;

procedure TAnimationPlayer.Erase;
begin
end;

end.

