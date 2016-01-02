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
      return @real[i*@height + j], @imag[i*@height + j]
    end

    def set_elem(i, j, vr, vi)
      @real[i*@height + j] = vr
      @imag[i*@height + j] = vi
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

    def bit_reversal(x, exponent)
      bits = x.to_s(2)
      # print "\t#{'0' * (@exponent - bits.length) + bits}"
      bits = "0" * (32 - bits.length) + bits
      rev = bits.reverse.slice(0, exponent)
      # print "\t#{rev}"
      return rev.to_i(2)
    end
    private :bit_reversal

    def get_permuted(exponent)
      buf_dst = Buffer.new(nil, @width, @height)
      @height.times do |h|
        @width.times do |w|
          rev = bit_reversal(w, exponent)
          vr, vi = get_elem(rev, h)
          buf_dst.set_elem(w, h, vr, vi)
        end
      end
      return buf_dst
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

  def apply_fft(buf_src)
    buf_tmp = buf_src.get_permuted(@exponent)
    buf_dst = Buffer.new(nil, buf_src.width, buf_src.height)
    buf_dst.height.times do |h|
      (1..@exponent).each do |e|                  # 1, 2, 3 (@exponent==3)
        muladd_dist = 2 ** (e-1)                  # 1, 2, 4 (@exponent==3)
        muladd_group_count = 2 ** (@exponent - e) # 4, 2, 1 (@exponent==3)
        muladd_group_member_count = 2 ** e        # 2, 4, 8 (@exponent==3)
        butterfly_count = muladd_group_member_count / 2 # Number of butterflys in a group
        muladd_group_count.times do |g|
          base = muladd_group_member_count * g
          butterfly_count.times do |b|
            wing0 = base + b
            wing1 = wing0 + muladd_dist
            prev_val0_r, prev_val0_i = buf_tmp.get_elem(wing0, h)
            prev_val1_r, prev_val1_i = buf_tmp.get_elem(wing1, h)
            wr, wi = get_dft_twiddle_factor(k*i)
#            next_val0 = prev_val0 + 
          end
        end
=begin
        @window_length.times do |k|
          rk = 0.0
          ik = 0.0
          @window_length.times do |i|
            wr, wi = get_dft_twiddle_factor(k*i)
            vr, vi = buf_src.get_elem(i, h)
            rk += vr * wr - vi * wi
            ik += vr * wi + vi * wr
          end
          buf_dst.set_elem(k, h, rk, ik)
        end
=end
      end
    end
    return buf_dst
  end

  def apply_ifft(buf_src)
  end
end
