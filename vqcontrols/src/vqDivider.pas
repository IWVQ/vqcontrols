// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqDivider;

interface

uses
    InterfaceBase, LclIntf, LclType, LMessages,
    Types, SysUtils, Classes, Graphics, Controls, Math, Dialogs,
    vqUtils, vqThemes, Windows;

type
    
    TvqDivider = class(TvqGraphicControl)
    private

        FDividerRect, 
        FDivLeftRect, 
        FDivRightRect, 
        FTextRect: TRect;

        FIndent: Integer;
        FAlignment: TAlignment;
        FLayout: TTextLayout;
        FOrientation: TvqTextOrientation;
        procedure SetIndent(Value: Integer);
        procedure SetAlignment(Value: TAlignment);
        procedure SetLayout(Value: TTextLayout);
        procedure SetOrientation(Value: TvqTextOrientation);
	protected
        class function GetControlClassDefaultSize: TSize; override;
        procedure TextChanged; override;
        procedure ColorChanged; override;
        procedure FontChanged; override;
        procedure Paint; override;
        procedure Resize; override;
        procedure UpdateMetrics; override;
        
        procedure CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean); override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
    published
        property Indent: Integer read FIndent write SetIndent;
        property Alignment: TAlignment read FAlignment write SetAlignment;
        property Layout: TTextLayout read FLayout write SetLayout;
        property Orientation: TvqTextOrientation read FOrientation write SetOrientation;
        
        property AutoSize default True;
        property BidiMode;
        property Caption;
        property DragCursor;
        property DragKind;
        property DragMode;
        property Font;
        property ParentBidiMode;
        property ParentFont;
        property PopupMenu;
        
        property OnContextPopup;
        property OnDragDrop;
        property OnDragOver;
        property OnEndDrag;
        property OnStartDrag;
    end;

implementation

{ TvqDivider }

constructor TvqDivider.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FIndent := 60;
    FAlignment := taLeftJustify;
    FLayout := tlCenter;
    FOrientation := vqTextHorizontal;
                                        
    with GetControlClassDefaultSize do
        SetInitialBounds(0, 0, cx, cy);
    AutoSize := True;
end;

destructor TvqDivider.Destroy;
begin
    inherited;
end;

class function TvqDivider.GetControlClassDefaultSize: TSize;
begin
    Result.cx := 300;
    Result.cy := 17;
end;

procedure TvqDivider.TextChanged;
begin
    inherited;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqDivider.ColorChanged;
begin
    inherited;
    Invalidate;
end;

procedure TvqDivider.FontChanged;
begin
    inherited;
    InvalidatePreferredSize;
    AdjustSize;
end;

procedure TvqDivider.Resize;
begin
    inherited;
end;

procedure TvqDivider.UpdateMetrics;
begin
    InvalidatePreferredSize;
    AdjustSize;
    inherited;
end;

procedure TvqDivider.SetIndent(Value: Integer);
begin
    if FIndent <> Value then begin
        FIndent := Value;
        Invalidate;
    end;
end;

procedure TvqDivider.SetAlignment(Value: TAlignment);
begin
    if FAlignment <> Value then begin
        FAlignment := Value;
        Invalidate;
    end;
end;

procedure TvqDivider.SetLayout(Value: TTextLayout);
begin
    if FLayout <> Value then begin
        FLayout := Value;
        Invalidate;
    end;
end;

procedure TvqDivider.SetOrientation(Value: TvqTextOrientation);
begin
    if FOrientation <> Value then begin
        FOrientation := Value;
        if not (csLoading in ComponentState) then
	        SetBounds(Left, Top, Height, Width);
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqDivider.CalculatePreferredSize(var PreferredWidth, PreferredHeight: Integer; WithThemeSpace: Boolean);
var
    Sz: TSize;
    Style: TTextStyle;
    Thickness, DividerSize: Integer;
begin
    Canvas.Font := Self.Font;
    Sz := Canvas.TextExtent(Caption);
    Thickness := vqThemeManager.DividerThickness;
    if FLayout = tlCenter then DividerSize := Max(Sz.cy, Thickness)
    else DividerSize := Sz.cy + Thickness;

    if FOrientation = vqTextHorizontal then begin
        PreferredWidth  := 0;
        PreferredHeight := DividerSize;
    end
    else begin
        PreferredWidth := DividerSize;
        PreferredHeight := 0;
    end;
end;

procedure TvqDivider.Paint;
var
    Client: TRect;
    TxtRect, Trace, TraceTL, TraceBR: TRect;
    TxtSz: TSize;
    AState: TvqThemeState;
    Thickness: Integer;
begin
    Client := ClientRect;
    
    with Canvas do begin
        // back
        if Color <> clNone then begin
            Pen.Style := psClear;
            Brush.Color := Color;
            FillRect(Client);
        end;
        Thickness := vqThemeManager.DividerThickness;
        // caption
        Font := Self.Font;
        TextStyle := LineTextStyle;
        Brush.Style := bsClear;
        TxtSz := TextExtent(Caption);
        
        if Enabled then AState := [vqthNormal]
        else AState := [vqthDisabled];
        if not Enabled then Font.Color := vqThemeManager.DisabledFore;
        
        case FOrientation of
            vqTextHorizontal: Font.Orientation := vqHorzTextLeftToRight;
            vqTextVerticalLeft: Font.Orientation := vqVertTextDownToUp;
            vqTextVerticalRight: Font.Orientation := vqVertTextUpToDown;
        end;
        TxtRect := Client;
        with TxtRect do
            case FOrientation of
                vqTextHorizontal: begin
                    case Alignment of
                        taLeftJustify: Inc(Left, Indent + Spacing);
                        taCenter: Left := (Left + Right - TxtSz.cx) div 2;
                        taRightJustify: Left := Right - Indent - Spacing;
                    end;
                    Right := Left + TxtSz.cx;
                end;
                vqTextVerticalLeft: begin
                    case Alignment of
                        taLeftJustify: Top := Bottom - Indent - Spacing;
                        taCenter: Top := (Top + Bottom - TxtSz.cy) div 2;
                        taRightJustify: Top := Top + Indent + Spacing;
                    end;
                    Bottom := Top + TxtSz.cy;
                end;
                vqTextVerticalRight: begin
                    case Alignment of
                        taLeftJustify: Top := Top + Indent + Spacing;
                        taCenter: Top := (Top + Bottom - TxtSz.cy) div 2;
                        taRightJustify: Top := Bottom - Indent - Spacing;
                    end;
                    Bottom := Top + TxtSz.cy;
                end;
            end;
        case FOrientation of
            vqTextHorizontal: TextRect(TxtRect, TxtRect.Left, TxtRect.Top, Caption);
            vqTextVerticalLeft: TextRect(TxtRect, TxtRect.Left, TxtRect.Bottom - 1, Caption);
            vqTextVerticalRight: TextRect(TxtRect, TxtRect.Right - 1, TxtRect.Top, Caption);
        end;
        
        // trace
        Trace := Client;
        with Trace do
            case FOrientation of
                vqTextHorizontal: begin
                    case Layout of
                        tlTop: Bottom := Top + Thickness;
                        tlBottom: Top := Bottom - Thickness;
                    end;
                    TxtRect.Inflate(Spacing, 0);
                end;
                vqTextVerticalLeft: begin
                    case Layout of
                        tlTop: Right := Left + Thickness;
                        tlBottom: Left := Right - Thickness;
                    end;
                    TxtRect.Inflate(0, Spacing);
                end;
                vqTextVerticalRight: begin
                    case Layout of
                        tlTop: Left := Right - Thickness;
                        tlBottom: Right := Left + Thickness;
                    end;
                    TxtRect.Inflate(0, Spacing);
                end;
            end;

        if (FLayout = tlCenter) and (Caption <> '') then begin
            TraceTL := Trace;
            TraceBR := Trace;
            if FOrientation = vqTextHorizontal then begin
                TraceTL.Right := TxtRect.Left - Spacing;
                TraceBR.Left := TxtRect.Right + Spacing;
                vqThemeManager.DrawHorzDivider(Self, Canvas, TraceTL, AState);
                vqThemeManager.DrawHorzDivider(Self, Canvas, TraceBR, AState);
            end
            else begin                           
                TraceTL.Bottom := TxtRect.Top - Spacing;
                TraceBR.Top := TxtRect.Bottom + Spacing;
                vqThemeManager.DrawVertDivider(Self, Canvas, TraceTL, AState);
                vqThemeManager.DrawVertDivider(Self, Canvas, TraceBR, AState);
            end;
        end
        else
            if FOrientation = vqTextHorizontal then
                vqThemeManager.DrawHorzDivider(Self, Canvas, Trace, AState)
            else
                vqThemeManager.DrawVertDivider(Self, Canvas, Trace, AState);
    end;
    inherited;
end;

end.
