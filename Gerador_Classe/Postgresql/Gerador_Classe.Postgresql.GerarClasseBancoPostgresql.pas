unit Gerador_Classe.Postgresql.GerarClasseBancoPostgresql;

interface

uses Gerar_Classe.Interfaces.iBaseGerarClasseBanco, DB, System.SysUtils, Classes;

type
  TGerarClasseBancoPostgresql = class(TInterfacedObject, iBaseGerarClasseBanco)
    private
      function GetTypeField(Tipo,SubTipo,Precisao,Escala: integer): string;
    public
      function GetSqlTabela(): string;
      function GetSqlCamposTabela(ATabela: string): string;
      function GetSqlCamposPK(ATabela: string): string;
      procedure GerarFields(ADs: TDataSet; AResultado: TStrings);
      procedure GerarProperties(ADs: TDataSet; AResultado: TStrings; ACamposPK: string);
      constructor Create;
      destructor Destroy;override;
      class function New: iBaseGerarClasseBanco;
  end;

implementation

{ TGerarClasseBancoPostgresql }

constructor TGerarClasseBancoPostgresql.Create;
begin
  //
end;

destructor TGerarClasseBancoPostgresql.Destroy;
begin
  //
  inherited;
end;

procedure TGerarClasseBancoPostgresql.GerarFields(ADs: TDataSet;
  AResultado: TStrings);
var
  Tipo,SubTipo,Precisao,Escala: integer;
  Nome: string;
begin
    AResultado.Add('  Private');
    ADs.First;
    while not ADs.Eof do
    begin
      Tipo := ADs.FieldByName('TIPO').AsInteger;
      SubTipo := ADs.FieldByName('SUBTIPO').AsInteger;
      Precisao := ADs.FieldByName('PRECISAO').AsInteger;
      Escala := ADs.FieldByName('ESCALA').AsInteger;
      Nome := Trim(ADs.FieldByName('NOME').AsString);
      Nome := 'F' + UpperCase(Nome[1]) + LowerCase(Copy(Nome, 2, Length(Nome)));
      AResultado.Add('  ' + Nome + ':' + GetTypeField(Tipo, SubTipo, Precisao, Escala) + ';');
      ADs.Next;
    end;
end;

procedure TGerarClasseBancoPostgresql.GerarProperties(ADs: TDataSet;
  AResultado: TStrings; ACamposPK: string);
var
  Tipo,SubTipo,Precisao,Escala: integer;
  Nome: string;
begin
   AResultado.Add('  Public');
   ADs.First;
   while not ADs.Eof do
   begin
     Tipo := ADs.FieldByName('TIPO').AsInteger;
     SubTipo := ADs.FieldByName('SUBTIPO').AsInteger;
     Precisao := ADs.FieldByName('PRECISAO').AsInteger;
     Escala := ADs.FieldByName('ESCALA').AsInteger;
     Nome := Trim(ADs.FieldByName('NOME').AsString);

     if pos(Nome, ACamposPK) > 0 then
       AResultado.Add('  [TChavePrimaria("ID", "C�digo", "C�digos")]');

     Nome := UpperCase(Nome[1]) + LowerCase(Copy(Nome, 2, Length(Nome)));
     AResultado.Add('  Property ' + Nome + ':' + GetTypeField(Tipo, SubTipo, Precisao, Escala) + ' read F' + Nome + ' write F' + Nome + ';');
     ADs.Next;
   end;
end;

function TGerarClasseBancoPostgresql.GetSqlCamposPK(ATabela: string): string;
begin
  Result := 'SELECT TC.TABLE_SCHEMA AS ESQUEMA, TC.TABLE_NAME AS TABELA, KC.COLUMN_NAME AS COLUNA ' +
            'FROM INFORMATION_SCHEMA.TABLE_CONSTRAINT TC ' +
            'JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KC ON KC.TABLE_NAME = TC.TABLE_NAME AND KC.CONSTRAINT_NAME = TC.CONSTRAINT_NAME ' +
            'WHERE KC.CONSTRAINT_TYPE = "PRIMARY KEY" AND KC.ORDINAL_POSITION IS NOT NULL AND TC.TABLE_NAME = ' + QuotedStr(ATabela) + '' +
            'ORDER BY TC.TABLE_SCHEMA, TC.TABLE_NAME, KC.POSITION_IN_UNIQUE_CONSTRAINT';
end;

function TGerarClasseBancoPostgresql.GetSqlCamposTabela(
  ATabela: string): string;
begin
  Result := 'SELECT COLUNM_NAME AS NOME, DATA_TYPE AS TIPO, NUMERIC_PRECISION AS PRECISAO, NUMERIC_SCALE AS ESCALA ' +
            'FROM INFORMATION_SCHEMA.COLUMNS ' +
            'WHERE TABLE_NAME = ' + QuotedStr(ATabela) + '';
end;

function TGerarClasseBancoPostgresql.GetSqlTabela: string;
begin
  Result := 'SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = "PUBLIC"';
end;

function TGerarClasseBancoPostgresql.GetTypeField(Tipo, SubTipo, Precisao,
  Escala: integer): string;
begin
   case Tipo of
     7,
     8,
     9,
     10,
     11,
     16,
     27:
        begin
          case Escala of
            0: Result := 'Integer';
            8: Result := 'Double' ;
            else
               Result := 'Currency';
          end;
        end;
     14,
     37,
     40: Result := 'string';
     12: Result := 'TDate';
     13: Result := 'TTime';
     35: Result := 'TDateTime';
     261:begin
           if SubTipo = 1 then
              Result := 'string'
           else Result := 'blob';
         end;
   end;
end;

class function TGerarClasseBancoPostgresql.New: iBaseGerarClasseBanco;
begin
  Self.Create;
end;

end.
