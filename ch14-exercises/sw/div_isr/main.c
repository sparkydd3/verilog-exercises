#include <stdio.h>
#include <sys/alt_irq.h>
#include "system.h"
#include "gpio.h"

typedef struct status_t {
	alt_u32 a;
	alt_u32 b;
	alt_u32 q;
	alt_u32 r;
	alt_u32 done;
} Status;

void sys_init(alt_u32 done_base)
{
	pio_int_mask(done_base, 0x1);	// enable interrupt for done tick
	pio_clear_edg(done_base);
}

void isr_done(void *context, alt_u32 id)
{
	Status *status = (Status *) context;
	status->done = 0x1;
	status->q = pio_read_lvl(QUO_BASE);
	status->r = pio_read_lvl(RMD_BASE);

	pio_clear_edg(DONE_BASE);
}

int main()
{
	Status s = {0, 0, 0, 0, 0};

	sys_init(DONE_BASE);
	alt_irq_register(DONE_IRQ, &s, &isr_done);

	/* display intro message */
	alt_u8 di1_msg[4] = {sseg_conv_hex(13), 0xfb, 0xff, sseg_conv_hex(1)};
	sseg_disp_ptn(SSEG_BASE, di1_msg);
	printf("Division accelerator test #1: \n\n");

	while (1) {
		/* get test data */
		printf("Perform division a / b = q remainder r\n");
		printf("Enter a: ");
		scanf("%d", &s.a);
		printf("Enter b: ");
		scanf("%d", &s.b);

		/* send data to division accelerator */
		pio_write(DVND_BASE, s.a);
		pio_write(DVSR_BASE, s.b);

		/* wait until the division accelerator is ready */
		while (!(pio_read_lvl(READY_BASE) & 0x1));

		/* generate a start pulse */
		printf("Start ...\n");
		s.done = 0;
		pio_write(START_BASE, 1);
		pio_write(START_BASE, 0);

		/* wait for completion */
		while (!s.done);
		s.done = 0;

		/* retrieve results from division accelerator */
		printf("Hardware: %u / %u = %u remainder %u\n", s.a, s.b, s.q, s.r);

		/* compare results with built-in C operators */
		printf("Software: %u / %u = %u remainder %u\n\n\n", s.a, s.b, s.a / s.b, s.a % s.b);
	}
}
