#include <stdio.h>
#include <unistd.h>
#include <sys/alt_alarm.h>
#include "alt_types.h"
#include "system.h"
#include "gpio.h"

typedef struct flash_cmd {
	int pause;
	int prd;
} cmd_type;

void flashsys_init_v2(alt_u32 btn_base)
{
	btn_clear(btn_base);	// clear button edge-capture flag
}

void sw_get_command_v1(alt_u32 btn_base, alt_u32 sw_base, cmd_type *cmd)
{
	alt_u8 btn;

	btn = (alt_u8) btn_read(btn_base) & 0xf;		// read 4 pushbuttons
	if (btn != 0) {
		if (btn & 0x01)
			cmd->pause = cmd->pause ^ 1;
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

	if (cmd.prd > 999)
		pd = 999;				// 999 is max # to be displayed
	else
		pd = cmd.prd;

	hex = pd % 10;
	msg[3] = sseg_conv_hex(hex);
	hex = (pd / 10) % 10;
	msg[2] = sseg_conv_hex(hex);
	hex = pd / 100;
	msg[1] = sseg_conv_hex(hex);

	if (cmd.pause)
		msg[0] = 0x0c;			// P pattern
	else
		msg[0] = 0xff;

	sseg_disp_ptn(sseg_base, msg);
}

void led_flash_v3(alt_u32 led_base, cmd_type cmd)
{
	static alt_u8 led_pattern = 0x01;
	static int last = 0;
	int now;

	if (cmd.pause) 
		return;
	
	now = (int) (alt_nticks() * 1000 / alt_ticks_per_second());
	if ((now - last) < cmd.prd) 
		return;
	
	last = now;
	led_pattern ^= 0x03;	// toggle 2 LSB of LEDs
	pio_write(led_base, led_pattern);
}

int main() {
	cmd_type sw_cmd = {0, 100};	// initial value: not paused, 100 ms interval

	flashsys_init_v2(BTN_BASE);

	while (1) {
		sw_get_command_v1(BTN_BASE, SWITCH_BASE, &sw_cmd);
		jtaguart_disp_msg_v2(sw_cmd);
		sseg_disp_msg_v1(SSEG_BASE, sw_cmd);
		led_flash_v3(LEDG_BASE, sw_cmd);
	}
}
