`include "assert.vh"
`timescale 1 ns / 1 ps

module fifo_dual_ram_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	localparam DATA_WIDTH = 4;
	localparam ADDR_WIDTH = 2;
	reg [2*DATA_WIDTH-1:0] wdata_i;
	reg wr_i, rd_i;
	reg [DATA_WIDTH-1:0] rdata_e;
	reg full_e, empty_e;
	wire [DATA_WIDTH-1:0] rdata_o;
	wire full_o, empty_o;

	fifo_dual_ram #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) uut
		(.iCLK(clk), .iRESET(reset),
		 .iWR(wr_i), .iRD(rd_i), .iWDATA(wdata_i),
		 .oFULL(full_o), .oEMPTY(empty_o), .oRDATA(rdata_o));

	// clock generator
	always begin
		clk = 1'b1;
		#(T/2);
		clk = 1'b0;
		#(T/2);
	end

	// watchdog circuit
	localparam T_WD = 5000 * 20;
	initial begin
		#(T_WD);
		`ASSERT((0), ("Watchdog expired: %0d ns", T_WD));		
	end

	// initial reset
	initial begin
		reset = 1'b1;
		#(3*T/2);
		reset = 1'b0;
	end

	// test vector generator
	localparam N = 36;
	integer clk_num;
	reg [15:0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/fifo_dual_ram_tb.tv", testvectors);
		{wdata_i, rdata_e, rd_i, wr_i, empty_e, full_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 1; clk_num < N; clk_num = clk_num + 1)
		begin
			@(posedge clk);
			`ASSERT(({rdata_e, empty_e, full_e} == {rdata_o, empty_o, full_o}), 
				("Test vector #%0d failed", clk_num - 1));

			{wdata_i, rdata_e, rd_i, wr_i, empty_e, full_e} = testvectors[clk_num];
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
