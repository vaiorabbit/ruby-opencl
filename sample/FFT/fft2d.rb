# Pure-Ruby FFT
class FFT2D

  class Buffer
    attr_accessor :real, :imag, :width, :height

    def initialize(real_src, width, height)
      @real = real_src != nil ? real_src.dup : Array.new(width) { 0.0 }
      @imag = Array.new(@real.length) { 0.0 }
      @width = width
      @height = height
    end

    def get_elem(i, j)
      return @real[i*@width + j], @imag[i*@width + j]
    end

    def set_elem(i, j, vr, vi)
      @real[i*@width + j] = vr
      @imag[i*@width + j] = vi
    end

    def get_transposed()
      buf_dst = Buffer.new(nil, height, width)
      @height.times do |h|
        @width.times do |w|
          vr, vi = get_elem(w, h)
          buf_dst.set_elem(h, w, vr, vi)
        end
      end
      return buf_dst
    end

    def transpose()
      @height.times do |h|
        @width.times do |w|
          next if w <= h
          vr_src, vi_src = get_elem(w, h)
          vr_dst, vi_dst = get_elem(h, w)
          set_elem(w, h, vr_dst, vi_dst)
          set_elem(h, w, vr_src, vi_src)
        end
      end
      @width, @height = @height, @width
    end
  end

  attr_reader :window_length, :twiddle_factor

  def initialize(window_length) # must be power-of-2
    @window_length = window_length # Fixnum
    @twiddle_factor = nil # Float x 2
    @exponent = Math.log2(@window_length).to_i # Fixnum
    create_twiddle_factor()
  end

  def create_twiddle_factor
    @twiddle_factor = Array.new(window_length)
    (@window_length / 2).times do |i|
      @twiddle_factor[2*i    ] =  Math.cos(2 * i * Math::PI / @window_length)
      @twiddle_factor[2*i + 1] = -Math.sin(2 * i * Math::PI / @window_length) # Math.cos(theta + PI/2)
    end
  end

  def get_dft_twiddle_factor(i)
    pos = i % @window_length
    if pos < @window_length / 2
      return @twiddle_factor[2*pos], @twiddle_factor[2*pos+1]
    else
      pos -= @window_length / 2
      return -@twiddle_factor[2*pos], -@twiddle_factor[2*pos+1]
    end
  end

  def get_idft_twiddle_factor(i)
    pos = i % @window_length
    if pos < @window_length / 2
      return @twiddle_factor[2*pos], -@twiddle_factor[2*pos+1]
    else
      pos -= @window_length / 2
      return -@twiddle_factor[2*pos], @twiddle_factor[2*pos+1]
    end
  end

  def create_buffer(src, width, height)
    return Buffer.new(src, width, height)
  end

  def bit_reversal(x)
    bits = x.to_s(2)
    # print "\t#{'0' * (@exponent - bits.length) + bits}"
    bits = "0" * (32 - bits.length) + bits
    rev = bits.reverse.slice(0, @exponent)
    # print "\t#{rev}"
    return rev.to_i(2)
  end

  def permute(buf_src)
    buf_dst = Buffer.new(buf_src.real)
    buf_src.real.length.times do |i|
      rev = bit_reversal(i)
      real, imag = buf_src.real[rev], buf_src.imag[rev]
      buf_dst.real[i] = real
      buf_dst.imag[i] = imag
    end
    return buf_dst
  end

  def apply_dft_dumb(buf_src)
    buf_dst = Buffer.new(buf_src.real, buf_src.width, buf_src.height)
    buf_dst.height.times do |h|
      @window_length.times do |k|
        rk = 0.0
        ik = 0.0
        @window_length.times do |i|
          wr, wi = get_dft_twiddle_factor(k*i) # angle = 2 * k*i * Math::PI / @window_length, wr =  Math.cos(angle), wi = -Math.sin(angle)
          vr, vi = buf_src.get_elem(i, h)
          rk += vr * wr - vi * wi
          ik += vr * wi + vi * wr
        end
        buf_dst.set_elem(k, h, rk, ik)
      end
    end
    return buf_dst
  end

  def apply_idft_dumb(buf_src)
    n = 1.0 / @window_length
    buf_dst = Buffer.new(buf_src.real, buf_src.width, buf_src.height)
    buf_dst.height.times do |h|
      @window_length.times do |k|
        rk = 0.0
        ik = 0.0
        @window_length.times do |i|
          wr, wi = get_idft_twiddle_factor(k*i) # angle = 2 * k*i * Math::PI / @window_length, wr =  Math.cos(angle), wi =  Math.sin(angle)
          vr, vi = buf_src.get_elem(i, h)
          rk += vr * wr - vi * wi
          ik += vr * wi + vi * wr
        end
        # apply normalization (1/N)
        rk *= n
        ik *= n
        buf_dst.set_elem(k, h, rk, ik)
      end
    end
    return buf_dst
  end

end
