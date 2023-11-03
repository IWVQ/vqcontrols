// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqToolPanel;

interface

uses

    Classes, SysUtils, LResources, Types, Forms, Controls, Graphics, Dialogs,
    Math, StdCtrls, ExtCtrls,
    vqUtils, vqThemes, vqQuickButton, vqToolButton;

type
    
    TvqToolPanel = class;

    { TvqToolPanelSheet }

    TvqToolPanelSheet = class(TvqPopupForm)
    private
        procedure LocateLaunchButton;
    protected
        FPanel: TvqToolPanel;
        procedure AdjustClientRect(var aRect: TRect); override;
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        procedure Paint; override;  
        procedure Resize; override;
    end;
    
    { TvqToolPanel }

    TvqToolPanel = class(TvqToolButton)
    private
        FContractedWidth: Integer;
        FLaunchButton: TvqQuickButton;
        FAlignment: TAlignment;
        FFooterRect: TRect;
        FSheet: TvqToolPanelSheet;
        FFooterFont: TFont;
        FMinExpandWidth: Integer;
        
        FFolded: Boolean;
        function GetAutosize: Boolean;
        function GetBorderWidth: TBorderWidth;
        procedure LocateLaunchButton;
        procedure SetAlignment(Value: TAlignment);
        procedure SetBorderWidth(Value: TBorderWidth);
        procedure SetFolded(Value: Boolean);
        procedure SetFooterFont(Value: TFont);
        
        procedure CalculatePanelMetrics;
    protected
        function IsInternalControl(AControl: TControl): Boolean; override;
        procedure AdjustClientRect(var aRect: TRect); override;
        procedure SetParentBackground(const AParentBackground: Boolean); override;
        procedure FooterFontChanged(Sender: TObject); virtual;
        
        class function GetControlClassDefaultSize: TSize; override;
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        
        procedure KeyDown(var Key: Word; Shift: TShiftState); override;
        procedure KeyUp(var Key: Word; Shift: TShiftState); override;
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
        procedure MouseEnter; override;
        procedure MouseLeave; override;
        procedure Click; override;
        
        procedure UpdateMetrics; override;
        procedure Resize; override;
        procedure Loaded; override;
        procedure TextChanged; override;
        procedure FocusChanged(AFocused: Boolean); override;
        procedure ColorChanged; override;
        procedure EnabledChanged; override;
        procedure Paint; override;
        
        procedure DoPrepareDropDown(var Caller: TControl); override;
        procedure DoCloseUp; override;
                            
        property DropDownMenu;
        property DropDownForm;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;

    published
        property Color default clDefault;
        property ParentBackground default True;
        property ParentColor default True;
        
        property MinExpandWidth: Integer read FMinExpandWidth write FMinExpandWidth;
        property FooterFont: TFont read FFooterFont write SetFooterFont;
        property LaunchButton: TvqQuickButton read FLaunchButton;
        property Folded: Boolean read FFolded write SetFolded;
        property Alignment: TAlignment read FAlignment write SetAlignment default taCenter;
        property Autosize;
        property Caption;
        
        property OnClick;
    end;
    
implementation

{ TvqLaunchButton }


type

    TvqLaunchButton = class(TvqQuickButton)
    protected
        procedure VisibleChanged; override;
    public

        property Cursor;
        property Left;
        property Top;
        property Height;
        property Width;
        property HelpType;
        property HelpKeyword;
        property HelpContext;
    published
        property ShowHint;
        property Hint;
        property Visible;
        property Flat;
    end;

procedure TvqLaunchButton.VisibleChanged;
begin
    inherited;
    if (Parent <> nil) and (Parent is TvqToolPanel) then begin
        TvqToolPanel(Parent).UpdateMetrics;
    end;
end;

{ TvqToolPanelSheet }

procedure TvqToolPanelSheet.AdjustClientRect(var aRect: TRect);
begin
    inherited AdjustClientRect(ARect);
    if FPanel = nil then Exit;
    ARect := vqThemeManager.ToolPanelContentRect(ARect);
    ARect.Inflate(-FPanel.BorderWidth, -FPanel.BorderWidth);
end;

procedure TvqToolPanelSheet.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
begin
    inherited CalculatePreferredSize(PreferredWidth, PreferredHeight, WithThemeSpace);
end;

procedure TvqToolPanelSheet.Resize;
begin
    inherited;
    LocateLaunchButton;
end;

procedure TvqToolPanelSheet.LocateLaunchButton;
var
    TxtRect: TRect;
begin
    if FPanel = nil then Exit;
    if FPanel.LaunchButton = nil then Exit;

    TxtRect := vqThemeManager.ToolPanelFooterRect(ClientRect);
    if (FPanel.LaunchButton.Visible) then begin
        FPanel.LaunchButton.Width := TxtRect.Height;
        FPanel.LaunchButton.Left := TxtRect.Right - FPanel.LaunchButton.Width;
        FPanel.LaunchButton.Top := TxtRect.Top;
        FPanel.LaunchButton.Height := TxtRect.Height;
    end;
end;

procedure TvqToolPanelSheet.Paint;
var
    Client, TxtRect: TRect;
    AState: TvqThemeState;
begin
    if FPanel = nil then Exit;
    Client := ClientRect;
    AState := [vqthNormal];
    vqThemeManager.DrawToolPanel(FPanel, Canvas, Client, AState);
    TxtRect := vqThemeManager.ToolPanelFooterRect(ClientRect);
    if FPanel.LaunchButton.Visible then
        Dec(TxtRect.Right, FPanel.LaunchButton.Width);
    Canvas.Font := FPanel.FooterFont;
    Canvas.TextOutHorz(TxtRect, FPanel.Caption, FPanel.Alignment, tlCenter);
    if Assigned(FPanel.OnPaint) then FPanel.OnPaint(Self);
end;

{ TvqToolPanel }

constructor TvqToolPanel.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FFolded := False;
    ControlStyle := ControlStyle + [csReplicatable, csNoFocus, csParentBackground]
        + [csAcceptsControls, csAutoSize0x0];
    
    Color := clDefault;
    ParentColor := True;
    
    FAlignment := taCenter;
    FLaunchButton := TvqLaunchButton.Create(Self);
    FLaunchButton.Parent := Self;
    FLaunchButton.Align := alCustom;
    // FLaunchButton.Visible := False;
    FLaunchButton.Flat := True;
    
    FFooterFont := TFont.Create;
    FFooterFont.OnChange := @FooterFontChanged;
    
    FSheet := TvqToolPanelSheet.CreateNew(nil);
    FSheet.FPanel := Self;
    FSheet.FreeOnClose := False;
    DropDownForm := FSheet;
    
    Kind := vqtbkButtonDrop;
    
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
    FMinExpandWidth := GetControlClassDefaultSize.cx;
    
    CalculatePanelMetrics;
end;

destructor TvqToolPanel.Destroy;
begin
    FLaunchButton.Free;
    inherited;
end;

procedure TvqToolPanel.AdjustClientRect(var ARect: TRect);
begin
    inherited AdjustClientRect(ARect);
    if not FFolded then begin
        ARect := vqThemeManager.ToolPanelContentRect(ARect);
        ARect.Inflate(-BorderWidth, -BorderWidth);
    end;
end;

procedure TvqToolPanel.SetParentBackground(const AParentBackground: Boolean);
begin
    if FFolded then 
        inherited
    else
        if ParentBackground <> AParentBackground then begin
            if AParentBackground then
                ControlStyle := ControlStyle - [csOpaque]
            else
                ControlStyle := ControlStyle + [csOpaque];
            inherited;
        end
end;

procedure TvqToolPanel.SetFooterFont(Value: TFont);
begin
    FFooterFont.Assign(Value);
end;

procedure TvqToolPanel.FooterFontChanged(Sender: TObject);
begin
    UpdateMetrics;
end;

class function TvqToolPanel.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 150;
    Result.cy := 100;
end;

procedure TvqToolPanel.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
begin
    if FFolded then
        inherited CalculatePreferredSize(PreferredWidth, PreferredHeight, WithThemeSpace)
    else
        inherited OldCalculatePreferredSize(PreferredWidth, PreferredHeight, WithThemeSpace);
end;

procedure TvqToolPanel.KeyDown(var Key: Word; Shift: TShiftState);
begin
    if FFolded then inherited KeyDown(Key, Shift)
    else inherited OldKeyDown(Key, Shift);
end;

procedure TvqToolPanel.KeyUp(var Key: Word; Shift: TShiftState);
begin
    if FFolded then inherited KeyUp(Key, Shift)
    else inherited OldKeyUp(Key, Shift);
end;

procedure TvqToolPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if FFolded then inherited MouseDown(Button, Shift, X, Y)
    else inherited OldMouseDown(Button, Shift, X, Y);
end;

procedure TvqToolPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if FFolded then inherited MouseUp(Button, Shift, X, Y)
    else inherited OldMouseUp(Button, Shift, X, Y);
end;

procedure TvqToolPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
    if FFolded then inherited MouseMove(Shift, X, Y)
    else inherited OldMouseMove(Shift, X, Y);
end;

procedure TvqToolPanel.MouseEnter;
begin
    if FFolded then inherited MouseEnter
    else inherited OldMouseEnter;
end;

procedure TvqToolPanel.MouseLeave;
begin
    if FFolded then inherited MouseLeave
    else inherited OldMouseLeave;
end;

procedure TvqToolPanel.Click;
begin
    if FFolded then inherited Click
    else inherited OldClick;
end;

function TvqToolPanel.GetAutosize: Boolean;
begin
    Result := inherited Autosize;
end;

function TvqToolPanel.GetBorderWidth: TBorderWidth;
begin
    Result := inherited BorderWidth;
end;

procedure TvqToolPanel.SetBorderWidth(Value: TBorderWidth);
begin
    FSheet.BorderWidth := Value;
    Self.BorderWidth := FSheet.BorderWidth;
end;

procedure TvqToolPanel.UpdateMetrics;
begin
    CalculatePanelMetrics;
    LocateLaunchButton;
    inherited;
end;

procedure TvqToolPanel.Resize;
begin
    inherited;             
    if Parent <> nil then begin
        CalculatePanelMetrics;
        LocateLaunchButton;
    end;
end;

procedure TvqToolPanel.Loaded;
begin
    inherited;
end;

procedure TvqToolPanel.TextChanged;
begin
    CalculatePanelMetrics;
    inherited;
end;

procedure TvqToolPanel.FocusChanged(AFocused: Boolean);
begin
    inherited;
end;

procedure TvqToolPanel.ColorChanged;
begin
    inherited;
end;

procedure TvqToolPanel.EnabledChanged;
begin
    inherited;
end;

procedure TvqToolPanel.SetAlignment(Value: TAlignment);
begin
    if FAlignment <> Value then begin
        FAlignment := Value;
        Invalidate;
    end;
end;

procedure TvqToolPanel.SetFolded(Value: Boolean);
var
    AControls: array of TControl;
    ACount, I: Integer;
begin
    if FFolded <> Value then begin
        FFolded := Value;
        if DroppedDown then ExecuteCloseUp;
        if FFolded then begin
            ACount := ControlCount;
            SetLength(AControls, ACount);
            for I := 0 to ACount - 1 do
                AControls[I] := Controls[I];
            for I := 0 to ACount - 1 do
                AControls[I].Parent := FSheet; // including LaunchButton
            FSheet.Visible := False;
            ControlStyle := ControlStyle - [csAcceptsControls, csAutoSize0x0];
        end
        else begin
            ACount := FSheet.ControlCount;
            SetLength(AControls, ACount);
            for I := 0 to ACount - 1 do
                AControls[I] := FSheet.Controls[I];
            for I := 0 to ACount - 1 do
                AControls[I].Parent := Self; // including LaunchButton
            FSheet.Visible := False;
            ControlStyle := ControlStyle + [csAcceptsControls, csAutoSize0x0];
        end;
        Invalidate;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

function TvqToolPanel.IsInternalControl(AControl: TControl): Boolean;
begin
    Result := (FLaunchButton <> nil) and (AControl = FLaunchButton);
end;

procedure TvqToolPanel.DoPrepareDropDown(var Caller: TControl);
begin
    inherited;
    DropDownForm := FSheet;
    DropDownForm.Beveled:=True;
    DropDownForm.Autosize := Self.Autosize;
    if not Autosize then begin
        FSheet.Width := Max(Width, FMinExpandWidth);
        FSheet.Height := Height;
    end;
end;

procedure TvqToolPanel.DoCloseUp; 
begin
    inherited;
end;

procedure TvqToolPanel.CalculatePanelMetrics;
begin
    FFooterRect := vqThemeManager.ToolPanelFooterRect(ClientRect);
end;

procedure TvqToolPanel.LocateLaunchButton;
begin
    if FLaunchButton = nil then Exit;
    if (FLaunchButton.Visible) then begin
        FLaunchButton.Width := FFooterRect.Height;
        FLaunchButton.Left := FFooterRect.Right - FLaunchButton.Width;
        FLaunchButton.Top := FFooterRect.Top;
        FLaunchButton.Height := FFooterRect.Height;
    end;
end;

procedure TvqToolPanel.Paint;
var
    Client, TxtRect: TRect;
    AState: TvqThemeState;
begin
    if FFolded then
        inherited Paint
    else begin
        Client := ClientRect;
        if Enabled then AState := [vqthNormal]
        else AState := [vqthDisabled];
        vqThemeManager.DrawToolPanel(Self, Canvas, Client, AState);
        TxtRect := FFooterRect;
        if FLaunchButton.Visible then
            Dec(TxtRect.Right, FLaunchButton.Width);
        Canvas.Font := FFooterFont;
        if not Enabled then 
            Canvas.Font.Color := vqThemeManager.DisabledFore;
        Canvas.TextOutHorz(TxtRect, Caption, FAlignment, tlCenter);
        inherited OldPaint;
    end;
end;

end.
