unit ufmAdditional;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmAdditional = class(TForm)
    chkAddRoute: TCheckBox;
    edtNodeAddr: TEdit;
    edtMask: TEdit;
    lblNodeAddr: TLabel;
    lblMask: TLabel;
    chkRDPConnect: TCheckBox;
    edtRDPFile: TEdit;
    btnSelectRDP: TButton;
    lblRDPFile: TLabel;
    btn1: TButton;
    btnCancel: TButton;
    bvl1: TBevel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

end.
