// License: modified LGPL
// See COPYING.modifiedLGPL.txt for details

{ vqTLDArray.inc included in vqEdition.pas }

{ TvqTLDArray }

const GROWSIZE = 8;

constructor TvqTLDArray.Create;
begin
    Initialize;
end;

destructor TvqTLDArray.Destroy;
begin
    inherited;
end;

procedure TvqTLDArray.UpdateRoom;
var
    L: Integer;
begin
    L := ((FCount div GROWSIZE) + 1)*GROWSIZE;
    if L <> Length(FDomains) then begin
        SetLength(FDomains, L);
        SetLength(FTypes, L);
    end;
end;

procedure TvqTLDArray.AddTLD(S: string; T: Byte);
begin //! mejorar con reordenamiento para busqueda binaria
    UpdateRoom;
    FDomains[FCount] := S;
    FTypes[FCount] := T;
    Inc(FCount);
end;

procedure TvqTLDArray.RemoveTLD(S: string);
var
    I, K: Integer;
begin
    I := FindTLD(S);
    for K := I + 1 to FCount - 1 do begin
        FDomains[K - 1] := FDomains[K];
        FTypes[K - 1] := FTypes[K];
    end;
    Dec(FCount);
    UpdateRoom;
end;

function TvqTLDArray.FindTLD(S: string): Integer;
var
    I: Integer;
begin //! mejorar con busqueda binaria
    Result := -1;
    for I := 0 to Count - 1 do
        if FDomains[I] = S then begin
            Result := I;
            Break;
        end;
end;

function TvqTLDArray.IsTLD(S: string): Boolean;
begin
    Result := FindTLD(S) <> vqInvalidValue;
end;

function TvqTLDArray.IsTLD(S: string; T: Byte): Boolean;
var
    I: Integer;
begin
    I := FindTLD(S);
    Result := (I <> vqInvalidValue) and (FTypes[I] = T);
end;

function TvqTLDArray.DomainType(S: string): Byte;
var
    I: Integer;
begin
    I := FindTLD(S);
    if I <> vqInvalidValue then Result := FTypes[I]
    else Result := 0;
end;

function TvqTLDArray.GetItem(I: Integer): string;
begin
    if (I >= 0) and (I < Count) then Result := FDomains[I]
    else Result := '';
end;

procedure TvqTLDArray.SetItem(I: Integer; Value: string);
begin
    if (I >= 0) and (I < Count) then begin
        FDomains[I] := Value;
    end;
end;

procedure TvqTLDArray.Initialize;
begin
    FCount := 320;
    SetLength(FDomains, FCount + 1);
    SetLength(FTypes, FCount + 1);
    
    // most important TLDs (may be mistakes)
    FDomains[000] := 'arpa'            ; FTypes[000] := INFRASTRUCTURE_TLD;
    FDomains[001] := 'aero'            ; FTypes[001] := SPONSORED_TLD;
    FDomains[002] := 'asia'            ; FTypes[002] := SPONSORED_TLD;
    FDomains[003] := 'cat'             ; FTypes[003] := SPONSORED_TLD;
    FDomains[004] := 'coop'            ; FTypes[004] := SPONSORED_TLD;
    FDomains[005] := 'edu'             ; FTypes[005] := SPONSORED_TLD;
    FDomains[006] := 'gov'             ; FTypes[006] := SPONSORED_TLD;
    FDomains[007] := 'int'             ; FTypes[007] := SPONSORED_TLD;
    FDomains[008] := 'jobs'            ; FTypes[008] := SPONSORED_TLD;
    FDomains[009] := 'mil'             ; FTypes[009] := SPONSORED_TLD;
    FDomains[010] := 'museum'          ; FTypes[010] := SPONSORED_TLD;
    FDomains[011] := 'post'            ; FTypes[011] := SPONSORED_TLD;
    FDomains[012] := 'tel'             ; FTypes[012] := SPONSORED_TLD;
    FDomains[013] := 'travel'          ; FTypes[013] := SPONSORED_TLD;
    FDomains[014] := 'xxx'             ; FTypes[014] := SPONSORED_TLD;
    FDomains[015] := 'biz'             ; FTypes[015] := GENERIC_RESTRICTED_TLD;
    FDomains[016] := 'name'            ; FTypes[016] := GENERIC_RESTRICTED_TLD;
    FDomains[017] := 'pro'             ; FTypes[017] := GENERIC_RESTRICTED_TLD;
    FDomains[018] := 'amsterdam'       ; FTypes[018] := GENERIC_TLD;
    FDomains[019] := 'apple'           ; FTypes[019] := GENERIC_TLD;
    FDomains[020] := 'bar'             ; FTypes[020] := GENERIC_TLD;
    FDomains[021] := 'bcn'             ; FTypes[021] := GENERIC_TLD;
    FDomains[022] := 'berlin'          ; FTypes[022] := GENERIC_TLD;
    FDomains[023] := 'bible'           ; FTypes[023] := GENERIC_TLD;
    FDomains[024] := 'brussels'        ; FTypes[024] := GENERIC_TLD;
    FDomains[025] := 'bzh'             ; FTypes[025] := GENERIC_TLD;
    FDomains[026] := 'cancerresearch'  ; FTypes[026] := GENERIC_TLD;
    FDomains[027] := 'cern'            ; FTypes[027] := GENERIC_TLD;
    FDomains[028] := 'cloud'           ; FTypes[028] := GENERIC_TLD;
    FDomains[029] := 'club'            ; FTypes[029] := GENERIC_TLD;
    FDomains[030] := 'com'             ; FTypes[030] := GENERIC_TLD;
    FDomains[031] := 'cymru'           ; FTypes[031] := GENERIC_TLD;
    FDomains[032] := 'cyou'            ; FTypes[032] := GENERIC_TLD;
    FDomains[033] := 'desi'            ; FTypes[033] := GENERIC_TLD;
    FDomains[034] := 'design'          ; FTypes[034] := GENERIC_TLD;
    FDomains[035] := 'domains'         ; FTypes[035] := GENERIC_TLD;
    FDomains[036] := 'eus'             ; FTypes[036] := GENERIC_TLD;
    FDomains[037] := 'frl'             ; FTypes[037] := GENERIC_TLD;
    FDomains[038] := 'gal'             ; FTypes[038] := GENERIC_TLD;
    FDomains[039] := 'gdn'             ; FTypes[039] := GENERIC_TLD;
    FDomains[040] := 'global'          ; FTypes[040] := GENERIC_TLD;
    FDomains[041] := 'hamburg'         ; FTypes[041] := GENERIC_TLD;
    FDomains[042] := 'hiv'             ; FTypes[042] := GENERIC_TLD;
    FDomains[043] := 'info'            ; FTypes[043] := GENERIC_TLD;
    FDomains[044] := 'istanbul'        ; FTypes[044] := GENERIC_TLD;
    FDomains[045] := 'kiwi'            ; FTypes[045] := GENERIC_TLD;
    FDomains[046] := 'krd'             ; FTypes[046] := GENERIC_TLD;
    FDomains[047] := 'lat'             ; FTypes[047] := GENERIC_TLD;
    FDomains[048] := 'lgbt'            ; FTypes[048] := GENERIC_TLD;
    FDomains[049] := 'london'          ; FTypes[049] := GENERIC_TLD;
    FDomains[050] := 'mobi'            ; FTypes[050] := GENERIC_TLD;
    FDomains[051] := 'moe'             ; FTypes[051] := GENERIC_TLD;
    FDomains[052] := 'net'             ; FTypes[052] := GENERIC_TLD;
    FDomains[053] := 'ngo'             ; FTypes[053] := GENERIC_TLD;
    FDomains[054] := 'nyc'             ; FTypes[054] := GENERIC_TLD;
    FDomains[055] := 'one'             ; FTypes[055] := GENERIC_TLD;
    FDomains[056] := 'ong'             ; FTypes[056] := GENERIC_TLD;
    FDomains[057] := 'online'          ; FTypes[057] := GENERIC_TLD;
    FDomains[058] := 'ooo'             ; FTypes[058] := GENERIC_TLD;
    FDomains[059] := 'org'             ; FTypes[059] := GENERIC_TLD;
    FDomains[060] := 'ovh'             ; FTypes[060] := GENERIC_TLD;
    FDomains[061] := 'paris'           ; FTypes[061] := GENERIC_TLD;
    FDomains[062] := 'quebec'          ; FTypes[062] := GENERIC_TLD;
    FDomains[063] := 'rio'             ; FTypes[063] := GENERIC_TLD;
    FDomains[064] := 'saarland'        ; FTypes[064] := GENERIC_TLD;
    FDomains[065] := 'scot'            ; FTypes[065] := GENERIC_TLD;
    FDomains[066] := 'tech'            ; FTypes[066] := GENERIC_TLD;
    FDomains[067] := 'tokyo'           ; FTypes[067] := GENERIC_TLD;
    FDomains[068] := 'top'             ; FTypes[068] := GENERIC_TLD;
    FDomains[069] := 'vlaanderen'      ; FTypes[069] := GENERIC_TLD;
    FDomains[070] := 'wales'           ; FTypes[070] := GENERIC_TLD;
    FDomains[071] := 'xyz'             ; FTypes[071] := GENERIC_TLD;
    FDomains[072] := 'ac'              ; FTypes[072] := COUNTRY_CODE_TLD;
    FDomains[073] := 'ad'              ; FTypes[073] := COUNTRY_CODE_TLD;
    FDomains[074] := 'ae'              ; FTypes[074] := COUNTRY_CODE_TLD;
    FDomains[075] := 'af'              ; FTypes[075] := COUNTRY_CODE_TLD;
    FDomains[076] := 'ag'              ; FTypes[076] := COUNTRY_CODE_TLD;
    FDomains[077] := 'ai'              ; FTypes[077] := COUNTRY_CODE_TLD;
    FDomains[078] := 'al'              ; FTypes[078] := COUNTRY_CODE_TLD;
    FDomains[079] := 'am'              ; FTypes[079] := COUNTRY_CODE_TLD;
    FDomains[080] := 'ao'              ; FTypes[080] := COUNTRY_CODE_TLD;
    FDomains[081] := 'aq'              ; FTypes[081] := COUNTRY_CODE_TLD;
    FDomains[082] := 'ar'              ; FTypes[082] := COUNTRY_CODE_TLD;
    FDomains[083] := 'as'              ; FTypes[083] := COUNTRY_CODE_TLD;
    FDomains[084] := 'at'              ; FTypes[084] := COUNTRY_CODE_TLD;
    FDomains[085] := 'au'              ; FTypes[085] := COUNTRY_CODE_TLD;
    FDomains[086] := 'aw'              ; FTypes[086] := COUNTRY_CODE_TLD;
    FDomains[087] := 'ax'              ; FTypes[087] := COUNTRY_CODE_TLD;
    FDomains[088] := 'az'              ; FTypes[088] := COUNTRY_CODE_TLD;
    FDomains[089] := 'ba'              ; FTypes[089] := COUNTRY_CODE_TLD;
    FDomains[090] := 'bb'              ; FTypes[090] := COUNTRY_CODE_TLD;
    FDomains[091] := 'bd'              ; FTypes[091] := COUNTRY_CODE_TLD;
    FDomains[092] := 'be'              ; FTypes[092] := COUNTRY_CODE_TLD;
    FDomains[093] := 'bf'              ; FTypes[093] := COUNTRY_CODE_TLD;
    FDomains[094] := 'bg'              ; FTypes[094] := COUNTRY_CODE_TLD;
    FDomains[095] := 'bh'              ; FTypes[095] := COUNTRY_CODE_TLD;
    FDomains[096] := 'bi'              ; FTypes[096] := COUNTRY_CODE_TLD;
    FDomains[097] := 'bj'              ; FTypes[097] := COUNTRY_CODE_TLD;
    FDomains[098] := 'bm'              ; FTypes[098] := COUNTRY_CODE_TLD;
    FDomains[099] := 'bn'              ; FTypes[099] := COUNTRY_CODE_TLD;
    FDomains[100] := 'bo'              ; FTypes[100] := COUNTRY_CODE_TLD;
    FDomains[101] := 'br'              ; FTypes[101] := COUNTRY_CODE_TLD;
    FDomains[102] := 'bs'              ; FTypes[102] := COUNTRY_CODE_TLD;
    FDomains[103] := 'bt'              ; FTypes[103] := COUNTRY_CODE_TLD;
    FDomains[104] := 'bv'              ; FTypes[104] := COUNTRY_CODE_TLD;
    FDomains[105] := 'bw'              ; FTypes[105] := COUNTRY_CODE_TLD;
    FDomains[106] := 'by'              ; FTypes[106] := COUNTRY_CODE_TLD;
    FDomains[107] := 'bz'              ; FTypes[107] := COUNTRY_CODE_TLD;
    FDomains[108] := 'ca'              ; FTypes[108] := COUNTRY_CODE_TLD;
    FDomains[109] := 'cc'              ; FTypes[109] := COUNTRY_CODE_TLD;
    FDomains[110] := 'cd'              ; FTypes[110] := COUNTRY_CODE_TLD;
    FDomains[111] := 'cf'              ; FTypes[111] := COUNTRY_CODE_TLD;
    FDomains[112] := 'cg'              ; FTypes[112] := COUNTRY_CODE_TLD;
    FDomains[113] := 'ch'              ; FTypes[113] := COUNTRY_CODE_TLD;
    FDomains[114] := 'ci'              ; FTypes[114] := COUNTRY_CODE_TLD;
    FDomains[115] := 'ck'              ; FTypes[115] := COUNTRY_CODE_TLD;
    FDomains[116] := 'cl'              ; FTypes[116] := COUNTRY_CODE_TLD;
    FDomains[117] := 'cm'              ; FTypes[117] := COUNTRY_CODE_TLD;
    FDomains[118] := 'cn'              ; FTypes[118] := COUNTRY_CODE_TLD;
    FDomains[119] := 'co'              ; FTypes[119] := COUNTRY_CODE_TLD;
    FDomains[120] := 'cr'              ; FTypes[120] := COUNTRY_CODE_TLD;
    FDomains[121] := 'cu'              ; FTypes[121] := COUNTRY_CODE_TLD;
    FDomains[122] := 'cv'              ; FTypes[122] := COUNTRY_CODE_TLD;
    FDomains[123] := 'cw'              ; FTypes[123] := COUNTRY_CODE_TLD;
    FDomains[124] := 'cx'              ; FTypes[124] := COUNTRY_CODE_TLD;
    FDomains[125] := 'cy'              ; FTypes[125] := COUNTRY_CODE_TLD;
    FDomains[126] := 'cz'              ; FTypes[126] := COUNTRY_CODE_TLD;
    FDomains[127] := 'de'              ; FTypes[127] := COUNTRY_CODE_TLD;
    FDomains[128] := 'dj'              ; FTypes[128] := COUNTRY_CODE_TLD;
    FDomains[129] := 'dk'              ; FTypes[129] := COUNTRY_CODE_TLD;
    FDomains[130] := 'dm'              ; FTypes[130] := COUNTRY_CODE_TLD;
    FDomains[131] := 'do'              ; FTypes[131] := COUNTRY_CODE_TLD;
    FDomains[132] := 'dz'              ; FTypes[132] := COUNTRY_CODE_TLD;
    FDomains[133] := 'ec'              ; FTypes[133] := COUNTRY_CODE_TLD;
    FDomains[134] := 'ee'              ; FTypes[134] := COUNTRY_CODE_TLD;
    FDomains[135] := 'eg'              ; FTypes[135] := COUNTRY_CODE_TLD;
    FDomains[136] := 'er'              ; FTypes[136] := COUNTRY_CODE_TLD;
    FDomains[137] := 'es'              ; FTypes[137] := COUNTRY_CODE_TLD;
    FDomains[138] := 'et'              ; FTypes[138] := COUNTRY_CODE_TLD;
    FDomains[139] := 'eu'              ; FTypes[139] := COUNTRY_CODE_TLD;
    FDomains[140] := 'fi'              ; FTypes[140] := COUNTRY_CODE_TLD;
    FDomains[141] := 'fj'              ; FTypes[141] := COUNTRY_CODE_TLD;
    FDomains[142] := 'fk'              ; FTypes[142] := COUNTRY_CODE_TLD;
    FDomains[143] := 'fm'              ; FTypes[143] := COUNTRY_CODE_TLD;
    FDomains[144] := 'fo'              ; FTypes[144] := COUNTRY_CODE_TLD;
    FDomains[145] := 'fr'              ; FTypes[145] := COUNTRY_CODE_TLD;
    FDomains[146] := 'ga'              ; FTypes[146] := COUNTRY_CODE_TLD;
    FDomains[147] := 'gb'              ; FTypes[147] := COUNTRY_CODE_TLD;
    FDomains[148] := 'gd'              ; FTypes[148] := COUNTRY_CODE_TLD;
    FDomains[149] := 'ge'              ; FTypes[149] := COUNTRY_CODE_TLD;
    FDomains[150] := 'gf'              ; FTypes[150] := COUNTRY_CODE_TLD;
    FDomains[151] := 'gg'              ; FTypes[151] := COUNTRY_CODE_TLD;
    FDomains[152] := 'gh'              ; FTypes[152] := COUNTRY_CODE_TLD;
    FDomains[153] := 'gi'              ; FTypes[153] := COUNTRY_CODE_TLD;
    FDomains[154] := 'gl'              ; FTypes[154] := COUNTRY_CODE_TLD;
    FDomains[155] := 'gm'              ; FTypes[155] := COUNTRY_CODE_TLD;
    FDomains[156] := 'gn'              ; FTypes[156] := COUNTRY_CODE_TLD;
    FDomains[157] := 'gp'              ; FTypes[157] := COUNTRY_CODE_TLD;
    FDomains[158] := 'gq'              ; FTypes[158] := COUNTRY_CODE_TLD;
    FDomains[159] := 'gr'              ; FTypes[159] := COUNTRY_CODE_TLD;
    FDomains[160] := 'gs'              ; FTypes[160] := COUNTRY_CODE_TLD;
    FDomains[161] := 'gt'              ; FTypes[161] := COUNTRY_CODE_TLD;
    FDomains[162] := 'gu'              ; FTypes[162] := COUNTRY_CODE_TLD;
    FDomains[163] := 'gw'              ; FTypes[163] := COUNTRY_CODE_TLD;
    FDomains[164] := 'gy'              ; FTypes[164] := COUNTRY_CODE_TLD;
    FDomains[165] := 'hk'              ; FTypes[165] := COUNTRY_CODE_TLD;
    FDomains[166] := 'hm'              ; FTypes[166] := COUNTRY_CODE_TLD;
    FDomains[167] := 'hn'              ; FTypes[167] := COUNTRY_CODE_TLD;
    FDomains[168] := 'hr'              ; FTypes[168] := COUNTRY_CODE_TLD;
    FDomains[169] := 'ht'              ; FTypes[169] := COUNTRY_CODE_TLD;
    FDomains[170] := 'hu'              ; FTypes[170] := COUNTRY_CODE_TLD;
    FDomains[171] := 'id'              ; FTypes[171] := COUNTRY_CODE_TLD;
    FDomains[172] := 'ie'              ; FTypes[172] := COUNTRY_CODE_TLD;
    FDomains[173] := 'il'              ; FTypes[173] := COUNTRY_CODE_TLD;
    FDomains[174] := 'im'              ; FTypes[174] := COUNTRY_CODE_TLD;
    FDomains[175] := 'in'              ; FTypes[175] := COUNTRY_CODE_TLD;
    FDomains[176] := 'io'              ; FTypes[176] := COUNTRY_CODE_TLD;
    FDomains[177] := 'iq'              ; FTypes[177] := COUNTRY_CODE_TLD;
    FDomains[178] := 'ir'              ; FTypes[178] := COUNTRY_CODE_TLD;
    FDomains[179] := 'is'              ; FTypes[179] := COUNTRY_CODE_TLD;
    FDomains[180] := 'it'              ; FTypes[180] := COUNTRY_CODE_TLD;
    FDomains[181] := 'je'              ; FTypes[181] := COUNTRY_CODE_TLD;
    FDomains[182] := 'jm'              ; FTypes[182] := COUNTRY_CODE_TLD;
    FDomains[183] := 'jo'              ; FTypes[183] := COUNTRY_CODE_TLD;
    FDomains[184] := 'jp'              ; FTypes[184] := COUNTRY_CODE_TLD;
    FDomains[185] := 'ke'              ; FTypes[185] := COUNTRY_CODE_TLD;
    FDomains[186] := 'kg'              ; FTypes[186] := COUNTRY_CODE_TLD;
    FDomains[187] := 'kh'              ; FTypes[187] := COUNTRY_CODE_TLD;
    FDomains[188] := 'ki'              ; FTypes[188] := COUNTRY_CODE_TLD;
    FDomains[189] := 'km'              ; FTypes[189] := COUNTRY_CODE_TLD;
    FDomains[190] := 'kn'              ; FTypes[190] := COUNTRY_CODE_TLD;
    FDomains[191] := 'kp'              ; FTypes[191] := COUNTRY_CODE_TLD;
    FDomains[192] := 'kr'              ; FTypes[192] := COUNTRY_CODE_TLD;
    FDomains[193] := 'kw'              ; FTypes[193] := COUNTRY_CODE_TLD;
    FDomains[194] := 'ky'              ; FTypes[194] := COUNTRY_CODE_TLD;
    FDomains[195] := 'kz'              ; FTypes[195] := COUNTRY_CODE_TLD;
    FDomains[196] := 'la'              ; FTypes[196] := COUNTRY_CODE_TLD;
    FDomains[197] := 'lb'              ; FTypes[197] := COUNTRY_CODE_TLD;
    FDomains[198] := 'lc'              ; FTypes[198] := COUNTRY_CODE_TLD;
    FDomains[199] := 'li'              ; FTypes[199] := COUNTRY_CODE_TLD;
    FDomains[200] := 'lk'              ; FTypes[200] := COUNTRY_CODE_TLD;
    FDomains[201] := 'lr'              ; FTypes[201] := COUNTRY_CODE_TLD;
    FDomains[202] := 'ls'              ; FTypes[202] := COUNTRY_CODE_TLD;
    FDomains[203] := 'lt'              ; FTypes[203] := COUNTRY_CODE_TLD;
    FDomains[204] := 'lu'              ; FTypes[204] := COUNTRY_CODE_TLD;
    FDomains[205] := 'lv'              ; FTypes[205] := COUNTRY_CODE_TLD;
    FDomains[206] := 'ly'              ; FTypes[206] := COUNTRY_CODE_TLD;
    FDomains[207] := 'ma'              ; FTypes[207] := COUNTRY_CODE_TLD;
    FDomains[208] := 'mc'              ; FTypes[208] := COUNTRY_CODE_TLD;
    FDomains[209] := 'md'              ; FTypes[209] := COUNTRY_CODE_TLD;
    FDomains[210] := 'me'              ; FTypes[210] := COUNTRY_CODE_TLD;
    FDomains[211] := 'mg'              ; FTypes[211] := COUNTRY_CODE_TLD;
    FDomains[212] := 'mh'              ; FTypes[212] := COUNTRY_CODE_TLD;
    FDomains[213] := 'mk'              ; FTypes[213] := COUNTRY_CODE_TLD;
    FDomains[214] := 'ml'              ; FTypes[214] := COUNTRY_CODE_TLD;
    FDomains[215] := 'mm'              ; FTypes[215] := COUNTRY_CODE_TLD;
    FDomains[216] := 'mn'              ; FTypes[216] := COUNTRY_CODE_TLD;
    FDomains[217] := 'mo'              ; FTypes[217] := COUNTRY_CODE_TLD;
    FDomains[218] := 'mp'              ; FTypes[218] := COUNTRY_CODE_TLD;
    FDomains[219] := 'mq'              ; FTypes[219] := COUNTRY_CODE_TLD;
    FDomains[220] := 'mr'              ; FTypes[220] := COUNTRY_CODE_TLD;
    FDomains[221] := 'ms'              ; FTypes[221] := COUNTRY_CODE_TLD;
    FDomains[222] := 'mt'              ; FTypes[222] := COUNTRY_CODE_TLD;
    FDomains[223] := 'mu'              ; FTypes[223] := COUNTRY_CODE_TLD;
    FDomains[224] := 'mv'              ; FTypes[224] := COUNTRY_CODE_TLD;
    FDomains[225] := 'mw'              ; FTypes[225] := COUNTRY_CODE_TLD;
    FDomains[226] := 'mx'              ; FTypes[226] := COUNTRY_CODE_TLD;
    FDomains[227] := 'my'              ; FTypes[227] := COUNTRY_CODE_TLD;
    FDomains[228] := 'mz'              ; FTypes[228] := COUNTRY_CODE_TLD;
    FDomains[229] := 'na'              ; FTypes[229] := COUNTRY_CODE_TLD;
    FDomains[230] := 'nc'              ; FTypes[230] := COUNTRY_CODE_TLD;
    FDomains[231] := 'ne'              ; FTypes[231] := COUNTRY_CODE_TLD;
    FDomains[232] := 'nf'              ; FTypes[232] := COUNTRY_CODE_TLD;
    FDomains[233] := 'ng'              ; FTypes[233] := COUNTRY_CODE_TLD;
    FDomains[234] := 'ni'              ; FTypes[234] := COUNTRY_CODE_TLD;
    FDomains[235] := 'nl'              ; FTypes[235] := COUNTRY_CODE_TLD;
    FDomains[236] := 'no'              ; FTypes[236] := COUNTRY_CODE_TLD;
    FDomains[237] := 'np'              ; FTypes[237] := COUNTRY_CODE_TLD;
    FDomains[238] := 'nr'              ; FTypes[238] := COUNTRY_CODE_TLD;
    FDomains[239] := 'nu'              ; FTypes[239] := COUNTRY_CODE_TLD;
    FDomains[240] := 'nz'              ; FTypes[240] := COUNTRY_CODE_TLD;
    FDomains[241] := 'om'              ; FTypes[241] := COUNTRY_CODE_TLD;
    FDomains[242] := 'pa'              ; FTypes[242] := COUNTRY_CODE_TLD;
    FDomains[243] := 'pe'              ; FTypes[243] := COUNTRY_CODE_TLD;
    FDomains[244] := 'pf'              ; FTypes[244] := COUNTRY_CODE_TLD;
    FDomains[245] := 'pg'              ; FTypes[245] := COUNTRY_CODE_TLD;
    FDomains[246] := 'ph'              ; FTypes[246] := COUNTRY_CODE_TLD;
    FDomains[247] := 'pk'              ; FTypes[247] := COUNTRY_CODE_TLD;
    FDomains[248] := 'pl'              ; FTypes[248] := COUNTRY_CODE_TLD;
    FDomains[249] := 'pm'              ; FTypes[249] := COUNTRY_CODE_TLD;
    FDomains[250] := 'pn'              ; FTypes[250] := COUNTRY_CODE_TLD;
    FDomains[251] := 'pr'              ; FTypes[251] := COUNTRY_CODE_TLD;
    FDomains[252] := 'ps'              ; FTypes[252] := COUNTRY_CODE_TLD;
    FDomains[253] := 'pt'              ; FTypes[253] := COUNTRY_CODE_TLD;
    FDomains[254] := 'pw'              ; FTypes[254] := COUNTRY_CODE_TLD;
    FDomains[255] := 'py'              ; FTypes[255] := COUNTRY_CODE_TLD;
    FDomains[256] := 'qa'              ; FTypes[256] := COUNTRY_CODE_TLD;
    FDomains[257] := 're'              ; FTypes[257] := COUNTRY_CODE_TLD;
    FDomains[258] := 'ro'              ; FTypes[258] := COUNTRY_CODE_TLD;
    FDomains[259] := 'rs'              ; FTypes[259] := COUNTRY_CODE_TLD;
    FDomains[260] := 'ru'              ; FTypes[260] := COUNTRY_CODE_TLD;
    FDomains[261] := 'rw'              ; FTypes[261] := COUNTRY_CODE_TLD;
    FDomains[262] := 'sa'              ; FTypes[262] := COUNTRY_CODE_TLD;
    FDomains[263] := 'sb'              ; FTypes[263] := COUNTRY_CODE_TLD;
    FDomains[264] := 'sc'              ; FTypes[264] := COUNTRY_CODE_TLD;
    FDomains[265] := 'sd'              ; FTypes[265] := COUNTRY_CODE_TLD;
    FDomains[266] := 'se'              ; FTypes[266] := COUNTRY_CODE_TLD;
    FDomains[267] := 'sg'              ; FTypes[267] := COUNTRY_CODE_TLD;
    FDomains[268] := 'sh'              ; FTypes[268] := COUNTRY_CODE_TLD;
    FDomains[269] := 'si'              ; FTypes[269] := COUNTRY_CODE_TLD;
    FDomains[270] := 'sj'              ; FTypes[270] := COUNTRY_CODE_TLD;
    FDomains[271] := 'sk'              ; FTypes[271] := COUNTRY_CODE_TLD;
    FDomains[272] := 'sl'              ; FTypes[272] := COUNTRY_CODE_TLD;
    FDomains[273] := 'sm'              ; FTypes[273] := COUNTRY_CODE_TLD;
    FDomains[274] := 'sn'              ; FTypes[274] := COUNTRY_CODE_TLD;
    FDomains[275] := 'so'              ; FTypes[275] := COUNTRY_CODE_TLD;
    FDomains[276] := 'sr'              ; FTypes[276] := COUNTRY_CODE_TLD;
    FDomains[277] := 'ss'              ; FTypes[277] := COUNTRY_CODE_TLD;
    FDomains[278] := 'st'              ; FTypes[278] := COUNTRY_CODE_TLD;
    FDomains[279] := 'su'              ; FTypes[279] := COUNTRY_CODE_TLD;
    FDomains[280] := 'sv'              ; FTypes[280] := COUNTRY_CODE_TLD;
    FDomains[281] := 'sx'              ; FTypes[281] := COUNTRY_CODE_TLD;
    FDomains[282] := 'sy'              ; FTypes[282] := COUNTRY_CODE_TLD;
    FDomains[283] := 'sz'              ; FTypes[283] := COUNTRY_CODE_TLD;
    FDomains[284] := 'tc'              ; FTypes[284] := COUNTRY_CODE_TLD;
    FDomains[285] := 'td'              ; FTypes[285] := COUNTRY_CODE_TLD;
    FDomains[286] := 'tf'              ; FTypes[286] := COUNTRY_CODE_TLD;
    FDomains[287] := 'tg'              ; FTypes[287] := COUNTRY_CODE_TLD;
    FDomains[288] := 'th'              ; FTypes[288] := COUNTRY_CODE_TLD;
    FDomains[289] := 'tj'              ; FTypes[289] := COUNTRY_CODE_TLD;
    FDomains[290] := 'tk'              ; FTypes[290] := COUNTRY_CODE_TLD;
    FDomains[291] := 'tl'              ; FTypes[291] := COUNTRY_CODE_TLD;
    FDomains[292] := 'tm'              ; FTypes[292] := COUNTRY_CODE_TLD;
    FDomains[293] := 'tn'              ; FTypes[293] := COUNTRY_CODE_TLD;
    FDomains[294] := 'to'              ; FTypes[294] := COUNTRY_CODE_TLD;
    FDomains[295] := 'tr'              ; FTypes[295] := COUNTRY_CODE_TLD;
    FDomains[296] := 'tt'              ; FTypes[296] := COUNTRY_CODE_TLD;
    FDomains[297] := 'tv'              ; FTypes[297] := COUNTRY_CODE_TLD;
    FDomains[298] := 'tw'              ; FTypes[298] := COUNTRY_CODE_TLD;
    FDomains[299] := 'tz'              ; FTypes[299] := COUNTRY_CODE_TLD;
    FDomains[300] := 'ua'              ; FTypes[300] := COUNTRY_CODE_TLD;
    FDomains[301] := 'ug'              ; FTypes[301] := COUNTRY_CODE_TLD;
    FDomains[302] := 'uk'              ; FTypes[302] := COUNTRY_CODE_TLD;
    FDomains[303] := 'us'              ; FTypes[303] := COUNTRY_CODE_TLD;
    FDomains[304] := 'uy'              ; FTypes[304] := COUNTRY_CODE_TLD;
    FDomains[305] := 'uz'              ; FTypes[305] := COUNTRY_CODE_TLD;
    FDomains[306] := 'va'              ; FTypes[306] := COUNTRY_CODE_TLD;
    FDomains[307] := 'vc'              ; FTypes[307] := COUNTRY_CODE_TLD;
    FDomains[308] := 've'              ; FTypes[308] := COUNTRY_CODE_TLD;
    FDomains[309] := 'vg'              ; FTypes[309] := COUNTRY_CODE_TLD;
    FDomains[310] := 'vi'              ; FTypes[310] := COUNTRY_CODE_TLD;
    FDomains[311] := 'vn'              ; FTypes[311] := COUNTRY_CODE_TLD;
    FDomains[312] := 'vu'              ; FTypes[312] := COUNTRY_CODE_TLD;
    FDomains[313] := 'wf'              ; FTypes[313] := COUNTRY_CODE_TLD;
    FDomains[314] := 'ws'              ; FTypes[314] := COUNTRY_CODE_TLD;
    FDomains[315] := 'ye'              ; FTypes[315] := COUNTRY_CODE_TLD;
    FDomains[316] := 'yt'              ; FTypes[316] := COUNTRY_CODE_TLD;
    FDomains[317] := 'za'              ; FTypes[317] := COUNTRY_CODE_TLD;
    FDomains[318] := 'zm'              ; FTypes[318] := COUNTRY_CODE_TLD;
    FDomains[319] := 'zw'              ; FTypes[319] := COUNTRY_CODE_TLD;
    
end;

