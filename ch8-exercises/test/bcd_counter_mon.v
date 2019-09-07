`timescale 1 ns/10 ps

module bcd_counter_mon
	(
		input wire clk, reset,
		input wire iEN, iCLEAR, iUP,
		input wire oMAX, oMIN,
		input wire [3:0] oBCD3, oBCD2, oBCD1, oBCD0,
		input integer fout
	);
	
	reg [3:0] bcd3_e, bcd2_e, bcd1_e, bcd0_e;
	reg max_e, min_e;
	integer count;
	localparam overflow_cnt = 9999;

	always @(posedge clk, posedge reset)
	begin
		if (reset)
			begin
				count = 0;
			end
		else
			begin
				if (iEN & iUP)
					count = (count == overflow_cnt) ? 0 : count + 1;
				else if (iEN & ~iUP)
					count = (count == 0) ? overflow_cnt : count - 1;
				else if (iCLEAR)
					count = 0;
			end

		#(1);
		bcd3_e = (count / 1000) % 10;
		bcd2_e = (count / 100) % 10;
		bcd1_e = (count / 10) % 10;
		bcd0_e = count % 10;
		
		max_e = (count == overflow_cnt);
		min_e = (count == 0);

		if ({oBCD3, oBCD2, oBCD1, oBCD0} != {bcd3_e, bcd2_e, bcd1_e, bcd0_e})
			$fdisplay(fout, "[Error]: (%5d ns) Incorrect bcd output", $time);

		if ({max_e, min_e} != {oMAX, oMIN})
			$fdisplay(fout, "[Error]: (%5d ns) Incorrect min/max tick", $time); 
	end
endmodule
