// 106 logic elements used

module fib_des2_top
	(
		input wire CLOCK_50,
		input wire [17:0] GPIO_0,
		output wire [18:0] GPIO_1
	);

	wire [3:0] bcd3_i, bcd2_i, bcd1_i, bcd0_i;
	wire [3:0] bcd3_o, bcd2_o, bcd1_o, bcd0_o;
	wire clk, reset, start;
	wire ready, done, overflow;

	assign clk = CLOCK_50;
	assign reset = GPIO_0[17];
	assign start = GPIO_0[16];
	assign {bcd3_i, bcd2_i, bcd1_i, bcd0_i} = GPIO_0[15:0];
	assign GPIO_1[18] = ready;
	assign GPIO_1[17] = done;
	assign GPIO_1[16] = overflow;
	assign GPIO_1[15:0] = {bcd3_o, bcd2_o, bcd1_o, bcd0_o}; 

	fib_des2 uut
		(.iCLK(clk), .iRESET(reset),
		 .iSTART(start),
		 .iBCD3(bcd3_i), .iBCD2(bcd2_i), .iBCD1(bcd1_i), .iBCD0(bcd0_i),
		 .oDONE(done), .oREADY(ready), .oOFLOW(overflow),
		 .oBCD3(bcd3_o), .oBCD2(bcd2_o), .oBCD1(bcd1_o), .oBCD0(bcd0_o));
endmodule
