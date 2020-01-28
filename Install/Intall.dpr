program Intall;

uses
  Forms,
  Main in 'Main.pas' {frmMain},
  Misk in 'Misk.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
