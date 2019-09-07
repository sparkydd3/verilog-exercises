module fibonacci
	(
		input wire iCLK, iRESET,
		input wire iSTART,
		input wire [3:0] iN,
		output wire oREADY, oDONE,
		output wire [9:0] oFIB
	);
	
	localparam [1:0]
		idle = 2'b00,
		calc = 2'b01,
		done = 2'b10;
	
	reg [1:0] state_reg;
	reg [9:0] f0_reg, f1_reg;
	reg [3:0] n_reg;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				state_reg <= idle;
				f1_reg <= 0;
				f0_reg <= 0;
			end
		else
			case (state_reg)
				idle:
					if (iSTART)
						begin
							state_reg <= calc;
							f0_reg <= 0;
							f1_reg <= 1;
							n_reg <= iN;
						end
				calc:
					if (n_reg == 0)
						state_reg <= done;
					else
						begin
							f1_reg <= f1_reg + f0_reg;
							f0_reg <= f1_reg;
							n_reg <= n_reg - 1;
						end
				done:
					state_reg <= idle;
				default:
					state_reg <= idle;
			endcase
	
	assign oREADY = (state_reg == idle);
	assign oDONE = (state_reg == done);
	assign oFIB = f0_reg;
endmodule
