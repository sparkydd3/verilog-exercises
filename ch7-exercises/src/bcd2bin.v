module bcd2bin
	(
		input wire iCLK, iRESET, iSTART,
		input wire [3:0] iBCD3, iBCD2, iBCD1, iBCD0,
		output reg oREADY, oDONE,
		output wire [13:0] oBIN
	);

	localparam [1:0]
		idle = 2'b00,
		op   = 2'b01,
		done = 2'b10;
	
	reg [1:0] state_reg, state_next;
	reg [13:0] bin_reg, bin_next;
	reg [3:0] n_reg, n_next;
	reg [3:0] bcd3_reg, bcd2_reg, bcd1_reg, bcd0_reg;
	reg [3:0] bcd3_next, bcd2_next, bcd1_next, bcd0_next;
	wire [3:0] bcd3_tmp, bcd2_tmp, bcd1_tmp, bcd0_tmp;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				state_reg <= idle;
				bin_reg <= 0;
				n_reg <= 0;
				bcd3_reg <= 0;
				bcd2_reg <= 0;
				bcd1_reg <= 0;
				bcd0_reg <= 0;
			end
		else
			begin
				state_reg <= state_next;
				bin_reg <= bin_next;
				n_reg <= n_next;
				bcd3_reg <= bcd3_next;
				bcd2_reg <= bcd2_next;
				bcd1_reg <= bcd1_next;
				bcd0_reg <= bcd0_next;
			end
	
	always @*
	begin
		state_next = state_reg;
		oREADY = 1'b0;
		oDONE = 1'b0;
		bin_next = bin_reg;
		bcd3_next = bcd3_reg;
		bcd2_next = bcd2_reg;
		bcd1_next = bcd1_reg;
		bcd0_next = bcd0_reg;
		case (state_reg)
			idle:
				begin
					oREADY = 1'b1;
					if (iSTART)
						begin
							state_next = op;
							bcd3_next = iBCD3;
							bcd2_next = iBCD2;
							bcd1_next = iBCD1;
							bcd0_next = iBCD0;
							n_next = 4'd14;
							bin_next = 0;
						end
				end
			op:
				begin
					bin_next = {bcd0_reg[0], bin_reg[13:1]};
					bcd0_next = (bcd0_tmp > 7) ? bcd0_tmp - 3 : bcd0_tmp; 
					bcd1_next = (bcd1_tmp > 7) ? bcd1_tmp - 3 : bcd1_tmp; 
					bcd2_next = (bcd2_tmp > 7) ? bcd2_tmp - 3 : bcd2_tmp; 
					bcd3_next = bcd3_tmp; 
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

	assign bcd0_tmp = {bcd1_reg[0], bcd0_reg[3:1]}; 
	assign bcd1_tmp = {bcd2_reg[0], bcd1_reg[3:1]}; 
	assign bcd2_tmp = {bcd3_reg[0], bcd2_reg[3:1]}; 
	assign bcd3_tmp = {1'b0       , bcd3_reg[3:1]}; 

	assign oBIN = bin_reg;	
endmodule
