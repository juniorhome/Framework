unit orm.lib.Biblioteca;

interface

uses SysUtils, IniFiles, Datasnap.DBClient, ZDataset, Data.DB,
  orm.IBaseVO, System.Rtti, orm.Atributos, Vcl.DBGrids;

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
         procedure DimensionarGrid(AObj: TObject; AGrid: TDBGrid);
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

procedure TLib<T>.DimensionarGrid(AObj: TObject; AGrid: TDBGrid);
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

{function TLib<T>.VerificaCaminho: boolean;
begin
   caminhoIni := ExtractFilePath(Application.ExeName) + '\config.ini';
   if FileExists(caminhoIni) then
      Result := True
   else Result := False;
end;}

end.