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
        function Atualizar(obj: T): boolean;overload;
        function Atualizar(obj, objOld: T): boolean;overload;
        function Excluir(obj: T): boolean;
        function Listagem(obj: T; const TipoJuncao:TTipoJoin = ttLeftJoin): TDataSet;
        function ConsultaSql(sql: string): TDataSet;
        {Fazer mais um m�todo de atualiza��o e mais listagem com v�rios retornos DataSet, IBaseVO, Listagem e Json}
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

      { 2 Camadas cliente-servidor.
      //Executar query. Op��o 2 � para usar o zeos.
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

function TBaseDAO<T>.Atualizar(obj, objOld: T): boolean;
var contexto: TRttiContext;
    tipo, tipoOld: TRttiType;
    propriedade, propriedadeOld: TRttiProperty;
    atributos, atributoOld: TCustomAttribute;
    strUpdate, strTabela, strWhere, strCampos, nomeTipo: string;
    Lib: TLib<T>;
    valorNovo,valorAntigo: variant;
    achouValorAntigo: boolean;
begin
   strUpdate := 'UPDATE [TABELA] SET [CAMPOS] WHERE [CONDICAO]';
   strTabela := '';
   strWhere := '';
   strCampos := '';
   contexto := TRttiContext.Create();
   try
     tipo := contexto.GetType(Obj.ClassType);
     tipoOld := contexto.GetType(objOld.ClassType);
     for atributos in tipo.GetAttributes do
     begin
       if atributos is TTabela then
         strTabela := strTabela + TTabela(atributos).Nome;
     end;
     for propriedade in tipo.GetProperties do
     begin
       for atributos in propriedade.GetAttributes do
       begin
         if atributos is TCampoTexto then
         begin
           achouValorAntigo := False;
           valorNovo := propriedade.GetValue(TObject(Obj)).AsString;
         end;
         if atributos is TCampoInteiro then
         begin
           achouValorAntigo := False;
           valorNovo := propriedade.GetValue(TObject(obj)).AsInteger;
         end;
         if atributos is TCampoData then
         begin
           achouValorAntigo := False;
           valorNovo := propriedade.GetValue(TObject(obj)).AsString;
         end;
         if atributos is TCampoDataHora then
         begin
           achouValorAntigo := False;
           valorNovo := propriedade.GetValue(TObject(obj)).AsString;
         end;
         if atributos is TCampoMonetario then
         begin
           achouValorAntigo := False;
           valorNovo := propriedade.GetValue(TObject(obj)).AsCurrency;
         end;
         if atributos is TCampoExtended then
         begin
           achouValorAntigo := False;
           valorNovo := propriedade.GetValue(TObject(obj)).AsExtended;
         end;
         if atributos is TCampoBooleano then
         begin
           achouValorAntigo := False;
           valorNovo := propriedade.GetValue(TObject(obj)).AsBoolean;
         end;
       end;
       for propriedadeOld in tipoOld.GetProperties do
       begin
         for atributoOld in propriedadeOld.GetAttributes do
         begin
           if strCampos <> EmptyStr then
              strCampos := strCampos + ',';
           if atributoOld is TCampoTexto then
           begin
             if TCampoTexto(atributoOld).Nome = TCampoTexto(atributos).Nome then
             begin
               achouValorAntigo := True;
               valorAntigo := propriedadeOld.GetValue(TObject(objOld)).AsString;

               if valorNovo <> valorAntigo then
               begin
                 if propriedade.PropertyType.TypeKind in [tkString, tkUString, tkUnicodeString] then
                    strCampos := strCampos + TCampoTexto(atributos).Nome + '=' + QuotedStr(propriedade.GetValue(TObject(obj)).AsString)
                 else  strCampos := strCampos + TCampoTexto(atributos).Nome + '=' + 'null';
               end;
             end;
           end;
           if atributoOld is TCampoInteiro then
           begin
             if TCampoInteiro(atributoOld).Nome = TCampoInteiro(atributos).Nome then
             begin
               achouValorAntigo := True;
               valorAntigo := propriedadeOld.GetValue(TObject(objOld)).AsInteger;

               if valorNovo <> valorAntigo then
               begin
                 if propriedade.PropertyType.TypeKind in [tkInteger, tkInt64] then
                 begin
                   if propriedade.GetValue(TObject(obj)).AsInteger <> 0 then
                      strCampos := strCampos + TCampoInteiro(atributos).Nome + '=' + propriedade.GetValue(TObject(obj)).AsString
                   else strCampos := strCampos + TCampoInteiro(atributos).Nome + '=' + 'null';
                 end
               end;
             end;
           end;
           if atributoOld is TCampoData then
           begin
             if TCampoData(atributoOld).Nome = TCampoData(atributos).Nome then
             begin
               achouValorAntigo := True;
               valorAntigo := propriedadeOld.GetValue(TObject(objOld)).AsExtended;

               if valorNovo <> valorAntigo then
               begin
                 if propriedade.PropertyType.TypeKind = tkFloat then
                 begin
                   if propriedade.GetValue(TObject(obj)).AsExtended <> 0 then
                   begin
                     nomeTipo := lowercase(propriedade.PropertyType.Name);
                     if nomeTipo = 'tdate' then
                        strCampos := strCampos + TCampoData(atributos).Nome + '=' + FormatDateTime(TCampoData(atributos).Mascara, propriedade.GetValue(TObject(obj)).AsExtended);
                   end;
                 end;
               end;
             end;
           end;
           if atributoOld is TCampoDataHora then
           begin
             if TCampoDataHora(atributoOld).Nome = TCampoDataHora(atributos).Nome then
             begin
               achouValorAntigo := True;
               valorAntigo := propriedadeOld.GetValue(TObject(objOld)).AsExtended;

               if valorNovo <> valorAntigo then
               begin
                 if propriedade.PropertyType.TypeKind = tkFloat then
                 begin
                   if propriedade.GetValue(TObject(obj)).AsExtended <> 0 then
                   begin
                     nomeTipo := LowerCase(propriedade.PropertyType.Name);
                     if nomeTipo = 'tdatetime' then
                        strCampos := strCampos + TCampoDataHora(atributos).Nome + '=' + FormatDateTime(TCampoDataHora(atributos).Mascara, propriedade.GetValue(TObject(obj)).AsExtended);
                   end;

                 end;
               end;
             end;
           end;
           if atributoOld is TCampoExtended then
           begin
             if TCampoExtended(atributoOld).Nome = TCampoExtended(atributos).Nome then
             begin
               achouValorAntigo := True;
               valorAntigo := propriedade.GetValue(TObject(objOld)).AsExtended;

               if valorNovo <> valorAntigo then
               begin
                 if propriedade.PropertyType.TypeKind = tkFloat then
                 begin
                   if propriedade.GetValue(TObject(obj)).AsExtended <> 0 then
                   begin
                     nomeTipo := LowerCase(propriedade.PropertyType.Name);
                     if nomeTipo = 'textended' then
                        strCampos := strCampos + TCampoExtended(atributos).Nome + '=' + FormatFloat(TCampoExtended(atributos).Mascara, propriedade.GetValue(TObject(obj)).AsExtended);
                   end;
                 end;
               end;
             end;
           end;
           if atributoOld is TCampoMonetario then
           begin
             if TCampoMonetario(atributoOld).Nome = TCampoMonetario(atributos).Nome then
             begin
               achouValorAntigo := True;
               valorAntigo := propriedade.GetValue(TObject(objOld)).AsCurrency;

               if valorNovo <> valorAntigo then
               begin
                 if propriedade.PropertyType.TypeKind = tkFloat then
                 begin
                   if propriedade.GetValue(TObject(obj)).AsCurrency <> 0 then
                   begin
                     strCampos := strCampos + TCampoMonetario(atributos).Nome + '=' + FormatCurr(TCampoMonetario(atributos).Mascara, propriedade.GetValue(TObject(obj)).AsCurrency);
                   end;
                 end;
               end;
             end;
           end;
           if atributoOld is TCampoBooleano then
           begin
             if TCampoBooleano(atributoOld).Nome = TCampoBooleano(atributos).Nome then
             begin
               achouValorAntigo := True;
               valorAntigo := propriedade.GetValue(TObject(objOld)).AsBoolean;

               if valorNovo <> valorAntigo then
               begin
                 if not propriedade.GetValue(TObject(obj)).AsBoolean then
                    strCampos := strCampos + TCampoBooleano(atributos).Nome + '=' + propriedade.GetValue(TObject(obj)).AsString;
               end;
             end;
           end;
         end;
         if atributos is TChavePrimaria then
            strWhere := strWhere + TChavePrimaria(atributos).Nome + '=' + propriedade.GetValue(TObject(obj)).AsString;
       end;
       if achouValorAntigo then
          break;
     end;
     Lib := TLib<T>.Create;
     try
       strUpdate := Lib.LocalizarSubstituir(strUpdate, '[TABELA]', strTabela);
       strUpdate := Lib.LocalizarSubstituir(strUpdate, '[CAMPOS]', strCampos);
       strUpdate := Lib.LocalizarSubstituir(strUpdate, '[CONDICAO]', strWhere);
     finally
       Lib.Free;
     end;

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
  raise Exception.Create('Falta implementar esse m�todo');
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
