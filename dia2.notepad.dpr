library dia2.notepad;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Windows,
  Messages,
  System.SysUtils,
  System.Classes,
  ConstUnit in 'ConstUnit.pas',
  Easy.diaplugin in 'Easy.diaplugin.pas',
  ThreadUnit in 'ThreadUnit.pas',
  CommandThreadUnit in 'CommandThreadUnit.pas',
  SqlPPConsoleUnit in 'SqlPPConsoleUnit.pas',
  logFormUnit in 'logFormUnit.pas' {logForm},
  PrFormUnit in 'PrFormUnit.pas' {PrForm},
  GetFolderDialogUnit in 'GetFolderDialogUnit.pas',
  SqlThreadUnit in 'SqlThreadUnit.pas',
  StringGridsUnit in 'StringGridsUnit.pas',
  StringGridExUnit in 'StringGridExUnit.pas',
  ExtScrollingWinControlUnit in 'ExtScrollingWinControlUnit.pas',
  BDLoginUnit in 'BDLoginUnit.pas' {BDLoginForm},
  LogFormHelpersUnit in 'LogFormHelpersUnit.pas',
  TreeViewExUnit in 'TreeViewExUnit.pas',
  prUnit in 'prUnit.pas' {pr},
  LogWriterUnit in 'LogWriterUnit.pas',
  lookupProcUnit in 'lookupProcUnit.pas' {lForm},
  NppDockingForms in '..\npp.connections\lib\NppDockingForms.pas' {NppDockingForm},
  NppForms in '..\npp.connections\lib\NppForms.pas' {NppForm},
  nppplugin in '..\npp.connections\lib\nppplugin.pas',
  SciSupport in '..\npp.connections\lib\SciSupport.pas',
  AlignStringsUnit in 'AlignStringsUnit.pas';

{$R *.res}
{$R diaplugin.res}

{$Include 'NppPluginInclude.pas'}

begin
  { First, assign the procedure to the DLLProc variable }
  DllProc := @DLLEntryPoint;
  { Now invoke the procedure to reflect that the DLL is attaching to the process }
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.

