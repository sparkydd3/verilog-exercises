module palette
	(
		output wire [11:0] color_o,
		input wire [7:0] color_i
	);

	// body
	// 3-bit read to 4-bit red, 3-bit green to 4-bit green
	// 2-bit blue to 4-bit blue
	assign color_o =
		{color_i[7:5], color_i[5],
		 color_i[4:2], color_i[2],
		 color_i[1:0], color_i[0], color_i[0]};
endmodule
