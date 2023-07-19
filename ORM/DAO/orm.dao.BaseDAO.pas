unit orm.dao.BaseDAO;

interface

uses Db,Rtti,orm.conexao.ModelConexaoFactory,orm.IBaseVO,orm.Atributos,
     orm.Lib.Biblioteca, orm.conexao.interfaces.Interfaces, ZDataset,
  uRESTDWBasicDB, orm.conexao.model_rdw.ModelRDWQuery, System.SysUtils, System.JSON,
  Generics.Collections, System.Contnrs, uRESTDWIdBase, Datasnap.DBClient,
  System.Classes;
  type
    TBaseDAO<T : class, constructor> = class(TInterfacedObject, IDAO<T>)
      private
        FQuery: IModelQuery;
        FDataSource: TDataSource;
        function FormatarString(aCampos: string): string;
      public
        constructor Create(aQuery: IModelQuery);
        class function New(aQuery: IModelQuery): IDAO<T>;
        function Inserir(obj: T): IDAO<T>;
        function Atualizar(obj: T): IDAO<T>;overload;
        function Atualizar(obj, objOld: T): IDAO<T>;overload;
        function Excluir(obj: T): IDAO<T>;
        function Listagem(obj: T; dataInicio,dataFim: string; TemData: boolean; const TipoJuncao:TTipoJoin = ttLeftJoin): IDAO<T>;overload;
        function Listagem(obj: T; dataInicio,dataFim: string; const TipoJuncao: TTipoJoin = ttLeftJoin; EhFiltro: boolean = False; ConsultaCompleta: boolean = False): IDAO<T>;overload;
        function Listagem(obj: T; dataInicio,dataFim: string; const TipoJuncao: TTipoJoin = ttLeftJoin): IDAO<T>;overload;
        function Listagem(obj: T; const TipoJuncao: TTipoJoin = ttLeftJoin): IDAO<T>; overload;
        function Listagem(obj: T;dataInicio,dataFim: string; const TipoJuncao:TTipoJoin = ttLeftJoin; ConsultaCompleta: boolean = True): IDAO<T>; overload;
        function DataSource(aDataSource: TDataSource): IDAO<T>;
        function ConsultaSql(sql: string): TDataSet;overload;
        procedure OnDataChange(Sender: TObject; Field: TField);
        {Fazer mais um m�todo de atualiza��o e mais listagem com v�rios retornos DataSet, IBaseVO, Listagem e Json}
    end;

implementation

{ TBaseDAO }

function TBaseDAO<T>.Atualizar(obj: T): IDAO<T>;
var
  contexto: TRttiContext;
  tipo: TRttiType;
  propriedade: TRttiProperty;
  atributos: TCustomAttribute;
  strUpdate,strCampos,strWhere, strTabela: string;
  Lib: TLib<T>;
begin
  Result := Self;
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

       //Formatar a string que cont�m os campos e valores.
       strCampos := FormatarString(strCampos);

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
       FQuery.ExecSql(strUpdate);
  finally
    contexto.Free;
  end;
end;

function TBaseDAO<T>.Atualizar(obj, objOld: T): IDAO<T>;
var contexto: TRttiContext;
    tipo, tipoOld: TRttiType;
    propriedade, propriedadeOld: TRttiProperty;
    atributos, atributoOld: TCustomAttribute;
    strUpdate, strTabela, strWhere, strCampos, nomeTipo: string;
    Lib: TLib<T>;
    valorNovo,valorAntigo: variant;
    achouValorAntigo: boolean;
begin
   Result := Self;
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
     //Formatar a string que cont�m os campos e valores.
     strCampos := FormatarString(strCampos);

     Lib := TLib<T>.Create;
     try
       strUpdate := Lib.LocalizarSubstituir(strUpdate, '[TABELA]', strTabela);
       strUpdate := Lib.LocalizarSubstituir(strUpdate, '[CAMPOS]', strCampos);
       strUpdate := Lib.LocalizarSubstituir(strUpdate, '[CONDICAO]', strWhere);
     finally
       Lib.Free;
     end;

     FQuery.ExecSql(strUpdate);
   finally
     contexto.Free;
   end;
end;

function TBaseDAO<T>.ConsultaSql(sql: string): TDataSet;
begin
  raise Exception.Create('Falta implementar esse m�todo');
end;

constructor TBaseDAO<T>.Create(aQuery: IModelQuery);
begin
   FQuery := aQuery;
end;

function TBaseDAO<T>.DataSource(aDataSource: TDataSource): IDAO<T>;
begin
  Result := Self;
  FDataSource := aDataSource;
  FDataSource.DataSet := FQuery.DataSet;
  FDataSource.OnDataChange := OnDataChange;
end;

function TBaseDAO<T>.Excluir(obj: T): IDAO<T>;
var
  contexto: TRttiContext;
  tipo: TRttiType;
  propriedade: TRttiProperty;
  atributo: TCustomAttribute;
  strDelete,strTabela,strCondicao, strWhere: string;
  Lib: TLib<T>;
begin
   Result := Self;
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
       FQuery.ExecSql(strDelete);
   finally
     contexto.Free;
   end;
end;

function TBaseDAO<T>.FormatarString(aCampos: string): string;
var sCampos: TSTringList;
    i, iRetorno: integer;
    sRetorno: string;
begin
   sCampos := TStringList.Create;
   try
     iRetorno := ExtractStrings([','], [], PWideChar(aCampos), sCampos);
     if iRetorno > 0 then
     begin
       for i := 0 to sCampos.Count - 1 do
       begin
         if not sRetorno.IsEmpty then
            sRetorno := sRetorno + ',';
         sRetorno := sRetorno + sCampos[i];
       end;
     end;
     Result := sRetorno;
   finally
     sCampos.Free;
   end;
end;

function TBaseDAO<T>.Inserir(obj: T): IDAO<T>;
var
  contexto: TRttiContext;
  tipo: TRttiType;
  propriedade: TRttiProperty;
  atributos: TCustomAttribute;
  strInsert, strCampos,strValores,strTabela: string;
  Lib: TLib<T>;
begin
   Result := Self;
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

        //Formatar string que cont�m os campos que ir�o ser inseridos.
        strCampos := FormatarString(strCampos);
        strValores := FormatarString(strValores);

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
        FQuery.ExecSql(strInsert);
   finally
     contexto.Free;
   end;
end;

function TBaseDAO<T>.Listagem(obj: T; dataInicio, dataFim: string;
  const TipoJuncao: TTipoJoin): IDAO<T>;
var
  contexto: TRttiContext;
  tipo: TRttiType;
  prop: TRttiProperty;
  atributo: TCustomAttribute;
  json: TJSONObject;
  Lib: TLib<T>;
  strSelect, strCampos, strTabela, strJuncao, strWhere, alias, aliasEstrangeiro: string;
begin
   Result := Self;
   strSelect := 'SELECT [CAMPOS] FFOM [TABELA] [JUNCAO] WHERE [CONDICAO]';
   strCampos := '';
   strTabela := '';
   strJuncao := '';
   strWhere := '';
   json := TJSONObject.Create;
   contexto := TRttiContext.Create;
   try
      tipo := contexto.GetType(TObject(obj).ClassInfo);
      for atributo in tipo.GetAttributes do
      begin
         if atributo is TTabela then
         begin
           alias := TTabela(atributo).Alias;
           strTabela := strTabela + TTabela(atributo).Nome + ' ' + TTabela(atributo).Alias;
         end;

         if atributo is TTabelaEstrangeira then
         begin
           aliasEstrangeiro := TTabelaEstrangeira(atributo).Alias;
           if not strJuncao.IsEmpty then
             strJuncao := strJuncao + '  ';
           case TipoJuncao of
             ttInnerJoin: strJuncao := strJuncao + ' INNER JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias + ' ON ' +
                                                   aliasEstrangeiro + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).Id ;
             ttLeftJoin: strJuncao := strJuncao + ' LEFT JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias + ' ON ' +
                                                  aliasEstrangeiro + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).Id;
             ttRigthJoin: strJuncao := strJuncao + ' RIGTH JOIN  ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias + ' ON ' +
                                                   aliasEstrangeiro + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).Id;
           end;
         end;
      end;
      for prop in tipo.GetProperties do
        for atributo in prop.GetAttributes do
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
             strCampos := strCampos + TCampoEstrangeiro(atributo).Alias + '.' + TCampoEstrangeiro(atributo).Nome;
          if atributo is TChaveEstrangeira then
             strCampos := strCampos + alias + '.' + TChaveEstrangeira(atributo).Nome;
          if atributo is TCampoFiltro then
          begin
            if prop.PropertyType.TypeKind = tkInteger then
            begin
              if prop.GetValue(TObject(obj)).AsInteger > 0 then
                strWhere := strWhere + alias + '.' + TCampoFiltro(atributo).Nome + ' = ' + IntToStr(prop.GetValue(TObject(obj)).AsInteger);
            end;
          end;
          if (prop.PropertyType.TypeKind = tkString) then
          begin
             if (not prop.GetValue(TObject(obj)).AsString.IsEmpty)  then
                strWhere := strWhere + alias + '.' + TCampoFiltro(atributo).Nome + ' LIKE ' + QuotedStr('%' + prop.GetValue(TObject(obj)).AsString + '%');
          end;
          if (prop.PropertyType.TypeKind = tkChar) then
          begin
            if (prop.GetValue(TObject(obj)).AsString.Length = 2) then
                strWhere := strWhere + alias + '.' + TCampoFiltro(atributo).Nome + ' = ' + QuotedStr(prop.GetValue(TObject(obj)).AsString);
          end;
          if prop.PropertyType.TypeKind = tkFloat then
          begin
            if CompareText(prop.PropertyType.Name, 'TDate') = 0 then
            begin
               if not(dataInicio.IsEmpty) and not(dataFim.IsEmpty) then
                 strWhere := strWhere + ' BETWEEN ' + dataInicio + ' AND ' + dataFim ;
            end;
          end;
          if atributo is TSomatorio then
             strCampos := strCampos + ' SUM(' + alias + '.' + TSomatorio(atributo).Nome + ')';
          if atributo is TMedia then
             strCampos := strCampos + ' AVG(' + alias + '.' + TMedia(atributo).Nome + ')';
          if atributo is TMinimo then
             strCampos := strCampos + ' MIN(' + alias + '.' + TMinimo(atributo).Nome + ')';
          if atributo is TMaximo then
             strCampos := strCampos + ' MAX(' + alias + '.' + TMaximo(atributo).Nome + ')';
        end;
        //Formatar string que cont�m os campos.
        strCampos := FormatarString(strCampos);

        Lib := TLib<T>.Create;
        try
          strSelect := Lib.LocalizarSubstituir(strSelect, '[TABELA]', strTabela);
          strSelect := Lib.LocalizarSubstituir(strSelect, '[CAMPOS]', strCampos);
          strSelect := Lib.LocalizarSubstituir(strSelect, '[JUNCAO]', strJuncao);
          if strWhere.IsEmpty then
            Delete(strSelect, Pos('WHERE', strSelect), 1)
          else strSelect := Lib.LocalizarSubstituir(strSelect, '[CONDICAO]', strWhere);

          FQuery.ExecSql(strSelect);
          json := Lib.QueryParaJson(FQuery, tqRDW);
        finally
          Lib.Free;
        end;
   finally
     contexto.Free;
     json.Free;
   end;
end;

function TBaseDAO<T>.Listagem(obj: T; dataInicio,dataFim: string; const TipoJuncao: TTipoJoin; EhFiltro,
  ConsultaCompleta: boolean): IDAO<T>;
var
   contexto: TRttiContext;
   tipo: TRttiType;
   propriedade: TRttiProperty;
   atributo: TCustomAttribute;
   strSelect,strTabela,strCampos,strwhere, strJuncao, alias, aliasEStrangeiro: string;
   Lib: TLib<T>;
begin
   Result := Self;
   strSelect := 'SELECT TOP 100 [CAMPOS] FROM [TABELA] [JUNCAO] WHERE [CONDICAO]';
   strTabela := '';
   strCampos := '';
   strJuncao := '';
   strwhere := '';
   contexto := TRttiContext.Create;
   try
     tipo := contexto.GetType(TObject(obj).ClassInfo);
     for atributo in tipo.GetAttributes do
     begin
       if atributo is TTabela then
       begin
          alias := TTabela(atributo).Alias;
          strTabela := strTabela + TTabela(atributo).Nome + '' + TTabela(atributo).Alias;
       end;
       if not strJuncao.IsEmpty then
          strJuncao := strJuncao + '#10#13';

       if atributo is TTabelaEstrangeira then
       begin
        aliasEstrangeiro := TTabelaEstrangeira(atributo).Alias;
         case TipoJuncao of
           ttInnerJoin: strJuncao := strJuncao + ' INNER JOIN ' + TTabelaEstrangeira(atributo).Nome + '' + TTabelaEstrangeira(atributo).Alias +
                                                 ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + '=' + TTabelaEstrangeira(atributo).Id;
           ttLeftJoin: strJuncao := strJuncao + ' LEFT JOIN ' + TTabelaEstrangeira(atributo).Nome + '' + TTabelaEstrangeira(atributo).Alias +
                                                  ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + '=' + TTabelaEstrangeira(atributo).Id;
           ttRigthJoin: strJuncao := strJuncao + ' RIGTH JOIN ' + TTabelaEstrangeira(atributo).Nome + '' + TTabelaEstrangeira(atributo).Alias +
                                                  ' ON ' + TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + '=' + TTabelaEstrangeira(atributo).Id ;
         end;
       end;
     end;

     for propriedade in tipo.GetProperties do
       for atributo in propriedade.GetAttributes do
       begin
         if not strCampos.IsEmpty then
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
         if atributo is TCampoEstrangeiro then
            strCampos := strCampos + aliasEStrangeiro + '.' + TCampoEstrangeiro(atributo).Nome;
         if atributo is TSomatorio then
            strCampos := strCampos + ' SUM(' + alias + '.' + TSomatorio(atributo).Nome + ')';
         if atributo is TMedia then
           strCampos := strCampos + ' AVG(' + alias + '.' + TMedia(atributo).Nome + ')';
         if atributo is TMaximo then
           strCampos := strCampos + ' MAX(' + alias + '.' + TMaximo(atributo).Nome + ')';
         if atributo is TMinimo then
           strCampos := strCampos + ' MIN(' + alias + '.' + TMinimo(atributo).Nome + ')';

         if not strWhere.IsEmpty then
            strWhere := strWhere + ' AND ';
         if atributo is TCampoFiltro then
         begin
           if propriedade.PropertyType.TypeKind = tkInteger then
             strWhere := strWhere + alias + '.' + TCampoFiltro(atributo).Nome + ' = ' + IntToStr(propriedade.GetValue(TObject(obj)).AsInteger);
           if propriedade.PropertyType.TypeKind = tkString then
             strWhere := strWhere + alias + '.' + TCampoFiltro(atributo).Nome + ' LIKE ' + QuotedStr('%' + propriedade.GetValue(TObject(obj)).AsString + '%');
           if propriedade.PropertyType.TypeKind = tkFloat then
           begin
             if CompareText(propriedade.PropertyType.Name, 'TDateTime') > 0 then
             begin
               if not(dataInicio.IsEmpty) and not(dataFim.IsEmpty) then
                 strWhere := strWhere + ' BETWEEN ' + dataInicio + ' AND ' + dataFim;
             end;
           end;
         end;
       end;
       //Formatar a string que cont�m os campos.
       strCampos := FormatarString(strCampos);

       Lib := TLib<T>.Create;
       try
         strSelect := Lib.LocalizarSubstituir(strSelect, '[TABELA]', strTabela);
         strSelect := Lib.LocalizarSubstituir(strSelect, '[CAMPOS]', strCampos);
         if not strJuncao.IsEmpty then
             strSelect := Lib.LocalizarSubstituir(strSelect, '[JUNCAO]', strJuncao)
         else  strSelect := Lib.LocalizarSubstituir(strSelect, '[JUNCAO]', '');
         if strWhere.IsEmpty then
           Delete(strSelect, Pos('WHERE', strSelect), 1)
         else strSelect := Lib.LocalizarSubstituir(strSelect, '[CONDICAO]', strwhere);

         FQuery.ExecSql(strSelect);
         Lib.QueryParaArrayJson(FQuery, tqRDW);
       finally
         Lib.Free;
       end;
   finally
     contexto.Free;
   end;
end;

function TBaseDAO<T>.Listagem(obj: T; dataInicio,dataFim: string; TemData: boolean; const TipoJuncao:TTipoJoin = ttLeftJoin): IDAO<T>;
var
   contexto: TRttiContext;
   tipo: TRttiType;
   propriedade: TRttiProperty;
   atributo: TCustomAttribute;
   strSelect,strTabela,strCampos,strWhere,strJuncao,tabela,alias,aliasEstrangeiro: string;
   Lib: TLib<T>;
   cds: TClientDataSet;
begin
   strSelect := 'SELECT TOP 100 [CAMPOS] FROM [TABELA] [JUNCAO] WHERE [CONDICAO]';
   strTabela := '';
   strCampos := '';
   strWhere := '';
   strJuncao := '';
   cds := TClientDataSet.Create(nil);
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
              strCampos := strCampos + TCampoEstrangeiro(atributo).Alias + '.' + TCampoEstrangeiro(atributo).Nome;

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

           if not strWhere.IsEmpty then
              strWhere := strWhere + ' AND ';

           if atributo is TCampoFiltro then
           begin
              if propriedade.PropertyType.TypeKind = tkInteger then
              begin
                 if propriedade.GetValue(TObject(obj)).AsInteger > 0 then
                    strWhere := strWhere + alias + '.' + TCampoFiltro(atributo).Nome + ' = ' + IntToStr(propriedade.GetValue(TObject(obj)).AsInteger);
              end;
              if propriedade.PropertyType.TypeKind = tkChar then
              begin
                if not propriedade.GetValue(TObject(obj)).AsString.IsEmpty then
                   strWhere := strWhere + alias + '.' + TCampoFiltro(atributo).Nome + ' = ' + QuotedStr(propriedade.GetValue(TObject(obj)).AsString);
              end;
              if propriedade.PropertyType.TypeKind = tkString then
              begin
                if not propriedade.GetValue(TObject(obj)).AsString.IsEmpty then
                   strWhere := strWhere + alias + '.' + TCampoFiltro(atributo).Nome + ' LIKE ' + QuotedStr('%'+propriedade.GetValue(TObject(obj)).AsString+'%');
              end;
              if propriedade.PropertyType.TypeKind = tkFloat then
              begin
                if CompareText(propriedade.PropertyType.Name, 'TDateTime') = 0 then
                begin
                  if (TemData) and not(dataInicio.IsEmpty) and not(dataFim.IsEmpty) then
                     strWhere := strWhere + ' BETWEEN ' + dataInicio + ' AND ' + dataFim;
                end;

              end;
           end;
         end;
     //Formatar a string que cont�m os campos.
     strCampos := FormatarString(strCampos);

     //Montar a query.
     Lib := TLib<T>.Create;
     try
        strSelect := Lib.LocalizarSubstituir(strSelect, '[TABELA]', strTabela);
        strSelect := Lib.LocalizarSubstituir(strSelect, '[JUNCAO]', strJuncao);
        if strWhere.IsEmpty then
          Delete(strSelect, Pos('WHERE', strSelect), Length(strSelect))
        else strSelect := Lib.LocalizarSubstituir(strSelect, '[CONDICAO]', strWhere);
        strSelect := Lib.LocalizarSubstituir(strSelect, '[CAMPOS]', strCampos);


       //Executar a query.
       {Modelo Cliente e Servidor.
       FQuery := TModelConexaoFactory.New.Query(2).ExecSql(strSelect);
       if (FQuery as TZQuery).RecordCount > 0 then
         Result := Lib.CopiarParaDataSet((FQuery as TZQuery));}

       //Rest Dataware n camadas.
       Lib.CriarCds(obj, cds);//prepara o clientdataset para carregar os dados vindos do banco.
       cds.Active := True;
       cds.Open;
       FQuery.ExecSql(strSelect);
       Lib.CopiarParaDataSet(FQuery, TTipoQuery.tqRDW, cds);
     finally
       Lib.Free;
     end;
   finally
     contexto.Free;
     cds.Free;
   end;
end;

class function TBaseDAO<T>.New(aQuery: IModelQuery): IDAO<T>;
begin
   Result := Self.Create(aQuery);
end;

procedure TBaseDAO<T>.OnDataChange(Sender: TObject; Field: TField);
var
  contexto: TRttiContext;
  tipo: TRttiType;
  campo: TRttiField;
  atributo: TCustomAttribute;
begin
   //Fazer o bind com o objeto.
   contexto := TRttiContext.Create;
   try
     tipo := contexto.GetType();
   finally
     contexto.Free;
   end;
end;

function TBaseDAO<T>.Listagem(obj: T; const TipoJuncao: TTipoJoin): IDAO<T>;
var
   contexto:               TRttiContext;
   prop:                   TRttiProperty;
   tipo:                   TRttiType;
   atributo:               TCustomAttribute;
   strSelect,
   strCampos,
   strTabela,
   strJuncao,
   strCondicao, alias:     string;
   Lib:                    TLib<T>;
begin
   Result := Self;
   strSelect :=    'SELECT [CAMPOS] FROM [TABELA] [JUNCAO] WHERE [CONDICAO]';
   strCampos :=    '';
   strTabela :=    '';
   strJuncao :=    '';
   strCondicao :=  '';
   contexto := TRttiContext.Create;
   try
     tipo := contexto.GetType(TObject(obj).ClassInfo);
     for atributo in tipo.GetAttributes do
     begin
       if atributo is TTabela then
       begin
         alias := TTabela(atributo).Alias;
         strTabela := strTabela + TTabela(atributo).Nome + ' ' + TTabela(atributo).Alias;
       end;

       if not strJuncao.IsEmpty then
          strJuncao := strJuncao + '  ';
       if atributo is TTabelaEstrangeira then
       begin
         case TipoJuncao of
           ttInnerJoin: strJuncao := strJuncao + ' INNER JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias + ' ON ' +
                                                 TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro;
           ttLeftJoin: strJuncao := strJuncao + ' LEFT JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias + ' ON ' +
                                                TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).Id;

           ttRigthJoin: strJuncao := strJuncao + ' RIGTH JOIN ' + TTabelaEstrangeira(atributo).Nome + ' ' + TTabelaEstrangeira(atributo).Alias + ' ON ' +
                                                  TTabelaEstrangeira(atributo).Alias + '.' + TTabelaEstrangeira(atributo).IdEstrangeiro + ' = ' + alias + '.' + TTabelaEstrangeira(atributo).Id;
         end;
       end;
     end;

     for prop in tipo.GetProperties do
       for atributo in prop.GetAttributes do
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
           strCampos := strCampos + TCampoEstrangeiro(atributo).Alias + '.' + TCampoEstrangeiro(atributo).Nome;
         if atributo is TCampoFiltro then
         begin
           if not strCondicao.IsEmpty then
              strCondicao := strCondicao + ' AND ';
           if prop.PropertyType.TypeKind = tkInteger then
           begin
             if prop.GetValue(TObject(obj)).AsInteger > 0 then
               strCondicao := strCondicao + alias + '.' + TCampoFiltro(atributo).Nome + ' = ' + IntToStr(prop.GetValue(TObject(obj)).AsInteger);
           end;
           if prop.PropertyType.TypeKind = tkChar then
           begin
             if not prop.GetValue(TObject(obj)).AsString.IsEmpty then
               strCondicao := strCondicao + alias + '.' + TCampoFiltro(atributo).Nome + ' = ' + QuotedStr(prop.GetValue(TObject(obj)).AsString);
           end;
           if prop.PropertyType.TypeKind = tkString then
           begin
             if not prop.GetValue(TObject(obj)).AsString.IsEmpty then
               strCondicao := strCondicao + alias + '.' + TCampoFiltro(atributo).Nome + ' LIKE ' + QuotedStr('%'+prop.GetValue(TObject(obj)).AsString+'%');
           end;
         end;
         if atributo is TSomatorio then
           strCampos := strCampos + ' SUM( ' + alias + '.' + TSomatorio(atributo).Nome + ') AS SOMA';
         if atributo is TMedia then
           strCampos := strCampos + ' AVG( ' + alias + '.' + TMedia(atributo).Nome + ') AS MEDIA';
         if atributo is TMinimo then
           strCampos := strCampos + ' MIN( ' + alias + '.' + TMinimo(atributo).Nome + ') AS MENOR';
         if atributo is TMaximo then
            strCampos := strCampos + ' MAX( ' + alias + '.' + TMaximo(atributo).Nome + ') AS MAIOR';
       end;
       //Formatar a string que cont�m os campos.
       strCampos := FormatarString(strCampos);

       Lib := TLib<T>.Create;
       try
         strSelect := Lib.LocalizarSubstituir(strSelect, '[CAMPOS]', strCampos);
         strSelect := Lib.LocalizarSubstituir(strSelect, '[TABELA]', strTabela);
         strSelect := Lib.LocalizarSubstituir(strSelect, '[JUNCAO]', strJuncao);
         if strCondicao.IsEmpty then
            Delete(strSelect, Pos('WHERE', strSelect), 1)
         else strSelect := Lib.LocalizarSubstituir(strSelect, '[CONDICAO]', strCondicao);

         FQuery.ExecSql(strSelect);
         Lib.QueryParaObjeto(FQuery, tqRDW);
       finally
         Lib.Free;
       end;
   finally
     contexto.Free;
   end;
end;

function TBaseDAO<T>.Listagem(obj: T; dataInicio, dataFim: string;
  const TipoJuncao: TTipoJoin; ConsultaCompleta: boolean): IDAO<T>;
begin
  ///Implementar depois.
end;

end.
