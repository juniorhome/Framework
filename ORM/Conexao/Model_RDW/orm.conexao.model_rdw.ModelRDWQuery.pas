unit orm.conexao.model_rdw.ModelRDWQuery;

interface

uses
  orm.conexao.interfaces.Interfaces, uRESTDWPoolerDB, orm.lib.Biblioteca,
  orm.IBaseVO, System.SysUtils, System.Classes, Data.DB;

type
  TModelRDWQuery<T: class, constructor> = class(TInterfacedObject, IModelQuery)
    private
      FConnection : TRESTDWDatabase;
      FQuery : TRESTDWClientSQL;
    public
      constructor Create(aConnection: TRESTDWDataBase);
      destructor Destroy;override;
      class function New(aConnection: TRESTDWDataBase): IModelQuery;
      function SQL: TStrings;
      function Params: TParams;
      function ExecSQL: IModelQuery;overload;
      function ExecSql(aSql: string): IModelQuery;overload;
      function DataSet: TDataSet;
      function Open(aSql: string): IModelQuery; overload;
      function Open: IModelQuery; overload;
      function Query: TObject;
  end;

implementation

{ TModelRDWQuery }

constructor TModelRDWQuery<T>.Create(aConnection: TRESTDWDataBase);
var Lib : TLib<T>;
    obj : T;
begin
  Lib := TLib<T>.Create;
  FConnection := aConnection;
  FQuery := TRESTDWClientSQL.Create(nil);
  FQuery.DataBase := FConnection;
  FQuery.AutoCommitData := False;
  FQuery.AutoRefreshAfterCommit := True;
  FQuery.UpdateTableName := Lib.PegarNomeTabela(obj);
end;

function TModelRDWQuery<T>.DataSet: TDataSet;
begin
   Result := FQuery;
end;

destructor TModelRDWQuery<T>.Destroy;
begin
  FreeAndNil(FQuery);
  inherited;
end;

function TModelRDWQuery<T>.ExecSQL(aSql: string): IModelQuery;
var aErro: string;
begin
   FQuery.SQL.Clear;
   FQuery.SQL.Add(aSql);
   Result := Self;
   FQuery.ExecSQL(aErro);
   FQuery.ApplyUpdates(aErro)
end;

function TModelRDWQuery<T>.ExecSQL: IModelQuery;
var aErro: string;
begin
   Result := Self;
   FQuery.ExecSQL(aErro);
   FQuery.ApplyUpdates(aErro);
end;

class function TModelRDWQuery<T>.New(aConnection: TRESTDWDataBase): IModelQuery;
begin
   Result := Self.Create(aConnection);
end;

function TModelRDWQuery<T>.Open: IModelQuery;
begin
  Result := Self;
  FQuery.Close;
  FQuery.Open;
end;

function TModelRDWQuery<T>.Open(aSql: string): IModelQuery;
begin
  FQuery.Close;
  Result := Self;
  FQuery.Open(aSql);
end;

function TModelRDWQuery<T>.Params: TParams;
begin
  Result := FQuery.Params;
end;

function TModelRDWQuery<T>.Query: TObject;
begin
  Result := FQuery;
end;

function TModelRDWQuery<T>.SQL: TStrings;
begin
   Result := FQuery.SQL;
end;

end.
