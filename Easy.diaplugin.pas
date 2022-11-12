unit Easy.diaplugin;

interface

uses
  Winapi.Windows,  Winapi.Messages, System.SysUtils,
  Vcl.Dialogs, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  System.Classes, Vcl.ComCtrls, SciSupport, System.Contnrs, System.Math,
  NppPlugin, ConstUnit, logFormUnit;

type

  TdiaPlugin = class(TNppPlugin)
  private
    { Private declarations }
    FLogForm: TLogForm;
    procedure DoNppnTracingCharAdded(const Key: Integer);
    function CurrentPos: LRESULT;
    function GetTextRange(const Range: TCharacterRange): nppString;
  public
    constructor Create;

    procedure DoNppnCode(code: NativeInt);override;
    procedure DoNppnToolbarModification; override;
    procedure DoNppnCharAdded(const ASCIIKey: Integer); override;
    procedure DoNppnModified(sn: PSCNotification); override;
    procedure DoNppnUpdateAutoSelection(P: PAnsiChar); override;
    procedure DoChangePluginTheme; override;
    procedure DoNppnShutdown; override;

    procedure SetCursor(const Mode: TCursorMode);

    procedure ShowAutocompletionTableList(const lengthEntered: NativeInt; Tables: AnsiString);
    procedure ShowAutocompletion(const TableName: string; Indx: TStringList);
    procedure FuncLog;
    procedure FuncPrForm;
    procedure FuncExecThisSQL(S: string);
    procedure FuncExecHelpSQL(help: THelpType; S: string);
    procedure FuncExecSQL;
    procedure FuncExecSQLPlan;
    procedure FuncInsertText(const S: string);
    procedure FuncInsertParam;
    procedure FuncSP_HELP;
    procedure FuncSP_HELPINDEX;
    procedure FuncSP_HELPTEXT;
    procedure FuncExecSQLTables;
  end;

var
  Npp: TdiaPlugin;

implementation

procedure _FuncExecSQLPlan; cdecl;
begin
  Npp.FuncExecSQLPlan;
end;

procedure _FuncLog; cdecl;
begin
  Npp.FuncLog;
end;

procedure _FuncPrForm; cdecl;
begin
  Npp.FuncPrForm;
end;

procedure _FuncExecSQL; cdecl;
begin
  Npp.FuncExecSQL;
end;

procedure f_M_BUSINESSLOG_BEGIN; cdecl;
begin
  Npp.FuncInsertText(cnstBSL_B);
end;

procedure f_M_BUSINESSLOG_BLOCK_BEGIN; cdecl;
begin
  Npp.FuncInsertText(cnstBSBL_B);
end;

procedure f_M_BUSINESSLOG_BLOCK_END; cdecl;
begin
  Npp.FuncInsertText(cnstBSBL_E);
end;

procedure f_M_BUSINESSLOG_CHECKPOINT; cdecl;
begin
  Npp.FuncInsertText(cnstBSL_C);
end;

procedure f_M_BUSINESSLOG_PARAM; cdecl;
begin
  Npp.FuncInsertParam;
end;

procedure f_M_LOG_TABLE_REQ; cdecl;
begin
  Npp.FuncInsertText(cnstBSL_T);
end;

procedure f_SP_HELP; cdecl;
begin
  Npp.FuncSP_HELP;
end;

procedure f_SP_HELPINDEX; cdecl;
begin
  Npp.FuncSP_HELPINDEX;
end;

procedure f_SP_HELPTEXT; cdecl;
begin
  Npp.FuncSP_HELPTEXT;
end;

procedure _FuncExecSQLTables; cdecl;
begin
  Npp.FuncExecSQLTables;
end;


{ TdiaPlugin }

constructor TdiaPlugin.Create;
var
  sk: TShortcutKey;
begin
  inherited;
{$IFNDEF NPPCONNECTIONS}
  PluginName := 'Easy.dia';
  AddFuncItem(PluginName, _FuncLog);

  sk.IsCtrl := true; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := 120; // F9
  AddFuncItem('Пролить скрипт на базу', _FuncPrForm, sk);

  sk.IsCtrl := true; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := 69; // 'E'
  AddFuncItem('Выполнить запрос SQL', _FuncExecSQL, sk);
  AddFuncItem('Получить план запроса SQL', _FuncExecSQLPlan);

  sk.IsCtrl := false; sk.IsAlt := true; sk.IsShift := false;
  sk.Key := 32; // Space
  AddFuncItem('Получить список p/t таблиц', _FuncExecSQLTables);
{$ELSE}
  PluginName := 'Npp.connections';
  AddFuncItem(PluginName, _FuncLog);

  sk.IsCtrl := true; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := 69; // 'E'
  AddFuncItem('Execute SQL query', _FuncExecSQL, sk);
  AddFuncItem('Get SQL execution plan', _FuncExecSQLPlan);
{$ENDIF}

{$IFNDEF NPPCONNECTIONS}
  AddFuncItem('-', nil );
  AddFuncItem('M_BUSINESSLOG_BEGIN'      ,f_M_BUSINESSLOG_BEGIN);
  AddFuncItem('M_BUSINESSLOG_BLOCK_BEGIN',f_M_BUSINESSLOG_BLOCK_BEGIN);
  AddFuncItem('M_BUSINESSLOG_BLOCK_END'  ,f_M_BUSINESSLOG_BLOCK_END);
  AddFuncItem('M_BUSINESSLOG_CHECKPOINT' ,f_M_BUSINESSLOG_CHECKPOINT);
  AddFuncItem('M_BUSINESSLOG_PARAM'      ,f_M_BUSINESSLOG_PARAM);
  AddFuncItem('M_LOG_TABLE_REQ'          ,f_M_LOG_TABLE_REQ);
{$ENDIF}
  AddFuncItem('-', nil );


  sk.IsCtrl := true; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := 123; // F12
  AddFuncItem('sp_help' ,f_SP_HELP,sk);
  AddFuncItem('sp_helpindex' ,f_SP_HELPINDEX);
  AddFuncItem('sp_helptext' ,f_SP_HELPTEXT);

  Sci_Send(SCI_SETMODEVENTMASK,SC_MOD_INSERTTEXT or SC_MOD_DELETETEXT,0);
end;

function TdiaPlugin.CurrentPos: LRESULT;
begin
  Result := Sci_Send(SCI_GETCURRENTPOS, 0, 0);
end;

procedure TdiaPlugin.DoChangePluginTheme;
begin
  inherited;
  if Assigned(FLogForm) then FLogForm.OnAfterChangeDarkMode(Self);
end;

procedure TdiaPlugin.DoNppnCharAdded(const ASCIIKey: Integer);
var
  i: Integer;
begin
  if not Assigned(FLogForm) then Exit;

  for i := Low(cnstTracingChar) to High(cnstTracingChar) do
    if cnstTracingChar[i] = ASCIIKey then
    begin
      DoNppnTracingCharAdded(ASCIIKey);
      Exit;
    end;
end;

procedure TdiaPlugin.DoNppnCode(code: NativeInt);
begin
{
      if Assigned(FLogForm) and (FLogForm.FindComponent('Memo1')<>nil) then
      begin
        TMemo(FLogForm.FindComponent('Memo1')).Lines.Add(code.ToString);
      end;

}
end;

procedure TdiaPlugin.DoNppnModified(sn: PSCNotification);
begin
  inherited;

end;

procedure TdiaPlugin.DoNppnShutdown;
begin
  if Assigned(FLogForm) then
  begin
    FLogForm.Free;
    FLogForm := nil;
  end;
  inherited;
end;

procedure TdiaPlugin.DoNppnTracingCharAdded(const Key: Integer);
  function DoSqlIndexProc(const SourceString,IndexString: string; Len: Integer): boolean;
  var
    S1: AnsiString;
    StartPos,i: Integer;
  begin
    Result := False;
    StartPos := Len - Length(IndexString);
    if (StartPos > 0) and (Copy(SourceString,StartPos,Length(IndexString))=IndexString) then
    begin
      S1 := Copy(SourceString,1,StartPos-1);
      i := Pos(cnstT1,LowerCase(S1));
      if i>0 then
        S1 := Copy(S1,i+Length(cnstT1),MaxInt)
      else
      begin
        i := Pos(cnstT2,LowerCase(S1));
        if i>0 then
          S1 := Copy(SourceString,i+Length(cnstT2),MaxInt)
      end;

      S1 := WholeWord(S1,1);
      if Length(S1) > 1 then
      begin
        FLogForm.DoSqlIndex(S1);
        Result := True;
      end;
    end;
  end;

var
  Size,Len: Integer;
  S: AnsiString;

begin
  Size := Sci_Send(SCI_GETCURLINE, 0, 0);
  SetLength(S,Size);
  try
    Len := Sci_Send(SCI_GETCURLINE, Size, LPARAM(PAnsiChar(S)));
    if not HasV5Apis then
      SetLength(S,Size-1);
    if DoSqlIndexProc(S,cnstI,Len) then Exit;
    if DoSqlIndexProc(S,cnstI1,Len) then Exit;
  finally
    SetLength(S,0);
  end;
end;

procedure TdiaPlugin.SetCursor(const Mode: TCursorMode);
begin
  if Mode = crNormal then Sci_Send(SCI_SETCURSOR, WPARAM(SC_CURSORNORMAL),0);
  if Mode = crWait then Sci_Send(SCI_SETCURSOR, SC_CURSORWAIT, 0);
end;

procedure TdiaPlugin.ShowAutocompletion(const TableName: string; Indx: TStringList);
var
  Size: Integer;
  S: AnsiString;
begin
  Sci_Send(SCI_AUTOCCANCEL, 0, 0);
  Indx.Delimiter := ' ';
  S := Indx.DelimitedText;
  Sci_Send(SCI_AUTOCSHOW, 0, LPARAM(PAnsiChar(S)));
end;

procedure TdiaPlugin.ShowAutocompletionTableList(const lengthEntered: NativeInt;  Tables: AnsiString);
begin
  Sci_Send(SCI_AUTOCCANCEL, 0, 0);
  Sci_Send(SCI_AUTOCSETIGNORECASE, 1, 1);
  Sci_Send(SCI_AUTOCSHOW, WPARAM(lengthEntered), LPARAM(PAnsiChar(Tables)));
end;

procedure TdiaPlugin.DoNppnToolbarModification;
var
  tb: TToolbarIcons;
  tb8: TTbIconsDarkMode;
  NppVersion: Cardinal;
begin
  NppVersion := GetNppVersion;
  if (HIWORD(NppVersion) >= 8) then
  begin
    tb8.ToolbarIcon := LoadImage(Hinstance, 'ITREEF', IMAGE_ICON, 0, 0, (LR_DEFAULTSIZE));
    tb8.ToolbarIconDarkMode := LoadImage(Hinstance, 'ITREEFDARK', IMAGE_ICON, 0, 0, (LR_DEFAULTSIZE));
    tb8.ToolbarBmp := LoadImage(Hinstance, 'TREE', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON_FORDARKMODE, WPARAM(self.CmdIdFromDlgId(0)), LPARAM(@tb8));

{$IFNDEF NPPCONNECTIONS}
    tb8.ToolbarIcon := LoadImage(Hinstance, 'ISERVER', IMAGE_ICON, 0, 0, (LR_DEFAULTSIZE));
    tb8.ToolbarIconDarkMode := LoadImage(Hinstance, 'ISERVERDARK', IMAGE_ICON, 0, 0, (LR_DEFAULTSIZE));
    tb8.ToolbarBmp := LoadImage(Hinstance, 'PROLIVKA', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON_FORDARKMODE, WPARAM(self.CmdIdFromDlgId(1)), LPARAM(@tb8));
{$ENDIF}

    tb8.ToolbarIcon := LoadImage(Hinstance, 'ISQL', IMAGE_ICON, 0, 0, (LR_DEFAULTSIZE));
    tb8.ToolbarIconDarkMode := LoadImage(Hinstance, 'ISQLDARK', IMAGE_ICON, 0, 0, (LR_DEFAULTSIZE));
    tb8.ToolbarBmp := LoadImage(Hinstance, 'SQL', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON_FORDARKMODE, WPARAM(self.CmdIdFromDlgId(2)), LPARAM(@tb8));

    tb8.ToolbarIcon := LoadImage(Hinstance, 'IPLAN', IMAGE_ICON, 0, 0, (LR_DEFAULTSIZE));
    tb8.ToolbarIconDarkMode := LoadImage(Hinstance, 'IPLANDARK', IMAGE_ICON, 0, 0, (LR_DEFAULTSIZE));
    tb8.ToolbarBmp := LoadImage(Hinstance, 'PLAN', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON_FORDARKMODE, WPARAM(self.CmdIdFromDlgId(3)), LPARAM(@tb8));
  end
  else
  begin
    tb.ToolbarIcon := 0;
    tb.ToolbarBmp := LoadImage(Hinstance, 'TREE', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON, WPARAM(self.CmdIdFromDlgId(0)), LPARAM(@tb));

{$IFNDEF NPPCONNECTIONS}
    tb.ToolbarIcon := 0;
    tb.ToolbarBmp := LoadImage(Hinstance, 'PROLIVKA', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON, WPARAM(self.CmdIdFromDlgId(1)), LPARAM(@tb));
{$ENDIF}
    tb.ToolbarIcon := 0;
    tb.ToolbarBmp := LoadImage(Hinstance, 'SQL', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON, WPARAM(self.CmdIdFromDlgId(2)), LPARAM(@tb));

    tb.ToolbarIcon := 0;
    tb.ToolbarBmp := LoadImage(Hinstance, 'PLAN', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON, WPARAM(self.CmdIdFromDlgId(3)), LPARAM(@tb));
  end;


end;

procedure TdiaPlugin.FuncExecHelpSQL(help: THelpType; S: string);
var N: integer;
begin
  if not Assigned(FLogForm) then
  begin
    FLogForm := TLogForm.Create(self, 0);
    TLogForm(FLogForm).DoConnect;
  end
  else
  begin
    N := Length(S);

    if (N > 1) and Assigned(FLogForm) then
      TLogForm(FLogForm).DoHelpSql(help,S);
  end;
end;

procedure TdiaPlugin.FuncExecSQL;
var S: string;
    N: integer;
begin
  S := SelectedText;
  N := Length(S);

  if N < 1 then
  begin
    S := GetText;
    N := Length(S);
  end;

  FuncExecThisSQL(S);
end;

procedure TdiaPlugin.FuncExecSQLPlan;
var S: string;
    N: integer;
begin
  if not Assigned(FLogForm) then FLogForm := TLogForm.Create(self, 0);
  S := SelectedText;
  N := Length(S);

  if N < 1 then
  begin
    S := GetText;
    N := Length(S);
  end;

  if (N > 1) and Assigned(FLogForm) then
  begin
    TLogForm(FLogForm).DoSql(cnstShowPlan + S);
  end;

end;

procedure TdiaPlugin.FuncExecSQLTables;
var
  Size: NativeInt;
  S: AnsiString;
  S1: string;
  Words: TStringList;
  i, iCurrentPos: Integer;
begin
  Size := Sci_Send(SCI_GETCURLINE, 0, 0);

  SetLength(S,Size);
  try
    iCurrentPos := Sci_Send(SCI_GETCURLINE, Size, LPARAM(PAnsiChar(S)));
    if not HasV5Apis then
      SetLength(S,Size-1);
    S1 := RemoveCarriageReturn(Copy(S,1,iCurrentPos));

    if S1 = '' then Exit;
    if S1.EndsWith(' ') then Exit;

    S1 := WholeWord(S1,MaxInt);
    for i in cnstTracingDataBaseChar do
      if Pos(Char(i),S1)=1 then
      begin
        FLogForm.DoSqlGetTableList(S1);
        Exit;
      end;

  finally
    SetLength(S,0);
  end;
end;

procedure TdiaPlugin.FuncExecThisSQL(S: string);
var N: integer;
begin
  if not Assigned(FLogForm) then
  begin
    FLogForm := TLogForm.Create(self, 0);
    TLogForm(FLogForm).DoConnect;
  end
  else
  begin
    N := Length(S);

    if (N > 1) and Assigned(FLogForm) then
    begin
      TLogForm(FLogForm).DoSql(S);
    end;
  end;
end;

procedure TdiaPlugin.FuncInsertParam;
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
              S0 := WholeWord(Trim(Copy(S,iPos+1,MaxInt)),1);
              {iPos := Pos(',',S0);
              if iPos > 0 then S0 := Copy(S0,1,iPos-1);
              iPos := Pos('=',S0);
              if iPos > 0 then S0 := Copy(S0,1,iPos-1);
              iPos := Pos(' ',S0);
              if iPos > 0 then S0 := Copy(S0,1,iPos-1);}
              if ItIsAWord(S0) then
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

const NoDuplicates = True;
      CheckLeftSymbols = False;
var
  S0,SText: AnsiString;
  Strings,Strings1: TStringList;
  Range: TCharacterRange;
  i,j,iPos: Integer;
begin
  S0 := SelectedText;
  Strings := RemoveNoVarString(WholeWords(S0,NoDuplicates),CheckLeftSymbols);
  if Assigned(Strings) then
  begin
    try
      Range.cpMin := 0;
      Range.cpMax := CurrentPos;
      SText := RemoveComments(GetTextRange(Range));
//      SText := GetText;

      Strings1 := RemoveStringsAboveStartProc(SText);
      try
        Strings1.Text := RemoveComments(Strings1.Text);
        Strings1 := RemoveNoVarString(Strings1);

        for i := 0 to Strings.Count - 1 do
        begin
          S0 := format(cnstBSL_P_Empty,[Strings[i]]);
          for j := 0 to Strings1.Count-1 do
          begin
            iPos := Pos(Strings[i]+' ',Strings1[j]);
            if iPos = 1 then
            begin
              SText := WholeWord(Trim(Copy(Strings1[j],Length(Strings[i])+1,MaxInt)),1);
//              iPos := Pos(',',SText);
//              if iPos>0 then SText := Copy(SText,1,iPos-1);
//              iPos := Pos('=',SText);
//              if iPos>0 then SText := Copy(SText,1,iPos-1);
              S0 := format(cnstBSL_P,[Strings[i],SText,GetType(SText)]);
              break;
            end;
          end;
          Strings[i] := S0;
        end;

        FuncInsertText(Strings.Text);
      finally
        Strings1.Free;
      end;
    finally
      Strings.Free;
    end;
  end;
end;

procedure TdiaPlugin.FuncInsertText(const S: string);
var
  S1: AnsiString;
  S2: AnsiString;
begin
  S1 := SelectedText;
  S2 := UTF8Encode(Format(S,[S1]));
  Sci_Send(SCI_REPLACESEL, 0, LPARAM(PAnsiChar(S2)));
end;

procedure TdiaPlugin.FuncLog;
begin
  if not Assigned(FLogForm) then FLogForm := TLogForm.Create(self, 0);
  (FLogForm as TLogForm).Show;
end;

procedure TdiaPlugin.FuncPrForm;
begin
  if not Assigned(FLogForm) then FLogForm := TLogForm.Create(self, 0);
  (FLogForm as TLogForm).DoPrForm;
end;

procedure TdiaPlugin.FuncSP_HELP;
var S: string;
    N: integer;
begin
  S := SelectedText;
  N := Length(S);

  if N = 0 then
  begin
    S := GetWord;
    N := Length(S);
  end;

  if N > 1 then
    FuncExecHelpSQL(spHelp,S);
end;

procedure TdiaPlugin.FuncSP_HELPINDEX;
var S: string;
    N: integer;
begin
  S := SelectedText;
  N := Length(S);

  if N = 0 then
  begin
    S := GetWord;
    N := Length(S);
  end;

  if N > 1 then
    FuncExecHelpSQL(spHelpindex,S);
end;

procedure TdiaPlugin.FuncSP_HELPTEXT;
var S: string;
    N: integer;
begin
  S := SelectedText;
  N := Length(S);

  if N = 0 then
  begin
    S := GetWord;
    N := Length(S);
  end;

  if N > 1 then
    FuncExecHelpSQL(spHelptext,S);
end;

function TdiaPlugin.GetTextRange(const Range: TCharacterRange): nppString;
var pt: PTextRange; //Возвращает текст внутри переданного диапазона
    Size,StartSize: NativeInt;
    S: AnsiString;
begin
  StartSize := (Range.cpMax - Range.cpMin)+1;
  GetMem(pt,SizeOf(TTextRange));
  GetMem(pt^.lpstrText,StartSize);
  try
    pt^.chrg := Range;
    Size :=Sci_Send(SCI_GETTEXTRANGEFULL,0,LPARAM(pt));
    if HasV5Apis then Inc(Size);
    SetLength(S,Size);
    StrLCopy(PAnsiChar(S),pt^.lpstrText,Size);
  finally
    FreeMem(pt^.lpstrText,StartSize);
    FreeMem(pt,SizeOf(TTextRange));
    Result := S;
  end;
end;

procedure TdiaPlugin.DoNppnUpdateAutoSelection(P: PAnsiChar);
var
  S: AnsiString;
  pS: PAnsiChar;
  iLen: Integer;
begin
  S := P;
  if Length(S) = 0 then
  begin
    GetMem(pS,255);
    try
      iLen := Sci_Send(SCI_AUTOCGETCURRENTTEXT,0,LPARAM(pS));
      if iLen > 0 then
      begin
        SetLength(S,iLen);
        StrLCopy(PAnsiChar(S),pS,iLen);
      end;
    finally
      FreeMem(pS);
    end;
  end;

  if (Length(S)>0) and  (S[1]= 'X') then
    if (Pos('(',S) > 0) and (Pos(')',S) = Length(S)) then
    begin
      iLen := Pos('(',S);
      try
        S := Copy(S,1,iLen-1);
        Sci_Send(SCI_AUTOCCANCEL,0,0);
        iLen := CurrentPos;
        Sci_Send(SCI_INSERTTEXT, WPARAM(-1), LPARAM(PAnsiChar(S)));
        Sci_Send(SCI_GOTOPOS,iLen + Length(S)+1,0);
      finally
        SetLength(S,0);
      end;
    end;
end;

end.
