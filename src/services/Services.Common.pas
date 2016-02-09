unit Services.Common;

interface

type
  TOnServiceError = procedure(AServiceName: string; AErrorMessage: string;
    AErrorCode: integer) of object;

implementation

end.
