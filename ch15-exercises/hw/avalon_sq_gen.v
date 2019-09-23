module avalon_sq_gen
	#(
		parameter MAX_PER = 50000000
	)
	(
		input wire clk, reset,
		input wire [31:0] writedata,
		input wire [0:0] address,
		input wire write,
		output wire [31:0] readdata,
		output wire sq
	);
	localparam PRD_W = $clog2(MAX_PER);

	reg [PRD_W-1:0] prd_reg;
	reg en_reg;

	wire prd_sel, en_sel;

	sq_gen #(.MAX_PER(MAX_PER)) gen_unit
		(.iCLK(clk), .iRESET(reset),
		 .iEN(en_reg), .iPRD(prd_reg),
		 .oSQ(sq));

	always @(posedge clk, posedge reset)
		if (reset)
			begin
				prd_reg <= 0;
				en_reg <= 0;
			end
		else
			begin
				if (prd_sel)
					prd_reg <= writedata[PRD_W-1:0];
				if (en_sel)
					en_reg <= writedata[0];
			end
	
	assign prd_sel = (write & address == 1'b0);
	assign en_sel = (write & address == 1'b1);
endmodule
