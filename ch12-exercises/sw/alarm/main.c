#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/alt_alarm.h>
#include <ctype.h>
#include "alt_types.h"
#include "system.h"
#include "gpio.h"

#define STDIN 0

void display_time(int time)
{
	alt_u8 sseg_time[4];
	alt_u8 hour;

	sseg_time[3] = sseg_conv_hex(time % 10);
	sseg_time[2] = sseg_conv_hex((time / 10) % 6);
	sseg_time[1] = sseg_conv_hex((time / 60) % 10);
	sseg_time[0] = sseg_conv_hex((time / 600) % 6);
	hour = (time / 3600) % 16;

	sseg_disp_ptn(SSEG_BASE, sseg_time);
	pio_write(LEDR_BASE, hour & 0xf);
}

void flash_alarm()
{
	static alt_u8 alarm_state = 0xff;
	static int old_time = 0;
	int time = alt_nticks() * 2 / alt_ticks_per_second();

	if (old_time != time) {
		alarm_state ^= 0xff;
		pio_write(LEDG_BASE, alarm_state);
		old_time = time;
	}
}

void clear_alarm()
{
	pio_write(LEDG_BASE, 0);
}

void flush_input()
{
	char ch;
	while (read(STDIN, &ch, 1) > 0);
}

int valid_time_str(const char buf[], int len)
{
	int i;
	for (i = 0; i < len; i++)
	{
		if (!isdigit(buf[i])) return 0;
	}

	/* check tens digit of hour */
	if (len >= 1 && (buf[0] - '0') > 1) return 0;

	/* check ones digit of hour */
	if (len >= 2 && (buf[0] - '0') == 1 && (buf[1] - '0') > 2) return 0;

	/* check tens digit of minute */
	if (len >= 3 && (buf[2] - '0') > 5) return 0;

	/* check tens digit of second */
	if (len >= 5 && (buf[4] - '0') > 5) return 0;

	return 1;
}

int str_to_time(const char buf[], int len)
{
	int time = 0;

	if (len >= 1) time += (buf[0] - '0') * 10 * 3600;
	if (len >= 2) time += (buf[1] - '0') * 3600;
	if (len >= 3) time += (buf[2] - '0') * 600;
	if (len >= 4) time += (buf[3] - '0') * 60;
	if (len >= 5) time += (buf[4] - '0') * 10;
	if (len >= 6) time += (buf[5] - '0');

	return time;
}

typedef struct status
{
	void (*state_func)(struct status *status);
	int cur_time;
	int alarm_time;
} status_type;

void clear_state(status_type *status);
void input_time_state(status_type *status);
void input_alarm_state(status_type *status);
void run_state(status_type *status);
void alarm_state(status_type *status);

void clear_state(status_type *status)
{
	char ch = 0;
	if (read(STDIN, &ch, 1) > 0) {
		flush_input();

		switch(ch) {
			case 's':
				printf("Enter 12h time in HHMMSS format");
				status->state_func = &input_time_state;
				break;
			case 'a':
				printf("Enter 12h time in HHMMSS format");
				status->state_func = &input_alarm_state;
				break;
		}
	}
}

void input_time_state(status_type *status)
{
	char buf[6];
	int len;
	while((len = read(STDIN, &buf, 6)) <= 0);
	flush_input();

	if(!valid_time_str(buf, len)) {
		printf("Invalid time entered.");
		return;
	}

	status->cur_time = str_to_time(buf, len);
	status->state_func = &run_state;
	display_time(status->cur_time);
}

void input_alarm_state(status_type *status)
{
	char buf[6];
	int len;
	while((len = read(STDIN, &buf, 6)) <= 0);
	flush_input();

	if(!valid_time_str(buf, len)) {
		printf("Invalid time entered.");
		return;
	}

	status->alarm_time = str_to_time(buf, len);
	status->state_func = &run_state;
	display_time(status->cur_time);
}

void run_state(status_type *status)
{
	char ch = 0;
	if (read(STDIN, &ch, 1) > 0) {
		flush_input();

		switch(ch) {
			case 's':
				printf("Enter 12h time in HHMMSS format");
				status->state_func = &input_time_state;
				break;
			case 'a':
				printf("Enter 12h time in HHMMSS format");
				status->state_func = &input_alarm_state;
				break;
		}
	}

	static int old_time = 0;
	int time = alt_nticks() / alt_ticks_per_second();

	if (old_time != time) {
		status->cur_time++;
		display_time(status->cur_time);
		old_time = time;
	}

	if(status->cur_time == status->alarm_time) {
		status->state_func = &alarm_state;
	}
}

void alarm_state(status_type *status)
{
	char ch = 0;
	if (read(STDIN, &ch, 1) > 0 && ch == 'c') {
		flush_input();
		status->state_func = &clear_state;
		clear_alarm();
		return;
	}

	flash_alarm();
}

void sys_init(const status_type status)
{
	// set input to non-blocking
	int flags = fcntl(STDIN, F_GETFL);
	fcntl(STDIN, F_SETFL, flags | O_NONBLOCK);

	display_time(status.cur_time);
}

int main() 
{
	status_type status = {&clear_state, 0, 0};
	sys_init(status);

	while (1) {
		status.state_func(&status);
	}
}
