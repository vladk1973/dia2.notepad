unit AlignStringsUnit;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Math, ConstUnit;


type

  TAlignStrings = class(TStringList)
  private
    procedure AlignDeclarations(const StartRow: Integer);
    procedure AlignVars(const StartRow: Integer; AlignColumn: Integer = 0);
    procedure AlignFunction(const StartRow: Integer; KeyWord: string);
  public
    procedure AlignFrom(const StartRow: Integer; KeyWord: string);
  end;

implementation

{ TAlignStrings }

procedure TAlignStrings.AlignFrom(const StartRow: Integer; KeyWord: string);
begin
  if KeyWord = cnstAlignStartWords[0] then AlignDeclarations(StartRow)
  else
    if KeyWord = cnstAlignStartWords[3] then
      AlignVars(StartRow)
    else
      AlignFunction(StartRow,KeyWord);
end;

procedure TAlignStrings.AlignDeclarations(const StartRow: Integer);
var
  iStartPos, iMax, iLen, iLenTotal, i: Integer;
  Line, S, Variables: string;
begin
  iMax := 0;
  iStartPos := Length(cnstAlignStartWords[0]) + 4;
  for i := StartRow to Count-1 do
  begin
    Line := String(WholeWord(AnsiString(Strings[i]),1));
    iLen := Line.Length;
    if (iLen>0) and (Line[1] = '@') then
      iMax := Max(iMax,iLen);
  end;

  if iMax > 0 then
  begin
    iLenTotal := 0;
    Variables := '';
    for i := StartRow to Count-1 do
    begin
      if i = StartRow then
        Strings[i] := StringReplace(Strings[i],cnstAlignStartWords[0],'',[rfIgnoreCase]);

      S := Strings[i];

      Line := String(WholeWord(AnsiString(S),1));
      iLen := Line.Length;
      if (iLen>0) and (Line[1] = '@') then
      begin
        if Pos(Line+',',Variables) = 0 then
        begin
          Variables := Variables + Line + ',';

          S := StringReplace(RemoveComments(S),',','',[]);
          S := StringReplace(S,Line,'',[rfIgnoreCase]).Trim;
          Strings[i] := Line.PadRight(iMax).PadLeft(iStartPos+iMax-1) + ' ' + S;
          iLenTotal := Max(iLenTotal,Strings[i].Length);
        end
        else
          if (Pos('--',Strings[i]) = 0) then
            Strings[i] := '--' + Strings[i];
      end;
    end;

    if iLenTotal > 0 then
    begin
      for i := StartRow to Count-1 do
      begin
        if i = StartRow then
        begin
          Strings[i] := '  ' + cnstAlignStartWords[0] + ' ' + Strings[i].TrimLeft;
        end;

        if (Pos('@',Strings[i]) > 0) and (Pos('--',Strings[i]) = 0) then
          Strings[i] := Strings[i].PadRight(iLenTotal) + ',';
      end;

      for i := Count-1 downto StartRow do
        if (Pos('@',Strings[i]) > 0) and (Pos('--',Strings[i]) = 0) then
        begin
          Strings[i] := StringReplace(Strings[i],',','',[]);
          Break;
        end;
    end;

  end;
end;

procedure TAlignStrings.AlignFunction(const StartRow: Integer; KeyWord: string);
var
  Words: TStringList;
  AlignColumn, Cnt: Integer;
begin
  if StartRow+1 < Count then
  begin
    Words := WholeWords(Strings[StartRow]);
    if Assigned(Words) then
    try
      Cnt := Words.Count;
      case Cnt of
        2 : AlignColumn := Pos(Words[1],Strings[StartRow])+2;
        3..255 : AlignColumn := Pos(Words[2],Strings[StartRow])+2;
      else
        AlignColumn := 0;
      end;
    finally
      Words.Free;
    end;
    AlignVars(StartRow+1, AlignColumn);
  end;
end;

procedure TAlignStrings.AlignVars(const StartRow: Integer; AlignColumn: Integer = 0);
var
  iStartPos, iMax, iLen, i: Integer;
  Line, S: string;
begin
  iMax := 0;
  if AlignColumn = 0 then
    iStartPos := Pos(cnstAlignStartWords[3],Strings[StartRow])
  else
    iStartPos := AlignColumn;

  for i := StartRow to Count-1 do
  begin
    Line := String(WholeWord(AnsiString(Strings[i]),1));
    iLen := Line.Length;
    if (iLen>0) and (Line[1] = '@') then
      iMax := Max(iMax,iLen);
  end;

  if iMax > 0 then
  begin
    for i := StartRow to Count-1 do
    begin
      S := Strings[i];

      Line := String(WholeWord(AnsiString(S),1));
      iLen := Line.Length;
      if (iLen>0) and (Line[1] = '@') then
      begin
        S := StringReplace(S,Line,'',[rfIgnoreCase]).Trim;
        iLen := Pos('=',S);
        if iLen = 1 then
          Strings[i] := Line.PadRight(iMax).PadLeft(iStartPos+iMax-1) + ' = ' + Copy(S,iLen+1,MaxInt).Trim
        else
          Strings[i] := Line.PadRight(iMax).PadLeft(iStartPos+iMax-1) + ' ' + S;

      end;
    end;
  end;
end;

end.
