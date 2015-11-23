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

cl_devices_buf_writable_count = 32
cl_devices_buf = ' ' * 4 * cl_devices_buf_writable_count
cl_devices_entry_count_buf = ' ' * 4

OpenCL.clGetDeviceIDs(cl_platform, OpenCL::CL_DEVICE_TYPE_ALL, cl_devices_buf_writable_count, cl_devices_buf, cl_devices_entry_count_buf)
cl_devices_entry_count = cl_devices_entry_count_buf.unpack("L")[0]
cl_device_ids = cl_devices_buf.unpack("Q#{cl_devices_entry_count}")
p cl_devices_entry_count, cl_device_ids

cl_devices_info_buf_length = 1024
cl_devices_info_buf = ' ' * cl_devices_info_buf_length
cl_devices_info_length_buf = ' ' * 4
cl_devices_info_length = 0

enum2name =  {
    OpenCL::CL_DEVICE_TYPE => "CL_DEVICE_TYPE",
    OpenCL::CL_DEVICE_VENDOR_ID => "CL_DEVICE_VENDOR_ID",
    OpenCL::CL_DEVICE_MAX_COMPUTE_UNITS => "CL_DEVICE_MAX_COMPUTE_UNITS",
    OpenCL::CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS => "CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS",
    OpenCL::CL_DEVICE_MAX_WORK_GROUP_SIZE => "CL_DEVICE_MAX_WORK_GROUP_SIZE",
    OpenCL::CL_DEVICE_MAX_WORK_ITEM_SIZES => "CL_DEVICE_MAX_WORK_ITEM_SIZES",
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR => "CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR",
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT => "CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT",
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT => "CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT",
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG => "CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG",
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT => "CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT",
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE => "CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE",
    OpenCL::CL_DEVICE_MAX_CLOCK_FREQUENCY => "CL_DEVICE_MAX_CLOCK_FREQUENCY",
    OpenCL::CL_DEVICE_ADDRESS_BITS => "CL_DEVICE_ADDRESS_BITS",
    OpenCL::CL_DEVICE_MAX_READ_IMAGE_ARGS => "CL_DEVICE_MAX_READ_IMAGE_ARGS",
    OpenCL::CL_DEVICE_MAX_WRITE_IMAGE_ARGS => "CL_DEVICE_MAX_WRITE_IMAGE_ARGS",
    OpenCL::CL_DEVICE_MAX_MEM_ALLOC_SIZE => "CL_DEVICE_MAX_MEM_ALLOC_SIZE",
    OpenCL::CL_DEVICE_IMAGE2D_MAX_WIDTH => "CL_DEVICE_IMAGE2D_MAX_WIDTH",
    OpenCL::CL_DEVICE_IMAGE2D_MAX_HEIGHT => "CL_DEVICE_IMAGE2D_MAX_HEIGHT",
    OpenCL::CL_DEVICE_IMAGE3D_MAX_WIDTH => "CL_DEVICE_IMAGE3D_MAX_WIDTH",
    OpenCL::CL_DEVICE_IMAGE3D_MAX_HEIGHT => "CL_DEVICE_IMAGE3D_MAX_HEIGHT",
    OpenCL::CL_DEVICE_IMAGE3D_MAX_DEPTH => "CL_DEVICE_IMAGE3D_MAX_DEPTH",
    OpenCL::CL_DEVICE_IMAGE_SUPPORT => "CL_DEVICE_IMAGE_SUPPORT",
    OpenCL::CL_DEVICE_MAX_PARAMETER_SIZE => "CL_DEVICE_MAX_PARAMETER_SIZE",
    OpenCL::CL_DEVICE_MAX_SAMPLERS => "CL_DEVICE_MAX_SAMPLERS",
    OpenCL::CL_DEVICE_MEM_BASE_ADDR_ALIGN => "CL_DEVICE_MEM_BASE_ADDR_ALIGN",
    OpenCL::CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE => "CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE",
    OpenCL::CL_DEVICE_SINGLE_FP_CONFIG => "CL_DEVICE_SINGLE_FP_CONFIG",
    OpenCL::CL_DEVICE_GLOBAL_MEM_CACHE_TYPE => "CL_DEVICE_GLOBAL_MEM_CACHE_TYPE",
    OpenCL::CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE => "CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE",
    OpenCL::CL_DEVICE_GLOBAL_MEM_CACHE_SIZE => "CL_DEVICE_GLOBAL_MEM_CACHE_SIZE",
    OpenCL::CL_DEVICE_GLOBAL_MEM_SIZE => "CL_DEVICE_GLOBAL_MEM_SIZE",
    OpenCL::CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE => "CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE",
    OpenCL::CL_DEVICE_MAX_CONSTANT_ARGS => "CL_DEVICE_MAX_CONSTANT_ARGS",
    OpenCL::CL_DEVICE_LOCAL_MEM_TYPE => "CL_DEVICE_LOCAL_MEM_TYPE",
    OpenCL::CL_DEVICE_LOCAL_MEM_SIZE => "CL_DEVICE_LOCAL_MEM_SIZE",
    OpenCL::CL_DEVICE_ERROR_CORRECTION_SUPPORT => "CL_DEVICE_ERROR_CORRECTION_SUPPORT",
    OpenCL::CL_DEVICE_PROFILING_TIMER_RESOLUTION => "CL_DEVICE_PROFILING_TIMER_RESOLUTION",
    OpenCL::CL_DEVICE_ENDIAN_LITTLE => "CL_DEVICE_ENDIAN_LITTLE",
    OpenCL::CL_DEVICE_AVAILABLE => "CL_DEVICE_AVAILABLE",
    OpenCL::CL_DEVICE_COMPILER_AVAILABLE => "CL_DEVICE_COMPILER_AVAILABLE",
    OpenCL::CL_DEVICE_EXECUTION_CAPABILITIES => "CL_DEVICE_EXECUTION_CAPABILITIES",
    OpenCL::CL_DEVICE_QUEUE_PROPERTIES => "CL_DEVICE_QUEUE_PROPERTIES",
    OpenCL::CL_DEVICE_NAME => "CL_DEVICE_NAME",
    OpenCL::CL_DEVICE_VENDOR => "CL_DEVICE_VENDOR",
    OpenCL::CL_DRIVER_VERSION => "CL_DRIVER_VERSION",
    OpenCL::CL_DEVICE_PROFILE => "CL_DEVICE_PROFILE",
    OpenCL::CL_DEVICE_VERSION => "CL_DEVICE_VERSION",
    OpenCL::CL_DEVICE_EXTENSIONS => "CL_DEVICE_EXTENSIONS",
    OpenCL::CL_DEVICE_PLATFORM => "CL_DEVICE_PLATFORM",
    OpenCL::CL_DEVICE_DOUBLE_FP_CONFIG => "CL_DEVICE_DOUBLE_FP_CONFIG",
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF => "CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF",
    OpenCL::CL_DEVICE_HOST_UNIFIED_MEMORY => "CL_DEVICE_HOST_UNIFIED_MEMORY",
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR => "CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR",
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT => "CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT",
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_INT => "CL_DEVICE_NATIVE_VECTOR_WIDTH_INT",
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG => "CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG",
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT => "CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT",
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE => "CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE",
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF => "CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF",
    OpenCL::CL_DEVICE_OPENCL_C_VERSION => "CL_DEVICE_OPENCL_C_VERSION",
    OpenCL::CL_DEVICE_LINKER_AVAILABLE => "CL_DEVICE_LINKER_AVAILABLE",
    OpenCL::CL_DEVICE_BUILT_IN_KERNELS => "CL_DEVICE_BUILT_IN_KERNELS",
    OpenCL::CL_DEVICE_IMAGE_MAX_BUFFER_SIZE => "CL_DEVICE_IMAGE_MAX_BUFFER_SIZE",
    OpenCL::CL_DEVICE_IMAGE_MAX_ARRAY_SIZE => "CL_DEVICE_IMAGE_MAX_ARRAY_SIZE",
    OpenCL::CL_DEVICE_PARENT_DEVICE => "CL_DEVICE_PARENT_DEVICE",
    OpenCL::CL_DEVICE_PARTITION_MAX_SUB_DEVICES => "CL_DEVICE_PARTITION_MAX_SUB_DEVICES",
    OpenCL::CL_DEVICE_PARTITION_PROPERTIES => "CL_DEVICE_PARTITION_PROPERTIES",
    OpenCL::CL_DEVICE_PARTITION_AFFINITY_DOMAIN => "CL_DEVICE_PARTITION_AFFINITY_DOMAIN",
    OpenCL::CL_DEVICE_PARTITION_TYPE => "CL_DEVICE_PARTITION_TYPE",
    OpenCL::CL_DEVICE_REFERENCE_COUNT => "CL_DEVICE_REFERENCE_COUNT",
    OpenCL::CL_DEVICE_PREFERRED_INTEROP_USER_SYNC => "CL_DEVICE_PREFERRED_INTEROP_USER_SYNC",
    OpenCL::CL_DEVICE_PRINTF_BUFFER_SIZE => "CL_DEVICE_PRINTF_BUFFER_SIZE",
    OpenCL::CL_DEVICE_IMAGE_PITCH_ALIGNMENT => "CL_DEVICE_IMAGE_PITCH_ALIGNMENT",
    OpenCL::CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT => "CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT"
}

work_item_dimensions = 0
cl_device_ids.each do |device|
  [
    [OpenCL::CL_DEVICE_TYPE, "L"],
    [OpenCL::CL_DEVICE_VENDOR_ID, "L"],
    [OpenCL::CL_DEVICE_MAX_COMPUTE_UNITS, "L"],
    [OpenCL::CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, "L"],
    [OpenCL::CL_DEVICE_MAX_WORK_GROUP_SIZE, "L"],
    [OpenCL::CL_DEVICE_MAX_WORK_ITEM_SIZES, "size_t[]"],
    [OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR, "L"],
    [OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT, "L"],
    [OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT, "L"],
    [OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG, "L"],
    [OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT, "L"],
    [OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE, "L"],
    [OpenCL::CL_DEVICE_MAX_CLOCK_FREQUENCY, "L"],
    [OpenCL::CL_DEVICE_ADDRESS_BITS, "L"],
    [OpenCL::CL_DEVICE_MAX_READ_IMAGE_ARGS, "L"],
    [OpenCL::CL_DEVICE_MAX_WRITE_IMAGE_ARGS, "L"],
    [OpenCL::CL_DEVICE_MAX_MEM_ALLOC_SIZE, "L"],
    [OpenCL::CL_DEVICE_IMAGE2D_MAX_WIDTH, "L"],
    [OpenCL::CL_DEVICE_IMAGE2D_MAX_HEIGHT, "L"],
    [OpenCL::CL_DEVICE_IMAGE3D_MAX_WIDTH, "L"],
    [OpenCL::CL_DEVICE_IMAGE3D_MAX_HEIGHT, "L"],
    [OpenCL::CL_DEVICE_IMAGE3D_MAX_DEPTH, "L"],
    [OpenCL::CL_DEVICE_IMAGE_SUPPORT, "cl_bool"],
    [OpenCL::CL_DEVICE_MAX_PARAMETER_SIZE, "L"],
    [OpenCL::CL_DEVICE_MAX_SAMPLERS, "L"],
    [OpenCL::CL_DEVICE_MEM_BASE_ADDR_ALIGN, "L"],
    [OpenCL::CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE, "L"],
    [OpenCL::CL_DEVICE_SINGLE_FP_CONFIG, "cl_bitfield"],
    [OpenCL::CL_DEVICE_GLOBAL_MEM_CACHE_TYPE, "L"],
    [OpenCL::CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE, "L"],
    [OpenCL::CL_DEVICE_GLOBAL_MEM_CACHE_SIZE, "L"],
    [OpenCL::CL_DEVICE_GLOBAL_MEM_SIZE, "L"],
    [OpenCL::CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE, "L"],
    [OpenCL::CL_DEVICE_MAX_CONSTANT_ARGS, "L"],
    [OpenCL::CL_DEVICE_LOCAL_MEM_TYPE, "L"],
    [OpenCL::CL_DEVICE_LOCAL_MEM_SIZE, "L"],
    [OpenCL::CL_DEVICE_ERROR_CORRECTION_SUPPORT, "cl_bool"],
    [OpenCL::CL_DEVICE_PROFILING_TIMER_RESOLUTION, "L"],
    [OpenCL::CL_DEVICE_ENDIAN_LITTLE, "cl_bool"],
    [OpenCL::CL_DEVICE_AVAILABLE, "cl_bool"],
    [OpenCL::CL_DEVICE_COMPILER_AVAILABLE, "cl_bool"],
    [OpenCL::CL_DEVICE_EXECUTION_CAPABILITIES, "L"],
    [OpenCL::CL_DEVICE_QUEUE_PROPERTIES, "cl_bitfield"],
    [OpenCL::CL_DEVICE_NAME, "char[]"],
    [OpenCL::CL_DEVICE_VENDOR, "char[]"],
    [OpenCL::CL_DRIVER_VERSION, "char[]"],
    [OpenCL::CL_DEVICE_PROFILE, "char[]"],
    [OpenCL::CL_DEVICE_VERSION, "char[]"],
    [OpenCL::CL_DEVICE_EXTENSIONS, "char[]"],
    [OpenCL::CL_DEVICE_PLATFORM, "Q"],
    [OpenCL::CL_DEVICE_DOUBLE_FP_CONFIG, "cl_bitfield"],
    [OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF, "L"],
    [OpenCL::CL_DEVICE_HOST_UNIFIED_MEMORY, "cl_bool"],
    [OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR, "L"],
    [OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT, "L"],
    [OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_INT, "L"],
    [OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG, "L"],
    [OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT, "L"],
    [OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE, "L"],
    [OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF, "L"],
    [OpenCL::CL_DEVICE_OPENCL_C_VERSION, "L"],
    [OpenCL::CL_DEVICE_LINKER_AVAILABLE, "cl_bool"],
    [OpenCL::CL_DEVICE_BUILT_IN_KERNELS, "char[]"],
    [OpenCL::CL_DEVICE_IMAGE_MAX_BUFFER_SIZE, "L"],
    [OpenCL::CL_DEVICE_IMAGE_MAX_ARRAY_SIZE, "L"],
    [OpenCL::CL_DEVICE_PARENT_DEVICE, "Q"],
    [OpenCL::CL_DEVICE_PARTITION_MAX_SUB_DEVICES, "L"],
    [OpenCL::CL_DEVICE_PARTITION_PROPERTIES, "L"],
    [OpenCL::CL_DEVICE_PARTITION_AFFINITY_DOMAIN, "cl_bitfield"],
    [OpenCL::CL_DEVICE_PARTITION_TYPE, "L"],
    [OpenCL::CL_DEVICE_REFERENCE_COUNT, "L"],
    [OpenCL::CL_DEVICE_PREFERRED_INTEROP_USER_SYNC, "L"],
    [OpenCL::CL_DEVICE_PRINTF_BUFFER_SIZE, "L"],
    [OpenCL::CL_DEVICE_IMAGE_PITCH_ALIGNMENT, "L"],
    [OpenCL::CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT, "L"]
  ].each do |param|

    OpenCL.clGetDeviceInfo(device, param[0], cl_devices_info_buf_length, cl_devices_info_buf, cl_devices_info_length_buf)
    cl_devices_info_length = cl_devices_info_length_buf.unpack("L")[0]

    if param[1] == "char[]"
      puts "#{device} : #{enum2name[param[0]]} = #{cl_devices_info_buf[0...(cl_devices_info_length-1)]}"
    elsif param[1] == "cl_bool"
      info = cl_devices_info_buf.unpack(param[1])
      puts "#{device} : #{enum2name[param[0]]} = #{info == 0 ? 'false' : 'true'}"
    elsif param[1] == "size_t[]"
      if param[0] == OpenCL::CL_DEVICE_MAX_WORK_ITEM_SIZES
        info = cl_devices_info_buf.unpack("L#{work_item_dimensions}")
      else
        info = cl_devices_info_buf.unpack("L")
      end
      puts "#{device} : #{enum2name[param[0]]} = #{info}"
    elsif param[1] == "cl_bitfield"
      info = cl_devices_info_buf.unpack("L")[0]
      puts "#{device} : #{enum2name[param[0]]} = 0b#{info.to_s(2)}"
    else
      info = cl_devices_info_buf.unpack(param[1])
      puts "#{device} : #{enum2name[param[0]]} = #{info}"

      if param[0] == OpenCL::CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS
        work_item_dimensions = info[0]
      end

    end

  end

end


#
# Mac mini (Late 2014) El Capitan :
#
# 2
# [4294967295, 16925952]
# 4294967295 : CL_DEVICE_TYPE = [2]
# 4294967295 : CL_DEVICE_VENDOR_ID = [4294967295]
# 4294967295 : CL_DEVICE_MAX_COMPUTE_UNITS = [4]
# 4294967295 : CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS = [3]
# 4294967295 : CL_DEVICE_MAX_WORK_GROUP_SIZE = [1024]
# 4294967295 : CL_DEVICE_MAX_WORK_ITEM_SIZES = [1024, 0, 1]
# 4294967295 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR = [16]
# 4294967295 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT = [8]
# 4294967295 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT = [4]
# 4294967295 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG = [2]
# 4294967295 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT = [4]
# 4294967295 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE = [2]
# 4294967295 : CL_DEVICE_MAX_CLOCK_FREQUENCY = [3000]
# 4294967295 : CL_DEVICE_ADDRESS_BITS = [64]
# 4294967295 : CL_DEVICE_MAX_READ_IMAGE_ARGS = [128]
# 4294967295 : CL_DEVICE_MAX_WRITE_IMAGE_ARGS = [8]
# 4294967295 : CL_DEVICE_MAX_MEM_ALLOC_SIZE = [0]
# 4294967295 : CL_DEVICE_IMAGE2D_MAX_WIDTH = [8192]
# 4294967295 : CL_DEVICE_IMAGE2D_MAX_HEIGHT = [8192]
# 4294967295 : CL_DEVICE_IMAGE3D_MAX_WIDTH = [2048]
# 4294967295 : CL_DEVICE_IMAGE3D_MAX_HEIGHT = [2048]
# 4294967295 : CL_DEVICE_IMAGE3D_MAX_DEPTH = [2048]
# 4294967295 : CL_DEVICE_IMAGE_SUPPORT = true
# 4294967295 : CL_DEVICE_MAX_PARAMETER_SIZE = [4096]
# 4294967295 : CL_DEVICE_MAX_SAMPLERS = [16]
# 4294967295 : CL_DEVICE_MEM_BASE_ADDR_ALIGN = [1024]
# 4294967295 : CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE = [128]
# 4294967295 : CL_DEVICE_SINGLE_FP_CONFIG = 0b10111111
# 4294967295 : CL_DEVICE_GLOBAL_MEM_CACHE_TYPE = [2]
# 4294967295 : CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE = [4194304]
# 4294967295 : CL_DEVICE_GLOBAL_MEM_CACHE_SIZE = [64]
# 4294967295 : CL_DEVICE_GLOBAL_MEM_SIZE = [0]
# 4294967295 : CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE = [65536]
# 4294967295 : CL_DEVICE_MAX_CONSTANT_ARGS = [8]
# 4294967295 : CL_DEVICE_LOCAL_MEM_TYPE = [2]
# 4294967295 : CL_DEVICE_LOCAL_MEM_SIZE = [32768]
# 4294967295 : CL_DEVICE_ERROR_CORRECTION_SUPPORT = true
# 4294967295 : CL_DEVICE_PROFILING_TIMER_RESOLUTION = [1]
# 4294967295 : CL_DEVICE_ENDIAN_LITTLE = true
# 4294967295 : CL_DEVICE_AVAILABLE = true
# 4294967295 : CL_DEVICE_COMPILER_AVAILABLE = true
# 4294967295 : CL_DEVICE_EXECUTION_CAPABILITIES = [3]
# 4294967295 : CL_DEVICE_QUEUE_PROPERTIES = 0b10
# 4294967295 : CL_DEVICE_NAME = Intel(R) Core(TM) i7-4578U CPU @ 3.00GHz
# 4294967295 : CL_DEVICE_VENDOR = Intel
# 4294967295 : CL_DRIVER_VERSION = 1.1
# 4294967295 : CL_DEVICE_PROFILE = FULL_PROFILE
# 4294967295 : CL_DEVICE_VERSION = OpenCL 1.2 
# 4294967295 : CL_DEVICE_EXTENSIONS = cl_APPLE_SetMemObjectDestructor cl_APPLE_ContextLoggingFunctions cl_APPLE_clut cl_APPLE_query_kernel_names cl_APPLE_gl_sharing cl_khr_gl_event cl_khr_fp64 cl_khr_global_int32_base_atomics cl_khr_global_int32_extended_atomics cl_khr_local_int32_base_atomics cl_khr_local_int32_extended_atomics cl_khr_byte_addressable_store cl_khr_int64_base_atomics cl_khr_int64_extended_atomics cl_khr_3d_image_writes cl_khr_image2d_from_buffer cl_APPLE_fp64_basic_ops cl_APPLE_fixed_alpha_channel_orders cl_APPLE_biased_fixed_point_image_formats cl_APPLE_command_queue_priority
# 4294967295 : CL_DEVICE_PLATFORM = [2147418112]
# 4294967295 : CL_DEVICE_DOUBLE_FP_CONFIG = 0b111111
# 4294967295 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF = [0]
# 4294967295 : CL_DEVICE_HOST_UNIFIED_MEMORY = true
# 4294967295 : CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR = [16]
# 4294967295 : CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT = [8]
# 4294967295 : CL_DEVICE_NATIVE_VECTOR_WIDTH_INT = [4]
# 4294967295 : CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG = [2]
# 4294967295 : CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT = [4]
# 4294967295 : CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE = [2]
# 4294967295 : CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF = [0]
# 4294967295 : CL_DEVICE_OPENCL_C_VERSION = [1852141647]
# 4294967295 : CL_DEVICE_LINKER_AVAILABLE = true
# 4294967295 : CL_DEVICE_BUILT_IN_KERNELS = 
# 4294967295 : CL_DEVICE_IMAGE_MAX_BUFFER_SIZE = [65536]
# 4294967295 : CL_DEVICE_IMAGE_MAX_ARRAY_SIZE = [2048]
# 4294967295 : CL_DEVICE_PARENT_DEVICE = [2048]
# 4294967295 : CL_DEVICE_PARTITION_MAX_SUB_DEVICES = [0]
# 4294967295 : CL_DEVICE_PARTITION_PROPERTIES = [0]
# 4294967295 : CL_DEVICE_PARTITION_AFFINITY_DOMAIN = 0b0
# 4294967295 : CL_DEVICE_PARTITION_TYPE = [0]
# 4294967295 : CL_DEVICE_REFERENCE_COUNT = [1]
# 4294967295 : CL_DEVICE_PREFERRED_INTEROP_USER_SYNC = [1]
# 4294967295 : CL_DEVICE_PRINTF_BUFFER_SIZE = [1048576]
# 4294967295 : CL_DEVICE_IMAGE_PITCH_ALIGNMENT = [1]
# 4294967295 : CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT = [1]
# 16925952 : CL_DEVICE_TYPE = [4]
# 16925952 : CL_DEVICE_VENDOR_ID = [16925952]
# 16925952 : CL_DEVICE_MAX_COMPUTE_UNITS = [40]
# 16925952 : CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS = [3]
# 16925952 : CL_DEVICE_MAX_WORK_GROUP_SIZE = [512]
# 16925952 : CL_DEVICE_MAX_WORK_ITEM_SIZES = [512, 0, 512]
# 16925952 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR = [1]
# 16925952 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT = [1]
# 16925952 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT = [1]
# 16925952 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG = [1]
# 16925952 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT = [1]
# 16925952 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE = [0]
# 16925952 : CL_DEVICE_MAX_CLOCK_FREQUENCY = [1200]
# 16925952 : CL_DEVICE_ADDRESS_BITS = [64]
# 16925952 : CL_DEVICE_MAX_READ_IMAGE_ARGS = [128]
# 16925952 : CL_DEVICE_MAX_WRITE_IMAGE_ARGS = [8]
# 16925952 : CL_DEVICE_MAX_MEM_ALLOC_SIZE = [402653184]
# 16925952 : CL_DEVICE_IMAGE2D_MAX_WIDTH = [16384]
# 16925952 : CL_DEVICE_IMAGE2D_MAX_HEIGHT = [16384]
# 16925952 : CL_DEVICE_IMAGE3D_MAX_WIDTH = [2048]
# 16925952 : CL_DEVICE_IMAGE3D_MAX_HEIGHT = [2048]
# 16925952 : CL_DEVICE_IMAGE3D_MAX_DEPTH = [2048]
# 16925952 : CL_DEVICE_IMAGE_SUPPORT = true
# 16925952 : CL_DEVICE_MAX_PARAMETER_SIZE = [1024]
# 16925952 : CL_DEVICE_MAX_SAMPLERS = [16]
# 16925952 : CL_DEVICE_MEM_BASE_ADDR_ALIGN = [1024]
# 16925952 : CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE = [128]
# 16925952 : CL_DEVICE_SINGLE_FP_CONFIG = 0b10111110
# 16925952 : CL_DEVICE_GLOBAL_MEM_CACHE_TYPE = [0]
# 16925952 : CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE = [0]
# 16925952 : CL_DEVICE_GLOBAL_MEM_CACHE_SIZE = [0]
# 16925952 : CL_DEVICE_GLOBAL_MEM_SIZE = [1610612736]
# 16925952 : CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE = [65536]
# 16925952 : CL_DEVICE_MAX_CONSTANT_ARGS = [8]
# 16925952 : CL_DEVICE_LOCAL_MEM_TYPE = [1]
# 16925952 : CL_DEVICE_LOCAL_MEM_SIZE = [65536]
# 16925952 : CL_DEVICE_ERROR_CORRECTION_SUPPORT = true
# 16925952 : CL_DEVICE_PROFILING_TIMER_RESOLUTION = [80]
# 16925952 : CL_DEVICE_ENDIAN_LITTLE = true
# 16925952 : CL_DEVICE_AVAILABLE = true
# 16925952 : CL_DEVICE_COMPILER_AVAILABLE = true
# 16925952 : CL_DEVICE_EXECUTION_CAPABILITIES = [1]
# 16925952 : CL_DEVICE_QUEUE_PROPERTIES = 0b10
# 16925952 : CL_DEVICE_NAME = Iris
# 16925952 : CL_DEVICE_VENDOR = Intel
# 16925952 : CL_DRIVER_VERSION = 1.2(Oct 13 2015 18:35:13)
# 16925952 : CL_DEVICE_PROFILE = FULL_PROFILE
# 16925952 : CL_DEVICE_VERSION = OpenCL 1.2 
# 16925952 : CL_DEVICE_EXTENSIONS = cl_APPLE_SetMemObjectDestructor cl_APPLE_ContextLoggingFunctions cl_APPLE_clut cl_APPLE_query_kernel_names cl_APPLE_gl_sharing cl_khr_gl_event cl_khr_global_int32_base_atomics cl_khr_global_int32_extended_atomics cl_khr_local_int32_base_atomics cl_khr_local_int32_extended_atomics cl_khr_byte_addressable_store cl_khr_image2d_from_buffer cl_khr_gl_depth_images cl_khr_depth_images cl_khr_3d_image_writes 
# 16925952 : CL_DEVICE_PLATFORM = [2147418112]
# 16925952 : CL_DEVICE_DOUBLE_FP_CONFIG = 0b0
# 16925952 : CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF = [0]
# 16925952 : CL_DEVICE_HOST_UNIFIED_MEMORY = true
# 16925952 : CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR = [1]
# 16925952 : CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT = [1]
# 16925952 : CL_DEVICE_NATIVE_VECTOR_WIDTH_INT = [1]
# 16925952 : CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG = [1]
# 16925952 : CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT = [1]
# 16925952 : CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE = [0]
# 16925952 : CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF = [0]
# 16925952 : CL_DEVICE_OPENCL_C_VERSION = [1852141647]
# 16925952 : CL_DEVICE_LINKER_AVAILABLE = true
# 16925952 : CL_DEVICE_BUILT_IN_KERNELS = 
# 16925952 : CL_DEVICE_IMAGE_MAX_BUFFER_SIZE = [25165824]
# 16925952 : CL_DEVICE_IMAGE_MAX_ARRAY_SIZE = [2048]
# 16925952 : CL_DEVICE_PARENT_DEVICE = [2048]
# 16925952 : CL_DEVICE_PARTITION_MAX_SUB_DEVICES = [0]
# 16925952 : CL_DEVICE_PARTITION_PROPERTIES = [0]
# 16925952 : CL_DEVICE_PARTITION_AFFINITY_DOMAIN = 0b0
# 16925952 : CL_DEVICE_PARTITION_TYPE = [0]
# 16925952 : CL_DEVICE_REFERENCE_COUNT = [1]
# 16925952 : CL_DEVICE_PREFERRED_INTEROP_USER_SYNC = [1]
# 16925952 : CL_DEVICE_PRINTF_BUFFER_SIZE = [1048576]
# 16925952 : CL_DEVICE_IMAGE_PITCH_ALIGNMENT = [32]
# 16925952 : CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT = [4]