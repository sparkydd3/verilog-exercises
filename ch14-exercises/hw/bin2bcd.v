module bin2bcd
	(
		input wire iCLK, iRESET,
		input wire iSTART,
		input wire [13:0] iBIN,
		output reg oREADY, oDONE, oOFLOW,
		output wire [3:0] oBCD3, oBCD2, oBCD1, oBCD0
	);
	
	// symbolic state declaration
	localparam [1:0]
		idle = 2'b00,
		op   = 2'b01,
		done = 2'b10;
	
	// signal declaration
	reg [1:0] state_reg, state_next;
	reg [13:0] p2s_reg, p2s_next;
	reg [3:0] n_reg, n_next;
	reg [3:0] bcd3_reg, bcd2_reg, bcd1_reg, bcd0_reg;
	reg [3:0] bcd3_next, bcd2_next, bcd1_next, bcd0_next;
	wire [3:0] bcd3_tmp, bcd2_tmp, bcd1_tmp, bcd0_tmp;
	reg overflow_reg, overflow_next;

	// body
	// FSMD state and data registers
	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				state_reg <= idle;
				p2s_reg <= 0;
				n_reg <= 0;
				bcd3_reg <= 0;
				bcd2_reg <= 0;
				bcd1_reg <= 0;
				bcd0_reg <= 0;
				overflow_reg <= 0;
			end
		else
			begin
				state_reg <= state_next;
				p2s_reg <= p2s_next;
				n_reg <= n_next;
				bcd3_reg <= bcd3_next;
				bcd2_reg <= bcd2_next;
				bcd1_reg <= bcd1_next;
				bcd0_reg <= bcd0_next;
				overflow_reg <= overflow_next;
			end
	
	// FSMD next-state logic
	always @*
	begin
		oREADY = 1'b0;
		oDONE = 1'b0;
		oOFLOW = overflow_reg;

		p2s_next = p2s_reg;
		bcd0_next = bcd0_reg;
		bcd1_next = bcd1_reg;
		bcd2_next = bcd2_reg;
		bcd3_next = bcd3_reg;
		n_next = n_reg;
		state_next = state_reg;
		overflow_next = overflow_reg;

		case (state_reg)
			idle:
				begin
					oREADY = 1'b1;
					if (iSTART)
						if (iBIN > 14'd9999)
							begin
								bcd3_next = 9;
								bcd2_next = 9;
								bcd1_next = 9;
								bcd0_next = 9;
								overflow_next = 1'b1;
								state_next = done;
							end
						else
							begin
								bcd3_next = 0;
								bcd2_next = 0;
								bcd1_next = 0;
								bcd0_next = 0;
								n_next = 4'd14;			// index
								p2s_next = iBIN;		// shift register
								overflow_next = 1'b0;
								state_next = op;
							end
				end
			op:
				begin
					// shift in iBINary bit
					p2s_next = p2s_reg << 1;
					// shift 4 BCD digits
					//{bcd3_next, bcd2_next, bcd1_next, bcd0_next}=
					//{bcd3_temp[2:0], bcd2_tmp, bcd1_tmp, bcd0_tmp,
					// p2s_reg[12]}

					bcd0_next = {bcd0_tmp[2:0], p2s_reg[13]};
					bcd1_next = {bcd1_tmp[2:0], bcd0_tmp[3]};
					bcd2_next = {bcd2_tmp[2:0], bcd1_tmp[3]};
					bcd3_next = {bcd3_tmp[2:0], bcd2_tmp[3]};
					n_next = n_reg - 1;
					if (n_next == 0)
						state_next = done;
				end
			done:
				begin
					oDONE = 1'b1;
					state_next = idle;
				end
			default: state_next = idle;
		endcase
	end

	// data path function units
	assign bcd0_tmp = (bcd0_reg > 4) ? bcd0_reg + 3 : bcd0_reg;
	assign bcd1_tmp = (bcd1_reg > 4) ? bcd1_reg + 3 : bcd1_reg;
	assign bcd2_tmp = (bcd2_reg > 4) ? bcd2_reg + 3 : bcd2_reg;
	assign bcd3_tmp = (bcd3_reg > 4) ? bcd3_reg + 3 : bcd3_reg;

	// output
	assign oBCD0 = bcd0_reg;
	assign oBCD1 = bcd1_reg;
	assign oBCD2 = bcd2_reg;
	assign oBCD3 = bcd3_reg;
endmodule
