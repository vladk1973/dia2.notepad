unit ConstUnit;

interface

uses Winapi.Windows, Winapi.Messages, System.StrUtils,
     Vcl.Controls, System.Classes, System.SysUtils;

type
  TCommand = string;
  TPathName = string;
  TFileName = string;

  TModalResultArray = array[False..True] of TModalResult;
  TGarbageArray   = array[0..9] of string;
  TBeginProcArray = array[0..4] of string;
  TBeginAlignArray = array[0..9] of string;

  TShowMode = (shSql,shPr,shCI);

  TBdType = (bdMSSQL, bdSybase, bdPostgreSQL, bdODBC);
  TBdTypeStringArray = array [TBdType] of string;

  //� TItemType - ������� ����� ������ ��������� � TBdType
  TItemType = (itServerMS,itServerSYB,itServerPostgreSQL,itODBC,itBase,itBaseRTI,itLogin);

  TTracingChar = array[0..1] of integer;
  TDSTypeArray = array[0..54] of string;

  THelpType = (spHelp, spHelpindex, spHelpText);
  THelpArray = array[TBdType,THelpType] of string;

const

  WM_USER_MESSAGE_FROM_THREAD =  WM_USER + 1;

  cnstSqlWaitResults = '�����........';
  cnstSqlNoResults = '������� ���������';
  cnstSqlNoPossible = '���������� ������� ����������';
  cnstSqlExec = '����������: %s\%s (%s)';

  cnstModalResultArray: TModalResultArray = (mrCancel,mrOk);

  cnstFileCopyError = '�� ������� ����������� ���� � %s';
  cnstFileCopyErrorCaption = '������ ����������� �����';

  cnstBatch = 'cmd.exe /D /C "set keep_tfiles=true&&cls&&..\serv %s"';
  cnstConvert = 'curl --location --request POST "http://postgrefagl:8089/v1/batch" --header "Content-Type: application/octet-stream" --data-binary @"%s"';
  cnstT01 = '.t01';
  cnstServersKey = 'Software\Diasoft 5NT\Servers';
  cnstDllKey = 'Software\dia2notepad';
  cnstPrFormKey = 'PrForm';
  cnstPrHistKey = 'PrPathHistory';
  cnstPrClearMenuItemCaption = '�������� ������� ����� ��������';

  constDBList = 'select name from master..sysdatabases order by name';
  constPostgreDBList = 'SELECT datname FROM pg_database;';

  cnstBSL_B = 'M_BUSINESSLOG_BEGIN';
  cnstBSBL_B = 'M_BUSINESSLOG_BLOCK_BEGIN(''%s'')'#13#10'M_BUSINESSLOG_BLOCK_END(''%0:s'')';
  cnstBSBL_E = 'M_BUSINESSLOG_BLOCK_END(''%s'')';
  cnstBSL_C = 'M_BUSINESSLOG_CHECKPOINT(''%s'')';
  cnstBSL_T = 'M_LOG_TABLE_REQ(%s,''������� %0:s �����'')';
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
    'api_create_proc(',
    'create or replace '
    {'create trigger',
    'create view ',
    'create table ',
    '#include ',
    '#define '}
    );

  cnstAlignStartWords: TBeginAlignArray = (
    'declare',
    'execute',
    'exec'   ,
    '@',
    'select',
    'if',
    'begin',
    'insert',
    'delete',
    'while'
    );

  cnstShowPlanXML_ON = 'SET SHOWPLAN_XML ON';
  cnstShowPlanXML_OFF = 'SET SHOWPLAN_XML OFF';
  cnstShowPlan_ON = 'set showplan on';
  cnstShowPlan_OFF = 'set showplan off';

  cnstShowSpHelp = 'sp_help %s';
  cnstShowSpHelpIndex = 'sp_helpindex %s';
  cnstShowSpHelpText = 'sp_helptext %s';


  cnstShowPlan_PostgreSQL = 'EXPLAIN ';
  cnstShowSpHelp_PostgreSQL = 'SELECT ''%s'' AS name;'+sLineBreak+
                              'SELECT * FROM information_schema.columns WHERE table_name = ''%0:s'';'+sLineBreak+
                              'SELECT * FROM pg_indexes WHERE tablename = ''%0:s'';';
  cnstShowSpHelpIndex_PostgreSQL = 'SELECT * FROM pg_indexes WHERE tablename = ''%s'';';
  cnstShowSpHelpText_PostgreSQL = 'SELECT'+sLineBreak+
                                    'pg_get_functiondef(('+sLineBreak+
                                                        'SELECT'+sLineBreak+
                                                        'oid FROM pg_proc'+sLineBreak+
                                                        'WHERE'+sLineBreak+
                                                        'proname = ''%s''));';
  cnstAseOleDB = '[ASEOLEDB]';
  cnstShowPlan = 'PLAN:';
  cnstShowIndx = 'INDX:';
  cnstOpenPlanMessage = '������� ���� �������?';
  cnstSqlplanExt = '.sqlplan';
  cnstGo = 'go';

  cnstI = '_INDEX';
  cnstI1= '_INDEX_COL';

  cnstT1 = 'join ';
  cnstT2 = 'from ';

  cnstHelpArray: THelpArray = ((cnstShowSpHelp,cnstShowSpHelpIndex,cnstShowSpHelpText),
                               (cnstShowSpHelp,cnstShowSpHelpIndex,cnstShowSpHelpText),
                               (cnstShowSpHelp_PostgreSQL,cnstShowSpHelpIndex_PostgreSQL,cnstShowSpHelpText_PostgreSQL),
                               ('%s','%s','%s')
                              );

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
//    'M_FORCESEEK_INDEX_COL(<IND>,<COL>) WITH (NOLOCK, FORCESEEK (<IND> (<COL>)))'#13#10+
    'M_FORCESEEK_INDEX_COL(<IND>,<COL>) WITH (NOLOCK, INDEX=<IND>)'#13#10+
    'M_UPDLOCK_FORCESEEK_INDEX(<IND>) WITH (rowlock, updlock INDEX=<IND>)'#13#10+
    'M_ROWLOCK_FORCESEEK_INDEX(<IND>) WITH (rowlock INDEX=<IND>)'#13#10+
    'M_UPDLOCK_FORCESEEK_INDEX_COL(<IND>,<COL>) WITH (rowlock, updlock INDEX=<IND>)'#13#10+
    'M_ROWLOCK_FORCESEEK_INDEX_COL(<IND>,<COL>) WITH (rowlock INDEX=<IND>)';


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
    'M_FORCESEEK_INDEX_COL(<IND>,<COL>) (INDEX <IND>)'#13#10+
    'M_UPDLOCK_FORCESEEK_INDEX(<IND>) (INDEX <IND>)'#13#10+
    'M_ROWLOCK_FORCESEEK_INDEX(<IND>) (INDEX <IND>)'#13#10+
    'M_UPDLOCK_FORCESEEK_INDEX_COL(<IND>,<COL>) (INDEX <IND>)'#13#10+
    'M_ROWLOCK_FORCESEEK_INDEX_COL(<IND>,<COL>) (INDEX <IND>)';


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
    'DSVARINDEX=varchar(6)',
    'FTIDENTIFIER_NULL=numeric(15,0)',
    'DSVARBINARY_MAX=DSVARBINARY_MAX',
    'DSVARCHAR_MAX=DSVARCHAR_MAX'
    );


  constSQL_RTI_Get_PostgreSQL =
  'do $$                                                                 '+sLineBreak+
  'DECLARE                                                               '+sLineBreak+
  'var_UserID DSIDENTIFIER;                                              '+sLineBreak+
  'var_HostName DSCOMMENT;                                               '+sLineBreak+
  'var_tempSelect record;                                                '+sLineBreak+
  'var_MinNumber DSIDENTIFIER;                                           '+sLineBreak+
  'var_ImplicitCallerRetVal int;                                         '+sLineBreak+
  'var_ImplicitResultSet refcursor := ''var_implicitresultset'';         '+sLineBreak+
  '                                                                      '+sLineBreak+
  'BEGIN                                                                 '+sLineBreak+
  'SELECT %15.0f     INTO var_MinNumber LIMIT 1;                         '+sLineBreak+
  'SELECT UserID                                                         '+sLineBreak+
  '  INTO var_tempSelect                                                 '+sLineBreak+
  '  FROM tUser                                                          '+sLineBreak+
  ' WHERE lower(Brief) = lower(CAST(suser_sname() AS char (30))) LIMIT 1;'+sLineBreak+
  'IF found THEN                                                         '+sLineBreak+
  'var_UserID := var_tempSelect.UserID;                                  '+sLineBreak+
  'END IF;                                                               '+sLineBreak+
  'SELECT host_name()::DSCOMMENT INTO var_HostName;                      '+sLineBreak+
  'open var_ImplicitResultSet FOR                                        '+sLineBreak+
  'SELECT ProcessID, Number, UserID, HostName,                           '+sLineBreak+
  '       DsSysModuleID, InDateTime, Message                             '+sLineBreak+
  '  FROM tLogMessage                                                    '+sLineBreak+
  ' WHERE UserID   = var_UserID                                          '+sLineBreak+
  '   AND HostName = var_HostName                                        '+sLineBreak+
  '   AND Number   > var_MinNumber                                       '+sLineBreak+
  'ORDER BY Number                                                       '+sLineBreak+
  'LIMIT 5000;                                                           '+sLineBreak+
  'END                                                                   '+sLineBreak+
  '$$;                                                                   '+sLineBreak+
  'fetch all from var_ImplicitResultSet;                                 ';

  {'SELECT ProcessID, Number, UserID, HostName,                           '+sLineBreak+
  '       DsSysModuleID, InDateTime, Message                             '+sLineBreak+
  '  FROM tLogMessage                                                    '+sLineBreak+
  ' WHERE UserID   = 1                                          '+sLineBreak+
  '   AND Number   > %15.0f                                         '+sLineBreak+
  'ORDER BY Number                                                       '+sLineBreak+
  'LIMIT 5000                                                           ';}


  constSQL_RTI_Clear_PostgreSQL =
  'do $$                                                                     '+sLineBreak+
  'DECLARE                                                                   '+sLineBreak+
  'var_UserID DSIDENTIFIER;                                                  '+sLineBreak+
  'var_HostName DSCOMMENT;                                                   '+sLineBreak+
  'var_RetVal DSINT_KEY;                                                     '+sLineBreak+
  'var_tempSelect record;                                                    '+sLineBreak+
  'var_ImplicitCallerRetVal int;                                             '+sLineBreak+
  'var_ImplicitResultSet refcursor := ''var_implicitresultset'';             '+sLineBreak+
  '                                                                          '+sLineBreak+
  'BEGIN                                                                     '+sLineBreak+
  'SELECT coalesce(0, 0)                                                     '+sLineBreak+
  '  INTO var_UserID LIMIT 1;                                                '+sLineBreak+
  'IF var_UserID = 0 THEN                                                    '+sLineBreak+
  'SELECT UserID                                                             '+sLineBreak+
  '  INTO var_tempSelect                                                     '+sLineBreak+
  '  FROM tUser                                                              '+sLineBreak+
  ' WHERE lower(Brief) = lower(CAST(suser_sname() AS char (30))) LIMIT 1;    '+sLineBreak+
  'IF found THEN                                                             '+sLineBreak+
  'var_UserID := var_tempSelect.UserID;                                      '+sLineBreak+
  'END IF;                                                                   '+sLineBreak+
  'END IF;                                                                   '+sLineBreak+
  'SELECT host_name()::DSCOMMENT,                                            '+sLineBreak+
  '       0                                                                  '+sLineBreak+
  '  INTO var_HostName,                                                      '+sLineBreak+
  '       var_RetVal;                                                        '+sLineBreak+
  '                                                                          '+sLineBreak+
  '                                                                          '+sLineBreak+
  'WHILE var_HostName <> '''' AND var_RetVal = 0 LOOP                        '+sLineBreak+
  'CALL FCD_10_Log_Delete(                                                   '+sLineBreak+
  '       var_ImplicitCallerRetVal,                                          '+sLineBreak+
  '       var_ImplicitResultSet,                                             '+sLineBreak+
  '       var_Mode => 0,                                                     '+sLineBreak+
  '       var_UserID => var_UserID,                                          '+sLineBreak+
  '       var_HostName => var_HostName                                       '+sLineBreak+
  ');                                                                        '+sLineBreak+
  'var_RetVal := var_ImplicitCallerRetVal;                                   '+sLineBreak+
  'SELECT ''''                                                               '+sLineBreak+
  '  INTO var_HostName LIMIT 1;                                              '+sLineBreak+
  'SELECT HostName                                                           '+sLineBreak+
  '  INTO var_tempSelect                                                     '+sLineBreak+
  '  FROM tLogMessage                                                        '+sLineBreak+
  ' WHERE UserID = var_UserID LIMIT 1;                                       '+sLineBreak+
  'IF found THEN                                                             '+sLineBreak+
  'var_HostName := var_tempSelect.HostName;                                  '+sLineBreak+
  'END IF;                                                                   '+sLineBreak+
  '                                                                          '+sLineBreak+
  'END LOOP;                                                                 '+sLineBreak+
  'open var_ImplicitResultSet FOR SELECT coalesce(var_RetVal, 0) AS "Error"; '+sLineBreak+
  'END                                                                       '+sLineBreak+
  '$$;                                                                       '+sLineBreak+
  'fetch all from var_implicitresultset;                                     ';

  constSQL_RTI_PostgreSQL =
  'do $$                                                          '+sLineBreak+
  'DECLARE                                                        '+sLineBreak+
  'var_HostName DSCOMMENT;                                        '+sLineBreak+
  'var_ImplicitCallerRetVal int;                                  '+sLineBreak+
  'var_ImplicitResultSet refcursor := ''var_implicitresultset'';  '+sLineBreak+
  '                                                               '+sLineBreak+
  'BEGIN                                                          '+sLineBreak+
  'SELECT host_name()::DSCOMMENT INTO var_HostName;               '+sLineBreak+
  'CALL FCD_10_Log_SaveOption(                                    '+sLineBreak+
  '       var_ImplicitCallerRetVal,                               '+sLineBreak+
  '       var_ImplicitResultSet,                                  '+sLineBreak+
  '       var_UserID => 0,                                        '+sLineBreak+
  '       var_HostName => var_HostName,                           '+sLineBreak+
  '       var_ActivateClientFlag => %d,                           '+sLineBreak+
  '       var_AClientSQLBatch => 1,                               '+sLineBreak+
  '       var_AClientSQLStat => 0,                                '+sLineBreak+
  '       var_AClientSQLTrancount => 0,                           '+sLineBreak+
  '       var_AClientProc => 1,                                   '+sLineBreak+
  '       var_AClientProcParam => 0,                              '+sLineBreak+
  '       var_AClientTrace => 0,                                  '+sLineBreak+
  '       var_AClientDebug => 1,                                  '+sLineBreak+
  '       var_AClientInfo => 1,                                   '+sLineBreak+
  '       var_AClientError => 1,                                  '+sLineBreak+
  '       var_AClientReWriteLog => 1,                             '+sLineBreak+
  '       var_ActivateServerFlag => %d,                           '+sLineBreak+
  '       var_AServerProc => 1,                                   '+sLineBreak+
  '       var_AServerProcParam => 1,                              '+sLineBreak+
  '       var_AServerTrace => 1,                                  '+sLineBreak+
  '       var_AServerDebug => 1,                                  '+sLineBreak+
  '       var_AServerInfo => 1,                                   '+sLineBreak+
  '       var_AServerError => 1,                                  '+sLineBreak+
  '       var_AServerProfile => 0,                                '+sLineBreak+
  '       var_AServerTable => 1,                                  '+sLineBreak+
  '       var_AServerBusiness => 1,                               '+sLineBreak+
  '       var_AServerObjectListID => '''',                        '+sLineBreak+
  '       var_ATrace => 0                                         '+sLineBreak+
  ');                                                             '+sLineBreak+
  'open var_ImplicitResultSet FOR SELECT coalesce(var_ImplicitCallerRetVal, 0) AS "Error";'+sLineBreak+
  'END                                                            '+sLineBreak+
  '$$;                                                            '+sLineBreak+
  'fetch all from var_implicitresultset;                          ';

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
                'select @RetVal, ''%s'' as Db';


//procedure TWatchCore_T.OpenLogMessages(SaveToFileName: string);
  constSQL_RTI_Get = //'M_P_ROWLOCK_READPAST_INDEX(������_�������)'#13#10+
                'declare @UserID    DSIDENTIFIER,                    '#13#10+
                '        @HostName  DSCOMMENT   ,                    '#13#10+
                '        @MinNumber DSIDENTIFIER                     '#13#10+
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

  constConnectionMSSQL =  'Provider=SQLOLEDB.1;Password=%s;Persist Security Info=True;User ID=%s;%sData Source=%s';
  constConnectionSybase = 'Provider=ASEOLEDB.1;Password=%s;Persist Security Info=True;User ID=%s;Data Source=%s:%s;%sExtended Properties="LANGUAGE=us_english";Connect Timeout=3';
  constConnectionPostgre = 'Provider=MSDASQL.1;Password=%s;Persist Security Info=True;User ID=%s;Extended Properties="DRIVER={PostgreSQL Unicode};SERVER=%s;PORT=%s;%s"';
  constConnectionODBC = 'Provider=MSDASQL.1;Persist Security Info=False;Data Source=%s';
  constConnectionStringArray: TBdTypeStringArray = (constConnectionMSSQL,
                                                    constConnectionSybase,
                                                    constConnectionPostgre,
                                                    constConnectionODBC);

  constLoginBDCaption  = '����������� � ';
  constLoginBDCaptionArray: TBdTypeStringArray = ('MSSQL','Sybase','PostgreSQL','ODBC');
  constDSBDCaptionArray: TBdTypeStringArray = ('������','������','������','��������');
  constLoginBDArray: TBdTypeStringArray = ('sa','sa','postgres','admin');


  cnstErroCaption = '������';
  cnstRecordConfirmation = '������ ���������������� �� ���� %s?';

  cnstRecordConfirmRewriteExistingFile = '���� � ������ "%s" ����������. ������������?';
  cnstRecordStopConfirmation = '���������� ���������������� �� ���� %s?';
  cnstRecordClearConfirmation= '�������� ���������������� �� ���� %s?';
  cnstRecordClearInformation = '���������������� �� ���� %s �������';
  cnstRecordAfterWriteRTIInformation = '���� %s ��������';
  cnstRecordAfterWriteRTIInformationNOFILE = '�������� �������� %s ���������.'#13#10'���� ������';
  cnstRecordConfirmationTitle = '����������������';
  cnstNoBaseSelected = '����� ��������� SQL ������, ���������� ������� ������ � ����!';
  cnstNoSQLSelected = '�� ���� ������ �������� �� ��������������!';
  cnstNoSQLbaseSelected = '����� ��������� ��������, ���������� ������� ������ � ����!';

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
