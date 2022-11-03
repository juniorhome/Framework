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
     arqIni.WriteInteger('AUTENTICA��O', 'ID', aId);
     arqIni.WriteString('AUTENTICA��O', 'APELIDO', aApelido);
     arqIni.WriteString('AUTENTICA��O', 'FOTO', aCaminhoFoto);
     arqIni.WriteBool('AUTENTICA��O', 'LEMBRAR', aLembrar);
   finally
     arqIni.Free;
   end;
end;

class procedure TSessaoUsuario.LerIni;
var arqIni: TIniFile;
begin
   arqIni := TIniFile.Create(ExtractFilePath(GetCurrentDir)+'\usuario.ini');
   try
     Self.Id := arqIni.ReadInteger('AUTENTICA��O','ID',Self.Id);
     Self.Apelido := arqIni.ReadString('AUTENTICA��O','APELIDO', Self.Apelido);
     Self.Lembrar := arqIni.ReadBool('AUTENTTICA��O','LEMBRAR',Self.Lembrar);
     Self.CaminhoFoto := arqIni.ReadString('AUTENTICA��O','FOTO', Self.CaminhoFoto);
   finally
     arqIni.Free;
   end;
end;

end.
