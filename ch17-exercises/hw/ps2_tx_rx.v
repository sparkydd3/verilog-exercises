module ps2_tx_rx
	(
		input wire clk, reset,
		input wire wr_ps2, rd_ps2,
		input wire [7:0] ps2_tx_data,
		output wire [7:0] ps2_rx_data,
		output wire ps2_tx_idle, ps2_rx_valid,
		inout wire ps2d, ps2c
	);

	// signal declaration
	wire rx_idle, tx_idle, rx_done_tick, ps2c_tx;

	// body
	// instantiate ps2 transmitter
	ps2_tx ps2_tx_unit
		(.clk(clk), .reset(reset), .wr_ps2(wr_ps2),
		 .rx_idle(rx_idle), .din(ps2_tx_data), .ps2d(ps2d), .ps2c(ps2c),
		 .tx_idle(tx_idle), .tx_done_tick());
	// instantiate ps2 receiver
	ps2_rx ps2_rx_unit
		(.clk(clk), .reset(reset), .rx_en(tx_idle & ~rx_int),
		 .ps2d(ps2d), .ps2c(ps2c), .rx_idle(rx_idle),
		 .rx_done_tick(rx_done_tick), .dout(ps2_rx_data));

	reg rx_int;
	always @(posedge clk, posedge reset)
		if (reset)
			rx_int <= 1'b0;
		else
			rx_int <= (rd_ps2) ? 1'b0 :
			          (rx_done_tick) ? 1'b1 :
					   rx_int;

	// output
	assign ps2_tx_idle = tx_idle;
	assign ps2_rx_valid = rx_int;
	assign ps2c = (rx_int & tx_idle) ? 1'b0 : 1'bz;
endmodule
