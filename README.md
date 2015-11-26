<!-- -*- mode:markdown; coding:utf-8; -*- -->

# Yet another OpenCL wrapper for Ruby #

A Ruby binding for OpenCL 1.2

*   Created : 2015-10-25
*   Last modified : 2015-11-26


## Features ##

*   Based on Fiddle (One of the Ruby standard libraries that wraps libffi)
	*   You don't need to build C extension library

*   Interoperability with OpenGL
	*   My OpenGL gem (opengl-bindings ( https://github.com/vaiorabbit/ruby-opengl ) version 1.5.2 and later) provides some platform-specific APIs essential for context sharing.
	*   'opengl-bindings' is also based on Fiddle.
	*   Supported Platforms: Windows, Mac OS X and Linux (X Window)
	*   See 'createContextWithGLInterop (sample/util/clu.rb)' for details.


## Prerequisites ##

*   Fiddle
	*   A libffi wrapper
	*   Standard library since Ruby 2.0.0
	*   I recommend you to use Ruby 2.1.2 and later, which fixed Fiddle's memory leak issue (https://bugs.ruby-lang.org/issues/9599).

### For sample ###

Use GLFW or GLUT for creating windows and OpenGL rendering contexts.

*   GLFW
    *   http://www.glfw.org/
    *   http://www.glfw.org/download.html

*   freeglut
    *   http://freeglut.sourceforge.net
    *   http://freeglut.sourceforge.net/index.php#download


## Installation ##

Via RubyGems ( https://rubygems.org/gems/opencl-bindings ):

    $ gem install opencl-bindings

Or grab all library codes (`lib/*.rb') and use them by adding as one of the load paths like:

    $ ruby -I ./lib your_app.rb


## How to use ##

See sample/hello.rb.

To get more samples, please visit:
https://github.com/vaiorabbit/ruby-opencl


## License ##

The zlib/libpng License ( http://opensource.org/licenses/Zlib ).

    Copyright (c) 2015 vaiorabbit <http://twitter.com/vaiorabbit>

    This software is provided 'as-is', without any express or implied
    warranty. In no event will the authors be held liable for any damages
    arising from the use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
       claim that you wrote the original software. If you use this software in a
       product, an acknowledgment in the product documentation would be
       appreciated but is not required.

    2. Altered source versions must be plainly marked as such, and must not be
       misrepresented as being the original software.

    3. This notice may not be removed or altered from any source distribution.
