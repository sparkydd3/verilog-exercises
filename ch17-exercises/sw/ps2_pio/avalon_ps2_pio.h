#include <alt_types.h>

typedef struct
{
	int lbtn;	// left button
	int rbtn;	// right button
	int xmov;	// x-axis movement
	int ymov;	// y-axis movement
} mouse_mv_type;

/* PS2 functions */
typedef struct {
	alt_u32 ps2_base;
	alt_u32 ps2_timer_base;
} ps2_ctxt;

void ps2_init(alt_u32 ps2_base, alt_u32 usr_timer_base);
int ps2_tx_is_idle(alt_u32 ps2_base);
void ps2_wr_cmd(alt_u32 ps2_base, alt_u8 cmd);
int ps2_is_empty(alt_u32 ps2_base);
alt_u8 ps2_read_fifo(alt_u32 ps2_base);
void ps2_rm_pkt(alt_u32 ps2_base);
int ps2_get_pkt(alt_u32 ps2_base, alt_u8 *byte);
void ps2_flush_fifo(alt_u32 ps2_base);
int ps2_reset_device(alt_u32 ps2_base);

void ps2_irq(void *context, alt_u32 id);
void ps2_timer_irq(void *context, alt_u32 id);

/* Keyboard functions */
int kb_get_ch(alt_u32 ps2_base, char *ch);
int kb_get_line(alt_u32 ps2_base, char *s, int lim);

/* Mouse functions */
int mouse_init(alt_u32 ps2_base);
int mouse_get_activity(alt_u32 ps2_base, mouse_mv_type *mv);
