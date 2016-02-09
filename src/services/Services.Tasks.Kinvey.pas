unit Services.Tasks.Kinvey;

interface

uses
  System.Classes, System.Generics.Collections,
  Services.Tasks.Interfaces, Services.Common,
  Model.Task, Model.TaskList, Common.Kinvey;

type
  TTaskServiceKinvey = class(TInterfacedObject, ITaskService)
  private
    FOnServiceError: TOnServiceError;
    function GetAppID: string;
    function GetAppSecret: string;
    function GetMasterSecret: string;
    function GetBackendClassName: string;
    procedure SetOnServiceError(const Value: TOnServiceError);
    function GetOnServiceError: TOnServiceError;
    procedure Error(AErrorMessage: string; AErrorCode: integer = 0);
  public
    procedure LoadTasks(ATaskList: TTaskList);
    procedure SaveTasks(ATaskList: TTaskList);
    procedure SaveTask(ATask: TTask);
    property OnServiceError: TOnServiceError read GetOnServiceError
      write SetOnServiceError;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, IPPeerClient, REST.Backend.ServiceTypes,
  REST.Backend.MetaTypes, System.JSON, REST.Backend.KinveyServices,
  REST.Backend.Providers, REST.Backend.ServiceComponents,
  REST.Backend.KinveyProvider, REST.JSON;

{ TTaskService }

procedure TTaskServiceKinvey.Error(AErrorMessage: string; AErrorCode: integer);
begin
  if Assigned(FOnServiceError) then
    FOnServiceError('Task File Service', AErrorMessage, AErrorCode);
end;

function TTaskServiceKinvey.GetAppID: string;
begin
  Result := KINVEY_APPKEY;
end;

function TTaskServiceKinvey.GetAppSecret: string;
begin
  Result := KINVEY_APPSECRET;
end;

function TTaskServiceKinvey.GetBackendClassName: string;
begin
  Result := 'Tasks';
end;

function TTaskServiceKinvey.GetMasterSecret: string;
begin
  Result := KINVEY_MASTERSECRET;
end;

function TTaskServiceKinvey.GetOnServiceError: TOnServiceError;
begin
  Result := FOnServiceError;
end;

procedure TTaskServiceKinvey.LoadTasks(ATaskList: TTaskList);
var
  Task: TTask;
  KinveyProvider: TKinveyProvider;
  BackendStorage: TBackendStorage;
  BackendList: TBackendObjectList<TTask>;
begin
  BackendList := TBackendObjectList<TTask>.Create;
  KinveyProvider := TKinveyProvider.Create(nil);
  BackendStorage := TBackendStorage.Create(nil);
  try
    try
      BackendStorage.Provider := KinveyProvider;
      KinveyProvider.AppKey := GetAppID;
      KinveyProvider.AppSecret := GetAppSecret;
      KinveyProvider.MasterSecret := GetMasterSecret;
      BackendStorage.Storage.QueryObjects<TTask>(GetBackendClassName, [],
        BackendList);

      ATaskList.Clear;
      for Task in BackendList do
      begin
        ATaskList.AddNewTask.Assign(Task);
      end;
    except
      on E: Exception do
      begin
        Error(E.Message);
      end;
    end;
  finally
    FreeAndNil(KinveyProvider);
    FreeAndNil(BackendStorage);
    FreeAndNil(BackendList);
  end;
end;

procedure TTaskServiceKinvey.SaveTask(ATask: TTask);
var
  KinveyProvider: TKinveyProvider;
  BackendStorage: TBackendStorage;
  Entity, UpdateEntity: TBackendEntityValue;
  Query: string;
  BackendList: TBackendObjectList<TTask>;
  Task: TTask;
begin
  BackendList := TBackendObjectList<TTask>.Create;
  KinveyProvider := TKinveyProvider.Create(nil);
  BackendStorage := TBackendStorage.Create(nil);
  try
    try
      BackendStorage.Provider := KinveyProvider;
      KinveyProvider.AppKey := GetAppID;
      KinveyProvider.AppSecret := GetAppSecret;
      KinveyProvider.MasterSecret := GetMasterSecret;

      Query := Format('query={"title":"%s"}', [ATask.Title]);

      BackendStorage.Storage.QueryObjects<TTask>(GetBackendClassName, [Query],
        BackendList);
      if BackendList.Count > 0 then
      begin

        for Task in BackendList do
        begin
          if SameText(Task.Title, ATask.Title) then
          begin
            Entity := BackendList.EntityValues[Task];
            BackendStorage.Storage.UpdateObject<TTask>(Entity, ATask,
              UpdateEntity);
          end;
        end;

      end
      else
      begin
        BackendStorage.Storage.CreateObject<TTask>(GetBackendClassName, ATask,
          UpdateEntity);
      end;
    except
      on E: Exception do
      begin
        Error(E.Message);
      end;
    end;
  finally
    FreeAndNil(KinveyProvider);
    FreeAndNil(BackendStorage);
    FreeAndNil(BackendList);
  end;
end;

procedure TTaskServiceKinvey.SaveTasks(ATaskList: TTaskList);
var
  Task: TTask;
begin
  for Task in ATaskList.GetEnumerable do
  begin
    SaveTask(Task);
  end;
end;

procedure TTaskServiceKinvey.SetOnServiceError(const Value: TOnServiceError);
begin
  FOnServiceError := Value;
end;

end.
