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
clu_ctx = CLUContext.newContext(nil, [clu_device[0]])

# Command Queues
clu_cq = CLUCommandQueue.newCommandQueue(clu_ctx, clu_device[0])

# Memory Buffer
MEM_SIZE = 128
clu_memobj = CLUMemory.newBuffer(clu_ctx.context, CL_MEM_READ_WRITE, MEM_SIZE * Fiddle:: SIZEOF_CHAR)

# Program
clu_prog = CLUProgram.newProgramWithSource(clu_ctx, [File.read("hello.cl")])
clu_prog.buildProgram([clu_device[0]])

# Kernel
clu_kern = CLUKernel.newKernel(clu_prog, "hello")

# Execute
clu_kern.setKernelArg(0, Fiddle::TYPE_VOIDP, [clu_memobj.handle.to_i])
clu_cq.enqueueTask(clu_kern)

# Result
result_buf = ' ' * MEM_SIZE
clu_cq.enqueueReadBuffer(clu_memobj, CL_TRUE, 0, MEM_SIZE * Fiddle::SIZEOF_CHAR, result_buf)
puts result_buf # => Hello, World!

# End
clu_cq.flush
clu_cq.finish
clu_kern.release
clu_prog.release
clu_memobj.release
clu_cq.release
clu_ctx.release
