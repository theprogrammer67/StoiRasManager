unit uRASMngrCommon;

interface

uses Winapi.Windows, Ras, RasHelperClasses, System.Classes, Winapi.Messages;

const
  ConnectionTimeout: Cardinal = 60000;
  SettingsFileName = 'RasManager\settings.ini';

const
  WM_CHANGESTATE = WM_USER + 0;
  WM_CONNSTATE = WM_USER + 1;
  WM_CONNMESSAGE = WM_USER + 2;

type
  TOperationStatus = (osConnected, osDisconnected, osProcessing, osUnknown);

  TControlThread = class(TThread)
  private const
    TIMEOUT = 1000;
  private
    FPollProc: TThreadProcedure;
  public
    constructor Create(APollProc: TThreadProcedure);
    procedure Execute; override;
  end;

  TConnectThread = class(TThread)
  private const
    TIMEOUT = 60000;
  private
    FEntry: TRasPhonebookEntry;
    FNotifyHwnd: THandle;
  public
    constructor Create(AEntry: TRasPhonebookEntry; ANotifyHwnd: THandle);
    procedure Execute; override;
  end;

  TPhonebook = class(TRasPhonebook)
  private
    FControlThread: TControlThread;
    FOwnerHwnd: THandle;
    FInited: Boolean;
    // FTmp: TConnectThread;
  private
    procedure CheckConnectionStatus(AItem: TRasPhonebookEntry);
    procedure UpdateConnections;
    procedure Poll;
  protected
    procedure DoRefresh; override;
  public
    constructor Create(AOwnerHwnd: THandle);
    destructor Destroy; override;
  public
    function FindEntry(const EntryName: string): TRasPhonebookEntry;
    procedure SetConnectionProcessDone(AConnectionHandle: THRasConn;
      ADisconnect: Boolean);
  end;

function GetOperationStatusDescr(AStatus: TOperationStatus): string;
procedure AddRoute(AppHandle: HWND; const Node, Mask, Gateway: string);

var
  NotifyWnd: THandle;
  Phonebook: TPhonebook;

implementation

uses System.SysUtils, Winapi.ShellAPI, RasUtils, RasError;

procedure RasDialFunc(AConnectionHandle: THRasConn; unMsg: UINT;
  AConnectionState: TRasConnState; AErrorCode: DWORD;
  AExtErrorCode: DWORD); stdcall;
var
  LMessage: string;
begin
  LMessage := RasConnStatusString(AConnectionState, AErrorCode);
  SendMessage(NotifyWnd, WM_CONNMESSAGE, 0, LPARAM(PChar(LMessage)));
  if AErrorCode <> 0 then
    RasHangUp(AConnectionHandle); // ќб€зательно разорвать соединение!

  if (AConnectionState = RASCS_Connected) or
    (AConnectionState = RASCS_Disconnected) or (AErrorCode <> 0) then
    Phonebook.SetConnectionProcessDone(AConnectionHandle, AErrorCode <> 0);
end;

function GetOperationStatusDescr(AStatus: TOperationStatus): string;
begin
  case AStatus of
    osConnected:
      Result := 'Connected';
    osDisconnected:
      Result := 'Disconnected';
    osProcessing:
      Result := 'Processing...';
    osUnknown:
      Result := 'Unknown state';
  end;
end;

procedure AddRoute(AppHandle: HWND; const Node, Mask, Gateway: string);
var
  Parameters: string;
begin
  Parameters := 'add ' + Node + ' mask ' + Mask + ' ' + Gateway;
  ShellExecute(AppHandle, '', 'route', PWideChar(Parameters), nil, SW_HIDE);
end;

{ TConnections }

procedure TPhonebook.CheckConnectionStatus(AItem: TRasPhonebookEntry);
begin
  if (AItem.NeedConnect = AItem.Connection.Connected) or (AItem.Connection.Busy)
  then
    Exit; // ≈сли соединение есть или устанавливаетс€ - пропускаем

  TConnectThread.Create(AItem, FOwnerHwnd);
end;

constructor TPhonebook.Create(AOwnerHwnd: THandle);
begin
  FOwnerHwnd := AOwnerHwnd;
  inherited Create;
  FInited := False;
  UpdateConnections;

  FControlThread := TControlThread.Create(Poll);
end;

destructor TPhonebook.Destroy;
begin
  FControlThread.Terminate;
  FControlThread.WaitFor;
  FreeAndNil(FControlThread);
  inherited;
end;

procedure TPhonebook.DoRefresh;
begin
  UpdateConnections;
  inherited;
end;

function TPhonebook.FindEntry(const EntryName: string): TRasPhonebookEntry;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Count - 1 do
  begin
    if Items[I].Name = EntryName then
    begin
      Result := Items[I];
      Exit;
    end;
  end;
end;

procedure TPhonebook.Poll;
begin
  try
    UpdateConnections;
  except
    SendMessage(FOwnerHwnd, WM_CONNMESSAGE, 0,
      LPARAM(PChar(Exception(ExceptObject).Message)));
  end;
end;

procedure TPhonebook.SetConnectionProcessDone(AConnectionHandle: THRasConn;
  ADisconnect: Boolean);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I].Connection.Handle = AConnectionHandle then
    begin
      Items[I].Connection.Busy := False;
      if ADisconnect then
        Items[I].Connection.HangUp;

      Exit;
    end;
  end;
end;

procedure TPhonebook.UpdateConnections;
var
  Entries, P: PRasConn;
  BufSize, NumberOfEntries, Res: DWORD;
  I, J: Integer;
  LFound: Boolean;

  procedure InitFirstEntry;
  begin
    ZeroMemory(Entries, BufSize);
    Entries^.dwSize := Sizeof(Entries^);
  end;

begin
  inherited;

  New(Entries);
  BufSize := Sizeof(Entries^);
  InitFirstEntry;
  Res := RasEnumConnections(Entries, BufSize, NumberOfEntries);
  if Res = ERROR_BUFFER_TOO_SMALL then
  begin
    ReallocMem(Entries, BufSize);
    InitFirstEntry;
    Res := RasEnumConnections(Entries, BufSize, NumberOfEntries);
  end;
  try
    RasCheck(Res);

    for I := 0 to Count - 1 do
    begin
      LFound := False;

      P := Entries;
      for J := 1 to NumberOfEntries do
      begin
        LFound := Items[I].Name = P^.szEntryName;
        if LFound then
          Items[I].Connection.RasConn := P^;
        Inc(P);
      end;

      if not LFound then
        Items[I].Connection.Handle := 0; // IsConnected = False

      if Items[I].Connection.Changed then
      begin
        PostMessage(FOwnerHwnd, WM_CHANGESTATE, Integer(Items[I]), 0);
        if Items[I].Connection.Connected then
        begin
          if Items[I].Connection.IPAddress <> '' then
            Items[I].Connection.Changed := False;
        end
        else
          Items[I].Connection.Changed := False;
      end;

      if FInited then
        CheckConnectionStatus(Items[I])
      else
        Items[I].NeedConnect := Items[I].Connection.Connected;
    end;
  finally
    FreeMem(Entries);
    FInited := True;
  end;
end;

{ TControlThread }

constructor TControlThread.Create(APollProc: TThreadProcedure);
begin
  inherited Create(False);
  FPollProc := APollProc;
end;

procedure TControlThread.Execute;
begin
  inherited;
  while not Terminated do
  begin
    Sleep(TIMEOUT);
    if Assigned(FPollProc) then
      FPollProc;
  end;
end;

{ TConnectThread }

constructor TConnectThread.Create(AEntry: TRasPhonebookEntry;
  ANotifyHwnd: THandle);
begin
  inherited Create(False);
  Self.FreeOnTerminate := True;

  FEntry := AEntry;
  FNotifyHwnd := ANotifyHwnd;
end;

procedure TConnectThread.Execute;
var
  Fp: LongBool;
  R: Integer;
  LHandle: THandle;
  LParams: TRasDialParams;
begin
  FEntry.Connection.Busy := True;

  FillChar(LParams, Sizeof(TRasDialParams), 0);
  with LParams do
  begin
    dwSize := Sizeof(TRasDialParams);
    StrPCopy(szEntryName, FEntry.Name);
  end;
  R := RasGetEntryDialParams(nil, LParams, Fp);
  if R = 0 then
  begin

    try
      SendMessage(FNotifyHwnd, WM_CONNSTATE, 0, Ord(osProcessing));
      if FEntry.NeedConnect then
      begin
        FEntry.Connection.Handle := 0;
        LHandle := 0;
        RasCheck(RasDial(nil, nil, @LParams, 1, @RasDialFunc, LHandle));
        FEntry.Connection.Handle := LHandle;
      end
      else
      begin
        if FEntry.Connection.Connected then
          FEntry.Connection.HangUp;
        FEntry.Connection.Busy := False;
        SendMessage(FNotifyHwnd, WM_CONNSTATE, 0, Ord(osDisconnected));
      end;
    except
      SendMessage(FNotifyHwnd, WM_CONNMESSAGE, 0,
        LPARAM(PChar(Exception(ExceptObject).Message)));
      FEntry.Connection.Busy := False;
    end;
  end;
end;

end.
