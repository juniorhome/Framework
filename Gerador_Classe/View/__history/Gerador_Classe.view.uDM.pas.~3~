unit Gerador_Classe.view.uDM;

interface

uses
  System.SysUtils, System.Classes, orm.conexao.ModelConexaoFactory;

type
  TDM = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  TModelConexaoFactory.New.Conexao(2);
end;

end.
