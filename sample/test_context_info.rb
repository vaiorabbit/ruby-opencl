require_relative '../lib/opencl'

OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
# OpenCL.load_lib('c:/Program Files/NVIDIA Corporation/OpenCL/OpenCL64.dll') # For Windows x86-64 NVIDIA GPU (* comes with NVIDIA Driver)
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

cprops = [OpenCL::CL_CONTEXT_PLATFORM, cl_platform, 0]

cb_args = [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, -Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP]
cb_retval = Fiddle::TYPE_VOID

$notify_callback = Fiddle::Closure::BlockCaller.new( cb_retval, cb_args, Fiddle::Function::DEFAULT) { |errinfo, private_info, cb, user_data|
  p user_data
}

user_data_buf = ""
errcode_ret_buf = ' ' * 4
cl_ctx = OpenCL.clCreateContext(cprops.pack("Q#{cprops.length}"), cl_devices_entry_count, cl_devices_buf, $notify_callback, user_data_buf, errcode_ret_buf)

# p errcode_ret_buf.unpack("l")[0].to_s

enum2name = {
  OpenCL::CL_CONTEXT_REFERENCE_COUNT => "CL_CONTEXT_REFERENCE_COUNT",
  OpenCL::CL_CONTEXT_DEVICES => "CL_CONTEXT_DEVICES",
  OpenCL::CL_CONTEXT_PROPERTIES => "CL_CONTEXT_PROPERTIES",
  OpenCL::CL_CONTEXT_NUM_DEVICES => "CL_CONTEXT_NUM_DEVICES"
}
[
  [OpenCL::CL_CONTEXT_REFERENCE_COUNT, "L", 4],
  [OpenCL::CL_CONTEXT_DEVICES, "Q", 8],
  [OpenCL::CL_CONTEXT_PROPERTIES, "Q", 8],
  [OpenCL::CL_CONTEXT_NUM_DEVICES, "L", 4],
].each do |param|
  param_value_buf = ' ' * 1024
  param_value_byte_ret_buf = ' ' * 4
  OpenCL.clGetContextInfo(cl_ctx, param[0], 1024, param_value_buf, param_value_byte_ret_buf)
  param_value_byte_ret = param_value_byte_ret_buf.unpack("L")[0]
  puts "#{enum2name[param[0]]} = #{param_value_buf.unpack(param[1]+(param_value_byte_ret/param[2]).to_s)}"
end

OpenCL.clReleaseContext(cl_ctx)
