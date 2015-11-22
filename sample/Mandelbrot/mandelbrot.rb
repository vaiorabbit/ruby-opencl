require_relative '../util/clu'

# Load DLL
begin
  OpenCL.load_lib('c:/Windows/System32/OpenCL.dll') # For Windows
rescue
  OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
end

include OpenCL

def save_tga(image, w, h, name = "#{Time.now.strftime('%Y%m%d-%H%M%S')}.tga")
  File.open( name, 'wb' ) do |fout|
    fout.write [0].pack('c')      # identsize
    fout.write [0].pack('c')      # colourmaptype
    fout.write [2].pack('c')      # imagetype
    fout.write [0].pack('s')      # colourmapstart
    fout.write [0].pack('s')      # colourmaplength
    fout.write [0].pack('c')      # colourmapbits
    fout.write [0].pack('s')      # xstart
    fout.write [0].pack('s')      # ystart
    fout.write [w].pack('s')      # image_width
    fout.write [h].pack('s')      # image_height
    fout.write [8 * 4].pack('c')  # image_bits_per_pixel
    fout.write [8].pack('c')      # descriptor
    fout.write image[0, w*h*4]
  end
end

$img_w = 4096
$img_h = 4096

if $0 == __FILE__
  clu_platform = CLUPlatform.new
  clu_device = CLUDevice.new(clu_platform[0], CL_DEVICE_TYPE_DEFAULT)
  clu_ctx = CLUContext.newContext(nil, clu_device.devices)

  kernel_source = File.read("mandelbrot.cl")
  clu_prog = CLUProgram.newProgramWithSource(clu_ctx, [kernel_source])
  clu_prog.buildProgram(clu_device.devices)
  clu_kern = CLUKernel.newKernel(clu_prog, "mandelbrot")

  clu_cq = CLUCommandQueue.newCommandQueue(clu_ctx, clu_device[0])

  step = 4
  host_img = Fiddle::Pointer.malloc(step * $img_w * $img_h)
  device_img = CLUMemory.newBuffer(clu_ctx, CL_MEM_WRITE_ONLY, host_img.size)

  clu_kern.setKernelArg(0, Fiddle::TYPE_VOIDP, [device_img.handle.to_i])
  clu_kern.setKernelArg(1, Fiddle::TYPE_INT, [step])

  global_work_offset = nil
  global_work_size = [$img_w, $img_h]
  local_work_size = nil
  clu_cq.enqueueNDRangeKernel(clu_kern, 2, global_work_offset, global_work_size, local_work_size)

  clu_cq.enqueueReadBuffer(device_img, CL_TRUE, 0, host_img.size, host_img)

  save_tga(host_img, $img_w, $img_h)

  device_img.release
  clu_cq.release
  clu_kern.release
  clu_prog.release
  clu_ctx.release
  clu_device.release
end
