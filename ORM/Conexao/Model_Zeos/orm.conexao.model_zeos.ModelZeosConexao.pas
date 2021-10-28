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
  FArqIni := TIniFile.Create(ExtractFileDir(GetCurrentDir)+'\Config.ini');
  FConexao := TZConnection.Create(nil);
  //Configura��es b�sicas para funcionar conex�o com banco de dados usando arquivo INI.
  FConexao.Protocol := FArqIni.ReadString('Configuracao', 'Driver', 'Erro ao ler o valor');
  FConexao.DataBase := FArqIni.ReadString('Configuracao', 'Banco', 'Erro ao ler o valor');
  FConexao.HostName := FArqIni.ReadString('Configuracao', 'Host', 'Erro ao ler o valor');
  FConexao.LibraryLocation := FArqIni.ReadString('Configuracao', 'DLL', 'Erro ao ler o valor');
  FConexao.User := FArqIni.ReadString('Configuracao', 'Usuario', 'Erro ao ler o valor');
  FConexao.Password := FArqIni.ReadString('Configuracao', 'Senha', 'Erro ao ler o valor');
  FConexao.Port := StrToInt(FArqIni.ReadString('Configuracao', 'Porta', 'Erro ao ler o valor'));
  FConexao.LoginPrompt := False;
  FConexao.Connected := True;
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
