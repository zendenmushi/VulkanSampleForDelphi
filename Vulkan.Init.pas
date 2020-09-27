(*
 * Vulkan Samples
 *
 * Copyright (C) 2015-2020 Valve Corporation
 * Copyright (C) 2015-2020 LunarG, Inc.
 * Copyright (C) 2015-2020 Google, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

 // Convert to pas : 2020 TMaeda
 // If you build with FireMonkey, you must define FMX

unit Vulkan.Init;

interface
uses
  System.Types, System.SysUtils,System.Math.Vectors
{$ifdef MSWINDOWS}
  ,Winapi.Windows, Winapi.Messages
{$endif}
{$ifdef MACOS}
  ,Macapi.AppKit, Macapi.MetalKit, Macapi.ObjectiveC, Macapi.QuartzCore
{$endif}
  ,Vulkan, Vulkan.Utils
{$ifdef FMX}
  ,FMX.Graphics, FMX.Types, FMX.DialogS//ervice
{$endif}
  ;

type
  TRaiseErrorFunc = procedure(code : integer; msg : string);
  TLogFunc = procedure(msg : string);


  function  init_global_extension_properties(var info : TVulkanSampleInfo; var layer_props : TLayerProperties) : TVkResult;
  function  init_global_layer_properties(var info : TVulkanSampleInfo) : TVkResult;
  function  init_device_extension_properties(var info : TVulkanSampleInfo; var layer_props : TLayerProperties) : TVkResult;

  procedure init_instance_extension_names(var info : TVulkanSampleInfo);
  function  init_instance(var info : TVulkanSampleInfo; const app_short_name : AnsiString) : TVkResult;
  procedure init_device_extension_names(var info : TVulkanSampleInfo);
  function  init_device(var info : TVulkanSampleInfo) : TVkResult;
  function  init_enumerate_device(var info : TVulkanSampleInfo; gpu_count : UInt32 = 1) : TVkResult;
  procedure init_queue_family_index(var info : TVulkanSampleInfo);
  function  init_debug_report_callback(var info : TVulkanSampleInfo; dbgFunc : TPFN_vkDebugReportCallbackEXT) : TVkResult;
  procedure destroy_debug_report_callback(var info : TVulkanSampleInfo);

{$if Defined(VK_USE_PLATFORM_WAYLAND_KHR)}
  procedure registry_handle_global(PRegistry : Twl_registry; id : UInt32; const interface_str : string; version : UInt32);
{$endif}

  procedure init_connection(var info : TVulkanSampleInfo);
  procedure init_window(var info : TVulkanSampleInfo; NativeHandle : NativeUInt = 0);
  procedure destroy_window(var info : TVulkanSampleInfo);
  procedure init_window_size(var info : TVulkanSampleInfo; default_width, default_height : UInt32);
  procedure init_depth_buffer(var info : TVulkanSampleInfo);
  procedure init_swapchain_extension(var info : TVulkanSampleInfo);
  procedure init_presentable_image(var info : TVulkanSampleInfo);
  procedure execute_queue_cmdbuf(var info : TVulkanSampleInfo; const cmd_bufs : PVkCommandBuffer; var fence : TVkFence);
  procedure execute_pre_present_barrier(var info : TVulkanSampleInfo);
  procedure execute_present_image(var info : TVulkanSampleInfo);
  procedure init_surface(var info : TVulkanSampleInfo); // add
  procedure init_swap_chain(var info : TVulkanSampleInfo; usageFlags : TVkImageUsageFlags = $11{VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT or VK_IMAGE_USAGE_TRANSFER_SRC_BIT}; NumOfSwapchain : UInt32 = 0);
  procedure init_uniform_buffer(var info : TVulkanSampleInfo);
  procedure init_descriptor_and_pipeline_layouts(var info : TVulkanSampleInfo; use_texture : Boolean; descSetLayoutCreateFlags : TVkDescriptorSetLayoutCreateFlags = 0);
  procedure init_renderpass(var info : TVulkanSampleInfo; include_depth : Boolean; clear : Boolean = true; finalLayout : TVkImageLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR; initialLayout : TVkImageLayout = VK_IMAGE_LAYOUT_UNDEFINED);
  procedure init_framebuffers(var info : TVulkanSampleInfo; include_depth : Boolean);
  procedure init_command_pool(var info : TVulkanSampleInfo);
  procedure init_command_buffer(var info : TVulkanSampleInfo);
  procedure execute_begin_command_buffer(var info : TVulkanSampleInfo);
  procedure execute_end_command_buffer(var info : TVulkanSampleInfo);
  procedure execute_queue_command_buffer(var info : TVulkanSampleInfo);
  procedure init_device_queue(var info : TVulkanSampleInfo);
  procedure init_vertex_buffer(var info : TVulkanSampleInfo; const vertexData : Pointer; dataSize : UInt32; dataStride : UInt32; use_texture : Boolean);
  procedure init_descriptor_pool(var info : TVulkanSampleInfo; use_texture : Boolean);
  procedure init_descriptor_set(var info : TVulkanSampleInfo; use_texture : Boolean);
  procedure init_shaders(var info : TVulkanSampleInfo; const vertShaderCI : PVkShaderModuleCreateInfo; const fragShaderCI : PVkShaderModuleCreateInfo);
  procedure init_pipeline_cache(var info : TVulkanSampleInfo);
  procedure init_pipeline(var info : TVulkanSampleInfo; include_depth : Boolean; include_vi : Boolean = true);
  procedure init_sampler(var info : TVulkanSampleInfo; var sampler : TVkSampler);
  procedure init_buffer(var info : TVulkanSampleInfo; var texObj : Ttexture_object);
  procedure init_image(var info : TVulkanSampleInfo; var texObj : Ttexture_object; const textureName : string; extraUsages : TVkImageUsageFlags; extraFeatures : TVkFormatFeatureFlags);
  procedure init_texture(var info : TVulkanSampleInfo; const textureName : string = ''; extraUsages : TVkImageUsageFlags = 0; extraFeatures : TVkFormatFeatureFlags = 0);
  procedure init_viewports(var info : TVulkanSampleInfo);
  procedure init_scissors(var info : TVulkanSampleInfo);
  function  init_fence(var info : TVulkanSampleInfo; var fence : TVkFence; flags : TVkFenceCreateFlags = 0) : TVkResult; // add flags and result
  procedure init_submit_info(var info : TVulkanSampleInfo; var submit_info : TVkSubmitInfo; var pipe_stage_flags : TVkPipelineStageFlags);
  procedure init_present_info(var info : TVulkanSampleInfo; var present : TVkPresentInfoKHR);
  procedure init_clear_color_and_depth(var info : TVulkanSampleInfo; var clear_values : array of TVkClearValue);
  procedure init_render_pass_begin_info(var info : TVulkanSampleInfo; var rp_begin : TVkRenderPassBeginInfo);
  procedure destroy_pipeline(var info : TVulkanSampleInfo);
  procedure destroy_pipeline_cache(var info : TVulkanSampleInfo);
  procedure destroy_uniform_buffer(var info : TVulkanSampleInfo);
  procedure destroy_descriptor_and_pipeline_layouts(var info : TVulkanSampleInfo);
  procedure destroy_descriptor_pool(var info : TVulkanSampleInfo);
  procedure destroy_shaders(var info : TVulkanSampleInfo);
  procedure destroy_command_buffer(var info : TVulkanSampleInfo);
  procedure destroy_command_pool(var info : TVulkanSampleInfo);
  procedure destroy_depth_buffer(var info : TVulkanSampleInfo);
  procedure destroy_vertex_buffer(var info : TVulkanSampleInfo);
  procedure destroy_swap_chain(var info : TVulkanSampleInfo; resize : Boolean = false);
  procedure destroy_framebuffers(var info : TVulkanSampleInfo);
  procedure destroy_renderpass(var info : TVulkanSampleInfo);
  procedure destroy_device(var info : TVulkanSampleInfo);
  procedure destroy_instance(var info : TVulkanSampleInfo);
  procedure destroy_textures(var info : TVulkanSampleInfo);
  procedure destroy_semaphore_and_fences(var info : TVulkanSampleInfo);

  function VKBool32(bool : Boolean) : TVkBool32;


var
  RaiseError : TRaiseErrorFunc;
  Log : TLogFunc;

implementation

function VKBool32(bool : Boolean) : TVkBool32;
begin
  if bool then result := VK_TRUE else result := VK_FALSE;
end;


procedure DefaultRaiseError(code : integer; msg : string);
begin
  Log(msg);
  halt(code);
end;

procedure DefaultLogFunc(msg : string);
begin
{$ifdef MSWINDOWS}
  OutputDebugString(PWideChar(msg));
{$endif}
end;

function init_global_extension_properties(var info : TVulkanSampleInfo; var layer_props : TLayerProperties) : TVkResult;
begin
  var instance_extensions : PVkExtensionProperties;
  var instance_extension_count : UInt32;
  var layer_name : PAnsiChar := layer_props.properties.layerName;

  repeat
    result := vkEnumerateInstanceExtensionProperties(layer_name, @instance_extension_count, nil);
    if result <> VK_SUCCESS then exit;

    if (instance_extension_count = 0) then
    begin
      exit(VK_SUCCESS);
    end;

    SetLength(layer_props.instance_extensions, instance_extension_count);
    instance_extensions := @layer_props.instance_extensions[0];
    result := vkEnumerateInstanceExtensionProperties(layer_name, @instance_extension_count, instance_extensions);
  until (result <> VK_INCOMPLETE);
end;

function init_global_layer_properties(var info : TVulkanSampleInfo) : TVkResult;
begin
  var instance_layer_count : UInt32;
  var vk_props : TArray<TVkLayerProperties>;
{$ifdef ANDROID}
  // This place is the first place for samples to use Vulkan APIs.
  // Here, we are going to open Vulkan.so on the device and retrieve function pointers using
  // vulkan_wrapper helper.
  if not InitVulkan() then
  begin
      LOGE('Failied initializing Vulkan APIs!');
      exit(VK_ERROR_INITIALIZATION_FAILED);
  end;
  LOGI('Loaded Vulkan APIs.');
{$endif}

  (*
   * It's possible, though very rare, that the number of
   * instance layers could change. For example, installing something
   * could include new layers that the loader would pick up
   * between the initial query for the count and the
   * request for VkLayerProperties. The loader indicates that
   * by returning a VK_INCOMPLETE status and will update the
   * the count parameter.
   * The count parameter will be updated with the number of
   * entries loaded into the data pointer - in case the number
   * of layers went down or is smaller than the size given.
   *)
  repeat
    result := vkEnumerateInstanceLayerProperties(@instance_layer_count, nil);
    if result <> VK_SUCCESS then exit;

    if (instance_layer_count = 0) then
    begin
      exit(VK_SUCCESS);
    end;

    SetLength(vk_props, instance_layer_count);

    result := vkEnumerateInstanceLayerProperties(@instance_layer_count, @vk_props[0]);
  until (result <> VK_INCOMPLETE);

  (*
   * Now gather the extension list for each instance layer.
   *)
  for var i := 0  to instance_layer_count-1 do
  begin
    var layer_props := Default(TLayerProperties);
    layer_props.properties := vk_props[i];
    result := init_global_extension_properties(info, layer_props);
    if result <> VK_SUCCESS then exit;
    info.instance_layer_properties := info.instance_layer_properties + [layer_props];
  end;
  vk_props := nil;
end;

function init_device_extension_properties(var info : TVulkanSampleInfo; var layer_props : TLayerProperties) : TVkResult;
begin
  var device_extension_count : UInt32;
  var layer_name : PAnsiChar := layer_props.properties.layerName;

  repeat
    result := vkEnumerateDeviceExtensionProperties(info.gpus[0], layer_name, @device_extension_count, nil);
    if result <> VK_SUCCESS then exit;

    if (device_extension_count = 0) then
    begin
      exit(VK_SUCCESS);
    end;

    SetLength(layer_props.device_extensions, device_extension_count);
    var device_extensions := @layer_props.device_extensions[0];
    result := vkEnumerateDeviceExtensionProperties(info.gpus[0], layer_name, @device_extension_count, device_extensions);
  until (result <> VK_INCOMPLETE);

end;

(*
 * Return 1 (true) if all layer names specified in check_names
 * can be found in given layer properties.
 *)
function demo_check_layers(const layer_props : TArray<TLayerProperties>; const layer_names : TArray<AnsiString>) : TVkBool32;
begin
  var check_count := Length(layer_names);
  var layer_count := Length(layer_props);

  for var i := 0 to check_count-1 do
  begin
    var found : TVkBool32 := 0;
    for var j := 0 to layer_count-1 do
    begin
      if (layer_names[i] = layer_props[j].properties.layerName) then
      begin
        found := 1;
      end;
    end;
    if found = 0 then
    begin
      Log('Cannot find layer: ' + string(layer_names[i]));
      exit(0);
    end;
  end;
  result := 1;
end;

procedure init_instance_extension_names(var info : TVulkanSampleInfo);
begin
  info.instance_extension_names := info.instance_extension_names + [VK_KHR_SURFACE_EXTENSION_NAME];
{$if Defined(DEBUG)}// and not Defined(MACOS)}
  info.instance_extension_names := info.instance_extension_names + [VK_EXT_DEBUG_REPORT_EXTENSION_NAME];
{$endif}

{$ifdef ANDROID}
  info.instance_extension_names := info.instance_extension_names + [VK_KHR_ANDROID_SURFACE_EXTENSION_NAME];
{$elseif Defined(MSWINDOWS)}
  info.instance_extension_names := info.instance_extension_names + [VK_KHR_WIN32_SURFACE_EXTENSION_NAME];
{$elseif Defined(VK_USE_PLATFORM_METAL_EXT)}
  info.instance_extension_names := info.instance_extension_names + [VK_EXT_METAL_SURFACE_EXTENSION_NAME];
{$elseif Defined(VK_USE_PLATFORM_WAYLAND_KHR)}
  info.instance_extension_names := info.instance_extension_names + [VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME];
{$else}
  info.instance_extension_names := info.instance_extension_names + [VK_KHR_XCB_SURFACE_EXTENSION_NAME];
{$endif}
end;

function init_instance(var info : TVulkanSampleInfo; const app_short_name : AnsiString) : TVkResult;
begin
  var app_info := Default(TVkApplicationInfo);
  app_info.sType := VK_STRUCTURE_TYPE_APPLICATION_INFO;
  app_info.pNext := nil;
  app_info.pApplicationName := PAnsiChar(app_short_name);
  app_info.applicationVersion := 1;
  app_info.pEngineName := PAnsiChar(app_short_name);
  app_info.engineVersion := 1;
  app_info.apiVersion := VK_API_VERSION_1_1;

  var inst_info := Default(TVkInstanceCreateInfo);
  inst_info.sType := VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
  inst_info.pNext := nil;
  inst_info.flags := 0;
  inst_info.pApplicationInfo := @app_info;
  inst_info.enabledLayerCount := Length(info.instance_layer_names);
  if Length(info.instance_layer_names) > 0 then
    inst_info.ppEnabledLayerNames := @info.instance_layer_names[0]
  else
    inst_info.ppEnabledLayerNames := nil;

  inst_info.enabledExtensionCount := Length(info.instance_extension_names);
  inst_info.ppEnabledExtensionNames := @info.instance_extension_names[0];

  result := vkCreateInstance(@inst_info, nil, @info.inst);
//  showmessage(inttostr(ord(result)));
  Assert(result = VK_SUCCESS);
end;

procedure init_device_extension_names(var info : TVulkanSampleInfo);
begin
  info.device_extension_names := info.device_extension_names + [VK_KHR_SWAPCHAIN_EXTENSION_NAME];
end;

function init_device(var info : TVulkanSampleInfo) : TVkResult;
begin
  var queue_info := Default(TVkDeviceQueueCreateInfo);
  var queue_priorities : TVkFloat := 0.0;
  queue_info.sType := VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
  queue_info.pNext := nil;
  queue_info.queueCount := 1;
  queue_info.pQueuePriorities := @queue_priorities;
  queue_info.queueFamilyIndex := info.graphics_queue_family_index;

  var device_info := Default(TVkDeviceCreateInfo);
  device_info.sType := VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
  device_info.pNext := nil;
  device_info.queueCreateInfoCount := 1;
  device_info.pQueueCreateInfos := @queue_info;
  device_info.enabledExtensionCount := Length(info.device_extension_names);
  if device_info.enabledExtensionCount > 0 then
    device_info.ppEnabledExtensionNames := @info.device_extension_names[0]
  else
    device_info.ppEnabledExtensionNames := nil;

  device_info.pEnabledFeatures := nil;

  result := vkCreateDevice(info.gpus[0], @device_info, nil, @info.device);
  Assert(result = VK_SUCCESS);
end;

function init_enumerate_device(var info : TVulkanSampleInfo; gpu_count : UInt32) : TVkResult;
begin
  const req_count = gpu_count;

  result := vkEnumeratePhysicalDevices(info.inst, @gpu_count, nil);
  Assert((result = VK_SUCCESS) and (gpu_count <> 0));
  SetLength(info.gpus, gpu_count);

  result := vkEnumeratePhysicalDevices(info.inst, @gpu_count, @info.gpus[0]);
  Assert((result = VK_SUCCESS) and (gpu_count >= req_count));

  vkGetPhysicalDeviceQueueFamilyProperties(info.gpus[0], @info.queue_family_count, nil);
  Assert(info.queue_family_count >= 1);

  SetLength(info.queue_props, info.queue_family_count);
  vkGetPhysicalDeviceQueueFamilyProperties(info.gpus[0], @info.queue_family_count, @info.queue_props[0]);
  Assert(info.queue_family_count >= 1);

  (* This is as good a place as any to do this *)
  vkGetPhysicalDeviceMemoryProperties(info.gpus[0], @info.memory_properties);
  vkGetPhysicalDeviceProperties(info.gpus[0], @info.gpu_props);
  (* query device extensions for enabled layers *)

  // for var layer_props in info.instance_layer_properties do
  for var i := 0 to Length(info.instance_layer_properties)-1 do
  begin
    init_device_extension_properties(info, info.instance_layer_properties[i]);
  end;
end;

procedure init_queue_family_index(var info : TVulkanSampleInfo);
begin
  (* This routine simply finds a graphics queue for a later vkCreateDevice,
   * without consideration for which queue family can present an image.
   * Do not use this if your intent is to present later in your sample,
   * instead use the init_connection, init_window, init_swapchain_extension,
   * init_device call sequence to get a graphics and present compatible queue
   * family
   *)

  vkGetPhysicalDeviceQueueFamilyProperties(info.gpus[0], @info.queue_family_count, nil);
  Assert(info.queue_family_count >= 1);

  SetLength(info.queue_props, info.queue_family_count);
  vkGetPhysicalDeviceQueueFamilyProperties(info.gpus[0], @info.queue_family_count, @info.queue_props[0]);
  Assert(info.queue_family_count >= 1);

  var found := false;
  for var i := 0 to info.queue_family_count-1 do
  begin
    if (info.queue_props[i].queueFlags and Ord(VK_QUEUE_GRAPHICS_BIT)) <> 0 then
    begin
      info.graphics_queue_family_index := i;
      found := true;
      break;
    end;
  end;
  Assert(found);
end;

function init_debug_report_callback(var info : TVulkanSampleInfo; dbgFunc : TPFN_vkDebugReportCallbackEXT) : TVkResult;
begin
  var debug_report_callback : TVkDebugReportCallbackEXT;

  info.dbgCreateDebugReportCallback := TvkCreateDebugReportCallbackEXT(vkGetInstanceProcAddr(info.inst, 'vkCreateDebugReportCallbackEXT'));
  if not Assigned(info.dbgCreateDebugReportCallback) then
  begin
    Log('GetInstanceProcAddr: Unable to find vkCreateDebugReportCallbackEXT function.');
    exit(VK_ERROR_INITIALIZATION_FAILED);
  end;

  Log('Got dbgCreateDebugReportCallback function');

  info.dbgDestroyDebugReportCallback := TvkDestroyDebugReportCallbackEXT(vkGetInstanceProcAddr(info.inst, 'vkDestroyDebugReportCallbackEXT'));
  if not Assigned(info.dbgDestroyDebugReportCallback) then
  begin
    Log('GetInstanceProcAddr: Unable to find vkDestroyDebugReportCallbackEXT function.');
    exit(VK_ERROR_INITIALIZATION_FAILED);
  end;
  Log('Got dbgDestroyDebugReportCallback function');

  var create_info := Default(TVkDebugReportCallbackCreateInfoEXT);
  create_info.sType := VK_STRUCTURE_TYPE_DEBUG_REPORT_CREATE_INFO_EXT;
  create_info.pNext := nil;
  create_info.flags := Ord(VK_DEBUG_REPORT_ERROR_BIT_EXT) or Ord(VK_DEBUG_REPORT_WARNING_BIT_EXT)
                       or Ord(VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT);// or Ord(VK_DEBUG_REPORT_INFORMATION_BIT_EXT);
  create_info.pfnCallback := dbgFunc;
  create_info.pUserData := nil;

  result := info.dbgCreateDebugReportCallback(info.inst, @create_info, nil, @debug_report_callback);
  case result of
  VK_SUCCESS:
    begin
      Log('Successfully created debug report callback object');
      info.debug_report_callbacks := info.debug_report_callbacks + [debug_report_callback];
    end;
  VK_ERROR_OUT_OF_HOST_MEMORY:
    begin
      Log('dbgCreateDebugReportCallback: out of host memory pointer');
      exit(VK_ERROR_INITIALIZATION_FAILED);
    end;
  else
    Log('dbgCreateDebugReportCallback: unknown failure');
    exit(VK_ERROR_INITIALIZATION_FAILED);
  end;
end;

procedure destroy_debug_report_callback(var info : TVulkanSampleInfo);
begin
  while (Length(info.debug_report_callbacks) > 0) do
  begin
    info.dbgDestroyDebugReportCallback(info.inst, info.debug_report_callbacks[Length(info.debug_report_callbacks)-1], nil);
    SetLength(info.debug_report_callbacks, Length(info.debug_report_callbacks)-1);
  end;
end;

{$if Defined(VK_USE_PLATFORM_WAYLAND_KHR)}

//staic funcs
procedure handle_ping(data : Pointer; shell_surface : Pwl_shell_surface; serial : UInt32);
begin
  wl_shell_surface_pong(shell_surface, serial);
end;

procedure handle_configure(data : Pointer; shell_surface : Pwl_shell_surface; edges : UInt32; width : UInt32; height : UInt32);
begin
end;

procedure handle_popup_done(data : Pointer; shell_surface : Pwl_shell_surface);
begin
end;

const shell_surface_listener : Twl_shell_surface_listener = (handle_ping, handle_configure, handle_popup_done);

procedure registry_handle_global(PRegistry : Twl_registry; id : UInt32; const interface_str : string; version : UInt32);
begin
  // pickup wayland objects when they appear
  if (interface_str = 'wl_compositor') then
  begin
    info.compositor = Pwl_compositor(wl_registry_bind(registry, id, @wl_compositor_interface, 1));
  end else if (interface_str = 'wl_shell') then
  begin
    info.shell = Pwl_shell(wl_registry_bind(registry, id, @wl_shell_interface, 1));
  end;
end;

static void registry_handle_global_remove(void *data, wl_registry *registry, uint32_t name) {}

static const wl_registry_listener registry_listener = {registry_handle_global, registry_handle_global_remove};

{$endif}

procedure init_connection(var info : TVulkanSampleInfo);
begin
{$if defined(VK_USE_PLATFORM_XCB_KHR)}
  var iter : Txcb_screen_iterator_t;
  var scr : integer;

  info.connection := xcb_connect(nil, @scr);
  if (info.connection = nil) or (xcb_connection_has_error(info.connection)) then
  begin
    RaiseError(-1, 'Unable to make an XCB connection');
  end;

  var setup := xcb_get_setup(info.connection);
  iter := xcb_setup_roots_iterator(setup);
  while (scr > 0) do
  begin
    xcb_screen_next(@iter);
    Dec(scr);
  end;

  info.screen := iter.data;
{$elseif defined(VK_USE_PLATFORM_WAYLAND_KHR)}
  info.display := wl_display_connect(nil);

  if (info.display = nil) then
  begin
     RaiseError(1, 'Cannot find a compatible Vulkan installable client driver '
          '(ICD).\nExiting ...\n');
//      fflush(stdout);
  end;

  info.registry = wl_display_get_registry(info.display);
  wl_registry_add_listener(info.registry, &registry_listener, &info);
  wl_display_dispatch(info.display);
{$endif}
end;

{$ifdef MSWINDOWS}
function run(var info : TVulkanSampleInfo) : Boolean;
begin (* Placeholder for samples that want to show dynamic content *)
end;

// MS-Windows event handling function:
function WndProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  var info := PVulkanSampleInfo(GetWindowLongPtr(hWnd, GWLP_USERDATA));

  case (uMsg) of
  WM_CLOSE:
    PostQuitMessage(0);
  WM_PAINT:
    begin
      run(info^);
      exit(0);
    end;
  else
  end;
  result := (DefWindowProc(hWnd, uMsg, wParam, lParam));
end;

procedure init_window(var info : TVulkanSampleInfo; NativeHandle : NativeUInt);
begin
  var win_class : WNDCLASSEX;
  info.connection := GetModuleHandle(nil);
  info.name := 'Sample';

  if NativeHandle = 0 then
  begin
    Assert(info.width > 0);
    Assert(info.height > 0);

    // Initialize the window class structure:
    win_class.cbSize := sizeof(WNDCLASSEX);
    win_class.style := CS_HREDRAW or CS_VREDRAW;
    win_class.lpfnWndProc := @WndProc;
    win_class.cbClsExtra := 0;
    win_class.cbWndExtra := 0;
    win_class.hInstance := info.connection;  // hInstance
    win_class.hIcon := LoadIcon(0, IDI_APPLICATION);
    win_class.hCursor := LoadCursor(0, IDC_ARROW);
    win_class.hbrBackground := HBRUSH(GetStockObject(WHITE_BRUSH));
    win_class.lpszMenuName := nil;
    win_class.lpszClassName := PWideChar(info.Name);
    win_class.hIconSm := LoadIcon(0, IDI_WINLOGO);
    // Register window class:
    if RegisterClassEx(win_class) = 0 then
    begin
      // It didn't work, so try to give a useful error:
      RaiseError(1, 'Unexpected error trying to start the application!');
     //flush(stdout);
    end;
    // Create window with the registered class:
    var wr : TRect := Rect(0, 0, info.width, info.height);
    AdjustWindowRect(wr, WS_OVERLAPPEDWINDOW, FALSE);
    info.window := CreateWindowEx(0,
                                 PWideChar(info.name),  // class name
                                 PWideChar(info.name),  // app name
                                 WS_OVERLAPPEDWINDOW or // window style
                                     WS_VISIBLE or WS_SYSMENU,
                                 100, 100,            // x/y coords
                                 wr.right - wr.left,  // width
                                 wr.bottom - wr.top,  // height
                                 0,                   // handle to parent
                                 0,                   // handle to menu
                                 info.connection,     // hInstance
                                 nil);                // no extra parameters
    if info.window = 0 then
    begin
        // It didn't work, so try to give a useful error:
        RaiseError(1, 'Cannot create a window in which to draw!');
    end;
  end else begin
    info.Window := HWND(NativeHandle);
  end;
 SetWindowLongPtr(info.window, GWLP_USERDATA, LONG_PTR(@info));
end;

procedure destroy_window(var info : TVulkanSampleInfo);
begin
  vkDestroySurfaceKHR(info.inst, info.surface, nil);
  DestroyWindow(info.window);
end;

{$elseif Defined(VK_USE_PLATFORM_METAL_EXT)}

// iOS & macOS: init_window() implemented externally to allow access to Objective-C components

procedure destroy_window(var info : TVulkanSampleInfo);
begin
  info.MetalLayer := nil;
end;

type
 TCAMetalLayer = class(TOCGenericImport<CAMetalLayerClass, CAMetalLayer>)
 end;

procedure init_window(var info : TVulkanSampleInfo; NativeHandle : NativeUInt);
begin
  var view := NSView(NativeHandle);
  var layer := TCAMetalLayer.OCClass.layer;
  view.setLayer(TCALayer.Wrap(layer));

  info.MetalLayer := layer;
end;

{$elseif Defined(ANDROID)}
// Android implementation.
procedure init_window(var info : TVulkanSampleInfo; NativeHandle : NativeUInt);
begin
end;

procedure destroy_window(var info : TVulkanSampleInfo);
begin
end;

{$elseif Defined(VK_USE_PLATFORM_WAYLAND_KHR)}

procedure init_window(var info : TVulkanSampleInfo; NativeHandle : NativeUInt);
begin
  Assert(info.width > 0);
  Assert(info.height > 0);

  info.window := wl_compositor_create_surface(info.compositor);
  if info.window = 0 then
  begin
    RaiseError(1, 'Can not create wayland_surface from compositor!');
  end;

  info.shell_surface := wl_shell_get_shell_surface(info.shell, info.window);
  if info.shell_surface = 0 then
  begin
    RaiseError(1, 'Can not get shell_surface from wayland_surface!');
  end;

  wl_shell_surface_add_listener(info.shell_surface, @shell_surface_listener, @info);
  wl_shell_surface_set_toplevel(info.shell_surface);
end;

procedure destroy_window();
begin
  wl_shell_surface_destroy(info.shell_surface);
  wl_surface_destroy(info.window);
  wl_shell_destroy(info.shell);
  wl_compositor_destroy(info.compositor);
  wl_registry_destroy(info.registry);
  wl_display_disconnect(info.display);
end;

{$else}

procedure init_window(var info : TVulkanSampleInfo; NativeHandle : NativeUInt);
var
  value_list : array of [0..31] of UInt32;
const
  coords : array of UInt32 := (100, 100);
begin
  Assert(info.width > 0);
  Assert(info.height > 0);

  var value_mask : UInt32;

  info.window =: xcb_generate_id(info.connection);

  value_mask := XCB_CW_BACK_PIXEL or XCB_CW_EVENT_MASK;
  value_list[0] := info.screen->black_pixel;
  value_list[1] := XCB_EVENT_MASK_KEY_RELEASE or XCB_EVENT_MASK_EXPOSURE;

  xcb_create_window(info.connection, XCB_COPY_FROM_PARENT, info.window, info.screen^.root, 0, 0, info.width, info.height, 0,
                    XCB_WINDOW_CLASS_INPUT_OUTPUT, info.screen^.root_visual, value_mask, value_list);

  (* Magic code that will send notification when window is destroyed *)
  var cookie : Txcb_intern_atom_cookie_t := xcb_intern_atom(info.connection, 1, 12, 'WM_PROTOCOLS');
  var reply : Pxcb_intern_atom_reply_t := xcb_intern_atom_reply(info.connection, cookie, 0);

  var cookie2 : Txcb_intern_atom_cookie_t  := xcb_intern_atom(info.connection, 0, 16, 'WM_DELETE_WINDOW');
  info.atom_wm_delete_window = xcb_intern_atom_reply(info.connection, cookie2, 0);

  xcb_change_property(info.connection, XCB_PROP_MODE_REPLACE, info.window, reply^.atom, 4, 32, 1,
                      @(info.atom_wm_delete_window^.atom));
  free(reply);

  xcb_map_window(info.connection, info.window);

  // Force the x/y coordinates to 100,100 results are identical in consecutive
  // runs
  xcb_configure_window(info.connection, info.window, XCB_CONFIG_WINDOW_X or XCB_CONFIG_WINDOW_Y, coords);
  xcb_flush(info.connection);

  var e := xcb_wait_for_event(info.connection);
  while (e <> nil) do
  begin
    if ((e^.sponse_type and $7F) = XCB_EXPOSE) then break;
    e := xcb_wait_for_event(info.connection);
  end;
end;

procedure destroy_window();
begin
  vkDestroySurfaceKHR(info.inst, info.surface, nil);
  xcb_destroy_window(info.connection, info.window);
  xcb_disconnect(info.connection);
end;

{$endif}  // _WIN32

procedure init_window_size(var info : TVulkanSampleInfo; default_width, default_height : UInt32);
begin
{$ifdef ANDROID}
  AndroidGetWindowSize(@info.width, @info.height);
{$else}
  info.width := default_width;
  info.height := default_height;
{$endif}
end;

procedure init_depth_buffer(var info : TVulkanSampleInfo);
begin
  var image_info := Default(TVkImageCreateInfo);
  var props : TVkFormatProperties;

  (* allow custom depth formats *)
{$ifdef ANDROID}
  // Depth format needs to be VK_FORMAT_D24_UNORM_S8_UINT on Android (if available).
  vkGetPhysicalDeviceFormatProperties(info.gpus[0], VK_FORMAT_D24_UNORM_S8_UINT, @props);
  if ((props.linearTilingFeatures and VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT) or
      (props.optimalTilingFeatures and VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT))
    info.depth.format = VK_FORMAT_D24_UNORM_S8_UINT
  else
    info.depth.format = VK_FORMAT_D16_UNORM;

{$elseif Defined(VK_USE_PLATFORM_IOS_MVK)}
  if (info.Depth.format = VK_FORMAT_UNDEFINED) then info.Depth.format := VK_FORMAT_D32_SFLOAT;
{$else}
  if (info.Depth.format = VK_FORMAT_UNDEFINED) then info.Depth.format := VK_FORMAT_D16_UNORM;
{$endif}

  const depth_format = info.depth.format;
  vkGetPhysicalDeviceFormatProperties(info.gpus[0], depth_format, @props);

  if (props.linearTilingFeatures and Ord(VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT)) <> 0 then
  begin
    image_info.tiling := VK_IMAGE_TILING_LINEAR;
  end else if (props.optimalTilingFeatures and Ord(VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT)) <> 0 then
  begin
    image_info.tiling := VK_IMAGE_TILING_OPTIMAL;
  end else begin
    (* Try other depth formats? *)
    RaiseError(-1, 'depth_format ' +IntToStr(Ord(depth_format)) + ' Unsupported.');
  end;

  image_info.sType := VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO;
  image_info.pNext := nil;
  image_info.imageType := VK_IMAGE_TYPE_2D;
  image_info.format := depth_format;
  image_info.extent.width := info.width;
  image_info.extent.height := info.height;
  image_info.extent.depth := 1;
  image_info.mipLevels := 1;
  image_info.arrayLayers := 1;
  image_info.samples := NUM_SAMPLES;
  image_info.initialLayout := VK_IMAGE_LAYOUT_UNDEFINED;
  image_info.queueFamilyIndexCount := 0;
  image_info.pQueueFamilyIndices := nil;
  image_info.sharingMode := VK_SHARING_MODE_EXCLUSIVE;
  image_info.usage := Ord(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT);
  image_info.flags := 0;

  var mem_alloc := Default(TVkMemoryAllocateInfo);
  mem_alloc.sType := VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
  mem_alloc.pNext := nil;
  mem_alloc.allocationSize := 0;
  mem_alloc.memoryTypeIndex := 0;

  var view_info := Default(TVkImageViewCreateInfo);
  view_info.sType := VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
  view_info.pNext := nil;
  view_info.image := VK_NULL_HANDLE;
  view_info.format := depth_format;
  view_info.components.r := VK_COMPONENT_SWIZZLE_R;  // diff: demo.c
  view_info.components.g := VK_COMPONENT_SWIZZLE_G;  // diff: demo.c
  view_info.components.b := VK_COMPONENT_SWIZZLE_B;  // diff: demo.c
  view_info.components.a := VK_COMPONENT_SWIZZLE_A;  // diff: demo.c
  view_info.subresourceRange.aspectMask := Ord(VK_IMAGE_ASPECT_DEPTH_BIT);
  view_info.subresourceRange.baseMipLevel := 0;
  view_info.subresourceRange.levelCount := 1;
  view_info.subresourceRange.baseArrayLayer := 0;
  view_info.subresourceRange.layerCount := 1;
  view_info.viewType := VK_IMAGE_VIEW_TYPE_2D;
  view_info.flags := 0;

  if (depth_format = VK_FORMAT_D16_UNORM_S8_UINT) or (depth_format = VK_FORMAT_D24_UNORM_S8_UINT) or
     (depth_format = VK_FORMAT_D32_SFLOAT_S8_UINT) then
  begin
    view_info.subresourceRange.aspectMask := view_info.subresourceRange.aspectMask or Ord(VK_IMAGE_ASPECT_STENCIL_BIT);
  end;

  var mem_reqs : TVkMemoryRequirements;

  (* Create image *)
  var result := vkCreateImage(info.device, @image_info, nil, @info.Depth.image);
  Assert(result = VK_SUCCESS);

  vkGetImageMemoryRequirements(info.device, info.depth.image, @mem_reqs);

  mem_alloc.allocationSize := mem_reqs.size;
  (* Use the memory properties to determine the type of memory required *)
  var pass := memory_type_from_properties(info, mem_reqs.memoryTypeBits, Ord(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT), mem_alloc.memoryTypeIndex);
  Assert(pass);

  (* Allocate memory *)
  result := vkAllocateMemory(info.device, @mem_alloc, nil, @info.depth.mem);
  Assert(result = VK_SUCCESS);

  (* Bind memory *)
  result := vkBindImageMemory(info.device, info.depth.image, info.depth.mem, 0);
  Assert(result = VK_SUCCESS);

  (* Create image view *)
  view_info.image := info.depth.image;
  result := vkCreateImageView(info.device, @view_info, nil, @info.depth.view);
  Assert(result = VK_SUCCESS);
end;

(* Use this surface format if it's available.  This ensures that generated
* images are similar on different devices and with different drivers.
*)
const PREFERRED_SURFACE_FORMAT = VK_FORMAT_B8G8R8A8_UNORM;

//  init_swapchain_extensionから分離
procedure init_surface(var info : TVulkanSampleInfo);
begin
  var result : TVkResult;
{$ifdef MSWINDOWS}
  var createInfo := Default(TVkWin32SurfaceCreateInfoKHR);
  createInfo.sType := VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
  createInfo.pNext := nil;
  createInfo.hinstance_ := info.connection;
  createInfo.hwnd_ := info.window;
  result := vkCreateWin32SurfaceKHR(info.inst, @createInfo, nil, @info.surface);
{$elseif Defined(ANDROID)}
  GET_INSTANCE_PROC_ADDR(info.inst, CreateAndroidSurfaceKHR);

  var createInfo := Default(TVkAndroidSurfaceCreateInfoKHR);
  createInfo.sType := VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR;
  createInfo.pNext := nil;
  createInfo.flags := 0;
  createInfo.window := AndroidGetApplicationWindow();
  result := info.fpCreateAndroidSurfaceKHR(info.inst, @createInfo, nil, @info.surface);
{$elseif Defined(VK_USE_PLATFORM_METAL_EXT)}
  var createInfo := Default(TVkMetalSurfaceCreateInfoEXT);
  createInfo.sType := VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT;
  createInfo.pNext := nil;
  createInfo.flags := 0;
  createInfo.pLayer := info.MetalLayer;
  result := vkCreateMetalSurfaceEXT(info.inst, @createInfo, nil, @info.surface);
{$elseif Defined(VK_USE_PLATFORM_WAYLAND_KHR)}
  var createInfo := Default(TVkWaylandSurfaceCreateInfoKHR);
  createInfo.sType := VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR;
  createInfo.pNext := nil;
  createInfo.display := info.display;
  createInfo.surface := info.window;
  result = vkCreateWaylandSurfaceKHR(info.inst, @createInfo, nil, @info.surface);
{$else}
  var createInfo := Default(TVkXcbSurfaceCreateInfoKHR);
  createInfo.sType := VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR;
  createInfo.pNext := nil;
  createInfo.connection = info.connection;
  createInfo.window := info.window;
  result = vkCreateXcbSurfaceKHR(info.inst, @createInfo, nil, @info.surface);
{$endif}  // __ANDROID__  && _WIN32
  Assert(result = VK_SUCCESS);
end;

procedure init_swapchain_extension(var info : TVulkanSampleInfo);
begin
  (* DEPENDS on init_connection() and init_window() *)

  var result : TVkResult;

// Construct the surface description:
  init_surface(info);

  // Iterate over each queue to learn whether it supports presenting:
  var SupportsPresent : TArray<TVkBool32>;
  SetLength(SupportsPresent, info.queue_family_count);
  for var i := 0 to info.queue_family_count-1 do
  begin
    vkGetPhysicalDeviceSurfaceSupportKHR(info.gpus[0], i, info.surface, @SupportsPresent[i]);
  end;

  // Search for a graphics and a present queue in the array of queue
  // families, try to find one that supports both
  const UINT32_MAX = $ffffffff;
  info.graphics_queue_family_index := UINT32_MAX;
  info.present_queue_family_index := UINT32_MAX;
  for var i := 0 to info.queue_family_count-1 do
  begin
    if ((info.queue_props[i].queueFlags and Ord(VK_QUEUE_GRAPHICS_BIT)) <> 0) then
    begin
      if (info.graphics_queue_family_index = UINT32_MAX) then info.graphics_queue_family_index := i;

      if (SupportsPresent[i] = VK_TRUE) then
      begin
        info.graphics_queue_family_index := i;
        info.present_queue_family_index := i;
        break;
      end;
    end;
  end;

  if (info.present_queue_family_index = UINT32_MAX) then
  begin
    // If didn't find a queue that supports both graphics and present, then
    // find a separate present queue.
    for var i := 0 to info.queue_family_count-1 do
    begin
      if (SupportsPresent[i] = VK_TRUE) then
      begin
        info.present_queue_family_index := i;
        break;
      end;
    end;
  end;
  SupportsPresent := nil;

  // Generate error if could not find queues that support graphics
  // and present
  if (info.graphics_queue_family_index = UINT32_MAX) or (info.present_queue_family_index = UINT32_MAX) then
  begin
    RaiseError(-1, 'Could not find a queues for both graphics and present');
  end;

  // Get the list of VkFormats that are supported:
  var formatCount : UInt32;
  result := vkGetPhysicalDeviceSurfaceFormatsKHR(info.gpus[0], info.surface, @formatCount, nil);
  Assert(result = VK_SUCCESS);
  var surfFormats : TArray<TVkSurfaceFormatKHR>;
  SetLength(surfFormats, formatCount);
  result := vkGetPhysicalDeviceSurfaceFormatsKHR(info.gpus[0], info.surface, @formatCount, @surfFormats[0]);
  Assert(result = VK_SUCCESS);

  // If the device supports our preferred surface format, use it.
  // Otherwise, use whatever the device's first reported surface
  // format is.
  Assert(formatCount >= 1);
  info.format := surfFormats[0].format;
  for var i := 0 to formatCount-1 do
  begin
    if (surfFormats[i].format = PREFERRED_SURFACE_FORMAT) then
    begin
      info.format := PREFERRED_SURFACE_FORMAT;
      break;
    end;
  end;

  surfFormats := nil;
end;

procedure init_presentable_image(var info : TVulkanSampleInfo);
begin
  (* DEPENDS on init_swap_chain() *)

  var imageAcquiredSemaphoreCreateInfo : TVkSemaphoreCreateInfo ;
  imageAcquiredSemaphoreCreateInfo.sType := VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;
  imageAcquiredSemaphoreCreateInfo.pNext := nil;
  imageAcquiredSemaphoreCreateInfo.flags := 0;

  var result := vkCreateSemaphore(info.device, @imageAcquiredSemaphoreCreateInfo, nil, @info.imageAcquiredSemaphore);
  Assert(result = VK_SUCCESS);

  // Get the index of the next available swapchain image:
  result := vkAcquireNextImageKHR(info.device, info.swap_chain, UInt64($ffffffffffffffff), info.imageAcquiredSemaphore, VK_NULL_HANDLE,
                              @info.current_buffer);
  // TODO: Deal with the VK_SUBOPTIMAL_KHR and VK_ERROR_OUT_OF_DATE_KHR
  // return codes
  Assert(result = VK_SUCCESS);
end;

procedure execute_queue_cmdbuf(var info : TVulkanSampleInfo; const cmd_bufs : PVkCommandBuffer; var fence : TVkFence);
var
  submit_info : array [0..0] of TVkSubmitInfo;
begin
  var pipe_stage_flags : TVkPipelineStageFlags  := Ord(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
  submit_info[0] := Default(TVkSubmitInfo);
  submit_info[0].pNext := nil;
  submit_info[0].sType := VK_STRUCTURE_TYPE_SUBMIT_INFO;
  submit_info[0].waitSemaphoreCount := 1;
  submit_info[0].pWaitSemaphores := @info.imageAcquiredSemaphore;
  submit_info[0].pWaitDstStageMask := nil;
  submit_info[0].commandBufferCount := 1;
  submit_info[0].pCommandBuffers := cmd_bufs;
  submit_info[0].pWaitDstStageMask := @pipe_stage_flags;
  submit_info[0].signalSemaphoreCount := 0;
  submit_info[0].pSignalSemaphores := nil;

  (* Queue the command buffer for execution *)
  var result := vkQueueSubmit(info.graphics_queue, 1, @submit_info[0], fence);
  Assert(result = VK_SUCCESS);
end;

procedure execute_pre_present_barrier(var info : TVulkanSampleInfo);
begin
  (* DEPENDS on init_swap_chain() *)
  (* Add mem barrier to change layout to present *)

  var prePresentBarrier := Default(TVkImageMemoryBarrier);
  prePresentBarrier.sType := VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  prePresentBarrier.pNext := nil;
  prePresentBarrier.srcAccessMask := Ord(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
  prePresentBarrier.dstAccessMask := Ord(VK_ACCESS_MEMORY_READ_BIT);
  prePresentBarrier.oldLayout := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
  prePresentBarrier.newLayout := VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
  prePresentBarrier.srcQueueFamilyIndex := VK_QUEUE_FAMILY_IGNORED;
  prePresentBarrier.dstQueueFamilyIndex := VK_QUEUE_FAMILY_IGNORED;
  prePresentBarrier.subresourceRange.aspectMask := Ord(VK_IMAGE_ASPECT_COLOR_BIT);
  prePresentBarrier.subresourceRange.baseMipLevel := 0;
  prePresentBarrier.subresourceRange.levelCount := 1;
  prePresentBarrier.subresourceRange.baseArrayLayer := 0;
  prePresentBarrier.subresourceRange.layerCount := 1;
  prePresentBarrier.image := info.buffers[info.current_buffer].image;
  vkCmdPipelineBarrier(info.cmd, Ord(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT), Ord(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT), 0, 0, nil,
                       0, nil, 1, @prePresentBarrier);
end;

procedure execute_present_image(var info : TVulkanSampleInfo);
begin
  (* DEPENDS on init_presentable_image() and init_swap_chain()*)
  (* Present the image in the window *)

  var present : TVkPresentInfoKHR;
  present.sType := VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
  present.pNext := nil;
  present.swapchainCount := 1;
  present.pSwapchains := @info.swap_chain;
  present.pImageIndices := @info.current_buffer;
  present.pWaitSemaphores := nil;
  present.waitSemaphoreCount := 0;
  present.pResults := nil;

  var result := vkQueuePresentKHR(info.present_queue, @present);
  // TODO: Deal with the VK_SUBOPTIMAL_WSI and VK_ERROR_OUT_OF_DATE_WSI
  // return codes
  Assert(result = VK_SUCCESS);
end;

procedure init_swap_chain(var info : TVulkanSampleInfo; usageFlags : TVkImageUsageFlags; NumOfSwapchain : UInt32);
begin
  (* DEPENDS on info.cmd and info.queue initialized *)

  var surfCapabilities : TVkSurfaceCapabilitiesKHR;

  var result := vkGetPhysicalDeviceSurfaceCapabilitiesKHR(info.gpus[0], info.surface, @surfCapabilities);
  Assert(result = VK_SUCCESS);

  var presentModeCount : UInt32;
  result := vkGetPhysicalDeviceSurfacePresentModesKHR(info.gpus[0], info.surface, @presentModeCount, nil);
  Assert(result = VK_SUCCESS);
  var presentModes : TArray<TVkPresentModeKHR>;
  SetLength(presentModes, presentModeCount);
  Assert(presentModes <> nil);
  result := vkGetPhysicalDeviceSurfacePresentModesKHR(info.gpus[0], info.surface, @presentModeCount, @presentModes[0]);
  Assert(result = VK_SUCCESS);

  var swapchainExtent : TVkExtent2D;
  // width and height are either both 0xFFFFFFFF, or both not 0xFFFFFFFF.
  if (surfCapabilities.currentExtent.width = $FFFFFFFF) then
  begin
    // If the surface size is undefined, the size is set to
    // the size of the images requested.
    swapchainExtent.width := info.width;
    swapchainExtent.height := info.height;
    if (swapchainExtent.width < surfCapabilities.minImageExtent.width) then
    begin
      swapchainExtent.width := surfCapabilities.minImageExtent.width;
    end else if (swapchainExtent.width > surfCapabilities.maxImageExtent.width) then
    begin
      swapchainExtent.width := surfCapabilities.maxImageExtent.width;
    end;

    if (swapchainExtent.height < surfCapabilities.minImageExtent.height) then
    begin
      swapchainExtent.height := surfCapabilities.minImageExtent.height;
    end else if (swapchainExtent.height > surfCapabilities.maxImageExtent.height) then
    begin
      swapchainExtent.height := surfCapabilities.maxImageExtent.height;
    end;
  end else begin
    // If the surface size is defined, the swap chain size must match
    swapchainExtent := surfCapabilities.currentExtent;
  end;

  // The FIFO present mode is guaranteed by the spec to be supported
  // Also note that current Android driver only supports FIFO
  var swapchainPresentMode := VK_PRESENT_MODE_FIFO_KHR;

  // Determine the number of VkImage's to use in the swap chain.
  // We need to acquire only 1 presentable image at at time.
  // Asking for minImageCount images ensures that we can acquire
  // 1 presentable image as long as we present it before attempting
  // to acquire another.
  var desiredNumberOfSwapChainImages := NumOfSwapchain;
  if desiredNumberOfSwapChainImages < surfCapabilities.minImageCount then // from demo.c
  begin
    desiredNumberOfSwapChainImages := surfCapabilities.minImageCount;
  end;

  var preTransform : TVkSurfaceTransformFlagBitsKHR;
  if (surfCapabilities.supportedTransforms and Ord(VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR)) <> 0 then
  begin
    preTransform := VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
  end else begin
    preTransform := surfCapabilities.currentTransform;
  end;

  // Find a supported composite alpha mode - one of these is guaranteed to be set
  var compositeAlpha : TVkCompositeAlphaFlagBitsKHR := VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
  var compositeAlphaFlags := [// Sampleと見比べやすくするために動的配列を使ってここで初期化しているが静的配列で良い
      VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
      VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR,
      VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR,
      VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR
  ];
  for var i := 0 to HIGH(compositeAlphaFlags) do
  begin
    if (surfCapabilities.supportedCompositeAlpha and Ord(compositeAlphaFlags[i])) <> 0 then
    begin
      compositeAlpha := compositeAlphaFlags[i];
      break;
    end;
  end;

  var oldSwapChain := info.Swap_chain;

  var swapchain_ci := Default(TVkSwapchainCreateInfoKHR);
  swapchain_ci.sType := VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
  swapchain_ci.pNext := nil;
  swapchain_ci.surface := info.surface;
  swapchain_ci.minImageCount := desiredNumberOfSwapChainImages;
  swapchain_ci.imageFormat := info.format;
  swapchain_ci.imageExtent.width := swapchainExtent.width;
  swapchain_ci.imageExtent.height := swapchainExtent.height;
  swapchain_ci.preTransform := preTransform;
  swapchain_ci.compositeAlpha := compositeAlpha;
  swapchain_ci.imageArrayLayers := 1;
  swapchain_ci.presentMode := swapchainPresentMode;
  swapchain_ci.oldSwapchain := oldSwapChain; {VK_NULL_HANDLE}; // diff: demo.c
{$ifndef ANDROID}
  swapchain_ci.clipped := 1{true};
{$else}
  swapchain_ci.clipped := 0{false};
{$endif}
  swapchain_ci.imageColorSpace := VK_COLORSPACE_SRGB_NONLINEAR_KHR;
  swapchain_ci.imageUsage := usageFlags;
  swapchain_ci.imageSharingMode := VK_SHARING_MODE_EXCLUSIVE;
  swapchain_ci.queueFamilyIndexCount := 0;
  swapchain_ci.pQueueFamilyIndices := nil;
  // diff: demo.c
  var queueFamilyIndices := [ UInt32(info.graphics_queue_family_index), UInt32(info.present_queue_family_index) ];
  if (info.graphics_queue_family_index <> info.present_queue_family_index) then
  begin
    // If the graphics and present queues are from different queue families,
    // we either have to explicitly transfer ownership of images between the
    // queues, or we have to create the swapchain with imageSharingMode
    // as VK_SHARING_MODE_CONCURRENT
    swapchain_ci.imageSharingMode := VK_SHARING_MODE_CONCURRENT;
    swapchain_ci.queueFamilyIndexCount := 2;
    swapchain_ci.pQueueFamilyIndices := @queueFamilyIndices[0];
  end;

  result := vkCreateSwapchainKHR(info.device, @swapchain_ci, nil, @info.swap_chain);
  Assert(result = VK_SUCCESS);

  // diff: demo.c  destroy old swapchain
  if oldSwapChain <> VK_NULL_HANDLE then
  begin
    vkDestroySwapchainKHR(info.Device, oldSwapChain, nil);
  end;

  result := vkGetSwapchainImagesKHR(info.device, info.swap_chain, @info.swapchainImageCount, nil);
  Assert(result = VK_SUCCESS, IntToStr(Ord(result)));

  var swapchainImages : TArray<TVkImage>;
  SetLength(swapchainImages, info.swapchainImageCount);
  Assert(swapchainImages <> nil);
  result := vkGetSwapchainImagesKHR(info.device, info.swap_chain, @info.swapchainImageCount, @swapchainImages[0]);
  Assert(result = VK_SUCCESS);

  for var i := 0 to info.swapchainImageCount-1 do
  begin
    var sc_buffer := Default(TSwap_chain_buffer);

    var color_image_view := Default(TVkImageViewCreateInfo);
    color_image_view.sType := VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
    color_image_view.pNext := nil;
    color_image_view.format := info.format;
    color_image_view.components.r := VK_COMPONENT_SWIZZLE_R;
    color_image_view.components.g := VK_COMPONENT_SWIZZLE_G;
    color_image_view.components.b := VK_COMPONENT_SWIZZLE_B;
    color_image_view.components.a := VK_COMPONENT_SWIZZLE_A;
    color_image_view.subresourceRange.aspectMask := Ord(VK_IMAGE_ASPECT_COLOR_BIT);
    color_image_view.subresourceRange.baseMipLevel := 0;
    color_image_view.subresourceRange.levelCount := 1;
    color_image_view.subresourceRange.baseArrayLayer := 0;
    color_image_view.subresourceRange.layerCount := 1;
    color_image_view.viewType := VK_IMAGE_VIEW_TYPE_2D;
    color_image_view.flags := 0;

    sc_buffer.image := swapchainImages[i];

    color_image_view.image := sc_buffer.image;

    result := vkCreateImageView(info.device, @color_image_view, nil, @sc_buffer.view);
    info.buffers := info.buffers + [sc_buffer];
    Assert(result = VK_SUCCESS);
  end;
  swapchainImages := nil;

  info.current_buffer := 0;

  presentModes := nil;
end;

procedure init_uniform_buffer(var info : TVulkanSampleInfo);
begin
  var result : TVkResult;
  var pass : Boolean;

  var fov := PI*45.0/180;
  var horizontal := info.width < info.height;
  var ratio := Single(info.width)/Single(info.height);

  if (horizontal) then
  begin
    ratio := Single(info.height)/Single(info.width);
  end;


  info.Projection := TMatrix3D.CreatePerspectiveFovLH(fov, ratio, 0.1, 100.0, horizontal);
  info.View := TMatrix3D.CreateLookAtLH(TPoint3D.Create(0, 3, 5), // Camera is at (-5,3,-10), in World Space
                                        TPoint3D.Create(0, 0, 0),     // and looks at the origin
                                        TPoint3D.Create(0, 1, 0)     // Head is up (set to 0,-1,0 to look upside-down)
  );
//  info.Model := TMatrix3D.Create(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1); // -> Move to  application code
  // Vulkan clip space has inverted Y and half Z.
  info.Clip := TMatrix3D.Create(1,0,0,0, 0,-1,0,0, 0,0,0.5,0, 0,0,0.5, 1);

//  info.MVP := info.Clip * info.Projection * info.View * info.Model;
  info.MVP := info.Model * info.View  * info.Projection * info.Clip ;
  var Mtrx := [info.MVP, info.Model.Inverse];

  (* VULKAN_KEY_START *)
  var buf_info := Default(TVkBufferCreateInfo);
  buf_info.sType := VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
  buf_info.pNext := nil;
  buf_info.usage := Ord(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT);
  buf_info.size := sizeof(info.MVP);
  buf_info.queueFamilyIndexCount := 0;
  buf_info.pQueueFamilyIndices := nil;
  buf_info.sharingMode := VK_SHARING_MODE_EXCLUSIVE;
  buf_info.flags := 0;

  for var i := 0 to info.SwapchainImageCount-1 do// refer: demo.c Create uniform buffer by swapchain count
  begin
  //  result := vkCreateBuffer(info.device, @buf_info, nil, @info.uniform_data.buf);
    result := vkCreateBuffer(info.device, @buf_info, nil, @info.Buffers[i].Uniform_data.buf);
    Assert(result = VK_SUCCESS);

    var mem_reqs : TVkMemoryRequirements;
  //  vkGetBufferMemoryRequirements(info.device, info.uniform_data.buf, @mem_reqs);
    vkGetBufferMemoryRequirements(info.device, info.Buffers[i].Uniform_data.buf, @mem_reqs);

    var alloc_info := Default(TVkMemoryAllocateInfo);
    alloc_info.sType := VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    alloc_info.pNext := nil;
    alloc_info.memoryTypeIndex := 0;

    alloc_info.allocationSize := mem_reqs.size;
    pass := memory_type_from_properties(info, mem_reqs.memoryTypeBits,
                                       Ord(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or Ord(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                       alloc_info.memoryTypeIndex);
    Assert(pass, 'No mappable, coherent memory');

    result := vkAllocateMemory(info.device, @alloc_info, nil, @(info.Buffers[i].Uniform_data.mem));
    Assert(result = VK_SUCCESS);

    result := vkMapMemory(info.device, info.Buffers[i].Uniform_data.mem, 0, mem_reqs.size, 0, @info.Buffers[i].Uniform_data.mem_ptr);
    Assert(result = VK_SUCCESS);

    Move(Mtrx[0], info.Buffers[i].Uniform_data.mem_ptr^, Length(Mtrx)*sizeof(TMatrix3D));

//    vkUnmapMemory(info.device, info.Buffers[i].Uniform_data.mem); // refer: cube.c ではUnmapせずに更新しているようなのでコメントアウト

    result := vkBindBufferMemory(info.device, info.Buffers[i].Uniform_data.buf, info.Buffers[i].Uniform_data.mem, 0);
    Assert(result = VK_SUCCESS);
  {
    info.uniform_data.buffer_info.buffer := info.uniform_data.buf;
    info.uniform_data.buffer_info.offset := 0;
    info.uniform_data.buffer_info.range := sizeof(info.MVP);
  }
    info.Buffers[i].Uniform_data.buffer_info.buffer := info.Buffers[i].Uniform_data.buf;
    info.Buffers[i].Uniform_data.buffer_info.offset := 0;
    info.Buffers[i].Uniform_data.buffer_info.range := sizeof(info.MVP);
  end;
end;

procedure init_descriptor_and_pipeline_layouts(var info : TVulkanSampleInfo; use_texture : Boolean;
                                               descSetLayoutCreateFlags : TVkDescriptorSetLayoutCreateFlags);
var
  layout_bindings : array [0..1] of TVkDescriptorSetLayoutBinding;
begin
  layout_bindings[0].binding := 0;
  layout_bindings[0].descriptorType := VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
  layout_bindings[0].descriptorCount := 1;
  layout_bindings[0].stageFlags := Ord(VK_SHADER_STAGE_VERTEX_BIT);
  layout_bindings[0].pImmutableSamplers := nil;

  if use_texture then
  begin
    layout_bindings[1].binding := 1;
    layout_bindings[1].descriptorType := VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
    layout_bindings[1].descriptorCount := 1;
    layout_bindings[1].stageFlags := Ord(VK_SHADER_STAGE_FRAGMENT_BIT);
    layout_bindings[1].pImmutableSamplers := nil;
  end;

  (* Next take layout bindings and use them to create a descriptor set layout
   *)
  var descriptor_layout := Default(TVkDescriptorSetLayoutCreateInfo);
  descriptor_layout.sType := VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
  descriptor_layout.pNext := nil;
  descriptor_layout.flags := descSetLayoutCreateFlags;
  if use_texture then
    descriptor_layout.bindingCount := 2
  else
    descriptor_layout.bindingCount := 1;

  descriptor_layout.pBindings := @layout_bindings[0];

  SetLength(info.desc_layout, NUM_DESCRIPTOR_SETS);
  var result := vkCreateDescriptorSetLayout(info.device, @descriptor_layout, nil, @info.desc_layout[0]);
  Assert(result = VK_SUCCESS);

  (* Now use the descriptor layout to create a pipeline layout *)
  var pPipelineLayoutCreateInfo := Default(TVkPipelineLayoutCreateInfo);
  pPipelineLayoutCreateInfo.sType := VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
  pPipelineLayoutCreateInfo.pNext := nil;
  pPipelineLayoutCreateInfo.pushConstantRangeCount := 0;
  pPipelineLayoutCreateInfo.pPushConstantRanges := nil;
  pPipelineLayoutCreateInfo.setLayoutCount := NUM_DESCRIPTOR_SETS;
  pPipelineLayoutCreateInfo.pSetLayouts := @info.desc_layout[0];

  result := vkCreatePipelineLayout(info.device, @pPipelineLayoutCreateInfo, nil, @info.pipeline_layout);
  Assert(result = VK_SUCCESS);
end;

procedure init_renderpass(var info : TVulkanSampleInfo; include_depth : Boolean; clear : Boolean; finalLayout : TVkImageLayout;
                     initialLayout : TVkImageLayout);
var
  attachments : array[0..1] of TVkAttachmentDescription;
begin
  (* DEPENDS on init_swap_chain() and init_depth_buffer() *)

  Assert(clear or (initialLayout <> VK_IMAGE_LAYOUT_UNDEFINED));

  (* Need attachments for render target and depth buffer *)
  attachments[0].format := info.format;
  attachments[0].samples := NUM_SAMPLES;
  if clear then
    attachments[0].loadOp := VK_ATTACHMENT_LOAD_OP_CLEAR
  else
    attachments[0].loadOp := VK_ATTACHMENT_LOAD_OP_LOAD;

  attachments[0].storeOp := VK_ATTACHMENT_STORE_OP_STORE;
  attachments[0].stencilLoadOp := VK_ATTACHMENT_LOAD_OP_DONT_CARE;
  attachments[0].stencilStoreOp := VK_ATTACHMENT_STORE_OP_DONT_CARE;
  attachments[0].initialLayout := initialLayout;
  attachments[0].finalLayout := finalLayout;
  attachments[0].flags := 0;

  if include_depth then
  begin
    attachments[1].format := info.depth.format;
    attachments[1].samples := NUM_SAMPLES;
    if clear then
      attachments[1].loadOp := VK_ATTACHMENT_LOAD_OP_CLEAR
    else
      attachments[1].loadOp := VK_ATTACHMENT_LOAD_OP_DONT_CARE;

    attachments[1].storeOp := VK_ATTACHMENT_STORE_OP_STORE;
    attachments[1].stencilLoadOp := VK_ATTACHMENT_LOAD_OP_DONT_CARE;
    attachments[1].stencilStoreOp := VK_ATTACHMENT_STORE_OP_STORE;
    attachments[1].initialLayout := VK_IMAGE_LAYOUT_UNDEFINED;
    attachments[1].finalLayout := VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
    attachments[1].flags := 0;
  end;

  var color_reference := Default(TVkAttachmentReference);
  color_reference.attachment := 0;
  color_reference.layout := VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;

  var depth_reference := Default(TVkAttachmentReference);
  depth_reference.attachment := 1;
  depth_reference.layout := VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;

  var subpass := Default(TVkSubpassDescription);
  subpass.pipelineBindPoint := VK_PIPELINE_BIND_POINT_GRAPHICS;
  subpass.flags := 0;
  subpass.inputAttachmentCount := 0;
  subpass.pInputAttachments := nil;
  subpass.colorAttachmentCount := 1;
  subpass.pColorAttachments := @color_reference;
  subpass.pResolveAttachments := nil;
  if include_depth then
    subpass.pDepthStencilAttachment := @depth_reference
  else
    subpass.pDepthStencilAttachment := nil;

  subpass.preserveAttachmentCount := 0;
  subpass.pPreserveAttachments := nil;

  // Subpass dependency to wait for wsi image acquired semaphore before starting layout transition
  // refer: demo.c  //TODO:? Depth buffer is shared between swapchain images
  var subpass_dependency := Default(TVkSubpassDependency);
  subpass_dependency.srcSubpass := VK_SUBPASS_EXTERNAL;
  subpass_dependency.dstSubpass := 0;
  subpass_dependency.srcStageMask := Ord(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
  subpass_dependency.dstStageMask := Ord(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
  subpass_dependency.srcAccessMask := 0;
  subpass_dependency.dstAccessMask := Ord(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
  subpass_dependency.dependencyFlags := 0;

  var rp_info := Default(TVkRenderPassCreateInfo);
  rp_info.sType := VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
  rp_info.pNext := nil;
  if include_depth then
    rp_info.attachmentCount := 2
  else
    rp_info.attachmentCount := 1;

  rp_info.pAttachments := @attachments[0];
  rp_info.subpassCount := 1;
  rp_info.pSubpasses := @subpass;
  rp_info.dependencyCount := 1;
  rp_info.pDependencies := @subpass_dependency;

  var result := vkCreateRenderPass(info.device, @rp_info, nil, @info.render_pass);
  Assert(result = VK_SUCCESS);
end;

procedure init_framebuffers(var info : TVulkanSampleInfo; include_depth : Boolean);
var
  attachments : array [0..1] of TVkImageView;
begin
  (* DEPENDS on init_depth_buffer(), init_renderpass() and
   * init_swapchain_extension() *)

  var result : TVkResult;
  attachments[1] := info.depth.view;

  var fb_info := Default(TVkFramebufferCreateInfo);
  fb_info.sType := VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
  fb_info.pNext := nil;
  fb_info.renderPass := info.render_pass;

  if include_depth then
    fb_info.attachmentCount := 2
  else
    fb_info.attachmentCount := 1;

  fb_info.pAttachments := @attachments[0];
  fb_info.width := info.width;
  fb_info.height := info.height;
  fb_info.layers := 1;

  SetLength(info.framebuffers, info.SwapchainImageCount);

  for var i := 0 to info.SwapchainImageCount-1 do
  begin
    attachments[0] := info.Buffers[i].view;
    result := vkCreateFramebuffer(info.Device, @fb_info, nil, @info.Framebuffers[i]);
    Assert(result = VK_SUCCESS);
  end;
end;

procedure init_command_pool(var info : TVulkanSampleInfo);
begin
  (* DEPENDS on init_swapchain_extension() *)
  var cmd_pool_info := Default(TVkCommandPoolCreateInfo);
  cmd_pool_info.sType := VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
  cmd_pool_info.pNext := nil;
  cmd_pool_info.queueFamilyIndex := info.graphics_queue_family_index;
  cmd_pool_info.flags := 0;//Ord(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT);

  var result := vkCreateCommandPool(info.device, @cmd_pool_info, nil, @info.cmd_pool);
  Assert(result = VK_SUCCESS);
end;

procedure init_command_buffer(var info : TVulkanSampleInfo);
begin
  (* DEPENDS on init_swapchain_extension() and init_command_pool() *)
  var cmd := Default(TVkCommandBufferAllocateInfo);
  cmd.sType := VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
  cmd.pNext := nil;
  cmd.commandPool := info.cmd_pool;
  cmd.level := VK_COMMAND_BUFFER_LEVEL_PRIMARY;
  cmd.commandBufferCount := 1;

  var result := vkAllocateCommandBuffers(info.device, @cmd, @info.cmd);
  Assert(result = VK_SUCCESS);

  // refer: demo.c add swapchain buffers cmd
  for var i := 0 to info.SwapchainImageCount-1 do
  begin
    result := vkAllocateCommandBuffers(info.device, @cmd, @info.Buffers[i].Cmd);
    Assert(result = VK_SUCCESS);
  end;
end;

procedure execute_begin_command_buffer(var info : TVulkanSampleInfo);
begin
  (* DEPENDS on init_command_buffer() *)
  var cmd_buf_info := Default(TVkCommandBufferBeginInfo);
  cmd_buf_info.sType := VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
  cmd_buf_info.pNext := nil;
  cmd_buf_info.flags := 0;
  cmd_buf_info.pInheritanceInfo := nil;

  var result := vkBeginCommandBuffer(info.cmd, @cmd_buf_info);
  Assert(result = VK_SUCCESS);
end;

procedure execute_end_command_buffer(var info : TVulkanSampleInfo);
begin
  var result := vkEndCommandBuffer(info.cmd);
  Assert(result = VK_SUCCESS);
end;

procedure execute_queue_command_buffer(var info : TVulkanSampleInfo);
var
  cmd_bufs : array[0..0] of TVkCommandBuffer;
  submit_info : array[0..0] of TVkSubmitInfo;
begin
  (* Queue the command buffer for execution *)
  var fenceInfo : TVkFenceCreateInfo;
  var drawFence: TVkFence;
  fenceInfo.sType := VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
  fenceInfo.pNext := nil;
  fenceInfo.flags := 0;
  vkCreateFence(info.device, @fenceInfo, nil, @drawFence);

  cmd_bufs[0] := info.cmd;
  var pipe_stage_flags : TVkPipelineStageFlags := Ord(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
  submit_info[0] := Default(TVkSubmitInfo);
  submit_info[0].pNext := nil;
  submit_info[0].sType := VK_STRUCTURE_TYPE_SUBMIT_INFO;
  submit_info[0].waitSemaphoreCount := 0;
  submit_info[0].pWaitSemaphores := nil;
  submit_info[0].pWaitDstStageMask := @pipe_stage_flags;
  submit_info[0].commandBufferCount := 1;
  submit_info[0].pCommandBuffers := @cmd_bufs[0];
  submit_info[0].signalSemaphoreCount := 0;
  submit_info[0].pSignalSemaphores := nil;

  var result := vkQueueSubmit(info.graphics_queue, 1, @submit_info[0], drawFence);
  Assert(result = VK_SUCCESS);

  repeat
    result := vkWaitForFences(info.device, 1, @drawFence, VK_TRUE, FENCE_TIMEOUT);
  until (result <> VK_TIMEOUT);
  Assert(result = VK_SUCCESS);

  vkDestroyFence(info.device, drawFence, nil);
end;

procedure init_device_queue(var info : TVulkanSampleInfo);
begin
  (* DEPENDS on init_swapchain_extension() *)

  vkGetDeviceQueue(info.device, info.graphics_queue_family_index, 0, @info.graphics_queue);
  info.SeparatePresentQueue := false; // refer: demo.c  add
  if (info.graphics_queue_family_index = info.present_queue_family_index) then
  begin
    info.present_queue := info.graphics_queue;
  end else begin
  info.SeparatePresentQueue := true;  // refer: demo.c  add
    vkGetDeviceQueue(info.device, info.present_queue_family_index, 0, @info.present_queue);
  end;
end;

procedure init_vertex_buffer(var info : TVulkanSampleInfo; const vertexData : Pointer; dataSize : UInt32; dataStride : UInt32; use_texture : Boolean);
begin
  var buf_info := Default(TVkBufferCreateInfo);
  buf_info.sType := VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
  buf_info.pNext := nil;
  buf_info.usage := Ord(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT);
  buf_info.size := dataSize;
  buf_info.queueFamilyIndexCount := 0;
  buf_info.pQueueFamilyIndices := nil;
  buf_info.sharingMode := VK_SHARING_MODE_EXCLUSIVE;
  buf_info.flags := 0;
  var result := vkCreateBuffer(info.device, @buf_info, nil, @info.vertex_buffer.buf);
  Assert(result = VK_SUCCESS);

  var mem_reqs : TVkMemoryRequirements;
  vkGetBufferMemoryRequirements(info.device, info.vertex_buffer.buf, @mem_reqs);

  var alloc_info := Default(TVkMemoryAllocateInfo);
  alloc_info.sType := VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
  alloc_info.pNext := nil;
  alloc_info.memoryTypeIndex := 0;

  alloc_info.allocationSize := mem_reqs.size;
  var pass := memory_type_from_properties(info, mem_reqs.memoryTypeBits,
                                     Ord(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or Ord(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
                                     alloc_info.memoryTypeIndex);
  Assert(pass, 'No mappable, coherent memory');

  result := vkAllocateMemory(info.device, @alloc_info, nil, @(info.vertex_buffer.mem));
  Assert(result = VK_SUCCESS);
  info.vertex_buffer.buffer_info.range := mem_reqs.size;
  info.vertex_buffer.buffer_info.offset := 0;

  var pData : PByte;
  result := vkMapMemory(info.device, info.vertex_buffer.mem, 0, mem_reqs.size, 0, @pData);
  Assert(result = VK_SUCCESS);

  Move(vertexData^, pData^, dataSize);

  vkUnmapMemory(info.device, info.vertex_buffer.mem);

  result := vkBindBufferMemory(info.device, info.vertex_buffer.buf, info.vertex_buffer.mem, 0);
  Assert(result = VK_SUCCESS);

  info.vi_binding.binding := 0;
  info.vi_binding.inputRate := VK_VERTEX_INPUT_RATE_VERTEX;
  info.vi_binding.stride := dataStride;

  info.vi_attribs[0].binding := 0;
  info.vi_attribs[0].location := 0;
  info.vi_attribs[0].format := VK_FORMAT_R32G32B32A32_SFLOAT;
  info.vi_attribs[0].offset := 0;
  info.vi_attribs[1].binding := 0;
  info.vi_attribs[1].location := 1;
  if use_texture then
    info.vi_attribs[1].format := VK_FORMAT_R32G32_SFLOAT
  else
    info.vi_attribs[1].format := VK_FORMAT_R32G32B32A32_SFLOAT;
  info.vi_attribs[1].offset := 16;

  info.vi_attribs[2].binding := 0;
  info.vi_attribs[2].location := 2;
  info.vi_attribs[2].format := VK_FORMAT_R32G32B32_SFLOAT;
  info.vi_attribs[2].offset := 24;
end;

procedure init_descriptor_pool(var info : TVulkanSampleInfo; use_texture : Boolean);
var
  type_count : array[0..1] of TVkDescriptorPoolSize;
begin
  (* DEPENDS on init_uniform_buffer() and
   * init_descriptor_and_pipeline_layouts() *)

  type_count[0].type_ := VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
  type_count[0].descriptorCount := 1;
  if use_texture then
  begin
    type_count[1].type_ := VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
    type_count[1].descriptorCount := 1;
  end;

  var descriptor_pool := Default(TVkDescriptorPoolCreateInfo);
  descriptor_pool.sType := VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO;
  descriptor_pool.pNext := nil;
//  descriptor_pool.maxSets := 1;
  descriptor_pool.maxSets := info.SwapchainImageCount; // refer: demo.c
  if use_texture then
    descriptor_pool.poolSizeCount := 2
  else
    descriptor_pool.poolSizeCount := 1;

  descriptor_pool.pPoolSizes := @type_count[0];

  var result := vkCreateDescriptorPool(info.device, @descriptor_pool, nil, @info.desc_pool);
  Assert(result = VK_SUCCESS);
end;

procedure init_descriptor_set(var info : TVulkanSampleInfo; use_texture : Boolean);
var
  alloc_info : array [0..0] of TVkDescriptorSetAllocateInfo;
  writes : array [0..1] of TVkWriteDescriptorSet;
begin
  (* DEPENDS on init_descriptor_pool() *)

  var result : TVkResult;

  alloc_info[0].sType := VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
  alloc_info[0].pNext := nil;
  alloc_info[0].descriptorPool := info.desc_pool;
  alloc_info[0].descriptorSetCount := NUM_DESCRIPTOR_SETS;
  alloc_info[0].pSetLayouts := @info.desc_layout[0];

// refer: demo.c Create descriptor by swapchain count
{
  SetLength(info.desc_set, NUM_DESCRIPTOR_SETS);
  result := vkAllocateDescriptorSets(info.device, @alloc_info[0], @info.desc_set[0]);
  Assert(result = VK_SUCCESS);
}
  writes[0] := Default(TVkWriteDescriptorSet);
  writes[0].sType := VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
  writes[0].pNext := nil;
//  writes[0].dstSet := info.desc_set[0];
  writes[0].descriptorCount := 1;
  writes[0].descriptorType := VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
//  writes[0].pBufferInfo := @info.uniform_data.buffer_info;
  writes[0].dstArrayElement := 0;
  writes[0].dstBinding := 0;

  if use_texture then
  begin
    writes[1] := Default(TVkWriteDescriptorSet);
    writes[1].sType := VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
//    writes[1].dstSet := info.desc_set[0];
    writes[1].dstBinding := 1;
    writes[1].descriptorCount := 1;
    writes[1].descriptorType := VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
    writes[1].pImageInfo := @info.texture_data.image_info;
    writes[1].dstArrayElement := 0;
  end;

  for var i := 0 to info.SwapchainImageCount-1 do// refer: demo.c Create uniform buffer by swapchain count
  begin
    result := vkAllocateDescriptorSets(info.device, @alloc_info[0], @info.Buffers[i].Descriptor_set);
    Assert(result = VK_SUCCESS);

    writes[0].pBufferInfo := @info.Buffers[i].Uniform_data.buffer_info;
    writes[0].dstSet := info.Buffers[i].Descriptor_set;

    var writecount := 1;
    if use_texture then
    begin
      writecount := 2;
      writes[1].dstSet := info.Buffers[i].Descriptor_set;
    end;
    vkUpdateDescriptorSets(info.device, writecount, @writes[0], 0, nil);
  end;

end;

procedure init_shaders(var info : TVulkanSampleInfo; const vertShaderCI : PVkShaderModuleCreateInfo; const fragShaderCI : PVkShaderModuleCreateInfo);
begin
  var result : TVkResult;

  if vertShaderCI <> nil then
  begin
    info.shaderStages[0].sType := VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    info.shaderStages[0].pNext := nil;
    info.shaderStages[0].pSpecializationInfo := nil;
    info.shaderStages[0].flags := 0;
    info.shaderStages[0].stage := VK_SHADER_STAGE_VERTEX_BIT;
    info.shaderStages[0].pName := 'main';
    result := vkCreateShaderModule(info.device, vertShaderCI, nil, @info.shaderStages[0].module);
    Assert(result = VK_SUCCESS);
  end;

  if fragShaderCI <> nil then
  begin
    info.shaderStages[1].sType := VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    info.shaderStages[1].pNext := nil;
    info.shaderStages[1].pSpecializationInfo := nil;
    info.shaderStages[1].flags := 0;
    info.shaderStages[1].stage := VK_SHADER_STAGE_FRAGMENT_BIT;
    info.shaderStages[1].pName := 'main';
    result := vkCreateShaderModule(info.device, fragShaderCI, nil, @info.shaderStages[1].module);
    Assert(result = VK_SUCCESS);
  end;
end;

procedure init_pipeline_cache(var info : TVulkanSampleInfo);
begin
  var result : TVkResult;

  var pipelineCache : TVkPipelineCacheCreateInfo;
  pipelineCache.sType := VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO;
  pipelineCache.pNext := nil;
  pipelineCache.initialDataSize := 0;
  pipelineCache.pInitialData := nil;
  pipelineCache.flags := 0;
  result := vkCreatePipelineCache(info.device, @pipelineCache, nil, @info.pipelineCache);
  Assert(result = VK_SUCCESS);
end;

procedure init_pipeline(var info : TVulkanSampleInfo; include_depth : Boolean; include_vi : Boolean);
var
  dynamicStateEnables : array [0..1] of TVkDynamicState;  // Viewport + Scissor
  att_state : array[0..0] of TVkPipelineColorBlendAttachmentState;
begin

  var dynamicState := Default(TVkPipelineDynamicStateCreateInfo);
  FillChar(dynamicStateEnables, sizeof(dynamicStateEnables), 0);
  dynamicState.sType := VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO;
  dynamicState.pNext := nil;
  dynamicState.pDynamicStates := @dynamicStateEnables[0];
  dynamicState.dynamicStateCount := 0;

  var vi := Default(TVkPipelineVertexInputStateCreateInfo);
  vi.sType := VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
  if include_vi then
  begin
    vi.pNext := nil;
    vi.flags := 0;
    vi.vertexBindingDescriptionCount := 1;
    vi.pVertexBindingDescriptions := @info.vi_binding;
    vi.vertexAttributeDescriptionCount := 3;
    vi.pVertexAttributeDescriptions := @info.vi_attribs[0];
  end;
  var ia := Default(TVkPipelineInputAssemblyStateCreateInfo);
  ia.sType := VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
  ia.pNext := nil;
  ia.flags := 0;
  ia.primitiveRestartEnable := VK_FALSE;
  ia.topology := VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;

  var rs := Default(TVkPipelineRasterizationStateCreateInfo);
  rs.sType := VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
  rs.pNext := nil;
  rs.flags := 0;
  rs.polygonMode := VK_POLYGON_MODE_FILL;
  rs.cullMode := Ord(VK_CULL_MODE_BACK_BIT);
  rs.frontFace := VK_FRONT_FACE_COUNTER_CLOCKWISE; // CW->CCW
  rs.depthClampEnable := VK_FALSE;
  rs.rasterizerDiscardEnable := VK_FALSE;
  rs.depthBiasEnable := VK_FALSE;
  rs.depthBiasConstantFactor := 0;
  rs.depthBiasClamp := 0;
  rs.depthBiasSlopeFactor := 0;
  rs.lineWidth := 1.0;

  var cb := Default(TVkPipelineColorBlendStateCreateInfo);
  cb.sType := VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
  cb.flags := 0;
  cb.pNext := nil;
  att_state[0] := Default(TVkPipelineColorBlendAttachmentState);
  att_state[0].colorWriteMask := $f;
  att_state[0].blendEnable := VK_FALSE;
  att_state[0].alphaBlendOp := VK_BLEND_OP_ADD;
  att_state[0].colorBlendOp := VK_BLEND_OP_ADD;
  att_state[0].srcColorBlendFactor := VK_BLEND_FACTOR_ZERO;
  att_state[0].dstColorBlendFactor := VK_BLEND_FACTOR_ZERO;
  att_state[0].srcAlphaBlendFactor := VK_BLEND_FACTOR_ZERO;
  att_state[0].dstAlphaBlendFactor := VK_BLEND_FACTOR_ZERO;
  cb.attachmentCount := 1;
  cb.pAttachments := @att_state[0];
  cb.logicOpEnable := VK_FALSE;
  cb.logicOp := VK_LOGIC_OP_NO_OP;
  cb.blendConstants[0] := 1.0;
  cb.blendConstants[1] := 1.0;
  cb.blendConstants[2] := 1.0;
  cb.blendConstants[3] := 1.0;

  var vp := Default(TVkPipelineViewportStateCreateInfo);
  vp.sType := VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
  vp.pNext := nil;
  vp.flags := 0;
{$ifndef ANDROID}
  vp.viewportCount := NUM_VIEWPORTS;
  dynamicStateEnables[dynamicState.dynamicStateCount] := VK_DYNAMIC_STATE_VIEWPORT;
  Inc(dynamicState.dynamicStateCount);
  vp.scissorCount := NUM_SCISSORS;
  dynamicStateEnables[dynamicState.dynamicStateCount] := VK_DYNAMIC_STATE_SCISSOR;
  Inc(dynamicState.dynamicStateCount);
  vp.pScissors := nil;
  vp.pViewports := nil;
{$else}
  // Temporary disabling dynamic viewport on Android because some of drivers doesn't
  // support the feature.
  var viewports := Default(TVkViewport);
  viewports.minDepth := 0.0;
  viewports.maxDepth := 1.0;
  viewports.x := 0;
  viewports.y := 0;
  viewports.width := info.width;
  viewports.height := info.height;
  var scissor : TVkRect2D;
  scissor.extent.width := info.width;
  scissor.extent.height := info.height;
  scissor.offset.x := 0;
  scissor.offset.y := 0;
  vp.viewportCount := NUM_VIEWPORTS;
  vp.scissorCount := NUM_SCISSORS;
  vp.pScissors := @scissor;
  vp.pViewports := @viewports;
{$endif}
  var ds := Default(TVkPipelineDepthStencilStateCreateInfo);
  ds.sType := VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO;
  ds.pNext := nil;
  ds.flags := 0;
  ds.depthTestEnable := VKBool32(include_depth);
  ds.depthWriteEnable := VKBool32(include_depth);
  ds.depthCompareOp := VK_COMPARE_OP_LESS_OR_EQUAL;
  ds.depthBoundsTestEnable := VK_FALSE;
  ds.stencilTestEnable := VK_FALSE;
  ds.back.failOp := VK_STENCIL_OP_KEEP;
  ds.back.passOp := VK_STENCIL_OP_KEEP;
  ds.back.compareOp := VK_COMPARE_OP_ALWAYS;
  ds.back.compareMask := 0;
  ds.back.reference := 0;
  ds.back.depthFailOp := VK_STENCIL_OP_KEEP;
  ds.back.writeMask := 0;
  ds.minDepthBounds := 0;
  ds.maxDepthBounds := 0;
  ds.stencilTestEnable := VK_FALSE;
  ds.front := ds.back;

  var ms := Default(TVkPipelineMultisampleStateCreateInfo);
  ms.sType := VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
  ms.pNext := nil;
  ms.flags := 0;
  ms.pSampleMask := nil;
  ms.rasterizationSamples := NUM_SAMPLES;
  ms.sampleShadingEnable := VK_FALSE;
  ms.alphaToCoverageEnable := VK_FALSE;
  ms.alphaToOneEnable := VK_FALSE;
  ms.minSampleShading := 0.0;

  var pipeline := Default(TVkGraphicsPipelineCreateInfo);
  pipeline.sType := VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
  pipeline.pNext := nil;
  pipeline.layout := info.pipeline_layout;
  pipeline.basePipelineHandle := VK_NULL_HANDLE;
  pipeline.basePipelineIndex := 0;
  pipeline.flags := 0;
  pipeline.pVertexInputState := @vi;
  pipeline.pInputAssemblyState := @ia;
  pipeline.pRasterizationState := @rs;
  pipeline.pColorBlendState := @cb;
  pipeline.pTessellationState := nil;
  pipeline.pMultisampleState := @ms;
  pipeline.pDynamicState := @dynamicState;
  pipeline.pViewportState := @vp;
  pipeline.pDepthStencilState := @ds;
  pipeline.pStages := @info.shaderStages[0];
  pipeline.stageCount := 2;
  pipeline.renderPass := info.render_pass;
  pipeline.subpass := 0;

  var result := vkCreateGraphicsPipelines(info.device, info.pipelineCache, 1, @pipeline, nil, @info.pipeline);
  Assert(result = VK_SUCCESS);
end;

procedure init_sampler(var info : TVulkanSampleInfo; var sampler : TVkSampler);
begin
  var samplerCreateInfo := Default(TVkSamplerCreateInfo);
  samplerCreateInfo.sType := VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO;
  samplerCreateInfo.magFilter := VK_FILTER_NEAREST;
  samplerCreateInfo.minFilter := VK_FILTER_NEAREST;
  samplerCreateInfo.mipmapMode := VK_SAMPLER_MIPMAP_MODE_NEAREST;
  samplerCreateInfo.addressModeU := VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
  samplerCreateInfo.addressModeV := VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
  samplerCreateInfo.addressModeW := VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
  samplerCreateInfo.mipLodBias := 0.0;
  samplerCreateInfo.anisotropyEnable := VK_FALSE;
  samplerCreateInfo.maxAnisotropy := 1;
  samplerCreateInfo.compareOp := VK_COMPARE_OP_NEVER;
  samplerCreateInfo.minLod := 0.0;
  samplerCreateInfo.maxLod := 0.0;
  samplerCreateInfo.compareEnable := VK_FALSE;
  samplerCreateInfo.borderColor := VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE;

  (* create sampler *)
  var result := vkCreateSampler(info.device, @samplerCreateInfo, nil, @sampler);
  Assert(result = VK_SUCCESS);
end;

procedure init_buffer(var info : TVulkanSampleInfo; var texObj : Ttexture_object);
begin
  var result : TVkResult;

  var buffer_create_info := Default(TVkBufferCreateInfo);
  buffer_create_info.sType := VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
  buffer_create_info.pNext := nil;
  buffer_create_info.flags := 0;
  buffer_create_info.size := texObj.tex_width * texObj.tex_height * 4;
  buffer_create_info.usage := Ord(VK_BUFFER_USAGE_TRANSFER_SRC_BIT);
  buffer_create_info.sharingMode := VK_SHARING_MODE_EXCLUSIVE;
  buffer_create_info.queueFamilyIndexCount := 0;
  buffer_create_info.pQueueFamilyIndices := nil;
  result := vkCreateBuffer(info.device, @buffer_create_info, nil, @texObj.buffer);
  Assert(result = VK_SUCCESS);

  var mem_alloc := Default(TVkMemoryAllocateInfo);
  mem_alloc.sType := VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
  mem_alloc.pNext := nil;
  mem_alloc.allocationSize := 0;
  mem_alloc.memoryTypeIndex := 0;

  var mem_reqs : TVkMemoryRequirements;
  vkGetBufferMemoryRequirements(info.device, texObj.buffer, @mem_reqs);
  mem_alloc.allocationSize := mem_reqs.size;
  texObj.buffer_size := mem_reqs.size;

  var requirements : TVkFlags := Ord(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or Ord(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
  var pass := memory_type_from_properties(info, mem_reqs.memoryTypeBits, requirements, mem_alloc.memoryTypeIndex);
  Assert(pass); // "No mappable, coherent memory";

  (* allocate memory *)
  result := vkAllocateMemory(info.device, @mem_alloc, nil, @(texObj.buffer_memory));
  Assert(result = VK_SUCCESS);

  (* bind memory *)
  result := vkBindBufferMemory(info.device, texObj.buffer, texObj.buffer_memory, 0);
  Assert(result = VK_SUCCESS);
end;

procedure init_image(var info : TVulkanSampleInfo; var texObj : TTexture_object; const textureName : string; extraUsages : TVkImageUsageFlags; extraFeatures : TVkFormatFeatureFlags);
var
  cmd_bufs : array[0..0] of TVkCommandBuffer;
  submit_info : array[0..0] of TVkSubmitInfo ;
begin
  var result : TVkResult;
  var filename := get_base_data_dir();

  if textureName = '' then
    filename := filename + 'lunarg.ppm'
  else
    filename := filename + textureName;

  if not read_ppm(filename, texObj.tex_width, texObj.tex_height, 0, nil) then
  begin
    var msg := 'Try relative pat'#10;

    filename := '../../API-Samples/data/';
    if textureName = '' then
      filename := filename + 'lunarg.ppm'
    else
      filename := filename + textureName;

    if not read_ppm(filename, texObj.tex_width, texObj.tex_height, 0, nil) then
    begin
      msg := msg + 'Could not read texture file ' + filename;
      RaiseError(-1, msg);
    end;
  end;

  var formatProps : TVkFormatProperties;
  vkGetPhysicalDeviceFormatProperties(info.gpus[0], VK_FORMAT_R8G8B8A8_UNORM, @formatProps);

  (* See if we can use a linear tiled image for a texture, if not, we will
   * need a staging buffer for the texture data *)
  var  allFeatures : TVkFormatFeatureFlags := Ord(VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) or extraFeatures;
  texObj.needs_staging := ((formatProps.linearTilingFeatures and allFeatures) <> allFeatures);

  if texObj.needs_staging then
  begin
    Assert((formatProps.optimalTilingFeatures and allFeatures) = allFeatures);
    init_buffer(info, texObj);
    extraUsages := extraUsages or Ord(VK_IMAGE_USAGE_TRANSFER_DST_BIT);
  end else begin
    texObj.buffer := VK_NULL_HANDLE;
    texObj.buffer_memory := VK_NULL_HANDLE;
  end;

  var image_create_info := Default(TVkImageCreateInfo);
  image_create_info.sType := VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO;
  image_create_info.pNext := nil;
  image_create_info.imageType := VK_IMAGE_TYPE_2D;
  image_create_info.format := VK_FORMAT_R8G8B8A8_UNORM;
  image_create_info.extent.width := texObj.tex_width;
  image_create_info.extent.height := texObj.tex_height;
  image_create_info.extent.depth := 1;
  image_create_info.mipLevels := 1;
  image_create_info.arrayLayers := 1;
  image_create_info.samples := NUM_SAMPLES;
  if texObj.needs_staging then
    image_create_info.tiling := VK_IMAGE_TILING_OPTIMAL
  else
    image_create_info.tiling := VK_IMAGE_TILING_LINEAR;

  if texObj.needs_staging then
    image_create_info.initialLayout := VK_IMAGE_LAYOUT_UNDEFINED  // diff: demo.c  always VK_IMAGE_LAYOUT_PREINITIALIZED
  else
    image_create_info.initialLayout := VK_IMAGE_LAYOUT_PREINITIALIZED;

  image_create_info.usage := ord(VK_IMAGE_USAGE_SAMPLED_BIT) or extraUsages;
  image_create_info.queueFamilyIndexCount := 0;
  image_create_info.pQueueFamilyIndices := nil;
  image_create_info.sharingMode := VK_SHARING_MODE_EXCLUSIVE;
  image_create_info.flags := 0;

  var mem_alloc := Default(TVkMemoryAllocateInfo);
  mem_alloc.sType := VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
  mem_alloc.pNext := nil;
  mem_alloc.allocationSize := 0;
  mem_alloc.memoryTypeIndex := 0;

  var mem_reqs : TVkMemoryRequirements;

  result := vkCreateImage(info.device, @image_create_info, nil, @texObj.image);
  Assert(result = VK_SUCCESS);

  vkGetImageMemoryRequirements(info.device, texObj.image, @mem_reqs);

  mem_alloc.allocationSize := mem_reqs.size;

  var requirements : TVkFlags := 0;
  if not texObj.needs_staging then requirements := Ord(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or Ord(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);

  var pass := memory_type_from_properties(info, mem_reqs.memoryTypeBits, requirements, mem_alloc.memoryTypeIndex);
  Assert(pass);

  (* allocate memory *)
  result := vkAllocateMemory(info.device, @mem_alloc, nil, @(texObj.image_memory));
  Assert(result = VK_SUCCESS);

  (* bind memory *)
  result := vkBindImageMemory(info.device, texObj.image, texObj.image_memory, 0);
  Assert(result = VK_SUCCESS);

  result := vkEndCommandBuffer(info.cmd);
  Assert(result = VK_SUCCESS);
  var fenceInfo : TVkFenceCreateInfo;
  var cmdFence : TVkFence;
  fenceInfo.sType := VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
  fenceInfo.pNext := nil;
  fenceInfo.flags := 0;
  vkCreateFence(info.device, @fenceInfo, nil, @cmdFence);

  cmd_bufs[0] := info.cmd;

  submit_info[0] := Default(TVkSubmitInfo);
  submit_info[0].pNext := nil;
  submit_info[0].sType := VK_STRUCTURE_TYPE_SUBMIT_INFO;
  submit_info[0].waitSemaphoreCount := 0;
  submit_info[0].pWaitSemaphores := nil;
  submit_info[0].pWaitDstStageMask := nil;
  submit_info[0].commandBufferCount := 1;
  submit_info[0].pCommandBuffers := @cmd_bufs[0];
  submit_info[0].signalSemaphoreCount := 0;
  submit_info[0].pSignalSemaphores := nil;

  (* Queue the command buffer for execution *)
  result := vkQueueSubmit(info.graphics_queue, 1, @submit_info[0], cmdFence);
  Assert(result = VK_SUCCESS);

  var subres := Default(TVkImageSubresource);
  subres.aspectMask := Ord(VK_IMAGE_ASPECT_COLOR_BIT);
  subres.mipLevel := 0;
  subres.arrayLayer := 0;

  var layout : TVkSubresourceLayout;
  var data : Pointer;
  if not texObj.needs_staging then
  begin
    (* Get the subresource layout so we know what the row pitch is *)
    vkGetImageSubresourceLayout(info.device, texObj.image, @subres, @layout);
  end;

  (* Make sure command buffer is finished before mapping *)
  repeat
    result := vkWaitForFences(info.device, 1, @cmdFence, VK_TRUE, FENCE_TIMEOUT);
  until (result <> VK_TIMEOUT);
  Assert(result = VK_SUCCESS);

  vkDestroyFence(info.device, cmdFence, nil);

  if texObj.needs_staging then
  begin
    result := vkMapMemory(info.device, texObj.buffer_memory, 0, texObj.buffer_size, 0, @data);
  end else begin
    result := vkMapMemory(info.device, texObj.image_memory, 0, mem_reqs.size, 0, @data);
  end;
  Assert(result = VK_SUCCESS);

  (* Read the ppm file into the mappable image's memory *)
  var rowPicth : UInt64;
  if texObj.needs_staging then rowPicth := texObj.tex_width * 4 else rowPicth := layout.rowPitch;

  if not read_ppm(filename, texObj.tex_width, texObj.tex_height, rowPicth, data) then
  begin
    RaiseError(-1,  'Could not load texture file lunarg.ppm');
  end;

  if texObj.needs_staging then
    vkUnmapMemory(info.device, texObj.buffer_memory)
  else
    vkUnmapMemory(info.device, texObj.image_memory);

  var cmd_buf_info := Default(TVkCommandBufferBeginInfo);
  cmd_buf_info.sType := VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
  cmd_buf_info.pNext := nil;
  cmd_buf_info.flags := 0;
  cmd_buf_info.pInheritanceInfo := nil;

  result := vkResetCommandBuffer(info.cmd, 0);
  Assert(result = VK_SUCCESS);
  result := vkBeginCommandBuffer(info.cmd, @cmd_buf_info);
  Assert(result = VK_SUCCESS);

  if not texObj.needs_staging then
  begin
    (* If we can use the linear tiled image as a texture, just do it *)
    texObj.imageLayout := VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
    set_image_layout(info, texObj.image, Ord(VK_IMAGE_ASPECT_COLOR_BIT), VK_IMAGE_LAYOUT_PREINITIALIZED, texObj.imageLayout,
                     Ord(VK_PIPELINE_STAGE_HOST_BIT), Ord(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT));
  end else begin
    (* Since we're going to blit to the texture image, set its layout to
     * DESTINATION_OPTIMAL *)
    set_image_layout(info, texObj.image, Ord(VK_IMAGE_ASPECT_COLOR_BIT), VK_IMAGE_LAYOUT_UNDEFINED,
                     VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, Ord(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT), Ord(VK_PIPELINE_STAGE_TRANSFER_BIT));

    var copy_region := Default(TVkBufferImageCopy);
    copy_region.bufferOffset := 0;
    copy_region.bufferRowLength := texObj.tex_width;
    copy_region.bufferImageHeight := texObj.tex_height;
    copy_region.imageSubresource.aspectMask := Ord(VK_IMAGE_ASPECT_COLOR_BIT);
    copy_region.imageSubresource.mipLevel := 0;
    copy_region.imageSubresource.baseArrayLayer := 0;
    copy_region.imageSubresource.layerCount := 1;
    copy_region.imageOffset.x := 0;
    copy_region.imageOffset.y := 0;
    copy_region.imageOffset.z := 0;
    copy_region.imageExtent.width := texObj.tex_width;
    copy_region.imageExtent.height := texObj.tex_height;
    copy_region.imageExtent.depth := 1;

    (* Put the copy command into the command buffer *)
    vkCmdCopyBufferToImage(info.cmd, texObj.buffer, texObj.image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, @copy_region);

    (* Set the layout for the texture image from DESTINATION_OPTIMAL to
     * SHADER_READ_ONLY *)
    texObj.imageLayout := VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
    set_image_layout(info, texObj.image, Ord(VK_IMAGE_ASPECT_COLOR_BIT), VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, texObj.imageLayout,
                     Ord(VK_PIPELINE_STAGE_TRANSFER_BIT), Ord(VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT));
  end;

  var view_info := Default(TVkImageViewCreateInfo);
  view_info.sType := VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
  view_info.pNext := nil;
  view_info.image := VK_NULL_HANDLE;
  view_info.viewType := VK_IMAGE_VIEW_TYPE_2D;
  view_info.format := VK_FORMAT_R8G8B8A8_UNORM;
  view_info.components.r := VK_COMPONENT_SWIZZLE_R;
  view_info.components.g := VK_COMPONENT_SWIZZLE_G;
  view_info.components.b := VK_COMPONENT_SWIZZLE_B;
  view_info.components.a := VK_COMPONENT_SWIZZLE_A;
  view_info.subresourceRange.aspectMask := Ord(VK_IMAGE_ASPECT_COLOR_BIT);
  view_info.subresourceRange.baseMipLevel := 0;
  view_info.subresourceRange.levelCount := 1;
  view_info.subresourceRange.baseArrayLayer := 0;
  view_info.subresourceRange.layerCount := 1;

  (* create image view *)
  view_info.image := texObj.image;
  result := vkCreateImageView(info.device, @view_info, nil, @texObj.view);
  Assert(result = VK_SUCCESS);
end;

procedure init_texture(var info : TVulkanSampleInfo; const textureName : string; extraUsages : TVkImageUsageFlags; extraFeatures : TVkFormatFeatureFlags);
begin
  var texObj : TTexture_object;

  (* create image *)
  init_image(info, texObj, textureName, extraUsages, extraFeatures);

  (* create sampler *)
  init_sampler(info, texObj.sampler);

  info.textures := info.textures + [texObj];

  (* track a description of the texture *)
  info.texture_data.image_info.imageView := info.textures[Length(info.textures)-1].view;
  info.texture_data.image_info.sampler := info.textures[Length(info.textures)-1].sampler;
  info.texture_data.image_info.imageLayout := VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
end;

procedure init_viewports(var info : TVulkanSampleInfo);
begin
{$ifdef ANDROID}
// Disable dynamic viewport on Android. Some drive has an issue with the dynamic viewport
// feature.
{$else}
  info.viewport.height := Single(info.height);
  info.viewport.width := Single(info.width);
  info.viewport.minDepth := 0.0;
  info.viewport.maxDepth := 1.0;
  info.viewport.x := 0;
  info.viewport.y := 0;
  vkCmdSetViewport(info.cmd, 0, NUM_VIEWPORTS, @info.viewport);
{$endif}
end;

procedure init_scissors(var info : TVulkanSampleInfo);
begin
{$ifdef ANDROID}
// Disable dynamic viewport on Android. Some drive has an issue with the dynamic scissors
// feature.
{$else}
  info.scissor.extent.width := info.width;
  info.scissor.extent.height := info.height;
  info.scissor.offset.x := 0;
  info.scissor.offset.y := 0;
  vkCmdSetScissor(info.cmd, 0, NUM_SCISSORS, @info.scissor);
{$endif}
end;

function init_fence(var info : TVulkanSampleInfo; var fence : TVkFence; flags : TVkFenceCreateFlags) : TVkResult;
begin
  var fenceInfo : TVkFenceCreateInfo;
  fenceInfo.sType := VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
  fenceInfo.pNext := nil;
  fenceInfo.flags := flags;
  result := vkCreateFence(info.device, @fenceInfo, nil, @fence);
end;

procedure init_submit_info(var info : TVulkanSampleInfo; var submit_info : TVkSubmitInfo; var pipe_stage_flags : TVkPipelineStageFlags);
begin
  submit_info.pNext := nil;
  submit_info.sType := VK_STRUCTURE_TYPE_SUBMIT_INFO;
  submit_info.waitSemaphoreCount := 1;
  submit_info.pWaitSemaphores := @info.imageAcquiredSemaphore;
  submit_info.pWaitDstStageMask := @pipe_stage_flags;
  submit_info.commandBufferCount := 1;
  submit_info.pCommandBuffers := @info.cmd;
  submit_info.signalSemaphoreCount := 0;
  submit_info.pSignalSemaphores := nil;
end;

procedure init_present_info(var info : TVulkanSampleInfo; var present : TVkPresentInfoKHR);
begin
  present.sType := VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
  present.pNext := nil;
  present.swapchainCount := 1;
  present.pSwapchains := @info.swap_chain;
  present.pImageIndices := @info.current_buffer;
  present.pWaitSemaphores := nil;
  present.waitSemaphoreCount := 0;
  present.pResults := nil;
end;

procedure init_clear_color_and_depth(var info : TVulkanSampleInfo; var clear_values : array of TVkClearValue);
begin
  if HIGH(clear_values) >= 1 then
  begin
    clear_values[0].color.float32[0] := 0.2;
    clear_values[0].color.float32[1] := 0.2;
    clear_values[0].color.float32[2] := 0.2;
    clear_values[0].color.float32[3] := 0.2;
    clear_values[1].depthStencil.depth := 1.0;
    clear_values[1].depthStencil.stencil := 0;
  end;
end;

procedure init_render_pass_begin_info(var info : TVulkanSampleInfo; var rp_begin : TVkRenderPassBeginInfo);
begin
  rp_begin.sType := VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
  rp_begin.pNext := nil;
  rp_begin.renderPass := info.render_pass;
  rp_begin.framebuffer := info.framebuffers[info.current_buffer];
  rp_begin.renderArea.offset.x := 0;
  rp_begin.renderArea.offset.y := 0;
  rp_begin.renderArea.extent.width := info.width;
  rp_begin.renderArea.extent.height := info.height;
  rp_begin.clearValueCount := 0;
  rp_begin.pClearValues := nil;
end;

procedure destroy_pipeline(var info : TVulkanSampleInfo);
begin
  vkDestroyPipeline(info.device, info.pipeline, nil);
end;

procedure destroy_pipeline_cache(var info : TVulkanSampleInfo);
begin
  vkDestroyPipelineCache(info.device, info.pipelineCache, nil);
end;

procedure destroy_uniform_buffer(var info : TVulkanSampleInfo);
begin
//  vkDestroyBuffer(info.device, info.uniform_data.buf, nil);
//  vkFreeMemory(info.device, info.uniform_data.mem, nil);
  var count := Length(info.Buffers);
  for var i := 0 to count-1 do
  begin
    vkDestroyBuffer(info.device, info.Buffers[i].Uniform_data.buf, nil);
    vkFreeMemory(info.device, info.Buffers[i].Uniform_data.mem, nil);
  end;
end;

procedure destroy_descriptor_and_pipeline_layouts(var info : TVulkanSampleInfo);
begin
  for var i := 0 to NUM_DESCRIPTOR_SETS-1 do  vkDestroyDescriptorSetLayout(info.device, info.desc_layout[i], nil);
  vkDestroyPipelineLayout(info.device, info.pipeline_layout, nil);
end;

procedure destroy_descriptor_pool(var info : TVulkanSampleInfo);
begin
  vkDestroyDescriptorPool(info.device, info.desc_pool, nil);
end;

procedure destroy_shaders(var info : TVulkanSampleInfo);
begin
  vkDestroyShaderModule(info.device, info.shaderStages[0].module, nil);
  vkDestroyShaderModule(info.device, info.shaderStages[1].module, nil);
end;

procedure destroy_command_buffer(var info : TVulkanSampleInfo);
begin
//    VkCommandBuffer cmd_bufs[1] := {info.cmd};
  vkFreeCommandBuffers(info.device, info.cmd_pool, 1, @info.cmd);
end;

procedure destroy_command_pool(var info : TVulkanSampleInfo);
begin
  vkDestroyCommandPool(info.device, info.cmd_pool, nil);
end;

procedure destroy_depth_buffer(var info : TVulkanSampleInfo);
begin
  vkDestroyImageView(info.device, info.depth.view, nil);
  vkDestroyImage(info.device, info.depth.image, nil);
  vkFreeMemory(info.device, info.depth.mem, nil);
end;

procedure destroy_vertex_buffer(var info : TVulkanSampleInfo);
begin
  vkDestroyBuffer(info.device, info.vertex_buffer.buf, nil);
  vkFreeMemory(info.device, info.vertex_buffer.mem, nil);
end;

procedure destroy_swap_chain(var info : TVulkanSampleInfo; resize : Boolean);
begin
  for var i := 0 to info.swapchainImageCount-1 do
  begin
    vkDestroyImageView(info.device, info.Buffers[i].view, nil);
    // refer: demo.c
    vkFreeCommandBuffers(info.device, info.cmd_pool, 1, @info.Buffers[i].cmd);
    vkDestroyBuffer(info.device, info.Buffers[i].Uniform_data.Buf, nil);
    vkUnmapMemory(info.device, info.Buffers[i].Uniform_data.Mem);
    vkFreeMemory(info.device, info.Buffers[i].Uniform_data.Mem, nil);
  end;
  if not resize then
  begin
    vkDestroySwapchainKHR(info.device, info.Swap_chain, nil);
    info.Swap_chain := VK_NULL_HANDLE;
  end;
  info.Buffers := nil;
end;

procedure destroy_framebuffers(var info : TVulkanSampleInfo);
begin
  for var i := 0 to info.swapchainImageCount-1 do
  begin
    vkDestroyFramebuffer(info.device, info.framebuffers[i], nil);
  end;
  info.framebuffers := nil;
end;

procedure destroy_renderpass(var info : TVulkanSampleInfo);
begin
  vkDestroyRenderPass(info.device, info.render_pass, nil);
end;

procedure destroy_device(var info : TVulkanSampleInfo);
begin
  vkDeviceWaitIdle(info.device);
  vkDestroyDevice(info.device, nil);
end;

procedure destroy_instance(var info : TVulkanSampleInfo);
begin
  vkDestroyInstance(info.inst, nil);
end;

procedure destroy_textures(var info : TVulkanSampleInfo);
begin
  var cnt := Length(info.textures) -1;
  for var i := 0 to cnt do
  begin
    vkDestroySampler(info.device, info.textures[i].sampler, nil);
    vkDestroyImageView(info.device, info.textures[i].view, nil);
    vkDestroyImage(info.device, info.textures[i].image, nil);
    vkFreeMemory(info.device, info.textures[i].image_memory, nil);
    vkDestroyBuffer(info.device, info.textures[i].buffer, nil);
    vkFreeMemory(info.device, info.textures[i].buffer_memory, nil);
  end;
  info.Textures := nil;
end;

// add
procedure destroy_semaphore_and_fences(var info : TVulkanSampleInfo);
begin
  vkDestroySemaphore(info.Device, info.ImageAcquiredSemaphore, nil);
  vkDestroySemaphore(info.Device, info.DrawCompleteSemaphore, nil);
  vkDestroyFence(info.Device, info.LoopFence, nil);
end;

initialization

  RaiseError := DefaultRaiseError;
  Log := DefaultLogFunc;

finalization

end.
