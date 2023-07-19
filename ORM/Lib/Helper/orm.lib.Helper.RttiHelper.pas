unit orm.lib.Helper.RttiHelper;

interface

uses System.Rtti, orm.Atributos;

type
  TRttiFieldHelper = class Helper for TRttiField
    private
    public
      function Tem<T: TCustomAttribute>: Boolean;
      function GetAtribute<T: TCustomAttribute>: T;
  end;

 type
   TRttiPropertyHelper = class Helper for TRttiProperty
     public
       function GetAtribute<T: TCustomAttribute>: T;
       function Tem<T: TCustomAttribute>: Boolean;
       function EhCampoTexto: Boolean;
   end;


implementation

{ TRttiFieldHelper }

function TRttiFieldHelper.GetAtribute<T>: T;
var atributo: TCustomAttribute;
begin
   Result := nil;
   for atributo in GetAttributes do
   begin
     if atributo is T then
       Exit((atributo as T));
   end;
end;

function TRttiFieldHelper.Tem<T>: Boolean;
begin
  Result := GetAtribute<T> <> nil;
end;

{ TRttiPropertyHelper }

function TRttiPropertyHelper.EhCampoTexto: Boolean;
begin
  Result := Tem<TCampoTexto>;
end;

function TRttiPropertyHelper.GetAtribute<T>: T;
var
  atributo: TCustomAttribute;
begin
   Result := nil;
   for atributo in GetAttributes do
   begin
     if atributo is T then
       Exit((atributo as T));
   end;

end;

function TRttiPropertyHelper.Tem<T>: Boolean;
begin
  Result := GetAtribute<T> <> nil;
end;

end.
