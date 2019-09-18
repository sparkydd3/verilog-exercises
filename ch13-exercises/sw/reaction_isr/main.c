#include <stdio.h>
#include <sys/alt_irq.h>
#include "system.h"
#include "gpio.h"
#include "timer_drv.h"
#include "uart_drv.h"

typedef struct status_t {
	void (*state_func) (struct status_t *status);
	unsigned int sys_ms;
	char c;
} Status;

void idle_state(Status *status)
{
	if (status->cmd == 's') {
		sseg_clear(SSEG_BASE);
		status->sys_ms = 2000 + rand() % 13000;
		status->state_func = &wait_state;
	}

	status->cmd = 0;
}

void wait_state(Status *status)
{
	if (status->cmd == 0) {
		status->sys_ms--;
	}
	else if (status->cmd == 'c') {
		sseg_disp_greet(SSEG_BASE);
		status->sys_ms = 0;
		status->state_func = &idle_state;
	}
	else if (statue->cmd == 'p') {
		status->sys_ms = 9999;
		sseg_disp_time(SSEG_BASE, status->sys_ms);
		status->state_func = &result_state;
	}
	else if (status->sys_ms == 0)
	{
		sseg_disp_time(SSEG_BASE, status->sys_ms);
		status->state_func = &react_state;
	}

	status->cmd = 0;
}

void react_state(Status *status)
{
	if (status->cmd == 0) {
		status->sys_ms++;
		sseg_disp_time(SSEG_BASE, time);
	}
	else if (status->cmd == 'c') {
		sseg_disp_greet(SSEG_BASE);
		status->sys_ms = 0;
		status->state_func = &idle_state;
	}
	else if (statue->cmd == 'p') {
		sseg_disp_time(SSEG_BASE, status->sys_ms);
		status->state_func = &result_state;
	}

	status->cmd = 0;
}

void result_state(Status *status)
{
	if (status->cmd == 's') {
		sseg_clear(SSEG_BASE);
		status->sys_ms = 2000 + rand() % 13000;
		status->state_func = &wait_state;
	}
	else if (status->cmd == 'c') {
		sseg_disp_greet(SSEG_BASE);
		status->sys_ms = 0;
		status->state_func = &idle_state;
	}

	status->cmd = 0;
}

void sseg_clear(alt_u32 sseg_base)
{
	alt_u8 msg[4] = {0xff, 0xff, 0xff, 0xff};
	sseg_disp_ptn(sseg_base, msg);
}

void sseg_disp_greet(alt_u32 sseg_base)
{
	alt_u8 msg[4] = {0xff, 0xff, 0x09, 0xf9};
	sseg_disp_ptn(sseg_base, msg);
}

void sseg_disp_time(alt_u32 sseg_base, unsigned int time)
{
	alt_u8 msg[4];
	msg[0] = sseg_conv_hex((time / 1000) % 10);
	msg[1] = sseg_conv_hex((time / 100) % 10);
	msg[2] = sseg_conv_hex((time / 10) % 10);
	msg[3] = sseg_conv_hex(time % 10);
	sseg_disp_ptn(sseg_base, msg);
}

void sys_init(alt_u32 jtag_base, alt_u32 timer_base)
{
	jtaguart_rd_int(jtag_base, 0x1);	// enable jtag read interrupt
	timer_wr_prd(timer_base, 50000);	// set 1 ms timeout period
}

alt_u32 isr_timer_base;
void ms_timer_isr(void *context, alt_u32 id)
{
	Status *status = (Status *) context;
	status->state_func(status);
	timer_clear_tick(isr_timer_base);
}

alt_u32 isr_jtag_base;
void jtag_isr(void *context, alt_u32 id)
{
	Status *status = (Status *) context;
	status->cmd = jtaguart_rd_ch(isr_jtag_base);
	status->state_func(status);
}

int main()
{
	Status status = {&idle_state, 0, 0};
	sys_init(JTAG_UART_BASE, USER_TIMER_BASE);

	isr_timer_base = USER_TIMER_BASE;
	alt_irq_register(USER_TIMER_IRQ, (void *) &status, ms_timer_isr);

	isr_jtag_base = JTAG_UART_BASE;
	alt_irq_register(JTAG_UART_IRQ, (void *) &status, jtag_isr);

	while (1);
}
