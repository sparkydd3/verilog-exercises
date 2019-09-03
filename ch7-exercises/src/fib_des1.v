module fib_des1
	(
		input wire iCLK, iRESET,
		input wire iSTART,
		input wire [3:0] iBCD3, iBCD2, iBCD1, iBCD0,
		output reg oREADY, oDONE, oOFLOW,
		output wire [3:0] oBCD3, oBCD2, oBCD1, oBCD0
	);

	wire bcd2bin_done, fib_done, bin2bcd_done, bin2bcd_overflow;
	reg bcd2bin_start, fib_start, bin2bcd_start;
	wire [13:0] bcd_bin;
	wire [19:0] bin_fib;
	reg  [13:0] fib_bcd;

	bcd2bin bcd2bin_unit
		(.iCLK(iCLK), .iRESET(iRESET),
		 .iSTART(bcd2bin_start),
		 .iBCD3(iBCD3), .iBCD2(iBCD2), .iBCD1(iBCD1), .iBCD0(iBCD0),
		 .oREADY(), .oDONE(bcd2bin_done),
		 .oBIN(bcd_bin));
	
	fib fib_unit
		(.iCLK(iCLK), .iRESET(iRESET),
		 .iSTART(fib_start),
		 .iI(bcd_bin[4:0]),
		 .oREADY(), .oDONE(fib_done),
		 .oF(bin_fib));

	bin2bcd bin2bcd_unit
		(.iCLK(iCLK), .iRESET(iRESET),
		 .iSTART(bin2bcd_start),
		 .iBIN(fib_bcd),
		 .oREADY(), .oDONE(bin2bcd_done), .oOFLOW(bin2bcd_overflow),
		 .oBCD3(oBCD3), .oBCD2(oBCD2), .oBCD1(oBCD1), .oBCD0(oBCD0));

	localparam [1:0]
		idle    = 3'b00,
		bcd2bin = 3'b01,
		fib     = 3'b10,
		bin2bcd = 3'b11;
	
	reg [1:0] state_reg, state_next;
	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			state_reg <= idle;
		else
			state_reg <= state_next;
	
	always @*
	begin
		oREADY= 1'b0;
		oDONE = 1'b0;
		oOFLOW = bin2bcd_overflow;

		bcd2bin_start = 1'b0;
		fib_start = 1'b0;
		bin2bcd_start = 1'b0;
		state_next = state_reg;

		fib_bcd = bin_fib[12:0];	// default: fib output to bcd

		case (state_reg)
			idle:
				begin
					oREADY = 1'b1;
					if (iSTART)
						begin
							bcd2bin_start = 1'b1;
							state_next = bcd2bin;
						end
				end
			bcd2bin:
				if (bcd2bin_done)
					if (bcd_bin > 20)	// 21st fib overflows 
						begin
							fib_bcd = 14'd10000;		// replace input to bin2bcd module
							bin2bcd_start = 1'b1;	// skip fibonnachi calculation
							state_next = bin2bcd;
						end
					else
						begin
							fib_start = 1'b1;
							state_next = fib;
						end
			fib:
				if (fib_done)
					begin
						bin2bcd_start = 1'b1;
						state_next = bin2bcd;
					end
			bin2bcd:
				if (bin2bcd_done)
					begin
						oDONE = 1'b1;
						state_next = idle;
					end
		endcase
	end
endmodule
