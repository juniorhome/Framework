unit orm.seguranca.criptografia;

interface

uses IdHashMessageDigest, System.Classes;

  type
    TCriptografia = class
      private
      public
        class function MD5(const texto: string): string; overload;
        class function MD5(const nomeArquivo: string; numero: integer = 0): string; overload;
    end;

implementation

{ TCriptografia }

class function TCriptografia.MD5(const texto: string): string;
var
  idmd5: TIdHashMessageDigest5;
begin
   idmd5 := TIdHashMessageDigest5.Create;
   try
     Result := idmd5.HashStringAsHex(texto);
   finally
     idmd5.Free;
   end;
end;

class function TCriptografia.MD5(const nomeArquivo: string;
  numero: integer): string;
var
  idmd5: TIdHashMessageDigest5;
  fs: TFileStream;
begin
   idmd5 := TIdHashMessageDigest5.Create;
   fs := TFileStream.Create(nomeArquivo, fmInOut);
   try
     result := idmd5.HashStreamAsHex(fs);
   finally
     idmd5.Free;
     fs.Free;
   end;
end;

end.
