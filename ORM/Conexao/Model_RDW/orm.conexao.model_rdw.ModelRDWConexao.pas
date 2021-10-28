unit orm.conexao.model_rdw.ModelRDWConexao;

interface

uses
  orm.conexao.interfaces.Interfaces, uRESTDWPoolerDB, System.SysUtils;

type
  TModelRDWConexao = class(TInterfacedObject, IModelConexao)
    private
      FConexao : TRestDWDatabase;
    public
      constructor Create();
      destructor destroy;override;
      class function New: IModelConexao;
      function Connection: TObject;
  end;

implementation

{ TModelRDWConexao }

function TModelRDWConexao.Connection: TObject;
begin
   Result := FConexao;
end;

constructor TModelRDWConexao.Create;
begin
  FConexao := TRESTDWDataBase.Create(nil);
  FConexao.MyIP := '127.0.0.1';
  FConexao.Active := True;
end;

destructor TModelRDWConexao.destroy;
begin
  FreeAndNil(FConexao);
  inherited;
end;

class function TModelRDWConexao.New: IModelConexao;
begin
   Result := Self.Create;
end;

end.
