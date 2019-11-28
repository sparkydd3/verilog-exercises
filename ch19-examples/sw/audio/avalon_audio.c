#include <io.h>
#include "avalon_audio.h"

int audio_i2c_is_idle(alt_u32 audio_base)
{
	alt_u32 status_reg;
	int i2c_idle_bit;

	status_reg = IORD(audio_base, AUD_STATUS_REG);
	i2c_idle_bit = (int) (status_reg & 0x00000001);
	return i2c_idle_bit;
}

void audio_i2c_wr_cmd(alt_u32 audio_base, alt_u8 addr, alt_u16 cmd)
{
	const alt_u32 i2c_id = 0x00000034;
	alt_u32 packet;		// data written to I2C; only 24 LSBs used

	packet = i2c_id;
	packet = (packet << 7) + (addr & 0x07f);	// append 7-bit address
	packet = (packet << 9) + (cmd & 0x01ff);	// append 9-bit command
	IOWR(audio_base, AUD_I2C_DATA_REG, (alt_u32) packet);
}

void audio_init(alt_u32 audio_base)
{
	// initial configuration values (registers R0 to R9)
	const alt_u16 cmds[10] = {	// only 9 LSBs used
		0x0017,		// R0: left line in gain 0 dB
		0x0017,		// R1: right line in gain 0 dB
		0x0079,		// R2: left headphone volume 0 dB
		0x0079,		// R3: right headphone volume 0 dB
		0x0010,		// R4: analog path select: line-in to adc, dac to line-out
		0x0000,		// R5: digital audio: high-pass filter, no de-emphasis
		0x0000,		// R6: enable all power
		0x0001,		// R7: digital interface: left-adjust, 16-bit resolution
		0x0000,		// R8: 48K sampling rate with 12.288 MHz master clock
		0x0001		// R9: activate
	};

	while (!audio_i2c_is_idle(audio_base));			// wait until I2C idle

	// write a dummy data to R15 to reset the codec
	audio_i2c_wr_cmd(audio_base, 15, 0);

	// cycle through 10 commands
	int i;
	for (i = 0; i < 10; i++) {
		while (!audio_i2c_is_idle(audio_base));		// wait until I2C idle
		audio_i2c_wr_cmd(audio_base, i, cmds[i]);	// send a command packet
	}

	audio_wr_src_sel(audio_base, 0, 0);				// dac/adc to Avalon bus
}

void audio_wr_src_sel(alt_u32 audio_base, int dac_sel, int adc_sel)
{
	alt_u32 sel_reg = 0x00000000;

	if (dac_sel != 0)
		sel_reg = sel_reg | 0x00000001;				// set LSB to 1
	if (adc_sel != 0)
		sel_reg = sel_reg | 0x00000002;				// set 2nd LSB to 1
	IOWR(audio_base, AUD_DBUS_SEL_REG, sel_reg);
}

int audio_dac_fifo_full(alt_u32 audio_base)
{
	alt_u32 status_reg;
	int dac_full_bit;

	status_reg = IORD(audio_base, AUD_STATUS_REG);
	dac_full_bit = (int)((status_reg & 0x00000002) >> 1);
	return dac_full_bit;
}

void audio_dac_wr_fifo(alt_u32 audio_base, alt_u32 data)
{
	IOWR(audio_base, AUD_DAC_DATA_REG, data);
}

int audio_adc_fifo_empty(alt_u32 audio_base)
{
	alt_u32 status_reg;
	int adc_empty_bit;

	status_reg = IORD(audio_base, AUD_STATUS_REG);
	adc_empty_bit = (int)((status_reg & 0x00000004) >> 2);
	return adc_empty_bit;
}

alt_u32 audio_adc_rd_fifo(alt_u32 audio_base)
{
	alt_u32 data_reg;

	data_reg = IORD(audio_base, AUD_ADC_DATA_REG);
	return data_reg;
}
