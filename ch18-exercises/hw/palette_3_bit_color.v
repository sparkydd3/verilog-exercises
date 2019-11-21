module palette_3_bit_color
	(
		output wire [11:0] o_color,
		input wire [3:0] i_color
	);

	// body
	// 1-bit red to 4-bit red, 1-bit green to 4-bit green
	// 1-bit blue to 4-bit blue
	assign o_color =
		{{4{i_color[2]}},
		 {4{i_color[1]}},
		 {4{i_color[0]}}};
endmodule
