`timescale 1 ns/10 ps
module univ_bin_counter_tb();
	
	// delaration
	localparam T = 20;	// clock period
	wire clk, reset;

	wire clear_i, load_i, en_i, up_i;
	wire [2:0] d_i;
	wire max_o, min_o;
	wire [2:0] q_o;
	integer log_file, console_file, out_file;

	initial
	begin
		log_file = $fopen("univ_bin_counter_tb.log");
		if (!log_file)
			$display("Cannot open logfile.");
		console_file = 32'h0000_0001;
		out_file = log_file | console_file;
	end

	// uut instantiation
	univ_bin_counter #(.N(3)) uut
		(.iCLK(clk), .iRESET(reset),
		 .iCLEAR(clear_i), .iLOAD(load_i), .iEN(en_i), .iUP(up_i),
		 .iD(d_i),
		 .oMAX(max_tick_o), .oMIN(min_tick_o),
		 .oQ(q_o));
	
	// test vector generator
	univ_bin_counter_gen #(.N(3), .T(20)) gen_unit
		(.clk(clk), .reset(reset),
		 .clear(clear_i), .load(load_i), .en(en_i), .up(up_i),
		 .d(d_i),
		 .fout(out_file));
	
	// bin_monitor instantiation
	univ_bin_counter_mon #(.N(3)) mon_unit
		(.clk(clk), .reset(reset),
		 .iCLEAR(clear_i), .iLOAD(load_i), .iEN(en_i), .iUP(up_i),
		 .iD(d_i),
		 .oMAX(max_tick_o), .oMIN(min_tick_o),
		 .oQ(q_o),
		 .fout(out_file));
endmodule
