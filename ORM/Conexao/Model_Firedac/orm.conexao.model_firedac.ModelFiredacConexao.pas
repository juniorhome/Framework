unit orm.conexao.model_firedac.ModelFiredacConexao;

interface

uses System.IniFiles, orm.conexao.interfaces.Interfaces, FireDAC.Comp.Client,
     System.SysUtils, Firedac.Phys.FB, Firedac.Phys.PG;

  type
    TModelFiredacConexao = class(TInterfacedObject, IModelConexao)
      private
        FConexao: TFDConnection;
        FDriverFB: TFDPhysFBDriverLink;
        FDriverPG: TFDPhysPgDriverLink;
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
var  sBase: string;
begin
   FArqIni := TIniFile.Create(ExtractFileDir(GetCurrentDir)+'\Debug\Config.ini');
   FConexao := TFDConnection.Create(nil);
   //Link das DLL do banco.
   sBase := FArqIni.ReadString('Banco', 'Base', 'Base'); //Essa linha est� com problema.
   if sBase = 'FIREBIRD' then
   begin
     FDriverFB := TFDPhysFBDriverLink.Create(nil);
     FDriverFB.VendorLib := FArqIni.ReadString('Banco', 'Biblioteca', 'Biblioteca');
   end
   else if sBase = 'POSTGRESQL' then
   begin
       FDriverPG := TFDPhysPgDriverLink.Create(nil);
       FDriverPG.VendorLib := FArqIni.ReadString('Banco', 'Biblioteca', 'Biblioteca');
   end;

   FConexao.Params.DriverID             := FArqIni.ReadString('FIREDAC', 'DriverID', 'DriverID');
   FConexao.Params.Values['Server']     := FArqIni.ReadString('Banco', 'Servidor', 'Erro ao ler o valor.');
   FConexao.Params.Database             := FArqIni.ReadString('Banco', 'Caminho', 'Erro ao ler o valor.');
   FConexao.Params.UserName             := FArqIni.ReadString('Banco', 'Usuario', 'Erro ao ler o valor.');
   FConexao.Params.Password             := FArqIni.ReadString('Banco', 'Senha', 'Erro ao ler o valor.');
   FConexao.LoginPrompt := False;
   FConexao.Connected := true;
end;

destructor TModelFiredacConexao.Destroy;
begin
  if Assigned(FDriverFB) then
     FDriverFB.Free;
  if Assigned(FDriverPG) then
     FDriverPG.Free;
  FreeAndNil(FConexao);
  FreeAndNil(FArqIni);
  inherited;
end;

class function TModelFiredacConexao.New(): IModelConexao;
begin
  Result := Self.Create();
end;

end.
