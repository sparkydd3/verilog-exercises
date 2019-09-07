`timescale 1 ns/10 ps

module fifo_gen
	#(
		parameter T = 20,
		          W = 8,
				  S = 16
	)
	(
		output reg clk, reset,
		output reg enq, deq,
		output reg [W-1:0] d,
		input integer fout
	);
	
	integer i;

	always
	begin
		clk = 1'b1;
		#(T/4);
		clk = 1'b0;
		#(T/4);
	end

	initial
	begin
		initialize();
		enqueue(0, S);
		dequeue(S);

		$fdisplay(fout, "(%5d ns) Test completed.", $time);
		$fclose(fout);
		$stop;
	end

	task reset_async();
		begin
			@(negedge clk);
			reset = 1'b1;
			#(T/4);
			reset = 1'b0;
		end
	endtask

	task initialize();
		begin
			enq = 1'b0;
			deq = 1'b0;
			reset_async();
		end
	endtask

	task enqueue(input integer START, input integer AMOUNT);
		begin
			for (i = 0; i < AMOUNT; i = i + 1)
				begin
					@(negedge clk);
					enq = 1'b1;
					d = START + i;
				end

			@(negedge clk);
			enq = 1'b0;
		end
	endtask
	
	task dequeue(input integer AMOUNT);	
		begin
			for (i = 0; i < AMOUNT; i = i + 1)
				begin
					@(negedge clk);
					deq = 1'b1;
				end

			@(negedge clk);
			deq = 1'b0;
		end
	endtask
endmodule
