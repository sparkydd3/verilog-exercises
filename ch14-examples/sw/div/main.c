#include <stdio.h>
#include "system.h"
#include "gpio.h"

int main()
{
	alt_u32 a, b, q, r, ready, done;
	alt_u8 di1_msg[4] = {sseg_conv_hex(13), 0xfb, 0xff, sseg_conv_hex(1)};

	sseg_disp_ptn(SSEG_BASE, di1_msg);
	printf("Division accelerator test #1: \n\n");

	while (1) {
		printf("Perform division a / b = q remainder r\n");
		printf("Enter a: ");
		scanf("%d", &a);
		printf("Enter b: ");
		scanf("%d", &b);

		/* send data to division accelerator */
		pio_write(DVND_BASE, a);
		pio_write(DVSR_BASE, b);

		/* wait until the division accelerator is ready */
		while (1) {
			ready = pio_read(READY_BASE) & 0x00000001;
			if (ready == 1)
				break;
		}

		/* generate a start pulse */
		printf("Start ...\n");
		pio_write(START_BASE, 1);
		pio_write(START_BASE, 0);

		/* wait for completion */
		while (1) {
			done = IORD(DONE_BASE, PIO_EDGE_REG_OFT) & 0x00000001;
			if (done == 1)
				break;
		}

		/* clear done_tick register */
		pio_write(DONE_BASE, 1);

		/* retrieve results from division accelerator */
		q = pio_read(QUO_BASE);
		r = pio_read(RMD_BASE);
		printf("Hardware: %u / %u = %u remainder %u\n", a, b, q, r);

		/* compare results with built-in C operators */
		printf("Software: %u / %u = %u remainder %u\n\n\n", a, b, a / b, a % b);
	}
}
