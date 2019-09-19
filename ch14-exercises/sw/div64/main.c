#include <stdio.h>
#include "system.h"
#include "gpio.h"

int main()
{
	alt_u64 a, b, q, r;
	alt_u8 di1_msg[4] = {sseg_conv_hex(13), 0xfb, 0xff, sseg_conv_hex(1)};

	sseg_disp_ptn(SSEG_BASE, di1_msg);
	printf("Division accelerator test #1: \n\n");

	while (1) {
		printf("Perform division a / b = q remainder r\n");
		printf("Enter a: ");
		scanf("%llu", &a);
		printf("Enter b: ");
		scanf("%llu", &b);

		/* send data to division accelerator */
		pio_write(DVND_U_BASE, (a >> 32) & 0xffffffff);
		pio_write(DVND_L_BASE, a & 0xffffffff);
		pio_write(DVSR_U_BASE, (b >> 32) & 0xffffffff);
		pio_write(DVSR_L_BASE, b & 0xffffffff);

		/* wait until the division accelerator is ready */
		while (!(pio_read_lvl(READY_BASE) & 0x1));

		/* generate a start pulse */
		printf("Start ...\n");
		pio_write(START_BASE, 1);
		pio_write(START_BASE, 0);

		/* wait for completion */
		while (!(pio_read_edg(DONE_BASE) & 0x1));

		/* clear done_tick register */
		pio_write(DONE_BASE, 1);

		/* retrieve results from division accelerator */
		q = pio_read_lvl(QUO_U_BASE) & 0xffffffff;
		q = (q << 32) | (pio_read_lvl(QUO_L_BASE) & 0xffffffff);
		r = pio_read_lvl(RMD_U_BASE);
		r = (r << 32) | (pio_read_lvl(RMD_L_BASE) & 0xffffffff);
		printf("Hardware: %llu / %llu = %llu remainder %llu\n", a, b, q, r);

		/* compare results with built-in C operators */
		printf("Software: %llu / %llu = %llu remainder %llu\n\n\n", a, b, a / b, a % b);
	}
}
