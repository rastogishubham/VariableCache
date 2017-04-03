`include "cache_types_package.vh"
`include "caches_if.vh"
import cache_types_package::*;
module dcache (
	input CLK, nRST,
	caches_if.cache_dp dcif,
	caches_if.cache_mem cif,
	caches_if.cache_sram csif
);

logic [WAYS - 1:0] match_arr;
logic [WAYS - 1:0] dirty_arr;
word_t dcachef;
logic match, dirty;
logic [MRU - 1:0] match_idx;
typedef enum logic [2:0] {IDLE, EVAL, LOAD, WB, WRITE_CACHE, HALT}; 
state_type;

state_type state, next_state;

always_ff @(posedge CLK, negedge nRST) 
begin
	if(~nRST)
	begin
		 state <= IDLE;
	end 
	else
		 state <= next_state;
end

always_comb
begin
	next_state = state;
	csif.sramWEN = 0;
	csif.sramREN = 0;
	csif.sramaddr = '0;
	csif.ramstore = '0;
	casez(state)
	
		IDLE:
		begin
			if((dcif.dmemWEN | dcif.dmemREN) & csif.sramstate == ACCESS)
				next_state = EVAL;
			else if(dcif.dmemWEN | dcif.dmemREN)
			begin
				csif.sramREN = 1;
				csif.sramaddr = {'0, dcachef.idx};
				next_state = IDLE;
			end
			else
				next_state = IDLE;
		end

		EVAL:
		begin

		end
	endcase
end

always_comb
begin
	match = 0;
	dirty = 0;
	for(integer i = 0; i < WAYS; i = i + 1)
	begin
		match_arr[i] = (csif.cacheline.set[i].tag == dcachef.tag) 
						& csif.cacheline.set[i].v;
		dirty_arr[i] = csif.cacheline.set[i].dirty;
		if(match_arr[i])
			match = 1;
		else if(dirty_arr[i] & match_arr[i])
		begin
			
		end
	end
end

assign dcachef = dcachef_t'(dcif.dmemaddr);