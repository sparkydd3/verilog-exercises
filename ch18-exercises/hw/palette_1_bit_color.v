module palette_1_bit_color
	(
		output wire [11:0] o_color,
		input wire i_color
	);

	// body
	assign o_color = (i_color == 1'b1) ? 12'hfff : 12'h000;
endmodule
