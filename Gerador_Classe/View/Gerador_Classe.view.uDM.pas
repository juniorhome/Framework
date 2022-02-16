unit Gerador_Classe.view.uDM;

interface

uses
  System.SysUtils, System.Classes, orm.conexao.ModelConexaoFactory,
  orm.conexao.interfaces.Interfaces, System.ImageList, FMX.ImgList;

type
  TDM = class(TDataModule)
    imgLstIcones: TImageList;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FConexao: IModelConexao;
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
  FConexao := TModelConexaoFactory.New.Conexao(2);
end;

end.
