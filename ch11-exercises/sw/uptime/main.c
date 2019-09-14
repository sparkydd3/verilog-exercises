#include "system.h"
#include "gpio.h"
#include "uart_drv.h"
#include "timer_drv.h"

#define PAUSE 0x01
#define DISP_PRD 0x02

typedef struct flash_cmd {
	int status;
	unsigned int prd;
	unsigned int upt;
} cmd_type;

void sys_init(alt_u32 btn_base, alt_u32 usr_timer_base) {
	btn_clear(btn_base);						// clear button edge-capture reg
	timer_wr_prd(usr_timer_base, 50000);		// set 1-ms timeout period
}

void sw_get_command(alt_u32 btn_base, alt_u32 sw_base, cmd_type *cmd) {
	alt_u8 btn;

	btn = (alt_u8) btn_read(btn_base) & 0xf;	// read 4 pushbuttons
	if (btn != 0) {
		if (btn & 0x01)
			cmd->status = cmd->status ^ PAUSE;
		if (btn & 0x02)
			cmd->prd = pio_read(sw_base) & 0x03ff;	// read 10 switches
		if (btn & 0x04)
			cmd->status = cmd->status ^ DISP_PRD;

		btn_clear(btn_base);
	}
}

void jtaguart_disp_msg(alt_u32 jtag_base, const cmd_type cmd) {
	static int cur_prd = 0;
	static int cur_upt_min = 0;

	char prd_msg[] = "Interval: 0000 ms\n";
	char upt_msg[] = "Flashing-LED system has run for 00 minutes\n";

	if (cmd.prd != cur_prd) {
		cur_prd = cmd.prd;
		prd_msg[13] = cur_prd % 10 + '0';
		prd_msg[12] = (cur_prd / 10) % 10 + '0';
		prd_msg[11] = (cur_prd / 100) % 10 + '0';
		prd_msg[10] = cur_prd / 1000 + '0';
		jtaguart_wr_str(jtag_base, prd_msg);
	} 
	
	if ((cmd.upt / 60) != cur_upt_min) {
		cur_upt_min = cmd.upt / 60;
		upt_msg[33] = cur_upt_min % 10 + '0';
		upt_msg[32] = (cur_upt_min / 10) % 10 + '0';
		jtaguart_wr_str(jtag_base, upt_msg);
	}
}

void sseg_disp_msg(alt_u32 sseg_base, const cmd_type cmd) {
	unsigned int prd;
	unsigned int upt_min, upt_sec;
	alt_u8 hex, msg[4];

	if (cmd.status & DISP_PRD) {
		if (cmd.prd > 999)
			prd = 999;
		else
			prd = cmd.prd;
	
		hex = prd % 10;
		msg[3] = sseg_conv_hex(hex);
		hex = (prd / 10) % 10;
		msg[2] = sseg_conv_hex(hex);
		hex = (prd / 100) % 10;
		msg[1] = sseg_conv_hex(hex);
	
		if (cmd.status & PAUSE)
			msg[0] = 0x0c;	// P pattern
		else
			msg[0] = 0xff;	// blank
	}
	else {
		upt_min = cmd.upt / 60;
		upt_sec = cmd.upt % 60;

		hex = upt_sec % 10;
		msg[3] = sseg_conv_hex(hex);
		hex = (upt_sec / 10) % 10;
		msg[2] = sseg_conv_hex(hex);
		hex = upt_min % 10;
		msg[1] = sseg_conv_hex(hex);
		hex = (upt_min / 10) % 10;
		msg[0] = sseg_conv_hex(hex);
	}

	sseg_disp_ptn(sseg_base, msg);
}

void wait_for_ms(alt_u32 usr_timer_base) {
	while (timer_read_tick(usr_timer_base) != 1);

	timer_clear_tick(usr_timer_base);
}

void led_flash(alt_u32 led_base, alt_u32 usr_timer_base, const cmd_type cmd) {
	static alt_u8 led_pattern = 0x01;
	static int ms_tick = 0;

	if (cmd.status & PAUSE)
		return;
	
	if (ms_tick++ >= cmd.prd) {
		ms_tick = 0;
		led_pattern ^= 0x03;	// toggle 2 LSBs of LED
		pio_write(led_base, led_pattern);
	}
}

void update_uptime(cmd_type *cmd) {
	static int ms_tick = 0;

	if (ms_tick++ == 999) {
		cmd->upt++;
		ms_tick = 0;
	}
}

int main() {
	/* initial value: not pause, display period, 100 ms interval, 0 uptime */
	cmd_type sw_cmd = {DISP_PRD, 100, 0};

	sys_init(BTN_BASE, USER_TIMER_BASE);

	while (1) {
		sw_get_command(BTN_BASE, SWITCH_BASE, &sw_cmd);

		sseg_disp_msg(SSEG_BASE, sw_cmd);
		jtaguart_disp_msg(JTAG_UART_BASE, sw_cmd);

		led_flash(LEDG_BASE, USER_TIMER_BASE, sw_cmd);
		update_uptime(&sw_cmd);

		wait_for_ms(USER_TIMER_BASE);
	}
}
