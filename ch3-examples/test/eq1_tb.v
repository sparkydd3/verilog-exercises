`define ASSERT(test, msg) \
	if(!(test)) $write("[ERROR] %s: %s\n",`__FILE__, $sformatf msg)

`timescale 1 ns / 1 ps

module eq1_tb;
	// signal declaration
	reg a_i, b_i;
	reg t_e;
	wire t_o;

	localparam TEST_NUM = 4;
	integer vectornum;
	reg [3:0] testvectors[TEST_NUM-1:0];
	integer logfile;

	// instantiate the circuit under test
	eq1 uut (.i0(a_i), .i1(b_i), .eq(t_o));

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/eq1_tb.tv", testvectors);

		for (vectornum = 0; vectornum < TEST_NUM; vectornum = vectornum + 1)
		begin
			{a_i, b_i, t_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((t_o == t_e), 
				("test vector #%0d: input = {%b, %b}, output = %b, expected = %b",
				vectornum,a_i, b_i, t_o, t_e));
		end
		$finish;
	end
endmodule
