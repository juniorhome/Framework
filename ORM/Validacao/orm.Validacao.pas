unit orm.Validacao;

interface

uses System.RegularExpressions, orm.lib.Constantes, System.SysUtils, System.Rtti,
     orm.Atributos;

 type
   TValidacao = class
     private
     public
       //Validaçao na Tela de cadastro.
       class function ValidarEmail(const Email: string): boolean;
       class function ValidarData(const Data: string): boolean;
       class function ValidarCnpj(const Cnpj: string): boolean;
       class function ValidarCpf(const Cpf: string): boolean;
       class function ValidarTelefone(const Telefone: string): boolean;
       class function ValidarCelular(const Celular: string): boolean;

       //Validação no servidor.
       class function IsCpf(const Cpf: string): boolean;
       class function IsCnpj(const Cnpj: string): boolean;
       class function ValidarCampo<T: class>(obj: T): string;
   end;

implementation

{ TValidacao }

class function TValidacao.IsCnpj(const Cnpj: string): boolean;
var
   dig13, dig14: string;
   r, sm, i, peso: integer;
begin
  if ((Cnpj = '0000000000000') or (Cnpj = '11111111111111')
     or (Cnpj = '22222222222222') or (Cnpj = '33333333333333')
     or (Cnpj = '44444444444444') or (Cnpj = '55555555555555')
     or (Cnpj = '66666666666666') or (Cnpj = '77777777777777')
     or (Cnpj = '88888888888888') or (Cnpj = '99999999999999')
     or (Length(Cnpj) <> 14)) then
     begin
       Result := False;
       exit;
     end;
     try
       sm := 0;
       peso := 2;
       for i := 12 downto 1 do
       begin
         sm := sm + (StrToInt(Cnpj[i]) * peso);
         peso := peso + 1;
         if peso = 10 then
           peso := 2;
       end;
       r := sm mod 11;
       if (r = 0) or (r = 1) then
           dig13 := '0'
       else str((11 - r):1, dig13);

       sm := 0;
       peso := 2;
       for i := 13 downto 1 do
       begin
         sm := sm + (StrToInt(Cnpj[i]) * peso);
         peso := peso + 1;
         if peso = 10 then
           peso := 2;
       end;
       r := sm mod 11;
       if (r = 0) or (r = 1) then
          dig14 := '0'
       else str((11 - r):1, dig14);
       if (Cnpj[13] = dig13) and (Cnpj[14] = dig14) then
          Result := True
       else Result := False;
     except on Exception do
        begin
           Result := False;
        end;

     end;

end;

class function TValidacao.IsCpf(const Cpf: string): boolean;
var
   dig10, dig11: string;
   s, i, r, peso: integer;
begin
   if ((Cpf = '00000000000') or (Cpf = '11111111111') or (Cpf = '22222222222')
      or (Cpf = '33333333333') or (Cpf = '44444444444') or (Cpf = '55555555555')
      or (Cpf = '66666666666') or (Cpf = '77777777777') or (Cpf = '88888888888')
      or (Cpf = '99999999999') or (Length(Cpf) <> 11)) then
      begin
        Result := False;
        exit;
      end;
   try
      s := 0;
      peso := 10;
      for i := 1 to 9 do
      begin
        s := s + (StrToInt(Cpf[i]) * peso);
        peso := peso - 1;
      end;
      r := 11  - (s mod 11);
      if (r = 10) or (r = 11) then
         dig10 := '0'
      else str(r:1, dig10);

      s := 0;
      peso := 11;
      for i := 1 to 10 do
      begin
        s := s + (StrToInt(Cpf[i]) * peso);
        peso := peso - 1;
      end;
      r := 11 - (s mod 11);
      if (r = 10) or (r = 11) then
         dig11 := '0'
      else str(r:1, dig11);

      if ((Cpf[10] = dig10) and (Cpf[11] = dig11)) then
         Result := True
      else Result := False;

   except
      Result := False;
   end;

end;

class function TValidacao.ValidarCampo<T>(obj: T): string;
var
   contexto: TRttiContext;
   prop: TRttiProperty;
   tipo: TRttiType;
   atributo: TCustomAttribute;
   mensagem_campo: string;
begin
    contexto := TRttiContext.Create;
    try
      tipo := contexto.GetType(TObject(obj).ClassInfo);
      for prop in tipo.GetProperties do
        for atributo in prop.GetAttributes do
        begin
          if atributo is TCampoTexto then
          begin
            if prop.GetValue(TObject(obj)).AsString.Equals('') then
              mensagem_campo := 'O campo '+ TCampoTexto(atributo).Nome + ' está vazio.';
          end;
          if atributo is TCampoInteiro then
          begin
            if (prop.GetValue(TObject(obj)).AsInteger = 0) or (prop.GetValue(TObject(obj)).AsInteger < 0) then
              mensagem_campo := 'O campo ' + TCampoInteiro(atributo).Nome + ' não pode receber zero.'
            else mensagem_campo := 'O campo ' + TCampoInteiro(atributo).Nome + ' não pode ter valor negativo.';
          end;
          if atributo is TCampoExtended then
          begin
            if prop.GetValue(TObject(obj)).AsExtended < 0.0 then
              mensagem_campo := 'O campo ' + TCampoExtended(atributo).Nome + ' não pode receber zero.';
          end;
          if atributo is TCampoMonetario then
          begin
            if prop.GetValue(TObject(obj)).AsCurrency < 0.00 then
              mensagem_campo := 'O campo ' + TCampoMonetario(atributo).Nome + ' não pode receber zero.';
          end;
        end;
        result := mensagem_campo;
    finally
      contexto.Free;
    end;
end;

class function TValidacao.ValidarCelular(const Celular: string): boolean;
begin
  Result := TRegex.IsMatch(Celular, CONST_CELULAR);
end;

class function TValidacao.ValidarCnpj(const Cnpj: string): boolean;
begin
   Result := TRegex.IsMatch(Cnpj, CONST_CNPJ);
end;

class function TValidacao.ValidarCpf(const Cpf: string): boolean;
begin
  Result := TRegex.IsMatch(Cpf, CONST_CPF);
end;

class function TValidacao.ValidarData(const Data: string): boolean;
begin
   Result := TRegex.IsMatch(Data, CONST_DATA);
end;

class function TValidacao.ValidarEmail(const Email: string): boolean;
begin
   Result := TRegex.IsMatch(Email, CONST_EMAIL);
end;

class function TValidacao.ValidarTelefone(const Telefone: string): boolean;
begin
  Result := TRegex.IsMatch(Telefone, CONST_TELEFONE);
end;

end.
