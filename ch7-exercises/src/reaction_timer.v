module reaction_timer
	(
		input wire iCLK, iRESET,
		input wire iSTART, iCLEAR, iSTOP,
		input wire [15:0] iSEED,
		output reg oLED,
		output reg [6:0] oSSEG3, oSSEG2, oSSEG1, oSSEG0
	);
	
	localparam [1:0]
		idle = 2'b00,
		pre  = 2'b01,
		post = 2'b10,
		stop = 2'b11;
	
	reg [1:0] state_reg, state_next;
	
	//==================================================================
	// ms timer
	//==================================================================
	wire ms_tick;
	reg ms_clear, ms_en;
	mod_m_counter #(.SIZE(50000)) ms_counter_unit
		(.iCLK(iCLK), .iRESET(iRESET),
		 .iCLEAR(ms_clear), .iEN(ms_en),
		 .oCNT(), .oTICK(ms_tick));

	//==================================================================
	// random interval generator
	//==================================================================
	wire [15:0] rand;
	reg rand_load, rand_en;
	rand rand_unit
		(.iCLK(iCLK), .iRESET(iRESET),
		 .iEN(rand_en), .iLOAD(rand_load),
		 .iSEED(iSEED),
		 .oRAND(rand));

	//==================================================================
	// pre state timer
	//==================================================================
	reg pre_clear, pre_en;
	wire [14:0] pre_cnt;
	mod_m_counter #(.SIZE(32000)) pre_counter_unit
		(.iCLK(iCLK), .iRESET(iRESET),
		 .iCLEAR(pre_clear), .iEN(pre_en),
		 .oCNT(pre_cnt), .oTICK());

	//==================================================================
	// reaction timer
	//==================================================================
	wire [3:0] bcd3, bcd2, bcd1, bcd0;
	wire [6:0] sseg3, sseg2, sseg1, sseg0;
	reg bcd_clear, bcd_en;
	bcd_counter bcd_counter_unit
		(.iCLK(iCLK), .iRESET(iRESET),
		 .iCLEAR(bcd_clear), .iEN(bcd_en),
		 .oBCD3(bcd3), .oBCD2(bcd2), .oBCD1(bcd1), .oBCD0(bcd0));
	bin2sseg sseg3_unit
		(.iBIN(bcd3), .oSSEG(sseg3));
	bin2sseg sseg2_unit
		(.iBIN(bcd2), .oSSEG(sseg2));
	bin2sseg sseg1_unit
		(.iBIN(bcd1), .oSSEG(sseg1));
	bin2sseg sseg0_unit
		(.iBIN(bcd0), .oSSEG(sseg0));

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			state_reg <= idle;
		else
			state_reg <= state_next;

	always @*
	begin
		state_next = state_reg;

		ms_clear = 1'b0;
		ms_en = 1'b0;
		
		rand_en = 1'b0;
		rand_load = 1'b0;

		pre_clear = 1'b0;
		pre_en = 1'b0;

		bcd_clear = 1'b0;
		bcd_en = 1'b0;

		oLED = 1'b0;

		case (state_reg)
			idle:
				begin
					oSSEG3 = 7'b1111111;
					oSSEG2 = 7'b1111111;
					oSSEG1 = 7'b0001001;
					oSSEG0 = 7'b1111001;
					
					if (iCLEAR)
						rand_load = 1'b1;
					else if (iSTART)
						begin
							ms_clear = 1'b1;
							pre_clear = 1'b1;
							bcd_clear = 1'b1;
							rand_en = 1'b1;
							state_next = pre;
						end
				end
			pre:
				begin
					oSSEG3 = 7'b1000000;
					oSSEG2 = 7'b1000000;
					oSSEG1 = 7'b1000000;
					oSSEG0 = 7'b1000000;
					ms_en = 1'b1;
					pre_en = (ms_tick) ? 1'b1 : 1'b0;
					
					if (iCLEAR)
						state_next = idle;
					else if (iSTOP)
						state_next = stop;
					else if (pre_cnt == {2'b0, rand[12:0]} + 15'd2000)
						begin
							ms_clear = 1'b1;
							state_next = post;
						end
				end
			post:
				begin
					oLED = 1'b1;
					oSSEG3 = sseg3;
					oSSEG2 = sseg1;
					oSSEG1 = sseg2;
					oSSEG0 = sseg0;
					ms_en = 1'b1;
					bcd_en = (ms_tick) ? 1'b1 : 1'b0;

					if (iCLEAR)
						state_next = idle;
					else if (iSTOP)
						state_next = stop;
					else if ({bcd3, bcd2, bcd1, bcd0} == {4'd1, 4'd0, 4'd0, 4'd0})
						state_next = stop;
				end
			stop:
				begin
					if ({bcd3, bcd2, bcd1, bcd0} == {4'd0, 4'd0, 4'd0, 4'd0})
						begin
							oSSEG3 = 7'b0010000;
							oSSEG2 = 7'b0010000;
							oSSEG1 = 7'b0010000;
							oSSEG0 = 7'b0010000;
						end
					else
						begin
							oSSEG3 = sseg3;	
							oSSEG2 = sseg2;	
							oSSEG1 = sseg1;	
							oSSEG0 = sseg0;	
						end
					
					if (iCLEAR)
						state_next = idle;
					else if (iSTART)
						begin
							ms_clear = 1'b1;
							pre_clear = 1'b1;
							bcd_clear = 1'b1;
							rand_en = 1'b1;
							state_next = pre;
						end
				end
			default: state_next = idle;
		endcase
	end
endmodule
