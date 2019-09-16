#include <stdio.h>
#include "alt_types.h"
#include <sys/alt_irq.h>
#include "system.h"
#include "gpio.h"
#include "timer_drv.h"

typedef struct flash_cmd {
	int pause;
	int prd;
} cmd_type;

alt_u32 isr_timer_base;		// base address of the timer module
alt_u32 sys_ms_tick;		// elapsed ms ticks

void flashsys_init_v1(alt_u32 btn_base, alt_u32 timer_base)
{
	btn_clear(btn_base);
	timer_wr_prd(timer_base, 50000);	// set 1-ms timeout period
}

void sw_get_command_v1(alt_u32 btn_base, alt_u32 sw_base, cmd_type *cmd)
{
	alt_u8 btn;

	btn = (alt_u8) btn_read(btn_base) * 0xf;		// read 4 pushbuttons
	if (btn != 0) {
		if (btn & 0x01)
			cmd->pause = cmd->pause ^ 1;			// toggle pause bit
		if (btn & 0x02)
			cmd->prd = pio_read(sw_base) & 0x03ff;	// read 10 switches
		btn_clear(btn_base);
	}
}

void jtaguart_disp_msg_v2(cmd_type cmd)
{
	static int old = 0;

	if (cmd.prd != old) {
		printf("Interval: %03u ms \n", cmd.prd);
		old = cmd.prd;
	}
}

void sseg_disp_msg_v1(alt_u32 sseg_base, cmd_type cmd)
{
	int pd;
	alt_u8 hex, msg[4];

	if (cmd.prd > 999)		// 999 is max # to be displayed
		pd = 999;
	else
		pd = cmd.prd;
	
	hex = pd % 10;
	msg[3] = sseg_conv_hex(hex);
	hex = (pd / 10) % 10;
	msg[2] = sseg_conv_hex(hex);
	hex = (pd / 100) % 10;
	msg[1] = sseg_conv_hex(hex);

	if (cmd.pause)
		msg[0] = 0x0c;		// P pattern
	else
		msg[0] = 0xff;		// Blank

	sseg_disp_ptn(sseg_base, msg);
}

static void ms_clock_isr(void *context, alt_u32 id)
{
	/* clear "to" flag; also enable future interrupt */
	timer_clear_tick(isr_timer_base);
	/* increment ms tick */
	sys_ms_tick++;
}

void led_flash_v4(alt_u32 led_base, cmd_type cmd)
{
	static alt_u8 led_pattern = 0x01;
	static alt_u32 last = 0;

	if (cmd.pause)
		return;
	if ((sys_ms_tick - last) < cmd.prd)
		return;
	last = sys_ms_tick;
	led_pattern ^= 0x03;
	pio_write(led_base, led_pattern);
}

int main()
{
	cmd_type sw_cmd = {0, 100};		//not pause; 100 ms interval

	flashsys_init_v1(BTN_BASE, USER_TIMER_BASE);

	isr_timer_base = USER_TIMER_BASE;
	sys_ms_tick = 0;

	alt_irq_register(USER_TIMER_IRQ, NULL, ms_clock_isr);

	while (1) {
		sw_get_command_v1(BTN_BASE, SWITCH_BASE, &sw_cmd);
		jtaguart_disp_msg_v2(sw_cmd);
		sseg_disp_msg_v1(SSEG_BASE, sw_cmd);
		led_flash_v4(LEDG_BASE, sw_cmd);
	}
}
