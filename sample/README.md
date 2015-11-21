For more samples, visit https://github.com/vaiorabbit/ruby-opengl/tree/master/sample .

## Getting GLFW (http://www.glfw.org) ##

*   Windows
	*   Put glfw3.dll here.
	*   Windows pre-compiled binaries:
		*   http://www.glfw.org/download.html

*   Mac OS X
	*   run ./glfwXX_build_dylib.sh to get ./libglfw.dylib.

## Getting GLUT ##

*   Windows
	*   Use freeglut (http://freeglut.sourceforge.net).
	*   Put freeglut.dll here.
	*   Windows pre-compiled binaries:
		*   http://www.transmissionzero.co.uk/software/freeglut-devel/

*   Mac OS X
	*   glut.rb refers /System/Library/Frameworks/GLUT.framework by default.
	*   If you want to use other GLUT dll, specify the dll path and file name
		via the arguments of 'GLUT.load_dll'.
		*   See util/setup_dll.rb for example.
			*   https://github.com/vaiorabbit/ruby-opengl/blob/master/sample/util/setup_dll.rb
