unit Gerador_Classe.Gerar_Classes.GerarClasseVO;

interface

uses Gerar_Classe.Interfaces.iBaseGerarClasseBanco, System.SysUtils,
  System.Classes;

type
  TGerarClasseVO = class
    private
      function Capitalize(ATexto: string): string;
    protected
       Resultado: TStringList;
       GerarClasseBanco: iBaseGerarClasseBanco;
       FTabela,FUnit,FClasse,FPacote: string;

       function GetCampoPK: string; virtual; abstract;
       procedure GerarCabecalho;
       procedure GerarFieldsProperties; virtual; abstract;
       procedure GerarRodape;
    public
       constructor Create(AClasseBanco: iBaseGerarClasseBanco);
       destructor Destroy; override;

       function Gerar(ATabela, ANomeUnit: string; ANomeClass: string = ''): string;
  end;

implementation

{ TGerarClasseVO }

function TGerarClasseVO.Capitalize(ATexto: string): string;
begin
  Result := UpperCase(ATexto[1]) + LowerCase(Copy(ATexto, 2, Length(ATexto)));
end;

constructor TGerarClasseVO.Create(AClasseBanco: iBaseGerarClasseBanco);
begin
   Resultado := TStringList.Create;
   GerarClasseBanco := AClasseBanco;
end;

destructor TGerarClasseVO.Destroy;
begin
  Resultado.Free;
  inherited;
end;

function TGerarClasseVO.Gerar(ATabela, ANomeUnit, ANomeClass: string): string;
begin
   FTabela := ATabela;
   FUnit := Capitalize(ANomeUnit);
   if Trim(ANomeClass) = '' then
      FClasse := Capitalize(FTabela)
   else
      FClasse := Capitalize(ANomeClass);
   GerarCabecalho;
   GerarFieldsProperties;
   GerarRodape;
   Result := Resultado.Text;

end;

procedure TGerarClasseVO.GerarCabecalho;
begin
  Resultado.Clear;
  Resultado.Add('unit ' + FPacote + '.'+ FUnit + '');
  Resultado.Add('');
  Resultado.Add(' interface');
  Resultado.Add('');
  Resultado.Add('uses');
  Resultado.Add('orm.IBaseVO, orm.Atributos');
  Resultado.Add('');
end;

procedure TGerarClasseVO.GerarRodape;
begin
   Resultado.Add(' end;');
   Resultado.Add('');
   Resultado.Add('implementation');
   Resultado.Add('');
   Resultado.Add('end.')
end;

end.
