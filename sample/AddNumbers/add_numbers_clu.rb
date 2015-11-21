# A Gentle Introduction to OpenCL
# By Matthew Scarpino, August 03, 2011
# http://www.drdobbs.com/parallel/a-gentle-introduction-to-opencl/231002854

require_relative '../util/clu'

# Load DLL
begin
  OpenCL.load_lib('c:/Windows/System32/OpenCL.dll') # For Windows
rescue
  OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
end

include OpenCL

PROGRAM_FILE = "add_numbers.cl"
KERNEL_FUNC = "add_numbers"
ARRAY_SIZE = 64

if $0 == __FILE__
  # Data and buffers
  data = (0...ARRAY_SIZE).collect { |i| 1.0 * i }
  sum = [0.0, 0.0]
  input_buffer = nil # cl_mem
  sum_buffer = nil   # cl_mem
  num_groups = 0     # cl_int
  err_buf = ' ' * 4

  # Create device and context
  clu_platform = CLUPlatform.new
  clu_device = CLUDevice.new(clu_platform.platforms[0], CL_DEVICE_TYPE_DEFAULT)
  clu_ctx = CLUContext.newContext(nil, clu_device.devices)
  abort("Couldn't create a context") if clu_ctx == nil

  # Build program
  kernel_source = File.read(PROGRAM_FILE)
  clu_prog = CLUProgram.newProgramWithSource(clu_ctx.context, [kernel_source])
  clu_prog.buildProgram(clu_device.devices)

  # Create data buffer
  global_size = 8
  local_size = 4
  num_groups = global_size/local_size
  input_buffer = CLUMemory.newBuffer(clu_ctx.context, CL_MEM_READ_ONLY  | CL_MEM_COPY_HOST_PTR, ARRAY_SIZE * Fiddle::SIZEOF_FLOAT, data.pack("F*"))
  sum_buffer   = CLUMemory.newBuffer(clu_ctx.context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, num_groups * Fiddle::SIZEOF_FLOAT, sum.pack("F*"))

  abort("Couldn't create a buffer") if input_buffer == nil || sum_buffer == nil

  # Create a command queue
  clu_cq = CLUCommandQueue.newCommandQueue(clu_ctx.context, clu_device.devices[0])
  abort("Couldn't create a command queue") if clu_cq == nil

  # Create a kernel
  clu_kern = CLUKernel.newKernel(clu_prog.program, KERNEL_FUNC)
  abort("Couldn't create a kernel") if clu_kern == nil

  # Create kernel arguments
  err  = clu_kern.setKernelArg(0, Fiddle::TYPE_VOIDP, [input_buffer.mem.to_i]) # __global
  err |= clu_kern.setLocalKernelArg(1, local_size * Fiddle::SIZEOF_FLOAT)      # __local
  err |= clu_kern.setKernelArg(2, Fiddle::TYPE_VOIDP, [sum_buffer.mem.to_i])   # __global
  abort("Couldn't create a kernel argument") if err < 0

  # Enqueue kernel
  err = clu_cq.enqueueNDRangeKernel(clu_kern.kernel, 1, nil, [global_size], [local_size])
  abort("Couldn't enqueue the kernel") if err < 0

  # Read the kernel's output
  sum_buf = ' ' * 4 * num_groups
  err = clu_cq.enqueueReadBuffer(sum_buffer.mem, CL_TRUE, 0, Fiddle::SIZEOF_FLOAT * num_groups, sum_buf)
  sum = sum_buf.unpack("F#{num_groups}")
  abort("Couldn't read the buffer") if err < 0

  # Check result
  total = sum.inject(:+)
  printf("Computed sum = %.1f.\n", total)
  actual_sum = (ARRAY_SIZE/2*(ARRAY_SIZE-1)).to_f
  result = (total - actual_sum).abs > 0.01*(actual_sum).abs ? "failed" : "passed"
  puts("Check #{result}.")

  # Deallocate resources
  clu_kern.release
  sum_buffer.release
  input_buffer.release
  clu_cq.release
  clu_prog.release
  clu_ctx.release
end
