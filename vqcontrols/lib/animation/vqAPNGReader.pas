// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqAPNGReader;

interface

uses
    SysUtils, Classes, FPImage, FPImgCmn, PNGComn, ZStream,
    FPReadPNG,
    IntfGraphics, GraphType, Graphics, StdCtrls, Dialogs,
    vqUtils;

const
    APNG_MAX_FRAME_COUNT        = MaxInt div 2;
    
    APNG_DISPOSE_OP_NONE        = 0;  
    APNG_DISPOSE_OP_BACKGROUND  = 1;  
    APNG_DISPOSE_OP_PREVIOUS    = 2;
    
    APNG_BLEND_OP_SOURCE        = 0;
    APNG_BLEND_OP_OVER          = 1;
    
type
    
    APNGException = class(FPImageException);
    
    TAPNGFrameControl = packed record
        case Byte of
            0: (
                SequenceNumber: Longword;
                Width: Longword;
                Height: Longword;
                XOffset: Longword;
                YOffset: Longword;
                DelayNumerator: Word;
                DelayDenominator: Word;
                DisposalOperator: Byte;
                BlendOperator: Byte;
            );   
    end;
    
    TAPNGAnimationControl = packed record
        case Byte of
            0: (
                FrameCount: Longword; 
                PlayCount: Longword;
            );
    end;
    
    TAPNGReader = class;
    
    { TAPNGFrame }

    TAPNGFrame = class
    public
        Control: TAPNGFrameControl;
        ZData: TMemoryStream;
        Image: TFPCustomImage;
        fdATChunkCount: Longword;
        constructor Create; virtual;
        destructor Destroy; override;
        procedure ReleaseZData;
        procedure RemoveImage(var AImage: TFPCustomImage);
    end;
                     
    TPixelWriterProc = procedure (AImage: TFPCustomImage; X, Y: Integer; 
        ColorData: TColorData) of object; 
            
    { TAPNGFrameDecompressor }

    TAPNGFrameDecompressor = class(TLazReaderPNG)
    protected  // variables for each frame   
        
        StartPass, EndPass: Integer;
        FrameCountScanLines, FrameScanLineLength: EightLong;
        FramePreviousLine: PByteArray;
        FrameCurrentLine: PByteArray;  
                       
    protected // global variables shadow
        
        ByteWidth: Byte;
        CountBitsUsed: Byte;
        BitShift: Byte;
        BitsUsed: EightLong;
        WritePixel: TPixelWriterProc; 
        AlphaPalette: Boolean;
        
        procedure PalettePixelWritter(AImage: TFPCustomImage; X, Y: Integer; ColorData: TColorData);
        procedure PaletteColorPixelWriter(AImage: TFPCustomImage; X, Y: Integer; ColorData: TColorData);
        procedure ColorTransparentPixelWriter(AImage: TFPCustomImage; X, Y: Integer; ColorData: TColorData);
        procedure ColorPixelWriter(AImage: TFPCustomImage; X, Y: Integer; ColorData: TColorData);
    protected
        procedure HandleAlpha; override;
    public
        Control: TAPNGFrameControl;
        Image: TFPCustomImage;
        DecompressionStream: TDecompressionStream;
        function ReverseFiltering(LineFilter: Byte; Col: Longword; Value: Byte): Byte;
        procedure DecompressFrame(AFrame: TAPNGFrame);
        procedure PrepareImage;
        procedure InitializeFrameDecompressor;
        procedure DecodeFrame; 
        
    end;
    
    TAPNGReader = class(TAPNGFrameDecompressor)
    protected                                
        procedure HandleDecompression;
        
        procedure HandleAnimationControl;
        procedure HandleDefaultFrameControl;
        procedure HandleFrameControl;
        procedure HandleFrameData;
        procedure HandleMainData;
        
        procedure ClearFrames;
        procedure APNGError(Msg: string);
    public
        FrameArrayLength: Integer;
        FrameArray: array of TAPNGFrame;
        DefaultFrameControl: TAPNGFrameControl; // default frame control
        AnimateDefault: Boolean; // if default image is a frame
        AnimationControl: TAPNGAnimationControl;
        
        
        // iteration
        IDATReaded: Boolean;
        IsAPNG: Boolean; 
        NoMoreIDAT: Boolean;
        Iterator: Longword;
        Frame: TAPNGFrame;
        
        procedure HandleChunk; override;
        procedure InternalRead(Str: TStream; Img: TFPCustomImage); override;
        procedure DoDecompress; override;
    public
        constructor Create; override;
        destructor Destroy; override;
    end;

implementation

{ TAPNGFrame }

constructor TAPNGFrame.Create;
begin
    fdATChunkCount := 0;
    ZData := TMemoryStream.Create;
    Image := TLazIntfImage.Create(0, 0, []);
end;

destructor TAPNGFrame.Destroy;
begin
    if ZData <> nil then ZData.Free;
    if Image <> nil then Image.Free;
    inherited;
end;

procedure TAPNGFrame.ReleaseZData;
begin
    if ZData <> nil then ZData.Free;
    ZData := nil;
end;

procedure TAPNGFrame.RemoveImage(var AImage: TFPCustomImage);
begin
    AImage := Image;
    Image := nil;
end;

{**************************** DECOMPRESSOR ************************************}

const 
    StartPointsTable: array[0..7, 0..1] of Word =
         ((0, 0), (0, 0), (4, 0), (0, 4), (2, 0), (0, 2), (1, 0), (0, 1));
    
    DeltaTable: array[0..7, 0..1] of Word =
        ((1, 1), (8, 8), (8, 8), (4, 8), (4, 4), (2, 4), (2, 2), (1, 2));
    
    BitsUsed1DepthTable: EightLong = 
        ($80, $40, $20, $10, $08, $04, $02, $01);
    
    BitsUsed2DepthTable: EightLong = 
        ($C0, $30, $0C, $03, 0, 0, 0, 0);
        
    BitsUsed4DepthTable: EightLong = 
        ($F0, $0F, 0, 0, 0, 0, 0, 0);
    
    BitsUsed8DepthTable: EightLong =
        ($F0, 0, 0, 0, 0, 0, 0, 0);
        
    BitsUsed16DepthTable: EightLong =
        (0, 0, 0, 0, 0, 0, 0, 0);
    
    ByteWidthTable: array[0..6, 0..4] of Byte = (     
    {    1  2  4  8 16     } 
    {0} (1, 1, 1, 1, 2),      
    {1} (0, 0, 0, 0, 0),      
    {2} (6, 6, 6, 3, 6),      
    {3} (1, 1, 1, 1, 2),      
    {4} (4, 4, 4, 2, 4),      
    {5} (0, 0, 0, 0, 0),      
    {6} (8, 8, 8, 4, 8)
    );
    
    CountBitsUsedTable: array[0..4] of Byte =                  
    {    1  2  4  8 16     } 
        (8, 4, 2, 1, 0);
    BitShiftTable: array[0..4] of Byte =                   
    {    1  2  4  8 16     }
        (1, 2, 4, 0, 0);
        
var
    BitsUsedTable: array[0..4] of  EightLong;

{ TAPNGReader.TFrameDecompressor }

procedure TAPNGFrameDecompressor.DecompressFrame(AFrame: TAPNGFrame);
begin              
    StartPass := 0;
    EndPass := 0;
    FillChar(FrameCountScanLines, SizeOf(FrameCountScanLines), 0);
    FillChar(FrameScanLineLength, SizeOf(FrameScanLineLength), 0);
    FramePreviousLine := nil;
    FrameCurrentLine := nil;
    
    Image := AFrame.Image;
    Control := AFrame.Control;
    AFrame.ZData.Position := 0;
    DecompressionStream := TDecompressionStream.Create(AFrame.ZData);
    
    try                                        
        PrepareImage;
        InitializeFrameDecompressor;
        DecodeFrame;
          
    finally
        DecompressionStream.Free;
        Image := nil;
    end;
end;

procedure TAPNGFrameDecompressor.PrepareImage;
var 
    IsAlpha: Boolean;
    Desc: TRawImageDescription;
begin
    // because Image is TLazIntfImage and Reader is TLazReaderPNG 
    // then always Updates description
    
    Image.UsePalette := TheImage.UsePalette;
    if Image.UsePalette then
        Image.Palette.Copy(TheImage.Palette);
        
    if TheImage is TLazIntfImage then begin
        
        IsAlpha := Boolean(Header.ColorType and 4) or AlphaPalette or UseTransparent;
        if (not IsAlpha) and UseTransparent then
            Desc.Init_BPP32_B8G8R8A8_M1_BIO_TTB(Control.Width, Control.Height)
        else
            Desc.Init_BPP32_B8G8R8A8_BIO_TTB(Control.Width, Control.Height);
        
        Desc.Format       := TLazIntfImage(TheImage).DataDescription.Format      ;
        Desc.BitsPerPixel := TLazIntfImage(TheImage).DataDescription.BitsPerPixel;
        Desc.Depth        := TLazIntfImage(TheImage).DataDescription.Depth       ;
        Desc.RedPrec      := TLazIntfImage(TheImage).DataDescription.RedPrec     ;
        Desc.RedShift     := TLazIntfImage(TheImage).DataDescription.RedShift    ;
        Desc.GreenPrec    := TLazIntfImage(TheImage).DataDescription.GreenPrec   ;
        Desc.GreenShift   := TLazIntfImage(TheImage).DataDescription.GreenShift  ;
        Desc.BluePrec     := TLazIntfImage(TheImage).DataDescription.BluePrec    ;
        Desc.BlueShift    := TLazIntfImage(TheImage).DataDescription.BlueShift   ;
        Desc.AlphaPrec    := TLazIntfImage(TheImage).DataDescription.AlphaPrec   ;
        Desc.AlphaShift   := TLazIntfImage(TheImage).DataDescription.AlphaShift  ;
        
        TLazIntfImage(Image).DataDescription := Desc;
        
    end;     

end;

procedure TAPNGFrameDecompressor.InitializeFrameDecompressor;
var
    R, D: Integer;
begin
    with Header do begin
        if Interlace = 0 then begin
            StartPass := 0;
            EndPass := 0;
            FrameCountScanLines[0] := Control.Height;
            FrameScanLineLength[0] := Control.Width;
        end
        else begin
            StartPass := 1;
            EndPass := 7;
            for R := 1 to 7 do begin
                D := Control.Height div DeltaTable[R, 1];
                if (Control.Height mod DeltaTable[R, 1]) > StartPointsTable[R, 1] then
                    Inc(D);
                FrameCountScanLines[R] := D;
                D := Control.Width div DeltaTable[R, 0];
                if (Control.Width mod DeltaTable[R, 0]) > StartPointsTable[R, 0] then
                    Inc(D);
                FrameScanLineLength[R] := D;  
            end;
        end;
        
    end;
end;

procedure TAPNGFrameDecompressor.DecodeFrame;
var
    Y, X, Pass, Row, Col, L: Integer;
    LineFilter: Byte;
    FrameUsingBitGroup: Byte;
    LineByte: PByte;
    ColorData: TColorData;
    
    StartX, StartY, DeltaX, DeltaY: Integer;
    
    procedure CalculateColor;
    var
        ColorByte, NextByte: PByte;
    begin
        // utilizar Inc, Dec, Next y Prev o cambiar algoritmo
        if FrameUsingBitGroup = 0 then begin
            ColorData := 0;
            NextByte := LineByte;
            Inc(NextByte, ByteWidth);
            if Header.BitDepth = 16 then begin
                ColorByte := @ColorData;
                while LineByte < Prev(NextByte) do begin
                    ColorByte^ := Next(LineByte)^;
                    Inc(ColorByte);
                    ColorByte^ := LineByte^;
                    Inc(ColorByte);
                    Inc(LineByte, 2);
                end;
            end
            else
                System.Move(LineByte^, ColorData, ByteWidth);
            {$IFDEF ENDIAN_BIG}
            ColorData := Swap(ColorData);
            {$ENDIF}
            LineByte := NextByte;
        end;
        if ByteWidth = 1 then begin
            ColorData := (ColorData and BitsUsed[FrameUsingBitGroup]);
            ColorData := ColorData shr ((CountBitsUsed - FrameUsingBitGroup - 1)*BitShift);
            Inc(FrameUsingBitGroup);
            if FrameUsingBitGroup >= CountBitsUsed then
                FrameUsingBitGroup := 0;
        end;
    end;
    
    procedure WriteLine;
    var
        C: Integer;
    begin
        FrameUsingBitGroup := 0;
        LineByte := @(FrameCurrentLine^);
        for C := 0 to FrameScanLineLength[Pass] - 1 do begin
            X := StartX + DeltaX*C;
            CalculateColor;
            WritePixel(Image, X, Y, ColorData);
        end;
    end;
    
begin
    for Pass := StartPass to EndPass do begin
        
        StartX := StartPointsTable[Pass, 0];
        StartY := StartPointsTable[Pass, 1];
        DeltaX := DeltaTable[Pass, 0];
        DeltaY := DeltaTable[Pass, 1];
        
        if ByteWidth = 1 then begin
            L := FrameScanLineLength[Pass] div CountBitsUsed;
            if (FrameScanLineLength[Pass] mod CountBitsUsed) > 0 then 
                Inc(L);
        end
        else
            L := FrameScanLineLength[Pass]*ByteWidth;
        if L > 0 then begin
            GetMem(FramePreviousLine, L);
            FillChar(FramePreviousLine^, L, 0);
            GetMem(FrameCurrentLine, L);
            try
                for Row := 0 to FrameCountScanLines[Pass] - 1 do begin
                    Y := StartY + Row*DeltaY;
                    DecompressionStream.Read(LineFilter, 1);
                    DecompressionStream.Read(FrameCurrentLine^, L);
                    
                    if LineFilter <> 0 then // filtered line
                        for Col := 0 to L - 1 do
                            FrameCurrentLine^[Col] := ReverseFiltering(LineFilter, Col, FrameCurrentLine^[Col]);
                    
                    WriteLine;
                    
                    ExchangePointer(FrameCurrentLine, FramePreviousLine);
                end;
            finally
                FreeMem(FramePreviousLine);
                FreeMem(FrameCurrentLine);
            end;
        end;
    end;
end;

function TAPNGFrameDecompressor.ReverseFiltering(LineFilter: Byte; Col: Longword; Value: Byte): Byte;
var
    Diff: Byte;
    Left, Above, UpperLeft: Byte;
    
    function PaethPredictor: Byte;
    var
        A, B, C: Integer;
    begin
        A := Abs(Above - UpperLeft);
        B := Abs(Left - UpperLeft);
        C := Abs(Left - UpperLeft + Above - UpperLeft);
        if (A <= B) and (A <= C) then 
            Result := Left
        else if B <= C then
            Result := Above
        else
            Result := UpperLeft;
    end;
    
begin
    { LineFilter <> 0 }
    if Col < ByteWidth then
        Left := 0
    else
        Left := FrameCurrentLine^[Col - ByteWidth];
    case LineFilter of
        1: // sub filter
            Diff := Left;
        2: // up filter
            Diff := FramePreviousLine^[Col];
        3: // average filter
            Diff := (Left + FramePreviousLine^[Col]) div 2;
        4: begin // paeth filter
            if Col < ByteWidth then
                UpperLeft := 0
            else
                UpperLeft := FramePreviousLine^[Col - ByteWidth];
            Above := FramePreviousLine^[Col];
            Diff := PaethPredictor;
        end;
    end;
    Result := (Value + Diff) mod 256;
end;

procedure TAPNGFrameDecompressor.PalettePixelWritter(AImage: TFPCustomImage; X, Y: Integer; ColorData: TColorData);
begin
    AImage.Pixels[X, Y] := ColorData;
end;

procedure TAPNGFrameDecompressor.PaletteColorPixelWriter(AImage: TFPCustomImage; X, Y: Integer; ColorData: TColorData);
begin
    AImage.Colors[X, Y] := ThePalette[ColorData];
end;

procedure TAPNGFrameDecompressor.ColorTransparentPixelWriter(AImage: TFPCustomImage; X, Y: Integer; ColorData: TColorData);
var
    C: TFPColor;
begin
    C := ConvertColor(ColorData);
    if TransparentDataValue = ColorData then
        C.Alpha := AlphaTransparent;
    AImage.Colors[X, Y] := C;
end;

procedure TAPNGFrameDecompressor.ColorPixelWriter(AImage: TFPCustomImage; X, Y: Integer; ColorData: TColorData);
begin
    AImage.Colors[X, Y] := ConvertColor(ColorData);
end;

procedure TAPNGFrameDecompressor.HandleAlpha;
begin
    inherited;
    AlphaPalette := Header.ColorType = 3;
end;

{**************************** READER ******************************************}

{ TAPNGReader }

constructor TAPNGReader.Create;
begin
    inherited Create;
    FrameArray := nil;
end;

destructor TAPNGReader.Destroy;
begin     
    ClearFrames;
    inherited;
end;

procedure TAPNGReader.HandleDecompression;
var
    I: Integer;                      
    BitDepthI: Byte;
begin
    // initialize shadow variables
    with Header do begin
        BitDepthI := Log2OfPow2[BitDepth];
        ByteWidth := ByteWidthTable[ColorType, BitDepthI];
        CountBitsUsed := CountBitsUsedTable[BitDepthI];
        BitShift := BitShiftTable[BitDepthI];
        BitsUsed := BitsUsedTable[BitDepthI];
        
        if Pltte then
            if TheImage.UsePalette then
                WritePixel := @PalettePixelWritter
            else
                WritePixel := @PaletteColorPixelWriter
        else
            if UseTransparent then
                WritePixel := @ColorTransparentPixelWriter
            else
                WritePixel := @ColorPixelWriter;
        
    end;
    // execute decompression           
    for I := 0 to FrameArrayLength - 1 do begin
        if FrameArray[I].fdATChunkCount = 0 then
            APNGError('At least one fdAT is required for fcTL')
        else
            DecompressFrame(FrameArray[I]);
    end;                         
end;

procedure TAPNGReader.HandleAnimationControl;
var
    I: Integer;
begin
    if Chunk.ALength <> 8 then
        APNGError('Invalid acTL chunk length');
    System.Move(Chunk.Data^, AnimationControl, 8);
    with AnimationControl do begin
        {$IFDEF ENDIAN_LITTLE}
        FrameCount := Swap(FrameCount); 
        PlayCount := Swap(PlayCount); 
        {$ELSE}
        // maintains 
        {$ENDIF}      
        if FrameCount = 0 then 
            APNGError('Invalid acTL frame count');    
        
        if FrameCount > APNG_MAX_FRAME_COUNT then
            APNGError('Sorry! Too much frames for TAPNGReader :-)');
        
        SetLength(FrameArray, FrameCount);
        for I := 0 to FrameCount - 1 do begin
            FrameArray[I] := TAPNGFrame.Create;
        end;
        
    end;
end;

procedure TAPNGReader.HandleDefaultFrameControl;
begin
    if Chunk.ALength <> 26 then
        APNGError('Invalid fcTL chunk length');
    
    AnimateDefault := True;
    
    System.Move(Chunk.Data^, DefaultFrameControl, 26);
    
    with DefaultFrameControl do begin
        {$IFDEF ENDIAN_LITTLE}   
        SequenceNumber   := Swap(SequenceNumber  );
        Width            := Swap(Width           );
        Height           := Swap(Height          );
        XOffset          := Swap(XOffset         );
        YOffset          := Swap(YOffset         );
        DelayNumerator   := Swap(DelayNumerator  );
        DelayDenominator := Swap(DelayDenominator);
        {$ELSE}       
        // maintains 
        {$ENDIF}
        
        // checking sequence number
        
        if SequenceNumber = Iterator then
            Inc(Iterator)
        else
            APNGError('Unsorted APNG stream');
        
        // checking bounds
        
        if  (XOffset <> 0) or
            (YOffset <> 0) or
            (Width <> Header.Width) or
            (Height <> Header.Height) then
            APNGError('Invalid default frame bounds');
    end;
    
end;
  
procedure TAPNGReader.HandleFrameControl;
begin                                
    if Chunk.ALength <> 26 then
        APNGError('Invalid fcTL chunk length');
    
    if not IDATReaded then 
        APNGError('Unexpected double fcTL in defaul frame');
    
    NoMoreIDAT := True;
    
    Frame := FrameArray[FrameArrayLength];
    Inc(FrameArrayLength);
    
    System.Move(Chunk.Data^, Frame.Control, 26);
    with Frame.Control do begin
        {$IFDEF ENDIAN_LITTLE}   
        SequenceNumber   := Swap(SequenceNumber  );
        Width            := Swap(Width           );
        Height           := Swap(Height          );
        XOffset          := Swap(XOffset         );
        YOffset          := Swap(YOffset         );
        DelayNumerator   := Swap(DelayNumerator  );
        DelayDenominator := Swap(DelayDenominator);
        {$ELSE}       
        // maintains 
        {$ENDIF}
        
        // checking sequence number
        
        if SequenceNumber = Iterator then
            Inc(Iterator)
        else                               
            APNGError('Unsorted APNG stream');  
        
        // checking bounds
        
        if  (Width = 0) or (Height = 0) or 
            (XOffset + Width > Header.Width) or
            (YOffset + Height > Header.Height) then
            APNGError('Invalid fcTL bounds');
        
        Frame.Image.SetSize(Width, Height);
    end;                                        
end;

procedure TAPNGReader.HandleFrameData;
var
    SequenceNumber: Longword;
    OldSize, SizeInc: Longword;
begin   
    if Chunk.alength < 4 then
        APNGError('Invalid fdAT chunk length');
    
    NoMoreIDAT := True;
    Inc(Frame.fdATChunkCount);
    
    System.Move(Chunk.Data^, SequenceNumber, 4);
    {$IFDEF ENDIAN_LITTLE}
    SequenceNumber := Swap(SequenceNumber);
    {$ELSE}
    // maintains
    {$ENDIF}
    
    if SequenceNumber = Iterator then
        Inc(Iterator)
    else
        APNGError('Unsorted APNG stream');
    
    SizeInc := Chunk.ALength;
    Dec(SizeInc, 4);     
    OldSize := Frame.ZData.Size;
    Frame.ZData.Size := OldSize + SizeInc;
    Frame.ZData.Write(Chunk.Data^[4], SizeInc); 
                                      
end;

procedure TAPNGReader.HandleMainData;
begin
    IDATReaded := True;
    if NoMoreIDAT then
        // IDAT is ivalid after no default fcTL
        APNGError('Invalid APNG no-default frame before IDAT')
    else
        // process default IDAT
        inherited HandleChunk;
end;

procedure TAPNGReader.HandleChunk;
begin
    
    if IsAPNG then begin
        // stream is APNG
        if Chunk.ReadType = 'acTL' then
            APNGError('Duplicated acTL chunk')
        else if Chunk.ReadType = 'fcTL' then begin    
            if (Iterator = 0) and (not IDATReaded) then
                HandleDefaultFrameControl
            else
                HandleFrameControl;                       
        end
        else if Chunk.ReadType = 'fdAT' then
            HandleFrameData
        else if Chunk.AType = ctIDAT then
            HandleMainData
        else
            // other chunk
            inherited HandleChunk;
    end
    
    // --
    
    else if IDATReaded then
        // stream is PNG only
        inherited HandleChunk  
    else begin
        // determine if stream is APNG or PNG
        
        if Chunk.AType = ctIDAT then begin
            // reading first IDAT
            IDATReaded := True; // flag for checking acTL order
            inherited HandleChunk;
        end
        else if Chunk.ReadType = 'acTL' then begin 
            // APNG detected
            IsAPNG := True;
            HandleAnimationControl;
        end
        else begin
            // reading chunks before IDAT | acTL
            inherited HandleChunk;
        end;
    end;
end;

procedure TAPNGReader.APNGError(Msg: string);
begin  
    raise APNGException.Create('APNG: ' + Msg);
end;

procedure TAPNGReader.ClearFrames;
var
    I: Integer;
begin
    for I := 0 to Length(FrameArray) - 1 do
        FrameArray[I].Free;  
    FrameArray := nil;
    Frame := nil;
end;

procedure TAPNGReader.InternalRead(Str: TStream; Img: TFPCustomImage);
var
    I: Longword;
begin
    
    ClearFrames;
    AnimateDefault := False;
    IDATReaded := False;
    IsAPNG := False;
    NoMoreIDAT := False;
    Iterator := 0;
    FrameArrayLength := 0;
    Frame := nil;
    
    try
        
        inherited InternalRead(Str, Img);
        
    finally         
        if IsAPNG then 
            for I := 0 to Length(FrameArray) - 1 do
                FrameArray[I].ReleaseZData;  
        
    end;                          
end;

procedure TAPNGReader.DoDecompress;
begin
    inherited DoDecompress;
    if IsAPNG then
        HandleDecompression;
end;

initialization
    BitsUsedTable[0] := BitsUsed1DepthTable;  
    BitsUsedTable[1] := BitsUsed2DepthTable ; 
    BitsUsedTable[2] := BitsUsed4DepthTable ;
    BitsUsedTable[3] := BitsUsed8DepthTable ;
    BitsUsedTable[4] := BitsUsed16DepthTable; 

end.
