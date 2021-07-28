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
	output [1:0] tick_tock_phase2_extern,
	
	input [30:0] tt_address [1:0],
	input [15:0] tt_data [1:0][3:0],
	input [2:0] tt_access_length [1:0],
	input tt_is_hyperfetch [1:0],
	input tt_is_byte_op [1:0],
	input tt_is_write_op [1:0],
	
	output out_soft_fault,
	output [15:0] cd_access_out_full_data [7:0],
	
	input  main_clk
);


wire cd_out_dirty;
wire [127:0] cd_raw_out_full_data;
wire [127:0] cd_raw_in_full_data;
wire is_cache_being_filled; // this is referring to being filled from DRAM


wire [30:0] cw_target_address;
wire cw_is_hyper_fetch;
wire cw_no_access;
wire cw_is_byte_op;
wire cw_is_write_op;
wire [2:0] cw_access_length;
wire [15:0] cw_data_in [3:0];

reg cd_is_byte_op=0;
reg cd_is_write_op=0;
reg [2:0] cd_access_length=0;

wire [10:0] addr_at_in_way_index;
wire soft_fault;
wire hard_fault;
wire any_fault; // includes no access faulting

wire was_hard_fault_starting;
wire was_hard_faulting;
reg signal_dram_of_hard_fault=0;
always @(posedge main_clk) signal_dram_of_hard_fault<=was_hard_fault_starting;

wire [10:0] cd_target_segment;
wire [1:0] cd_target_way;
wire [1:0] lru_least_used_way;
wire enable_data_and_lru;
wire [1:0] cd_way;
reg [15:0] cd_data_in [3:0];
reg [30:0] cd_target_address=0;

always @(posedge main_clk) begin
	if (!(hard_fault && !was_hard_faulting)) begin
		cd_target_address<=cw_target_address;
		cd_is_byte_op<=cw_is_byte_op;
		cd_is_write_op<=cw_is_write_op;
		cd_access_length<=cw_access_length;
		cd_data_in<=cw_data_in;
	end
end


reg change_way_for_data=0;


always @(posedge main_clk) begin
	if (hard_fault && !was_hard_faulting) change_way_for_data<=1;
	if (is_cache_being_filled) change_way_for_data<=0;
end


assign cd_target_way=change_way_for_data?lru_least_used_way:cd_way;
assign cd_target_segment=cd_target_address[14:4];

assign enable_data_and_lru=!any_fault;

reg [1:0] tick_tock_phase1=0;
reg [1:0] tick_tock_phase2=0;
assign tick_tock_phase2_extern=tick_tock_phase2;

assign cw_no_access=(tick_tock_phase0==tick_tock_phase1)?1'b1:1'b0;

assign cw_target_address=tt_address[tick_tock_phase1[0]];
assign cw_is_hyper_fetch=tt_is_hyperfetch[tick_tock_phase1[0]];
assign cw_is_byte_op=tt_is_byte_op[tick_tock_phase1[0]];
assign cw_is_write_op=tt_is_write_op[tick_tock_phase1[0]];
assign cw_access_length=tt_access_length[tick_tock_phase1[0]];
assign cw_data_in=tt_data[tick_tock_phase1[0]];


always @(posedge main_clk) begin
	tick_tock_phase2<=tick_tock_phase1;
	tick_tock_phase1<=tick_tock_phase1 + ((tick_tock_phase0!=tick_tock_phase1)?1'b1:1'b0);
	if (hard_fault) begin
		tick_tock_phase2<=tick_tock_phase2;
		tick_tock_phase1<=tick_tock_phase2;
	end
end

reg soft_fault_r=0;
assign out_soft_fault=soft_fault_r;
always @(posedge main_clk) soft_fault_r<=soft_fault;


cache_way cache_way(
	addr_at_in_way_index,
	
	soft_fault,
	hard_fault,
	any_fault,
	was_hard_fault_starting,
	was_hard_faulting,
	
	cd_way,
	
	lru_least_used_way, // cache way to set
	
	cw_target_address,
	cw_is_hyper_fetch,
	cw_no_access,
	
	is_cache_being_filled, // do_set_cache_way
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
	if (signal_dram_of_hard_fault) begin
		$display("signal_dram_of_hard_fault [%h]",cd_target_address);
	end
	if (hard_fault) begin
		$display("addr_at_in_way_index [%h,%h]",addr_at_in_way_index,cd_target_address);
	end
end



dram_controller dram_controller_inst(
	cd_target_address[25:15],
	addr_at_in_way_index,
	cd_target_address[14: 4],
	cd_raw_in_full_data,
	cd_raw_out_full_data,
	cd_out_dirty,
	
	signal_dram_of_hard_fault,
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


