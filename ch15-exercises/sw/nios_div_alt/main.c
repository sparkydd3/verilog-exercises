#include <stdio.h>
#include "system.h"
#include "gpio.h"

/* register offset definitions */
#define DVND_REG_OFT 0	// dividend register address offset
#define DVSR_REG_OFT 1	// divisor register address offset
#define QUOT_REG_OFT 2	// quotient register address offset
#define REMN_REG_OFT 3	// remainder register address offset
#define REDY_REG_OFT 4	// ready signal register address offset
#define DONE_REG_OFT 5	// done_tick register address offset

/* main program */
int main()
{
	alt_u32 a, b, q, r, ready, done;
	alt_u8 di1_msg[4] = {sseg_conv_hex(13), 0xfb, 0xff, sseg_conv_hex(2)};

	sseg_disp_ptn(SSEG_BASE, di1_msg);		// display "di 2"
	printf("Division accelerator test #2: \n\n");
	
	while (1) {
		printf("Perform division a / b = q remainder r\n");
		printf("Enter a: ");
		scanf("%d", &a);
		printf("Enter b: ");
		scanf("%d", &b);
		
		/* send dividend data to division accelerator */
		IOWR(DIV32_BASE, DVND_REG_OFT, a);

		/* wait until the division accelerator is ready */
		while (1) {
			ready = IORD(DIV32_BASE, REDY_REG_OFT) & 0x00000001;
			if (ready == 1) {
				printf("Start ...\n");
				IOWR(DIV32_BASE, DVSR_REG_OFT, b);
				break;
			}
		}
		
		/* wait for completion */
		while (1) {
			done = IORD(DIV32_BASE, DONE_REG_OFT) & 0x00000001;
			if (done == 1)
				break;
		}

		/* clear the done_tick register */
		IOWR(DIV32_BASE, DONE_REG_OFT, 1);

		/* retrieve results from the division accelerator */
		q = IORD(DIV32_BASE, QUOT_REG_OFT);
		r = IORD(DIV32_BASE, REMN_REG_OFT);
		printf("Hardware: %u / %u = %u remainder %u\n", a, b, q, r);

		/* compare results with built-in C operators */
		printf("Software: %u / %u = %u remainder %u\n\n\n", a, b, a / b, a % b);
	}
}
