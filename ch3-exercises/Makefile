QDIR = quartus
MDIR = modelsim

export PROJECT = ch3-exercises
export TOP = dec3to8_top
export TOP_TB = dec4to16_tb

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
