program GenClasse;

uses
  System.StartUpCopy,
  FMX.Forms,
  Gerador_Classe.View.uFrmPrincipal in 'Gerador_Classe.View.uFrmPrincipal.pas' {frmPrincipal},
  Gerar_Classe.Interfaces.iBaseGerarClasseBanco in 'Interfaces\Gerar_Classe.Interfaces.iBaseGerarClasseBanco.pas',
  Gerar_Classe.Firebird.GerarClasseBancoFirebird in 'Firebird\Gerar_Classe.Firebird.GerarClasseBancoFirebird.pas',
  orm.IBaseVO in '..\ORM\orm.IBaseVO.pas',
  orm.Atributos in '..\ORM\orm.Atributos.pas',
  orm.conexao.interfaces.Interfaces in '..\ORM\Conexao\Interfaces\orm.conexao.interfaces.Interfaces.pas',
  orm.conexao.model_zeos.ModelZeosConexao in '..\ORM\Conexao\Model_Zeos\orm.conexao.model_zeos.ModelZeosConexao.pas',
  orm.conexao.model_zeos.ModelZeosQuery in '..\ORM\Conexao\Model_Zeos\orm.conexao.model_zeos.ModelZeosQuery.pas',
  orm.conexao.ModelConexaoFactory in '..\ORM\Conexao\orm.conexao.ModelConexaoFactory.pas',
  orm.conexao.model_firedac.ModelFiredacConexao in '..\ORM\Conexao\Model_Firedac\orm.conexao.model_firedac.ModelFiredacConexao.pas',
  orm.conexao.model_firedac.ModelFiredacQuery in '..\ORM\Conexao\Model_Firedac\orm.conexao.model_firedac.ModelFiredacQuery.pas',
  orm.lib.Biblioteca in '..\ORM\Lib\orm.lib.Biblioteca.pas',
  Gerardor_Classe.GerarClasseZeos in 'Gerardor_Classe.GerarClasseZeos.pas',
  Gerador_Classe.Postgresql.GerarClasseBancoPostgresql in 'Postgresql\Gerador_Classe.Postgresql.GerarClasseBancoPostgresql.pas',
  Gerador_Classe.view.uDM in 'View\Gerador_Classe.view.uDM.pas' {DM: TDataModule},
  Gerador_Classe.Gerar_Classes.GerarClasseController in 'Gerar_Classes\Gerador_Classe.Gerar_Classes.GerarClasseController.pas',
  Gerador_Classe.Gerar_Classes.GerarClasse in 'Gerar_Classes\Gerador_Classe.Gerar_Classes.GerarClasse.pas',
  Gerador_Classe.Gerar_Classes.GerarClasseVO in 'Gerar_Classes\Gerador_Classe.Gerar_Classes.GerarClasseVO.pas',
  orm.dao.BaseDAOZeos in '..\ORM\DAO\orm.dao.BaseDAOZeos.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
