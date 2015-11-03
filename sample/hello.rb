#
# Usage : $ ruby hello.rb
#         Hello, World!
#
# Ref.: http://www.fixstars.com/en/opencl/book/sample/
#
require_relative '../lib/opencl'

# Load DLL
OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
# OpenCL.load_lib('c:/Program Files/NVIDIA Corporation/OpenCL/OpenCL64.dll') # For Windows x86-64 NVIDIA GPU (* comes with NVIDIA Driver)

cl_platforms_buf = ' ' * 4
cl_platforms_count_buf = ' ' * 4

include OpenCL

# Prepare source
source_str = File.read("hello.cl")

# Platform
clGetPlatformIDs(1, cl_platforms_buf, cl_platforms_count_buf)
cl_platform = cl_platforms_buf.unpack("L")[0]

# Devices
cl_devices_buf_writable_count = 32
cl_devices_buf = ' ' * 4 * cl_devices_buf_writable_count
cl_devices_entry_count_buf = ' ' * 4

clGetDeviceIDs(cl_platform, CL_DEVICE_TYPE_DEFAULT, cl_devices_buf_writable_count, cl_devices_buf, cl_devices_entry_count_buf)
cl_devices_entry_count = cl_devices_entry_count_buf.unpack("L")[0]
cl_device_ids = cl_devices_buf.unpack("Q#{cl_devices_entry_count}")

# Context
errcode_ret_buf = ' ' * 4
cl_ctx = OpenCL.clCreateContext(nil, 1, cl_devices_buf, nil, nil, errcode_ret_buf)
# p errcode_ret_buf.unpack("l")[0]

# Command Queues
cl_cq = clCreateCommandQueue(cl_ctx, cl_device_ids[0], 0, errcode_ret_buf)
# p errcode_ret_buf.unpack("l")[0]

# Memory Buffer
MEM_SIZE = 128
cl_memobj = clCreateBuffer(cl_ctx, CL_MEM_READ_WRITE, MEM_SIZE * Fiddle:: SIZEOF_CHAR, nil, errcode_ret_buf);
#buf_area = Fiddle::Pointer.malloc(MEM_SIZE)
#cl_memobj = clCreateBuffer(cl_ctx, CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR, MEM_SIZE * Fiddle:: SIZEOF_CHAR, [buf_area.to_i].pack("L"), errcode_ret_buf);
# cl_memobj.size = MEM_SIZE
# p errcode_ret_buf.unpack("l")[0]

# Program
cl_prog = clCreateProgramWithSource(cl_ctx, 1, [source_str].pack("p"), [source_str.bytesize].pack("Q"), errcode_ret_buf)
# p errcode_ret_buf.unpack("l")[0]

cb_args = [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]
cb_retval = Fiddle::TYPE_VOID

$notify_callback = nil
=begin
$notify_callback = Fiddle::Closure::BlockCaller.new( cb_retval, cb_args, Fiddle::Function::DEFAULT) { |program, user_data|
  p program, user_data
}
=end
clBuildProgram(cl_prog, 1, [cl_device_ids[0]].pack("Q"), nil, $notify_callback, nil)

cl_kern = clCreateKernel(cl_prog, "hello", errcode_ret_buf);
# p errcode_ret_buf.unpack("l")[0]

# Execute
clSetKernelArg(cl_kern, 0, Fiddle::SIZEOF_VOIDP, [cl_memobj.to_i].pack("Q"));
clEnqueueTask(cl_cq, cl_kern, 0, nil, nil)

# Result
result_buf = ' ' * MEM_SIZE
clEnqueueReadBuffer(cl_cq, cl_memobj, CL_TRUE, 0, MEM_SIZE * Fiddle::SIZEOF_CHAR, result_buf, 0, nil, nil)
puts result_buf # => Hello, World!

# End
clFlush(cl_cq)
clFinish(cl_cq)
clReleaseKernel(cl_kern)
clReleaseProgram(cl_prog)
clReleaseMemObject(cl_memobj)
clReleaseCommandQueue(cl_cq)
clReleaseContext(cl_ctx)

