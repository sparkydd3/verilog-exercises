`timescale 1 ns/10 ps

module fibonacci_mon
	(
		input wire clk, reset,
		input wire iSTART,
		input wire [3:0] iN,
		input wire oREADY, oDONE,
		input wire [9:0] oFIB,
		input integer fout
	);

	integer fib_result;

	initial
	begin
		repeat(10000) @(posedge clk);
		$fdisplay(fout, "[Error] Watchdog failed.");
		$stop;
	end

	always @(posedge clk)
		if (oREADY & iSTART)
			fib_result = fib_calc(iN);
		else if (oDONE)
		begin
			#(1);
			if (fib_result != oFIB)
				$fdisplay(fout, "[Error] (%5d ns) Expected %d got %d",
					$time, fib_result, oFIB);
		end

	function integer fib_calc(input integer n);
		integer f0, f1, swp;
		begin
			f0 = 0;
			f1 = 1;
			while(n > 0)
				begin
					swp = f1;
					f1 = f1 + f0;
					f0 = swp;
					n = n - 1;
				end
			fib_calc = f0;
		end
	endfunction
endmodule
