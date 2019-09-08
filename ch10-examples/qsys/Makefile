all: build

build: $(PROJECT).sopcinfo 

%.sopcinfo: %.qsys
	qsys-generate.exe $^ -syn=VERILOG

clean:
	rm -rf */ *.html *.rpt *.sopcinfo *.cmp
