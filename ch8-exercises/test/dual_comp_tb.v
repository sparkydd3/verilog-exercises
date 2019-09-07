module dual_comp_tb();
	
	localparam T = 20;	// clock period
	localparam W = 8;	// data width

	reg signed_i;
	reg [W-1:0] a_i, b_i;
	reg gt_e;
	wire gt_o;
	integer log_file, console_file, out_file;

	localparam N = 5;
	reg [2*W+1:0] test_v [0:N-1];
	integer i;

	initial
	begin
		log_file = $fopen("dual_comp_tb.log");
		if (!log_file)
			$display("Cannot open log file");
		console_file = 32'h0000_0001;
		out_file = log_file | console_file;

		$readmemb("../test/dual_comp_tb.tv", test_v);

		for(i = 0; i < N; i = i + 1)
			begin
				{a_i, b_i, signed_i, gt_e} = test_v[i];
				#20;
				if (gt_o != gt_e)
					$fdisplay(out_file, "[Error] (%5d ns) Test vector $d failed",
						$time, i);
			end	

		$fdisplay(out_file, "(%5d ns) Test Completed.", $time);
	end

	dual_comp #(.W(W)) uut
		(.iA(a_i), .iB(b_i),
		 .iSIGNED(signed_i),
		 .oGT(gt_o));
endmodule
