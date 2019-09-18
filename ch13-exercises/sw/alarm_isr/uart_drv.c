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

#define RVALID_BIT_OFT 15

unsigned int jtaguart_rd_str(alt_u32 jtag_base, char *buf, unsigned int buf_len)
{
	unsigned int i;
	alt_u32 jtag_data;

	for (i = 0; i < buf_len - 1; i++) {
		jtag_data = IORD(jtag_base, JUART_DATA_REG_OFT);

		if(!(jtag_data & (0x1 << RVALID_BIT_OFT))) break;
		buf[i] = jtag_data & 0xff;
	}

	buf[i] = '\0';
	return i;
}
