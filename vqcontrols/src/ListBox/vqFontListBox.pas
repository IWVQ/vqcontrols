// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqFontListBox;

interface
        
{$MODESWITCH ADVANCEDRECORDS}

uses
    InterfaceBase, LCLIntf, LCLType, LMessages,
    Classes, Types, SysUtils, Controls, Graphics, Math, ExtCtrls,
    ComCtrls, Menus, ImgList, ActnList, Dialogs, Forms, Buttons, StdCtrls,
    BGRABitmap, BGRACanvas, BGRABitmapTypes,
    vqUtils, vqThemes, vqScrollingControl, vqToolTip,
    vqFontUtils, vqButtons,
    vqStringList, vqListBoxUtils, vqListBoxBuffer, vqListBox;

type

    TvqFontItemRenderer = record
        WYSIWYG: Boolean;
        CharSet: TFontCharSet;
        Pitch: TFontPitch;
        Options: TvqFontOptions;
        AuxFaces: TStrArray;
        procedure DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; 
            AIndex: Integer; AState: TvqThemeState);
        procedure MeasureItem(Sender: TObject; AIndex: Integer;
            var AWidth, AHeight: Integer);
    end;
    
implementation

{ TvqFontItemRenderer }

function FontTypeFromData(AData: Longint): Longint;
begin
    Result := AData shr 12;
end;

procedure TvqFontItemRenderer.DrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; 
    AIndex: Integer; AState: TvqThemeState);
var
    ListBox: TvqListBox;
    Item: TvqListBoxItem;
    Str: string;
    SzG, SzT: TSize;
    GlXY, TxtXY: TPoint;
    DCIndex: Integer;


begin
    if not (Sender is TvqListBox) then Exit;
    
    with ACanvas do begin
        ListBox := TvqListBox(Sender);
        Item := ListBox.Items[AIndex];
        
        
        
        Font := ListBox.Font;
        if WYSIWYG then begin
            if AuxFaces <> nil then
                Font.Name := AuxFaces[AIndex]
            else
                Font.Name := Item.Text;
            Font.Style := StyleFromMask(Item.Data);
        end;
        if not ListBox.Enabled then Font.Color := vqThemeManager.DisabledFore
        else if vqthSelected in AState then Font.Color := vqThemeManager.HiliteFore;
        Str := Item.Text;
        if vqfoFontImages in Options then
            SzG := vqThemeManager.FontTypeIconSize(FontTypeFromData(Item.Data))
        else
            SzG := TSize.Zero;
        
        if Str = '' then
            SzT := TSize.Create(0, TextExtent('Qq').cy)
        else
            SzT := TextExtent(Str);
        
        GlXY.Y := (ARect.Top + ARect.Bottom - SzG.cy) div 2;
        TxtXY.Y := (ARect.Top + ARect.Bottom - SzT.cy) div 2;
        
        GlXY.X := ARect.Left;
        TxtXY.X := GlXY.X + SzG.cx;
        
        DCIndex := WidgetSet.SaveDC(Handle);
        WidgetSet.IntersectClipRect(Handle, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
        
        if vqfoFontImages in Options then
            vqThemeManager.DrawFontTypeIcon(ListBox, ACanvas, FontTypeFromData(Item.Data), GlXY.X, GlXY.Y, ListBox.Enabled);
        ACanvas.TextRect(ARect, TxtXY.X, TxtXY.Y, Str, LineTextStyle);
        
        WidgetSet.RestoreDC(Handle, DCIndex);
    end;
end;

procedure TvqFontItemRenderer.MeasureItem(Sender: TObject; AIndex: Integer;
    var AWidth, AHeight: Integer);
var
    Item: TvqListBoxItem;
    Str: string;
    SzG, SzT: TSize;
begin
    if Sender is TvqListBox then
    with TvqListBox(Sender).Canvas do begin
        Item := TvqListBox(Sender).Items[AIndex];
        
        Font := TvqListBox(Sender).Font;
        if WYSIWYG then begin
            if AuxFaces <> nil then
                Font.Name := AuxFaces[AIndex]
            else
                Font.Name := Item.Text;
            Font.Style := StyleFromMask(Item.Data);
        end;
        
        Str := Item.Text;
        
        if vqfoFontImages in Options then
            SzG := vqThemeManager.FontTypeIconSize(FontTypeFromData(Item.Data))
        else
            SzG := TSize.Zero;
        
        if Str = '' then
            SzT := TSize.Create(0, TextExtent('Qq').cy)
        else
            SzT := TextExtent(Str);
        
        AWidth := SzT.cx + SzG.cx;
        AHeight := Max(SzT.cy, SzG.cy);
    end;
end;

end.

    
