require_relative '../../lib/opencl'

# Load DLL
begin
  OpenCL.load_lib('c:/Windows/System32/OpenCL.dll') # For Windows
rescue
  OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
end

cl_platforms_buf = ' ' * 4

# Platform
OpenCL.clGetPlatformIDs(1, cl_platforms_buf, nil)
cl_platform = cl_platforms_buf.unpack("L")[0]

# Devices
cl_devices_buf_writable_count = 32
cl_devices_buf = ' ' * 4 * cl_devices_buf_writable_count
cl_devices_entry_count_buf = ' ' * 4

OpenCL.clGetDeviceIDs(cl_platform, OpenCL::CL_DEVICE_TYPE_ALL, cl_devices_buf_writable_count, cl_devices_buf, cl_devices_entry_count_buf)
cl_devices_entry_count = cl_devices_entry_count_buf.unpack("L")[0]
cl_device_ids = cl_devices_buf.unpack("Q#{cl_devices_entry_count}")

# Context
ctxprops = [OpenCL::CL_CONTEXT_PLATFORM, cl_platform, 0]

cb_args = [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, -Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP]
cb_retval = Fiddle::TYPE_VOID

$notify_callback = Fiddle::Closure::BlockCaller.new( cb_retval, cb_args, Fiddle::Function::DEFAULT) { |errinfo, private_info, cb, user_data|
  p user_data
}

user_data_buf = ""
errcode_ret_buf = ' ' * 4
cl_ctx = OpenCL.clCreateContext(ctxprops.pack("Q#{ctxprops.length}"), cl_devices_entry_count, cl_devices_buf, $notify_callback, user_data_buf, errcode_ret_buf)

#p errcode_ret_buf.unpack("l")[0].to_s

# Command Queues
cqprops = [OpenCL::CL_CONTEXT_PLATFORM, cl_platform, 0]

cl_cq0 = OpenCL.clCreateCommandQueue(cl_ctx, cl_device_ids[0], 0, errcode_ret_buf)
cl_cq1 = OpenCL.clCreateCommandQueue(cl_ctx, cl_device_ids[1], 0, errcode_ret_buf)
cl_cqs = [cl_cq0, cl_cq1]

enum2name = {
  OpenCL::CL_QUEUE_REFERENCE_COUNT => "CL_QUEUE_REFERENCE_COUNT",
  OpenCL::CL_QUEUE_DEVICE => "CL_QUEUE_DEVICE",
  OpenCL::CL_QUEUE_PROPERTIES => "CL_QUEUE_PROPERTIES",
  OpenCL::CL_QUEUE_CONTEXT => "CL_QUEUE_CONTEXT"
}

cl_cqs.each_with_index do |cl_cq, idx|
  next if cl_cq.null?
  [
    [OpenCL::CL_QUEUE_REFERENCE_COUNT, "L", 4],
    [OpenCL::CL_QUEUE_DEVICE, "Q", 8],
    [OpenCL::CL_QUEUE_PROPERTIES, "Q", 8],
    [OpenCL::CL_QUEUE_CONTEXT, "L", 4],
  ].each do |param|
    param_value_buf = ' ' * 1024
    param_value_byte_ret_buf = ' ' * 4
    OpenCL.clGetCommandQueueInfo(cl_cq, param[0], 1024, param_value_buf, param_value_byte_ret_buf)
    param_value_byte_ret = param_value_byte_ret_buf.unpack("L")[0]
    puts "cq#{idx} : #{enum2name[param[0]]} = #{param_value_buf.unpack(param[1]+(param_value_byte_ret/param[2]).to_s)}"
  end
end

cl_cqs.each do |cl_cq|
  OpenCL.clReleaseCommandQueue(cl_cq)
end
OpenCL.clReleaseContext(cl_ctx)
