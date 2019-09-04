module bin_gen
	#(
		parameter N = 8,
		          T = 20
	)
	(
		output reg clk, reset,
		output reg syn_clr, load, en, up,
		output reg [N-1:0] d
	);

	// clock
	// clock running forever
	always
	begin
		clk = 1'b1;
		#(T/2);
		clk = 1'b0;
		#(T/2);
	end

	// test procedure
	initial
	begin
		initialize();
		count(12, 1);			// count up 12 cycles
		count(6, 0);			// count down 6 cycles
		load_data(3'b011);
		count(2, 1);			// count up 2 cycles
		clr_counter_sync();
		count(3, 1);			// count up 3 cycles
		clr_counter_async();
		count(5, 1);			// count up 5 cycles
		$stop;
	end

	//===============================================================
	// task definitions
	//===============================================================
	// assert reset between clock edges
	task clr_counter_async();
		begin
			@(negedge clk);		// wait for falling edge
			reset = 1'b1;
			#(T/4);				// assert T/4
			reset = 1'b0;
		end
	endtask

	// system intialization
	task initialize();
		begin
			en = 0;
			up = 0;
			load = 0;
			syn_clr = 0;
			d = 3'b000;
			clr_counter_async();
		end
	endtask

	// assert syn_clr one clock cycle
	task clr_counter_sync();
		begin
			@(negedge clk);		// wait for falling edge
			syn_clr = 1'b1;		// assert clear
			@(negedge clk);
			syn_clr = 1'b0;
		end
	endtask

	// load register
	task load_data(input [N-1:0] data_in);
		begin
			@(negedge clk);		// wait for falling edge
			load = 1'b1;
			d = data_in;
			@(negedge clk);
			load = 1'b0;
		end
	endtask

	// count up or down for C cycles
	task count(input integer C, input integer UP_DOWN);
		begin
			@(negedge clk);		// wait for falling edge
			en = 1'b1;
			if (UP_DOWN == 1)	// count up if up_down is 1
				up = 1'b1;
			repeat(C) @(negedge clk);
			en = 1'b0;
			up = 1'b0;
		end
	endtask
endmodule
