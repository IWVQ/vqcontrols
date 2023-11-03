// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqFontButton;

interface
     
uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Types, Classes, SysUtils, Graphics, Forms, Controls, StdCtrls, Buttons,
    ImgList, ActnList, Dialogs,
    BGRABitmap, BGRACanvas, BGRABitmapTypes,
    vqUtils, vqFontUtils, vqThemes, vqButtons;

type

    TvqFontButton = class;
                       
    TvqFontButtonOption = (vqfboShowStyle, vqfboShowSize, vqfboAddItalic,
        vqfboPushOnly, vqfboShowImage, vqfboAutoSizeFont);
    TvqFontButtonOptions = set of TvqFontButtonOption;

    IvqFontButtonDialog = interface
        function _GetFontValue: TFont;
        procedure _SetFontValue(Value: TFont);
        function _ShowModal(AButton: TvqFontButton): Integer;
        property _FontValue: TFont read _GetFontValue write _SetFontValue;
    end;

    { TvqFontButton }

    TvqFontButton = class(TvqButtonControl)
    private
        FFontName: string;
        FFontType: Integer;
        FFontValue: TFont;
        FFontDialog: TFontDialog;
        FCustomDialog: IvqFontButtonDialog;
        FOptions: TvqFontButtonOptions;
        FWYSIWYG: Boolean;
        
        FFontAlignment: TAlignment;
        FSizeAlignment: TAlignment;
        FFontSpacing: Integer;
        
        FOnFontChanged: TNotifyEvent;
        FOnBeforeShowDialog: TNotifyEvent;
        FOnAfterShowDialog: TNotifyEvent;
        procedure UpdateFontParams;
        procedure OnFontValueChange(Sender: TObject);
        procedure SetFontValue(Value: TFont);
        procedure SetOptions(Value: TvqFontButtonOptions);
        procedure SetWYSIWYG(Value: Boolean);
        procedure SetFontAlignment(Value: TAlignment);
        procedure SetSizeAlignment(Value: TAlignment);
        procedure SetFontSpacing(Value: Integer);
    protected
        const DefaultOptions = [vqfboShowSize];
        function GlyphSize(AArea: TRect): TSize; override;
        procedure DrawGlyph(AArea, ARect: TRect); override;
        function FontValueText: string;
        
        procedure DoFontValueChanged; virtual;
        procedure DoBeforeShowDialog; virtual;
        procedure DoAfterShowDialog; virtual;
        procedure ShowFontDialog; virtual;
        procedure Click; override;
        procedure UpdateMetrics; override;
        property Glyph;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        
        property ModalResult;
        property Default;
        property Cancel;
    published
        property FontValue: TFont read FFontValue write SetFontValue;
        
        property FontDialog: TFontDialog read FFontDialog write FFontDialog;
        property CustomDialog: IvqFontButtonDialog read FCustomDialog write FCustomDialog;
        property Options: TvqFontButtonOptions read FOptions write SetOptions;
        property WYSIWYG: Boolean read FWYSIWYG write SetWYSIWYG;
        property FontAlignment: TAlignment read FFontAlignment write SetFontAlignment;
        property SizeAlignment: TAlignment read FSizeAlignment write SetSizeAlignment;
        property FontSpacing: Integer read FFontSpacing write SetFontSpacing;
        
        property OnFontChanged: TNotifyEvent read FOnFontChanged write FOnFontChanged;
        property OnBeforeShowDialog: TNotifyEvent read FOnBeforeShowDialog write FOnBeforeShowDialog;
        property OnAfterShowDialog: TNotifyEvent read FOnAfterShowDialog write FOnAfterShowDialog;
    end;
    
//! WYSIWYG affects only FontName and FontStyle

implementation

{ TvqFontButton }

constructor TvqFontButton.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FFontValue := TFont.Create;
    FFontValue.OnChange := @OnFontValueChange;
    FFontDialog := nil;
    FCustomDialog := nil;
    FOptions := DefaultOptions;
    FWYSIWYG := True;
    
    FFontAlignment := taCenter;
    FSizeAlignment := taRightJustify;
    FFontSpacing := 20;
    
    FCaptionRenderer.OwnerDraw := True;
    ControlStyle := ControlStyle - [csSetCaption];
end;

destructor TvqFontButton.Destroy;
begin
    FFontValue.Free;
    inherited;
end;

function TvqFontButton.GlyphSize(AArea: TRect): TSize;
var
    S: string;
    Sz, SzSz, TxtSz, GlSz: TSize;
    I: Integer;
begin
    if vqfboAutoSizeFont in FOptions then begin
        S := FontValueText;
        if FWYSIWYG then
            Canvas.Font := FontValue
        else
            Canvas.Font := Font;
        TxtSz := TextRectExtent(Canvas.Handle, AArea, S, LineTextStyle);
        GlSz := vqThemeManager.FontTypeIconSize(FFontType);
        
        Sz := TxtSz;
        if Sz.cy = 0 then Sz.cy := Canvas.TextHeight('Qq');
        if Sz.cy < GlSz.cy then Sz.cy := GlSz.cy;
        Inc(Sz.cx, GlSz.cx);
        if vqfboShowSize in FOptions then begin
            Inc(Sz.cx, FFontSpacing);
            Canvas.Font := Font;
            SzSz := Canvas.TextExtent(IntToStr(FontValue.Size));
            Inc(Sz.cx, SzSz.cx);
            if Sz.cy < SzSz.cy then 
                Sz.cy := SzSz.cy;
        end;
        
    end
    else begin
        Canvas.Font := Font;
        TxtSz := TextRectExtent(Canvas.Handle, AArea, Caption, TextFormat.Style);
        Sz := AArea.Size;
        case Layout of
            blGlyphLeft, blGlyphRight: 
                Sz.cx := AArea.Width - TxtSz.cx - Spacing;
            blGlyphTop, blGlyphBottom: 
                Sz.cy := AArea.Height - TxtSz.cy - Spacing;
        end;
        if Sz.cx < 0 then Sz.cx := 0;
        if Sz.cy < 0 then Sz.cy := 0;
    end;
    Result := Sz;
end;

procedure TvqFontButton.DrawGlyph(AArea, ARect: TRect);
var
    GlSz, TxtSz, SSz: TSize;
    GlXY, TxtXY, SXY: TPoint;
    S: String;
    AFontSpacing: Integer;
begin
    
    // sizes
    
    if vqfboShowImage in FOptions then
        GlSz := vqThemeManager.FontTypeIconSize(FFontType)
    else
        GlSz := TSize.Create(0, 0);
    
    S := FontValueText;
    if FWYSIWYG then
        Canvas.Font := FontValue
    else
        Canvas.Font := Font;
    TxtSz := TextRectExtent(Canvas.Handle, ARect, S, LineTextStyle);
    if TxtSz.cy = 0 then TxtSz.cy := Canvas.TextHeight('Qq');
    
    if vqfboShowSize in FOptions then begin
        Canvas.Font := Font;
        SSz := Canvas.TextExtent(IntToStr(FontValue.Size));
        AFontSpacing := FFontSpacing;
    end
    else begin
        SSz := TSize.Create(0, 0);
        AFontSpacing := 0;
    end;
    
    // positions
    
    GlXY.Y := (ARect.Top + ARect.Bottom - GlSz.cy) div 2;
    TxtXY.Y := (ARect.Top + ARect.Bottom - TxtSz.cy) div 2;
    SXY.Y := (ARect.Top + ARect.Bottom - SSz.cy) div 2;
    
    case FFontAlignment of
        taLeftJustify:
            GlXY.X := ARect.Left;
        taCenter:
            GlXY.X := (ARect.Left + ARect.Right - (GlSz.cx + TxtSz.cx + SSz.cx + AFontSpacing)) div 2;
        taRightJustify:
            GlXY.X := ARect.Right - (GlSz.cx + TxtSz.cx + SSz.cx + AFontSpacing);
    end;
    TxtXY.X := GlXY.X + GlSz.cx;
    case FSizeAlignment of
        taLeftJustify: SXY.X := TxtXY.X + TxtSz.cx + AFontSpacing;
        taCenter: 
            if FFontAlignment = taLeftJustify then
                SXY.X := (ARect.Left + GlSz.cx + TxtSz.cx + AFontSpacing + ARect.Right - SSz.cx) div 2
            else 
                SXY.X := TxtXY.X + TxtSz.cx + AFontSpacing;
        taRightJustify: SXY.X := ARect.Right - SSz.cx;
    end;
    
    with Canvas do begin
        if vqfboShowImage in FOptions then
            vqThemeManager.DrawFontTypeIcon(Self, Canvas, FFontType, GlXY.X, GlXY.Y, Enabled);
        if S <> '' then begin
            if FWYSIWYG then
                Font := FontValue
            else
                Font := Self.Font;
            if not Enabled then Font.Color := vqThemeManager.DisabledFore;
            TextRect(ARect, TxtXY.X, TxtXY.Y, S, LineTextStyle);
        end;
        if vqfboShowSize in FOptions then begin
            Font := Self.Font;
            if not Enabled then Font.Color := vqThemeManager.DisabledFore;
            TextOut(SXY.X, SXY.Y, IntToStr(FontValue.Size));
        end;
    end;
end;

function TvqFontButton.FontValueText: string;
begin
    Result := FFontName;
end;

procedure TvqFontButton.DoFontValueChanged;
begin
    if Assigned(FOnFontChanged) then FOnFontChanged(Self);
end;

procedure TvqFontButton.DoBeforeShowDialog;
begin
    if Assigned(FOnBeforeShowDialog) then FOnBeforeShowDialog(Self);
end;

procedure TvqFontButton.DoAfterShowDialog;
begin
    if Assigned(FOnAfterShowDialog) then FOnAfterShowDialog(Self);
end;

procedure TvqFontButton.ShowFontDialog;
var
    FreeDialog: Boolean;
begin
    if Enabled and not(vqfboPushOnly in FOptions) then begin
        DoBeforeShowDialog;
        if (FCustomDialog <> nil) then begin
            FCustomDialog._FontValue := FontValue;
            if FCustomDialog._ShowModal(Self) = mrOK then
                FontValue := FCustomDialog._FontValue;
        end
        else begin
            FreeDialog := FFontDialog = nil;
            if FreeDialog then
                FFontDialog := TFontDialog.Create(GetTopParent);
            try
                FFontDialog.Font := FontValue;
                if FFontDialog.Execute then
                    FontValue := FFontDialog.Font;
            finally
                if FreeDialog then
                    FreeAndNil(FFontDialog);
            end;
        end;
        DoAfterShowDialog;
    end;
end;

procedure TvqFontButton.Click;
begin
    inherited;
    ShowFontDialog;
end;

procedure TvqFontButton.UpdateMetrics;
begin
    inherited;
end;

procedure TvqFontButton.UpdateFontParams;
begin
    FFontName := FullNameAndTypeFromFont(FFontValue, vqfboAddItalic in FOptions, FFontType);
    if not (vqfboShowStyle in FOptions) then
        FFontName := FFontValue.Name;
end;

procedure TvqFontButton.OnFontValueChange(Sender: TObject);
begin
    UpdateFontParams;
    InvalidatePreferredSize;
    AdjustSize;
    DoFontValueChanged;
end;

procedure TvqFontButton.SetFontValue(Value: TFont);
begin
    FFontValue.Assign(Value);
end;

procedure TvqFontButton.SetOptions(Value: TvqFontButtonOptions);
begin
    if FOptions <> Value then begin
        FOptions := Value;
        UpdateFontParams;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqFontButton.SetWYSIWYG(Value: Boolean);
begin
    if FWYSIWYG <> Value then begin
        FWYSIWYG := Value;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqFontButton.SetFontAlignment(Value: TAlignment);
begin
    if FFontAlignment <> Value then begin
        FFontAlignment := Value;
        UpdateMetrics;
    end;
end;

procedure TvqFontButton.SetSizeAlignment(Value: TAlignment);
begin
    if FSizeAlignment <> Value then begin
        FSizeAlignment := Value;
        UpdateMetrics;
    end;
end;

procedure TvqFontButton.SetFontSpacing(Value: Integer);
begin
    if FFontSpacing <> Value then begin
        FFontSpacing := Value;
        UpdateMetrics;
    end;
end;

end.
