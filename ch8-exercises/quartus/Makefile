# Project Configuration

PROJECT = default_project
TOP = default_top

SRCS = $(wildcard ../src/*.v)
SRCS += $(wildcard ../brd/*.v)

FAMILY = "Cyclone II"
DEVICE = EP2C20F484C7
BOARDFILE = ../brd/DE1Pins.qsf

# Main Targets

all: $(PROJECT).asm.rpt $(PROJECT).sta.rpt

init: $(PROJECT).qpf
map:  $(PROJECT).map.rpt
fit:  $(PROJECT).fit.rpt
asm:  $(PROJECT).asm.rpt
sta:  $(PROJECT).sta.rpt

program:
	quartus_pgm.exe -c USB-Blaster -m jtag -o "P;$(PROJECT).sof"

clean:
	rm -rf *.tcl *.pof *.sof *.pin *.qsf *.qpf
	rm -rf *.rpt *.summary *.done *.smsg db incremental_db *.cdf *.jdi *.qws

# Executable Configuration

MAP_ARGS = --read_settings_files=on
FIT_ARGS = --read_settings_files=on
ASM_ARGS =
STA_ARGS =

# Target Implementations

SGAN_CMD = set_global_assignment -name

$(PROJECT).tcl:
	$(file >$(PROJECT).tcl,project_new $(PROJECT) -overwrite)
	$(file >>$(PROJECT).tcl,$(SGAN_CMD) FAMILY $(FAMILY))
	$(file >>$(PROJECT).tcl,$(SGAN_CMD) DEVICE $(DEVICE))
	$(file >>$(PROJECT).tcl,$(SGAN_CMD) TOP_LEVEL_ENTITY $(TOP))
	$(foreach S, $(SRCS), $(file >>$(PROJECT).tcl,$(SGAN_CMD) VERILOG_FILE $S))
	-cat $(BOARDFILE) >> $(PROJECT).tcl

$(PROJECT).qsf: $(PROJECT).tcl
	quartus_sh.exe -t $(PROJECT).tcl

$(PROJECT).map.rpt: $(SRCS) $(PROJECT).qsf
	quartus_sh.exe --prepare -t $(TOP) $(PROJECT)
	quartus_map.exe $(MAP_ARGS) $(PROJECT)

$(PROJECT).fit.rpt: $(PROJECT).map.rpt
	quartus_fit.exe $(FIT_ARGS) $(PROJECT)

$(PROJECT).asm.rpt: $(PROJECT).fit.rpt
	quartus_asm.exe $(ASM_ARGS) $(PROJECT)

$(PROJECT).sta.rpt: $(PROJECT).fit.rpt
	quartus_sta.exe $(STA_ARGS) $(PROJECT)
