#include "system.h"
#include "alt_types.h"
#include "io.h"

void sleep_for_loop(int prd)
{
	unsigned long i, itr;
	itr = prd * 2500;
	for(i = 0; i < itr; i++);
}

int sw_read_period(alt_u32 sw_base)
{
	return IORD(sw_base, 0) & 0x1f;	// period from right 5 switches
}

int key_read_reset(alt_u32 key_base)
{
	return IORD(key_base, 0) & 0x1;
}

void led_display_pattern(alt_u32 ledr_base, alt_u32 ledg_base, alt_u32 pattern)
{
	IOWR(ledg_base, 0, (pattern & 0x000000ff));
	IOWR(ledr_base, 0, (pattern & 0x0003ff00) >> 8);
}

int main()
{
	alt_u32 pattern = 0x1;
	int prd;

	while (1) {
		prd = sw_read_period(SWITCH_BASE);
		sleep_for_loop(prd);

		if (key_read_reset(KEY_BASE)) {
			pattern = 0x1;
		} else if (pattern == (0x1 << 18)){
			pattern = 0x1;
		} else {
			pattern = pattern << 1;
		}

		led_display_pattern(LEDR_BASE,LEDG_BASE, pattern);
	}
}
