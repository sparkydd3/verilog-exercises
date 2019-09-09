#include "system.h"
#include "gpio.h"
#include "uart_drv.h"
#include "timer_drv.h"

typedef struct flash_cmd {
	int pause;
	int prd;
} cmd_type;

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

void jtaguart_disp_msg_v1(alt_u32 jtag_base, cmd_type cmd)
{
	static int current = 0;
	char msg[] = "Interval: 0000 ms\n";

	if (cmd.prd != current) {
		msg[13] = cmd.prd % 10 + '0';
		msg[12] = (cmd.prd / 10) % 10 + '0';
		msg[11] = (cmd.prd / 100) % 10 + '0';
		msg[10] = cmd.prd / 1000 + '0';
		jtaguart_wr_str(jtag_base, msg);
		current = cmd.prd;
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

void led_flash_v1(alt_u32 led_base, alt_u32 timer_base, cmd_type cmd)
{
	static alt_u8 led_pattern = 0x01;
	int ntick = 0;

	if (cmd.pause)
		return;
	
	led_pattern ^= 0x03;	// toggle 2 LSB of LEDs
	pio_write(led_base, led_pattern);

	/* pause for cmd.prd ms */
	while (ntick < cmd.prd) {
		if (timer_read_tick(timer_base) == 1) {
			timer_clear_tick(timer_base);
			ntick++;
		}
	}

}

int main() {
	cmd_type sw_cmd = {0, 100};	// initial value: not paused, 100 ms interval

	flashsys_init_v1(BTN_BASE, USER_TIMER_BASE);

	while (1) {
		sw_get_command_v1(BTN_BASE, SWITCH_BASE, &sw_cmd);
		jtaguart_disp_msg_v1(JTAG_UART_BASE, sw_cmd);
		sseg_disp_msg_v1(SSEG_BASE, sw_cmd);
		led_flash_v1(LEDG_BASE, USER_TIMER_BASE, sw_cmd);
	}
}
