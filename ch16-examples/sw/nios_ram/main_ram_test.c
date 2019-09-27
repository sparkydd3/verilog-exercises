#include <stdio.h>
#include <alt_types.h>
#include "system.h"

int check_mem(alt_u32 mem_base, int min, int max)
{
	int err, real_err;
	alt_u32 *pbase;					// pointer to the base address
	alt_u32 i;						// index used to generate data
	alt_u32 t_pattn = 0xfa30fa30;	// toggling pattern for data write

	pbase = (alt_u32 *) mem_base;
	err = 0;

	/* write entire test range */
	printf("Write started ...\n");
	for (i = min; i < (max - 3); i++) {
		pbase[i] = i ^ t_pattn;	// invert certain bits
	}

	/* inject 4 errors in the end */
	for (i = max - 3; i <= max; i++) {
		pbase[i] = i;
	}

	/* read back entire range */
	printf("Read back started ...\n");
	for (i = min; i <= max; i++) {
		if (pbase[i] != (i ^ t_pattn)) {
			err++;
			// printf("     Error at address %x: 0x%08x (0x%08x expected) \n",
			//		(int) i, (int) pbase[i], (int) i ^ t_pattn);
		}
	}

	real_err = err - 4;
	printf("Completed with %d actual errors.\n", real_err);
	return real_err;
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
