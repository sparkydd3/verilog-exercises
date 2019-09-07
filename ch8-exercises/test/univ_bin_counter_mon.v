`timescale 1 ns/10 ps

module univ_bin_counter_mon
	#(
		parameter N = 3
	)
	(
		input wire clk, reset,
		input wire iCLEAR, iLOAD, iEN, iUP,
		input wire [N-1:0] iD,
		input wire oMAX, oMIN,
		input wire [N-1:0] oQ,
		input integer fout
	);
	
	reg [N-1:0] q_old, gold;

	always @(posedge clk, posedge reset)
	begin
		if (reset)
			q_old <= 0;
		else
			#1 q_old <= oQ;

		if (reset | iCLEAR)
			gold = 0;
		else if (iLOAD)
			gold = iD;
		else if (iEN & iUP)
			gold = q_old + 1;
		else if (iEN & ~iUP)
			gold = q_old - 1;
		else
			gold = q_old;

		#1 if (oQ != gold)
			$fdisplay(fout, "[Error] (%5d ns) Expected: %0d, Got: %0d",
		          $time, gold, oQ);
	end
endmodule
