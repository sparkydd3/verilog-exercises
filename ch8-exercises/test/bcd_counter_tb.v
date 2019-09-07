module bcd_counter_tb();
	
	localparam T = 20;	// clock period
	wire clk, reset;
	wire clear_i, en_i, up_i;
	wire max_o, min_o;
	wire [3:0] bcd3_o, bcd2_o, bcd1_o, bcd0_o;
	integer log_file, console_file, out_file;

	initial
	begin
		log_file = $fopen("bcd_counter_tb.log");
		if (!log_file)
			$display("Cannot open log file.");
		console_file = 32'h0000_0001;
		out_file = log_file | console_file;
	end

	bcd_counter uut
		(.iCLK(clk), .iRESET(reset),
		 .iEN(en_i), .iCLEAR(clear_i), .iUP(up_i),
		 .oMAX(max_o), .oMIN(min_o),
		 .oBCD3(bcd3_o), .oBCD2(bcd2_o), .oBCD1(bcd1_o), .oBCD0(bcd0_o));
	
	bcd_counter_gen #(.T(20)) gen_unit
		(.clk(clk), .reset(reset),
		 .en(en_i), .clear(clear_i), .up(up_i),
		 .fout(out_file));
	
	bcd_counter_mon mon_unit
		(.clk(clk), .reset(reset),
		 .iEN(en_i), .iCLEAR(clear_i), .iUP(up_i),
		 .oMAX(max_o), .oMIN(min_o),
		 .oBCD3(bcd3_o), .oBCD2(bcd2_o), .oBCD1(bcd1_o), .oBCD0(bcd0_o),
		 .fout(out_file));
endmodule
