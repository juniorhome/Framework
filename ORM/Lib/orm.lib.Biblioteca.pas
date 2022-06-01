unit orm.lib.Biblioteca;

interface

uses SysUtils, IniFiles, Datasnap.DBClient, ZDataset, Data.DB,
  orm.IBaseVO, System.Rtti, orm.Atributos, Vcl.DBGrids, Winapi.Windows, Vcl.Grids, Vcl.Graphics,
  orm.conexao.interfaces.Interfaces, FireDAC.Comp.Client, System.JSON;

  type
    TLib<T : class, constructor> = class(TObject)
      private
        FArqIni: TIniFile;
      public
         function LocalizarSubstituir(texto,busca,troca: string): string;
         //function VerificaCaminho: boolean;
         procedure EscreverIni(aDriver,aBanco,aHost,aDll,aUsuario,aSenha: string; aPorta:integer);
         function CopiarParaDataSet(aQuery: TZQuery): TClientDataSet;
         function PegarNomeTabela(aObj: T): string;
         procedure GridZebrado(grid: TDBGrid; aRect: TRect; aDataCol: integer; aColumn: TColumn; aState: TGridDrawState);
         procedure OrdenarColunaGrid(aGrid: TDBGrid; aCds: TClientDataSet);
         constructor Create();
         destructor Destroy; override;
         function QueryParaObjeto(aQuery: IModelQuery; aOp: integer): T;
         function QueryParaJson(aQuery: IModelQuery; op: integer): TJSONObject;
         function QueryParaArrayJson(aQuery: IModelQuery; op: integer): TJSONArray;
         //procedure DimensionarGrid(AObj: TObject; AGrid: TDBGrid);
    end;

implementation

var  caminhoIni: string;

{ TLib }

function TLib<T>.CopiarParaDataSet(aQuery: TZQuery): TClientDataSet;
var cds: TClientDataSet;
    field: TField;
begin
//Fun��o que popula um TClientDataSet a partir de um componente tipo Query(TZQuery,TFQuery,TQuery,etc...).
  cds := TClientDataSet.Create(nil);
  try
    aQuery.First;
    cds.Append;
    while not aQuery.Eof do
    begin
      for field in aQuery.Fields do
        cds.Fields[field.Index].Value := field.Value;
      cds.Post;
      aQuery.Next;
    end;
    Result := cds;
  finally
    cds.Free;
  end;
end;

{procedure TLib<T>.DimensionarGrid(AObj: TObject; AGrid: TDBGrid);
type
  TArray = Array of integer;
  procedure AjustarColuna(Swidth, TSize: integer; ASize: TArray);
  var
    idx: integer;
  begin
    if TSize = 0 then
    begin
      TSize := AGrid.Columns.Count;
      for idx := 0 to TSize - 1 do
        AGrid.Columns[idx].Width := (AGrid.Width - AGrid.Canvas.TextWidth('AAAAAA')) div TSize;
    end
    else
    begin
      for idx := 0 to AGrid.Columns.Count - 1 do
        AGrid.Columns[idx].Width := AGrid.Columns[idx].Width + (Swidth * ASize[idx] div TSize);
    end;
  end;
var
   idx, Twidth, TSize, Swidth: integer;
   AWidth: TArray;
   ASize: TArray;
   NomeColuna: string;
begin
   SetLength(AWidth, AGrid.Columns.Count);
   SetLength(ASize, AGrid.Columns.Count);
   Twidth := 0;
   TSize := 0;
   for idx := 0 to AGrid.Columns.Count - 1 do
   begin
     NomeColuna := AGrid.Columns[idx].Title.Caption;
     AGrid.Columns[idx].Width := AGrid.Canvas.TextWidth(AGrid.Columns[idx].Title.Caption + 'A');
     AWidth[idx] := AGrid.Columns[idx].Width;
     Twidth := Twidth + AWidth[idx];

     if Assigned(AGrid.Columns[idx].Field) then
        ASize[idx] := AGrid.Columns[idx].Field.Size
     else
        ASize[idx] := 1;
   end;
   if TDBGridOption.dgColLines in AGrid.Options then
      Twidth := Twidth + AGrid.Columns.Count;

   if TDBGridOption.dgIndicator in AGrid.Options then
      Twidth := Twidth + IndicatorWidth;

   Swidth := AGrid.ClientWidth - Twidth;
   AjustarColuna(Swidth, TSize, ASize);
end;}

constructor TLib<T>.Create;
begin
  //
end;

destructor TLib<T>.Destroy;
begin
  FArqIni.Free;
  inherited;
end;

procedure TLib<T>.EscreverIni(aDriver,aBanco,aHost,aDll,aUsuario,aSenha: string; aPorta:integer);
begin
   //if VerificaCaminho then
  // begin
     FArqIni := TIniFile.Create(ExtractFileDir(GetCurrentDir) + '\config.ini');
     FArqIni.WriteString('Configuracao',aDriver,aDriver);
     FArqIni.WriteString('Configuracao',aBanco,aBanco);
     FArqIni.WriteString('Configuracao',aHost,aHost);
     FArqIni.WriteString('Configuracao',aDll,aDll);
     FArqIni.WriteString('Configuracao',aUsuario,aUsuario);
     FArqIni.WriteString('Configuracao',aSenha,aSenha);
     FArqIni.WriteInteger('Configuracao','',aPorta);
   //end;

end;
{Colocar no evento OnDrawCoumnCell no DBGrid.}
procedure TLib<T>.GridZebrado(grid: TDBGrid; aRect: TRect; aDataCol: integer;
  aColumn: TColumn; aState: TGridDrawState);
var
  nLinha: integer;
begin
  nLinha := grid.DataSource.DataSet.RecNo;

  if odd(nLinha) then
     grid.Canvas.Brush.Color := clMenu
  else grid.Canvas.Brush.Color := clMoneyGreen;

  grid.DefaultDrawColumnCell(aRect, aDataCol, aColumn, aState);
end;

function TLib<T>.LocalizarSubstituir(texto, busca, troca: string): string;
var
  n,i: integer;
begin
   i := length(busca);
   for n := 0 to length(texto) do
   begin
     if Copy(texto, n, i) = busca then
     begin
       Delete(texto, n, i);
       Insert(troca, texto, n);
     end;
   end;
   Result := texto;
end;
{Colocar no evento OnTitleClick do DBGrid.}
procedure TLib<T>.OrdenarColunaGrid(aGrid: TDBGrid; aCds: TClientDataSet);
var sNomeIndice,sNomeColuna: string;
    oOrdenacao: TIndexOptions;
    i: smallint;
begin
   for i := 0 to aGrid.Columns.Count - 1 do
   begin
     aGrid.Columns[i].Title.Font.Style := [];
     if aCds.IndexName = aGrid.Columns[i].FieldName + '_ASC' then
     begin
       sNomeIndice := aGrid.Columns[i].FieldName + '_DESC';
       oOrdenacao := [ixDescending];
     end
     else
     begin
       sNomeIndice := aGrid.Columns[i].FieldName + '_ASC';
       oOrdenacao := [];
     end;
     if aCds.IndexDefs.IndexOf(sNomeIndice) < 0 then
       aCds.AddIndex(sNomeIndice, aGrid.Columns[i].FieldName, oOrdenacao);
     aCds.IndexDefs.Update;
     aGrid.Columns[i].Title.Font.Style := [TFontStyle.fsBold];
     aCds.IndexFieldNames := sNomeIndice;
     aCds.First;
   end;
end;

function TLib<T>.PegarNomeTabela(aObj: T): string;
var contexto: TRttiContext;
    tipo: TRttiType;
    atributo: TCustomAttribute;
begin
   contexto := TRttiContext.Create();
   try
     tipo := contexto.GetType(aObj.ClassInfo);
     for atributo in tipo.GetAttributes  do
     begin
       if atributo is TTabela then
           Result := TTabela(atributo).Nome;
     end;
   finally
     contexto.Free;
   end;
end;

function TLib<T>.QueryParaArrayJson(aQuery: IModelQuery;
  op: integer): TJSONArray;
var
  json: TJSONObject;
  ArrayJson: TJSONArray;
  i: integer;
  campo: TField;
begin
   ArrayJson := TJSONArray.Create;
   try
     case op of
     1:
       begin
         json := TJSONObject.Create;
         (aQuery as TFDQuery).First;
         while not (aQuery as TFDQuery).Eof do
         begin
           for campo in (aQuery as TFDQuery).Fields do
           begin
             case campo.DataType of
               ftString: json.AddPair(campo.FieldName, TJSONString.Create(campo.AsString));
               ftInteger: json.AddPair(campo.FieldName, TJSONNumber.Create(campo.AsInteger));
               ftBoolean: json.AddPair(campo.FieldName, TJSONBool.Create(campo.AsBoolean));
               ftFloat: json.AddPair(campo.FieldName, TJSONNumber.Create(campo.AsFloat));
               ftCurrency: json.AddPair(campo.FieldName, TJSONString.Create(FormatCurr('#,##0.00', campo.AsCurrency)));
               ftDate: json.AddPair(campo.FieldName, TJSONString.Create(FormatDateTime('##/##/####', campo.AsDateTime)));
               ftDateTime: json.AddPair(campo.FieldName, TJSONString.Create(FormatDateTime('##/##/#### HH:mm:ss', campo.AsDateTime)));
               ftExtended: json.AddPair(campo.FieldName, TJSONString.Create(FormatFloat('##,###0.00', campo.AsExtended)));
             end;
           end;
           ArrayJson.Add(json);
           (aQuery as TFDQuery).Next;
         end;
       end;
     2:
       begin
         json := TJSONObject.Create;
         (aQuery as TZQuery).First;
         while not (aQuery as TZQuery).Eof do
         begin
           for campo in (aQuery as TZQuery).Fields do
           begin
             case campo.DataType of
               ftString: json.AddPair(campo.FieldName, TJSONString.Create(campo.AsString));
               ftInteger: json.AddPair(campo.FieldName, TJSONNumber.Create(campo.AsInteger));
               ftBoolean: json.AddPair(campo.FieldName, TJSONBool.Create(campo.AsBoolean));
               ftFloat: json.AddPair(campo.FieldName, TJSONNumber.Create(campo.AsFloat));
               ftCurrency: json.AddPair(campo.FieldName, TJSONString.Create(FormatCurr('##,###0.00', campo.AsCurrency)));
               ftDate: json.AddPair(campo.FieldName, TJSONString.Create(FormatDateTime('##/##/####', campo.AsDateTime)));
               ftDateTime: json.AddPair(campo.FieldName, TJSONString.Create(FormatDateTime('##/##/#### HH:mm:ss', campo.AsDateTime)));
               ftExtended: json.AddPair(campo.FieldName, TJSONString.Create(FormatFloat('###,###0.00', campo.AsExtended)));
             end;
           end;
           ArrayJson.Add(json);
           (aQuery as TZQuery).Next;
         end;
       end;
     end;
     Result := ArrayJson;
   finally
     ArrayJson.Free;
   end;
end;

function TLib<T>.QueryParaJson(aQuery: IModelQuery; op: integer): TJSONObject;
var
  json: TJSONObject;
  ArrayJson: TJSONArray;
  i: integer;
  campo: TField;
begin
  json := TJSONObject.Create;
   try
     case op of
     1://Firedac.
       begin
         (aQuery as TFDQuery).First;
         while not (aQuery as TFDQuery).Eof do
         begin
           for campo in (aQuery as TFDQuery).Fields do
           begin
             case campo.DataType of
             ftString: json.AddPair(campo.FieldName, TJSONString.Create(campo.AsString));
             ftInteger: json.AddPair(campo.FieldName, TJSONNumber.Create(campo.AsInteger));
             ftCurrency: json.AddPair(campo.FieldName, TJSONString.Create(FormatCurr('##.###0.00', campo.AsCurrency)));
             ftDate: json.AddPair(campo.FieldName, TJSONString.Create(FormatDateTime('##/##/####', campo.AsDateTime)));
             ftDateTime: json.AddPair(campo.FieldName, TJSONString.Create(FormatDateTime('##/##/#### HH:mm:ss', campo.AsDateTime)));
             ftExtended: json.AddPair(campo.FieldName, TJSONString.Create(FormatFloat('###.###0.000', campo.AsExtended)));
             ftBoolean: json.AddPair(campo.FieldName, TJSONBool.Create(campo.AsBoolean));
             end;
           end;
           (aQuery as TFDQuery).Next;
         end;
       end;
     2:
       begin
         (aQuery as TZQuery).First;
         while not (aQuery as TZQuery).Eof do
         begin
           for campo in (aQuery as TZQuery).Fields do
           begin
             case campo.DataType of
             ftString: json.AddPair(campo.FieldName, TJSONString.Create(campo.AsString));
             ftInteger: json.AddPair(campo.FieldName, TJSONNumber.Create(campo.AsInteger));
             ftCurrency: json.AddPair(campo.FieldName, TJSONString.Create(FormatCurr('##.###0.00', campo.AsCurrency)));
             ftDate: json.AddPair(campo.FieldName, TJSONString.Create(FormatDateTime('##/##/####', campo.AsDateTime)));
             ftDateTime: json.AddPair(campo.FieldName, TJSONString.Create(FormatDateTime('##/##/#### HH:mm:ss', campo.AsDateTime)));
             ftExtended: json.AddPair(campo.FieldName, TJSONString.Create(FormatFloat('###.###0.000', campo.AsExtended)));
             ftBoolean: json.AddPair(campo.FieldName, TJSONBool.Create(campo.AsBoolean));
             end;
           end;
           (aQuery as TZQuery).Next;
         end;
       end;
     end;
     Result := json;
   finally
     json.Free;
   end;
end;

function TLib<T>.QueryParaObjeto(aQuery: IModelQuery; aOp: integer): T;
var contexto: TRttiContext;
    tipo: TRttiType;
    propriedade: TRttiProperty;
    atributo: TCustomAttribute;
    valor: TValue;
    i: integer;
    NomeColuna: string;
    Obj: T;
begin
  Obj := T.Create;
  contexto := TRttiContext.Create;
  try
    tipo := contexto.GetType(TObject(Obj).ClassInfo);

    case aOp of
      1://firedac
        begin
          for i := 0 to (aQuery as TFDQuery).FieldDefs.Count - 1 do
          begin
           NomeColuna := (aQuery as TFDQuery).FieldDefs[i].Name;
           case (aQuery as TFDQuery).FieldDefs[i].DataType of
             ftString, ftWideString:   valor := (aQuery as TFDQuery).FieldByName(NomeColuna).AsString;
             ftInteger, ftSmallint, ftLargeint: valor := (aQuery as TFDQuery).FieldByName(NomeColuna).AsInteger;
             ftBoolean: valor := (aQuery as TFDQuery).FieldByName(NomeColuna).AsBoolean;
             ftFloat: valor := (aQuery as TFDQuery).FieldByName(NomeColuna).AsFloat;
             ftCurrency:  valor :=  (aQuery as TFDQuery).FieldByName(NomeColuna).AsCurrency;
             ftExtended: valor := (aQuery as TFDQuery).FieldByName(NomeColuna).AsExtended;
             ftDate, ftDateTime: valor := (aQuery as TFDQuery).FieldByName(NomeColuna).AsDateTime;
           end;
           for propriedade in tipo.GetProperties do
             for atributo in propriedade.GetAttributes do
             begin
               if atributo is TChavePrimaria then
               begin
                 if TChavePrimaria(atributo).Nome = NomeColuna then
                 begin
                   if not valor.IsEmpty then
                     propriedade.SetValue(TObject(Obj), valor);
                 end;
               end;
               if atributo is TCampoTexto then
               begin
                 if TCampoTexto(atributo).Nome = NomeColuna then
                 begin
                   if not valor.IsEmpty then
                      propriedade.SetValue(TObject(Obj), valor);
                 end;
               end;
               if atributo is TCampoInteiro then
               begin
                 if TCampoInteiro(atributo).Nome = NomeColuna then
                 begin
                   if not valor.IsEmpty then
                     propriedade.SetValue(TObject(Obj), valor);
                 end;
               end;
               if (atributo is TCampoData) then
               begin
                 if TCampoData(atributo).Nome = NomeColuna then
                 begin
                   if not valor.IsEmpty then
                      propriedade.SetValue(TObject(Obj), valor);
                 end;
               end;
             end;
             if atributo is TCampoDataHora then
             begin
               if TCampoDataHora(atributo).Nome = NomeColuna then
               begin
                 if not valor.IsEmpty then
                    propriedade.SetValue(TObject(Obj), valor);
               end;
             end;
             if atributo is TCampoExtended then
             begin
               if TCampoExtended(atributo).Nome = NomeColuna then
               begin
                 if not valor.IsEmpty then
                    propriedade.SetValue(TObject(Obj), valor);
               end;
             end;
             if atributo is TCampoMonetario then
             begin
               if TCampoMonetario(atributo).Nome = NomeColuna then
               begin
                 if not valor.IsEmpty then
                    propriedade.SetValue(TObject(Obj), valor);
               end;
             end;
             if atributo is TCampoBooleano then
             begin
               if TCampoBooleano(atributo).Nome = NomeColuna then
               begin
                 if not valor.IsEmpty then
                   propriedade.SetValue(TObject(Obj), valor);
               end;
             end;
          end;
        end;
      2: //zeos
         begin
           for i := 0 to (aQuery as TZQuery).FieldDefs.Count - 1 do
           begin
             NomeColuna := (aQuery as TZQuery).FieldDefs[i].Name;
             case (aQuery as TZQuery).FieldDefs[i].DataType of
               ftString, ftWideString: valor := (aQuery as TZQuery).FieldByName(NomeColuna).AsString;
               ftInteger, ftLargeint, ftSmallint: valor := (aQuery as TZQuery).FieldByName(NomeColuna).AsInteger;
               ftBoolean: valor := (aQuery as TZQuery).FieldByName(NomeColuna).AsBoolean;
               ftFloat: valor := (aQuery as TZQuery).FieldByName(NomeColuna).AsFloat;
               ftCurrency: valor := (aQuery as TZQuery).FieldByName(NomeColuna).AsCurrency;
               ftExtended: valor := (aQuery as TZQuery).FieldByName(NomeColuna).AsExtended;
               ftDate, ftDateTime: valor := (aQuery as TZQuery).FieldByName(NomeColuna).AsDateTime;
             end;

             for propriedade in tipo.GetProperties do
               for atributo in propriedade.GetAttributes do
               begin
                 if atributo is TChavePrimaria then
                 begin
                   if TChavePrimaria(atributo).Nome = NomeColuna then
                   begin
                     if not valor.IsEmpty then
                       propriedade.SetValue(TObject(Obj), valor);
                   end;
                 end;
                 if atributo is TCampoTexto then
                 begin
                   if TCampoTexto(atributo).Nome = NomeColuna then
                   begin
                     if not valor.IsEmpty then
                       propriedade.SetValue(TObject(Obj), valor);
                   end;
                 end;
                 if atributo is TCampoInteiro then
                 begin
                   if TCampoInteiro(atributo).Nome = NomeColuna then
                   begin
                     if not valor.IsEmpty then
                       propriedade.SetValue(TObject(Obj), valor);
                   end;
                 end;
                 if atributo is TCampoData then
                 begin
                   if TCampoData(atributo).Nome = NomeColuna then
                   begin
                     if not valor.IsEmpty then
                       propriedade.SetValue(TObject(Obj), valor);
                   end;
                 end;
                 if atributo is TCampoDataHora then
                 begin
                   if TCampoDataHora(atributo).Nome = NomeColuna then
                   begin
                     if not valor.IsEmpty then
                       propriedade.SetValue(TObject(Obj), valor);
                   end;
                 end;
                 if atributo is TCampoExtended then
                 begin
                   if TCampoExtended(atributo).Nome = NomeColuna then
                   begin
                     if not valor.IsEmpty then
                       propriedade.SetValue(TObject(Obj), valor);
                   end;
                 end;
                 if atributo is TCampoMonetario then
                 begin
                   if TCampoMonetario(atributo).Nome = NomeColuna then
                   begin
                     if not valor.IsEmpty then
                       propriedade.SetValue(TObject(Obj), valor);
                   end;
                 end;
                 if atributo is TCampoBooleano then
                 begin
                   if TCampoBooleano(atributo).Nome = NomeColuna then
                   begin
                     if not valor.IsEmpty then
                       propriedade.SetValue(TObject(Obj), valor);
                   end;
                 end;
               end;
           end;
         end;
    end;
    Result := Obj;
  finally
    contexto.Free;
  end;
end;

{function TLib<T>.VerificaCaminho: boolean;
begin
   caminhoIni := ExtractFilePath(Application.ExeName) + '\config.ini';
   if FileExists(caminhoIni) then
      Result := True
   else Result := False;
end;}

end.
