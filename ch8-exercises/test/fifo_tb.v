module fifo_tb();
	
	localparam T = 20;	// clock period
	localparam W = 8, S = 16;	// fifo parameters

	wire clk, reset;
	wire enq_i, deq_i;
	wire full_o, empty_o;
	wire [W-1:0] d_i, q_o;
	integer log_file, console_file, out_file;

	initial
	begin
		log_file = $fopen("fifo_tb.log");
		if (!log_file)
			$display("Cannot open log file");
		console_file = 32'h0000_0001;
		out_file = log_file | console_file;
	end

	fifo #(.W(W), .S(S)) uut
		(.iCLK(clk), .iRESET(reset),
		 .iENQ(enq_i), .iDEQ(deq_i),
		 .iD(d_i),
		 .oFULL(full_o), .oEMPTY(empty_o),
		 .oQ(q_o));
	
	fifo_gen #(.T(20), .W(W), .S(S)) gen_unit
		(.clk(clk), .reset(reset),
		 .enq(enq_i), .deq(deq_i),
		 .d(d_i),
		 .fout(out_file));
	
	fifo_mon #(.W(W), .S(S)) mon_unit
		(.clk(clk), .reset(reset),
		 .iENQ(enq_i), .iDEQ(deq_i),
		 .iD(d_i),
		 .oFULL(full_o), .oEMPTY(empty_o),
		 .oQ(q_o),
		 .fout(out_file));
endmodule
