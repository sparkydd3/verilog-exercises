#include <stdio.h>
#include "alt_types.h"
#include "system.h"
#include "avalon_ps2_en_kb.h"

void sys_init(alt_u32 ps2_base)
{
	ps2_reset_device(ps2_base);
}

int main()
{
	char ch;
	sys_init(PS2_BASE);

	while (1) {
		while(!kb_get_ch(PS2_BASE, &ch));
		printf("%c", ch);
	}
}
