module mod_m_counter
	#(
		parameter SIZE = 16,				// count 0 to SIZE - 1
		          W = $clog2(SIZE)
	)
	(
		input wire iCLK, iRESET, iEN,
		output wire [W-1:0] oCNT,
		output wire oTICK
	);

	reg [W-1:0] cnt_reg;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			cnt_reg <= 0;
		else if (iEN)
			cnt_reg <= (cnt_reg == SIZE-1) ? 0 : cnt_reg + 1;
	
	assign oCNT = cnt_reg;
	assign oTICK = (cnt_reg == SIZE-1) ? 1'b1 : 1'b0;

endmodule
