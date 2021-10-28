unit orm.IBaseVO;

interface

uses
  REST.json;

type
  IBaseVO <T: class> = interface(iinterface)
      ['{48297E67-C372-4C5E-90D5-9DB2D2BCB23B}']
      function toJson(): string;
      function fromJson(json:string): T;
  end;

implementation

end.
