unit prUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, NppDockingForms, Vcl.StdCtrls,
  Vcl.ExtCtrls, ConstUnit, System.Actions, Vcl.ActnList, System.ImageList,
  Vcl.ImgList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, Vcl.ToolWin,
  Vcl.Clipbrd, Winapi.ShellApi, System.Math, Vcl.ActnCtrls, Vcl.Menus;

type
  Tpr = class(TNppDockingForm)
    pr: TPanel;
    LogBox: TListBox;
    ActionManager1: TActionManager;
    Images: TImageList;
    BeforePrAction: TAction;
    AfterPrAction: TAction;
    PRAction: TAction;
    ReloadPrAction: TAction;
    InstallerLogAction: TAction;
    SubFileAction: TAction;
    CopyLogAction: TAction;
    LogPopupMenu: TPopupMenu;
    N1: TMenuItem;
    ResultLabel: TPanel;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    procedure BeforePrActionExecute(Sender: TObject);
    procedure AfterPrActionExecute(Sender: TObject);
    procedure PRActionExecute(Sender: TObject);
    procedure ReloadPrActionExecute(Sender: TObject);
    procedure LogBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure LogBoxDblClick(Sender: TObject);
    procedure InstallerLogActionExecute(Sender: TObject);
    procedure SubFileActionExecute(Sender: TObject);
    procedure SubFileActionUpdate(Sender: TObject);
    procedure CopyLogActionExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FSubFile: TPath;
    FLogFile: TPath;
    function IsErrorString(const S: string): boolean;
    procedure WMThreadMessage(var Msg: TMessage); message WM_USER_MESSAGE_FROM_THREAD;
  public
    { Public declarations }
    procedure DoPrForm(const Server: string = ''; const Base: string = '');
  end;

implementation

uses
  nppplugin, PrFormUnit, ThreadUnit, CommandThreadUnit, LogFormHelpersUnit;

{$R *.dfm}

procedure Tpr.AfterPrActionExecute(Sender: TObject);
var
  Obj: TPrThreadObject;
begin
  Obj := TPrThreadObject(TAction(Sender).Tag);
  if Obj.ErrMessage = '' then
  begin
    FLogFile := Obj.LogFile;
    if FLogFile <> '' then
    begin
      ResultLabel.Caption := Obj.Description;
      SubFileAction.Update;
      ReloadPRAction.Execute;
    end;
  end
  else
  begin
    FLogFile := '';
    FSubFile := '';
    SubFileAction.Update;
    LogBox.Items.Clear;
    LogBox.Items.Add(Obj.ErrMessage);
  end;
  Show;
end;

procedure Tpr.BeforePrActionExecute(Sender: TObject);
begin
  LogBox.Items.Clear;
  LogBox.Items.Add(cnstSqlWaitResults);
end;

procedure Tpr.CopyLogActionExecute(Sender: TObject);
begin
  Clipboard.AsText := LogBox.Items.Text;
end;

procedure Tpr.DoPrForm(const Server: string = ''; const Base: string = '');
var
  FPrForm: TPrForm;
  CmdThread: TPrThreadObject;
begin
  FPrForm := TPrForm.Create(self);
  try
    FPrForm.ExternalServer := Server;
    FPrForm.ExternalBase   := Base;
    FPrForm.InitConnectionString;
    if FPrForm.ShowModal = mrOk then
    begin
      ResultLabel.Caption := '';
      FSubFile := IncludeTrailingPathDelimiter(FPrForm.Path) + ChangeFileExt(FPrForm.FileName,cnstT01);
      CmdThread := TPrThreadObject.Create;
      CmdThread.Description := IncludeTrailingPathDelimiter(FPrForm.Path) + FPrForm.FileName;
      CmdThread.Command := Format(cnstBatch,[FPrForm.ConnectString]);
      CmdThread.DestinationPath := FPrForm.Path;
      CmdThread.OnBeforeAction := BeforePrAction;
      CmdThread.OnAfterAction := AfterPrAction;
      CmdThread.WinHandle := self.Handle;
      CmdThread.Start;
    end;
  finally
    FPrForm.Free;
  end;
end;

procedure Tpr.FormCreate(Sender: TObject);
begin
  LogBox.Align := alClient;
  LogBox.BorderStyle := bsNone;

  FSubFile := '';
  FLogFile := '';
end;

procedure Tpr.InstallerLogActionExecute(Sender: TObject);
begin
  ShellExecute(Npp.NppData.NppHandle, 'explore', nppPChar(Npp.InstallerLogPath(FSubFile)), nil, nil, SW_SHOWNORMAL);
end;

function Tpr.IsErrorString(const S: string): boolean;
begin
  Result := (S.IndexOf('Msg ')=0) or (S.IndexOf('Сообщение ')=0);
end;

procedure Tpr.LogBoxDblClick(Sender: TObject);
  function GetNumber(S: string): integer;
  var i: Longint;
      S0: string;
  begin
    Result := 0;
    S := S.Trim;
    S0 := '';
    for i := 1 to Length(S) do
      if cnstNumbers.IndexOf(S[i])>=0 then S0 := S0 + S[i];

    if S0.Length>0 then Result := S0.ToInteger;
  end;

  procedure GetProcNameAndErrorLine(const S: string;
    var ProcName: string; var LineNumber: integer);
  var Strings: TStrings;
      i: integer;
      S0: string;
  begin
    LineNumber := 0;
    ProcName := '';
    S0 := '|' + StringReplace(S,',','|,|',[rfReplaceAll]) + '|';
    Strings := TStringList.Create;
    try
      Strings.Delimiter := ',';
      Strings.QuoteChar := '|';
      Strings.DelimitedText := S0;
      //StringsToAnsi(Strings);
      i := Strings.Count - 1;
      if i > 0 then
      begin
        {Ищем номер}
        LineNumber := GetNumber(Strings[i]); //Предположительно, здесь "Line XXX" или "Строка XXX"

        {Ищем наименование процедуры}
        Dec(i);
        if i >= 0 then
        begin
          S0 := Trim(Strings[i]);
          i := Pos(' ',S0); //Предположительно, здесь "Procedure XXX"
          if i > 0 then
          begin
            S0 := Copy(S0,i+1,MaxInt);
            ProcName := RemoveGarbage(S0);
          end;
        end;
      end;
    finally
      Strings.Free;
    end;
  end;

var ItemNo: Integer;
    ProcName: string;
    Index,LineNumber: integer;
    Strings: TStrings;
begin
  ItemNo := LogBox.ItemIndex;
  if (ItemNo >= 0) and IsErrorString(LogBox.Items[ItemNo]) then
  begin
    if (FSubFile <> '') and FileExists(FSubFile) then
    begin
      GetProcNameAndErrorLine(LogBox.Items[ItemNo],ProcName,LineNumber);
      Index := 0;
      if ProcName <> '' then
      begin
        Strings := TStringList.Create;
        try
          Strings.LoadFromFile(FSubFile);
          Index := Strings.IndexOf(cnstBeginProcArray[0] + ProcName);
          if Index < 0 then Index := Strings.IndexOf(cnstBeginProcArray[1] + ProcName);
          Inc(Index);
        finally
          Strings.Free;
        end;
      end;
      Self.Npp.DoOpen(FSubFile,LineNumber + Index - 1);
    end;
  end;
end;

procedure Tpr.LogBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  S: string;
  Offset: Integer;
begin
  with (Control as TListBox).Canvas do
	begin
  	FillRect(Rect);
  	Offset := 2;
    S := (Control as TListBox).Items[Index];

    if IsErrorString(S) then Images.Draw((Control as TListBox).Canvas,Rect.Left + Offset, Rect.Top,10);
    Offset := 22;
  	TextOut(Rect.Left + Offset, Rect.Top, S)
	end;
end;

procedure Tpr.PRActionExecute(Sender: TObject);
begin
  DoPrForm;
end;

procedure Tpr.ReloadPrActionExecute(Sender: TObject);
  procedure SetLogBoxHorzScrollBarVisible;
  var
    i, MaxWidth: integer;
  begin
    MaxWidth := 0;
    for i := 0 to LogBox.Items.Count - 1 do
      MaxWidth := Max(MaxWidth,LogBox.Canvas.TextWidth(LogBox.Items.Strings[i]+'wwwww'));
    SendMessage(LogBox.Handle, LB_SETHORIZONTALEXTENT, MaxWidth, 0);
  end;

var
  Strings: TStringList;
begin
  if (FLogFile <> '') and FileExists(FLogFile) then
  begin
    Strings := TStringList.Create;
    try
      Strings.LoadFromFile(FLogFile);
      StringsToAnsi(Strings);
      LogBox.Items.Clear;
      LogBox.Items.Assign(Strings);
    finally
      Strings.Free;
    end;
    SetLogBoxHorzScrollBarVisible;
  end;
end;

procedure Tpr.SubFileActionExecute(Sender: TObject);
begin
  if (FSubFile <> '') and FileExists(FSubFile) then Npp.DoOpen(FSubFile);
end;

procedure Tpr.SubFileActionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FSubFile <> '') and FileExists(FSubFile);
end;

procedure Tpr.WMThreadMessage(var Msg: TMessage);
var
  ExecObject: TExecObject;
begin
  ExecObject := TExecObject(Msg.LParam);
  try
    ExecObject.Finish;
  finally
    ExecObject.Free;
  end;
end;

end.
