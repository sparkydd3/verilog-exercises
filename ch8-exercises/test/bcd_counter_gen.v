`timescale 1 ns/10 ps

module bcd_counter_gen
	#(
		parameter T = 20
	)
	(
		output reg clk, reset,
		output reg en, clear, up,
		input integer fout
	);
	
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
		count(9999, 1);
		clr_counter_sync();
		count(10000, 0);
		count(5, 1);
		reset_counter_async();
		count(5, 1);

		$fdisplay(fout, "(%5d ns) Test completed.", $time);
		$fclose(fout);
		$stop;
	end

	task reset_counter_async();
		begin
			@(negedge clk)
			reset = 1'b1;
			#(T/4);
			reset = 1'b0;
		end
	endtask

	task initialize();
		begin
			en = 1'b0;
			up = 1'b0;
			clear = 1'b0;
			reset_counter_async();
		end
	endtask

	task clr_counter_sync();
		begin
			@(negedge clk);
			clear = 1'b1;
			@(negedge clk);
			clear = 1'b0;
		end
	endtask
	
	task count(input integer C, input integer UP_DOWN);
		begin
			@(negedge clk);
			en = 1'b1;
			if (UP_DOWN == 1)
				up = 1'b1;
			repeat(C) @(negedge clk);
			en = 1'b0;
			up = 1'b0;
		end
	endtask
endmodule
