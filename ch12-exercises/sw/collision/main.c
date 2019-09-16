#include <stdio.h>
#include <unistd.h>
#include <sys/alt_alarm.h>
#include "alt_types.h"
#include "system.h"
#include "gpio.h"

#define POS_NUM 18

typedef struct status {
	unsigned int lpos;
	unsigned int rpos;
	unsigned int lspeed;
	unsigned int rspeed;
	int ldir;
	int rdir;
	int paused;
} status_type;

void sys_init(alt_u32 btn_base)
{
	btn_clear(btn_base);	// clear button edge-capture flag
}

void sw_get_command(alt_u32 btn_base, alt_u32 sw_base, status_type *status)
{
	alt_u8 btn_data;
	alt_u16 sw_data;

	btn_data = (alt_u8) btn_read(btn_base) & 0xf;		// read 4 pushbuttons
	if (btn_data != 0) {
		sw_data = (alt_u16) pio_read(sw_base) & 0x03ff;	// read 10 switches

		if (btn_data & (0x1 << 0))
			status->paused ^= 0x1;
		if (btn_data & (0x1 << 1))
			status->rspeed = (sw_data >= 100) ? 99 : sw_data;
		if (btn_data & (0x1 << 2))
			status->lspeed = (sw_data >= 100) ? 99 : sw_data;

		btn_clear(btn_base);
	}
}

void pos_update(status_type *status) {
	static unsigned int ltime = 0;
	static unsigned int rtime = 0;

	if (status->paused) return;
	
	unsigned int lint = (status->lspeed == 0) ? 0 : 1000 / status->lspeed;
	unsigned int rint = (status->rspeed == 0) ? 0 : 1000 / status->rspeed;

	unsigned int time = (unsigned int) (alt_nticks() * 1000 / alt_ticks_per_second());

	if (status->lpos >= status->rpos)
		status->ldir = -1;
	else if (status->lpos == 0)
		status->ldir = 1;
	else if (status->lpos >= POS_NUM - 1)
		status->ldir = -1;

	if (status->rpos <= status->lpos)
		status->rdir = 1;
	else if (status->rpos >= POS_NUM - 1)
		status->rdir = -1;
	else if (status->rpos == 0)
		status->rdir = 1;

	if (lint != 0 && time - ltime > lint) {
		status->lpos = (status->ldir > 0) ? status->lpos + 1 : status->lpos - 1;
		ltime = time;
	}

	if (rint != 0 && time - rtime > rint) {
		status->rpos = (status->rdir > 0) ? status->rpos + 1 : status->rpos - 1;
		rtime = time;
	}
}

void sseg_disp_msg(alt_u32 sseg_base, const status_type status)
{
	alt_u8 hex, msg[4];
	
	hex = (status.lspeed / 10) % 10;
	msg[0] = sseg_conv_hex(hex);
	hex = status.lspeed % 10;
	msg[1] = sseg_conv_hex(hex);
	hex = (status.rspeed / 10) % 10;
	msg[2] = sseg_conv_hex(hex);
	hex = status.rspeed % 10;
	msg[3] = sseg_conv_hex(hex);

	sseg_disp_ptn(sseg_base, msg);
}

void led_disp(alt_u32 ledr_base, alt_u32 ledg_base, const status_type status)
{
	alt_u32 led_ptn_l = 0x1 << (POS_NUM - 1 - status.lpos);
	alt_u32 led_ptn_r = 0x1 << (POS_NUM - 1 - status.rpos);
	alt_u32 led_ptn = led_ptn_l | led_ptn_r;

	pio_write(ledg_base, led_ptn & 0xff);
	pio_write(ledr_base, (led_ptn & (0x3ff << 8)) >> 8);
}

int main() {						
	/* initial value: led_l at left, led_r at right, both speed 50, directions, not paused */ 
	status_type status = {0, 17, 50, 50, 1, 0, 0};

	sys_init(BTN_BASE);

	while (1) {
		sw_get_command(BTN_BASE, SWITCH_BASE, &status);
		pos_update(&status);

		sseg_disp_msg(SSEG_BASE, status);
		led_disp(LEDR_BASE, LEDG_BASE, status);
	}
}
