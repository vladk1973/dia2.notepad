unit LogWriterUnit;

interface

uses
  System.SysUtils, Winapi.Windows, Vcl.Controls, Winapi.Messages, Vcl.Dialogs, Vcl.Forms,
  System.Classes, ComCtrls, System.Contnrs, System.Math,
  ConstUnit, SqlThreadUnit;

type
  TLogWriter = class
  private
    StrLine: string;
    FContinue: Boolean;
  public
    FFileName: string;
    constructor Create(FileName: string);
    procedure WriteToRTI(pStrLine: String);
    procedure ConvertMessageToRTI(pNumber, pDateTimeStr, pText: String);
    procedure AddLine(Value: string);
    procedure LogSave(Value: string);
  end;

  TSqlQueryRTIObject = class(TSqlQueryObject)
  private
    procedure WriteRecord(LogName: TFileName);
  protected
    procedure Execute; override;
  public
    //constructor Create;
  end;

implementation

{ TLogWriter }

procedure TLogWriter.AddLine(Value: string);
begin
  if FFileName <> '' then LogSave(Value);
end;

procedure TLogWriter.ConvertMessageToRTI(pNumber,
  pDateTimeStr, pText: String);
var
  vStrLine,
  vStrLine1,
  vStrLine2,
  vModuleID,
  vNumber: String;
  idx,
  idxc,
  idxm: Integer;


  function AddDsModule(const pModuleID, pStrLine: String): String;
  var
    vStr1,
    vStr2,
    vStr3,
    vStr4: String;
    i, j: Integer;
  begin
    Result := pStrLine;
    vStr1 := '';
    vStr2 := '';
    vStr3 := '';
    vStr4 := '';
    i := Pos('@@NESTLEVEL', UpperCase(pStrLine));
    if i > 0 then
    begin
      vStr1 := copy(pStrLine, 0, i - 1);
      vStr2 := copy(pStrLine, i, length(pStrLine) - i);
      j := Pos(LineEnd, UpperCase(vStr2));
      if j > 0 then
      begin
        vStr3 := copy(vStr2, 0, j - 1);
        vStr4 := copy(vStr2, j, length(vStr2) - j);
      end;
      Result := vStr1 + vStr3 + ' @@DsSysModuleID = ' + pModuleID + vStr4; 
    end;
  end;
begin
  vStrLine  := '';
  vStrLine1 := '';
  vStrLine2 := '';

  idxm := Pos(':', pNumber);
  vModuleID := copy(pNumber, 0, idxm - 1);
  vNumber := copy(pNumber, idxm + 1, length(pNumber) - idxm);

  idx := Pos('CONTINUE:', UpperCase(pText));
  if idx = 0 then
  begin
    FContinue := False;
    idxc := Pos('[CLIENT]', UpperCase(pText));
    if idxc > 0 then
    begin
      vStrLine := copy(pText, idxc + 8, length(pText) - 8);
    end
    else
    begin
      vStrLine := pDateTimeStr + c_TAB + pText;
      idx := Pos('[NNN]', UpperCase(vStrLine));
      if idx > 0 then
      begin
        vStrLine1 := copy(vStrLine, 0, idx - 1);
        vStrLine2 := AddDsModule(vModuleID,
                                 copy(vStrLine, idx - 1, length(vStrLine) - idx + 2));
        vStrLine := vStrLine1 + vNumber + vStrLine2;
      end;
    end;
  end
  else
  begin
    FContinue := True;
    vStrLine := StrLine + LineEnd +
                copy(pText, idx + 9, length(pText) - 9);
    StrLine  := '';
  end;

  if StrLine = '' then
  begin
    StrLine := vStrLine;
  end
  else
  begin
    if not FContinue then
    begin
      WriteToRTI(StrLine);
      StrLine := vStrLine;
    end;
  end;
end;

constructor TLogWriter.Create(FileName: string);
begin
  FFileName := FileName;
end;

procedure TLogWriter.LogSave(Value: string);
var
  filename : String;
  LogFile  : TextFile;
begin
  filename := FFileName;
  AssignFile(LogFile, filename);
  if FileExists(filename) then
    Append(LogFile)
  else
    Rewrite(LogFile);
  WriteLn(LogFile, Value);
  CloseFile(LogFile);
end;

procedure TLogWriter.WriteToRTI(pStrLine: String);
var
  vStrLine,
  vStrLine1,
  vStrLine2: string;
  vSize,
  idx: Integer;
begin
  vStrLine  := '';
  vStrLine1 := '';
  vStrLine2 := '';

  idx := Pos('[NNN]', UpperCase(pStrLine));
  if idx > 0 then
  begin
    vStrLine1 := copy(pStrLine, 0, idx - 1);
    vStrLine2 := copy(pStrLine, idx + 5, length(pStrLine) - idx - 4);
    vSize     := length(vStrLine2);

    vStrLine  := vStrLine1       +
                 ''              + c_TAB +
                 '0'             + c_TAB +
                 IntToStr(vSize) +
                 vStrLine2;
  end
  else
    vStrLine := pStrLine;

  AddLine(vStrLine);
end;

{ TSqlQueryRTIObject }

procedure TSqlQueryRTIObject.Execute;
begin
  inherited;
  if (not FThread.Terminated) then WriteRecord(Self.Name);
end;

procedure TSqlQueryRTIObject.WriteRecord(LogName: TFileName);
var LogWriter : TLogWriter;
    MinNumber: double;
    RecCount: integer;
    StrLine,CurNumber : string;
begin
  LogWriter := TLogWriter.Create(LogName);
  MinNumber := -1;

  try
    if not Query.Active then
    begin
      Query.SQL.Text := constSQL_RTI_Get;
      ConvertSqlText(BdType=bdSybase,TStringList(Query.SQL));
      Query.ParamCheck := True;
    end;

    repeat
      (*Начало цикла*)

      Query.Parameters.ParamByName('MinNumber').Value := MinNumber;
      Query.Open;
      RecCount := Query.RecordCount;
      Query.First;
      StrLine  := '';
      while not Query.Eof do
      begin
        CurNumber := Query.FieldByName('Number').AsString;
        LogWriter.ConvertMessageToRTI(Query.FieldByName('DsSysModuleID').AsString + ':' +
                            CurNumber,
                            FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', Query.FieldByName('InDateTime').AsDateTime),
                            Query.FieldByName('Message').AsString);
        Query.Next;
      end;
      if StrLine <> '' then
      begin
        LogWriter.WriteToRTI(StrLine);
      end;
      Query.Close;
      if CurNumber <> '' then
        MinNumber := StrToFloat(CurNumber);
      (*окончание цикла*)
    until RecCount = 0
  finally
    Query.Close;
    LogWriter.Free;
  end;
end;

end.
