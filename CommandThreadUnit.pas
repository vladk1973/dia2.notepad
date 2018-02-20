unit CommandThreadUnit;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Winapi.ActiveX, ThreadUnit, ConstUnit;

type
  TPrThreadObject = class(TThreadExecObject)
  private
    FLogFile: TPath;
    FDestinationPath: TPath;
    FCommand: TCommand;

    procedure SetDestinationPath(const Value: TPath);
    procedure SetCommand(const Value: TCommand);
  protected
    procedure Execute; override;
  public
    property LogFile: TPath read FLogFile;

    property DestinationPath: TPath read FDestinationPath write SetDestinationPath;
    property Command: TCommand read FCommand write SetCommand;
  end;

implementation

uses SqlPPConsoleUnit;

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

procedure TPrThreadObject.SetDestinationPath(const Value: TPath);
begin
  FDestinationPath := Value;
end;

end.
