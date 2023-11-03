// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqAutoPath;

interface
            
uses
    vqUtils;

function ScanPath(Text: IvqTextBuffer; var From: Integer): Integer;

implementation

function ScanPath(Text: IvqTextBuffer; var From: Integer{; AutoFile: Boolean = False}): Integer;

label
    LBL_NO_AUTOFILE;

var
    I, L, S, T: Integer;

    function IsNameChar(C: Char): Boolean;
    begin
        Result :=
            (C > #127) or
            ((C > #32) and
             (C < #127) and
             not (C in ['|', '?', '*', '/', ':', '<', '>', '\', '"']));
    end;
    
    function IsAutoFileChar(C: Char): Boolean;
    begin
        Result := IsAlphaNumChar(C) or (C in []);
    end;
    
begin
    Result := 0;
    L := Text._TextLength;
    I := From;
    
    {if (Text[I] = '.') and AutoFile then begin
        S := I;
        T := I;
        while (I < L) and IsAutoFileChar(Text[I]) do begin
            Inc(I);
            if (I < L) and (Text[I] = '.') then begin
                Inc(I);
                if (I < L) and IsAutoFileChar(Text[I]) then
                    T := I // new extension
                else
                    Dec(I); // no more extesions
            end;
        end;
        if IsCommonFile(Text._GetString(T, I - T)) then begin
            while (S > 0) and IsAutoFileChar(Text[S - 1]) do begin
                Dec(S);
                if (S > 0) and (Text[S - 1] in ['.', '\', '/']) then
                    Dec(S);
            end;
            From := S;
        end
        else goto LBL_NO_AUTOFILE;
    end
    else} begin
        LBL_NO_AUTOFILE:
        
        if (Text[I] in ['A'..'Z']) and (Text[I + 1] = ':') then begin
            Inc(I);
            Inc(I);
        end;
        while IsNameChar(Text[I]) or (Text[I] in ['\', '/']) do
            Inc(I);
    end;
    Result := I - From;
end;

end.
