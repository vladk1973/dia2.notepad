unit CommandThreadUnit;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Winapi.ActiveX, ThreadUnit, ConstUnit, IOUtils;

type
  TPrThreadObject = class(TThreadExecObject)
  private
    FLogFile: TPathName;
    FDestinationPath: TPathName;
    FCommand: TCommand;

    procedure SetDestinationPath(const Value: TPathName);
    procedure SetCommand(const Value: TCommand);
  protected
    procedure Execute; override;
  public
    property LogFile: TPathName read FLogFile;

    property DestinationPath: TPathName read FDestinationPath write SetDestinationPath;
    property Command: TCommand read FCommand write SetCommand;
  end;

  TPgConversionThreadObject = class(TPrThreadObject)
  private
    FSourceFile: TFileName;
    FDestinationFile: TFileName;
    procedure SetSourceFile(const Value: TFileName);
    procedure SetDestinationFile(const Value: TFileName);
    procedure ConvertSourceFileToUniCode;
  protected
    procedure Execute; override;
  public
    property SourceFile: TFileName read FSourceFile write SetSourceFile;
    property DestinationFile: TFileName read FDestinationFile write SetDestinationFile;
  end;

implementation

uses SqlPPConsoleUnit, regUnit;

{ TCommandThreadObject }

procedure TPrThreadObject.Execute;
var
  PPConsole: TSqlPPConsole;
begin
  PPConsole := TSqlPPConsole.Create;
  try
    PPConsole.Run(Command, ExcludeTrailingPathDelimiter(DestinationPath));

    {Бесценные результаты проливки}
    if FileExists(PPConsole.ConsoleFile) then
    begin
      FLogFile := PPConsole.ConsoleFile;
    end;
  finally
    PPConsole.Free;
  end;
end;

procedure TPrThreadObject.SetCommand(const Value: TCommand);
begin
  FCommand := Value;
end;

procedure TPrThreadObject.SetDestinationPath(const Value: TPathName);
begin
  FDestinationPath := Value;
end;

{ TPgConversionThreadObject }

procedure TPgConversionThreadObject.ConvertSourceFileToUniCode;
var
  Strings: TStrings;
  S: string;
  PS: PAnsiChar;
  i,Len : Integer;
begin
  Strings := TStringList.Create;
  try
    Strings.LoadFromFile(FSourceFile);
    for i := 0 to Strings.Count-1 do
    begin
      S := Strings[i];
      Len := Length(S);
      if Len=0 then continue;

      GetMem(PS, Len + 1);
      try
        StrPCopy(PS, AnsiString(S));
        OemToAnsi(PS, PS);
        Strings[i] := String(PS);
      finally
        FreeMem(PS);
      end;
    end;
    Strings.WriteBOM := False;
    Strings.SaveToFile(DestinationFile,TEncoding.UTF8);
  finally
    Strings.Free;
  end;
end;

procedure TPgConversionThreadObject.Execute;
var
  ConvertString: string;
begin
  ConvertSourceFileToUniCode;
  ConvertString := TOptionsReg.GetPostgreSQLConvertString;
  Command := Format(ConvertString,[FDestinationFile]);
  inherited;

  if IOUtils.TFile.Exists(FLogFile) then
    IOUtils.TFile.Copy(FLogFile, FDestinationFile, True);
end;

procedure TPgConversionThreadObject.SetDestinationFile(const Value: TFileName);
begin
  FDestinationFile := Value;
end;

procedure TPgConversionThreadObject.SetSourceFile(const Value: TFileName);
begin
  FSourceFile := Value;
end;

end.
