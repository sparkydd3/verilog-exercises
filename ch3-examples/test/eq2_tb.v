`define ASSERT(test, msg) \
	if(!(test)) $write("[ERROR] %s: %s\n", `__FILE__, $sformatf msg)

`timescale 1 ns / 1 ps

module eq2_tb;
	// signal declaration
	reg [1:0] a_i, b_i;
	reg t_e;
	wire t_o;

	localparam TEST_NUM = 16;
	integer vectornum;
	reg [4:0] testvectors[TEST_NUM-1:0];

	// instantiate the circuit under test
	eq2 uut (.a(a_i), .b(b_i), .aeqb(t_o));

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/eq2_tb.tv", testvectors);

		for (vectornum = 0; vectornum < TEST_NUM; vectornum = vectornum + 1)
		begin
			{a_i, b_i, t_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((t_o == t_e),
				("test vector #%0d: input = {%b, %b}, output = %b, expected = %b",
				vectornum, a_i, b_i, t_o, t_e));
		end

		$finish;
	end
endmodule
