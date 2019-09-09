#include "uart_drv.h"

void jtaguart_wr_str(alt_u32 jtag_base, char *msg)
{
	alt_u32 data32;

	while (*msg) {
		data32 = (alt_u32) *msg;
		if (jtaguart_rd_wspace(jtag_base) != 0) {
			jtaguart_wr_ch(jtag_base, data32);
			msg++;
		}
	}
}
