`ifndef CACHE_TYPES_PACKAGE_VH
`define CACHE_TYPES_PACKAGE_VH
package cpu_types_package;

	parameter WAYS = 2;
	parameter WORDS = 2;
	parameter DTAG_W = 26;
	parameter WORD_W = 32;
	parameter DIDX_W = 3;
	parameter DBLK_W = 1;
	parameter DBYT_W = 2;
	parameter PAD = 32 - DIDX_W;
	parameter MRU = $clog(WAYS);

	typedef logic [WORD_W-1:0] word_t;

  	typedef enum logic [1:0] {
    	FREE,
    	BUSY,
    	ACCESS,
    	ERROR
  	} ramstate_t;

	typedef struct packed {
		logic v;
		logic dirty;
		logic [DTAG_W - 1:0] tag;
		word_t [WORDS - 1:0] data; 
	} dcache_entry;

	typedef struct packed {
		dcache_entry [WAYS - 1:0] set;
		logic [MRU - 1:0] most;
	} dcache_frame;

	typedef struct packed {
    	logic [DTAG_W - 1:0]  tag;
    	logic [DIDX_W - 1:0]  idx;
    	logic [DBLK_W - 1:0]  blkoff;
    	logic [DBYT_W - 1:0]  bytoff;
  } dcachef_t;
