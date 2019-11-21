#include <stdio.h>
#include <stdlib.h>		// use srand()
#include <time.h>		// use time()
#include <math.h>		// use exp(), sin(), cos()
#include <unistd.h>
#include <io.h>
#include "system.h"
#include "avalon_gpio.h"
#include "avalon_ps2.h"
#include "avalon_vga.h"

/* 12-row-by-20-column 3-bit-color mouse pointer bitmap array */
alt_u8 MOUSE_DATA[]={
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x00, 
0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 
0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x0f, 0x00, 0x00, 0x00, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 0x00, 
0x00, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x00, 0x00, 
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x0f, 0x0f, 0x0f, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x0f, 0x00, 0x00,
};

bmp_type MOUSE_BMP = {
	12,
	20,
	MOUSE_DATA
};

void vga_init_mouse_ptr(alt_u32 vga_base, alt_u32 ps2_base,
	int x, int y, bmp_type *mouse, bmp_type *below1, bmp_type *below2)
{
	vga_rd_bitmap(vga_base, x, y, below1);
	vga_wr_bitmap(vga_base, x, y, mouse, 1);
	vga_refresh(vga_base);
	vga_rd_bitmap(vga_base, x, y, below2);
	vga_wr_bitmap(vga_base, x, y, mouse, 1);
}

int vga_move_mouse_ptr(alt_u32 vga_base, alt_u32 ps2_base,
	int xold, int yold, bmp_type *below1, bmp_type *below2,
	int *xnew, int *ynew, bmp_type *mouse,
	mouse_mv_type *mv)
{
	if (mouse_get_activity(ps2_base, mv) == 0)
		return 0;
	
	*xnew = xold + mv->xmov;
	if (*xnew > (639 - mouse->width))
		*xnew = 639 - mouse->width;
	if (*xnew < 0)
		*xnew = 0;

	*ynew = yold - mv->ymov;
	if (*ynew > (479 - mouse->height))
		*ynew = 479 - mouse->height;
	if (*ynew < 0)
		*ynew = 0;

	vga_move_bitmap(vga_base, xold, yold, below1, *xnew, *ynew, mouse);
	vga_refresh(vga_base);
	vga_move_bitmap(vga_base, xold, yold, below2, *xnew, *ynew, mouse);
	return 1;
}

static void _plot_color_chart(alt_u32 vga_base)
{
	int x, y;
	alt_u8 i;
	alt_u8 color_r, color_g, color_b, color_rgb;

	for (x = 0; x < DISP_GRF_X_MAX; x++) {
		for (y = 0; y < DISP_GRF_Y_MAX; y++) {
			if (x < 240) {
				/* x < 240 */
				color_r = (alt_u8) (x / 120);
				if (y < 240){
					color_g = (alt_u8) (y / 120);
					color_b = 0x00;
				} 
				else {
					color_g = (alt_u8) ((y - 240) / 120);
					color_b = 0x01;
				}
			} 
			else if (x < 480) {
				/* 240 <= x < 480 */
				color_r = (alt_u8) ((x - 240) / 120);
				if (y < 240) {
					color_g = (alt_u8) (y / 120);
					color_b = 0x00;
				}
				else {
					color_g = (alt_u8) ((y - 240) / 120);
					color_b = 0x01;
				}
			}
			else {
				/* 480 <= x < 640 */
				i = (x - 480) / 30;
				if (i & 0x04)
					color_r = 0x01;
				else
					color_r = 0x00;
				
				if (i & 0x02)
					color_g = 0x01;
				else
					color_g = 0x00;

				if (i & 0x01)
					color_b = 0x01;
				else
					color_b = 0x00;
			}

			color_rgb = (color_r << 2) + (color_g << 1) + color_b;
			vga_wr_pix(vga_base, x, y, color_rgb);
		}
	}
}

void plot_color_chart(alt_u32 vga_base)
{
	_plot_color_chart(vga_base);
	vga_refresh(vga_base);
	_plot_color_chart(vga_base);
}

static void _plot_random_pix(alt_u32 vga_base, time_t seed)
{
	int i, x, y;
	alt_u8 color;

	srand(seed);
	for (i = 0; i < 300000; i++) {
		x = rand() % DISP_GRF_X_MAX;
		y = rand() % DISP_GRF_Y_MAX;
		color = rand() % 8;
		vga_wr_pix(vga_base, x, y, color);
	}
}

void plot_random_pix(alt_u32 vga_base)
{
	time_t seed = time(0);
	_plot_random_pix(vga_base, seed);
	vga_refresh(vga_base);
	_plot_random_pix(vga_base, seed);
}

static void _plot_random_line(alt_u32 vga_base, time_t seed)
{
	int i, x, y;
	alt_u8 color;

	/* re-seed to ensure buffers have same random numbers */
	srand(seed);

	/* test for a white dot */
	vga_plot_line(vga_base, 10, 10, 10, 10, 0x0f);

	/* a blue vertical line */
	vga_plot_line(vga_base, 600, 0, 600, DISP_GRF_Y_MAX - 1, 0x01);

	/* a green horizontal line */
	vga_plot_line(vga_base, 0, 400, DISP_GRF_X_MAX - 1, 400, 0x02);

	/* plot 30 random lines from center */
	for (i = 0; i < 30; i++) {
		x = rand() % DISP_GRF_X_MAX;
		y = rand() % DISP_GRF_Y_MAX;
		color = rand() % 8;
		vga_plot_line(
			vga_base, 
			DISP_GRF_X_MAX / 2, DISP_GRF_Y_MAX / 2, 
			x, y, 
			color);
	}
}

void plot_random_line(alt_u32 vga_base)
{
	time_t seed = time(0);
	_plot_random_line(vga_base, seed);
	vga_refresh(vga_base);
	_plot_random_line(vga_base, seed);
}

static void _plot_function(alt_u32 vga_base) {
	const float XMAX = 10.0;
	const float YMAX = 10.0;
	float x, y, step;
	int i, j;

	step = XMAX / (float) (DISP_GRF_X_MAX);
	/* red line with small slope y = 0.1 * x */
	x = 0.0;
	for (i = 1; i < DISP_GRF_X_MAX; i++) {
		x = x + step;
		y = 0.1 * x;
		if (y < YMAX) {
			j = DISP_GRF_Y_MAX - (y / YMAX) * DISP_GRF_Y_MAX;
			vga_wr_pix(vga_base, i, j, 0x04);
		}
	}

	/* blue line with 45 degree slope y = x */
	x = 0.0;
	for (i = 1; i < DISP_GRF_X_MAX; i++) {
		x = x + step;
		y = x;
		if (y < YMAX) {
			j = DISP_GRF_Y_MAX - (y / YMAX) * DISP_GRF_Y_MAX;
			vga_wr_pix(vga_base, i, j, 0x01);
		}
	}

	/* green steep line y = 10 * x */
	x = 0.0;
	for (i = 1; i < DISP_GRF_X_MAX; i++) {
		x = x + step;
		y = 10 * x;
		if (y < YMAX) {
			j = DISP_GRF_Y_MAX - (y / YMAX) * DISP_GRF_Y_MAX;
			vga_wr_pix(vga_base, i, j, 0x02);
		}
	}

	/* y = 0.2 * x * x */
	x = 0.0;
	for (i = 1; i < DISP_GRF_X_MAX; i++) {
		x = x + step;
		y = 0.2 * x * x;
		if (y < YMAX) {
			j = DISP_GRF_Y_MAX - (y / YMAX) * DISP_GRF_Y_MAX;
			vga_wr_pix(vga_base, i, j, 0x03);
		}
	}

	/* y = 5.0 + (5.0 * sin(4.0 * x) - 3.0*cos(4.0 * x)) * exp(-0.5 * x) */
	x = 0.0;
	for (i = 1; i < DISP_GRF_X_MAX; i++) {
		x = x + step;
		y = 5.0 + (5.0 * sin(4.0 * x) - 3.0*cos(4.0 * x)) * exp(-0.5 * x);
		if (y < YMAX) {
			j = DISP_GRF_Y_MAX - (y / YMAX) * DISP_GRF_Y_MAX;
			vga_wr_pix(vga_base, i, j, 0x07);
		}
	}
}

void plot_function(alt_u32 vga_base)
{
	_plot_function(vga_base);
	vga_refresh(vga_base);
	_plot_function(vga_base);
}

static void _plot_swap(alt_u32 vga_base, time_t seed)
{
	alt_u8 buf[80 * 480];
	alt_u8 color;
	int x, y, x1, x2;

	x1 = rand() % 8;
	x2 = rand() % 8;
	if (x1 == x2)
		x2 = (x1 + 1) % 8;
	
	x1 = 80 * x1;
	x2 = 80 * x2;

	for (y = 0; y < 480; y++)
		for (x = 0; x < 80; x++)
			buf[80 * y + x] = vga_rd_pix(vga_base, x + x1, y);
	
	for (y = 0; y < 480; y++)
		for (x = 0; x < 80; x++) {
			color = vga_rd_pix(vga_base, x + x2, y);
			vga_wr_pix(vga_base, x + x1, y, color);
		}
	
	for (y = 0; y < 480; y++)
		for (x = 0; x < 80; x++)
			vga_wr_pix(vga_base, x + x2, y, buf[80 * y + x]);
}

plot_swap(alt_u32 vga_base)
{
	time_t seed = time(0);
	_plot_swap(vga_base, seed);
	vga_refresh(vga_base);
	_plot_swap(vga_base, seed);
}

void plot_mouse(alt_u32 vga_base, alt_u32 ps2_base, alt_u32 btn_base)
{
	mouse_mv_type mv;
	int xold, yold, xnew, ynew, act;
	static alt_u8 bdata1[20 * 12];
	static alt_u8 bdata2[20 * 12];
	bmp_type below1 = {12, 20, bdata1};
	bmp_type below2 = {12, 20, bdata2};

	bmp_type *below1_ptr = &below1;
	bmp_type *below2_ptr = &below2;
	bmp_type *below_swp;

	if (!mouse_init(ps2_base)) {
		printf("Mouse initialization failed.\n");
		return;
	}

	xold = 320;
	yold = 240;
	vga_init_mouse_ptr(vga_base, ps2_base, xold, yold,
		&MOUSE_BMP, below1_ptr, below2_ptr);

	while (!btn_is_pressed(btn_base)) {
		act = vga_move_mouse_ptr(vga_base, ps2_base,
			xold, yold, below1_ptr, below2_ptr,
			&xnew, &ynew, &MOUSE_BMP, &mv);

		below_swp = below1_ptr;
		below1_ptr = below2_ptr;
		below2_ptr = below_swp;

		if (act == 1) {
			if (mv.lbtn)
				printf("\ncurrent mouse location: %d %d", xnew, ynew);
			xold = xnew;
			yold = ynew;
		}
	}

	vga_wr_bitmap(vga_base, xold, yold, below1_ptr, 0);
	vga_refresh(vga_base);
	vga_wr_bitmap(vga_base, xold, yold, below2_ptr, 0);

	printf("\n");
}

static void _plot_text(alt_u32 vga_base) {
	int x, y;
	char buffer[50];
	char msg_box[] =
		"******************************\n"
		"*                            *\n" 
		"*         Hello World        *\n"
		"*                            *\n" 
		"******************************";
	
	vga_wr_bit_ch(vga_base, 0, 0, 'a', 0x07, 1);
	vga_wr_bit_ch(vga_base, DISP_GRF_X_MAX - 8, 0, 'b', 0x04, 1);
	vga_wr_bit_ch(vga_base, 0, DISP_GRF_Y_MAX - 16, 'c', 0x02, 1);
	vga_wr_bit_ch(vga_base, DISP_GRF_X_MAX - 8, DISP_GRF_Y_MAX - 16,
		'd', 0x01, 1);
	
	vga_wr_bit_str(vga_base, 30 * 8, 3 * 16, "Hello World", 0x02, 1);
	vga_wr_bit_str(vga_base, 28 * 8, 5 * 16, "Hello World", 0x02, 2);
	vga_wr_bit_str(vga_base, 23 * 8, 8 * 16, "Hello World", 0x02, 3);

	vga_wr_bit_str(vga_base, 25 * 8, 16 * 16, msg_box, 0x02, 1);

	vga_rd_xy(vga_base, &x, &y);
	sprintf(buffer, "current pixel (x, y): (%3d, %3d)", x, y);
	vga_wr_bit_str(vga_base, 24 * 8, 24 * 16, buffer, 0x01, 1);
}

void plot_text(vga_base)
{
	_plot_text(vga_base);
	vga_refresh(vga_base);
	_plot_text(vga_base);
}

int main()
{
	int sw, btn;

	alt_u8 disp_msg[4] = {sseg_conv_hex(13), sseg_conv_hex(1),
		sseg_conv_hex(5), 0x0c};
	sseg_disp_ptn(SSEG_BASE, disp_msg);	// show dISP for display

	//vga_clr_screen(VRAM_BASE, 0);
	printf("VGA videoc ontroller test: \n\n");
	btn_clear(BTN_BASE);

	while (1) {
		while (!btn_is_pressed(BTN_BASE));
		btn = btn_read(BTN_BASE);
		if (btn & 0x02) {
			sw = pio_read(SWITCH_BASE);
			printf("key/sw: %d/%d\n", btn, sw);
		}
		btn_clear(BTN_BASE);

		switch(sw) {
			case 0:
				vga_clr_screen(VRAM_BASE, 0);
				break;
			case 1:
				plot_color_chart(VRAM_BASE);
				break;
			case 2:
				plot_random_pix(VRAM_BASE);
				break;
			case 3:
				plot_random_line(VRAM_BASE);
				break;
			case 4:
				plot_function(VRAM_BASE);
				break;
			case 5:
				plot_swap(VRAM_BASE);
				break;
			case 6:
				plot_mouse(VRAM_BASE, PS2_BASE, BTN_BASE);
				break;
			case 7:
				plot_text(VRAM_BASE);
				break;
		}
	}
}
