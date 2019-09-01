module parking_lot_counter_top
	(
		input wire CLOCK_50,
		input wire [2:0] KEY,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);
	
	wire clk, reset, a, b;
	assign clk = CLOCK_50;
	assign reset = ~KEY[2];
	assign a = ~KEY[0];
	assign b = ~KEY[1];

	wire enter, exit;
	parking_lot_counter uut
		(.iCLK(clk), .iRESET(reset),
		 .iA(a), .iB(b),
		 .oENTER(enter), .oEXIT(exit), .oERROR());
	
	wire [15:0] count;
	counter #(.W(16)) cnt
		(.iCLK(clk), .iRESET(reset),
		 .iINC(enter), .iDEC(exit),
		 .oCNT(count));
	
	bin2sseg hex3
		(.iBIN(count[15:12]), .oSSEG(HEX3));
	bin2sseg hex2
		(.iBIN(count[11:8]), .oSSEG(HEX2));
	bin2sseg hex1
		(.iBIN(count[7:4]), .oSSEG(HEX1));
	bin2sseg hex0
		(.iBIN(count[3:0]), .oSSEG(HEX0));
endmodule
