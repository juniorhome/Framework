unit orm.lib.Constantes;

interface

const

  CONST_ENDRDW = '';

  CONST_CPF       = '/^\d{3}\.\d{3}\.\d{3}\-\d{2}$/';
  CONST_CNPJ      = '/^\d{2}\.\d{3}\.\d{3}\/\d{4}\-\d{2}$/';
  CONST_EMAIL     = '^((?>[a-zA-Z\d!#$%&''*+\-/=?^_`{|}~]+\x20*|"((?=[\ x01-\x7f])'
                    +'[^"\\]|\\[\x01-\x7f])*"\x20*)*(?<�ngulo><))?((?!\.)'
                    +'(?>\.?[a-zA-Z\d!#$%&''*+\-/=?^_`{|}~]+)+|"((?=[\x01 -\x7f])'
                    +'[^"\\]|\\[\x01-\x7f])*")@(((?!-)[a-zA-Z\d\-]+(?<!-)\. )+[a-zA-Z]'
                    +'{2,}|\[(((?(?<!\[)\.)(25[0-5]|2[0-4]\d|[01]?\d?\d) )'
                    +'{4}|[a-zA-Z\d\-]*[a-zA-Z\d]:((?=[\x01-\x7f])[^\\\[\]]| \\'
                    +'[\x01-\x7f])+)\])(?(�ngulo)>)$';
  CONST_TELEFONE  = '/^(?:(?:\+|00)?(55)\s?)?(?:\(?([1-9][0-9])\)?\s? )?(?:((?:9\d|[2-9])\d{3})\-?(\d{4}))$/';
  CONST_CELULAR   = '^[1-9]{2}(?:[6-9]|9[1-9])[0-9]{3}[0-9]{4}$';
  CONST_DATA      = '^((0[1-9]|[12]\d)\/(0[1-9]|1[0-2])|30\/(0[13-9]|1[0-2])|31\/(0[13578]|1[02])) \/\d{4}$';

implementation

end.
