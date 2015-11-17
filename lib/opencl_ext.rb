# -*- coding: utf-8 -*-
require 'fiddle/import'
require_relative 'opencl'

# OpenCL 1.2 - Platform-dependent extensions

module OpenCL

  #
  # cl_khr_fp16 extension
  #

  CL_DEVICE_HALF_FP_CONFIG                    = 0x1033

  #
  # cl_khr_icd
  #

  # cl_platform_info
  CL_PLATFORM_ICD_SUFFIX_KHR                  = 0x0920

  # Additional Error Codes
  CL_PLATFORM_NOT_FOUND_KHR                   = -1001

  #
  # cl_khr_initalize_memory
  #

  CL_CONTEXT_MEMORY_INITIALIZE_KHR            = 0x200E

  #
  # cl_khr_terminate_context
  #

  CL_DEVICE_TERMINATE_CAPABILITY_KHR          = 0x200F
  CL_CONTEXT_TERMINATE_KHR                    = 0x2010

  #
  # cl_khr_spir
  #

  CL_DEVICE_SPIR_VERSIONS                     = 0x40E0
  CL_PROGRAM_BINARY_TYPE_INTERMEDIATE         = 0x40E1

  #
  # cl_nv_device_attribute_query
  #

  CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV       = 0x4000
  CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV       = 0x4001
  CL_DEVICE_REGISTERS_PER_BLOCK_NV            = 0x4002
  CL_DEVICE_WARP_SIZE_NV                      = 0x4003
  CL_DEVICE_GPU_OVERLAP_NV                    = 0x4004
  CL_DEVICE_KERNEL_EXEC_TIMEOUT_NV            = 0x4005
  CL_DEVICE_INTEGRATED_MEMORY_NV              = 0x4006

  #
  # cl_amd_device_attribute_query
  #

  CL_DEVICE_PROFILING_TIMER_OFFSET_AMD        = 0x4036

  #
  # cl_arm_printf
  #

  CL_PRINTF_CALLBACK_ARM                      = 0x40B0
  CL_PRINTF_BUFFERSIZE_ARM                    = 0x40B1

  # cl_device_partition_property_ext
  CL_DEVICE_PARTITION_EQUALLY_EXT             = 0x4050
  CL_DEVICE_PARTITION_BY_COUNTS_EXT           = 0x4051
  CL_DEVICE_PARTITION_BY_NAMES_EXT            = 0x4052
  CL_DEVICE_PARTITION_BY_AFFINITY_DOMAIN_EXT  = 0x4053

  # clDeviceGetInfo selectors
  CL_DEVICE_PARENT_DEVICE_EXT                 = 0x4054
  CL_DEVICE_PARTITION_TYPES_EXT               = 0x4055
  CL_DEVICE_AFFINITY_DOMAINS_EXT              = 0x4056
  CL_DEVICE_REFERENCE_COUNT_EXT               = 0x4057
  CL_DEVICE_PARTITION_STYLE_EXT               = 0x4058

  # error codes
  CL_DEVICE_PARTITION_FAILED_EXT              = -1057
  CL_INVALID_PARTITION_COUNT_EXT              = -1058
  CL_INVALID_PARTITION_NAME_EXT               = -1059

  # CL_AFFINITY_DOMAINs
  CL_AFFINITY_DOMAIN_L1_CACHE_EXT             = 0x1
  CL_AFFINITY_DOMAIN_L2_CACHE_EXT             = 0x2
  CL_AFFINITY_DOMAIN_L3_CACHE_EXT             = 0x3
  CL_AFFINITY_DOMAIN_L4_CACHE_EXT             = 0x4
  CL_AFFINITY_DOMAIN_NUMA_EXT                 = 0x10
  CL_AFFINITY_DOMAIN_NEXT_FISSIONABLE_EXT     = 0x100

  # cl_device_partition_property_ext list terminators
  CL_PROPERTIES_LIST_END_EXT                  = 0
  CL_PARTITION_BY_COUNTS_LIST_END_EXT         = 0
  CL_PARTITION_BY_NAMES_LIST_END_EXT          = CL_ULONG_MAX # ((cl_device_partition_property_ext) 0 - 1)

  #
  # cl_qcom_ext_host_ptr
  #

  CL_MEM_EXT_HOST_PTR_QCOM                  = (1 << 29)

  CL_DEVICE_EXT_MEM_PADDING_IN_BYTES_QCOM   = 0x40A0
  CL_DEVICE_PAGE_SIZE_QCOM                  = 0x40A1
  CL_IMAGE_ROW_ALIGNMENT_QCOM               = 0x40A2
  CL_IMAGE_SLICE_ALIGNMENT_QCOM             = 0x40A3
  CL_MEM_HOST_UNCACHED_QCOM                 = 0x40A4
  CL_MEM_HOST_WRITEBACK_QCOM                = 0x40A5
  CL_MEM_HOST_WRITETHROUGH_QCOM             = 0x40A6
  CL_MEM_HOST_WRITE_COMBINING_QCOM          = 0x40A7

  #
  # cl_qcom_ion_host_ptr
  #

  CL_MEM_ION_HOST_PTR_QCOM                  = 0x40A8

  #
  # cl_APPLE_query_kernel_names (from /OpenCL.framework/Headers/cl_ext.h)
  #

  CL_PROGRAM_NUM_KERNELS_APPLE              = 0x10000004
  CL_PROGRAM_KERNEL_NAMES_APPLE             = 0x10000005

  #
  # cl_APPLE_fixed_alpha_channel_orders (from /OpenCL.framework/Headers/cl_ext.h)
  #

  CL_1RGB_APPLE                             = 0x10000006
  CL_BGR1_APPLE                             = 0x10000007

  #
  # cl_APPLE_biased_fixed_point_image_formats (from /OpenCL.framework/Headers/cl_ext.h)
  #

  CL_SFIXED14_APPLE                         = 0x10000008
  CL_BIASED_HALF_APPLE                      = 0x10000009

  #
  # YUV image support (from /OpenCL.framework/Headers/cl_ext.h)
  #

  CL_YCbYCr_APPLE                           = 0x10000010
  CL_CbYCrY_APPLE                           = 0x10000011

  #
  # ABGR and xBGR formats for CoreImage CL-GPU support (from /OpenCL.framework/Headers/cl_ext.h)
  #

  CL_ABGR_APPLE                             = 0x10000012

  # cl_platform_id : platform
  def self.import_ext(platform)
    return false unless @@cl_import_done

    #
    # cl_APPLE_SetMemObjectDestructor
    #

    addr = clGetExtensionFunctionAddressForPlatform(platform, 'clSetMemObjectDestructorAPPLE')
    unless addr.null?
      # cl_mem : memobj
      # void*  : pfn_notify(char *, void *, size_t, void *),
      # void*  : user_data
      extern 'cl_int clSetMemObjectDestructorAPPLE(cl_mem, void*, void*)', func_addr: addr
    end

    #
    # cl_APPLE_ContextLoggingFunctions
    #

    addr = clGetExtensionFunctionAddressForPlatform(platform, 'clLogMessagesToSystemLogAPPLE')
    unless addr.null?
      # const char * : errstr
      # const void * : private_info
      # size_t       : cb
      # void *       : user_data
      extern 'void clLogMessagesToSystemLogAPPLE(const char*, const void*, size_t, void*)', func_addr: addr
    end

    addr = clGetExtensionFunctionAddressForPlatform(platform, 'clLogMessagesToStdoutAPPLE')
    unless addr.null?
      # const char * : errstr
      # const void * : private_info
      # size_t       : cb
      # void *       : user_data
      extern 'void clLogMessagesToStdoutAPPLE(const char*, const void*, size_t, void*)', func_addr: addr
    end

    addr = clGetExtensionFunctionAddressForPlatform(platform, 'clLogMessagesToStderrAPPLE')
    unless addr.null?
      # const char * : errstr
      # const void * : private_info
      # size_t       : cb
      # void *       : user_data
      extern 'void clLogMessagesToStderrAPPLE(const char*, const void*, size_t, void*)', func_addr: addr
    end

    #
    # cl_khr_icd
    #

    addr = clGetExtensionFunctionAddressForPlatform(platform, 'clIcdGetPlatformIDsKHR')
    unless addr.null?
      # cl_uint          : num_entries
      # cl_platform_id * : platforms
      # cl_uint *        : num_platforms
      extern 'cl_int clIcdGetPlatformIDsKHR(cl_uint, cl_platform_id *, cl_uint *)', func_addr: addr
    end

    #
    # cl_khr_terminate_context
    #

    addr = clGetExtensionFunctionAddressForPlatform(platform, 'clTerminateContextKHR')
    unless addr.null?
      # cl_context : context
      extern 'cl_int clTerminateContextKHR(cl_context)', func_addr: addr
    end

    #
    # cl_ext_device_fission
    #

    addr = clGetExtensionFunctionAddressForPlatform(platform, 'clReleaseDeviceEXT')
    unless addr.null?
      # cl_device_id : device
      extern 'cl_int clReleaseDeviceEXT(cl_device_id)', func_addr: addr
    end

    addr = clGetExtensionFunctionAddressForPlatform(platform, 'clRetainDeviceEXT')
    unless addr.null?
      # cl_device_id : device
      extern 'cl_int clRetainDeviceEXT(cl_device_id)', func_addr: addr
    end

    typealias 'cl_device_partition_property_ext', 'cl_ulong'

    addr = clGetExtensionFunctionAddressForPlatform(platform, 'clCreateSubDevicesEXT')
    unless addr.null?
      # cl_device_id                             : device
      # const cl_device_partition_property_ext * : properties
      # cl_uint                                  : num_entries
      # cl_device_id *                           : out_devices
      # cl_uint *                                : num_devices
      extern 'cl_int clCreateSubDevicesEXT(cl_device_id, const cl_device_partition_property_ext *, cl_uint, cl_device_id *, cl_uint *)', func_addr: addr
    end

    #
    # cl_qcom_ext_host_ptr
    #

    typealias 'cl_image_pitch_info_qcom', 'cl_uint'

    addr = clGetExtensionFunctionAddressForPlatform(platform, 'clGetDeviceImageInfoQCOM')
    unless addr.null?
      # cl_device_id             : device
      # size_t                   : image_width
      # size_t                   : image_height
      # const cl_image_format*   : image_format
      # cl_image_pitch_info_qcom : param_name
      # size_t                   : param_value_size
      # void*                    : param_value
      # size_t*                  : param_value_size_ret
      extern 'cl_int clGetDeviceImageInfoQCOM(cl_device_id, size_t, size_t, const cl_image_format*, cl_image_pitch_info_qcom, size_t, void*, size_t*)', func_addr: addr
    end

    cl_mem_ext_host_ptr = struct(["cl_uint  allocation_type",
                                  "cl_uint  host_cache_policy"])

    #
    # cl_qcom_ion_host_ptr
    #

    cl_mem_ion_host_ptr = struct(["cl_uint  ext_host_ptr_allocation_type",   # ext_host_ptr.allocation_type
                                  "cl_uint  ext_host_ptr_host_cache_policy", # ext_host_ptr.host_cache_policy
                                  "int ion_filedesc",
                                  "void* ion_hostptr"])

    return true
  end

end
