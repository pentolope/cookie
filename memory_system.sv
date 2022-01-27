`timescale 1 ps / 1 ps

`include "dram_controller.sv"
`include "cache_lru.sv"
`include "cache_data.sv"
`include "cache_way.sv"

module memory_system(
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,
	
	input  [1:0] tick_tock_phase0,
	output [1:0] tick_tock_phase1_extern,
	output [1:0] tick_tock_phase2_extern,
	output tick_tock_phase2_moved_extern,
	
	input [30:0] tt_address [1:0],
	input [15:0] tt_data_in0 [3:0],
	input [15:0] tt_data_in1 [3:0],
	input [1:0] tt_move [1:0],
	input tt_secondary [1:0],
	input [2:0] tt_access_length [1:0],
	input tt_is_byte_op [1:0],
	input tt_is_write_op [1:0],
	
	output [15:0] cd_access_out_full_data [7:0],
	
	input  main_clk
);

reg [1:0] tick_tock_phase1=0;
reg [1:0] tick_tock_phase2=0;
reg tick_tock_phase2_moved=0;
assign tick_tock_phase1_extern=tick_tock_phase1;
assign tick_tock_phase2_extern=tick_tock_phase2;
assign tick_tock_phase2_moved_extern=tick_tock_phase2_moved;


wire cd_out_dirty;
wire [127:0] cd_raw_out_full_data;
wire [127:0] cd_raw_in_full_data;
wire is_cache_being_filled; // this is referring to being filled from DRAM


wire [30:0] cw_target_address;
wire cw_no_access;
wire cw_is_byte_op;
wire cw_is_write_op;
wire [2:0] cw_access_length;
wire [15:0] cw_data_in [3:0];
wire [1:0] cw_move;
wire cw_secondary;

reg cd_is_byte_op=0;
reg cd_is_write_op=0;
reg [2:0] cd_access_length=0;

wire [10:0] addr_at_in_way_index;
wire hard_fault;
wire any_fault; // includes no access faulting

wire was_hard_fault_starting;
wire was_hard_faulting;

wire [10:0] cd_target_segment;
wire [1:0] cd_target_way;
wire [1:0] lru_least_used_way;
wire enable_data_and_lru;
wire [1:0] cd_way;
reg [15:0] cd_data_in [3:0];

reg [30:0] cd_target_address=0;

reg [30:0] raw_address;
always_comb begin
	raw_address=tt_address[tick_tock_phase1[0]];
	if (tt_secondary[tick_tock_phase1[0]]) begin
		raw_address=raw_address+5'd16;
		raw_address[3:0]=4'h0;
	end
end

wire [15:0] moved_data_in [3:0];
wire [15:0] almost_moved_data [3:0];
wire [15:0] moving_data_mux [3:0][3:0];
wire [1:0] move_value;
assign almost_moved_data=tick_tock_phase1[0]?tt_data_in1:tt_data_in0;
assign move_value=tt_move[tick_tock_phase1[0]];
assign moving_data_mux[0][2:0]=almost_moved_data[3:1];
assign moving_data_mux[0][  3]=16'hx;
assign moving_data_mux[1][1:0]=almost_moved_data[3:2];
assign moving_data_mux[1][3:2]='{16'hx,16'hx};
assign moving_data_mux[2][  0]=almost_moved_data[3  ];
assign moving_data_mux[2][3:1]='{16'hx,16'hx,16'hx};
assign moving_data_mux[3][3:0]=almost_moved_data[3:0];
assign moved_data_in=moving_data_mux[move_value];


always @(posedge main_clk) begin
	cd_target_address<=cw_target_address;
	cd_is_byte_op<=cw_is_byte_op;
	cd_is_write_op<=cw_is_write_op;
	cd_access_length<=cw_access_length;
	cd_data_in<=cw_data_in;
end


reg change_way_for_data=0;


always @(posedge main_clk) begin
	if (hard_fault && !was_hard_faulting) change_way_for_data<=1;
	if (is_cache_being_filled) change_way_for_data<=0;
end


assign cd_target_way=change_way_for_data?lru_least_used_way:cd_way;
assign cd_target_segment=cd_target_address[14:4];

assign enable_data_and_lru=!any_fault;


assign cw_no_access=(tick_tock_phase0==tick_tock_phase1 && !was_hard_faulting)?1'b1:1'b0;

assign cw_target_address=hard_fault?cd_target_address:raw_address;
assign cw_is_byte_op=hard_fault?cd_is_byte_op:tt_is_byte_op[tick_tock_phase1[0]];
assign cw_is_write_op=hard_fault?cd_is_write_op:tt_is_write_op[tick_tock_phase1[0]];
assign cw_access_length=hard_fault?cd_access_length:tt_access_length[tick_tock_phase1[0]];
assign cw_data_in=hard_fault?cd_data_in:moved_data_in;


always @(posedge main_clk) begin
	if (!hard_fault) begin
		tick_tock_phase2_moved<=(tick_tock_phase2!=tick_tock_phase1)? 1'b1:1'b0;
		tick_tock_phase2<=tick_tock_phase1;
		tick_tock_phase1<=tick_tock_phase1 + ((tick_tock_phase0!=tick_tock_phase1)?1'b1:1'b0);
	end else begin
		tick_tock_phase2_moved<=0;
	end
end

cache_way cache_way(
	addr_at_in_way_index,
	
	hard_fault,
	any_fault,
	was_hard_fault_starting,
	was_hard_faulting,
	
	cd_way,
	
	lru_least_used_way, // cache way to set
	
	cw_target_address,
	cw_no_access,
	
	is_cache_being_filled, // do_write
	main_clk
);

cache_data cache_data_inst(
	cd_out_dirty,

	cd_access_out_full_data,
	cd_raw_out_full_data,
	
	cd_data_in,
	cd_raw_in_full_data,

	cd_target_segment,
	cd_target_way,

	cd_is_write_op,
	cd_is_byte_op,
	
	cd_target_address[0], // byte_operation_polarity
	cd_target_address[3:1], // word_offset
	cd_access_length,
	is_cache_being_filled, // do_full_write
	
	any_fault,
	main_clk
);

cache_LRU cache_LRU_inst(
	lru_least_used_way,

	cd_target_segment, // lru_addr
	cd_target_way, // lru_used_index
	enable_data_and_lru,
	main_clk
);

always @(posedge main_clk) begin
	if (was_hard_fault_starting) $display("hard fault start at %t",$time);
end
wire [30:0] evicted_address;assign evicted_address={addr_at_in_way_index,cd_target_address[14: 4],4'b0};

dram_controller dram_controller_inst(
	cd_target_address[25:15],
	addr_at_in_way_index,
	cd_target_address[14: 4],
	cd_raw_in_full_data,
	cd_raw_out_full_data,
	cd_out_dirty,
	
	was_hard_fault_starting, // signal_dram_of_hard_fault
	is_cache_being_filled,
	
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_CKE,
	DRAM_CS_N,
	DRAM_DQ,
	DRAM_LDQM,
	DRAM_RAS_N,
	DRAM_UDQM,
	DRAM_WE_N,
	
	main_clk
);

endmodule


