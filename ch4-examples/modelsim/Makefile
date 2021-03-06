SRCS = $(wildcard ../src/*.v)
TEST_SRCS = $(wildcard ../test/*.v)
TVS = $(wildcard ../test/tv/*.tv)

SRC_DIRS = $(patsubst ../src/%.v,src/%,$(SRCS))
TEST_DIRS = $(patsubst ../test/%.v,test/%,$(TEST_SRCS))
TEST_WLFS = $(patsubst ../test/%.v,%.wlf,$(TEST_SRCS))
TEST_LOGS = $(patsubst ../test/%.v,%.log,$(TEST_SRCS))

all: $(TEST_LOGS)

check: $(SRC_DIRS) $(TEST_DIRS)

show: $(TOP_TB).wlf
	vsim.exe -view $(TOP_TB).wlf -do \
	"add wave -color white    clk;\
	 add wave -color white    reset;\
	 add wave -color green    *_i;\
	 add wave -color yellow   *_e;\
	 add wave -color red      *_o;\
	 wave zoom full;\
	 config wave -signalnamewidth 1;"

%.log: %.wlf
	$(if $(shell grep 'Error' $@), $(error "Test $(basename $@) failed."))

%.wlf: $(SRC_DIRS) test/% ../test/tv/%.tv
	vsim.exe -c -wlf $(basename $@).wlf -L src test.$(basename $@) -do \
	"add wave reset clk *_i *_o *_e;\
	 run -all;\
	 quit;" | tee $(patsubst %.wlf,%.log,$@)

.PRECIOUS: src/%
src/%: ../src/%.v | src
	vlog.exe $(patsubst src/%,../src/%.v,$@) -work src +incdir+../src

.PRECIOUS: test/%
test/%: ../test/%.v | test
	vlog.exe $(patsubst test/%,../test/%.v,$@) -work test -y src +incdir+../test

src:
	vlib.exe src

test:
	vlib.exe test

clean:
	rm -rf *.log *.mti *.mpf modelsim.ini transcript src test *.wlf *.chg
