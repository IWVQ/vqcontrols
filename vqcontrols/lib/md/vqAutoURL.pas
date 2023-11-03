// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqAutoURL;

interface

uses
    vqUtils;

type
    
    TvqTLDArray = class
    protected
        FTypes: TByteArray;
        FDomains: TStrArray;
        FCount: Integer;
        procedure UpdateRoom;
        function GetItem(I: Integer): string;
        procedure SetItem(I: Integer; Value: string);
    public
        constructor Create;
        destructor Destroy; override;
        procedure Initialize;
        procedure AddTLD(S: string; T: Byte);
        procedure RemoveTLD(S: string);
        function FindTLD(S: string): Integer;
        function IsTLD(S: string): Boolean;
        function IsTLD(S: string; T: Byte): Boolean;
        function DomainType(S: string): Byte;
        property Count: Integer read FCount;
        property Item[I: Integer]: string read GetItem write SetItem; default;
    end;
    
const
    INFRASTRUCTURE_TLD     = 1;
    TEST_TLD               = 2;
    SPONSORED_TLD          = 3;
    GENERIC_TLD            = 4;
    GENERIC_RESTRICTED_TLD = 5;
    COUNTRY_CODE_TLD       = 6;
    
var
    vqTLDArray: TvqTLDArray;
    
function IsTLD(S: string): Boolean;
function ScanURL(Text: IvqTextBuffer; var From: Integer): Integer;
function ScanURIScheme(Text: IvqTextBuffer; var I: Integer; var Scheme: string): Boolean;

implementation

function IsTLD(S: string): Boolean;
begin // only most used TLDs
    Result := vqTLDArray.IsTLD(S);
end;

function ScanURL(Text: IvqTextBuffer; var From: Integer): Integer;
// utf-8 only
const
    _FILE   = 1;
    _FTP    = 2;
    _HTTP   = 3; // http or https
    _MAILTO = 4;
    
var
    I, L, K: Integer;
    Scheme: Byte;

    function IsBodyChar(C: Char): Boolean;
    begin
        Result :=
            (C > #127) or
            ((C > #32) and
             (C < #127) and
             not (C in ['"', '''', '<', '`', '>', '{', '}']));
    end;

    function IsUPHChar(C: Char): Boolean;
    begin // User, Password or Host char
        Result :=
            (C > #127) or
            ((C > #32) and
             (C < #127) and
             not (C in ['"', '''', '<', '`', '>', '{', '}', '/', '\', ':', '@', '#']));
    end;
    
    function IsHeaderChar(C: Char): Boolean;
    begin
        Result :=
            (C > #127) or
            ((C > #32) and
             (C < #127) and
             not (C in ['"', '''', '`', '<', '>', '{', '}', '#', '?']));
    end;
    
    function IsPathChar(C: Char): Boolean;
    begin
        Result :=
            (C > #127) or
            ((C > #32) and
             (C < #127) and
             not (C in ['"', '''', '`', '<', '>', '{', '}', '#']));
    end;
    
    function IsFragmentChar(C: Char): Boolean;
    begin
        Result :=
            (C > #127) or
            ((C > #32) and
             (C < #127) and
             not (C in ['"', '''', '`', '<', '>', '{', '}', '#', '?']));
    end;
    
    function IsTopLevelChar(C: Char): Boolean;
    begin
        Result := IsAlphaNumChar(C) or (C in ['-', '+', '%']);
    end;
    
    function ScanBody: Boolean;
    label
        LBL_NOLOGIN;
        
    var
        T, S, P: Integer;
        BracketDepth, ParDepth, CurlyDepth: Integer;
        Pass: Boolean;
        
        procedure CheckPunctuaction;
        begin
            if Text[I] = '[' then begin
                Inc(BracketDepth);
                P := I + 1;
            end
            else if Text[I] = '(' then begin
                Inc(ParDepth);
                P := I + 1;
            end
            // else if Text[I] = '{' then begin
            //     Inc(CurlyDepth);
            //     P := I + 1;
            // end
            else if Text[I] = ']' then begin
                if BracketDepth > 0 then begin
                    Dec(BracketDepth);
                    P := I + 1;
                end;
            end
            else if Text[I] = ')' then begin
                if ParDepth > 0 then begin
                    Dec(ParDepth);
                    P := I + 1;
                end;
            end
            // else if Text[I] = '}' then begin
            //     if CurlyDepth > 0 then begin
            //         Dec(CurlyDepth);
            //         P := I + 1;
            //     end;
            // end
            else if Text[I] in [',', ';', '.', ':', '?', '!'] then begin
            end
            else P := I + 1;
        end;
        
    begin
        BracketDepth := 0;
        ParDepth := 0;
        CurlyDepth := 0;
        Pass := False;
        Result := False;
        S := I;
        
        // -- LOGIN --
        
        T := I;
        P := I;
        while (I < L) and IsUPHChar(Text[I]) do begin
            CheckPunctuaction;
            Inc(I); // user | host
        end;
        if T = I then goto LBL_NOLOGIN; // neither user nor host
        if (I < L) and (Text[I] = ':') then begin
            Inc(I);
            T := I;
            while (I < L) and IsNumeralChar(Text[I]) do begin
                Inc(I); // tentative port
                P := I; // break punctuaction
            end;
            while (I < L) and IsUPHChar(Text[I]) do begin
                Pass := True;
                CheckPunctuaction;
                Inc(I); // password
            end;
            if T = I then
                Dec(I); // neither port nor password
        end;
        if (I < L) and (Text[I] = '@') then begin
            // previous was user
            P := I; // break punctuaction in "@"
            Inc(I);
            T := I;
            while (I < L) and IsUPHChar(Text[I]) do begin
                CheckPunctuaction;
                Inc(I); // host
            end;
            if (T < I) and (I < L) and (Text[I] = ':') then begin
                Inc(I);
                T := I;
                while (I < L) and IsNumeralChar(Text[I]) do begin
                    Inc(I); // port number
                    P := I; // break punctuaction
                end;
                if T = I then
                    Dec(I); // no port
            end
            else if T = I then begin
                Dec(I); // no hostport for posible user
                if Pass then
                    I := S; // no login, user needs hostport
            end
            else if P < I then begin
                I := P; // truncate
                if (T = I + 1) and Pass then
                    I := S; // no login, user needs hostport
            end;
        end;
        if (P < I) and (I > S) then begin
            // no user detected
            // no port, only host
            I := P; // truncate
        end;
        
    LBL_NOLOGIN:
        if (Scheme in [_FTP, _HTTP]) and (I = S) { no login } then Exit(False);
        P := I; // break punctuaction at least at login end
        
        // -- PATH --
        
        if (Scheme = _MAILTO) and (I < L) and
            (Text[I] = '?') then begin
            P := I; // break punctuaction in "?"
            Inc(I);
            T := I;
            while (I < L) and IsHeaderChar(Text[I]) do begin
                CheckPunctuaction;
                Inc(I); // headers
            end;
            if T = I then
                Dec(I); // no headers
        end
        else if (Scheme in [_FTP, _HTTP, _FILE]) and (I < L) and
            (Text[I] in ['\', '/']) then begin
            Inc(I);
            P := I; // break punctuaction after slash
            while (I < L) and IsPathChar(Text[I]) do begin
                CheckPunctuaction;
                Inc(I); // path, includes queries and types
            end;
        end;
        if (Scheme in [_FTP, _FILE, _HTTP]) and 
            (I < L) and (Text[I] = '#') then begin
            P := I; //break punctuaction in "#"
            Inc(I);
            T := I;
            while IsFragmentChar(Text[I]) do begin
                CheckPunctuaction;
                Inc(I); // fragment
            end;
            if T = I then
                Dec(I); // no fragment
        end;
        if P < I then begin
            I := P; // truncate
        end;
        
        //
        
        Result := I > S;
    end;
    
    function ScanSmallURL: Boolean;
    var
        S, T: Integer;
        Mail: Boolean;
    begin // punctuaction friendly
        Result := False;
        Mail := False;
        S := I;

        Inc(I);

        if I >= L then Exit;

        T := I;
        while (I < L) and IsTopLevelChar(Text[I]) do begin
            Inc(I);
            if (I < L) and (Text[I] = '.') then begin
                Inc(I);
                if (I < L) and IsTopLevelChar(Text[I]) then
                    T := I // new domain
                else
                    Dec(I); // no more domains
            end;
        end;
        
        if IsTLD(Text._GetString(T, I - T)) then begin
            while (S > 0) and IsTopLevelChar(Text[S - 1]) do begin
                Dec(S);
                if (S > 0) and (Text[S - 1] = '.') then
                    Dec(S);
            end;
            if Text[S] = '.' then Inc(S);
            //if S = T then Exit; // no domain
            if (S > 0) and (Text[S - 1] = '@') then begin
                Mail := True;
                Dec(S);
                while (S > 0) and IsTopLevelChar(Text[S - 1]) do begin
                    Dec(S);
                    if (S > 0) and (Text[S - 1] = '.') then
                        Dec(S);
                end;
                if Text[S] = '.' then Inc(S);
                if Text[S] = '@' then begin
                    Inc(S);
                    Mail := False;
                end;
            end;
            if Mail then begin
                if (I < L) and (Text[I] = '?') then begin
                    Inc(I);
                    while (I < L) and IsHeaderChar(Text[I]) do
                        Inc(I); // headers
                end;    
            end
            else { http } begin
                if (I < L) and (Text[I] in ['/', '\']) then begin
                    Inc(I);
                    while (I < L) and IsPathChar(Text[I]) do
                        Inc(I); // path, includes queries and types
                end;
                if (I < L) and (Text[I] = '#') then begin
                    Inc(I);
                    T := I;
                    while IsFragmentChar(Text[I]) do
                        Inc(I); // fragment
                    if T = I then
                        Dec(I); // no fragment
                end;
            end;
            From := S;
            Result := True;
        end
        else I := S; // not necesarily, because using "Exit"
        
    end;
    
begin
    Result := 0;
    L := Text._TextLength;
    I := From;
    
    if (I + 6 < L) and (Text[I] in ['f', 'F']) then begin
        Inc(I);
        if Text[I] in ['t', 'T'] then begin {ftp}
            Inc(I);
            if Text[I] in ['p', 'P'] then begin
                Inc(I);
                if Text[I] = ':' then begin
                    Inc(I);
                    if Text[I] = '/' then begin
                        Inc(I);
                        if Text[I] = '/' then begin
                            Inc(I);
                            if (I < L) and not IsBodyChar(Text[I]) then Exit;
                            Scheme := _FTP;
                            if not ScanBody() then Exit;
                        end
                        else Exit;
                    end
                    else Exit;
                end
                else Exit;
            end
            else Exit;
        end
        else if Text[I] in ['i', 'I'] then begin{file}
            Inc(I);
            if Text[I] in ['l', 'L'] then begin
                Inc(I);
                if Text[I] in ['e', 'E'] then begin
                    Inc(I);
                    if Text[I] = ':' then begin
                        Inc(I);
                        if Text[I] = '/' then begin
                            Inc(I);
                            if Text[I] = '/' then begin
                                Inc(I);
                                if (I < L) and not IsBodyChar(Text[I]) then Exit;
                                Scheme := _FILE;
                                if not ScanBody() then Exit;
                            end
                            else Exit;
                        end
                        else Exit;
                    end
                    else Exit;
                end
                else Exit;
            end
            else Exit;
        end
        else Exit;
    end
    else if (I + 7 < L) and (Text[I] in ['h', 'H']) then begin
        Inc(I);
        if Text[I] in ['t', 'T'] then begin
            Inc(I);
            if Text[I] in ['t', 'T'] then begin
                Inc(I);
                if Text[I] in ['p', 'P'] then begin
                    Inc(I);
                    if Text[I] in ['s', 'S'] then
                        Inc(I);
                    if Text[I] = ':' then begin
                        Inc(I);
                        if Text[I] = '/' then begin
                            Inc(I);
                            if Text[I] = '/' then begin
                                Inc(I);
                                if (I < L) and not IsBodyChar(Text[I]) then Exit;
                                Scheme := _HTTP;
                                if not ScanBody() then Exit;
                            end
                            else Exit;
                        end
                        else Exit;
                    end
                    else Exit;
                end
                else Exit;
            end
            else Exit;
        end
        else Exit;
    end
    else if (I + 7 < L) and (Text[I] in ['m', 'M']) then begin
        Inc(I);
        if Text[I] in ['a', 'A'] then begin
            Inc(I);
            if Text[I] in ['i', 'I'] then begin
                Inc(I);
                if Text[I] in ['l', 'L'] then begin
                    Inc(I);
                    if Text[I] in ['t', 'T'] then begin
                        Inc(I);
                        if Text[I] in ['o', 'O'] then begin
                            Inc(I);
                            if Text[I] = ':' then begin
                                Inc(I);
                                if (I < L) and not IsBodyChar(Text[I]) then Exit;
                                Scheme := _MAILTO;
                                if not ScanBody() then Exit;
                            end
                            else Exit;
                        end
                        else Exit;
                    end
                    else Exit;
                end
                else Exit;
            end
            else Exit;
        end
        else Exit;
    end
    else if (I < L) and (Text[I] = '.') and
        (I > 0) and
        (IsTopLevelChar(Text[I - 1])) then begin
        if not ScanSmallURL then Exit;
    end
    else Exit;
    Result := I - From;
    
end;

function ScanURIScheme(Text: IvqTextBuffer; var I: Integer; var Scheme: string): Boolean;
var
    From, L: Integer;
    
    function IsURISchemeChar(C: Char): Boolean;
    begin
        Result := IsAlphaNumChar(C) or (C in ['+', '.', '-']);
    end;
    
begin
    L := Text._TextLength;
    From := I;
    Result := False;
    if (I < L) and IsAlphaChar(Text[I]) then begin
        Inc(I);
        while (I < L) and IsURISchemeChar(Text[I]) and (Text[I] <> ':') do
            Inc(I);
        if (I < L) and (Text[I] = ':') then begin
            Scheme := Text._GetString(From, I - From);
            Result := True;
        end;
    end;
end;

{$I vqTLDArray.inc }

initialization

    vqTLDArray := TvqTLDArray.Create;

finalization

    vqTLDArray.Free;

end.


