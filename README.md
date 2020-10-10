#Vulkan Simple Sample for Delphi

I'm using Vulkan.pas  converted vulkan header. (https://github.com/BeRo1985/pasvulkan)

*A few changes for macOS 64bit (LogWord->UInt32, LongInt->Int32), statick link libMoltenVK.a when iOS

##base sample
Vulkan SDK 1.2.148.1

                      Samples/API-Samples/utils

                      Samples/API-Samples/draw_textured_cube
                      
                      Demos/cube.c

util.cpp/hpp -> Vulkan.Utils.pas

util_init.cpp/hpp -> Vulkan.Init.pas

draw_textured_cube.cpp + cube.c -> Vulkan_TestMain<.Vcl/.Fmx>.pas


##forVCL

 project:VulkanTest.Vcl.dproj
 
 binary :VulkanTest.Vcl.exe
 
##forFMX

 project:VulkanTest.FMX.dproj
 
 binary :VulkanTest.FMX.exe
 
 ios/macos64 binary is not contained. must build and deploy


