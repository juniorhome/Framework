unit orm.lib.RttiUtils;

interface

uses System.Rtti, System.Classes, System.Variants, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Mask, System.StrUtils, System.SysUtils, Vcl.Forms;

type
  TRttiUtils<T: class, constructor> = class
    private
       class procedure BindValueToComponent(aComponent: TComponent; aValue: Variant);
       class procedure BindValueToProperty(aEntidade: T; aProp: TRttiProperty; aValue: TValue);
       class function GetComponentToValue(aComponent: TComponent): TValue;
       class function GetRttiPropertyValue(aEntidade: T; aPropNome: string): Variant;
       class function GetRttiProperty(aEntidade: T; aPropNome: string): TRttiProperty;
    public
       //M�todos que realizam a liga��o entre os campos com os componentes...
       class procedure BindClassToForm(aForm: TForm; const aEntidade: T);

end;

implementation

{ TRttiUtils }



class procedure TRttiUtils<T>.BindValueToProperty(aEntidade: T;
  aProp: TRttiProperty; aValue: TValue);
begin
   case aProp.PropertyType.TypeKind of
     tkUnknown: ;
     tkInteger: aProp.SetValue(Pointer(aEntidade), StrToInt(aValue.ToString));
     tkChar: aProp.SetValue(Pointer(aEntidade), aValue);
     tkEnumeration: ;
     tkFloat:
        begin
          if (aValue.TypeInfo = TypeInfo(TDate)) or (aValue.TypeInfo = TypeInfo(TDateTime)) or (aValue.TypeInfo = TypeInfo(TTime)) then
             aProp.SetValue(Pointer(aEntidade), StrToDateTime(aValue.ToString))
          else
             aProp.SetValue(Pointer(aEntidade), StrToFloat(aValue.ToString));

        end;
     tkSet: ;
     tkClass: ;
     tkMethod: ;
     tkString, tkWString, tkLString, tkWChar, tkVariant, tkUString:
            aProp.SetValue(Pointer(aEntidade), aValue);
     tkArray: ;
     tkRecord: ;
     tkInterface: ;
     tkInt64: aProp.SetValue(Pointer(aEntidade), aValue.Cast<Int64>);
     tkDynArray: ;
     tkClassRef: ;
     tkPointer: ;
     tkProcedure: ;
     tkMRecord: ;
     else
       aProp.SetValue(Pointer(aEntidade), aValue);
   end;
end;

class function TRttiUtils<T>.GetComponentToValue(
  aComponent: TComponent): TValue;
var a: string;
begin
   if aComponent is TEdit then
     Result := TValue.FromVariant((aComponent as TEdit).Text);
   if aComponent is TComboBox then
      Result := TValue.FromVariant((aComponent as TComboBox).Items[(aComponent as TComboBox).ItemIndex]);
   if aComponent is TRadioGroup then
      Result := TValue.FromVariant((aComponent as TRadioGroup).Items[(aComponent as TRadioGroup).ItemIndex]);
   if aComponent is TCheckBox then
      Result := TValue.FromVariant((aComponent as TCheckBox).Checked);
   if aComponent is TDateTimePicker then
      Result := TValue.FromVariant((aComponent as TDateTimePicker).Date);
   if aComponent is TMemo then
      Result := TValue.FromVariant((aComponent as TMemo).Lines.Text);
   if aComponent is TMaskEdit then
      Result := TValue.FromVariant((aComponent as TMaskEdit).Text);
   if aComponent is TRadioButton then
       Result := TValue.FromVariant((aComponent as TRadioButton).Checked);
end;

class function TRttiUtils<T>.GetRttiProperty(aEntidade: T;
  aPropNome: string): TRttiProperty;
 var
   contexto: TRttiContext;
   tipo: TRttiType;
begin
  contexto := TRttiContext.Create;
  try
    tipo := contexto.GetType(aEntidade.ClassInfo);
    Result := tipo.GetProperty(aPropNome);
    if not Assigned(Result) then
      //Result := tipo.GetPropertyFromAtribute<Campo>(aPropNome);
  finally
    contexto.Free;
  end;
end;

class function TRttiUtils<T>.GetRttiPropertyValue(aEntidade: T;
  aPropNome: string): Variant;
begin
  Result := GetRttiProperty(aEntidade, aPropNome).GetValue(Pointer(aEntidade)).AsVariant;
end;

{ TRttiUtils }

class procedure TRttiUtils<T>.BindClassToForm(aForm: TForm; const aEntidade: T);
var contexto: TRttiContext;
    tipo: TRttiType;
    campo: TRttiField;
    atributo: TCustomAttribute;
begin
   contexto := TRttiContext.Create;
   try
     tipo := contexto.GetType(aForm.ClassInfo);
     for campo in tipo.GetFields do
       for atributo in campo.GetAttributes do
       begin
         //if atributo is TBind then
           //BindValueToComponent(aForm.FindComponent(campo.Name), GetRttiPropertyValue(aEntidade, campo.GetAtributes<Bind>.Field));
       end;
   finally
     contexto.Free;
   end;
end;

class procedure TRttiUtils<T>.BindValueToComponent(aComponent: TComponent;
  aValue: Variant);
begin
  if VarIsNull(aValue) then
    exit;

   if aComponent is TEdit then
      (aComponent as TEdit).Text             := aValue;
   if aComponent is TComboBox then
      (aComponent as TComboBox).ItemIndex    := (aComponent as TComboBox).Items.IndexOf(aValue);
   if aComponent is TRadioGroup then
      (aComponent as TRadioGroup).ItemIndex  := (aComponent as TRadioGroup).Items.IndexOf(aValue);
   if aComponent is TCheckBox then
      (aComponent as TCheckBox).Checked      := aValue;
   if aComponent is TDateTimePicker then
      (aComponent as TDateTimePicker).Date   := aValue;
   if aComponent is TMemo then
      (aComponent as TMemo).Lines.Add(aValue);
   if aComponent is TMaskEdit then
      (aComponent as TMaskEdit).Text         := aValue;
   if aComponent is TRadioButton then
      (aComponent as TRadioButton).Checked   := aValue;
end;

end.