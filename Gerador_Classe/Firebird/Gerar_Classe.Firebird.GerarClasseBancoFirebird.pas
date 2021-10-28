unit Gerar_Classe.Firebird.GerarClasseBancoFirebird;

interface

uses Gerar_Classe.Interfaces.iBaseGerarClasseBanco, System.SysUtils, DB, Classes;

type
  TGerarClasseBancoFirebird = class(TInterfacedObject, iBaseGerarClasseBanco)
    private
      function GetTypeField(Tipo, SubTipo, precisao, escala: integer): string;
    public
      function GetSqlCamposTabela(ATabela: string): string;
      function GetSqlCamposPK(ATabela: string): string;
      function GetSqlTabela(): string;
      procedure GerarFields(Ads: TDataSet; AResult: TStrings);
      procedure GerarProperties(Ads: TDataSet; AResult: TStrings; ACamposPK: string);
  end;

implementation

{ TGerarClasseBancoFirebird }

procedure TGerarClasseBancoFirebird.GerarFields(Ads: TDataSet;
  AResult: TStrings);
var
  Tipo,SubTipo,Precisao,Escala: integer;
  Nome: string;
begin
   AResult.Add('  Private');
   Ads.First;
   while not Ads.Eof do
   begin
     Tipo := Ads.FieldByName('TIPO').AsInteger;
     SubTipo := Ads.FieldByName('SUBTIPO').AsInteger;
     Precisao := Ads.FieldByName('PRECISAO').AsInteger;
     Escala := Ads.FieldByName('ESCALA').AsInteger;
     Nome := Trim(Ads.FieldByName('NOME').AsString);
     Nome := 'F' + UpperCase(Nome[1]) + LowerCase(Copy(Nome, 2, Length(Nome)));
     AResult.Add('  ' + Nome + ':' + GetTypeField(Tipo,SubTipo,Precisao,Escala) + ';');
     Ads.Next;
   end;
end;

procedure TGerarClasseBancoFirebird.GerarProperties(Ads: TDataSet;
  AResult: TStrings; ACamposPK: string);
var
  Tipo,SubTipo,Precisao,Escala: integer;
  Nome: string;
begin
   AResult.Add('  Public');
   Ads.First;
   while not Ads.Eof do
   begin
      Tipo := Ads.FieldByName('TIPO').AsInteger;
      SubTipo := Ads.FieldByName('SUBTIPO').AsInteger;
      Precisao := Ads.FieldByName('PRECISAO').AsInteger;
      Escala := Ads.FieldByName('ESCALA').AsInteger;
      Nome := Trim(Ads.FieldByName('Nome').AsString);

      if pos(Nome, ACamposPK) > 0 then
         AResult.Add('  [TChavePrimaria("ID", "Código", "Códigos")]');

      Nome := UpperCase(Nome[1]) + LowerCase(Copy(Nome, 2, Length(Nome)));
      AResult.Add('  Property ' + Nome + ':' + GetTypeField(Tipo, SubTipo, Precisao, Escala) + 'read F'+ Nome + 'write F'+Nome+';');
      Ads.Next;
   end;
end;

function TGerarClasseBancoFirebird.GetSqlCamposPK(ATabela: string): string;
begin
   Result := 'SELECT rc.RDB$RELATION_NAME AS TABELA, rc.RDB$CONSTRAINT_NAME AS CHAVE, rc.RDB$INDEX_NAME AS INDICE_CHAVE, ' +
             'ic.RDBE$FIELD_NAME AS CAMPO, ic.RDB$FIELD_POSITION AS POSICAO' +
             'FROM RDB$RELATION_CONSTRAINTS rc, RDB$INDICES i, RDB$INDEX_SEGMENTS ic ' +
             'WHERE rc.RDB$RELATION_TYPE = "PRIMARY KEY"' +
             'AND rc.RDB$RELATION_NAME = ' + QuotedStr(ATabela) + '' +
             'AND rc.RDB$INDEX_NAME = i.RDB$INDEX_NAME' +
             'AND ic.RDB$INDEX_NAME = i.RDB$INDEX_NAME' +
             'ORDER BY rc.RDB$CONSTRAINT_NAME, ic.RDB$FIELD_POSITION';
end;

function TGerarClasseBancoFirebird.GetSqlCamposTabela(ATabela: string): string;
begin
  Result := 'SELECT r.RDB$FIELD_NAME AS NOME, r.RDB$DESCRIPTION AS DESCRICAO, f.RDB$FIELD_LENGTH AS TAMANHO,' +
            'f.RDB$FIELD_TYPE AS TIPO, f.RDB$FIELD_SUBTYPE AS SUBTIPO, f.RDB$FIELD_PRECISION AS PRECISAO, RDB$FIELD_SCALA AS ESCALA' +
            'FROM RDB$RELATION_FIELDS r' +
            'LEFT JOIN RDB$FIELD f ON r.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME' +
            'WHERE r.RDB$RELATION_NAME = '+ QuotedStr(ATabela) + '' +
            'ORDER BY r.RDB$FIELD_POSITION';
end;

function TGerarClasseBancoFirebird.GetSqlTabela: string;
begin
  Result := 'SELECT RDB$RELATION_NAME AS TABELAS FROM RDB$RELATIONS WHERE RDB$SYSTEM_FLAG = 0';
end;

function TGerarClasseBancoFirebird.GetTypeField(Tipo, SubTipo, precisao,
  escala: integer): string;
begin
  case Tipo of
    7,
    8,
    9,
    10,
    11,
    16,
    27: begin
           case escala of
            0: Result := 'Integer';
           -8: Result := 'Double';
           else
             Result := 'Currency';
             end
        end;
    14,
    37,
    40: Result := 'string';
    12: Result := 'TDate';
    13: Result := 'TTime';
    35: Result := 'TDateTime';
    261: begin
          if SubTipo = 1 then
             Result := 'string'
          else Result := 'Blob';
         end;
  end;
end;

end.
