program VulkanTest.Vcl;

uses
  Vcl.Forms,
  Vulkan_TestMain.Vcl in 'Vulkan_TestMain.Vcl.pas' {MainForm},
  Vulkan.Init in 'Vulkan.Init.pas',
  Vulkan in 'Vulkan.pas',
  Vulkan.Utils in 'Vulkan.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
