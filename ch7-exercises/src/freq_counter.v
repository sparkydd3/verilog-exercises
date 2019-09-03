module freq_counter
	(
		input wire iCLK, iRESET,
		input wire iSTART, iSIG,
		output wire [3:0] oBCD6, oBCD5, oBCD4, oBCD3, oBCD2, oBCD1, oBCD0,
		output wire [1:0] oDEC
	);

	// symbolic state declaration
	localparam [2:0]
		idle  = 3'b000,
		count = 3'b001,
		frq   = 3'b010,
		b2b   = 3'b011,
		shift = 3'b100;
	
	// signal declaration
	reg [1:0] state_reg, state_next;
	wire [19:0] prd;
	wire [19:0] dvsr, dvnd, quo;
	reg prd_start, div_start, b2b_start;
	wire [3:0] bcd6, bcd5, bcd4, bcd3, bcd2, bcd1, bcd0;
	reg [27:0] bcd_shift_reg, bcd_shift_next;
	reg [1:0] dec_reg, dec_next;
	wire prd_done_tick, div_done_tick, b2b_done_tick;
	//===============================================================
	// component instantiation
	//===============================================================
	// instantiate period counter
	period_counter prd_count_unit
		(.iCLK(iCLK), .iRESET(iRESET), .iSTART(prd_start), .iSIG(iSIG),
		 .oREADY(), .oDONE(prd_done_tick), .oPRD(prd));
	// instantiate division circuit
	div #(.W(20)) div_unit
		(.iCLK(iCLK), .iRESET(iRESET), .iSTART(div_start),
		 .iDVSR(dvsr), .iDVND(dvnd), .oQUO(quo), .oRMD(),
		 .oREADY(), .oDONE(div_done_tick));
	// instantiate binary-to-BCD converter
	bin2bcd_long b2b_unit
		(.iCLK(iCLK), .iRESET(iRESET), .iSTART(b2b_start),
		 .iBIN(quo), .oREADY(), .oDONE(b2b_done_tick),
		 .oBCD6(bcd6), .oBCD5(bcd5), .oBCD4(bcd4),
		 .oBCD3(bcd3), .oBCD2(bcd2), .oBCD1(bcd1), .oBCD0(bcd0));
	// signal width extension
	assign dvnd = 20'd1000000;
	assign dvsr = prd;
	//===============================================================
	// master FSM
	//===============================================================
	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				state_reg <= idle;
				bcd_shift_reg <= 0;
			end
		else
			begin
				state_reg <= state_next;
				bcd_shift_reg <= bcd_shift_next;
			end
	
	always @*
	begin
		state_next = state_reg;
		bcd_shift_next = bcd_shift_reg;
		dec_next = dec_reg;
		prd_start = 1'b0;
		div_start = 1'b0;
		b2b_start = 1'b0;
		case (state_reg)
			idle:
				begin
					if (iSTART)
						begin
							prd_start = 1'b1;
							state_next = count;
						end
				end
			count:
				if (prd_done_tick)
					begin
						div_start = 1'b1;
						state_next = frq;
					end
			frq:
				if (div_done_tick)
					begin
						b2b_start = 1'b1;
						state_next = b2b;
					end
			b2b:
				if (b2b_done_tick)
					begin
						state_next = shift;
						bcd_shift_next = {bcd6, bcd5, bcd4, bcd3, bcd2, bcd1, bcd0};
						dec_next = 2'd0;
					end
			shift:
				if (bcd_shift_reg[27:24] == 4'b0)
					begin
						bcd_shift_next = bcd_shift_reg << 4;
						dec_next = dec_reg + 1;
					end
				else
					begin
						state_next = idle;
					end
		endcase
	end

	assign oBCD3 = bcd_shift_reg[27:24];
	assign oBCD2 = bcd_shift_reg[23:20];
	assign oBCD1 = bcd_shift_reg[19:16];
	assign oBCD0 = bcd_shift_reg[15:12];
	assign oDEC = dec_reg;
endmodule
