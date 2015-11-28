// https://en.wikipedia.org/wiki/Mandelbrot_set#Escape_time_algorithm
__kernel void mandelbrot_per4_loop(__global uint* image)
{
    const int workrect_size = 4;

    int tx = get_global_id(0);
    int ty = get_global_id(1);
    int sx = get_global_size(0) * workrect_size;
    int sy = get_global_size(1);

    float y0 = 2.0f * ((float)ty / sy) - 1.0f; // scaled y coordinate of pixel (scaled to lie in the Mandelbrot Y scale (-1, 1))

    uint color[4] = {0, 0, 0, 0};

    const int max_iteration = 1000;
    const float map_to_color = 255.0f / max_iteration;
    for (int i = 0; i < workrect_size; ++i) {
        int iteration = 0;
        int tx_i = workrect_size * tx + i;
        float x0 = 3.5f * ((float)tx_i/ sx) - 2.5f; // scaled x coordinate of pixel (scaled to lie in the Mandelbrot X scale (-2.5, 1))
        float x = 0.0f;
        float y = 0.0f;
        while (x*x + y*y < 2*2 && iteration < max_iteration)
        {
            float xtemp = x*x - y*y + x0;
            y = 2*x*y + y0;
            x = xtemp;
            ++iteration;
        }

        color[i] = (iteration == max_iteration) ? 0 : (uchar)(map_to_color * iteration);
    }

    for (int i = 0; i < workrect_size; ++i ) {
        int tx_i = workrect_size * tx + i;
        int pos = (tx_i + ty * sy);
        image[pos] = color[i] | (color[i] << 8) | (color[i] << 16) | (color[i] << 24);
    }
}

////////////////////////////////////////////////////////////////////////////////

__kernel void mandelbrot_per4_vec(__global uint* image) // just for practice.
{
    const int workrect_size = 4;

    int tx = get_global_id(0);
    int ty = get_global_id(1);
    int sx = get_global_size(0) * workrect_size;
    int sy = get_global_size(1);

    // scaled y coordinate of pixel (scaled to lie in the Mandelbrot Y scale (-1, 1))
    float4 y0 = 2.0f * ((float)ty / sy) - 1.0f;

    int4 color;
    const int4 max_iteration = (1000, 1000, 1000, 1000);
    const float map_to_color = 255.0f / 1000;
    {
        int4 iteration = (0, 0, 0, 0);
        float4 tx_i = workrect_size * tx + (float4)(0, 1, 2, 3);

        // scaled x coordinate of pixel (scaled to lie in the Mandelbrot X scale (-2.5, 1))
        float4 x0 = tx_i / (float4)(sx, sx, sx, sx);
        x0 *= 3.5f;
        x0 -= 2.5f;

        float4 x = (0.0f, 0.0f, 0.0f, 0.0f);
        float4 y = (0.0f, 0.0f, 0.0f, 0.0f);

        bool cont = 1;
        while (cont)
        {
            float4 xx = x*x;
            float4 yy = y*y;
            int4 converge = xx + yy < 2*2;
            int4 iterating = iteration < max_iteration;
            int4 recompute = converge && iterating;
            cont = any(recompute);
            if (cont) {
                float4 xtemp = xx - yy + x0;
                y = 2*x*y + y0;
                x = xtemp;
                iteration += (recompute & (int4)(1, 1, 1, 1));
            }
        }

        color = iteration;
        color = select(color, (int4)(0, 0, 0, 0), (iteration == max_iteration));
        float4 fcolor = map_to_color * convert_float4(color);
        color = convert_int4(fcolor);
    }

    __global uint* imgdst = image + workrect_size * tx + ty * sy;
    imgdst[0] = color.s0 | (color.s0 << 8) | (color.s0 << 16) | (color.s0 << 24);
    imgdst[1] = color.s1 | (color.s1 << 8) | (color.s1 << 16) | (color.s1 << 24);
    imgdst[2] = color.s2 | (color.s2 << 8) | (color.s2 << 16) | (color.s2 << 24);
    imgdst[3] = color.s3 | (color.s3 << 8) | (color.s3 << 16) | (color.s3 << 24);
}
