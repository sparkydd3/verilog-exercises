module freq_counter_top
	(
		input wire CLOCK_50,
		input wire [0:0] GPIO_0,
		input wire [1:0] KEY,
		output wire [2:0] LEDR,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);

	wire [3:0] bcd3, bcd2, bcd1, bcd0;
	wire [1:0] dec;

	freq_counter uut
		(.iCLK(CLOCK_50), .iRESET(~KEY[0]),
		 .iSTART(~KEY[1]), .iSIG(GPIO_0[0]),
		 .oBCD3(bcd3), .oBCD2(bcd2), .oBCD1(bcd1), .oBCD0(bcd0),
		 .oDEC(dec));
	
	bin2sseg bcd3_unit
		(.iBIN(bcd3), .oSSEG(HEX3));
	bin2sseg bcd2_unit
		(.iBIN(bcd2), .oSSEG(HEX2));
	bin2sseg bcd1_unit
		(.iBIN(bcd1), .oSSEG(HEX1));
	bin2sseg bcd0_unit
		(.iBIN(bcd0), .oSSEG(HEX0));

	assign LEDR = (dec == 2'b01) ? 3'b001 :
				  (dec == 2'b10) ? 3'b010 :
				  (dec == 2'b11) ? 3'b111 :
				                   3'b000 ;
endmodule
