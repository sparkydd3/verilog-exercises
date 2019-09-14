#include "system.h"
#include "gpio.h"

#define OUTSIDE 0
#define GATE_STREET 1
#define GATE_MIDDLE 2
#define GATE_LOT 3

#define NONE 0
#define ENTERING 1
#define EXITING 2

void sseg_disp_occupancy(alt_u32 sseg_base, int occupancy)
{
	alt_u8 msg[4];

	msg[0] = sseg_conv_hex((occupancy / 1000) % 10);
	msg[1] = sseg_conv_hex((occupancy / 100) % 10);
	msg[2] = sseg_conv_hex((occupancy / 10) % 10);
	msg[3] = sseg_conv_hex(occupancy % 10);

	sseg_disp_ptn(sseg_base, msg);
}

int main()
{
	int occupancy = 0;
	int car_loc = OUTSIDE;
	int car_dir = NONE;

	alt_u8 new_btn_data = 0;
	alt_u8 old_btn_data = 0;

	while (1) {
		sseg_disp_occupancy(SSEG_BASE, occupancy);

		old_btn_data = new_btn_data;
		new_btn_data = ~pio_read(BTN_BASE) & 0x3;

		if (new_btn_data == old_btn_data) continue;

		switch(car_loc) {
			case OUTSIDE:
				if (new_btn_data == 0x1) {
					car_loc = GATE_STREET;
					car_dir = ENTERING;
				}
				else if (new_btn_data == 0x2) {
					car_loc = GATE_STREET;
					car_dir = EXITING;
				}
				break;
			case GATE_STREET:
				if (new_btn_data == 0x3){
					car_loc = GATE_MIDDLE;
				}
				else {
					if (car_dir == EXITING)
						occupancy = (occupancy > 0) ? occupancy - 1 : 0;

					car_loc = OUTSIDE;
					car_dir = NONE;
				}
				break;
			case GATE_MIDDLE:
				if (new_btn_data == 0x1) {
					car_loc = GATE_STREET;
				}
				else if (new_btn_data == 0x2) {
					car_loc = GATE_LOT;
				}
				else {
					car_loc = OUTSIDE;
					car_dir = NONE;
				}
				break;
			case GATE_LOT:
				if (new_btn_data == 0x3) {
					car_loc = GATE_MIDDLE;
				} else {
					if (car_dir == ENTERING)
						occupancy++;

					car_loc = OUTSIDE;
					car_dir = NONE;
				}
				break;
		}
	}
}
