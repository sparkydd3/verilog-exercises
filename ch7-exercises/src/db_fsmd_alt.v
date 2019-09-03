module db_fsmd_alt
	(
		input wire iCLK, iRESET,
		input wire iSW,
		output reg oDB
	);
	
	// symbolic state declaration
	localparam [1:0]
		zero  = 2'b00,
		wait0 = 2'b01,
		one   = 2'b10,
		wait1 = 2'b11;
	
	// number of counter bits (2^N * 20 ns = 40 ms)
	localparam N = 21;

	// signal declaration
	reg [N-1:0] q_reg, q_next;
	reg [1:0] state_reg, state_next;

	// body
	// fsmd state and data registers
	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				state_reg <= 0;
				q_reg <= 0;
			end
		else
			begin
				state_reg <= state_next;
				q_reg <= q_next;
			end
	
	// next-state logic and data path functional units/routing
	always @*
	begin
		state_next = state_reg;		// default state: the same
		q_next = q_reg;				// default q: unchanged
		oDB = 1'b0;
		case (state_reg)
			zero:
				begin
					oDB = 1'b0;
					if (iSW)
						begin
							state_next = wait1;
							q_next = {N{1'b1}};	// load 1..1
						end
				end
			wait1:
				begin
					oDB = 1'b1;
					q_next = q_reg - 1;
					if (q_next == 0)
						state_next = one;
				end
			one:
				begin
					oDB = 1'b1;
					if (~iSW)
						begin
							q_next = wait0;
							q_next = {N{1'b1}};	// load 1..1
						end
				end
			wait0:
				begin
					oDB = 1'b0;
					q_next = q_reg - 1;
					if (q_next == 0)
						state_next = zero;
				end
			default: state_next = zero;
		endcase
	end
endmodule
