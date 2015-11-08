# -*- coding: utf-8 -*-
require 'fiddle/import'
require_relative 'opencl'

# OpenCL 1.2 - Functions for OpenGL interoperability

module OpenCL

  # define (from cl_gl.h)

  # cl_gl_object_type = 0x2000 - 0x200F enum values are currently taken
  CL_GL_OBJECT_BUFFER                     = 0x2000
  CL_GL_OBJECT_TEXTURE2D                  = 0x2001
  CL_GL_OBJECT_TEXTURE3D                  = 0x2002
  CL_GL_OBJECT_RENDERBUFFER               = 0x2003
  CL_GL_OBJECT_TEXTURE2D_ARRAY            = 0x200E
  CL_GL_OBJECT_TEXTURE1D                  = 0x200F
  CL_GL_OBJECT_TEXTURE1D_ARRAY            = 0x2010
  CL_GL_OBJECT_TEXTURE_BUFFER             = 0x2011

  # cl_gl_texture_info
  CL_GL_TEXTURE_TARGET                    = 0x2004
  CL_GL_MIPMAP_LEVEL                      = 0x2005
  CL_GL_NUM_SAMPLES                       = 0x2012

  @@cl_gl_import_done = false

  def self.import_gl

    return false unless @@cl_import_done

    # type (from cl_gl.h)

    # aliases
    typealias 'cl_gl_object_type',   'cl_uint'
    typealias 'cl_gl_texture_info',  'cl_uint'
    typealias 'cl_gl_platform_info', 'cl_uint'

    # opaque pointer
    typealias 'cl_GLsync', 'void*'

    # cl_context     : context
    # cl_mem_flags   : flags
    # cl_GLuint      : bufobj
    # int *          : errcode_ret
    extern 'cl_mem clCreateFromGLBuffer(cl_context, cl_mem_flags, cl_GLuint, int *)'

    # cl_context      : context
    # cl_mem_flags    : flags
    # cl_GLenum       : target
    # cl_GLint        : miplevel
    # cl_GLuint       : texture
    # cl_int *        : errcode_ret
    extern 'cl_mem clCreateFromGLTexture(cl_context, cl_mem_flags, cl_GLenum, cl_GLint, cl_GLuint, cl_int *)'

    # cl_context   : context
    # cl_mem_flags : flags
    # cl_GLuint    : renderbuffer
    # cl_int *     : errcode_ret
    extern 'cl_mem clCreateFromGLRenderbuffer(cl_context, cl_mem_flags, cl_GLuint, cl_int *)'

    # cl_mem                : memobj
    # cl_gl_object_type *   : gl_object_type
    # cl_GLuint *           : gl_object_name
    extern 'cl_int clGetGLObjectInfo(cl_mem, cl_gl_object_type *, cl_GLuint *)'

    # cl_mem               : memobj
    # cl_gl_texture_info   : param_name
    # size_t               : param_value_size
    # void *               : param_value
    # size_t *             : param_value_size_ret
    extern 'cl_int clGetGLTextureInfo(cl_mem, cl_gl_texture_info, size_t, void *, size_t *)'

    # cl_command_queue      : command_queue
    # cl_uint               : num_objects
    # const cl_mem *        : mem_objects
    # cl_uint               : num_events_in_wait_list
    # const cl_event *      : event_wait_list
    # cl_event *            : event
    extern 'cl_int clEnqueueAcquireGLObjects(cl_command_queue, cl_uint, const cl_mem *, cl_uint, const cl_event *, cl_event *)'

    # cl_command_queue      : command_queue
    # cl_uint               : num_objects
    # const cl_mem *        : mem_objects
    # cl_uint               : num_events_in_wait_list
    # const cl_event *      : event_wait_list
    # cl_event *            : event
    extern 'cl_int clEnqueueReleaseGLObjects(cl_command_queue, cl_uint, const cl_mem *, cl_uint, const cl_event *, cl_event *)'

    @@cl_gl_import_done = true

    return true
 end

end
