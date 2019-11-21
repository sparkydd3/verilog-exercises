create_clock -name "CLOCK_50" -period 20 [get_ports {CLOCK_50}]
derive_pll_clocks
derive_clock_uncertainty

create_clock -name SRAM_CLK -period 20

set_output_delay -clock SRAM_CLK -max 17 [get_ports SRAM_WE_N]
set_output_delay -clock SRAM_CLK -min 0 [get_ports SRAM_WE_N]

set_output_delay -clock SRAM_CLK -max 17 [get_ports SRAM_ADDR[*]]
set_output_delay -clock SRAM_CLK -min 0 [get_ports SRAM_ADDR[*]]

set_output_delay -clock SRAM_CLK -max 17 [get_ports SRAM_DQ[*]]
set_output_delay -clock SRAM_CLK -min 0 [get_ports SRAM_DQ[*]]
