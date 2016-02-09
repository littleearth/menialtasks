unit ViewModel.Main;

interface

uses
  Model.TaskList, ViewModel.Task, Model.Task, Services.Tasks.Interfaces,
  Services.Common;

type
  TOnEditTask = reference to procedure(Sender: TObject;
    TaskViewModel: TTaskViewModel);
  TOnError = reference to procedure(ASender: TObject; AErrorMessage: string;
    AErrorCode: Integer);

  TMainViewModel = class
  private
    FTasks: TTaskList;
    FOnEditTask: TOnEditTask;
    FTaskService: ITaskService;
    FOnError: TOnError;
    procedure SetOnError(const Value: TOnError);
    procedure OnServiceError(AServiceName: string; AErrorMessage: string;
      AErrorCode: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    property Tasks: TTaskList read FTasks;
    procedure AddNewTask;
    procedure Load;
    procedure Save;
    procedure EditTask(ATask: TTask);
    property OnEditTask: TOnEditTask read FOnEditTask write FOnEditTask;
    property OnError: TOnError read FOnError write SetOnError;
  end;

implementation

uses
  System.SysUtils, Services.Tasks.Kinvey;

{ TMainViewModel }

procedure TMainViewModel.AddNewTask;
var
  LTaskViewModel: TTaskViewModel;
  NewTask: TTask;
begin
  NewTask := TTask.Create;
  LTaskViewModel := TTaskViewModel.Create(NewTask);
  LTaskViewModel.OnSaveTask := procedure(Sender: TTaskViewModel; Task: TTask)
    begin
      Tasks.AddTask(Task);
      Save;
    end;
  if Assigned(FOnEditTask) then
    FOnEditTask(self, LTaskViewModel);
end;

constructor TMainViewModel.Create;
begin
  FTasks := TTaskList.Create;
  FTaskService := TTaskServiceKinvey.Create;
  FTaskService.OnServiceError := OnServiceError;
end;

destructor TMainViewModel.Destroy;
begin
  FTasks.Free;
  FTaskService := nil;
  inherited;
end;

procedure TMainViewModel.EditTask(ATask: TTask);
var
  LTaskViewModel: TTaskViewModel;
begin
  LTaskViewModel := TTaskViewModel.Create(ATask);
  LTaskViewModel.OnSaveTask := procedure(Sender: TTaskViewModel; Task: TTask)
    begin
      Save;
    end;
  if Assigned(FOnEditTask) then
    FOnEditTask(self, LTaskViewModel);
end;

procedure TMainViewModel.Load;
begin
  FTaskService.LoadTasks(FTasks);
end;

procedure TMainViewModel.OnServiceError(AServiceName, AErrorMessage: string;
  AErrorCode: Integer);
begin
  if Assigned(FOnError) then
    FOnError(self, Format('[%s] ERROR: %s', [AServiceName, AErrorMessage]),
      AErrorCode);
end;

procedure TMainViewModel.Save;
begin
  FTaskService.SaveTasks(FTasks);
end;

procedure TMainViewModel.SetOnError(const Value: TOnError);
begin
  FOnError := Value;
end;

end.
