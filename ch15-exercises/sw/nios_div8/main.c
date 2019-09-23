#include <stdio.h>
#include "system.h"
#include "gpio.h"

/* register offset definitions */
#define INPT_REG_OFT 0			// input register address offset
#define OTPT_REG_OFT 1			// output register address offset

#define DVND_BIT_OFT 0			// dividend byte offset
#define DVSR_BIT_OFT 8			// divisor byte offset
#define STRT_BIT_OFT 16			// start bit offset

#define DONE_BIT_OFT 8			// done bit offset
#define REDY_BIT_OFT 9			// ready bit offset
#define QUOT_BIT_OFT 16			// quotient bit offset
#define REMN_BIT_OFT 24			// remainder bit offset

/* main program */
int main()
{
	alt_u32 a, b, q, r, read_data;
	alt_u8 di1_msg[4] = {sseg_conv_hex(13), 0xfb, 0xff, sseg_conv_hex(2)};

	sseg_disp_ptn(SSEG_BASE, di1_msg);		// display "di 2"
	printf("Division accelerator test #2: \n\n");
	
	while (1) {
		printf("Perform division a / b = q remainder r\n");
		printf("Enter a: ");
		scanf("%d", &a);
		printf("Enter b: ");
		scanf("%d", &b);
		
		a &= 0xff;
		b &= 0xff;

		/* wait until the division accelerator is ready */
		while (!(IORD(DIV8_BASE, OTPT_REG_OFT) & (1 << REDY_BIT_OFT)));

		/* send data to division accelerator */
		IOWR(DIV8_BASE, INPT_REG_OFT,
			(a << DVND_BIT_OFT) |
			(b << DVSR_BIT_OFT) |
			(1 << STRT_BIT_OFT));
		
		/* wait for completion */
		while (!(IORD(DIV8_BASE, OTPT_REG_OFT) & (1 << DONE_BIT_OFT)));


		/* retrieve results from the division accelerator */
		read_data = IORD(DIV8_BASE, OTPT_REG_OFT);
		q = (read_data >> QUOT_BIT_OFT) & 0xff;
		r = (read_data >> REMN_BIT_OFT) & 0xff;

		/* clear the done_tick register */
		IOWR(DIV8_BASE, OTPT_REG_OFT, 1 << DONE_BIT_OFT);

		printf("Hardware: %u / %u = %u remainder %u\n", a, b, q, r);

		/* compare results with built-in C operators */
		printf("Software: %u / %u = %u remainder %u\n\n\n", a, b, a / b, a % b);
	}
}
