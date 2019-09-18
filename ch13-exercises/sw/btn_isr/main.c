#include <stdio.h>
#include <sys/alt_irq.h>
#include "system.h"
#include "gpio.h"
#include "timer_drv.h"

typedef struct status_t {
	int pause;
	int prd;
	int sys_ms_time;
} Status;

alt_u32 isr_timer_base;
alt_u32 isr_btn_base;
alt_u32 isr_switch_base;

void sys_init(alt_u32 btn_base, alt_u32 timer_base)
{
	btn_int_en(btn_base);
	btn_clear(btn_base);
	timer_wr_prd(timer_base, 50000);	// set 1 ms timeout period
}

void jtag_uart_disp_msg(const Status status)
{
	static int prd = 0;
	
	if (prd == status.prd) return;

	printf("Interval: %03u ms\n", status.prd);
	prd = status.prd;
}

void sseg_disp_msg(alt_u32 sseg_base, const Status status)
{
	alt_u8 msg[4];
	msg[3] = sseg_conv_hex(status.prd % 10);
	msg[2] = sseg_conv_hex((status.prd / 10) % 10);
	msg[1] = sseg_conv_hex((status.prd / 100) % 10);
	msg[0] = (status.pause) ? 0x0c : 0xff;		// P if paused

	sseg_disp_ptn(sseg_base, msg);
}

void led_flash(alt_u32 led_base, const Status status)
{
	static alt_u8 led_pattern = 0x01;
	static int last = 0;

	if (status.pause) return;

	if ((status.sys_ms_time - last) < status.prd) return;

	last = status.sys_ms_time;
	led_pattern ^= 0x03;
	pio_write(led_base, led_pattern);
}

static void ms_clock_isr(void *context, alt_u32 id)
{
	Status *status = (Status *) context;
	status->sys_ms_time++;
	timer_clear_tick(isr_timer_base);
}

static void btn_isr(void *context, alt_u32 id)
{
	Status *status = (Status *) context;
	alt_u8 btn_data;

	btn_data = (alt_u8) btn_read(isr_btn_base) & 0xf;

	if (btn_data & (0x1 << 0))
		status->pause = status->pause ^ 1;
	if (btn_data & (0x1 << 1))
		status->prd = pio_read(isr_switch_base) & 0x3ff;

	btn_clear(isr_btn_base);
}

int main()
{
	Status status = {0, 100, 0};		// not paused; 100 ms interval; 0 ms time

	sys_init(BTN_BASE, USER_TIMER_BASE);

	isr_timer_base = USER_TIMER_BASE;
	isr_btn_base = BTN_BASE;
	isr_switch_base = SWITCH_BASE;

	alt_irq_register(USER_TIMER_IRQ, (void *) &status, ms_clock_isr);
	alt_irq_register(BTN_IRQ, (void *) &status, btn_isr);

	while (1) {
		jtag_uart_disp_msg(status);
		sseg_disp_msg(SSEG_BASE, status);
		led_flash(LEDG_BASE, status);
	}
}
