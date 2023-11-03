// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqFontUtils;

interface

uses
    InterfaceBase, LclIntf, LclType, LMessages, LResources,
    Types, SysUtils, Classes, Graphics, Controls, Math,
    vqUtils, vqStringList;

{
- font information from font or face
    - style names
    - current style name
    - sizes
    - type(device, raster, tt, ot)
    - monospaced
    - full font name
    - scripts
- list all font faces or names
- list all font full names
- in future posible including metrics
}

const

    MONOSPACED_FONT = $00000800;

type
    TvqFontOption = (vqfoMonospacedFonts, vqfoRasterFonts, vqfoDeviceFonts, 
        vqfoTrueTypeFont, vqfoUnknownFonts, vqfoFontFaces, vqfoFontStyles, 
        vqfoAddItalic, vqfoSortNames, vqfoSortStyles, vqfoFontImages);
    TvqFontOptions = set of TvqFontOption;
    
procedure FontFaceList(Options: TvqFontOptions; Pitch: TFontPitch; Charset: TFontCharset;
    var List: TvqStringList);
procedure FontFullFaceList(Options: TvqFontOptions; Pitch: TFontPitch; Charset: TFontCharset;
    var List: TvqStringList; var AuxFaces: TStrArray);
procedure FontCharsetList(Sort: Boolean; Face: TFontName; 
    var List: TvqStringList);
procedure FontFamilyList(Options: TvqFontOptions; CollectingSize: Boolean; Face: TFontName; Charset: TFontCharset; 
    var StyleList, SizeList: TvqStringList);

function FullNameAndTypeFromFont(Font: TFont; AddItalic: Boolean; var AType: Integer): TFontName;
function StyleFromMask(Mask: Integer): TFontStyles;

implementation

var
    Font: TFont = nil;
    FontIsTTF: Boolean;
    FontOptions: TvqFontOptions;
    SzList: TvqStringList;
    
function EnumFontsProc(var LogFont: TEnumLogFontEx; var Metric: TNewTextMetricEx;
    FontType: Longint; Data: LParam): LongInt; stdcall;
var
    List: TvqStringList;
    S: string;
    CanAdd, IsMono: Boolean;
    Mask: Integer;
begin
    List := TvqStringList(ptrint(Data));
    
    S := LogFont.elfLogFont.lfFaceName;
    // filter
    CanAdd := False;
    case FontType of
        RASTER_FONTTYPE: CanAdd := vqfoRasterFonts in FontOptions;
        DEVICE_FONTTYPE: CanAdd := vqfoDeviceFonts in FontOptions;
        TRUETYPE_FONTTYPE: CanAdd := vqfoTrueTypeFont in FontOptions;
        else CanAdd := vqfoUnknownFonts in FontOptions;
    end;
    Font.Name := S;
    IsMono := Font.IsMonoSpace;
    if CanAdd and (vqfoMonospacedFonts in FontOptions) then
        CanAdd := IsMono;
    
    // add
    if CanAdd and (List.IndexOf(S) < 0) then begin
        Mask := FontType shl 12;
        if IsMono then Mask := Mask or MONOSPACED_FONT;
        List.AddData(S, Mask);
    end;
    Result := 1;
end;

function EnumCharsetProc(var LogFont: TEnumLogFontEx; var Metric: TNewTextMetricEx;
    FontType: Longint; Data: LParam): LongInt; stdcall;
var
    List: TvqStringList;
    S: string;
begin
    List := TvqStringList(ptrint(Data));
    S := CharsetToString(LogFont.elfLogFont.lfCharset);
    if List.IndexOf(S) < 0 then
        List.AddData(S, LogFont.elfLogFont.lfCharset);
    Result := 1;
end;


function EnumFamilyProc(var LogFont: TEnumLogFontEx; var Metric: TNewTextMetricEx;
    FontType: Longint; Data: LParam): LongInt; stdcall;
var
    StyleList: TvqStringList;
    S: string;
    Mask, Sz: Integer;
begin
    StyleList := TvqStringList(ptrint(Data));
    
    // collect styles
    if vqfoFontFaces in FontOptions then S := LogFont.elfFullName
    else S := LogFont.elfStyle;
    if StyleList.IndexOf(S) < 0 then begin
        // encode italic and weight
        
        Mask := LogFont.elfLogFont.lfItalic and $00000001;
        Mask := Mask or LogFont.elfLogFont.lfWeight;
        // encode mono
        if Font.IsMonoSpace then // font name previously assigned
            Mask := Mask or MONOSPACED_FONT;
        // encode font type
        Mask := Mask or (FontType shl 12);
        // 
        StyleList.AddData(S, Mask);
    end;
    
    // collect sizes
    if FontType = TRUETYPE_FONTTYPE then
        FontIsTTF := True
    else if SzList <> nil then 
        with Metric.ntmentm do
            if tmDigitizedAspectY <> 0 then begin
                Sz := (tmHeight - tmInternalLeading)*72 + tmDigitizedAspectY shr 1;
                Sz := Sz div tmDigitizedAspectY;
                if Sz > 0 then begin
                    S := IntToStr(Sz);
                    if SzList.IndexOf(S) < 0 then
                        SzList.AddData(S, Sz);
                end;
            end;
    Result := 1;
end;

//--------------

procedure FontFaceList(Options: TvqFontOptions; Pitch: TFontPitch; Charset: TFontCharset;
    var List: TvqStringList);
var
    Lf: TLogFont;
    DC: HDC;
begin
    if List = nil then List := TvqStringList.Create;
    if Charset < 0 then Charset := DEFAULT_CHARSET;
    Lf.lfCharset := Byte(Charset);
    Lf.lfFaceName := '';
    case Pitch of
        fpDefault  : Lf.lfPitchAndFamily := DEFAULT_PITCH;
        fpVariable : Lf.lfPitchAndFamily := VARIABLE_PITCH;
        fpFixed    : Lf.lfPitchAndFamily := FIXED_PITCH;
    end;
    FontOptions := Options;
    
    Font := TFont.Create;
    
    DC := GetDC(0);
    try
        EnumFontFamiliesEX(DC, @Lf, @EnumFontsProc, ptrint(List), 0);
        
        if vqfoSortNames in Options then 
            List.Sort;
    finally
        ReleaseDC(0, DC);
        FreeAndNil(Font);
    end;
end;

procedure FontFullFaceList(Options: TvqFontOptions; Pitch: TFontPitch; Charset: TFontCharset;
    var List: TvqStringList; var AuxFaces: TStrArray);
var
    I, K: Integer;
    FaceList: TvqStringList;
    StyleList, SizeList: TvqStringList;
    
    procedure EnsureAuxFacesRoom;
    begin
        if List.Count = Length(AuxFaces) then 
            SetLength(AuxFaces, List.Count + 16);
    end;
    
begin
    if List = nil then List := TvqStringList.Create;
    FaceList := nil;
    FontFaceList(Options, Pitch, Charset, FaceList);
    Options := Options + [vqfoFontFaces, vqfoFontStyles];
    try
        List.Capacity := FaceList.Count*4;
        for I := 0 to FaceList.Count - 1 do begin
            StyleList := nil;
            SizeList := nil;
            FontFamilyList(Options, False, FaceList[I], Charset, StyleList, SizeList);
            EnsureAuxFacesRoom;
            
            if StyleList.Count = 0 then begin
                AuxFaces[List.Count] := FaceList[I];
                List.AddData(FaceList[I], FaceList.Datas[I] or FW_REGULAR);
            end
            else
                for K := 0 to StyleList.Count - 1 do begin
                    EnsureAuxFacesRoom;
                    AuxFaces[List.Count] := StyleList[K];
                    List.AddData(StyleList[K], FaceList.Datas[I] or StyleList.Datas[K]);
                end;
        end;
    finally
        SetLength(AuxFaces, List.Count);
        if StyleList <> nil then StyleList.Free;
        if FaceList <> nil then FaceList.Free;
    end;
end;

procedure FontCharsetList(Sort: Boolean; Face: TFontName; 
    var List: TvqStringList);
var
    Lf: TLogFont;
    DC: HDC;
begin
    if Face = '' then Exit;
    if List = nil then List := TvqStringList.Create;
    
    Lf.lfFaceName := Face;
    Lf.lfCharset := DEFAULT_CHARSET;
    Lf.lfPitchAndFamily := 0;
    
    DC := GetDC(0);
    try
        EnumFontFamiliesEX(DC, @Lf, @EnumCharsetProc, ptrint(List), 0);
    
        if Sort then List.Sort;
    finally
        ReleaseDC(0, DC);
    end;
end;

function CompareSizeItem(Left, Right: TvqStringItem): Integer;
begin
    Result:= Left.Data - Right.Data;
end;

procedure FontFamilyList(Options: TvqFontOptions; CollectingSize: Boolean; Face: TFontName; Charset: TFontCharset; 
    var StyleList, SizeList: TvqStringList);
var
    Lf: TLogFont;
    DC: HDC;
    CheckedWeights: array[0 .. 9] of Boolean;
    I, Mask, K: Integer;
    S: string;
    
    procedure AddSize(Sz: Integer);
    begin
        SizeList.AddData(IntToStr(Sz), Sz);
    end;
    
begin
    
    if StyleList = nil then StyleList := TvqStringList.Create;
    if CollectingSize and (SizeList = nil) then SizeList := TvqStringList.Create;
    if Charset < 0 then Charset := DEFAULT_CHARSET;
    if Face = '' then Face := 'default';
    
    Lf.lfFaceName := Face;
    Lf.lfCharset := Byte(Charset);
    Lf.lfPitchAndFamily := 0;
    FontOptions := Options;
    
    Font := TFont.Create;
    Font.Name := Face;
    DC := GetDC(0);
    try
        FontIsTTF := False;
        if CollectingSize then SzList := SizeList
        else SzList := nil;
        EnumFontFamiliesEX(DC, @Lf, @EnumFamilyProc, ptrint(StyleList), 0);
        if FontIsTTF and (vqfoAddItalic in Options) then begin
            
            FillChar(CheckedWeights, SizeOf(CheckedWeights), 0);
            I := 0;
            while I < StyleList.Count do begin
                Mask := StyleList.Datas[I];
                if CheckedWeights[Mask div 100] then Continue;
                for K := I to StyleList.Count - 1 do begin
                    if (Mask and $FFFFFFFE) = (StyleList.Datas[K] and $FFFFFFFE) then
                        Mask := Mask or StyleList.Datas[K];
                end;
                if (Mask and $00000001) = 0 then begin
                    if (Mask and $FFFFFFFE) = FW_REGULAR then begin
                        if vqfoFontFaces in Options then
                            S := Face
                        else
                            S := '';
                    end
                    else
                        S := StyleList[I];
                    S := S + ' Oblique';
                    Mask := Mask or $00000001;
                    StyleList.InsertObject(I + 1, S, TObject(ptrint(Mask)));
                end;
                CheckedWeights[Mask div 100] := True;
                Inc(I);
            end;
            
        end;
        if vqfoSortStyles in Options then
            StyleList.Sort;
        if CollectingSize then begin
            if FontIsTTF then begin
                AddSize(08); 
                AddSize(09); 
                AddSize(10);
                AddSize(11);
                AddSize(12);
                AddSize(14);
                AddSize(16);
                AddSize(18);
                AddSize(20);
                AddSize(22);
                AddSize(24);
                AddSize(26);
                AddSize(28);
                AddSize(36);
                AddSize(48);
                AddSize(72);
            end
            else begin
                SizeList.CompareMethod := TvqStringListComparer(@CompareSizeItem);
                SizeList.Sort; // sorted by default
            end;
        end;
        
    finally
        ReleaseDC(0, DC);
        FreeAndNil(Font);
    end;
    
end;

function FullNameAndTypeFromFont(Font: TFont; AddItalic: Boolean; var AType: Integer): TFontName;
var
    StyleList, SizeList: TvqStringList;
    Options: TvqFontOptions;
    I, Mask, Weight: Integer;
    Italic: Boolean;
begin
    StyleList := nil;
    Options := [vqfoRasterFonts, vqfoDeviceFonts, 
        vqfoTrueTypeFont, vqfoUnknownFonts, vqfoFontFaces, vqfoFontStyles];
    if AddItalic then Options := Options + [vqfoAddItalic];
    FontFamilyList(Options, False, Font.Name, Font.Charset, StyleList, SizeList);
    
    Result := Font.Name;
    AType := 0;
    for I := 0 to StyleList.Count - 1 do begin
        Mask := StyleList.Datas[I];
        AType := Mask shr 12;
        Weight := Mask and $00000FFE;
        Italic := (Mask and $00000001) <> 0;
        if Italic and (fsItalic in Font.Style) then
            if (Weight > FW_MEDIUM) and (fsBold in Font.Style) then begin
                Result := StyleList[I];
                Break;
            end;
    end;
    
end;

function StyleFromMask(Mask: Integer): TFontStyles;
begin
    Result := [];
    if (Mask and $00000001) <> 0 then Result := Result + [fsItalic];
    if (Mask and $00000FFE) > FW_MEDIUM then Result := Result + [fsBold];
end;

finalization

    if Font <> nil then FreeAndNil(Font);

end.
