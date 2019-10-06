HARDWARE = default

all: build

build: $(HARDWARE).sopcinfo 

%.sopcinfo: %.qsys
	qsys-generate.exe $^ -syn=VERILOG

clean:
	rm -rf $(HARDWARE)/ *.html *.rpt *.sopcinfo *.cmp *.lck *.bsf
