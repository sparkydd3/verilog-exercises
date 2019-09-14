#include "system.h"
#include "gpio.h"
#include "timer_drv.h"

#define N 12

void sys_init(alt_u32 timer_base, char *ch_digits, alt_u8 *sseg_digits) {
	timer_wr_prd(timer_base, 25000000);	// 0.5 ms tick

	int i;
	for (i = 0; i < N; i++) {
		sseg_digits[i] = sseg_conv_hex(ch_digits[i] - '0');
	}
}

int main() {
	int dir = 0;
	int paused = 0;

	char ch_digits[] = "012345789012";
	alt_u8 sseg_digits[N];
	int i = 0;

	sys_init(USER_TIMER_BASE, ch_digits, sseg_digits);

	while (1) {
		paused = ~pio_read(BTN_BASE) & 0x1;
		dir = pio_read(SWITCH_BASE) & 0x1;

		if(timer_read_tick(USER_TIMER_BASE)) {
			timer_clear_tick(USER_TIMER_BASE);
			
			if(!paused) {
				if (dir)
					i = (i == N - 4) ? 0 : i + 1;
				else
					i = (i == 0) ? N - 4 : i - 1;
			}
		}

		sseg_disp_ptn(SSEG_BASE, &sseg_digits[i]);
	}
}
