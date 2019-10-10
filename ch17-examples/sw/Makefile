HARDWARE = nios
SRCS = $(patsubst %/,%,$(wildcard */))

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
		--script $(TCL_DIR)/bsp-set-defaults.tcl
		
clean:
	-$(foreach src,$(SRCS),$(MAKE) -C $(src) -e clean;)
	-$(foreach src,$(SRCS),rm $(src)/Makefile;)
	-$(foreach src,$(SRCS),rm $(src)/.cproject;)
	-$(foreach src,$(SRCS),rm $(src)/.project;)
	-rm -r $(HARDWARE)_bsp
	-rm -r .metadata
