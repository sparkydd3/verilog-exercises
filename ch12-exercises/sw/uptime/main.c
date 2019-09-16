#include <stdio.h>
#include <unistd.h>
#include <sys/alt_alarm.h>
#include "alt_types.h"
#include "system.h"
#include "gpio.h"

#define PAUSE_OFT 0
#define SHOW_UPTIME_OFT 1

typedef struct status {
	int status;
	unsigned int prd;
	unsigned int uptime;
} status_type;

void sys_init(alt_u32 btn_base)
{
	btn_clear(btn_base);	// clear button edge-capture flag
}

void sw_get_command(alt_u32 btn_base, alt_u32 sw_base, status_type *status)
{
	alt_u8 btn_data;

	btn_data = (alt_u8) btn_read(btn_base) & 0xf;		// read 4 pushbuttons
	if (btn_data != 0) {
		if (btn_data & (0x1 << 0))
			status->status = status->status ^ (0x1 << PAUSE_OFT);
		if (btn_data & (0x1 << 1))
			status->prd = pio_read(sw_base) & 0x03ff;		// read 10 switches
		if (btn_data & (0x1 << 2))
			status->status = status->status ^ (0x1 << SHOW_UPTIME_OFT);
		btn_clear(btn_base);
	}
}

void update_uptime(status_type *status)
{
	static unsigned int old_time = 0;
	unsigned int time;

	time = (unsigned int) (alt_nticks() / alt_ticks_per_second());
	if (time == old_time) return;

	status->uptime++;
	old_time = time;
}

void jtaguart_disp_interval(const status_type status)
{
	static int old = 0;

	if (status.prd != old) {
		printf("Interval: %03u ms \n", status.prd);
		old = status.prd;
	}
}

void jtaguart_disp_uptime(const status_type status)
{
	static int old = 0;
	int uptime_min = status.uptime / 60;

	if (uptime_min != old) {
		printf("Flashing-LED system has run for %02u minutes\n", uptime_min);
		old = uptime_min;
	}
}

void sseg_disp_msg(alt_u32 sseg_base, const status_type status)
{
	int data;
	alt_u8 hex, msg[4];

	if (status.status & (0x1 << SHOW_UPTIME_OFT)) {
		data = status.uptime;
		
		hex = data % 10;
		msg[3] = sseg_conv_hex(hex);
		hex = (data / 10) % 6;
		msg[2] = sseg_conv_hex(hex);
		hex = (data / 60) % 10;
		msg[1] = sseg_conv_hex(hex);
		hex = (data / 600) % 10;
		msg[0] = sseg_conv_hex(hex);
	} 
	else {
		/* 999 is max period to be displayed */
		data = (status.prd > 999) ? 999 : status.prd;

		hex = data % 10;
		msg[3] = sseg_conv_hex(hex);
		hex = (data / 10) % 10;
		msg[2] = sseg_conv_hex(hex);
		hex = data / 100;
		msg[1] = sseg_conv_hex(hex);

		/* Show P pattern when paused */
		msg[0] = (status.status & (0x1 << PAUSE_OFT)) ? 0x0c : 0xff;
	}

	sseg_disp_ptn(sseg_base, msg);
}

void led_flash(alt_u32 led_base, const status_type status)
{
	static alt_u8 led_pattern = 0x01;
	static unsigned int last_time = 0;
	unsigned int time;

	if (status.status & (0x1 << PAUSE_OFT)) return;
	
	time = (unsigned int) (alt_nticks() * 1000 / alt_ticks_per_second());
	if ((time - last_time) < status.prd) return;
	
	last_time = time;
	led_pattern ^= 0x03;							// toggle 2 LSB of LEDs
	pio_write(led_base, led_pattern);
}

int main() {						
	/* initial value: not paused, don't show uptime, 100 ms interval, no uptime */
	status_type status = {0, 100, 0};

	sys_init(BTN_BASE);

	while (1) {
		sw_get_command(BTN_BASE, SWITCH_BASE, &status);
		update_uptime(&status);

		jtaguart_disp_interval(status);
		jtaguart_disp_uptime(status);
		sseg_disp_msg(SSEG_BASE, status);
		led_flash(LEDG_BASE, status);
	}
}
