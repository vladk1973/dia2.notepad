unit PrFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.StrUtils, System.SysUtils,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, nppplugin, NppForms, System.Win.Registry,
  NppDockingForms, Vcl.StdCtrls, ConstUnit, Vcl.Clipbrd,
  Buttons, ExtCtrls, ActnList, Vcl.Menus, System.Actions,
  {$IFNDEF NPPCONNECTIONS}diaConstUnit,{$ENDIF}
  CustomDialogUnit;

type
  TPrForm = class(TCustomDialogForm)
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    HistoryPopupMenu: TPopupMenu;
    Password: TEdit;
    cmdEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    HistorySpeedButton: TSpeedButton;
    SpeedButton1: TSpeedButton;
    PathEdit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure PasswordChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HistorySpeedButtonClick(Sender: TObject);
  private
    FPathHistory: TStringList;
    FExternalServer: String;
    FExternalBase: String;
    FPath: String;
    F�onnectString: String;
    FExternalPort: String;
    function GetFileName: String;
    function GetTargetPath: TPathName;
    function GetFullFileName: String;
    procedure SaveSettings;
    procedure RestoreSettings;
    procedure SetExternalServer(const Value: String);
    procedure SetExternalBase(const Value: String);
    function GetConnectString: String;
    procedure SetExternalPort(const Value: String);
  protected
    procedure OnClickHistoryPopupMenu(Sender: TObject);
    procedure OnClearHistoryPopupMenu(Sender: TObject);
    procedure ChangeColorMode(Sender: TObject); override;
    property TargetPath: TPathName read GetTargetPath;
    property FullFileName: String read GetFullFileName;
  public
    function DoForm: TModalResult; override;
    procedure InitConnectionString;
    property FileName: String read GetFileName;
    property ConnectString: String read GetConnectString;
    property Path: String read FPath;

    property ExternalServer: String read FExternalServer write SetExternalServer;
    property ExternalPort: String read FExternalPort write SetExternalPort;
    property ExternalBase: String read FExternalBase write SetExternalBase;
  end;

implementation

uses GetFolderDialogUnit;

{$R *.dfm}

procedure TPrForm.FormCreate(Sender: TObject);
begin
  inherited;
  FPathHistory := TStringList.Create;
end;

function TPrForm.GetConnectString: String;
begin
  Result := F�onnectString;
end;

function TPrForm.GetFileName: String;
begin
  Npp.GetFileName(Result);
end;

function TPrForm.GetFullFileName: String;
begin
  Npp.GetFullFileName(Result);
end;

procedure TPrForm.InitConnectionString;
begin
  if Password.Text = '' then Password.Text := 'dca 123456';
  F�onnectString := ChangeFileExt(FileName,'');
  F�onnectString := F�onnectString + ' ' + FExternalServer;
  if FExternalPort <> '' then {��� PostgreSQL}
    F�onnectString := F�onnectString + ':' + FExternalPort;

  F�onnectString := F�onnectString + ' ' + FExternalBase;
  F�onnectString := Trim(F�onnectString + ' ' + Password.Text);
  cmdEdit.Text := '..\serv ' + F�onnectString;
end;

procedure TPrForm.PasswordChange(Sender: TObject);
begin
  inherited;
  InitConnectionString;
end;

procedure TPrForm.SpeedButton1Click(Sender: TObject);
var sFolder: String;
begin
  sFolder:= 'c:\';
  if GetFolderDialog(Application.Handle, Label3.Caption, sFolder) then
  begin
    PathEdit.Text := sFolder;
  end;
end;

procedure TPrForm.OkBtnClick(Sender: TObject);
  function CopyFileTo(const Source,Target: TPathName): boolean;
  begin
    Result := True;
    if Source <> Target then
    begin
      if FileExists(Target) then
      begin
        if FileIsReadOnly(Target) then FileSetReadOnly(Target,False);
      end;
      Result := CopyFile(nppPChar(Source),nppPChar(Target),False);
    end;
  end;
var Target: TPathName;
    Succ: boolean;
begin
  inherited;
  Self.Npp.SaveCurrentFile;
  SaveSettings;

  FPath := TargetPath;
  if FPath = '' then
  begin
    FPath := ExtractFilePath(FullFileName);
    Succ := True;
  end
  else
  begin
    Target := IncludeTrailingPathDelimiter(FPath) + FileName;
    Succ := CopyFileTo(FullFileName,Target);
    if not Succ then MessageError(Format(cnstFileCopyError,[Target]),cnstFileCopyErrorCaption);
  end;

  ModalResult := cnstModalResultArray[Succ];
end;

function TPrForm.GetTargetPath: TPathName;
begin
  Result := PathEdit.Text;
end;

procedure TPrForm.HistorySpeedButtonClick(Sender: TObject);
var aPoint: TPoint;
    i: integer;
    NewItem: TMenuItem;
begin
  inherited;
  HistoryPopupMenu.Items.Clear;
  for i := 0 to FPathHistory.Count - 1 do
  begin
    NewItem := TMenuItem.Create(Self);
    NewItem.Caption := FPathHistory[i];
    NewItem.Hint    := FPathHistory[i];
    NewItem.OnClick := OnClickHistoryPopupMenu;
    HistoryPopupMenu.Items.Add(NewItem);
  end;

  if FPathHistory.Count > 3 then
  begin
    NewItem := TMenuItem.Create(Self);
    NewItem.Caption := '-';
    HistoryPopupMenu.Items.Add(NewItem);

    NewItem := TMenuItem.Create(Self);
    NewItem.Caption := cnstPrClearMenuItemCaption;
    NewItem.OnClick := OnClearHistoryPopupMenu;
    HistoryPopupMenu.Items.Add(NewItem);

  end;

  aPoint := PathEdit.ClientToScreen(Point(PathEdit.Width,HistorySpeedButton.Height));
  HistoryPopupMenu.Popup(aPoint.X,aPoint.Y);
end;

procedure TPrForm.ChangeColorMode(Sender: TObject);
begin
  inherited;
  if DarkMode then
  begin
    Password.BorderStyle := bsNone;
    cmdEdit.BorderStyle := bsNone;
    PathEdit.BorderStyle := bsNone;
  end;
end;

function TPrForm.DoForm: TModalResult;
begin
  RestoreSettings;
  InitConnectionString;
  Result := inherited DoForm;
end;

procedure TPrForm.SaveSettings;
var Registry: TRegistry;
    i: integer;
    S: TPathName;
begin
  inherited;
  Registry := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Registry.RootKey := HKEY_CURRENT_USER;

    if not Registry.KeyExists(cnstDllKey) then Registry.CreateKey(cnstDllKey);

    if Registry.OpenKey(cnstDllKey + '\' + cnstPrFormKey, True) then
    begin
      Registry.WriteString('Password',Trim(Password.Text));
      Registry.WriteString('PathMemo',Trim(PathEdit.Text));
      Registry.CloseKey;
    end;


    S := Trim(PathEdit.Text);
    if (S<>'') and (FPathHistory.IndexOf(S)<0) then FPathHistory.Add(S);
    if FPathHistory.Count = 0 then
      Registry.DeleteKey(cnstDllKey + '\' + cnstPrHistKey)
    else
      if Registry.OpenKey(cnstDllKey + '\' + cnstPrHistKey, True) then
      begin
        for i := 0 to FPathHistory.Count - 1 do
          Registry.WriteString('Item' + IntToStr(i),FPathHistory[i]);
        Registry.CloseKey;
      end;

  finally
    Registry.Free;
  end;
end;

procedure TPrForm.RestoreSettings;
var Registry: TRegistry;
    Server,Base: String;
    i: integer;
begin
  Registry := TRegistry.Create(KEY_READ);
  try
    Registry.RootKey := HKEY_CURRENT_USER;

    if Registry.OpenKey(cnstDllKey + '\' + cnstPrFormKey, False) then
    begin
      Password.Text := Registry.ReadString('Password');
      PathEdit.Text := Registry.ReadString('PathMemo');
      Registry.CloseKey;
    end;

    if Registry.OpenKey(cnstDllKey + '\' + cnstPrHistKey, False) then
    begin
      Registry.GetValueNames(FPathHistory);
      for i := 0 to FPathHistory.Count - 1 do
        FPathHistory[i] := Registry.ReadString(FPathHistory[i]);
      Registry.CloseKey;
    end;

  finally
    Registry.Free;
  end;
end;

procedure TPrForm.FormDestroy(Sender: TObject);
begin
  inherited;
  FPathHistory.Free;
end;

procedure TPrForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then OkBtn.Click;
  if Key = VK_ESCAPE then CancelBtn.Click;
end;

procedure TPrForm.OnClickHistoryPopupMenu(Sender: TObject);
begin
  PathEdit.Text := TMenuItem(Sender).Hint;
end;

procedure TPrForm.OnClearHistoryPopupMenu(Sender: TObject);
var
  Registry : TRegistry;
begin
  HistoryPopupMenu.Items.Clear;
  FPathHistory.Clear;
  Registry := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    Registry.DeleteKey(cnstDllKey + '\' + cnstPrHistKey);
  finally
    Registry.Free;
  end;
end;

procedure TPrForm.SetExternalServer(const Value: String);
begin
  FExternalServer := Value;
end;

procedure TPrForm.SetExternalBase(const Value: String);
begin
  FExternalBase := Value;
end;

procedure TPrForm.SetExternalPort(const Value: String);
begin
  FExternalPort := Value;
end;

end.
