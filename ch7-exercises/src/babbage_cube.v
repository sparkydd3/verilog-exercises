module babbage_cube
	(
		input wire iCLK, iRESET,
		input wire iSTART,
		input wire [5:0] iN,
		output reg oREADY, oDONE,
		output reg [17:0] oF
	);
	
	localparam [1:0]
		idle = 2'b00,
		calc = 2'b01,
		done = 2'b10;
	
	reg [1:0] state_reg, state_next;
	reg [5:0] n_reg, n_next;
	reg [17:0] f_reg, f_next, g_reg, g_next, h_reg, h_next;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				state_reg <= idle;
				n_reg <= 0;
				f_reg <= 0;
				g_reg <= 0;
				h_reg <= 0;
			end
		else
			begin
				state_reg <= state_next;
				n_reg <= n_next;
				f_reg <= f_next;
				g_reg <= g_next;
				h_reg <= h_next;
			end
	
	always @*
	begin
		state_next = state_reg;
		n_next = n_reg;
		f_next = f_reg;
		g_next = g_reg;
		h_next = h_reg;
		oREADY = 1'b0;
		oDONE = 1'b0;
		oF = f_reg;

		case (state_reg)
			idle:
				begin
					oREADY = 1'b1;
					if (iSTART)
						begin
							n_next = iN;
							f_next = 1;
							g_next = 5;
							h_next = 10;
							state_next = calc;
						end
				end
			calc:
				begin
					if (n_reg == 0)
						state_next = done;
					else
						begin
							f_next = f_reg + g_reg;
							g_next = g_reg + h_reg;
							h_next = h_reg + 6;
							n_next = n_reg - 1;
						end
				end
			done:
				begin
					oDONE = 1'b1;
					state_next = idle;
				end
			default: state_next = idle;
		endcase
	end
endmodule
