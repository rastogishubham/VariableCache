`include "cache_types_package.vh"
`include "caches_if.vh"
import cache_types_package::*;
module cache_controller (
	input CLK, nRST,
	caches_if.cache_dp dcif,
	caches_if.cache_mem cif,
	caches_if.cache_sram csif,
	caches_if.cache_rep crif
);

logic [WAYS - 1:0] match_arr;
logic [WAYS - 1:0] dirty_arr;
dcachef_t dcachef;
logic match, dirty;
logic [MRU - 1:0] match_idx;
logic [WORD_COUNT - 1:0] count, next_count, blocknum, next_blocknum;
dcache_frame next_sramstore;
typedef enum logic [2:0] {IDLE, EVAL, LOAD, WB, WRITE_CACHE, HALT}
state_type;

state_type state, next_state;

always_ff @(posedge CLK, negedge nRST) 
begin
	if(~nRST)
	begin
		 state <= IDLE;
		 count <= '0;
		 blocknum <= '0;
		 csif.sramstore <= '0;

	end 
	else
		 state <= next_state;
		 count <= next_count;
		 blocknum <= next_blocknum;
		 csif.sramstore <= next_sramstore;
end

always_comb
begin
	next_state = state;
	next_count = count;
	next_blocknum = blocknum;
	next_sramstore = csif.sramstore;

	csif.sramWEN = 0;
	csif.sramREN = 0;
	csif.sramaddr = '0;
	csif.ramstore = '0;

	cif.dREN = 0;
	cif.dWEN = 0;

	dcif.dhit = 0;
	casez(state)
	
		IDLE:
		begin
			
			next_blocknum = 0;
			next_count = 0;

			if((dcif.dmemWEN | dcif.dmemREN) & csif.sramstate == ACCESS)
			begin
				next_state = EVAL;
				next_sramstore = csif.cacheline;
			end
			else if(dcif.dmemWEN | dcif.dmemREN)
			begin
				csif.sramREN = 1;
				csif.sramaddr = {'0, dcachef.idx};
				next_state = IDLE;
			end
			else if(dcif.halt)
			begin
				next_state = HALT;
			end
			else
				next_state = IDLE;
		end

		EVAL:
		begin

			if(match & dcif.dmemWEN)
			begin
				next_state = WRITE_CACHE;
				next_sramstore.set[match_idx].data[dcachef.blkoff] = dcif.dmemstore;
			end
			else if(match & dcif.dmemREN)
			begin
				next_state = IDLE;
				dcif.dmemload = csif.cacheline.set[match_idx].data[dcachef.blkoff];
				dcif.dhit = 1;
			end
			else if(!match & dirty)
			begin
				next_state = WB;
			end
			else
			begin
				next_state = LOAD;
			end
		end

		LOAD:
		begin
			cif.dREN = 1;
			if(count == WORDS)
				next_state = WRITE_CACHE;
			else
				next_state = LOAD;

			if(~count & ~cif.dwait)
			begin
				next_blocknum = blocknum + 1;
				next_count = count + 1;
				dcif.dhit = 1;
				next_sramstore.set[crif.way].data[blocknum] = dcif.dmemload;
			end
			else if(~count)
			begin
				cif.daddr = dcif.dmemaddr;
				next_blocknum = dcachef.idx;
			end
			else
			begin
				cif.daddr = {dcachef.tag, dcachef.idx, blocknum, dcachef.bytoff};
				if(~cif.dwait)
				begin
					next_blocknum = blocknum + 1;
					next_count = count + 1;
					next_sramstore.set[crif.way].data[blocknum] = dcif.dmemload;
				end
			end
		end

		WB:
		begin
			cif.dWEN = 1;
			if(count == WORDS)
			begin
				next_count = 0;
				next_state = LOAD;
			end
			else
				next_state = WB;

			if(~cif.dwait)
			begin
				next_count = count + 1;
			end
			else
			begin
				cif.daddr = {csif.cacheline.set[crif.way].tag, dcachef.idx, count, dcachef.bytoff};
				cif.dstore = csif.cacheline.set[crif.way].data[count];
			end
		end

		WRITE_CACHE:
		begin
			csif.sramWEN = 1;
			if(crif.sramstate == ACCESS)
				next_state = IDLE;
			else
				next_state = WRITE_CACHE;
		end

		HALT:
		begin
			dcif.flushed = 1;
			next_state = HALT;
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
		begin
			match = 1;
			match_idx = i;
		end
		if(dirty_arr[i] & match_arr[i])
		begin
			match = 1;
			dirty = 1;
			match_idx = i;
		end

	end
end

assign dcachef = dcachef_t'(dcif.dmemaddr);
assign crif.match_arr = match_arr;
assign crif.rep_daddr = dcif.dmemaddr;
assign crif.rep_cacheline = csif.cachelinel;
assign crif.match_idx = match_idx;
assign crif.match = (match & (dcif.dmemREN | dcif.dmemWEN) & state == EVAL);
endmodule