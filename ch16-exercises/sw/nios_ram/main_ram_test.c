#include <stdio.h>
#include <alt_types.h>
#include <sys/alt_timestamp.h>
#include "system.h"


void check_mem(alt_u32 mem_base, int min, int max)
{
	int err, real_err;
	alt_u32 time_start, time_end;
	alt_u32 *pbase;					// pointer to the base address
	alt_u32 i;						// index used to generate data
	alt_u32 t_pattn = 0xfa30fa30;

	pbase = (alt_u32 *) mem_base;
	err = 0;

	// write entire test range
	printf("Test started ...\n");

	alt_timestamp_start();
	time_start = alt_timestamp();
	for (i = min; i < (max - 3); i++) {
		pbase[i] = i ^ t_pattn;
	}

	for (i = max - 3; i <= max; i++) {
		pbase[i] = i;
	}

	for (i = min; i <= max; i++) {
		if (pbase[i] != (i ^ t_pattn)) err++;
	}
	time_end = alt_timestamp();

	real_err = err - 4;
	printf("Completed with %ld errors.\n", real_err);
	printf("Completed in %ld ms.\n",
			(time_end - time_start) / (alt_timestamp_freq() / 1000));
}

int main()
{
	printf("DE1 external SRAM/SDRAM test \n\n");
	printf("SRAM test: \n");
	check_mem(SRAM_BASE, 0, 0x0001ffff);	// 128K word address space

	printf("\n\nSDRAM test: \n");
	check_mem(SDRAM_BASE, 0, 0x001fffff);	// 2M word address space

	return 0;
}
