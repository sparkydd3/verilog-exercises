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

typedef struct ctxt1 {
	cmd_type *cmd_ptr;
	alt_u32 timer_base;
	alt_u32 led_base;
} ctxt1_type;

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

static void flash_led_isr(void *context, alt_u32 id)
{
	ctxt1_type *ctxt;
	cmd_type *cmd;
	static int ntick = 0;
	static unsigned char led_pattern = 0x01;

	/* type casting */
	ctxt = (ctxt1_type *) context;
	cmd = ctxt->cmd_ptr;

	/* clear "to" flag; also enable future interrupt */
	timer_clear_tick(ctxt->timer_base);
	if (cmd->pause)
		return;
	if (ntick < cmd->prd)
		ntick++;
	else {
		ntick = 0;
		led_pattern ^= 0x03;		// invert 2 LSBs
		pio_write(ctxt->led_base, led_pattern);
	}
}

int main()
{
	cmd_type sw_cmd = {0, 100};		//not pause; 100 ms interval
	ctxt1_type ctxt1;

	flashsys_init_v1(BTN_BASE, USER_TIMER_BASE);
	ctxt1.led_base = LEDG_BASE;
	ctxt1.timer_base = USER_TIMER_BASE;
	ctxt1.cmd_ptr = &sw_cmd;
	alt_irq_register(USER_TIMER_IRQ, (void *) &ctxt1, flash_led_isr);
	while (1) {
		sw_get_command_v1(BTN_BASE, SWITCH_BASE, &sw_cmd);
		jtaguart_disp_msg_v2(sw_cmd);
		sseg_disp_msg_v1(SSEG_BASE, sw_cmd);
	}
}
