module rot_banner_top
	(
		input wire CLOCK_50,
		input wire [0:0] SW,
		input wire [0:0] KEY,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);

	wire clk, reset, dir, tick;
	assign clk = CLOCK_50;
	assign reset = ~KEY[0];
	assign dir = SW[0];

	// 0.5 sec tick
	localparam DVSR = 25000000;
	mod_m_counter #(.SIZE(DVSR)) tick_gen
		(.iCLK(clk), .iRESET(reset), .iEN(1'b1),
		 .oCNT(), .oTICK(tick));

	wire [3:0] bin3, bin2, bin1, bin0;
	rot_banner rot_banner_unit
		(.iCLK(clk), .iRESET(reset), .iEN(tick), .iDIR(dir),
		 .oBIN3(bin3), .oBIN2(bin2), .oBIN1(bin1), .oBIN0(bin0));

	bin2sseg_rom hex3
		(.iCLK(clk), .iBIN(bin3), .oSSEG(HEX3));
	bin2sseg_rom hex2
		(.iCLK(clk), .iBIN(bin2), .oSSEG(HEX2));
	bin2sseg_rom hex1
		(.iCLK(clk), .iBIN(bin1), .oSSEG(HEX1));
	bin2sseg_rom hex0
		(.iCLK(clk), .iBIN(bin0), .oSSEG(HEX0));
endmodule
