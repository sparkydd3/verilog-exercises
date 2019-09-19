#include <stdio.h>
#include "system.h"
#include "gpio.h"

#define DVND_OFT 8
#define DVSR_OFT 0
#define QUO_OFT 8
#define RMD_OFT 0
#define READY_BIT_OFT 16
#define DONE_BIT_OFT 17
#define START_BIT_OFT 16

int main()
{
	alt_u32 a, b, q, r;
	alt_u8 di1_msg[4] = {sseg_conv_hex(13), 0xfb, 0xff, sseg_conv_hex(1)};

	sseg_disp_ptn(SSEG_BASE, di1_msg);
	printf("Division accelerator test #1: \n\n");

	while (1) {
		printf("Perform division a / b = q remainder r\n");
		printf("Enter a: ");
		scanf("%u", &a);
		printf("Enter b: ");
		scanf("%u", &b);

		/* send data to division accelerator */
		a &= 0xff;
		b &= 0xff;
		pio_write(DIV_OUT_BASE, (a << DVND_OFT) | (b << DVSR_OFT));

		/* wait until the division accelerator is ready */
		while (!(pio_read_lvl(DIV_IN_BASE) & (0x1 << READY_BIT_OFT)));

		/* generate a start pulse */
		printf("Start ...\n");
		pio_set_output(DIV_OUT_BASE, 0x1 << START_BIT_OFT);
		pio_clr_output(DIV_OUT_BASE, 0x1 << START_BIT_OFT);

		/* wait for completion */
		while (!(pio_read_edg(DIV_IN_BASE) & (0x1 << DONE_BIT_OFT)));

		/* clear done_tick register */
		pio_clear_edg(DIV_IN_BASE);

		/* retrieve results from division accelerator */

		q = (pio_read_lvl(DIV_IN_BASE) & (0xff << QUO_OFT)) >> QUO_OFT;
		r = (pio_read_lvl(DIV_IN_BASE) & (0xff << RMD_OFT)) >> RMD_OFT;
		printf("Hardware: %u / %u = %u remainder %u\n", a, b, q, r);

		/* compare results with built-in C operators */
		printf("Software: %u / %u = %u remainder %u\n\n\n", a, b, a / b, a % b);
	}
}
