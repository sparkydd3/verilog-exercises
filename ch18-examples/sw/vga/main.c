#include <stdio.h>
#include <stdlib.h>		// use rand()
#include <math.h>		// use exp(), sin(), cos()
#include <unistd.h>
#include <io.h>
#include "system.h"
#include "avalon_gpio.h"
#include "avalon_ps2.h"
#include "avalon_vga.h"

/* 12-row-by-20-column 8-bit-color mouse pointer bitmap array */
alt_u8 MOUSE_DATA[]={
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x6d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x92, 0x6d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x92, 0x92, 0x6d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x92, 0x92, 0x92, 0x6d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x92, 0x92, 0x92, 0x92, 0x6d, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x92, 0x92, 0x92, 0x92, 0x92, 0x6d, 0x00, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x92, 0x92, 0x92, 0x92, 0x92, 0x92, 0x6d, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x92, 0x92, 0x92, 0x92, 0x92, 0x92, 0x92, 0x6d, 0x00, 0x00, 
0x00, 0xff, 0x92, 0x92, 0x92, 0x92, 0x92, 0x92, 0x92, 0x92, 0x6d, 0x00, 
0x00, 0xff, 0x92, 0x92, 0x92, 0x92, 0x6d, 0x6d, 0x6d, 0x6d, 0x6d, 0x6d, 
0x00, 0xff, 0x92, 0x92, 0x6d, 0x92, 0x92, 0x6d, 0x00, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x92, 0x92, 0x00, 0x00, 0x92, 0x92, 0x6d, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x92, 0x00, 0x00, 0x00, 0x92, 0x92, 0x6d, 0x00, 0x00, 0x00, 
0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x6d, 0x92, 0x92, 0x6d, 0x00, 0x00, 
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6d, 0x92, 0x92, 0x6d, 0x00, 0x00, 
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6d, 0x92, 0x92, 0x6d, 0x00, 
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6d, 0x92, 0x92, 0x6d, 0x00, 
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6d, 0x6d, 0x00, 0x00, 
};

bmp_type MOUSE_BMP = {
	12,
	20,
	MOUSE_DATA
};

void vga_init_mouse_ptr(alt_u32 vga_base, alt_u32 ps2_base,
	int x, int y, bmp_type *mouse, bmp_type *below)
{
	vga_rd_bitmap(vga_base, x, y, below);
	vga_wr_bitmap(vga_base, x, y, mouse, 1);
}

int vga_move_mouse_ptr(alt_u32 vga_base, alt_u32 ps2_base,
	int xold, int yold, bmp_type *below, int *xnew, int *ynew,
	bmp_type *mouse, mouse_mv_type *mv)
{
	if (mouse_get_activity(ps2_base, mv) == 0)
		return 0;
	
	*xnew = xold + mv->xmov;
	if (*xnew > (639 - mouse->width))
		*xnew = 639 - mouse->width;
	if (*xnew < 0)
		*xnew = 0;

	*ynew = yold + mv->ymov;
	if (*ynew > (479 - mouse->width))
		*ynew = 479 - mouse->width;
	if (*ynew < 0)
		*ynew = 0;

	vga_move_bitmap(vga_base, xold, yold, below, *xnew, *ynew, mouse);
	return 1;
}

void plot_color_chart(alt_u32 vga_base)
{
	int x, y;
	alt_u8 i;
	alt_u8 color_r, color_g, color_b, color_rgb;

	for (x = 0; x < DISP_GRF_X_MAX; x++) {
		for (y = 0; y < DISP_GRF_Y_MAX; y++) {
			if (x < 240) {
				/* x < 240 */
				color_r = (alt_u8) (x / 30);
				if (y < 240){
					color_g = (alt_u8) (y / 30);
					color_b = 0x00;
				} 
				else {
					color_g = (alt_u8) ((y - 240) / 30);
					color_b = 0x02;
				}
			} 
			else if (x < 480) {
				/* 240 <= x < 480 */
				color_r = (alt_u8) ((x - 240) / 30);
				if (y < 240) {
					color_g = (alt_u8) (y / 30);
					color_b = 0x01;
				}
				else {
					color_g = (alt_u8) ((y - 240) / 30);
					color_b = 0x03;
				}
			}
			else {
				/* 480 <= x < 640 */
				i = (x - 480) /20;
				if (i & 0x04)
					color_r = 0x07;
				else
					color_r = 0x00;
				
				if (i & 0x02)
					color_g = 0x07;
				else
					color_g = 0x00;

				if (i & 0x01)
					color_b = 0x03;
				else
					color_b = 0x00;
			}

			color_rgb = (color_r << 5) + (color_g << 2) + color_b;
			vga_wr_pix(vga_base, x, y, color_rgb);
		}
	}
}

void plot_random_pix(alt_u32 vga_base)
{
	int i, x, y;
	alt_u8 color;

	for (i = 0; i < 300000; i++) {
		x = rand() % DISP_GRF_X_MAX;
		y = rand() % DISP_GRF_Y_MAX;
		color = rand() % 256;
		vga_wr_pix(vga_base, x, y, color);
	}
}

void plot_random_line(alt_u32 vga_base)
{
	int i, x, y;
	alt_u8 color;

	/* test for a white dot */
	vga_plot_line(vga_base, 10, 10, 10, 10, 0xff);

	/* a blue vertical line */
	vga_plot_line(vga_base, 600, 0, 600, DISP_GRF_Y_MAX - 1, 0x03);

	/* a green horizontal line */
	vga_plot_line(vga_base, 0, 400, DISP_GRF_X_MAX - 1, 400, 0x1c);

	/* plot 30 random lines from center */
	for (i = 0; i < 30; i++) {
		x = rand() % DISP_GRF_X_MAX;
		y = rand() % DISP_GRF_Y_MAX;
		color = rand() % 256;
		vga_plot_line(
			vga_base, 
			DISP_GRF_X_MAX / 2, DISP_GRF_Y_MAX / 2, 
			x, y, 
			color);
	}
}

void plot_function(alt_u32 vga_base) {
	const float XMAX = 10.0;
	const float YMAX = 10.0;
	float x, y, step;
	int i, j;

	step = XMAX / (float) (DISP_GRF_X_MAX);
	/* read line with small slope y = 0.1 * x */
	x = 0.0;
	for (i = 1; i < DISP_GRF_X_MAX; i++) {
		x = x + step;
		y = 0.1 * x;
		if (y < YMAX) {
			j = DISP_GRF_Y_MAX - (y / YMAX) * DISP_GRF_Y_MAX;
			vga_wr_pix(vga_base, i, j, 0xe0);
		}
	}

	/* blue line with 45 degree slope y = x */
	x = 0.0;
	for (i = 1; i < DISP_GRF_X_MAX; i++) {
		x = x + step;
		y = x;
		if (y < YMAX) {
			j = DISP_GRF_Y_MAX - (y / YMAX) * DISP_GRF_Y_MAX;
			vga_wr_pix(vga_base, i, j, 0x03);
		}
	}

	/* green steep line y = 10 * x */
	x = 0.0;
	for (i = 1; i < DISP_GRF_X_MAX; i++) {
		x = x + step;
		y = 10 * x;
		if (y < YMAX) {
			j = DISP_GRF_Y_MAX - (y / YMAX) * DISP_GRF_Y_MAX;
			vga_wr_pix(vga_base, i, j, 0x1c);
		}
	}

	/* y = 0.2 * x * x */
	x = 0.0;
	for (i = 1; i < DISP_GRF_X_MAX; i++) {
		x = x + step;
		y = 0.2 * x * x;
		if (y < YMAX) {
			j = DISP_GRF_Y_MAX - (y / YMAX) * DISP_GRF_Y_MAX;
			vga_wr_pix(vga_base, i, j, 0x1f);
		}
	}

	/* y = 5.0 + (5.0 * sin(4.0 * x) - 3.0*cos(4.0 * x)) * exp(-0.5 * x) */
	x = 0.0;
	for (i = 1; i < DISP_GRF_X_MAX; i++) {
		x = x + step;
		y = 5.0 + (5.0 * sin(4.0 * x) - 3.0*cos(4.0 * x)) * exp(-0.5 * x);
		if (y < YMAX) {
			j = DISP_GRF_Y_MAX - (y / YMAX) * DISP_GRF_Y_MAX;
			vga_wr_pix(vga_base, i, j, 0xff);
		}
	}
}

void plot_swap(alt_u32 vga_base)
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

	for (y = 9; y < 480; y++)
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

void plot_mouse(alt_u32 vga_base, alt_u32 ps2_base, alt_u32 btn_base)
{
	mouse_mv_type mv;
	int xold, yold, xnew, ynew, act;
	static alt_u8 bdata[20 * 12];
	bmp_type below = {12, 20, bdata};

	if (!mouse_init(ps2_base)) {
		printf("Mouse initialization failed.\n");
		return;
	}

	xold = 320;
	yold = 240;
	vga_init_mouse_ptr(vga_base, ps2_base, xold, yold, &MOUSE_BMP, &below);

	while (!btn_is_pressed(btn_base)) {
		act = vga_move_mouse_ptr(vga_base, ps2_base,
			xold, yold, &below, &xnew, &ynew, &MOUSE_BMP, &mv);
		if (act == 1) {
			if (mv.lbtn)
				printf("\ncurrent mouse location: %d %d", xnew, ynew);
			xold = xnew;
			yold = ynew;
		}
	}
	vga_wr_bitmap(vga_base, xold, yold, &below, 0);
	printf("\n");
}

void plot_text(alt_u32 vga_base) {
	int x, y;
	char buffer[50];
	char msg_box[] =
		"******************************\n"
		"*                            *\n" 
		"*         Hello World        *\n"
		"*                            *\n" 
		"******************************";
	
	vga_wr_bit_ch(vga_base, 0, 0, 'a', 0xff, 1);
	vga_wr_bit_ch(vga_base, DISP_GRF_X_MAX - 8, 0, 'b', 0xe0, 1);
	vga_wr_bit_ch(vga_base, 0, DISP_GRF_Y_MAX - 16, 'c', 0x1c, 1);
	vga_wr_bit_ch(vga_base, DISP_GRF_X_MAX - 8, DISP_GRF_Y_MAX - 16,
		'd', 0x03, 1);
	
	vga_wr_bit_str(vga_base, 30 * 8, 3 * 16, "Hello World", 0x1c, 1);
	vga_wr_bit_str(vga_base, 28 * 8, 5 * 16, "Hello World", 0x1c, 2);
	vga_wr_bit_str(vga_base, 23 * 8, 8 * 16, "Hello World", 0x1c, 3);

	vga_wr_bit_str(vga_base, 25 * 8, 16 * 16, msg_box, 0x1c, 1);

	vga_rd_xy(vga_base, &x, &y);
	sprintf(buffer, "current pixel (x, y): (%3d, %3d)", x, y);
	vga_wr_bit_str(vga_base, 24 * 8, 24 * 16, buffer, 0x03, 1);
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
