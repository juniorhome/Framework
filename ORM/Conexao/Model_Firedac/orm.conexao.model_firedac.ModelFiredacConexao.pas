unit orm.conexao.model_firedac.ModelFiredacConexao;

interface

uses System.IniFiles, orm.conexao.interfaces.Interfaces, FireDAC.Comp.Client,
     System.SysUtils;

  type
    TModelFiredacConexao = class(TInterfacedObject, IModelConexao)
      private
        FConexao: TFDConnection;
        FArqIni: TIniFile;
      public
        constructor Create();
        destructor Destroy;override;
        class function New(): IModelConexao;
        function Connection: TObject;
    end;

implementation



{ TModelFiredacConexao }

function TModelFiredacConexao.Connection: TObject;
begin
   Result := FConexao;
end;

constructor TModelFiredacConexao.Create();
begin
   FArqIni := TIniFile.Create(ExtractFileDir(GetCurrentDir)+'\Config.ini');
   FConexao := TFDConnection.Create(nil);
   FConexao.Params.DriverID := FArqIni.ReadString('Configuracao', 'Driver', 'Erro ao ler o valor.');
   FConexao.Params.Values['Server'] := FArqIni.ReadString('Configuracao', 'Host', 'Erro ao ler o valor.');
   FConexao.Params.Database := FArqIni.ReadString('Configuracao', 'Banco', 'Erro ao ler o valor.');
   FConexao.Params.UserName := FArqIni.ReadString('Configuracao', 'Usuario', 'Erro ao ler o valor.');
   FConexao.Params.Password := FArqIni.ReadString('Configuracao', 'Senha', 'Erro ao ler o valor.');
   FConexao.LoginPrompt := False;
   FConexao.Connected := true;
end;

destructor TModelFiredacConexao.Destroy;
begin
  FreeAndNil(FConexao);
  FreeAndNil(FArqIni);
  inherited;
end;

class function TModelFiredacConexao.New(): IModelConexao;
begin
  Result := Self.Create();
end;

end.
