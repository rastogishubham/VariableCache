`ifndef REPLACEMENT_IF_VH
`define REPLACEMENT_IF_VH

// ram memory types
`include "cache_types_package.vh"

interface replacement_if;

  // import types
  import cache_types_package::*;

  logic [MRU - 1:0] way, match_idx;
  dcache_frame cacheline;
  word_t daddr;
  logic match;

  modport rep_cache (
  	input cacheline,
  		addr, match_idx,
  		match,
    output way
  );

endinterface
`endif