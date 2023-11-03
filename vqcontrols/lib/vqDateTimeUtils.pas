// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

unit vqDateTimeUtils;

interface
                   
uses
    InterfaceBase, LclIntf, LclType, LMessages, LResources,
    Types, SysUtils, Classes, Graphics, Controls, Math, DateUtils,
    vqUtils;

const

    NullDateTime = TDateTime(Math.MaxDouble);
    
type

    TvqDateTime = class(TPersistent)
    private
        FDateTime: TDateTime;
        FMinDateTime: TDateTime;
        FMaxDateTime: TDateTime;
        FOnChange: TNotifyEvent;
        function GetDate: TDate;
        function GetTime: TTime;
        function GetAmPm: TAmPm;
        function GetWeek: Word;
        function GetDay: Word;
        function GetDayOfWeek: Word;
        function GetDecade: Word;
        function GetCentury: Word;
        function GetYear2D: Word;
        function GetHour: Word;
        function GetHour12: Word;
        function GetMillisecond: Word;
        function GetMinute: Word;
        function GetMonth: Word;
        function GetSecond: Word;
        function GetYear: Word;
        
        procedure SetDateTime(Value: TDateTime);
        procedure SetMinDateTime(Value: TDateTime);
        procedure SetMaxDateTime(Value: TDateTime);
        procedure SetDate(Value: TDate);
        procedure SetTime(Value: TTime);
        procedure SetAmPm(Value: TAmPm);
        procedure SetWeek(Value: Word);
        procedure SetDay(Value: Word);
        procedure SetDayOfWeek(Value: Word);
        procedure SetDecade(Value: Word);
        procedure SetCentury(Value: Word);
        procedure SetYear2D(Value: Word);
        procedure SetHour(Value: Word);
        procedure SetHour12(Value: Word);
        procedure SetMillisecond(Value: Word);
        procedure SetMinute(Value: Word);
        procedure SetMonth(Value: Word);
        procedure SetSecond(Value: Word);
        procedure SetYear(Value: Word);
    protected
        procedure Changed; virtual;
        procedure CheckNullDateTime;
        procedure CheckNullDate;
        procedure CheckNullTime;
    public
        constructor Create(ADateTime: TDateTime);
        procedure Assign(Source: TPersistent); override;
        
        function GetParams(var AYear, AMonth, ADay, AHour, AMinute, ASecond, AMillisecond: Word): Boolean;
        function GetDateParams(var AYear, AMonth, ADay: Word): Boolean;
        function GetTimeParams(var AHour, AMinute, ASecond, AMillisecond: Word): Boolean;
        procedure SetParams(AYear, AMonth, ADay, AHour, AMinute, ASecond, AMillisecond: Word);
        procedure SetDateParams(AYear, AMonth, ADay: Word);
        procedure SetTimeParams(AHour, AMinute, ASecond, AMillisecond: Word);
        function IsNull: Boolean;
        function DateTimeString(Format: string; Settings: TFormatSettings): string;
        
        procedure OffsetCentury(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetYear2D(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetDecade(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetYear(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetMonth(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetDay(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetWeek(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetDayOfWeek(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetHour12(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetHour(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetMinute(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetSecond(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetMillisecond(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        procedure OffsetAmPm(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
        
        property DateTime: TDateTime read FDateTime write SetDateTime;
        property MinDateTime: TDateTime read FMinDateTime write SetMinDateTime;
        property MaxDateTime: TDateTime read FMaxDateTime write SetMaxDateTime;
        property Date: TDate read GetDate write SetDate;
        property Time: TTime read GetTime write SetTime;
        property Century: Word read GetCentury write SetCentury;
        property Year2D: Word read GetYear2D write SetYear2D; // year mod 100
        property Decade: Word read GetDecade write SetDecade;
        property Year: Word read GetYear write SetYear;
        property Month: Word read GetMonth write SetMonth;
        property Week: Word read GetWeek write SetWeek;
        property Day: Word read GetDay write SetDay;
        property DayOfWeek: Word read GetDayOfWeek write SetDayOfWeek;
        property Hour12: Word read GetHour12 write SetHour12;
        property Hour: Word read GetHour write SetHour;
        property Minute: Word read GetMinute write SetMinute;
        property Second: Word read GetSecond write SetSecond;
        property Millisecond: Word read GetMillisecond write SetMillisecond;
        property AmPm: TAmPm read GetAmPm write SetAmPm;
        
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
    end;
    
function SameDateTime(D, E: TDateTime): Boolean;
function IsNullDateTime(D: TDateTime): Boolean;

implementation

function SameDateTime(D, E: TDateTime): Boolean;
begin
    if IsNullDateTime(D) then Result := IsNullDateTime(E)
    else if IsNullDateTime(E) then Result := False
    else Result := D = E;
end;

function IsNullDateTime(D: TDateTime): Boolean;
begin
    Result := IsNan(D) or IsInfinite(D) or
        (D > SysUtils.MaxDateTime) or (D < SysUtils.MinDateTime);
end;

{ TvqDateTime }

constructor TvqDateTime.Create(ADateTime: TDateTime);
begin
    FMinDateTime := SysUtils.MinDateTime;
    FMaxDateTime := SysUtils.MaxDateTime;
    if IsNullDateTime(ADateTime) then
        FDateTime := NullDateTime
    else
        FDateTime := ADateTime;
end;

procedure TvqDateTime.Assign(Source: TPersistent);
begin
    if (Source is TvqDateTime) and (Source <> Self) then
        SetDateTime(TvqDateTime(Source).DateTime)
    else inherited;
end;

procedure TvqDateTime.Changed; 
begin
    if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TvqDateTime.CheckNullDateTime;
begin
    if IsNullDateTime(FDateTime) then begin
        FDateTime := SysUtils.Now;
        if FDateTime < FMinDateTime then FDateTime := FMinDateTime;
        if FDateTime > FMaxDateTime then FDateTime := FMaxDateTime;
        Changed;
    end;
end;

procedure TvqDateTime.CheckNullDate;
begin
    if IsNullDateTime(FDateTime) then begin
        FDateTime := SysUtils.Date;
        if FDateTime < FMinDateTime then FDateTime := FMinDateTime;
        if FDateTime > FMaxDateTime then FDateTime := FMaxDateTime;
        Changed;
    end;
end;

procedure TvqDateTime.CheckNullTime;
begin
    if IsNullDateTime(FDateTime) then begin
        FDateTime := SysUtils.Now;
        if FDateTime < FMinDateTime then FDateTime := FMinDateTime;
        if FDateTime > FMaxDateTime then FDateTime := FMaxDateTime;
        Changed;
    end;
end;

function TvqDateTime.GetParams(var AYear, AMonth, ADay, AHour, AMinute, ASecond, AMillisecond: Word): Boolean;
begin
    Result := True;
    if IsNullDateTime(FDateTime) then
        Result := False
    else
        DecodeDateTime(FDateTime, AYear, AMonth, ADay, AHour, AMinute, ASecond, AMillisecond);
end;

function TvqDateTime.GetDateParams(var AYear, AMonth, ADay: Word): Boolean;
begin
    Result := True;
    if IsNullDateTime(FDateTime) then
        Result := False
    else
        DecodeDate(FDateTime, AYear, AMonth, ADay);
end;

function TvqDateTime.GetTimeParams(var AHour, AMinute, ASecond, AMillisecond: Word): Boolean;
begin
    Result := True;
    if IsNullDateTime(FDateTime) then
        Result := False
    else
        DecodeTime(FDateTime, AHour, AMinute, ASecond, AMillisecond);
end;

procedure TvqDateTime.SetParams(AYear, AMonth, ADay, AHour, AMinute, ASecond, AMillisecond: Word);
begin
    SetDateTime(EncodeDateTime(AYear, AMonth, ADay, AHour, AMinute, ASecond, AMillisecond));
end;

procedure TvqDateTime.SetDateParams(AYear, AMonth, ADay: Word);
var
    H, N, S, Z: Word;
begin
    DecodeTime(FDateTime, H, N, S, Z);
    SetParams(AYear, AMonth, ADay, H, N, S, Z);
end;

procedure TvqDateTime.SetTimeParams(AHour, AMinute, ASecond, AMillisecond: Word);
var
    Y, M, D: Word;
begin
    DecodeDate(FDateTime, Y, M, D);
    SetParams(Y, M, D, AHour, AMinute, ASecond, AMillisecond);
end;
 
function TvqDateTime.IsNull: Boolean;
begin
    Result := IsNullDateTime(FDateTime);
end;

function TvqDateTime.DateTimeString(Format: string; Settings: TFormatSettings): string;
begin
    DateTimeToString(Result, Format, FDateTime, Settings);
end;

procedure TvqDateTime.OffsetCentury(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);     
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullDate;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncYear(FDateTime, Delta*100))
    else begin
        V := GetCentury;
        L := 100;
        if Full then begin
            if Delta < 0 then V := 1
            else if Delta > 0 then V := L - 1;
        end
        else begin
            Dec(V);
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
            Inc(V);
        end;
        SetCentury(V);
    end;
end;

procedure TvqDateTime.OffsetYear2D(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);      
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullDate;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncYear(FDateTime, Delta))
    else begin
        V := GetYear2D;
        L := 100;
        if Full then begin
            if Delta < 0 then V := 0
            else if Delta > 0 then V := L - 1;
        end
        else begin
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
        end;
        SetYear2D(V);
    end;
end;

procedure TvqDateTime.OffsetDecade(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullDate;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncYear(FDateTime, Delta*10))
    else begin
        V := GetDecade;
        L := 10;
        if Full then begin
            if Delta < 0 then V := 0
            else if Delta > 0 then V := L - 1;
        end
        else begin
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
        end;
        SetDecade(V);
    end;
end;

procedure TvqDateTime.OffsetYear(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);        
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullDate;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncYear(FDateTime, Delta))
    else begin
        V := GetYear;
        L := 9999;
        if Full then begin
            if Delta < 0 then V := 1
            else if Delta > 0 then V := L;
        end
        else begin
            Dec(V);
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
            Inc(V);
        end;
        SetYear(V);
    end;
end;

procedure TvqDateTime.OffsetMonth(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);       
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullDate;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncMonth(FDateTime, Delta))
    else begin
        V := GetMonth;
        L := 12;
        if Full then begin
            if Delta < 0 then V := 1
            else if Delta > 0 then V := L;
        end
        else begin
            Dec(V);
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
            Inc(V);
        end;
        SetMonth(V);
    end;
end;

procedure TvqDateTime.OffsetDay(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);         
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullDate;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncDay(FDateTime, Delta))
    else begin
        V := GetDay;
        L := MonthDays[IsLeapYear(GetYear)][GetMonth];
        if Full then begin
            if Delta < 0 then V := 1
            else if Delta > 0 then V := L;
        end
        else begin
            Dec(V);
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
            Inc(V);
        end;
        SetDay(V);
    end;
end;

procedure TvqDateTime.OffsetWeek(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullDate;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncWeek(FDateTime, Delta))
    else begin
        V := GetWeek;
        L := WeeksInAYear(GetYear);
        if Full then begin
            if Delta < 0 then V := 1
            else if Delta > 0 then V := L;
        end
        else begin
            Dec(V);
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
            Inc(V);
        end;
        SetWeek(V);
    end;
end;

procedure TvqDateTime.OffsetDayOfWeek(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);   
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullDate;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncDay(FDateTime, Delta))
    else begin
        V := GetDayOfWeek;
        L := 7;
        if Full then begin
            if Delta < 0 then V := 1
            else if Delta > 0 then V := L;
        end
        else begin
            Dec(V);
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
            Inc(V);
        end;
        SetDayOfWeek(V);
    end;
end;

procedure TvqDateTime.OffsetHour12(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);      
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullTime;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncHour(FDateTime, Delta))
    else begin
        V := GetHour12;
        L := 12;
        if Full then begin
            if Delta < 0 then V := 1
            else if Delta > 0 then V := L;
        end
        else begin
            Dec(V);
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
            Inc(V);
        end;
        SetHour12(V);
    end;
end;

procedure TvqDateTime.OffsetHour(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);        
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullTime;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncHour(FDateTime, Delta))
    else begin
        V := GetHour;
        L := 24;
        if Full then begin
            if Delta < 0 then V := 0
            else if Delta > 0 then V := L - 1;
        end
        else begin
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
        end;
        SetHour(V);
    end;
end;

procedure TvqDateTime.OffsetMinute(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);      
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullTime;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncMinute(FDateTime, Delta))
    else begin
        V := GetMinute;
        L := 60;
        if Full then begin
            if Delta < 0 then V := 0
            else if Delta > 0 then V := L - 1;
        end
        else begin
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
        end;
        SetMinute(V);
    end;
end;

procedure TvqDateTime.OffsetSecond(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);      
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullTime;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncSecond(FDateTime, Delta))
    else begin
        V := GetSecond;
        L := 60;
        if Full then begin
            if Delta < 0 then V := 0
            else if Delta > 0 then V := L - 1;
        end
        else begin
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
        end;
        SetSecond(V);
    end;
end;

procedure TvqDateTime.OffsetMillisecond(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False); 
var
    V, L: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullTime;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncMillisecond(FDateTime, Delta))
    else begin
        V := GetMillisecond;
        L := 1000;
        if Full then begin
            if Delta < 0 then V := 0
            else if Delta > 0 then V := L - 1;
        end
        else begin
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, L)
            else if V < 0 then V := 0
            else if V >= L then V := L - 1;
        end;
        SetMillisecond(V);
    end;
end;

procedure TvqDateTime.OffsetAmPm(Delta: Integer; Cascade, Wrap: Boolean; Full: Boolean = False);        
var
    V: Integer;
begin
    if Delta = 0 then Exit;
    CheckNullTime;
    if Cascade and (not Wrap) and (not Full) then
        SetDateTime(IncHour(FDateTime, Delta*12))
    else begin
        V := Ord(GetAmPm);
        if Full then begin
            if Delta < 0 then V := 0
            else if Delta > 0 then V := 1;
        end
        else begin
            Inc(V, Delta);
            if Wrap then V := EuclidMod(V, 2)
            else if V < 0 then V := 0
            else if V >= 2 then V := 1;
        end;
        SetAmPm(TAmPm(V));
    end;
end;

function TvqDateTime.GetDate: TDate;                 
begin
    Result := DateOf(FDateTime);
end;

function TvqDateTime.GetTime: TTime;                 
begin
    Result := TimeOf(FDateTime);
end;

function TvqDateTime.GetAmPm: TAmPm;                 
var
    H, N, S, Z: Word;
begin
    if GetTimeParams(H, N, S, Z) then
        Result := TAmPm(H div 12)
    else
        Result := TAmPm(0);
end;

function TvqDateTime.GetWeek: Word;
begin
    if IsNullDateTime(FDateTime) then
        Result := 0
    else
        Result := WeekOf(FDateTime);
end;

function TvqDateTime.GetDay: Word;                   
begin   
    if IsNullDateTime(FDateTime) then
        Result := 0
    else
        Result := DayOf(FDateTime);
end;

function TvqDateTime.GetDayOfWeek: Word;             
begin
    if IsNullDateTime(FDateTime) then
        Result := 0
    else
        Result := SysUtils.DayOfWeek(FDateTime);
end;

function TvqDateTime.GetCentury: Word;               
begin
    if IsNullDateTime(FDateTime) then
        Result := 0
    else
        Result := (GetYear div 10) + 1;
end;

function TvqDateTime.GetYear2D: Word;                
begin
    if IsNullDateTime(FDateTime) then
        Result := 0
    else
        Result := GetYear mod 100;
end;

function TvqDateTime.GetDecade: Word;
begin
    if IsNullDateTime(FDateTime) then
        Result := 0
    else
        Result := (GetYear mod 100) div 10;
end;

function TvqDateTime.GetHour: Word;                  
begin
    if IsNullDateTime(FDateTime) then
        Result := 99
    else
        Result := HourOf(DateTime);
end;

function TvqDateTime.GetHour12: Word;                
begin
    if IsNullDateTime(FDateTime) then
        Result := 99
    else
        Result := HourOf(DateTime) mod 12 + 1;
end;

function TvqDateTime.GetMillisecond: Word;           
begin
    if IsNullDateTime(FDateTime) then
        Result := 999
    else
        Result := MilliSecondOf(DateTime);
end;

function TvqDateTime.GetMinute: Word;                
begin
    if IsNullDateTime(FDateTime) then
        Result := 99
    else
        Result := MinuteOf(DateTime);
end;

function TvqDateTime.GetMonth: Word;                 
begin
    if IsNullDateTime(FDateTime) then
        Result := 0
    else
        Result := MonthOf(DateTime);
end;

function TvqDateTime.GetSecond: Word;                
begin
    if IsNullDateTime(FDateTime) then
        Result := 99
    else
        Result := SecondOf(DateTime);
end;

function TvqDateTime.GetYear: Word;                  
begin
    if IsNullDateTime(FDateTime) then
        Result := 0
    else
        Result := YearOf(DateTime);
end;

procedure TvqDateTime.SetDateTime(Value: TDateTime);
begin
    if not SameDateTime(FDateTime, Value) then begin
        if IsNullDateTime(Value) then
            FDateTime := NullDateTime
        else begin
            if Value < FMinDateTime then Value := FMinDateTime
            else if Value > FMaxDateTime then Value := FMaxDateTime;
            FDateTime := Value;
        end;
        Changed;
    end;
end;

procedure TvqDateTime.SetMinDateTime(Value: TDateTime);
begin
    if not IsNullDateTime(Value) then
        if FMinDateTime <> Value then begin
            FMinDateTime := Value;
            if FMaxDateTime < FMinDateTime then
                FMaxDateTime := FMinDateTime;
            if not IsNullDateTime(FDateTime) then
                if FDateTime < FMinDateTime then begin
                    FDateTime := FMinDateTime;
                    Changed;
                end;
        end;
end;

procedure TvqDateTime.SetMaxDateTime(Value: TDateTime);
begin
    if not IsNullDateTime(Value) then
        if FMaxDateTime <> Value then begin
            FMaxDateTime := Value;
            if FMinDateTime > FMaxDateTime then
                FMinDateTime := FMaxDateTime;
            if not IsNullDateTime(FDateTime) then
                if FDateTime > FMaxDateTime then begin
                    FDateTime := FMaxDateTime;
                    Changed;
                end;
        end;
end;

procedure TvqDateTime.SetDate(Value: TDate);
begin
    if IsNullDateTime(Value) then
        SetDateTime(NullDateTime)
    else if IsNullDateTime(FDateTime) then
        SetDateTime(Int(Value))
    else
        SetDateTime(ComposeDateTime(Value, FDateTime));
end;

procedure TvqDateTime.SetTime(Value: TTime);     
begin
    if IsNullDateTime(Value) then
        SetDateTime(NullDateTime)
    else if IsNullDateTime(FDateTime) then
        SetDateTime(ComposeDateTime(Max(Min(SysUtils.Date, MaxDateTime), MinDateTime), Value))
    else
        SetDateTime(ComposeDateTime(FDateTime, Value));
end;

procedure TvqDateTime.SetAmPm(Value: TAmPm);         
begin
    CheckNullTime;
    SetHour(GetHour12 - 1 + Ord(Value)*12);
end;

procedure TvqDateTime.SetWeek(Value: Word);
var
    Y, M, D, DoW: Word;
    ADateTime, ATime: TDateTime;
begin
    if IsNullDateTime(FDateTime) then begin
        ADateTime := SysUtils.Date;
        if ADateTime < FMinDateTime then ADateTime := FMinDateTime;
        if ADateTime > FMaxDateTime then ADateTime := FMaxDateTime;
        DecodeDateFully(ADateTime, Y, M, D, DoW);
        ATime := TimeOf(ADateTime);
    end
    else begin
        DecodeDateFully(FDateTime, Y, M, D, DoW);
        ATime := GetTime;
    end;
    if TryEncodeDateWeek(Y, Value, ADateTime, DoW) then
        SetDateTime(ComposeDateTime(ADateTime, ATime));
end;

procedure TvqDateTime.SetDay(Value: Word);           
var
    ADateTime: TDateTime;
    Y, M, D: Word;
begin
    if IsNullDateTime(FDateTime) then begin
        ADateTime := SysUtils.Date;
        if ADateTime < FMinDateTime then ADateTime := FMinDateTime;
        if ADateTime > FMaxDateTime then ADateTime := FMaxDateTime;
        DecodeDate(ADateTime, Y, M, D);
        
        if (Value > 0) and (Value <= MonthDays[IsLeapYear(Y)][M]) then begin
            FDateTime := ADateTime;
            Changed;
            SetDateParams(Y, M, Value);
        end;
    end
    else begin
        GetDateParams(Y, M, D);
        if (Value > 0) and (Value <= MonthDays[IsLeapYear(Y)][M]) then
            SetDateParams(Y, M, Value);
    end;
end;

procedure TvqDateTime.SetDayOfWeek(Value: Word);     
var
    ADate: TDateTime;
begin
    if (Value > 0) and (Value <= 7) then begin
        CheckNullDate;  
        ADate := StartOfTheWeek(FDateTime);
        IncDay(ADate, Value - 1);
        SetDate(ADate);
    end;
end;

procedure TvqDateTime.SetYear2D(Value: Word); 
begin
    if (Value >= 0) and (Value < 100) then begin
        CheckNullDate;  
        SetYear(GetCentury*100 + Value);
    end;
end;

procedure TvqDateTime.SetCentury(Value: Word);
var
    CY: Word;
begin
    if (Value >= 0) and (Value <= 100) then begin
        CheckNullDate;  
        CY := GetYear mod 100;
        if Value > 0 then Dec(Value);
        SetYear(CY + Value*100);
    end;
end;

procedure TvqDateTime.SetDecade(Value: Word);
var
    Y: Word;
begin
    if (Value >= 0) and (Value < 10) then begin
        CheckNullDate;  
        Y := GetYear;
        SetYear((Y div 100)*100 + Value*10 + Y mod 10);
    end;
end;

procedure TvqDateTime.SetHour(Value: Word);          
var
    H, N, S, Z: Word;
begin
    if (Value >= 0) and (Value < 24) then begin
        CheckNullTime;  
        GetTimeParams(H, N, S, Z);
        SetTimeParams(Value, N, S, Z);
    end;
end;

procedure TvqDateTime.SetHour12(Value: Word);        
begin
    if (Value >= 1) and (Value <= 12) then begin
        CheckNullTime;  
        SetHour(Value - 1 + Word(GetAmPm)*12);
    end;
end;

procedure TvqDateTime.SetMillisecond(Value: Word);   
var
    H, N, S, Z: Word;
begin
    if (Value >= 0) and (Value < 1000) then begin
        CheckNullTime;  
        GetTimeParams(H, N, S, Z);
        SetTimeParams(H, N, S, Value);
    end;
end;

procedure TvqDateTime.SetMinute(Value: Word);        
var
    H, N, S, Z: Word;
begin
    if (Value >= 0) and (Value < 60) then begin
        CheckNullTime;  
        GetTimeParams(H, N, S, Z);
        SetTimeParams(H, Value, S, Z);
    end;
end;

procedure TvqDateTime.SetMonth(Value: Word);         
var
    Y, M, D: Word;
begin
    if (Value >= 1) and (Value <= 12) then begin
        CheckNullDate;  
        GetDateParams(Y, M, D);
        if MonthDays[IsLeapYear(Y)][Value] > D then
            D := MonthDays[IsLeapYear(Y)][Value];
        SetDateParams(Y, Value, D);
    end;
end;

procedure TvqDateTime.SetSecond(Value: Word);        
var
    H, N, S, Z: Word;
begin
    if (Value >= 0) and (Value < 60) then begin
        CheckNullTime;  
        GetTimeParams(H, N, S, Z);
        SetTimeParams(H, N, Value, Z);
    end;
end;

procedure TvqDateTime.SetYear(Value: Word);          
var
    Y, M, D: Word;
begin
    if (Value >= 1) and (Value <= 9999) then begin
        CheckNullDate;  
        GetDateParams(Y, M, D);
        if MonthDays[IsLeapYear(Value)][M] > D then
            D := MonthDays[IsLeapYear(Value)][M];
        SetDateParams(Value, M, D);
    end;
end;

end.
