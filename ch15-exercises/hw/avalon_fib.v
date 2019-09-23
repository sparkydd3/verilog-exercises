module avalon_fib
	(
		input wire clk, reset,
		input wire [0:0] fib_address,
		input wire [7:0] fib_byteenable,
		input wire fib_chipselect,
		input wire fib_write,
		input wire [63:0] fib_writedata,
		output wire [63:0] fib_readdata
	);

	wire wr_en;
	wire [7:0] fib_in;
	wire fib_ready, fib_start, set_done, clr_done;
	wire [63:0] fib_out;
	reg done_reg;

	fib fib_unit
		(.iCLK(clk), .iRESET(reset),
	 	 .iIN(fib_in), .iSTART(fib_start),
	 	 .oREADY(fib_ready), .oDONE(set_done),
	 	 .oFIB(fib_out));

	always @(posedge clk, posedge reset)
		if (reset)
			done_reg <= 0;
		else
			if(set_done)
				done_reg <= 1;
			else if(clr_done)
				done_reg <= 0;

	assign wr_en = fib_write & fib_chipselect;
	assign fib_in = (wr_en & fib_address == 1'b0 & (&fib_byteenable[1:0])) ? fib_writedata[7:0] : 8'bx;
	assign fib_start = (wr_en & fib_address == 1'b0 & (&fib_byteenable[1:0]));
	assign clr_done = (wr_en & fib_address == 1'b0 & (&fib_byteenable[1:0]));

	assign fib_readdata = (fib_address == 1'b0) ? {62'bx, done_reg, fib_ready} : fib_out;
endmodule
