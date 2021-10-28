unit orm.conexao.interfaces.Interfaces;

interface

uses
  Data.DB, orm.IBaseVO, orm.Atributos;

type
    TTipoController = (tcCliente, tcFuncionario, tcFornecedor, tcTransportadora, tcProduto, tcVenda, tcNfe, tcNfce);

type
    IModelQuery = interface;


   IModelConexao = interface
   ['{E053AD22-4518-478A-906B-0373BF9CAF8A}']
     function Connection: TObject;
   end;

   IModelConexaoFactory = interface(iinterface)
     ['{DEB41385-72C6-40F1-AEF7-67DE1175BC20}']
       function Conexao(aOp: integer): IModelConexao;
       function Query(aOp: integer): IModelQuery;
   end;

   IModelQuery = interface(iinterface)
       ['{10E5C694-4672-4DD4-A75F-D04A2A38ECBC}']
         function Query: TObject;
         function Open(aSql: string): IModelQuery;
         function ExecSql(aSql: string): IModelQuery;
   end;

   IDAO <T: class> = interface(iinterface)
     ['{7FBAC46D-3355-414C-9B35-CB20D000BB27}']
     function Inserir(obj: T): integer;
     function Atualizar(obj: T): boolean;
     function Excluir(obj: T): boolean;
     function Listagem(obj: T; const TipoJuncao:TTipoJoin = ttLeftJoin): TDataSet;
     function ConsultaSql(sql: string): TDataSet;
   end;

   IController<T: class> = interface(iinterface)
     ['{01620415-A483-4162-B952-0A56CD36B3B1}']
     function Salvar(obj: T): integer;
     function Atualizar(obj: T): boolean;
     function Excluir(obj: T): boolean;
     function Listagem(obj: T): TDataSet;
   end;

   IFabricaController<T: class> = interface(iinterface)
     ['{ADB6D3D4-3F24-427D-A631-53457A76DCEC}']
     function Controller(aTipoController: TTipoController): IController<T>;
   end;

 implementation

end.
