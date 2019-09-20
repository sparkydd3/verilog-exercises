QUAR_DIR = quartus
QSYS_DIR = qsys
SW_DIR = sw

export HARDWARE = nios_div2

all: build 

build: quartus/$(HARDWARE).sof
	$(MAKE) -C $(SW_DIR) -e all

$(QUAR_DIR)/$(HARDWARE).sof: $(QSYS_DIR)/$(HARDWARE).sopcinfo
	$(MAKE) -C $(QUAR_DIR) -e all

$(QSYS_DIR)/$(HARDWARE).sopcinfo:
	$(MAKE) -C $(QSYS_DIR) -e all

clean:
	$(MAKE) -C $(QSYS_DIR) -e clean
	$(MAKE) -C $(QUAR_DIR) -e clean
	$(MAKE) -C $(SW_DIR) -e clean

program:
	$(MAKE) -C $(QUAR_DIR) -e program
