unit orm.dao.BaseDAOFiredac;

interface

uses Db,Rtti,orm.conexao.ModelConexaoFactory,orm.IBaseVO,orm.Atributos,
     orm.Lib.Biblioteca, orm.conexao.interfaces.Interfaces, Firedac.Comp.Client,
     System.SysUtils, System.JSON, System.Generics.Collections;
  type
    TBaseDAOFiredac<T : class, constructor> = class(TInterfacedObject, IDAO<T>)
      private
        FQuery: IModelQuery;
        FTransacao: TFDTransaction;
      public
        constructor Create();
        destructor Destroy;override;
        class function New(): IDAO<T>;
        function Inserir(obj: T): integer;
        function Atualizar(obj: T): boolean;
        function Excluir(obj: T): boolean;
        function Listagem(obj: T; const TipoJuncao:TTipoJoin = ttLeftJoin): TDataSet;overload;
        function Listagem(obj: T; TemFiltro: boolean; const TipoJuncao: TTipoJoin = ttLeftJoin; dataIni: string = ''; dataFim: string = ''): T;overload;
        function Listagem(obj: T; const TipoJuncao: TTipoJoin = ttLeftJoin; ConsultaCompleta: boolean = True; dataIni: string = ''; dataFim: string = ''): TJSONObject; overload;
        function Listagem(obj: T; const TipoJuncao: TTipoJoin = ttLeftJoin; ConsultaCompleta: boolean = True): TJSONArray;overload;
        function Listagem(obj: T; const TipoJuncao: TTipoJoin = ttLeftJoin; ConsultaCompleta: boolean = True; TemLista: boolean = True; dataIni: string = ''; dataFim: string = ''): TObjectList<T>;overload;

        //Transa��es com banco de dados.
        procedure ComecarTransacao;
        procedure Commit;
        procedure RollBack;

        //Gerar Classes.
        function ConsultaSql(sql: string): TDataSet;
    end;

implementation

{ TBaseDAOZeos }

function TBaseDAOFiredac<T>.Atualizar(obj: T): boolean;
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

         //Pegar a chave prim�ria para colocar na clausula WHERE.
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

       //Executar query. Op��o 1 � para usar o firedac.
       FQuery := TModelConexaoFactory.New.Query(1).ExecSql(strUpdate);
       if (FQuery as TFDQuery).RecordCount > 0 then
          Result := True
       else Result := False;
  finally
    contexto.Free;
  end;
end;

procedure TBaseDAOFiredac<T>.ComecarTransacao;
begin
   FTransacao.StartTransaction;
end;

procedure TBaseDAOFiredac<T>.Commit;
begin
  FTransacao.Commit;
end;

function TBaseDAOFiredac<T>.ConsultaSql(sql: string): TDataSet;
var
   Lib: TLib<T>;
begin
   FQuery.Open(sql);
   //Result := Lib.CopiarParaDataSet((FQuery as TFDQuery));
end;

constructor TBaseDAOFiredac<T>.Create();
begin
   //FQuery := TModelConexaoFactory.New.Query(1);
   FTransacao := TFDTransaction.Create(nil);
   FTransacao.Connection := (TModelConexaoFactory.New.Conexao(1).Connection as TFDConnection);
end;

destructor TBaseDAOFiredac<T>.Destroy;
begin
  inherited;
  FTransacao.DisposeOf;
end;

function TBaseDAOFiredac<T>.Excluir(obj: T): boolean;
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

     //pegar a condi��o da clausula WHERE.
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

       //Op��o 1 � para usar o firedac.
       FQuery := TModelConexaoFactory.New.Query(1).ExecSql(strDelete);
       if (FQuery as TFDQuery).RecordCount > 0 then
          Result := True
       else Result := False;

   finally
     contexto.Free;
   end;
end;

function TBaseDAOFiredac<T>.Inserir(obj: T): integer;
var
  contexto: TRttiContext;
  tipo: TRttiType;
  propriedade: TRttiProperty;
  atributos: TCustomAttribute;
  strInsert, strCampos,strValores,strTabela: string;
  Lib: TLib<T>;
begin
   strInsert := 'INSERT INTO [TABELA]([CAMPOS]) VALUES([VALORES]) RETURNING ID';
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
        FQuery := TModelConexaoFactory.New.Query(1).ExecSql(strInsert);
        if (FQuery as TFDQuery).RecordCount > 0 then
            Result := (FQuery as TFDQuery).FieldByName('ID').AsInteger
        else Result := 0;

   finally
     contexto.Free;
   end;
end;

function TBaseDAOFiredac<T>.Listagem(obj: T; const TipoJuncao: TTipoJoin;
  ConsultaCompleta: boolean; dataIni: string; dataFim: string): TJSONObject;
var
   contexto: TRttiContext;
   tipo: TRttiType;
   propriedade: TRttiProperty;
   atributo: TCustomAttribute;
   json: TJSONObject;
   strSelect, strCampos, strCondicao, strJuncao, strTabela, alias, aliasEstrangeiro, tabela: string;
   Lib: TLib<T>;
begin
   json := TJSONObject.Create;
   contexto := TRttiContext.Create;
   try
     strSelect := 'SELECT [CAMPOS] FROM [TABELA] [JUNCAO] WHERE [CONDICAO]';
     strCampos := '';
     strTabela := '';
     strJuncao := '';
     strCondicao := '';
     tipo := contexto.GetType(TObject(obj).ClassInfo);
     //pegar o nome da tabela.
     for atributo in tipo.GetAttributes do
     begin
       if atributo is TTabela then
       begin
         strTabela := strTabela + TTabela(atributo).Nome + ' ' + TTabela(atributo).Alias;
         alias := TTabela(atributo).Alias;
       end;

       if not strJuncao.IsEmpty then
          strJuncao := strJuncao + '  ';

       if atributo is TTabelaEstrangeira then
       begin
         aliasEstrangeiro := TTabelaEstrangeira(atributo).Alias;
         case TipoJuncao of
          ttInnerJoin:
                      begin
                        strJuncao := strJuncao + ' INNER JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                                 ' ON ' + TTabela(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).Id;
                        break;
                      end;
          ttLeftJoin:
                      begin
                        strJuncao := strJuncao + ' LEFT JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                                 ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).Id;
                        break;
                      end;
          ttRigthJoin:
                      begin
                         strJuncao := strJuncao + ' RIGTH JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                                 ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).Id;
                        break;
                      end;

         end;
       end;
     end;

     for propriedade in tipo.GetProperties do
       for atributo in propriedade.GetAttributes do
       begin
         if atributo is TChavePrimaria then
           strCampos := strCampos + alias + '.' + TChavePrimaria(atributo).Nome;
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
         if atributo is TCampoEstrangeiro then
           strCampos := strCampos + aliasEstrangeiro + TCampoEstrangeiro(atributo).Nome;
         if atributo is TSomatorio then
           strCampos := strCampos + ' SUM( ' + alias + TSomatorio(atributo).Nome + ') AS SOMATORIO';
         if atributo is TMedia then
            strCampos := strCampos + ' AVG( ' + alias + '.' + TMedia(atributo).Nome + ') AS MEDIA';
         if atributo is TMaximo then
           strCampos := strCampos + ' MAX(' + alias + '.' + TMaximo(atributo).Nome + ') AS MAIOR';
         if atributo is TMinimo then
           strCampos := strCampos + ' MIN( ' + alias + '.' + TMinimo(atributo).Nome + ') AS MENOR';
         if atributo is TCampoFiltro then
         begin
           if not strCondicao.IsEmpty then
              strCondicao := strCondicao + ' AND ';
           if propriedade.PropertyType.TypeKind = tkInteger then
              strCondicao := strCondicao + alias + '.' + TCampoFiltro(atributo).Nome + ' = ' + IntToStr(propriedade.GetValue(TObject(obj)).AsInteger);
           if propriedade.PropertyType.TypeKind = tkString then
              strCondicao := strCondicao + alias + '.' + TCampoFiltro(atributo).Nome + ' LIKE ' + QuotedStr('%'+propriedade.GetValue(TObject(obj)).AsString+'%');
           if propriedade.PropertyType.TypeKind = tkFloat then
           begin
             if CompareText(propriedade.PropertyType.Name, 'TDate') = 0 then
             begin
                if not(dataIni.IsEmpty) and not(dataFim.IsEmpty) then
                   strCondicao := strCondicao + ' BETWEEN ' + dataIni + ' AND ' + dataFim;
             end;
           end;
         end;

         Lib := TLib<T>.Create;
         try
            strSelect := Lib.LocalizarSubstituir(strSelect, '[CAMPOS]', strCampos);
            strSelect := Lib.LocalizarSubstituir(strSelect, '[TABELA]', strTabela);
            strSelect := Lib.LocalizarSubstituir(strSelect, '[JUNCAO]', strJuncao);
            strSelect := Lib.LocalizarSubstituir(strSelect, '[CONDICAO]', strCondicao);
            FQuery.ExecSql(strSelect);
            if (FQuery as TFDQuery).RecordCount > 0 then
               Result := Lib.QueryParaJson(FQuery, 1);
         finally
           Lib.Free;
         end;
       end;
   finally
     contexto.Free;
   end;
end;

function TBaseDAOFiredac<T>.Listagem(obj: T; TemFiltro: boolean; const TipoJuncao: TTipoJoin; dataIni: string; dataFim: string): T;
var
   contexto: TRttiContext;
   tipo: TRttiType;
   propriedade: TRttiProperty;
   atributo: TCustomAttribute;
   strSelect,strTabela,strCampos,strWhere,strJuncao,strCondicao, strParametro1, strParametro2,tabela,alias,aliasEstrangeiro: string;
   Lib: TLib<T>;
begin
   strSelect := 'SELECT [CAMPOS] FROM [TABELA] [JUNCAO] WHERE [CONDICAO]';
   strCampos := '';
   strTabela := '';
   strWhere := '';
   strJuncao := '';
   strCondicao := '';
   strParametro1 := '';
   strParametro2 := '';
   contexto := TRttiContext.Create;
   try
     tipo := contexto.GetType(obj.ClassInfo);

     for atributo in tipo.GetAttributes do
     begin
       if atributo is TTabela then
       begin
         strTabela := strTabela + TTabela(atributo).Nome + ' ' + TTabela(atributo).Alias;
         alias := TTabela(atributo).Alias;
       end;

       if not(strJuncao = EmptyStr) then
          strJuncao := strJuncao + '  ';

       if atributo is TTabelaEstrangeira then
       begin
         aliasEstrangeiro := TTabelaEstrangeira(atributo).Alias;
         case TipoJuncao of
           ttInnerJoin:
                       begin
                          strJuncao := strJuncao + ' INNER JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias + ' ON ' +
                                                   TTabelaEstrangeira(atributo).Alias + '.' +  TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + TTabela(atributo).Alias + '.' + TTabelaEstrangeira(atributo).Id;
                          break;
                       end;
           ttLeftJoin:
                      begin
                        strJuncao := strJuncao + ' LEFT JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                                 ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + TTabela(atributo).Alias + '.' + TTabelaEstrangeira(atributo).Id;
                        break;
                      end;
           ttRigthJoin:
                       begin
                         strJuncao := strJuncao + ' RIGHT JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                                  ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' = TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + TTabela(atributo).Alias + '.' + TTabelaEstrangeira(atributo).Id;
                         break;
                       end;
         end;
       end;
     end;
     //pegar os campos.
       for propriedade in tipo.GetProperties do
         for atributo in propriedade.GetAttributes do
         begin
           if TemFiltro then
           begin
             if not(strCampos = EmptyStr) then
               strCampos := strCampos + ',';

             if atributo is TCampoInteiro then
               strCampos := strCampos + alias + '.' + TCampoInteiro(atributo).Nome;
             if atributo is TCampoTexto then
               strCampos := strCampos + alias + '.' + TCampoTexto(atributo).Nome;
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
             if atributo is TCampoEstrangeiro then
                strCampos := strCampos + aliasEstrangeiro + '.' + TCampoEstrangeiro(atributo).Nome;

             if atributo is TCampoFiltro then
             begin
               if propriedade.GetValue(TObject(obj)).Kind = tkInteger then
                  strCondicao := strCondicao + alias + '.' + TCampoFiltro(atributo).Nome + '=' + IntToStr(propriedade.GetValue(TObject(obj)).AsInteger);
               if propriedade.PropertyType.TypeKind = tkString then
                 strCondicao := strCondicao + alias + '.' + TCampoFiltro(atributo).Nome + ' LIKE ' +  QuotedStr('%'+ propriedade.GetValue(TObject(obj)).AsString+'%');
               if propriedade.PropertyType.TypeKind = tkFloat then
               begin
                  if CompareText(propriedade.PropertyType.Name, 'TDate') = 0 then
                  begin
                     if not(dataIni.IsEmpty) and not(dataFim.IsEmpty) then
                       strCondicao := strCondicao + ' BETWEEN ' + dataIni + ' AND ' + dataFim;
                  end;

               end;
             end;
             if atributo is TSomatorio then
               strCampos := strCampos + 'SUM(' + alias + '.' + TSomatorio(atributo).Nome + ')';
             if atributo is TMedia then
               strCampos := strCampos + 'AVG(' + alias + '.' + TMedia(atributo).Nome + ')';
             if atributo is TMaximo then
               strCampos := strCampos + 'MAX(' + alias + '.' + TMaximo(atributo).Nome + ')';
             if atributo is TMinimo then
               strCampos := strCampos + 'MIN(' + alias + '.' + TMinimo(atributo).Nome + ')';
           end;
         end;

         //Montar a query
         Lib := TLib<T>.Create;
         try
           strSelect := Lib.LocalizarSubstituir(strSelect, '[CAMPOS]', strCampos);
           strSelect := Lib.LocalizarSubstituir(strSelect, '[TABELA]', strTabela);
           strSelect := Lib.LocalizarSubstituir(strSelect, '[JUNCAO]', strJuncao);
           strSelect := Lib.LocalizarSubstituir(strSelect, '[CONDICAO]', strCondicao);

           //Executar a query.
           FQuery.ExecSql(strSelect);
           if (FQuery as TFDQuery).RecordCount > 0 then
               Result := Lib.QueryParaObjeto(FQuery, 1);
         finally
           Lib.Free;
         end;
   finally
     contexto.Free;
   end;
end;

function TBaseDAOFiredac<T>.Listagem(obj: T; const TipoJuncao:TTipoJoin = ttLeftJoin): TDataSet;
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
     FQuery := TModelConexaoFactory.New.Query(1).ExecSql(strSelect);
     if (FQuery as TFDQuery).RecordCount > 0 then
       Result := (FQuery as TFDQuery);

   finally
     contexto.Free;
   end;
end;

class function TBaseDAOFiredac<T>.New(): IDAO<T>;
begin
   Result := Self.Create();
end;

procedure TBaseDAOFiredac<T>.RollBack;
begin
  FTransacao.Rollback;
end;

function TBaseDAOFiredac<T>.Listagem(obj: T; const TipoJuncao: TTipoJoin;
  ConsultaCompleta: boolean): TJSONArray;
var
   contexto: TRttiContext;
   tipo: TRttiType;
   propriedade: TRttiProperty;
   atributo: TCustomAttribute;
   objArray: TJSONArray;
   Lib: TLib<T>;
   strSelect,strCampos,strTabela,strJuncao, alias, aliasEstrangeiro: string;
begin
  strSelect := 'SELECT TOP 100 [CAMPOS] FROM [TABELAS] [JUNCAO]';
  strCampos := '';
  strTabela := '';
  strJuncao := '';
  contexto := TRttiContext.Create;
  objArray := TJSONArray.Create;
  try
    tipo := contexto.GetType(TObject(obj).ClassInfo);
    //pegar o nome da tabela.
    for atributo in tipo.GetAttributes do
    begin
      if atributo is TTabela then
      begin
        strTabela := strTabela + TTabela(atributo).Nome + ' ' + TTabela(atributo).Alias;
        alias :=  TTabela(atributo).Alias;
      end;

      if not strJuncao.IsEmpty then
        strJuncao := strJuncao + ' ';

      if atributo is TTabelaEstrangeira then
      begin
        case TipoJuncao of
          ttInnerJoin: strJuncao := strJuncao + ' INNER JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                                 ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).Id;
          ttLeftJoin: strJuncao := strJuncao + ' LEFT JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                               ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).Id;
          ttRigthJoin: strJuncao := strJuncao + ' RIGTH JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias +
                                                ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).Id;
        end;
      end;
    end;

    //pegar os campos.
    for propriedade in tipo.GetProperties do
      for atributo in propriedade.GetAttributes do
      begin
        if not strCampos.IsEmpty then
          strCampos := strCampos + ',';

        if atributo is TChavePrimaria then
          strCampos := strCampos + alias + '.' + TChavePrimaria(atributo).Nome;
        if atributo is TChaveEstrangeira then
          strCampos := strCampos + alias + '.' + TChaveEstrangeira(atributo).Nome;
        if atributo is TCampoInteiro then
          strCampos := strCampos + alias + '.' + TCampoInteiro(atributo).Nome;
        if atributo is TCampoTexto then
          strCampos := strCampos + alias + '.' + TCampoTexto(atributo).Nome;
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
        if atributo is TCampoEstrangeiro then
          strCampos := strCampos + TCampoEstrangeiro(atributo).Alias + TCampoEstrangeiro(atributo).Nome;
        if atributo is TSomatorio then
          strCampos := strCampos + 'SUM(' + alias + '.' + TSomatorio(atributo).Nome + ') AS SOMA';
        if atributo is TMedia then
          strCampos := strCampos + 'AVG(' + alias + '.' + TMedia(atributo).Nome + ') AS MEDIA';
        if atributo is TMaximo then
          strCampos := strCampos + 'MAX(' + alias + '.' + TMaximo(atributo).Nome + ') AS MAIOR';
        if atributo is TMinimo then
          strCampos := strCampos + 'MIN(' + alias + '.' + TMinimo(atributo).Nome + ') AS MENOR';
      end;

      Lib := TLib<T>.Create;
      try
         strSelect := Lib.LocalizarSubstituir(strSelect, '[TABELA]', strTabela);
         strSelect := Lib.LocalizarSubstituir(strSelect, '[JUNCAO]', strJuncao);
         strSelect := Lib.LocalizarSubstituir(strSelect, '[CAMPOS]', strCampos);

         //Executar a query.
         FQuery.ExecSql(strSelect);
         if (FQuery as TFDQuery).RecordCount > 0 then
         begin
           //Transforma a consulta em um Array de Json.
           objArray := Lib.QueryParaArrayJson(FQuery, 1);
           Result := objArray;
         end;
      finally
        Lib.Free;
      end;
  finally
    contexto.Free;
    objArray.Free;
  end;
end;

function TBaseDAOFiredac<T>.Listagem(obj: T; const TipoJuncao: TTipoJoin;
  ConsultaCompleta, TemLista: boolean; dataIni: string; dataFim: string): TObjectList<T>;
var
  contexto: TRttiContext;
  tipo: TRttiType;
  propriedade: TRttiProperty;
  atributo: TCustomAttribute;
  Lista: TObjectList<T>;
  strSelect, strSelectCompleta, strCampos, strJuncao, strTabela, strCondicao, alias, aliasEstrangeiro: string;
  Lib: TLib<T>;
begin
   strSelectCompleta := 'SELECT TOP 100 [CAMPOS] FROM [TABELA] [JUNCAO] WHERE [CONDICAO]';
   strSelect := 'SELECT TOP 100 [CAMPOS] FROM [TABELA] [JUNCAO]';
   strCampos := '';
   strJuncao := '';
   strTabela := '';
   strCondicao := '';
   contexto := TRttiContext.Create;
   try
     tipo := contexto.GetType(TObject(obj).ClassInfo);
     for atributo in tipo.GetAttributes do
     begin
       if atributo is TTabela then
       begin
         strTabela := strTabela + TTabela(atributo).Nome + ' ' + TTabela(atributo).Alias;
         alias := TTabela(atributo).Alias;
       end;

       if not strJuncao.IsEmpty then
          strJuncao := strJuncao + ' ';
       if atributo is TTabelaEstrangeira then
       begin
         aliasEstrangeiro := TTabelaEstrangeira(atributo).Alias;
         case TipoJuncao of
           ttInnerJoin: strJuncao := strJuncao + 'INNER JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias + 'ON' +
                                                  TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + '=' + alias + '.' + TTabelaEstrangeira(atributo).Id;
           ttLeftJoin: strJuncao := strJuncao + 'LEFT JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias + 'ON' +
                                                  TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + '=' + alias + '.' + TTabelaEstrangeira(atributo).Id;
           ttRigthJoin: strJuncao := strJuncao + 'RIGTH JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias + 'ON' +
                                                  TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + '=' + alias + '.' + TTabelaEstrangeira(atributo).Id;
         end;
       end;
     end;
     for propriedade in tipo.GetProperties do
       for atributo in propriedade.GetAttributes do
       begin
         if not strCampos.IsEmpty then
           strCampos := strCampos + ',';

         if atributo is TChavePrimaria then
            strCampos := strCampos + alias + '.' + TChavePrimaria(atributo).Nome;
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
         if atributo is TCampoEstrangeiro then
           strCampos := strCampos + aliasEstrangeiro + '.' + TCampoEstrangeiro(atributo).Nome;
         if atributo is TChaveEstrangeira then
            strCampos := strCampos + alias + TChaveEstrangeira(atributo).Nome;
         if atributo is TSomatorio then
           strCampos := strCampos + 'SUM(' + alias + '.' + TSomatorio(atributo).Nome + ') AS SOMATORIO';
         if atributo is TMedia then
           strCampos := strCampos + 'AVG(' + alias + '.' + TMedia(atributo).Nome + ') AS MEDIA';
         if atributo is TMaximo then
            strCampos := strCampos + 'MAX(' + alias + '.' + TMaximo(atributo).Nome + ') AS MAIOR';
         if atributo is TMinimo then
            strCampos := strCampos + 'MIN(' + alias + '.' + TMinimo(atributo).Nome + ') AS MENOR';
         if atributo is TCampoFiltro then
         begin
           if propriedade.PropertyType.TypeKind = tkInteger then
             strCondicao := strCondicao + alias + '.' + TCampoFiltro(atributo).Nome + '=' + IntToStr(propriedade.GetValue(TObject(obj)).AsInteger);
           if propriedade.PropertyType.TypeKind = tkString then
             strCondicao := strCondicao + alias + '.' + TCampoFiltro(atributo).Nome + ' LIKE ' + QuotedStr('%'+propriedade.GetValue(TObject(obj)).AsString+'%');
           if propriedade.PropertyType.TypeKind = tkFloat then
           begin
             if CompareStr(propriedade.PropertyType.Name, 'TDate') > 0 then
             begin
               if not(dataIni.IsEmpty) and not(dataFim.IsEmpty) then
                  strCondicao := strCondicao + TCampoFiltro(atributo).Nome + ' BETWEEN ' + dataIni + ' AND ' + dataFim;
             end;
           end;
         end;
       end;
       Lib := TLib<T>.Create;
       try
         if ConsultaCompleta then
         begin
           strSelectCompleta := Lib.LocalizarSubstituir(strSelectCompleta, '[TABELA]', strTabela);
           strSelectCompleta := Lib.LocalizarSubstituir(strSelectCompleta, '[JUNCAO]', strJuncao);
           strSelectCompleta := Lib.LocalizarSubstituir(strSelectCompleta, '[CONDICAO]', strCondicao);
           strSelectCompleta := Lib.LocalizarSubstituir(strSelectCompleta, '[CAMPOS]', strCampos);
           FQuery.ExecSql(strSelectCompleta);
         end
         else
         begin
            strSelect := Lib.LocalizarSubstituir(strSelect, '[TABELA]', strTabela);
            strSelect := Lib.LocalizarSubstituir(strSelect, '[CAMPOS]', strCampos);
            strSelect := Lib.LocalizarSubstituir(strSelect, '[JUNCAO]', strJuncao);
            FQuery.ExecSql(strSelect);
         end;
         if (FQuery as TFDQuery).RecordCount > 0 then
         begin
           Lista := Lib.QueryParaListaObjeto(FQuery, 1);
           Result := Lista;
         end;
       finally
         Lib.Free;
       end;
   finally
     contexto.Free;
   end;

end;

end.
