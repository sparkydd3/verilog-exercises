#include <alt_types.h>

typedef struct tag_bmp
{
	int width;
	int height;
	alt_u8 *pdata;	// pointer to pixel array
} bmp_type;

#define DISP_GRF_X_MAX 640
#define DISP_GRF_Y_MAX 480

/* Video memory access */
alt_u32 vga_calc_sram_addr(int x, int y);
alt_u8 vga_rd_pix(alt_u32 vga_base, int x, int y);
void vga_rd_xy(alt_u32 vga_base, int *x, int *y);
void vga_wr_pix(alt_u32 vga_base, int x, int y, alt_u8 color);
void vga_refresh(alt_u32 vga_base);

/* Plotting and clear */
void vga_plot_line(alt_u32 vga_base, 
	int x1, int y1,
	int x2, int y2,
	alt_u8 color);
void vga_clr_screen(alt_u32 vga_base, alt_u8 color);

/* Bitmap processing */
void vga_wr_bitmap(alt_u32 vga_base, int x, int y,
	bmp_type *bmp, int tran);
void vga_rd_bitmap(alt_u32 vga_base, int x, int y, bmp_type *bmp);
void vga_move_bitmap(alt_u32 vga_base,
	int xold, int yold, bmp_type *below,
	int xnew, int ynew, bmp_type *bmp);

/* Bit-mapped text */
void vga_wr_bit_ch(alt_u32 vga_base, int x, int y,
	char ch, int color, int zoom);
void vga_wr_bit_str(alt_u32 vga_base, int x, int y,
	char *s, int color, int zoom);
