module eq2_function
	(
		input wire [1:0] a, b,
		output reg aeqb
	);
	
	reg e0, e1;

	always @*
	begin
		#2 e0 = equ_func(a[0], b[0]);
		#2 e1 = equ_func(a[1], b[1]);
		aeqb = e0 & e1;
	end

	// function definition
	function equ_func(input i0, i1);
		begin
			equ_func = (~i0 & ~i1) | (i0 & i1);
		end
	endfunction
endmodule
