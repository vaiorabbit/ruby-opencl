require '../util/setup_glut'
require_relative '../../lib/opencl'
require_relative '../../lib/opencl_ext'
require_relative '../../lib/opencl_gl'
require_relative '../../lib/opencl_gl_ext'

def checkErrors(desc="")
  e = glGetError()
  if e != GL_NO_ERROR
    $stderr.puts "OpenGL error in \"#{desc}\": #{gluErrorString(e)} (#{e})\n"
    exit
  end
end

# Load DLL
begin
  OpenCL.load_lib('c:/Windows/System32/OpenCL.dll') # For Windows
rescue
  OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
end
include OpenCL

$width = 512
$height = 512

$t_color = 0.0
$color_A = [ 0.25, 0.45, 1.0, 1.0 ]
$color_B = [ 0.25, 0.45, 1.0, 1.0 ]
$color_C = [ 0.25, 0.45, 1.0, 1.0 ]

$t_mu  = 0.0
$mu_A  = [ -0.278, -0.479,  0.0,   0.0 ]
$mu_B  = [  0.278,  0.479,  0.0,   0.0 ]
$mu_C  = [ -0.278, -0.479, -0.231, 0.235 ]

$gl_tex_id = nil

$cl_ctx = nil
$cl_cq = nil
$cl_prog = nil
$cl_kern = nil
$cl_image_memobj = nil
$cl_result_memobj = nil
$max_workgroup_size = nil
$workgroup_size = [nil, nil]
$workgroup_items = 32


################################################################################

def create_texture(width, height)
  glActiveTexture(GL_TEXTURE1)
  tex_id_buf = ' ' * 4
  glGenTextures(1, tex_id_buf)
  tex_id = tex_id_buf.unpack("L")[0]

  glBindTexture(GL_TEXTURE_2D, tex_id)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0)
  glBindTexture(GL_TEXTURE_2D, 0)

  return tex_id
end

def render_texture(sub_data)
  glDisable( GL_LIGHTING )

  glViewport( 0, 0, $width, $height )

  glMatrixMode( GL_PROJECTION )
  glLoadIdentity()
  gluOrtho2D( -1.0, 1.0, -1.0, 1.0 )

  glMatrixMode( GL_MODELVIEW )
  glLoadIdentity()

  glMatrixMode( GL_TEXTURE )
  glLoadIdentity()

  glEnable( GL_TEXTURE_2D )
  glBindTexture( GL_TEXTURE_2D, $gl_tex_id )

  if sub_data != nil
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, $width, $height, GL_RGBA, GL_UNSIGNED_BYTE, sub_data)
  end

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_NONE)
  glBegin( GL_QUADS )

  glColor3f(1.0, 1.0, 1.0)
  glTexCoord2f( 0.0, 0.0 )
  glVertex3f( -1.0, -1.0, 0.0 )

  glTexCoord2f( 0.0, 1.0 )
  glVertex3f( -1.0, 1.0, 0.0 )

  glTexCoord2f( 1.0, 1.0 )
  glVertex3f( 1.0, 1.0, 0.0 )

  glTexCoord2f( 1.0, 0.0 )
  glVertex3f( 1.0, -1.0, 0.0 )

  glEnd()
  glBindTexture( GL_TEXTURE_2D, 0 )
  glDisable( GL_TEXTURE_2D )
end

def lerp(t, a, b)
  return (1.0 - t) * a + t * b
end

def update_mu(t, a, b)
  t_next = t + 0.01

  if t_next >= 1.0
    t_next = 0.0
    a[0] = b[0]
    a[1] = b[1]
    a[2] = b[2]
    a[3] = b[3]
    b[0] = rand(-1.0..1.0)
    b[1] = rand(-1.0..1.0)
    b[2] = rand(-1.0..1.0)
    b[3] = rand(-1.0..1.0)
  end

  return t_next
end

def random_color(col)
  col[0] = rand()
  col[1] = rand()
  col[2] = rand()
  col[3] = 1.0
end

def update_color(t, a, b)
  t_next = t + 0.01

  if t_next >= 1.0
    t_next = 0.0
    a[0] = b[0]
    a[1] = b[1]
    a[2] = b[2]
    a[3] = b[3]
    b[0] = rand()
    b[1] = rand()
    b[2] = rand()
    b[3] = 1.0
  end

  return t_next
end

def init_gl()
  $gl_tex_id = create_texture($width, $height)

  glClearColor(0.0, 0.0, 0.0, 0.0)

  glDisable(GL_DEPTH_TEST)
  glActiveTexture(GL_TEXTURE0)
  glViewport(0, 0, $width, $height)
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()

  vpos = [
    [ -1.0, -1.0],
    [ +1.0, -1.0],
    [ +1.0, +1.0],
    [ -1.0, +1.0]
  ]

  texcoords = [
    [0.0, $height],
    [$width, $height],
    [$width, 0.0],
    [0.0, 0.0],
  ]

  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_TEXTURE_COORD_ARRAY)
  glVertexPointer(2, GL_FLOAT, 0, vpos.flatten.pack("F*"))
  glClientActiveTexture(GL_TEXTURE0)
  glTexCoordPointer(2, GL_FLOAT, 0, texcoords.flatten.pack("F*"))
end

################################################################################

# cl_context : ctx, cl_device_id : dev, String : kernel_source
def build_program(ctx, dev, kernel_source)
  # Create program from file
  err_buf = ' ' * 4
  program = clCreateProgramWithSource(ctx, 1, [kernel_source].pack("p"), [kernel_source.bytesize].pack("Q"), err_buf)
  err = err_buf.unpack("l")[0]
  abort("Couldn't create the program") if err < 0

  # Build program
  err = clBuildProgram(program, 0, nil, nil, nil, nil)
  if err < 0
    # Find size of log and print to std output
    log_size_buf = ' ' * 4
    clGetProgramBuildInfo(program, dev, CL_PROGRAM_BUILD_LOG, 0, nil, log_size_buf)
    log_size = log_size_buf.unpack("L")[0]
    program_log = ' ' * log_size
    clGetProgramBuildInfo(program, dev, CL_PROGRAM_BUILD_LOG, log_size, program_log, nil)
    abort(program_log)
  end

  return program
end

def init_cl()
  cl_platforms_buf = ' ' * 4
  cl_platforms_count_buf = ' ' * 4
  # Platform
  clGetPlatformIDs(1, cl_platforms_buf, cl_platforms_count_buf)
  cl_platform = cl_platforms_buf.unpack("L")[0]

  OpenCL.import_ext(cl_platform)
  OpenCL.import_gl
  OpenCL.import_gl_ext(cl_platform)

  # Devices
  cl_devices_buf_writable_count = 32
  cl_devices_buf = ' ' * 4 * cl_devices_buf_writable_count
  cl_devices_entry_count_buf = ' ' * 4

  clGetDeviceIDs(cl_platform, CL_DEVICE_TYPE_GPU, cl_devices_buf_writable_count, cl_devices_buf, cl_devices_entry_count_buf)
  cl_devices_entry_count = cl_devices_entry_count_buf.unpack("L")[0]
  cl_device_ids = cl_devices_buf.unpack("Q#{cl_devices_entry_count}")

  # Check functionality
  image_support_buf = ' ' * 4
  clGetDeviceInfo(cl_device_ids[0], CL_DEVICE_IMAGE_SUPPORT, Fiddle::SIZEOF_INT, image_support_buf, nil);
  image_support = image_support_buf.unpack("L")[0]
  abort("Qjulia requires images: Images not supported on this device.") if image_support == CL_FALSE

  # Context
  kCGLContext = CGLGetCurrentContext() # CGLContextObj
  kCGLShareGroup = CGLGetShareGroup(kCGLContext) # CGLShareGroupObj
  props = [ CL_CONTEXT_PROPERTY_USE_CGL_SHAREGROUP_APPLE, kCGLShareGroup,
            0 ]

  errcode_ret_buf = ' ' * 4
  $cl_ctx = clCreateContext(props.pack("Q*"), 0, 0, nil, nil, errcode_ret_buf)

  # Command Queues
  $cl_cq = clCreateCommandQueue($cl_ctx, cl_device_ids[0], 0, errcode_ret_buf)

  kernel_source = "#define WIDTH (#{$width})\n#define HEIGHT (#{$height})\n" + File.read("qjulia_kernel.cl")
  $cl_prog = build_program($cl_ctx, cl_device_ids[0], kernel_source)
  $cl_kern = clCreateKernel($cl_prog, "QJuliaKernel", errcode_ret_buf);

  max_workgroup_size_buf = ' ' * 8
  clGetKernelWorkGroupInfo($cl_kern, cl_device_ids[0], CL_KERNEL_WORK_GROUP_SIZE, Fiddle::SIZEOF_LONG, max_workgroup_size_buf, nil)
  $max_workgroup_size = max_workgroup_size_buf.unpack("Q")[0]
  $workgroup_size[0] = $max_workgroup_size > 1 ? ($max_workgroup_size / $workgroup_items) : $max_workgroup_size
  $workgroup_size[1] = $max_workgroup_size / $workgroup_size[0]

  $cl_image_memobj = clCreateFromGLTexture($cl_ctx, CL_MEM_WRITE_ONLY, GL_TEXTURE_2D, 0, $gl_tex_id, errcode_ret_buf);
  $cl_result_memobj = clCreateBuffer($cl_ctx, CL_MEM_WRITE_ONLY, Fiddle::SIZEOF_CHAR * 4 * $width * $height, nil, nil);

  random_color($color_A)
  random_color($color_B)
  random_color($color_C)

end

def recompute()
  clSetKernelArg($cl_kern, 0, Fiddle::SIZEOF_VOIDP, [$cl_result_memobj.to_i].pack("Q"))
  clSetKernelArg($cl_kern, 1, 4 * Fiddle::SIZEOF_FLOAT, $mu_C.pack("F4"))
  clSetKernelArg($cl_kern, 2, 4 * Fiddle::SIZEOF_FLOAT, $color_C.pack("F4"))
  clSetKernelArg($cl_kern, 3, Fiddle::SIZEOF_FLOAT, [0.003].pack("F"))

  global = [($width % $workgroup_size[0] != 0 ? ($width / $workgroup_size[0] + 1) : $width / $workgroup_size[0]) * $workgroup_size[0],
            ($height % $workgroup_size[1] != 0 ? ($height / $workgroup_size[1] + 1) : $height / $workgroup_size[1]) * $workgroup_size[1]]
  local = [$workgroup_size[0], $workgroup_size[1]]

  clEnqueueNDRangeKernel($cl_cq, $cl_kern, 2, nil, global.pack("Q2"), local.pack("Q2"), 0, nil, nil)
  clEnqueueAcquireGLObjects($cl_cq, 1, [$cl_image_memobj.to_i].pack("Q"), 0, nil, 0)
  origin = [0, 0, 0]
  region = [$width, $height, 1]
  clEnqueueCopyBufferToImage($cl_cq, $cl_result_memobj, $cl_image_memobj, 0, origin.pack("Q3"), region.pack("Q3"), 0, nil ,0)
  clEnqueueReleaseGLObjects($cl_cq, 1, [$cl_image_memobj.to_i].pack("Q"), 0, nil, 0)
end

################################################################################

def reshape(w, h)
  glViewport(0, 0, w, h)
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  glClear(GL_COLOR_BUFFER_BIT)

  # TODO rebuild CL/GL resources

  $width = w
  $height = h
end

def display()
  glClearColor(0.0, 0.0, 0.0, 0.0)
  glClear(GL_COLOR_BUFFER_BIT)

  $t_mu = update_mu($t_mu, $mu_A, $mu_B)
  $mu_C[0] = lerp($t_mu, $mu_A[0], $mu_B[0])
  $mu_C[1] = lerp($t_mu, $mu_A[1], $mu_B[1])
  $mu_C[2] = lerp($t_mu, $mu_A[2], $mu_B[2])

  $t_color = update_color($t_color, $color_A, $color_B)
  $color_C[0] = lerp($t_color, $color_A[0], $color_B[0])
  $color_C[1] = lerp($t_color, $color_A[1], $color_B[1])
  $color_C[2] = lerp($t_color, $color_A[2], $color_B[2])

  recompute()

  render_texture(nil)

  glFinish()
  glutSwapBuffers()
end

def key(key, x, y)
  case key
  when 27 # Press ESC to exit.
    exit
  end
end

def idle()
  glutPostRedisplay()
end


if __FILE__ == $0
  glutInit([1].pack('I'), [""].pack('p'))
  glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH)
  glutInitWindowSize($width, $height)
  glutInitWindowPosition(0, 0)
  window = glutCreateWindow("Quaternion Julia Set")

  init_gl()
  init_cl()

  glutDisplayFunc(GLUT.create_callback(:GLUTDisplayFunc, method(:display).to_proc))  # Called by GLUT every frame
  glutKeyboardFunc(GLUT.create_callback(:GLUTKeyboardFunc, method(:key).to_proc))
  glutReshapeFunc(GLUT.create_callback(:GLUTReshapeFunc, method(:reshape).to_proc))
  glutIdleFunc(GLUT.create_callback(:GLUTIdleFunc, method(:idle).to_proc))

  glutMainLoop()
end
