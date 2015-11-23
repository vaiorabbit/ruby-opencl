# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "opencl-bindings"
  gem.version       = "1.0.0pre2"
  gem.authors       = ["vaiorabbit"]
  gem.email         = ["vaiorabbit@gmail.com"]
  gem.summary       = %q{Bindings for OpenCL 1.2}
  gem.homepage      = "https://github.com/vaiorabbit/ruby-opencl"
  gem.require_paths = ["lib"]
  gem.license       = "zlib/libpng"
  gem.description   = <<-DESC
Ruby bindings for OpenCL 1.2 using Fiddle (For MRI >= 2.0.0).
  DESC

  gem.required_ruby_version = '>= 2.0.0'

  gem.files = Dir.glob("lib/*.rb") +
              ["README.md", "LICENSE.txt", "ChangeLog"] +
              ["sample/hello.cl", "sample/hello.rb", "sample/hello_clu.rb", "sample/report_env.rb"] +
              ["sample/util/clu.rb"]
end
