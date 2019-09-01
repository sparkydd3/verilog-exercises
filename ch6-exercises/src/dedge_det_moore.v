module dedge_det_moore
	(
		input wire iCLK, iRESET,
		input wire iLEVEL,
		output reg oTICK
	);
	
	localparam [1:0]
		zero = 2'b00,
		rise = 2'b01,
		one  = 2'b10,
		fall = 2'b11;
	
	reg [1:0] state_reg, state_next;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			state_reg <= zero;
		else
			state_reg <= state_next;
	
	always @*
	begin
		state_next = state_reg;
		oTICK = 1'b0;

		case (state_reg)
			zero:
				begin
					if (iLEVEL)
						state_next = rise;
				end
			rise:
				begin
					oTICK = 1'b1;
					if (iLEVEL)
						state_next = one;
					else
						state_next = fall;
				end
			one:
				begin
					if (~iLEVEL)
						state_next = fall;
				end
			fall:
				begin
					oTICK = 1'b1;
					if (~iLEVEL)
						state_next = zero;
					else
						state_next = rise;
				end
		endcase
	end
endmodule
