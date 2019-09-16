#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/alt_alarm.h>
#include "alt_types.h"
#include "system.h"
#include "gpio.h"

typedef struct status
{
	void (*state_func)(struct status *status);
	int time;
} status_type;

void sseg_disp_greet()
{
	alt_u8 msg[4] = {0xff, 0xff, 0x09, 0xf9};
	sseg_disp_ptn(SSEG_BASE, msg);
}

void sseg_disp_clear()
{
	alt_u8 msg[4] = {0xff, 0xff, 0xff, 0xff};
	sseg_disp_ptn(SSEG_BASE, msg);
}

void sseg_disp_time(int time)
{
	alt_u8 msg[4];
	msg[0] = sseg_conv_hex((time / 1000) % 10);
	msg[1] = sseg_conv_hex((time / 100) % 10);
	msg[2] = sseg_conv_hex((time / 10) % 10);
	msg[3] = sseg_conv_hex(time % 10);
	sseg_disp_ptn(SSEG_BASE, msg);
}

#define STDIN 0
#define STDOUT 1
#define STDERR 2

void sys_init(alt_u32 btn_base)
{
	btn_clear(btn_base);

	// set input to non-blocking
	int flags = fcntl(STDIN, F_GETFL);
	fcntl(STDIN, F_SETFL, flags | O_NONBLOCK);

	sseg_disp_greet();
}

void idle_state(status_type *status);
void start_state(status_type *status);
void react_state(status_type *status);
void result_state(status_type *status);

void idle_state(status_type *status)
{
	char ch;
	if (read(STDIN, &ch, 1) > 0 && ch == 's') {
		sseg_disp_clear();
		status->time = 2000 + rand() % 13000;
		status->state_func = &start_state;
	}
}

void start_state(status_type *status)
{
	char ch;
	if (read(STDIN, &ch, 1) > 0) {
		if (ch == 'c') {
			sseg_disp_greet();
			status->time = 0;
			status->state_func = &idle_state;
		}
		else if (ch == 'p') {
			sseg_disp_time(9999);
			status->time = 9999;
			status->state_func = &result_state;
		}
	}

	static int old_time = 0;
	int time = (alt_nticks() * 1000 / alt_ticks_per_second());
	if (old_time != time) {
		status->time--;
		old_time = time;
	}

	if (status->time == 0) {
		sseg_disp_time(0);
		status->state_func = &react_state;
	}
}

void react_state(status_type *status)
{
	char ch;
	if (read(STDIN, &ch, 1) > 0) {
		if (ch == 'c') {
			sseg_disp_greet();
			status->time = 0;
			status->state_func = &idle_state;
		}
		else if (ch == 'p') {
			sseg_disp_time(status->time);
			status->state_func = &result_state;
		}
	}

	static int old_time = 0;
	int time = (alt_nticks() * 1000 / alt_ticks_per_second());
	if (old_time != time) {
		status->time++;
		sseg_disp_time(status->time);
		old_time = time;
	}

	if (status->time == 1000) {
		status->state_func = &result_state;
	}
}

void result_state(status_type *status)
{
	char ch;
	if (read(STDIN, &ch, 1) > 0) {
		if (ch == 'c') {
			sseg_disp_greet();
			status->time = 0;
			status->state_func = &idle_state;
		}
		else if (ch == 's') {
			sseg_disp_clear();
			status->time = 2000 + rand() % 13000;
			status->state_func = &start_state;
		}
	}
}

int main() 
{
	status_type status = {&idle_state, 0};

	sys_init(BTN_BASE);

	while (1) {
		status.state_func(&status);
	}
}
