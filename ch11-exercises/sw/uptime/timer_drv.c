#include "timer_drv.h"

void timer_wr_prd(alt_u32 timer_base, alt_u32 prd)
{
	alt_u16 high, low;

	high = (alt_u16) (prd >> 16);
	low = (alt_u16) (prd & 0x0000ffff);

	IOWR(timer_base, TIMER_PRDH_REG_OFT, high);
	IOWR(timer_base, TIMER_PRDL_REG_OFT, low);
	
	/* configure timer to start, continous mode; enable interrupt */
	IOWR(timer_base, TIMER_CTRL_REG_OFT, 0x0007);
}
