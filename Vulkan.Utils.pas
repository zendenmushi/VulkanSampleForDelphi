(*
 * Vulkan Samples
 *
 * Copyright (C) 2015-2016 Valve Corporation
 * Copyright (C) 2015-2016 LunarG, Inc.
 * Copyright (C) 2015-2016 Google, Inc.
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

unit Vulkan.Utils;

interface
uses
  System.Classes, System.SysUtils, System.Math.Vectors,
  Vulkan,
{$ifdef FMX}
  FMX.Platform, FMX.Types,
{$endif}
{$ifdef MSWINDOWS}
  Winapi.Windows
{$else}
  Macapi.Cocoatypes
{$endif}
  ;


(* Number of descriptor sets needs to be the same at alloc,       *)
(* pipeline layout creation, and descriptor set layout creation   *)
const NUM_DESCRIPTOR_SETS = 1;

(* Number of samples needs to be the same at image creation,      *)
(* renderpass creation and pipeline creation.                     *)
const NUM_SAMPLES = VK_SAMPLE_COUNT_1_BIT;

(* Number of viewports and number of scissors have to be the same *)
(* at pipeline creation and in any call to set them dynamically   *)
(* They also have to be the same as each other                    *)
const NUM_VIEWPORTS = 1;
const NUM_SCISSORS = NUM_VIEWPORTS;

(* Amount of time, in nanoseconds, to wait for a command buffer to complete *)
const FENCE_TIMEOUT = 100000000;

type

(*
 * structure to track all objects related to a texture.
 *)
  TTexture_object = record
    Sampler : TVkSampler;

    Image : TVkImage;
    ImageLayout : TVkImageLayout;

    Needs_staging : Boolean;
    Buffer : TVkBuffer;
    Buffer_size : tVkDeviceSize;

    Image_memory : TVkDeviceMemory;
    Buffer_memory : TVkDeviceMemory;
    View : TVkImageView;
    Tex_width, Tex_height : Int32;
  end;

(*
 * Keep each of our swap chain buffers' image, command buffer and view in one
 * spot
 *)
  TSwap_chain_buffer = record
  type // refer: demo.c move from TVulkanSampleInfo
    TUniform_data = record
      Buf : TVkBuffer;
      Mem : TVkDeviceMemory;
      Mem_Ptr : Pointer;
      Buffer_info : TVkDescriptorBufferInfo;
    end;
  var
    Image : TVkImage;
    View : TVkImageView;
    Uniform_data : TUniform_data;
    Descriptor_set : TVkDescriptorSet; // move from TVulkanSampleInfo
    Cmd : TVkCommandBuffer; // Buffer for commands // refer: demo.c
  end;

(*
 * A layer can expose extensions, keep track of those
 * extensions here.
 *)
  TLayerProperties = record
    Properties : TVkLayerProperties;
    Instance_extensions : TArray<TVkExtensionProperties>;
    Device_extensions : TArray<TVkExtensionProperties>;
  end;

(*
 * Structure for tracking information used / created / modified
 * by utility functions.
 *)


  TVulkanSampleInfo = record
{$ifdef MSWINDOWS}
    Connection : System.HINST;     // hInstance - Windows Instance
    Name : string;                 // Name to put on the window/icon
    Window : HWND;                 // hWnd - window handle
{$elseif Defined(VK_USE_PLATFORM_METAL_EXT)}
    MetalLayer : Pointer;
{$elseif ANDROID}
    CreateAndroidSurfaceKHR : PFN_vkCreateAndroidSurfaceKHR;
{$elseif Defined(VK_USE_PLATFORM_WAYLAND_KHR)}
    Display : Pwl_display;
    Registry : Pwl_registry ;
    Compositor : Pwl_compositor;
    Window : Pwl_surface;
    Shell : Pwl_shell;
    Shell_surface : Pwl_shell_surface;
{$else}
    Connection : Pxcb_connection_t;
    Screen : Pxcb_screen_t;
    Window : Txcb_window_t;
    Atom_wm_delete_window : Pxcb_intern_atom_reply_t;
{$endif} // MSWINDOWS
    Surface : TVkSurfaceKHR ;
    Prepared : Boolean;
    Use_staging_buffer : Boolean;
    Save_images : Boolean;

    Instance_layer_names : TArray<AnsiString>;
    Instance_extension_names : TArray<AnsiString>;
    Instance_layer_properties : TArray<TLayerProperties>;
    Instance_extension_properties : TArray<TVkExtensionProperties> ;
    Inst : TVkInstance;

    Device_extension_names : TArray<AnsiString>;
    device_extension_properties : TArray<TVkExtensionProperties>;
    Gpus : TArray<TVkPhysicalDevice>;
    Device : TVkDevice;
    Graphics_queue : TVkQueue;
    Present_queue : TVkQueue;
    Graphics_queue_family_index : UInt32;
    Present_queue_family_index : UInt32;
    SeparatePresentQueue : Boolean;  // refer: demo.c  add
    Gpu_props : TVkPhysicalDeviceProperties;
    Queue_props : TArray<TVkQueueFamilyProperties>;
    Memory_properties : TVkPhysicalDeviceMemoryProperties;

    Framebuffers : TArray<TVkFramebuffer>;
    Width, Height : Integer;
    Format : TVkFormat;

    SwapchainImageCount : UInt32;
    Swap_chain : TVkSwapchainKHR;
    Buffers : TArray<TSwap_chain_buffer>;
    ImageAcquiredSemaphore : TVkSemaphore;
    DrawCompleteSemaphore : TVkSemaphore; // refer: demo.c  add

    LoopFence : TVkFence; // add for loop

    Cmd_pool : TVkCommandPool;

  type
    TDepth = record
      Format : TVkFormat;

      Image : TVkImage;
      Mem : TVkDeviceMemory;
      View : TVkImageView;
    end;
    { // refer: demo.c move to TSwap_chain_buffer
    TUniform_data = record
      Buf : TVkBuffer;
      Mem : TVkDeviceMemory;
      Buffer_info : TVkDescriptorBufferInfo;
    end;
    }

    TTexture_data = record
      image_info : TVkDescriptorImageInfo;
    end;

    TVertex_buffer = record
      Buf : TVkBuffer;
      Mem : TVkDeviceMemory;
      Buffer_info : TVkDescriptorBufferInfo;
    end;
  var
    Depth : TDepth;
    { // refer: demo.c move to TSwap_chain_buffer
    Uniform_data :TUniform_data;
    }
    Texture_data : TTexture_data;
    Vertex_buffer : TVertex_buffer;
    Textures : TArray<TTexture_object>;

    Vi_binding : TVkVertexInputBindingDescription;
    Vi_attribs : array [0..2] of TVkVertexInputAttributeDescription;

    Projection : TMatrix3D;
    View : TMatrix3D;
    Model : TMatrix3D;
    Clip : TMatrix3D;
    MVP : TMatrix3D;

    Cmd : TVkCommandBuffer; // Buffer for initialization commands
    Pipeline_layout : TVkPipelineLayout;
    Desc_layout : TArray<TVkDescriptorSetLayout>;
    PipelineCache : TVkPipelineCache;
    Render_pass : TVkRenderPass;
    Pipeline : TVkPipeline;

    ShaderStages : array [0..1] of TVkPipelineShaderStageCreateInfo;

    Desc_pool : TVkDescriptorPool;
//    Desc_set : TArray<TVkDescriptorSet>;// refer: demo.c move to TSwap_chain_buffer

    dbgCreateDebugReportCallback : TvkCreateDebugReportCallbackEXT;
    dbgDestroyDebugReportCallback : TvkDestroyDebugReportCallbackEXT;
    dbgBreakCallback : TvkDebugReportMessageEXT;
    debug_report_callbacks : TArray<TVkDebugReportCallbackEXT>;

    Current_buffer : UInt32;
    Queue_family_count : UInt32;

    Viewport : TVkViewport;
    Scissor : TVkRect2D;
  end;

  PVulkanSampleInfo = ^TVulkanSampleInfo;

function get_base_data_dir() : string;

//procedure process_command_line_args(var info : TVulkanSampleInfo; argc : Integer; var argv : array of string);
procedure process_command_line_args(var info : TVulkanSampleInfo); // use ParamStr()
function memory_type_from_properties(const info : TVulkanSampleInfo; typeBits : UInt32; requirements_mask : TVkFlags; var typeIndex : UInt32) : Boolean;
procedure set_image_layout(const info : TVulkanSampleInfo; image : TVkImage; aspectMask : TVkImageAspectFlags; old_image_layout : TVkImageLayout;
                      new_image_layout : TVkImageLayout; src_stages : TVkPipelineStageFlags; dest_stages : TVkPipelineStageFlags);
function read_ppm(const filename : string; var width, height : Integer; rowPitch : UInt64; dataPtr : PByte) : Boolean;
procedure write_ppm(const info : TVulkanSampleInfo; basename : string);
procedure extract_version(version : UInt32; var major, minor, patch : UInt32);
{$if Defined(VK_USE_PLATFORM_IOS_MVK) or Defined(VK_USE_PLATFORM_MACOS_MVK)}
function GLSLtoSPV(const shader_type : TVkShaderStageFlagBits; const pshader : string; var spirv : TArray<UInt32>) : Boolean;
procedure init_glslang();
procedure finalize_glslang();
{$endif}
procedure wait_seconds(seconds : Integer);
procedure print_UUID(pipelineCacheUUID : PByte);
function get_file_directory()  : string;

function get_milliseconds() : UInt32;

{$ifdef ANDROID}
// Android specific definitions & helpers.
{
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "VK-SAMPLE", __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, "VK-SAMPLE", __VA_ARGS__))
// Replace printf to logcat output.
#define printf(...) __android_log_print(ANDROID_LOG_DEBUG, "VK-SAMPLE", __VA_ARGS__);
}
function Android_process_command() : Boolean;
function AndroidGetApplicationWindow() : PANativeWindow;
{
FILE* AndroidFopen(const char* fname, const char* mode);
void AndroidGetWindowSize(int32_t *width, int32_t *height);
bool AndroidLoadFile(const char* filePath, std::string *data);
}
{$ifndef VK_API_VERSION_1_0}
// On Android, NDK would include slightly older version of headers that is missing the definition.
{$define VK_API_VERSION_1_0 VK_API_VERSION}
{$endif}
{$endif}

implementation

procedure extract_version(version : UInt32; var major, minor, patch : UInt32);
begin
  major := version shr 22;
  minor := (version shr 12) and $3ff;
  patch := version and $fff;
end;


// iOS & macOS: get_base_data_dir() implemented externally to allow access to Objective-C components
function get_base_data_dir() : string;
begin
{$ifdef ANDROID}
    result := '';
{$elseif Defined(MACOS)}
    result := ExtractFilePath(ParamStr(0)) + '../Resources/data/';
{$else}
//    result := VULKAN_SAMPLES_BASE_DIR + '\data\';
    result := ExtractFilePath(ParamStr(0)) + '\data\';
{$endif}
end;

function get_data_dir(filename : string) : string;
begin
  var basedir := get_base_data_dir();
    // get the base filename
  var fname := ExtractFileName(filename);

  // get the prefix of the base filename, i.e. the part before the dash
  {
  stringstream stream(fname);
  std::string prefix;
  getline(stream, prefix, '-');
  std::string ddir = basedir + prefix;
  return ddir;
  }
end;

function memory_type_from_properties(const info : TVulkanSampleInfo; typeBits : UInt32; requirements_mask : TVkFlags; var typeIndex : UInt32) : Boolean;
begin
  // Search memtypes to find first index with those properties
  for var i := 0 to info.memory_properties.memoryTypeCount-1 do
  begin
    if (typeBits and 1) <> 0 then
    begin
      // Type is available, does it match user properties?
      if ((info.Memory_properties.MemoryTypes[i].PropertyFlags and requirements_mask) = requirements_mask) then
      begin
          typeIndex := i;
          exit(true);
      end;
    end;
    typeBits := typeBits shr 1;
  end;
  // No memory types matched, return failure
  result := false;
end;

procedure set_image_layout(const info : TVulkanSampleInfo; image : TVkImage; aspectMask : TVkImageAspectFlags; old_image_layout : TVkImageLayout;
                      new_image_layout : TVkImageLayout; src_stages : TVkPipelineStageFlags; dest_stages : TVkPipelineStageFlags);
begin
  (* DEPENDS on info.cmd and info.queue initialized *)

  Assert(info.cmd <> VK_NULL_HANDLE);
  Assert(info.graphics_queue <> VK_NULL_HANDLE);

  var image_memory_barrier := Default(TVkImageMemoryBarrier);
  image_memory_barrier.sType := VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
  image_memory_barrier.pNext := nil;
  image_memory_barrier.srcAccessMask := 0;
  image_memory_barrier.dstAccessMask := 0;
  image_memory_barrier.oldLayout := old_image_layout;
  image_memory_barrier.newLayout := new_image_layout;
  image_memory_barrier.srcQueueFamilyIndex := VK_QUEUE_FAMILY_IGNORED;
  image_memory_barrier.dstQueueFamilyIndex := VK_QUEUE_FAMILY_IGNORED;
  image_memory_barrier.image := image;
  image_memory_barrier.subresourceRange.aspectMask := aspectMask;
  image_memory_barrier.subresourceRange.baseMipLevel := 0;
  image_memory_barrier.subresourceRange.levelCount := 1;
  image_memory_barrier.subresourceRange.baseArrayLayer := 0;
  image_memory_barrier.subresourceRange.layerCount := 1;

  case (old_image_layout) of
  VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:
    image_memory_barrier.srcAccessMask := TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
  VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:
    image_memory_barrier.srcAccessMask := TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
  VK_IMAGE_LAYOUT_PREINITIALIZED:
    image_memory_barrier.srcAccessMask := TVkAccessFlags(VK_ACCESS_HOST_WRITE_BIT);
  end;

  case (new_image_layout) of
  VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL:
    image_memory_barrier.dstAccessMask := TVkAccessFlags(VK_ACCESS_TRANSFER_WRITE_BIT);
  VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL:
    image_memory_barrier.dstAccessMask := TVkAccessFlags(VK_ACCESS_TRANSFER_READ_BIT);
  VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL:
    image_memory_barrier.dstAccessMask := TVkAccessFlags(VK_ACCESS_SHADER_READ_BIT);
  VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL:
    image_memory_barrier.dstAccessMask := TVkAccessFlags(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
  VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL:
    image_memory_barrier.dstAccessMask := TVkAccessFlags(VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);
  end;

  vkCmdPipelineBarrier(info.cmd, src_stages, dest_stages, 0, 0, nil, 0, nil, 1, @image_memory_barrier);
end;

const saneDimension = 32768;  //??

function read_ppm(const filename : string; var width, height : Integer; rowPitch : UInt64; dataPtr : PByte) : Boolean;

  function read_str(stream : TMemoryStream) : AnsiString;
  begin
    result := '';
    var start : Boolean := false;
    repeat
      var ch : AnsiChar;
      if stream.Read(ch,1) > 0 then
      begin
        var is_space := ch in [#8,#9,#10,#13,' '];
        if not start and is_space then continue;
        if start and is_space then
        begin
          break;
        end;

        start := true;
        result := result + ch;

      end else begin
        break;
      end;
    until false;
  end;

begin
    // PPM format expected from http://netpbm.sourceforge.net/doc/ppm.html
    //  1. magic number
    //  2. whitespace
    //  3. width
    //  4. whitespace
    //  5. height
    //  6. whitespace
    //  7. max color value
    //  8. whitespace
    //  7. data

    // Comments are not supported, but are detected and we kick out
    // Only 8 bits per channel is supported
    // If dataPtr is nullptr, only width and height are returned

    // Read in values from the PPM file as characters to check for comments
  var magicStr, heightStr, widthStr, formatStr : AnsiString;

  var stream := TMemoryStream.Create();
  try
    stream.LoadFromFile(filename);

    // Read the four values from file, accounting with any and all whitepace
    magicStr := read_str(stream); Assert(magicStr <> '');
    widthStr := read_str(stream); Assert(widthStr <> '');
    heightStr := read_str(stream); Assert(heightStr <> '');
    formatStr := read_str(stream); Assert(formatStr <> '');

    // Kick out if comments present
    if (magicStr[1] = '#') or (widthStr[1] = '#') or (heightStr[1] = '#') or (formatStr[1] = '#') then
    begin
      Writeln('Unhandled comment in PPM file');
      exit(false);
    end;

    // Only one magic value is valid
    if (magicStr <> 'P6') then
    begin
      Writeln('Unhandled PPM magic number: '+ magicStr);
      exit(false);
    end;

    width := StrToIntDef(string(widthStr),0);
    height := StrToIntDef(string(heightStr),0);

    // Ensure we got something sane for width/height
    if ((width <= 0) or (width > saneDimension)) then
    begin
      Writeln('Width seems wrong.  Update read_ppm if not: '+IntToStr(width));
      exit(false);
    end;
    if ((height <= 0) or (height > saneDimension)) then
    begin
      Writeln('Height seems wrong.  Update read_ppm if not: '+IntToStr(height));
      exit(false);
    end;

    if (dataPtr = nil) then
    begin
      // If no destination pointer, caller only wanted dimensions
      exit(true);
    end;

    // Now read the data
    for var y := 0 to height-1 do
    begin
      var rowPtr := dataPtr;
      for var x := 0 to width-1 do
      begin
        var count := stream.Read(rowPtr^, 3);
        Assert(count = 3);
        Inc(rowPtr,3);
        rowPtr^ := 255; (* Alpha of 1 *)
        Inc(rowPtr,1);
      end;
      Inc(dataPtr, rowPitch);
    end;
  finally
    stream.Free;
  end;

  result := true;
end;



{$if Defined(VK_USE_PLATFORM_IOS_MVK) or Defined(VK_USE_PLATFORM_MACOS_MVK)}
procedure init_glslang();
begin
end;

procedure finalize_glslang();
begin
end;


function GLSLtoSPV(const shader_type : TVkShaderStageFlagBits; const pshader : string; var spirv TArray<UInt32>) : Boolean;
begin
  // TODO:MoltenVKのヘッダーも移植する必要あり

    MVKGLSLConversionShaderStage shaderStage;
    switch (shader_type) {
        case VK_SHADER_STAGE_VERTEX_BIT:
            shaderStage = kMVKGLSLConversionShaderStageVertex;
            break;
        case VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT:
            shaderStage = kMVKGLSLConversionShaderStageTessControl;
            break;
        case VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT:
            shaderStage = kMVKGLSLConversionShaderStageTessEval;
            break;
        case VK_SHADER_STAGE_GEOMETRY_BIT:
            shaderStage = kMVKGLSLConversionShaderStageGeometry;
            break;
        case VK_SHADER_STAGE_FRAGMENT_BIT:
            shaderStage = kMVKGLSLConversionShaderStageFragment;
            break;
        case VK_SHADER_STAGE_COMPUTE_BIT:
            shaderStage = kMVKGLSLConversionShaderStageCompute;
            break;
        default:
            shaderStage = kMVKGLSLConversionShaderStageAuto;
            break;
    }

    mvk::GLSLToSPIRVConverter glslConverter;
    glslConverter.setGLSL(pshader);
    bool wasConverted = glslConverter.convert(shaderStage, false, false);
    if (wasConverted) {
        spirv = glslConverter.getSPIRV();
    }
    return wasConverted;
end;

{$endif}  // IOS or macOS

procedure wait_seconds(seconds : Integer);
begin
{$ifdef MSWINDOWS}
    Sleep(seconds * 1000);
{$elseif Defined(ANDROID)}
    sleep(seconds);
{$else}
    sleep(seconds);
{$endif}
end;

function get_milliseconds() : UInt32;
begin
{$ifdef MSWINDOWS}
    var frequency : TLargeInteger;
    var useQPC := QueryPerformanceFrequency(frequency);
    if (useQPC) then
    begin
        var now : TLargeInteger;
        QueryPerformanceCounter(now);
        var temp : _LARGE_INTEGER;
        exit(Round((1000 * now) / frequency));
    end else begin
        exit(GetTickCount());
    end;
{$else}
  var ts : IFMXTimerService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXTimerService, IInterface(ts)) then
  begin
    result := Round(ts.GetTick);
  end else begin
    result := 0;
  end;
{$endif}
end;

procedure print_UUID(pipelineCacheUUID : PByte);
begin
  var s := '';
  for var j := 0 to VK_UUID_SIZE-1 do
  begin
    var ui32 := UInt32(pipelineCacheUUID^);
    s := s + Format('%0.2d', [ui32]);
    if (j = 3) or (j = 5) or (j = 7) or (j = 9) then
    begin
      s := s + '-';
    end;
  end;
  Writeln(s);
end;

function optionMatch(option : string; optionLine : string) : Boolean;
begin
  if (option = optionLine) then
      exit(true)
  else
      exit(false);
end;

//procedure process_command_line_args(var info : TVulkanSampleInfo; argc : Integer; var argv : array of string);
procedure process_command_line_args(var info : TVulkanSampleInfo);
begin
  for var i := 1 to ParamCount-1 do
  begin
    if (optionMatch('--save-images', ParamStr(i))) then
    begin
      info.save_images := true;
    end else if (optionMatch('--help', ParamStr(i)) or optionMatch('-h', ParamStr(i))) then
    begin
      Writeln(#10'Other options:');
      Writeln(
          #9'--save-images'#10+
          #9#9'Save tests images as ppm files in current working '#10+
          'directory.');
      exit;
    end else begin
      Writeln(#10'Unrecognized option: '+ParamStr(i));
      Writeln(#10'Use --help or -h for option list.');
      exit;
    end;

  end;
end;



procedure write_ppm(const info : TVulkanSampleInfo; basename : string);
var
  submit_info : array[0..0] of TVkSubmitInfo;
  cmd_bufs : array[0..0] of TVkCommandBuffer;
begin
    var image_create_info := Default(TVkImageCreateInfo);
    image_create_info.sType := VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO;
    image_create_info.pNext := nil;
    image_create_info.imageType := VK_IMAGE_TYPE_2D;
    image_create_info.format := info.format;
    image_create_info.extent.width := info.width;
    image_create_info.extent.height := info.height;
    image_create_info.extent.depth := 1;
    image_create_info.mipLevels := 1;
    image_create_info.arrayLayers := 1;
    image_create_info.samples := VK_SAMPLE_COUNT_1_BIT;
    image_create_info.tiling := VK_IMAGE_TILING_LINEAR;
    image_create_info.initialLayout := VK_IMAGE_LAYOUT_UNDEFINED;
    image_create_info.usage := TVkImageUsageFlags(VK_IMAGE_USAGE_TRANSFER_DST_BIT);
    image_create_info.queueFamilyIndexCount := 0;
    image_create_info.pQueueFamilyIndices := nil;
    image_create_info.sharingMode := VK_SHARING_MODE_EXCLUSIVE;
    image_create_info.flags := 0;

    var mem_alloc := Default(TVkMemoryAllocateInfo);

    mem_alloc.sType := VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    mem_alloc.pNext := nil;
    mem_alloc.allocationSize := 0;
    mem_alloc.memoryTypeIndex := 0;

    var mappableImage : TVkImage;
    var mappableMemory : TVkDeviceMemory;

    (* Create a mappable image *)
    var res := vkCreateImage(info.device, @image_create_info, nil, @mappableImage);
    Assert(res = VK_SUCCESS);

    var mem_reqs : TVkMemoryRequirements;
    vkGetImageMemoryRequirements(info.device, mappableImage, @mem_reqs);

    mem_alloc.allocationSize := mem_reqs.size;

    (* Find the memory type that is host mappable *)
    var pass := memory_type_from_properties(
        info, mem_reqs.memoryTypeBits, TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) or TVkMemoryPropertyFlags(VK_MEMORY_PROPERTY_HOST_COHERENT_BIT),
        mem_alloc.memoryTypeIndex);
    Assert(pass, 'No mappable, coherent memory');

    (* allocate memory *)
    res := vkAllocateMemory(info.device, @mem_alloc, nil, @mappableMemory);
    Assert(res = VK_SUCCESS);

    (* bind memory *)
    res := vkBindImageMemory(info.device, mappableImage, mappableMemory, 0);
    Assert(res = VK_SUCCESS);

    var cmd_buf_info := Default(TVkCommandBufferBeginInfo);
    cmd_buf_info.sType := VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
    cmd_buf_info.pNext := nil;
    cmd_buf_info.flags := 0;
    cmd_buf_info.pInheritanceInfo := nil;

    res := vkBeginCommandBuffer(info.cmd, @cmd_buf_info);
    Assert(res = VK_SUCCESS);

    set_image_layout(info, mappableImage, TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT), VK_IMAGE_LAYOUT_UNDEFINED,
                     VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, TVkPipelineStageFlags(VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT), TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT));

    set_image_layout(info, info.buffers[info.current_buffer].image, TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT), VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
                     VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, TVkPipelineStageFlags(VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT), TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT));

    var copy_region : TVkImageCopy;
    copy_region.srcSubresource.aspectMask := TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
    copy_region.srcSubresource.mipLevel := 0;
    copy_region.srcSubresource.baseArrayLayer := 0;
    copy_region.srcSubresource.layerCount := 1;
    copy_region.srcOffset.x := 0;
    copy_region.srcOffset.y := 0;
    copy_region.srcOffset.z := 0;
    copy_region.dstSubresource.aspectMask := TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
    copy_region.dstSubresource.mipLevel := 0;
    copy_region.dstSubresource.baseArrayLayer := 0;
    copy_region.dstSubresource.layerCount := 1;
    copy_region.dstOffset.x := 0;
    copy_region.dstOffset.y := 0;
    copy_region.dstOffset.z := 0;
    copy_region.extent.width := info.width;
    copy_region.extent.height := info.height;
    copy_region.extent.depth := 1;

    (* Put the copy command into the command buffer *)
    vkCmdCopyImage(info.cmd, info.buffers[info.current_buffer].image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, mappableImage,
                   VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, @copy_region);

    set_image_layout(info, mappableImage, TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT), VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_GENERAL,
                     TVkPipelineStageFlags(VK_PIPELINE_STAGE_TRANSFER_BIT), TVkPipelineStageFlags(VK_PIPELINE_STAGE_HOST_BIT));

    res := vkEndCommandBuffer(info.cmd);
    Assert(res = VK_SUCCESS);
//    const VkCommandBuffer cmd_bufs[] = {info.cmd};
    cmd_bufs[0] := info.cmd;
    var fenceInfo : TVkFenceCreateInfo;
    var cmdFence : TVkFence;
    fenceInfo.sType := VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
    fenceInfo.pNext := nil;
    fenceInfo.flags := 0;
    vkCreateFence(info.device, @fenceInfo, nil, @cmdFence);


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
    res := vkQueueSubmit(info.graphics_queue, 1, @submit_info[0], cmdFence);
    Assert(res = VK_SUCCESS);

    (* Make sure command buffer is finished before mapping *)
    repeat
        res := vkWaitForFences(info.device, 1, @cmdFence, VK_TRUE, FENCE_TIMEOUT);
    until (res <> VK_TIMEOUT);
    Assert(res = VK_SUCCESS);

    vkDestroyFence(info.device, cmdFence, nil);

    var filename := basename+'.ppm';

    var subres := Default(TVkImageSubresource);
    subres.aspectMask := TVkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT);
    subres.mipLevel := 0;
    subres.arrayLayer := 0;
    var sr_layout : TVkSubresourceLayout;
    vkGetImageSubresourceLayout(info.device, mappableImage, @subres,@sr_layout);

    var ptr : PAnsiChar;
    res := vkMapMemory(info.device, mappableMemory, 0, mem_reqs.size, 0, @ptr);
    Assert(res = VK_SUCCESS);

    Inc(ptr, sr_layout.offset);
    var ofstream := TMemoryStream.Create();//file(filename.c_str(), ios::binary);
    try
      var s : AnsiString := 'P6'#10;
      ofstream.Write(s, Length(s));
      s := AnsiString(IntToStr(info.width))+#10;
      ofstream.Write(s, Length(s));
      s := AnsiString(IntToStr(info.height)+#10);
      ofstream.Write(s, Length(s));
      s := '255'#10;
      ofstream.Write(s, Length(s));

      for var y := 0 to info.height-1 do
      begin
        var row : PUint32 := PUInt32(ptr);
        var swapped : Uint32;

        if (info.format = VK_FORMAT_B8G8R8A8_UNORM) or (info.format = VK_FORMAT_B8G8R8A8_SRGB) then
        begin
            for var x := 0 to info.width-1 do
            begin
              swapped := (row^ and $ff00ff00) or ((row^ and $000000ff) shl 16) or ((row^ and $00ff0000) shr 16);
              ofstream.Write(swapped, 3);
              Inc(row);
            end;
        end else if (info.format = VK_FORMAT_R8G8B8A8_UNORM) then
        begin
            for var x := 0 to info.width-1 do
            begin
              ofstream.Write(row^, 3);
              Inc(row);
            end;
        end else begin
          Writeln('Unrecognized image format - will not write image files');
          break;
        end;

        Inc(ptr, sr_layout.rowPitch);
      end;
    finally
      ofstream.Free;
    end;

    vkUnmapMemory(info.device, mappableMemory);
    vkDestroyImage(info.device, mappableImage, nil);
    vkFreeMemory(info.device, mappableMemory, nil);
end;

function get_file_directory()  : string;
begin
{$ifndef ANDROID}
    result := '';
{$else}
    Assert(Android_application <> nullptr);
    result :=  Android_application->activity->externalDataPath;
{$endif}
end;

{$ifdef ANDROID}
//
// Android specific helper functions.
//

// Helpder class to forward the cout/cerr output to logcat derived from:
// http://stackoverflow.com/questions/8870174/is-stdcout-usable-in-android-ndk
class AndroidBuffer : public std::streambuf {
   public:
    AndroidBuffer(android_LogPriority priority) {
        priority_ = priority;
        this->setp(buffer_, buffer_ + kBufferSize - 1);
    }

   private:
    static const int32_t kBufferSize = 128;
    int32_t overflow(int32_t c) {
        if (c == traits_type::eof()) {
            *this->pptr() = traits_type::to_char_type(c);
            this->sbumpc();
        }
        return this->sync() ? traits_type::eof() : traits_type::not_eof(c);
    }

    int32_t sync() {
        int32_t rc = 0;
        if (this->pbase() != this->pptr()) {
            char writebuf[kBufferSize + 1];
            memcpy(writebuf, this->pbase(), this->pptr() - this->pbase());
            writebuf[this->pptr() - this->pbase()] = '\0';

            rc = __android_log_write(priority_, "std", writebuf) > 0;
            this->setp(buffer_, buffer_ + kBufferSize - 1);
        }
        return rc;
    }

    android_LogPriority priority_ = ANDROID_LOG_INFO;
    char buffer_[kBufferSize];
};

void Android_handle_cmd(android_app *app, int32_t cmd) {
    switch (cmd) {
        case APP_CMD_INIT_WINDOW:
            // The window is being shown, get it ready.
            sample_main(0, nullptr);
            LOGI("\n");
            LOGI("=================================================");
            LOGI("          The sample ran successfully!!");
            LOGI("=================================================");
            LOGI("\n");
            break;
        case APP_CMD_TERM_WINDOW:
            // The window is being hidden or closed, clean it up.
            break;
        default:
            LOGI("event not handled: %d", cmd);
    }
}

bool Android_process_command() {
    Assert(Android_application != nullptr);
    int events;
    android_poll_source *source;
    // Poll all pending events.
    if (ALooper_pollAll(0, NULL, &events, (void **)&source) >= 0) {
        // Process each polled events
        if (source != NULL) source->process(Android_application, source);
    }
    return Android_application->destroyRequested;
}

void android_main(struct android_app *app) {
    // Set static variables.
    Android_application = app;
    // Set the callback to process system events
    app->onAppCmd = Android_handle_cmd;

    // Forward cout/cerr to logcat.
    std::cout.rdbuf(new AndroidBuffer(ANDROID_LOG_INFO));
    std::cerr.rdbuf(new AndroidBuffer(ANDROID_LOG_ERROR));

    // Main loop
    do {
        Android_process_command();
    }  // Check if system requested to quit the application
    while (app->destroyRequested == 0);

    return;
}

ANativeWindow *AndroidGetApplicationWindow() {
    Assert(Android_application != nullptr);
    return Android_application->window;
}

bool AndroidFillShaderMap(const char *path, std::unordered_map<std::string, std::string> *map_shaders) {
    Assert(Android_application != nullptr);
    auto directory = AAssetManager_openDir(Android_application->activity->assetManager, path);

    const char *name = nullptr;
    while (1) {
        name = AAssetDir_getNextFileName(directory);
        if (name == nullptr) {
            break;
        }

        std::string file_name = name;
        if (file_name.find(".frag") != std::string::npos || file_name.find(".vert") != std::string::npos) {
            // Add path to the filename.
            file_name = std::string(path) + "/" + file_name;
            std::string shader;
            if (!AndroidLoadFile(file_name.c_str(), &shader)) {
                continue;
            }
            // Remove \n to make the lookup more robust.
            while (1) {
                auto ret_pos = shader.find("\n");
                if (ret_pos == std::string::npos) {
                    break;
                }
                shader.erase(ret_pos, 1);
            }

            auto pos = file_name.find_last_of(".");
            if (pos == std::string::npos) {
                // Invalid file nmae.
                continue;
            }
            // Generate filename for SPIRV binary.
            std::string spirv_name = file_name.replace(pos, 1, "-") + ".spirv";
            // Store the SPIRV file name with GLSL contents as a key.
            // The file contents can be long, but as we are using unordered map, it wouldn't take
            // much storage space.
            // Put the file into the map.
            (*map_shaders)[shader] = spirv_name;
        }
    };

    AAssetDir_close(directory);
    return true;
}

bool AndroidLoadFile(const char *filePath, std::string *data) {
    Assert(Android_application != nullptr);
    AAsset *file = AAssetManager_open(Android_application->activity->assetManager, filePath, AASSET_MODE_BUFFER);
    size_t fileLength = AAsset_getLength(file);
    LOGI("Loaded file:%s size:%zu", filePath, fileLength);
    if (fileLength == 0) {
        return false;
    }
    data->resize(fileLength);
    AAsset_read(file, &(*data)[0], fileLength);
    return true;
}

void AndroidGetWindowSize(int32_t *width, int32_t *height) {
    // On Android, retrieve the window size from the native window.
    Assert(Android_application != nullptr);
    *width = ANativeWindow_getWidth(Android_application->window);
    *height = ANativeWindow_getHeight(Android_application->window);
}

// Android fopen stub described at
// http://www.50ply.com/blog/2013/01/19/loading-compressed-android-assets-with-file-pointer/#comment-1850768990
static int android_read(void *cookie, char *buf, int size) { return AAsset_read((AAsset *)cookie, buf, size); }

static int android_write(void *cookie, const char *buf, int size) {
    return EACCES;  // can't provide write access to the apk
}

static fpos_t android_seek(void *cookie, fpos_t offset, int whence) { return AAsset_seek((AAsset *)cookie, offset, whence); }

static int android_close(void *cookie) {
    AAsset_close((AAsset *)cookie);
    return 0;
}

FILE *AndroidFopen(const char *fname, const char *mode) {
    if (mode[0] == 'w') {
        return NULL;
    }

    Assert(Android_application != nullptr);
    AAsset *asset = AAssetManager_open(Android_application->activity->assetManager, fname, 0);
    if (!asset) {
        return NULL;
    }

    return funopen(asset, android_read, android_write, android_seek, android_close);
}
{$endif}

end.

