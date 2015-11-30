require_relative '../util/clu'
require_relative 'tga.rb'
require_relative 'fft2d.rb'

# Load DLL
begin
  OpenCL.load_lib('c:/Windows/System32/OpenCL.dll') # For Windows
rescue
  OpenCL.load_lib('/System/Library/Frameworks/OpenCL.framework/OpenCL') # For Mac OS X
end

include OpenCL

if $0 == __FILE__
  if ARGV[0] == nil
    puts "ARGV[0] is nil"
    exit
  end
  image, w, h, bps = load_tga(ARGV[0])
  # p image, w, h, bps
  save_tga(image, w, h, bps)
end
