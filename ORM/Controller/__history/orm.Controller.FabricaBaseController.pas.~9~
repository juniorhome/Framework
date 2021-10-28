unit orm.Controller.FabricaBaseController;

interface

uses
  orm.conexao.interfaces.Interfaces;

  type
    TFabricaControllerBase<T: class, constructor> = class(TInterfacedObject, IFabricaController<T>)
    private
    public
      constructor Create;
      destructor Destroy;override;
      class function New: IFabricaController<T>;
      function Controller(aTipoController: TTipoController): IController<T>;
    end;

implementation

{ TFabricaControllerBase<T> }

function TFabricaControllerBase<T>.Controller(
  aTipoController: TTipoController): IController<T>;
begin
  case aTipoController of
    tcCliente:
              begin
                //Falta implementar.
              end;
    tcFuncionario:
                  begin
                    //Falta implementar.
                  end;

  end;
end;

constructor TFabricaControllerBase<T>.Create;
begin
//
end;

destructor TFabricaControllerBase<T>.Destroy;
begin

  inherited;
end;

class function TFabricaControllerBase<T>.New: IFabricaController<T>;
begin
  Result := Self.Create;
end;

end.
