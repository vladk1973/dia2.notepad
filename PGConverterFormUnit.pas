unit PGConverterFormUnit;

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
  TPGConverterForm = class(TCustomDialogForm)
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    HistoryPopupMenu: TPopupMenu;
    cmdEdit: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    HistorySpeedButton: TSpeedButton;
    SpeedButton1: TSpeedButton;
    PathEdit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HistorySpeedButtonClick(Sender: TObject);
  private
    FPathHistory: TStringList;
    FPath: String;
    FÑommandString: String;
    function GetFileName: String;
    function GetTargetPath: TPathName;
    function GetFullFileName: String;
    procedure SaveSettings;
    procedure RestoreSettings;
    procedure SetExternalServer(const Value: String);
    procedure SetExternalBase(const Value: String);
    function GetCmd: String;
  protected
    procedure OnClickHistoryPopupMenu(Sender: TObject);
    procedure OnClearHistoryPopupMenu(Sender: TObject);
    procedure ChangeColorMode(Sender: TObject); override;
    property TargetPath: TPathName read GetTargetPath;
    property FullFileName: String read GetFullFileName;
  public
    function DoForm: TModalResult; override;
    property FileName: String read GetFileName;
    property Cmd: String read GetCmd;
    property Path: String read FPath;
  end;

implementation

uses GetFolderDialogUnit;

{$R *.dfm}

procedure TPGConverterForm.FormCreate(Sender: TObject);
begin
  inherited;
  FPathHistory := TStringList.Create;
end;

function TPGConverterForm.GetCmd: String;
begin
  Result := cmdEdit.Text;
end;

function TPGConverterForm.GetFileName: String;
begin
  Npp.GetFileName(Result);
end;

function TPGConverterForm.GetFullFileName: String;
begin
  Npp.GetFullFileName(Result);
end;

procedure TPGConverterForm.SpeedButton1Click(Sender: TObject);
var sFolder: String;
begin
  sFolder:= 'c:\';
  if GetFolderDialog(Application.Handle, PathEdit.Hint, sFolder) then
  begin
    PathEdit.Text := sFolder;
  end;
end;

procedure TPGConverterForm.OkBtnClick(Sender: TObject);
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

function TPGConverterForm.GetTargetPath: TPathName;
begin
  Result := PathEdit.Text;
end;

procedure TPGConverterForm.HistorySpeedButtonClick(Sender: TObject);
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
    NewItem.Caption := cnstPgClearMenuItemCaption;
    NewItem.OnClick := OnClearHistoryPopupMenu;
    HistoryPopupMenu.Items.Add(NewItem);

  end;

  aPoint := PathEdit.ClientToScreen(Point(PathEdit.Width,HistorySpeedButton.Height));
  HistoryPopupMenu.Popup(aPoint.X,aPoint.Y);
end;

procedure TPGConverterForm.ChangeColorMode(Sender: TObject);
begin
  inherited;
  if DarkMode then
  begin
    cmdEdit.BorderStyle := bsNone;
    PathEdit.BorderStyle := bsNone;
  end;
end;

function TPGConverterForm.DoForm: TModalResult;
begin
  RestoreSettings;
  Result := inherited DoForm;
end;

procedure TPGConverterForm.SaveSettings;
var Registry: TRegistry;
    i: integer;
    S: TPathName;
begin
  inherited;
  Registry := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Registry.RootKey := HKEY_CURRENT_USER;

    if not Registry.KeyExists(cnstDllKey) then Registry.CreateKey(cnstDllKey);

    if Registry.OpenKey(cnstDllKey + '\' + cnstPgFormKey, True) then
    begin
      Registry.WriteString('PathMemo',Trim(PathEdit.Text));
      Registry.WriteString('cmdEdit',Trim(cmdEdit.Text));
      Registry.CloseKey;
    end;

    S := Trim(PathEdit.Text);
    if (S<>'') and (FPathHistory.IndexOf(S)<0) then FPathHistory.Add(S);
    if FPathHistory.Count = 0 then
      Registry.DeleteKey(cnstDllKey + '\' + cnstPgHistKey)
    else
      if Registry.OpenKey(cnstDllKey + '\' + cnstPgHistKey, True) then
      begin
        for i := 0 to FPathHistory.Count - 1 do
          Registry.WriteString('Item' + IntToStr(i),FPathHistory[i]);
        Registry.CloseKey;
      end;

  finally
    Registry.Free;
  end;
end;

procedure TPGConverterForm.SetExternalBase(const Value: String);
begin

end;

procedure TPGConverterForm.SetExternalServer(const Value: String);
begin

end;

procedure TPGConverterForm.RestoreSettings;
var Registry: TRegistry;
    Server,Base: String;
    i: integer;
begin
  Registry := TRegistry.Create(KEY_READ);
  try
    Registry.RootKey := HKEY_CURRENT_USER;

    if Registry.OpenKey(cnstDllKey + '\' + cnstPgFormKey, False) then
    begin
      PathEdit.Text := Registry.ReadString('PathMemo');
      cmdEdit.Text := Registry.ReadString('cmdEdit');
      Registry.CloseKey;
    end;

    if Registry.OpenKey(cnstDllKey + '\' + cnstPgHistKey, False) then
    begin
      Registry.GetValueNames(FPathHistory);
      for i := 0 to FPathHistory.Count - 1 do
        FPathHistory[i] := Registry.ReadString(FPathHistory[i]);
      Registry.CloseKey;
    end;

    if cmdEdit.Text = '' then cmdEdit.Text := cnstPgCmd;

  finally
    Registry.Free;
  end;
end;

procedure TPGConverterForm.FormDestroy(Sender: TObject);
begin
  inherited;
  FPathHistory.Free;
end;

procedure TPGConverterForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then OkBtn.Click;
  if Key = VK_ESCAPE then CancelBtn.Click;
end;

procedure TPGConverterForm.OnClickHistoryPopupMenu(Sender: TObject);
begin
  PathEdit.Text := TMenuItem(Sender).Hint;
end;

procedure TPGConverterForm.OnClearHistoryPopupMenu(Sender: TObject);
var
  Registry : TRegistry;
begin
  HistoryPopupMenu.Items.Clear;
  FPathHistory.Clear;
  Registry := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    Registry.DeleteKey(cnstDllKey + '\' + cnstPgHistKey);
  finally
    Registry.Free;
  end;
end;

end.
