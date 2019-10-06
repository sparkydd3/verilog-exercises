module avalon_sdram32
	(
		// Avalon MM
		input wire clk, reset,
		input wire chipselect,
		input wire [20:0] address,
		input wire [3:0] byteenable_n,
		input wire read,
		output wire [31:0] readdata,
		input wire write,
		input wire [31:0] writedata,
		output wire waitrequest,
		output wire validdata,

		// Output conduit
		output wire [11:0] sdram_addr,
		inout [15:0] sdram_dq,
		output wire [1:0] sdram_ba,
		output wire [1:0] sdram_dqm,
		output wire sdram_ras_n,
		output wire sdram_cas_n,
		output wire sdram_cke,
		output wire sdram_we_n,
		output wire sdram_cs_n
	);

	reg [20:0] addr_reg;
	reg read_reg, write_reg;
	reg [3:0] byteenable_n_reg;

	reg [31:0] rdata_reg, wdata_reg;
	reg wait_reg;

	// fifo read_queue to handle timing for read data that appears cas delay
	// cycles after read command given
	reg [3:0] read_queue;

	// commands
	reg [3:0] cmd_reg;
	localparam [3:0]
		NOP = 4'b1111,
		ACTIVE = 4'b0011,
		READ = 4'b0101,
		WRITE = 4'b0100,
		PRECHARGE = 4'b0010,
		REFRESH = 4'b0001,
		LOAD_MODE = 4'b0000;

	localparam t_initial = 100000 / 20;
	localparam t_refresh = (64000000 / 4096) / 20;
	reg [$clog2(t_initial)-1:0] timer_reg;

	localparam mode_settings = {
		2'b00,	// A[11:10], reserved
		1'b0,	// A[9], programmed burst length
		2'b00,	// A[8:7], reserved
		3'b010,	// A[6:4], CAS latency 2
		1'b0,	// A[3], sequential burst type
		3'b001 	// A[2:0], 2 burst length
	};

	// state machine states
	localparam [2:0]
		s_init = 0,
		s_idle = 1,
		s_refresh = 2,
		s_active = 3,
		s_proc_l = 4,
		s_proc_u = 5,
		s_precharge = 6;
	reg [2:0] state_reg;

	always @(posedge clk, posedge reset)
		if (reset)
			begin
				cmd_reg <= NOP;	
				wait_reg <= 1'b1;

				state_reg <= s_init;
				timer_reg <= t_initial + 11;

				read_queue <= 3'b000;
			end
		else 
			begin
				timer_reg <= (timer_reg == 0) ? 0 : timer_reg - 1;
				cmd_reg <= NOP;
				
				// read data appears cas cycle delay (2) after read command given
				read_queue <= {(state_reg == s_proc_l & read_reg), read_queue[3:1]};
				if (read_queue[2])
					rdata_reg[15:0] <= sdram_dq;
				if (read_queue[1])
					rdata_reg[31:16] <= sdram_dq;

				case (state_reg)
					s_init:
						case (timer_reg)
							11: cmd_reg <= PRECHARGE;
							10: cmd_reg <= REFRESH;
							5: cmd_reg <= REFRESH;
							0:
								begin
									cmd_reg <= LOAD_MODE;
									state_reg <= s_idle;
									wait_reg <= 1'b0;
									timer_reg <= t_refresh;
								end
						endcase
					s_idle:
						begin			
							// default to no wait if nothing happens			
							wait_reg <= 1'b0;

							// only read commands if not waiting, otherwise
							// there may already be a command in buffer
							if (~wait_reg)
								begin
									addr_reg <= address;
									byteenable_n_reg <= byteenable_n;
									read_reg <= read;
									write_reg <= write;
									wdata_reg <= writedata;
								end

							if (timer_reg == 0)
								begin
									wait_reg <= 1'b1;
									cmd_reg <= REFRESH;
									timer_reg <= 3;
									state_reg <= s_refresh;
								end
							else if (read | write | read_reg | write_reg)
								begin
									cmd_reg <= ACTIVE;
									wait_reg <= 1'b1;
									state_reg <= s_active;
								end
						end
					s_active:
						begin
							state_reg <= s_proc_l;

							if (read_reg)
								cmd_reg <= READ;
							else if (write_reg)
								cmd_reg <= WRITE;
						end
					s_proc_l:
						begin
							wait_reg <= 1'b0;
							state_reg <= s_proc_u;
						end
					s_proc_u:
						begin
							addr_reg <= address;
							byteenable_n_reg <= byteenable_n;
							read_reg <= read;
							write_reg <= write;
							wdata_reg <= writedata;
							wait_reg <= 1'b1;

							if ((read | write) & (address[20:7] == addr_reg[20:7]) & ~(read_reg & write))
								begin
									state_reg <= s_proc_l;

									if (read)
										cmd_reg <= READ;
									else if (write)
										cmd_reg <= WRITE;
								end
							else
								state_reg <= s_precharge;
						end
					s_precharge:
						begin
							state_reg <= s_idle;
							cmd_reg <= PRECHARGE;
							wait_reg <= read_reg | write_reg;
						end
					s_refresh:
						if (timer_reg == 0)
							begin
								timer_reg <= t_refresh;
								state_reg <= s_idle;
								wait_reg <= read_reg | write_reg;
							end
				endcase
			end

	// Avalon MM signals
	assign waitrequest = wait_reg;
	assign validdata = read_queue[0];
	assign readdata = rdata_reg;

	// SDRAM signals
	assign sdram_cke = 1'b1;

	assign sdram_addr = (state_reg == s_active) ? addr_reg[18:7] :
	                    (state_reg == s_proc_l) ? {4'b0, addr_reg[6:0], 1'b0} :
	                    (cmd_reg == PRECHARGE) ? (1'b1 << 10) :
	                    (cmd_reg == LOAD_MODE) ? mode_settings :
	                    12'b0;

	assign sdram_ba = (state_reg == s_active) ? addr_reg[20:19] :
	                  (state_reg == s_proc_l) ? addr_reg[20:19] :
	                  2'b00;

	assign {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = cmd_reg;

	assign sdram_dq = (state_reg == s_proc_l & write_reg) ? wdata_reg[15:0] : 
	                  (state_reg == s_proc_u & write_reg) ? wdata_reg[31:16] :
	                   16'bz;

	assign sdram_dqm = (state_reg == s_proc_l) ? byteenable_n_reg[1:0] : 
	                   (state_reg == s_proc_u) ? byteenable_n_reg[3:2] :
	                   2'b11; 
endmodule
