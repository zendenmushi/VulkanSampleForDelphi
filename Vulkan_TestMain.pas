// Convert from Vulkan Sample  draw_textured_cube + (vkCube Demo)cube.c

// Original Header
(*
 * Vulkan Samples
 *
 * Copyright (C) 2015-2020 Valve Corporation
 * Copyright (C) 2015-2020 LunarG, Inc.
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

 // Convert to pas : 2020 TMaeda  https://github.com/zendenmushi

 // Tested
 // Windows 10 64bit  : Drawing stops when the window size is changed.
 // macOS 10.15 64bit : The libMoltenVK.dylib in the application bundle may not be used.
 //                      Perhaps the .dylib in the SDK is called
 // iOS 13.7          : static link libMoltenVK.a

 // Untested
 // Android, Linux

unit Vulkan_TestMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Platform
  , Vulkan, Vulkan.Utils, Vulkan.Init
  ;

type
  TMainForm = class(TForm)
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private 宣言 }
    FSample_info : TVulkanSampleInfo;
    FVulkanReady : Boolean;
    function LoadShader(var stream : TMemoryStream; shader_name : string): TVkShaderModuleCreateInfo;
    procedure BuildDrawCommand(cmd: TVkCommandBuffer);
    procedure DestroyAndPrepere_forResize;
    procedure PrepareVulkan;
  protected
    procedure PaintRects(const UpdateRects: array of TRectF); override;
  public
    { public 宣言 }
  end;

var
  MainForm: TMainForm;

implementation
uses
{$ifdef MSWINDOWS}
  Winapi.Windows
  , FMX.Platform.Win
{$endif}
{$ifdef IOS}
  iOSapi.CocoaTypes, iOSapi.Foundation
  , FMX.Platform.iOS, Macapi.Helpers
{$elseif Defined(MACOS)}
  Macapi.CocoaTypes, Macapi.Foundation
  , FMX.Platform.Mac, Macapi.Helpers
{$endif}
  , System.Math.Vectors
  ;

{$R *.fmx}

type TVertexUV = packed record
    x, y, z, w : Single;  // Position data
    u, v : Single;        // texture u,v
    nx, ny, nz : Single;  // normal
end;

const vb_texture_data : array[0..35] of TVertexUV = (
// -X
  (x:-1; y:-1; z:-1; w:1; u:1; v:1; nx:-1; ny:0; nz:0 ),
  (x:-1; y: 1; z: 1; w:1; u:0; v:0; nx:-1; ny:0; nz:0 ),
  (x:-1; y:-1; z: 1; w:1; u:0; v:1; nx:-1; ny:0; nz:0 ),
  (x:-1; y: 1; z: 1; w:1; u:0; v:0; nx:-1; ny:0; nz:0 ),
  (x:-1; y:-1; z:-1; w:1; u:1; v:1; nx:-1; ny:0; nz:0 ),
  (x:-1; y: 1; z:-1; w:1; u:1; v:0; nx:-1; ny:0; nz:0 ),
// -Z
  (x:-1; y:-1; z:-1; w:1; u:0; v:1; nx:0; ny:0; nz:-1 ),
  (x: 1; y:-1; z:-1; w:1; u:1; v:1; nx:0; ny:0; nz:-1 ),
  (x: 1; y: 1; z:-1; w:1; u:1; v:0; nx:0; ny:0; nz:-1 ),
  (x:-1; y:-1; z:-1; w:1; u:0; v:1; nx:0; ny:0; nz:-1 ),
  (x: 1; y: 1; z:-1; w:1; u:1; v:0; nx:0; ny:0; nz:-1 ),
  (x:-1; y: 1; z:-1; w:1; u:0; v:0; nx:0; ny:0; nz:-1 ),
// -Y {bottom}
  (x:-1; y:-1; z:-1; w:1; u:0; v:0; nx:0; ny:-1; nz:0 ),
  (x: 1; y:-1; z: 1; w:1; u:1; v:1; nx:0; ny:-1; nz:0 ),
  (x: 1; y:-1; z:-1; w:1; u:1; v:0; nx:0; ny:-1; nz:0 ),
  (x:-1; y:-1; z:-1; w:1; u:0; v:0; nx:0; ny:-1; nz:0 ),
  (x:-1; y:-1; z: 1; w:1; u:0; v:1; nx:0; ny:-1; nz:0 ),
  (x: 1; y:-1; z: 1; w:1; u:1; v:1; nx:0; ny:-1; nz:0 ),
// +Y {top}
  (x:-1; y: 1; z:-1; w:1; u:0; v:1; nx:0; ny:1; nz:0 ),
  (x: 1; y: 1; z: 1; w:1; u:1; v:0; nx:0; ny:1; nz:0 ),
  (x:-1; y: 1; z: 1; w:1; u:0; v:0; nx:0; ny:1; nz:0 ),
  (x:-1; y: 1; z:-1; w:1; u:0; v:1; nx:0; ny:1; nz:0 ),
  (x: 1; y: 1; z:-1; w:1; u:1; v:1; nx:0; ny:1; nz:0 ),
  (x: 1; y: 1; z: 1; w:1; u:1; v:0; nx:0; ny:1; nz:0 ),
// +X
  (x: 1; y: 1; z:-1; w:1; u:0; v:0; nx:1; ny:0; nz:0 ),
  (x: 1; y:-1; z: 1; w:1; u:1; v:1; nx:1; ny:0; nz:0 ),
  (x: 1; y: 1; z: 1; w:1; u:1; v:0; nx:1; ny:0; nz:0 ),
  (x: 1; y:-1; z: 1; w:1; u:1; v:1; nx:1; ny:0; nz:0 ),
  (x: 1; y: 1; z:-1; w:1; u:0; v:0; nx:1; ny:0; nz:0 ),
  (x: 1; y:-1; z:-1; w:1; u:0; v:1; nx:1; ny:0; nz:0 ),
// +Z
  (x:-1; y: 1; z: 1; w:1; u:1; v:0; nx:0; ny:0; nz:1 ),
  (x: 1; y: 1; z: 1; w:1; u:0; v:0; nx:0; ny:0; nz:1 ),
  (x:-1; y:-1; z: 1; w:1; u:1; v:1; nx:0; ny:0; nz:1 ),
  (x:-1; y:-1; z: 1; w:1; u:1; v:1; nx:0; ny:0; nz:1 ),
  (x: 1; y: 1; z: 1; w:1; u:0; v:0; nx:0; ny:0; nz:1 ),
  (x: 1; y:-1; z: 1; w:1; u:0; v:1; nx:0; ny:0; nz:1 )
 );

function TMainForm.LoadShader(var stream : TMemoryStream; shader_name : string) : TVkShaderModuleCreateInfo;
begin
  var fname := get_base_data_dir()+shader_name;
  stream.LoadFromFile(fname);

  result := Default(TVkShaderModuleCreateInfo);
  result.sType := VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
  result.codeSize := stream.Size;
  result.pCode := stream.Memory;
end;

procedure TMainForm.PaintRects(const UpdateRects: array of TRectF);
begin
//  inherited;
  if @OnPaint <> nil then OnPaint(self, Canvas, ClientRect);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  FormPaint(self, Canvas, ClientRect); // MacだとInvalidateで画面更新されない？
//  Invalidate;
end;

function debug_func(flags:TVkDebugReportFlagsEXT;objectType:TVkDebugReportObjectTypeEXT;object_:TVkUInt64;location:TVkSize;messageCode:TVkInt32;const pLayerPrefix:PVkChar;const pMessage:PVkChar;pUserData:PVkVoid):TVkBool32;{$ifdef MSWINDOWS}stdcall;{$else}{$ifdef Android}{$ifdef cpuarm}hardfloat;{$else}cdecl;{$endif}{$else}cdecl;{$endif}{$endif}
begin
{$ifdef MSWINDOWS}
  OutputDebugStringA(pMessage);
{$endif}
{$ifdef macOS}
  NSLog(StringToId(string(pMessage)));
{$endif}
  result := VK_FALSE;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
{$ifdef IOS}
  LoadVulkanLibrary();
{$elseif Defined(MACOS)}
  LoadVulkanLibrary('libvulkan.1.2.148.dylib');
{$else}
  LoadVulkanLibrary();
{$endif}

{$ifndef IOS}
  LoadVulkanGlobalCommands;
{$endif}
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  process_command_line_args(FSample_info);
  init_global_layer_properties(FSample_info);
  init_instance_extension_names(FSample_info);
  init_device_extension_names(FSample_info);
  init_instance(FSample_info, 'Draw Texture Sample');
{$ifdef IOS}
  LoadVulkanGlobalCommands(FSample_info.Inst);
{$endif}
{$ifdef DEBUG}
  init_debug_report_callback(FSample_info, debug_func);
{$endif}
  init_enumerate_device(FSample_info);
  init_connection(FSample_info);
{$ifdef MSWINDOWS}
  init_window(FSample_info, NativeUInt(WindowHandleToPlatform(Handle).Wnd));
{$endif}
{$ifdef IOS}
  init_window_size(FSample_info, Trunc(ClientWidth*Handle.Scale), Trunc(ClientHeight*Handle.Scale));
  init_window(FSample_info, NativeUInt(WindowHandleToPlatform(Handle).MTView));
{$elseif Defined(MACOS)}
  init_window(FSample_info, NativeUInt(WindowHandleToPlatform(Handle).View));
{$endif}
  init_swapchain_extension(FSample_info);
  init_device(FSample_info);
  { // init_swap_chainの後ろに移動
  init_command_pool(FSample_info);
  init_command_buffer(FSample_info);
  execute_begin_command_buffer(FSample_info);
  }
  init_device_queue(FSample_info);

  FSample_info.Model := TMatrix3D.Create(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1); // <- Move from Vulkan.init.pas

  PrepareVulkan();
end;

procedure TMainForm.PrepareVulkan();
begin
{$if defined(MSWINDOWS) or Defined(IOS)}
  init_window_size(FSample_info, Trunc(ClientWidth*Handle.Scale), Trunc(ClientHeight*Handle.Scale));
{$else}
  init_window_size(FSample_info, ClientWidth, ClientHeight);
{$endif}
  init_swap_chain(FSample_info, Ord(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) or Ord(VK_IMAGE_USAGE_TRANSFER_SRC_BIT), 3); // add NumOfSwapchain
  init_command_pool(FSample_info);
  init_command_buffer(FSample_info);
  execute_begin_command_buffer(FSample_info);

  init_depth_buffer(FSample_info);
  init_texture(FSample_info);
  init_uniform_buffer(FSample_info);
  init_descriptor_and_pipeline_layouts(FSample_info, true);
  var depthPresent : Boolean := true;
  init_renderpass(FSample_info, depthPresent);

  var vert_stream := TMemoryStream.Create;
  var frag_stream := TMemoryStream.Create;
  try
    var vert_info := LoadShader(vert_stream, 'draw_textured_cube.vert.spv');
    var frag_info := LoadShader(frag_stream, 'draw_textured_cube.frag.spv');
    init_shaders(FSample_info, @vert_info, @frag_info);
  finally
    vert_stream.Free;
    frag_stream.Free;
  end;

  init_framebuffers(FSample_info, depthPresent);
  init_vertex_buffer(FSample_info, @vb_texture_data[0], sizeof(vb_texture_data), sizeof(vb_texture_data[0]), true);
  init_descriptor_pool(FSample_info, true);
  init_descriptor_set(FSample_info, true);
  init_pipeline_cache(FSample_info);
  init_pipeline(FSample_info, depthPresent);

  // refer: demo.c 各swapchain用のコマンドを生成
  for var i := 0 to FSample_info.SwapchainImageCount-1 do
  begin
    FSample_info.Current_buffer := i;
    BuildDrawCommand(FSample_info.Buffers[i].Cmd);
  end;
  FSample_info.Current_buffer := 0;

  var imageAcquiredSemaphoreCreateInfo : TVkSemaphoreCreateInfo ;
  imageAcquiredSemaphoreCreateInfo.sType := VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;
  imageAcquiredSemaphoreCreateInfo.pNext := nil;
  imageAcquiredSemaphoreCreateInfo.flags := 0;

  var result := vkCreateSemaphore(FSample_info.device, @imageAcquiredSemaphoreCreateInfo, nil, @FSample_info.ImageAcquiredSemaphore);
  assert(result = VK_SUCCESS);
  result := vkCreateSemaphore(FSample_info.device, @imageAcquiredSemaphoreCreateInfo, nil, @FSample_info.DrawCompleteSemaphore); // refer: demo.c add
  assert(result = VK_SUCCESS);

  // Get the index of the next available swapchain image:
  result := vkAcquireNextImageKHR(FSample_info.device, FSample_info.swap_chain, $ffffffffffffffff, FSample_info.ImageAcquiredSemaphore, VK_NULL_HANDLE,
                              @FSample_info.current_buffer);
  // TODO: Deal with the VK_SUBOPTIMAL_KHR and VK_ERROR_OUT_OF_DATE_KHR
  // return codes
  assert(result = VK_SUCCESS);

//  BuildDrawCommand(FSample_info.Cmd);
  execute_end_command_buffer(FSample_info);

  // FormPaint()内の最初のvkWaitForFences()を通過するためにシグナル状態で生成
  result := init_fence(FSample_info, FSample_info.LoopFence, Ord(VK_FENCE_CREATE_SIGNALED_BIT));

  FVulkanReady := true;
end;

procedure TMainForm.BuildDrawCommand(cmd : TVkCommandBuffer);
var
  clear_values : array [0..1] of TVkClearValue;
begin
  var cmd_buf_info := Default(TVkCommandBufferBeginInfo);
  cmd_buf_info.sType := VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
  cmd_buf_info.pNext := nil;
  cmd_buf_info.flags := Ord(VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT);
  cmd_buf_info.pInheritanceInfo := nil;
  var result := vkBeginCommandBuffer(cmd, @cmd_buf_info);

  clear_values[0].color.float32[0] := 0.2;
  clear_values[0].color.float32[1] := 0.2;
  clear_values[0].color.float32[2] := 0.2;
  clear_values[0].color.float32[3] := 0.2;
  clear_values[1].depthStencil.depth := 1.0;
  clear_values[1].depthStencil.stencil := 0;

  var rp_begin : TVkRenderPassBeginInfo;
  rp_begin.sType := VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
  rp_begin.pNext := nil;
  rp_begin.renderPass := FSample_info.render_pass;
  rp_begin.framebuffer := FSample_info.framebuffers[FSample_info.current_buffer];
  rp_begin.renderArea.offset.x := 0;
  rp_begin.renderArea.offset.y := 0;
  rp_begin.renderArea.extent.width := FSample_info.width;
  rp_begin.renderArea.extent.height := FSample_info.height;
  rp_begin.clearValueCount := 2;
  rp_begin.pClearValues := @clear_values[0];

  vkCmdBeginRenderPass(cmd, @rp_begin, VK_SUBPASS_CONTENTS_INLINE);

  vkCmdBindPipeline(cmd, VK_PIPELINE_BIND_POINT_GRAPHICS, FSample_info.pipeline);
  vkCmdBindDescriptorSets(cmd, VK_PIPELINE_BIND_POINT_GRAPHICS, FSample_info.pipeline_layout, 0, NUM_DESCRIPTOR_SETS,
                          @FSample_info.Buffers[FSample_info.Current_buffer].Descriptor_set, 0, nil);

  var offsets : TVkDeviceSize := 0;
  vkCmdBindVertexBuffers(cmd, 0, 1, @FSample_info.vertex_buffer.buf, @offsets);

  var viewport := Default(TVkViewPort);
  var viewport_dimension : Single;
  viewport.width := FSample_info.Width;
  viewport.height := FSample_info.Height;
  viewport.x := 0;
  viewport.y := 0;
  viewport.minDepth := 0.0;
  viewport.maxDepth := 1.0;
  vkCmdSetViewport(cmd, 0, 1, @viewport);

  var scissor := Default(TVkRect2D);
  scissor.extent.width := FSample_info.Width;
  scissor.extent.height := FSample_info.Height;
  scissor.offset.x := 0;
  scissor.offset.y := 0;
  vkCmdSetScissor(cmd, 0, 1, @scissor);


  vkCmdDraw(cmd, 12 * 3, 1, 0, 0);
  vkCmdEndRenderPass(cmd);
  result := vkEndCommandBuffer(cmd);
  assert(result = VK_SUCCESS);
end;

// refer:demo.c
procedure TMainForm.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  Mtrx : array[0..1] of TMatrix3D;
begin

  if FVulkanReady then
  begin
    vkWaitForFences(FSample_info.Device, 1, @FSample_info.LoopFence, VK_TRUE, $ffffffffffffffff);
    vkResetFences(FSample_info.Device, 1, @FSample_info.LoopFence);

    var result : TVkResult;
    repeat
      result := vkAcquireNextImageKHR(FSample_info.device, FSample_info.swap_chain, $ffffffffffffffff, FSample_info.ImageAcquiredSemaphore, VK_NULL_HANDLE,
                                @FSample_info.current_buffer);

      case result of
      VK_ERROR_OUT_OF_DATE_KHR:
        begin
          DestroyAndPrepere_forResize();
          vkResetFences(FSample_info.Device, 1, @FSample_info.LoopFence);
        end;
      VK_SUBOPTIMAL_KHR:
        begin
          //
        end;
      VK_ERROR_SURFACE_LOST_KHR:
        begin
          // recreate surface
          vkDestroySurfaceKHR(FSample_Info.Inst, FSample_Info.Surface, nil);
          init_surface(FSample_Info);
          DestroyAndPrepere_forResize();
          vkResetFences(FSample_info.Device, 1, @FSample_info.LoopFence);
        end;
      else
        Assert(result = VK_SUCCESS);
      end;
    until result = VK_SUCCESS;

    // update uniform
    var VP : TMatrix3D;
    VP := FSample_info.View  * FSample_info.Projection * FSample_info.Clip;
    // Rotate around the Y axis
    var Rot := TMatrix3D.CreateRotation(TPoint3D.Create(0,1,0), -0.05);
    FSample_info.Model := Rot * FSample_info.Model;

    Mtrx[0] := FSample_info.Model * VP;
    Mtrx[1] := FSample_info.Model.Inverse;

    Move(Mtrx, FSample_info.Buffers[FSample_info.current_buffer].Uniform_data.Mem_ptr^ , Length(Mtrx)*sizeof(TMatrix3D));


    var pipe_stage_flags : TVkPipelineStageFlags;
    var submit_info := Default(TVkSubmitInfo);
    submit_info.sType := VK_STRUCTURE_TYPE_SUBMIT_INFO;
    submit_info.pNext := nil;
    submit_info.pWaitDstStageMask := @pipe_stage_flags;
    pipe_stage_flags := Ord(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);
    submit_info.waitSemaphoreCount := 1;
    submit_info.pWaitSemaphores := @FSample_info.ImageAcquiredSemaphore;
    submit_info.commandBufferCount := 1;
    submit_info.pCommandBuffers := @FSample_info.Buffers[FSample_info.Current_buffer].Cmd;
    submit_info.signalSemaphoreCount := 1;
    submit_info.pSignalSemaphores := @FSample_info.DrawCompleteSemaphore;

    result := vkQueueSubmit(FSample_info.Graphics_queue, 1, @submit_info, FSample_info.LoopFence);
    Assert(result = VK_SUCCESS);

    // todo: separete present queue

    var present := Default(TVkPresentInfoKHR);
    present.sType := VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
    present.pNext := nil;
    present.waitSemaphoreCount := 1;
    present.pWaitSemaphores := @FSample_info.DrawCompleteSemaphore;
    present.swapchainCount := 1;
    present.pSwapchains := @FSample_info.Swap_chain;
    present.pImageIndices := @FSample_info.Current_buffer;

    //  VK_KHR_incremental_present

    result := vkQueuePresentKHR(FSample_info.Present_queue, @present);

    case result of
    VK_ERROR_OUT_OF_DATE_KHR:
      begin
        DestroyAndPrepere_forResize();
      end;
    VK_SUBOPTIMAL_KHR:
      begin
      end;
    VK_ERROR_SURFACE_LOST_KHR:
      begin
        // recreate surface
          vkDestroySurfaceKHR(FSample_Info.Inst, FSample_Info.Surface, nil);
          init_surface(FSample_Info);
          DestroyAndPrepere_forResize();
      end;
    else
      Assert(result = VK_SUCCESS);
    end;

  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  FormPaint(self, Canvas, ClientRect);
end;

procedure TMainForm.DestroyAndPrepere_forResize();
begin
  if FVulkanReady then
  begin
    FVulkanReady := false;
    vkDeviceWaitIdle(FSample_info.Device);

    destroy_framebuffers(FSample_info);
    destroy_descriptor_pool(FSample_info);
    destroy_pipeline(FSample_info);
    destroy_pipeline_cache(FSample_info);
    destroy_renderpass(FSample_info);
    destroy_descriptor_and_pipeline_layouts(FSample_info);
    destroy_textures(FSample_info);
    destroy_depth_buffer(FSample_info);
    destroy_swap_chain(FSample_info, true);
    destroy_command_buffer(FSample_info);
    destroy_command_pool(FSample_info);
    destroy_semaphore_and_fences(FSample_info);
    PrepareVulkan();
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if FVulkanReady then
  begin
    FVulkanReady := false;
    vkDeviceWaitIdle(FSample_info.Device);

    destroy_framebuffers(FSample_info);
    destroy_descriptor_pool(FSample_info);
    destroy_pipeline(FSample_info);
    destroy_pipeline_cache(FSample_info);
    destroy_renderpass(FSample_info);
    destroy_descriptor_and_pipeline_layouts(FSample_info);
    destroy_textures(FSample_info);
    destroy_depth_buffer(FSample_info);
    destroy_swap_chain(FSample_info);
    destroy_command_buffer(FSample_info);
    destroy_command_pool(FSample_info);
    destroy_uniform_buffer(FSample_info);
    destroy_semaphore_and_fences(FSample_info);
    destroy_shaders(FSample_info);
    destroy_device(FSample_info);
    destroy_instance(FSample_info);
  end;
end;

initialization

{$ifdef IOS}
  GlobalUseMetal := true;
{$endif}

end.
