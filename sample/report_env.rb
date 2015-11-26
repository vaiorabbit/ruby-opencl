require_relative '../lib/opencl'
require_relative '../lib/opencl_ext'

# Load DLL
begin
  OpenCL.load_lib('c:/Windows/System32/OpenCL.dll') # For Windows
rescue
  OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
end
include OpenCL

################################################################################

$enum2name = {
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

$enum2pack = {
  OpenCL::CL_DEVICE_TYPE => "L",
  OpenCL::CL_DEVICE_VENDOR_ID => "L",
  OpenCL::CL_DEVICE_MAX_COMPUTE_UNITS => "L",
  OpenCL::CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS => "L",
  OpenCL::CL_DEVICE_MAX_WORK_GROUP_SIZE => "Q",
  OpenCL::CL_DEVICE_MAX_WORK_ITEM_SIZES => "Q3",
  OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR => "L",
  OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT => "L",
  OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT => "L",
  OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG => "L",
  OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT => "L",
  OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE => "L",
  OpenCL::CL_DEVICE_MAX_CLOCK_FREQUENCY => "L",
  OpenCL::CL_DEVICE_ADDRESS_BITS => "L",
  OpenCL::CL_DEVICE_MAX_READ_IMAGE_ARGS => "L",
  OpenCL::CL_DEVICE_MAX_WRITE_IMAGE_ARGS => "L",
  OpenCL::CL_DEVICE_MAX_MEM_ALLOC_SIZE => "L",
  OpenCL::CL_DEVICE_IMAGE2D_MAX_WIDTH => "Q",
  OpenCL::CL_DEVICE_IMAGE2D_MAX_HEIGHT => "Q",
  OpenCL::CL_DEVICE_IMAGE3D_MAX_WIDTH => "Q",
  OpenCL::CL_DEVICE_IMAGE3D_MAX_HEIGHT => "Q",
  OpenCL::CL_DEVICE_IMAGE3D_MAX_DEPTH => "Q",
  OpenCL::CL_DEVICE_IMAGE_SUPPORT => "cl_bool",
  OpenCL::CL_DEVICE_MAX_PARAMETER_SIZE => "Q",
  OpenCL::CL_DEVICE_MAX_SAMPLERS => "L",
  OpenCL::CL_DEVICE_MEM_BASE_ADDR_ALIGN => "L",
  OpenCL::CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE => "L",
  OpenCL::CL_DEVICE_SINGLE_FP_CONFIG => "cl_bitfield",
  OpenCL::CL_DEVICE_GLOBAL_MEM_CACHE_TYPE => "L",
  OpenCL::CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE => "L",
  OpenCL::CL_DEVICE_GLOBAL_MEM_CACHE_SIZE => "L",
  OpenCL::CL_DEVICE_GLOBAL_MEM_SIZE => "L",
  OpenCL::CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE => "L",
  OpenCL::CL_DEVICE_MAX_CONSTANT_ARGS => "L",
  OpenCL::CL_DEVICE_LOCAL_MEM_TYPE => "L",
  OpenCL::CL_DEVICE_LOCAL_MEM_SIZE => "L",
  OpenCL::CL_DEVICE_ERROR_CORRECTION_SUPPORT => "cl_bool",
  OpenCL::CL_DEVICE_PROFILING_TIMER_RESOLUTION => "Q",
  OpenCL::CL_DEVICE_ENDIAN_LITTLE => "cl_bool",
  OpenCL::CL_DEVICE_AVAILABLE => "cl_bool",
  OpenCL::CL_DEVICE_COMPILER_AVAILABLE => "cl_bool",
  OpenCL::CL_DEVICE_EXECUTION_CAPABILITIES => "L",
  OpenCL::CL_DEVICE_QUEUE_PROPERTIES => "cl_bitfield",
  OpenCL::CL_DEVICE_NAME => "Z*",
  OpenCL::CL_DEVICE_VENDOR => "Z*",
  OpenCL::CL_DRIVER_VERSION => "Z*",
  OpenCL::CL_DEVICE_PROFILE => "Z*",
  OpenCL::CL_DEVICE_VERSION => "Z*",
  OpenCL::CL_DEVICE_EXTENSIONS => "Z*",
  OpenCL::CL_DEVICE_PLATFORM => "Q",
  OpenCL::CL_DEVICE_DOUBLE_FP_CONFIG => "cl_bitfield",
  OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF => "L",
  OpenCL::CL_DEVICE_HOST_UNIFIED_MEMORY => "cl_bool",
  OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR => "L",
  OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT => "L",
  OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_INT => "L",
  OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG => "L",
  OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT => "L",
  OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE => "L",
  OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF => "L",
  OpenCL::CL_DEVICE_OPENCL_C_VERSION => "Z*",
  OpenCL::CL_DEVICE_LINKER_AVAILABLE => "cl_bool",
  OpenCL::CL_DEVICE_BUILT_IN_KERNELS => "Z*",
  OpenCL::CL_DEVICE_IMAGE_MAX_BUFFER_SIZE => "Q",
  OpenCL::CL_DEVICE_IMAGE_MAX_ARRAY_SIZE => "Q",
  OpenCL::CL_DEVICE_PARENT_DEVICE => "Q",
  OpenCL::CL_DEVICE_PARTITION_MAX_SUB_DEVICES => "L",
  OpenCL::CL_DEVICE_PARTITION_PROPERTIES => "L",
  OpenCL::CL_DEVICE_PARTITION_AFFINITY_DOMAIN => "cl_bitfield",
  OpenCL::CL_DEVICE_PARTITION_TYPE => "L",
  OpenCL::CL_DEVICE_REFERENCE_COUNT => "L",
  OpenCL::CL_DEVICE_PREFERRED_INTEROP_USER_SYNC => "L",
  OpenCL::CL_DEVICE_PRINTF_BUFFER_SIZE => "Q",
  OpenCL::CL_DEVICE_IMAGE_PITCH_ALIGNMENT => "L",
  OpenCL::CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT => "L"
}

def print_device_info(device_id)
  err = 0
  errcode_ret_buf = ' ' * 4
  info_buf = ' ' * 1024

  enums = [
    OpenCL::CL_DEVICE_TYPE,
    OpenCL::CL_DEVICE_VENDOR_ID,
    OpenCL::CL_DEVICE_MAX_COMPUTE_UNITS,
    OpenCL::CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS,
    OpenCL::CL_DEVICE_MAX_WORK_GROUP_SIZE,
    OpenCL::CL_DEVICE_MAX_WORK_ITEM_SIZES,
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR,
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT,
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT,
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG,
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT,
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE,
    OpenCL::CL_DEVICE_MAX_CLOCK_FREQUENCY,
    OpenCL::CL_DEVICE_ADDRESS_BITS,
    OpenCL::CL_DEVICE_MAX_READ_IMAGE_ARGS,
    OpenCL::CL_DEVICE_MAX_WRITE_IMAGE_ARGS,
    OpenCL::CL_DEVICE_MAX_MEM_ALLOC_SIZE,
    OpenCL::CL_DEVICE_IMAGE2D_MAX_WIDTH,
    OpenCL::CL_DEVICE_IMAGE2D_MAX_HEIGHT,
    OpenCL::CL_DEVICE_IMAGE3D_MAX_WIDTH,
    OpenCL::CL_DEVICE_IMAGE3D_MAX_HEIGHT,
    OpenCL::CL_DEVICE_IMAGE3D_MAX_DEPTH,
    OpenCL::CL_DEVICE_IMAGE_SUPPORT,
    OpenCL::CL_DEVICE_MAX_PARAMETER_SIZE,
    OpenCL::CL_DEVICE_MAX_SAMPLERS,
    OpenCL::CL_DEVICE_MEM_BASE_ADDR_ALIGN,
    OpenCL::CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE,
    OpenCL::CL_DEVICE_SINGLE_FP_CONFIG,
    OpenCL::CL_DEVICE_GLOBAL_MEM_CACHE_TYPE,
    OpenCL::CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE,
    OpenCL::CL_DEVICE_GLOBAL_MEM_CACHE_SIZE,
    OpenCL::CL_DEVICE_GLOBAL_MEM_SIZE,
    OpenCL::CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE,
    OpenCL::CL_DEVICE_MAX_CONSTANT_ARGS,
    OpenCL::CL_DEVICE_LOCAL_MEM_TYPE,
    OpenCL::CL_DEVICE_LOCAL_MEM_SIZE,
    OpenCL::CL_DEVICE_ERROR_CORRECTION_SUPPORT,
    OpenCL::CL_DEVICE_PROFILING_TIMER_RESOLUTION,
    OpenCL::CL_DEVICE_ENDIAN_LITTLE,
    OpenCL::CL_DEVICE_AVAILABLE,
    OpenCL::CL_DEVICE_COMPILER_AVAILABLE,
    OpenCL::CL_DEVICE_EXECUTION_CAPABILITIES,
    OpenCL::CL_DEVICE_QUEUE_PROPERTIES,
    OpenCL::CL_DEVICE_NAME,
    OpenCL::CL_DEVICE_VENDOR,
    OpenCL::CL_DRIVER_VERSION,
    OpenCL::CL_DEVICE_PROFILE,
    OpenCL::CL_DEVICE_VERSION,
    OpenCL::CL_DEVICE_EXTENSIONS,
    OpenCL::CL_DEVICE_PLATFORM,
    OpenCL::CL_DEVICE_DOUBLE_FP_CONFIG,
    OpenCL::CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF,
    OpenCL::CL_DEVICE_HOST_UNIFIED_MEMORY,
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR,
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT,
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_INT,
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG,
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT,
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE,
    OpenCL::CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF,
    OpenCL::CL_DEVICE_OPENCL_C_VERSION,
    OpenCL::CL_DEVICE_LINKER_AVAILABLE,
    OpenCL::CL_DEVICE_BUILT_IN_KERNELS,
    OpenCL::CL_DEVICE_IMAGE_MAX_BUFFER_SIZE,
    OpenCL::CL_DEVICE_IMAGE_MAX_ARRAY_SIZE,
    OpenCL::CL_DEVICE_PARENT_DEVICE,
    OpenCL::CL_DEVICE_PARTITION_MAX_SUB_DEVICES,
    OpenCL::CL_DEVICE_PARTITION_PROPERTIES,
    OpenCL::CL_DEVICE_PARTITION_AFFINITY_DOMAIN,
    OpenCL::CL_DEVICE_PARTITION_TYPE,
    OpenCL::CL_DEVICE_REFERENCE_COUNT,
    OpenCL::CL_DEVICE_PREFERRED_INTEROP_USER_SYNC,
    OpenCL::CL_DEVICE_PRINTF_BUFFER_SIZE,
    OpenCL::CL_DEVICE_IMAGE_PITCH_ALIGNMENT,
    OpenCL::CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT,
  ]

  enums.each do |e|
    err = clGetDeviceInfo(device_id, e, info_buf.length, info_buf, nil)

    if $enum2pack[e] == "cl_bool"
      info = info_buf.unpack($enum2pack[e])
      info = "#{info == 0 ? 'false' : 'true'}"
    elsif $enum2pack[e] == "cl_bitfield"
      info = info_buf.unpack("L")[0]
      info = "#{info} (0b#{info.to_s(2)})"
    else
      info = info_buf.unpack($enum2pack[e])
    end

    if e == OpenCL::CL_DEVICE_EXTENSIONS
      extensions = info[0].split
      puts "CL_DEVICE_EXTENSIONS: "
      extensions.each do |extension|
        puts "\t#{extension}"
      end
    else
      puts "#{$enum2name[e]}: \t#{info}"
    end
  end
end

################################################################################

$imageformat2name = {
  # cl_channel_order
  OpenCL::CL_R                => "CL_R",
  OpenCL::CL_A                => "CL_A",
  OpenCL::CL_RG               => "CL_RG",
  OpenCL::CL_RA               => "CL_RA",
  OpenCL::CL_RGB              => "CL_RGB",
  OpenCL::CL_RGBA             => "CL_RGBA",
  OpenCL::CL_BGRA             => "CL_BGRA",
  OpenCL::CL_ARGB             => "CL_ARGB",
  OpenCL::CL_INTENSITY        => "CL_INTENSITY",
  OpenCL::CL_LUMINANCE        => "CL_LUMINANCE",
  OpenCL::CL_Rx               => "CL_Rx",
  OpenCL::CL_RGx              => "CL_RGx",
  OpenCL::CL_RGBx             => "CL_RGBx",
  OpenCL::CL_DEPTH            => "CL_DEPTH",
  OpenCL::CL_DEPTH_STENCIL    => "CL_DEPTH_STENCIL",

  # cl_channel_type
  OpenCL::CL_SNORM_INT8       => "CL_SNORM_INT8",
  OpenCL::CL_SNORM_INT16      => "CL_SNORM_INT16",
  OpenCL::CL_UNORM_INT8       => "CL_UNORM_INT8",
  OpenCL::CL_UNORM_INT16      => "CL_UNORM_INT16",
  OpenCL::CL_UNORM_SHORT_565  => "CL_UNORM_SHORT_565",
  OpenCL::CL_UNORM_SHORT_555  => "CL_UNORM_SHORT_555",
  OpenCL::CL_UNORM_INT_101010 => "CL_UNORM_INT_101010",
  OpenCL::CL_SIGNED_INT8      => "CL_SIGNED_INT8",
  OpenCL::CL_SIGNED_INT16     => "CL_SIGNED_INT16",
  OpenCL::CL_SIGNED_INT32     => "CL_SIGNED_INT32",
  OpenCL::CL_UNSIGNED_INT8    => "CL_UNSIGNED_INT8",
  OpenCL::CL_UNSIGNED_INT16   => "CL_UNSIGNED_INT16",
  OpenCL::CL_UNSIGNED_INT32   => "CL_UNSIGNED_INT32",
  OpenCL::CL_HALF_FLOAT       => "CL_HALF_FLOAT",
  OpenCL::CL_FLOAT            => "CL_FLOAT",
  OpenCL::CL_UNORM_INT24      => "CL_UNORM_INT24",

  # 0x10000012 : ABGR and xBGR formats for CoreImage CL-GPU support (from /OpenCL.framework/Headers/cl_ext.h)
  OpenCL::CL_ABGR_APPLE       => "CL_ABGR_APPLE",

  # cl_APPLE_fixed_alpha_channel_orders (from /OpenCL.framework/Headers/cl_ext.h)

  # 0x10000006
  OpenCL::CL_1RGB_APPLE => "CL_1RGB_APPLE",
  # 0x10000007
  OpenCL::CL_BGR1_APPLE => "CL_BGR1_APPLE",

  # cl_APPLE_biased_fixed_point_image_formats (from /OpenCL.framework/Headers/cl_ext.h)

  # 0x10000008
  CL_SFIXED14_APPLE => "CL_SFIXED14_APPLE",
  # 0x10000009
  CL_BIASED_HALF_APPLE => "CL_BIASED_HALF_APPLE",

  # YUV image support (from /OpenCL.framework/Headers/cl_ext.h)

  # 0x10000010
  OpenCL::CL_YCbYCr_APPLE => "OpenCL::CL_YCbYCr_APPLE",
  # 0x10000011
  OpenCL::CL_CbYCrY_APPLE => "OpenCL::CL_CbYCrY_APPLE",
}

def print_supported_image_formats(cl_ctx, image_type = OpenCL::CL_MEM_OBJECT_IMAGE2D)
  return unless (image_type == CL_MEM_OBJECT_IMAGE2D || image_type == CL_MEM_OBJECT_IMAGE3D)
  err = 0

  image_formats = []

  num_image_formamts_buf = ' ' * 4
  err = clGetSupportedImageFormats(cl_ctx, CL_MEM_READ_ONLY, image_type, 0, nil, num_image_formamts_buf)
  num_image_formamts = num_image_formamts_buf.unpack("L")[0]
  image_formats_buf = Fiddle::Pointer.malloc(num_image_formamts * OpenCL::CL_STRUCT_IMAGE_FORMAT.size)
  err = clGetSupportedImageFormats(cl_ctx, CL_MEM_READ_ONLY, image_type, num_image_formamts, image_formats_buf, nil)

  num_image_formamts.times do |i|
    fmt = OpenCL::CL_STRUCT_IMAGE_FORMAT.new(image_formats_buf.to_i + i * OpenCL::CL_STRUCT_IMAGE_FORMAT.size)
    image_formats << fmt
  end

  puts "Supported Image Formats (#{image_type == CL_MEM_OBJECT_IMAGE2D ? '2D' : '3D'})"
  image_formats.each_with_index do |fmt, i|
    puts "\t#{i}:\t#{$imageformat2name[fmt.image_channel_order]} - #{$imageformat2name[fmt.image_channel_data_type]}"
  end
end

################################################################################

if __FILE__ == $0

  err = 0
  errcode_ret_buf = ' ' * 4
  info_buf = ' ' * 1024

  # Platform
  cl_platforms_count_buf = ' ' * 4
  err = clGetPlatformIDs(0, nil, cl_platforms_count_buf)
  cl_platforms_count = cl_platforms_count_buf.unpack("L")[0]

  cl_platforms_buf = ' ' * 8 * cl_platforms_count
  err = clGetPlatformIDs(cl_platforms_count, cl_platforms_buf, nil)
  cl_platforms = cl_platforms_buf.unpack("Q#{cl_platforms_count}")

  platform_info_params = {
    CL_PLATFORM_PROFILE => "CL_PLATFORM_PROFILE",
    CL_PLATFORM_VERSION => "CL_PLATFORM_VERSION",
    CL_PLATFORM_NAME => "CL_PLATFORM_NAME",
    CL_PLATFORM_VENDOR => "CL_PLATFORM_VENDOR",
  }
  platform_info_params.each do |k, v|
    err = clGetPlatformInfo(cl_platforms[0], k, info_buf.length, info_buf, nil)
    puts "#{v}: \t#{info_buf.unpack("Z*")[0]}"
  end

  err = clGetPlatformInfo(cl_platforms[0], CL_PLATFORM_EXTENSIONS, info_buf.length, info_buf, nil)
  extensions = info_buf.unpack("Z*")[0].split
  puts "CL_PLATFORM_EXTENSIONS: "
  extensions.each do |extension|
    puts "\t#{extension}"
  end
  puts ""

  # Devices
  cl_devices_count_buf = ' ' * 4

  err = clGetDeviceIDs(cl_platforms[0], CL_DEVICE_TYPE_ALL, 0, nil, cl_devices_count_buf)
  cl_devices_count = cl_devices_count_buf.unpack("L")[0]

  exit if cl_devices_count == 0

  cl_devices_buf = ' ' * 8 * cl_devices_count
  err = clGetDeviceIDs(cl_platforms[0], CL_DEVICE_TYPE_ALL, cl_devices_count, cl_devices_buf, nil)
  cl_devices = cl_devices_buf.unpack("Q#{cl_devices_count}")

  cl_devices_count.times do |i|
    err = clGetDeviceInfo(cl_devices[i], CL_DEVICE_NAME, info_buf.length, info_buf, nil)
    puts "================================================================================"
    puts "CL_DEVICE_NAME: #{info_buf.unpack("Z*")[0]}"
    puts "================================================================================"
    print_device_info(cl_devices[i])
    puts ""
  end

  # Supported Image Formats
  cl_ctx = clCreateContext(nil, cl_devices_count, cl_devices.pack("Q*"), nil, nil, nil)

  # 2D
  print_supported_image_formats(cl_ctx, CL_MEM_OBJECT_IMAGE2D)

  puts ""

  # 3D
  print_supported_image_formats(cl_ctx, CL_MEM_OBJECT_IMAGE3D)
end
