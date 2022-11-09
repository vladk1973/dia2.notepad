unit Easy.diaplugin;

interface

uses
  Winapi.Windows,  Winapi.Messages, System.SysUtils,
  Vcl.Dialogs, Vcl.Forms, Vcl.Controls,
  System.Classes, Vcl.ComCtrls, SciSupport, System.Contnrs, System.Math,
  NppPlugin, ConstUnit, logFormUnit, AlignStringsUnit;

type

  TdiaPlugin = class(TNppPlugin)
  private
    { Private declarations }
    FLogForm: TLogForm;
    procedure DoNppnTracingCharAdded(const Key: Integer);
    function CurrentPos: LRESULT;
   // function GetTextRange(const Range: TCharacterRange): nppString;
  public
    constructor Create;

    procedure DoNppnToolbarModification; override;
    procedure DoNppnCharAdded(const ASCIIKey: Integer); override;
    procedure DoNppnModified(sn: PSCNotification); override;
    procedure DoNppnUpdateAutoSelection(P: PAnsiChar); override;
    procedure DoChangePluginTheme; override;
    procedure DoNppnShutdown; override;

    procedure ShowAutocompletion(const TableName: string; Indx: TStringList);
    procedure FuncLog;
    procedure FuncPrForm;
    procedure FuncExecThisSQL(S: string);
    procedure FuncExecHelpSQL(help: THelpType; S: string);
    procedure FuncExecSQL;
    procedure FuncExecSQLPlan;
    procedure FuncInsertText(const S: string);
    procedure FuncInsertParam;
    procedure FuncReplaceProcParams;
    procedure FuncSP_HELP;
    procedure FuncSP_HELPINDEX;
    procedure FuncSP_HELPTEXT;
    procedure FuncAlignCode;
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

procedure f_REPLACEPROCPARAMS; cdecl;
begin
  Npp.FuncReplaceProcParams;
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

procedure f_FuncAlignCode; cdecl;
begin
  Npp.FuncAlignCode;
end;

{ TdiaPlugin }

constructor TdiaPlugin.Create;
var
  sk: TShortcutKey;
begin
  inherited;

  PluginName := 'Easy.dia';
  AddFuncItem(PluginName, _FuncLog);

  sk.IsCtrl := true; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := 120; // F9
  AddFuncItem('Пролить скрипт на базу', _FuncPrForm, sk);

  sk.IsCtrl := true; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := 69; // 'E'
  AddFuncItem('Выполнить запрос SQL', _FuncExecSQL, sk);
  AddFuncItem('Получить план запроса SQL', _FuncExecSQLPlan);

  AddFuncItem('-', nil );
  AddFuncItem('M_BUSINESSLOG_BEGIN'      ,f_M_BUSINESSLOG_BEGIN);
  AddFuncItem('M_BUSINESSLOG_BLOCK_BEGIN',f_M_BUSINESSLOG_BLOCK_BEGIN);
  AddFuncItem('M_BUSINESSLOG_BLOCK_END'  ,f_M_BUSINESSLOG_BLOCK_END);
  AddFuncItem('M_BUSINESSLOG_CHECKPOINT' ,f_M_BUSINESSLOG_CHECKPOINT);
  AddFuncItem('M_BUSINESSLOG_PARAM'      ,f_M_BUSINESSLOG_PARAM);
  AddFuncItem('M_LOG_TABLE_REQ'          ,f_M_LOG_TABLE_REQ);
  AddFuncItem('-', nil );
//  AddFuncItem('Параметризация процедуры' ,f_REPLACEPROCPARAMS);
//  AddFuncItem('Выровнять блок SQL кода' ,f_FuncAlignCode);


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
  for i := Low(cnstTracingChar) to High(cnstTracingChar) do
  begin
    if cnstTracingChar[i] = ASCIIKey then
    begin
      DoNppnTracingCharAdded(cnstTracingChar[i]);
      break;
    end;
  end;
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
var
  Size,StartPos,Position: NativeInt;
  S,S1: AnsiString;
  i: Integer;
begin
  if Assigned(FLogForm) then
  begin
    Size := Sci_Send(SCI_GETCURLINE, 0, 0);
//    S := AnsiString(StringOfChar(#0, Size+1));

    SetLength(S,Size);
    try
      Position := Sci_Send(SCI_GETCURLINE, Size, LPARAM(PAnsiChar(S)));
      if not HasV5Apis then
        SetLength(S,Size-1);
      StartPos := Position - Length(cnstI);
      if (StartPos > 0) and (Copy(S,StartPos,Length(cnstI))=cnstI) then
      begin
        S1 := Copy(S,1,StartPos-1);
        i := Pos(cnstT1,LowerCase(S1));
        if i>0 then
          S1 := Copy(S1,i+Length(cnstT1),MaxInt)
        else
        begin
          i := Pos(cnstT2,LowerCase(S1));
          if i>0 then
            S1 := Copy(S,i+Length(cnstT2),MaxInt)
        end;

        S1 := WholeWord(S1,1);
        if Length(S1) > 1 then FLogForm.DoSqlIndex(S1);
        Exit;
      end;

      StartPos := Position - Length(cnstI1);
      if (StartPos > 0) and (Copy(S,StartPos,Length(cnstI1))=cnstI1) then
      begin
        S1 := Copy(S,1,StartPos-1);
        i := Pos(cnstT1,S1);
        if i>0 then
          S1 := Copy(S1,i+Length(cnstT1),MaxInt)
        else
        begin
          i := Pos(cnstT2,S1);
          if i>0 then
            S1 := Copy(S,i+Length(cnstT2),MaxInt)
        end;

        S1 := WholeWord(S1,1);
        if Length(S1) > 1 then FLogForm.DoSqlIndex(S1);
        Exit;
      end;
    finally
      SetLength(S,0);
    end;
  end;
end;

procedure TdiaPlugin.ShowAutocompletion(const TableName: string; Indx: TStringList);
var
  Size: Integer;
  S: AnsiString;
begin
  Sci_Send(SCI_AUTOCCANCEL, 0, 0);
  Size := Sci_Send(SCI_GETCURLINE, 0, 0);

  SetLength(S,Size);
  Sci_Send(SCI_GETCURLINE, Size, LPARAM(PAnsiChar(S)));

  try
    if not HasV5Apis then
      SetLength(S,Size-1);
    if Pos(TableName+' ',S) > 0 then
    begin
      Indx.Delimiter := ' ';
      S := Indx.DelimitedText;
      Sci_Send(SCI_AUTOCSHOW, 0, LPARAM(PAnsiChar(S)));
    end;
  finally
    SetLength(S,0);
  end;
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

    tb8.ToolbarIcon := LoadImage(Hinstance, 'ISERVER', IMAGE_ICON, 0, 0, (LR_DEFAULTSIZE));
    tb8.ToolbarIconDarkMode := LoadImage(Hinstance, 'ISERVERDARK', IMAGE_ICON, 0, 0, (LR_DEFAULTSIZE));
    tb8.ToolbarBmp := LoadImage(Hinstance, 'PROLIVKA', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON_FORDARKMODE, WPARAM(self.CmdIdFromDlgId(1)), LPARAM(@tb8));

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

    tb.ToolbarIcon := 0;
    tb.ToolbarBmp := LoadImage(Hinstance, 'PROLIVKA', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON, WPARAM(self.CmdIdFromDlgId(1)), LPARAM(@tb));

    tb.ToolbarIcon := 0;
    tb.ToolbarBmp := LoadImage(Hinstance, 'SQL', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON, WPARAM(self.CmdIdFromDlgId(2)), LPARAM(@tb));

    tb.ToolbarIcon := 0;
    tb.ToolbarBmp := LoadImage(Hinstance, 'PLAN', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
    Npp_Send(NPPM_ADDTOOLBARICON, WPARAM(self.CmdIdFromDlgId(3)), LPARAM(@tb));
  end;


end;

procedure TdiaPlugin.FuncAlignCode;
  function GetRightWord(S: string): string;
  begin
    Result := trim(S);
    if Pos('=',Result) = 1 then
      Result := '= ' + trim(Copy(Result,2,MaxInt));
  end;
var
  S: AnsiString;
  Strings: TAlignStrings;
  i,j,iPos: Integer;
begin
  S := SelectedText;

  Strings := TAlignStrings.Create;
  try
    Strings.Text := S;
    for i := 0 to Strings.Count-1 do
    begin
      S := LowerCase(RemoveComments(Strings[i]));
      iPos := 0;
      for j := Low(cnstAlignStartWords) to High(cnstAlignStartWords) do
      begin
        iPos := Pos(cnstAlignStartWords[j],S);
        if iPos > 0 then
        begin
          Strings.AlignFrom(i,cnstAlignStartWords[j]);
          Break;
        end;
      end;
      if iPos > 0 then Break;
    end;

    if (iPos > 0) then
    begin
      S := UTF8Encode(Strings.Text);
      Sci_Send(SCI_REPLACESEL, 0, LPARAM(PAnsiChar(S)));
    end;
  finally
    Strings.Free;
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
              S0 := Trim(Copy(S,iPos+1,MaxInt));
              iPos := Pos(',',S0);
              if iPos > 0 then S0 := Copy(S0,1,iPos-1);
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
  i,j,iPos: Integer;
begin
  S0 := SelectedText;
  Strings := RemoveNoVarString(WholeWords(S0,NoDuplicates),CheckLeftSymbols);
  if Assigned(Strings) then
  begin
    try
      SText := GetText;
      //iPos := Pos(S0,SText);
      //SText := Copy(SText,1,iPos-1);

      SText := RemoveComments(SText);
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
              SText := Trim(Copy(Strings1[j],Length(Strings[i])+1,MaxInt));
              iPos := Pos(',',SText);
              if iPos>0 then SText := Copy(SText,1,iPos-1);
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

procedure TdiaPlugin.FuncReplaceProcParams;
var
  S0,S: AnsiString;
  Line: string;
  Strings,Strings1,Strings2: TStringList;
  Range: TCharacterRange;
  i,j,iPos,iPos1,cPos,cPos1: Integer;
begin
  S0 := SelectedText;
  Strings := TStringList.Create;
  Strings1:= TStringList.Create;
  Strings2:= TStringList.Create;
  try
    Strings.Text := S0;
    for i := 0 to Strings.Count-1 do
    begin
      iPos := Pos('%',Strings[i]);
      iPos1:= Pos('!',Strings[i]); //Это параметры в DFM форме
      cPos := Pos('''%',Strings[i]);
      cPos1:= Pos('!''',Strings[i]); //Это параметры в кавычках
      if cPos = 0 then
        cPos := Pos('"%',Strings[i]);
      if cPos1 = 0 then
        cPos1:= Pos('!"',Strings[i]); //Это параметры в кавычках

      if (iPos > 0) and (iPos1 > iPos) then
      begin
        S0 := RemoveComments(Copy(Strings[i],1,iPos-1));
        S0 := StringReplace(S0,' ','',[rfReplaceAll]);
        S0 := StringReplace(S0,',','',[rfReplaceAll]);
        S0 := StringReplace(S0,'=','',[rfReplaceAll]);
        S0 := StringReplace(S0,'''','',[rfReplaceAll]);
        S0 := StringReplace(S0,'"','',[rfReplaceAll]);
        S0 := trim(S0);
        if Pos('@',S0) = 1 then
        begin
          if Strings1.Count > 0 then
            Strings1.Add('       ' + S0)
          else
            Strings1.Add('select ' + S0);

          if cPos > 0  then
            S := RemoveComments(Copy(Strings[i],cPos,MaxInt))
          else
            S := RemoveComments(Copy(Strings[i],iPos,MaxInt));

          S := StringReplace(S,' ','',[rfReplaceAll]);
          S := StringReplace(S,',','',[rfReplaceAll]);
          S := trim(S);
          Strings2.Add(S);

          if (cPos > 0) and (cPos1 > 0) then
            S := Copy(Strings[i],1,cPos-1) + S0 + Copy(Strings[i],cPos1+2,MaxInt)
          else
            S := Copy(Strings[i],1,iPos-1) + S0 + Copy(Strings[i],iPos1+1,MaxInt);
          Strings[i] := S;
        end;
      end;

    end;

    j := 0;
    for i := 0 to Strings1.Count - 1 do
      j := Max(j,length(Strings1[i]));

    for i := 0 to Strings1.Count - 1 do
    begin
      Line := Strings1[i];
      Strings1[i] := Line.PadRight(j+1) + '= ' + Strings2[i];
    end;

    j := 0;
    for i := 0 to Strings1.Count - 1 do
      j := Max(j,length(Strings1[i]));

    for i := 0 to Strings1.Count - 2 do
    begin
      Line := Strings1[i];
      Strings1[i] := Line.PadRight(j+1) + ',';
    end;

    if Strings1.Count > 0 then
    begin
      Strings1.Add('');
      Strings1.AddStrings(Strings);
      //FuncInsertText(Strings1.Text);
      S := UTF8Encode(Strings1.Text);
      Sci_Send(SCI_REPLACESEL, 0, LPARAM(PAnsiChar(S)));
    end;

  finally
    Strings.Free;
    Strings1.Free;
    Strings2.Free;
  end;
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

{function TdiaPlugin.GetTextRange(const Range: TCharacterRange): nppString;
var pt: PTextRange; //Возвращает текст внутри переданного диапазона
    Size: LRESULT;
    S: AnsiString;
begin
  Size := (Range.cpMax - Range.cpMin)+1;
  GetMem(pt,SizeOf(TTextRange));
  GetMem(pt^.lpstrText,Size);
  try
    pt^.chrg := Range;
    Sci_Send(SCI_GETTEXTRANGE,0,LPARAM(pt));
    if not HasV5Apis then
      SetLength(S,Size-1);
    StrLCopy(PAnsiChar(S),pt^.lpstrText,Size-1);
  finally
    FreeMem(pt^.lpstrText,Size);
    FreeMem(pt,SizeOf(TTextRange));
    Result := S;
  end;
end;}

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
        iLen := Sci_Send(SCI_GETCURRENTPOS,0,0);
        Sci_Send(SCI_INSERTTEXT, WPARAM(-1), LPARAM(PAnsiChar(S)));
        Sci_Send(SCI_GOTOPOS,iLen + Length(S)+1,0);
      finally
        SetLength(S,0);
      end;
    end;
end;

end.
