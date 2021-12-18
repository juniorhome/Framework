unit Gerador_Classe.Gerar_Classes.GerarClasse;

interface

uses Gerar_Classe.Interfaces.iBaseGerarClasseBanco, System.SysUtils,
  System.Classes;

type
  TGerarClasse = class
    private
      function Capitalize(ATexto: string): string;
    protected
       Resultado: TStringList;
       GerarClasseBanco: iBaseGerarClasseBanco;
       FTabela,FUnit,FClasse,FPacote: string;

       function GetCampoPK: string; virtual; abstract;
       procedure GerarCabecalho; virtual; abstract;
       procedure GerarFieldsProperties; virtual; abstract;
       procedure GerarRodape;
    public
       constructor Create(AClasseBanco: iBaseGerarClasseBanco);
       destructor Destroy; override;

       function Gerar(ATabela, ANomeUnit: string; ANomeClass: string = ''): string;
  end;

implementation

{ TGerarClasseVO }

function TGerarClasse.Capitalize(ATexto: string): string;
begin
  Result := UpperCase(ATexto[1]) + LowerCase(Copy(ATexto, 2, Length(ATexto)));
end;

constructor TGerarClasse.Create(AClasseBanco: iBaseGerarClasseBanco);
begin
   Resultado := TStringList.Create;
   GerarClasseBanco := AClasseBanco;
end;

destructor TGerarClasse.Destroy;
begin
  Resultado.Free;
  inherited;
end;

function TGerarClasse.Gerar(ATabela, ANomeUnit, ANomeClass: string): string;
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

procedure TGerarClasse.GerarRodape;
begin
   Resultado.Add(' end;');
   Resultado.Add('');
   Resultado.Add('implementation');
   Resultado.Add('');
   Resultado.Add('end.')
end;

end.
