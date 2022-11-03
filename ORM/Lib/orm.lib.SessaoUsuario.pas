unit orm.lib.SessaoUsuario;

interface

uses IniFiles, System.SysUtils;

type
  TSessaoUsuario = class
    private
      class var FId: integer;
      class var FApelido: string;
      class var FLembrar: boolean;
      class var FCaminhoFoto: string;
    public
      class property Id: integer read FId write FId;
      class property Apelido: string read FApelido write FApelido;
      class property Lembrar: boolean read FLembrar write FLembrar;
      class property CaminhoFoto: string read FCaminhoFoto write FCaminhoFoto;
      class procedure EscreverIni(aId: integer;aApelido,aCaminhoFoto: string;aLembrar: boolean);
      class procedure LerIni;
  end;

implementation

{ TSessaoUsuario }

class procedure TSessaoUsuario.EscreverIni(aId: integer;aApelido,aCaminhoFoto: string;aLembrar: boolean);
var arqIni: TIniFile;
begin
   arqIni := TIniFile.Create(ExtractFileDir(GetCurrentDir)+'\usuario.ini');
   try
     arqIni.WriteInteger('AUTENTICA플O', 'ID', aId);
     arqIni.WriteString('AUTENTICA플O', 'APELIDO', aApelido);
     arqIni.WriteString('AUTENTICA플O', 'FOTO', aCaminhoFoto);
     arqIni.WriteBool('AUTENTICA플O', 'LEMBRAR', aLembrar);
   finally
     arqIni.Free;
   end;
end;

class procedure TSessaoUsuario.LerIni;
var arqIni: TIniFile;
begin
   arqIni := TIniFile.Create(ExtractFilePath(GetCurrentDir)+'\usuario.ini');
   try
     Self.Id := arqIni.ReadInteger('AUTENTICA플O','ID',Self.Id);
     Self.Apelido := arqIni.ReadString('AUTENTICA플O','APELIDO', Self.Apelido);
     Self.Lembrar := arqIni.ReadBool('AUTENTTICA플O','LEMBRAR',Self.Lembrar);
     Self.CaminhoFoto := arqIni.ReadString('AUTENTICA플O','FOTO', Self.CaminhoFoto);
   finally
     arqIni.Free;
   end;
end;

end.
