module avalon_sram32
	(
		input wire clk, reset,
		
		// Avalon-MM slave interface
		input wire [16:0] address,
		input wire chipselect_n, read_n, write_n,
		input wire [3:0] byteenable_n,
		input wire [31:0] writedata,
		output wire [31:0] readdata,
		output wire readdatavalid,
		output wire waitrequest,

		// conduit to/from SRAM
		output wire [17:0] sram_addr,
		inout [15:0] sram_dq,
		output sram_ce_n, sram_oe_n, sram_we_n,
		output sram_lb_n, sram_ub_n
	);

	reg [16:0] addr_reg;
	reg [31:0] rdata_reg, wdata_reg;
	reg [3:0] bten_n_reg;
	reg ce_n_reg, oe_n_reg, we_n_reg;
	reg valid_reg, wait_reg;

	localparam [1:0]
		idle = 2'b00,
		proc_lword = 2'b01,
		proc_uword = 2'b10;
	reg [1:0] state_reg;

	always @(posedge clk, posedge reset)
		if (reset)
			begin
				ce_n_reg <= 1'b1;
				oe_n_reg <= 1'b1;
				we_n_reg <= 1'b1;

				state_reg <= idle;
				valid_reg <= 1'b0;
				wait_reg <= 1'b0;

				addr_reg <= 17'b0;
				rdata_reg <= 32'b0;
				wdata_reg <= 32'b0;
				bten_n_reg <= 4'b1111;
			end
		else 
			begin
				valid_reg <= 1'b0;
				wait_reg <= 1'b0;

				case (state_reg)
					idle:
						begin						
							if (~chipselect_n)
								begin
									ce_n_reg <= chipselect_n;
									oe_n_reg <= read_n;
									we_n_reg <= write_n;

									addr_reg <= address;
									wdata_reg <= writedata;
									bten_n_reg <= byteenable_n;

									state_reg <= proc_lword;
									wait_reg <= 1'b1;
								end
						end
					proc_lword:
						begin
							state_reg <= proc_uword;
							
							if (~oe_n_reg)
								rdata_reg[15:0] <= sram_dq;
						end
					proc_uword:
						begin
							if (~oe_n_reg)
								begin
									rdata_reg[31:16] <= sram_dq;
									valid_reg <= 1'b1;
								end

							if (~chipselect_n)
								begin
									ce_n_reg <= chipselect_n;
									oe_n_reg <= read_n;
									we_n_reg <= write_n;

									addr_reg <= address;
									wdata_reg <= writedata;
									bten_n_reg <= byteenable_n;

									state_reg <= proc_lword;
									wait_reg <= 1'b1;
								end
							else
								begin
									ce_n_reg <= 1'b1;
									oe_n_reg <= 1'b1;
									we_n_reg <= 1'b1;
									state_reg <= idle;
								end
						end
				endcase
			end

	// to Avalon interface
	assign readdata = rdata_reg;
	assign waitrequest = wait_reg;
	assign readdatavalid = valid_reg;

	// to SRAM
	assign sram_ce_n = ce_n_reg;
	assign sram_oe_n = oe_n_reg;
	assign sram_we_n = we_n_reg;

	assign sram_addr = (state_reg == proc_lword) ? {addr_reg, 1'b0} :
	                   (state_reg == proc_uword) ? {addr_reg, 1'b1} :
	                    17'b0;

	assign {sram_ub_n, sram_lb_n} = (state_reg == proc_lword) ? bten_n_reg[1:0] :
	                                (state_reg == proc_uword) ? bten_n_reg[3:2] :
	                                 2'b11;

	// SRAM tristate data bus
	assign sram_dq = (ce_n_reg | we_n_reg) ? 16'bz :
					 (state_reg == proc_lword) ? wdata_reg[15:0] :
	                 (state_reg == proc_uword) ? wdata_reg[31:16] :
					  16'bz;
endmodule
