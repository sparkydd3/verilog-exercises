module bin2bcd_long
	(
		input wire iCLK, iRESET,
		input wire iSTART,
		input wire [19:0] iBIN,
		output reg oREADY, oDONE,
		output wire [3:0] oBCD6, oBCD5, oBCD4, 
			oBCD3, oBCD2, oBCD1, oBCD0
	);
	
	// symbolic state declaration
	localparam [1:0]
		idle = 2'b00,
		op   = 2'b01,
		done = 2'b10;
	
	// signal declaration
	reg [1:0] state_reg, state_next;
	reg [19:0] p2s_reg, p2s_next;
	reg [4:0] n_reg, n_next;
	reg [3:0] bcd6_reg, bcd5_reg, bcd4_reg,
		bcd3_reg, bcd2_reg, bcd1_reg, bcd0_reg;
	reg [3:0] bcd6_next, bcd5_next, bcd4_next,
		bcd3_next, bcd2_next, bcd1_next, bcd0_next;
	wire [3:0] bcd6_tmp, bcd5_tmp, bcd4_tmp, 
		bcd3_tmp, bcd2_tmp, bcd1_tmp, bcd0_tmp;
	reg overflow_reg, overflow_next;

	// body
	// FSMD state and data registers
	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				state_reg <= idle;
				p2s_reg <= 0;
				n_reg <= 0;
				bcd6_reg <= 0;
				bcd5_reg <= 0;
				bcd4_reg <= 0;
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
				bcd6_reg <= bcd6_next;
				bcd5_reg <= bcd5_next;
				bcd4_reg <= bcd4_next;
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

		p2s_next = p2s_reg;
		bcd0_next = bcd0_reg;
		bcd1_next = bcd1_reg;
		bcd2_next = bcd2_reg;
		bcd3_next = bcd3_reg;
		bcd4_next = bcd4_reg;
		bcd5_next = bcd5_reg;
		bcd6_next = bcd6_reg;
		n_next = n_reg;
		state_next = state_reg;
		overflow_next = overflow_reg;

		case (state_reg)
			idle:
				begin
					oREADY = 1'b1;
					if (iSTART)
						begin
							bcd6_next = 0;
							bcd5_next = 0;
							bcd4_next = 0;
							bcd3_next = 0;
							bcd2_next = 0;
							bcd1_next = 0;
							bcd0_next = 0;
							n_next = 5'd20;			// index
							p2s_next = iBIN;		// shift register
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
					bcd4_next = {bcd4_tmp[2:0], bcd3_tmp[3]};
					bcd5_next = {bcd5_tmp[2:0], bcd4_tmp[3]};
					bcd6_next = {bcd6_tmp[2:0], bcd5_tmp[3]};
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
	assign bcd4_tmp = (bcd4_reg > 4) ? bcd4_reg + 3 : bcd4_reg;
	assign bcd5_tmp = (bcd5_reg > 4) ? bcd5_reg + 3 : bcd5_reg;
	assign bcd6_tmp = (bcd6_reg > 4) ? bcd6_reg + 3 : bcd6_reg;

	// output
	assign oBCD0 = bcd0_reg;
	assign oBCD1 = bcd1_reg;
	assign oBCD2 = bcd2_reg;
	assign oBCD3 = bcd3_reg;
	assign oBCD4 = bcd4_reg;
	assign oBCD5 = bcd5_reg;
	assign oBCD6 = bcd6_reg;
endmodule
