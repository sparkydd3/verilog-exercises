#include <stdio.h>
#include "system.h"
#include "gpio.h"

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

int main()
{
	alt_u32 fib_in;
	alt_u64 fib_out;

	printf("Fibonacci hardware test: \n\n");
	while (1) {
		printf("Perform fib(i) = o\n");
		printf("Enter i: ");
		scanf("%u", &fib_in);
		fib_in &= 0xff;

		/* send data to hardware accelerator */
		pio_write(FIB_IN_BASE, fib_in);

		/* wait until the hardware accelerator is ready */
		while (!(pio_read_lvl(READY_BASE) & 0x1));

		/* generate a start pulse */
		printf("Start ...\n");
		pio_write(START_BASE, 1);
		pio_write(START_BASE, 0);

		/* wait for completion */
		while (!(pio_read_edg(DONE_BASE) & 0x1));

		/* clear done_tick register */
		pio_clr_edg(DONE_BASE);

		/* retrieve results from hardware accelerator */
		fib_out = pio_read_lvl(FIB_OUT_U_BASE) & 0xffffffff;
		fib_out = (fib_out << 32) | (pio_read_lvl(FIB_OUT_L_BASE) & 0xffffffff);
		printf("Hardware: fib(%u) = %llu\n", fib_in, fib_out);

		/* compare results with C software */
		printf("Software: fib(%u) = %llu\n", fib_in, fib(fib_in));
	}
}
