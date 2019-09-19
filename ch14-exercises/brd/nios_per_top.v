module nios_per_top
	(
		input wire CLOCK_50,
		input wire [0:0] KEY,
		output wire [0:0] LEDR,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0,
		output wire [17:0] SRAM_ADDR,
		inout [15:0] SRAM_DQ,
		output SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
		output SRAM_LB_N, SRAM_UB_N
	);
	
	// signal declaration
	wire [31:0] sseg, bcd;
	
	wire [25:0] per_test;
	wire gen_en, sq;

	wire cnt_ready, cnt_start, cnt_done;
	wire [19:0] cnt_per;

	wire div_ready, div_start, div_done;
	wire [19:0] div_freq;

	wire bcd_ready, bcd_start, bcd_done;
	wire [3:0] bcd3, bcd2, bcd1, bcd0;

	// body
	// instantiate nios
	nios_per nios_cpu_unit
		(.clk_clk(CLOCK_50),
		 .reset_reset_n(KEY[0]),
		 .sram_sram_addr_addr(SRAM_ADDR),
		 .sram_sram_addr_ce_n(SRAM_CE_N),
		 .sram_sram_addr_dq(SRAM_DQ),
		 .sram_sram_addr_lb_n(SRAM_LB_N),
		 .sram_sram_addr_oe_n(SRAM_OE_N),
		 .sram_sram_addr_ub_n(SRAM_UB_N),
		 .sram_sram_addr_we_n(SRAM_WE_N),
		 .cmd_external_connection_export({gen_en, cnt_start, div_start, bcd_start}),
		 .sq_gen_external_connection_export(per_test),
		 .cnt_external_connection_export({cnt_done, cnt_ready, cnt_per}),
		 .div_external_connection_export({div_done, div_ready, div_freq}),
		 .bcd_external_connection_export({bcd_done, bcd_ready, bcd3, bcd2, bcd1, bcd0}),
		 .sseg_external_connection_export(sseg),
		);

	sq_gen #(.W(26)) test_gen (
		.iCLK(CLOCK_50), .iRESET(~KEY[0]),
		.iPER(per_test), .iEN(gen_en),
		.oSQ(sq));

	period_counter per_cnt (
		.iCLK(CLOCK_50), .iRESET(~KEY[0]),
		.iSTART(cnt_start), .iSIG(sq),
		.oREADY(cnt_ready), .oDONE(cnt_done),
		.oPRD(cnt_per));
	
	div #(.W(20)) div_unit (
		.iCLK(CLOCK_50), .iRESET(~KEY[0]),
		.iSTART(div_start),
		.iDVSR(cnt_per), .iDVND(20'd1000000),
		.oREADY(div_ready), .oDONE(div_done),
		.oQUO(div_freq), .oRMD());

	bin2bcd bcd_unit (
		.iCLK(CLOCK_50), .iRESET(~KEY[0]),
		.iSTART(bcd_start),
		.iBIN(div_freq[13:0]),
		.oREADY(bcd_ready), .oDONE(bcd_done),
		.oOFLOW(),
		.oBCD3(bcd3), .oBCD2(bcd2), .oBCD1(bcd1), .oBCD0(bcd0));

	assign HEX3 = sseg[30:24];
	assign HEX2 = sseg[22:16];
	assign HEX1 = sseg[14:8];
	assign HEX0 = sseg[6:0];
endmodule
