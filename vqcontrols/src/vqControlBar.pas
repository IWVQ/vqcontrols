// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqControlBar;
{
- al achicar se apila/achica los controles y vuelve si se agranda
- al alinear si un aplica/achica los controles que se cortan y vuelve si se agranda


}
{
- autopush(left, right, remember position)
- contentRect
- custom themes
- autoalign
- rowsnap
- rowsize
- autoheight controls
- resize bands(min width, max width)
- autofill
- fit bands to area
}

{
FRowSnap: x
FWrappable: x
FPushable: can auto push bands +
FResizable: can auto width bands +
FMagnetic: band are magnetic +
FFixedrowCount +

remembering protocol
glue policy
alignbands
moveband
sort after move
autosize loop

THEMES
CURSOR
EVENTS

- Fixed rowcount, move horizontally only
}

interface

uses           
    Classes, SysUtils, LResources, Types, Forms, Controls, Graphics, Dialogs,
    Math, StdCtrls, ExtCtrls,
    vqUtils, vqThemes, vqQuickButton;

type
    
    TvqControlBar = class;
    
    TvqControlBand = class
    private
        FControl: TControl;
        
        FLeft: Integer;
        FTop: Integer;
        FWidth: Integer;
        FHeight: Integer;
        
        function GetRight: Integer;
        function GetBottom: Integer;
        function GetBandRect: TRect;
        procedure SetBandRect(Value: TRect);
        procedure SetRight(Value: Integer);
        procedure SetBottom(Value: Integer);
        function GetEnabled: Boolean;
        procedure SetEnabled(Value: Boolean);
    protected
        AltControlMaxWidth: Integer;
        
        SaveLeft: Integer;
        SaveTop: Integer;
        SaveWidth: Integer;
        SaveHeight: Integer;
        
        RowCount: Integer;
        Nexts: array of TvqControlBand;
        Prevs: array of TvqControlBand;
    public
        Row: Integer;
        MinWidth: Integer;
        MaxWidth: Integer;
        ControlLeft: Integer;
        ControlTop: Integer;
        ControlWidth: Integer;
        ControlHeight: Integer;
        Visible: Boolean;
        
        constructor Create; virtual;
        procedure StoreBounds;
        procedure RestoreBounds;
        property BandRect: TRect read GetBandRect write SetBandRect;
        property Left: Integer read FLeft write FLeft;
        property Top: Integer read FTop write FTop;
        property Width: Integer read FWidth write FWidth;
        property Height: Integer read FHeight write FHeight;
        property Right: Integer read GetRight write SetRight;
        property Bottom: Integer read GetBottom write SetBottom;
        property Enabled: Boolean read GetEnabled write SetEnabled;
        property Control: TControl read FControl write FControl;
    end;
    
    TvqControlBandArray = array of TvqControlBand;
    
    TvqBandMoveEvent = procedure (Sender: TObject; AControl: TvqControlBand) of object;
    TvqBandPaintEvent = procedure (Sender: TObject; AControl: TvqControlBand; ACanvas: TCanvas; ARect: TRect) of object;
    
    TvqControlBar = class(TvqCustomControl)
    private
        FRowSize: TRowSize;
        FMagnetic: Boolean;
        FHorizontalOnly: Boolean;
        
        FMoveThreshold: Integer;
        FMagneticThreshold: Integer;
        
        FRecalculateBands: Boolean;
        FResizing: Boolean;
        FSaveClient: TRect;
        FAligning: Boolean;
        FMoveBand: TvqControlBand;
        FMoveAnchor: TPoint;
        FMoving: Boolean;
        FSaveBand: TPoint;
        
        FOnBandMove: TvqBandMoveEvent;
        FOnBandPaint: TvqBandPaintEvent;

        FBandGrabSize: Integer;
        FBandPadding: TRect;


        procedure SetRowSize(Value: TRowSize);
        
        function CalculateBandHeight(ABand: TvqControlBand): Integer;
        function CalculateBandMaxWidth(ABand: TvqControlBand): Integer;
        function CalculateBandMinWidth(ABand: TvqControlBand): Integer;
        
        procedure CalculateMetrics;
    protected
        FBands: TvqControlBandArray;
        FHeads: TvqControlBandArray;
        FTails: TvqControlBandArray;
        FRowCount: Integer;
        
        procedure Loaded; override;
        procedure Resize; override;
        procedure UpdateMetrics; override;
        procedure DrawBand(ABand: TvqControlBand); virtual;
        procedure Paint; override;
        
        class function GetControlClassDefaultSize: TSize; override;
        procedure AdjustClientRect(var ARect: TRect); override;
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        procedure AlignControls(AControl: TControl; var RemainingClientRect: TRect); override;
        procedure AlignBands; virtual;
        procedure StickControl(ABand: TvqControlBand); virtual;
        function BandFromPoint(P: TPoint): TvqControlBand;
        
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MoveBand(AMoveBand: TvqControlBand; X, Y: Integer; ByMouse: Boolean = False); virtual;
        procedure BeginMove(AMoveBand: TvqControlBand); virtual;
        procedure EndMove(AMoveBand: TvqControlBand); virtual;
        procedure DoBandMove(AMoveBand: TvqControlBand); virtual;
        procedure DoBandPaint(ABand: TvqControlBand; ACanvas: TCanvas; ARect: TRect); virtual;
        
        property Moving: Boolean read FMoving;
    protected
        function BandGrabSize: Integer;
        function BandPadding: TRect;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure FlipChildren(AllLevels: Boolean); override;
        procedure InsertControl(AControl: TControl; Index: Integer); override;
        procedure RemoveControl(AControl: TControl); override;
    published
        property AutoSize;
        property DockSite default True;
        property RowSize: TRowSize read FRowSize write SetRowSize default 26;
        property Magnetic: Boolean read FMagnetic write FMagnetic;
        property HorizontalOnly: Boolean read FHorizontalOnly write FHorizontalOnly;
        property MoveThreshold: Integer read FMoveThreshold write FMoveThreshold;
        property MagneticThreshold: Integer read FMagneticThreshold write FMagneticThreshold;
        property OnBandMove: TvqBandMoveEvent read FOnBandMove write FOnBandMove;
        property OnBandPaint: TvqBandPaintEvent read FOnBandPaint write FOnBandPaint;
    end;

implementation

type
    TBandPosition = record
        X, Y: Integer;
        Band: TvqControlBand;
        SubBand: Boolean;
    end;
    
    TBandSorter = specialize TSorter<TBandPosition>;
    
function CompareBandPositions(const ALeft, ARight: TBandPosition): Integer;
begin
    if (ALeft.Y = ARight.Y) and (ALeft.X = ARight.X) then
        Result := 0
    else if (ALeft.Y < ARight.Y) or
        ((ALeft.Y = ARight.Y) and
        (ALeft.X < ARight.X)) then
        Result := -1
    else
        Result := 1;
end;

{ TvqControlBand }

constructor TvqControlBand.Create;
begin
    //
end;

procedure TvqControlBand.RestoreBounds;
begin
    FLeft   := SaveLeft  ;
    FTop    := SaveTop   ;
    FWidth  := SaveWidth ;
    FHeight := SaveHeight;
end;

procedure TvqControlBand.StoreBounds;
begin
    SaveLeft   := FLeft  ;
    SaveTop    := FTop   ;
    SaveWidth  := FWidth ;
    SaveHeight := FHeight;
end;

function TvqControlBand.GetBandRect: TRect;
begin
    Result.Top := FTop;
    Result.Left := FLeft;
    Result.Right := GetRight;
    Result.Bottom := GetBottom;
end;

procedure TvqControlBand.SetBandRect(Value: TRect);
begin
    FLeft := Value.Left;
    FTop := Value.Top;
    FWidth := Value.Width;
    FHeight := Value.Height;
end;

function TvqControlBand.GetRight: Integer;
begin
    Result := FLeft + FWidth;
end;

function TvqControlBand.GetBottom: Integer;
begin
    Result := FTop + FHeight;
end;

procedure TvqControlBand.SetRight(Value: Integer);
begin
    FWidth := Value - FLeft;
end;

procedure TvqControlBand.SetBottom(Value: Integer);
begin
    FHeight := Value - FTop;
end;

function TvqControlBand.GetEnabled: Boolean;
begin
    if FControl <> nil then Result := FControl.Enabled
    else Result := False;
end;

procedure TvqControlBand.SetEnabled(Value: Boolean);
begin
    if FControl <> nil then FControl.Enabled := Value;
end;

{ TvqControlBar }

constructor TvqControlBar.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    BorderStyle := bsNone;
    
    FMagneticThreshold := 5;
    FMoveThreshold := 7;
    FRowCount := 0;
    FRowSize := 26;
    FMagnetic := True;
    FHorizontalOnly := False;
    
    ControlStyle := ControlStyle + [csAcceptsControls];
    CalculateMetrics;
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
end;

destructor TvqControlBar.Destroy;
var
    ABand: TvqControlBand;
begin
    for ABand in FBands do
        ABand.Free;
    FBands := nil;
    inherited;
end;

procedure TvqControlBar.FlipChildren(AllLevels: Boolean);
begin
    // do nothing
end;

procedure TvqControlBar.InsertControl(AControl: TControl; Index: Integer);
var
    BandCount: Integer;
    Band: TvqControlBand;
begin
    inherited InsertControl(AControl, Index);
    if AControl is TWinControl then begin
        FAligning := True;
        try
            BandCount := Length(FBands);
            SetLength(FBands, BandCount + 1);
            Band := TvqControlBand.Create;
            Band.Control := AControl;
            if AControl.Visible then
                Band.AltControlMaxWidth := AControl.Width;
            AControl.Align := alNone;
            FBands[BandCount] := Band;
            FRecalculateBands := True;
        finally              
            FAligning := False;
        end;
    end;
end;

procedure TvqControlBar.RemoveControl(AControl: TControl);
var
    I, AIndex, BandCount: Integer;
    NewBands: TvqControlBandArray;
begin
    if AControl is TWinControl then begin
        FAligning := True;
        try
            BandCount := Length(FBands);
            AIndex := 0;
            while AIndex < BandCount do begin
                if FBands[AIndex].Control = AControl then Break;
                Inc(AIndex);
            end;
            FBands[AIndex].Free;
            SetLength(NewBands, BandCount - 1);
            for I := 0 to AIndex - 1 do
                NewBands[I] := FBands[I];
            for I := AIndex + 1 to BandCount - 1 do
                NewBands[I - 1] := FBands[I];
            FBands := NewBands;
            NewBands := nil;
            FRecalculateBands := True;
        finally
            FAligning := False;
        end;
    end;
    inherited RemoveControl(AControl);
end;

procedure TvqControlBar.SetRowSize(Value: TRowSize);
var
    ARow: Integer;
    Band: TvqControlBand;
    PrevRowSize: Integer;
    Client: TRect;
begin
    if FRowSize <> Value then begin
        DisableAlign;
        FAligning := True;
        try
            Client := ClientRect;
            AdjustClientRect(Client);
            PrevRowSize := FRowSize;
            FRowSize := Value;
            
            for Band in FBands do begin
                ARow := (Band.Top - Client.Top) div PrevRowSize;
                Band.Top := ARow*Value + Client.Top;
                if Band.Visible then
                    Band.Height := CalculateBandHeight(Band)
                else
                    Band.Height := FRowSize;
                
                StickControl(Band);
            end;
            
        finally
            EnableAlign;
            FAligning := False;
        end;
        
        if AutoSize then begin
            InvalidatePreferredSize;
            AdjustSize;
        end;
    end;
end;

function TvqControlBar.CalculateBandHeight(ABand: TvqControlBand): Integer;
begin
    //# sinchronize with StickBand CtrlHeight
    Result := 
        (1 + 
        Trunc((ABand.Control.Height + BandPadding.Top + BandPadding.Bottom) div FRowSize)
        )*FRowSize;
end;

function TvqControlBar.CalculateBandMaxWidth(ABand: TvqControlBand): Integer;
var
    AMaxWidth: Integer;
begin
    if ABand.Control.Constraints.MaxWidth = 0 then
        AMaxWidth := ABand.AltControlMaxWidth
    else
        AMaxWidth := ABand.Control.Constraints.EffectiveMaxWidth;
    Result := BandGrabSize + BandPadding.Left + AMaxWidth + BandPadding.Right;
end;

function TvqControlBar.CalculateBandMinWidth(ABand: TvqControlBand): Integer;
begin
    Result := BandGrabSize + BandPadding.Left + ABand.Control.Constraints.EffectiveMinWidth + BandPadding.Right;
end;

procedure TvqControlBar.Loaded;
begin
    inherited;
    FResizing := False;
    FAligning := False;
    FRecalculateBands := True;
    FSaveClient := TRect.Empty;
    FAligning := True;
    AlignBands;
    FAligning := False;
end;

class function TvqControlBar.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 170;
    Result.cy := 70;
end;

procedure TvqControlBar.AdjustClientRect(var ARect: TRect);
begin
    inherited AdjustClientRect(ARect);
    ARect := vqThemeManager.ControlBarContentRect(ARect);
end;

procedure TvqControlBar.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
var
    Band: TvqControlBand;
    Client: TRect;
begin
    Client := ClientRect;
    AdjustClientRect(Client);
    
    PreferredWidth := 0;
    PreferredHeight := 0;
    
    if FBands <> nil then begin
        PreferredHeight := FRowCount*FRowSize;
        Inc(PreferredHeight, Height - Client.Height);
    end;
end;

procedure TvqControlBar.AlignControls(AControl: TControl; var RemainingClientRect: TRect);
begin
    if FAligning then Exit;
    FAligning := True;
    DisableAlign;
    try
        AlignBands;
    finally
        EnableAlign;
        FAligning := False;
    end;    
end;

procedure TvqControlBar.AlignBands;
label
    LBL_RESIZING, LBL_END;

var
    BandPositions: array of TBandPosition;
    BandPosCount: Integer;
    BandCount: Integer;
    Client: TRect;
    
    procedure AddBandPos(ABand: TvqControlBand; X, Y : Integer);
    begin
        if BandPosCount = Length(BandPositions) then
            SetLength(BandPositions, BandPosCount + 32);
        BandPositions[BandPosCount].Band := ABand;
        BandPositions[BandPosCount].X := X;
        BandPositions[BandPosCount].Y := Y;
        BandPositions[BandPosCount].SubBand := Y > ABand.Top;
        Inc(BandPosCount);
    end;
    
    procedure CorrectBandLeft(ABand: TvqControlBand; AMinLeft: Integer);
    var
        ANext: TvqControlBand;
    begin
        if ABand <> nil then begin
            if ABand.Left < AMinLeft then
                ABand.Left := AMinLeft;
            AMinLeft := ABand.Right;
            for ANext in ABand.Nexts do
                CorrectBandLeft(ANext, AMinLeft);
        end;
    end;
    
    function CalculateFullPackSize(ABand: TvqControlBand): Integer;
    var
        APrev: TvqControlBand;
        ALeftSize: Integer;
    begin
        Result := 0;
        if ABand <> nil then begin
            Result := ABand.MinWidth;

            ALeftSize := 0;
            for APrev in ABand.Prevs do
                ALeftSize := Max(ALeftSize, CalculateFullPackSize(APrev));
            Result := Result + ALeftSize;
        end;
    end;
    
    procedure PushBand(ABand: TvqControlBand; AMaxRight: Integer);
    var
        APrev: TvqControlBand;
        AMinLeft: Integer;
    begin
        if ABand = nil then Exit;
        if ABand.Right > AMaxRight then begin
            // calculate min left
            AMinLeft := Client.Left;
            for APrev in ABand.Prevs do
                if APrev <> nil then
                    AMinLeft := Max(AMinLeft, APrev.Right);
            
            // locate band
            ABand.Right := AMaxRight;
            if ABand.Width < ABand.MinWidth then begin
                ABand.Width := ABand.MinWidth;
                ABand.Left := AMaxRight - ABand.MinWidth;
            end;

            {
            ABand.Left := AMaxRight - ABand.Width;
            if ABand.Left < AMinLeft then begin
                ABand.Left := AMinLeft;
                ABand.Width := AMaxRight - AMinLeft;
                if ABand.Width < ABand.MinWidth then begin
                    ABand.Width := ABand.MinWidth;
                    ABand.Left := AMaxRight - ABand.MinWidth;
                end;
            end;              }
            
            // new max right
            AMaxRight := ABand.Left;
            
            // push previous bands
            for APrev in ABand.Prevs do
                PushBand(APrev, AMaxRight);
        end;
    end;
    
var
    I, K, R, Y, RowY, OffsetY: Integer;
    ARow, AFullPackSize: Integer;
    ABand, APrev: TvqControlBand;
    ABandPos: TBandPosition;
    AControl: TControl;
    SortedBands: TvqControlBandArray;
    
begin
    
    // if FAligning then Exit;
    // FAligning := True;
    
    TRY

        //# new remembering protocol

    
    Client := ClientRect;
    AdjustClientRect(Client);
    
    // CHECK CHANGES
    
    for ABand in FBands do begin
        AControl := ABand.Control;
        if  (ABand.ControlLeft <> AControl.Left) or
            (ABand.ControlTop <> AControl.Top) or
            (ABand.ControlWidth <> AControl.Width) or
            (ABand.ControlHeight <> AControl.Height) then begin
            // bounds changed by user
            FRecalculateBands := True;
            if AControl.Visible then
                ABand.AltControlMaxWidth := AControl.Width;
        end
        else if ABand.Visible <> AControl.Visible then
            FRecalculateBands := True;
    end;
    
    if FRecalculateBands then
        FResizing := False
    else begin
        if Client = FSaveClient then goto LBL_END; // no changes
        if FResizing then
            for ABand in FBands do
                if ABand.Visible then
                    ABand.RestoreBounds;
        goto LBL_RESIZING;
    end;
    
    // RECALCULATE BANDS
    
    BandPositions := nil;
    BandCount := Length(FBands);
    BandPosCount := 0;
    for ABand in FBands do begin
        AControl := ABand.Control;
        AControl.Align := alNone;
        
        Y := ABand.Control.Top {- BandPadding.Top} - Client.Top;
        if Y < 0 then Dec(Y, FRowSize - 1);
        ABand.Top := Client.Top + (Y div FRowSize)*FRowSize;
        ABand.Left := AControl.Left - BandPadding.Left - BandGrabSize;
        ABand.Height := CalculateBandHeight(ABand);
        ABand.Width := BandGrabSize + BandPadding.Left + AControl.Width + BandPadding.Right;
        ABand.RowCount := ABand.Height div FRowSize;
        ABand.Visible := AControl.Visible;
        
        ABand.MaxWidth := CalculateBandMaxWidth(ABand);
        ABand.MinWidth := CalculateBandMinWidth(ABand);
        
        if not ABand.Visible then
            ABand.Row := ABand.Top div FRowSize; // fixed
        
        SetLength(ABand.Nexts, ABand.RowCount);
        SetLength(ABand.Prevs, ABand.RowCount);
        for R := 0 to ABand.RowCount - 1 do begin
            ABand.Prevs[R] := nil;
            ABand.Nexts[R] := nil;
            AddBandPos(ABand, ABand.Left, ABand.Top + R*FRowSize);
        end;
    end;
    SetLength(BandPositions, BandPosCount);
    
    // SORT BANDS
    
    TBandSorter.Sort(
        TBandSorter.TTArray(BandPositions),
        TBandSorter.TComparerFunction(@CompareBandPositions), True);
    SetLength(SortedBands, BandCount);
    K := 0;
    for I := 0 to BandPosCount - 1 do
        if not BandPositions[I].SubBand then begin
            SortedBands[K] := BandPositions[I].Band;
            Inc(K);
        end;
    FBands := SortedBands;
    SortedBands := nil;
    
    // NORMALIZE ROWS
    
    FRowCount := 0;
    FHeads := nil;
    FTails := nil;
    
    if FBands <> nil then begin
        // CALCULATE ROW COUNT, ERASE EMPTY ROWS, OFFSET, HEADs, TAILs AND CONNECT BANDS
        SetLength(FHeads, BandPosCount);
        SetLength(FTails, BandPosCount);
        
        ABand := BandPositions[0].Band;
        ARow := 0;
        OffsetY := BandPositions[0].Y;
        RowY := BandPositions[0].Y;
        APrev := nil;
        FHeads[ARow] := ABand;
        
        //
        for I := 0 to BandPosCount - 1 do begin
            ABandPos := BandPositions[I];
            ABand := ABandPos.Band;
            
            if not ABand.Visible then Continue; //! don't connect invisible bands
            
            if ABandPos.Y <> RowY then begin // new row
                // add tail
                FTails[ARow] := APrev;
                // update values
                Inc(OffsetY, ABandPos.Y - (RowY + FRowSize));
                RowY := ABandPos.Y;
                Inc(ARow);
                // add head
                FHeads[ARow] := ABand;
                if not ABandPos.SubBand then
                   ABand.Row := ARow;  
                APrev := ABand;
            end
            else begin // same row
                // connect
                if not ABandPos.SubBand then
                    ABand.Row := ARow;
                ABand.Prevs[ARow - ABand.Row] := APrev;
                if APrev <> nil then
                    APrev.Nexts[ARow - APrev.Row] := ABand;
                APrev := ABand;
            end;
            
            Dec(ABandPos.Y, OffsetY);
            if not ABandPos.SubBand then
                ABandPos.Band.Top := ABandPos.Y;
            
        end;
        FTails[ARow] := APrev;
        FRowCount := ARow + 1;
        SetLength(FHeads, FRowCount);
        SetLength(FTails, FRowCount);
    end;
    
    // ALIGN BANDS HORIZONTALLY
    
    APrev := nil;
    for ABand in FHeads do begin
        if ABand = APrev then Continue;
        CorrectBandLeft(ABand, Client.Left);
        APrev := ABand;
    end;
    
LBL_RESIZING:
    
    // PACK BANDS
    
    APrev := nil;
    for ABand in FTails do begin
        if ABand = APrev then Continue;
        if (ABand <> nil) and (ABand.Right > Client.Right) then begin
            AFullPackSize := CalculateFullPackSize(ABand);
            PushBand(ABand, Max(Client.Right, AFullPackSize));
        end;
        APrev := ABand;
    end;
    
    for ABand in FBands do
        StickControl(ABand);
    Invalidate;
    
LBL_END:
    
    FSaveClient := Client;
    FRecalculateBands := False;
    
    FINALLY {FAligning := False;} END;
    
end;

procedure TvqControlBar.StickControl(ABand: TvqControlBand);
var
    AControl: TControl;
    ALeft, ATop, AWidth, AHeight: Integer;
begin
    if ABand = nil then Exit;
    ALeft := ABand.Left + BandGrabSize + BandPadding.Left;
    ATop := ABand.Top + BandPadding.Top;
    AWidth := ABand.Width - BandPadding.Left - BandPadding.Right - BandGrabSize;
    AHeight := ABand.Control.Height; // ABand.Height - BandPadding.Top - BandPadding.Bottom;
    if AWidth < 0 then AWidth := 0;
    if AHeight < 0 then AHeight := 0;
    AControl := ABand.Control;
    if (AControl.Left <> ALeft) or (AControl.Top <> ATop) or
        (AControl.Width <> AWidth) or (AControl.Height <> AHeight) then
        AControl.SetBounds(ALeft, ATop, AWidth, AHeight);
    ABand.ControlLeft := AControl.Left;
    ABand.ControlTop := AControl.Top;
    ABand.ControlWidth := AControl.Width;
    ABand.ControlHeight := AControl.Height;
end;

function TvqControlBar.BandFromPoint(P: TPoint): TvqControlBand;
var
    ABand: TvqControlBand;
begin
    Result := nil;
    for ABand in FBands do
        if ABand.Visible and PtInRect(ABand.BandRect, P) then begin
            Result := ABand;
            Break;
        end;
end;

var
    MsgLabel2Num: Integer = 0;
    
procedure TvqControlBar.CalculateMetrics;
begin
    FBandGrabSize := vqThemeManager.ControlBandGrabSize;
    FBandPadding := Rect(0, 0, 10000, 10000); // so big rect
    FBandPadding := vqThemeManager.ControlBandContentRect(FBandPadding);
    FBandPadding.Right := 10000 - FBandPadding.Right;
    FBandPadding.Bottom := 10000 - FBandPadding.Bottom;
end;

procedure TvqControlBar.UpdateMetrics;
begin
    CalculateMetrics;
    InvalidatePreferredSize;
    AdjustSize;
    inherited;
end;

procedure TvqControlBar.Resize;
var
    ANext, ABand: TvqControlBand;
    HasGlue: Boolean;
begin
    inherited;
                {
    if MsgLAbelTwo <> nil then begin

        Inc(MsgLAbel2Num);
        MsgLabelTwo.Caption := IntToStr(MsgLabel2Num);
        MsgLabelTwo.Repaint;

    end;       }

    if (not FResizing) and (not FMoving) then begin
        FResizing := True;
        for ABand in FBands do begin
            if not ABand.Visible then Continue;
            ABand.StoreBounds;
            
            HasGlue := True;
            for ANext in ABand.Nexts do
                if ANext <> nil then begin
                    HasGlue := False;
                    Break;
                end;
            if HasGlue and (ABand.Right >= FSaveClient.Right) then
                ABand.SaveWidth := ABand.MaxWidth;
        end;
    end;
end;

procedure TvqControlBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseDown(Button, Shift, X, Y);
    if Button = mbLeft then begin
        FMoveAnchor := Point(X, Y);
        FMoveBand := BandFromPoint(Point(X, Y));
        if FMoveBand <> nil then begin
            FSaveBand.X := FMoveBand.Left;
            FSaveBand.Y := FMoveBand.Top;
        end;
        FMoving := False;
    end;
end;

procedure TvqControlBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
    Dx, Dy, MoveX: Integer;
begin
    inherited MouseMove(Shift, X, Y);
    if (ssLeft in Shift) and (FMoveBand <> nil) then begin
        Dx := X - FMoveAnchor.X;
        Dy := Y - FMoveAnchor.Y;
        if not FMoving then
            if (Abs(Dx) > MoveThreshold) or (Abs(Dy) > MoveThreshold) then
                BeginMove(FMoveBand);
        if FMoving then begin
            MoveX := FSaveBand.X + Dx;
            MoveBand(FMoveBand, MoveX, FSaveBand.Y + Dy + FRowSize div 2, True);
        end;
    end
    else begin
        if BandFromPoint(Point(X, Y)) <> nil then
            Cursor := crSizeAll
        else
            Cursor := crDefault;
    end;
end;

procedure TvqControlBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    inherited MouseUp(Button, Shift, X, Y);
    if FMoving then
        EndMove(FMoveBand);
end;

procedure TvqControlBar.BeginMove(AMoveBand: TvqControlBand);
var
    ABand, ANext, APrev: TvqControlBand;
    HasGlue: Boolean;
    R, ARight: Integer;
begin
    FResizing := False;
    FMoving := True;
    
    for ABand in FBands do
        if ABand.Visible then
            ABand.StoreBounds;
    for R := 0 to AMoveBand.RowCount - 1 do begin
        APrev := AMoveBand.Prevs[R];
        ANext := AMoveBand.Nexts[R];
        if APrev <> nil then begin
            APrev.SaveWidth := APrev.MaxWidth;
            if ANext <> nil then
                if APrev.SaveLeft + APrev.SaveWidth > ANext.SaveLeft then
                    APrev.SaveWidth := ANext.SaveLeft - APrev.SaveLeft;
        end;
    end;
end;

// X: the left position for band
// Y: the top position for band
procedure TvqControlBar.MoveBand(AMoveBand: TvqControlBand; X, Y: Integer; ByMouse: Boolean = False);
var
    Client: TRect;
    APrevs: TvqControlBandArray;
    ANexts: TvqControlBandArray;

    function CalculateLeftFullPackSize(ABand: TvqControlBand): Integer;
    var
        APrev: TvqControlBand;
        ALeftSize: Integer;
    begin
        Result := 0;
        if ABand <> nil then begin
            Result := ABand.MinWidth;
            ALeftSize := 0;
            for APrev in ABand.Prevs do
                ALeftSize := Max(ALeftSize, CalculateLeftFullPackSize(APrev));
            Result := Result + ALeftSize;
        end;
    end;
    
    function CalculateRightFullPackSize(ABand: TvqControlBand): Integer;
    var
        ANext: TvqControlBand;
        ARightSize: Integer;
    begin
        Result := 0;
        if ABand <> nil then begin
            Result := ABand.MinWidth;
            ARightSize := 0;
            for ANext in ABand.Nexts do
                ARightSize := Max(ARightSize, CalculateRightFullPackSize(ANext));
            Result := Result + ARightSize;
        end;
    end;
    
    procedure PushBandLeft(ABand: TvqControlBand; AMaxRight: Integer);
    var
        APrev: TvqControlBand;
        AMinLeft: Integer;
    begin
        if ABand = nil then Exit;
        if ABand.Right > AMaxRight then begin
            // calculate min left
            AMinLeft := Client.Left;
            for APrev in ABand.Prevs do
                if APrev <> nil then
                    AMinLeft := Max(AMinLeft, APrev.Right);
            
            // locate band
            ABand.Right := AMaxRight;
            if ABand.Width < ABand.MinWidth then begin
                ABand.Width := ABand.MinWidth;
                ABand.Left := AMaxRight - ABand.MinWidth;
            end;
            {
            ABand.Left := AMaxRight - ABand.Width;
            if ABand.Left < AMinLeft then begin
                ABand.Left := AMinLeft;
                ABand.Width := AMaxRight - AMinLeft;
                if ABand.Width < ABand.MinWidth then begin
                    ABand.Width := ABand.MinWidth;
                    ABand.Left := AMaxRight - ABand.MinWidth;
                end;
            end;
            }
            // new max right
            AMaxRight := ABand.Left;
            
            // push previous bands
            for APrev in ABand.Prevs do
                PushBandLeft(APrev, AMaxRight);
        end;
    end;
    
    procedure PushBandRight(ABand: TvqControlBand; AMinLeft: Integer);
    var
        ANext: TvqControlBand;
        AMaxRight, AOldRight: Integer;
    begin
        if ABand = nil then Exit;
        if ABand.Left < AMinLeft then begin
            // calculate max right
            AMaxRight := Client.Right;
            for ANext in ABand.Nexts do
                if ANext <> nil then
                    AMaxRight := Min(AMaxRight, ANext.Right);
                
            // locate band
            AOldRight := ABand.Right;
            ABand.Left := AMinLeft;
            ABand.Right := AOldRight;
            if ABand.Width < ABand.MinWidth then
                ABand.Width := ABand.MinWidth;
            {
            ABand.Left := AMinLeft;
            if ABand.Right > AMaxRight then begin
                ABand.Right := AMaxRight;
                if ABand.Width < ABand.MinWidth then
                    ABand.Width := ABand.MinWidth;
            end;
            }
            
            // new min left
            AMinLeft := ABand.Right;
            
            // push next bands
            for ANext in ABand.Nexts do
                PushBandRight(ANext, AMinLeft);
        end;
    end;
    
var
    OldRow, Row, R, RowInc, OffsetY, NewRowCount, NewRow: Integer;
    AMinLeft, AMaxRight: Integer;
    ABand, APrev, ANext, AUp: TvqControlBand;
    NewHeads, NewTails: TvqControlBandArray;
    ARight, AMagneticLeft, AMagneticDelta: Integer;
    
begin
    if FAligning then Exit;
    FAligning := True;
    TRY 
        
        {
        - calculate position
        - check out of bounds
        - find ustitch location for insertion
        - check unstitch location for space
        - if has space
            - disconect MoveBand and stitch gap
            - restore memory
            - find magnetic position
            - unstitch the location
            - push left if necesary
            - locate MoveBand
            - resize MoveBand if necesary
            - push right if necesary
            - connect MoveBand
            - erase empty rows
            - stick controls
        - else
            - nothing
        }
        
        // calculate Row and offset
        
        Client := ClientRect;
        AdjustClientRect(Client);

        if FHorizontalOnly then
            Row := AMoveBand.Row
        else if Y < Client.Top then
            Row := -1
        else begin
            Row := (Y - Client.Top) div FRowSize;
            if Row >= FRowCount then Row := FRowCount;
        end;
        
        // check for out of bounds

        if Row = -1 then begin
            // add new empty row
            SetLength(FHeads, FRowCount + 1);
            SetLength(FTails, FRowCount + 1);
            for R := FRowCount downto 1 do begin
                FHeads[R] := FHeads[R - 1];
                FTails[R] := FTails[R - 1];
            end;
            FHeads[0] := nil;
            FTails[0] := nil;
            Inc(FRowCount);
            Row := 0;

            // offset bands in graph
            for ABand in FBands do
                if ABand.Visible then begin
                    ABand.Top := ABand.Top + FRowSize;
                    ABand.Row := ABand.Row + 1;
                end;
        end
        else if Row + AMoveBand.RowCount > FRowCount then begin
            RowInc := Row + AMoveBand.RowCount - FRowCount;
            SetLength(FHeads, FRowCount + RowInc);
            SetLength(FTails, FRowCount + RowInc);
            for R := FRowCount to FRowCount + RowInc - 1 do begin
                FHeads[R] := nil;
                FTails[R] := nil;
            end;
            Inc(FRowCount, RowInc);
        end;
        OldRow := AMoveBand.Row;
        
        // find insertion location
        
        SetLength(APrevs, AMoveBand.RowCount);
        SetLength(ANexts, AMoveBand.RowCount);
        for R := Row to Row + AMoveBand.RowCount - 1 do begin
            APrev := nil;
            ANext := FHeads[R];
            if ANext = AMoveBand then
                ANext := ANext.Nexts[R - ANext.Row];
            while (ANext <> nil) and (ANext.SaveLeft < X) do begin // use saved positions
                APrev := ANext;
                ANext := ANext.Nexts[R - ANext.Row];
                if ANext = AMoveBand then
                    ANext := ANext.Nexts[R - ANext.Row];
            end;

            APrevs[R - Row] := APrev;
            ANexts[R - Row] := ANext;
        end;
        
        // calculate space 
        
        AMinLeft := 0;
        for APrev in APrevs do
            AMinLeft := Max(AMinLeft, CalculateLeftFullPackSize(APrev));
        AMinLeft := AMinLeft + Client.Left;
        
        AMaxRight := 0;
        for ANext in ANexts do
            AMaxRight := Max(AMaxRight, CalculateRightFullPackSize(ANext));
        AMaxRight := Client.Right - AMaxRight;
        
        // move if has space
        
        if AMaxRight - AMinLeft >= AMoveBand.MinWidth then begin

            // disconect moveband

            for R := 0 to AMoveBand.RowCount - 1 do begin
                APrev := AMoveBand.Prevs[R];
                ANext := AMoveBand.Nexts[R];
                if APrev = nil then
                    FHeads[OldRow + R] := ANext
                else
                    APrev.Nexts[R + OldRow - APrev.Row] := ANext;
                if ANext = nil then
                    FTails[OldRow + R] := APrev
                else
                    ANext.Prevs[R + OldRow - ANext.Row] := APrev;
            end;

            // reconect moveband

            for R := 0 to AMoveBand.RowCount - 1 do begin
                APrev := APrevs[R];
                ANext := ANexts[R];
                AMoveBand.Prevs[R] := APrev;
                if APrev = nil then
                    FHeads[Row + R] := AMoveBand
                else
                    APrev.Nexts[R + Row - APrev.Row] := AMoveBand;
                AMoveBand.Nexts[R] := ANext;
                if ANext = nil then
                    FTails[Row + R] := AMoveBand
                else
                    ANext.Prevs[R + Row - ANext.Row] := AMoveBand;
            end;
            AMoveBand.Row := Row;
            AMoveBand.Top := Row*FRowSize;

            // restore memory

            for ABand in FBands do
                if (ABand.Visible) and (ABand <> AMoveBand) then begin
                    ABand.RestoreBounds;   
                end;

            // find magnetic position

            if FMagnetic and ByMouse then begin
                AMagneticDelta := MagneticThreshold;
                for APrev in APrevs do begin
                    if APrev = nil then
                        AMagneticLeft := Client.Left
                    else
                        AMagneticLeft := APrev.Right;
                    if Abs(X - AMagneticLeft) < AMagneticDelta then begin
                        AMagneticDelta := Abs(X - AMagneticLeft);
                        X := AMagneticLeft;
                    end;
                end;
            end;

            // locate moveband
            
            AMoveBand.Left := Max(X, AMinLeft);
            ARight := Client.Right;
            for ANext in AMoveBand.Nexts do
                if ANext <> nil then
                    ARight := Min(ARight, ANext.Left);
            AMoveBand.Right := ARight;
            if AMoveBand.Width > AMoveBand.MaxWidth then
                AMoveBand.Width := AMoveBand.MaxWidth
            else if AMoveBand.Width < AMoveBand.MinWidth then begin
                AMoveBand.Width := AMoveBand.MinWidth;
                if AMoveBand.Right > AMaxRight then
                    AMoveBand.Left := AMaxRight - AMoveBand.Width;
            end;

            //# correct glue algorithm
            //# correct band min-max width algorithm and policy

            // push left
            
            AUp := nil;
            for APrev in APrevs do begin
                if APrev = AUp then Continue;
                if (APrev <> nil) and (APrev.Right > AMoveBand.Left) then
                    PushBandLeft(APrev, AMoveBand.Left);
                AUp := APrev;
            end;
            
            // push right
            
            AUp := nil;
            for ANext in ANexts do begin
                if ANext = AUp then Continue;
                if (ANext <> nil) and (ANext.Left < AMoveBand.Right) then
                    PushBandRight(ANext, AMoveBand.Right);
                AUp := ANext;
            end;
            
            // erase empty rows

            NewRow := 0;  
            SetLength(NewHeads, FRowCount);
            SetLength(NewTails, FRowCount);
            for R := 0 to FRowCount - 1 do
                if FHeads[R] <> nil then begin
                    // offset top
                    ABand := FHeads[R];
                    while ABand <> nil do begin
                        if ABand.Row = R then
                            ABand.Top := NewRow*FRowSize;
                        ABand := ABand.Nexts[R - ABand.Row];
                    end;
                    // new head-tail
                    NewHeads[NewRow] := FHeads[R];
                    NewTails[NewRow] := FTails[R];

                    Inc(NewRow);
                end;
            SetLength(NewHeads, NewRow);
            SetLength(NewTails, NewRow);
            FRowCount := NewRow;
            FHeads := NewHeads;
            FTails := NewTails;
            // update new rows
            for ABand in FBands do   
                if ABand.Visible then
                    ABand.Row := ABand.Top div FRowSize;
            
            DoBandMove(AMoveBand);
            
            // stick
            
            for ABand in FBands do
                StickControl(ABand);
            Repaint;
            
        end;
        
    FINALLY FAligning := False; END;
    
end;

procedure TvqControlBar.EndMove(AMoveBand: TvqControlBand);
begin
    //# reorder bands
    FResizing := False;
    FMoving := False;
end;

procedure TvqControlBar.DoBandMove(AMoveBand: TvqControlBand);
begin
    if Assigned(FOnBandMove) then FOnBandMove(Self, AMoveBand);
end;

procedure TvqControlBar.DoBandPaint(ABand: TvqControlBand; ACanvas: TCanvas; ARect: TRect);
begin
    if Assigned(FOnBandPaint) then FOnBandPaint(Self, ABand, ACanvas, ARect);
end;

function TvqControlBar.BandGrabSize: Integer;
begin
    Result := FBandGrabSize;
end;

function TvqControlBar.BandPadding: TRect;
begin 
    Result := FBandPadding;
end;

procedure TvqControlBar.DrawBand(ABand: TvqControlBand);
var
    ARect: TRect;
    AState: TvqThemeState;
begin
    if ABand = nil then Exit;
    ARect := ABand.BandRect;
    if ABand.Enabled then 
        AState := [vqthNormal]
    else
        AState := [vqthDisabled];
    vqThemeManager.DrawControlBand(ABand, Canvas, ARect, AState);
    DoBandPaint(ABand, Canvas, ARect);
end;

procedure TvqControlBar.Paint;
var
    ABand: TvqControlBand;
    AState: TvqThemeState;
begin
    if Enabled then AState := [vqthNormal]
    else AState := [vqthDisabled];
    vqThemeManager.DrawControlBar(Self, Canvas, ClientRect, AState);
    for ABand in FBands do
        if ABand.Visible then
            DrawBand(ABand);
    inherited Paint;
end;

end.
