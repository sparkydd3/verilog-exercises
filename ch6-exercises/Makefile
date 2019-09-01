QDIR = quartus
MDIR = modelsim

export PROJECT = ch5-exercises
export TOP = parking_lot_counter_top
export TOP_TB = parking_lot_counter_tb

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
