`ifndef ASSERT_VH
`define ASSERT_VH
`define ASSERT(test, msg)\
	if(!(test)) $write("[Error] %s: %s\n", `__FILE__, $sformatf msg)
`endif
