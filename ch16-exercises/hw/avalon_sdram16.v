module avalon_sdram16
	(
		// Avalon MM
		input wire clk, reset,
		input wire chipselect,
		input wire [21:0] address,
		input wire [1:0] byteenable_n,
		input wire read,
		output wire [15:0] readdata,
		input wire write,
		input wire [15:0] writedata,
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

	// 2 deep buffer to process sequential access addresses that may not
	// require a precharge cycle
	reg [21:0] addr_reg [1:0];
	reg read_reg [1:0], write_reg [1:0];
	reg [1:0] byteenable_n_reg [1:0];
	reg [15:0] wdata_reg [1:0];

	reg [15:0] rdata_reg;
	reg wait_reg;

	// fifo read_queue to handle timing for read data that appears cas delay
	// cycles after read command given
	reg [2:0] read_queue;

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
		3'b000 	// A[2:0], 0 burst length
	};

	// state machine states
	localparam [2:0]
		s_init = 0,
		s_idle = 1,
		s_refresh = 2,
		s_active = 3,
		s_proc = 4,
		s_precharge = 5;
	reg [2:0] state_reg;

	wire cont_proc;
	assign cont_proc = 
		(read | write) & 
		~(read_reg[1] & write) &
		(address[21:8] == addr_reg[1][21:8]);

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
				read_queue <= {(state_reg == s_proc & read_reg[0]), read_queue[2:1]};
				if (read_queue[1])
					rdata_reg <= sdram_dq;

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
									addr_reg[1] <= address;
									byteenable_n_reg[1] <= byteenable_n;
									read_reg[1] <= read;
									write_reg[1] <= write;
									wdata_reg[1] <= writedata;
								end

							if (timer_reg == 0)
								begin
									wait_reg <= 1'b1;
									cmd_reg <= REFRESH;
									timer_reg <= 3;
									state_reg <= s_refresh;
								end
							else if (read | write | read_reg[1] | write_reg[1])
								begin
									cmd_reg <= ACTIVE;
									state_reg <= s_active;
								end
						end
					s_active:
						begin
							if (read_reg[1])
								cmd_reg <= READ;
							else if (write_reg[1])
								cmd_reg <= WRITE;

							addr_reg[0] <= addr_reg[1];
							byteenable_n_reg[0] <= byteenable_n_reg[1];
							read_reg[0] <= read_reg[1];
							write_reg[0] <= write_reg[1];
							wdata_reg[0] <= wdata_reg[1];

							addr_reg[1] <= address;
							byteenable_n_reg[1] <= byteenable_n;
							read_reg[1] <= read;
							write_reg[1] <= write;
							wdata_reg[1] <= writedata;

							state_reg <= s_proc;
							wait_reg <= ~cont_proc;
						end
					s_proc:
						if (~wait_reg)
							begin
								if (read_reg[1])
									cmd_reg <= READ;
								else if (write_reg[1])
									cmd_reg <= WRITE;

								addr_reg[0] <= addr_reg[1];
								byteenable_n_reg[0] <= byteenable_n_reg[1];
								read_reg[0] <= read_reg[1];
								write_reg[0] <= write_reg[1];
								wdata_reg[0] <= wdata_reg[1];

								addr_reg[1] <= address;
								byteenable_n_reg[1] <= byteenable_n;
								read_reg[1] <= read;
								write_reg[1] <= write;
								wdata_reg[1] <= writedata;

								wait_reg <= ~cont_proc;
							end
						else
							state_reg <= s_precharge;
					s_precharge:
						begin
							state_reg <= s_idle;
							cmd_reg <= PRECHARGE;
							wait_reg <= read_reg[1] | write_reg[1];
						end
					s_refresh:
						if (timer_reg == 0)
							begin
								timer_reg <= t_refresh;
								state_reg <= s_idle;
								wait_reg <= read_reg[1] | write_reg[1];
							end
				endcase
			end

	// Avalon MM signals
	assign waitrequest = wait_reg;
	assign validdata = read_queue[0];
	assign readdata = rdata_reg;

	// SDRAM signals
	assign sdram_cke = 1'b1;

	assign sdram_addr = (state_reg == s_active) ? addr_reg[1][19:8] :
	                    (state_reg == s_proc) ? {4'b0, addr_reg[0][7:0]} :
						(cmd_reg == PRECHARGE) ? (1'b1 << 10) :
	                    (cmd_reg == LOAD_MODE) ? mode_settings :
	                    12'b0;

	assign sdram_ba = (state_reg == s_active) ? addr_reg[1][21:20] :
	                  (state_reg == s_proc) ? addr_reg[0][21:20] :
	                  2'b00;

	assign {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = cmd_reg;

	assign sdram_dq = (state_reg == s_proc & write_reg[0]) ? wdata_reg[0] : 16'bz;
	assign sdram_dqm = (state_reg == s_proc) ? byteenable_n_reg[0] : 2'b11; 
endmodule
