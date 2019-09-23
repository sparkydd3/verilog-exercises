#include <stdio.h>
#include "system.h"
#include "gpio.h"

/* register offset definitions */

#define SQ_PRD_REG_OFT 0
#define SQ_ENB_REG_OFT 1

#define PRD_CNT_REDY_OFT 30
#define PRD_CNT_STRT_OFT 30
#define PRD_CNT_DONE_OFT 31
#define PRD_CNT_RSLT_MSK 0x000fffff

#define DIV_DVND_REG_OFT 0
#define DIV_DVSR_REG_OFT 1
#define DIV_STRT_REG_OFT 2
#define DIV_QUOT_REG_OFT 3
#define DIV_REMN_REG_OFT 4
#define DIV_REDY_REG_OFT 5
#define DIV_DONE_REG_OFT 6

#define BIN2BCD_STRT_OFT 30
#define BIN2BCD_REDY_OFT 30
#define BIN2BCD_DONE_OFT 31
#define BIN2BCD_BIN_MSK 0x00003fff

/* main program */
int main()
{
	alt_u32 freq_test, prd_test, prd_meas, freq_meas;

	while (1) {
		IOWR(SQ_GEN_BASE, SQ_ENB_REG_OFT, 0);

		printf("Enter test frequency:");
		scanf("%d", &freq_test);
		prd_test = 50000000 / freq_test;
		
		/* start test sq wave generator */
		IOWR(SQ_GEN_BASE, SQ_PRD_REG_OFT, prd_test);
		IOWR(SQ_GEN_BASE, SQ_ENB_REG_OFT, 1);

		printf("Enter s to start test\n");
		while(getchar() != 's');

		/* wait until period counter is ready */
		while (!(IORD(PRD_CNT_BASE, 0) & (0x1 << PRD_CNT_REDY_OFT)));

		/* start measurement */
		IOWR(PRD_CNT_BASE, 0, (0x1 << PRD_CNT_STRT_OFT));

		/* wait for completion */
		while (!(IORD(PRD_CNT_BASE, 0) & (0x1 << PRD_CNT_DONE_OFT)));
		IOWR(PRD_CNT_BASE, 0, (0x1 << PRD_CNT_DONE_OFT));

		prd_meas = IORD(PRD_CNT_BASE, 0) & PRD_CNT_RSLT_MSK;

		/* wait until division circuit is ready */
		while (!(IORD(DIV_BASE, DIV_REDY_REG_OFT)));

		IOWR(DIV_BASE, DIV_DVND_REG_OFT, 1000000);
		IOWR(DIV_BASE, DIV_DVSR_REG_OFT, prd_meas);
		IOWR(DIV_BASE, DIV_STRT_REG_OFT, 1);

		/* wait for completion */
		while (!(IORD(DIV_BASE, DIV_DONE_REG_OFT)));
		IOWR(DIV_BASE, DIV_DONE_REG_OFT, 0);

		freq_meas = IORD(DIV_BASE, DIV_QUOT_REG_OFT);

		/* wait until bin2bcd circuit is ready */
		while (!(IORD(BIN2BCD_BASE, 0) & (0x1 << BIN2BCD_REDY_OFT)));
		IOWR(BIN2BCD_BASE, 0, (freq_meas & BIN2BCD_BIN_MSK) | (0x1 << BIN2BCD_STRT_OFT));

		/* wait for completion */
		while(!(IORD(BIN2BCD_BASE, 0) & (0x1 << BIN2BCD_DONE_OFT)));
		IOWR(BIN2BCD_BASE, 0, (0x1 << BIN2BCD_DONE_OFT));

		printf("Period measured: %u\n", prd_meas);
		printf("Frequency measured: %u hz\n\n", freq_meas);
	}
}
