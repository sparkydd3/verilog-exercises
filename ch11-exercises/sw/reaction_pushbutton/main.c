#include <stdlib.h>
#include "system.h"
#include "gpio.h"
#include "timer_drv.h"

#define CLEAR_OFT 0
#define START_OFT 1
#define STOP_OFT 2

void sys_init(alt_u32 timer_base) {
	timer_wr_prd(timer_base, 50000);	// 1 ms tick
}

void sseg_disp_greet(alt_u32 sseg_base) {
	alt_u8 msg[] = {0xff, 0xff, 0x09, 0xf9};
	sseg_disp_ptn(sseg_base, msg);
}

void sseg_disp_time(alt_u32 sseg_base, int time) {
	alt_u8 msg[4];
	msg[0] = sseg_conv_hex((time / 1000) % 10);
	msg[1] = sseg_conv_hex((time / 100) % 10);
	msg[2] = sseg_conv_hex((time / 10) % 10);
	msg[3] = sseg_conv_hex(time % 10);
	sseg_disp_ptn(sseg_base, msg);
}

void sseg_clear(alt_u32 sseg_base) {
	alt_u8 msg[] = {0xff, 0xff, 0xff, 0xff};
	sseg_disp_ptn(sseg_base, msg);
}

int main()
{
	int time = 0;

	sys_init(USER_TIMER_BASE);

	while (1) {
		sseg_disp_greet(SSEG_BASE);

		/* wait for start signal */
		while(!(btn_read(BTN_BASE) & (0x1 << START_OFT)));
		btn_clear(BTN_BASE);

		/* wait for random time 2-15 sec or until any button pressed */
		time = rand() % 13000 + 2000;
		sseg_clear(SSEG_BASE);

		while (time > 0 && !btn_is_pressed(BTN_BASE)) {
			if (timer_read_tick(USER_TIMER_BASE)){
				timer_clear_tick(USER_TIMER_BASE);
				time--;
			}
		}

		/* begin recording reaction time or display false start result */
		if (!btn_is_pressed(BTN_BASE)) {
			while (time < 1000 && !btn_is_pressed(BTN_BASE)) {
				if (timer_read_tick(USER_TIMER_BASE)) {
					timer_clear_tick(USER_TIMER_BASE);
					time++;
					sseg_disp_time(SSEG_BASE, time);
				}
			}
		} else if (btn_read(BTN_BASE) & (0x1 << STOP_OFT)) {
			time = 9999;
			btn_clear(BTN_BASE);
			sseg_disp_time(SSEG_BASE, time);
		}

		/* wait for clear button press */
		while(!(btn_read(BTN_BASE) & (0x1 << CLEAR_OFT)));
		btn_clear(BTN_BASE);
	}
}
