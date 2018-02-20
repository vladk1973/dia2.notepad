unit GetFolderDialogUnit;

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, Winapi.ShlObj;


function GetFolderDialog(Handle: Integer; Caption: string; var strFolder: string): Boolean;


implementation

uses nppplugin;

function BrowseCallbackProc(hwnd: HWND; uMsg: UINT; lParam: LPARAM; lpData: LPARAM): Integer; stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) then
    SendMessage(hwnd, BFFM_SETSELECTION, 1, lpData);
  BrowseCallbackProc:= 0;
end;

function GetFolderDialog(Handle: Integer; Caption: string; var strFolder: string): Boolean;
const
  BIF_STATUSTEXT           = $0004;
  BIF_NEWDIALOGSTYLE       = $0040;
  BIF_RETURNONLYFSDIRS     = $0080;
  BIF_SHAREABLE            = $0100;
  BIF_USENEWUI             = BIF_EDITBOX or BIF_NEWDIALOGSTYLE;

var
  BrowseInfo: TBrowseInfo;
  ItemIDList: PItemIDList;
  JtemIDList: PItemIDList;
  Path: PWideChar;
begin
  Result:= False;
  Path:= StrAlloc(MAX_PATH);
  SHGetSpecialFolderLocation(Handle, CSIDL_DRIVES, JtemIDList);
  with BrowseInfo do
  begin
    hwndOwner:= GetActiveWindow;
    pidlRoot:= JtemIDList;
    SHGetSpecialFolderLocation(hwndOwner, CSIDL_DRIVES, JtemIDList);

    { Возврат названия выбранного элемента }
    pszDisplayName:= StrAlloc(MAX_PATH);

    { Установка названия диалога выбора папки }
    lpszTitle:= nppPChar(Caption);
    { Флаги, контролирующие возврат }
    lpfn:= @BrowseCallbackProc;
    { Дополнительная информация, которая отдаётся обратно в обратный вызов (callback) }
    lParam:= NativeInt(nppPChar(strFolder));
  end;

  ItemIDList:= SHBrowseForFolder(BrowseInfo);

  if (ItemIDList <> nil) then
    if SHGetPathFromIDList(ItemIDList, Path) then
    begin
      strFolder:= Path;
      Result:= True;
    end;
end;

end.
