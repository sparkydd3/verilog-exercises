module fifo
	#(
		parameter S = 16,
		          W = 8
	)
	(
		input wire iCLK, iRESET,
		input wire iENQ, iDEQ,
		input wire [W-1:0] iD,
		output reg oEMPTY, oFULL,
		output reg [W-1:0] oQ
	);

	localparam SW = $clog2(S);
	reg [W-1:0] fifo_reg [0:S-1];
	reg [SW-1:0] head, tail;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				head <= 0;
				tail <= 0;
				oEMPTY <= 1;
				oFULL <= 0;
			end
		else
			if (iENQ & ~iDEQ & ~oFULL)
				begin
					fifo_reg[head] <= iD;
					head <= inc(head);
					
					oEMPTY <= 0;
					oFULL <= (inc(head) == tail);
				end
			else if (iDEQ & ~iENQ & ~oEMPTY)
				begin
					tail <= inc(tail);
					oFULL <= 0;
					oEMPTY <= (inc(tail) == head);
				end
			else if (iDEQ & iENQ)
				begin
					fifo_reg[head] <= iD;
					tail <= inc(tail);
					head <= inc(head);
				end
	
	always @*
		oQ = fifo_reg[tail];
	
	function [SW-1:0] inc(input [SW-1:0] pointer);
		inc = (pointer == S - 1) ? 0 : pointer + 1;
	endfunction
endmodule
