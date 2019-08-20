QDIR = quartus
MDIR = modelsim

export PROJECT = ch3-examples
export TOP = eq2_top
export TOP_TB = eq1_tb

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
