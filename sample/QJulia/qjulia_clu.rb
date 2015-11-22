require 'rbconfig'
require '../util/setup_glfw'
require '../util/clu'

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

$clu_ctx = nil
$clu_cq = nil
$clu_prog = nil
$clu_kern = nil
$clu_image_memobj = nil
$clu_result_memobj = nil
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

def init_cl()
  # Platform
  clu_platform = CLUPlatform.new

  OpenCL.import_ext(clu_platform[0])
  OpenCL.import_gl
  OpenCL.import_gl_ext(clu_platform[0])

  # Devices
  clu_device = CLUDevice.new(clu_platform[0], CL_DEVICE_TYPE_GPU)

  # Check functionality
  image_support = clu_device.getDeviceInfo(CL_DEVICE_IMAGE_SUPPORT)
  abort("Qjulia requires images: Images not supported on this device.") if image_support == CL_FALSE

  # Context
  $clu_ctx = CLUContext.newContextWithGLInterop([CL_CONTEXT_PLATFORM, clu_platform[0], 0], clu_device.devices, clu_platform[0])

  # Command Queues
  $clu_cq = CLUCommandQueue.newCommandQueue($clu_ctx, clu_device[0])

  kernel_source = "#define WIDTH (#{$width})\n#define HEIGHT (#{$height})\n" + File.read("qjulia_kernel.cl")
  $clu_prog = CLUProgram.newProgramWithSource($clu_ctx, [kernel_source])
  $clu_prog.buildProgram(clu_device.devices)
  $clu_kern = CLUKernel.newKernel($clu_prog, "QJuliaKernel")

  $max_workgroup_size = $clu_kern.getKernelWorkGroupInfo(CL_KERNEL_WORK_GROUP_SIZE, clu_device[0])

  $workgroup_size[0] = $max_workgroup_size > 1 ? ($max_workgroup_size / $workgroup_items) : $max_workgroup_size
  $workgroup_size[1] = $max_workgroup_size / $workgroup_size[0]

  $clu_image_memobj = CLUMemory.newFromGLTexture($clu_ctx, CL_MEM_WRITE_ONLY, GL_TEXTURE_2D, 0, $gl_tex_id)
  $clu_result_memobj = CLUMemory.newBuffer($clu_ctx, CL_MEM_WRITE_ONLY, Fiddle::SIZEOF_CHAR * 4 * $width * $height)

  random_color($color_A)
  random_color($color_B)
  random_color($color_C)
end

def recompute()
  $clu_kern.setKernelArg(0, Fiddle::TYPE_VOIDP, [$clu_result_memobj.mem.to_i])
  $clu_kern.setKernelArg(1, Fiddle::TYPE_FLOAT, $mu_C)
  $clu_kern.setKernelArg(2, Fiddle::TYPE_FLOAT, $color_C)
  $clu_kern.setKernelArg(3, Fiddle::TYPE_FLOAT, [0.003])

  global = [($width % $workgroup_size[0] != 0 ? ($width / $workgroup_size[0] + 1) : $width / $workgroup_size[0]) * $workgroup_size[0],
            ($height % $workgroup_size[1] != 0 ? ($height / $workgroup_size[1] + 1) : $height / $workgroup_size[1]) * $workgroup_size[1]]
  local = [$workgroup_size[0], $workgroup_size[1]]

  $clu_cq.enqueueNDRangeKernel($clu_kern, 2, nil, global, local)
  $clu_cq.enqueueAcquireGLObjects([$clu_image_memobj])
  origin = [0, 0, 0]
  region = [$width, $height, 1]
  $clu_cq.enqueueCopyBufferToImage($clu_result_memobj, $clu_image_memobj, 0, origin, region)
  $clu_cq.enqueueReleaseGLObjects([$clu_image_memobj])
end

################################################################################

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
end

reshape_callback = GLFW::create_callback(:GLFWframebuffersizefun) do |window, w, h|
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

# Press ESC to exit.
key_callback = GLFW::create_callback(:GLFWkeyfun) do |window_handle, key, scancode, action, mods|
  if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS
    glfwSetWindowShouldClose(window_handle, 1)
  end
end


if __FILE__ == $0
  glfwInit()

  glfwDefaultWindowHints()
  glfwWindowHint(GLFW_DEPTH_BITS, 16)
  glfwWindowHint(GLFW_RESIZABLE, GL_FALSE) # TODO remove after making 'rebuild CL/GL resources'

  window = glfwCreateWindow( $width, $height, "Quaternion Julia Set", nil, nil )

  glfwSetFramebufferSizeCallback(window, reshape_callback)
  glfwSetKeyCallback(window, key_callback)

  glfwMakeContextCurrent( window )
  glfwSwapInterval( 1 )
  reshape_callback.call(window, $width, $height)

  init_gl()
  init_cl()

  while true
    # Draw one frame
    display()

    # Swap buffers
    glfwSwapBuffers(window)
    glfwPollEvents()

    # Check if we are still running
    break if glfwWindowShouldClose(window) != 0
  end

  glfwDestroyWindow( window )
  glfwTerminate()
end
