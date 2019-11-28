#include <stdlib.h>		// to use abs()
#include <io.h>
#include "avalon_vga.h"
#include "avalon_vga_font_table.h"

alt_u32 vga_calc_sram_addr(int x, int y)
{
	alt_u32 addr;
	addr = (alt_u32) (DISP_GRF_X_MAX * y + x);
	//addr = (alt_u32) ((y << 9) + (y << 7) + x);
	return addr;
}

alt_u8 vga_rd_pix(alt_u32 vga_base, int x, int y)
{
	alt_u32 offset;
	alt_u8 color;

	offset = vga_calc_sram_addr(x, y);
	color = (alt_u8) IORD(vga_base, offset);
	return color;
}

void vga_rd_xy(alt_u32 vga_base, int *x, int *y)
{
	alt_u32 data;
	const alt_u32 XY_ADDR = 0x00080000;

	data = IORD(vga_base, XY_ADDR);
	*x = 0x000003ff & data;
	*y = 0x000003ff & (data >> 10);
}

void vga_wr_pix(alt_u32 vga_base, int x, int y, alt_u8 color)
{
	alt_u32 offset;

	offset = vga_calc_sram_addr(x, y);
	IOWR(vga_base, offset, color);
}

void vga_plot_line(alt_u32 vga_base, int x1, int y1, int x2, int y2, alt_u8 color)
{
	int horiz, step, x, y;
	float slope;

	if ((y1 == y2) && (x1 == x2)) {
		vga_wr_pix(vga_base, x1, y1, color);
		return;
	}

	horiz = (abs(x2 - x1) > abs(y2 - y1)) ? 1 : 0;

	if (horiz) {
		slope = (float) (y2 - y1) / (float) (x2 - x1);
		step = ((x2 - x1) > 1) ? 1 : -1;
		for (x = x1; x != x2; x = x + step) {
			y = slope * (x - x1) + y1;
			vga_wr_pix(vga_base, x, y, color);
		}
	} 
	else {
		slope = (float) (x2 - x1) / (float) (y2 - y1);
		step = ((y2 - y1) > 1) ? 1 : -1;
		for (y = y1; y != y2; y = y + step) {
			x = slope * (y - y1) + x1;
			vga_wr_pix(vga_base, x, y, color);
		}
	}
}

void vga_clr_screen(alt_u32 vga_base, alt_u8 color)
{
	int x, y;
	
	for (x = 0; x < DISP_GRF_X_MAX; x++)
		for (y = 0; y < DISP_GRF_Y_MAX; y++)
			vga_wr_pix(vga_base, x, y, color);
}

void vga_wr_bitmap(alt_u32 vga_base, int x, int y, bmp_type *bmp, int tran)
{
	int i, j;
	alt_u8 color;

	for (j = 0; j < bmp->height; j++) {
		for (i = 0; i < bmp->width; i++) {
			color = bmp->pdata[(j * bmp->width) + i];
			if (tran == 0 || color != 0)
				vga_wr_pix(vga_base, i + x, j + y, color);
		}
	}
}

void vga_rd_bitmap(alt_u32 vga_base, int x, int y, bmp_type *bmp)
{
	int i, j;
	alt_u8 color;

	for (j = 0; j < bmp->height; j++) {
		for (i = 0; i < bmp->width; i++) {
			color = vga_rd_pix(vga_base, i + x, j + y);
			bmp->pdata[(j * bmp->width) + i] = color;
		}
	}
}

void vga_move_bitmap(alt_u32 vga_base,
	int xold, int yold, bmp_type *below,
	int xnew, int ynew, bmp_type *bmp)
{
	vga_wr_bitmap(vga_base, xold, yold, below, 0);
	vga_rd_bitmap(vga_base, xnew, ynew, below);
	vga_wr_bitmap(vga_base, xnew, ynew, bmp, 1);
}

void vga_wr_bit_ch(alt_u32 vga_base, int x, int y, char ch, int color, int zoom)
{
	int i, j, ch_line_addr, bit;
	alt_u8 row;

	for (j = 0; j < 16 * zoom; j++) {
		ch_line_addr = 16 * ch + j / zoom;
		row = FONT[ch_line_addr];

		for (i = 0; i < 8 * zoom; i++) {
			bit = row & (0x80 >> (i / zoom));
			if (bit != 0)
				vga_wr_pix(vga_base, x + i, y + j, color);
		}
	}
}

void vga_wr_bit_str(alt_u32 vga_base, int x, int y, char *s, int color, int zoom)
{
	int cx, cy;	// current x, y

	cx = x;
	cy = y;

	while (*s) {
		if (*s == '\n') {
			cx = x;
			cy = cy + 16 * zoom;
			s++;
		}
		else {
			vga_wr_bit_ch(vga_base, cx, cy, *s, color, zoom);
			s++;
			cx = cx + 8 * zoom;
		}
	}
}
