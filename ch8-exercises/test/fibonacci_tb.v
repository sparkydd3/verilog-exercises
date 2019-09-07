module fibonacci_tb();
	localparam T = 20;
	wire clk, reset;
	wire start_i;
	wire [3:0] n_i;
	wire ready_o, done_o;
	wire [9:0] fib_o;
	integer log_file, console_file, out_file;

	initial
	begin
		log_file = $fopen("fibonacci_tb.log");
		if (!log_file)
			$display("Cannot open log file.");
		console_file = 32'h0000_0001;
		out_file = log_file | console_file;
	end
	
	fibonacci uut
		(.iCLK(clk), .iRESET(reset),
		 .iSTART(start_i),
		 .iN(n_i),
		 .oREADY(ready_o), .oDONE(done_o),
		 .oFIB(fib_o));
	
	fibonacci_gen #(.T(20)) gen_unit
		(.clk(clk), .reset(reset),
		 .start(start_i),
		 .n(n_i),
		 .ready(ready_o), .done(done_o),
		 .fout(out_file));
	
	fibonacci_mon mon_unit
		(.clk(clk), .reset(reset),
		 .iSTART(start_i),
		 .iN(n_i),
		 .oREADY(ready_o), .oDONE(done_o),
		 .oFIB(fib_o),
		 .fout(out_file));
endmodule
