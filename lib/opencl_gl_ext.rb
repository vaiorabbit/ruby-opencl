# -*- coding: utf-8 -*-
require 'fiddle/import'
require_relative 'opencl'

# OpenCL 1.2 - Extensions for OpenGL interoperability

module OpenCL

  #
  # cl_khr_gl_sharing
  #

  # Additional Error Codes
  CL_INVALID_GL_SHAREGROUP_REFERENCE_KHR  = -1000

  # cl_gl_context_info
  CL_CURRENT_DEVICE_FOR_GL_CONTEXT_KHR    = 0x2006
  CL_DEVICES_FOR_GL_CONTEXT_KHR           = 0x2007

  # Additional cl_context_properties
  CL_GL_CONTEXT_KHR                       = 0x2008
  CL_EGL_DISPLAY_KHR                      = 0x2009
  CL_GLX_DISPLAY_KHR                      = 0x200A
  CL_WGL_HDC_KHR                          = 0x200B
  CL_CGL_SHAREGROUP_KHR                   = 0x200C

  #
  # cl_khr_gl_event
  #

  CL_COMMAND_GL_FENCE_SYNC_OBJECT_KHR     = 0x200D

  #
  # cl_APPLE_gl_sharing
  #
  CL_CONTEXT_PROPERTY_USE_CGL_SHAREGROUP_APPLE        = 0x10000000
  CL_CGL_DEVICE_FOR_CURRENT_VIRTUAL_SCREEN_APPLE      = 0x10000002
  CL_CGL_DEVICES_FOR_SUPPORTED_VIRTUAL_SCREENS_APPLE  = 0x10000003
  CL_INVALID_GL_CONTEXT_APPLE                         = -1000

  # cl_platform_id : platform
  def self.import_gl_ext(platform)
    return false unless (@@cl_import_done && @@cl_gl_import_done)

    #
    # cl_khr_gl_sharing
    #

    typealias 'cl_gl_context_info', 'cl_uint'

    unless clGetExtensionFunctionAddressForPlatform(platform, 'clGetGLContextInfoKHR').null?
      # const cl_context_properties * : properties
      # cl_gl_context_info            : param_name
      # size_t                        : param_value_size
      # void *                        : param_value
      # size_t *                      : param_value_size_ret
      extern 'cl_int clGetGLContextInfoKHR(const cl_context_properties*, cl_gl_context_info, size_t, void*, size_t*)'
    end

    #
    # cl_khr_gl_event
    #

    unless clGetExtensionFunctionAddressForPlatform(platform, 'clCreateEventFromGLsyncKHR').null?
      # cl_context           : context
      # cl_GLsync            : cl_GLsync
      # cl_int *             : errcode_ret
      extern 'cl_event clCreateEventFromGLsyncKHR(cl_context, cl_GLsync, cl_int*)'
    end

    #
    # cl_APPLE_gl_sharing
    #

    unless clGetExtensionFunctionAddressForPlatform(platform, 'clGetGLContextInfoAPPLE').null?
      # cl_context          : context
      # void *              : platform_gl_ctx
      # cl_gl_platform_info : param_name
      # size_t              : param_value_size
      # void *              : param_value
      # size_t *            : param_value_size_ret
      extern 'cl_int clGetGLContextInfoAPPLE ( cl_context, void *, cl_gl_platform_info, size_t, void *, size_t *)'
    end

    return true
  end

end
