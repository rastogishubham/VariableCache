`include "cache_types_package.vh"
`include "replacement_if.vh"
import cache_types_package::*;
module replacement_block (
	input CLK, nRST,
	replacement_if.rep_cache rcif
);

always_ff @(posedge CLK, negedge nRST) 
begin
	if(nRST)
		rcif.way <= 0;
	else if(rcif.match)
		rcif.way <= match_idx - 1;
end
endmodule