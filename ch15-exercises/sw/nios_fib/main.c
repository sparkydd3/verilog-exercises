#include <stdio.h>
#include "system.h"
#include "gpio.h"

/* register offset definitions */
#define INPT_REG_OFT 0				// input register address offset
#define INPT_REG_MSK 0x000000ff		// input register bit mask

#define STAS_REG_OFT 0				// status register address offset
#define REDY_BIT_OFT 0				// ready bit offset
#define DONE_BIT_OFT 1				// done bit offset

#define OTPL_REG_OFT 2				// output lower half register address offset
#define OTPH_REG_OFT 3				// output upper half register address offset

alt_u64 fib(alt_u8 fib_in)
{
	alt_u64 fib1 = 1;
	alt_u64 fib2 = 0;
	alt_u64 fib_tmp;

	while (fib_in-- > 0) {
		fib_tmp = fib1;
		fib1 = fib1 + fib2;
		fib2 = fib_tmp;
	}

	return fib2;
}

/* main program */
int main()
{
	alt_u32 fib_in;
	alt_u64 fib_out;
	alt_u8 di1_msg[4] = {sseg_conv_hex(13), 0xfb, 0xff, sseg_conv_hex(2)};

	sseg_disp_ptn(SSEG_BASE, di1_msg);		// display "di 2"
	printf("Fibonacci accelerator test #2: \n\n");
	
	while (1) {
		printf("Calculate fibonacci number a\n");
		printf("Enter a: ");
		scanf("%d", &fib_in);
		fib_in &= INPT_REG_MSK;
		
		/* wait until the division accelerator is ready */
		while (!(IORD(FIB_BASE, STAS_REG_OFT) & (0x1 << REDY_BIT_OFT)));

		/* send data to division accelerator */
		IOWR(FIB_BASE, INPT_REG_OFT, fib_in);
		
		/* wait for completion */
		while (!(IORD(FIB_BASE, STAS_REG_OFT) & (0x1 << DONE_BIT_OFT)));


		/* retrieve results from the division accelerator */
		fib_out = IORD(FIB_BASE, OTPH_REG_OFT) & 0xffffffff;
		fib_out = (fib_out << 32) | (IORD(FIB_BASE, OTPL_REG_OFT) & 0xffffffff);

		printf("Hardware: fib(%u) = %llu\n", fib_in, fib_out);

		/* compare results with built-in C operators */
		printf("Software: fib(%u) = %llu\n\n\n", fib_in, fib(fib_in));
	}
}
