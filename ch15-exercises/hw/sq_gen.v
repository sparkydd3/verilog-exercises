module sq_gen
	#(
		parameter MAX_PER = 50000000,
		W = $clog2(MAX_PER)
	)
	(
		input wire iCLK, iRESET,
		input wire iEN,
		input wire [W-1:0] iPRD,
		output reg oSQ
	);

	reg [W-1:0] prd_reg, cnt_reg;
	reg running;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				oSQ <= 0;
				prd_reg <= 0;
				cnt_reg <= 0;
				running <= 0;
			end
		else
			case ({running, iEN})
				// 2'b00: do nothing
				2'b01:
					begin
						running <= 1;
						cnt_reg <= 0;
						prd_reg <= iPRD;
						oSQ <= 1;
					end
				2'b11:
					begin
						cnt_reg <= (cnt_reg == prd_reg - 1) ? 0 : cnt_reg + 1;
						oSQ <= (cnt_reg > (prd_reg >> 1)) ? 0 : 1;
					end
				2'b10:
					begin
						running <= 0;
						cnt_reg <= 0;
						prd_reg <= 0;
						oSQ <= 0;
					end
			endcase
endmodule
