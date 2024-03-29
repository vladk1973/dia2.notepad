unit diaConstUnit;

interface

uses Winapi.Windows, Winapi.Messages, System.StrUtils,
     Vcl.Controls, System.Classes, System.SysUtils,
     System.Math, ConstUnit;

type
  TDSTypeArray = array[0..54] of string;
  TTracingDataBaseChar = array[0..3] of integer;

{$IFNDEF NPPCONNECTIONS}
const

  cnstBatch = 'cmd.exe /D /C "set keep_tfiles=true&&cls&&..\serv %s"';
  cnstConvert = 'curl --location --request POST "http://postgrefagl:8089/v1/batch" --header "Content-Type: application/octet-stream" --data-binary @"%s"';
  cnstT01 = '.t01';
  cnstPrFormKey = 'PrForm';
  cnstPgFormKey = 'PGConvertForm';
  cnstPrHistKey = 'PrPathHistory';
  cnstPgHistKey = 'PgPathHistory';
  cnstPgCmd = 'local-build.all.product.cmd';
  cnstBSL_B = 'M_BUSINESSLOG_BEGIN';
  cnstBSBL_B = 'M_BUSINESSLOG_BLOCK_BEGIN(''%s'')'#13#10'M_BUSINESSLOG_BLOCK_END(''%0:s'')';
  cnstBSBL_E = 'M_BUSINESSLOG_BLOCK_END(''%s'')';
  cnstBSL_C = 'M_BUSINESSLOG_CHECKPOINT(''%s'')';
  cnstBSL_T = 'M_LOG_TABLE_REQ(%s,''Таблица %0:s пуста'')';
  cnstBSL_P_Empty = 'M_BUSINESSLOG_PARAM(%s,,)';
  cnstBSL_P = 'M_BUSINESSLOG_PARAM(%s,%s,%s)';

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
  'var___sys_rowcount bigint := 0;                                           '+sLineBreak+
  'var_ImplicitCallerRetVal int;                                             '+sLineBreak+
  'var_ImplicitResultSet refcursor := ''var_implicitresultset'';             '+sLineBreak+
  '                                                                          '+sLineBreak+
  'BEGIN                                                                     '+sLineBreak+
  'SELECT coalesce(0, 0)                                                     '+sLineBreak+
  '  INTO var_UserID LIMIT 1;                                                '+sLineBreak+
  'IF var_UserID = 0 THEN                                                    '+sLineBreak+
  '  SELECT /*+ IndexScan(tuser tuser_xak0tuser) */                          '+sLineBreak+
  '         UserID                                                           '+sLineBreak+
  '    INTO var_tempSelect                                                   '+sLineBreak+
  '    FROM tUser                                                            '+sLineBreak+
  '   WHERE lower(Brief)::dsusername = lower(CAST(suser_sname() AS char (30))) LIMIT 1;'+sLineBreak+
  '  IF found THEN                                                           '+sLineBreak+
  '    var_UserID := var_tempSelect.UserID;                                  '+sLineBreak+
  '  END IF;                                                                 '+sLineBreak+
  '  GET DIAGNOSTICS var___sys_rowcount = ROW_COUNT;                         '+sLineBreak+
  'END IF;                                                                   '+sLineBreak+
  'SELECT host_name()::DSCOMMENT,                                            '+sLineBreak+
  '       0                                                                  '+sLineBreak+
  '  INTO var_HostName,                                                      '+sLineBreak+
  '       var_RetVal;                                                        '+sLineBreak+
  '                                                                          '+sLineBreak+
  'CALL tran_count_inc();                                                    '+sLineBreak+
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
  'GET DIAGNOSTICS var___sys_rowcount = ROW_COUNT;                           '+sLineBreak+
  '                                                                          '+sLineBreak+
  'END LOOP;                                                                 '+sLineBreak+
  '                                                                          '+sLineBreak+
  'CALL tran_count_dec();                                                    '+sLineBreak+
  '                                                                          '+sLineBreak+
  '  IF NOT EXISTS(SELECT 1   FROM pg_cursors  WHERE name = ''var_implicitresultset'') THEN '+sLineBreak+
  '    open var_ImplicitResultSet FOR                                        '+sLineBreak+
  '    SELECT coalesce(var_RetVal, 0) AS "Error";                            '+sLineBreak+
  '  END IF;                                                                 '+sLineBreak+
  '  IF NOT EXISTS(    SELECT 1                                              '+sLineBreak+
  '      FROM pg_cursors                                                     '+sLineBreak+
  '     WHERE name = ''var_implicitresultset'') THEN                         '+sLineBreak+
  '    open var_ImplicitResultSet FOR                                        '+sLineBreak+
  '    SELECT 0 AS "ResultSetNotFound"                                       '+sLineBreak+
  '     WHERE 0 = 1;                                                         '+sLineBreak+
  '  END IF;                                                                 '+sLineBreak+
  'END                                                                       '+sLineBreak+
  '$$;                                                                       '+sLineBreak+
  'fetch all from var_implicitresultset;                                     '+sLineBreak+
  'close var_implicitresultset;                                              '+sLineBreak;

  constSQL_RTI_PostgreSQL =
  'do $$                                                          '+sLineBreak+
  'DECLARE                                                        '+sLineBreak+
  'var_HostName DSCOMMENT;                                        '+sLineBreak+
  'var_ImplicitCallerRetVal int;                                  '+sLineBreak+
  'var_ImplicitResultSet refcursor := ''var_implicitresultset'';  '+sLineBreak+
  '                                                               '+sLineBreak+
  'BEGIN                                                          '+sLineBreak+
  'CALL tran_count_inc();                                         '+sLineBreak+
  '                                                               '+sLineBreak+
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
  '  IF NOT EXISTS(SELECT 1   FROM pg_cursors  WHERE name = ''var_implicitresultset'') THEN'+sLineBreak+
  '    open var_ImplicitResultSet FOR                             '+sLineBreak+
  '    SELECT 0;                                                  '+sLineBreak+
  '  END IF;                                                      '+sLineBreak+
  '  IF NOT EXISTS(    SELECT 1                                   '+sLineBreak+
  '      FROM pg_cursors                                          '+sLineBreak+
  '     WHERE name = ''var_implicitresultset'') THEN              '+sLineBreak+
  '    open var_ImplicitResultSet FOR                             '+sLineBreak+
  '    SELECT 0 AS "ResultSetNotFound"                            '+sLineBreak+
  '     WHERE 0 = 1;                                              '+sLineBreak+
  '  END IF;                                                      '+sLineBreak+
  '                                                               '+sLineBreak+
  'CALL tran_count_dec();                                         '+sLineBreak+
  'END                                                            '+sLineBreak+
  '$$;                                                            '+sLineBreak+
  'fetch all from var_implicitresultset;                          '+sLineBreak+
  'close var_implicitresultset;                                   '+sLineBreak;

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
  'declare @UserID   DSIDENTIFIER,                     '#13#10+
  '        @HostName DSCOMMENT,                        '#13#10+
  '        @RetVal   DSINT_KEY                         '#13#10+
  '                                                    '#13#10+
  'set rowcount 1                                      '#13#10+
  '                                                    '#13#10+
  'select @UserID = isnull(0, 0)                       '#13#10+
  'if @UserID = 0                                      '#13#10+
  '  select @UserID = UserID                           '#13#10+
  '    from tUser M_NOLOCK_INDEX(XAK0tUser)            '#13#10+
  '   where Brief = convert(char(30),suser_sname())    '#13#10+
  '                                                    '#13#10+
  '                                                    '#13#10+
  'set rowcount 0                                      '#13#10+
  '                                                    '#13#10+
  'select @HostName = host_name(),                     '#13#10+
  '       @RetVal   = 0                                '#13#10+
  '                                                    '#13#10+
  'while @HostName <> '''' and @RetVal = 0             '#13#10+
  'begin                                               '#13#10+
  '  exec @RetVal = FCD_10_Log_Delete                  '#13#10+
  '                   @Mode     = 0,                   '#13#10+
  '                   @UserID   = @UserID,             '#13#10+
  '                   @HostName = @HostName            '#13#10+
  '                                                    '#13#10+
  '  set rowcount 1                                    '#13#10+
  '  select @HostName = ''''                           '#13#10+
  '  select @HostName = HostName                       '#13#10+
  '    from tLogMessage M_NOLOCK_INDEX(XAK2tLogMessage)'#13#10+
  '   where UserID = @UserID                           '#13#10+
  '                                                    '#13#10+
  '  set rowcount 0                                    '#13#10+
  'end                                                 '#13#10+
  '                                                    '#13#10+
  'select isnull(@RetVal, 0) as Error, ''%s'' as Db    ';


//procedure TWatchCore_T.OpenLogMessages(SaveToFileName: string);
  constSQL_RTI_Get = //'M_P_ROWLOCK_READPAST_INDEX(ПРИМЕР_ИНДЕКСА)'#13#10+
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

  {Начальные буквы имени таблицы - p,t,P,T}
  cnstTracingDataBaseChar: TTracingDataBaseChar = (80,84,112,116);

  cnstI = '_INDEX';
  cnstI1= '_INDEX_COL';

  cnstSqlWaitResults = 'Ждемс........';
  cnstFileCopyError = 'Не удалось скопировать файл в %s';
  cnstFileCopyErrorCaption = 'Ошибка копирования файла';
  cnstPrClearMenuItemCaption = 'Очистить историю папок проливки';
  cnstPgClearMenuItemCaption = 'Очистить историю папок копирования';
  cnstRecordConfirmation = 'Начать протоколирование на базе %s?';

  cnstRecordConfirmRewriteExistingFile = 'Файл с именем "%s" существует. Перезаписать?';
  cnstRecordStopConfirmation = 'Остановить протоколирование на базе %s?';
  cnstRecordClearConfirmation= 'Очистить протоколирование на базе %s?';
  cnstRecordClearInformation = 'Протоколирование на базе %s очищено';
  cnstRecordAfterWriteRTIInformation = 'Файл %s сохранен';
  cnstRecordAfterWriteRTIInformationNOFILE = 'Операция выгрузки %s завершена.'#13#10'Файл пустой';
  cnstRecordConfirmationTitle = 'Протоколирование';
  cnstNoSQLSelected = 'На этот сервер проливка не поддерживается!';
  cnstNoSQLbaseSelected = 'Чтобы выполнить проливку, необходимо выбрать сервер и базу!';

function GetType(S: string): String;
procedure StringsToAnsi(Strings: TStrings);
procedure ReplaceConstants(SqlText: TStringList);
function ConvertSqlText(const SybStyle: boolean; SqlText: TStringList): TStringList;

procedure ProcessSqlIndex(S: string; StringProcedure: TStringProcedure);
function RemoveNoVarString(Strings: TStringList; CheckLeftSymbols: boolean = True): TStringList;
function RemoveStringsAboveStartProc(S: AnsiString): TStringList;

{$ENDIF}

implementation
{$IFNDEF NPPCONNECTIONS}

function RemoveNoVarString(Strings: TStringList; CheckLeftSymbols: boolean = True): TStringList;
var
  i,iPos: Integer;
  S,S0: string;
begin
  Result := Strings;
  if Assigned(Strings) then
    for i := Strings.Count-1 downto 0 do
    begin
      iPos := Pos('@',Strings[i]);
      if iPos > 0 then
      begin
        S := RemoveComments(Copy(Strings[i],1,iPos-1));
        S := StringReplace(S,' ','',[rfReplaceAll]);
        S := StringReplace(S,',','',[rfReplaceAll]);
        S := StringReplace(S,'declare','',[rfReplaceAll]);
        S := trimleft(S);
        if (S <>'') and CheckLeftSymbols then
        begin
          Strings.Delete(i)
        end
        else
        begin
          S := Copy(Strings[i],iPos,MaxInt);
          iPos := Pos(' ',S);
          if iPos > 0 then
          begin
            S0 := Trim(Copy(S,iPos+1,MaxInt));
            if (S0.Length>0) and (Pos(LowerCase(S0[1]),cnstAlphabetStartWord) > 0) then
              Strings[i] := S
            else
              Strings.Delete(i);
          end
          else
            Strings[i] := S;
        end;
      end
      else
        Strings.Delete(i);
    end;
end;

function RemoveStringsAboveStartProc(S: AnsiString): TStringList;
var
  S0: string;
  i,iPos: Integer;
begin
  S0 := LowerCase(S);
  Result := TStringList.Create;
  iPos := 0;
  for i := Low(cnstBeginProcArray) to High(cnstBeginProcArray) do
    iPos := Max(iPos,Pos(cnstBeginProcArray[i],S0));
  if iPos = 0 then
    Result.Text := S
  else
    Result.Text := Copy(S,iPos,MaxInt);
end;

procedure ProcessSqlIndex(S: string; StringProcedure: TStringProcedure);
  function DoSqlIndexProc(const SourceString,IndexString: string): boolean;
  var
    S: string;
    StartPos,i: Integer;
  begin
    Result := False;
    StartPos := SourceString.IndexOf(IndexString);
    if StartPos > 0 then
    begin
      S := SourceString.Substring(0,StartPos);
      i := S.ToLower.IndexOf(cnstT1);
      if i>=0 then
        S := S.Substring(i+Length(cnstT1))
      else
      begin
        i := S.ToLower.IndexOf(cnstT2);
        if i>=0 then
          S := S.Substring(i+Length(cnstT1))
      end;

      S := WholeWord(S,1);
      if Length(S) > 1 then
      begin
        StringProcedure(S);
        Result := True;
      end;
    end;
  end;
begin
  if DoSqlIndexProc(S,cnstI) then Exit;
  if DoSqlIndexProc(S,cnstI1) then Exit;
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

function ConvertSqlText(const SybStyle: boolean; SqlText: TStringList): TStringList;
  function StringReplaceIndexCol(mvalue,mparams,S: string): string;
  var
    iPos: integer;
    mparams1,mparams2: string;
  begin
    iPos := Pos(',',mparams);
    if iPos>0 then
    begin
      mparams1 := Copy(mparams,1,iPos-1);
      mparams2 := Copy(mparams,iPos+1,MaxInt);
      Result := StringReplace(mvalue,mparams1,Copy(S,1,Pos(',',S)-1),[rfReplaceAll]);
      Result := StringReplace(Result,mparams2,Copy(S,Pos(',',S)+1,MaxInt),[rfReplaceAll]);
    end
    else
      Result := StringReplace(mvalue,mparams,S,[rfReplaceAll]);
  end;
var
  S,Si,macros,macrosf,mvalue, ind: string;
  M: TStringList;
  i,j,ipos, start, finish: integer;
begin
  {$IFNDEF NPPCONNECTIONS}ReplaceConstants(SqlText);{$ENDIF}

  M := TStringList.Create;
  try

    if SybStyle then M.Text := SYB else M.Text := MS;
    for i := 0 to M.Count-1 do
    begin
      ipos := Pos(' ',M[i]);
      if ipos > 1 then
      begin
        macros := Copy(M[i],1,ipos-1); //M_P_ROWLOCK_INDEX(IND)
        mvalue := Copy(M[i],ipos+1,MaxInt);

        ipos := Pos('(',macros);
        if ipos > 1 then
        begin
          macrosf := Copy(macros,1,ipos-1); //M_P_ROWLOCK_INDEX
          ind := Copy(macros,ipos+1,MaxInt);
          ipos:= Pos(')',ind);
          ind := Copy(ind,1,ipos-1);
        end
        else
        begin
          macrosf := macros;
          ind := '';
        end;


        for j := 0 to SqlText.Count - 1 do
          if Pos(macrosf,SqlText[j]) > 0 then
          begin
            start := Pos(macrosf,SqlText[j]);

            if start > 1 then
              if SqlText[j][start-1] = '#' then
                SqlText[j] := Copy(SqlText[j],1,start-2) + ' ' + Copy(SqlText[j],start,MaxInt);

            S := Trim(Copy(SqlText[j],start + Length(macrosf),MaxInt)) + ' ';

            if S[1] in ['(',' '] then
            begin

              if ind <> '' then
              begin
                finish := PosEx(')',SqlText[j],start+1);
                Si := Copy(SqlText[j],PosEx('(',SqlText[j],start+1)+1,MaxInt);
                ipos := Pos(')',Si);
                Si := Copy(Si,1,ipos-1);
              end
              else
              begin
                finish := start + Length(macrosf);
                Si := '';
              end;

              S := Copy(SqlText[j],1,start-1)
                   + StringReplaceIndexCol(mvalue,ind,Si)
                   + Copy(SqlText[j],finish+1,MaxInt);

              SqlText[j] := S;

            end;
          end;

        for j := SqlText.Count - 1 downto 0 do
          if Trim(SqlText[j]) = '' then SqlText.Delete(j);

      end;
    end;
    Result := SqlText;
  finally
    M.Free;
  end;
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
    NewStr := DosToWin(AnsiString(Strings[i]));
    Strings[i] := NewStr;
  end;
end;

{$ENDIF}

end.
