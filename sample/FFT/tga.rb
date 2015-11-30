def save_tga(image, w, h, bps = 32, name = "#{Time.now.strftime('%Y%m%d-%H%M%S')}.tga")
  File.open( name, 'wb' ) do |fout|
    fout.write [0].pack('c')      # identsize
    fout.write [0].pack('c')      # colourmaptype
    fout.write [2].pack('c')      # imagetype
    fout.write [0].pack('s')      # colourmapstart
    fout.write [0].pack('s')      # colourmaplength
    fout.write [0].pack('c')      # colourmapbits
    fout.write [0].pack('s')      # xstart
    fout.write [0].pack('s')      # ystart
    fout.write [w].pack('s')      # image_width
    fout.write [h].pack('s')      # image_height
    fout.write [bps].pack('c')    # image_bits_per_pixel
    fout.write [8].pack('c')      # descriptor
    fout.write image[0, w * h * (bps / 8)]
  end
end

def load_tga(name, as_grayscale: true)
  image = nil
  w = nil
  h = nil
  bps = nil
  File.open( name, 'rb' ) do |fin|
    fin.read(12)
    w = fin.read(2).unpack('s')[0]   # image_width 
    h = fin.read(2).unpack('s')[0]   # image_height
    bps = fin.read(1).unpack('c')[0] # image_bits_per_pixel
    fin.read(1)
    image = fin.read(w * h * (bps / 8))
  end
  if as_grayscale
    step = bps / 8
    gray_image = []
    h.times do |j|
      w.times do |i|
        pos = step*(i + j*w)
        r = image.byteslice(pos + 0).ord / 255.0
        g = image.byteslice(pos + 1).ord / 255.0
        b = image.byteslice(pos + 2).ord / 255.0
        y = (255.0 * (0.2126 * r + 0.7152 * g + 0.0722 * b)).to_i
        step.times do
          gray_image << y
        end
      end
    end
    return gray_image.pack('c*'), w, h, bps
  else
    return image, w, h, bps
  end
end
