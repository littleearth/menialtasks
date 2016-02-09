unit Services.Tasks.Local;

interface

uses
  System.Classes, System.Generics.Collections,
  Services.Tasks.Interfaces, Services.Common,
  Model.Task, Model.TaskList;

type
  TTaskServiceLocal = class(TInterfacedObject, ITaskService)
  private
    FOnServiceError: TOnServiceError;
    function GetFileName: string;
    function LoadFile: string;
    procedure SaveFile(AJSON: string);
    procedure SetOnServiceError(const Value: TOnServiceError);
    function GetOnServiceError: TOnServiceError;
    procedure Error(AErrorMessage: string; AErrorCode: integer = 0);
  public
    procedure LoadTasks(ATaskList: TTaskList);
    procedure SaveTasks(ATaskList: TTaskList);
    property OnServiceError: TOnServiceError read GetOnServiceError
      write SetOnServiceError;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.JSON, REST.JSON;

{ TTaskService }

procedure TTaskServiceLocal.Error(AErrorMessage: string; AErrorCode: integer);
begin
  if Assigned(FOnServiceError) then
    FOnServiceError('Task File Service', AErrorMessage, AErrorCode);
end;

function TTaskServiceLocal.GetFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(TPath.GetDocumentsPath) + 'tasks.json';
end;

function TTaskServiceLocal.GetOnServiceError: TOnServiceError;
begin
  Result := FOnServiceError;
end;

function TTaskServiceLocal.LoadFile: string;
var
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    if FileExists(GetFileName) then
    begin
      StringList.LoadFromFile(GetFileName);
    end;
    Result := StringList.Text;
    if Trim(Result) = '' then
      Result := '[]';
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TTaskServiceLocal.LoadTasks(ATaskList: TTaskList);
var
  JSONArray: TJSONArray;
  JSONValue: TJSONValue;
  Task: TTask;
  JSON: string;
begin
  JSONArray := nil;
  try
    try
      JSON := LoadFile;
      JSONArray := TJSONObject.ParseJSONValue(JSON) as TJSONArray;
      if Assigned(JSONArray) then
      begin
        ATaskList.Clear;
        JSON := JSONArray.ToJSON;
        for JSONValue in JSONArray do
        begin
          try
            JSON := JSONValue.ToJSON;
            Task := TJson.JsonToObject<TTask>(JSONValue.ToJSON);
            ATaskList.AddTask(Task);
          except
          end;
        end;
      end;
    except
      on E: Exception do
      begin
        Error(E.Message);
      end;
    end;
  finally
    if Assigned(JSONArray) then
      JSONArray.Free;
  end;
end;

procedure TTaskServiceLocal.SaveFile(AJSON: string);
var
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    StringList.Add(AJSON);
    StringList.SaveToFile(GetFileName);
  finally
    FreeAndNil(StringList);
  end;
end;

procedure TTaskServiceLocal.SaveTasks(ATaskList: TTaskList);
var
  JSONArray: TJSONArray;
  Task: TTask;
  JSON: string;
begin
  try
    JSONArray := TJSONArray.Create;
    for Task in ATaskList.GetEnumerable do
    begin
      JSON := TJson.ObjectToJsonString(Task);
      JSONArray.AddElement(TJSONObject.ParseJSONValue(JSON) as TJSONValue);
    end;
    JSON := JSONArray.ToJSON;
    SaveFile(JSONArray.ToJSON);
  except
    on E: Exception do
    begin
      Error(E.Message);
    end;
  end;
end;

procedure TTaskServiceLocal.SetOnServiceError(const Value: TOnServiceError);
begin
  FOnServiceError := Value;
end;

end.
