// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqSwitch;

interface

uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Types, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons, Math,
    ImgList, ActnList, Dialogs, Menus,
    vqUtils, vqThemes, vqButtons;

type
    
    { TvqSwitch }
    
    TvqSwitch = class(TvqPushControl)
    private
        FGlyph: TvqGlyph;
        FLayout: TvqGlyphLayout;
        FTextFormat: TvqTextFormat;
        FChecked: Boolean;
        FAlignment: TLeftRight;
        
        procedure OnGlyphChange(Sender: TObject);
        procedure SetGlyph(Value: TvqGlyph);
        procedure SetLayout(Value: TvqGlyphLayout);
        procedure SetTextFormat(Value: TvqTextFormat);
        procedure SetAlignment(Value: TLeftRight);
        
        procedure OnTextFormatChange(Sender: TObject);
    strict protected
        FCaptionRenderer: TvqCaptionRenderer;
    protected
        class function GetControlClassDefaultSize: TSize; override;
        function DialogChar(var Message: TLMKey): Boolean; override;
        function GlyphSize(AArea: TRect): TSize; virtual;
        function CaptionArea: TRect; virtual;
        procedure DrawGlyph(AArea, ARect: TRect); virtual;
        
        procedure EnabledChanged; override;
        procedure ColorChanged; override;
        procedure FontChanged; override;
        procedure TextChanged; override;
        procedure FocusChanged(AFocused: Boolean); override;
        procedure Click; override;
        procedure Loaded; override;
        procedure UpdateMetrics; override;
        procedure InitializeWnd; override;
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
        
        procedure DrawCheckArea(ARect: TRect; AState: TvqThemeState); virtual;
        procedure Paint; override;
        
        procedure ApplyChanges; virtual;
        function CheckArea: TRect; virtual;
        function GetChecked: Boolean; override;
        procedure SetChecked(Value: Boolean); override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        
    published
        property Spacing;
        property Layout: TvqGlyphLayout read FLayout write SetLayout;
        property TextFormat: TvqTextFormat read FTextFormat write SetTextFormat;
        property Alignment: TLeftRight read FAlignment write SetAlignment default taRightJustify;
        property Glyph: TvqGlyph read FGlyph write SetGlyph;
        property Checked;
        
        property AutoSize default False;
        property BidiMode;
        property Caption;
        property DragCursor;
        property DragKind;
        property DragMode;
        property Font;
        property ParentBidiMode;
        property ParentFont;
        property PopupMenu;
        
        property OnChange;
        property OnContextPopup;
        property OnDragDrop;
        property OnDragOver;
        property OnEndDrag;
        property OnStartDrag;
    end;
    
implementation

{ TvqSwitch }

constructor TvqSwitch.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FLayout := blGlyphTop;
    FTextFormat := TvqTextFormat.Create(Self);
    FTextFormat.Layout := tlCenter;
    FAlignment := taLeftJustify;
    FChecked := False;
    FGlyph := TvqGlyph.Create(AOwner);
    FGlyph.OnChange := @OnGlyphChange;

    FCaptionRenderer := TvqCaptionRenderer.Create;
    FCaptionRenderer.Format := FTextFormat;
    FCaptionRenderer.Font := Font;
    FCaptionRenderer.Canvas := Canvas;
    
    FCaptionRenderer.DrawGlyphMethod := @DrawGlyph;
    FCaptionRenderer.GlyphSizeMethod := @GlyphSize;
    FCaptionRenderer.OwnerDraw := False;
    
end;

destructor TvqSwitch.Destroy;
begin
    FTextFormat.Free;
    FGlyph.Free;
    FCaptionRenderer.Free;
    inherited;
end;

class function TvqSwitch.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 120;
    Result.cy := 17;
end;

procedure TvqSwitch.OnGlyphChange(Sender: TObject);
begin
    UpdateMetrics;
end;

procedure TvqSwitch.SetGlyph(Value: TvqGlyph);
begin
    FGlyph.Assign(Value);
end;

procedure TvqSwitch.SetLayout(Value: TvqGlyphLayout);
begin
    if FLayout <> Value then begin
        FLayout := Value;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqSwitch.SetTextFormat(Value: TvqTextFormat); 
begin
    FTextFormat.Assign(Value);
end;

procedure TvqSwitch.SetAlignment(Value: TLeftRight);     
begin
    if FAlignment <> Value then begin
        FAlignment := Value;
        Invalidate;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqSwitch.OnTextFormatChange(Sender: TObject); 
begin
    InvalidatePreferredSize;
    AdjustSize;
    Invalidate;
end;

function TvqSwitch.GetChecked: Boolean;
begin
    Result := FChecked;
end;

procedure TvqSwitch.SetChecked(Value: Boolean);
begin
    if FChecked <> Value then begin
        FChecked := Value;
        ApplyChanges;
    end;
end;

procedure TvqSwitch.InitializeWnd; 
begin
    inherited InitializeWnd;
    ApplyChanges;
end;

procedure TvqSwitch.ApplyChanges;
begin
    Repaint;
    Changed;
end;

procedure TvqSwitch.EnabledChanged; 
begin
    inherited;
    Invalidate;
end;

procedure TvqSwitch.ColorChanged;   
begin
    inherited;
    Invalidate;
end;

procedure TvqSwitch.FontChanged;    
begin
    inherited;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqSwitch.TextChanged;    
begin
    inherited;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqSwitch.FocusChanged(AFocused: Boolean);   
begin
    inherited;
    Invalidate;
end;

procedure TvqSwitch.UpdateMetrics;
begin
    InvalidatePreferredSize;
    AdjustSize;
    inherited;
end;

function TvqSwitch.DialogChar(var Message: TLMKey): Boolean;
begin
    Result := False;
    if (Message.msg <> LM_SYSCHAR) then Exit;
    if Enabled and FTextFormat.ShowPrefix and IsAccel(Message.CharCode, Caption) then begin
        if CanFocus then SetFocus;
        Click;
        Result := True;
    end
    else Result := inherited DialogChar(Message);
end;

procedure TvqSwitch.Click;
begin
    Toggle;
    inherited;
end;

procedure TvqSwitch.Loaded;      
begin
    inherited Loaded;
end;

function TvqSwitch.CheckArea: TRect;
begin
    Result := ClientRect;
    if FAlignment = taLeftJustify then
        Result.Left := Result.Right - vqThemeManager.SwitchSize.cx
    else
        Result.Right := Result.Left + vqThemeManager.SwitchSize.cx;
end;

function TvqSwitch.GlyphSize(AArea: TRect): TSize;
begin
    Result := TSize.Create(0, 0);
end;

function TvqSwitch.CaptionArea: TRect;
begin
    Result := ClientRect;
    if FAlignment = taLeftJustify then
        Dec(Result.Right, vqThemeManager.SwitchSize.cx + Spacing)
    else
        Inc(Result.Left, vqThemeManager.SwitchSize.cx + Spacing);
end;

procedure TvqSwitch.DrawGlyph(AArea, ARect: TRect);
begin
end;

procedure TvqSwitch.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
var
    Sz: TSize;
    Style: TTextStyle;
    Area: TRect;
    Client: TRect;
    Dx, Dy: Integer;
    TxtR: TRect;
begin
    TxtR := CaptionArea;
    Dx := Width - TxtR.Width;
    Dy := Height - TxtR.Height;
    FCaptionRenderer.Area := TxtR;
    Sz := FCaptionRenderer.TextExtent(Caption, Glyph, FLayout, Spacing, vqTextHorizontal);
    Inc(Sz.cx, Dx);
    Inc(Sz.cy, Dy);
    PreferredWidth := Sz.cx;
    PreferredHeight := Sz.cy;
    PreferredHeight := Max(PreferredHeight, vqThemeManager.SwitchSize.cy);
end;

procedure TvqSwitch.DrawCheckArea(ARect: TRect; AState: TvqThemeState);
begin
    // switch
    if Checked then
        vqThemeManager.DrawSwitchOn(Self, Canvas, ARect, AState)
    else
        vqThemeManager.DrawSwitchOff(Self, Canvas, ARect, AState);
end;

procedure TvqSwitch.Paint;
var
    AState: TvqThemeState;
    Client, CheckR, TxtR, FocusR: TRect;
begin
    if not OwnerDraw then begin
        // rects
        Client := ClientRect;
        CheckR := CheckArea;
        
        TxtR := CaptionArea;
        // back
        if Color = clDefault then
            Canvas.FullBrush(clNone)
        else
            Canvas.FullBrush(Color);
        Canvas.FillRect(Client);
        
        // switch
        if not Enabled then AState := [vqthDisabled]
        else if FPressed then AState := [vqthPressed]
        else if FMouseOver then AState := [vqthHot]
        else AState := [vqthNormal];
        
        DrawCheckArea(CheckR, AState);
        
        if Checked then
            vqThemeManager.DrawSwitchOn(Self, Canvas, CheckR, AState)
        else
            vqThemeManager.DrawSwitchOff(Self, Canvas, CheckR, AState);
        
        // caption
        Glyph.TransparentGlyph := True; //!
        
        FCaptionRenderer.DisabledColor := vqThemeManager.DisabledFore;
        FCaptionRenderer.Area := TxtR;
        FCaptionRenderer.Render(Caption, Glyph, FLayout, Enabled, Spacing, vqTextHorizontal);
        
        // focus
        if Focused then begin
            FocusR := Client;
            if FAlignment = taLeftJustify then
                Dec(FocusR.Right, CheckR.Width)
            else
                Inc(FocusR.Left, CheckR.Width);
            Brush.Color := Color;
            vqThemeManager.DrawFocusRect(Self, Canvas, FocusR, [vqthNormal]);
        end;
        
    end;
    inherited;
end;

end.
