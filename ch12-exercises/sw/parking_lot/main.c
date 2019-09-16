#include <stdio.h>
#include <unistd.h>
#include <sys/alt_alarm.h>
#include "alt_types.h"
#include "system.h"
#include "gpio.h"

#define	OUTSIDE 0
#define GATE_STREET 1
#define GATE_MID 2
#define GATE_LOT 3

#define GATE_STREET_OFT 0
#define GATE_LOT_OFT 1

typedef struct status {
	int car_loc;
	int car_dir;
	unsigned int ocpcy;
} status_type;

void sys_init(alt_u32 btn_base)
{
	btn_clear(btn_base);	// clear button edge-capture flag
}

void btn_get_command(alt_u32 btn_base, status_type *status)
{
	static alt_u8 old_btn_data = 0;
	alt_u8 btn_data = ~pio_read(btn_base) & 0x3;

	if (old_btn_data == btn_data) return;

	switch (status->car_loc) {
		case OUTSIDE:
			if (btn_data == (0x1 << GATE_STREET_OFT)) {
				status->car_dir = 1;
				status->car_loc = GATE_STREET;
			}
			else if (btn_data == (0x1 << GATE_LOT_OFT)) {
				status->car_dir = -1;
				status->car_loc = GATE_LOT;
			}
			break;
		case GATE_STREET:
			if (btn_data == 0x0) {
				if (status->car_dir == -1) 
					status->ocpcy = (status->ocpcy == 0) ? 0 : status->ocpcy - 1;

				status->car_loc = OUTSIDE;
				status->car_dir= 0;
			}
			else if (btn_data == ((0x1 << GATE_STREET_OFT) | (0x1 << GATE_LOT_OFT))) {
				status->car_loc = GATE_MID;
			} 
			else {
				status->car_loc = OUTSIDE;
				status->car_dir = 0;
			}
			break;
		case GATE_MID:
			if (btn_data == (0x1 << GATE_STREET_OFT)) {
				status->car_loc = GATE_STREET;
			}
			else if (btn_data == (0x1 << GATE_LOT_OFT)) {
				status->car_loc = GATE_LOT;
			} else {
				status->car_loc = OUTSIDE;
				status->car_dir = 0;
			}
			break;
		case GATE_LOT:
			if (btn_data == 0x0) {
				if (status->car_dir == 1)
					status->ocpcy++;

				status->car_loc = OUTSIDE;
				status->car_dir = 0;
			}
			else if (btn_data == ((0x1 << GATE_STREET_OFT) | (0x1 << GATE_LOT_OFT))) {
				status->car_loc = GATE_MID;
			}
			else {
				status->car_loc = OUTSIDE;
				status->car_dir = 0;
			}
			break;
	}

	old_btn_data = btn_data;
}

void sseg_disp_ocpcy(alt_u32 sseg_base, const status_type status)
{
	alt_u8 hex, msg[4];
	
	hex = (status.ocpcy / 1000) % 10;
	msg[0] = sseg_conv_hex(hex);
	hex = (status.ocpcy / 100) % 10; 
	msg[1] = sseg_conv_hex(hex);
	hex = (status.ocpcy / 10) % 10;
	msg[2] = sseg_conv_hex(hex);
	hex = status.ocpcy % 10; 
	msg[3] = sseg_conv_hex(hex);

	sseg_disp_ptn(sseg_base, msg);
}

int main() {						
	/* car outside, no direction, no occupants*/
	status_type status = {OUTSIDE, 0, 0};

	sys_init(BTN_BASE);

	while (1) {
		btn_get_command(BTN_BASE, &status);
		sseg_disp_ocpcy(SSEG_BASE, status);
	}
}
