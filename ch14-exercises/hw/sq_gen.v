module sq_gen
	#(
		parameter W = 26
	)
	(
		input wire iCLK, iRESET,
		input wire iEN,
		input wire [W-1:0] iPER,
		output reg oSQ
	);

	reg [W-1:0] per, cnt;
	reg running;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				oSQ <= 0;
				per <= 0;
				cnt <= 0;
				running <= 0;
			end
		else
			case ({running, iEN})
				// 2'b00: do nothing
				2'b01:
					begin
						running <= 1;
						cnt <= 0;
						per <= iPER;
						oSQ <= 1;
					end
				2'b11:
					begin
						cnt <= (cnt == per - 1) ? 0 : cnt + 1;
						oSQ <= (cnt > (per >> 1)) ? 0 : 1;
					end
				2'b10:
					begin
						running <= 0;
						cnt <= 0;
						per <= 0;
						oSQ <= 0;
					end
			endcase
endmodule
