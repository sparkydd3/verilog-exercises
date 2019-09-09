#include "system.h"
#include "alt_types.h"
#include "io.h"

#define LEFT 0
#define RIGHT 1

void sleep_for_loop()
{
	int i;
	for(i = 0; i < 2500; i++);
}

void led_display_pattern(alt_u32 ledr_base, alt_u32 ledg_base, alt_u32 pattern)
{
	IOWR(ledg_base, 0, pattern & 0xff);
	IOWR(ledr_base, 0, (pattern & 0x3ff00) >> 8);
}

int main()
{
	int prd_l = 0;
	int prd_r = 0;

	int dir_l = RIGHT;
	int dir_r = LEFT;

	alt_u32 pattern_l = 0x1 << 17;
	alt_u32 pattern_r = 0x1;

	alt_u32 switch_data;
	alt_u32 key_data;

	while (1) {
		sleep_for_loop();
		
		switch_data = IORD(SWITCH_BASE, 0);
		key_data = IORD(KEY_BASE, 0); 

		// determine led direction
		if (pattern_l <= pattern_r)
			dir_l = LEFT;

		if (pattern_l == (0x1 << 17))
			dir_l = RIGHT;

		if (pattern_r >= pattern_l)
			dir_r = RIGHT;

		if (pattern_r == 0x1)
			dir_r = LEFT;

		// reset LED positions
		if (key_data & (0x1 << 1))
			pattern_l = (0x1 << 17);

		if (key_data & 0x1)
			pattern_r = 0x1;

		// read left 5 switches when ready to update
		if (prd_l > (switch_data & (0x1f << 5)) >> 5) {
			if (dir_l == LEFT)
				pattern_l <<= 1;
			else if (dir_l == RIGHT)
				pattern_l >>= 1;

			prd_l = 0;
		}

		// read right 5 switches when ready to update
		if (prd_r > (switch_data & 0x1f)) {
			if (dir_r == LEFT)
				pattern_r <<= 1;
			else if (dir_r == RIGHT)
				pattern_r >>= 1;

			prd_r = 0;
		}

		prd_l++;
		prd_r++;

		led_display_pattern(LEDR_BASE, LEDG_BASE, (pattern_l | pattern_r));
	}
}
