program MenialTasks;

uses
  FMX.Forms,
  Views.Main in '..\views\Win\Views.Main.pas' {ViewMain},
  Views.Task in '..\views\Win\Views.Task.pas' {TaskView},
  Common.Exceptions in '..\common\Common.Exceptions.pas',
  Model.TaskList in '..\model\Model.TaskList.pas',
  Model.Task in '..\model\Model.Task.pas',
  Model.Exceptions in '..\model\Model.Exceptions.pas',
  ViewModel.Task in '..\viewmodels\ViewModel.Task.pas',
  ViewModel.Main in '..\viewmodels\ViewModel.Main.pas',
  EnumerableAdapter in '..\EnumerableAdapter.pas',
  Services.Tasks.Local in '..\services\Services.Tasks.Local.pas',
  Services.Tasks.Interfaces in '..\services\Services.Tasks.Interfaces.pas',
  Services.Common in '..\services\Services.Common.pas',
  Services.Tasks.Kinvey in '..\services\Services.Tasks.Kinvey.pas',
  Common.Kinvey in '..\common\Common.Kinvey.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TViewMain, ViewMain);
  Application.Run;

end.
