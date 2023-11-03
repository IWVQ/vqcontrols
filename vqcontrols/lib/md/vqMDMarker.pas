// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqMDMarker;

interface

uses
    InterfaceBase, LCLIntf, LclType, FileUtil, URIParser,
    Types, SysUtils, Classes, Graphics, Controls,
    ImgList, StdCtrls, Math, StrUtils, Dialogs,
    vqUtils, vqThemes, vqAutoURL, vqAutoPath;
    
const
    
    MARK_NORMAL      = $00;
    MARK_BOLD        = $01;
    MARK_ITALIC      = $02;
    MARK_UNDERLINE   = $04;
    MARK_STRIKEOUT   = $08;
    MARK_CODE        = $10;
    MARK_LINK        = $20;
    MARK_IMAGE       = $40;
    MARK_VISITED     = $80;
    
    MARK_CMD_NONE         = $0000;
    MARK_CMD_AUTOOPENURL  = $0100;
    MARK_CMD_DOWN         = $0001;
    MARK_CMD_MOVE         = $0002;
    MARK_CMD_UP           = $0003;
    MARK_CMD_ENTER        = $0004;
    MARK_CMD_LEAVE        = $0008;
    
type
    TvqMarkOption = (vqmoAutoURLDetect, vqmoCodeFenceAutoURL, vqmoCopyright,
        vqmoQuotation);
    TvqMarkOptions = set of TvqMarkOption;
    TvqHyperlinkEvent = procedure(Sender: TObject; ALabel, AAddress, AHint: string;
        AIndex: Integer; var Opened: Boolean) of object;
    TvqImageRequestEvent = procedure(Sender: TObject; URI: string; Picture: TPicture; var Handled: Boolean) of object;

    TvqMarkedText = class;

    TvqMarkLink = class
    private
        FMarkedText: TvqMarkedText;
        FPos, FLen: Integer;
        FLabel: string;
        FAddress: string;
        FHint: string;
        FIndex: Integer;
        function GetLabel: string;
        function GetVisited: Boolean;
        procedure SetVisited(Value: Boolean);
    public
        constructor Create(AMarkedText: TvqMarkedText; AIndex: Integer);
        destructor Destroy; override;
        function InRange(APos: Integer): Boolean;
        function BeforeLimit(APos: Integer): Boolean;
        function AfterRange(APos: Integer): Boolean;
        function BeforeRange(APos: Integer): Boolean;
        property Pos: Integer read FPos;
        property Len: Integer read FLen;
        property _Label: string read GetLabel;
        property Address: string read FAddress;
        property Hint: string read FHint;
        property Visited: Boolean read GetVisited write SetVisited;
        property Index: Integer read FIndex;
    end;
    
    TvqMarkImage = class
    private const
        OTHER_URI   = 00;
        HTTP_URI    = 01;
        HTTPS_URI   = 02;
        FILE_URI    = 03;
        PATH_URI    = 04;

    private
        
        FMarkedText: TvqMarkedText;
        FPicture: TPicture;
        FAlt: string;
        FAddress: string;
        FHint: string;
        FIndex: Integer;        
        function LoadPictureFromFile(FileName: TFileName): Boolean;
    public
        constructor Create(AMarkedText: TvqMarkedText; AIndex: Integer);
        destructor Destroy; override;
        procedure Reload;
        function CalculateSize(Canvas: TCanvas): TSize;
        procedure Draw(Canvas: TCanvas; X, Y: Integer; Enabled: Boolean);
        property Picture: TPicture   read FPicture;
        property Alt: string         read FAlt;
        property Address: string     read FAddress;
        property Hint: string        read FHint;
        property Index:  Integer     read FIndex;
    end; { image indexes are encoded as a utf-8 character }

    TvqMarkStyle = class;

    TvqMarkedText = class(TvqObject, IvqTextBuffer)
    private const 
        
    private
        FMetricBmp: TBitmap;
        FUpdatingBuffer: Boolean;
        
        function GetLinkAt(Index: Integer): TvqMarkLink;
        function GetMark(Index: Integer): Byte;
        function GetChar(Index: Integer): Char;
        procedure SetMark(Index: Integer; Value: Byte);
        
        function CalculateRowLimit(Row: Integer): Integer;
        procedure InternalCalculateLocation(Area: TRect; Canvas: TCanvas; Format: TTextStyle;
            var Sizes: TSizeArray; var Starts, RowsLeft, RowsBottom, RowsWidth: TIntArray;
            var Origin: TPoint; var Ellipsis: Integer; var Extent: TSize;
            var EmptyRowHeight: Integer);
    public
        function _GetChar(Pos: Integer): Char;
        function _GetString(Pos, Len: Integer): string;
        function _GetArray(Pos, Len: Integer; var Txt: TCharArray): Boolean;
        function _TextLength: Integer;
        function _WholeWordAt(PosFrom, PosTo: Integer): Boolean;
    public
        
        FLinks: array of TvqMarkLink;
        FImages: array of TvqMarkImage;
        
        // text
        FChars: TCharArray; {utf-8}
        FMarks: TByteArray;
        FLinesCount: Integer;
        
        // location
        
        FSizes: TSizeArray;
        FStarts: TIntArray;
        
        FRowsLeft: TIntArray;
        FRowsBottom: TIntArray;
        FRowsWidth: TIntArray;
        FOrigin: TPoint;
        FExtent: TSize;
        FEllipsis: Integer;
        FEmptyRowHeight: Integer;
        
        // interaction
        
        FPressedLink, FHoveredLink: TvqMarkLink;
        
    public
        
        MarkStyle: TvqMarkStyle;
        Font: TFont;
        TextArea: TRect;
        TextFormat: TTextStyle;
        OnRequestEvent: TvqImageRequestEvent;
        OnHyperlinkEvent: TvqHyperlinkEvent;
        
        constructor Create(AStyle: TvqMarkStyle; AFont: TFont);
        destructor Destroy; override;
        
        function Parse(Text: IvqTextBuffer; Options: TvqMarkOptions): Boolean;
        function Locate(AArea: TRect; AFormat: TTextStyle): Boolean;
        function Render(Canvas: TCanvas; Enabled: Boolean): Boolean;
        function Perform(Sender: TObject; Command: Word; X, Y: Integer): Boolean;
        
        function TextExtentFor(Format: TTextStyle; WrapWidth: Integer): TSize;
        function CharFormat(Pos: Integer;
            var FontFore, FontBack: TColor; var FontStyle: TFontStyles; var FontFace: TFontName;
            var AddUnderline: Boolean): Boolean;
        function PositionFromPoint(P: TPoint): Integer;
        function LinkFromPosition(Pos: Integer): TvqMarkLink;
        
        function TextLength: Integer;
        function RowCount: Integer;
        property Extent: TSize read FExtent;
        property LinesCount: Integer read FLinesCount;
        property Link[Index: Integer]: TvqMarkLink read GetLinkAt;
        
        property Mark[Index: Integer]: Byte read GetMark write SetMark;
        property Ch[Index: Integer]: Char read GetChar; default;
    end;
    
    TvqMarkStyle = class(TPersistent)
    private
        FLinkNormal : TColor    ;
        FLinkHovered: TColor    ;
        FLinkVisited: TColor    ;
        FLinkPressed: TColor    ;
        FCodeFore   : TColor    ;
        FCodeBack   : TColor    ;
        FCodeFace   : TFontName ;
        FImageFore  : TColor    ;
        FUnderlineHotLink: Boolean;
        
        FControl: TControl;
        FOnUpdateMetrics: TNotifyEvent;
        procedure SetLinkNormal (Value: TColor);
        procedure SetLinkHovered(Value: TColor);
        procedure SetLinkVisited(Value: TColor);
        procedure SetLinkPressed(Value: TColor);
        procedure SetCodeFore   (Value: TColor);
        procedure SetCodeBack   (Value: TColor);
        procedure SetCodeFace   (Value: TFontName);
        procedure SetImageFore  (Value: TColor);
        procedure SetUnderlineHotLink(Value: Boolean);
    public
        constructor Create(AControl: TControl); 
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        procedure Repaint;
        procedure UpdateMetrics;
    published
        property LinkNormal : TColor    read FLinkNormal  write SetLinkNormal ;
        property LinkHovered: TColor    read FLinkHovered write SetLinkHovered;
        property LinkVisited: TColor    read FLinkVisited write SetLinkVisited;
        property LinkPressed: TColor    read FLinkPressed write SetLinkPressed;
        property CodeFore   : TColor    read FCodeFore    write SetCodeFore   ;
        property CodeBack   : TColor    read FCodeBack    write SetCodeBack   ;
        property CodeFace   : TFontName read FCodeFace    write SetCodeFace   ;
        property ImageFore  : TColor    read FImageFore   write SetImageFore  ;
        property UnderlineHotLink: Boolean read FUnderlineHotLink write SetUnderlineHotLink;
        property OnUpdateMetrics: TNotifyEvent read FOnUpdateMetrics write FOnUpdateMetrics;
    end;

var
    CanUserActiveFiuFiu: Boolean = False;

implementation

procedure DoSomeThing;
begin
    // do nothing
end;

const
    GROW_SIZE = 8;

function IsMarkChar(C: Char): Boolean;
begin
    Result := C in ['*', '_', '&', '~', '[', ']', '\', '`', '!', '"'];
end;

{ TvqMarkLink }

constructor TvqMarkLink.Create(AMarkedText: TvqMarkedText; AIndex: Integer);
begin
    FMarkedText := AMarkedText;
    FIndex := AIndex;
    FLabel := '';
    FAddress := '';
    FHint := '';
    FPos := 0;
    FLen := 0;
end;

destructor TvqMarkLink.Destroy;
begin
    inherited;
end;

function TvqMarkLink.InRange(APos: Integer): Boolean;
begin
    Result := (FPos <= APos) and (APos < FPos + FLen);
end;

function TvqMarkLink.BeforeLimit(APos: Integer): Boolean;
begin
    Result := (APos < FPos + FLen);
end;

function TvqMarkLink.AfterRange(APos: Integer): Boolean;
begin
    Result := APos >= FPos + FLen;
end;

function TvqMarkLink.BeforeRange(APos: Integer): Boolean;
begin
    Result := APos < FPos;
end;

function TvqMarkLink.GetLabel: string;
begin
    if FLabel = '' then
        FLabel := FMarkedText._GetString(FPos, FLen);
    Result := FLabel;
end;

function TvqMarkLink.GetVisited: Boolean;
begin
    Result := (FMarkedText.Mark[FPos] and MARK_VISITED) <> 0;
end;

procedure TvqMarkLink.SetVisited(Value: Boolean);
var
    I: Integer;
begin
    for I := FPos to FPos + FLen - 1 do
        if Value then
            FMarkedText.Mark[I] := FMarkedText.Mark[I] or MARK_VISITED
        else
            FMarkedText.Mark[I] := FMarkedText.Mark[I] and (not MARK_VISITED);
end;

{ TvqMarkImage } 

constructor TvqMarkImage.Create(AMarkedText: TvqMarkedText; AIndex: Integer);
begin
    FIndex := AIndex;
    FMarkedText := AMarkedText;
    FPicture := TPicture.Create;
end;

destructor TvqMarkImage.Destroy;
begin
    FPicture.Free;
    inherited;
end;

function TvqMarkImage.LoadPictureFromFile(FileName: TFileName): Boolean;
begin
    Result := False;
    try
        FPicture.LoadFromFile(FileName);
        Result := FPicture.Graphic <> nil;
    except
        on E: Exception do
            Result := False;
    end;
end;

procedure TvqMarkImage.Reload;
var
    FileName: string;
    AddressText: TvqStringText;
    I, L: Integer;
    Scheme: string;
    RequestHandled: Boolean;
begin
                             
    RequestHandled := False;
    if Assigned(FMarkedText.OnRequestEvent) then begin
        FPicture.Clear;
        FMarkedText.OnRequestEvent(FMarkedText, FAddress, FPicture, RequestHandled);
        if RequestHandled then Exit;
    end;
    
    AddressText := TvqStringText.CreatePointer(FAddress);
    FPicture.Clear;
    try
        L := AddressText._TextLength;
        I := 0;
        if ScanURIScheme(AddressText, I, Scheme) then begin
            if Scheme = 'file' then begin
                Inc(I);
                if (I + 1 < L) and (AddressText[I] + AddressText[I + 1] = '\\') then begin
                    if URIToFileName(FAddress, FileName) then
                        LoadPictureFromFile(FileName);
                end;
            end
            else if (Length(Scheme) = 1) and IsUpperAlphaChar(Scheme[1]) then begin
                // special case, this is a Windows device letter
                Inc(I);
                if (I < L) and (AddressText[I] in ['\', '/']) then begin
                    LoadPictureFromFile(FAddress);
                end;
            end
            else
                begin end;
        end 
        else
            LoadPictureFromFile(FAddress);
    finally
        AddressText.Free;
    end;
end;

function TvqMarkImage.CalculateSize(Canvas: TCanvas): TSize;
begin
    if FPicture.Graphic <> nil then
        Result := TSize.Create(FPicture.Width, FPicture.Height)
    else
        Result := Canvas.TextExtent(FAlt);
end;

procedure TvqMarkImage.Draw(Canvas: TCanvas; X, Y: Integer; Enabled: Boolean);
var
    Img: TImageList;
begin
    if FPicture.Graphic <> nil then begin
        if Enabled then
            Canvas.Draw(X, Y, FPicture.Graphic)
        else begin
            Img := TImageList.Create(nil);
            try
                Img.Width := FPicture.Width;
                Img.Height := FPicture.Height;
                Img.AddMasked(FPicture.Bitmap, clNone);
                Img.Draw(Canvas, X, Y, 0, Enabled);
            finally
                Img.Free; 
            end;
        end;
    end
    else begin
        if not Enabled then 
            begin { font color is grayed } end;
        Canvas.TextOut(X, Y, FAlt);
    end;
end;

{ TvqMarkedText }

constructor TvqMarkedText.Create(AStyle: TvqMarkStyle; AFont: TFont);
begin
    MarkStyle := AStyle;
    Font := AFont;
    
    FLinks := nil;
    FImages := nil;
    FChars := nil;
    FMarks := nil;
    FMetricBmp := TBitmap.Create;
    FMetricBmp.Width := 10;
    FMetricBmp.Height := 10;
end;

destructor TvqMarkedText.Destroy;
var
    I: Integer;
begin
    for I := 0 to Length(FLinks) - 1 do
        FLinks[I].Free;
    for I := 0 to Length(FImages) - 1 do
        if FImages[I] <> nil then
            FImages[I].Free;
    FLinks := nil;
    FImages := nil;
    FMetricBmp.Free;
    inherited;
end;

function TvqMarkedText.GetMark(Index: Integer): Byte;
begin
    if (Index >= 0) and (Index < TextLength) then 
        Result := FMarks[Index]
    else
        Result := 0;
end;

function TvqMarkedText.GetChar(Index: Integer): Char;
begin
    if (Index >= 0) and (Index < TextLength) then 
        Result := FChars[Index]
    else
        Result := #0;
end;

procedure TvqMarkedText.SetMark(Index: Integer; Value: Byte);
begin
    if (Index >= 0) and (Index < TextLength) then
        FMarks[Index] := Value;
end;

function TvqMarkedText.Parse(Text: IvqTextBuffer; Options: TvqMarkOptions): Boolean;
var
    L, I, cL, LinkCount, ImageCount: Integer;
    BoldDepth,
    ItalicDepth, 
    UnderlineDepth, 
    StrikeOutDepth,
    LinkDepth,
    CodeDepth,
    QuotationDepth,
    ImageDepth: Integer;
    
    procedure EnsureLinkRoom;
    begin
        if LinkCount >= Length(FLinks) then
            SetLength(FLinks, LinkCount + GROW_SIZE);
    end;
    
    procedure FixLinkRoom;
    begin
        SetLength(FLinks, LinkCount);
    end;
    
    procedure EnsureImageRoom;
    begin
        if ImageCount >= Length(FImages) then
            SetLength(FImages, ImageCount + GROW_SIZE);
    end;
    
    procedure FixImageRoom;
    begin
        SetLength(FImages, ImageCount);
    end;
    
    function AddLink(APos, ALen: Integer; AAddress, AHint: string): Integer;
    begin
        if (ALen > 0) and (LinkDepth = 1) then begin // disables nested links
            EnsureLinkRoom;
            FLinks[LinkCount] := TvqMarkLink.Create(Self, LinkCount);
            FLinks[LinkCount].FPos := APos;
            FLinks[LinkCount].FLen := ALen;
            FLinks[LinkCount].FAddress := AAddress;
            FLinks[LinkCount].FHint := AHint;
            Result := LinkCount;
            Inc(LinkCount);
        end
        else Result := -1;
    end;
    
    function AddImage(AAlt, AAddress, AHint: string): string;
    begin
        Result := '';
        
        EnsureImageRoom;
        // images are coded as unicode character marked with MARK_IMAGE
        // the unicode index is the image index in list
        // tab, cr, lf are excluded
        if ImageCount = 9 then begin
            FImages[ImageCount] := nil; // 9
            Inc(ImageCount);
            FImages[ImageCount] := nil; // 10
            Inc(ImageCount);
        end
        else if (ImageCount = 10) or (ImageCount = 13) then begin
            FImages[ImageCount] := nil; // 10 or 13
            Inc(ImageCount);
        end;
        
        FImages[ImageCount] := TvqMarkImage.Create(Self, ImageCount);
        FImages[ImageCount].FAlt := AAlt;
        FImages[ImageCount].FAddress := AAddress;
        FImages[ImageCount].FHint := AHint;
        Result := EncodeUTF8(ImageCount);
        Inc(ImageCount);
    end;
    
    function CurrentFormat: Byte;
    begin
        Result := $00;
        if BoldDepth > 0 then Result := Result or MARK_BOLD;
        if ItalicDepth > 0 then Result := Result or MARK_ITALIC;
        if UnderlineDepth > 0 then Result := Result or MARK_UNDERLINE;
        if StrikeOutDepth > 0 then Result := Result or MARK_STRIKEOUT;
        if LinkDepth > 0 then Result := Result or MARK_LINK;
        if CodeDepth > 0 then Result := Result or MARK_CODE;
        if ImageDepth  > 0 then Result := Result or MARK_IMAGE;
    end;

    procedure Append(Ch: Char);
    begin
        FChars[cL] := Ch;
        FMarks[cL] := CurrentFormat;
        Inc(cL);
    end;
    
    procedure AppendUTF8(Ch: ansistring);
    var
        _I: Integer;
    begin
        for _I := 1 to Length(Ch) do
            Append(Ch[_I]);
    end;

    procedure AppendAndAdvance;
    begin
        Append(Text[I]);
        Inc(I);
    end;
                        
    function ScanEoL: Boolean;
    begin
        Result := True;
        while (I < L) and (Text[I] in [CR, LF]) do
            AppendAndAdvance;
    end;
                 
    function ScanItalic: Boolean; forward;
    function ScanStrikeOut: Boolean; forward;
    function ScanUnderline: Boolean; forward;
    function ScanLink: Boolean; forward;
    function ScanImage: Boolean; forward;
    function ScanChar: Boolean; forward;
    function ScanEscape: Boolean; forward;
    function ScanQuotation: Boolean; forward;

    function ScanCode: Boolean;
    var
        _S, _L, _I, _LinkPos, _LinkLen: Integer;
    begin
        Result := True;
        Inc(I);
        Inc(CodeDepth);
        while I < L do begin
            case Text[I] of
                '`':
                    if (I + 1 < L) and (Text[I + 1] = '`') then begin
                        Inc(I);
                        AppendAndAdvance;
                    end
                    else Break;
                CR, LF: Result := ScanEoL;
                else begin
                    if (vqmoAutoURLDetect in Options) and (vqmoCodeFenceAutoURL in Options) then begin
                        _S := I;
                        _L := ScanURL(Text, _S);
                    end
                    else _L := 0;
                    if _L > 0 then begin
                        Inc(LinkDepth);
                        _LinkPos := cL - (I - _S);
                        _LinkLen := _L;
                        for _I := _LinkPos to cL - 1 do
                            FMarks[_I] := FMarks[_I] or MARK_LINK;
                        while I < _S + _L do
                            AppendAndAdvance;
                        AddLink(_LinkPos, _LinkLen, Text._GetString(_S, _L), '');
                        Dec(LinkDepth);
                    end
                    else
                        AppendAndAdvance;
                end;
            end
        end;              
        Inc(I); // if closes or finishes
        Dec(CodeDepth);
    end;

    function ScanBold: Boolean;
    begin
        Result := True;
        Inc(I);
        Inc(BoldDepth);
        while I < L do begin
            case Text[I] of
                '`': Result := ScanCode;
                '*': Break;
                '_': Result := ScanItalic;
                '~': Result := ScanStrikeOut;
                '&': Result := ScanUnderline;
                '[': Result := ScanLink;
                '!': 
                    if Text[I + 1] = '[' then
                        Result := ScanImage
                    else
                        Result := ScanChar;
                '\': Result := ScanEscape;
                CR,
                LF : Result := ScanEoL;
                '"':
                    if vqmoQuotation in Options then
                        Result := ScanQuotation
                    else
                        Result := ScanChar;
                else Result := ScanChar;
            end;
        end;
        Inc(I); // if closes or finishes
        Dec(BoldDepth);
    end;
    
    function ScanItalic: Boolean;
    begin
        Result := True;
        Inc(I);
        Inc(ItalicDepth);
        while I < L do begin
            case Text[I] of
                '`': Result := ScanCode;
                '*': Result := ScanBold;
                '_': Break;
                '~': Result := ScanStrikeOut;
                '&': Result := ScanUnderline;
                '[': Result := ScanLink;
                '!': 
                    if Text[I + 1] = '[' then
                        Result := ScanImage
                    else
                        Result := ScanChar;
                '\': Result := ScanEscape;
                CR,
                LF : Result := ScanEoL; 
                
                '"':
                    if vqmoQuotation in Options then
                        Result := ScanQuotation
                    else
                        Result := ScanChar;
                else Result := ScanChar;
            end;
        end;
        Inc(I); // if closes or finishes
        Dec(ItalicDepth);
    end;
    
    function ScanStrikeOut: Boolean;
    begin
        Result := True;
        Inc(I);
        Inc(StrikeOutDepth);
        while I < L do begin
            case Text[I] of
                '`': Result := ScanCode;
                '*': Result := ScanBold;
                '_': Result := ScanItalic;
                '~': Break;
                '&': Result := ScanUnderline;
                '[': Result := ScanLink;
                '!': 
                    if Text[I + 1] = '[' then
                        Result := ScanImage
                    else
                        Result := ScanChar;
                '\': Result := ScanEscape;
                CR,
                LF : Result := ScanEoL; 
                
                '"':
                    if vqmoQuotation in Options then
                        Result := ScanQuotation
                    else
                        Result := ScanChar;
                else Result := ScanChar;
            end;
        end;
        Inc(I); // if closes or finishes
        Dec(StrikeOutDepth);
    end;
    
    function ScanUnderline: Boolean;
    begin
        Result := True;
        Inc(I);
        Inc(UnderlineDepth);
        while I < L do begin
            case Text[I] of
                '`': Result := ScanCode;
                '*': Result := ScanBold;
                '_': Result := ScanItalic;
                '~': Result := ScanStrikeOut;
                '&': Break;
                '[': Result := ScanLink;
                '!': 
                    if Text[I + 1] = '[' then
                        Result := ScanImage
                    else
                        Result := ScanChar;
                '\': Result := ScanEscape;
                CR,
                LF : Result := ScanEoL; 
                
                '"':
                    if vqmoQuotation in Options then
                        Result := ScanQuotation
                    else
                        Result := ScanChar;
                else Result := ScanChar;
            end;
        end;
        Inc(I); // if closes or finishes
        Dec(UnderlineDepth);
    end;
    
    function ScanAddress(var Address, Hint: string): Boolean;
    var
        _I, _AddressPos, _AddressLen,
        _HintPos, _HintLen: Integer;
    begin
        Result := False;
        Address := '';
        Hint := '';
        if I < L then begin
            _AddressLen := 0;
            _HintLen := 0;
            if Text[I] = '(' then begin
                Inc(I);
                while (I < L) and (Text[I] in [' ', #9, CR, LF]) do Inc(I);
                _AddressPos := I;
                while (I < L) and not(Text[I] in ['"',')']) do Inc(I);
                _AddressLen := I - _AddressPos ;
                
                if Text[I] = '"' then begin
                    Inc(I);
                    _HintPos := I;
                    while (I < L) and (Text[I] <> '"') do Inc(I); // ignores inner ')'
                    _HintLen := I - _HintPos;
                    if Text[I] = '"' then Inc(I);
                end;
                while (I < L) and (Text[I] <> ')') do Inc(I); // closes
                if Text[I] = ')' then Inc(I);
                Result := True;
            end;
            if _AddressLen > 0 then 
                Address := TrimRight(Text._GetString(_AddressPos, _AddressLen));
            if _HintLen > 0 then
                Hint := Text._GetString(_HintPos, _HintLen);
                
        end;
        
    end;
    
    function ScanLink: Boolean;
    var
        _LinkPos, _LinkLen: Integer;
        Address, Hint: string;
        PrevOptions: TvqMarkOptions;
    begin
        Result := True;
        Inc(I);
        Inc(LinkDepth);
        _LinkPos := cL; // link position
        
        PrevOptions := Options;
        Options := Options - [vqmoAutoURLDetect]; // disable autourldetect in link label
        
        while I < L do begin
            case Text[I] of
                '`': Result := ScanCode;
                '*': Result := ScanBold;
                '_': Result := ScanItalic;
                '~': Result := ScanStrikeOut;
                '&': Result := ScanUnderline;
                '[': Result := ScanLink; // extrae la etiqueta pero no guarda el link
                ']': Break;
                '!': 
                    if Text[I + 1] = '[' then
                        Result := ScanImage
                    else
                        Result := ScanChar;
                '\': Result := ScanEscape;
                CR,
                LF : Result := ScanEoL; 
                
                '"':
                    if vqmoQuotation in Options then
                        Result := ScanQuotation
                    else
                        Result := ScanChar;
                else Result := ScanChar;
            end;
        end;
        Options := PrevOptions;
        
        _LinkLen := cL - _LinkPos; // link length
        Inc(I); // if closes or finishes
        
        ScanAddress(Address, Hint);
        
        AddLink(_LinkPos, _LinkLen, Address, Hint);
        Dec(LinkDepth);
        
    end;
    
    function ScanImage: Boolean;
    var
        _S, _L, BracketDepth: Integer;
        Alt, Address, Hint: string;
    begin
        Result := True;
        Inc(I);
        Inc(I);
        Inc(ImageDepth);
        _S := I;
        
        BracketDepth := 0;
        while I < L do begin
            case Text[I] of
                // ignores all markup for Alt text (including eol)
                '[': begin
                    Inc(BracketDepth); // brackets are nested
                    Inc(I);
                end;
                ']':
                    if BracketDepth = 0 then Break
                    else begin
                        Dec(BracketDepth);
                        Inc(I);
                    end;
                else Inc(I);
            end;
        end;
        Alt := Text._GetString(_S, I - _S);
        Inc(I); // if closes or finishes
        
        ScanAddress(Address, Hint);
        AppendUTF8(AddImage(Alt, Address, Hint));
        
        Dec(ImageDepth);
    end;
    
    function ScanEscape: Boolean;
    var
        Ch: TUTF8Char;
        SaveI: Integer;
    begin
        Result := ScanEscapeSequence(Text, True, I, Ch);
        if Result then
            AppendUTF8(Ch)
        else
            AppendUTF8('\');
        Result := True;
    end;

    function ScanQuotation: Boolean;
    begin
        Result := True;
        AppendUTF8('“');
        Inc(I);
        Inc(QuotationDepth);
        while I < L do begin
            case Text[I] of
                '`': Result := ScanCode;
                '*': Result := ScanBold;
                '_': Result := ScanItalic;
                '~': Result := ScanStrikeOut;
                '&': Result := ScanUnderline;
                '[': Result := ScanLink;
                '!': 
                    if Text[I + 1] = '[' then
                        Result := ScanImage
                    else
                        Result := ScanChar;
                '\': Result := ScanEscape;
                CR,
                LF : Result := ScanEoL;
                
                '"': begin
                    AppendUTF8('”');
                    Break;
                end;
                else Result := ScanChar;
            end;
        end;
        Inc(I); // if closes or finishes
        Dec(QuotationDepth);
    end;
    
    function ScanChar: Boolean;
    var
        _S, _L, _I, _LinkPos, _LinkLen: Integer;
        _HasC: Boolean;
    begin { utf-8 friendly }
        Result := True;
        if vqmoAutoURLDetect in Options then begin
            _S := I;
            _L := ScanURL(Text, _S);
        end
        else _L := 0;
        if _L > 0 then begin
            Inc(LinkDepth);
            _LinkPos := cL - (I - _S);
            _LinkLen := _L;
            for _I := _LinkPos to cL - 1 do
                FMarks[_I] := FMarks[_I] or MARK_LINK;
            while I < _S + _L do
                AppendAndAdvance;
            AddLink(_LinkPos, _LinkLen, Text._GetString(_S, _L), '');
            Dec(LinkDepth);
        end
        else begin
            _HasC := False;
            if vqmoCopyright in Options then 
                if Text[I] = '(' then
                    if Text[I + 1] in ['c', 'C'] then
                        if Text[I + 2] = ')' then begin
                            I := I + 3;
                            _HasC := True;
                        end;
            if _HasC then
                AppendUTF8('©')
            else
                AppendAndAdvance;
        end;
    end;
    
    function Scan: Boolean;
    begin
        Result := True;
        
        while I < L do begin
            case Text[I] of
                '`': Result := ScanCode;
                '*': Result := ScanBold;
                '_': Result := ScanItalic;
                '~': Result := ScanStrikeOut;
                '&': Result := ScanUnderline;
                '[': Result := ScanLink;
                '!': 
                    if Text[I + 1] = '[' then
                        Result := ScanImage
                    else
                        Result := ScanChar;
                '\': Result := ScanEscape;
                CR,
                LF : Result := ScanEoL; 
                
                '"':
                    if vqmoQuotation in Options then
                        Result := ScanQuotation
                    else
                        Result := ScanChar;
                else Result := ScanChar;
            end;
        end;
    end;
    
    procedure CalculateLines;
    begin
        FLinesCount := 1;
        I := 0;
        while I < cL do begin
            if FChars[I] = CR then begin
                Inc(I);
                if FChars[I] = LF then
                    Inc(I);
                Inc(FLinesCount);
            end
            else if FChars[I] = LF then begin
                Inc(I);
                Inc(FLinesCount);
            end
            else
                Inc(I);
        end;
    end;
    
begin
    Result := False;
    if FUpdatingBuffer then Exit;
    FUpdatingBuffer := True;

    // Initialization
    
    for I := 0 to Length(FLinks) - 1 do
        FLinks[I].Free;
    for I := 0 to Length(FImages) - 1 do
        if FImages[I] <> nil then
            FImages[I].Free;
    FLinks := nil;
    FImages := nil;
    
    FChars := nil;
    FMarks := nil;
    FLinesCount := 0;
    FSizes := nil;
    FStarts := nil;
    FRowsLeft := nil;
    FRowsBottom := nil;
    FRowsWidth := nil;
    FOrigin := Point(0, 0);
    FExtent := TSize.Create(0, 0);
    FEllipsis := -1;
    FPressedLink := nil;
    FHoveredLink := nil;
    FEmptyRowHeight := 0;
    
    LinkCount := 0;
    ImageCount := 0;
    
    CodeDepth := 0;
    LinkDepth := 0;
    BoldDepth := 0;
    ItalicDepth := 0;
    StrikeOutDepth := 0;
    UnderlineDepth := 0;
    QuotationDepth := 0;
    ImageDepth := 0;
    
    L := Text._TextLength;
    SetLength(FChars, L);
    SetLength(FMarks, L);
    for I := 0 to L - 1 do FMarks[I] := 0;
    I := 0;
    cL := 0;
    
    // Marking

    if Scan then begin
        SetLength(FChars, cL);
        SetLength(FMarks, cL);
        FixImageRoom;
        FixLinkRoom;
        CalculateLines;
        for I := 0 to ImageCount - 1 do
            if FImages[I] <> nil then 
                FImages[I].Reload;
        Result := True;
    end
    else begin
        FixImageRoom;
        FixLinkRoom;
        FUpdatingBuffer := False;
        raise Exception.Create('TvqMarkedText: can''t scan text');
    end;
    
    //
    
    FUpdatingBuffer := False;
end;

function TvqMarkedText.CalculateRowLimit(Row: Integer): Integer;
begin
    if Row = RowCount - 1 then Result := _TextLength
    else Result := FStarts[Row + 1];
end;

procedure TvqMarkedText.InternalCalculateLocation(Area: TRect; Canvas: TCanvas; Format: TTextStyle;
    var Sizes: TSizeArray; var Starts, RowsLeft, RowsBottom, RowsWidth: TIntArray;
    var Origin: TPoint; var Ellipsis: Integer; var Extent: TSize;
    var EmptyRowHeight: Integer);
     
var
    I, L: Integer;
    
    SpaceSz, EllipsisSz: TSize;
    SpaceWidth, SpaceHeight, TabWidth, TabHeight, EllipsisWidth, EllipsisHeight,
    PrevSizeTo, Rows, WrapWidth, LineStart,
    SpaceLeft, SpanWidth: Integer;
    
    function NextTentativeBreak(var ASpanWidth: Integer): Integer;
    var
        ccStart: TvqCharClass;
        K: Integer;
    begin
        K := I;
        ccStart := GetClassOfChar(FChars[K]); // simple char classification
        ASpanWidth := 0;
        while (K < L) and (GetClassOfChar(FChars[K]) = ccStart) and
            (ASpanWidth + Sizes[K].cx < WrapWidth) and
            not (FChars[K] in [CR, LF]) do begin
            Inc(ASpanWidth, Sizes[K].cx);
            Inc(K);
        end;
        {
        if (K < L) and (FChars[K] = CR) then begin
            Inc(K);
            if (K < L) and (FChars[K] = LF) then Inc(K);
        end
        else if (K < L) and (FChars[K] = LF) then Inc(K);
        }
        if K = I then begin
            ASpanWidth := Sizes[I].cx;
            K := I + 1;
        end;
        Result := K;
    end;
    
    procedure AddWrapStart(AWrapStart: Integer);
    begin
        Starts[Rows] := AWrapStart;
        Inc(Rows);
    end;
    
    function RowLimit(ARow: Integer): Integer;
    begin
        if ARow = Rows - 1 then Result := _TextLength
        else Result := Starts[ARow + 1];
    end;
    
    function CalculateCharSize(Pos: Integer; Ch: TUTF8Char): TSize;
    var 
        FontFore, FontBack: TColor;
        FontStyle: TFontStyles;
        FontFace: TFontName;
        AddUnderline: Boolean;
        Uni: Integer;
    begin
        CharFormat(Pos, FontFore, FontBack, FontStyle, FontFace, AddUnderline);
        if AddUnderline then
            Canvas.Font.Style := FontStyle + [fsUnderline]
        else
            Canvas.Font.Style := FontStyle;
        Canvas.Font.Name := FontFace;
        if (FMarks[Pos] and MARK_IMAGE) <> 0 then begin
            Uni := DecodeUTF8(Ch);
            if Uni > -1 then
                Result := FImages[Uni].CalculateSize(Canvas)
            else
                Result := TSize.Zero;
        end
        else
            Result := Utf8CharExtent(Canvas, Ch, False);
    end;

var
    M, R, RowB, RowH, RowW, Next: Integer;
    Utf8Ch: TUTF8Char;
    
begin
{

--> calculate special sizes(ellipsis, tabulation, space)
--> calculate character sizes
--> word wrapping(starts, rowcount, linecount)
--> relative position(rowright, rowbase, extent, ellipsis)

}
    // calculate special sizes
    Canvas.Font := Font;
    // space size
    SpaceSz := Canvas.TextExtent(' ');
    SpaceWidth := SpaceSz.cx;
    SpaceHeight := SpaceSz.cy;
    TabHeight := SpaceHeight;
    EmptyRowHeight := SpaceHeight;
    // ellipsis size
    EllipsisSz := Canvas.TextExtent('...');
    EllipsisWidth := EllipsisSz.cx;
    EllipsisHeight := EllipsisSz.cy;
    // tab size
    if Format.ExpandTabs then
        TabWidth := TextRectExtent(Canvas.Handle, Rect(0, 0, 5, 5), #9, LineTextStyle(True)).cx
    else
        TabWidth := 0;
    // text length
    L := _TextLength;

    // calculate caracter sizes
    I := 0;
    PrevSizeTo := 0;
    SetLength(Sizes, L);
    while I < L do begin
        if FChars[I] = CR then begin
            Sizes[I] := CalculateCharSize(I, CR);
            Inc(I);
            if FChars[I] = LF then begin
                Sizes[I] := CalculateCharSize(I, LF);
                Inc(I);
            end;
            PrevSizeTo := 0;
        end
        else if FChars[I] = LF then begin
            Sizes[I] := CalculateCharSize(I, LF);
            Inc(I);
            PrevSizeTo := 0;
        end
        else if FChars[I] = #9 then begin
            // tab size is fixed for any markup
            if TabWidth = 0 then 
                Sizes[I] := TSize.Create(TabWidth, TabHeight)
            else
                Sizes[I] := TSize.Create(TabWidth - (PrevSizeTo mod TabWidth), TabHeight);
            PrevSizeTo := PrevSizeTo + Sizes[I].cx;
            Inc(I);
        end
        else begin
            M := I;
            ScanUTF8(Self, I, Utf8Ch);
            Sizes[M] := CalculateCharSize(M, Utf8Ch);
            Inc(M);
            while M < I do begin
                Sizes[M] := TSize.Zero; // por comodidad se rellena con cero
                Inc(M);
            end;
        end;
    end;
    
    // word wrapping
    SetLength(Starts, L + 1);
    Rows := 0;
    AddWrapStart(0);
    if (not Format.SingleLine) or Format.WordBreak then begin
        if Format.WordBreak then WrapWidth := Area.Width
        else WrapWidth := MaxInt div 2;
        
        I := 0;
        LineStart := 0;
        SpaceLeft := WrapWidth;
        while I < L do begin
            if FChars[I] = CR then begin
                Inc(I);
                if (I < L) and (FChars[I] = LF) then
                    Inc(I);
                AddWrapStart(I);
                LineStart := I;
                SpaceLeft := WrapWidth;
            end
            else if FChars[I] = LF then begin
                Inc(I);
                AddWrapStart(I);
                LineStart := I;
                SpaceLeft := WrapWidth;
            end
            else begin
                Next := NextTentativeBreak(SpanWidth);
                if SpanWidth > SpaceLeft then begin
                    if I > LineStart then begin
                        AddWrapStart(I);
                        LineStart := I;
                    end;
                    SpaceLeft := WrapWidth - SpanWidth;
                end
                else
                    SpaceLeft := SpaceLeft - SpanWidth;
                I := Next;
            end;
        end;
    end;
    SetLength(Starts, Rows);
    
    // positioning
    
    SetLength(RowsBottom, Rows);
    SetLength(RowsWidth, Rows);
    Extent := TSize.Create(0, 0);
    Ellipsis := -1;
    
    RowB := 0;
    for R := 0 to Rows - 1 do begin
        // calculate row size
        RowW := 0;
        RowH := 0;
        if Starts[R] = L then // last empty row
            RowH := SpaceHeight // default height
        else
            for I := Starts[R] to RowLimit(R) - 1 do begin
                Inc(RowW, Sizes[I].cx);
                if RowH < Sizes[I].cy then RowH := Sizes[I].cy;
                if  (R = Rows - 1) and
                    (RowW + EllipsisWidth > Area.Width) then
                    Ellipsis := I;
            end;
        //
        Inc(RowB, RowH);
        RowsBottom[R] := RowB;
        RowsWidth[R] := RowW;
        
        if RowW > Extent.cx then Extent.cx := RowW;
        Extent.cy := RowB;
        
        if (RowW < Area.Width) or (not Format.EndEllipsis) then 
            Ellipsis := -1;
    end;
    
    case Format.Alignment of
        taLeftJustify: Origin.X := Area.Left;
        taCenter: Origin.X := (Area.Left + Area.Right - Extent.cx) div 2;
        taRightJustify: Origin.X := Area.Right - Extent.cx;
    end;
    case Format.Layout of
        tlTop: Origin.Y := Area.Top;
        tlCenter: Origin.Y := (Area.Top + Area.Bottom - Extent.cy) div 2;
        tlBottom: Origin.Y := Area.Bottom - Extent.cy;
    end;
    SetLength(RowsLeft, Rows);
    for R := 0 to Rows - 1 do begin
        case Format.Alignment of
            taLeftJustify: RowsLeft[R] := Area.Left;
            taCenter: RowsLeft[R] := (Area.Left + Area.Right - RowsWidth[R]) div 2;
            taRightJustify: RowsLeft[R] := Area.Right - RowsWidth[R];
        end;
        Inc(RowsBottom[R], Origin.Y);
    end;
    
end;

function TvqMarkedText.Locate(AArea: TRect; AFormat: TTextStyle): Boolean;
begin
    Result := True;
    TextArea := AArea;
    TextFormat := AFormat;
    InternalCalculateLocation(AArea, FMetricBmp.Canvas, AFormat,
        FSizes, FStarts, FRowsLeft, FRowsBottom, FRowsWidth, FOrigin, 
        FEllipsis, FExtent, FEmptyRowHeight);
end;

function TvqMarkedText.Render(Canvas: TCanvas; Enabled: Boolean): Boolean;
var
    LineStyle: TTextStyle;
    FontStyle: TFontStyles;
    FontFore, FontBack: TColor;
    FontFace: TFontName;
    DCIndex: Integer;
    CurrLink, RowLimit, I: Integer;
    AddUnderline: Boolean;
    
    function ChunkLimit(var ChunkHeight, ChunkWidth, Image: Integer): Integer;
    var 
        MarkStart: Byte;
        Ch: TUTF8Char;
        _I: Integer;
    begin
        Result := I;
        Image := -1;
        // chunk
        MarkStart := GetMark(I);
        if (MARK_IMAGE and MarkStart) <> 0 then begin
            ScanUTF8(Self, Result, Ch);
            Image := DecodeUTF8(Ch);
        end
        else if ((MARK_LINK and MarkStart) <> 0) and (CurrLink < Length(FLinks)) then begin
            while (Result < RowLimit) and (FMarks[Result] = MarkStart) and
                (FLinks[CurrLink].BeforeLimit(Result)) do
                Inc(Result);
            if FLinks[CurrLink].AfterRange(Result) then
                Inc(CurrLink);
        end
        else
            while (Result < RowLimit) and (FMarks[Result] = MarkStart) do
                Inc(Result);
        
        // calculating chunk size
        ChunkWidth := 0;
        if Result = TextLength then ChunkHeight := FEmptyRowHeight
        else ChunkHeight := 0;
        for _I := I to Result - 1 do
            with FSizes[_I] do begin
                Inc(ChunkWidth, cx);
                if cy > ChunkHeight then ChunkHeight := cy;
            end;
    end;
    
    procedure DrawChunk(Rect: TRect; X, Y: Integer; From, _To, ImageIndex: Integer);
    var
        Str: string;
    begin
        if Boolean(MARK_IMAGE and FMarks[From]) and (ImageIndex <> -1) then begin
            FImages[ImageIndex].Draw(Canvas, X, Y, Enabled);
            if AddUnderline then with Canvas do begin
                Brush.Style := bsClear;
                ThinPen(Font.Color);
                Rectangle(Rect);
            end;
        end
        else  begin
            Str := _GetString(From, _To - From);
            Canvas.TextRect(Rect, X, Y, Str, LineStyle);
        end;
    end;

var
    Y, Yb, X, K, ChunkW, ChunkH, Row: Integer;
    R: TRect;
    ImageIndex: Integer;
    
begin
{

--> text origin Y
--> for every row
    --> row origin X
    --> row base Y
    --> calculate row chunks and draw

}

    Result := True;
    // preparing
    
    LineStyle := LineTextStyle;
    LineStyle.Layout := tlTop;
    Canvas.Font := Font;
    if TextFormat.Opaque then
        Canvas.FillRect(TextArea);
    Canvas.Brush.Style := bsClear;
    if not Enabled then Canvas.Font.Color := vqThemeManager.DisabledFore;
    if TextFormat.Clipping then begin
        DCIndex := WidgetSet.SaveDC(Canvas.Handle);
        WidgetSet.IntersectClipRect(Canvas.Handle, TextArea.Left, TextArea.Top, TextArea.Right, TextArea.Bottom);
    end;
    
    // drawing
    
    Y := FOrigin.Y;
    CurrLink := 0;
    for Row := 0 to Length(FStarts) - 1 do begin
        X := FRowsLeft[Row];
        I := FStarts[Row];
        Yb := FRowsBottom[Row];
        
        RowLimit := CalculateRowLimit(Row);
        while I < RowLimit do begin
            // calculating chunk
            K := ChunkLimit(ChunkH, ChunkW, ImageIndex);
            
            R := Rect(X, Y, X + ChunkW, Yb);
            with Canvas do begin
                // style
                CharFormat(I, FontFore, FontBack, FontStyle, FontFace, AddUnderline);
                if Enabled then Canvas.Font.Color := FontFore;
                if AddUnderline then
                    Canvas.Font.Style := FontStyle + [fsUnderline]
                else
                    Canvas.Font.Style := FontStyle;
                Canvas.Font.Name := FontFace;
                // chunk background
                if FontBack <> clNone then begin
                    Canvas.FullBrush(FontBack);
                    Canvas.FillRect(R);
                    Canvas.Brush.Style := bsClear;
                end;
                // chunk text
                DrawChunk(R, R.Left, Yb - ChunkH, I, K, ImageIndex);
            end;
            X := X + ChunkW;
            I := K;
        end;
        
        Y := Yb;
    end;
    
    // finishing
    
    if TextFormat.Clipping then
        WidgetSet.RestoreDC(Canvas.Handle, DCIndex);
end;

function TvqMarkedText.Perform(Sender: TObject; Command: Word; X, Y: Integer): Boolean;
var
    ALink, PrevLink: TvqMarkLink;
    URLOpened: Boolean;
    
    procedure ChangeCursor(Cursor: TCursor);
    begin
        if Sender is TControl then
            TControl(Sender).Cursor := Cursor;
    end;
    
begin
    Result := False;
    case Command and $00FF of
        MARK_CMD_DOWN: begin
            ALink := LinkFromPosition(PositionFromPoint(Point(X, Y)));
            if ALink <> FPressedLink then begin
                FPressedLink := ALink;
                if FPressedLink <> nil then
                    FHoveredLink := FPressedLink;
                Result := True;
                if FHoveredLink <> nil then
                    ChangeCursor(crHandPoint)
                else
                    ChangeCursor(crDefault);
            end;
        end;
        MARK_CMD_MOVE: begin
            if FPressedLink = nil then begin
                ALink := LinkFromPosition(PositionFromPoint(Point(X, Y)));
                if ALink <> FHoveredLink then begin
                    FHoveredLink := ALink;
                    Result := True;
                    if FHoveredLink <> nil then
                        ChangeCursor(crHandPoint)
                    else
                        ChangeCursor(crDefault);
                end;
            end;
        end;
        MARK_CMD_UP: begin
            if FPressedLink <> nil then begin
                ALink := LinkFromPosition(PositionFromPoint(Point(X, Y)));
                PrevLink := FPressedLink;
                FPressedLink := nil;
                FHoveredLink := ALink;
                if (PrevLink = ALink) and (ALink <> nil) then begin
                    if (Command and MARK_CMD_AUTOOPENURL) <> 0 then begin
                        if ALink.Address <> '' then begin
                            URLOpened := OpenURL(ALink.Address);
                            ALink.Visited := URLOpened;
                        end;
                    end;
                    if Assigned(OnHyperlinkEvent) then begin
                        with ALink do
                            OnHyperlinkEvent(Self, _Label, Address, Hint, Index, URLOpened);
                        ALink.Visited := URLOpened;
                    end;
                end;
                if FHoveredLink <> nil then
                    ChangeCursor(crHandPoint)
                else
                    ChangeCursor(crDefault);
                Result := True;
            end;
        end;
        MARK_CMD_ENTER:;
        MARK_CMD_LEAVE: if FHoveredLink <> nil then begin
            FHoveredLink := nil;
            ChangeCursor(crDefault);
            Result := True;
        end;
    end;
end;

function TvqMarkedText.TextExtentFor(Format: TTextStyle; WrapWidth: Integer): TSize;
var
    Area: TRect;
    Sizes: TSizeArray;
    Starts, RowsLeft, RowsBottom, RowsWidth: TIntArray;
    Origin: TPoint;
    Ellipsis, EmptyRowHeight: Integer;
begin
    Area := Rect(0, 0, WrapWidth, 5);
    Sizes := nil;
    Starts := nil;
    RowsLeft := nil;
    RowsBottom := nil;
    RowsWidth := nil;
    Ellipsis := -1;
    InternalCalculateLocation(Area, FMetricBmp.Canvas, Format, Sizes, Starts,
        RowsLeft, RowsBottom, RowsWidth,
        Origin, Ellipsis, Result, EmptyRowHeight);
end;

function TvqMarkedText.CharFormat(Pos: Integer;
    var FontFore, FontBack: TColor; var FontStyle: TFontStyles; var FontFace: TFontName;
    var AddUnderline: Boolean): Boolean;
begin
    if (Pos >= 0) and (Pos < TextLength) then begin
        // foreground
        if Boolean(FMarks[Pos] and MARK_LINK) then begin
            if Boolean(FMarks[Pos] and MARK_VISITED) then
                FontFore := MarkStyle.LinkVisited
            else if (FPressedLink <> nil) and
                    FPressedLink.InRange(Pos) then
                FontFore := MarkStyle.LinkPressed
            else if (FHoveredLink <> nil) and
                    FHoveredLink.InRange(Pos) then
                FontFore := MarkStyle.LinkHovered
            else
                FontFore := MarkStyle.LinkNormal;
        end
        else if Boolean(FMarks[Pos] and MARK_CODE) then
            FontFore := MarkStyle.CodeFore
        else if Boolean(FMarks[Pos] and MARK_IMAGE) then
            FontFore := MarkStyle.ImageFore
        else
            FontFore := Font.Color;
        // background
        if Boolean(FMarks[Pos] and MARK_CODE) then
            FontBack := MarkStyle.CodeBack
        else
            FontBack := clNone;
        // style
        AddUnderline := False;
        if Boolean(FMarks[Pos] and MARK_LINK) and
            (FHoveredLink <> nil) and
            FHoveredLink.InRange(Pos) then
            AddUnderline := MarkStyle.UnderlineHotLink;
        FontStyle := [];
        if Boolean(FMarks[Pos] and MARK_BOLD) then
            Include(FontStyle, fsBold);
        if Boolean(FMarks[Pos] and MARK_ITALIC) then
            Include(FontStyle, fsItalic);
        if Boolean(FMarks[Pos] and MARK_UNDERLINE) then
            Include(FontStyle, fsUnderline);
        if Boolean(FMarks[Pos] and MARK_STRIKEOUT) then
            Include(FontStyle, fsStrikeOut);
        // face
        if Boolean(FMarks[Pos] and MARK_CODE) then
            FontFace := MarkStyle.CodeFace
        else
            FontFace := Font.Name;
        Result := True;
    end
    else
        Result := False;
end;

function TvqMarkedText.PositionFromPoint(P: TPoint): Integer;
var
    I, Row: Integer;
    RowLimit, Right: Integer;
begin
    Result := -1;
    if P.Y >= FOrigin.Y then begin
        // calculate row
        Row := 0;
        while (Row < RowCount) and (FRowsBottom[Row] <= P.Y) do
            Inc(Row);
        // calculate position
        if Row < RowCount then begin
            RowLimit := CalculateRowLimit(Row);
            I := FStarts[Row];
            if I < RowLimit then begin
                Right := FSizes[I].cx + FRowsLeft[Row];
                while (I < RowLimit) and (Right <= P.X) do begin
                    Inc(I);
                    Inc(Right, FSizes[I].cx);
                end;
            end;
            // return
            if I < RowLimit then Result := I;
        end;
    end;
end;

function TvqMarkedText.LinkFromPosition(Pos: Integer): TvqMarkLink;
var
    I: Integer;
begin                                               
    Result := nil;
    if (Pos >= 0) and (Pos < TextLength) then begin
        for I := 0 to Length(FLinks) - 1 do
            if FLinks[I].InRange(Pos) then begin
                Result := FLinks[I];
                Break;
            end;
    end;
end;

//--

function TvqMarkedText.TextLength: Integer;
begin
    Result := Length(FChars);
end;

function TvqMarkedText.RowCount: Integer;
begin
    Result := Length(FStarts);
end;

function TvqMarkedText.GetLinkAt(Index: Integer): TvqMarkLink;
begin
    if (Index >= 0) and (Index < Length(FLinks)) then
        Result := FLinks[Index]
    else
        Result := nil;
end;    

function TvqMarkedText._GetChar(Pos: Integer): Char;
begin
    Result := GetChar(Pos);
end;

function TvqMarkedText._GetString(Pos, Len: Integer): string;
var
    I: Integer;
begin
    if (Pos >= 0) and (Pos < TextLength) and (Len > 0) then begin
        if Pos + Len > TextLength then
            Len := TextLength - Pos;
        SetLength(Result, Len);
        for I := 1 to Len do
            Result[I] := FChars[I - 1 + Pos];
    end
    else Result := '';
end;

function TvqMarkedText._GetArray(Pos, Len: Integer; var Txt: TCharArray): Boolean;
var
    I: Integer;
begin
    Result := False;
    if (Pos >= 0) and (Pos < TextLength) and (Len > 0) then begin
        if Pos + Len > TextLength then
            Len := TextLength - Pos;
        SetLength(Txt, Len);
        for I := 1 to Len do
            Txt[I] := FChars[I - 1 + Pos];
        Result := True;
    end
    else Txt := '';
end;

function TvqMarkedText._TextLength: Integer;
begin
    Result := TextLength;
end;

function TvqMarkedText._WholeWordAt(PosFrom, PosTo: Integer): Boolean;
begin
    Result := True;
end;

{ TvqMarkStyle }

constructor TvqMarkStyle.Create(AControl: TControl); 
begin
    FControl := AControl;
    FLinkNormal  := clHighlight;
    FLinkHovered := clHotlight;
    FLinkVisited := clViolet;
    FLinkPressed := clHotlight;
    FCodeFore := clCaptionText;
    FCodeBack := clSilver;
    FCodeFace := 'Lucida Console';
    FImageFore := clGray;
    FUnderlineHotLink := True;
end;

destructor TvqMarkStyle.Destroy;
begin
    inherited;
end;

procedure TvqMarkStyle.Assign(Source: TPersistent);
var
    Other: TvqMarkStyle;
begin
    if (Source is TvqMarkStyle) and (Source <> Self) then begin
        Other := TvqMarkStyle(Source);
        FLinkNormal       := Other.FLinkNormal      ;
        FLinkHovered      := Other.FLinkHovered     ;
        FLinkVisited      := Other.FLinkVisited     ;
        FLinkPressed      := Other.FLinkPressed     ;
        FCodeFore         := Other.FCodeFore        ;
        FCodeBack         := Other.FCodeBack        ;
        FCodeFace         := Other.FCodeFace        ;
        FImageFore        := Other.FImageFore       ;
        FUnderlineHotLink := Other.FUnderlineHotLink;
        UpdateMetrics;
    end
    else inherited;
end;

procedure TvqMarkStyle.UpdateMetrics;
begin
    if Assigned(FOnUpdateMetrics) then 
        FOnUpdateMetrics(Self)
    else
        Repaint;
end;

procedure TvqMarkStyle.Repaint;
begin
    if FControl <> nil then 
        FControl.Repaint;
end;

procedure TvqMarkStyle.SetLinkNormal (Value: TColor);
begin
    if FLinkNormal <> Value then begin
        FLinkNormal := Value;
        Repaint;
    end;
end;

procedure TvqMarkStyle.SetLinkHovered(Value: TColor);
begin
    if FLinkHovered <> Value then begin
        FLinkHovered := Value;
        Repaint;
    end;
end;

procedure TvqMarkStyle.SetLinkVisited(Value: TColor);
begin
    if FLinkVisited <> Value then begin
        FLinkVisited := Value;
        Repaint;
    end;
end;

procedure TvqMarkStyle.SetLinkPressed(Value: TColor);
begin
    if FLinkPressed <> Value then begin
        FLinkPressed := Value;
        Repaint;
    end;
end;

procedure TvqMarkStyle.SetCodeFore   (Value: TColor);
begin
    if FCodeFore <> Value then begin
        FCodeFore := Value;
        Repaint;
    end;
end;

procedure TvqMarkStyle.SetCodeBack   (Value: TColor);
begin
    if FCodeBack <> Value then begin
        FCodeBack := Value;
        Repaint;
    end;
end;

procedure TvqMarkStyle.SetImageFore  (Value: TColor);
begin
    if FImageFore <> Value then begin
        FImageFore := Value;
        Repaint;
    end;
end;

procedure TvqMarkStyle.SetCodeFace   (Value: TFontName);
begin
    if FCodeFace <> Value then begin
        FCodeFace := Value;
        UpdateMetrics;
    end;
end;

procedure TvqMarkStyle.SetUnderlineHotLink(Value: Boolean);
begin
    if FUnderlineHotLink <> Value then begin
        FUnderlineHotLink := Value;
        UpdateMetrics;
    end;
end;

end.
