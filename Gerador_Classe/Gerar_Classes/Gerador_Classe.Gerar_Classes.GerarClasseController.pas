unit Gerador_Classe.Gerar_Classes.GerarClasseController;

interface

uses System.SysUtils, System.Classes, Gerador_Classe.Gerar_Classes.GerarClasse;

type
  TGerarClasseController = class(TGerarClasse)
    private
      function Capitalize(ATexto: string): string;
    protected
      Resultado: TStringList;
      FPacoteVO, FClasseVO: string;

      procedure GerarCabecalho; override;
      function GetCampoPk: string; override;
      procedure GerarFieldsProperties;override;
      function GerarCorpoClasse: string;
    public
      constructor Create(AClasseVO, APacoteVO: string);
      destructor destroy;override;
      function Gerar(ATabela, AClasse, AUnit: string): string;
  end;

implementation

{ TGerarClasseController }

function TGerarClasseController.Capitalize(ATexto: string): string;
begin
  Result := UpperCase(ATexto[1]) + LowerCase(Copy(ATexto, 2, Length(ATexto)));
end;

constructor TGerarClasseController.Create(AClasseVO, APacoteVO: string);
begin
  Resultado := TStringList.Create;
  FClasseVO := AClasseVO;
  FPacoteVO := APacoteVO;
end;

destructor TGerarClasseController.destroy;
begin
  Resultado.DisposeOf;
  inherited;
end;

function TGerarClasseController.Gerar(ATabela, AClasse, AUnit: string): string;
begin
  FTabela := ATabela;
  FClasse := AClasse;
  FUnit := AUnit;
  GerarCabecalho;
  Resultado := GerarCorpoClasse;
  Result := Resultado.Text;
end;

procedure TGerarClasseController.GerarCabecalho;
begin
  Resultado.Clear;
  Resultado.Add('unit ' + FPacote + '.'+  FUnit + 'Controller' + '');
  Resultado.Add('');
  Resultado.Add(' interface');
  Resultado.Add('');
  Resultado.Add('uses');
  Resultado.Add('orm.IBaseVO, orm.dao.BaseDAO, orm.conexao.interfaces.Interfaces, DB, uRESTDWPoolerDB,'+FPacoteVO+'.'+FClasseVO+'');
  Resultado.Add('');
  inherited;
end;

function TGerarClasseController.GerarCorpoClasse: string;
begin
  Resultado.Clear;
  Resultado.Add('type');
  Resultado.Add('  T'+ FClasse + 'Controller = class(TInterfacedObject, IController<'+ FClasseVO+'>)' + '');
  Resultado.Add('  private');
  Resultado.Add('    FConexao: TRESTDWDatabase;');
  Resultado.Add('  public');
  Resultado.Add('    function Inserir(obj: '+FClasseVO+'): integer;');
  Resultado.Add('    function Alterar(obj: '+FClasseVO+'): boolean');
  Resultado.Add('    function Exluir(obj: '+FClasseVO+'): boolean');
  Resultado.Add('    function Listagem(obj: '+FClasseVO+'): TDataSet');
  Resultado.Add('    constructor Create(AConexao: TRESTDWDatabase);');
  Resultado.Add('    destructor Destroy;override;');
  Resultado.Add('    class function New(AConexao: TRESTDWDatabase): IController<'+FClasseVO+'>;');
  Resultado.Add( 'end;');
  Resultado.Add(' implementation');
  Resultado.Add(' {'+FClasse+'Controller}');
  Resultado.Add(' function '+FClasse+'Controller.Inserir(obj: '+FClasseVO+'): integer;');
  Resultado.Add(' Begin');
  Resultado.Add('   raise Exception.Create("Esse m�todo n�o foi implementado."); ');
  Resultado.Add(' end;');
  Resultado.Add(' function '+FClasse+'Controller.Alterar(obj: '+FClasseVO+'): boolean;');
  Resultado.Add(' begin');
  Resultado.Add('   raise Exception.Create("Esse m�todo n�o foi implementado.");');
  Resultado.Add(' end;');
  Resultado.Add(' function '+FClasse+'Controller.Excluir(obj: '+FClasseVO+'): boolean;');
  Resultado.Add(' begin');
  Resultado.Add('   raise Exception.Create("Esse m�todo n�o foi implementado.");');
  Resultado.Add(' end;');
  Resultado.Add(' function '+FClasse+'Controller.Listagem(obj: '+FClasseVO+'): boolean;');
  Resultado.Add(' begin');
  Resultado.Add('   raise Exception.Create("Esse m�todo n�o foi implementado.");');
  Resultado.Add(' end;');
  Resultado.Add(' constructor '+FClasse+'Controller.Create(AConexao: TRESTDWDatabase);');
  Resultado.Add(' begin');
  Resultado.Add('   FConexao := AConexao;');
  Resultado.Add(' end');
  Resultado.Add(' destructor Destroy;');
  Resultado.Add(' begin');
  Resultado.Add('   FConexao.Free;');
  Resultado.Add('   inherited;');
  Resultado.Add(' end');
  Resultado.Add(' class function '+FClasse+'Controller.New(AConexao: TRESTDWDatabase);');
  Resultado.Add(' begin');
  Resultado.Add('   Self.Create(AConexao);');
  Resultado.Add(' end;');
  Resultado.Add('end.');

end;

procedure TGerarClasseController.GerarFieldsProperties;
begin
  raise Exception.Create('Esse m�todo n�o foi implementado.');
end;

function TGerarClasseController.GetCampoPk: string;
begin
  raise Exception.Create('Esse m�todo n�o foi implementado.');
end;

end.
