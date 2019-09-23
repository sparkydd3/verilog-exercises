module fib
	(
		input wire iCLK, iRESET,
		input wire iSTART,
		input wire [7:0] iIN,
		output reg oREADY, oDONE,
		output wire [63:0] oFIB
	);
	
	// symbolic state declaration
	localparam [1:0]
		idle = 2'b00,
		op   = 2'b01,
		done = 2'b10;
	
	// signal declaration
	reg [1:0] state_reg, state_next;
	reg [63:0] t0_reg, t0_next, t1_reg, t1_next;
	reg [7:0] n_reg, n_next;

	// body
	// FSMD state & data registers
	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				state_reg <= idle;
				t0_reg <= 0;
				t1_reg <= 0;
				n_reg <= 0;
			end
		else
			begin
				state_reg <= state_next;
				t0_reg <= t0_next;
				t1_reg <= t1_next;
				n_reg <= n_next;
			end
	// FSMD next-state logic
	always @*
	begin
		state_next = state_reg;
		oREADY = 1'b0;
		oDONE = 1'b0;
		t0_next = t0_reg;
		t1_next = t1_reg;
		n_next = n_reg;
		case (state_reg)
			idle:
				begin
					oREADY = 1'b1;
					if (iSTART)
						begin
							t0_next = 0;
							t1_next = 1;
							n_next = iIN;
							state_next = op;
						end
				end
			op:
				if (n_reg == 0)
					begin
						t1_next = 0;
						state_next = done;
					end
				else if (n_reg == 1)
					state_next = done;
				else
					begin
						t1_next = t1_reg + t0_reg;
						t0_next = t1_reg;
						n_next = n_reg - 1;
					end
			done:
				begin
					oDONE = 1'b1;
					state_next = idle;
				end
			default: state_next = idle;
		endcase
	end
	// output
	assign oFIB = t1_reg;
endmodule
