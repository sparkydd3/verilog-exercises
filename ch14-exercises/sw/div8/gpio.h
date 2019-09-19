#include "alt_types.h"
#include "io.h"

#define PIO_DATA_REG_OFT 0	// data register address offset
#define PIO_DIRT_REG_OFT 1	// direction register address offset
#define PIO_INTM_REG_OFT 2	// interrupt mask register address offset
#define PIO_EDGE_REG_OFT 3	// edge capture register address offset
#define PIO_OSET_REG_OFT 4	// output port setting bits offset
#define PIO_OCLR_REG_OFT 5	// output port clearing bits offset

#define pio_read_lvl(base) IORD(base, PIO_DATA_REG_OFT)
#define pio_write(base, data) IOWR(base, PIO_DATA_REG_OFT, data)

#define pio_read_edg(base) IORD(base, PIO_EDGE_REG_OFT)
#define pio_clear_edg(base) IOWR(base, PIO_EDGE_REG_OFT, 0xffffffff)

#define pio_int_mask(base, mask) IOWR(base, PIO_INTM_REG_OFT, mask)

#define pio_set_output(base, data) IOWR(base, PIO_OSET_REG_OFT, data)
#define pio_clr_output(base, data) IOWR(base, PIO_OCLR_REG_OFT, data)

alt_u8 sseg_conv_hex(int hex);
void sseg_disp_ptn(alt_u32 base, alt_u8 *ptn);
