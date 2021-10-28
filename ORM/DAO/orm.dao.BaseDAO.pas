unit orm.dao.BaseDAO;

interface

uses Db,Rtti,orm.conexao.ModelConexaoFactory,orm.IBaseVO,orm.Atributos,
     orm.Lib.Biblioteca, orm.conexao.interfaces.Interfaces, ZDataset,
  uRESTDWPoolerDB, orm.conexao.model_rdw.ModelRDWQuery, System.SysUtils;
  type
    TBaseDAO<T : class, constructor> = class(TInterfacedObject, IDAO<T>)
      private
        FConexao: TRESTDWDatabase;
        FQuery: IModelQuery;
      public
        constructor Create(aConexao: TRESTDWDatabase);
        class function New(aConexao: TRESTDWDatabase): IDAO<T>;
        function Inserir(obj: T): integer;
        function Atualizar(obj: T): boolean;
        function Excluir(obj: T): boolean;
        function Listagem(obj: T; const TipoJuncao:TTipoJoin = ttLeftJoin): TDataSet;
        function ConsultaSql(sql: string): TDataSet;
    end;

implementation

{ TBaseDAO }

function TBaseDAO<T>.Atualizar(obj: T): boolean;
var
  contexto: TRttiContext;
  tipo: TRttiType;
  propriedade: TRttiProperty;
  atributos: TCustomAttribute;
  strUpdate,strCampos,strWhere, strTabela: string;
  Lib: TLib<T>;
begin
  strUpdate := 'UPDATE [TABELA] SET [CAMPOS] WHERE [CONDICAO]';
  strCampos := '';
  strWhere := '';
  strTabela := '';
  contexto := TRttiContext.Create;
  try
    tipo := contexto.GetType(obj.ClassInfo);
    //pegar o nome da tabela.
    for atributos in tipo.GetAttributes do
    begin
      if atributos is TTabela then
         strTabela := strTabela + TTabela(atributos).Nome;
    end;

    //pegar o nome dos campos e seus valores.
    for propriedade in tipo.GetProperties do
       for atributos in propriedade.GetAttributes do
       begin
         if not(strCampos = '') then
            strCampos := strCampos + ',';

         if atributos is TCampoTexto then
         begin
           strCampos := strCampos + TCampoTexto(atributos).Nome + '= ' + propriedade.GetValue(TObject(obj)).ToString;
         end;

         if atributos is TCampoInteiro then
            strCampos := strCampos + TCampoInteiro(atributos).Nome + '= ' + propriedade.GetValue(TObject(obj)).ToString;

         if atributos is TCampoData then
            strCampos := strCampos + TCampoData(atributos).Nome + '= ' + propriedade.GetValue(TObject(obj)).ToString;

         if atributos is TCampoDataHora then
            strCampos := strCampos + TCampoDataHora(atributos).Nome + '= ' + propriedade.GetValue(TObject(obj)).ToString;

         if atributos is TCampoExtended then
            strCampos := strCampos + TCampoExtended(atributos).Nome + '= ' + propriedade.GetValue(TObject(obj)).ToString;

         if atributos is TCampoMonetario then
            strCampos := strCampos + TCampoMonetario(atributos).Nome + '= ' + propriedade.GetValue(TObject(obj)).ToString;

         if atributos is TCampoBooleano then
            strCampos := strCampos + TCampoBooleano(atributos).Nome + '= ' + propriedade.GetValue(TObject(obj)).ToString;

         if atributos is TChaveEstrangeira then
            strCampos := strCampos + TChaveEstrangeira(atributos).Nome + '= ' + propriedade.GetValue(TObject(obj)).ToString;

         //Pegar a chave primária para colocar na clausula WHERE.
         if atributos is TChavePrimaria then
            strWhere := strWhere + TChavePrimaria(atributos).Nome + '= ' + propriedade.GetValue(TObject(obj)).ToString;
       end;

       //Montar a query.
       Lib := TLib<T>.Create;
       try
         strUpdate := Lib.LocalizarSubstituir(strUpdate,'[TABELA]', strTabela);
         strUpdate := Lib.LocalizarSubstituir(strUpdate,'[CAMPOS]', strCampos);
         strUpdate := Lib.LocalizarSubstituir(strUpdate,'[CONDICAO]',strWhere);
       finally
         Lib.Free;
       end;

      { 2 Camadas cliente-servidor.
      //Executar query. Opção 2 é para usar o zeos.
       FQuery := TModelConexaoFactory.New.Query(2).ExecSql(strUpdate);
       if (FQuery as TZQuery).RecordCount > 0 then
          Result := True
       else Result := False;}

       //Rest Dataware 3 camadas.
       FQuery := TModelRDWQuery<T>.New(FConexao).ExecSql(strUpdate);
       if (FQuery as TRESTDWClientSQL).RecordCount > 0 then
          Result := True
       else Result := False;

  finally
    contexto.Free;
  end;
end;

function TBaseDAO<T>.ConsultaSql(sql: string): TDataSet;
begin
  raise Exception.Create('Falta implementar esse método');
end;

constructor TBaseDAO<T>.Create(aConexao: TRESTDWDatabase);
begin
   FConexao := aConexao;
end;

function TBaseDAO<T>.Excluir(obj: T): boolean;
var
  contexto: TRttiContext;
  tipo: TRttiType;
  propriedade: TRttiProperty;
  atributo: TCustomAttribute;
  strDelete,strTabela,strCondicao, strWhere: string;
  Lib: TLib<T>;
begin
   strDelete := 'DELETE FROM [TABELA] WHERE [CONDICAO]';
   strTabela := '';
   strCondicao := '';
   contexto := TRttiContext.Create;
   try
     tipo := contexto.GetType(obj.ClassInfo);
     //pegar o nome da tabela.
     for atributo in tipo.GetAttributes do
     begin
       if atributo is TTabela then
          strTabela := strTabela + TTabela(atributo).Nome;
     end;

     //pegar a condição da clausula WHERE.
     for propriedade in tipo.GetProperties do
       for atributo in propriedade.GetAttributes do
       begin
         if atributo is TChavePrimaria then
            strWhere := strWhere + TChavePrimaria(atributo).Nome + '= ' + propriedade.GetValue(TObject(obj)).ToString;
       end;

       //Montar query.
       Lib := TLib<T>.Create;
       try
         strDelete := Lib.LocalizarSubstituir(strDelete,'[TABELA]',strTabela);
         strDelete := Lib.LocalizarSubstituir(strDelete,'[CONDICAO]',strWhere);
       finally
         Lib.Free;
       end;

       //Executar a query. Clinte e Servidor
       {FQuery := TModelConexaoFactory.New.Query(2).ExecSql(strDelete);
       if (FQuery as TZQuery).RecordCount > 0 then
          Result := True
       else Result := False;}

       //Rest Dataware n camadas.
       FQuery := TModelRDWQuery<T>.New(FConexao).ExecSql(strDelete);
       if (FQuery as TRestDWClientSQL).RecordCount > 0 then
          Result := True
       else Result := False;
   finally
     contexto.Free;
   end;
end;

function TBaseDAO<T>.Inserir(obj: T): integer;
var
  contexto: TRttiContext;
  tipo: TRttiType;
  propriedade: TRttiProperty;
  atributos: TCustomAttribute;
  strInsert, strCampos,strValores,strTabela: string;
  Lib: TLib<T>;
begin
   strInsert := 'INSERT INTO [TABELA]([CAMPOS]) VALUES([VALORES])';
   strCampos := '';
   strValores := '';
   strTabela := '';
   contexto := TRttiContext.Create;
   try
     tipo := contexto.GetType(obj.ClassInfo);
     //Pegar o nome da tabela.
     for atributos in tipo.GetAttributes do
     begin
       if atributos is TTabela then
         strTabela := strTabela + TTabela(atributos).Nome;
     end;

     //Pegar os campos da tabela.
     for propriedade in tipo.GetProperties do
       for atributos in propriedade.GetAttributes do
        begin

          if not(strCampos = '') then
             strCampos := strCampos + ',';

          if atributos is TCampoTexto then
            strCampos := strCampos + TCampoTexto(atributos).Nome;

          if atributos is TCampoInteiro then
            strCampos := strCampos + TCampoInteiro(atributos).Nome;

          if atributos is TCampoData then
            strCampos := strCampos + TCampoData(atributos).Nome;

          if atributos is TCampoDataHora then
            strCampos := strCampos + TCampoDataHora(atributos).Nome;

          if atributos is TCampoExtended then
             strCampos := strCampos + TCampoExtended(atributos).Nome;

          if atributos is TCampoMonetario then
             strCampos := strCampos + TCampoMonetario(atributos).Nome;

          if atributos is TCampoBooleano then
             strCampos := strCampos + TCampoBooleano(atributos).Nome;

          if atributos is TChaveEstrangeira then
             strCampos := strCampos + TChaveEstrangeira(atributos).Nome;
        end;

        //Pegar os valores os campos.
        for propriedade in tipo.GetProperties do
        begin
          for atributos in propriedade.GetAttributes do
          begin
            if not(strValores = '') then
               strValores := strValores + ',';

            if atributos is TCampoTexto then
               strValores := strValores + propriedade.GetValue(TObject(obj)).ToString;

            if atributos is TCampoInteiro then
               strValores := strValores + propriedade.GetValue(TObject(obj)).ToString;

            if atributos is TCampoData then
               strValores := strValores + propriedade.GetValue(TObject(obj)).ToString;

            if atributos is TCampoDataHora then
               strValores := strValores + propriedade.GetValue(TObject(obj)).ToString;

            if atributos is TCampoExtended then
               strValores := strValores + propriedade.GetValue(TObject(obj)).ToString;

            if atributos is TCampoMonetario then
               strValores := strValores + propriedade.GetValue(TObject(obj)).ToString;

            if atributos is TCampoBooleano then
               strValores := strValores + propriedade.GetValue(TObject(obj)).ToString;

            if atributos is TChaveEstrangeira then
               strValores := strValores + propriedade.GetValue(TObject(obj)).ToString;
          end;
        end;

        //Montar a query.
        Lib := TLib<T>.Create;
        try
          strInsert := Lib.LocalizarSubstituir(strInsert,'[TABELA]',strTabela);
          strInsert := Lib.LocalizarSubstituir(strInsert,'[CAMPOS]',strCampos);
          strInsert := Lib.LocalizarSubstituir(strInsert,'[VALORES]',strValores);
        finally
          Lib.Free;
        end;

        //Executar a query.
        {  Cliente e servidor.
        FQuery := TModelConexaoFactory.New.Query(2).ExecSql(strInsert);
        if (FQuery as TZQuery).RecordCount > 0 then
            Result := True
        else Result := False;}

        //Rest Dataware n camadas.
        FQuery := TModelRDWQuery<T>.New(FConexao).ExecSql(strInsert);
        if (FQuery as TRestDWClientSQL).RecordCount > 0 then
           Result := (FQuery as TRestDWClientSQL).FieldByName('ID').AsInteger
        else Result := -1;
   finally
     contexto.Free;
   end;
end;

function TBaseDAO<T>.Listagem(obj: T; const TipoJuncao:TTipoJoin = ttLeftJoin): TDataSet;
var
   contexto: TRttiContext;
   tipo: TRttiType;
   propriedade: TRttiProperty;
   atributo: TCustomAttribute;
   strSelect,strTabela,strCampos,strWhere,strJuncao,strCondicao,tabela,alias,aliasEstrangeiro: string;
   Lib: TLib<T>;
begin
   strSelect := 'SELECT TOP 100 [CAMPOS] FROM [TABELA] [JUNCAO] WHERE [CONDICAO]';
   strTabela := '';
   strCampos := '';
   strWhere := '';
   strJuncao := '';
   contexto := TRttiContext.Create;
   try
     tipo := contexto.GetType(obj.ClassInfo);
     //Pegar o nome da Tabela.
     for atributo in tipo.GetAttributes do
     begin
       if atributo is TTabela then
       begin
          strTabela := strTabela + TTabela(atributo).Nome + ' ' + TTabela(atributo).Alias;
          tabela := TTabela(atributo).Nome;
          alias :=  TTabela(atributo).Alias;
       end;
       if not(strJuncao = '') then
          strJuncao := strJuncao + ' ';

       if atributo is TTabelaEstrangeira then
       begin
          aliasEstrangeiro := TTabelaEstrangeira(atributo).Alias;
          case TipoJuncao of
             ttInnerJoin:
                         begin
                            strJuncao := strJuncao + ' INNER JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                         ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).Id;
                            break;
                         end;
             ttRigthJoin:
                         begin
                             strJuncao := strJuncao + ' RIGHT JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                          ' ON ' + TTabelaEstrangeira(atributo).Id + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro;
                             break;
                         end;
             ttLeftJoin:
                         begin
                           strJuncao := strJuncao + ' LEFT JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                        ' ON ' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).Id;
                           break;
                         end;
          end;
       end;
     end;



       //Pegar os campos.
       for propriedade in tipo.GetProperties do
         for atributo in propriedade.GetAttributes do
         begin
           if not(strCampos = '') then
              strCampos := strCampos + ',';

           if atributo is TCampoTexto then
              strCampos := strCampos + alias + '.' + TCampoTexto(atributo).Nome;

           if atributo is TCampoInteiro then
              strCampos := strCampos + alias + '.' + TCampoInteiro(atributo).Nome;

           if atributo is TCampoData then
              strCampos := strCampos + alias + '.' + TCampoData(atributo).Nome;

           if atributo is TCampoDataHora then
              strCampos := strCampos + alias + '.' + TCampoDataHora(atributo).Nome;

           if atributo is TCampoExtended then
              strCampos := strCampos + alias + '.' + TCampoExtended(atributo).Nome;

           if atributo is TCampoMonetario then
              strCampos := strCampos + alias + '.' + TCampoMonetario(atributo).Nome;

           if atributo is TCampoBooleano then
              strCampos := strCampos + alias + '.' + TCampoBooleano(atributo).Nome;

           if atributo is TChavePrimaria then
              strCampos := strCampos + alias + '.' + TChavePrimaria(atributo).Nome;

           if atributo is TChaveEstrangeira then
              strCampos := strCampos + alias + '.' + TChaveEstrangeira(atributo).Nome;

           if atributo is TCampoEstrangeiro then
           begin
              if atributo is TSomatorio then
              begin
                if TSomatorio(atributo).Ativo then
                  strCampos :=  strCampos + 'SUM('+ aliasEstrangeiro + '.' +TSomatorio(atributo).Nome+')'
              end;

              if atributo is TMedia then
              begin
                if TMedia(atributo).Ativo then
                   strCampos := strCampos + 'AVG('+ aliasEstrangeiro + '.' + TMedia(atributo).Nome+')';
              end;

              if atributo is TMinimo then
              begin
                if TMinimo(atributo).Ativo then
                  strCampos := strCampos + 'MIN('+ aliasEstrangeiro + '.' + TMinimo(atributo).Nome+')';
              end;

              if atributo is TMaximo then
              begin
                if TMaximo(atributo).Ativo then
                  strCampos := strCampos + 'MAX(' + aliasEstrangeiro + '.' + TMaximo(atributo).Nome+')';
              end;
              strCampos := strCampos + aliasEstrangeiro + '.' + TCampoEstrangeiro(atributo).Nome;
           end;

           if atributo is TSomatorio then
           begin
             if TSomatorio(atributo).Ativo then
                strCampos := strCampos + 'SUM('+ alias + '.' + TSomatorio(atributo).Nome+')';
           end;

           if atributo is TMedia then
           begin
             if TMedia(atributo).Ativo then
               strCampos := strCampos + 'AVG('+ alias + '.' + TMedia(atributo).Nome+')';
           end;

           if atributo is TMinimo then
           begin
             if TMinimo(atributo).Ativo then
               strCampos := strCampos + 'MIN('+ alias + '.' + TMinimo(atributo).Nome+')';
           end;

           if atributo is TMaximo then
           begin
             if TMaximo(atributo).Ativo then
               strCampos :=  strCampos + 'MAX('+ alias + '.' + TMaximo(atributo).Nome+')';
           end;

           //Pegar os campos para filtro na clausula WHERE.

           if atributo is TCampoFiltro then
              strWhere := strWhere + alias + '.' + TCampoFiltro(atributo).Nome;
         end;
     //Montar a query.
     Lib := TLib<T>.Create;
     try
        strSelect := Lib.LocalizarSubstituir(strSelect, '[TABELA]', strTabela);
        strSelect := Lib.LocalizarSubstituir(strSelect, '[JUNCAO]', strJuncao);
        strSelect := Lib.LocalizarSubstituir(strSelect, '[CONDICAO]', strCondicao);
        strSelect := Lib.LocalizarSubstituir(strSelect, '[CAMPOS]', strCampos);
     finally
       Lib.Free;
     end;

     //Executar a query.
     {Modelo Cliente e Servidor.
     FQuery := TModelConexaoFactory.New.Query(2).ExecSql(strSelect);
     if (FQuery as TZQuery).RecordCount > 0 then
       Result := Lib.CopiarParaDataSet((FQuery as TZQuery));}

     //Rest Dataware n camadas.
     FQuery := TModelRDWQuery<T>.New(FConexao).ExecSql(strSelect);
     if (FQuery as TRestDWClientSQL).RecordCount > 0 then
         Result := (FQuery as TRestDWClientSQL);
   finally
     contexto.Free;
   end;
end;

class function TBaseDAO<T>.New(aConexao: TRESTDWDatabase): IDAO<T>;
begin
   Result := Self.Create(aConexao);
end;

end.
