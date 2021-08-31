unit ConstUnit;

interface

uses Winapi.Windows, Winapi.Messages, System.StrUtils,
     Vcl.Controls, System.Classes, System.SysUtils;

type
  TCommand = string;
  TPath = string;

  TModalResultArray = array[False..True] of TModalResult;
  TGarbageArray   = array[0..9] of string;
  TBeginProcArray = array[0..3] of string;
  TShowMode = (shSql,shPr,shCI);

  TBdType = (bdMSSQL, bdSybase, bdODBC);
  TBdTypeStringArray = array [TBdType] of string;

  TItemType = (itServerMS,itServerSYB,itODBC,itBase,itBaseRTI,itLogin);

  TTracingChar = array[0..1] of integer;
  TDSTypeArray = array[0..51] of string;

const

  WM_USER_MESSAGE_FROM_THREAD =  WM_USER + 1;

  cnstSqlWaitResults = 'Ждемс........';
  cnstSqlNoResults = 'Команда выполнена';
  cnstSqlNoPossible = 'Выполнение команды невозможно';
  cnstSqlExec = 'Результаты: %s\%s (%s)';

  cnstModalResultArray: TModalResultArray = (mrCancel,mrOk);

  cnstFileCopyError = 'Не удалось скопировать файл в %s';
  cnstFileCopyErrorCaption = 'Ошибка копирования файла';
  cnstBatch = 'cmd.exe /D /C "set keep_tfiles=true&&cls&&..\serv %s"';
  cnstT01 = '.t01';
  cnstServersKey = 'Software\Diasoft 5NT\Servers';
  cnstDllKey = 'Software\dia2notepad';
  cnstPrFormKey = 'PrForm';
  cnstPrHistKey = 'PrPathHistory';
  cnstPrClearMenuItemCaption = 'Очистить историю папок проливки';

  cnstBSL_B = 'M_BUSINESSLOG_BEGIN';
  cnstBSBL_B = 'M_BUSINESSLOG_BLOCK_BEGIN(''%s'')'#13#10'M_BUSINESSLOG_BLOCK_END(''%0:s'')';
  cnstBSBL_E = 'M_BUSINESSLOG_BLOCK_END(''%s'')';
  cnstBSL_C = 'M_BUSINESSLOG_CHECKPOINT(''%s'')';
  cnstBSL_T = 'M_LOG_TABLE_REQ(%s,''Таблица %0:s пуста'')';
  cnstBSL_P_Empty = 'M_BUSINESSLOG_PARAM(%s,,)';
  cnstBSL_P = 'M_BUSINESSLOG_PARAM(%s,%s,%s)';
  cnstNumbers = '0123456789';
  cnstAlphabet = '@0123456789abcdefghijklmnopqrstuvwxyz_()';
  cnstAlphabetStartWord = 'abcdefghijklmnopqrstuvwxyz';

  cnstGarbageArray: TGarbageArray =(
    '--',
    '/*',
    '(',
    ')',
    '\',
    ' ',
    #09,
    #13#10,
    #13,
    #10
    );

  cnstBeginProcArray: TBeginProcArray =(
    'create proc ',
    'create procedure ',
    'dcl_proc_begin(',
    'api_create_proc('
    {'create trigger',
    'create view ',
    'create table ',
    '#include ',
    '#define '}
    );


  cnstShowPlanXML_ON = 'SET SHOWPLAN_XML ON';
  cnstShowPlanXML_OFF = 'SET SHOWPLAN_XML OFF';
  cnstShowPlan_ON = 'set showplan on';
  cnstShowPlan_OFF = 'set showplan off';
  cnstAseOleDB = '[ASEOLEDB]';
  cnstShowPlan = 'PLAN:';
  cnstShowIndx = 'INDX:';
  cnstOpenPlanMessage = 'Открыть план запроса?';
  cnstSqlplanExt = '.sqlplan';
  cnstGo = 'go';

  cnstI = '_INDEX';
  cnstI1= '_INDEX_COL';

  cnstT1 = 'join ';
  cnstT2 = 'from ';

  MS =
    'M_NOLOCK (NOLOCK)'#13#10+
    'char_length datalength'#13#10+
    'sqlstatus fetch_status'#13#10+
    'M_ISOLAT /* at isolation  read uncommitted */'#13#10+
    'M_INDEX(<IND>) WITH (INDEX=<IND>)'#13#10+
    'M_NOLOCK_INDEX(<IND>) WITH (NOLOCK INDEX=<IND>)'#13#10+
    'M_ROWLOCK_INDEX(<IND>) WITH (ROWLOCK INDEX=<IND>)'#13#10+
    'M_ROWLOCK_READPAST_INDEX(<IND>) WITH (ROWLOCK INDEX=<IND> READPAST)'#13#10+
    'M_READPAST_INDEX(<IND>) WITH (INDEX=<IND> READPAST)'#13#10+
    'M_UPDLOCK_INDEX(<IND>) WITH (rowlock, updlock INDEX=<IND>)'#13#10+
    'M_UPDLOCK_READPAST_INDEX(<IND>) WITH (rowlock, updlock INDEX=<IND> READPAST)'#13#10+
    'M_WITH_ROWLOCK WITH (rowlock)'#13#10+
    'M_HOLDLOCK_INDEX(<IND>) WITH(holdlock index = <IND>)'#13#10+
    'M_ROWLOCK  -- lock datarows'#13#10+
    'M_HOLDLOCK WITH (holdlock)'#13#10+
    'M_KEEPPLAN  option (KEEPFIXED PLAN)'#13#10+
    'M_KEEPPLAN_FAST  option (KEEPFIXED PLAN, FAST 1)'#13#10+

    'M_P_ROWLOCK_INDEX(<IND>) WITH (ROWLOCK INDEX=<IND>)'#13#10+
    'M_P_ROWLOCK_READPAST_INDEX(<IND>) WITH (ROWLOCK INDEX=<IND> READPAST)'#13#10+
    'M_P_READPAST_INDEX(<IND>) WITH (INDEX=<IND> READPAST)'#13#10+
    'M_P_UPDLOCK_INDEX(<IND>) WITH (rowlock, updlock INDEX=<IND>)'#13#10+
    'M_P_UPDLOCK_READPAST_INDEX(<IND>) WITH (rowlock, updlock INDEX=<IND> READPAST)'#13#10+
    'M_P_WITH_ROWLOCK WITH (rowlock)'#13#10+
    'M_P_HOLDLOCK_INDEX(<IND>) WITH(holdlock index = <IND>)'#13#10+
    'M_P_HOLDLOCK WITH (holdlock)'#13#10+
    'M_FORCEORDER option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)'#13#10+
    'M_FORCEORDER_FAST option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN, FAST 1)'#13#10+
    'M_FORCESEEK_INDEX(<IND>) WITH (NOLOCK, INDEX=<IND>)'#13#10+
    'M_UPDLOCK_FORCESEEK_INDEX(<IND>) WITH (rowlock, updlock INDEX=<IND>)'#13#10+
    'M_ROWLOCK_FORCESEEK_INDEX(<IND>) WITH (rowlock INDEX=<IND>)';

  SYB =
    'M_NOLOCK /*NOLOCK*/'#13#10+
    'len char_length'#13#10+
    'datalength char_length'#13#10+
    'fetch_status sqlstatus'#13#10+
    'M_ISOLAT  at isolation  read uncommitted'#13#10+
    'M_INDEX(<IND>) (INDEX <IND>)'#13#10+
    'M_NOLOCK_INDEX(<IND>) (INDEX <IND>)'#13#10+
    'M_ROWLOCK_INDEX(<IND>) (INDEX <IND>)'#13#10+
    'M_ROWLOCK_READPAST_INDEX(<IND>) (INDEX <IND>) READPAST'#13#10+
    'M_READPAST_INDEX(<IND>) (INDEX <IND>) READPAST'#13#10+
    'M_UPDLOCK_INDEX(<IND>) (INDEX <IND>)'#13#10+
    'M_UPDLOCK_READPAST_INDEX(<IND>) (INDEX <IND>) READPAST'#13#10+
    'M_WITH_ROWLOCK /*WITH (rowlock)*/'#13#10+
    'M_HOLDLOCK_INDEX(<IND>) (index <IND>) holdlock'#13#10+
    'M_ROWLOCK  lock datarows'#13#10+
    'M_HOLDLOCK holdlock'#13#10+
    'M_KEEPPLAN  /*option (KEEP PLAN)*/'#13#10+
    'M_KEEPPLAN_FAST  /*option (KEEPFIXED PLAN, FAST 1)*/'#13#10+
    'M_P_ROWLOCK_INDEX(<IND>) (INDEX <IND>)'#13#10+
    'M_P_ROWLOCK_READPAST_INDEX(<IND>) (INDEX <IND>) READPAST'#13#10+
    'M_P_READPAST_INDEX(<IND>) (INDEX <IND>) READPAST'#13#10+
    'M_P_UPDLOCK_INDEX(<IND>) (INDEX <IND>)'#13#10+
    'M_P_UPDLOCK_READPAST_INDEX(<IND>) (INDEX <IND>) READPAST'#13#10+
    'M_P_WITH_ROWLOCK /*WITH (rowlock)*/'#13#10+
    'M_P_HOLDLOCK_INDEX(<IND>) (index <IND>) holdlock'#13#10+
    'M_P_HOLDLOCK holdlock'#13#10+
    'M_FORCEORDER /* option (FORCE ORDER, LOOP JOIN) */'#13#10+
    'M_FORCEORDER_FAST /* option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN, FAST 1) */'#13#10+
    'M_FORCESEEK_INDEX(<IND>) (INDEX <IND>)'#13#10+
    'M_UPDLOCK_FORCESEEK_INDEX(<IND>) (INDEX <IND>)'#13#10+
    'M_ROWLOCK_FORCESEEK_INDEX(<IND>) (INDEX <IND>)';

  M_CONST =
    'NULLDATE=''19000101'''#13#10+
    'DATESTARTTAX=''19000102'''#13#10+
    'MARKER_DATE=''20501231''';

  cnstDSTypeArray: TDSTypeArray = (
    'DAY=smalldatetime',
    'DSACC_SWIFT=char(35)',
    'DSACCNUMBER=char(25)',
    'DSACCNUMBER35=varchar(35)',
    'DSACCNUMVAR=varchar(25)',
    'DSBIC=varchar(15)',
    'DSBIGMONEY=numeric(28,10)',
    'DSBIT0=bit',
    'DSBIT1=bit',
    'DSBRIEFNAME=char(10)',
    'DSBRIEFVAR=varchar(10)',
    'DSCOMMENT=varchar(255)',
    'DSCOMMENT300=varchar(300)',
    'DSCOMMENTC=char(255)',
    'DSDATETIME=datetime',
    'DSDAY_STR=char(8)',
    'DSDEPHASH=char(120)',
    'DSFIELDNAME=char(30)',
    'DSFIELDNAMEVAR=varchar(30)',
    'DSFLOAT=float',
    'DSFORMCLASS=char(50)',
    'DSFULLNAME=char(60)',
    'DSHASH=varchar(120)',
    'DSIDENTIFIER=numeric(15,0)',
    'DSIDENTNAME=char(30)',
    'DSINDEXHASH=char(80)',
    'DSINT_KEY_ONE=int',
    'DSINT_KEY=int',
    'DSLABEL=varchar(80)',
    'DSMEMO=varchar(1954)',
    'DSMEMO1000=varchar(1000)',
    'DSMONEY=money',
    'DSNMEMO=nvarchar(1954)',
    'DSNOMINAL=numeric(32,14)',
    'DSNUMBER=char(10)',
    'DSNUMBER12=char(12)',
    'DSNUMBER20=char(20)',
    'DSNUMBER3=char(3)',
    'DSNUMBER5=char(5)',
    'DSOPERDAY=smalldatetime',
    'DSPERCENT=numeric(7,4)',
    'DSSMALLINT=smallint',
    'DSSPID=numeric(15,0)',
    'DSSYMBOL=char(1)',
    'DSTEXT=text',
    'DSTINYINT=tinyint',
    'DSUSERNAME=char(30)',
    'DSUUID=binary(16)',
    'DSVARFULLNAME=varchar(60)',
    'DSVARFULLNAME160=varchar(160)',
    'DSVARFULLNAME40=varchar(40)',
    'DSVARINDEX=varchar(6)'
    );





  constSQL_RTI =
                'declare @Brief DSUSERNAME,                  '#13#10+
                '        @UserID DSIDENTIFIER,               '#13#10+
                '        @HostName DSCOMMENT                 '#13#10+
                '                                            '#13#10+
                'select @Brief = ''%s'',                     '#13#10+
                '       @HostName = host_name()              '#13#10+
                '                                            '#13#10+
                'select @UserID = UserID                     '#13#10+
                '  from tUser where Brief = @Brief           '#13#10+
                '                                            '#13#10+
//                'exec User_Update                            '#13#10+
//                '  @UserID  = @UserID,                       '#13#10+
//                '  @Brief   = @Brief,                        '#13#10+
//                '  @MakeRTI = %d                             '#13#10+
//                '                                            '#13#10+
                'exec FCD_10_Log_SaveOption                  '#13#10+
                '        @UserID              = @UserID,     '#13#10+
                '        @HostName            = @HostName,   '#13#10+
                '        @ActivateClientFlag  = %d   ,       '#13#10+
                '        @AClientSQLBatch     = 1    ,       '#13#10+
                '        @AClientSQLStat      = 0    ,       '#13#10+
                '        @AClientSQLTrancount = 0    ,       '#13#10+
                '        @AClientProc         = 1    ,       '#13#10+
                '        @AClientProcParam    = 0    ,       '#13#10+
                '        @AClientTrace        = 0   ,        '#13#10+
                '        @AClientDebug        = 1   ,        '#13#10+
                '        @AClientInfo         = 1   ,        '#13#10+
                '        @AClientError        = 1   ,        '#13#10+
                '        @AClientReWriteLog   = 1   ,        '#13#10+
                '                                            '#13#10+
                '        @ActivateServerFlag  = %d  ,        '#13#10+
                '        @AServerProc         = 1   ,        '#13#10+
                '        @AServerProcParam    = 1   ,        '#13#10+
                '        @AServerTrace        = 1   ,        '#13#10+
                '        @AServerDebug        = 1   ,        '#13#10+
                '        @AServerInfo         = 1   ,        '#13#10+
                '        @AServerError        = 1   ,        '#13#10+
                '        @AServerProfile      = 0   ,        '#13#10+
                '        @AServerTable        = 1   ,        '#13#10+
                '        @AServerBusiness     = 1   ,        '#13#10+
                '        @AServerObjectListID = ''''         '#13#10+
                '                                            '#13#10+
                'select %d, ''%s'' as Db';


  constSQL_RTI_Clear =
                'declare @UserID   DSIDENTIFIER,          '#13#10+
                '        @Brief    DSUSERNAME  ,          '#13#10+
                '        @HostName DSCOMMENT   ,          '#13#10+
                '        @RetVal   int                    '#13#10+
                '                                         '#13#10+
                'select @Brief = ''%s'',                  '#13#10+
                '       @HostName = host_name(),          '#13#10+
                '       @RetVal   = 0                     '#13#10+
                '                                         '#13#10+
                'set rowcount 1                           '#13#10+
                '                                         '#13#10+
                'select @UserID = UserID                  '#13#10+
                '  from tUser where Brief = @Brief        '#13#10+
                '                                         '#13#10+
                'set rowcount 0                           '#13#10+
                '                                         '#13#10+
                'exec @RetVal = FCD_10_Log_Delete         '#13#10+
                '                  @Mode     = 0        , '#13#10+
                '                  @UserID   = @UserID  , '#13#10+
                '                  @HostName = @HostName  '#13#10+
                '                                         '#13#10+
                'select 3, ''%s'' as Db, @RetVal as RetVal';


//procedure TWatchCore_T.OpenLogMessages(SaveToFileName: string);
  constSQL_RTI_Get = //'M_P_ROWLOCK_READPAST_INDEX(ПРИМЕР_ИНДЕКСА)'#13#10+
                'declare @UserID    DSIDENTIFIER,                    '#13#10+
                '        @HostName  DSCOMMENT   ,                    '#13#10+
                '        @MinNumber numeric(15,0)                    '#13#10+
                '                                                    '#13#10+
                'select @MinNumber = :MinNumber                      '#13#10+
                '                                                    '#13#10+
                'set rowcount 1                                      '#13#10+
                '                                                    '#13#10+
                'select @UserID = UserID                             '#13#10+
                '  from tUser M_NOLOCK_INDEX(XPKtUser)               '#13#10+
                ' where Brief = suser_name()                         '#13#10+
                '                                                    '#13#10+
                'set rowcount 0                                      '#13#10+
                '                                                    '#13#10+
                'select @HostName = host_name()                      '#13#10+
                'set rowcount 5000                                   '#13#10+
                '                                                    '#13#10+
                'select ProcessID, Number, UserID, HostName,         '#13#10+
                '       DsSysModuleID, InDateTime, Message           '#13#10+
                '  from tLogMessage M_NOLOCK_INDEX(XAK2tLogMessage)  '#13#10+
                ' where UserID   = @UserID                           '#13#10+
                '   and HostName = @HostName                         '#13#10+
                '   and Number   > @MinNumber                        '#13#10+
                'order by Number                                     '#13#10+
                'M_ISOLAT                                            '#13#10+
                'M_KEEPPLAN                                          '#13#10+
                '                                                    '#13#10+
                'set rowcount 0';

  LineEnd = #13#10;
  c_Tab   = #9;

  cnstTracingChar: TTracingChar = (40,40);

  constLoginBDCaption  = 'Подключение к ';
  constLoginBDCaptionArray: TBdTypeStringArray = ('MSSQL','Sybase','ODBC');
  constDSBDCaptionArray: TBdTypeStringArray = ('Сервер','Сервер','Источник');
  cnstErroCaption = 'Ошибка';
  cnstRecordConfirmation = 'Начать протоколирование на базе %s?';
  cnstRecordConfirmRewriteExistingFile = 'Файл с именем "%s" существует. Перезаписать?';
  cnstRecordStopConfirmation = 'Остановить протоколирование на базе %s?';
  cnstRecordClearConfirmation= 'Очистить протоколирование на базе %s?';
  cnstRecordClearInformation = 'Протоколирование на базе %s очищено';
  cnstRecordAfterWriteRTIInformation = 'Файл %s сохранен';
  cnstRecordAfterWriteRTIInformationNOFILE = 'Операция выгрузки %s завершена.'#13#10'Файл пустой';
  cnstRecordConfirmationTitle = 'Протоколирование';
  cnstNoBaseSelected = 'Чтобы выполнить SQL запрос, необходимо выбрать сервер и базу!';

procedure StringsToAnsi(Strings: TStrings);
function RemoveGarbage(const S: string): string;
function TempPath: string;
procedure ReplaceConstants(SqlText: TStringList);
function ItIsAWord(S: AnsiString): boolean;
function WholeWords(S: AnsiString; const NoDuplacates: boolean = False): TStringList;
function WholeWord(const S: AnsiString; const WordIndex: Integer): AnsiString;
function RemoveComments(S: string): string;
//function GetDSType(S: string): String;
function GetType(S: string): String;

implementation

function TempPath: string;
var
	i: integer;
begin
  SetLength(Result, MAX_PATH);
	i := GetTempPath(Length(Result), PChar(Result));
	SetLength(Result, i);
  IncludeTrailingPathDelimiter(Result);
end;

function DosToWin(St: AnsiString): string;
var
  Len : Integer;
begin
  Len := Length(St);
  SetLength(Result, Len);
  OemToCharBuffW(PAnsiChar(St), PWideChar(Result), Len);
end;

procedure StringsToAnsi(Strings: TStrings);
var
  NewStr: string;
  i: integer;
begin
  for i := 0 to Strings.Count - 1 do
  begin
    NewStr := DosToWin(Strings[i]);
    Strings[i] := NewStr;
  end;
end;

function RemoveGarbage(const S: string): string;
var
  j: Longint;
  S0: string;
begin
  Result := Trim(S);
  for S0 in cnstGarbageArray do
  begin
    j := Result.IndexOf(S0);
    if j >= 0 then Result := Copy(Result,1,j);
  end;
end;

procedure ReplaceConstants(SqlText: TStringList);
var
  M: TStringList;
  i,j,ipos: integer;
  S,name,val: string;
  changed: boolean;
begin
  M := TStringList.Create;
  M.Text := M_CONST;
  try
    for i := 0 to SqlText.Count-1 do
    begin
      S := SqlText[i];
      changed := False;
      for j := 0 to M.Count-1 do
      begin
        name := M.Names[j];
        val := M.Values[name];
        ipos := Pos(name,S);
        if ipos > 0 then
        begin
          S := Copy(S,1,ipos-1) + val + Copy(S,ipos + Length(name),MaxInt);
          changed := True;
        end;
      end;
      if changed then SqlText[i] := S;
    end;
  finally
    M.Free;
  end;
end;

function GetType(S: string): String;
var i,j: Longint;
begin
  Result := Trim(S);
  for i := Low(cnstDSTypeArray) to High(cnstDSTypeArray) do
  begin
    j := pos(Trim(S)+'=',cnstDSTypeArray[i]);
    if j > 0 then
    begin
      Result := Copy(cnstDSTypeArray[i],pos('=',cnstDSTypeArray[i])+1,MaxInt);
      Exit;
    end;
  end;
end;

{function GetDSType(S: string): String;
var Strings: TStrings;
    i: Longint;
begin
  Result := '';
  Strings := WholeWords(S);
  if Assigned(Strings) then
  try
    for i := 0 to Strings.Count - 1 do
     if Copy(Strings[i],1,1) <> '@' then
     begin
       Result := Strings[i];
       Exit;
     end;
  finally
    Strings.Free;
  end;
end;}

function ItIsAWord(S: AnsiString): boolean;
var i: Longint;
    S0: AnsiString;
begin
  S := Trim(S);
  S0 := '';
  for i := 1 to Length(S) do
  begin
    if i = 1 then
    begin
      if pos(LowerCase(S[i]),cnstAlphabetStartWord) > 0 then
        S0 := S0 + S[i];
    end
    else
      if pos(LowerCase(S[i]),cnstAlphabet) > 0 then
        S0 := S0 + S[i];
  end;
  Result := S = S0;
end;

function WholeWords(S: AnsiString; const NoDuplacates: boolean = False): TStringList;
var i: Longint;
    S0: AnsiString;
begin
  Result := nil;
  S := Trim(S);
  S0 := '';
  for i := 1 to Length(S) do
  begin
    if pos(LowerCase(S[i]),cnstAlphabet) > 0 then
      S0 := S0 + S[i]
    else
    begin
      if Length(S0)>0 then
      begin
        if not Assigned(Result) then
        begin
          Result := TStringList.Create;
          if NoDuplacates then Result.Duplicates := dupIgnore;
        end;
        Result.Add(S0);
      end;
      S0 := '';
    end;
  end;

  if Length(S0)>0 then
  begin
    if not Assigned(Result) then Result := TStringList.Create;
    Result.Add(S0);
  end;
end;

function WholeWord(const S: AnsiString; const WordIndex: Integer): AnsiString;
var
  Strings: TStringList;
begin
  Result := '';
  Strings := WholeWords(S);
  if Assigned(Strings) then
  begin
    try
      if WordIndex <= Strings.Count then
        Result := Strings[WordIndex-1];
    finally
      FreeAndNil(Strings);
    end;
  end;
end;

function RemoveComments(S: string): string;
var
  i,ipos, ipos1: Integer;
  Strings: TStringList;
begin
  S := StringReplace(S,#9,' ',[rfReplaceAll]);
  while true do
  begin
    ipos := pos('/*',S);
    ipos1:= pos('*/',S);

    if (ipos = 0) and (ipos1 = 0) then break;
    if (ipos = 0) and (ipos1 > 0) then S := Copy(S,ipos1+2,MaxInt);
    if (ipos > 0) and (ipos1 = 0) then S := Copy(S,1,ipos-1);
    if (ipos > 0) and (ipos1 > 0) then
    begin
      if ipos > ipos1 then S := Copy(S,ipos1+2,MaxInt);
      if ipos < ipos1 then S := Copy(S,1,ipos-1) + #13#10 + Copy(S,ipos1+2,MaxInt);
    end;
  end;

  Strings := TStringList.Create;
  try
    Strings.Text := S;
    for i := Strings.Count - 1 downto 0 do
    begin
      S := Strings[i];
      ipos := pos('--',S);
      if ipos > 0 then S := Copy(S,1,ipos-1);
      S := Trim(S);
      if S = '' then
        Strings.Delete(i)
      else
        Strings[i] := S;
    end;
    S := Strings.Text;
  finally
    Strings.Free;
  end;

  Result := S;
end;


end.
