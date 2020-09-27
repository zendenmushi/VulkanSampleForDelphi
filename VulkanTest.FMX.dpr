program VulkanTest.FMX;



uses
  System.StartUpCopy,
  FMX.Forms,
  Vulkan.Init in 'Vulkan.Init.pas',
  Vulkan in 'Vulkan.pas',
  Vulkan.Utils in 'Vulkan.Utils.pas',
  Vulkan_TestMain in 'Vulkan_TestMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
