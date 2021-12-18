unit Gerador_Classe.Gerar_Classes.GerarClasseVO;

interface

uses System.SysUtils, System.Classes, Gerador_Classe.Gerar_Classes.GerarClasse, Gerar_Classe.Interfaces.iBaseGerarClasseBanco, orm.dao.BaseDAOZeos,
  Datasnap.DBClient, Data.DB;

type
  TGerarClasseVO = class(TGerarClasse)
    private
      Resultado: TStringList;
      BaseGerarClasseBanco: iBaseGerarClasseBanco;
    public
      constructor Create(ABaseGerarClasseBanco: iBaseGerarClasseBanco);
      procedure GerarCabecalho; override;
      function GetCampoPk: string; override;
      procedure GerarFieldsProperties; override;
      function Gerar(ATabela, APacote, AClasse: string): string;
  end;

implementation

{ TGerarClasseVO }

constructor TGerarClasseVO.Create(ABaseGerarClasseBanco: iBaseGerarClasseBanco);
begin
   BaseGerarClasseBanco := ABaseGerarClasseBanco;
end;

function TGerarClasseVO.Gerar(ATabela, APacote, AClasse: string): string;
begin
   FTabela := ATabela;
   FPacote := APacote;
   FClasse := AClasse;
   GerarCabecalho;
   GerarFieldsProperties;
   GerarRodape;
   Result := Resultado.Text;
end;

procedure TGerarClasseVO.GerarCabecalho;
begin
  inherited;
  Resultado.Clear;
  Resultado.Add('unit '+ FPacote + '.' + FClasse + 'VO' + '');
  Resultado.Add('');
  Resultado.Add('uses orm.IBaseVO, orm.Atributos');
  Resultado.Add('');
end;

procedure TGerarClasseVO.GerarFieldsProperties;
var ds: TDataSet;
    sql: string;
begin
  try
    sql :=  BaseGerarClasseBanco.GetSqlCamposTabela(FTabela);
    ds :=  TBaseDAOZeos<TGerarClasseVO>.New.ConsultaSql(sql);
    BaseGerarClasseBanco.GerarFields(ds, Resultado);
    BaseGerarClasseBanco.GerarProperties(ds, Resultado, GetCampoPk);

  finally
    ds.DisposeOf;

  end;
end;

function TGerarClasseVO.GetCampoPk: string;
var ds: TDataSet;
    sql: string;
begin
   sql := BaseGerarClasseBanco.GetSqlCamposPK(FTabela);
   ds := TBaseDAOZeos<TGerarClasseVO>.New.ConsultaSql(sql);
end;

end.
