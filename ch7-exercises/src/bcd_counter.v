module bcd_counter
	(
		input wire iCLK, iRESET,
		input wire iCLEAR, iEN,
		output wire [3:0] oBCD3, oBCD2, oBCD1, oBCD0
	);

	reg [3:0] bcd3_reg, bcd2_reg, bcd1_reg, bcd0_reg;
	reg [3:0] bcd3_next, bcd2_next, bcd1_next, bcd0_next;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				bcd3_reg <= 4'b0;
				bcd2_reg <= 4'b0;
				bcd1_reg <= 4'b0;
				bcd0_reg <= 4'b0;
			end
		else
			begin
				bcd3_reg <= bcd3_next;
				bcd2_reg <= bcd2_next;
				bcd1_reg <= bcd1_next;
				bcd0_reg <= bcd0_next;
			end

	always @*
	begin
		bcd3_next = bcd3_reg;
		bcd2_next = bcd2_reg;
		bcd1_next = bcd1_reg;
		bcd0_next = bcd0_reg;

		if (iCLEAR)
			begin
				bcd3_next = 4'b0;
				bcd2_next = 4'b0;
				bcd1_next = 4'b0;
				bcd0_next = 4'b0;
			end
		else if (iEN)
			begin
				if (bcd0_reg == 4'd9)
					bcd0_next = 4'd0;
				else
					bcd0_next = bcd0_reg + 1;

				if (bcd0_reg == 4'd9)
					if (bcd1_reg == 4'd9)
						bcd1_next = 4'd0;
					else
						bcd1_next = bcd1_reg + 1;
						
				if (bcd0_reg == 4'd9 && bcd1_reg == 4'd9)
					if (bcd2_reg == 4'd9)
						bcd2_next = 4'd0;
					else
						bcd2_next = bcd2_reg + 1;

				if (bcd0_reg == 4'd9 && bcd1_reg == 4'd9 && bcd2_reg == 4'd9)
					if (bcd3_reg == 4'd9)
						bcd3_next = 4'd0;
					else
						bcd3_next = bcd3_reg + 1;
			end
	end

	assign oBCD3 = bcd3_reg;
	assign oBCD2 = bcd2_reg;
	assign oBCD1 = bcd1_reg;
	assign oBCD0 = bcd0_reg;
endmodule
