`timescale 1 ns/10 ps

module fifo_mon
	#(
		parameter W = 8,
		          S = 16
	)
	(
		input wire clk, reset,
		input wire iENQ, iDEQ,
		input wire [W-1:0] iD,
		output wire oFULL, oEMPTY,
		output wire [W-1:0] oQ,
		input integer fout
	);

	reg [W-1:0] q_e;
	reg full_e, empty_e;
	integer elements;
	integer dequeue_element;

	always @(posedge clk, posedge reset)
	begin
		if (reset)
			begin
				elements = 0;
				dequeue_element = 0;
			end
		else
			if (iENQ)
					elements = (elements == S) ? S : elements + 1;
			else if (iDEQ)
				begin
					elements = (elements == 0) ? 0 : elements - 1;
					dequeue_element = dequeue_element + 1;
				end
		#1;
		full_e = (elements == S);
		empty_e = (elements == 0);

		if (full_e != oFULL)
			$fdisplay(fout, "[Error]: (%5d ns) expected full", $time);

		if (empty_e != oEMPTY)
			$fdisplay(fout, "[Error]: (%5d ns) expected empty", $time);

		if (~oEMPTY && oQ != dequeue_element)
			$fdisplay(fout, "[Error]: (%5d ns) expected %0d, got %0d",
				$time, dequeue_element, oQ);
	end
endmodule
