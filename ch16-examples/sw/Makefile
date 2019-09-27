HARDWARE = nios_ram
SRCS = $(patsubst %/,%,$(wildcard */))

SETTINGS = \
	--set hal.enable_reduced_device_drivers 1 \
	--set hal.enable_small_c_library 1 

TCL_CMDS = "add_section_mapping .bss onchip_mem; \
	add_section_mapping .heap onchip_mem; \
	add_section_mapping .rodata onchip_mem; \
	add_section_mapping .rwdata onchip_mem; \
	add_section_mapping .stack onchip_mem; \
	add_section_mapping .text onchip_mem;"

TCL_DIR = C:/altera/13.0sp1/nios2eds/sdk2/bin

all: $(HARDWARE)_bsp/settings.bsp $(addsuffix /Makefile,$(SRCS))

%/Makefile:
	nios2-app-generate-makefile.exe \
		--bsp-dir $(HARDWARE)_bsp \
		--app-dir $* \
		--src-dir $* \
		--elf-name $*.elf \

$(HARDWARE)_bsp/settings.bsp: ../qsys/$(HARDWARE).sopcinfo
	nios2-bsp-create-settings.exe \
		--sopc ../qsys/$(HARDWARE).sopcinfo --jdi ../quartus/$(HARDWARE).jdi \
		--type hal \
		--bsp-dir $(HARDWARE)_bsp --settings $(HARDWARE)_bsp/settings.bsp \
		--script $(TCL_DIR)/bsp-set-defaults.tcl \
		$(SETTINGS) \
		--cmd $(TCL_CMDS)

clean:
	-$(foreach src,$(SRCS),$(MAKE) -C $(src) -e clean;)
	-$(foreach src,$(SRCS),rm $(src)/Makefile;)
	-$(foreach src,$(SRCS),rm $(src)/.cproject;)
	-$(foreach src,$(SRCS),rm $(src)/.project;)
	-rm -r $(HARDWARE)_bsp
	-rm -r .metadata
