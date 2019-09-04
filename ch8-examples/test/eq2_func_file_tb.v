`timescale 1 ns/10 ps

module eq2_func_file_tb;
	// signal declaration
	reg [1:0] test_in0_i, test_in1_i;
	wire test_out_o;
	integer log_file, console_file, out_file;
	reg [3:0] v_mem[0:7];
	integer i;

	// instantiate the circuit under test
	eq2_task uut
		(.a(test_in0_i), .b(test_in1_i), .aeqb(test_out_o));
	
	initial
	begin
		// setup output file
		log_file = $fopen("../test/eqlog_func.txt");
		if (!log_file)
			$display("Cannot open log file");
		console_file = 32'h0000_0001;
		out_file = log_file | console_file;

		// read test vector
		$readmemb("../test/vector_func.txt", v_mem);

		// test generator iterating through 8 patterns
		for (i = 0; i < 8; i = i + 1)
			begin
				{test_in0_i, test_in1_i} = v_mem[i];
				#200;
			end

		// stop simulation
		$fclose(log_file);
		$quit;
	end

	// text display
	initial
	begin
		$fdisplay(out_file, "      time test_in0 test_in1 test_out");
		$fdisplay(out_file, "           (a)      (b)      (aeqb)");
		$fmonitor(out_file, "%10d %b       %b       %b",
			$time, test_in0_i, test_in1_i, test_out_o);
	end
endmodule
