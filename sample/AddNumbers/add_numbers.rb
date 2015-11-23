# A Gentle Introduction to OpenCL
# By Matthew Scarpino, August 03, 2011
# http://www.drdobbs.com/parallel/a-gentle-introduction-to-opencl/231002854

require 'opencl'

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

# Find a GPU or CPU associated with the first available platform
def create_device()
  # Identify a platform
  platforms_buf = ' ' * 4 * 32
  err = clGetPlatformIDs(1, platforms_buf, nil)
  platform = platforms_buf.unpack("L")[0]
  abort("Couldn't identify a platform") if err < 0

  # Access a device
  dev_buf = ' ' * 4 * 32
  err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, dev_buf, nil)
  if err == CL_DEVICE_NOT_FOUND
    err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_CPU, 1, dev_buf, nil)
  end
  abort("Couldn't access any devices") if err < 0

  return dev_buf.unpack("Q")[0]
end


# Create program from a file and compile it
# cl_context : ctx, cl_device_id : dev, const char* : filename
def build_program(ctx, dev, filename)
  abort("Couldn't find the program file") if not File.exists?(filename)

  # Read program file and place content into buffer
  program_buffer = File.read(filename)

  # Create program from file
  err_buf = ' ' * 4
  program = clCreateProgramWithSource(ctx, 1, [program_buffer].pack("p"), [program_buffer.bytesize].pack("Q"), err_buf)
  err = err_buf.unpack("l")[0]
  abort("Couldn't create the program") if err < 0

  # Build program
  err = clBuildProgram(program, 0, nil, nil, nil, nil)
  if err < 0
    # Find size of log and print to std output
    log_size_buf = ' ' * 4
    clGetProgramBuildInfo(program, dev, CL_PROGRAM_BUILD_LOG, 0, nil, log_size_buf)
    log_size = log_size_buf.unpack("L")[0]
    program_log = ' ' * log_size
    clGetProgramBuildInfo(program, dev, CL_PROGRAM_BUILD_LOG, log_size, program_log, nil)
    abort(program_log)
  end

  return program
end


if $0 == __FILE__
  # Data and buffers
  data = (0...ARRAY_SIZE).collect { |i| 1.0 * i }
  sum = [0.0, 0.0]
  input_buffer = nil # cl_mem
  sum_buffer = nil   # cl_mem
  num_groups = 0     # cl_int
  err_buf = ' ' * 4

  # Create device and context
  device = create_device()
  context = clCreateContext(nil, 1, [device].pack("Q"), nil, nil, err_buf)
  err = err_buf.unpack("l")[0]
  abort("Couldn't create a context") if err < 0

  # Build program
  program = build_program(context, device, PROGRAM_FILE)

  # Create data buffer
  global_size = 8
  local_size = 4
  num_groups = global_size/local_size
  input_buffer = clCreateBuffer(context, CL_MEM_READ_ONLY  | CL_MEM_COPY_HOST_PTR, ARRAY_SIZE * Fiddle::SIZEOF_FLOAT, data.pack("F*"), err_buf)
  sum_buffer   = clCreateBuffer(context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, num_groups * Fiddle::SIZEOF_FLOAT, sum.pack("F*"),  err_buf)
  err = err_buf.unpack("l")[0]
  abort("Couldn't create a buffer") if err < 0

  # Create a command queue
  queue = clCreateCommandQueue(context, device, 0, err_buf)
  err = err_buf.unpack("l")[0]
  abort("Couldn't create a command queue") if err < 0

  # Create a kernel
  kernel = clCreateKernel(program, KERNEL_FUNC, err_buf)
  err = err_buf.unpack("l")[0]
  abort("Couldn't create a kernel") if err < 0

  # Create kernel arguments
  err  = clSetKernelArg(kernel, 0, Fiddle::SIZEOF_VOIDP, [input_buffer.to_i].pack("Q"))
  err |= clSetKernelArg(kernel, 1, local_size * Fiddle::SIZEOF_FLOAT, nil)
  err |= clSetKernelArg(kernel, 2, Fiddle::SIZEOF_VOIDP, [sum_buffer.to_i].pack("Q"))
  abort("Couldn't create a kernel argument") if err < 0

  # Enqueue kernel
  err = clEnqueueNDRangeKernel(queue, kernel, 1, nil, [global_size].pack("Q"), [local_size].pack("Q"), 0, nil, nil)
  abort("Couldn't enqueue the kernel") if err < 0

  # Read the kernel's output
  sum_buf = ' ' * 4 * num_groups
  err = clEnqueueReadBuffer(queue, sum_buffer, CL_TRUE, 0, Fiddle::SIZEOF_FLOAT * num_groups, sum_buf, 0, nil, nil)
  sum = sum_buf.unpack("F#{num_groups}")
  abort("Couldn't read the buffer") if err < 0

  # Check result
  total = sum.inject(:+)
  printf("Computed sum = %.1f.\n", total)
  actual_sum = (ARRAY_SIZE/2*(ARRAY_SIZE-1)).to_f
  result = (total - actual_sum).abs > 0.01*(actual_sum).abs ? "failed" : "passed"
  puts("Check #{result}.")

  # Deallocate resources
  clReleaseKernel(kernel)
  clReleaseMemObject(sum_buffer)
  clReleaseMemObject(input_buffer)
  clReleaseCommandQueue(queue)
  clReleaseProgram(program)
  clReleaseContext(context)
end
