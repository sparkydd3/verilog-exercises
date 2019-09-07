`timescale 1 ns/10 ps

module fibonacci_gen
	#(
		parameter T = 20
	)
	(
		output reg clk, reset,
		output reg start,
		output reg [3:0] n,
		input wire ready, done,
		input integer fout
	);
	
	integer i;
	
	always
	begin
		clk = 1'b1;
		#(T/2);
		clk = 1'b0;
		#(T/2);
	end

	initial
	begin
		initialize();
		for (i = 0; i < 16; i = i + 1)
			calc_fib(i);

		$fdisplay(fout, "(%5d ns) Test completed.", $time);
		$stop;
	end
	
	task initialize();
		begin
			start = 0;
			n = 0;

			@(negedge clk);
			reset = 1'b1;
			#(T/4);
			reset = 1'b0;
		end 
	endtask

	task calc_fib(input integer i);
		begin
			wait(ready == 1);
			@(negedge clk);
			n = i[3:0];
			start = 1'b1;

			@(negedge clk);
			start = 1'b0;

			wait(done == 1);
		end
	endtask
endmodule
