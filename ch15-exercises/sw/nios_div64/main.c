#include <stdio.h>
#include "system.h"
#include "gpio.h"

/* register offset definitions */
#define DVND_REG_OFT 0	// dividend register address offset
#define DVSR_REG_OFT 2	// divisor register address offset
#define STRT_REG_OFT 4	// start register address offset
#define QUOT_REG_OFT 6	// quotient register address offset
#define REMN_REG_OFT 8	// remainder register address offset
#define REDY_REG_OFT 10	// ready signal register address offset
#define DONE_REG_OFT 12	// done_tick register address offset

/* main program */
int main()
{
	alt_u64 a, b, q, r;
	alt_u8 di1_msg[4] = {sseg_conv_hex(13), 0xfb, 0xff, sseg_conv_hex(2)};

	sseg_disp_ptn(SSEG_BASE, di1_msg);		// display "di 2"
	printf("Division accelerator test #2: \n\n");
	
	while (1) {
		printf("Perform division a / b = q remainder r\n");
		printf("Enter a: ");
		scanf("%llu", &a);
		printf("Enter b: ");
		scanf("%llu", &b);
		
		/* send data to division accelerator */
		IOWR(DIV64_BASE, DVND_REG_OFT, a & 0xffffffff);
		IOWR(DIV64_BASE, DVND_REG_OFT + 1, (a >> 32) & 0xffffffff);
		IOWR(DIV64_BASE, DVSR_REG_OFT, b & 0xffffffff);
		IOWR(DIV64_BASE, DVSR_REG_OFT + 1, (b >> 32) & 0xffffffff);


		/* wait until the division accelerator is ready */
		while (!IORD(DIV64_BASE, REDY_REG_OFT));

		/* generate a 1-pulse */
		//printf("Start ...\n");
		IOWR(DIV64_BASE, STRT_REG_OFT, 1);
		
		/* wait for completion */
		while (!IORD(DIV64_BASE, DONE_REG_OFT));

		/* clear the done_tick register */
		IOWR(DIV64_BASE, DONE_REG_OFT, 1);

		/* retrieve results from the division accelerator */
		q = IORD(DIV64_BASE, QUOT_REG_OFT + 1) & 0xffffffff;
		q = (q << 32) | (IORD(DIV64_BASE, QUOT_REG_OFT) & 0xffffffff);
		r = IORD(DIV64_BASE, REMN_REG_OFT + 1) & 0xffffffff;
		r = (r << 32) | (IORD(DIV64_BASE, REMN_REG_OFT) & 0xffffffff);

		printf("Hardware: %llu / %llu = %llu remainder %llu\n", a, b, q, r);

		/* compare results with built-in C operators */
		printf("Software: %llu / %llu = %llu remainder %llu\n\n\n", a, b, a / b, a % b);
	}
}
