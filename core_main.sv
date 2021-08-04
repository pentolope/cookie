`timescale 1 ps / 1 ps

`include "utilities.sv"
`include "memory_interface.sv"
`include "instruction_cache.sv"
`include "dependancy_generation.sv"
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
	
	input  [15:0] data_out_io,
	output [15:0] data_in_io,
	output [31:0] address_io,
	output [1:0] control_io,
	
	input main_clk,
	
	output [15:0] debug_user_reg [15:0],
	output [15:0] debug_stack_pointer,
	output [25:0] debug_instruction_fetch_address,
	input debug_scheduler

);

reg [15:0] stack_pointer=0;

reg [15:0] user_reg [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

always @(posedge main_clk) begin
	if (^user_reg[0]===1'bx) $stop;
	if (^user_reg[1]===1'bx) $stop;
	if (^user_reg[2]===1'bx) $stop;
	if (^user_reg[3]===1'bx) $stop;
	if (^user_reg[4]===1'bx) $stop;
	if (^user_reg[5]===1'bx) $stop;
	if (^user_reg[6]===1'bx) $stop;
	if (^user_reg[7]===1'bx) $stop;
	if (^user_reg[8]===1'bx) $stop;
	if (^user_reg[9]===1'bx) $stop;
	if (^user_reg[10]===1'bx) $stop;
	if (^user_reg[11]===1'bx) $stop;
	if (^user_reg[12]===1'bx) $stop;
	if (^user_reg[13]===1'bx) $stop;
	if (^user_reg[14]===1'bx) $stop;
	if (^user_reg[15]===1'bx) $stop;
	if (^stack_pointer===1'bx) $stop;
end

wire [16:0] executer0DoWrite;
wire [15:0] executer0WriteValues [16:0];
wire [16:0] executer1DoWrite;
wire [15:0] executer1WriteValues [16:0];
wire [16:0] executer2DoWrite;
wire [15:0] executer2WriteValues [16:0];
wire [16:0] executer3DoWrite;
wire [15:0] executer3WriteValues [16:0];
wire [16:0] executer4DoWrite;
wire [15:0] executer4WriteValues [16:0];
wire [16:0] executer5DoWrite;
wire [15:0] executer5WriteValues [16:0];
wire [16:0] executer6DoWrite;
wire [15:0] executer6WriteValues [16:0];
wire [16:0] executer7DoWrite;
wire [15:0] executer7WriteValues [16:0];

wire [2:0] jump_next_executer_index;
wire [31:0] instruction_jump_address_next_executer [7:0];
wire [7:0] jump_signal_executer;
wire [7:0] jump_signal_next_executer;
reg [31:0] instruction_jump_address_selected=0;

always @(posedge main_clk) begin
	instruction_jump_address_selected<=
		(instruction_jump_address_next_executer[0] & {32{jump_signal_next_executer[0]}}) | 
		(instruction_jump_address_next_executer[1] & {32{jump_signal_next_executer[1]}}) | 
		(instruction_jump_address_next_executer[2] & {32{jump_signal_next_executer[2]}}) | 
		(instruction_jump_address_next_executer[3] & {32{jump_signal_next_executer[3]}}) |
		(instruction_jump_address_next_executer[4] & {32{jump_signal_next_executer[4]}}) | 
		(instruction_jump_address_next_executer[5] & {32{jump_signal_next_executer[5]}}) | 
		(instruction_jump_address_next_executer[6] & {32{jump_signal_next_executer[6]}}) | 
		(instruction_jump_address_next_executer[7] & {32{jump_signal_next_executer[7]}});
end

wire [7:0] memory_dependency_clear;

///

wire [ 2:0] mem_stack_access_size_all [7:0];
wire [31:0] mem_target_address_all [7:0];

wire [15:0] mem_data_in_all [7:0][3:0];

wire [7:0] mem_is_access_write_all;
wire [7:0] mem_is_general_access_byte_operation_all;
wire [7:0] mem_is_general_access_requesting_all;
wire [7:0] mem_is_stack_access_requesting_all;

wire [7:0] mem_is_general_or_stack_access_acknowledged_pulse;

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
wire [4:0] new_instructionID_table [3:0];


wire [16:0] generatedDependSelfRegRead_table [3:0];
wire [16:0] generatedDependSelfRegWrite_table [3:0];
wire [2:0] generatedDependSelfSpecial_table [3:0];

dependancy_generation dependancy_generation_inst0(new_instruction_table[0],new_instructionID_table[0],generatedDependSelfRegRead_table[0],generatedDependSelfRegWrite_table[0],generatedDependSelfSpecial_table[0]);
dependancy_generation dependancy_generation_inst1(new_instruction_table[1],new_instructionID_table[1],generatedDependSelfRegRead_table[1],generatedDependSelfRegWrite_table[1],generatedDependSelfSpecial_table[1]);
dependancy_generation dependancy_generation_inst2(new_instruction_table[2],new_instructionID_table[2],generatedDependSelfRegRead_table[2],generatedDependSelfRegWrite_table[2],generatedDependSelfSpecial_table[2]);
dependancy_generation dependancy_generation_inst3(new_instruction_table[3],new_instructionID_table[3],generatedDependSelfRegRead_table[3],generatedDependSelfRegWrite_table[3],generatedDependSelfSpecial_table[3]);



wire [7:0] is_instructions_valid;
wire [7:0] is_instructions_valid_next;

assign jump_next_executer_index={ // only should be considered valid if there is a single executer doing a jump next cycle
	jump_signal_next_executer[4] | jump_signal_next_executer[5] | jump_signal_next_executer[6] | jump_signal_next_executer[7],
	jump_signal_next_executer[2] | jump_signal_next_executer[3] | jump_signal_next_executer[6] | jump_signal_next_executer[7],
	jump_signal_next_executer[1] | jump_signal_next_executer[3] | jump_signal_next_executer[5] | jump_signal_next_executer[7]
};
reg [2:0] jump_executer_index; // only should be considered valid if there is a single executer doing a jump this cycle
wire is_performing_jump_next_instant_on=jump_signal_next_executer[0] | jump_signal_next_executer[1] | jump_signal_next_executer[2] | jump_signal_next_executer[3] | jump_signal_next_executer[4] | jump_signal_next_executer[5] | jump_signal_next_executer[6] | jump_signal_next_executer[7];
reg is_performing_jump_instant_on=0;
wire [3:0] jump_index_next_for_executer={is_performing_jump_next_instant_on?1'b0:1'b1,jump_next_executer_index};
reg [3:0] jump_index_for_executer={1'b1,3'h0};
wire is_performing_jump_state;
wire is_performing_jump;

always @(posedge main_clk) begin
	jump_executer_index<=jump_next_executer_index;
	is_performing_jump_instant_on<=is_performing_jump_next_instant_on;
	jump_index_for_executer<=jump_index_next_for_executer;
end

wire [4:0] fifo_instruction_cache_size;
wire [4:0] fifo_instruction_cache_size_next;
wire [2:0] fifo_instruction_cache_consume_count;
wire [4:0] fifo_instruction_cache_size_after_read;


instruction_cache instruction_cache_inst(
	mem_is_instruction_fetch_requesting,
	mem_is_hyper_instruction_fetch_0_requesting,
	mem_is_hyper_instruction_fetch_1_requesting,
	mem_void_hyper_instruction_fetch,
	is_performing_jump_state,
	is_performing_jump,
	fifo_instruction_cache_size,
	fifo_instruction_cache_size_next,
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
	instruction_jump_address_selected,
	mem_data_out_type_0,
	user_reg,
	main_clk
);

wire [15:0] instant_updated_core_values [16:0];
wire [15:0] core_values [16:0];
assign core_values[15:0]=user_reg;
assign core_values[16]=stack_pointer;

recomb_mux_all_user_reg_large recomb_mux_full(
	instant_updated_core_values,
	core_values,
	'{executer7DoWrite,executer6DoWrite,executer5DoWrite,executer4DoWrite,executer3DoWrite,executer2DoWrite,executer1DoWrite,executer0DoWrite},
	executer0WriteValues,
	executer1WriteValues,
	executer2WriteValues,
	executer3WriteValues,
	executer4WriteValues,
	executer5WriteValues,
	executer6WriteValues,
	executer7WriteValues
);



always @(posedge main_clk) begin
	assert ((executer0DoWrite & executer1DoWrite)==0);
	assert ((executer0DoWrite & executer2DoWrite)==0);
	assert ((executer0DoWrite & executer3DoWrite)==0);
	assert ((executer0DoWrite & executer4DoWrite)==0);
	assert ((executer0DoWrite & executer5DoWrite)==0);
	assert ((executer0DoWrite & executer6DoWrite)==0);
	assert ((executer0DoWrite & executer7DoWrite)==0);
	assert ((executer1DoWrite & executer2DoWrite)==0);
	assert ((executer1DoWrite & executer3DoWrite)==0);
	assert ((executer1DoWrite & executer4DoWrite)==0);
	assert ((executer1DoWrite & executer5DoWrite)==0);
	assert ((executer1DoWrite & executer6DoWrite)==0);
	assert ((executer1DoWrite & executer7DoWrite)==0);
	assert ((executer2DoWrite & executer3DoWrite)==0);
	assert ((executer2DoWrite & executer4DoWrite)==0);
	assert ((executer2DoWrite & executer5DoWrite)==0);
	assert ((executer2DoWrite & executer6DoWrite)==0);
	assert ((executer2DoWrite & executer7DoWrite)==0);
	assert ((executer3DoWrite & executer4DoWrite)==0);
	assert ((executer3DoWrite & executer5DoWrite)==0);
	assert ((executer3DoWrite & executer6DoWrite)==0);
	assert ((executer3DoWrite & executer7DoWrite)==0);
	assert ((executer4DoWrite & executer5DoWrite)==0);
	assert ((executer4DoWrite & executer6DoWrite)==0);
	assert ((executer4DoWrite & executer7DoWrite)==0);
	assert ((executer5DoWrite & executer6DoWrite)==0);
	assert ((executer5DoWrite & executer7DoWrite)==0);
	assert ((executer6DoWrite & executer7DoWrite)==0);
end


always @(posedge main_clk) begin
	user_reg<=instant_updated_core_values[15:0];
	stack_pointer   <=instant_updated_core_values[16];
	stack_pointer[0]<=1'b0;
end



wire [7:0] is_new_instruction_entering_this_cycle;
wire [7:0] is_instruction_finishing_this_cycle_pulse;

wire [16:0] dependRegRead [7:0];
wire [16:0] dependRegWrite [7:0];
wire [2:0] dependSpecial [7:0];

wire [16:0] dependRegRead_next [7:0];
wire [16:0] dependRegWrite_next [7:0];
wire [2:0] dependSpecial_next [7:0];

wire [7:0] isAfter [7:0];
wire [7:0] isAfter_next [7:0];
wire [1:0] setIndexes [7:0];


scheduler scheduler_inst(
	fifo_instruction_cache_size_after_read,
	fifo_instruction_cache_consume_count,
	is_new_instruction_entering_this_cycle,
	isAfter,
	isAfter_next,
	setIndexes,
	
	is_instructions_valid_next,
	is_performing_jump_next_instant_on,
	fifo_instruction_cache_size,
	fifo_instruction_cache_size_next,
	
	main_clk
);



core_executer core_executer_inst0(
	3'h0,
	jump_index_for_executer,
	jump_index_next_for_executer,
	is_new_instruction_entering_this_cycle[0],
	is_instructions_valid[0],
	is_instructions_valid_next[0],
	new_instruction_table[setIndexes[0]],
	new_instructionID_table[setIndexes[0]],
	new_instruction_address_table[setIndexes[0]],
	
	generatedDependSelfRegRead_table[setIndexes[0]],
	generatedDependSelfRegWrite_table[setIndexes[0]],
	generatedDependSelfSpecial_table[setIndexes[0]],
	
	dependRegRead[0],
	dependRegWrite[0],
	dependSpecial[0],
	
	dependRegRead_next[0],
	dependRegWrite_next[0],
	dependSpecial_next[0],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	
	isAfter[0],
	isAfter_next[0],
	
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	executer0DoWrite,
	executer0WriteValues,
	
	mem_stack_access_size_all[0],
	mem_target_address_all[0],
	
	mem_data_out_type_1[4:0],
	mem_data_in_all[0],
	
	mem_is_access_write_all[0],
	mem_is_general_access_byte_operation_all[0],
	mem_is_general_access_requesting_all[0],
	mem_is_stack_access_requesting_all[0],
	
	mem_is_general_or_stack_access_acknowledged_pulse[0],
	memory_dependency_clear,
	
	is_instruction_finishing_this_cycle_pulse[0],
	
	instruction_jump_address_next_executer[0],
	jump_signal_executer[0],
	jump_signal_next_executer[0],
	
	main_clk
);

core_executer core_executer_inst1(
	3'h1,
	jump_index_for_executer,
	jump_index_next_for_executer,
	is_new_instruction_entering_this_cycle[1],
	is_instructions_valid[1],
	is_instructions_valid_next[1],
	new_instruction_table[setIndexes[1]],
	new_instructionID_table[setIndexes[1]],
	new_instruction_address_table[setIndexes[1]],
	
	generatedDependSelfRegRead_table[setIndexes[1]],
	generatedDependSelfRegWrite_table[setIndexes[1]],
	generatedDependSelfSpecial_table[setIndexes[1]],
	
	dependRegRead[1],
	dependRegWrite[1],
	dependSpecial[1],
	
	dependRegRead_next[1],
	dependRegWrite_next[1],
	dependSpecial_next[1],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	
	isAfter[1],
	isAfter_next[1],
	
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	executer1DoWrite,
	executer1WriteValues,
	
	mem_stack_access_size_all[1],
	mem_target_address_all[1],
	
	mem_data_out_type_1[4:0],
	mem_data_in_all[1],
	
	mem_is_access_write_all[1],
	mem_is_general_access_byte_operation_all[1],
	mem_is_general_access_requesting_all[1],
	mem_is_stack_access_requesting_all[1],
	
	mem_is_general_or_stack_access_acknowledged_pulse[1],
	memory_dependency_clear,
	
	is_instruction_finishing_this_cycle_pulse[1],
	
	instruction_jump_address_next_executer[1],
	jump_signal_executer[1],
	jump_signal_next_executer[1],
	
	main_clk
);

core_executer core_executer_inst2(
	3'h2,
	jump_index_for_executer,
	jump_index_next_for_executer,
	is_new_instruction_entering_this_cycle[2],
	is_instructions_valid[2],
	is_instructions_valid_next[2],
	new_instruction_table[setIndexes[2]],
	new_instructionID_table[setIndexes[2]],
	new_instruction_address_table[setIndexes[2]],
	
	generatedDependSelfRegRead_table[setIndexes[2]],
	generatedDependSelfRegWrite_table[setIndexes[2]],
	generatedDependSelfSpecial_table[setIndexes[2]],
	
	dependRegRead[2],
	dependRegWrite[2],
	dependSpecial[2],
	
	dependRegRead_next[2],
	dependRegWrite_next[2],
	dependSpecial_next[2],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	
	isAfter[2],
	isAfter_next[2],
	
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	executer2DoWrite,
	executer2WriteValues,
	
	mem_stack_access_size_all[2],
	mem_target_address_all[2],
	
	mem_data_out_type_1[4:0],
	mem_data_in_all[2],
	
	mem_is_access_write_all[2],
	mem_is_general_access_byte_operation_all[2],
	mem_is_general_access_requesting_all[2],
	mem_is_stack_access_requesting_all[2],
	
	mem_is_general_or_stack_access_acknowledged_pulse[2],
	memory_dependency_clear,
	
	is_instruction_finishing_this_cycle_pulse[2],
	
	instruction_jump_address_next_executer[2],
	jump_signal_executer[2],
	jump_signal_next_executer[2],
	
	main_clk
);

core_executer core_executer_inst3(
	3'h3,
	jump_index_for_executer,
	jump_index_next_for_executer,
	is_new_instruction_entering_this_cycle[3],
	is_instructions_valid[3],
	is_instructions_valid_next[3],
	new_instruction_table[setIndexes[3]],
	new_instructionID_table[setIndexes[3]],
	new_instruction_address_table[setIndexes[3]],
	
	generatedDependSelfRegRead_table[setIndexes[3]],
	generatedDependSelfRegWrite_table[setIndexes[3]],
	generatedDependSelfSpecial_table[setIndexes[3]],
	
	dependRegRead[3],
	dependRegWrite[3],
	dependSpecial[3],
	
	dependRegRead_next[3],
	dependRegWrite_next[3],
	dependSpecial_next[3],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	
	isAfter[3],
	isAfter_next[3],
	
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	executer3DoWrite,
	executer3WriteValues,
	
	mem_stack_access_size_all[3],
	mem_target_address_all[3],
	
	mem_data_out_type_1[4:0],
	mem_data_in_all[3],
	
	mem_is_access_write_all[3],
	mem_is_general_access_byte_operation_all[3],
	mem_is_general_access_requesting_all[3],
	mem_is_stack_access_requesting_all[3],
	
	mem_is_general_or_stack_access_acknowledged_pulse[3],
	memory_dependency_clear,
	
	is_instruction_finishing_this_cycle_pulse[3],
	
	instruction_jump_address_next_executer[3],
	jump_signal_executer[3],
	jump_signal_next_executer[3],
	
	main_clk
);

core_executer core_executer_inst4(
	3'h4,
	jump_index_for_executer,
	jump_index_next_for_executer,
	is_new_instruction_entering_this_cycle[4],
	is_instructions_valid[4],
	is_instructions_valid_next[4],
	new_instruction_table[setIndexes[4]],
	new_instructionID_table[setIndexes[4]],
	new_instruction_address_table[setIndexes[4]],
	
	generatedDependSelfRegRead_table[setIndexes[4]],
	generatedDependSelfRegWrite_table[setIndexes[4]],
	generatedDependSelfSpecial_table[setIndexes[4]],
	
	dependRegRead[4],
	dependRegWrite[4],
	dependSpecial[4],
	
	dependRegRead_next[4],
	dependRegWrite_next[4],
	dependSpecial_next[4],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	
	isAfter[4],
	isAfter_next[4],
	
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	executer4DoWrite,
	executer4WriteValues,
	
	mem_stack_access_size_all[4],
	mem_target_address_all[4],
	
	mem_data_out_type_1[4:0],
	mem_data_in_all[4],
	
	mem_is_access_write_all[4],
	mem_is_general_access_byte_operation_all[4],
	mem_is_general_access_requesting_all[4],
	mem_is_stack_access_requesting_all[4],
	
	mem_is_general_or_stack_access_acknowledged_pulse[4],
	memory_dependency_clear,
	
	is_instruction_finishing_this_cycle_pulse[4],
	
	instruction_jump_address_next_executer[4],
	jump_signal_executer[4],
	jump_signal_next_executer[4],
	
	main_clk
);

core_executer core_executer_inst5(
	3'h5,
	jump_index_for_executer,
	jump_index_next_for_executer,
	is_new_instruction_entering_this_cycle[5],
	is_instructions_valid[5],
	is_instructions_valid_next[5],
	new_instruction_table[setIndexes[5]],
	new_instructionID_table[setIndexes[5]],
	new_instruction_address_table[setIndexes[5]],
	
	generatedDependSelfRegRead_table[setIndexes[5]],
	generatedDependSelfRegWrite_table[setIndexes[5]],
	generatedDependSelfSpecial_table[setIndexes[5]],
	
	dependRegRead[5],
	dependRegWrite[5],
	dependSpecial[5],
	
	dependRegRead_next[5],
	dependRegWrite_next[5],
	dependSpecial_next[5],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	
	isAfter[5],
	isAfter_next[5],
	
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	executer5DoWrite,
	executer5WriteValues,
	
	mem_stack_access_size_all[5],
	mem_target_address_all[5],
	
	mem_data_out_type_1[4:0],
	mem_data_in_all[5],
	
	mem_is_access_write_all[5],
	mem_is_general_access_byte_operation_all[5],
	mem_is_general_access_requesting_all[5],
	mem_is_stack_access_requesting_all[5],
	
	mem_is_general_or_stack_access_acknowledged_pulse[5],
	memory_dependency_clear,
	
	is_instruction_finishing_this_cycle_pulse[5],
	
	instruction_jump_address_next_executer[5],
	jump_signal_executer[5],
	jump_signal_next_executer[5],
	
	main_clk
);

core_executer core_executer_inst6(
	3'h6,
	jump_index_for_executer,
	jump_index_next_for_executer,
	is_new_instruction_entering_this_cycle[6],
	is_instructions_valid[6],
	is_instructions_valid_next[6],
	new_instruction_table[setIndexes[6]],
	new_instructionID_table[setIndexes[6]],
	new_instruction_address_table[setIndexes[6]],
	
	generatedDependSelfRegRead_table[setIndexes[6]],
	generatedDependSelfRegWrite_table[setIndexes[6]],
	generatedDependSelfSpecial_table[setIndexes[6]],
	
	dependRegRead[6],
	dependRegWrite[6],
	dependSpecial[6],
	
	dependRegRead_next[6],
	dependRegWrite_next[6],
	dependSpecial_next[6],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	
	isAfter[6],
	isAfter_next[6],
	
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	executer6DoWrite,
	executer6WriteValues,
	
	mem_stack_access_size_all[6],
	mem_target_address_all[6],
	
	mem_data_out_type_1[4:0],
	mem_data_in_all[6],
	
	mem_is_access_write_all[6],
	mem_is_general_access_byte_operation_all[6],
	mem_is_general_access_requesting_all[6],
	mem_is_stack_access_requesting_all[6],
	
	mem_is_general_or_stack_access_acknowledged_pulse[6],
	memory_dependency_clear,
	
	is_instruction_finishing_this_cycle_pulse[6],
	
	instruction_jump_address_next_executer[6],
	jump_signal_executer[6],
	jump_signal_next_executer[6],
	
	main_clk
);

core_executer core_executer_inst7(
	3'h7,
	jump_index_for_executer,
	jump_index_next_for_executer,
	is_new_instruction_entering_this_cycle[7],
	is_instructions_valid[7],
	is_instructions_valid_next[7],
	new_instruction_table[setIndexes[7]],
	new_instructionID_table[setIndexes[7]],
	new_instruction_address_table[setIndexes[7]],
	
	generatedDependSelfRegRead_table[setIndexes[7]],
	generatedDependSelfRegWrite_table[setIndexes[7]],
	generatedDependSelfSpecial_table[setIndexes[7]],
	
	dependRegRead[7],
	dependRegWrite[7],
	dependSpecial[7],
	
	dependRegRead_next[7],
	dependRegWrite_next[7],
	dependSpecial_next[7],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	
	isAfter[7],
	isAfter_next[7],
	
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	executer7DoWrite,
	executer7WriteValues,
	
	mem_stack_access_size_all[7],
	mem_target_address_all[7],
	
	mem_data_out_type_1[4:0],
	mem_data_in_all[7],
	
	mem_is_access_write_all[7],
	mem_is_general_access_byte_operation_all[7],
	mem_is_general_access_requesting_all[7],
	mem_is_stack_access_requesting_all[7],
	
	mem_is_general_or_stack_access_acknowledged_pulse[7],
	memory_dependency_clear,
	
	is_instruction_finishing_this_cycle_pulse[7],
	
	instruction_jump_address_next_executer[7],
	jump_signal_executer[7],
	jump_signal_next_executer[7],
	
	main_clk
);


memory_interface memory_interface_inst(
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
	
	mem_stack_access_size_all,
	mem_is_stack_access_requesting_all,
	
	mem_target_address_all,
	
	mem_data_in_all,
	
	mem_is_access_write_all,
	mem_is_general_access_byte_operation_all,
	mem_is_general_access_requesting_all,

	mem_is_general_or_stack_access_acknowledged_pulse,
	
	mem_target_address_hyper_instruction_fetch_0,
	mem_target_address_hyper_instruction_fetch_1,
	
	mem_is_hyper_instruction_fetch_0_requesting,
	mem_is_hyper_instruction_fetch_0_acknowledged_pulse,
	mem_is_hyper_instruction_fetch_1_requesting,
	mem_is_hyper_instruction_fetch_1_acknowledged_pulse,
	
	mem_void_hyper_instruction_fetch,
	
	mem_target_address_instruction_fetch,
	
	mem_is_instruction_fetch_requesting,
	mem_is_instruction_fetch_acknowledged_pulse,
	
	mem_data_out_type_0,
	mem_data_out_type_1,
	
	memory_dependency_clear,
	
	data_out_io,
	data_in_io,
	address_io,
	control_io,
	
	main_clk
);



assign debug_instruction_fetch_address=mem_target_address_instruction_fetch;
assign debug_stack_pointer=stack_pointer;
assign debug_user_reg=user_reg;


endmodule
