module dedge_det_mealy
	(
		input wire iCLK, iRESET,
		input wire iLEVEL,
		output reg oTICK
	);
	
	localparam
		zero = 1'b0,
		one  = 1'b1;
	
	reg state_reg, state_next;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			state_reg <= zero;
		else
			state_reg <= state_next;

	always @*
	begin
		oTICK = 1'b0;
		state_next = state_reg;

		case (state_reg)
			zero:
				if (iLEVEL)
					begin
						state_next = one;
						oTICK = 1'b1;
					end
			one:
				if (~iLEVEL)
					begin
						state_next = zero;
						oTICK = 1'b1;
					end
		endcase
	end
endmodule
