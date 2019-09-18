#include <stdio.h>
#include <sys/alt_irq.h>
#include "system.h"
#include "gpio.h"
#include "timer_drv.h"
#include "uart_drv.h"

typedef struct status_t {
	int pause;
	int prd;
} Status;

alt_u32 isr_timer_base;
alt_u32 isr_btn_base;
alt_u32 isr_switch_base;
alt_u32 isr_sseg_base;
alt_u32 isr_jtag_base;
alt_u32 isr_ledg_base;

void sys_init(alt_u32 btn_base, alt_u32 timer_base)
{
	btn_int_en(btn_base);
	btn_clear(btn_base);
	timer_wr_prd(timer_base, 50000);	// set 1 ms timeout period
}

void jtag_uart_disp_msg(alt_u32 jtag_base, const Status status)
{
	static int prd = 0;
	char msg[] = "Interval: 0000 ms\n";
	
	if (status.prd != prd) {
		msg[13] = status.prd % 10 + '0';
		msg[12] = (status.prd / 10) % 10 + '0';
		msg[11] = (status.prd / 100) % 10 + '0';
		msg[10] = (status.prd / 1000) % 10 + '0';
		jtaguart_wr_str(jtag_base, msg);
		prd = status.prd;
	}
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

static void ms_clock_isr(void *context, alt_u32 id)
{
	static int time = 0;
	static alt_u8 led_ptn = 0x01;

	Status *status = (Status *) context;

	if (status->pause) {
		timer_clear_tick(isr_timer_base);
		return;
	}

	if (time < status->prd) {
		time++;
	}
	else {
		time = 0;
		led_ptn ^= 0x03;
		pio_write(isr_ledg_base, led_ptn);
	}

	timer_clear_tick(isr_timer_base);
}

static void btn_isr(void *context, alt_u32 id)
{
	Status *status = (Status *) context;
	alt_u8 btn_data = (alt_u8) btn_read(isr_btn_base) & 0xf;

	if (btn_data & (0x1 << 0))
		status->pause = status->pause ^ 1;
	if (btn_data & (0x1 << 1))
		status->prd = pio_read(isr_switch_base) & 0x3ff;

	sseg_disp_msg(isr_sseg_base, *status);
	jtag_uart_disp_msg(isr_jtag_base, *status);

	btn_clear(isr_btn_base);
}

int main()
{
	Status status = {0, 100};		// not paused; 100 ms interval; 0 ms time

	sys_init(BTN_BASE, USER_TIMER_BASE);
	sseg_disp_msg(SSEG_BASE, status);
	jtag_uart_disp_msg(JTAG_UART_BASE, status);

	isr_timer_base = USER_TIMER_BASE;
	isr_btn_base = BTN_BASE;
	isr_switch_base = SWITCH_BASE;
	isr_sseg_base = SSEG_BASE;
	isr_jtag_base = JTAG_UART_BASE;
	isr_ledg_base = LEDG_BASE;

	alt_irq_register(USER_TIMER_IRQ, (void *) &status, ms_clock_isr);
	alt_irq_register(BTN_IRQ, (void *) &status, btn_isr);

	while (1);
}
