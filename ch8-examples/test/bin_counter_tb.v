`timescale 1 ns/10 ps
module bin_counter_tb();
	
	// delaration
	localparam T = 20;	// clock period
	wire clk, reset;

	wire syn_clr_i, load_i, en_i, up_i;
	wire [2:0] d_i;
	wire max_tick_o, min_tick_o;
	wire [2:0] q_o;

	// uut instantiation
	univ_bin_counter_merged #(.N(3)) uut
		(.clk(clk), .reset(reset),
		 .syn_clr(syn_clr_i), .load(load_i), .en(en_i), .up(up_i),
		 .d(d_i),
		 .max_tick(max_tick_o), .min_tick(min_tick_o),
		 .q(q_o));
	
	// test vector generator
	bin_gen #(.N(3), .T(20)) gen_unit
		(.clk(clk), .reset(reset),
		 .syn_clr(syn_clr_i), .load(load_i), .en(en_i), .up(up_i),
		 .d(d_i));
	
	// bin_monitor instantiation
	bin_monitor #(.N(3)) mon_unit
		(.clk(clk), .reset(reset),
		 .syn_clr(syn_clr_i), .load(load_i), .en(en_i), .up(up_i),
		 .d(d_i),
		 .max_tick(max_tick_o), .min_tick(min_tick_o),
		 .q(q_o));
endmodule
