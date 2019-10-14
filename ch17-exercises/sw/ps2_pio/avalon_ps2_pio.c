#include <io.h>
#include <unistd.h>			// to use usleep
#include <sys/alt_irq.h>
#include "avalon_ps2_pio.h"

#define PS2_DATA_REG 0
#define PS2_DIRN_REG 1
#define PS2_INTR_REG 2
#define PS2_EDGE_REG 3
#define PS2_OUTS_REG 4
#define PS2_OUTC_REG 5

#define TIMER_STAT_REG 0
#define TIMER_CTRL_REG 1
#define TIMER_PRDL_REG 2
#define TIMER_PRDH_REG 3
#define TIMER_SNPL_REG 4
#define TIMER_SNPH_REG 5
#define TO_CLK_CYCLES 10000	// 200 us
#define REQ_CLK_CYCLES 8000	// 160 us

#define FIFO_SIZE 4
static alt_u8 read_fifo[FIFO_SIZE];
static int head = 0;
static int tail = 0;

static alt_u16 wr_buf, rd_buf;
static int wr_num = 0;
static int rd_num = 0;

#define REQ_TO_SEND 12
#define START_BIT 11
#define PAR_BIT 2
#define STOP_BIT 1

// set both pins to input
#define PS2_HOST_IDL(ps2_base) \
	IOWR((ps2_base), PS2_DIRN_REG, 0x0)

// clk low, set clk pin to output
#define PS2_HOST_INH(ps2_base) \
	IOWR((ps2_base), PS2_DATA_REG, 0x0); \
	IOWR((ps2_base), PS2_DIRN_REG, 0x2)

// data low, set data pin to output
#define PS2_HOST_REQ(ps2_base) \
	IOWR((ps2_base), PS2_DATA_REG, 0x0); \
	IOWR((ps2_base), PS2_DIRN_REG, 0x1)

#define PS2_CLR_IRQ(ps2_base) \
	IOWR((ps2_base), PS2_EDGE_REG, 0x2)

// start timer, count once
#define TIMER_RST_IRQ(timer_base, to_clk_cycles) \
	IOWR((timer_base), TIMER_PRDL_REG, (to_clk_cycles) & 0xffff); \
	IOWR((timer_base), TIMER_PRDH_REG, ((to_clk_cycles) >> 16)); \
	IOWR((timer_base), TIMER_CTRL_REG, 0x5)

#define TIMER_STP_IRQ(timer_base) \
	IOWR((timer_base), TIMER_CTRL_REG, 0x8)

#define TIMER_CLR_IRQ(timer_base) \
	IOWR((timer_base), TIMER_STAT_REG, 0x0)

void ps2_timer_irq(void *context, alt_u32 id)
{
	ps2_ctxt *ctxt = (ps2_ctxt *) context;
	alt_u32 ps2_base = ctxt->ps2_base;
	alt_u32 ps2_timer_base = ctxt->ps2_timer_base;

	TIMER_CLR_IRQ(ps2_timer_base);	// clear timer interrupt

	if (wr_num == REQ_TO_SEND) {
		TIMER_RST_IRQ(ps2_timer_base, TO_CLK_CYCLES);
		PS2_HOST_REQ(ps2_base);
		wr_num--;
	}

	rd_num = 0;
}

void ps2_irq(void *context, alt_u32 id)
{
	ps2_ctxt *ctxt = (ps2_ctxt *) context;
	alt_u32 ps2_base = ctxt->ps2_base;
	alt_u32 ps2_timer_base = ctxt->ps2_timer_base;

	PS2_CLR_IRQ(ps2_base);
	TIMER_RST_IRQ(ps2_timer_base, TO_CLK_CYCLES);

	if (rd_num == 0 && wr_num == REQ_TO_SEND) {
		TIMER_RST_IRQ(ps2_timer_base, REQ_CLK_CYCLES);
	}
	else if (wr_num == PAR_BIT) {
		PS2_HOST_IDL(ps2_base);
		wr_num--;
	}
	else if (wr_num == STOP_BIT) {
		TIMER_STP_IRQ(ps2_timer_base);
		wr_num--;
	}
	else if (wr_num) {
		IOWR(ps2_base, PS2_DATA_REG, wr_buf & 0x1);
		wr_buf >>= 1;
		wr_num--;
	}
	else if (rd_num) {
		rd_buf >>= 1;
		rd_buf |= ((IORD(ps2_base, PS2_DATA_REG) & 0x1) << (START_BIT - PAR_BIT));
		rd_num--;

		if (rd_num == 0){
			TIMER_STP_IRQ(ps2_timer_base);
			rd_buf &= 0xff;

			int new_head = (head + 1) % FIFO_SIZE;
			if (new_head != tail) {
				read_fifo[head] = rd_buf;
				head = new_head;
			}

			if (wr_num == REQ_TO_SEND) {
				PS2_HOST_INH(ps2_base);
				TIMER_RST_IRQ(ps2_timer_base, REQ_CLK_CYCLES);
			}
		}
	}
	else {
		// receive start bit
		rd_num = START_BIT - 1;
	}
}

void ps2_init(alt_u32 ps2_base, alt_u32 ps2_timer_base)
{
	// enable ps2 clk irq
	IOWR(ps2_base, PS2_INTR_REG, 0x2);

	// empty read_fifo
	head = 0;
	tail = 0;

	// reset state
	wr_num = 0;
	rd_num = 0;

	PS2_HOST_IDL(ps2_base);
}

int ps2_tx_is_idle(alt_u32 ps2_base)
{
	return !wr_num;
}

void ps2_wr_cmd(alt_u32 ps2_base, alt_u8 cmd)
{
	wr_buf = cmd;

	alt_u16 wr_par = cmd;
	wr_par ^= (wr_par >> 4);
	wr_par ^= (wr_par >> 2);
	wr_par ^= (wr_par >> 1);
	wr_par ^= 0x1;
	wr_par &= 0x1;
	wr_buf |= wr_par << 8;

	wr_num = REQ_TO_SEND;

	if (!rd_num) {
		PS2_HOST_INH(ps2_base);
	}
}

int ps2_is_empty(alt_u32 ps2_base)
{
	return head == tail;
}

alt_u8 ps2_read_fifo(alt_u32 ps2_base)
{
	return read_fifo[tail];
}

void ps2_rm_pkt(alt_u32 ps2_base)
{
	tail = (tail + 1) % FIFO_SIZE;
}

int ps2_get_pkt(alt_u32 ps2_base, alt_u8 *byte)
{
	if (!ps2_is_empty(ps2_base)) {
		*byte = ps2_read_fifo(ps2_base);
		return 1;
	}
	return 0;
}

void ps2_flush_fifo(alt_u32 ps2_base)
{
	while (!ps2_is_empty(ps2_base)) {
		ps2_rm_pkt(ps2_base);
	}
}

int ps2_reset_device(alt_u32 ps2_base)
{
	alt_u8 packet;

	ps2_flush_fifo(ps2_base);

	/* send reset 0xff */
	ps2_wr_cmd(ps2_base, 0xff);
	usleep(500000);	// wait for 0.5 s
	
	/* check 0xfa 0xaa */
	if (ps2_get_pkt(ps2_base, &packet) == 0 || packet != 0xfa)
		return 0;	// no response or wrong response
	ps2_rm_pkt(ps2_base);
	if (ps2_get_pkt(ps2_base, &packet) == 0 || packet != 0xaa)
		return 0;	// no response or wrong response
	ps2_rm_pkt(ps2_base);

	/* check whether 0x00 received */
	if (ps2_get_pkt(ps2_base, &packet) == 0)
		return 1;	// fifo has no more packet, device is keyboard
	ps2_rm_pkt(ps2_base);

	if (packet == 0x00)
		return 2;	// mouse id
	else
		return 0;	// unknown device id
}

int kb_get_ch(alt_u32 ps2_base, char *ch)
{
	#define TAB		0x09
	#define BKSP	0X08
	#define ENTER	0x0d
	#define ESC		0x1b
	#define BKSL	0x5c
	#define SFT_L	0x12
	#define SFT_R 	0x59

	#define CAPS	0x80
	#define NUM		0x81
	#define CTRL_L	0x82
	#define F1		0xf0
	#define F2		0xf1
	#define F3		0xf2
	#define F4		0xf3
	#define F5		0xf4
	#define F6		0xf5
	#define F7		0xf6
	#define F8		0xf7
	#define F9		0xf8
	#define F10		0xf9
	#define F11		0xfa
	#define F12		0xfb
	
	// keyboard scan code to ascii (lowercase)
	static const char SCAN2ASCII_LO_TABLE[128] = {
	0,		F9,		0,		F5,		F3,		F1, 	F2,		F12,	//0
	0,		F10,	F8,		F6,		F4,		TAB,	'`',	0,		//08
	0,		0,		SFT_L,	0,		CTRL_L,	'q',	'1',	0,		//10
	0,		0,		'z',	's',	'a',	'w',	'2',	0,		//18
	0,		'c',	'x',	'd',	'e',	'4',	'3',	0,		//20
	0,		' ',	'v',	'f',	't',	'r',	'5',	0,		//28
	0,		'n',	'b',	'h',	'g',	'y',	'6',	0,		//30
	0,		0,		'm',	'j',	'u',	'7',	'8',	0,		//38
	0,		',',	'k',	'i',	'o',	'0',	'9',	0,		//40
	0,		'.',	'/',	'l',	';',	'p',	'-',	0,		//48
	0,		0,		'\'',	0,		'[',	'=',	0,		0,		//50
	CAPS,	SFT_R,	ENTER,	']',	0,		BKSL,	0,		0,		//58
	0,		0,		0,		0,		0,		0,		BKSP,	0,		//60
	0,		'1',	0,		'4',	'7',	0,		0,		0,		//68
	0,		'.',	'2',	'5',	'6',	'8',	ESC,	NUM,	//70
	F11,	'+',	'3',	'-',	'*',	'9',	0,		0		//78
	};
	// keyboard scan code to ascii (uppercase)
	static const char SCAN2ASCII_UP_TABLE[128] = {
	0,		F9,		0,		F5,		F3,		F1, 	F2,		F12,	//0
	0,		F10,	F8,		F6,		F4,		TAB,	'~',	0,		//08
	0,		0,		SFT_L,	0,		CTRL_L,	'Q',	'!',	0,		//10
	0,		0,		'Z',	'S',	'A',	'W',	'@',	0,		//18
	0,		'C',	'X',	'D',	'E',	'$',	'#',	0,		//20
	0,		' ',	'V',	'F',	'T',	'R',	'%',	0,		//28
	0,		'N',	'B',	'H',	'G',	'Y',	'^',	0,		//30
	0,		0,		'M',	'J',	'U',	'&',	'*',	0,		//38
	0,		'<',	'K',	'I',	'O',	')',	'(',	0,		//40
	0,		'>',	'?',	'L',	':',	'P',	'_',	0,		//48
	0,		0,		'\"',	0,		'{',	'+',	0,		0,		//50
	CAPS,	SFT_R,	ENTER,	'}',	0,		'|',	0,		0,		//58
	0,		0,		0,		0,		0,		0,		BKSP,	0,		//60
	0,		'1',	0,		'4',	'7',	0,		0,		0,		//68
	0,		'.',	'2',	'5',	'6',	'8',	ESC,	NUM,	//70
	F11,	'+',	'3',	'-',	'*',	'9',	0,		0		//78
	};

	static int sft_on = 0;
	alt_u8 scode;
	
	while (1) {
		if (!ps2_get_pkt(ps2_base, &scode))		// no packet
			return 0;
		ps2_rm_pkt(ps2_base);

		switch (scode) {
			case 0xf0:	// break code
				while (!ps2_get_pkt(ps2_base, &scode));	// get next
				ps2_rm_pkt(ps2_base);
				if (scode == SFT_L || scode == SFT_R)
					sft_on = 0;
				break;
			case SFT_L:
			case SFT_R:
				sft_on = 1;
				break;
			default:
				if (sft_on)
					*ch = SCAN2ASCII_UP_TABLE[scode];
				else
					*ch = SCAN2ASCII_LO_TABLE[scode];
				return 1;
		}
	}
}

int kb_get_line(alt_u32 ps2_base, char *s, int lim)
{
	char ch;
	int i;

	i = 0;
	while (1) {
		while (!kb_get_ch(ps2_base, &ch));
		if ((ch == '\n') | (i == (lim - 1)))
			break;
		else
			s[i++] = ch;
	}
	s[i] = '\0';
	return i;
}

int mouse_init(alt_u32 ps2_base)
{
	alt_u8 packet;

	if (ps2_reset_device(ps2_base) != 2)
		return 0;

	/* send stream mode command 0xf4 */
	ps2_wr_cmd(ps2_base, 0xf4);
	usleep(500000);	// wait 0.5s
	
	/* check 0xfa (acknowledge) */
	if (ps2_get_pkt(ps2_base, &packet) == 0 || packet != 0xfa)
		return 0;	// no response or wrong response
	ps2_rm_pkt(ps2_base);

	return 1;	// int complete
}

int mouse_get_activity(alt_u32 ps2_base, mouse_mv_type *mv)
{
	alt_u8 b1, b2, b3;
	alt_u32 tmp;

	/* check and retrieve 1st byte */
	if (!ps2_get_pkt(ps2_base, &b1))
		return 0;	// no data in rx buffer
	ps2_rm_pkt(ps2_base);

	/* double check 1st byte is valid */
	while(!(b1 & (0x1 << 3))) {
		ps2_get_pkt(ps2_base, &b1);
		ps2_rm_pkt(ps2_base);
	}

	/* wait and retrieve 2nd byte */
	while (!ps2_get_pkt(ps2_base, &b2));
	ps2_rm_pkt(ps2_base);

	/* wait and retrieve 3rd byte */
	while (!ps2_get_pkt(ps2_base, &b3));
	ps2_rm_pkt(ps2_base);

	/* extract button info */
	mv->lbtn = (int) (b1 & 0x01);		// extract bit 0
	mv->rbtn = (int) (b1 & 0x02) >> 1;	// extract bit 1

	/* extract x movement; manually convert 9-bit 2's comp to int */
	tmp = (alt_u32) b2;
	if (b1 & 0x10)						// check MSB (sign bit) of x movement
		tmp = tmp | 0xffffff00;			// manual sign-extension if negative
	mv->xmov = (int) tmp;				// data conversion

	/* extract y movement; manually convert 9-bit 2's comp to int */
	tmp = (alt_u32) b3;
	if (b1 & 0x20)						// check MSB (sign bit) of y movement
		tmp = tmp | 0xffffff00;			// manual sign-extension if negative
	mv->ymov = (int) tmp;				// data conversion

	return 1;
}
