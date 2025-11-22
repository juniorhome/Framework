unit orm.conexao.model_firedac.ModelFiredacQuery;

interface

uses orm.conexao.interfaces.Interfaces, FireDAC.Comp.Client, System.SysUtils;

  type
    TModelFiredacQuery = class(TInterfacedObject, IModelQuery)
      private
        FQuery: TFDQuery;
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

{ TModelFiredacQuery }

constructor TModelFiredacQuery.Create(aValue: IModelConexao);
begin
   FConexao := aValue;
   FQuery := TFDQuery.Create(nil);
   FQuery.Connection := TFDConnection(FConexao.Connection);
end;

destructor TModelFiredacQuery.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelFiredacQuery.ExecSql(aSql: string): IModelQuery;
begin
  Result := Self;
  FQuery.ExecSql(aSql);
end;

class function TModelFiredacQuery.New(aValue: IModelConexao): IModelQuery;
begin
   Result := Self.Create(aValue);
end;

function TModelFiredacQuery.Open(aSql: string): IModelQuery;
begin
   Result := Self;
   FQuery.Open(aSql);
end;

function TModelFiredacQuery.Query: TObject;
begin
  Result := FQuery;
end;

end.
