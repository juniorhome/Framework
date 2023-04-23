unit orm.conexao.ModelConexaoFactory;

interface

uses
  orm.conexao.interfaces.Interfaces, orm.conexao.model_firedac.ModelFiredacConexao,
  orm.conexao.model_zeos.ModelZeosConexao,
  orm.conexao.model_firedac.ModelFiredacQuery,
  orm.conexao.model_zeos.ModelZeosQuery;

  type
   TModelConexaoFactory = class(TInterfacedObject, IModelConexaoFactory)
     private
     public
       constructor Create;
       destructor Destroy;override;
       class function New: IModelConexaoFactory;
       function Conexao(aOp: integer): IModelConexao;
       function Query(aOp: integer): IModelQuery;
   end;

implementation


{ TModelConexaoFactory }

function TModelConexaoFactory.Conexao(aOp: integer): IModelConexao;
begin
   case aOp of
     1:
       begin
         Result := TModelFiredacConexao.New;
       end;
     2:
       begin
         Result:= TModelZeosConexao.New;
       end;
   end;
end;

constructor TModelConexaoFactory.Create;
begin

end;

destructor TModelConexaoFactory.Destroy;
begin

  inherited;
end;

class function TModelConexaoFactory.New: IModelConexaoFactory;
begin
  Result := Self.Create;
end;

function TModelConexaoFactory.Query(aOp: integer): IModelQuery;
begin
  case aOp of
    1:
      begin
        Result := TModelFiredacQuery.New(Self.Conexao(1));
      end;
    2:
      begin
        Result := TModelZeosQuery.New(Self.Conexao(2));
      end;
  end;
end;

end.
