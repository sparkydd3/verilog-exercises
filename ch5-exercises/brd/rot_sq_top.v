module rot_sq_top
	(
		input wire CLOCK_50,
		input wire [0:0] KEY,
		input wire [1:0] SW,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);

	wire clk, tick, reset, en, cw;
	assign clk = CLOCK_50;
	assign reset = ~KEY[0];
	assign en = tick & SW[0];
	assign cw = SW[1];

	// 0.5 sec tick generator
	localparam DVSR = 25000000;
	mod_m_counter #(.SIZE(DVSR)) tick_gen
		(.iCLK(clk), .iRESET(reset), .iEN(1'b1),
		 .oCNT(), .oTICK(tick));

	rot_sq rot_sq_unit
		(.iCLK(clk), .iRESET(reset),
		 .iCW(cw), .iEN(en),
		 .oSQ(),
		 .oSSEG3(HEX3), .oSSEG2(HEX2), .oSSEG1(HEX1), .oSSEG0(HEX0));
endmodule
