module avalon_bin2bcd
	(
		input wire clk, reset,
		input wire write,
		input wire [31:0] write_data,
		output wire [31:0] read_data,
		output wire irq,
		output wire [15:0] bcd
	);

	wire start, ready, done_tick, done_clr, oflow;
	reg done_reg;
	wire [3:0] bcd3, bcd2, bcd1, bcd0;

	bin2bcd bin2bcd_unit
		(.iCLK(clk), .iRESET(reset),
		 .iSTART(start),.iBIN(write_data[13:0]),
		 .oREADY(ready), .oDONE(done_tick), .oOFLOW(oflow),
		 .oBCD3(bcd3), .oBCD2(bcd2), .oBCD1(bcd1), .oBCD0(bcd0));

	always @(posedge clk, posedge reset)
		if (reset)
			done_reg <= 0;
		else
			if (done_tick)
				done_reg <= 1;
			else if (done_clr)
				done_reg <= 0;

	assign done_clr = (write & write_data[31]);
	assign start = (write & write_data[30]);

	assign read_data = {done_reg, ready, oflow, 13'bx, bcd3, bcd2, bcd1, bcd0};
	assign irq = done_reg;
	assign bcd = {bcd3, bcd2, bcd1, bcd0};
endmodule
