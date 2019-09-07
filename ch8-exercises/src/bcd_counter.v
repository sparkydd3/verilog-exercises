module bcd_counter
	(
		input wire iCLK, iRESET,
		input wire iEN, iCLEAR, iUP,
		output reg oMAX, oMIN,
		output reg [3:0] oBCD3, oBCD2, oBCD1, oBCD0
	);
	
	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			{oBCD3, oBCD2, oBCD1, oBCD0} <= 16'b0;
		else if (iCLEAR)
			{oBCD3, oBCD2, oBCD1, oBCD0} <= 16'b0;				
		else if (iEN & iUP)
			begin
				oBCD0 <= 
					bcd_inc(oBCD0);
				oBCD1 <= (oBCD0 == 4'd9) ? 
					bcd_inc(oBCD1) : oBCD1;
				oBCD2 <= (oBCD1 == 4'd9 && oBCD0 == 4'd9) ? 
					bcd_inc(oBCD2) : oBCD2;
				oBCD3 <= (oBCD2 == 4'd9 && oBCD1 == 4'd9 && oBCD0 == 4'd9) ?
					bcd_inc(oBCD3) : oBCD3;
			end
		else if (iEN & ~iUP)
			begin
				oBCD0 <= 
					bcd_dec(oBCD0);
				oBCD1 <= (oBCD0 == 4'd0) ? 
					bcd_dec(oBCD1) : oBCD1;
				oBCD2 <= (oBCD1 == 4'd0 && oBCD0 == 4'd0) ? 
					bcd_dec(oBCD2) : oBCD2;
				oBCD3 <= (oBCD2 == 4'd0 && oBCD1 == 4'd0 && oBCD0 == 4'd0) ?
					bcd_dec(oBCD3) : oBCD3;
			end
	
	always @*
		begin
			oMIN = 1'b0;
			oMAX = 1'b0;

			if ({oBCD3, oBCD2, oBCD1, oBCD0} == {4{4'd0}})
				oMIN = 1'b1;
			
			if ({oBCD3, oBCD2, oBCD1, oBCD0} == {4{4'd9}})
				oMAX = 1'b1;
		end

	function [3:0] bcd_inc(input [3:0] bcd_in);
		bcd_inc = (bcd_in == 4'd9) ? 4'd0 : bcd_in + 4'd1;
	endfunction

	function [3:0] bcd_dec(input [3:0] bcd_in);
		bcd_dec = (bcd_in == 4'd0) ? 4'd9 : bcd_in - 4'd1;
	endfunction
endmodule
