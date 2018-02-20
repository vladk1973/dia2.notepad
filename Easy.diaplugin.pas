unit Easy.diaplugin;

interface

uses
  Winapi.Windows,  Winapi.Messages, System.SysUtils,
  Vcl.Dialogs, Vcl.Forms, Vcl.Controls,
  System.Classes, Vcl.ComCtrls, SciSupport, System.Contnrs, System.Math,
  NppPlugin, ConstUnit, logFormUnit, prUnit, lookupProcUnit;

type

  TdiaPlugin = class(TNppPlugin)
  private
    { Private declarations }
    FLogForm: TLogForm;
    Fpr: Tpr;
    FlForm: TlForm;
    procedure DoNppnTracingCharAdded(const Key: Integer);
    function CurrentPos: LRESULT;
    function GetTextRange(const Range: TCharacterRange): nppString;
  public
    constructor Create;

    procedure DoNppnToolbarModification; override;
    procedure DoNppnCharAdded(const ASCIIKey: Integer); override;
    procedure DoNppnModified(sn: PSCNotification); override;
    procedure DoNppnUpdateAutoSelection(P: PAnsiChar); override;

    procedure ShowAutocompletion(const TableName: string; Indx: TStringList);
    procedure ShowProcedureList;
    procedure FuncLog;
    procedure FuncPrForm(const Server: string = ''; const Base: string = '');
    procedure FuncExecSQL;
    procedure FuncExecSQLPlan;
    procedure FuncInsertText(const S: string);
    procedure FuncInsertParam;
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

procedure _FuncLForm; cdecl;
begin
  Npp.ShowProcedureList;
end;

{ TdiaPlugin }

constructor TdiaPlugin.Create;
var
  sk: TShortcutKey;
begin
  inherited;

  PluginName := 'Easy.dia';
  AddFuncItem('Показать результаты', _FuncLog);

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

  Sci_Send(SCI_SETMODEVENTMASK,SC_MOD_INSERTTEXT or SC_MOD_DELETETEXT,0);
end;

function TdiaPlugin.CurrentPos: LRESULT;
begin
  Result := Sci_Send(SCI_GETCURRENTPOS, 0, 0);
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

procedure TdiaPlugin.DoNppnTracingCharAdded(const Key: Integer);
var
  Size,StartPos,Position: NativeInt;
  S,S1: AnsiString;
  i: Integer;
begin
  if Assigned(FLogForm) then
  begin
    Size := Sci_Send(SCI_GETCURLINE, 0, 0);
    SetLength(S,Size);
    try
      Position := Sci_Send(SCI_GETCURLINE, 0, LPARAM(PAnsiChar(S)));
      SetLength(S,Size-1);
      StartPos := Position - Length(cnstI);
      if (StartPos > 0) and (Copy(S,StartPos,Length(cnstI))=cnstI) then
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
  Sci_Send(SCI_GETCURLINE, 0, LPARAM(PAnsiChar(S)));

  try
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

procedure TdiaPlugin.ShowProcedureList;
begin
  if not Assigned(FlForm) then FlForm := TlForm.Create(self, 0);
  (FlForm as TlForm).Show;
end;

procedure TdiaPlugin.DoNppnToolbarModification;
var
  tb: TToolbarIcons;
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
  tb.ToolbarBmp := LoadImage(Hinstance, 'PLANBUTTON', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE));
  Npp_Send(NPPM_ADDTOOLBARICON, WPARAM(self.CmdIdFromDlgId(3)), LPARAM(@tb));
end;

procedure TdiaPlugin.FuncExecSQL;
var S: string;
    N: integer;
begin
  if not Assigned(FLogForm) then
  begin
    FLogForm := TLogForm.Create(self, 0);
    TLogForm(FLogForm).DoConnect;
  end
  else
  begin
    S := SelectedText;
    N := Length(S);

    if N < 1 then
    begin
      S := GetText;
      N := Length(S);
    end;

    if (N > 1) and Assigned(FLogForm) then
    begin
      TLogForm(FLogForm).DoSql(S);
    end;
  end;
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

procedure TdiaPlugin.FuncInsertParam;
  function RemoveNoVarString(Strings: TStringList): TStringList;
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
          if S <>'' then
            Strings.Delete(i)
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
var
  S0,SText: AnsiString;
  Strings,Strings1: TStringList;
  Range: TCharacterRange;
  i,j,iPos: Integer;
begin
  S0 := SelectedText;
  Strings := RemoveNoVarString(WholeWords(S0,NoDuplicates));
  if Assigned(Strings) then
  begin
    try
      Range.cpMin := 0;
      Range.cpMax := CurrentPos;
      SText := RemoveComments(GetTextRange(Range));
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

procedure TdiaPlugin.FuncPrForm(const Server: string = ''; const Base: string = '');
begin
  if not Assigned(Fpr) then Fpr := Tpr.Create(self, 0);
  (Fpr as Tpr).DoPrForm(Server,Base);
end;

function TdiaPlugin.GetTextRange(const Range: TCharacterRange): nppString;
var pt: PTextRange; {Возвращает текст внутри переданного диапазона}
    Size: LRESULT;
    S: AnsiString;
begin
  Size := (Range.cpMax - Range.cpMin)+1;
  GetMem(pt,SizeOf(TTextRange));
  GetMem(pt^.lpstrText,Size);
  try
    pt^.chrg := Range;
    Sci_Send(SCI_GETTEXTRANGE,0,LPARAM(pt));
    SetLength(S,Size-1);
    StrLCopy(PAnsiChar(S),pt^.lpstrText,Size-1);
  finally
    FreeMem(pt^.lpstrText,Size);
    FreeMem(pt,SizeOf(TTextRange));
    Result := S;
  end;
end;

procedure TdiaPlugin.DoNppnUpdateAutoSelection(P: PAnsiChar);
var
  S: AnsiString;
  iLen: Integer;
begin
  S := P;
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
