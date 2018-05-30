program RASManager;

uses
  Vcl.Forms,
  ufmMainForm in 'ufmMainForm.pas' {frmMainForm},
  uRASMngrCommon in 'uRASMngrCommon.pas',
  ufmAdditional in 'ufmAdditional.pas' {frmAdditional},
  Lmcons in 'ras\pas\Lmcons.pas',
  LmErr in 'ras\pas\LmErr.pas',
  Ras in 'ras\pas\Ras.pas',
  RasAuth in 'ras\pas\RasAuth.pas',
  RasDlg in 'ras\pas\RasDlg.pas',
  RasEapif in 'ras\pas\RasEapif.pas',
  RasError in 'ras\pas\RasError.pas',
  RasSapi in 'ras\pas\RasSapi.pas',
  RasShost in 'ras\pas\RasShost.pas',
  RasHelperClasses in 'ras\utils\RasHelperClasses.pas',
  RasUtils in 'ras\utils\RasUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.Run;
end.
