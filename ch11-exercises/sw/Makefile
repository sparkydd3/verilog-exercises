PROJECT = reaction_keyboard

HARDWARE = nios2
SETTINGS = --set altera_avalon_jtag_uart_driver.enable_small_driver 1
TCL_DIR = C:/altera/13.0sp1/nios2eds/sdk2/bin
SRC = $(wildcard $(PROJECT)/*.c)

all: $(HARDWARE)_bsp/settings.bsp $(SRC) $(PROJECT)/Makefile

$(PROJECT)/Makefile:
	nios2-app-generate-makefile.exe \
		--bsp-dir $(HARDWARE)_bsp \
		--app-dir $(PROJECT) \
		--src-dir $(PROJECT) \
		--elf-name $(PROJECT).elf \

$(HARDWARE)_bsp/settings.bsp: ../qsys/$(HARDWARE).sopcinfo
	nios2-bsp-create-settings.exe \
		--sopc ../qsys/$(HARDWARE).sopcinfo --jdi ../quartus/$(HARDWARE).jdi \
		--type hal \
		--bsp-dir $(HARDWARE)_bsp --settings $(HARDWARE)_bsp/settings.bsp \
		--script $(TCL_DIR)/bsp-set-defaults.tcl \
		$(SETTINGS)

clean:
ifneq ($(wildcard $(PROJECT)/Makefile),)
	$(MAKE) -C $(PROJECT) clean
	-rm $(PROJECT)/Makefile
endif
