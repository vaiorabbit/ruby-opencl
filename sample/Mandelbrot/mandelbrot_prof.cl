// https://en.wikipedia.org/wiki/Mandelbrot_set#Escape_time_algorithm
__kernel void mandelbrot_div(__global uchar* image, int step, int div)
{
    int sw = div * get_global_size(0);
    int sh = div * get_global_size(1);

    int gx = get_global_id(0);
    int gy = get_global_id(1);
    int gw = div;
    int gh = div;
    int gox = gx * gw;
    int goy = gy * gh;


    for (int ly = 0; ly < gh; ++ly) {
        for (int lx = 0; lx < gw; ++lx) {
            int tx = lx + gox;
            int ty = ly + goy;
            float x0 = 3.5f * ((float)tx / sw) - 2.5f; // scaled x coordinate of pixel (scaled to lie in the Mandelbrot X scale (-2.5, 1))
            float y0 = 2.0f * ((float)ty / sh) - 1.0f; // scaled y coordinate of pixel (scaled to lie in the Mandelbrot Y scale (-1, 1))
            float x = 0.0;
            float y = 0.0;

            int iteration = 0;
            int max_iteration = 1000;
            while (x*x + y*y < 2*2 && iteration < max_iteration)
            {
                float xtemp = x*x - y*y + x0;
                y = 2*x*y + y0;
                x = xtemp;
                ++iteration;
            }

            uchar col = (iteration == max_iteration) ? 0 : (uchar)(255 * ((float)iteration / max_iteration));
            int pos = step * (tx + ty * sh);
            for (int i = 0; i < step; ++i)
            {
                image[pos + i] = col;
            }
        }
    }
}
