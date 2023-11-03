// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqScrollingControl;

interface

uses
    InterfaceBase, LCLIntf, LCLType, LMessages, LResources,
    Types, Classes, Graphics, Controls, Forms, StdCtrls, SysUtils, Math,
    ExtCtrls, Dialogs,
    vqUtils, vqThemes;
    
type
    
    { TvqScrollingControl }

    TvqScrollingControl = class(TvqCustomControl)
    private
        FDrawUpdatingScroll: Boolean;
        FUpdatingScroll: Boolean;
        
        FVertScrollVisible: Boolean;
        FHorzScrollVisible: Boolean;
    protected
        FLastVertScrollInfo: TScrollInfo;
        FLastHorzScrollInfo: TScrollInfo;
    private
        
        FVertInc: TScrollBarInc;
        FHorzInc: TScrollBarInc;
        FScrollBars: TScrollStyle;
        
        procedure SetLeftOffset(Value: Integer);
        procedure SetTopOffset(Value: Integer);
        procedure SetScrollBars(Value: TScrollStyle);
        
        procedure WMHScroll(var Msg: TLMScroll); message LM_HSCROLL;
        procedure WMVScroll(var Msg: TLMScroll); message LM_VSCROLL;
        procedure SetShowScrollBar(SB: Integer; AShow: Boolean);
    protected
        FLeftOffset: Integer;
        FTopOffset: Integer;
        FPainting: Boolean;       
        function MaxLeftOffset: Integer;
        function MaxTopOffset: Integer;
    protected
        property UpdatingScroll: Boolean read FUpdatingScroll;
        function ScrollDocSize: TSize; virtual;
        
        function SetOffset(ALeftOffset, ATopOffset: Integer): Boolean; virtual;
        function UpdateScrollBars: Boolean; virtual;
        procedure ChangingOffset; virtual;
        procedure OffsetChanged; virtual;
        
        function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
        procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; Handled: Boolean); virtual;
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        
        procedure WndProc(var Message: TLMessage); override;
        procedure Resize; override;
        procedure Paint; override;
        procedure BorderChanged; override;
        
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Invalidate; override;            
        procedure EraseBackground(DC: HDC); override;
        
        property LeftOffset: Integer read FLeftOffset write SetLeftOffset;
        property TopOffset: Integer read FTopOffset write SetTopOffset;
        property VertInc: TScrollBarInc read FVertInc write FVertInc;
        property HorzInc: TScrollBarInc read FHorzInc write FHorzInc;
    published
        property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars default ssAutoBoth;
    end;
    
implementation

{ TvqScrollingControl }

constructor TvqScrollingControl.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FPainting := False;
    FScrollBars := ssNone;
    
    FVertInc := 5;
    FHorzInc := 5;
    
    FVertScrollVisible := False;
    FHorzScrollVisible := False;
    FillChar(FLastHorzScrollInfo, SizeOf(FLastHorzScrollInfo), 0);
    FillChar(FLastVertScrollInfo, SizeOf(FLastVertScrollInfo), 0);
    
end;

destructor TvqScrollingControl.Destroy;
begin
    inherited;
end;

procedure TvqScrollingControl.Invalidate;
begin
    if not FPainting then
        inherited Invalidate;
end;

procedure TvqScrollingControl.EraseBackground(DC: HDC);
begin
    // do nothing
end;

procedure TvqScrollingControl.WndProc(var Message: TLMessage); 
begin
    if (Message.Msg = LM_LBUTTONDOWN) and CanFocus and not (csNoFocus in ControlStyle) then
        SetFocus;
    inherited;
end;

procedure TvqScrollingControl.BorderChanged;
begin
    inherited;
    if Parent <> nil then
        UpdateScrollBars;
end;

procedure TvqScrollingControl.Resize;
begin
    inherited;
end;

procedure TvqScrollingControl.Paint;
begin
    if FUpdatingScroll then
        FDrawUpdatingScroll := True;
    inherited;
end;

procedure TvqScrollingControl.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
begin
    PreferredWidth := 0;
    PreferredHeight := 0;
end;

procedure TvqScrollingControl.SetScrollBars(Value: TScrollStyle);             
begin
    if FScrollBars <> Value then begin
        FScrollBars := Value;
        UpdateScrollBars;
    end;
end;

procedure TvqScrollingControl.SetLeftOffset(Value: Integer);
begin
    SetOffset(Value, FTopOffset);
end;

procedure TvqScrollingControl.SetTopOffset(Value: Integer);
begin
    SetOffset(FLeftOffset, Value);
end;

function TvqScrollingControl.ScrollDocSize: TSize;
begin
    Result := Size(1, 1);
end;

procedure TvqScrollingControl.MouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; Handled: Boolean);
begin
end;

function TvqScrollingControl.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var
    LeftWheelOffset, TopWheelOffset: Integer;
begin
    Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
    if not Result then
        MouseWheel(Shift, WheelDelta, MousePos, Result);
    if not Result then begin
        LeftWheelOffset := FLeftOffset;
        TopWheelOffset :=  FTopOffset;

        if (ssShift in Shift) and FHorzScrollVisible then
            Inc(LeftWheelOffset, -WheelDelta)
        else if FVertScrollVisible then
            Inc(TopWheelOffset, -WheelDelta)
        else if FHorzScrollVisible then
            Inc(LeftWheelOffset, -WheelDelta);

        SetOffset(LeftWheelOffset, TopWheelOffset);
        Result := True;
    end;
end;

function TvqScrollingControl.SetOffset(ALeftOffset, ATopOffset: Integer): Boolean;
var
    ScrollFlags, DeltaX, DeltaY: Integer;
    ScrollArea: TRect;
    HorzInfo, VertInfo: TScrollInfo;
begin
    if (ALeftOffset <> FLeftOffset) or (ATopOffset <> FTopOffset) then begin
        if ALeftOffset < 0 then ALeftOffset := 0;
        if ALeftOffset > MaxLeftOffset then ALeftOffset := MaxLeftOffset;
        if ATopOffset < 0 then ATopOffset := 0;
        if ATopOffset > MaxTopOffset then ATopOffset := MaxTopOffset;
        if (ALeftOffset = FLeftOffset) and (ATopOffset = FTopOffset) then Exit(False);
        ChangingOffset;
        
        DeltaX := FLeftOffset - ALeftOffset;
        DeltaY := FTopOffset - ATopOffset;

        FLeftOffset := ALeftOffset;
        FTopOffset := ATopOffset;
        ScrollFlags := SW_INVALIDATE or SW_ERASE{ or SW_SCROLLCHILDREN};
        ScrollArea := ClientRect;
        ScrollWindowEx(Handle, DeltaX, DeltaY, @ScrollArea, @ScrollArea, 0, nil, ScrollFlags);
        
        // move scrollbars
        if FHorzScrollVisible then begin
            HorzInfo.cbSize := SizeOf(HorzInfo);
            HorzInfo.fMask := SIF_ALL or SIF_DISABLENOSCROLL;
            HorzInfo.nTrackPos := 0;
            HorzInfo.nMin := 0;
            
            HorzInfo.nPage := Max(1, ClientWidth);
            HorzInfo.nMax := Max(0, ScrollDocSize.cx);
            HorzInfo.nPos := FLeftOffset;
            if not CompareMem(@HorzInfo, @FLastHorzScrollInfo, SizeOf(TScrollInfo)) then
                SetScrollInfo(Handle, SB_HORZ, HorzInfo, True);
            FLastHorzScrollInfo := HorzInfo;
        end
        else
            FLastHorzScrollInfo.cbSize := 0;
        
        if FVertScrollVisible then begin
            VertInfo.cbSize := SizeOf(VertInfo);
            VertInfo.fMask := SIF_ALL or SIF_DISABLENOSCROLL;
            VertInfo.nTrackPos := 0;
            VertInfo.nMin := 0;

            VertInfo.nPage := Max(1, ClientHeight);
            VertInfo.nMax := Max(0, ScrollDocSize.cy);
            VertInfo.nPos := FTopOffset;
            if not CompareMem(@VertInfo, @FLastVertScrollInfo, SizeOf(TScrollInfo)) then
                SetScrollInfo(Handle, SB_VERT, VertInfo, True);
            FLastVertScrollInfo := VertInfo;
        end
        else
            FLastVertScrollInfo.cbSize := 0;
        
        // offset changed
        OffsetChanged;

        Exit(True);
    end;
    Exit(False);
end;

function TvqScrollingControl.UpdateScrollBars: Boolean;
var
    ScrollBarSize,
    ADocSize: TSize;
    AContent, // inner rect
    AClient: TRect; // rect without scrollbars
    VertInfo, HorzInfo: TScrollInfo;
    VertShow, HorzShow, OffsetModified: Boolean;
    NewLeftOffset, NewTopOffset: Integer;
begin
    if FUpdatingScroll then Exit;
    FUpdatingScroll := True;
    // calculate Client
    ScrollBarSize.cx := WidgetSet.GetSystemMetrics(SM_CXVSCROLL);
    ScrollBarSize.cy := WidgetSet.GetSystemMetrics(SM_CYHSCROLL);
    AClient := ClientRect;
    if FVertScrollVisible then Inc(AClient.Right, ScrollBarSize.cy);
    if FHorzScrollVisible then Inc(AClient.Bottom, ScrollBarSize.cx);
    
    // initial values
    ADocSize := ScrollDocSize;
    AContent := AClient;
    
    // initialize scroll info
    VertShow := False;
    HorzShow := False;
    
    // calculate scrolls
    if (AContent.Width <= ScrollBarSize.cx) or (AContent.Height <= ScrollBarSize.cy) then begin
        // no show
    end
    else begin
        case ScrollBars of
            ssBoth: 
                begin
                    Dec(AContent.Right, ScrollBarSize.cx);
                    Dec(AContent.Bottom, ScrollBarSize.cy);
                    VertShow := True;
                    HorzShow := True;
                end;
            ssVertical: 
                begin
                    Dec(AContent.Right, ScrollBarSize.cx);
                    VertShow := True;
                end;
            ssHorizontal:
                begin
                    Dec(AContent.Bottom, ScrollBarSize.cy);
                    HorzShow := True;
                end;
            ssAutoBoth: begin
                if AContent.Height < ADocSize.Height then begin
                    Dec(AContent.Right, ScrollBarSize.cx);
                    VertShow := True;
                    if AContent.Width < ADocSize.Width then begin
                        Dec(AContent.Bottom, ScrollBarSize.cy);
                        HorzShow := True;
                    end;
                end
                else if AContent.Width < ADocSize.Width then begin
                    Dec(AContent.Bottom, ScrollBarSize.cy);
                    HorzShow := True;
                    if AContent.Height < ADocSize.Height then begin
                        Dec(AContent.Right, ScrollBarSize.cx);
                        VertShow := True;
                    end;
                end;
            end;
            ssAutoVertical:
                if AContent.Height < ADocSize.Height then begin
                    Dec(AContent.Right, ScrollBarSize.cx);
                    VertShow := True;
                end;
            ssAutoHorizontal: 
                if AContent.Width < ADocSize.Width then begin
                    Dec(AContent.Bottom, ScrollBarSize.cy);
                    HorzShow := True;
                end;
        end;
    end;
    
    // checking offset
    OffsetModified := False;
    NewLeftOffset := FLeftOffset;
    NewTopOffset := FTopOffset;
    if NewLeftOffset > ADocSize.cx - AContent.Width then
        NewLeftOffset := ADocSize.cx - AContent.Width;
    if NewLeftOffset < 0 then NewLeftOffset := 0;
    if NewTopOffset > ADocSize.cy - AContent.Height then
        NewTopOffset := ADocSize.cy - AContent.Height;
    if NewTopOffset < 0 then NewTopOffset := 0;
    if (NewLeftOffset <> FLeftOffset) or (NewTopOffset <> FTopOffset) then begin
        ChangingOffset;
        FLeftOffset := NewLeftOffset;
        FTopOffset := NewTopOffset;
        OffsetModified := True;
    end;
    
    FDrawUpdatingScroll := False;
    // show and move scrollbars
    SetShowScrollBar(SB_VERT, VertShow);
    ADocSize := ScrollDocSize; // update after show/hide scroll when wordwraps
    if VertShow then begin
        VertInfo.cbSize := SizeOf(VertInfo);
        VertInfo.fMask := SIF_ALL or SIF_DISABLENOSCROLL;
        VertInfo.nTrackPos := 0;
        VertInfo.nMin := 0;
        
        VertInfo.nPage := Max(1, AContent.Height);
        VertInfo.nMax := Max(0, ADocSize.cy);
        VertInfo.nPos := FTopOffset;
        if not CompareMem(@VertInfo, @FLastVertScrollInfo, SizeOf(TScrollInfo)) then begin
            SetScrollInfo(Handle, SB_VERT, VertInfo, True);
        end;
        FLastVertScrollInfo := VertInfo;
    end
    else
        FLastVertScrollInfo.cbSize := 0;
    
    SetShowScrollBar(SB_HORZ, HorzShow);
    if HorzShow then begin
        HorzInfo.cbSize := SizeOf(HorzInfo);
        HorzInfo.fMask := SIF_ALL or SIF_DISABLENOSCROLL;
        HorzInfo.nTrackPos := 0;
        HorzInfo.nMin := 0;
        
        HorzInfo.nPage := Max(1, AContent.Width);
        HorzInfo.nMax := Max(0, ADocSize.cx);
        HorzInfo.nPos := FLeftOffset;
        if not CompareMem(@HorzInfo, @FLastHorzScrollInfo, SizeOf(TScrollInfo)) then
            SetScrollInfo(Handle, SB_HORZ, HorzInfo, True);
        FLastHorzScrollInfo := HorzInfo;
    end
    else
        FLastHorzScrollInfo.cbSize := 0;
    Result := FDrawUpdatingScroll;
    
    // client changed
    // if PrevClientWidth <> ClientWidth then 
    //     ClientChanged;
    // offset changed
    if OffsetModified then
        OffsetChanged;
    
    FUpdatingScroll := False;
end;

procedure TvqScrollingControl.ChangingOffset;
begin
end;

procedure TvqScrollingControl.OffsetChanged;
begin
end;

procedure TvqScrollingControl.WMHScroll(var Msg: TLMScroll);
begin
    case Msg.ScrollCode of
        SB_LEFT         : LeftOffset := 0;
        SB_RIGHT        : LeftOffset := MaxLeftOffset;
        SB_LINERIGHT    : LeftOffset := LeftOffset + HorzInc;
        SB_LINELEFT     : LeftOffset := LeftOffset - HorzInc;
        SB_PAGERIGHT    : LeftOffset := LeftOffset + ClientWidth;
        SB_PAGELEFT     : LeftOffset := LeftOffset - ClientWidth;
        SB_THUMBPOSITION: LeftOffset := Msg.Pos;
        SB_THUMBTRACK   : LeftOffset := Msg.Pos;
        SB_ENDSCROLL    : Invalidate;
    end;
end;

procedure TvqScrollingControl.WMVScroll(var Msg: TLMScroll);
begin
    case Msg.ScrollCode of
        SB_TOP          : TopOffset := 0;
        SB_BOTTOM       : TopOffset := MaxTopOffset;
        SB_LINEDOWN     : TopOffset := TopOffset + VertInc;
        SB_LINEUP       : TopOffset := TopOffset - VertInc;
        SB_PAGEDOWN     : TopOffset := TopOffset + ClientHeight;
        SB_PAGEUP       : TopOffset := TopOffset - ClientHeight;
        SB_THUMBPOSITION: TopOffset := Msg.Pos;
        SB_THUMBTRACK   : TopOffset := Msg.Pos;
        SB_ENDSCROLL    : Invalidate;
    end;
end;

procedure TvqScrollingControl.SetShowScrollBar(SB: Integer; AShow: Boolean);
begin
    if ((SB = SB_HORZ) and (FHorzScrollVisible <> AShow)) or
       ((SB = SB_VERT) and (FVertScrollVisible <> AShow))
    then begin
        ShowScrollBar(Handle, SB, AShow);
    end;
    if SB = SB_HORZ then FHorzScrollVisible := AShow;
    if SB = SB_VERT then FVertScrollVisible := AShow;
end;

function TvqScrollingControl.MaxTopOffset: Integer;
begin
    Result := ScrollDocSize.cy - ClientHeight;
    if Result < 0 then Result := 0;
end;

function TvqScrollingControl.MaxLeftOffset: Integer;
begin
    Result := ScrollDocSize.cx - ClientWidth;
    if Result < 0 then Result := 0;
end;

end.

