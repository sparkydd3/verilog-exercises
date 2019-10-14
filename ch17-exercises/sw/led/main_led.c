#include <stdio.h>
#include "alt_types.h"
#include <sys/alt_irq.h>
#include "system.h"
#include "gpio.h"
#include "timer_drv.h"
#include "avalon_ps2.h"

typedef struct flash_cmd {
	int pause;
	int prd;
} cmd_type;

typedef struct ctxt {
	cmd_type *cmd_ptr;
	alt_u32 timer_base;
	alt_u32 led_base;
} ctxt_type;

void flashsys_init(alt_u32 btn_base, alt_u32 timer_base, alt_u32 ps2_base)
{
	btn_clear(btn_base);
	timer_wr_prd(timer_base, 50000);	// set 1-ms timeout period
	ps2_reset_device(ps2_base);
}

void jtaguart_disp_msg(cmd_type cmd)
{
	static int old = 0;

	if (cmd.prd != old) {
		printf("Interval: %03u ms \n", cmd.prd);
		old = cmd.prd;
	}
}

void sseg_disp_msg(alt_u32 sseg_base, cmd_type cmd)
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
	ctxt_type *ctxt;
	cmd_type *cmd;
	static int ntick = 0;
	static unsigned char led_pattern = 0x01;

	ctxt = (ctxt_type *) context;
	cmd = ctxt->cmd_ptr;

	/* clear "to" flag; also enable future interrupt */
	timer_clear_tick(ctxt->timer_base);
	if (cmd->pause)
		return;
	if (ntick < cmd->prd)
		ntick++;
	else {
		ntick = 0;
		led_pattern ^= 0x03;
		pio_write(ctxt->led_base, led_pattern);
	}
}

void ps2_get_command(alt_u32 ps2_base, cmd_type *cmd)
{
	#define BUF_SIZE 5
	static alt_u8 buf[BUF_SIZE];

	kb_get_line(ps2_base, buf, BUF_SIZE);

	if (buf[0] == 'p' || buf[0] == 'P'){
		cmd->pause ^= 0x1;
	}

	if (buf[0] == 0xf0) {	// F1
		int prd = 0;
		int j;
		for (j = 1; buf[j] != '\0'; j++){
			if (buf[j] >= '0' && buf[j] <= '9') {
				prd = prd * 10 + (buf[j] - '0');
			}
		}

		cmd->prd = prd;
	}
}

int main()
{
	cmd_type sw_cmd = {0, 100};		//not pause; 100 ms interval
	ctxt_type ctxt;

	flashsys_init(BTN_BASE, USR_TIMER_BASE, PS2_BASE);
	ctxt.led_base = LED_BASE;
	ctxt.timer_base = USR_TIMER_BASE;
	ctxt.cmd_ptr = &sw_cmd;

	alt_irq_register(USR_TIMER_IRQ, (void *) &ctxt, flash_led_isr);

	while (1) {
		ps2_get_command(PS2_BASE, &sw_cmd);
		jtaguart_disp_msg(sw_cmd);
		sseg_disp_msg(SSEG_BASE, sw_cmd);
	}
}
