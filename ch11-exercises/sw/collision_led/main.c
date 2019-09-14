#include "system.h"
#include "gpio.h"
#include "uart_drv.h"
#include "timer_drv.h"

typedef struct led_state {
	alt_u32 pos;
	alt_u8 spd;
	alt_u8 paused;
} led_state;

void sys_init(alt_u32 btn_base, alt_u32 timer_base)
{
	btn_clear(btn_base);
	timer_wr_prd(timer_base, 50000);	// set 1-ms timeout period
}

void led_disp_pos(alt_u32 ledr_base, alt_u32 ledg_base, const led_state left, const led_state right)
{
	alt_u32 combined_leds = left.pos | right.pos;
	pio_write(ledg_base, combined_leds & 0xff);
	pio_write(ledr_base, (combined_leds & (0x3ff << 8)) >> 8);
}

void input_read(alt_u32 btn_base, alt_u32 sw_base, led_state *left, led_state *right)
{
	alt_u8 btn_edge = btn_read(btn_base);
	alt_u8 btn_level = pio_read(btn_base);

	left->paused = ~btn_level & 0x1;
	right->paused = ~btn_level & 0x1;
	
	if (btn_edge & 0x1 << 1)
		right->spd = pio_read(sw_base) & 0x1f;

	if (btn_edge & 0x1 << 2)
		left->spd = (pio_read(sw_base) & (0x1f << 5)) >> 5;
	
	if (left->spd > 99)
		left->spd = 99;
	
	if (right->spd > 99)
		right->spd = 99;
	
	btn_clear(btn_base);
}

void sseg_disp_spd(alt_u32 sseg_base, const led_state left, const led_state right) {
	static alt_u8 msg[4];
	msg[0] = sseg_conv_hex(left.spd / 10);
	msg[1] = sseg_conv_hex(left.spd % 10);
	msg[2] = sseg_conv_hex(right.spd / 10);
	msg[3] = sseg_conv_hex(right.spd % 10);
	sseg_disp_ptn(sseg_base, msg);
}

void jtaguart_disp_msg(alt_u32 jtag_base, const led_state left, const led_state right) {
	static int left_cur = 0;
	static int right_cur = 0;
	char left_msg[] = "Left speed: 00\n";
	char right_msg[]= "Right speed: 00\n";

	if (left.spd != left_cur) {
		left_msg[12] = left.spd / 10 + '0';
		left_msg[13] = left.spd % 10 + '0';
		jtaguart_wr_str(jtag_base, left_msg);
		left_cur = left.spd;
	}
	
	if (right.spd != right_cur) {
		right_msg[13] = right.spd / 10 + '0';
		right_msg[14] = right.spd % 10 + '0';
		jtaguart_wr_str(jtag_base, right_msg);
		right_cur = right.spd;
	}
}

void led_pos_calc(alt_u32 timer_base, led_state *left, led_state *right) {
	static alt_u16 ltick = 0, rtick = 0;
	static alt_u8 lspd = 0, rspd = 0;
	static alt_u16 lper = 0, rper = 0;
	static alt_u8 ldir = 1, rdir = 0;

	/* Update speed, convert speed to movement period */
	if (left->spd != lspd) {
		lspd = left->spd;
		lper = (lspd == 0) ? 0 : 1000 / lspd;
		ltick = 0;
	}

	if (right->spd != rspd) {
		rspd = right->spd;
		rper = (rspd == 0) ? 0 : 1000 / rspd;
		rtick = 0;
	}

	/* Perform following update actions only after timer tick */
	if (timer_read_tick(timer_base) == 1) {
		ltick++;
		rtick++;
		timer_clear_tick(timer_base);
	} else {
		return;
	}

	/* bounds checking, wall bounce requirement stricter and modified last */
	if (left->pos <= right->pos) ldir = 0;
	if (left->pos >= 0x1 << 17) ldir = 1;

	if (right->pos >= left->pos) rdir = 1;
	if (right->pos <= 0x1) rdir = 0;

	/* update location */
	if (ltick >= lper && lper != 0 && !left->paused) {
		left->pos = (ldir) ? left->pos >> 1 : left->pos << 1;
		ltick = 0;
	}

	if (rtick >= rper && rper != 0 && !right->paused) {
		right->pos = (rdir) ? right->pos >> 1 : right->pos << 1;
		rtick = 0;
	}
}

int main() {
	led_state left = {0x1 << 17, 50, 0};		// leftmost (0), speed 50, not paused
	led_state right = {0x1, 50, 0};				// rightmost (17), speed 50, not paused
	sys_init(BTN_BASE, USER_TIMER_BASE);

	while (1) {
		led_disp_pos(LEDR_BASE, LEDG_BASE, left, right);
		sseg_disp_spd(SSEG_BASE, left, right);
		jtaguart_disp_msg(JTAG_UART_BASE, left, right);

		input_read(BTN_BASE, SWITCH_BASE, &left, &right);
		led_pos_calc(USER_TIMER_BASE, &left, &right);
	}
}
