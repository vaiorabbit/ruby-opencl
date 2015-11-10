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
  require 'glut'
else
  # puts("Loaging from local path.")
  require '../../lib/opengl'
  require '../../lib/glu'
  require '../../lib/glut'
end

include OpenGL
include GLU
include GLUT

case OpenGL.get_platform
when :OPENGL_PLATFORM_WINDOWS
  OpenGL.load_lib('opengl32.dll', 'C:/Windows/System32')
  GLU.load_lib('GLU32.dll', 'C:/Windows/System32')
  GLUT.load_lib('freeglut.dll', '..')
when :OPENGL_PLATFORM_MACOSX
  OpenGL.load_lib('libGL.dylib', '/System/Library/Frameworks/OpenGL.framework/Libraries')
  GLU.load_lib('libGLU.dylib', '/System/Library/Frameworks/OpenGL.framework/Libraries')
  GLUT.load_lib('GLUT', '/System/Library/Frameworks/GLUT.framework')
when :OPENGL_PLATFORM_LINUX
  OpenGL.load_lib()
  GLU.load_lib()
  GLUT.load_lib()
else
  raise RuntimeError, "Unsupported platform."
end
