// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqColorButton;

interface
        
uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Types, Classes, SysUtils, Graphics, Forms, Controls, StdCtrls, Buttons,
    ImgList, ActnList, Dialogs,
    BGRABitmap, BGRACanvas, BGRABitmapTypes,
    vqUtils, vqThemes, vqColorMap, vqButtons;

type

    { IvqColorButtonForm }
                      
    TvqColorButtonOption = (vqcboAlphaBlend, vqcboDefaultColor,
        vqcboNoneTransparent, vqcboNoneColor, vqcboPushOnly, vqcboAutoSizeColor);
    TvqColorButtonOptions = set of TvqColorButtonOption;

    TvqColorButton = class;

    IvqColorButtonDialog = interface

        function _GetAlpha: Byte;
        function _GetColor: TColor;
        procedure _SetAlpha(AValue: Byte);
        procedure _SetColor(AValue: TColor);
        function _ShowModal(AButton: TvqColorButton): Integer;
        
        property _Alpha: Byte read _GetAlpha write _SetAlpha;
        property _Color: TColor read _GetColor write _SetColor;
    end;

    { TvqColorButton }

    TvqColorButton = class(TvqButtonControl)
    private
        FValue: TColor;
        FAlpha: Byte;
        FColorDialog: TColorDialog;
        FCustomDialog: IvqColorButtonDialog;
        FOptions: TvqColorButtonOptions;
        FColorSize: Integer;
        FOnColorChanged: TNotifyEvent;
        FOnBeforeShowDialog: TNotifyEvent;
        FOnAfterShowDialog: TNotifyEvent;
        procedure SetOptions(Value: TvqColorButtonOptions);
        procedure SetValue(AValue: TColor);
        procedure SetAlpha(AValue: Byte);
        procedure SetColorOptions(AValue: TvqColorButtonOptions);
        procedure SetColorSize(AValue: Integer);
    protected
        const DefaultOptions = [vqcboDefaultColor, 
        vqcboNoneColor];
        function GlyphSize(AArea: TRect): TSize; override;
        procedure DrawGlyph(AArea, ARect: TRect); override;
        
        procedure DoBeforeShowDialog; virtual;
        procedure DoAfterShowDialog; virtual;
        procedure ShowColorDialog; virtual;
        procedure Click; override;
        property Glyph;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure SetColorAlpha(AColor: TColor; AAlpha: Byte);
        property ModalResult;
        property Default;
        property Cancel;
    published
        property Value: TColor read FValue write SetValue;
        property Alpha: Byte read FAlpha write SetAlpha;
        
        property ColorDialog: TColorDialog read FColorDialog write FColorDialog;
        property CustomDialog: IvqColorButtonDialog read FCustomDialog write FCustomDialog;
        property Options: TvqColorButtonOptions read FOptions write SetOptions;
        property ColorSize: Integer read FColorSize write SetColorSize;
        
        property OnColorChanged: TNotifyEvent read FOnColorChanged write FOnColorChanged;
        property OnBeforeShowDialog: TNotifyEvent read FOnBeforeShowDialog write FOnBeforeShowDialog;
        property OnAfterShowDialog: TNotifyEvent read FOnAfterShowDialog write FOnAfterShowDialog;
    end;

implementation

{ TvqColorButton }

constructor TvqColorButton.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FValue := clBlack;
    FAlpha := 255;
    FColorDialog := nil;
    FCustomDialog := nil;
    FOptions := DefaultOptions;
    FColorSize := 17;
    FCaptionRenderer.OwnerDraw := True;
    ControlStyle := ControlStyle - [csSetCaption];
end;

destructor TvqColorButton.Destroy;
begin
    inherited;
end;

function TvqColorButton.GlyphSize(AArea: TRect): TSize;
var
    TxtSz: TSize;
begin
    if vqcboAutoSizeColor in FOptions then begin
        Canvas.Font := Font;
        TxtSz := TextRectExtent(Canvas.Handle, AArea, Caption, TextFormat.Style);
        Result := AArea.Size;
        case Layout of
            blGlyphLeft, blGlyphRight: 
                Result.cx := AArea.Width - TxtSz.cx - Spacing;
            blGlyphTop, blGlyphBottom: 
                Result.cy := AArea.Height - TxtSz.cy - Spacing;
        end;
        if Result.cx < 0 then Result.cx := 0;
        if Result.cy < 0 then Result.cy := 0;
    end
    else
        Result := TSize.Create(FColorSize, FColorSize);
end;

procedure TvqColorButton.DrawGlyph(AArea, ARect: TRect);
var
    Bitmap: TBGRABitmap;
begin
    with Canvas do begin
        if Enabled then begin
            Bitmap := TBGRABitmap.Create(ARect.Width, ARect.Height, clNone);
            RenderColorPattern(Bitmap, ARect.Width, ARect.Height, FValue, FAlpha,
                vqcboNoneTransparent in FOptions);
            Bitmap.Draw(Canvas, ARect.Left, ARect.Top, False);
            Bitmap.Free;
        end
        else
            vqThemeManager.DrawHorzDivider(Self, Canvas, ARect, [vqthDisabled]);
    end;
end;

procedure TvqColorButton.DoBeforeShowDialog;
begin
    if Assigned(FOnBeforeShowDialog) then FOnBeforeShowDialog(Self);
end;

procedure TvqColorButton.DoAfterShowDialog;
begin
    if Assigned(FOnAfterShowDialog) then FOnAfterShowDialog(Self);
end;

procedure TvqColorButton.ShowColorDialog;
var
    FreeDialog: Boolean;
    AAlpha: Byte;
    AColor: TColor;
begin
    if Enabled and not(vqcboPushOnly in FOptions) then begin
        DoBeforeShowDialog;
        AAlpha := FAlpha;
        AColor := FValue;
        if (FCustomDialog <> nil) then begin
            FCustomDialog._Color := AColor;
            FCustomDialog._Alpha := AAlpha;
            if FCustomDialog._ShowModal(Self) = mrOK then begin
                AColor := FCustomDialog._Color;
                if vqcboAlphaBlend in FOptions then
                    AAlpha := FCustomDialog._Alpha;
            end;
        end
        else begin
            FreeDialog := FColorDialog = nil;
            if FreeDialog then
                FColorDialog := TColorDialog.Create(GetTopParent);
            try
                FColorDialog.Color := AColor;
                if FColorDialog.Execute then
                    AColor := FColorDialog.Color;
            finally
                if FreeDialog then
                    FreeAndNil(FColorDialog);
            end;
        end;
        SetColorAlpha(AColor, AAlpha);
        DoAfterShowDialog;
    end;
end;

procedure TvqColorButton.Click;
begin
    inherited;
    ShowColorDialog;
end;

procedure TvqColorButton.SetOptions(Value: TvqColorButtonOptions);
begin
    if FOptions <> Value then begin
        FOptions := Value;
        UpdateMetrics;
    end;
end;

procedure TvqColorButton.SetValue(AValue: TColor);
begin
    SetColorAlpha(AValue, FAlpha);
end;

procedure TvqColorButton.SetAlpha(AValue: Byte);
begin
    SetColorAlpha(FValue, AValue);
end;

procedure TvqColorButton.SetColorAlpha(AColor: TColor; AAlpha: Byte);
begin
    if (FValue <> AColor) or (FAlpha <> AAlpha) then begin
        FValue := AColor;
        FAlpha := AAlpha;
        Repaint;
    end;
end;

procedure TvqColorButton.SetColorOptions(AValue: TvqColorButtonOptions);
begin
    if FOptions <> AValue then begin
        FOptions := AValue;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

procedure TvqColorButton.SetColorSize(AValue: Integer);
begin
    if FColorSize <> AValue then begin
        FColorSize := AValue;
        InvalidatePreferredSize;
        AdjustSize;
    end;
end;

end.
