#include "system.h"
#include "alt_types.h"
#include "io.h"

void sleep_loop(){
	// assume 400 ns per loop
	// sleep for 62.5 ms
	int i;
	for(i = 0; i < 156250; i++);
}

int main()
{
	alt_u8 pwm_count = 0;
	alt_u8 ledg = 0x1;

	while (1) {
		pwm_count = (pwm_count == 0xf) ? 0x0 : pwm_count + 1;

		if(pwm_count == 0)
			ledg = 0x1;

		if (pwm_count == (IORD(SWITCH_BASE, 0) & 0xf))
			ledg = 0x0;

		IOWR(LEDG_BASE, 0, ledg);
		sleep_loop();
	}
}
