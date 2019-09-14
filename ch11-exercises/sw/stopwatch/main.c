#include "system.h"
#include "gpio.h"
#include "timer_drv.h"

typedef struct btn_status {
	int clear;
	int pause;
	int dir_up;
} btn_status;

void sys_init(alt_u32 timer_base) {
	timer_wr_prd(timer_base, 5000000);	// 0.1 sec timeout
}

void read_inputs(alt_u32 btn_base, alt_u32 switch_base, btn_status *status)
{
	alt_u8 btn_data = ~pio_read(btn_base);
	alt_u8 switch_data = pio_read(switch_base);

	status->clear = btn_data & 0x1;
	status->pause = btn_data & (0x1 << 1);
	status->dir_up = switch_data & 0x1;
}

void sseg_disp_time(alt_u32 sseg_base, alt_u16 ticks)
{
	alt_u8 msg[4];

	msg[3] = sseg_conv_hex(ticks % 10);
	msg[2] = sseg_conv_hex((ticks / 10) % 10);
	msg[1] = sseg_conv_hex((ticks / 100) % 6);
	msg[0] = sseg_conv_hex((ticks / 600) % 10);

	sseg_disp_ptn(sseg_base, msg);
}

int main() {
	btn_status status = {0, 0, 1};	// not clear, not pause, count up;
	alt_u16 ticks = 0;

	sys_init(USER_TIMER_BASE);

	while (1) {
		read_inputs(BTN_BASE, SWITCH_BASE, &status);

		if (status.clear) ticks = 0;

		if (timer_read_tick(USER_TIMER_BASE)) {
			if (!status.pause){
				if (status.dir_up)
					ticks++;
				else
					ticks--;

				ticks = (ticks > 6000) ? 5999 : ticks;
			}
			timer_clear_tick(USER_TIMER_BASE);
		}

		sseg_disp_time(SSEG_BASE, ticks);
	}
}
