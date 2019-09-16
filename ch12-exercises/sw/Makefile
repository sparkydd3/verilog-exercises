PROJECT = alarm

HARDWARE = nios2

SETTINGS = \
	--set hal.enable_reduced_device_drivers 1 \
	--set hal.enable_c_plus_plus 0 \
	--set hal.enable_exit 0 \
	
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
