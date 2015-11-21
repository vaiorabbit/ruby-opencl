# Ref.: https://github.com/pyopencl/pyopencl/blob/master/examples/gl_particle_animation.pyg
#       http://enja.org/2011/03/22/adventures-in-pyopencl-part-2-particles-with-pyopengl/ (See LICENSE.txt)

require_relative '../util/setup_glut'
require_relative '../util/clu'

include OpenCL

# Load DLL
begin
  OpenCL.load_lib('c:/Windows/System32/OpenCL.dll') # For Windows
rescue
  OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
end

$width = 800
$height = 600
$num_particles = 100000
$time_step = 0.005
$mouse_down = false
$mouse_old = {'x'=> 0.0, 'y'=> 0.0}
$rotate = {'x'=> 0.0, 'y'=> 0.0, 'z'=> 0.0}
$translate = {'x'=> 0.0, 'y'=> 0.0, 'z'=> 0.0}
$initial_translate = {'x'=> 0.0, 'y'=> 0.0, 'z'=> -2.5}

$pos = nil
$vel = nil
$gl_position = nil
$gl_color = nil
$clu_cq = nil
$clu_prog = nil
$clu_kern = nil
$clu_start_position = nil
$clu_start_velocity = nil
$clu_velocity = nil
$clu_gl_position = nil
$clu_gl_color = nil

def create_vbo(data_size, data, target, usage)
  id_buf = ' ' * 4
  glGenBuffers(1, id_buf)
  id = id_buf.unpack("L")[0]
  glBindBuffer(target, id)
  glBufferData(target, data_size, data.pack("F*"), usage)
  glBindBuffer(target, 0)

  return id
end

def glut_window()
  glutInit([1].pack('I'), [""].pack('p'))
  glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH)
  glutInitWindowSize($width, $height)
  glutInitWindowPosition(0, 0)
  window = glutCreateWindow("Particle Simulation")

  glutDisplayFunc(GLUT.create_callback(:GLUTDisplayFunc, method(:on_display).to_proc))  # Called by GLUT every frame
  glutKeyboardFunc(GLUT.create_callback(:GLUTKeyboardFunc, method(:on_key).to_proc))
  glutMouseFunc(GLUT.create_callback(:GLUTMouseFunc, method(:on_click).to_proc))
  glutMotionFunc(GLUT.create_callback(:GLUTMotionFunc, method(:on_mouse_move).to_proc))
  glutTimerFunc(10, GLUT.create_callback(:GLUTTimerFunc, method(:on_timer).to_proc), 10)  # Call draw every 30 ms

  glClearColor(0.0, 0.0, 0.0, 1.0)

  glViewport(0, 0, $width, $height)
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  gluPerspective(60.0, $width / $height.to_f, 0.1, 1000.0)

  return window
end

def initial_buffers(num_particles)
  pos = Array.new(4 * num_particles) { 0.0 }
  vel = Array.new(4 * num_particles) { 0.0 }
  color = Array.new(4 * num_particles) { 0.0 }

  num_particles.times do |i|
    rad = rand(0.2..0.5)
    pos[4*i + 0] = rad * Math.sin(2 * Math::PI * i / num_particles)
    pos[4*i + 1] = rad * Math.cos(2 * Math::PI * i / num_particles)
    pos[4*i + 2] = 0.0
    pos[4*i + 3] = 1.0

    life_r = rand
    vel[4*i + 0] = 2 * rand
    vel[4*i + 1] = rand
    vel[4*i + 2] = 3.0 + rand(0.1)
    vel[4*i + 3] = life_r

    color[4*i + 0] = 0.0
    color[4*i + 1] = 1.0
    color[4*i + 2] = 1.0
    color[4*i + 3] = 1.0
  end

  gl_position = create_vbo(Fiddle::SIZEOF_FLOAT * pos.length, pos, GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW)
  gl_color    = create_vbo(Fiddle::SIZEOF_FLOAT * color.length, color, GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW)

  return pos, vel, gl_position, gl_color
end

def on_timer(t)
  glutTimerFunc(t, GLUT.create_callback(:GLUTTimerFunc, method(:on_timer).to_proc), t)
  glutPostRedisplay()
end

def on_key(key, x, y)
  case key
  when 27 # Press ESC to exit.
    exit
  end
end

def on_click(button, state, x, y)
  $mouse_old['x'] = x
  $mouse_old['y'] = y
end

def on_mouse_move(x, y)
  $rotate['x'] += (y - $mouse_old['y']) * 0.2
  $rotate['y'] += (x - $mouse_old['x']) * 0.2

  $mouse_old['x'] = x
  $mouse_old['y'] = y
end

def on_display()
  # Update or particle positions by calling the OpenCL kernel

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
  glFinish()

  $clu_cq.enqueueAcquireGLObjects([$clu_gl_position.mem.to_i, $clu_gl_color.mem.to_i])
  $clu_cq.enqueueNDRangeKernel($clu_kern.kernel, 1, nil, [$pos.length / 4], nil)
  $clu_cq.enqueueReleaseGLObjects([$clu_gl_position.mem.to_i, $clu_gl_color.mem.to_i])
  $clu_cq.finish

  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()

  # Handle mouse transformations
  glTranslatef($initial_translate['x'], $initial_translate['y'], $initial_translate['z'])
  glRotatef($rotate['x'], 1, 0, 0)
  glRotatef($rotate['y'], 0, 1, 0) #we switched around the axis so make this rotate_z
  glTranslatef($translate['x'], $translate['y'], $translate['z'])

  # Render the particles
  glEnable(GL_POINT_SMOOTH)
  glPointSize(2)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  # Set up the VBOs
  glBindBuffer(GL_ARRAY_BUFFER, $gl_color)
  glColorPointer(4, GL_FLOAT, 0, nil)
  glBindBuffer(GL_ARRAY_BUFFER, $gl_position)
  glVertexPointer(4, GL_FLOAT, 0, nil)
  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_COLOR_ARRAY)

  # Draw the VBOs
  glDrawArrays(GL_POINTS, 0, $num_particles)

  glDisableClientState(GL_COLOR_ARRAY)
  glDisableClientState(GL_VERTEX_ARRAY)

  glDisable(GL_BLEND)

  glutSwapBuffers()
end

if __FILE__ == $0
  #
  # OpenGL
  #
  window = glut_window()

  $pos, $vel, $gl_position, $gl_color = initial_buffers($num_particles)

  #
  # OpenCL
  #

  # Platform
  clu_platform = CLUPlatform.new

  OpenCL.import_ext(clu_platform.platforms[0])
  OpenCL.import_gl
  OpenCL.import_gl_ext(clu_platform.platforms[0])

  # Devices
  clu_device = CLUDevice.new(clu_platform.platforms[0], CL_DEVICE_TYPE_DEFAULT)

  # Context
  $clu_ctx = CLUContext.newContextWithGLInterop([OpenCL::CL_CONTEXT_PLATFORM, clu_platform.platforms[0], 0], clu_device.devices, clu_platform.platforms[0])

  # Command Queues
  $clu_cq = CLUCommandQueue.newCommandQueue($clu_ctx.context, clu_device.devices[0])

  $clu_velocity       = CLUMemory.newBuffer($clu_ctx.context, CL_MEM_COPY_HOST_PTR, Fiddle::SIZEOF_FLOAT * $vel.length, $vel.pack("F*"))
  $clu_start_position = CLUMemory.newBuffer($clu_ctx.context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, Fiddle::SIZEOF_FLOAT * $pos.length, $pos.pack("F*"))
  $clu_start_velocity = CLUMemory.newBuffer($clu_ctx.context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, Fiddle::SIZEOF_FLOAT * $vel.length, $vel.pack("F*"))

  $clu_gl_position = CLUMemory.newFromGLBuffer($clu_ctx.context, CL_MEM_READ_WRITE, $gl_position)
  $clu_gl_color    = CLUMemory.newFromGLBuffer($clu_ctx.context, CL_MEM_READ_WRITE, $gl_color)

  kernel_source = <<-SRC
    __kernel void particle_fountain(__global float4* position, 
                                                __global float4* color, 
                                                __global float4* velocity, 
                                                __global float4* start_position, 
                                                __global float4* start_velocity, 
                                                float time_step)
    {
        unsigned int i = get_global_id(0);
        float4 p = position[i];
        float4 v = velocity[i];
        float life = velocity[i].w;
        life -= time_step;
        if (life <= 0.f)
        {
            p = start_position[i];
            v = start_velocity[i];
            life = 1.0f;    
        }

        v.z -= 9.8f*time_step;
        p.x += v.x*time_step;
        p.y += v.y*time_step;
        p.z += v.z*time_step;
        v.w = life;

        position[i] = p;
        velocity[i] = v;

        color[i].w = life; /* Fade points as life decreases */
    }
  SRC

  $clu_prog = CLUProgram.newProgramWithSource($clu_ctx.context, [kernel_source])
  $clu_prog.buildProgram(clu_device.devices)
  $clu_kern = CLUKernel.newKernel($clu_prog.program, "particle_fountain")

  $clu_kern.setKernelArg(0, Fiddle::TYPE_VOIDP, [$clu_gl_position.mem.to_i])
  $clu_kern.setKernelArg(1, Fiddle::TYPE_VOIDP, [$clu_gl_color.mem.to_i])
  $clu_kern.setKernelArg(2, Fiddle::TYPE_VOIDP, [$clu_velocity.mem.to_i])
  $clu_kern.setKernelArg(3, Fiddle::TYPE_VOIDP, [$clu_start_position.mem.to_i])
  $clu_kern.setKernelArg(4, Fiddle::TYPE_VOIDP, [$clu_start_velocity.mem.to_i])
  $clu_kern.setKernelArg(5, Fiddle::TYPE_FLOAT, [$time_step])

  glutMainLoop()
end
