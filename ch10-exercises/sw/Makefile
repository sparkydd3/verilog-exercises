PROJECT = nios_led1
TCL_DIR = C:/altera/13.0sp1/nios2eds/sdk2/bin
SRC = $(wildcard $(PROJECT)/*.c)

all: $(PROJECT)_bsp/settings.bsp $(SRC) $(PROJECT)/Makefile

$(PROJECT)/Makefile:
	nios2-app-generate-makefile.exe \
		--bsp-dir $(PROJECT)_bsp \
		--app-dir $(PROJECT) \
		--src-dir $(PROJECT) \
		--elf-name $(PROJECT).elf \

$(PROJECT)_bsp/settings.bsp: ../qsys/$(PROJECT).sopcinfo
	nios2-bsp-create-settings.exe \
		--sopc ../qsys/$(PROJECT).sopcinfo --jdi ../quartus/$(PROJECT).jdi \
		--type hal \
		--bsp-dir $(PROJECT)_bsp --settings $(PROJECT)_bsp/settings.bsp \
		--script $(TCL_DIR)/bsp-set-defaults.tcl

clean:
ifneq ($(wildcard $(PROJECT)/Makefile),)
	$(MAKE) -C $(PROJECT) clean
	rm $(PROJECT)/Makefile
endif
	rm -rf *_bsp/
