require_relative '../../lib/opencl'

# Load DLL
begin
  OpenCL.load_lib('c:/Windows/System32/OpenCL.dll') # For Windows
rescue
  OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
end

cl_platforms_buf = ' ' * 4

OpenCL.clGetPlatformIDs(1, cl_platforms_buf, nil)
cl_platform = cl_platforms_buf.unpack("L")[0]
platform_info_buf_size = 1024
platform_info_buf = ' ' * platform_info_buf_size
platform_info_ret_size_buf = ' ' * 4

enum2name = {
  OpenCL::CL_PLATFORM_PROFILE => "CL_PLATFORM_PROFILE",
  OpenCL::CL_PLATFORM_VERSION => "CL_PLATFORM_VERSION",
  OpenCL::CL_PLATFORM_NAME => "CL_PLATFORM_NAME",
  OpenCL::CL_PLATFORM_VENDOR => "CL_PLATFORM_VENDOR",
  OpenCL::CL_PLATFORM_EXTENSIONS => "CL_PLATFORM_EXTENSIONS"
}

[OpenCL::CL_PLATFORM_PROFILE, OpenCL::CL_PLATFORM_VERSION, OpenCL::CL_PLATFORM_NAME, OpenCL::CL_PLATFORM_VENDOR, OpenCL::CL_PLATFORM_EXTENSIONS].each do |param|
  OpenCL.clGetPlatformInfo(cl_platform, param, platform_info_buf_size, platform_info_buf, platform_info_ret_size_buf)
  platform_info_ret_size = platform_info_ret_size_buf.unpack("L")[0]
  puts "#{enum2name[param]} : #{platform_info_buf[0...(platform_info_ret_size-1)]}"
end

#
# Mac mini (Late 2014) El Capitan :
#
# CL_PLATFORM_PROFILE : FULL_PROFILE
# CL_PLATFORM_VERSION : OpenCL 1.2 (Sep 21 2015 19:24:11)
# CL_PLATFORM_NAME : Apple
# CL_PLATFORM_VENDOR : Apple
# CL_PLATFORM_EXTENSIONS : cl_APPLE_SetMemObjectDestructor cl_APPLE_ContextLoggingFunctions cl_APPLE_clut cl_APPLE_query_kernel_names cl_APPLE_gl_sharing cl_khr_gl_event
