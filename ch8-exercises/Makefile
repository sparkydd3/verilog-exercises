QDIR = quartus
MDIR = modelsim

export PROJECT = ch8-examples
export TOP = 
export TOP_TB = univ_bin_counter_tb

all: test build

.PHONY: test
test:
	$(MAKE) -C $(MDIR) -e all 

check:
	$(MAKE) -C $(MDIR) -e check

show:
	$(MAKE) -C $(MDIR) -e show

build:
	$(MAKE) -C $(QDIR) -e all

clean:
	$(MAKE) -C $(MDIR) -e clean
	$(MAKE) -C $(QDIR) -e clean

program:
	$(MAKE) -C $(QDIR) -e program
