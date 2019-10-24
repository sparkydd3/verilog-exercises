module palette
	(
		output wire [11:0] o_color,
		input wire [7:0] i_color
	);

	// body
	// 3-bit read to 4-bit red, 3-bit green to 4-bit green
	// 2-bit blue to 4-bit blue
	assign o_color =
		{i_color[7:5], i_color[5],
		 i_color[4:2], i_color[2],
		 i_color[1:0], i_color[0], i_color[0]};
endmodule
