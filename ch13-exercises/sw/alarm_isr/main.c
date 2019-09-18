#include <stdio.h>
#include <ctype.h>
#include <sys/alt_irq.h>
#include "system.h"
#include "gpio.h"
#include "timer_drv.h"
#include "uart_drv.h"

void disp_time(unsigned int time)
{
	alt_u8 msg[4];
	msg[3] = sseg_conv_hex(time % 10);
	msg[2] = sseg_conv_hex((time / 10) % 6);
	msg[1] = sseg_conv_hex((time / 60) % 10);
	msg[0] = sseg_conv_hex((time / 600) % 6);
	sseg_disp_ptn(SSEG_BASE, msg);
	pio_write(LEDR_BASE, (time / 3600) & 0xf);
}

int valid_time_str(const char buf[], int len)
{
	if (len == 0) return 0;

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

#define LBUF 8

typedef struct status_t {
	void (*state_func) (struct status_t *status);
	unsigned int sys_s;
	unsigned int alarm_s;
	char cmd_buf[LBUF];
} Status;

void idle_state(Status *status);
void input_time_state(Status *status);
void input_alarm_state(Status *status);
void run_state(Status *status);
void alarm_state(Status *status);

void idle_state(Status *status)
{
	if (status->cmd_buf[0] == 's') {
		jtaguart_wr_str(JTAG_UART_BASE, "Input clock time in HHMMSS format\n");
		status->state_func = &input_time_state;
		status->cmd_buf[0] = '\0';
	}
	else if (status->cmd_buf[0] == 'a') {
		jtaguart_wr_str(JTAG_UART_BASE, "Input alarm time in HHMMSS format\n");
		status->state_func = &input_alarm_state;
		status->cmd_buf[0] = '\0';
	}
}

void input_time_state(Status *status)
{
	int str_len;
	for (str_len = 0; str_len < LBUF && isdigit(status->cmd_buf[str_len]); str_len ++);

	if (str_len == 0) {
		return;
	}
	else if (!valid_time_str(status->cmd_buf, str_len)) {
		status->cmd_buf[0] = '\0';
		jtaguart_wr_str(JTAG_UART_BASE, "Invalid time entered\n");
		return;
	}

	status->sys_s = str_to_time(status->cmd_buf, str_len);
	status->cmd_buf[0] = '\0';
	status->state_func = &run_state;
}

void input_alarm_state(Status *status)
{
	int str_len;
	for (str_len = 0; str_len < LBUF && isdigit(status->cmd_buf[str_len]); str_len ++);

	if (str_len == 0) {
		return;
	}
	else if (!valid_time_str(status->cmd_buf, str_len)) {
		status->cmd_buf[0] = '\0';
		jtaguart_wr_str(JTAG_UART_BASE, "Invalid time entered\n");
		return;
	}

	status->alarm_s = str_to_time(status->cmd_buf, str_len);
	status->cmd_buf[0] = '\0';
	status->state_func = &run_state;
}

void run_state(Status *status)
{
	if (status->cmd_buf[0] == 's') {
		jtaguart_wr_str(JTAG_UART_BASE, "Input clock time in HHMMSS format\n");
		status->state_func = &input_time_state;
		status->cmd_buf[0] = '\0';
	}
	else if (status->cmd_buf[0] == 'a') {
		jtaguart_wr_str(JTAG_UART_BASE, "Input alarm time in HHMMSS format\n");
		status->state_func = &input_alarm_state;
		status->cmd_buf[0] = '\0';
	}
	else {
		status->sys_s++;
		disp_time(status->sys_s);

		if (status->sys_s == status->alarm_s) {
			status->state_func = &alarm_state;
		}
	}
}

void alarm_state(Status *status)
{
	static int alarm_ptn = 0x00;

	if (status->cmd_buf[0] == 'c') {
		status->state_func = &idle_state;
		status->cmd_buf[0] = '\0';
		alarm_ptn = 0x00;
	} else {
		alarm_ptn ^= 0xff;
	}

	pio_write(LEDG_BASE, alarm_ptn);
}

void sys_init(alt_u32 jtag_base, alt_u32 timer_base)
{
	jtaguart_rd_int(jtag_base, 0x1);		// enable jtag read interrupt
	timer_wr_prd(timer_base, 50000000);		// set 1 s timeout period
}

void timer_isr(void *context, alt_u32 id)
{
	Status *status = (Status *) context;
	status->state_func(status);
	timer_clear_tick(USER_TIMER_BASE);
}

void jtag_isr(void *context, alt_u32 id)
{
	Status *status = (Status *) context;
	jtaguart_rd_str(JTAG_UART_BASE, status->cmd_buf, LBUF);
	status->state_func(status);
}

int main()
{
	Status status = {&idle_state, 0, 0, {0}};
	sys_init(JTAG_UART_BASE, USER_TIMER_BASE);

	alt_irq_register(USER_TIMER_IRQ, (void *) &status, timer_isr);
	alt_irq_register(JTAG_UART_IRQ, (void *) &status, jtag_isr);

	while (1);
}
