unit lookupProcUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, scisupport,
  nppplugin, NppDockingForms, Vcl.StdCtrls;

type
  TlForm = class(TNppDockingForm)
    pList: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TlForm }

end.
