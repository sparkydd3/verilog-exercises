#include <stdio.h>
#include "system.h"
#include "gpio.h"

#define SQ_EN_OFT 3
#define CNT_START_OFT 2
#define DIV_START_OFT 1
#define BCD_START_OFT 0

#define CNT_RDY_OFT 20
#define CNT_DONE_OFT 21

#define DIV_RDY_OFT 20
#define DIV_DONE_OFT 21

#define BCD_RDY_OFT 16
#define BCD_DONE_OFT 17

void sys_init()
{
	pio_write(CMD_BASE, 0);
	pio_clr_edg(CNT_BASE);
	pio_clr_edg(DIV_BASE);
	pio_clr_edg(BCD_BASE);
}

int main()
{
	printf("Frequency counter hardware test: \n\n");

	while (1) {
		sys_init();

		alt_u32 test_freq;
		printf("Generate test wave frequency (hz):\n");
		scanf("%u", &test_freq);

		pio_write(SQ_GEN_BASE, 50000000 / test_freq);
		pio_write(CMD_BASE, 0x1 << SQ_EN_OFT);

		/* wait until hardware is ready */
		printf("Press s to start measurement\n");
		while(getchar() != 's');
		printf("Start ...\n");

		/* wait for measurement ready */
		while (!(pio_read_lvl(CNT_BASE) & (0x1 << CNT_RDY_OFT)));

		/* start measurement */
		pio_set_output(CMD_BASE, 0x1 << CNT_START_OFT);
		pio_clr_output(CMD_BASE, 0x1 << CNT_START_OFT);

		/* wait for measurement completion */
		while (!(pio_read_edg(CNT_BASE) & (0x1 << CNT_DONE_OFT)));
		alt_u32 period = pio_read_lvl(CNT_BASE) & 0x000fffff;

		/* wait for division ready */
		while (!(pio_read_lvl(DIV_BASE) & (0x1 << DIV_RDY_OFT)));

		/* start division */
		pio_set_output(CMD_BASE, 0x1 << DIV_START_OFT);
		pio_clr_output(CMD_BASE, 0x1 << DIV_START_OFT);

		/* wait for division completion */
		while (!(pio_read_edg(DIV_BASE) & (0x1 << DIV_DONE_OFT)));
		alt_u32 freq = pio_read_lvl(DIV_BASE) & 0x000fffff;

		/* wait for bcd conversion ready */
		while (!(pio_read_lvl(BCD_BASE) & (0x1 << BCD_RDY_OFT)));

		/* start bcd conversion */
		pio_set_output(CMD_BASE, 0x1 << BCD_START_OFT);
		pio_clr_output(CMD_BASE, 0x1 << BCD_START_OFT);

		/* wait for bcd conversion completion */
		while (!(pio_read_edg(BCD_BASE) & (0x1 << BCD_DONE_OFT)));
		alt_u32 bcd_data = pio_read_lvl(BCD_BASE) & 0x0000ffff;

		/* display bcd on sseg */
		alt_8 ptn[4];
		ptn[0] = sseg_conv_hex((bcd_data & (0xf << 12)) >> 12);
		ptn[1] = sseg_conv_hex((bcd_data & (0xf << 8)) >> 8);
		ptn[2] = sseg_conv_hex((bcd_data & (0xf << 4)) >> 4);
		ptn[3] = sseg_conv_hex((bcd_data & (0xf << 0)) >> 0);
		sseg_disp_ptn(SSEG_BASE, ptn);

		printf("Period (us): %u\n", period);
		printf("Freq (hz): %u\n", freq);
	}
}
