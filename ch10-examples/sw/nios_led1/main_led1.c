#include "io.h"
#include "alt_types.h"
#include "system.h"

void sw_get_command_v0(alt_u32 sw_base, int *prd)
{
	*prd = IORD(sw_base, 0) & 0x000003ff;
}

void led_flash_v0(alt_u32 led_base, int prd)
{
	static alt_u8 led_pattern = 0x01;
	unsigned long i, itr;

	led_pattern ^= 0x03;
	IOWR(led_base, 0, led_pattern);
	itr = prd * 2500;
	for (i = 0; i < itr; i++) {}
}

int main()
{
	int prd;

	while (1) {
		sw_get_command_v0(SWITCH_BASE, &prd);
		led_flash_v0(LED_BASE, prd);
	}
}
