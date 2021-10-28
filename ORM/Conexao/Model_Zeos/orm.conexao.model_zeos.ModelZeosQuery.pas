unit orm.conexao.model_zeos.ModelZeosQuery;

interface

uses
  orm.conexao.interfaces.Interfaces, ZDataset, ZConnection, System.SysUtils;

  type
    TModelZeosQuery = class(TInterfacedObject, IModelQuery)
      private
        FQuery: TZQuery;
        FConexao: IModelConexao;
      public
        constructor Create(aValue: IModelConexao);
        destructor Destroy; override;
        class function New(aValue: IModelConexao): IModelQuery;
        function Query: TObject;
        function Open(aSql: string): IModelQuery;
        function ExecSql(aSql: string): IModelQuery;
    end;

implementation

{ TModelZeosQuery }

constructor TModelZeosQuery.Create(aValue: IModelConexao);
begin
  FConexao := aValue;
  FQuery := TZQuery.Create(nil);
  FQuery.Connection := TZConnection(FConexao.Connection);
end;

destructor TModelZeosQuery.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelZeosQuery.ExecSql(aSql: string): IModelQuery;
begin
  Result := Self;
  FQuery.SQL.Text := aSql;
  FQuery.ExecSql;
end;

class function TModelZeosQuery.New(aValue: IModelConexao): IModelQuery;
begin
  Result := Self.Create(aValue);
end;

function TModelZeosQuery.Open(aSql: string): IModelQuery;
begin
   Result := Self;
   FQuery.SQL.Text := aSql;
   FQuery.Open;
end;

function TModelZeosQuery.Query: TObject;
begin
  Result := FQuery;
end;

end.
