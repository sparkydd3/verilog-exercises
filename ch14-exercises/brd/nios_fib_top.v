module nios_fib_top
	(
		input wire CLOCK_50,
		output wire [17:0] SRAM_ADDR,
		inout [15:0] SRAM_DQ,
		output SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
		output SRAM_LB_N, SRAM_UB_N
	);
	
	// signal declaration
	wire [63:0] fib;
	wire [7:0] in;
	wire start, ready, done;

	// body
	// instantiate nios
	nios_fib nios_cpu_unit
		(.clk_clk(CLOCK_50),
		 .reset_reset_n(1'b1),
		 .sram_sram_addr_addr(SRAM_ADDR),
		 .sram_sram_addr_ce_n(SRAM_CE_N),
		 .sram_sram_addr_dq(SRAM_DQ),
		 .sram_sram_addr_lb_n(SRAM_LB_N),
		 .sram_sram_addr_oe_n(SRAM_OE_N),
		 .sram_sram_addr_ub_n(SRAM_UB_N),
		 .sram_sram_addr_we_n(SRAM_WE_N),
		 .fib_in_external_connection_export(in),
		 .fib_out_u_external_connection_export(fib[63:32]),
		 .fib_out_l_external_connection_export(fib[31:0]),
		 .start_external_connection_export(start),
		 .ready_external_connection_export(ready),
		 .done_external_connection_export(done)
		);

	fib fib_unit (
		.iCLK(CLOCK_50), .iRESET(1'b0),
		.iSTART(start),
		.iI(in),
		.oREADY(ready), .oDONE(done),
		.oF(fib));
endmodule
