`ifndef CACHES_IF_VH
`define CACHES_IF_VH

// ram memory types
`include "cache_types_package.vh"

interface caches_if;

  // import types
  import cache_types_package::*;

  logic          dwait, dREN, dWEN;
  word_t         dload, dstore;
  word_t         daddr;

  logic          sramWEN, sramREN;
  ramstate_t     sramstate;
  word_t         sramaddr;
  dcache_frame	 cacheline, sramstore;

  logic 		 halt, dmemREN, dmemWEN,
  				 flushed, dhit;
  word_t		 dmemstore, dmemaddr,
  				 dmemload;

  logic [MRU - 1:0] way, match_idx;
  dcache_frame rep_cacheline;
  word_t rep_daddr;
  logic match;


  modport cache_dp (
  	input halt, dmemREN, dmemWEN,
  	 	dmemstore, dmemaddr,
  	output dhit, dmemload, flushed
  );

  modport cache_mem (
  	input dwait, dload,
  	output dREN, dWEN, 
  		daddr, dstore
  );

  modport cache_sram (
  	input sramstate, cacheline,
  	output sramWEN, sramREN,
  		sramaddr, sramstore
  );

  modport cache_rep (
    input way,
    output rep_cacheline,
      rep_daddr, match_idx,
      match
  );

endinterface
`endif