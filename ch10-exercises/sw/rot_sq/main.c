#include "system.h"
#include "alt_types.h"
#include "io.h"

void sleep_forloop()
{
	int i;

	// assume each loop takes 400 ns
	for(i = 0; i < 1250000; i++);
}

void disp_sq(int sq_pos){
	alt_u8 hex3 = 0x7f, hex2 = 0x7f, hex1 = 0x7f, hex0 = 0x7f;

	switch(sq_pos){
		case 0: hex3 = 0x1c; break;
		case 1: hex2 = 0x1c; break;
		case 2: hex1 = 0x1c; break;
		case 3: hex0 = 0x1c; break;
		case 4: hex0 = 0x23; break;
		case 5: hex1 = 0x23; break;
		case 6: hex2 = 0x23; break;
		case 7: hex3 = 0x23; break;
	}

	IOWR(HEX3_BASE, 0, hex3);
	IOWR(HEX2_BASE, 0, hex2);
	IOWR(HEX1_BASE, 0, hex1);
	IOWR(HEX0_BASE, 0, hex0);
}

int main()
{
	int sq_pos = 0;
	alt_u8 sw_data;

	while (1) {
		sw_data = IORD(SWITCH_BASE, 0);

		if(sw_data & 0x1){
			sleep_forloop();

			if(sw_data & (0x1 << 1)){
				sq_pos = (sq_pos == 7) ? 0 : sq_pos + 1;
			} else {
				sq_pos = (sq_pos == 0) ? 7 : sq_pos - 1;
			}
		}

		disp_sq(sq_pos);
	}
}
