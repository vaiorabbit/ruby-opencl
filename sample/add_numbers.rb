# A Gentle Introduction to OpenCL
# By Matthew Scarpino, August 03, 2011
# http://www.drdobbs.com/parallel/a-gentle-introduction-to-opencl/231002854

require_relative '../lib/opencl'
# Load DLL
OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
# OpenCL.load_lib('c:/Program Files/NVIDIA Corporation/OpenCL/OpenCL64.dll') # For Windows x86-64 NVIDIA GPU (* comes with NVIDIA Driver)

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
  if err < 0
    $stderr.puts("Couldn't identify a platform")
    exit(1)
  end

  # Access a device
  dev_buf = ' ' * 4 * 32
  err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, dev_buf, nil)
  if err == CL_DEVICE_NOT_FOUND
    err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_CPU, 1, dev_buf, nil)
  end
  if err < 0
    $stderr.puts("Couldn't access any devices")
    exit(1)
  end
  dev = dev_buf.unpack("Q")[0]

  return dev
end


# Create program from a file and compile it
# cl_context : ctx, cl_device_id : dev, const char* : filename
def build_program(ctx, dev, filename)
  if not File.exists?(filename)
    $stderr.puts("Couldn't find the program file")
    exit(1)
  end

  # Read program file and place content into buffer
  program_buffer = File.read(filename)

  # Create program from file
  err_buf = ' ' * 4
  program = clCreateProgramWithSource(ctx, 1, [program_buffer].pack("p"), [program_buffer.bytesize].pack("Q"), err_buf)
  err = err_buf.unpack("l")[0]
  if err < 0
    $stderr.puts("Couldn't create the program")
    exit(1)
  end

  # Build program
  err = clBuildProgram(program, 0, nil, nil, nil, nil)
  if err < 0
    # Find size of log and print to std output
    log_size_buf = ' ' * 4
    clGetProgramBuildInfo(program, dev, CL_PROGRAM_BUILD_LOG, 0, nil, log_size_buf)
    log_size = log_size_buf.unpack("L")[0]
    program_log = ' ' * log_size
    clGetProgramBuildInfo(program, dev, CL_PROGRAM_BUILD_LOG, log_size, program_log, nil)
    printf("%s\n", program_log)
    exit(1)
  end

  return program
end

if $0 == __FILE__

  # Create device and context
  device = create_device()
  err_buf = ' ' * 4
  context = clCreateContext(nil, 1, [device].pack("Q"), nil, nil, err_buf)
  err = err_buf.unpack("l")[0]
  if err < 0
    $stderr.puts("Couldn't create a context")
    exit(1)
  end

  # Build program
  program = build_program(context, device, PROGRAM_FILE)
p program
end

