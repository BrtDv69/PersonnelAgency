unit Misk;

interface

uses WinSvc, Windows, SysUtils;

function CreateNTService(ExecutablePath, ServiceName: string): Boolean;
function DeleteNTService(ServiceName: string): boolean;
function FullRemoveDir(Dir: string; DeleteAllFilesAndFolders,
             StopIfNotAllDeleted, RemoveRoot: boolean): Boolean;
function ServiceStop(aMachine,aServiceName: string ): boolean;
function ServiceStart(aMachine, aServiceName: string ): boolean;

implementation

function CreateNTService(ExecutablePath, ServiceName: string): Boolean;
 var hNewService, hSCMgr: SC_HANDLE;
begin
 Result := False;
 hSCMgr := OpenSCManager(nil, nil, SC_MANAGER_CREATE_SERVICE);
 If (hSCMgr<>0) then
  Begin
   hNewService := CreateService(hSCMgr, PChar(ServiceName), PChar(ServiceName),
      STANDARD_RIGHTS_REQUIRED, SERVICE_WIN32_OWN_PROCESS or SERVICE_INTERACTIVE_PROCESS,
      SERVICE_AUTO_START, SERVICE_ERROR_NORMAL,
      PChar(ExecutablePath), nil, nil, nil, nil, nil);
   CloseServiceHandle(hSCMgr);
   If (hNewService <> 0) then
    Result := True
   else
    Result := False;
  End
end;

function DeleteNTService(ServiceName: string): Boolean;
var hServiceToDelete, hSCMgr: SC_HANDLE;
    RetVal: LongBool;
begin
 Result := False;
 hSCMgr := OpenSCManager(nil, nil, SC_MANAGER_CREATE_SERVICE);
 If (hSCMgr <> 0) then
  Begin
   hServiceToDelete := OpenService(hSCMgr, PChar(ServiceName), SERVICE_ALL_ACCESS);
   RetVal := DeleteService(hServiceToDelete);
   CloseServiceHandle(hSCMgr);
   Result := RetVal
  end
end;

function FullRemoveDir(Dir: string; DeleteAllFilesAndFolders,
  StopIfNotAllDeleted, RemoveRoot: boolean): Boolean;
var
  i: Integer;
  SRec: TSearchRec;
  FN: string;
begin
  Result := False;
  if not DirectoryExists(Dir) then
    exit;
  Result := True;
  // Добавляем слэш в конце и задаем маску - "все файлы и директории"
  Dir := IncludeTrailingBackslash(Dir);
  i := FindFirst(Dir + '*', faAnyFile, SRec);
  try
    while i = 0 do
    begin
      // Получаем полный путь к файлу или директорию
      FN := Dir + SRec.Name;
      // Если это директория
      if SRec.Attr = faDirectory then
      begin
        // Рекурсивный вызов этой же функции с ключом удаления корня
        if (SRec.Name <> '') and (SRec.Name <> '.') and (SRec.Name <> '..') then
        begin
          if DeleteAllFilesAndFolders then
            FileSetAttr(FN, faArchive);
          Result := FullRemoveDir(FN, DeleteAllFilesAndFolders,
            StopIfNotAllDeleted, True);
          if not Result and StopIfNotAllDeleted then
            exit;
        end;
      end
      else // Иначе удаляем файл
      begin
        if DeleteAllFilesAndFolders then
          FileSetAttr(FN, faArchive);
        Result := SysUtils.DeleteFile(FN);
        if not Result and StopIfNotAllDeleted then
          exit;
      end;
      // Берем следующий файл или директорию
      i := FindNext(SRec);
    end;
  finally
    SysUtils.FindClose(SRec);
  end;
  if not Result then
    exit;
  if RemoveRoot then // Если необходимо удалить корень - удаляем
    if not RemoveDir(Dir) then
      Result := false;
end;

function ServiceStart(aMachine, aServiceName: string ): boolean;
// aMachine это UNC путь, либо локальный компьютер если пусто
var
  h_manager,h_svc: SC_Handle;
  svc_status: TServiceStatus;
  Temp: PChar;
  dwCheckPoint: DWord;
begin
  svc_status.dwCurrentState := 1;
  h_manager := OpenSCManager(PChar(aMachine), nil, SC_MANAGER_CONNECT);
  if h_manager > 0 then
  begin
    h_svc := OpenService(h_manager, PChar(aServiceName),
    SERVICE_START or SERVICE_QUERY_STATUS);
    if h_svc > 0 then
    begin
      temp := nil;
      if (StartService(h_svc,0,temp)) then
        if (QueryServiceStatus(h_svc,svc_status)) then
        begin
          while (SERVICE_RUNNING <> svc_status.dwCurrentState) do
          begin
            dwCheckPoint := svc_status.dwCheckPoint;
            Sleep(svc_status.dwWaitHint);
            if (not QueryServiceStatus(h_svc,svc_status)) then
              break;
            if (svc_status.dwCheckPoint < dwCheckPoint) then
            begin
              // QueryServiceStatus не увеличивает dwCheckPoint
              break;
            end;
          end;
        end;
      CloseServiceHandle(h_svc);
    end;
    CloseServiceHandle(h_manager);
  end;
  Result := SERVICE_RUNNING = svc_status.dwCurrentState;
end;


function ServiceStop(aMachine,aServiceName: string ): boolean;
// aMachine это UNC путь, либо локальный компьютер если пусто
var
  h_manager, h_svc: SC_Handle;
  svc_status: TServiceStatus;
  dwCheckPoint: DWord;
begin
  h_manager:=OpenSCManager(PChar(aMachine),nil, SC_MANAGER_CONNECT);
  if h_manager > 0 then
  begin
    h_svc := OpenService(h_manager,PChar(aServiceName),
    SERVICE_STOP or SERVICE_QUERY_STATUS);
    if h_svc > 0 then
    begin
      if(ControlService(h_svc,SERVICE_CONTROL_STOP, svc_status))then
      begin
        if(QueryServiceStatus(h_svc,svc_status))then
        begin
          while(SERVICE_STOPPED <> svc_status.dwCurrentState)do
          begin
            dwCheckPoint := svc_status.dwCheckPoint;
            Sleep(svc_status.dwWaitHint);
            if(not QueryServiceStatus(h_svc,svc_status))then
            begin
              // couldn't check status
              break;
            end;
            if(svc_status.dwCheckPoint < dwCheckPoint)then
              break;
          end;
        end;
      end;
      CloseServiceHandle(h_svc);
    end;
    CloseServiceHandle(h_manager);
  end;
  Result := SERVICE_STOPPED = svc_status.dwCurrentState;
end;

end.
