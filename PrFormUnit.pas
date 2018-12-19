unit PrFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.StrUtils, System.SysUtils,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, nppplugin, NppForms, System.Win.Registry,
  NppDockingForms, Vcl.StdCtrls, ConstUnit, Vcl.Clipbrd,
  Buttons, ExtCtrls, ActnList, Vcl.Menus, System.Actions;

type
  TPrForm = class(TNppForm)
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    Panel2: TPanel;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Panel3: TPanel;
    connectStrings: TComboBox;
    GroupBox2: TGroupBox;
    Panel4: TPanel;
    PathMemo: TMemo;
    SpeedButton1: TSpeedButton;
    ServerList: TComboBox;
    BaseList: TComboBox;
    Password: TComboBox;
    ActionList1: TActionList;
    PopupMenu1: TPopupMenu;
    PasteAction: TAction;
    ClearAction: TAction;
    CopyAction: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    actionLabel: TLabel;
    HistorySpeedButton: TSpeedButton;
    HistoryAction: TAction;
    HistoryPopupMenu: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure PasswordChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ServerListChange(Sender: TObject);
    procedure BaseListChange(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure ClearActionExecute(Sender: TObject);
    procedure CopyActionExecute(Sender: TObject);
    procedure PasteActionExecute(Sender: TObject);
    procedure HistoryActionExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPathHistory: TStringList;
    FExternalServer: String;
    FExternalBase: String;
    FPath: String;
    function GetServers: TStrings;
    function GetFileName: String;
    procedure ServerListFill;
    procedure BaseListFill;
    function GetTargetPath: TPath;
    function GetFullFileName: String;
    procedure SaveSettings;
    procedure RestoreSettings;
    procedure SetExternalServer(const Value: String);
    procedure SetExternalBase(const Value: String);
    function GetConnectString: String;
  protected
    procedure OnClickHistoryPopupMenu(Sender: TObject);
    procedure OnClearHistoryPopupMenu(Sender: TObject);
    property Servers: TStrings read GetServers;
    property TargetPath: TPath read GetTargetPath;
    property FullFileName: String read GetFullFileName;
  public
    procedure InitConnectionString;
    property FileName: String read GetFileName;
    property ConnectString: String read GetConnectString;
    property Path: String read FPath;

    property ExternalServer: String read FExternalServer write SetExternalServer;
    property ExternalBase: String read FExternalBase write SetExternalBase;
  end;

implementation

uses GetFolderDialogUnit;

{$R *.dfm}

procedure TPrForm.FormCreate(Sender: TObject);
begin
  inherited;
  Servers.Clear;
  BaseList.Items.Clear;

  FPathHistory := TStringList.Create;

  ServerListFill;
  RestoreSettings;
  ExternalServer := '';
  ExternalBase := '';
end;

function TPrForm.GetConnectString: String;
begin
  Result := connectStrings.Text;
end;

function TPrForm.GetFileName: String;
begin
  Npp.GetFileName(Result);
end;

function TPrForm.GetFullFileName: String;
begin
  Npp.GetFullFileName(Result);
end;

function TPrForm.GetServers: TStrings;
begin
  Result := ServerList.Items;
end;

procedure TPrForm.InitConnectionString;
begin
  if Password.Text = '' then Password.Text := 'dca 123456';
  connectStrings.Text := ChangeFileExt(FileName,'');
  connectStrings.Text := connectStrings.Text + ' ' + ServerList.Text;
  connectStrings.Text := connectStrings.Text + ' ' + BaseList.Text;
  connectStrings.Text := Trim(connectStrings.Text + ' ' + Password.Text);
end;

procedure TPrForm.BaseListFill;
var Registry: TRegistry;
begin
  if ExternalBase = '' then
  begin
    Registry := TRegistry.Create(KEY_READ);
    try
      Registry.RootKey := HKEY_CURRENT_USER;
      BaseList.Clear;
      if ServerList.ItemIndex > 0 then
      begin
        if Registry.OpenKey(cnstServersKey + '\' + ServerList.Items[ServerList.ItemIndex], False) then
        begin
          Registry.GetValueNames(BaseList.Items);
          BaseList.Items.Insert(0,'Выбор базы');
        end;
      end
      else
        BaseList.Items.Add('Выбор базы');
      if BaseList.Items.Count > 0 then BaseList.ItemIndex := 0;
    finally
      Registry.Free;
    end;
  end;
end;

procedure TPrForm.ServerListFill;
var Registry: TRegistry;
begin
  if ExternalServer = '' then
  begin
    Registry := TRegistry.Create(KEY_READ);
    try
      Registry.RootKey := HKEY_CURRENT_USER;
      Servers.Clear;
      if Registry.OpenKey(cnstServersKey, False) then
      begin
        Registry.GetKeyNames(Servers);
        Servers.Insert(0,'Выбор сервера');
        Registry.CloseKey;
      end
      else
        Servers.Add('Пусто');
      if ServerList.Items.Count > 0 then ServerList.ItemIndex := 0;
    finally
      Registry.Free;
    end;
  end;
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
  if GetFolderDialog(Application.Handle, GroupBox2.Caption, sFolder) then
  begin
    PathMemo.Lines.Clear;
    PathMemo.Lines.Add(sFolder);
  end;
end;

procedure TPrForm.ServerListChange(Sender: TObject);
begin
  inherited;
  BaseListFill;
  InitConnectionString;
end;

procedure TPrForm.BaseListChange(Sender: TObject);
begin
  inherited;
  InitConnectionString;
end;

procedure TPrForm.OkBtnClick(Sender: TObject);
  function CopyFileTo(const Source,Target: TPath): boolean;
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
var Target: TPath;
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

function TPrForm.GetTargetPath: TPath;
begin
  Result := StringReplace(Trim(PathMemo.Text),#13#10,'',[rfReplaceAll]);
end;

procedure TPrForm.ClearActionExecute(Sender: TObject);
begin
  inherited;
  PathMemo.Lines.Clear;
end;

procedure TPrForm.CopyActionExecute(Sender: TObject);
begin
  inherited;
  Clipboard.AsText := TargetPath;
end;

procedure TPrForm.PasteActionExecute(Sender: TObject);
var S: string;
begin
  inherited;
  S := Clipboard.AsText;
  if Length(S)>0 then
  begin
    PathMemo.Lines.Clear;
    PathMemo.Lines.Add(S);
  end;
end;

procedure TPrForm.SaveSettings;
var Registry: TRegistry;
    i: integer;
    S: TPath;
begin
  inherited;
  Registry := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Registry.RootKey := HKEY_CURRENT_USER;

    if not Registry.KeyExists(cnstDllKey) then Registry.CreateKey(cnstDllKey);

    if Registry.OpenKey(cnstDllKey + '\' + cnstPrFormKey, True) then
    begin
      if ServerList.Text <> '' then
        Registry.WriteString('Server',ServerList.Text);
      if BaseList.Text <> '' then
        Registry.WriteString('Base',BaseList.Text);
      Registry.WriteString('Connectionstring',
        Trim(StringReplace(connectStrings.Text,ChangeFileExt(FileName,''),'',[rfReplaceAll])));
      Registry.WriteString('Password',Trim(Password.Text));
      Registry.WriteString('PathMemo',Trim(PathMemo.Lines.Text));
      Registry.CloseKey;
    end;


    S := Trim(PathMemo.Lines.Text);
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

    if ExternalServer = '' then
    begin
      if Registry.OpenKey(cnstDllKey + '\' + cnstPrFormKey, False) then
      begin
        connectStrings.Text := ChangeFileExt(FileName,'') + ' ' + Registry.ReadString('Connectionstring');
        Server := Registry.ReadString('Server');
        Base := Registry.ReadString('Base');
        Password.Text := Registry.ReadString('Password');
        PathMemo.Lines.Text := Registry.ReadString('PathMemo');

        if Servers.Count > 1 then
        begin
          i := Servers.IndexOf(Server);
          if i < 0 then
          begin
            Servers.Add(Server);
            i := Servers.IndexOf(Server);
          end;

          if i > 0 then begin
            ServerList.ItemIndex := i;
            BaseListFill;

            if BaseList.Items.Count > 1 then
            begin
              i := BaseList.Items.IndexOf(Base);
              if i < 0 then
              begin
                BaseList.AddItem(Base,nil);
                i := BaseList.Items.IndexOf(Base);
              end;

              if i > 0 then BaseList.ItemIndex := i;
            end
          end;
        end;
        Registry.CloseKey;
      end
      else
      begin
        BaseListFill;
        InitConnectionString;
      end;
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

procedure TPrForm.HistoryActionExecute(Sender: TObject);
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

  aPoint := PathMemo.ClientToScreen(Point(PathMemo.Width,HistorySpeedButton.Height));
  HistoryPopupMenu.Popup(aPoint.X,aPoint.Y);
end;

procedure TPrForm.FormDestroy(Sender: TObject);
begin
  inherited;
  FPathHistory.Free;
end;

procedure TPrForm.OnClickHistoryPopupMenu(Sender: TObject);
begin
  PathMemo.Lines.Clear;
  PathMemo.Lines.Text := TMenuItem(Sender).Hint;
end;

procedure TPrForm.OnClearHistoryPopupMenu(Sender: TObject);
var
  Registry : TRegistry;
begin
//ShowMessage('aa');

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
  if Value <> '' then
  begin
    ServerList.Items.Clear;
    ServerList.Items.Add(Value);
    ServerList.ItemIndex := 0;
    ServerList.Enabled := False;
    Self.ActiveControl := Password;
  end;
end;

procedure TPrForm.SetExternalBase(const Value: String);
begin
  FExternalBase := Value;
  if Value <> '' then
  begin
    BaseList.Items.Clear;
    BaseList.Items.Add(Value);
    BaseList.ItemIndex := 0;
    BaseList.Enabled := False;
    Self.ActiveControl := Password;
  end;
end;

end.
