module avalon_ps2_int
	(
		input wire clk, reset,
		// avalon-MM slave interface
		input wire [0:0] ps2_address,
		input wire ps2_chipselect, ps2_write,
		input wire [31:0] ps2_writedata,
		output wire irq,
		output wire [31:0] ps2_readdata,
		// conduit to/from PS2 port
		inout ps2d, ps2c
	);

	// signal declaration
	wire [7:0] ps2_rx_data;
	wire rd_ps2, ps2_rx_valid;
	wire wr_ps2, ps2_tx_idle;

	// body
	//===============================================================
	// instantiate PS2 controller
	//===============================================================
	ps2_tx_rx ps2_unit
		(.clk(clk), .reset(reset), .wr_ps2(wr_ps2),
		 .rd_ps2(rd_ps2), .ps2_tx_data(ps2_writedata[7:0]),
		 .ps2_rx_data(ps2_rx_data), .ps2_tx_idle(ps2_tx_idle),
		 .ps2_rx_valid(ps2_rx_valid),
		 .ps2d(ps2d), .ps2c(ps2c));

	//===============================================================
	// decoding and read multiplexing
	//===============================================================
	// read data and clear interrupt
	assign rd_ps2 = ps2_chipselect & (ps2_address == 1'b0);
	// write data to PS2 transmitting subsystem
	assign wr_ps2 = ps2_chipselect & (ps2_address == 1'b0) & ps2_write;
	// read data multiplexing
	assign ps2_readdata = (ps2_address == 1'b0) ?
	                      {24'b0, ps2_rx_data} :
						  {30'b0, ps2_tx_idle, ps2_rx_valid};
	// irq
	assign irq = ps2_rx_valid;
endmodule
