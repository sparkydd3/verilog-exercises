#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "gpio.h"
#include "avalon_ps2_en_mouse.h"

void mouse_led(alt_u32 led_base, mouse_mv_type *mv)
{
	static int count = 0;
	int pos;
	alt_u32 led_ptn;

	if (mv->lbtn)
		count = 0;
	else if (mv->rbtn)
		count = 255;
	else {
		count = count + mv->xmov;
		if (count > 255)
			count = 255;
		if (count < 0)
			count = 0;
	}

	pos = (count >> 5);		// get 3 MSB
	led_ptn = (0x00000080) >> pos;	//0b10000000
	pio_write(led_base, led_ptn);
}

void sys_init(alt_u32 ps2_base)
{
	mouse_init(ps2_base);
}

int main(void) {
	mouse_mv_type mv;
	alt_u8 ps2_msg[4] = {0xff, 0x0c, sseg_conv_hex(5), sseg_conv_hex(2)};

	sseg_disp_ptn(SSEG_BASE, ps2_msg);	// display " PS2"
	printf("PS2 test: \n");

	sys_init(PS2_BASE);

	printf("Mouse data stream: (left button, right button, "
		"x-axis move, y-axis move)\n");

	while (1) {
		if (mouse_get_activity(PS2_BASE, &mv)) {
			printf("(%d, %d, %d, %d, %d, %d) ",
					mv.lbtn, mv.rbtn, mv.mbtn, mv.xmov, mv.ymov, mv.zmov);
			mouse_led(LED_BASE, &mv);
		}
	}
}
