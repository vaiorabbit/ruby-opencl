require_relative 'tga.rb'
require_relative 'fft2d.rb'

if $0 == __FILE__
  if ARGV[0] == nil
    puts "ARGV[0] is nil"
    exit
  end
  image, w, h, bps = load_tga(ARGV[0])

  depth = (bps / 8)
  signal_src = []
  image.bytesize.times do |i|
    signal_src << image.byteslice(i).ord.to_f if (i % depth) == 0
  end

  fft = FFT2D.new(w)
  buffer = fft.create_buffer(signal_src, w, h)

  buffer = fft.apply_dft_dumb(buffer)
  buffer.transpose()
  buffer = fft.apply_dft_dumb(buffer)

  hl = buffer.width / 2
  r = buffer.width / 1.5
  buffer.height.times do |h|
    buffer.width.times do |w|
      d2 = (w - hl)**2 + (h - hl)**2
      if d2 < r**2
        buffer.set_elem(w, h, 0.0, 0.0)
      end
    end
  end

  buffer = fft.apply_idft_dumb(buffer)
  buffer.transpose()
  buffer = fft.apply_idft_dumb(buffer)

  filtered = []
  buffer.real.length.times do |i|
    pixel = (Math.sqrt(buffer.real[i]**2 + buffer.imag[i]**2)).to_i
    pixel = 255 if pixel > 255
    depth.times do 
      filtered << pixel
    end
  end
  save_tga(filtered.pack('c*'), w, h, bps)

end
