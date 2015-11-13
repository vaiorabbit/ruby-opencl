def opengl_bindings_gem_available?
  Gem::Specification.find_by_name('opengl-bindings')
rescue Gem::LoadError
  false
rescue
  Gem.available?('opengl-bindings')
end

if opengl_bindings_gem_available?
  # puts("Loading from Gem system path.")
  require 'opengl'
  require 'glu'
  require 'glfw'
else
  # puts("Loaging from local path.")
  require '../../lib/opengl'
  require '../../lib/glu'
  require '../../lib/glfw'
end

include OpenGL
include GLU
include GLFW

case OpenGL.get_platform
when :OPENGL_PLATFORM_WINDOWS
  OpenGL.load_lib('opengl32.dll', 'C:/Windows/System32')
  GLU.load_lib('GLU32.dll', 'C:/Windows/System32')
  GLFW.load_lib('glfw3.dll', '..')
when :OPENGL_PLATFORM_MACOSX
  OpenGL.load_lib('libGL.dylib', '/System/Library/Frameworks/OpenGL.framework/Libraries')
  GLU.load_lib('libGLU.dylib', '/System/Library/Frameworks/OpenGL.framework/Libraries')
  GLFW.load_lib('libglfw.dylib', '..')
when :OPENGL_PLATFORM_LINUX
  OpenGL.load_lib()
  GLU.load_lib()
  GLFW.load_lib()
else
  raise RuntimeError, "Unsupported platform."
end
