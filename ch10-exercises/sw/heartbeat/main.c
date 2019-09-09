#include "system.h"
#include "alt_types.h"
#include "io.h"

void sleep_forloop()
{
	int i;

	// assume each loop takes 400 ns
	for(i = 0; i < 612500; i++);
}

int main()
{
	int pos = 0;

	IOWR(HEX3_BASE, 0, 0x7f);
	IOWR(HEX2_BASE, 0, 0x7f);
	IOWR(HEX1_BASE, 0, 0x7f);
	IOWR(HEX0_BASE, 0, 0x7f);

	while (1) {
		pos = (pos == 4) ? 0 : pos + 1;

		switch (pos) {
			case 0:
				IOWR(HEX2_BASE, 0, 0x79);
				IOWR(HEX1_BASE, 0, 0x4f);
				break;
			
			case 1:
				IOWR(HEX2_BASE, 0, 0x4f);
				IOWR(HEX1_BASE, 0, 0x79);
				break;
			
			case 2:
				IOWR(HEX3_BASE, 0, 0x4f);
				IOWR(HEX2_BASE, 0, 0x7f);
				IOWR(HEX1_BASE, 0, 0x7f);
				IOWR(HEX0_BASE, 0, 0x79);
				break;

			case 3:
				IOWR(HEX3_BASE, 0, 0x7f);
				IOWR(HEX0_BASE, 0, 0x7f);
				break;
		}

		sleep_forloop();
	}
}
