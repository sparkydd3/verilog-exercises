PROJECT = default

all: build

build: $(PROJECT).sopcinfo 

%.sopcinfo: %.qsys
	qsys-generate.exe $^ -syn=VERILOG

clean:
	rm -rf $(PROJECT)/ *.html *.rpt *.sopcinfo *.cmp *.lck
