`timescale 1 ps / 1 ps

`include "utilities.sv"
`include "internal_memory.sv"
`include "vga_driver.sv"
`include "instruction_cache.sv"
`include "scheduler.sv"
`include "core_executer.sv"


module core_main(
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
	
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		     [3:0]		VGA_R,
	output		          		VGA_HS,
	output		          		VGA_VS,

	input vga_clk,
	input main_clk,
	
	output [15:0] debug_user_reg [15:0],
	output [15:0] debug_stack_pointer,
	output [25:0] debug_instruction_fetch_address,
	input debug_scheduler

);

reg [15:0] stack_pointer=16'h0000;
reg [15:0] stack_pointer_m2=16'hFFFE;
reg [15:0] stack_pointer_m4=16'hFFFC;
reg [15:0] stack_pointer_m6=16'hFFFA;
reg [15:0] stack_pointer_m8=16'hFFF8;

reg [15:0] stack_pointer_p2=16'h0002;
reg [15:0] stack_pointer_p4=16'h0004;

reg [15:0] user_reg [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};


wire [16:0] executer0DoWrite;
wire [15:0] executer0WriteValues [16:0];
wire [16:0] executer1DoWrite;
wire [15:0] executer1WriteValues [16:0];
wire [16:0] executer2DoWrite;
wire [15:0] executer2WriteValues [16:0];
wire [16:0] executer3DoWrite;
wire [15:0] executer3WriteValues [16:0];

wire [31:0] instruction_jump_address_executer [3:0];
wire jump_signal_executer [3:0];
wire [31:0] instruction_jump_address_selected=
	(instruction_jump_address_executer[0] & {32{jump_signal_executer[0]}}) | 
	(instruction_jump_address_executer[1] & {32{jump_signal_executer[1]}}) | 
	(instruction_jump_address_executer[2] & {32{jump_signal_executer[2]}}) | 
	(instruction_jump_address_executer[3] & {32{jump_signal_executer[3]}});

wire [3:0] memory_dependency_clear;

///

wire [ 2:0] mem_stack_access_size_all [3:0];
wire [15:0] mem_target_address_stack_all [3:0];
wire [31:0] mem_target_address_general_all [3:0];

wire [15:0] mem_data_in_all [3:0][3:0];

wire [3:0] mem_is_stack_access_write_all;
wire [3:0] mem_is_stack_access_requesting_all;

wire [3:0] mem_is_general_access_write_all;
wire [3:0] mem_is_general_access_byte_operation_all;
wire [3:0] mem_is_general_access_requesting_all;

wire [3:0] mem_is_general_or_stack_access_acknowledged_pulse;
wire [3:0] mem_will_general_or_stack_access_be_acknowledged_pulse;

///


wire [25:0] mem_target_address_instruction_fetch;

wire mem_is_instruction_fetch_requesting;
wire mem_is_instruction_fetch_acknowledged_pulse;

wire [15:0] mem_data_out_type_0 [7:0];
wire [15:0] mem_data_out_type_1 [7:0];

wire [25:0] mem_target_address_hyper_instruction_fetch_0;
wire [25:0] mem_target_address_hyper_instruction_fetch_1;

wire mem_is_hyper_instruction_fetch_0_requesting;
wire mem_is_hyper_instruction_fetch_0_acknowledged_pulse;

wire mem_is_hyper_instruction_fetch_1_requesting;
wire mem_is_hyper_instruction_fetch_1_acknowledged_pulse;


wire mem_void_hyper_instruction_fetch;

///
wire [15:0] new_instruction_table [3:0];
wire [25:0] new_instruction_address_table [3:0];

wire [4:0] fifo_instruction_cache_size;
wire [4:0] fifo_instruction_cache_size_after_read;
wire [2:0] fifo_instruction_cache_consume_count;


wire [1:0] jump_executer_index={jump_signal_executer[2] | jump_signal_executer[3],jump_signal_executer[1] | jump_signal_executer[3]}; // only should be considered valid if there is a single executer doing a jump this cycle
wire is_performing_jump_instant_on=jump_signal_executer[0] | jump_signal_executer[1] | jump_signal_executer[2] | jump_signal_executer[3];
wire is_performing_jump_state;
wire is_performing_jump;

instruction_cache instruction_cache_inst(
	mem_is_instruction_fetch_requesting,
	mem_is_hyper_instruction_fetch_0_requesting,
	mem_is_hyper_instruction_fetch_1_requesting,
	mem_void_hyper_instruction_fetch,
	is_performing_jump_state,
	is_performing_jump,
	fifo_instruction_cache_size,
	mem_target_address_instruction_fetch,
	mem_target_address_hyper_instruction_fetch_0,
	mem_target_address_hyper_instruction_fetch_1,
	new_instruction_table,
	new_instruction_address_table,
	
	fifo_instruction_cache_size_after_read,
	fifo_instruction_cache_consume_count,
	mem_is_instruction_fetch_acknowledged_pulse,
	mem_is_hyper_instruction_fetch_0_acknowledged_pulse,
	mem_is_hyper_instruction_fetch_1_acknowledged_pulse,
	is_performing_jump_instant_on,
	jump_executer_index,
	instruction_jump_address_selected,
	mem_data_out_type_0,
	user_reg,
	main_clk
);

wire [15:0] instant_updated_core_values [16:0];

recomb_mux_all_user_reg recomb_mux_full(
	instant_updated_core_values[15:0],
	user_reg,
	'{executer3DoWrite[15:0],executer2DoWrite[15:0],executer1DoWrite[15:0],executer0DoWrite[15:0]},
	executer0WriteValues[15:0],
	executer1WriteValues[15:0],
	executer2WriteValues[15:0],
	executer3WriteValues[15:0]
);
recomb_mux recomb_mux_16(
	instant_updated_core_values[16],
	stack_pointer,
	{executer3DoWrite[16] , executer2DoWrite[16] , executer1DoWrite[16] , executer0DoWrite[16]},
	'{executer3WriteValues[16],executer2WriteValues[16],executer1WriteValues[16],executer0WriteValues[16]}
);


always @(posedge main_clk) begin
	assert ((executer0DoWrite & executer1DoWrite)==0);
	assert ((executer0DoWrite & executer2DoWrite)==0);
	assert ((executer0DoWrite & executer3DoWrite)==0);
	assert ((executer1DoWrite & executer2DoWrite)==0);
	assert ((executer1DoWrite & executer3DoWrite)==0);
	assert ((executer2DoWrite & executer3DoWrite)==0);
end


always @(posedge main_clk) begin
	user_reg<=instant_updated_core_values[15:0];
	stack_pointer   <=instant_updated_core_values[16];
	stack_pointer_m2<=instant_updated_core_values[16]-5'd2;
	stack_pointer_m4<=instant_updated_core_values[16]-5'd4;
	stack_pointer_m6<=instant_updated_core_values[16]-5'd6;
	stack_pointer_m8<=instant_updated_core_values[16]-5'd8;
	stack_pointer_p2<=instant_updated_core_values[16]+5'd2;
	stack_pointer_p4<=instant_updated_core_values[16]+5'd4;
	stack_pointer[0]   <=1'b0;
	stack_pointer_m2[0]<=1'b0;
	stack_pointer_m4[0]<=1'b0;
	stack_pointer_m6[0]<=1'b0;
	stack_pointer_m8[0]<=1'b0;
	stack_pointer_p2[0]<=1'b0;
	stack_pointer_p4[0]<=1'b0;
end


wire [4:0] new_instructionID_table [3:0];
assign new_instructionID_table[0]=(& new_instruction_table[0][15:12])?{1'b1,new_instruction_table[0][11:8]}:{1'b0,new_instruction_table[0][15:12]};
assign new_instructionID_table[1]=(& new_instruction_table[1][15:12])?{1'b1,new_instruction_table[1][11:8]}:{1'b0,new_instruction_table[1][15:12]};
assign new_instructionID_table[2]=(& new_instruction_table[2][15:12])?{1'b1,new_instruction_table[2][11:8]}:{1'b0,new_instruction_table[2][15:12]};
assign new_instructionID_table[3]=(& new_instruction_table[3][15:12])?{1'b1,new_instruction_table[3][11:8]}:{1'b0,new_instruction_table[3][15:12]};

wire [15:0] instructionCurrent_scheduler [3:0];
wire [4:0] instructionCurrentID_scheduler [3:0];

wire [25:0] current_instruction_address_table [3:0];

wire executerEnable [3:0];
wire executerWillBeEnabled [3:0];

wire is_instruction_finishing_this_cycle_pulse_0;
wire is_instruction_finishing_this_cycle_pulse_1;
wire is_instruction_finishing_this_cycle_pulse_2;
wire is_instruction_finishing_this_cycle_pulse_3;

wire will_instruction_finish_next_cycle_pulse_0;
wire will_instruction_finish_next_cycle_pulse_1;
wire will_instruction_finish_next_cycle_pulse_2;
wire will_instruction_finish_next_cycle_pulse_3;


scheduler scheduler_inst(
	executerEnable,
	executerWillBeEnabled,
	instructionCurrent_scheduler,
	instructionCurrentID_scheduler,
	current_instruction_address_table,
	fifo_instruction_cache_size_after_read,
	fifo_instruction_cache_consume_count,
	
	is_performing_jump_instant_on,
	is_performing_jump_state,
	jump_executer_index,
	fifo_instruction_cache_size,
	new_instruction_table,
	new_instructionID_table,
	new_instruction_address_table,
	memory_dependency_clear,
	'{is_instruction_finishing_this_cycle_pulse_3,is_instruction_finishing_this_cycle_pulse_2,is_instruction_finishing_this_cycle_pulse_1,is_instruction_finishing_this_cycle_pulse_0},
	'{ will_instruction_finish_next_cycle_pulse_3, will_instruction_finish_next_cycle_pulse_2, will_instruction_finish_next_cycle_pulse_1, will_instruction_finish_next_cycle_pulse_0},
	debug_scheduler,
	main_clk
);


core_executer core_executer_inst0(
	instructionCurrent_scheduler[0],
	instructionCurrentID_scheduler[0],
	current_instruction_address_table[0],
	executerEnable[0],
	executerWillBeEnabled[0],
	user_reg,
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	stack_pointer,
	stack_pointer_m2,
	stack_pointer_m4,
	stack_pointer_m6,
	stack_pointer_m8,
	stack_pointer_p2,
	stack_pointer_p4,
	executer0DoWrite,
	executer0WriteValues,
	
	mem_stack_access_size_all[0],
	mem_target_address_stack_all[0],
	mem_target_address_general_all[0],
	
	mem_data_out_type_1[0],
	mem_data_out_type_1[4:0],
	mem_data_in_all[0],
	
	mem_is_stack_access_write_all[0],
	mem_is_stack_access_requesting_all[0],
	mem_is_general_access_write_all[0],
	mem_is_general_access_byte_operation_all[0],
	mem_is_general_access_requesting_all[0],
	mem_is_general_or_stack_access_acknowledged_pulse[0],
	mem_will_general_or_stack_access_be_acknowledged_pulse[0],
	
	is_instruction_finishing_this_cycle_pulse_0,
	will_instruction_finish_next_cycle_pulse_0,
	
	instruction_jump_address_executer[0],
	jump_signal_executer[0],
	
	main_clk
);

core_executer core_executer_inst1(
	instructionCurrent_scheduler[1],
	instructionCurrentID_scheduler[1],
	current_instruction_address_table[1],
	executerEnable[1],
	executerWillBeEnabled[1],
	user_reg,
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	stack_pointer,
	stack_pointer_m2,
	stack_pointer_m4,
	stack_pointer_m6,
	stack_pointer_m8,
	stack_pointer_p2,
	stack_pointer_p4,
	executer1DoWrite,
	executer1WriteValues,
	
	mem_stack_access_size_all[1],
	mem_target_address_stack_all[1],
	mem_target_address_general_all[1],
	
	mem_data_out_type_1[0],
	mem_data_out_type_1[4:0],
	mem_data_in_all[1],
	
	mem_is_stack_access_write_all[1],
	mem_is_stack_access_requesting_all[1],
	mem_is_general_access_write_all[1],
	mem_is_general_access_byte_operation_all[1],
	mem_is_general_access_requesting_all[1],
	mem_is_general_or_stack_access_acknowledged_pulse[1],
	mem_will_general_or_stack_access_be_acknowledged_pulse[1],
	
	is_instruction_finishing_this_cycle_pulse_1,
	will_instruction_finish_next_cycle_pulse_1,
	
	instruction_jump_address_executer[1],
	jump_signal_executer[1],
	
	main_clk
);

core_executer core_executer_inst2(
	instructionCurrent_scheduler[2],
	instructionCurrentID_scheduler[2],
	current_instruction_address_table[2],
	executerEnable[2],
	executerWillBeEnabled[2],
	user_reg,
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	stack_pointer,
	stack_pointer_m2,
	stack_pointer_m4,
	stack_pointer_m6,
	stack_pointer_m8,
	stack_pointer_p2,
	stack_pointer_p4,
	executer2DoWrite,
	executer2WriteValues,
	
	mem_stack_access_size_all[2],
	mem_target_address_stack_all[2],
	mem_target_address_general_all[2],
	
	mem_data_out_type_1[0],
	mem_data_out_type_1[4:0],
	mem_data_in_all[2],
	
	mem_is_stack_access_write_all[2],
	mem_is_stack_access_requesting_all[2],
	mem_is_general_access_write_all[2],
	mem_is_general_access_byte_operation_all[2],
	mem_is_general_access_requesting_all[2],
	mem_is_general_or_stack_access_acknowledged_pulse[2],
	mem_will_general_or_stack_access_be_acknowledged_pulse[2],
	
	is_instruction_finishing_this_cycle_pulse_2,
	will_instruction_finish_next_cycle_pulse_2,
	
	instruction_jump_address_executer[2],
	jump_signal_executer[2],
	
	main_clk
);

core_executer core_executer_inst3(
	instructionCurrent_scheduler[3],
	instructionCurrentID_scheduler[3],
	current_instruction_address_table[3],
	executerEnable[3],
	executerWillBeEnabled[3],
	user_reg,
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	stack_pointer,
	stack_pointer_m2,
	stack_pointer_m4,
	stack_pointer_m6,
	stack_pointer_m8,
	stack_pointer_p2,
	stack_pointer_p4,
	executer3DoWrite,
	executer3WriteValues,
	
	mem_stack_access_size_all[3],
	mem_target_address_stack_all[3],
	mem_target_address_general_all[3],
	
	mem_data_out_type_1[0],
	mem_data_out_type_1[4:0],
	mem_data_in_all[3],
	
	mem_is_stack_access_write_all[3],
	mem_is_stack_access_requesting_all[3],
	mem_is_general_access_write_all[3],
	mem_is_general_access_byte_operation_all[3],
	mem_is_general_access_requesting_all[3],
	mem_is_general_or_stack_access_acknowledged_pulse[3],
	mem_will_general_or_stack_access_be_acknowledged_pulse[3],
	
	is_instruction_finishing_this_cycle_pulse_3,
	will_instruction_finish_next_cycle_pulse_3,
	
	instruction_jump_address_executer[3],
	jump_signal_executer[3],
	
	main_clk
);


full_memory full_memory_inst(
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
	
	VGA_B,
	VGA_G,
	VGA_R,
	VGA_HS,
	VGA_VS,
	
	// for all memory access ports, once a request has begun to be issued, it should not be changed before it is acknowledged. hyper_instruction_fetch has a void signal that allows it to change
	
	mem_stack_access_size_all,
	mem_target_address_stack_all,
	mem_is_stack_access_write_all,
	mem_is_stack_access_requesting_all,
	
	mem_target_address_general_all,
	// target_address_general is allowed to access I/O mapped memory regions and can be any type of memory access 
	mem_data_in_all,
	
	mem_is_general_access_write_all,
	mem_is_general_access_byte_operation_all,
	mem_is_general_access_requesting_all,

	mem_is_general_or_stack_access_acknowledged_pulse,
	mem_will_general_or_stack_access_be_acknowledged_pulse,
	
	mem_target_address_hyper_instruction_fetch_0,
	mem_target_address_hyper_instruction_fetch_1,
	// target_address_hyper_instruction_fetch_x is very similiar to target_address_instruction_fetch
	// However, it will NEVER cause a cache fault to DRAM because it is a suggestion to read memory when it is unknown if memory at that location will actually be needed.
	// This request is always serviced at miniumum priority, therefore all other accesses will occur before either of these accesses occure.
	// Further, if target_address_hyper_instruction_fetch_0 is not in cache, then target_address_hyper_instruction_fetch_1 will not be accessed.
	// target_address_hyper_instruction_fetch_0 will always be served before target_address_hyper_instruction_fetch_1
	// these accesses use data_out_type_0_extern
	
	mem_is_hyper_instruction_fetch_0_requesting,
	mem_is_hyper_instruction_fetch_0_acknowledged_pulse,
	mem_is_hyper_instruction_fetch_1_requesting,
	mem_is_hyper_instruction_fetch_1_acknowledged_pulse,
	
	mem_void_hyper_instruction_fetch, // when on, this will void any in-progress hyper instruction fetches. This is needed to ensure validity in some edge cases. it does NOT void the request that is being requested on the same cycle that this is on
	
	mem_target_address_instruction_fetch,
	// target_address_instruction_fetch is not allowed to access I/O mapped memory regions, and must be a word read. 
	// the entire cache lane is given for where the word read falls. The amount of valid words returned is trivial to calculate elsewhere, so it is not given
	// this access uses data_out_type_0_extern
	
	mem_is_instruction_fetch_requesting,
	mem_is_instruction_fetch_acknowledged_pulse,
	
	mem_data_out_type_0, // type_0 always uses the single access
	mem_data_out_type_1, // type_1 potentially uses the multi access
	
	memory_dependency_clear,
	
	vga_clk,
	main_clk
);



assign debug_instruction_fetch_address=mem_target_address_instruction_fetch;
assign debug_stack_pointer=stack_pointer;
assign debug_user_reg=user_reg;


endmodule
