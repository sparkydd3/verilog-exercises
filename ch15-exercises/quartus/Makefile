# Project Configuration

HARDWARE = default
TOP = $(addsuffix _top,$(HARDWARE))

SRCS = $(wildcard ../hw/*.v)
SRCS += $(wildcard ../brd/*.v)

QIP = ../qsys/$(HARDWARE)/synthesis/$(HARDWARE).qip

FAMILY = "Cyclone II"
DEVICE = EP2C20F484C7
BOARDFILE = ../brd/DE1Pins.qsf

# Main Targets

all: $(HARDWARE).sof 

$(HARDWARE).sof: $(HARDWARE).asm.rpt $(HARDWARE).sta.rpt

init: $(HARDWARE).qsf
map:  $(HARDWARE).map.rpt
fit:  $(HARDWARE).fit.rpt
asm:  $(HARDWARE).asm.rpt
sta:  $(HARDWARE).sta.rpt

program: $(HARDWARE).sof
	quartus_pgm.exe -c USB-Blaster -m jtag -o "P;$(HARDWARE).sof"

clean:
	rm -rf *.tcl *.pof *.sof *.pin *.qsf *.qpf
	rm -rf *.rpt *.summary *.done *.smsg *.cdf *.jdi *.qws *.stp
	rm -rf db incremental_db

# Executable Configuration

MAP_ARGS = --read_settings_files=on
FIT_ARGS = --read_settings_files=on
ASM_ARGS =
STA_ARGS =

# Target Implementations

SGAN_CMD = set_global_assignment -name

$(HARDWARE).tcl:
	$(file >$(HARDWARE).tcl,project_new $(HARDWARE) -overwrite)
	$(file >>$(HARDWARE).tcl,$(SGAN_CMD) FAMILY $(FAMILY))
	$(file >>$(HARDWARE).tcl,$(SGAN_CMD) DEVICE $(DEVICE))
	$(file >>$(HARDWARE).tcl,$(SGAN_CMD) TOP_LEVEL_ENTITY $(TOP))
	$(foreach S, $(SRCS), $(file >>$(HARDWARE).tcl,$(SGAN_CMD) VERILOG_FILE $S))
	$(file >>$(HARDWARE).tcl,$(SGAN_CMD) QIP_FILE $(QIP))
	-cat $(BOARDFILE) >> $(HARDWARE).tcl

$(HARDWARE).qsf: $(HARDWARE).tcl
	quartus_sh.exe -t $(HARDWARE).tcl

$(HARDWARE).map.rpt: $(SRCS) $(HARDWARE).qsf
	quartus_sh.exe --prepare -t $(TOP) $(HARDWARE)
	quartus_map.exe $(MAP_ARGS) $(HARDWARE)

$(HARDWARE).fit.rpt: $(HARDWARE).map.rpt
	quartus_fit.exe $(FIT_ARGS) $(HARDWARE)

$(HARDWARE).asm.rpt: $(HARDWARE).fit.rpt
	quartus_asm.exe $(ASM_ARGS) $(HARDWARE)

$(HARDWARE).sta.rpt: $(HARDWARE).fit.rpt
	quartus_sta.exe $(STA_ARGS) $(HARDWARE)
