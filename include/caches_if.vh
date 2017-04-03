`ifndef CACHES_IF_VH
`define CACHES_IF_VH

// ram memory types
`include "caches_types_package.vh"

interface caches_if;

  // import types
  import caches_types_package::*;

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

  modport cache_dp {
  	input halt, dmemREN, dmemWEN,
  	 	dmemstore, dmemstore,
  	output dhit, dmemload, flushed;
  };

  modport cache_mem {
  	input dwait, dload,
  	output dREN, dWEN, 
  		daddr, dstore
  };

  modport cache_sram {
  	input sramstate, cacheline,
  	output sramWEN, sramREN,
  		sramaddr, sramstore
  };