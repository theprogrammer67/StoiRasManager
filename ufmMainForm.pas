unit ufmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, RasHelperClasses,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.ComCtrls, Vcl.StdCtrls,
  Ras, Vcl.ToolWin, Vcl.Menus, uRASMngrCommon, Vcl.ExtCtrls, System.ImageList;

type
  TfrmMainForm = class(TForm)
    ilImages: TImageList;
    mmMainMenu: TMainMenu;
    mniFile1: TMenuItem;
    mniNew1: TMenuItem;
    mniOpen1: TMenuItem;
    mniSave1: TMenuItem;
    mniN1: TMenuItem;
    mniExit1: TMenuItem;
    mniAdditional: TMenuItem;
    pmPopup: TPopupMenu;
    mniConnectPopup: TMenuItem;
    mniDisconnectPopup: TMenuItem;
    tvConnections: TTreeView;
    mniN2: TMenuItem;
    mniAddConnection: TMenuItem;
    mniDeleteConnection: TMenuItem;
    mniEditConnection: TMenuItem;
    mniN3: TMenuItem;
    mniAbout1: TMenuItem;
    statStatus: TStatusBar;
    mniEditConnectionPopup: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mniNew1Click(Sender: TObject);
    procedure mniConnectPopupClick(Sender: TObject);
    procedure tvConnectionsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mniDisconnectPopupClick(Sender: TObject);
    // procedure tmrUpdTimerTimer(Sender: TObject);
    procedure mniOpen1Click(Sender: TObject);
    procedure mniSave1Click(Sender: TObject);
    procedure mniExit1Click(Sender: TObject);
    procedure mniEditConnectionClick(Sender: TObject);
    procedure mniAddConnectionClick(Sender: TObject);
    procedure mniAdditionalClick(Sender: TObject);
    procedure mniselected1Click(Sender: TObject);
    procedure mniEditConnectionPopupClick(Sender: TObject);
  private
    FSelConnectionInd: Integer;
    FOperationStatus: TOperationStatus;
    FAddRoute: Boolean;
    FRDPConnect: Boolean;
    FRouteNodeAddr: string;
    FRouteMask: string;
    FRDPFile: string;
  private
    procedure StoreSelConnectionInd;
    procedure ReStoreSelConnectionInd;
    procedure UpdateConnectionView(ANode: TTreeNode;
      APhonebookEntry: TRasPhonebookEntry);
  private
    function GetSelectedConnection: TRasPhonebookEntry;
    procedure UpdatePhonebookView;
    procedure Connect; overload;
    procedure Disconnect; overload;
    procedure EditConnection(AEntry: TRasPhonebookEntry); overload;
    procedure EditConnection; overload;
    procedure AddRouteToConnection(AEntry: TRasPhonebookEntry); overload;
  private
    procedure SaveSettings;
    procedure ReadSettings;
  private
    procedure OnMsgChangeState(var Msg: TMessage); message WM_CHANGESTATE;
    procedure OnMsgConnectionState(var Msg: TMessage); message WM_CONNSTATE;
    procedure OnMsgConnectionMessage(var Msg: TMessage); message WM_CONNMESSAGE;
  public
//    FPhonebook: TPhonebook;
  end;

var
  frmMainForm: TfrmMainForm;

implementation

uses Winapi.CommCtrl, RasUtils, ufmAdditional, Winapi.ShlObj,
  System.IniFiles, RasDlg, System.UITypes;

function GetSpecialPath(CSIDL: Word): string;
var
  S: string;
begin
  SetLength(S, MAX_PATH);
  if not SHGetSpecialFolderPath(0, PChar(S), CSIDL, True) then
    S := GetSpecialPath(CSIDL_APPDATA);
  Result := IncludeTrailingPathDelimiter(PChar(S));
end;


{$R *.dfm}
{ TfrmMainForm }

procedure TfrmMainForm.AddRouteToConnection(AEntry: TRasPhonebookEntry);
begin
  if AEntry.Connection.Connected then
    AddRoute(Application.Handle, FRouteNodeAddr, FRouteMask,
      AEntry.Connection.IPAddress);
end;

procedure TfrmMainForm.Connect;
var
  SelConnection: TRasPhonebookEntry;
begin
  SelConnection := GetSelectedConnection;
  if SelConnection = nil then
    Exit;

  SelConnection.NeedConnect := True;
end;

procedure TfrmMainForm.Disconnect;
var
  SelConnection: TRasPhonebookEntry;
begin
  SelConnection := GetSelectedConnection;
  if SelConnection = nil then
    Exit;

  SelConnection.NeedConnect := False;
end;

procedure TfrmMainForm.EditConnection(AEntry: TRasPhonebookEntry);
var
  LEntry: TRasEntryDlg;
begin
  FillChar(LEntry, SizeOf(TRasEntryDlg), 0);
  LEntry.dwFlags := 0;
  LEntry.dwSize := SizeOf(TRasEntryDlg);
  RasEntryDlg(nil, PWideChar(AEntry.Name), LEntry);
end;

procedure TfrmMainForm.EditConnection;
var
  SelConnection: TRasPhonebookEntry;
begin
  SelConnection := GetSelectedConnection;
  if SelConnection = nil then
    Exit;

  EditConnection(SelConnection);
  Phonebook.Refresh;
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  NotifyWnd := Self.Handle;

  FSelConnectionInd := -1;
  FOperationStatus := osUnknown;
  FAddRoute := False;
  FRDPConnect := False;
  FRouteNodeAddr := '';
  FRouteMask := '';
  FRDPFile := '';

  Phonebook := TPhonebook.Create(Self.Handle);

  tvConnections.Perform(TVM_SETITEMHEIGHT, 21, 0);

  ReadSettings;
  UpdatePhonebookView;
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  SaveSettings;
  FreeAndNil(Phonebook);
end;

function TfrmMainForm.GetSelectedConnection: TRasPhonebookEntry;
var
  SelNode: TTreeNode;
begin
  Result := nil;
  SelNode := tvConnections.Selected;
  if SelNode = nil then
    Exit;
  if SelNode.Level = 0 then
    Exit;

  while SelNode.Level <> 1 do
    SelNode := SelNode.Parent;

  Result := TRasPhonebookEntry(SelNode.Data);
end;

procedure TfrmMainForm.mniAddConnectionClick(Sender: TObject);
begin
  RasCreatePhonebookEntry(Self.Handle, nil);
end;

procedure TfrmMainForm.mniAdditionalClick(Sender: TObject);
begin
  with TfrmAdditional.Create(Self) do
    try
      chkAddRoute.Checked := FAddRoute;
      chkRDPConnect.Checked := FRDPConnect;
      edtNodeAddr.Text := FRouteNodeAddr;
      edtMask.Text := FRouteMask;
      edtRDPFile.Text := FRDPFile;

      if IsPositiveResult(ShowModal) then
      begin
        FAddRoute := chkAddRoute.Checked;
        FRDPConnect := chkRDPConnect.Checked;
        FRouteNodeAddr := edtNodeAddr.Text;
        FRouteMask := edtMask.Text;
        FRDPFile := edtRDPFile.Text;
        SaveSettings;
      end;
    finally
      Free;
    end;
end;

procedure TfrmMainForm.mniConnectPopupClick(Sender: TObject);
begin
  Connect;
end;

procedure TfrmMainForm.mniDisconnectPopupClick(Sender: TObject);
begin
  Disconnect;
end;

procedure TfrmMainForm.mniEditConnectionClick(Sender: TObject);
begin
  EditConnection;
end;

procedure TfrmMainForm.mniEditConnectionPopupClick(Sender: TObject);
begin
  EditConnection;
end;

procedure TfrmMainForm.mniExit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMainForm.mniNew1Click(Sender: TObject);
begin
  Phonebook.Refresh;
end;

procedure TfrmMainForm.mniOpen1Click(Sender: TObject);
begin
  Connect;
end;

procedure TfrmMainForm.mniSave1Click(Sender: TObject);
begin
  Disconnect;
end;

procedure TfrmMainForm.mniselected1Click(Sender: TObject);
begin
  ShowMessage(IntToStr(tvConnections.Selected.AbsoluteIndex));
  tvConnections.Selected := tvConnections.Items
    [tvConnections.Selected.AbsoluteIndex];
end;

procedure TfrmMainForm.OnMsgChangeState(var Msg: TMessage);
var
  I: Integer;
  Root, Node: TTreeNode;
  LItem: TRasPhonebookEntry;
begin
  if tvConnections.Items.Count = 0 then
    Exit;

  LItem := TRasPhonebookEntry(Msg.WParam);

  Root := tvConnections.Items[0];
  for I := 0 to Root.Count - 1 do
  begin
    Node := Root.Item[I];
    if Node.Data <> nil then
    begin
      if TRasPhonebookEntry(Node.Data) = LItem then
        UpdateConnectionView(Node, LItem);
    end;
  end;
end;

procedure TfrmMainForm.OnMsgConnectionMessage(var Msg: TMessage);
begin
  statStatus.Panels[0].Text := PChar(Msg.LParam);
end;

procedure TfrmMainForm.OnMsgConnectionState(var Msg: TMessage);
begin
  statStatus.Panels[0].Text := GetOperationStatusDescr
    (TOperationStatus(Msg.LParam));
end;

procedure TfrmMainForm.ReadSettings;
var
  FileName: string;
  DirName: string;
  IniFile: TIniFile;
begin
  FileName := GetSpecialPath(CSIDL_COMMON_APPDATA) + SettingsFileName;
  DirName := ExtractFilePath(FileName);
  ForceDirectories(DirName);

  IniFile := TIniFile.Create(FileName);
  try
    FAddRoute := IniFile.ReadBool('OPTIONS', 'AddRoute', False);
    FRDPConnect := IniFile.ReadBool('OPTIONS', 'RDPConnect', False);
    FRouteNodeAddr := IniFile.ReadString('OPTIONS', 'RouteNodeAddr', '');
    FRouteMask := IniFile.ReadString('OPTIONS', 'RouteMask', '');
    FRDPFile := IniFile.ReadString('OPTIONS', 'RDPFile', '');
  finally
    IniFile.Free;
  end;
end;

procedure TfrmMainForm.ReStoreSelConnectionInd;
begin
  if (FSelConnectionInd >= 0) and (tvConnections.Items.Count > FSelConnectionInd)
  then
  begin
    tvConnections.Enabled := True;
    tvConnections.Selected := tvConnections.Items[FSelConnectionInd];
//    ProcessMessages;
    tvConnections.SetFocus;
  end;
end;

procedure TfrmMainForm.SaveSettings;
var
  FileName: string;
  DirName: string;
  IniFile: TIniFile;
  // I: Integer;
begin
  FileName := GetSpecialPath(CSIDL_COMMON_APPDATA) + SettingsFileName;
  DirName := ExtractFilePath(FileName);
  ForceDirectories(DirName);

  IniFile := TIniFile.Create(FileName);
  try
    IniFile.WriteBool('OPTIONS', 'AddRoute', FAddRoute);
    IniFile.WriteBool('OPTIONS', 'RDPConnect', FRDPConnect);
    IniFile.WriteString('OPTIONS', 'RouteNodeAddr', FRouteNodeAddr);
    IniFile.WriteString('OPTIONS', 'RouteMask', FRouteMask);
    IniFile.WriteString('OPTIONS', 'RDPFile', FRDPFile);
  finally
    IniFile.Free;
  end;
end;

procedure TfrmMainForm.StoreSelConnectionInd;
begin
  if tvConnections.Selected <> nil then
    FSelConnectionInd := tvConnections.Selected.AbsoluteIndex
  else
    FSelConnectionInd := -1;
end;

procedure TfrmMainForm.tvConnectionsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  Node := TTreeView(Sender).GetNodeAt(X, Y);
  if Node = nil then
    Exit;

  if Button = mbRight then
    TTreeView(Sender).Selected := Node;
end;

procedure TfrmMainForm.UpdatePhonebookView;
var
  I: Integer;
  Root, Node, EntryNode, ConnectionNode: TTreeNode;
begin
  StoreSelConnectionInd;

  tvConnections.Items.BeginUpdate;
  try
    tvConnections.Items.Clear;
    Root := tvConnections.Items.AddFirst(nil, 'Connections');
    Root.SelectedIndex := 0;
    Root.ImageIndex := 0;
    for I := 0 to Phonebook.Count - 1 do
    begin
      EntryNode := tvConnections.Items.AddChildObject(Root, Phonebook[I].Name,
        Phonebook[I]);
      EntryNode.SelectedIndex := 1;
      EntryNode.ImageIndex := 1;

      Node := tvConnections.Items.AddChild(EntryNode,
        'Phone number: ' + Phonebook[I].PhoneNumber);
      Node.SelectedIndex := 3;
      Node.ImageIndex := 3;

      Node := tvConnections.Items.AddChild(EntryNode,
        'User name: ' + Phonebook[I].UserName);
      Node.SelectedIndex := 4;
      Node.ImageIndex := 4;

      ConnectionNode := tvConnections.Items.AddChild(EntryNode,
        'Connected: no');
      ConnectionNode.SelectedIndex := 7;
      ConnectionNode.ImageIndex := 7;

      UpdateConnectionView(EntryNode, Phonebook[I]);

      Root.Expand(False);
    end;
  finally
    ReStoreSelConnectionInd;

    tvConnections.Items.EndUpdate;
  end;
end;

procedure TfrmMainForm.UpdateConnectionView(ANode: TTreeNode;
  APhonebookEntry: TRasPhonebookEntry);
var
  LConnectionNode, LNode: TTreeNode;
begin
  if ANode.Count < 3 then
    Exit;

  LConnectionNode := ANode.Item[2];
  LConnectionNode.DeleteChildren;

  if not APhonebookEntry.Connection.Connected then
  begin
    ANode.SelectedIndex := 1;
    ANode.ImageIndex := 1;
    LConnectionNode.Text := 'Connected: no';
    Exit;
  end;

  ANode.SelectedIndex := 2;
  ANode.ImageIndex := 2;
  LConnectionNode.Text := 'Connected: yes';

  LNode := tvConnections.Items.AddChild(LConnectionNode,
    'Device: ' + APhonebookEntry.Connection.DeviceName);
  LNode.SelectedIndex := 5;
  LNode.ImageIndex := 5;
  LNode := tvConnections.Items.AddChild(LConnectionNode,
    'Status: ' + APhonebookEntry.Connection.ConnStatusStr);
  LNode.SelectedIndex := 6;
  LNode.ImageIndex := 6;
  LNode := tvConnections.Items.AddChild(LConnectionNode,
    'IP address: ' + APhonebookEntry.Connection.IPAddress);
  LNode.SelectedIndex := 8;
  LNode.ImageIndex := 8;

  if FAddRoute then
    AddRouteToConnection(APhonebookEntry);
end;

end.
