program Windows10HealthFixProject;

uses
  Vcl.Forms,
  Windows10HealthFixUnit in 'Windows10HealthFixUnit.pas' {MainForm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Windows 10 Health Fix';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
