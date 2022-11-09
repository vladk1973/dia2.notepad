unit SqlPPConsoleUnit;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  System.StrUtils, System.Variants, ConstUnit;

type
  TSqlPPConsole = class
  private
    FConsoleFile: TPathName;
    function TempPath: string;
  public
    function Run(Command: TCommand; Path: TPathName): boolean;
    property ConsoleFile: TPathName read FConsoleFile;
  end;

implementation

{ TSqlPPConsole }

function TSqlPPConsole.Run(Command: TCommand; Path: TPathName): boolean;
var
  i: integer;
  ATempPath, CurDir: string;
  stdOut: THandle;
  startUpInfo: TStartUpInfo;
  ProcInfo: TProcessInformation;
  SecAtrtrs: TSecurityAttributes;
  lpTempFileName: array[0..MAX_PATH] of char;
begin
  with SecAtrtrs do
  begin
    nLength := SizeOf(TSecurityAttributes);
    lpSecurityDescriptor := nil;
    bInheritHandle := true;
  end;

  FConsoleFile := '';
  ATempPath := TempPath;
  GetTempFileName(PChar(ATempPath), '~lpp', 0, lpTempFileName);
  CurDir := GetCurrentDir;
  try
    stdOut := CreateFile(lpTempFileName, GENERIC_WRITE, 0,  @SecAtrtrs,
      CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    FillChar(startUpInfo, SizeOf(TStartUpInfo), 0);

    startUpInfo.cb := SizeOf(TStartUpInfo);
    startUpInfo.hStdOutput := stdOut;
    startUpInfo.dwFlags :=  STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
    startUpInfo.wShowWindow := SW_HIDE;

    if Path <> '' then ChDir(Path);

    Result := CreateProcess(nil, PChar(Command),nil, nil, true,
                NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcInfo);

    if Result then
    begin
      try
        WaitForInputIdle(ProcInfo.hProcess, INFINITE);
        WaitForSingleObject(ProcInfo.hProcess, INFINITE);
      finally
        CloseHandle(ProcInfo.hProcess);
        CloseHandle(ProcInfo.hThread);
        CloseHandle(stdOut);
      end;

      i := StrLen(lpTempFileName);
      SetLength(FConsoleFile,i);
      StrCopy(PChar(FConsoleFile),lpTempFileName);
    end;
  finally
    ChDir(CurDir);
  end;
end;

function TSqlPPConsole.TempPath: string;
var
	i: integer;
begin
  SetLength(Result, MAX_PATH);
	i := GetTempPath(Length(Result), PChar(Result));
	SetLength(Result, i);
  IncludeTrailingPathDelimiter(Result);
end;

end.
