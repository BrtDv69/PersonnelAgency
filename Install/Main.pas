unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ExtCtrls, cxPC, cxControls, cxContainer, cxEdit, cxCheckBox, StdCtrls,
  cxButtons, cxTextEdit, cxShellBrowserDialog, cxMaskEdit, cxButtonEdit,
  cxMemo, Registry, RegStr, Dialogs, ShellApi, LbCipher, LbString,
  IB_Services;

type
  TfrmMain = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    cxPageControl1: TcxPageControl;
    tsChoose: TcxTabSheet;
    cbServer: TcxCheckBox;
    cbClient: TcxCheckBox;
    cbUninstall: TcxCheckBox;
    tsIntro: TcxTabSheet;
    Label1: TLabel;
    Panel2: TPanel;
    btNext: TcxButton;
    btClose: TcxButton;
    btPrevious: TcxButton;
    tsServer: TcxTabSheet;
    Label2: TLabel;
    sbDlg: TcxShellBrowserDialog;
    bteServer: TcxButtonEdit;
    tsClient: TcxTabSheet;
    Label3: TLabel;
    bteClient: TcxButtonEdit;
    tsProgres: TcxTabSheet;
    mProcess: TcxMemo;
    Label5: TLabel;
    lblServerPosition: TLabel;
    bteServerPosition: TcxButtonEdit;
    ibss: TpFIBSecurityService;
    Label4: TLabel;
    teAdminName: TcxTextEdit;
    Label6: TLabel;
    teAdminPass1: TcxTextEdit;
    teAdminPass2: TcxTextEdit;
    procedure FormCreate(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btNextClick(Sender: TObject);
    procedure btPreviousClick(Sender: TObject);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cbServerClick(Sender: TObject);
    procedure cbClientClick(Sender: TObject);
    procedure cbUninstallClick(Sender: TObject);
    procedure tsServerShow(Sender: TObject);
    procedure teAdminPass1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tsChooseShow(Sender: TObject);
  private
    { Private declarations }
    procedure Install;
    function GetProgramFiles : String;
    function GetServerPath : String;
    function GetClientPath : String;
    procedure Uninstall;
    procedure ServerInstall;
    procedure ClientInstall;
    procedure InstallFB;
    procedure InstallKeySrv;
    function GetTxt(Txt : String; MaxLength : Integer): String;
    function WorkingKeyDriver(Install : Boolean) : LongWord;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses Misk;

{$R *.dfm}
const MsgStr : array[1..4] of String = ('Невозможно начать установку драйверов.','Ошибка в процессе установки.','Недостаточно прав у пользователя.','Драйвер занят другим приложением.');

procedure TfrmMain.FormCreate(Sender: TObject);
 var W : Integer;
begin
 cxPageControl1.ActivePageIndex := 0;
 W := tsIntro.Width;
 cxPageControl1.HideTabs := True;
 frmMain.Width := frmMain.Width-tsIntro.Width+W;
 bteServer.Text := GetServerPath;
 bteClient.Text := GetClientPath
end;

procedure TfrmMain.cxPageControl1Change(Sender: TObject);
begin
 btPrevious.Visible := (cxPageControl1.ActivePageIndex<>0);
 If (cxPageControl1.ActivePageIndex=Pred(cxPageControl1.PageCount)) then
  btNext.Caption := 'Установить'
 else
  btNext.Caption := 'Далее'
end;

procedure TfrmMain.btCloseClick(Sender: TObject);
begin
 Close
end;

procedure TfrmMain.btNextClick(Sender: TObject);
begin
 If (cxPageControl1.ActivePageIndex=Pred(cxPageControl1.PageCount)) then
  Install
 else
  cxPageControl1.SelectNextPage(True,True)
end;

procedure TfrmMain.btPreviousClick(Sender: TObject);
begin
  cxPageControl1.SelectNextPage(False,True)
end;

procedure TfrmMain.cxButtonEdit1PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
 sbDlg.Path := (Sender as TcxButtonEdit).Text;
 If (sbDlg.Execute) then
  (Sender as TcxButtonEdit).Text := sbDlg.Path
end;

procedure TfrmMain.Install;
 var Crs : TCursor;
begin
 btPrevious.Enabled := False;
 btNext.Enabled := False;
 btClose.Enabled := False;
 Crs := Cursor;
 Screen.Cursor := crHourGlass;
 If (cbUninstall.Checked) then
  Begin
   Uninstall;
   mProcess.Lines.Add('Удаление программного комплекса завершено.')
  End
 else
  Begin
   If (cbServer.Checked) then
    ServerInstall;
   If (cbClient.Checked) then
    ClientInstall;
   mProcess.Lines.Add('Установка программного комплекса завершена.');
   MessageDlg('Установка ситемы Persona 1.0 NE прошла успешно',mtInformation,[mbOK],0)
  End;
 Screen.Cursor := Crs;
 btClose.Caption := 'Закрыть';
 btClose.Enabled := True
end;

function TfrmMain.GetProgramFiles : String;
var Reg : TRegistry;
begin
 Result := '';
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 If (Reg.KeyExists(REGSTR_PATH_SETUP)) then
  Begin
   Reg.OpenKeyReadOnly(REGSTR_PATH_SETUP);
   Result := Reg.ReadString('ProgramFilesDir')
  End; 
 Reg.Free
end;

function TfrmMain.GetServerPath : String;
var Reg : TRegistry;
begin
 Result := '';
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 If (Reg.KeyExists('\Software\BertSoftware\Persona')) then
  Begin
   Reg.OpenKeyReadOnly('\Software\BertSoftware\Persona');
   If (Reg.ValueExists('ServerInstallPath')) then
    Result := Reg.ReadString('ServerInstallPath');
  End;
 If (Result='') then
  Result := GetProgramFiles+'\Persona';
 Reg.Free
end;

function TfrmMain.GetClientPath : String;
var Reg : TRegistry;
begin
 Result := '';
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 If (Reg.KeyExists('\Software\BertSoftware\Persona')) then
  Begin
   Reg.OpenKeyReadOnly('\Software\BertSoftware\Persona');
   If (Reg.ValueExists('ClientInstallPath')) then
    Result := Reg.ReadString('ClientInstallPath');
  End;
 If (Result='') then
  Result := GetProgramFiles+'\Persona';
 Reg.Free
end;

procedure TfrmMain.Uninstall;
 var ServerPath : String;
     ClientPath : String;
     Reg : TRegistry;
     zAppName : array[0..512] of char;
     zCurDir : array[0..255] of char;
     StartupInfo : TStartupInfo;
     ProcessInfo : TProcessInformation;
begin
 mProcess.Lines.Add('Удаление...');
 mProcess.Lines.Add(' ');
 ServerPath := '';
 ClientPath := '';
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 If (Reg.KeyExists('\Software\BertSoftware\Persona')) then
  Begin
   Reg.OpenKeyReadOnly('\Software\BertSoftware\Persona');
   If (Reg.ValueExists('ServerInstallPath')) then
    ServerPath := Reg.ReadString('ServerInstallPath');
   If (Reg.ValueExists('ClientInstallPath')) then
    ClientPath := Reg.ReadString('ClientInstallPath');
  End;
 Reg.Free;
 If (ServerPath<>'') then
  Begin
   mProcess.Lines.Add('Удаление серверной части ...');
   mProcess.Lines.Add('->   Останов сервиса сервера баз данных...');
   Application.ProcessMessages;
   StrPCopy(zAppName,ServerPath+'\Firebird\bin\instsvc.exe stop');
   StrPCopy(zCurDir,ServerPath+'\Firebird\bin');
   FillChar(StartupInfo,Sizeof(StartupInfo),#0);
   StartupInfo.cb := Sizeof(StartupInfo);
   StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
   StartupInfo.wShowWindow := 1;
   CreateProcess(nil,
                 zAppName,                      { указатель командной строки }
                 nil,                           { указатель на процесс атрибутов безопасности }
                 nil,                           { указатель на поток атрибутов безопасности }
                 False,                         { флаг родительского обработчика }
                 CREATE_NEW_CONSOLE or          { флаг создания }
                 NORMAL_PRIORITY_CLASS,
                 nil,                           { указатель на новую среду процесса }
                 zCurDir,                       { указатель на имя текущей директории }
                 StartupInfo,                   { указатель на STARTUPINFO }
                 ProcessInfo);                  { указатель на PROCESS_INF }
   While (WaitForSingleObject(ProcessInfo.hProcess,15000)=WAIT_TIMEOUT) do
    Repaint;
   mProcess.Lines.Add('->   Удаление сервиса сервера баз данных...');
   Application.ProcessMessages;
   StrPCopy(zAppName,ServerPath+'\Firebird\bin\instsvc.exe r');
   StrPCopy(zCurDir,ServerPath+'\Firebird\bin');
   FillChar(StartupInfo,Sizeof(StartupInfo),#0);
   StartupInfo.cb := Sizeof(StartupInfo);
   StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
   StartupInfo.wShowWindow := 1;
   CreateProcess(nil,
                 zAppName,                      { указатель командной строки }
                 nil,                           { указатель на процесс атрибутов безопасности }
                 nil,                           { указатель на поток атрибутов безопасности }
                 False,                         { флаг родительского обработчика }
                 CREATE_NEW_CONSOLE or          { флаг создания }
                 NORMAL_PRIORITY_CLASS,
                 nil,                           { указатель на новую среду процесса }
                 zCurDir,                       { указатель на имя текущей директории }
                 StartupInfo,                   { указатель на STARTUPINFO }
                 ProcessInfo);                  { указатель на PROCESS_INF }
   While (WaitForSingleObject(ProcessInfo.hProcess,3000)=WAIT_TIMEOUT) do
    Repaint;
   mProcess.Lines.Add('->   Удаление ключей реестра сервера баз данных...');
   Application.ProcessMessages;
   StrPCopy(zAppName,ServerPath+'\Firebird\bin\instreg.exe r');
   StrPCopy(zCurDir,ServerPath+'\Firebird\bin');
   FillChar(StartupInfo,Sizeof(StartupInfo),#0);
   StartupInfo.cb := Sizeof(StartupInfo);
   StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
   StartupInfo.wShowWindow := 1;
   CreateProcess(nil,
                 zAppName,                      { указатель командной строки }
                 nil,                           { указатель на процесс атрибутов безопасности }
                 nil,                           { указатель на поток атрибутов безопасности }
                 False,                         { флаг родительского обработчика }
                 CREATE_NEW_CONSOLE or          { флаг создания }
                 NORMAL_PRIORITY_CLASS,
                 nil,                           { указатель на новую среду процесса }
                 zCurDir,                       { указатель на имя текущей директории }
                 StartupInfo,                   { указатель на STARTUPINFO }
                 ProcessInfo);                  { указатель на PROCESS_INF }
   While (WaitForSingleObject(ProcessInfo.hProcess,2000)=WAIT_TIMEOUT) do
    Repaint;
    StrPCopy(zAppName,ServerPath+'\GUARDANT\NNKSRV32.EXE /R');
    StrPCopy(zCurDir,ServerPath+'\GUARDANT');
    FillChar(StartupInfo,Sizeof(StartupInfo),#0);
    StartupInfo.cb := Sizeof(StartupInfo);
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := 1;
    CreateProcess(nil,
                zAppName,                      { указатель командной строки }
                nil,                           { указатель на процесс атрибутов безопасности }
                nil,                           { указатель на поток атрибутов безопасности }
                False,                         { флаг родительского обработчика }
                CREATE_NEW_CONSOLE or          { флаг создания }
                NORMAL_PRIORITY_CLASS,
                nil,                           { указатель на новую среду процесса }
                zCurDir,                       { указатель на имя текущей директории }
                StartupInfo,                   { указатель на STARTUPINFO }
                ProcessInfo);                  { указатель на PROCESS_INF }
   Reg := TRegistry.Create;
   Reg.RootKey := HKEY_LOCAL_MACHINE;
   If (Reg.KeyExists('\Software\BertSoftware\Persona')) then
    Begin
     Reg.OpenKey('\Software\BertSoftware\Persona',False);
     If (Reg.ValueExists('ServerInstallPath')) then
      Reg.DeleteValue('ServerInstallPath');
    End;
   Reg.Free;
   mProcess.Lines.Add('Успешно.')
  End;
 If (ClientPath<>'') then
  Begin
   mProcess.Lines.Add('Удаление клиентской части ...');
   mProcess.Lines.Add(' ');
   Reg := TRegistry.Create;
   Reg.RootKey := HKEY_LOCAL_MACHINE;
   If (Reg.KeyExists('\Software\BertSoftware\Persona')) then
    Begin
     Reg.OpenKey('\Software\BertSoftware\Persona',False);
     If (Reg.ValueExists('ClientInstallPath')) then
      Reg.DeleteValue('ClientInstallPath');
    End;
   Reg.Free;
  End;
 mProcess.Lines.Add('Удаление настроек реестра ...');
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 If (Reg.KeyExists('\Software\BertSoftware\Persona')) then
  Begin
   Reg.OpenKey('\Software\BertSoftware\Persona',False);
   Reg.DeleteKey('\Software\BertSoftware\Persona')
  End;
 Reg.Free;
 mProcess.Lines.Add('Удаление файлов комплекса ...');
 FullRemoveDir(ServerPath, True, False, True);
 FullRemoveDir(ClientPath, True, False, True)
end;

procedure TfrmMain.ServerInstall;
 var Reg : TRegistry;
     St : TStringList;
     zAppName : array[0..512] of char;
     zCurDir : array[0..255] of char;
     StartupInfo : TStartupInfo;
     ProcessInfo : TProcessInformation;
begin
 mProcess.Lines.Add('Установка серверной части...');
 mProcess.Lines.Add(' ');
 InstallFB;
// Создание пользователей ->
 mProcess.Lines.Add('Создание пользователей...');
 ibss.Params.Clear;
 ibss.Params.Add('user_name=SYSDBA');
 ibss.Params.Add('password=masterkey');
 ibss.SecurityAction := ActionAddUser;
 ibss.UserName := 'USERLIST';
 ibss.Password := 'qwerty';
 try
  ibss.Active := True;
  ibss.AddUser;
  ibss.Active := False;
 except
  MessageDlg('Ошибка создания служебного пользователя!',mtError,[mbOK],0);
  Halt
 end;
 ibss.UserName := GetTxt(teAdminName.Text,31);
 ibss.Password := GetTxt(GetTxt(teAdminPass1.Text,8),8);
 try
  ibss.Active := True;
  ibss.AddUser;
  ibss.Active := False;
 except
  MessageDlg('Ошибка создания владельца базы данных!',mtError,[mbOK],0);
  Halt
 end;
 mProcess.Lines.Add('Успешно.');
// <- Создание пользователей
// Создание базы данных ->
 mProcess.Lines.Add('Создание базы данных...');
 ForceDirectories(bteServer.Text+'\DATA');
 St := TStringList.Create;
 St.LoadFromFile(ExtractFileDir(Application.ExeName)+'\Firebird\create.sql');
 St.Insert(0,'SET SQL DIALECT 3;');
 St.Insert(1,'SET NAMES WIN1251;');
 St.Insert(2,'CREATE DATABASE '+#39+bteServer.Text+'\DATA\DATA.FDB'+#39);
 St.Insert(3,'USER '+#39+GetTxt(teAdminName.Text,31)+#39+' PASSWORD '+#39+GetTxt(GetTxt(teAdminPass1.Text,8),8)+#39);
 St.Insert(4,'PAGE_SIZE 4096');
 St.Insert(5,'DEFAULT CHARACTER SET WIN1251;');
 St.SaveToFile(bteServer.Text+'\Firebird\create.sql');
 St.Free;
 CopyFile(PChar(ExtractFileDir(Application.ExeName)+'\Firebird\ibescript.exe'),PChar(bteServer.Text+'\Firebird\ibescript.exe'),False);
 CopyFile(PChar(ExtractFilePath(Application.ExeName)+'\Firebird\bin\fbclient.dll'),PChar(bteServer.Text+'\Firebird\gds32.dll'),False);
 StrPCopy(zAppName,bteServer.Text+'\Firebird\ibescript.exe create.sql -S');
 StrPCopy(zCurDir,bteServer.Text+'\Firebird');
 FillChar(StartupInfo,Sizeof(StartupInfo),#0);
 StartupInfo.cb := Sizeof(StartupInfo);
 StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
 StartupInfo.wShowWindow := 1;
 CreateProcess(nil,
               zAppName,                      { указатель командной строки }
               nil,                           { указатель на процесс атрибутов безопасности }
               nil,                           { указатель на поток атрибутов безопасности }
               False,                         { флаг родительского обработчика }
               CREATE_NEW_CONSOLE or          { флаг создания }
               NORMAL_PRIORITY_CLASS,
               nil,                           { указатель на новую среду процесса }
               zCurDir,                       { указатель на имя текущей директории }
               StartupInfo,                   { указатель на STARTUPINFO }
               ProcessInfo);                  { указатель на PROCESS_INF }
 While (WaitForSingleObject(ProcessInfo.hProcess,15000)=WAIT_TIMEOUT) do
  Repaint;
 DeleteFile(bteServer.Text+'\Firebird\create.sql');
 mProcess.Lines.Add('Успешно.');
// <- Создание базы данных
 InstallKeySrv;
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 Reg.OpenKey('\Software\BertSoftware\Persona',True);
 Reg.WriteString('ServerInstallPath',bteServer.Text);
 Reg.Free;
 mProcess.Lines.Add('Установка серверной части завершена.')
end;

procedure TfrmMain.InstallKeySrv;
 var ResultBool : LongBool;
     zAppName : array[0..512] of char;
     zCurDir : array[0..255] of char;
     StartupInfo : TStartupInfo;
     ProcessInfo : TProcessInformation;
begin
 mProcess.Lines.Add('Установка ключа...');
 WorkingKeyDriver(True);
 mProcess.Lines.Add('->   Копирование файлов сервера ключа...');
 ResultBool := CopyFile(PChar(ExtractFilePath(Application.ExeName)+'\GUARDANT\NNKSRV32.EXE'),PChar(bteServer.Text+'\GUARDANT\NNKSRV32.EXE'),False);
 ResultBool := ResultBool and CopyFile(PChar(ExtractFilePath(Application.ExeName)+'\GUARDANT\NOVEX32.DLL'),PChar(bteServer.Text+'\GUARDANT\NOVEX32.DLL'),False);
 ResultBool := ResultBool and CopyFile(PChar(ExtractFilePath(Application.ExeName)+'\GUARDANT\NNKSRV32.INI'),PChar(bteServer.Text+'\GUARDANT\NNKSRV32.INI'),False);
 If (ResultBool=False) then
  Begin
   MessageDlg('Ошибка копирования файлов сервера ключа!',mtError,[mbOK],0);
   Halt
  End;
 StrPCopy(zAppName,bteServer.Text+'\GUARDANT\NNKSRV32.EXE /I');
 StrPCopy(zCurDir,bteServer.Text+'\GUARDANT');
 FillChar(StartupInfo,Sizeof(StartupInfo),#0);
 StartupInfo.cb := Sizeof(StartupInfo);
 StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
 StartupInfo.wShowWindow := 1;
 CreateProcess(nil,
               zAppName,                      { указатель командной строки }
               nil,                           { указатель на процесс атрибутов безопасности }
               nil,                           { указатель на поток атрибутов безопасности }
               False,                         { флаг родительского обработчика }
               CREATE_NEW_CONSOLE or          { флаг создания }
               NORMAL_PRIORITY_CLASS,
               nil,                           { указатель на новую среду процесса }
               zCurDir,                       { указатель на имя текущей директории }
               StartupInfo,                   { указатель на STARTUPINFO }
               ProcessInfo);                  { указатель на PROCESS_INF }
 mProcess.Lines.Add('Успешно.')
end;

procedure TfrmMain.ClientInstall;
 var Reg : TRegistry;
     ResultBool : LongBool;
     S : String;
     Key256 : TKey256;
begin
 mProcess.Lines.Add('Установка клиентской части...');
 mProcess.Lines.Add(' ');
 mProcess.Lines.Add('->   Создание папок...');
 ForceDirectories(bteClient.Text);
 mProcess.Lines.Add('->   Копирование файлов...');
 ResultBool := CopyFile(PChar(ExtractFilePath(Application.ExeName)+'\Firebird\bin\fbclient.dll'),PChar(bteClient.Text+'\fbclient.dll'),False);
 ResultBool := ResultBool and CopyFile(PChar(ExtractFilePath(Application.ExeName)+'\GUARDANT\GNCLIENT.INI'),PChar(bteClient.Text+'\GNCLIENT.INI'),False);
 ResultBool := ResultBool and CopyFile(PChar(ExtractFilePath(Application.ExeName)+'\Persona.exe'),PChar(bteClient.Text+'\Persona.exe'),False);
 ResultBool := ResultBool and CopyFile(PChar(ExtractFilePath(Application.ExeName)+'\GUARDANT\NOVEX32.DLL'),PChar(bteClient.Text+'\NOVEX32.DLL'),False);
 If (ResultBool=False) then
  Begin
   MessageDlg('Ошибка копирования файлов клиента!',mtError,[mbOK],0);
   Halt
  End;
 mProcess.Lines.Add('->   Создание ключей реестра...');
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 Reg.OpenKey('\Software\BertSoftware\Persona',True);
 Reg.WriteString('ClientInstallPath',bteClient.Text);
 Reg.OpenKey('\Software\BertSoftware\Persona\SetUp',True);
 GenerateLMDKey(Key256, SizeOf(Key256), 'MZPX†f0“Ъвљ 8¬ЎлмyWdasdІО=`бюЪ БєyX†f0“Ъвљ 845098yhfjb hJLUGLI,. ., **&*^#');
 If (tsServer.TabVisible) then
  S := RDLEncryptStringCBCEx(bteServer.Text+'\Data\Data.fdb', Key256, 32, True)
 else
  S := RDLEncryptStringCBCEx(bteServerPosition.Text+'\Data\Data.fdb', Key256, 32, True);
 Reg.WriteString('Path', S);
 Reg.Free;
 mProcess.Lines.Add('Установка клиентской части завершена.')
end;

procedure TfrmMain.cbServerClick(Sender: TObject);
begin
 tsServer.TabVisible := cbServer.Checked;
 lblServerPosition.Visible := Not tsServer.Visible;
 bteServerPosition.Visible := lblServerPosition.Visible;
 If (cbServer.Checked) then
  cbUninstall.Checked := False
end;

procedure TfrmMain.cbClientClick(Sender: TObject);
begin
 tsClient.TabVisible := cbClient.Checked;
 If (cbClient.Checked) then
  cbUninstall.Checked := False
end;

procedure TfrmMain.cbUninstallClick(Sender: TObject);
begin
 tsServer.TabVisible := Not cbUninstall.Checked;
 tsClient.TabVisible := Not cbUninstall.Checked;
 If (cbUninstall.Checked) then
  Begin
   cbServer.Checked := False;
   cbClient.Checked := False
  End;
end;

procedure TfrmMain.InstallFB;
 var ResultBool : LongBool;
     Handle : THandle;
     zAppName : array[0..512] of char;
     zCurDir : array[0..255] of char;
     StartupInfo : TStartupInfo;
     ProcessInfo : TProcessInformation;
     k : Cardinal;
     SelfPath : String;
begin
 mProcess.Lines.Add('Установка сервера баз данных...');
 SelfPath := ExtractFilePath(Application.ExeName);
 Application.ProcessMessages;
 Handle := FindWindow(nil,'Firebird Guardian')+FindWindow(nil,'Firebird Server');
 If (Handle<>0) then
  Begin
   mProcess.Lines.Add('->   Остановка существующего сервера...');
   Handle := FindWindow(nil,'Firebird Guardian');
   If (Handle<>0) then
    PostMessage(Handle, WM_QUIT, 0, 0);
   Handle := FindWindow(nil,'Firebird Server');
   If (Handle<>0) then
    PostMessage(Handle, WM_QUIT, 0, 0);
   k := GetTickCount;
   While (GetTickCount-k<10000) do
    Application.ProcessMessages
  End;
 mProcess.Lines.Add('->   Создание папок...');
 Application.ProcessMessages;
 ForceDirectories(bteServer.Text);
 ForceDirectories(bteServer.Text+'\Firebird\bin');
 ForceDirectories(bteServer.Text+'\Firebird\intl');
 ForceDirectories(bteServer.Text+'\GUARDANT');
 mProcess.Lines.Add('->   Копирование файлов сервера баз данных...');
 Application.ProcessMessages;
 ResultBool := CopyFile(PChar(SelfPath+'\Firebird\bin\fbserver.exe'),PChar(bteServer.Text+'\Firebird\bin\fbserver.exe'),False);
 ResultBool := ResultBool and CopyFile(PChar(SelfPath+'\Firebird\bin\msvcp60.dll'),PChar(bteServer.Text+'\Firebird\bin\msvcp60.dll'),False);
 ResultBool := ResultBool and CopyFile(PChar(SelfPath+'\Firebird\bin\msvcrt.dll'),PChar(bteServer.Text+'\Firebird\bin\msvcrt.dll'),False);
 ResultBool := ResultBool and CopyFile(PChar(SelfPath+'\Firebird\bin\instreg.exe'),PChar(bteServer.Text+'\Firebird\bin\instreg.exe'),False);
 ResultBool := ResultBool and CopyFile(PChar(SelfPath+'\Firebird\bin\instsvc.exe'),PChar(bteServer.Text+'\Firebird\bin\instsvc.exe'),False);
 ResultBool := ResultBool and CopyFile(PChar(SelfPath+'\Firebird\intl\fbintl.dll'),PChar(bteServer.Text+'\Firebird\intl\fbintl.dll'),False);
 ResultBool := ResultBool and CopyFile(PChar(SelfPath+'\Firebird\firebird.msg'),PChar(bteServer.Text+'\Firebird\firebird.msg'),False);
 ResultBool := ResultBool and CopyFile(PChar(SelfPath+'\Firebird\security.fdb'),PChar(bteServer.Text+'\Firebird\security.fdb'),False);
 SetFileAttributes(PChar(bteServer.Text+'\Firebird\security.fdb'), FILE_ATTRIBUTE_NORMAL);
 ResultBool := ResultBool and CopyFile(PChar(SelfPath+'\Firebird\firebird.conf'),PChar(bteServer.Text+'\Firebird\firebird.conf'),False);
 If (ResultBool=False) then
  Begin
   MessageDlg('Ошибка копирования файлов сервера!',mtError,[mbOK],0);
   Halt
  End;
 mProcess.Lines.Add('->   Создание ключей реестра...');
 Application.ProcessMessages;
 StrPCopy(zAppName,bteServer.Text+'\Firebird\bin\instreg.exe i');
 StrPCopy(zCurDir,bteServer.Text+'\Firebird\bin');
 FillChar(StartupInfo,Sizeof(StartupInfo),#0);
 StartupInfo.cb := Sizeof(StartupInfo);
 StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
 StartupInfo.wShowWindow := 1;
 CreateProcess(nil,
               zAppName,                      { указатель командной строки }
               nil,                           { указатель на процесс атрибутов безопасности }
               nil,                           { указатель на поток атрибутов безопасности }
               False,                         { флаг родительского обработчика }
               CREATE_NEW_CONSOLE or          { флаг создания }
               NORMAL_PRIORITY_CLASS,
               nil,                           { указатель на новую среду процесса }
               zCurDir,                       { указатель на имя текущей директории }
               StartupInfo,                   { указатель на STARTUPINFO }
               ProcessInfo);                  { указатель на PROCESS_INF }
 While (WaitForSingleObject(ProcessInfo.hProcess,2000)=WAIT_TIMEOUT) do
  Repaint;
 mProcess.Lines.Add('->   Создание сервиса сервера баз данных...');
 Application.ProcessMessages;
 StrPCopy(zAppName,bteServer.Text+'\Firebird\bin\instsvc.exe i');
 StrPCopy(zCurDir,bteServer.Text+'\Firebird\bin');
 FillChar(StartupInfo,Sizeof(StartupInfo),#0);
 StartupInfo.cb := Sizeof(StartupInfo);
 StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
 StartupInfo.wShowWindow := 1;
 CreateProcess(nil,
               zAppName,                      { указатель командной строки }
               nil,                           { указатель на процесс атрибутов безопасности }
               nil,                           { указатель на поток атрибутов безопасности }
               False,                         { флаг родительского обработчика }
               CREATE_NEW_CONSOLE or          { флаг создания }
               NORMAL_PRIORITY_CLASS,
               nil,                           { указатель на новую среду процесса }
               zCurDir,                       { указатель на имя текущей директории }
               StartupInfo,                   { указатель на STARTUPINFO }
               ProcessInfo);                  { указатель на PROCESS_INF }
 While (WaitForSingleObject(ProcessInfo.hProcess,5000)=WAIT_TIMEOUT) do
  Repaint;
 mProcess.Lines.Add('->   Старт сервиса сервера баз данных...');
 Application.ProcessMessages;
 StrPCopy(zAppName,bteServer.Text+'\Firebird\bin\instsvc.exe start');
 StrPCopy(zCurDir,bteServer.Text+'\Firebird\bin');
 FillChar(StartupInfo,Sizeof(StartupInfo),#0);
 StartupInfo.cb := Sizeof(StartupInfo);
 StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
 StartupInfo.wShowWindow := 1;
 CreateProcess(nil,
               zAppName,                      { указатель командной строки }
               nil,                           { указатель на процесс атрибутов безопасности }
               nil,                           { указатель на поток атрибутов безопасности }
               False,                         { флаг родительского обработчика }
               CREATE_NEW_CONSOLE or          { флаг создания }
               NORMAL_PRIORITY_CLASS,
               nil,                           { указатель на новую среду процесса }
               zCurDir,                       { указатель на имя текущей директории }
               StartupInfo,                   { указатель на STARTUPINFO }
               ProcessInfo);                  { указатель на PROCESS_INF }
 While (WaitForSingleObject(ProcessInfo.hProcess,15000)=WAIT_TIMEOUT) do
  Repaint;
 mProcess.Lines.Add('Успешно.');
 Application.ProcessMessages
end;

procedure TfrmMain.tsServerShow(Sender: TObject);
begin
 btNext.Enabled := (teAdminPass1.Text=teAdminPass2.Text) and (teAdminPass1.Text<>'')
end;

procedure TfrmMain.teAdminPass1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 btNext.Enabled := (teAdminPass1.Text=teAdminPass2.Text) and (teAdminPass1.Text<>'')
end;

function TfrmMain.GetTxt(Txt : String; MaxLength : Integer): String;
 var Key256 : TKey256;
begin
 GenerateLMDKey(Key256, SizeOf(Key256), 'MZPX†f0“Ъвљ 8¬ЎлмyWІО=`бюЪБєgfdgyX†f0“Ъвљ845098yhfjbhJLUGLI,.,**&*^#');
 Result := Copy(RDLEncryptStringEx(Txt, Key256, SizeOf(Key256), True),0,MaxLength)
end;

function TfrmMain.WorkingKeyDriver(Install : Boolean) : LongWord;
var zAppName : array[0..512] of char;
    zCurDir : array[0..255] of char;
    StartupInfo : TStartupInfo;
    ProcessInfo : TProcessInformation;
begin
 If (Install) then
  Begin
   StrPCopy(zAppName,ExtractFileDir(Application.ExeName)+'\GUARDANT\DRIVERS\INSTDRV.EXE /Q /NORB');
   mProcess.Lines.Add('->   Устанавливается драйвер ключа...')
  End
 else
  Begin
   StrPCopy(zAppName,ExtractFileDir(Application.ExeName)+'\GUARDANT\DRIVERS\INSTDRV.EXE /Q /U /NORB');
   mProcess.Lines.Add('->   Удаляется драйвер ключа...')
  End;
 Application.ProcessMessages;
 StrPCopy(zCurDir,ExtractFileDir(Application.ExeName)+'\GUARDANT\DRIVERS');
 FillChar(StartupInfo,Sizeof(StartupInfo),#0);
 StartupInfo.cb := Sizeof(StartupInfo);
 StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
 StartupInfo.wShowWindow := 0;
 CreateProcess(nil,
                       zAppName,                      { указатель командной строки }
                       nil,                           { указатель на процесс атрибутов безопасности }
                       nil,                           { указатель на поток атрибутов безопасности }
                       False,                         { флаг родительского обработчика }
                       CREATE_NEW_CONSOLE or          { флаг создания }
                       NORMAL_PRIORITY_CLASS,
                       nil,                           { указатель на новую среду процесса }
                       zCurDir,                       { указатель на имя текущей директории }
                       StartupInfo,                   { указатель на STARTUPINFO }
                       ProcessInfo);             { указатель на PROCESS_INF }
 WaitforSingleObject(ProcessInfo.hProcess,15000);
 GetExitCodeProcess(ProcessInfo.hProcess,Result);
 If (Result<>0) then
  Begin
   MessageDlg('Ошибка установки драйвера ключа!'#13#10+MsgStr[Result-1],mtError,[mbOK],0);
   Halt
  End
end;

procedure TfrmMain.tsChooseShow(Sender: TObject);
begin
 btNext.Enabled := True
end;

end.
