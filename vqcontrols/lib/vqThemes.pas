// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqThemes;

interface

uses             
    InterfaceBase, LclIntf, LclType, LMessages, LResources, IntfGraphics,
    Types, SysUtils, Classes, Graphics, Controls, Math, GraphType, StdCtrls, ImgList,
    ExtCtrls, Themes, Forms,
    BGRABitmap, BGRACanvas, BGRABitmapTypes,
    vqUtils;

type
    
    TvqThemeStateElement = (
        vqthNormal, vqthHot, vqthPressed, vqthDisabled, 
        vqthHovered, 
        vqthSelected, vqthDefaulted, vqthFocused);
    
    TvqThemeState = set of TvqThemeStateElement;
    
    TvqThemeManager = class(TPersistent)
    private
        FOnApply: TNotifyEvent;
    private
        FBackBmp: TBitmap;
        FSysImages: TImageList;
        FSwitchImages: TImageList; // [-,-,-,-,o,o,o,o]

    protected const
        FontImageIndex = 0;
        MenuImageIndex = 3;
        MiscImageIndex = 7;
        HChevronImageIndex = MiscImageIndex + 0;
        VChevronImageIndex = MiscImageIndex + 1;
        ClearImageIndex = MiscImageIndex + 2;
    protected
        procedure DoApply; virtual;
    public
        constructor Create; virtual;
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        function Apply: Boolean; virtual;
        procedure Refresh; virtual;
    public // misc
        CaptionFore: TColor;
        CaptionBack: TColor;
        
        InnerBack: TColor;
        OuterBack: TColor;
        
        DisabledFore: TColor;
        DisabledBack: TColor;
        TextFore: TColor;
        TextBack: TColor;
        HiliteFore: TColor;
        HiliteBack: TColor;
        BevelColor: TColor;
        CaretColor: TColor;
        TickColor: TColor;

        AlphaWhite: TColor;
        AlphaBlack: TColor;
        AlphaSize: Integer;

        function FontTypeIconSize(FontType: Longint): TSize; virtual;
        procedure DrawFontTypeIcon(Control: TControl; Canvas: TCanvas; FontType: Longint; R: TRect; Enabled: Boolean); virtual;
        procedure DrawFontTypeIcon(Control: TControl; Canvas: TCanvas; FontType: Longint; X, Y: Integer; Enabled: Boolean); virtual;
        procedure DrawArrowGlyph(Control: TControl; Canvas: TCanvas; R: TRect; Dir: TvqArrowDirection; Enabled: Boolean); virtual;
        procedure DrawFocusRect(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawEdge(Control: TControl; Canvas: TCanvas; R: TRect; Edge, Flags: Cardinal); virtual;
    public // arrow
        procedure DrawArrowHorzUp(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawArrowHorzDown(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawArrowVertUp(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawArrowVertDown(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawArrowHorzSpacer(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawArrowVertSpacer(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // hint 
        function ToolTipContentRect(R: TRect): TRect; virtual;
        
        procedure DrawToolTip(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // divider
        function DividerThickness: Integer; virtual;
        
        procedure DrawHorzDivider(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawVertDivider(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawVertSpacer(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawHorzSpacer(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // buttons
        //" contentrect needs control and canvas
        function ButtonContentRect(R: TRect): TRect; virtual;
        
        procedure DrawFlatButton(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawButton(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawFlatButtonChecked(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawButtonChecked(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawFlatCloseButton(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawCloseButton(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // drop down
        function DropDownArrowSize: TSize; virtual;
        procedure DrawHorzFlatDropDownButton(Control: TControl; Canvas: TCanvas; R, Arrow: TRect; State, ArrowState: TvqThemeState); virtual;
        procedure DrawVertFlatDropDownButton(Control: TControl; Canvas: TCanvas; R, Arrow: TRect; State, ArrowState: TvqThemeState); virtual;
        procedure DrawHorzDropDownButton(Control: TControl; Canvas: TCanvas; R, Arrow: TRect; State, ArrowState: TvqThemeState); virtual;
        procedure DrawVertDropDownButton(Control: TControl; Canvas: TCanvas; R, Arrow: TRect; State, ArrowState: TvqThemeState); virtual;
        procedure DrawDropDownArrow(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // switch
        function SwitchSize: TSize; virtual;
        function RadioSize: TSize; virtual;
        function CheckSize: TSize; virtual;
        
        procedure DrawSwitchOn(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawSwitchOff(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawRadioOn(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawRadioOff(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawCheckOn(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawCheckOff(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawCheckGrayed(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // slider
        procedure DrawHorzSlider(Control: TControl; Canvas: TCanvas; Track, Knob: TRect; T, B: Boolean; State, KnobState: TvqThemeState); virtual;
        procedure DrawVertSlider(Control: TControl; Canvas: TCanvas; Track, Knob: TRect; L, R: Boolean; State, KnobState: TvqThemeState); virtual;
    public // dial
        procedure DrawDial(Control: TControl; Canvas: TCanvas; O: TPoint; Radius: Integer; Knob, KnobSize: Double; State, KnobState: TvqThemeState); virtual;
    public // tool bar
        function ToolBarChevronSize: TSize; virtual;
        
        procedure DrawHorzToolBarChevron(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawVertToolBarChevron(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // tool panel
        function ToolPanelFooterRect(R: TRect): TRect; virtual;
        function ToolPanelContentRect(R: TRect): TRect; virtual;

        procedure DrawToolPanel(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // controlbar
        function ControlBandGrabSize: Integer; virtual;
        function ControlBandContentRect(R: TRect): TRect; virtual;
        function ControlBarContentRect(R: TRect): TRect; virtual;
        
        procedure DrawControlBand(Band: TObject; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawControlBar(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // tab
        function TabContentRect(Page: TControl; Close: Boolean; R: TRect): TRect; virtual;
        function TabBodyContentRect(R: TRect): TRect; virtual;
        function TabCloseRect(R: TRect): TRect; virtual;
        
        // procedure DrawTabHeader(Page: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawTabBody(Page: TControl; Canvas: TCanvas; R, Tab: TRect; State: TvqThemeState); virtual;
        procedure DrawTab(Page: TControl; Canvas: TCanvas; R, Body: TRect; State: TvqThemeState); virtual;
        procedure DrawTabClose(Page: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawAddTab(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // notifier  
        function NotifierContentRect(R: TRect): TRect; virtual;
        
        procedure DrawNotifier(Control: TControl; Canvas: TCanvas; R: TRect; Color: TColor; State: TvqThemeState); virtual;
    public // edits
        function LineEditContentRect(R: TRect): TRect; virtual;
        function ClearButtonSize: TSize; virtual;
        function MRUDividerThickness: Integer; virtual;
        function SpinArrowSize: TSize; virtual;
        
        procedure DrawLineEditFrame(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawClearButton(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawMRUDivider(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawSpinBar(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawListItem(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // menu box
        function MenuCheckSize: TSize; virtual;
        function MenuSeparatorThickness: Integer; virtual;
        
        procedure DrawMenuHeader(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawMenuSeparator(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawMenuItem(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawMenuRadioOn(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawMenuRadioOff(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawMenuCheckOn(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
        procedure DrawMenuCheckOff(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // frame
        function FrameContentRect(R: TRect): TRect; virtual;
        procedure DrawFrame(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState); virtual;
    public // docking
        
    published
        property OnApply: TNotifyEvent read FOnApply write FOnApply;
    end;
    
var
    vqThemeManager: TvqThemeManager = nil;
    
implementation

constructor TvqThemeManager.Create;
begin
    inherited Create;
    FBackBmp := TBitmap.Create;
    FBackBmp.Width := 100;
    FBackBmp.Height := 100;
    FSysImages := TImageList.Create(nil);
    FSwitchImages := TImageList.Create(nil);
    Refresh;
end;

destructor TvqThemeManager.Destroy;
begin
    FreeAndNil(FBackBmp);
    FreeAndNil(FSysImages);
    FreeAndNil(FSwitchImages);
    inherited;
end;

procedure TvqThemeManager.Assign(Source: TPersistent);
begin
    if Source is TvqThemeManager then
        begin end
    else inherited;
end;

procedure TvqThemeManager.Refresh;
begin
    // colors
    
    CaptionFore := clCaptionText;
    CaptionBack := clBtnFace;
    InnerBack := clWhite;
    OuterBack := CaptionBack;
    DisabledFore := clGrayText;
    DisabledBack := CaptionBack;
    TextFore := clBlack;
    TextBack := clWhite;
    HiliteFore := clHighlightText;
    HiliteBack := clHighlight;
    BevelColor := clLead;
    CaretColor := clBlack;
    TickColor := clGray;

    AlphaWhite := clWhite;
    AlphaBlack := clSilver;
    AlphaSize := 8;
    
    // sysimages
    if FSysImages = nil then Exit;
    
    FSysImages.Clear;
    FSysImages.Width := 17;
    FSysImages.Height := 17;
    FSysImages.AddLazarusResource('RFont');
    FSysImages.AddLazarusResource('DFont');
    FSysImages.AddLazarusResource('TTFont');
    FSysImages.AddLazarusResource('MenuRadioOn');
    FSysImages.AddLazarusResource('MenuRadioOff');
    FSysImages.AddLazarusResource('MenuCheckOn');
    FSysImages.AddLazarusResource('MenuCheckOff');
    FSysImages.AddLazarusResource('HChevron');
    FSysImages.AddLazarusResource('VChevron');
    FSysImages.AddLazarusResource('ClearBtn');
    // switchimages
    if FSwitchImages = nil then Exit;
    
    FSwitchImages.Clear;
    FSwitchImages.Width := 40;
    FSwitchImages.Height := 17;
    FSwitchImages.AddLazarusResource('SwitchOn');
    FSwitchImages.AddLazarusResource('SwitchOnHot');
    FSwitchImages.AddLazarusResource('SwitchOnPressed');
    FSwitchImages.AddLazarusResource('SwitchOnDis');
    FSwitchImages.AddLazarusResource('SwitchOff');
    FSwitchImages.AddLazarusResource('SwitchOffHot');
    FSwitchImages.AddLazarusResource('SwitchOffPressed');
    FSwitchImages.AddLazarusResource('SwitchOffDis');
end;

//----------------------

// misc

function TvqThemeManager.FontTypeIconSize(FontType: Longint): TSize;
begin
    Result.cx := FSysImages.Width;
    Result.cy := FSysImages.Height;
end;

procedure TvqThemeManager.DrawFontTypeIcon(Control: TControl; Canvas: TCanvas; FontType: Longint; R: TRect; Enabled: Boolean);
var
    X, Y: Integer;
begin
    
    X := (R.Left + R.Right - FSysImages.Width) div 2;
    Y := (R.Top + R.Bottom - FSysImages.Height) div 2;
    
    case FontType of
        RASTER_FONTTYPE:
            FSysImages.Draw(Canvas, X, Y, FontImageIndex + 0, Enabled);
        DEVICE_FONTTYPE:
            FSysImages.Draw(Canvas, X, Y, FontImageIndex + 1, Enabled);
        TRUETYPE_FONTTYPE:
            FSysImages.Draw(Canvas, X, Y, FontImageIndex + 2, Enabled);
    end;
    
end;

procedure TvqThemeManager.DrawFontTypeIcon(Control: TControl; Canvas: TCanvas; FontType: Longint; X, Y: Integer; Enabled: Boolean);
begin
    
    case FontType of
        RASTER_FONTTYPE:
            FSysImages.Draw(Canvas, X, Y, FontImageIndex + 0, Enabled);
        DEVICE_FONTTYPE:
            FSysImages.Draw(Canvas, X, Y, FontImageIndex + 1, Enabled);
        TRUETYPE_FONTTYPE:
            FSysImages.Draw(Canvas, X, Y, FontImageIndex + 2, Enabled);
    end;
    
end;

procedure TvqThemeManager.DrawArrowGlyph(Control: TControl; Canvas: TCanvas; R: TRect; Dir: TvqArrowDirection; Enabled: Boolean);
var
    W, H, Mx, My, D, WH, T: Integer;
    A, B, C: TPoint;
    Fore: TColor;
begin
    if R.IsEmpty then Exit;
    with Canvas, R do begin
        if Enabled then Fore := TextFore
        else Fore := DisabledFore;
                         
        FullBrush(Fore);
        ThinPen(Fore);
        
        W := Right - Left;
        H := Bottom - Top;
        WH := Min(W, H);
        if W < H then begin
            Top := (Top + Bottom - WH) div 2;
            Bottom := Top + WH;
        end
        else if H < W then begin
            Left := (Left + Right - WH) div 2;
            Right := Left + WH;
        end;

        if WH < 5 then D := 0
        else if WH < 7 then D := 1
        else if WH < 9 then D := 2
        else if WH < 15 then D := (2*WH div 5) - 1
        else D := (WH div 3) - 1;
                                      
        Mx:= (Right + Left) div 2;
        My:= (Bottom + Top) div 2;
        if D <= 0 then begin
            if WH > 2 then Pixels[Mx, My] := Fore;
        end
        else begin
            case Dir of
                vqArrowLeft: begin
                    A := Point((Left + Right - 1 - D) div 2, My);
                    B := Point(A.X + D, A.Y + D);
                    C := Point(A.X + D, A.Y - D);
                end;
                vqArrowTop: begin
                    A := Point(Mx, (Top + Bottom - 1 - D) div 2);
                    B := Point(A.X - D, A.Y + D);
                    C := Point(A.X + D, A.Y + D);
                end;
                vqArrowRight: begin
                    A := Point((Left + Right + D) div 2, My);
                    B := Point(A.X - D, A.Y + D);
                    C := Point(A.X - D, A.Y - D);
                end;
                vqArrowBottom: begin
                    A := Point(Mx, (Top + Bottom + D) div 2);
                    B := Point(A.X - D, A.Y - D);
                    C := Point(A.X + D, A.Y - D);
                end;
            end;
            Polygon([C, A, B]);
        end;
    end;
end;

procedure TvqThemeManager.DrawFocusRect(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    Canvas.DrawFocusRect(R);
end;

procedure TvqThemeManager.DrawEdge(Control: TControl; Canvas: TCanvas; R: TRect; Edge, Flags: Cardinal);
begin
    WidgetSet.DrawEdge(Canvas.Handle, R, Edge, Flags);
end;

// arrow

procedure TvqThemeManager.DrawArrowHorzUp(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails; 
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tsUpHorzDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tsUpHorzPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tsUpHorzHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tsUpHorzHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tsUpHorzNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawArrowHorzDown(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails; 
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tsDownHorzDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tsDownHorzPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tsDownHorzHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tsDownHorzHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tsDownHorzNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawArrowVertUp(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails; 
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tsUpDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tsUpPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tsUpHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tsUpHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tsUpNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawArrowVertDown(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails; 
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tsDownDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tsDownPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tsDownHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tsDownHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tsDownNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawArrowHorzSpacer(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    Canvas.FullBrush(Control.Color);
    Canvas.FillRect(R);
end;

procedure TvqThemeManager.DrawArrowVertSpacer(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    Canvas.FullBrush(Control.Color);
    Canvas.FillRect(R);
end;

// hint 

const
    ToolTipBorderWidth = 2;

function TvqThemeManager.ToolTipContentRect(R: TRect): TRect;
begin
    Result := R;
    Result.Inflate(-ToolTipBorderWidth, -ToolTipBorderWidth);
end;

procedure TvqThemeManager.DrawToolTip(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails; 
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tttStandardNormal)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tttStandardNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

// divider

function TvqThemeManager.DividerThickness: Integer;
begin
    Result := 2;
end;

procedure TvqThemeManager.DrawHorzDivider(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails; 
    Y: Integer;
begin
    Y := (R.Top + R.Bottom - 2) div 2;
    with Canvas do begin
        ThinPen(clBtnShadow);
        MoveTo(R.Left, Y);
        LineTo(R.Right, Y);
        ThinPen(clBtnHighlight);
        Inc(Y);
        MoveTo(R.Left, Y);
        LineTo(R.Right, Y);
    end;
end;

procedure TvqThemeManager.DrawVertDivider(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails; 
    X: Integer;
begin 
    X := (R.Left + R.Right - 2) div 2;
    with Canvas do begin
        ThinPen(clBtnShadow);
        MoveTo(X, R.Top);
        LineTo(X, R.Bottom);
        ThinPen(clBtnHighlight);
        Inc(X);
        MoveTo(X, R.Top);
        LineTo(X, R.Bottom);
    end;
end;

procedure TvqThemeManager.DrawVertSpacer(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    // do nothing
end;

procedure TvqThemeManager.DrawHorzSpacer(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    // do nothing
end;

// buttons

function TvqThemeManager.ButtonContentRect(R: TRect): TRect;
var
    Details: TThemedElementDetails;
begin
    Details := ThemeServices.GetElementDetails(tbPushButtonNormal);
    Result := ThemeServices.ContentRect(FBackBmp.Canvas.Handle, Details, R);
end;

procedure TvqThemeManager.DrawFlatButton(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(ttbButtonDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(ttbButtonPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(ttbButtonHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(ttbButtonHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(ttbButtonNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawButton(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tbPushButtonDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonPressed)
    else if vqthDefaulted in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonDefaulted)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonNormal)
    else
       Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawFlatButtonChecked(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(ttbButtonDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(ttbButtonPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(ttbButtonCheckedHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(ttbButtonCheckedHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(ttbButtonChecked)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawButtonChecked(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tbPushButtonDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonPressed)
    else if vqthDefaulted in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonPressed)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonPressed)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonPressed)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawFlatCloseButton(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    DrawCloseButton(Control, Canvas, R, State);
end;

procedure TvqThemeManager.DrawCloseButton(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    BGRABmp: TBGRABitmap;
    X, Y: Integer;
    C: TBGRAPixel;
    T: Double;
    Fore, Back: TColor;
begin
    BGRABmp := TBGRABitmap.Create(R.Width, R.Height);
    try
        X := (R.Right - R.Left) div 2;
        Y := (R.Bottom - R.Top) div 2;
        T := Min(R.Width div 2, R.Height div 2);
        
        C.red := 0;
        C.green := 0;
        C.blue := 0;
        C.alpha := 0;
        BGRABmp.Fill(C);
        BGRABmp.JoinStyle := pjsBevel;
        BGRABmp.LineCap := pecSquare;
        BGRABmp.PenStyle := psSolid;
        
        Back := clNone;
        Fore := clNone;
        if vqthDisabled in State then begin
            Fore := DisabledFore;
            Back := clNone;
        end
        else if vqthPressed in State then begin
            Fore := clWhite;
            Back := RGBToColor(166, 0, 0);
        end
        else if vqthHot in State then begin
            Fore := clWhite;
            Back := clRed;
        end
        else if vqthHovered in State then begin
            Fore := clGray;
            Back := clNone;
        end
        else if vqthNormal in State then begin
            Fore := clGray;
            Back := clNone;
        end
        else
            Exit;

        BGRABmp.EllipseAntialias(X, Y, T, T, Back, 1, Back);
        T := T/Sqrt(2);
        T := T - 1;
        BGRABmp.DrawLineAntialias(X - T, Y - T, X + T, Y + T, Fore, 1.2);
        BGRABmp.DrawLineAntialias(X - T, Y + T, X + T, Y - T, Fore, 1.2);

        BGRABmp.Draw(Canvas, R.Left, R.Top, False);
    finally
        BGRABmp.Free;
    end;
end;

// drop down

function TvqThemeManager.DropDownArrowSize: TSize;
begin
    Result.cx := 17;
    Result.cy := 17;
end;

procedure TvqThemeManager.DrawHorzFlatDropDownButton(Control: TControl; Canvas: TCanvas; R, Arrow: TRect; State, ArrowState: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(ttbButtonDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(ttbButtonPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(ttbButtonHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(ttbButtonHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(ttbButtonNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
    
    if vqthDisabled in ArrowState then 
        Details := ThemeServices.GetElementDetails(ttbButtonDisabled)
    else if vqthPressed in ArrowState then
        Details := ThemeServices.GetElementDetails(ttbButtonPressed)
    else if vqthHot in ArrowState then
        Details := ThemeServices.GetElementDetails(ttbButtonHot)
    else if vqthHovered in ArrowState then
        Details := ThemeServices.GetElementDetails(ttbButtonHot)
    else if vqthNormal in ArrowState then
        Details := ThemeServices.GetElementDetails(ttbButtonNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, Arrow, nil);
end;

procedure TvqThemeManager.DrawVertFlatDropDownButton(Control: TControl; Canvas: TCanvas; R, Arrow: TRect; State, ArrowState: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(ttbButtonDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(ttbButtonPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(ttbButtonHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(ttbButtonHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(ttbButtonNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
    
    if vqthDisabled in ArrowState then 
        Details := ThemeServices.GetElementDetails(ttbButtonDisabled)
    else if vqthPressed in ArrowState then
        Details := ThemeServices.GetElementDetails(ttbButtonPressed)
    else if vqthHot in ArrowState then
        Details := ThemeServices.GetElementDetails(ttbButtonHot)
    else if vqthHovered in ArrowState then
        Details := ThemeServices.GetElementDetails(ttbButtonHot)
    else if vqthNormal in ArrowState then
        Details := ThemeServices.GetElementDetails(ttbButtonNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, Arrow, nil);
end;

procedure TvqThemeManager.DrawHorzDropDownButton(Control: TControl; Canvas: TCanvas; R, Arrow: TRect; State, ArrowState: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tbPushButtonDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonPressed)
    else if vqthDefaulted in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonDefaulted)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
    
    Arrow.Right := Arrow.Left + 2;
    Inc(Arrow.Top, 2);
    Dec(Arrow.Bottom, 2);
    DrawVertDivider(Control, Canvas, Arrow, ArrowState);
end;

procedure TvqThemeManager.DrawVertDropDownButton(Control: TControl; Canvas: TCanvas; R, Arrow: TRect; State, ArrowState: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tbPushButtonDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonPressed)
    else if vqthDefaulted in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonDefaulted)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tbPushButtonNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
    
    Arrow.Bottom := Arrow.Top + 2;
    Inc(Arrow.Left, 2);
    Dec(Arrow.Right, 2);
    DrawHorzDivider(Control, Canvas, Arrow, ArrowState);
end;

procedure TvqThemeManager.DrawDropDownArrow(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tcDropDownButtonDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tcDropDownButtonPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tcDropDownButtonHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tcDropDownButtonHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tcDropDownButtonNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

// switch

function TvqThemeManager.SwitchSize: TSize;
begin
    Result.cx := 40;
    Result.cy := 17;
end;

function TvqThemeManager.RadioSize: TSize;
var
    Details: TThemedElementDetails;
begin
    Details := ThemeServices.GetElementDetails(tbRadioButtonCheckedNormal);
    Result := ThemeServices.GetDetailSize(Details);
end;

function TvqThemeManager.CheckSize: TSize;
var
    Details: TThemedElementDetails;
begin
    Details := ThemeServices.GetElementDetails(tbCheckBoxCheckedNormal);
    Result := ThemeServices.GetDetailSize(Details);
end;

procedure TvqThemeManager.DrawSwitchOn(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
    X, Y, I: Integer;
begin
    X := (R.Left + R.Right - FSwitchImages.Width) div 2;
    Y := (R.Top + R.Bottom - FSwitchImages.Height) div 2;
    
    if vqthDisabled in State then 
        I := 3
    else if vqthPressed in State then
        I := 2
    else if vqthHot in State then
        I := 1
    else if vqthHovered in State then
        I := 1
    else if vqthNormal in State then
        I := 0
    else
        Exit;
    FSwitchImages.Draw(Canvas, X, Y, I, gdeNormal);
end;

procedure TvqThemeManager.DrawSwitchOff(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
    X, Y, I: Integer;
begin
    X := (R.Left + R.Right - FSwitchImages.Width) div 2;
    Y := (R.Top + R.Bottom - FSwitchImages.Height) div 2;
    
    if vqthDisabled in State then 
        I := 3
    else if vqthPressed in State then
        I := 2
    else if vqthHot in State then
        I := 1
    else if vqthHovered in State then
        I := 1
    else if vqthNormal in State then
        I := 0
    else
        Exit;
    FSwitchImages.Draw(Canvas, X, Y, I + 4, gdeNormal);
end;

procedure TvqThemeManager.DrawRadioOn(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tbRadioButtonCheckedDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tbRadioButtonCheckedPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tbRadioButtonCheckedHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tbRadioButtonCheckedHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tbRadioButtonCheckedNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawRadioOff(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tbRadioButtonUncheckedDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tbRadioButtonUncheckedPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tbRadioButtonUncheckedHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tbRadioButtonUncheckedHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tbRadioButtonUncheckedNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawCheckOn(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tbCheckBoxCheckedDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxCheckedPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxCheckedHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxCheckedHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxCheckedNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawCheckOff(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tbCheckBoxUncheckedDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxUncheckedPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxUncheckedHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxUncheckedHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxUncheckedNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawCheckGrayed(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(tbCheckBoxMixedDisabled)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxMixedPressed)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxMixedHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxMixedHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(tbCheckBoxMixedNormal)
    else
        Exit;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

// slider

procedure TvqThemeManager.DrawHorzSlider(Control: TControl; Canvas: TCanvas; Track, Knob: TRect; T, B: Boolean; State, KnobState: TvqThemeState);
var
    Details: TThemedElementDetails;
    Clip: TRect;
    Base: TThemedTrackBar;
begin                    
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(ttbTrack)
    else
        Details := ThemeServices.GetElementDetails(ttbTrack);
    with Track do begin
        Top := (Top + Bottom - 4) div 2;
        Bottom := Top + 4;
    end;
    ThemeServices.DrawElement(Canvas.Handle, Details, Track, nil);
    
    Base := ttbThumbNormal;
    if B and T then
        Base := ttbThumbNormal
    else if B then
        Base := ttbThumbBottomNormal
    else if T then
        Base := ttbThumbTopNormal
    else
        Base := ttbThumbNormal;
    
    if vqthDisabled in KnobState then 
        Inc(Base, 3)
    else if vqthPressed in KnobState then
        Inc(Base, 2)
    else if vqthHot in KnobState then
        Inc(Base, 1)
    else if vqthHovered in KnobState then
        Inc(Base, 1)
    else if vqthNormal in KnobState then
        Inc(Base, 0)
    else
        Exit;

    Details := ThemeServices.GetElementDetails(Base);
    ThemeServices.DrawElement(Canvas.Handle, Details, Knob, nil);
end;

procedure TvqThemeManager.DrawVertSlider(Control: TControl; Canvas: TCanvas; Track, Knob: TRect; L, R: Boolean; State, KnobState: TvqThemeState);
var
    Details: TThemedElementDetails;
    Clip: TRect;
    Base: TThemedTrackBar;
begin            
    if vqthDisabled in State then 
        Details := ThemeServices.GetElementDetails(ttbTrackVert)
    else
        Details := ThemeServices.GetElementDetails(ttbTrackVert);
    Clip := Knob;
    ThemeServices.DrawElement(Canvas.Handle, Details, Track, @Clip);
    
    Base := ttbThumbNormal;
    if R and L then
        Base := ttbThumbVertNormal
    else if L then
        Base := ttbThumbLeftNormal
    else if R then
        Base := ttbThumbRightNormal
    else
        Base := ttbThumbVertNormal;
    
    if vqthDisabled in KnobState then 
        Inc(Base, 3)
    else if vqthPressed in KnobState then
        Inc(Base, 2)
    else if vqthHot in KnobState then
        Inc(Base, 1)
    else if vqthHovered in KnobState then
        Inc(Base, 1)
    else if vqthNormal in KnobState then
        Inc(Base, 0)
    else
        Exit;
    Details := ThemeServices.GetElementDetails(Base);
    ThemeServices.DrawElement(Canvas.Handle, Details, Knob, nil);
end;

// dial

procedure TvqThemeManager.DrawDial(Control: TControl; Canvas: TCanvas; O: TPoint; Radius: Integer;
    Knob, KnobSize: Double; State, KnobState: TvqThemeState);
var
    BGRABmp: TBGRABitmap;
    X, Y: Integer;
    Ks, Kr, sn: Double;
    C: TBGRAPixel;
    Fore, Back: TColor;
    P: TPoint;
begin
    BGRABmp := TBGRABitmap.Create(2*Radius + 2, 2*Radius + 2);
    try
        P.X := Radius + 1;
        P.Y := Radius + 1;
        
        C.red := 0;
        C.green := 0;
        C.blue := 0;
        C.alpha := 0;
        BGRABmp.Fill(C);
        BGRABmp.JoinStyle := pjsBevel;
        BGRABmp.LineCap := pecSquare;
        BGRABmp.PenStyle := psSolid;
        
        Back := clNone;
        Fore := clBtnShadow;
        if vqthFocused in State then begin
            Fore := clHighlight;
            Back := clPlatinum;
        end
        else if vqthDisabled in State then
            Back := clLightPlatinum
        else
            Back := clPlatinum;

        BGRABmp.EllipseAntialias(P.X, P.Y, Radius, Radius, Fore, 1, Back);
        sn := Sin(KnobSize/2);
        Kr := Radius/(1 + 2*sn);
        P := P + VectorFromNormArg(Kr, Knob);
        Fore := clBtnShadow;
        if vqthDisabled in KnobState then 
            Back := clLightPlatinum
        else if vqthPressed in KnobState then
            Back := clSilver
        else if vqthHot in KnobState then
            Back := clPlatinum
        else if vqthHovered in KnobState then
            Back := clPlatinum
        else if vqthNormal in KnobState then
            Back := clPlatinum
        else
            Back := clPlatinum;
        Ks := Kr*sn;
        BGRABmp.EllipseAntialias(P.X, P.Y, Ks, Ks, Fore, 1, Back);

        BGRABmp.Draw(Canvas, O.X - Radius - 1, O.Y - Radius - 1, False);
    finally
        BGRABmp.Free;
    end;
end;

// tool bar

function TvqThemeManager.ToolBarChevronSize: TSize;
var
    Details: TThemedElementDetails;
begin
    Result.cx := 11;
    Result.cy := 11;
end;

procedure TvqThemeManager.DrawHorzToolBarChevron(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    X, Y: Integer;
begin   
    X := (R.Left + R.Right - FSysImages.Width) div 2;
    Y := (R.Top + R.Bottom - FSysImages.Height) div 2;
    DrawFlatButton(Control, Canvas, R, State);
    FSysImages.Draw(Canvas, X, Y, HChevronImageIndex, not(vqthDisabled in State));
end;

procedure TvqThemeManager.DrawVertToolBarChevron(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    X, Y: Integer;
begin   
    X := (R.Left + R.Right - FSysImages.Width) div 2;
    Y := (R.Top + R.Bottom - FSysImages.Height) div 2;
    DrawFlatButton(Control, Canvas, R, State);
    FSysImages.Draw(Canvas, X, Y, VChevronImageIndex, not(vqthDisabled in State));
end;

// toolpanel

function TvqThemeManager.ToolPanelFooterRect(R: TRect): TRect;
begin
    Result := R;
    Result.Inflate(-2, -2);
    Result.Top := Result.Bottom - 15;
    if Result.Top < R.Top then Result.Top := R.Top;
end;

function TvqThemeManager.ToolPanelContentRect(R: TRect): TRect;
begin
    Result := R;
    Result.Inflate(-2, -2);
    Dec(Result.Bottom, 15 + 2);
end;

type
    TCustomControlAccess = class(TCustomControl);

procedure TvqThemeManager.DrawToolPanel(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    X1, X2, Y: Integer;
begin
    with Canvas do begin
        if Control.Color = clDefault then
            FullBrush(clNone)
        else
            FullBrush(Control.Color);
        if TCustomControlAccess(Control).Canvas <> Canvas then begin
            // sheet
            ThinPen(clGray);
            Rectangle(R);
        end
        else
            FillRect(R);
        ThinPen(clSilver);
        X1 := R.Left + 2 + 2;
        X2 := R.Right - 2 - 2;
        Y := R.Bottom - 2 - 15 - 1;     
        if X1 > R.Right then X1 := R.Left;
        if X2 < R.Left then X2 := R.Right;
        if Y < R.Top then Y := R.Top;
        MoveTo(X1, Y);
        LineTo(X2, Y);
    end;
end;

// controlbar

function TvqThemeManager.ControlBandGrabSize: Integer;
begin
    Result := 7;
end;

function TvqThemeManager.ControlBandContentRect(R: TRect): TRect;
begin
    Result := R;
    Result.Inflate(-2, -2);
end;

function TvqThemeManager.ControlBarContentRect(R: TRect): TRect;
begin
    Result := R;
    Result.Inflate(-1, -1);
end;

procedure TvqThemeManager.DrawControlBand(Band: TObject; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
begin
    Canvas.FullBrush(clNone);
    Canvas.FillRect(R);
    Details := ThemeServices.GetElementDetails(trGripperVert);
    R.Right := R.Left + 4;
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawControlBar(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    // do nothing
end;

// tab

function TvqThemeManager.TabContentRect(Page: TControl; Close: Boolean; R: TRect): TRect;
begin      
    Result := R;
    Result.Inflate(-5, -5);
    if Close then 
        Dec(Result.Right, 17);
end;

function TvqThemeManager.TabBodyContentRect(R: TRect): TRect;
var
    Details: TThemedElementDetails;
begin
    Details := ThemeServices.GetElementDetails(ttPane);
    Result := ThemeServices.ContentRect(FBackBmp.Canvas.Handle, Details, R);
end;

function TvqThemeManager.TabCloseRect(R: TRect): TRect;
begin
    with Result do begin
        Left := R.Right - 5 - 15;
        Right := R.Right - 5;
        Top := (R.Top + R.Bottom - 15) div 2;
        Bottom := Top + 15;
    end;
end;

procedure TvqThemeManager.DrawTabBody(Page: TControl; Canvas: TCanvas; R, Tab: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
    Clip: TRect;
begin                  
    Details := ThemeServices.GetElementDetails(ttPane);
    ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
end;

procedure TvqThemeManager.DrawTab(Page: TControl; Canvas: TCanvas; R, Body: TRect; State: TvqThemeState);
var
    Details: TThemedElementDetails;
    RR: TRect;
begin         
    if vqthDisabled in State then
        Details := ThemeServices.GetElementDetails(ttTabItemDisabled)
    else if vqthFocused in State then 
        Details := ThemeServices.GetElementDetails(ttTabItemFocused)
    else if vqthSelected in State then
        Details := ThemeServices.GetElementDetails(ttTabItemSelected)
    else if vqthPressed in State then
        Details := ThemeServices.GetElementDetails(ttTabItemHot)
    else if vqthHot in State then
        Details := ThemeServices.GetElementDetails(ttTabItemHot)
    else if vqthHovered in State then
        Details := ThemeServices.GetElementDetails(ttTabItemHot)
    else if vqthNormal in State then
        Details := ThemeServices.GetElementDetails(ttTabItemNormal)
    else
        Exit;

    if Page.Parent <> nil then begin
       Canvas.FullBrush(Page.Parent.Color);
       Canvas.FillRect(R);
    end;
    if R.Bottom = Body.Top then begin // top

        if vqthSelected in State then
            Inc(R.Bottom, 2);

        ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
    end
    else if R.Top = Body.Bottom then begin // bottom
        ThemeServices.DrawElement(Canvas.Handle, Details, R, nil);
        RR := R;
        Exchange(RR.Top, RR.Bottom);
        Canvas.CopyRect(RR, Canvas, R);
    end;  
end;

procedure TvqThemeManager.DrawTabClose(Page: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    DrawFlatCloseButton(Page, Canvas, R, State);
end;

procedure TvqThemeManager.DrawAddTab(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    BGRABmp: TBGRABitmap;
    X, Y, T: Integer;
    C: TBGRAPixel;
    Fore, Back: TColor;
begin
    BGRABmp := TBGRABitmap.Create(R.Width, R.Height);
    try
        X := (R.Right - R.Left) div 2;
        Y := (R.Bottom - R.Top) div 2;
        T := Min(R.Width div 2, R.Height div 2);
        
        C.red := 0;
        C.green := 0;
        C.blue := 0;
        C.alpha := 0;
        BGRABmp.Fill(C);
        BGRABmp.JoinStyle := pjsBevel;
        BGRABmp.LineCap := pecSquare;
        BGRABmp.PenStyle := psSolid;
        
        Back := clNone;
        Fore := clNone;
        if vqthDisabled in State then begin
            Fore := DisabledFore;
            Back := clNone;
        end
        else if vqthPressed in State then begin
            Fore := clWhite;
            Back := clSilver;
        end
        else if vqthHot in State then begin
            Fore := clLead;
            Back := clPlatinum;
        end
        else if vqthHovered in State then begin
            Fore := clLead;
            Back := clPlatinum;
        end
        else if vqthNormal in State then begin
            Fore := clLead;
            Back := clNone;
        end
        else
            Exit;
                                                                
        Dec(T, 2);
        BGRABmp.EllipseAntialias(X, Y, T, T, Back, 1, Back);
        Dec(T, 1);
        BGRABmp.DrawLineAntialias(X - T, Y, X + T, Y, Fore, 1.2);
        BGRABmp.DrawLineAntialias(X, Y + T, X, Y - T, Fore, 1.2);
        
        BGRABmp.Draw(Canvas, R.Left, R.Top, False);
    finally
        BGRABmp.Free;
    end;
end;

// notifier  

function TvqThemeManager.NotifierContentRect(R: TRect): TRect;
begin
    Result := R;
    Result.Inflate(-2, -2);
end;

procedure TvqThemeManager.DrawNotifier(Control: TControl; Canvas: TCanvas; R: TRect; Color: TColor; State: TvqThemeState);
var
    BGRABmp: TBGRABitmap;
    C: TBGRAPixel;
    Fore: TColor;
    B: TBGRAPixel;
begin     
    BGRABmp := TBGRABitmap.Create(R.Width, R.Height);
    try
        C.red := 0;
        C.green := 0;
        C.blue := 0;
        C.alpha := 0;
        BGRABmp.Fill(C);
        BGRABmp.JoinStyle := pjsBevel;
        BGRABmp.LineCap := pecSquare;
        BGRABmp.PenStyle := psSolid;
        
        Fore := Color;
        B.FromColor(Color, 128);
        BGRABmp.RoundRectAntialias(R.Left, R.Top, R.Right - 1, R.Bottom - 1, 3, 3, Fore, 1, B);
        BGRABmp.Draw(Canvas, R.Left, R.Top, False);
    finally
        BGRABmp.Free;
    end;      
end;

// edits

function TvqThemeManager.LineEditContentRect(R: TRect): TRect;
begin
    Result := R;
end;

function TvqThemeManager.ClearButtonSize: TSize;
begin
    Result.cx := 17;
    Result.cy := 17;
end;

function TvqThemeManager.MRUDividerThickness: Integer;
begin
    Result := 2;
end;

function TvqThemeManager.SpinArrowSize: TSize;
begin
    Result.cx := 17;
    Result.cy := 17;
end;

procedure TvqThemeManager.DrawLineEditFrame(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    // do nothing
end;

procedure TvqThemeManager.DrawClearButton(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    X, Y: Integer;
begin
    X := (R.Left + R.Right - FSysImages.Width) div 2;
    Y := (R.Top + R.Bottom - FSysImages.Height) div 2;
    FSysImages.Draw(Canvas, X, Y, ClearImageIndex, not(vqthDisabled in State));
end;

procedure TvqThemeManager.DrawMRUDivider(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    Canvas.FullBrush(RGBToColor(206, 216, 231));
    Canvas.FillRect(R);
end;

procedure TvqThemeManager.DrawSpinBar(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Back: TColor;
begin
    if vqthDisabled in State then
        Back := clSilver
    else
        Back := RGBToColor(151, 163, 240);
    if R.Right > R.Left then begin
        Dec(R.Right);
        Canvas.FullBrush(Back);
        Canvas.ThinPen(clGray);
        Canvas.Rectangle(R);
        Canvas.Pen.Color := clLead;
        Canvas.MoveTo(R.Right, R.Top);
        Canvas.LineTo(R.Right, R.Bottom);
    end;
end;

procedure TvqThemeManager.DrawListItem(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Back: TColor;
begin
    if vqthDisabled in State then
        Back := Control.Color
    else if vqthSelected in State then
        Back := HiliteBack
    else
        Back := Control.Color;
    Canvas.FullBrush(Back);
    Canvas.FillRect(R);
end;

// menu box

function TvqThemeManager.MenuCheckSize: TSize;
begin
    Result.cx := FSysImages.Width;
    Result.cy := FSysImages.Height;
end;

function TvqThemeManager.MenuSeparatorThickness: Integer;
begin
    Result := 2;
end;

procedure TvqThemeManager.DrawMenuHeader(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    Canvas.FullBrush(Control.Color);
    Canvas.FillRect(R);
end;

procedure TvqThemeManager.DrawMenuSeparator(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    DrawHorzDivider(Control, Canvas, R, State);
end;

procedure TvqThemeManager.DrawMenuItem(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    Back: TColor;
begin
    if vqthDisabled in State then
        Back := Control.Color
    else if vqthSelected in State then
        Back := HiliteBack
    else
        Back := Control.Color;
    Canvas.FullBrush(Back);
    Canvas.FillRect(R);
end;

procedure TvqThemeManager.DrawMenuRadioOn(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    X, Y: Integer;
begin
    X := (R.Left + R.Right - FSysImages.Width) div 2;
    Y := (R.Top + R.Bottom - FSysImages.Height) div 2;
    FSysImages.Draw(Canvas, X, Y, MenuImageIndex + 0, not(vqthDisabled in State));
end;

procedure TvqThemeManager.DrawMenuRadioOff(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    X, Y: Integer;
begin
    X := (R.Left + R.Right - FSysImages.Width) div 2;
    Y := (R.Top + R.Bottom - FSysImages.Height) div 2;
    FSysImages.Draw(Canvas, X, Y, MenuImageIndex + 1, not(vqthDisabled in State));
end;

procedure TvqThemeManager.DrawMenuCheckOn(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    X, Y: Integer;
begin
    X := (R.Left + R.Right - FSysImages.Width) div 2;
    Y := (R.Top + R.Bottom - FSysImages.Height) div 2;
    FSysImages.Draw(Canvas, X, Y, MenuImageIndex + 2, not(vqthDisabled in State));
end;

procedure TvqThemeManager.DrawMenuCheckOff(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
var
    X, Y: Integer;
begin
    X := (R.Left + R.Right - FSysImages.Width) div 2;
    Y := (R.Top + R.Bottom - FSysImages.Height) div 2;
    FSysImages.Draw(Canvas, X, Y, MenuImageIndex + 3, not(vqthDisabled in State));
end;

// frame

function TvqThemeManager.FrameContentRect(R: TRect): TRect;
begin
    Result := R;
    Result.Inflate(-1, -1);
end;

procedure TvqThemeManager.DrawFrame(Control: TControl; Canvas: TCanvas; R: TRect; State: TvqThemeState);
begin
    Canvas.ThinPen(BevelColor);
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(R);
end;

// docking

//----------------------

type
    TvqCustomControlAccess = class(TvqCustomControl);
    TvqGraphicControlAccess = class(TvqGraphicControl);

function TvqThemeManager.Apply: Boolean;

    procedure ApplyToGraphicControl(AControl: TGraphicControl);
    begin
        if AControl is TvqGraphicControl then
            TvqGraphicControlAccess(AControl).UpdateMetrics
        else
            AControl.Invalidate;
    end;

    procedure ApplyToWinControl(AControl: TWinControl);
    var
        I: Integer;
    begin
        if AControl is TvqCustomControl then
            TvqCustomControlAccess(AControl).UpdateMetrics
        else
            AControl.Invalidate;
        for I := 0 to AControl.ControlCount do
            if AControl.Controls[I] is TGraphicControl then
                ApplyToGraphicControl(TGraphicControl(AControl.Controls[I]))
            else
                ApplyToWinControl(TWinControl(AControl.Controls[I]));
    end;

    procedure ApplyToForm(AForm: TCustomForm);
    var
        I: Integer;
    begin                                  
        for I := 0 to AForm.ControlCount do
            if AForm.Controls[I] is TGraphicControl then
                ApplyToGraphicControl(TGraphicControl(AForm.Controls[I]))
            else
                ApplyToWinControl(TWinControl(AForm.Controls[I]));
    end;
    
begin
    Result := False;
    //------------------
    
    vqThemeManager := Self;
    
    // forms: standart, dialogs, popups, others
    {
    for AForm in Forms do begin
        AForm.DisableAutosize;
        try
            ApplyToForm(AForm);
        finally
            AForm.EnableAutosize;
        end;
    end;
    }
    DoApply;
    
    //------------------
    Result := True;
end;

procedure TvqThemeManager.DoApply;
begin
    if Assigned(FOnApply) then FOnApply(Self);
end;

initialization
    
    {$I vqThemes.lrs}
    vqThemeManager := TvqThemeManager.Create;
    
finalization
    
    vqThemeManager.Free;
    
end.
