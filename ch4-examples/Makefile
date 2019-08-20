QDIR = quartus
MDIR = modelsim

export PROJECT = ch4-examples
export TOP = bin_to_sseg_test
export TOP_TB = fp_adder_tb

all: test build

.PHONY: test
test:
	$(MAKE) -C $(MDIR) -e all 

show:
	$(MAKE) -C $(MDIR) -e show

build:
	$(MAKE) -C $(QDIR) -e all

clean:
	$(MAKE) -C $(MDIR) -e clean
	$(MAKE) -C $(QDIR) -e clean

program:
	$(MAKE) -C $(QDIR) -e program
