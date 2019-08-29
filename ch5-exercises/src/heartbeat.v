module heartbeat
	(
		input wire iCLK, iRESET, iEN,
		output reg [2:0] oHB
	);
	
	reg [2:0] hb_reg;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			hb_reg <= 5;
		else if (iEN)
			hb_reg <= (hb_reg == 5) ? 0 : hb_reg + 1;
	
	always @*
		case (hb_reg)
			3'o0 : oHB = 3'b001;
			3'o1 : oHB = 3'b010;
			3'o2 : oHB = 3'b100;
			default: oHB = 3'b000;
		endcase
endmodule
