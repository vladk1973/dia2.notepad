unit logFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, System.Math, Winapi.ShellApi,
  System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList, Vcl.OleCtrls,
  SHDocVw, Vcl.Grids, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, Vcl.ActnCtrls,
  StringGridsUnit, ConstUnit, ExtScrollingWinControlUnit, NppDockingForms, nppplugin,
  Vcl.ExtCtrls, Vcl.WinXCtrls, Vcl.ActnPopup, TreeViewExUnit;

type
  TlogForm = class(TNppDockingForm)
    Images: TImageList;
    ActionManager1: TActionManager;
    SQLAction: TAction;
    CopyGridRowAction: TAction;
    CopyAllGridAction: TAction;
    ConnectAction: TAction;
    DisonnectSQLAction: TAction;
    rtiRecordAction: TAction;
    rtiRecordStopAction: TAction;
    rtiSaveAction: TAction;
    rtiClearAction: TAction;
    AfterSQLAction: TAction;
    BasesPanel: TSplitView;
    OpenListBDAction: TAction;
    TreeImageList: TImageList;
    msModeAction: TAction;
    sybModeAction: TAction;
    ActionToolBar2: TActionToolBar;
    AfterAddServerAction: TAction;
    invTreeView: TTreeView;
    Panel1: TPanel;
    TabControl: TTabControl;
    sql: TPanel;
    invGrid: TStringGrid;
    ResultLabel: TPanel;
    TreeViewPopupMenu: TPopupMenu;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    RTI1: TMenuItem;
    N12: TMenuItem;
    GridMenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    RefreshButton: TToolButton;
    ToolButton3: TToolButton;
    RefreshMenu: TPopupMenu;
    AfterSQLIndexAction: TAction;
    RTI2: TMenuItem;
    N3: TMenuItem;
    AfterRTIAction: TAction;
    AfterClearRTIAction: TAction;
    SaveDialog: TSaveDialog;
    AfterWriteRTIAction: TAction;
    PrAction: TAction;
    N4: TMenuItem;
    N5: TMenuItem;
    odbcModeAction: TAction;
    tabPopupMenu: TPopupMenu;
    DeleteTabAction: TAction;
    N6: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure SQLActionExecute(Sender: TObject);
    procedure CopyAllGridActionExecute(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure OpenListBDActionExecute(Sender: TObject);
    procedure ConnectActionExecute(Sender: TObject);
    procedure msModeActionExecute(Sender: TObject);
    procedure sybModeActionExecute(Sender: TObject);
    procedure AfterAddServerActionExecute(Sender: TObject);
    procedure msTreeViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DisonnectSQLActionExecute(Sender: TObject);
    procedure DisonnectSQLActionUpdate(Sender: TObject);
    procedure rtiRecordActionUpdate(Sender: TObject);
    procedure AfterSQLActionExecute(Sender: TObject);
    procedure AfterSQLIndexActionExecute(Sender: TObject);
    procedure CopyGridRowActionExecute(Sender: TObject);
    procedure rtiRecordActionExecute(Sender: TObject);
    procedure AfterRTIActionExecute(Sender: TObject);
    procedure rtiRecordStopActionExecute(Sender: TObject);
    procedure rtiClearActionExecute(Sender: TObject);
    procedure AfterClearRTIActionExecute(Sender: TObject);
    procedure rtiSaveActionExecute(Sender: TObject);
    procedure AfterWriteRTIActionExecute(Sender: TObject);
    procedure PrActionExecute(Sender: TObject);
    procedure odbcModeActionExecute(Sender: TObject);
    procedure DeleteTabActionUpdate(Sender: TObject);
    procedure DeleteTabActionExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    msTreeView: TTreeViewEx;
    sybTreeView: TTreeViewEx;
    odbcTreeView: TTreeViewEx;

    FCurrentNode: TTreeNode;
    FRTIFileName: TFileName;
    function CreateBox: TExScrollBox;
    procedure HideAllExcept(const aIndex: Integer);
    function rtiFileName(const LoggerPath: TFileName): TFileName;

    const MaxTabIndex = 10;
    procedure WMThreadMessage(var Msg: TMessage); message WM_USER_MESSAGE_FROM_THREAD;

    procedure FillResultGrid(Results: TObjectStrings);

    procedure GridButtonClick(Sender: TObject);

    procedure SetCurrentNode(const Value: TTreeNode);
    function GetResultPanel: TExScrollBox;
  protected
    property CurrentNode: TTreeNode read FCurrentNode write SetCurrentNode;
    property ResultPanel: TExScrollBox read GetResultPanel;
  public
    procedure DoSql(const SqlText: string);
    procedure DoSqlIndex(const SqlText: string);
    procedure DoConnect;
  end;

implementation

uses
  Easy.diaplugin,Vcl.Clipbrd,
  ThreadUnit,StringGridExUnit,
  SqlThreadUnit,CommandThreadUnit,
  BDLoginUnit, LogFormHelpersUnit,
  LogWriterUnit
  ;


{$R *.dfm}

procedure TlogForm.DeleteTabActionExecute(Sender: TObject);
var
  aIndex: Integer;
  EBox: TExScrollBox;
begin
  aIndex := TabControl.TabIndex;
  if aIndex = TabControl.Tabs.Count-2 then
   TabControl.TabIndex := TabControl.TabIndex-1
  else
   TabControl.TabIndex := TabControl.TabIndex+1;


  HideAllExcept(TabControl.TabIndex);
  EBox := TExScrollBox(TabControl.Tabs.Objects[aIndex]);
  TabControl.Tabs.Delete(aIndex);

  sql.RemoveComponent(EBox);
  Ebox.Free;
end;

procedure TlogForm.DeleteTabActionUpdate(Sender: TObject);
begin
  inherited;
  TAction(Sender).Enabled := (TabControl.Tabs.Count>2)
    and (TabControl.TabOrder < (TabControl.Tabs.Count-1));
end;

procedure TlogForm.DisonnectSQLActionExecute(Sender: TObject);
var
  TreeNode: TTreeNode;
begin
  inherited;
  TreeNode := BasesPanel.CurrentNode;
  if Assigned(TreeNode) then
  begin
    if Assigned(TreeNode.Parent) then
      TreeNode := TreeNode.Parent;
    TreeNode.Delete;
  end;
end;

procedure TlogForm.DisonnectSQLActionUpdate(Sender: TObject);
var
  TreeNode: TTreeNode;
begin
  inherited;
  TreeNode := BasesPanel.CurrentNode;
  if Assigned(TreeNode) then
    TAction(Sender).Enabled := TreeNode.ItemType in [itServerMS,itServerSYB,itODBC]
  else
    TAction(Sender).Enabled := False;
end;

procedure TlogForm.ConnectActionExecute(Sender: TObject);
var
  FBDLoginForm: TBDLoginForm;
  BDType: TBdType;
  TreeView: TTreeViewEx;
  Data: string;
  Node: TTreeNode;
  SqlThread: TSqlQueryObject;
begin
  FBDLoginForm := TBDLoginForm.Create(Npp);
  BdType := BasesPanel.BdType;
  try
    FBDLoginForm.BDType := BdType;

    if FBDLoginForm.ShowModal = mrOK then
    begin
      TreeView := BasesPanel.CurrentTreeView;
      Data := FBDLoginForm.Data;
      Node := TreeView.NodeFoundByDataSource(TreeView,Data);
      if Assigned(Node) then
      begin
        Node.Selected := True;
        Node.Expanded := True
      end
      else
      begin
        SqlThread := TSqlQueryObject.Create;
        SqlThread.Description := Data;
        SqlThread.BdType := BdType;

        if BdType <> bdODBC then
          SqlThread.SQL.Text := FBDLoginForm.constDBList;

        SqlThread.ConnectionString := TSplitView.GetConnectionString(Data);
        SqlThread.OnAfterAction := AfterAddServerAction;
        SqlThread.WinHandle := self.Handle;
        SqlThread.Start; //Запрашивам список баз
      end;
    end;
  finally
    FBDLoginForm.Free;
  end;
end;

procedure TlogForm.CopyAllGridActionExecute(Sender: TObject);
begin
  if Self.ActiveControl is TStringGridEx then
    TStringGridEx(Self.ActiveControl).CopyAllToClipboard;
end;

procedure TlogForm.CopyGridRowActionExecute(Sender: TObject);
begin
  if Self.ActiveControl is TStringGridEx then
    TStringGridEx(Self.ActiveControl).CopyToClipboard;
end;

procedure TlogForm.AfterAddServerActionExecute(Sender: TObject);
var
  Obj: TSqlQueryObject;
  TreeView: TTreeViewEx;
begin
  Obj := TSqlQueryObject(TAction(Sender).Tag);
  if Obj.ErrMessage = '' then
  begin
    case Obj.BdType of
      bdMSSQL: TreeView := msTreeView;
      bdSybase: TreeView := sybTreeView;
    else
      TreeView := odbcTreeView;
    end;

    TreeView.AddServer(Obj.Description,Obj.Login,Obj.Query);
    //TreeView.Refresh;
  end
  else
   MessageError(Obj.ErrMessage,cnstErroCaption);
end;


procedure TlogForm.AfterSQLActionExecute(Sender: TObject);
  function GetDots(const S: string): string;
  begin
    if length(S) > 150 then
      Result := '...'
    else
      Result := '';
  end;
  procedure SetItem(const Value: string);
  var
    i: integer;
    NewItem: TMenuItem;
    S: string;
  begin
    if Length(Value) > 3 then
    begin
      //RefreshButton.Hint := Value;
      for i := 0 to RefreshMenu.Items.Count - 1 do
        if RefreshMenu.Items[i].Hint = Value then Exit;

      S := Trim(StringReplace(Value,sLineBreak,' ',[rfReplaceAll]));
      NewItem := TMenuItem.Create(RefreshMenu);
      RefreshMenu.Items.Add(NewItem);
      NewItem.Caption := Copy(S,1,150) + GetDots(S);
      NewItem.Hint := Value;
      NewItem.OnClick := SQLActionExecute;
      NewItem.ImageIndex := 0;
    end
  end;


var
  Obj: TSqlExecutorObject;
begin
  Obj := TSqlExecutorObject(TAction(Sender).Tag);
  if Obj.ErrMessage = '' then
  begin
    FillResultGrid(Obj.Grids);
    SetItem(Obj.Description);//Добавляем пункт меню
    Show;
  end
  else
   MessageError(Obj.ErrMessage,cnstErroCaption);
end;

procedure TlogForm.AfterSQLIndexActionExecute(Sender: TObject);
var
  Obj: TSqlIndexObject;
begin
  Obj := TSqlIndexObject(TAction(Sender).Tag);
  if (Obj.ErrMessage = '') and (Obj.Indexes.Count>0) then
    TDiaPlugin(Npp).ShowAutocompletion(Obj.Description,Obj.Indexes);
end;

procedure TlogForm.AfterWriteRTIActionExecute(Sender: TObject);
var
  Obj: TSqlQueryRTIObject;
begin
  Obj := TSqlQueryRTIObject(TAction(Sender).Tag);
  if Obj.ErrMessage = '' then
  begin
    if FileExists(Obj.Name) then
      MessageSimple(Format(cnstRecordAfterWriteRTIInformation,[Obj.Name]),cnstRecordConfirmationTitle)
    else
      MessageWarning(Format(cnstRecordAfterWriteRTIInformationNOFILE,[Obj.Name]),cnstRecordConfirmationTitle);
  end
  else
   MessageError(Obj.ErrMessage,cnstErroCaption);
end;

procedure TlogForm.AfterClearRTIActionExecute(Sender: TObject);
var
  Obj: TSqlQueryObject;
  TreeView: TTreeViewEx;
  i: Integer;
  FServer,FBase: string;
begin
  Obj := TSqlQueryObject(TAction(Sender).Tag);
  if Obj.ErrMessage = '' then
  begin
    FBase := Obj.Description;
    FServer := Obj.Name;

    TreeView := TTreeViewEx(Obj.UserTree);
    for i := 0 to TreeView.Items.Count-1 do
    begin
      if TreeView.Items[i].Text = FServer then
        if TreeView.Items[i].IndexOf(TTreeNode(Obj.UserObject)) >= 0 then
        begin
          MessageSimple(Format(cnstRecordClearInformation,[FBase]),cnstRecordConfirmationTitle);
          Exit;
        end;
    end;
  end
  else
   MessageError(Obj.ErrMessage,cnstErroCaption);
end;

procedure TlogForm.AfterRTIActionExecute(Sender: TObject);
var
  Obj: TSqlQueryObject;
  TreeView: TTreeViewEx;
  i: Integer;
  FServer,FBase: string;
begin
  Obj := TSqlQueryObject(TAction(Sender).Tag);
  if Obj.ErrMessage = '' then
  begin
    FBase := Obj.Description;
    FServer := Obj.Name;

    TreeView := TTreeViewEx(Obj.UserTree);
    for i := 0 to TreeView.Items.Count-1 do
    begin
      if TreeView.Items[i].Text = FServer then
        if TreeView.Items[i].IndexOf(TTreeNode(Obj.UserObject)) >= 0 then
        begin
          TTreeNode(Obj.UserObject).ItemType := TItemType(Obj.UserTag);
          //TreeView.Refresh;
          TreeView.Repaint;
          Exit;
        end;
    end;
  end
  else
   MessageError(Obj.ErrMessage,cnstErroCaption);
end;

procedure TlogForm.DoConnect;
begin
  ConnectAction.Execute;
end;

procedure TlogForm.DoSql(const SqlText: string);
var
  SqlThread: TSqlExecutorObject;
  CString,CName: string;
begin
  CString := BasesPanel.ConnectionString;
  CName := Format(cnstSqlExec,[
                               BasesPanel.CurrentServer,
                               BasesPanel.CurrentBase,
                               BasesPanel.CurrentUser
                               ]);
  if CString = '' then
  begin
    CString := ResultPanel.ConnectionString;
    CName   := ResultPanel.Description;
  end;

  if CString <> '' then
  begin
    SqlThread := TSqlExecutorObject.Create;
    SqlThread.Description := SqlText.Trim;
    SqlThread.BdType := BasesPanel.BdType;
    SqlThread.SQL.Text := SqlThread.Description;
    SqlThread.Name := CName;
    SqlThread.ConnectionString := CString;
    SqlThread.OnAfterAction := AfterSQLAction;
    SqlThread.WinHandle := self.Handle;
    SqlThread.Start;
  end
  else
    MessageError(cnstNoBaseSelected,cnstErroCaption);
end;

procedure TlogForm.DoSqlIndex(const SqlText: string);
var
  SqlThread: TSqlIndexObject;
  CString,CName: string;
begin
  CString := BasesPanel.ConnectionString;
  CName := Format(cnstSqlExec,[
                               BasesPanel.CurrentServer,
                               BasesPanel.CurrentBase,
                               BasesPanel.CurrentUser
                               ]);
  if CString = '' then
  begin
    CString := ResultPanel.ConnectionString;
    CName   := ResultPanel.Description;
  end;

  if CString <> '' then
  begin
    SqlThread := TSqlIndexObject.Create;
    SqlThread.SQL.Text := SqlText;
    SqlThread.Description := SqlText;
    SqlThread.BdType := BasesPanel.BdType;
    SqlThread.Name := CName;
    SqlThread.ConnectionString := CString;
    SqlThread.OnAfterAction := AfterSQLIndexAction;
    SqlThread.WinHandle := self.Handle;
    SqlThread.Start;
  end;
end;

procedure TlogForm.FormCreate(Sender: TObject);
begin
  NppDefaultDockingMask := DWS_DF_FLOATING;
  FRTIFileName := '';

  msTreeView := TTreeViewEx.Create(Self);
  msTreeView.Parent := BasesPanel;
  msTreeView.Images := TreeImageList;
  msTreeView.PopupMenu := TreeViewPopupMenu;
  msTreeView.BdType := bdMSSQL;

  sybTreeView := TTreeViewEx.Create(Self);
  sybTreeView.Parent := BasesPanel;
  sybTreeView.Images := TreeImageList;
  sybTreeView.PopupMenu := TreeViewPopupMenu;
  sybTreeView.BdType := bdSybase;


  odbcTreeView := TTreeViewEx.Create(Self);
  odbcTreeView.Parent := BasesPanel;
  odbcTreeView.Images := TreeImageList;
  odbcTreeView.PopupMenu := TreeViewPopupMenu;
  odbcTreeView.BdType := bdODBC;

  TabControl.Tabs.Objects[0] := CreateBox;
  TabControl.Tabs.Objects[1] := nil;
  msModeAction.Execute;
end;

procedure TlogForm.FormDestroy(Sender: TObject);
var
  i: Integer;
  EBox: TExScrollBox;
begin
  for i := 0 to TabControl.Tabs.Count-1 do
    if Assigned(TabControl.Tabs.Objects[i]) then
    begin
      EBox := TExScrollBox(TabControl.Tabs.Objects[i]);
      try
        sql.RemoveComponent(EBox);
      finally
        Ebox.Free;
        TabControl.Tabs.Objects[i] := nil;
      end;
    end;
end;

procedure TlogForm.FillResultGrid(Results: TObjectStrings);
var i,j,k,maxWidthGrid,aTop: integer;
    Temp: TComponent;
    Grid: TStringGridEx;
begin
  ResultLabel.Caption := Results.Name;

  maxWidthGrid := 0;
  Grid := nil;
  try

    for i := ResultPanel.ControlCount - 1 downto 0 do
    begin
      Temp := ResultPanel.Controls[i];
      if (Temp is TStringGrid) or (Temp is TButton) then
      begin
        ResultPanel.RemoveComponent(Temp);
        Temp.Free;
      end;
    end;

    ResultPanel.HorzScrollBar.Range := MaxInt;
    ResultPanel.VertScrollBar.Range:= MaxInt;
    ResultPanel.DisableAlign;
    ResultPanel.Description := Results.Name;
    ResultPanel.ConnectionString := Results.ConnectionString;


    Results.OwnsObjects := False;
    aTop := 0;
    for i := 0 to Results.Count - 1 do
    begin
      Grid := TStringGridEx(Results[i]);
      Grid.Parent := ResultPanel;
      ResultPanel.InsertComponent(Grid);

      Grid.Align := alTop;
      //Grid.Color := clBlue;
      //Grid.DisableAlign;

      {if Results.Count > 1 then
        Grid.Align := alNone
      else
      begin
        Grid.Align := alClient;
        Grid.ScrollBars := ssBoth;
      end;}

      Grid.FixedCols := 0;

      if Grid.RowCount > 1 then
        Grid.FixedRows := 1
      else
        Grid.FixedRows := 0;

      Grid.Options := Grid.Options + [goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goRangeSelect,goColSizing];
      if (Grid.ColCount = 1) and (Grid.RowCount = 1) then Grid.Options := [];


      Grid.Font.Assign(invGrid.Font);
    //  Grid.Height := {(Grid.DefaultRowHeight+2)} (Abs(invGrid.Font.Height)+2) * (Grid.RowCount+1);

      if Grid.Hint <> '' then
        Grid.OnButtonClick := GridButtonClick;
      Grid.PopupMenu := GridMenu;

      k := 0;
      for j := 0 to Grid.ColCount - 1 do
      begin
        Grid.ColWidths[j] := Grid.ColWidths[j] * Grid.Font.Size;
        k := k + Grid.ColWidths[j];
      end;
      Grid.Width := k+50;


      k := 0;
      for j := 0 to Grid.RowCount - 1 do
      begin
        k := k + Grid.RowHeights[j]+ Grid.GridLineWidth;
      end;
      Grid.Height := k+18;


      //Max(k,ResultPanel.Width);
      maxWidthGrid := Max(maxWidthGrid,Grid.Width);

      //Grid.Top := aTop;
     // Grid.SetBounds(0, aTop, Grid.Width, Grid.Height);

     // SetWindowPos(Grid.Handle, 0, 0, aTop, Grid.Width, Grid.Height,
     //   SWP_NOZORDER + SWP_NOACTIVATE);

      //Grid.Visible := True;

      aTop := aTop + Grid.Height + 1;

    end;

    ResultPanel.HorzScrollBar.Position := 0;
    ResultPanel.HorzScrollBar.Range := maxWidthGrid;
    ResultPanel.VertScrollBar.Position := 0;
    ResultPanel.VertScrollBar.Range := aTop;

    for k := Results.Count-1 downto 0 do
    begin
      if k = 0 then
        Grid := TStringGridEx(Results[0]);
      Results.Delete(k);
    end;
    if Assigned(Grid) and Grid.CanFocus then Grid.SetFocus;

  finally
    ResultPanel.EnableAlign;
    ResultPanel.ShowMe;
    //ResultPanel.Perform(WM_SETREDRAW, 1, 0);
  end;
end;

function TlogForm.GetResultPanel: TExScrollBox;
begin
  Result := TExScrollBox(TabControl.Tabs.Objects[TabControl.TabIndex]);
end;

procedure TlogForm.GridButtonClick(Sender: TObject);
var
  lpTempFileName: array[0..MAX_PATH] of char;
  i: integer;
  ATempPath: string;
  S: AnsiString;
  Stream: TFileStream;
begin
  if Confirmed(cnstOpenPlanMessage,'Подтверждение') then
  begin
    ATempPath := TempPath;
    GetTempFileName(PChar(ATempPath), 'p', 0, lpTempFileName);
    i := StrLen(lpTempFileName);
    if i > 0 then
    begin
      SetLength(ATempPath,i);
      StrCopy(PChar(ATempPath),lpTempFileName);
      if Sender is TStringGridEx then
      begin
        ATempPath := ChangeFileExt(ATempPath,cnstSqlplanExt);
        Stream := TFileStream.Create(ATempPath, fmCreate);
        try
          S := TStringGridEx(Sender).Hint;
          Stream.WriteBuffer(Pointer(S)^, Length(S));
        finally
          Stream.Free;
        end;
      end;

      if FileExists(ATempPath) then
        ShellExecute(Self.Npp.NppData.NppHandle, 'open', PChar(ATempPath), nil, nil, SW_SHOWNORMAL);

    end;
  end;
end;

procedure TlogForm.msModeActionExecute(Sender: TObject);
begin
  if not TAction(Sender).Checked then
  begin
    TAction(Sender).Checked := True;
    sybModeAction.Checked := False;
    odbcModeAction.Checked:= False;
    sybTreeView.HideMe;
    odbcTreeView.HideMe;
    msTreeView.ShowMe;
  end;
end;

procedure TlogForm.msTreeViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TreeView: TTreeViewEx;
  Node: TTreeNode;
begin
  TreeView := BasesPanel.CurrentTreeView;
  if Assigned(TreeView) then
  begin
    Node := TreeView.GetNodeAt(X,Y);
    if Assigned(Node) then Node.Selected := True;
  end;
end;

procedure TlogForm.odbcModeActionExecute(Sender: TObject);
begin
  if not TAction(Sender).Checked then
  begin
    TAction(Sender).Checked := True;
    msModeAction.Checked := False;
    sybModeAction.Checked:= False;
    msTreeView.HideMe;
    sybTreeView.HideMe;
    odbcTreeView.ShowMe;
  end;
end;

procedure TlogForm.OpenListBDActionExecute(Sender: TObject);
begin
  if BasesPanel.Opened then
    BasesPanel.Close
  else
    BasesPanel.Open;
end;

procedure TlogForm.PrActionExecute(Sender: TObject);
begin
  inherited;
  TdiaPlugin(Npp).FuncPrForm(BasesPanel.CurrentServer,BasesPanel.CurrentBase);
end;

procedure TlogForm.rtiClearActionExecute(Sender: TObject);
var
  SqlThread: TSqlQueryObject;
begin
  if Confirmed(Format(cnstRecordClearConfirmation,[BasesPanel.CurrentBase]),cnstRecordConfirmationTitle) then
  begin
    inherited;
    SqlThread := TSqlQueryObject.Create;
    SqlThread.SQL.Text := Format(constSQL_RTI_Clear,[BasesPanel.CurrentUser,BasesPanel.CurrentBase]);
    SqlThread.Description := BasesPanel.CurrentBase;
    SqlThread.BdType := BasesPanel.BdType;
    SqlThread.Name := BasesPanel.CurrentServer;
    SqlThread.UserObject := BasesPanel.CurrentNode;
    SqlThread.UserTree := BasesPanel.CurrentTreeView;
    SqlThread.ConnectionString := BasesPanel.ConnectionString;
    SqlThread.OnAfterAction := AfterClearRTIAction;
    SqlThread.WinHandle := self.Handle;
    SqlThread.Start;
  end;
end;

procedure TlogForm.rtiRecordActionExecute(Sender: TObject);
var
  SqlThread: TSqlQueryObject;
begin
  if Confirmed(Format(cnstRecordConfirmation,[BasesPanel.CurrentBase]),cnstRecordConfirmationTitle) then
  begin
    inherited;
    SqlThread := TSqlQueryObject.Create;
    SqlThread.SQL.Text := Format(constSQL_RTI,[BasesPanel.CurrentUser,1,1,1,BasesPanel.CurrentBase]);
    SqlThread.Description := BasesPanel.CurrentBase;
    SqlThread.BdType := BasesPanel.BdType;
    SqlThread.Name := BasesPanel.CurrentServer;
    SqlThread.UserObject := BasesPanel.CurrentNode;
    SqlThread.UserTree := BasesPanel.CurrentTreeView;
    SqlThread.UserTag := NativeInt(itBaseRTI);
    SqlThread.ConnectionString := BasesPanel.ConnectionString;
    SqlThread.OnAfterAction := AfterRTIAction;
    SqlThread.WinHandle := self.Handle;
    SqlThread.Start;
  end;
end;

procedure TlogForm.rtiRecordStopActionExecute(Sender: TObject);
var
  SqlThread: TSqlQueryObject;
begin
  if Confirmed(Format(cnstRecordStopConfirmation,[BasesPanel.CurrentBase]),cnstRecordConfirmationTitle) then
  begin
    inherited;
    SqlThread := TSqlQueryObject.Create;
    SqlThread.SQL.Text := Format(constSQL_RTI,[BasesPanel.CurrentUser,0,0,0,BasesPanel.CurrentBase]);
    SqlThread.Description := BasesPanel.CurrentBase;
    SqlThread.BdType := BasesPanel.BdType;
    SqlThread.Name := BasesPanel.CurrentServer;
    SqlThread.UserObject := BasesPanel.CurrentNode;
    SqlThread.UserTree := BasesPanel.CurrentTreeView;
    SqlThread.UserTag := NativeInt(itBase);
    SqlThread.ConnectionString := BasesPanel.ConnectionString;
    SqlThread.OnAfterAction := AfterRTIAction;
    SqlThread.WinHandle := self.Handle;
    SqlThread.Start;
  end;
end;

procedure TlogForm.rtiSaveActionExecute(Sender: TObject);
var
  F: string;
  SqlThread: TSqlQueryRTIObject;
begin
  if FRTIFileName <> '' then F := FRTIFileName
  else
    Npp.GetFullFileName(F);

  SaveDialog.InitialDir := ExtractFilePath(F);
  SaveDialog.FileName := ExtractFileName(rtiFileName(ExtractFilePath(F)));
  if SaveDialog.Execute then
  begin

    if FileExists(SaveDialog.FileName) then
    begin
       if Confirmed(Format(cnstRecordConfirmRewriteExistingFile,[SaveDialog.FileName]),cnstRecordConfirmationTitle) then
         //Если необходимо перезаписать - удаляем файл
         DeleteFile((SaveDialog.FileName))
       else
         Exit;
    end;

    FRTIFileName := SaveDialog.FileName;

    SqlThread := TSqlQueryRTIObject.Create;
    SqlThread.Name := SaveDialog.FileName;
    SqlThread.BdType := BasesPanel.BdType;
    SqlThread.ConnectionString := BasesPanel.ConnectionString;
    SqlThread.OnAfterAction := AfterWriteRTIAction;
    SqlThread.WinHandle := self.Handle;
    SqlThread.Start;
  end;
end;

procedure TlogForm.rtiRecordActionUpdate(Sender: TObject);
var
  TreeNode: TTreeNode;
begin
  inherited;
  TreeNode := BasesPanel.CurrentNode;
  if Assigned(TreeNode) then
    TAction(Sender).Enabled := TreeNode.ItemType in [itBase,itBaseRTI]
  else
    TAction(Sender).Enabled := False;
end;

procedure TlogForm.SetCurrentNode(const Value: TTreeNode);
begin
  FCurrentNode := Value;
end;

procedure TlogForm.SQLActionExecute(Sender: TObject);
var
  S: string;
begin
  if Sender is TMenuItem then
    S := TMenuItem(Sender).Hint
  else
    S := '';

  if not S.IsEmpty then
    DoSql(S)
  else
    TdiaPlugin(Npp).FuncExecSQL;
end;

procedure TlogForm.sybModeActionExecute(Sender: TObject);
begin
  if not TAction(Sender).Checked then
  begin
    TAction(Sender).Checked := True;
    msModeAction.Checked := False;
    odbcModeAction.Checked:= False;
    msTreeView.HideMe;
    odbcTreeView.HideMe;
    sybTreeView.ShowMe;
  end;
end;

function TlogForm.CreateBox: TExScrollBox;
var
  ResultPanel0: TExScrollBox;
begin
  ResultPanel0:= TExScrollBox.Create(sql);
  ResultPanel0.Parent := sql;
  ResultPanel0.Color := clWhite;
  ResultPanel0.DoubleBuffered := True;
  ResultPanel0.Align := alClient;
  ResultPanel0.BorderStyle := bsNone;
  ResultPanel0.Visible := True;
  Result := ResultPanel0;
end;

procedure TlogForm.HideAllExcept(const aIndex: Integer);
var
  i: Integer;
begin
  for i := 0 to TabControl.Tabs.Count-1 do
    if TabControl.Tabs.Objects[i] <> nil then
    begin
      if i = aIndex then
      begin
        TExScrollBox(TabControl.Tabs.Objects[i]).ShowMe;
        ResultLabel.Caption := TExScrollBox(TabControl.Tabs.Objects[i]).Description;
      end
      else
        TExScrollBox(TabControl.Tabs.Objects[i]).HideMe
    end;
end;

procedure TlogForm.TabControlChange(Sender: TObject);
var
  i: Integer;
begin
  i := TTabControl(Sender).TabIndex;

  if not Assigned(TTabControl(Sender).Tabs.Objects[i]) then
  begin
    if i = MaxTabIndex then
     TTabControl(Sender).TabIndex := i-1
    else
    begin
      TTabControl(Sender).Tabs.Objects[i] := CreateBox;
      with TTabControl(Sender).Tabs do
      begin
        Strings[i] := 'SQL';
        AddObject('Добавить',nil);
      end;
    end;
  end;
  HideAllExcept(i);
end;

procedure TlogForm.WMThreadMessage(var Msg: TMessage);
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

function TlogForm.rtiFileName(const LoggerPath: TFileName): TFileName;
  function GetHostName: String;
  var
    Buf: array[0..MAX_COMPUTERNAME_LENGTH] of char;
    BufLength: DWORD;
  begin
    BufLength := sizeof(Buf);
    if GetComputerName(Buf, BufLength) then
      Result := Buf
    else
      Result := '';
  end;
var S,CurrentBD,FFileName: string;
    Counter : integer;
begin
  Result := '';
  CurrentBD := BasesPanel.CurrentBase;
  if LoggerPath <> '' then Result := IncludeTrailingPathDelimiter(LoggerPath);
  if CurrentBD<>'' then
  begin
    S := Result + GetHostName + '_' +
         BasesPanel.CurrentUser + '_' +
         BasesPanel.CurrentServer + '_' +
         CurrentBD + '_SRV';

      Counter := -1;
      while True do
      begin
        // подбираем имя файла
        inc(Counter);
        FFileName := S;
        if Counter > 0 then
          FFileName := FFileName + '_' + IntToStr(Counter);
        if (FileExists(FFileName + '.rti')) then
          Continue;
        Break;
      end;
      Result := FFileName + '.rti';
  end;
end;

end.
