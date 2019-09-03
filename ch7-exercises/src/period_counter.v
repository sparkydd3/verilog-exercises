module period_counter
	(
		input wire iCLK, iRESET,
		input wire iSTART, iSIG,
		output reg oREADY, oDONE,
		output wire [19:0] oPRD
	);

	// symbolic state declaration
	localparam [1:0]
		idle = 2'b00,
		waite = 2'b01,
		count = 2'b10,
		done = 2'b11;
	
	// constant declaration
	localparam CLK_US_COUNT = 50;	// 1 us tick

	// signal declaration
	reg [1:0] state_reg, state_next;
	reg [4:0] t_reg, t_next;	// up to 50
	reg [19:0] p_reg, p_next;	// up to 1 sec
	reg delay_reg;
	wire edg;

	// body
	// FSMD state and data registers
	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				state_reg <= idle;
				t_reg <= 0;
				p_reg <= 0;
				delay_reg <= 0;
			end
		else
			begin
				state_reg <= state_next;
				t_reg <= t_next;
				p_reg <= p_next;
				delay_reg <= iSIG;
			end
	
	// rising edge tick
	assign edg = ~delay_reg & iSIG;

	// FSMD next-state logic
	always @*
	begin
		state_next = state_reg;
		oREADY = 1'b0;
		oDONE = 1'b0;
		p_next = p_reg;
		t_next = t_reg;
		case (state_reg)
			idle:
				begin
					oREADY = 1'b1;
					if (iSTART)
						state_next = waite;
				end
			waite:	// wait for the first edge
				if (edg)
					begin
						state_next = count;
						t_next = 0;
						p_next = 0;
					end
			count:
				if (edg)	// 2nd edge arrived
					state_next = done;
				else		// otherwise count
					if (t_reg == CLK_US_COUNT - 1)	// 1 ms tick
						begin
							t_next = 0;
							p_next = p_reg + 1;
						end
					else
						t_next = t_reg + 1;
			done:
				begin
					oDONE = 1'b1;
					state_next = idle;
				end
			default: state_next = idle;
		endcase
	end

	// output
	assign oPRD = p_reg;
endmodule
