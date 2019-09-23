#include <stdio.h>
#include <sys/alt_irq.h>
#include "system.h"
#include "gpio.h"

/* register offset definitions */
#define DVND_REG_OFT 0	// dividend register address offset
#define DVSR_REG_OFT 1	// divisor register address offset
#define STRT_REG_OFT 2	// start register address offset
#define QUOT_REG_OFT 3	// quotient register address offset
#define REMN_REG_OFT 4	// remainder register address offset
#define REDY_REG_OFT 5	// ready signal register address offset
#define DONE_REG_OFT 6	// done_tick register address offset

typedef struct context_t
{
	alt_u32 a;
	alt_u32 b;
	alt_u32 q;
	alt_u32 r;
	alt_u32 done;
} Context;

void isr_div(void *context, alt_u32 id)
{
	Context *c = (Context *) context;

	/* clear the done_tick register */
	IOWR(DIV32_BASE, DONE_REG_OFT, 1);
	
	c->q = IORD(DIV32_BASE, QUOT_REG_OFT);
	c->r = IORD(DIV32_BASE, REMN_REG_OFT);
	c->done = 1;
}

/* main program */
int main()
{
	Context c = {0, 0, 0, 0, 0};
	alt_u8 di1_msg[4] = {sseg_conv_hex(13), 0xfb, 0xff, sseg_conv_hex(2)};

	sseg_disp_ptn(SSEG_BASE, di1_msg);		// display "di 2"
	printf("Division accelerator test #2: \n\n");

	alt_irq_register(DIV32_IRQ, &c, &isr_div);

	while (1) {
		printf("Perform division a / b = q remainder r\n");
		printf("Enter a: ");
		scanf("%d", (int *) &c.a);
		printf("Enter b: ");
		scanf("%d", (int *) &c.b);
		
		/* send data to division accelerator */
		IOWR(DIV32_BASE, DVND_REG_OFT, c.a);
		IOWR(DIV32_BASE, DVSR_REG_OFT, c.b);

		/* wait until the division accelerator is ready */
		while (!(IORD(DIV32_BASE, REDY_REG_OFT) & 0x1));

		/* generate a 1-pulse */
		printf("Start ...\n");
		IOWR(DIV32_BASE, STRT_REG_OFT, 1);
		
		/* wait for completion */
		while (!c.done);
		c.done = 0;

		/* display results of hardware division */
		printf("Hardware: %u / %u = %u remainder %u\n",
			(unsigned int) c.a,
			(unsigned int) c.b,
			(unsigned int) c.q,
			(unsigned int) c.r);

		/* compare results with built-in C operators */
		printf("Software: %u / %u = %u remainder %u\n\n\n",
			(unsigned int) c.a,
			(unsigned int) c.b,
			(unsigned int) (c.a / c.b),
			(unsigned int) (c.a % c.b));
	}
}
