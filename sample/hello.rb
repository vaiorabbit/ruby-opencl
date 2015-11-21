#
# Usage : $ ruby hello.rb
#         Hello, World!
#
# Ref.: http://www.fixstars.com/en/opencl/book/sample/
#
require_relative '../lib/opencl'

# Load DLL
begin
  OpenCL.load_lib('c:/Windows/System32/OpenCL.dll') # For Windows
rescue
  OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
end
include OpenCL

# Platform
cl_platforms_buf = ' ' * 4
cl_platforms_count_buf = ' ' * 4
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

# Command Queues
cl_cq = clCreateCommandQueue(cl_ctx, cl_device_ids[0], 0, errcode_ret_buf)

# Memory Buffer
MEM_SIZE = 128
cl_memobj = clCreateBuffer(cl_ctx, CL_MEM_READ_WRITE, MEM_SIZE * Fiddle:: SIZEOF_CHAR, nil, errcode_ret_buf)

# Program
source_str = File.read("hello.cl")
cl_prog = clCreateProgramWithSource(cl_ctx, 1, [source_str].pack("p"), [source_str.bytesize].pack("Q"), errcode_ret_buf)
clBuildProgram(cl_prog, 1, [cl_device_ids[0]].pack("Q"), nil, nil, nil)

# Kernel
cl_kern = clCreateKernel(cl_prog, "hello", errcode_ret_buf)

# Execute
clSetKernelArg(cl_kern, 0, Fiddle::SIZEOF_VOIDP, [cl_memobj.to_i].pack("Q"))
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
