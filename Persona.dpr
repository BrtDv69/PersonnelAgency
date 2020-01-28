program Persona;

{%ToDo 'Persona.todo'}

uses
  Forms,
  Registry,
  Windows,
  Controls,
  Dialogs,
  Main in 'Main.pas' {frmMain},
  Like in 'Like.pas' {frmLike},
  ExportOptions in 'ExportOptions.pas' {frmExportOptions},
  Summaries in 'Summaries.pas' {frmSummaries},
  Vacansies in 'Vacansies.pas' {frmVacansies},
  Questionnaires in 'Questionnaires.pas' {frmQuestionnaires},
  ActivityJobs in 'ActivityJobs.pas' {frmActivityJobs},
  Districts in 'Districts.pas' {frmDistricts},
  About in 'About.pas' {frmAbout},
  DM in 'DM.pas' {frmDM: TDataModule},
  Managers in 'Managers.pas' {frmManagers},
  Misk in 'Misk.pas',
  EnterPassword in 'EnterPassword.pas' {frmEnterPassword},
  LogIn in 'LogIn.pas' {frmLogIn},
  Synchronize in 'Synchronize.pas' {frmSynchronize},
  TMP_Tables in 'TMP_Tables.pas' {frmTMP_Tables};

{$R *.RES}

var Reg: TRegistry;
    tc : Cardinal;

begin
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  If (Reg.KeyExists('\Software\BertSoftware\Persona\SetUp')) then
   Begin
    Reg.OpenKeyReadOnly('\Software\BertSoftware\Persona\SetUp');
    If (Reg.ValueExists('Path')) then
     Begin
      Reg.Free;
      Application.Initialize;
      frmAbout := TfrmAbout.Create(Application);
      tc := GetTickCount;
      frmAbout.ClientWidth := frmAbout.Image1.Picture.Width+4;
      frmAbout.ClientHeight := frmAbout.Image1.Picture.Height+4;
      frmAbout.Show;
      frmAbout.Update;
      Application.Title := 'Persona';
      Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmLogIn, frmLogIn);
  While Abs(GetTickCount-tc)<2000 do
       Application.ProcessMessages;
      frmAbout.Free;
      frmLogIn.ShowModal;
      If (frmLogIn.ModalResult=mrOK) then
       Begin
        frmMain.dxStatusBar1.Panels[0].Text := frmLogIn.lcUserName.Text;
        frmLogIn.Free;
        Application.CreateForm(TfrmDM, frmDM);
        Application.Run
       End
      else
       frmMain.Free
     End
   End
  else
   Begin
    Reg.Free;
    MessageDlg('Программный продукт не установлен. Воспользуйтесь программой установки.',mtError,[mbOK],0)
   End
end.
