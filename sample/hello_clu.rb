# An example using simple wrapper.
# For more samples, visit https://github.com/vaiorabbit/ruby-opencl/tree/master/sample .
#
# Usage : $ ruby hello_clu.rb
#         Hello, World!
#
# Ref.: http://www.fixstars.com/en/opencl/book/sample/

require_relative 'util/clu'

# Load DLL
begin
  OpenCL.load_lib('c:/Windows/System32/OpenCL.dll') # For Windows
rescue
  OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
end
include OpenCL

# Platform
clu_platform = CLUPlatform.new

# Devices
clu_device = CLUDevice.new(clu_platform.platforms[0], CL_DEVICE_TYPE_DEFAULT)

# Context
clu_ctx = CLUContext.newContext(nil, clu_device.devices)

# Command Queues
clu_cq = CLUCommandQueue.newCommandQueue(clu_ctx.context, clu_device.devices[0])

# Memory Buffer
MEM_SIZE = 128
clu_memobj = CLUMemory.newBuffer(clu_ctx.context, CL_MEM_READ_WRITE, MEM_SIZE * Fiddle:: SIZEOF_CHAR)

# Program
source_str = File.read("hello.cl")
clu_prog = CLUProgram.newProgramWithSource(clu_ctx.context, [source_str])
clu_prog.buildProgram(clu_device.devices)

# Kernel
clu_kern = CLUKernel.newKernel(clu_prog.program, "hello")

# Execute
clu_kern.setKernelArg(0, Fiddle::TYPE_VOIDP, [clu_memobj.mem.to_i])
clu_cq.enqueueTask(clu_kern.kernel)

# Result
result_buf = ' ' * MEM_SIZE
clu_cq.enqueueReadBuffer(clu_memobj.mem, CL_TRUE, 0, MEM_SIZE * Fiddle::SIZEOF_CHAR, result_buf)
puts result_buf # => Hello, World!

# End
clu_cq.flush
clu_cq.finish
clu_kern.releaseKernel
clu_prog.releaseProgram
clu_memobj.releaseMemObject
clu_cq.releaseCommandQueue
clu_ctx.releaseContext
