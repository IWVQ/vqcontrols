// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqAnimation;

interface
                           
uses                                                     
    InterfaceBase, LclIntf, LclType, LMessages, LResources,
    SysUtils, Classes, FPImage, LazUTF8Classes,
    IntfGraphics, GraphType, Graphics, StdCtrls, Dialogs, ImgList, Controls,
    ExtCtrls,
    vqUtils, vqAnimationPlayer, vqAnimatedImages, vqAPNG, vqGIF;

type
    
    TvqAnimation = class(TPersistent)
    private
        FGraphic: TGraphic;
        FOnChange: TNotifyEvent;
        FOnProgress: TProgressEvent;
        function GetBitmap: TBitmap;
        function GetAPNG: TAnimatedPNG;
        function GetGIF: TAnimatedGIF;
        function GetHeight: Integer;
        function GetWidth: Integer;
        procedure SetBitmap(Value: TBitmap);
        procedure SetAPNG(Value: TAnimatedPNG);
        procedure SetGIF(Value: TAnimatedGIF);
        procedure SetGraphic(Value: TGraphic);
        
    protected
        function GetFrameCount: Integer; virtual;
        function GetPlayCount: Integer; virtual;
        
        procedure AssignTo(Dest: TPersistent); override;
        procedure ForceType(AType: TGraphicClass);
        procedure Changed(Sender: TObject); virtual;
        procedure Progress(Sender: TObject; Stage: TProgressStage;
            PercentDone: Byte; RedrawNow: Boolean; const R: TRect;
            const Msg: string; var DoContinue: boolean); virtual;
         
        procedure LoadFromStreamWithClass(Stream: TStream; AClass: TGraphicClass);
        function GraphicClassFromFileExt(Ext: string): TGraphicClass; virtual;
        function GraphicClassFromStream(Stream: TStream): TGraphicClass; virtual;
    public
        constructor Create; virtual;
        destructor Destroy; override;
        
        procedure Assign(Source: TPersistent); override;
        procedure Clear; virtual;
        class function PlayerClass(AType: TGraphicClass): TAnimationPlayerClass; virtual;

        procedure LoadFromFile(FileName: string);
        procedure LoadFromLazarusResource(AName: string);
        procedure LoadFromStream(Stream: TStream);
        procedure LoadFromStreamWithFileExt(Stream: TStream; Ext: string);
        
        procedure SaveToFile(FileName: string);
        procedure SaveToStream(Stream: TStream);
        
        property Bitmap: TBitmap read GetBitmap write SetBitmap;   
        property Graphic: TGraphic read FGraphic write SetGraphic;
        property Height: Integer read GetHeight;
        property Width: Integer read GetWidth;

        property APNG: TAnimatedPNG read GetAPNG write SetAPNG;
        property GIF: TAnimatedGIF read GetGIF write SetGIF;
        property FrameCount: Integer read GetFrameCount;
        property PlayCount: Integer read GetPlayCount;
        
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
        property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
    end;

implementation

constructor TvqAnimation.Create;
begin
    inherited Create;
    FGraphic := nil;
end;

destructor TvqAnimation.Destroy;
begin
    if FGraphic <> nil then
        FGraphic.Free;
    inherited;
end;

procedure TvqAnimation.Assign(Source: TPersistent);
begin
    if Source = nil then
        SetGraphic(nil)
    else if Source is TvqAnimation then
        SetGraphic(TvqAnimation(Source).Graphic)
    else if Source is TGraphic then
        SetGraphic(TGraphic(Source))
    else
        inherited Assign(Source);
end;

procedure TvqAnimation.Clear;
begin
    SetGraphic(nil);
end;

class function TvqAnimation.PlayerClass(AType: TGraphicClass): TAnimationPlayerClass;
begin
    if AType = nil then
        Result := nil
    else if AType.InheritsFrom(TAnimatedPNG) then
        Result := TAnimatedPNGPlayer
    else if AType.InheritsFrom(TAnimatedGIF) then
        Result := TAnimatedGIFPlayer
    else
        Result := nil;
end;

procedure TvqAnimation.AssignTo(Dest: TPersistent);
begin
    if FGraphic is Dest.ClassType then 
        Dest.Assign(FGraphic)
    else inherited;
end;

procedure TvqAnimation.ForceType(AType: TGraphicClass);
var
    AGraphic: TGraphic;
begin
    if not (FGraphic is AType) then begin
        AGraphic := AType.Create;
        AGraphic.Assign(FGraphic);
        FGraphic.Free;
        FGraphic := AGraphic;
        FGraphic.OnChange := @Changed;
        FGraphic.OnProgress := @Progress;
        Changed(Self);
    end;
end;

function TvqAnimation.GetBitmap: TBitmap;
begin
    ForceType(TBitmap);
    Result := TBitmap(Graphic);
end;

function TvqAnimation.GetAPNG: TAnimatedPNG;
begin
    ForceType(TAnimatedPNG);
    Result := TAnimatedPNG(Graphic);
end;

function TvqAnimation.GetGIF: TAnimatedGIF;
begin
    ForceType(TAnimatedGIF);
    Result := TAnimatedGIF(Graphic);
end;

function TvqAnimation.GetHeight: Integer;
begin
    if FGraphic <> nil then
        Result := FGraphic.Height
    else
        Result := 0;
end;

function TvqAnimation.GetWidth: Integer;
begin
    if FGraphic <> nil then
        Result := FGraphic.Width
    else
        Result := 0;
end;

function TvqAnimation.GetFrameCount: Integer;
begin
    if FGraphic = nil then 
        Result := 0
    else if FGraphic is TAnimatedPNG then
        Result := TAnimatedPNG(FGraphic).FrameCount
    else if FGraphic is TAnimatedGIF then
        Result := TAnimatedGIF(FGraphic).Count
    else
        Result := 0;
end;

function TvqAnimation.GetPlayCount: Integer;
begin
    if FGraphic = nil then 
        Result := 0
    else if FGraphic is TAnimatedPNG then
        Result := TAnimatedPNG(FGraphic).PlayCount
    else if FGraphic is TAnimatedGIF then
        Result := TAnimatedGIF(FGraphic).LoopCount
    else
        Result := 0;
end;

procedure TvqAnimation.SetBitmap(Value: TBitmap);
begin
    SetGraphic(Value);
end;

procedure TvqAnimation.SetAPNG(Value: TAnimatedPNG);
begin
    SetGraphic(Value);
end;

procedure TvqAnimation.SetGIF(Value: TAnimatedGIF);
begin
    SetGraphic(Value);
end;

procedure TvqAnimation.SetGraphic(Value: TGraphic);
var 
    AGraphic: TGraphic;
begin
    if FGraphic <> Value then begin
        AGraphic := nil;
        try
            if Value <> nil then begin
                AGraphic := TGraphicClass(Value.ClassType).Create;
                AGraphic.Assign(Value);
                AGraphic.OnChange := @Changed;
                AGraphic.OnProgress := @Progress;
            end;
            if FGraphic <> nil then
                FGraphic.Free;
            FGraphic := AGraphic;
            AGraphic := nil;
            Changed(Self);
        finally
            if AGraphic <> nil then
                AGraphic.Free;
        end;
    end;
end;

procedure TvqAnimation.Changed(Sender: TObject);
begin
    if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TvqAnimation.Progress(Sender: TObject; Stage: TProgressStage;
    PercentDone: Byte; RedrawNow: Boolean; const R: TRect;
    const Msg: string; var DoContinue: boolean);
begin
    DoContinue := True;
    if Assigned(FOnProgress) then
        FOnProgress(Sender, Stage, PercentDone, RedrawNow, R, Msg, DoContinue);
end;

procedure TvqAnimation.LoadFromFile(FileName: string);
var
    Ext: string;
    Stream: TFileStreamUTF8;
begin
    Ext := ExtractFileExt(FileName);

    System.Delete(Ext, 1, 1);
    
    Stream := TFileStreamUTF8.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
        if Ext <> '' then
            LoadFromStreamWithFileExt(Stream, Ext)
        else
            LoadFromStream(Stream);
    finally
        Stream.Free;
    end;
end;

procedure TvqAnimation.LoadFromLazarusResource(AName: string);
var
    Stream: TLazarusResourceStream;
begin
    Stream := TLazarusResourceStream.Create(AName, nil);
    try
        LoadFromStreamWithFileExt(Stream, Stream.Res.ValueType);
    finally
        Stream.Free;
    end;
end;

procedure TvqAnimation.LoadFromStream(Stream: TStream);
var
    AClass: TGraphicClass;
begin
    AClass := GraphicClassFromStream(Stream);
    LoadFromStreamWithClass(Stream, AClass);
end;

procedure TvqAnimation.LoadFromStreamWithFileExt(Stream: TStream; Ext: string);
var
    AClass: TGraphicClass;
begin
    AClass := GraphicClassFromFileExt(Ext);
    LoadFromStreamWithClass(Stream, AClass);
end;

procedure TvqAnimation.SaveToFile(FileName: string);
begin
    if FGraphic <> nil then
        FGraphic.SaveToFile(FileName);
end;

procedure TvqAnimation.SaveToStream(Stream: TStream);
begin
    if FGraphic <> nil then 
        FGraphic.SaveToStream(Stream);
end;

procedure TvqAnimation.LoadFromStreamWithClass(Stream: TStream; AClass: TGraphicClass);
var
    AGraphic: TGraphic;
begin
    if AClass = nil then Exit;
    AGraphic := nil;
    try
        AGraphic := AClass.Create;
        AGraphic.OnProgress := @Progress;
        AGraphic.LoadFromStream(Stream);
        if FGraphic <> nil then
            FGraphic.Free;
        FGraphic := AGraphic;
        AGraphic := nil;
        FGraphic.OnChange := OnChange;
        Changed(Self);
    finally
        if AGraphic <> nil then
            AGraphic.Free;
    end;
end;

function TvqAnimation.GraphicClassFromFileExt(Ext: string): TGraphicClass;
begin
    if TAnimatedPNG.IsFileExtensionSupported(Ext) then
        Result := TAnimatedPNG
    else if TAnimatedGIF.IsFileExtensionSupported(Ext) then
        Result := TAnimatedGIF
    else
        Result := nil;
end;

function TvqAnimation.GraphicClassFromStream(Stream: TStream): TGraphicClass;
begin
    if TAnimatedPNG.IsStreamFormatSupported(Stream) then
        Result := TAnimatedPNG
    else if TAnimatedGIF.IsStreamFormatSupported(Stream) then
        Result := TAnimatedGIF
    else
        Result := nil;
end;

end.
