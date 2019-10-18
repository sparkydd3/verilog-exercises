create_clock -name "CLOCK_50" -period 20 [get_ports {CLOCK_50}]
derive_pll_clocks
derive_clock_uncertainty

set_output_delay -clock CLOCK_50 1 [get_ports SRAM_*]
