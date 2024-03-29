unit orm.conexao.model_zeos.ModelZeosConexao;

interface

uses System.IniFiles, orm.conexao.interfaces.Interfaces, ZConnection,
  System.SysUtils;

 type
   TModelZeosConexao = class(TInterfacedObject, IModelConexao)
     private
       FConexao: TZConnection;
       FArqIni: TIniFile;
     public
       constructor Create();
       destructor Destroy;override;
       class function New(): IModelConexao;
       function Connection: TObject;
   end;

implementation

{ TModelZeosConexao }

function TModelZeosConexao.Connection: TObject;
begin
   Result := FConexao;
end;

constructor TModelZeosConexao.Create();
begin
  FArqIni := TIniFile.Create(ExtractFileDir(GetCurrentDir)+'\Debug\Config.ini');
  FConexao := TZConnection.Create(nil);
  if FileExists(ExtractFileDir(GetCurrentDir)+'\Debug\Config.ini') then
  begin
    //Configura��es b�sicas para funcionar conex�o com banco de dados usando arquivo INI.
    FConexao.Protocol := FArqIni.ReadString('Banco', 'Base', 'Erro ao ler o valor do campo Base');
    FConexao.DataBase := FArqIni.ReadString('Banco', 'Caminho', 'Erro ao ler o valor Banco');
    FConexao.HostName := FArqIni.ReadString('Banco', 'Servidor', 'Erro ao ler o valor Servidor');
    FConexao.LibraryLocation := FArqIni.ReadString('Banco', 'Biblioteca', 'Erro ao ler o valor Biblioteca');
    FConexao.User := FArqIni.ReadString('Banco', 'Usuario', 'Erro ao ler o valor Usu�rio');
    FConexao.Password := FArqIni.ReadString('Banco', 'Senha', 'Erro ao ler o valor');
    FConexao.Port := StrToInt(FArqIni.ReadString('Banco', 'Porta', 'Erro ao ler o valor Porta'));
    FConexao.LoginPrompt := False;
    FConexao.Connected := True;
    FConexao.AutoCommit := False;
  end;
end;

destructor TModelZeosConexao.Destroy;
begin
  FreeAndNil(FConexao);
  FreeAndNil(FArqIni);
  inherited;
end;

class function TModelZeosConexao.New(): IModelConexao;
begin
  Result := Self.Create();
end;

end.
