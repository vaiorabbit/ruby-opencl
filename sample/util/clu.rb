require 'rbconfig'
require_relative '../../lib/opencl'
require_relative '../../lib/opencl_ext'
require_relative '../../lib/opencl_gl'
require_relative '../../lib/opencl_gl_ext'

################################################################################

class CLUPlatform
  attr_reader :platforms # Array of cl_platform_id

  def initialize
    @platforms = nil
  end

  def getPlatformIDs(error_info: nil)
    # cl_uint         : num_entries
    # cl_platform_id* : platforms
    # cl_uint*        : num_platforms
    num_entries = 32
    platforms_buf = ' ' * 8 * num_entries
    platforms_count_buf = ' ' * 4

    err = OpenCL.clGetPlatformIDs(num_entries, platforms_buf, platforms_count_buf)
    error_info << err if error_info != nil

    num_platforms = platforms_count_buf.unpack("L")[0]
    @platforms = platforms_buf.unpack("Q#{num_platforms}")

    return @platforms
  end

  # cl_platform_id   : platform
  # cl_platform_info : param_name
  def getPlatformInfo(param_name, platform: @platforms[0], error_info: nil)
    param_value_buf_size = 1024
    param_value_buf = ' ' * param_value_buf_size
    param_value_size_ret_buf = ' ' * 4

    err = OpenCL.clGetPlatformInfo(platform, param_name, param_value_buf_size, param_value_buf, param_value_size_ret_buf)
    error_info << err if error_info != nil

    param_value_size_ret = param_value_size_ret_buf.unpack("L")[0]

    return param_value_buf[0...(param_value_size_ret-1)]
  end
end

################################################################################

class CLUDevice
  attr_reader :devices # Array of cl_device_id

  def initialize
    @devices = nil
  end

  # cl_platform_id   : platform
  # cl_device_type   : device_type
  def getDeviceIDs(platform, device_type, error_info: nil)
    # cl_uint          : num_entries
    # cl_device_id *   : devices
    # cl_uint *        : num_devices
    num_entries = 32
    devices_buf = ' ' * 4 * num_entries
    num_devices_buf = ' ' * 4

    err = OpenCL.clGetDeviceIDs(platform, device_type, num_entries, devices_buf, num_devices_buf)
    error_info << err if error_info != nil

    num_devices = num_devices_buf.unpack("L")[0]
    @devices = devices_buf.unpack("Q#{num_devices}")

    return @devices
  end

  # cl_device_id : device
  def retainDevice(device: @devices[0], error_info: nil)
    return OpenCL.clRetainDevice(device)
  end

  def retainDevices(error_info: nil)
    @devices.each do |device|
      err = OpenCL.clRetainDevice(device)
      error_info << err if error_info != nil
    end
  end

  # cl_device_id : device
  def releaseDevice(device: @devices[0], error_info: nil)
    return OpenCL.clReleaseDevice(device)
  end

  def releaseDevices(error_info: nil)
    @devices.each do |device|
      err = OpenCL.clReleaseDevice(device)
      error_info << err if error_info != nil
    end
  end

  # cl_device_id    : device
  # cl_device_info  : param_name
  def getDeviceInfo(param_name, device: @devices[0], error_info: nil)
    # size_t          : param_value_size
    # void *          : param_value
    # size_t *        : param_value_size_ret
    param_value_buf_length = 1024
    param_value_buf = ' ' * param_value_buf_length
    param_value_size_ret_buf = ' ' * 4

    err = OpenCL.clGetDeviceInfo(device, param_name, param_value_buf_length, param_value_buf, param_value_size_ret_buf)
    error_info << err if error_info != nil

    param_value_size_ret = param_value_size_ret_buf.unpack("L")[0]

    if param_name == OpenCL::CL_DEVICE_MAX_WORK_ITEM_SIZES
      # Ref.: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clGetDeviceInfo.html
      # CL_DEVICE_MAX_WORK_ITEM_SIZES returns n size_t entries, where n is the value returned by the query for CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS.
      work_item_dimensions_buf = ' ' * 4
      err = OpenCL.clGetDeviceInfo(device, OpenCL::CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, 4, work_item_dimensions_buf, nil)
      error_info << err if error_info != nil
      work_item_dimensions = work_item_dimensions_buf.unpack("L")[0]
    end

    unpack_format = @@param2unpack[param_name]
    case unpack_format
    when "char[]"
      return param_value_buf[0...(param_value_size_ret-1)]
    when "cl_bool"
      return param_value_buf.unpack("L")[0] == 0 ? false : true
    when "size_t[]"
      if param_name == OpenCL::CL_DEVICE_MAX_WORK_ITEM_SIZES
        return param_value_buf.unpack("Q#{work_item_dimensions}")
      else
        return param_value_buf.unpack("Q")
      end
    when "intptr_t[]"
      if param_name == OpenCL::CL_DEVICE_PARTITION_PROPERTIES
        # This is an array of cl_device_partition_property values...
        # If the device does not support any partition types, a value of 0 will be returned.
        return param_value_buf.unpack("Q#{param_value_size_ret / 8}")
      else
        return param_value_buf.unpack("Q")
      end
    when "cl_bitfield"
      return param_value_buf.unpack("L")[0]
    else
      return param_value_buf.unpack(unpack_format)[0]
    end
  end

  @@param2unpack = {
    OpenCL::CL_DEVICE_TYPE => "L",
    OpenCL::CL_DEVICE_VENDOR_ID => "L",
    OpenCL::CL_DEVICE_MAX_COMPUTE_UNITS => "L",
    OpenCL::CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS => "L",
    OpenCL::CL_DEVICE_MAX_WORK_GROUP_SIZE => "Q",
    OpenCL::CL_DEVICE_MAX_WORK_ITEM_SIZES => "size_t[]",
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
    OpenCL::CL_DEVICE_MAX_MEM_ALLOC_SIZE => "Q",
    OpenCL::CL_DEVICE_IMAGE2D_MAX_WIDTH => "L",
    OpenCL::CL_DEVICE_IMAGE2D_MAX_HEIGHT => "L",
    OpenCL::CL_DEVICE_IMAGE3D_MAX_WIDTH => "L",
    OpenCL::CL_DEVICE_IMAGE3D_MAX_HEIGHT => "L",
    OpenCL::CL_DEVICE_IMAGE3D_MAX_DEPTH => "L",
    OpenCL::CL_DEVICE_IMAGE_SUPPORT => "cl_bool",
    OpenCL::CL_DEVICE_MAX_PARAMETER_SIZE => "L",
    OpenCL::CL_DEVICE_MAX_SAMPLERS => "L",
    OpenCL::CL_DEVICE_MEM_BASE_ADDR_ALIGN => "L",
    OpenCL::CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE => "L",
    OpenCL::CL_DEVICE_SINGLE_FP_CONFIG => "cl_bitfield",
    OpenCL::CL_DEVICE_GLOBAL_MEM_CACHE_TYPE => "L",
    OpenCL::CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE => "L",
    OpenCL::CL_DEVICE_GLOBAL_MEM_CACHE_SIZE => "L",
    OpenCL::CL_DEVICE_GLOBAL_MEM_SIZE => "Q",
    OpenCL::CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE => "Q",
    OpenCL::CL_DEVICE_MAX_CONSTANT_ARGS => "L",
    OpenCL::CL_DEVICE_LOCAL_MEM_TYPE => "L",
    OpenCL::CL_DEVICE_LOCAL_MEM_SIZE => "Q",
    OpenCL::CL_DEVICE_ERROR_CORRECTION_SUPPORT => "cl_bool",
    OpenCL::CL_DEVICE_PROFILING_TIMER_RESOLUTION => "L",
    OpenCL::CL_DEVICE_ENDIAN_LITTLE => "cl_bool",
    OpenCL::CL_DEVICE_AVAILABLE => "cl_bool",
    OpenCL::CL_DEVICE_COMPILER_AVAILABLE => "cl_bool",
    OpenCL::CL_DEVICE_EXECUTION_CAPABILITIES => "L",
    OpenCL::CL_DEVICE_QUEUE_PROPERTIES => "cl_bitfield",
    OpenCL::CL_DEVICE_NAME => "char[]",
    OpenCL::CL_DEVICE_VENDOR => "char[]",
    OpenCL::CL_DRIVER_VERSION => "char[]",
    OpenCL::CL_DEVICE_PROFILE => "char[]",
    OpenCL::CL_DEVICE_VERSION => "char[]",
    OpenCL::CL_DEVICE_EXTENSIONS => "char[]",
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
    OpenCL::CL_DEVICE_OPENCL_C_VERSION => "L",
    OpenCL::CL_DEVICE_LINKER_AVAILABLE => "cl_bool",
    OpenCL::CL_DEVICE_BUILT_IN_KERNELS => "char[]",
    OpenCL::CL_DEVICE_IMAGE_MAX_BUFFER_SIZE => "L",
    OpenCL::CL_DEVICE_IMAGE_MAX_ARRAY_SIZE => "L",
    OpenCL::CL_DEVICE_PARENT_DEVICE => "Q",
    OpenCL::CL_DEVICE_PARTITION_MAX_SUB_DEVICES => "L",
    OpenCL::CL_DEVICE_PARTITION_PROPERTIES => "intptr_t[]",
    OpenCL::CL_DEVICE_PARTITION_AFFINITY_DOMAIN => "cl_bitfield",
    OpenCL::CL_DEVICE_PARTITION_TYPE => "L",
    OpenCL::CL_DEVICE_REFERENCE_COUNT => "L",
    OpenCL::CL_DEVICE_PREFERRED_INTEROP_USER_SYNC => "L",
    OpenCL::CL_DEVICE_PRINTF_BUFFER_SIZE => "L",
    OpenCL::CL_DEVICE_IMAGE_PITCH_ALIGNMENT => "L",
    OpenCL::CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT => "L"
  }
end

################################################################################

class CLUContext
  attr_reader :context

  def initialize
    @context = nil # cl_context
  end

  # cl_context_properties * : properties
  # cl_device_id *          : devices
  # void *                  : pfn_notify(char *, void *, size_t, void *),
  # void *                  : user_data
  def createContext(properties, devices, pfn_notify: nil, user_data: nil, error_info: nil)
    packed_properties = properties == nil ? nil : properties.pack("Q*")
    num_devices = devices.length
    errcode_ret_buf = ' ' * 4

    cl_ctx = OpenCL.clCreateContext(packed_properties, num_devices, devices.pack("Q*"), pfn_notify, user_data, errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    if errcode_ret == OpenCL::CL_SUCCESS
      @context = cl_ctx
      return @context
    else
      return nil
    end
  end

  # Prerequisite : opengl-bindings 1.5.2 or later ( https://github.com/vaiorabbit/ruby-opengl )
  def createContextWithGLInterop(properties, devices, platform, pfn_notify: nil, user_data: nil, error_info: nil)

    properties.pop if properties.last == 0

    case RbConfig::CONFIG['host_os']

    when /mswin|msys|mingw|cygwin/
      # for Windows
      hGLRC = wglGetCurrentContext()
      hDC   = wglGetCurrentDC()
      props = [ OpenCL::CL_GL_CONTEXT_KHR, hGLRC,
                OpenCL::CL_WGL_HDC_KHR, hDC,
                OpenCL::CL_CONTEXT_PLATFORM, platform,
                0 ]
      properties.concat(props)

    when /darwin/
      # for Mac OS X
      hCGLContext    = CGLGetCurrentContext()
      hCGLShareGroup = CGLGetShareGroup(hCGLContext)
      props = [ OpenCL::CL_CONTEXT_PROPERTY_USE_CGL_SHAREGROUP_APPLE, hCGLShareGroup,
                0 ]
      properties.concat(props)

    when /linux/
      hGLXContext = glXGetCurrentContext()
      hDisplay    = glXGetCurrentDisplay()
      props = [ OpenCL::CL_GL_CONTEXT_KHR, hGLXContext,
                OpenCL::CL_GLX_DISPLAY_KHR, hDisplay,
                OpenCL::CL_CONTEXT_PLATFORM, platform,
                0 ]
      properties.concat(props)

    else
      raise RuntimeError, "OpenCL : Unknown OS: #{host_os.inspect}"

    end

    return createContext(properties, devices, pfn_notify: pfn_notify, user_data: user_data, error_info: error_info)
  end

  # cl_context : context
  def retainContext(context: @context)
    return OpenCL.clRetainContext(context)
  end

  # cl_context : context
  def releaseContext(context: @context)
    return OpenCL.clReleaseContext(context)
  end

  # cl_context      : context
  # cl_context_info : param_name
  def getContextInfo(param_name, context: @context, error_info: nil)
    # size_t          : param_value_size
    # void *          : param_value
    # size_t *        : param_value_size_ret
    param_value_buf_length = 1024
    param_value_buf = ' ' * param_value_buf_length
    param_value_size_ret_buf = ' ' * 4

    err = OpenCL.clGetContextInfo(context, param_name, param_value_buf_length, param_value_buf, param_value_size_ret_buf)
    error_info << err if error_info != nil

    param_value_size_ret = param_value_size_ret_buf.unpack("L")[0]

    unpack_format = @@param2unpack[param_name]
    return param_value_buf.unpack(unpack_format)[0]
  end

  @@param2unpack = {
    OpenCL::CL_CONTEXT_REFERENCE_COUNT => "L",
    OpenCL::CL_CONTEXT_DEVICES => "Q",
    OpenCL::CL_CONTEXT_PROPERTIES => "Q",
    OpenCL::CL_CONTEXT_NUM_DEVICES => "L",
  }

  # cl_context           : context
  # cl_mem_flags         : flags
  # cl_mem_object_type   : image_type
  def getSupportedImageFormats(flags, image_type, context: @context, error_info: nil)
    # cl_uint              : num_entries
    # cl_image_format *    : image_formats
    # cl_uint *            : num_image_formats

    num_image_formamts_buf = ' ' * 4
    err = OpenCL.clGetSupportedImageFormats(context, flags, image_type, 0, nil, num_image_formamts_buf)
    error_info << err if error_info != nil
    num_image_formamts = num_image_formamts_buf.unpack("L")[0]

    image_formats_buf = Fiddle::Pointer.malloc(num_image_formamts * OpenCL::CL_STRUCT_IMAGE_FORMAT.size)
    err = OpenCL.clGetSupportedImageFormats(context, flags, image_type, num_image_formamts, image_formats_buf, nil)
    error_info << err if error_info != nil

    image_formats = []
    num_image_formamts.times do |i|
      fmt = OpenCL::CL_STRUCT_IMAGE_FORMAT.new(image_formats_buf.to_i + i * OpenCL::CL_STRUCT_IMAGE_FORMAT.size)
      image_formats << fmt
    end
    return image_formats
  end
end

################################################################################

class CLUMemory
  attr_reader :mem # cl_mem

  def initialize
    @mem = nil
  end

  # cl_context   : context
  # cl_mem_flags : flags
  # size_t       : size
  # void *       : host_ptr
  def createBuffer(context, flags, size, host_ptr = nil, error_info: nil)
    errcode_ret_buf = ' ' * 4

    mem = OpenCL.clCreateBuffer(context, flags, size, host_ptr, errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    if errcode_ret == OpenCL::CL_SUCCESS
      @mem = mem
      return @mem
    else
      return nil
    end
  end

  # cl_context              : context
  # cl_mem_flags            : flags
  # const cl_image_format * : image_format
  # const cl_image_desc *   : image_desc
  # void *                  : host_ptr
  def createImage(context, flags, image_format, image_desc, host_ptr = nil, error_info: nil)
    errcode_ret_buf = ' ' * 4

    mem = OpenCL.clCreateImage(context, flags, image_format, image_desc, host_ptr, errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    if errcode_ret == OpenCL::CL_SUCCESS
      @mem = mem
      return @mem
    else
      return nil
    end
  end

  # cl_context     : context
  # cl_mem_flags   : flags
  # cl_GLuint      : bufobj
  def createFromGLBuffer(context, flags, bufobj, error_info: nil)
    errcode_ret_buf = ' ' * 4

    mem = OpenCL.clCreateFromGLBuffer(context, flags, bufobj, errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    if errcode_ret == OpenCL::CL_SUCCESS
      @mem = mem
      return @mem
    else
      return nil
    end
  end

  # cl_context      : context
  # cl_mem_flags    : flags
  # cl_GLenum       : target
  # cl_GLint        : miplevel
  # cl_GLuint       : texture
  def createFromGLTexture(context, flags, target, miplevel, texture, error_info: nil)
    errcode_ret_buf = ' ' * 4

    mem = OpenCL.clCreateFromGLTexture(context, flags, target, miplevel, texture, errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    if errcode_ret == OpenCL::CL_SUCCESS
      @mem = mem
      return @mem
    else
      return nil
    end
  end

  # cl_context   : context
  # cl_mem_flags : flags
  # cl_GLuint    : renderbuffer
  def createFromGLRenderBuffer(context, flags, renderbuffer, error_info: nil)
    errcode_ret_buf = ' ' * 4

    mem = OpenCL.clCreateFromGLRenderBuffer(context, flags, renderbuffer, errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    if errcode_ret == OpenCL::CL_SUCCESS
      @mem = mem
      return @mem
    else
      return nil
    end
  end

  # cl_mem : mem
  def retainMemObject(mem: @mem)
    return OpenCL.clRetainMemObject(mem)
  end

  # cl_mem : mem
  def releaseMemObject(mem: @mem)
    return OpenCL.clReleaseMemObject(mem)
  end


  # cl_mem           : memobj
  # cl_mem_info      : param_name
  def getMemObjectInfo(param_name, memobj: @mem, error_info: nil)
    # size_t          : param_value_size
    # void *          : param_value
    # size_t *        : param_value_size_ret
    param_value_buf_length = 1024
    param_value_buf = ' ' * param_value_buf_length
    param_value_size_ret_buf = ' ' * 4

    err = OpenCL.clGetMemObjectInfo(memobj, param_name, param_value_buf_length, param_value_buf, param_value_size_ret_buf)
    error_info << err if error_info != nil

    param_value_size_ret = param_value_size_ret_buf.unpack("L")[0]

    unpack_format = @@mem_objinfo_param2unpack[param_name]
    case unpack_format
    when "void*" # param_name == OpenCL::CL_MEM_HOST_PTR
      addr = param_value_buf.unpack("Q")[0]
      # OS X (El Capitan) : Quering CL_MEM_HOST_PTR to memobj created without
      # CL_MEM_USE_HOST_PTR does not return NULL, but keeps param_value_buf untouched.
      if addr == 0 || param_value_buf[0, 8] == '        '
        return nil
      else
        return Fiddle::Pointer.new(addr)
      end
    else
      return param_value_buf.unpack(unpack_format)[0]
    end
  end

  @@mem_objinfo_param2unpack = {
    OpenCL::CL_MEM_TYPE => "L",
    OpenCL::CL_MEM_FLAGS => "Q",
    OpenCL::CL_MEM_SIZE => "Q",
    OpenCL::CL_MEM_HOST_PTR => "void*",
    OpenCL::CL_MEM_MAP_COUNT => "L",
    OpenCL::CL_MEM_REFERENCE_COUNT => "L",
    OpenCL::CL_MEM_CONTEXT => "Q",
    OpenCL::CL_MEM_ASSOCIATED_MEMOBJECT => "Q",
    OpenCL::CL_MEM_OFFSET => "Q",
  }

  # cl_mem           : memobj
  # cl_image_info    : param_name
  def getImageInfo(param_name, memobj: @mem, error_info: nil)
    # size_t          : param_value_size
    # void *          : param_value
    # size_t *        : param_value_size_ret
    param_value_buf_length = 1024
    param_value_buf = ' ' * param_value_buf_length
    param_value_size_ret_buf = ' ' * 4

    err = OpenCL.clGetImageInfo(memobj, param_name, param_value_buf_length, param_value_buf, param_value_size_ret_buf)
    error_info << err if error_info != nil

    param_value_size_ret = param_value_size_ret_buf.unpack("L")[0]

    unpack_format = @@mem_imageinfo_param2unpack[param_name]
    case unpack_format
    when "cl_image_format" # param_name == OpenCL::CL_IMAGE_FORMAT
      values = param_value_buf.unpack("L2") # instance of cl_image_format
      fmt = OpenCL::CL_STRUCT_IMAGE_FORMAT.malloc
      fmt.image_channel_order = values[0]
      fmt.image_channel_data_type = values[1]
      return fmt
    else
      return param_value_buf.unpack(unpack_format)[0]
    end
  end

  @@mem_imageinfo_param2unpack = {
    OpenCL::CL_IMAGE_FORMAT => "cl_image_format",
    OpenCL::CL_IMAGE_ELEMENT_SIZE => "Q",
    OpenCL::CL_IMAGE_ROW_PITCH => "Q",
    OpenCL::CL_IMAGE_SLICE_PITCH => "Q",
    OpenCL::CL_IMAGE_WIDTH => "Q",
    OpenCL::CL_IMAGE_HEIGHT => "Q",
    OpenCL::CL_IMAGE_DEPTH => "Q",
    OpenCL::CL_IMAGE_ARRAY_SIZE => "Q",
    OpenCL::CL_IMAGE_BUFFER => "Q",
    OpenCL::CL_IMAGE_NUM_MIP_LEVELS => "L",
    OpenCL::CL_IMAGE_NUM_SAMPLES => "L",
  }

  # cl_mem           : memobj
  def getGLObjectInfo(memobj: @mem, error_info: nil)
    # cl_gl_object_type *   : gl_object_type
    # cl_GLuint *           : gl_object_name
    gl_object_type_buf = ' ' * 8
    gl_object_name_buf = ' ' * 4

    err = OpenCL.clGetGLObjectInfo(memobj, gl_object_type_buf, gl_object_name_buf)
    error_info << err if error_info != nil

    return gl_object_type_buf.unpack("L")[0], gl_object_name_buf.unpack("L")[0]
  end

  # cl_mem           : memobj
  # cl_image_info    : param_name
  def getGLTextureInfo(param_name, memobj: @mem, error_info: nil)
    # size_t          : param_value_size
    # void *          : param_value
    # size_t *        : param_value_size_ret
    param_value_buf_length = 1024
    param_value_buf = ' ' * param_value_buf_length
    param_value_size_ret_buf = ' ' * 4

    err = OpenCL.clGetGLTextureInfo(memobj, param_name, param_value_buf_length, param_value_buf, param_value_size_ret_buf)
    error_info << err if error_info != nil

    param_value_size_ret = param_value_size_ret_buf.unpack("L")[0]

    unpack_format = @@mem_gltextureinfo_param2unpack[param_name]
    return param_value_buf.unpack(unpack_format)[0]
  end

  @@mem_gltextureinfo_param2unpack = {
    OpenCL::CL_GL_TEXTURE_TARGET => "L",
    OpenCL::CL_GL_MIPMAP_LEVEL => "l",
  }

end

################################################################################

class CLUCommandQueue
  attr_reader :command_queue # cl_command_queue

  def initialize
    @command_queue = nil # cl_command_queue
  end

  # cl_context                     : context
  # cl_device_id                   : device
  # cl_command_queue_properties    : properties
  def createCommandQueue(context, device, properties = 0, error_info: nil)
    errcode_ret_buf = ' ' * 4

    cl_cq = OpenCL.clCreateCommandQueue(context, device, properties, errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    if errcode_ret == OpenCL::CL_SUCCESS
      @command_queue = cl_cq
      return @command_queue
    else
      return nil
    end
  end

  # cl_command_queue : command_queue
  def retainCommandQueue(command_queue: @command_queue)
    return OpenCL.clRetainCommandQueue(command_queue)
  end

  # cl_command_queue : command_queue
  def releaseCommandQueue(command_queue: @command_queue)
    return OpenCL.clReleaseCommandQueue(command_queue)
  end

  # cl_command_queue : command_queue
  def flush(command_queue: @command_queue)
    return OpenCL.clFlush(command_queue)
  end

  # cl_command_queue : command_queue
  def finish(command_queue: @command_queue)
    return OpenCL.clFinish(command_queue)
  end

  # cl_command_queue      : command_queue
  # cl_command_queue_info : param_name
  def getCommandQueueInfo(param_name, command_queue: @command_queue, error_info: nil)
    # size_t          : param_value_size
    # void *          : param_value
    # size_t *        : param_value_size_ret
    param_value_buf_length = 1024
    param_value_buf = ' ' * param_value_buf_length
    param_value_size_ret_buf = ' ' * 4

    err = OpenCL.clGetCommandQueueInfo(command_queue, param_name, param_value_buf_length, param_value_buf, param_value_size_ret_buf)
    error_info << err if error_info != nil

    param_value_size_ret = param_value_size_ret_buf.unpack("L")[0]

    unpack_format = @@param2unpack[param_name]
    return param_value_buf.unpack(unpack_format)[0]
  end

  @@param2unpack = {
    OpenCL::CL_QUEUE_CONTEXT => "Q",
    OpenCL::CL_QUEUE_DEVICE => "Q",
    OpenCL::CL_QUEUE_REFERENCE_COUNT => "L",
    OpenCL::CL_QUEUE_PROPERTIES => "L",
  }

  # cl_command_queue    : command_queue
  # cl_mem              : buffer
  # cl_bool             : blocking_read
  # size_t              : offset
  # size_t              : size
  # void *              : ptr
  # const cl_event *    : event_wait_list
  # cl_event *          : event
  def enqueueReadBuffer(buffer, blocking_read, offset, size, ptr, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueReadBuffer(command_queue, buffer, blocking_read, offset, size, ptr, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue   : command_queue
  # cl_mem             : buffer
  # cl_bool            : blocking_write
  # size_t             : offset
  # size_t             : size
  # const void *       : ptr
  # const cl_event *   : event_wait_list
  # cl_event *         : event
  def enqueueWriteBuffer(buffer, blocking_write, offset, size, ptr, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueWriteBuffer(command_queue, buffer, blocking_write, offset, size, ptr, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue   : command_queue
  # cl_mem             : buffer
  # const void *       : pattern
  # size_t             : offset
  # size_t             : size
  # const cl_event *   : event_wait_list
  # cl_event *         : event
  def enqueueFillBuffer(buffer, pattern, offset, size, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length
    # size_t             : pattern_size
    pattern_size = pattern.size

    err = OpenCL.clEnqueueFillBuffer(command_queue, buffer, pattern, pattern_size, offset, size, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end


  # cl_command_queue   : command_queue
  # cl_mem             : src_buffer
  # cl_mem             : dst_buffer
  # size_t             : src_offset
  # size_t             : dst_offset
  # size_t             : size
  # const cl_event *   : event_wait_list
  # cl_event *         : event
  def enqueueCopyBuffer(src_buffer, dst_buffer, src_offset, dst_offset, size, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueCopyBuffer(command_queue, src_buffer, dst_buffer, src_offset, dst_offset, size, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue     : command_queue
  # cl_mem               : image
  # cl_bool              : blocking_read
  # const size_t *       : origin[3]
  # const size_t *       : region[3]
  # size_t               : row_pitch
  # size_t               : slice_pitch
  # void *               : ptr
  # const cl_event *     : event_wait_list
  # cl_event *           : event
  def enqueueReadImage(image, blocking_read, origin, region, row_pitch, slice_pitch, ptr, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueReadImage(command_queue, image, blocking_read, origin.pack("Q3"), region.pack("Q3"), row_pitch, slice_pitch, ptr, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue     : command_queue
  # cl_mem               : image
  # cl_bool              : blocking_write
  # const size_t *       : origin[3]
  # const size_t *       : region[3]
  # size_t               : row_pitch
  # size_t               : slice_pitch
  # void *               : ptr
  # const cl_event *     : event_wait_list
  # cl_event *           : event
  def enqueueWriteImage(image, blocking_write, origin, region, row_pitch, slice_pitch, ptr, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueWriteImage(command_queue, image, blocking_write, origin.pack("Q3"), region.pack("Q3"), row_pitch, slice_pitch, ptr, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue   : command_queue
  # cl_mem             : image
  # const void *       : fill_color
  # const size_t *     : origin[3]
  # const size_t *     : region[3]
  # const cl_event *   : event_wait_list
  # cl_event *         : event
  def enqueueFillImage(image, fill_color, origin, region, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueFillImage(command_queue, image, fill_color, origin.pack("Q3"), region.pack("Q3"), num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue     : command_queue
  # cl_mem               : src_image
  # cl_mem               : dst_image
  # const size_t *       : src_origin[3]
  # const size_t *       : dst_origin[3]
  # const size_t *       : region[3]
  # const cl_event *     : event_wait_list
  # cl_event *           : event
  def enqueueCopyImage(src_image, dst_image, src_origin, dst_origin, region, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueCopyImage(command_queue, src_image, dst_image, src_origin.pack("Q3"), dst_origin.pack("Q3"), region.pack("Q3"), num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue : command_queue
  # cl_mem           : src_image
  # cl_mem           : dst_buffer
  # const size_t *   : src_origin[3]
  # const size_t *   : region[3]
  # size_t           : dst_offset
  # const cl_event * : event_wait_list
  # cl_event *       : event
  def enqueueCopyImageToBuffer(src_image, dst_buffer, src_origin, region, dst_offset, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueCopyImageToBuffer(command_queue, src_image, dst_buffer, src_origin.pack("Q3"), region.pack("Q3"), dst_offset, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue : command_queue
  # cl_mem           : src_buffer
  # cl_mem           : dst_image
  # size_t           : src_offset
  # const size_t *   : dst_origin[3]
  # const size_t *   : region[3]
  # const cl_event * : event_wait_list
  # cl_event *       : event
  def enqueueCopyBufferToImage(src_buffer, dst_image, src_offset, dst_origin, region, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueCopyBufferToImage(command_queue, src_buffer, dst_image, src_offset, dst_origin.pack("Q3"), region.pack("Q3"), num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end


  # cl_command_queue : command_queue
  # cl_mem           : buffer
  # cl_bool          : blocking_map
  # cl_map_flags     : map_flags
  # size_t           : offset
  # size_t           : size
  # const cl_event * : event_wait_list
  # cl_event *       : event
  def enqueueMapBuffer(buffer, blocking_map, map_flags, offset, size, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length
    errcode_ret_buf = ' ' * 4

    mapped_ptr = OpenCL.clEnqueueMapBuffer(command_queue, buffer, blocking_map, map_flags, offset, size, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf, errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    if errcode_ret == OpenCL::CL_SUCCESS
      return mapped_ptr
    else
      return nil
    end
  end

  # cl_command_queue  : command_queue
  # cl_mem            : image
  # cl_bool           : blocking_map
  # cl_map_flags      : map_flags
  # const size_t *    : origin[3]
  # const size_t *    : region[3]
  # const cl_event *  : event_wait_list
  # cl_event *        : event
  def enqueueMapImage(buffer, blocking_map, map_flags, origin, region, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length
    errcode_ret_buf = ' ' * 4

    image_row_pitch_buf = ' ' * 8
    image_slice_pitch_buf = ' ' * 8

    mapped_ptr = OpenCL.clEnqueueMapImage(command_queue, buffer, blocking_map, map_flags, origin.pack("Q3"), region.pack("Q3"), image_row_pitch_buf, image_slice_pitch_buf, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf, errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    image_row_pitch = image_row_pitch_buf.unpack("Q")[0]
    image_slice_pitch = image_slice_pitch_buf.unpack("Q")[0]

    event << event_buf.unpack("Q")[0] if event != nil
    if errcode_ret == OpenCL::CL_SUCCESS
      return mapped_ptr, image_row_pitch, image_slice_pitch
    else
      return nil, image_row_pitch, image_slice_pitch
    end
  end

  # cl_command_queue : command_queue
  # cl_mem           : memobj
  # void *           : mapped_ptr
  # const cl_event * : event_wait_list
  # cl_event *       : event
  def enqueueUnmapMemObject(memobj, mapped_ptr, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueUnmapMemObject(command_queue, memobj, mapped_ptr, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue : command_queue
  # cl_kernel        : kernel
  # cl_uint          : work_dim
  # const size_t *   : global_work_offset
  # const size_t *   : global_work_size
  # const size_t *   : local_work_size
  # const cl_event * : event_wait_list
  # cl_event *       : event
  def enqueueNDRangeKernel(kernel, work_dim, global_work_offset, global_work_size, local_work_size, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    global_work_offset_buf = global_work_offset == nil ? nil : global_work_offset.pack("Q*")
    local_work_size_buf = local_work_size == nil ? nil : local_work_size.pack("Q*")

    err = OpenCL.clEnqueueNDRangeKernel(command_queue, kernel, work_dim, global_work_offset_buf, global_work_size.pack("Q*"), local_work_size_buf, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue  : command_queue
  # cl_kernel         : kernel
  # const cl_event *  : event_wait_list
  # cl_event *        : event
  def enqueueTask(kernel, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueTask(command_queue, kernel, num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue      : command_queue
  # const cl_mem *        : mem_objects
  # const cl_event *      : event_wait_list
  # cl_event *            : event
  def enqueueAcquireGLObjects(mem_objects, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueAcquireGLObjects(command_queue, mem_objects.length, mem_objects.pack("Q*"), num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end

  # cl_command_queue      : command_queue
  # const cl_mem *        : mem_objects
  # const cl_event *      : event_wait_list
  # cl_event *            : event
  def enqueueReleaseGLObjects(mem_objects, command_queue: @command_queue, event_wait_list: nil, event: nil, error_info: nil)
    event_buf = event == nil ? nil : ' ' * 8
    num_events_in_wait_list = event_wait_list == nil ? 0 : event_wait_list.length

    err = OpenCL.clEnqueueReleaseGLObjects(command_queue, mem_objects.length, mem_objects.pack("Q*"), num_events_in_wait_list, event_wait_list == nil ? nil : event_wait_list.pack("Q"), event_buf)
    error_info << err if error_info != nil

    event << event_buf.unpack("Q")[0] if event != nil
    return err
  end
end

################################################################################

class CLUProgram
  attr_reader :program # cl_program

  def initialize
    @program = nil
  end

  # cl_context    : context
  # const char ** : strings
  def createProgramWithSource(context, strings, error_info: nil)
    # cl_uint        : count
    # const size_t * : lengths
    # cl_int *       : errcode_ret
    errcode_ret_buf = ' ' * 4
    count = strings.length
    lengthes = strings.collect {|src| src.length}

    program = OpenCL.clCreateProgramWithSource(context, count, strings.pack("p*"), lengthes.pack("Q*"), errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    if errcode_ret == OpenCL::CL_SUCCESS
      @program = program
      return @program
    else
      return nil
    end
  end

  # cl_program : program
  def retainProgram(program: @program)
    return OpenCL.clRetainProgram(program)
  end

  # cl_program : program
  def releaseProgram(program: @program)
    return OpenCL.clReleaseProgram(program)
  end

  # cl_program           : program
  # const cl_device_id * : device_list
  # const char *         : options 
  # void *               : pfn_notify(cl_program, void*)
  # void *               : user_data
  def buildProgram(device_list, program: @program, options: nil, pfn_notify: nil, user_data: nil, error_info: nil)
    num_devices = device_list.length
    err = OpenCL.clBuildProgram(program, num_devices, device_list.pack("Q*"), options, pfn_notify, user_data)

    if err < 0 && error_info != nil
      log_size_buf = ' ' * 4
      OpenCL.clGetProgramBuildInfo(program, device_list[0], OpenCL::CL_PROGRAM_BUILD_LOG, 0, nil, log_size_buf)
      log_size = log_size_buf.unpack("L")[0]
      program_log = ' ' * log_size
      OpenCL.clGetProgramBuildInfo(program, device_list[0], OpenCL::CL_PROGRAM_BUILD_LOG, log_size, program_log, nil)

      error_info << program_log
    end

    return err
  end
end

################################################################################

class CLUKernel
  attr_reader :kernel, :name # cl_kernel and the name of '__kernel' entry point

  def initialize
    @kernel = nil
    @name = nil
  end

  # cl_program   : program
  # const char * : kernel_name
  def createKernel(program, kernel_name, error_info: nil)
    errcode_ret_buf = ' ' * 4
    kernel = OpenCL.clCreateKernel(program, kernel_name, errcode_ret_buf)
    errcode_ret = errcode_ret_buf.unpack("l")[0]
    error_info << errcode_ret if error_info != nil

    if errcode_ret == OpenCL::CL_SUCCESS
      @kernel = kernel
      @name   = kernel_name
      return @kernel
    else
      return nil
    end
  end

  # cl_kernel       : kernel
  # cl_kernel_info  : param_name
  def getKernelInfo(param_name, kernel: @kernel, error_info: nil)
    # size_t          : param_value_size
    # void *          : param_value
    # size_t *        : param_value_size_ret
    param_value_buf_length = 1024
    param_value_buf = ' ' * param_value_buf_length
    param_value_size_ret_buf = ' ' * 4

    err = OpenCL.clGetKernelInfo(kernel, param_name, param_value_buf_length, param_value_buf, param_value_size_ret_buf)
    error_info << err if error_info != nil

    param_value_size_ret = param_value_size_ret_buf.unpack("L")[0]

    unpack_format = @@kernel_info_param2unpack[param_name]
    case unpack_format
    when "char[]"
      return param_value_buf[0...(param_value_size_ret-1)]
    else
      return param_value_buf.unpack(unpack_format)[0]
    end
  end

  @@kernel_info_param2unpack = {
    OpenCL::CL_KERNEL_FUNCTION_NAME => "char[]",
    OpenCL::CL_KERNEL_NUM_ARGS => "L",
    OpenCL::CL_KERNEL_REFERENCE_COUNT => "L",
    OpenCL::CL_KERNEL_CONTEXT => "Q",
    OpenCL::CL_KERNEL_PROGRAM => "Q",
    OpenCL::CL_KERNEL_ATTRIBUTES => "char[]",
  }

  # cl_kernel : kernel
  def retainKernel(kernel: @kernel)
    return OpenCL.clRetainKernel(kernel)
  end

  # cl_kernel : kernel
  def releaseKernel(kernel: @kernel)
    return OpenCL.clReleaseKernel(kernel)
  end

  def sizeof_type(fiddle_type)
    size = 0

    case fiddle_type
    when Fiddle::TYPE_VOIDP
      size = Fiddle::SIZEOF_VOIDP
    when Fiddle::TYPE_CHAR, -Fiddle::TYPE_CHAR
      size = Fiddle::SIZEOF_CHAR
    when Fiddle::TYPE_SHORT, -Fiddle::TYPE_SHORT
      size = Fiddle::SIZEOF_SHORT
    when Fiddle::TYPE_INT, -Fiddle::TYPE_INT
      size = Fiddle::SIZEOF_INT
    when Fiddle::TYPE_LONG, -Fiddle::TYPE_LONG
      size = Fiddle::SIZEOF_LONG
    when Fiddle::TYPE_FLOAT
      size = Fiddle::SIZEOF_FLOAT
    when Fiddle::TYPE_DOUBLE
      size = Fiddle::SIZEOF_DOUBLE
    when Fiddle::TYPE_SIZE_T
      size = Fiddle::SIZEOF_SIZE_T
    when Fiddle::TYPE_SSIZE_T
      size = Fiddle::SIZEOF_SSIZE_T
    when Fiddle::TYPE_PTRDIFF_T
      size = Fiddle::SIZEOF_PTRDIFF_T
    when Fiddle::TYPE_INTPTR_T
      size = Fiddle::SIZEOF_INTPTR_T
    when Fiddle::TYPE_UINTPTR_T
      size = Fiddle::SIZEOF_UINTPTR_T
    end

    if Fiddle.const_defined?(:TYPE_LONG_LONG) && (fiddle_type == Fiddle::TYPE_LONG_LONG || fiddle_type == -Fiddle::TYPE_LONG_LONG)
      size = Fiddle::SIZEOF_LONG_LONG
    end

    return size
  end
  private :sizeof_type

  def pack_format(fiddle_type)
    format = ""

    case fiddle_type
    when Fiddle::TYPE_VOIDP
      format = (Fiddle.const_defined?(:TYPE_LONG_LONG) && (Fiddle::SIZEOF_VOIDP == Fiddle::SIZEOF_LONG_LONG)) ? "Q" : "L"

    when Fiddle::TYPE_CHAR, -Fiddle::TYPE_CHAR
      format = fiddle_type > 0 ? "c" : "C"

    when Fiddle::TYPE_SHORT, -Fiddle::TYPE_SHORT
      format = fiddle_type > 0 ? "s" : "S"

    when Fiddle::TYPE_INT, -Fiddle::TYPE_INT
      format = fiddle_type > 0 ? "i" : "I"

    when Fiddle::TYPE_LONG, -Fiddle::TYPE_LONG
      format = fiddle_type > 0 ? "l" : "L"

    when Fiddle::TYPE_FLOAT
      format = "F"

    when Fiddle::TYPE_DOUBLE
      format = "D"

    when Fiddle::TYPE_SIZE_T, Fiddle::TYPE_UINTPTR_T
      size = sizeof_type(fiddle_type)
      case size
      when Fiddle::SIZEOF_INT
        format = "I"
      when Fiddle::SIZEOF_LONG
        format = "L"
      else
        if Fiddle.const_defined?(:TYPE_LONG_LONG) && size == Fiddle::SIZEOF_LONG_LONG
          format = "Q"
        end
      end

    when Fiddle::TYPE_SSIZE_T, Fiddle::TYPE_PTRDIFF_T, Fiddle::TYPE_INTPTR_T
      size = sizeof_type(fiddle_type)
      case size
      when Fiddle::SIZEOF_INT
        format = "i"
      when Fiddle::SIZEOF_LONG
        format = "l"
      else
        if Fiddle.const_defined?(:TYPE_LONG_LONG) && size == Fiddle::SIZEOF_LONG_LONG
          format = "q"
        end
      end
    end

    if Fiddle.const_defined?(:TYPE_LONG_LONG) && (fiddle_type == Fiddle::TYPE_LONG_LONG || fiddle_type == -Fiddle::TYPE_LONG_LONG)
      format = fiddle_type > 0 ? "q" : "Q"
    end

    return format
  end
  private :sizeof_type

  # cl_kernel                 : kernel
  # cl_uint                   : arg_index
  # Fiddle::TYPE_VOIDP, etc.  : arg_type
  # const void *              : arg_value
  def setKernelArg(arg_index, arg_type, arg_value, kernel: @kernel)
    num_elements = arg_value.length
    arg_size = sizeof_type(arg_type) * num_elements
    pack_arg = pack_format(arg_type) + num_elements.to_s

    return OpenCL.clSetKernelArg(kernel, arg_index, arg_size, arg_value.pack(pack_arg))
  end

  # cl_kernel       : kernel
  # cl_uint         : arg_indx
  # cl_kernel_info  : param_name
  def getKernelArgInfo(arg_index, param_name, kernel: @kernel, error_info: nil)
    # size_t          : param_value_size
    # void *          : param_value
    # size_t *        : param_value_size_ret
    param_value_buf_length = 1024
    param_value_buf = ' ' * param_value_buf_length
    param_value_size_ret_buf = ' ' * 4

    err = OpenCL.clGetKernelArgInfo(kernel, arg_index, param_name, param_value_buf_length, param_value_buf, param_value_size_ret_buf)
    error_info << err if error_info != nil
    param_value_size_ret = param_value_size_ret_buf.unpack("L")[0]

    unpack_format = @@kernel_arginfo_param2unpack[param_name]
    case unpack_format
    when "char[]"
      return param_value_buf[0...(param_value_size_ret-1)]
    else
      return param_value_buf.unpack(unpack_format)[0]
    end
  end

  @@kernel_arginfo_param2unpack = {
    OpenCL::CL_KERNEL_ARG_ADDRESS_QUALIFIER => "L",
    OpenCL::CL_KERNEL_ARG_ACCESS_QUALIFIER => "L",
    OpenCL::CL_KERNEL_ARG_TYPE_NAME => "char[]",
    OpenCL::CL_KERNEL_ARG_TYPE_QUALIFIER => "L",
    OpenCL::CL_KERNEL_ARG_NAME => "char[]",
  }

  # cl_kernel                  : kernel
  # cl_device_id               : device
  # cl_kernel_work_group_info  : param_name
  def getKernelWorkGroupInfo(param_name, device, kernel: @kernel, error_info: nil)
    # size_t          : param_value_size
    # void *          : param_value
    # size_t *        : param_value_size_ret
    param_value_buf_length = 1024
    param_value_buf = ' ' * param_value_buf_length
    param_value_size_ret_buf = ' ' * 4

    err = OpenCL.clGetKernelWorkGroupInfo(kernel, device, param_name, param_value_buf_length, param_value_buf, param_value_size_ret_buf)
    error_info << err if error_info != nil
    param_value_size_ret = param_value_size_ret_buf.unpack("L")[0]

    unpack_format = @@kernel_workgroupinfo_param2unpack[param_name]
    case unpack_format
    when "Q3"
      # Ref.: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clGetKernelWorkGroupInfo.html
      #   CL_INVALID_VALUE if param_name is CL_KERNEL_GLOBAL_WORK_SIZE and device
      #   is not a custom device or kernel is not a built-in kernel.
      if param_name == OpenCL::CL_KERNEL_GLOBAL_WORK_SIZE && err == OpenCL::CL_INVALID_VALUE
        return [0, 0, 0]
      else
        return param_value_buf.unpack(unpack_format)
      end
    else
      return param_value_buf.unpack(unpack_format)[0]
    end
  end

  @@kernel_workgroupinfo_param2unpack = {
    OpenCL::CL_KERNEL_GLOBAL_WORK_SIZE => "Q3",
    OpenCL::CL_KERNEL_WORK_GROUP_SIZE => "Q",
    OpenCL::CL_KERNEL_COMPILE_WORK_GROUP_SIZE => "Q3",
    OpenCL::CL_KERNEL_LOCAL_MEM_SIZE => "Q",
    OpenCL::CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE => "Q",
    OpenCL::CL_KERNEL_PRIVATE_MEM_SIZE => "Q",
  }
end

################################################################################

class CLU

  @@image_format = {
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
    OpenCL::CL_ABGR_APPLE       => "CL_ABGR_APPLE"
  }

  def self.getImageFormatString(image_channel)
    return @@image_format.has_key?(image_channel) ? @@image_format[image_channel] : image_channel.to_s
  end
end

################################################################################

=begin
Ruby-OpenCL : Yet another OpenCL wrapper for Ruby
Copyright (c) 2015 vaiorabbit <http://twitter.com/vaiorabbit>

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

    2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

    3. This notice may not be removed or altered from any source
    distribution.
=end
