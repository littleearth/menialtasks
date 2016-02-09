unit Services.Tasks.Interfaces;

interface

uses
  Model.Task, Model.TaskList, Services.Common;

type
  ITaskService = interface
    ['{2166898E-A823-41B5-B17F-D60D86ED8FAD}']
    function GetOnServiceError: TOnServiceError;
    procedure SetOnServiceError(const Value: TOnServiceError);
    procedure Error(AErrorMessage: string; AErrorCode: integer = 0);
    procedure LoadTasks(ATaskList: TTaskList);
    procedure SaveTasks(ATaskList: TTaskList);
    property OnServiceError: TOnServiceError read GetOnServiceError
      write SetOnServiceError;
  end;

implementation

end.
