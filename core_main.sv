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
	output [9:0] debug_port_states2,
	output [9:0] debug_port_states0,
	output [9:0] debug_port_states1
);

reg [15:0] stack_pointer=0;

reg [15:0] user_reg [31:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,16'hx,16'hx,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; // twice as large due to register renaming

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


	if (^user_reg[18]===1'bx) $stop;
	if (^user_reg[19]===1'bx) $stop;
	if (^user_reg[20]===1'bx) $stop;
	if (^user_reg[21]===1'bx) $stop;
	if (^user_reg[22]===1'bx) $stop;
	if (^user_reg[23]===1'bx) $stop;
	if (^user_reg[24]===1'bx) $stop;
	if (^user_reg[25]===1'bx) $stop;
	if (^user_reg[26]===1'bx) $stop;
	if (^user_reg[27]===1'bx) $stop;
	if (^user_reg[28]===1'bx) $stop;
	if (^user_reg[29]===1'bx) $stop;
	if (^user_reg[30]===1'bx) $stop;
	if (^user_reg[31]===1'bx) $stop;
	if (^stack_pointer===1'bx) $stop;
end

wire [32:0] executer0DoWrite;
wire [15:0] executer0WriteValues [32:0];
wire [32:0] executer1DoWrite;
wire [15:0] executer1WriteValues [32:0];
wire [32:0] executer2DoWrite;
wire [15:0] executer2WriteValues [32:0];
wire [32:0] executer3DoWrite;
wire [15:0] executer3WriteValues [32:0];
wire [32:0] executer4DoWrite;
wire [15:0] executer4WriteValues [32:0];
wire [32:0] executer5DoWrite;
wire [15:0] executer5WriteValues [32:0];
wire [32:0] executer6DoWrite;
wire [15:0] executer6WriteValues [32:0];
wire [32:0] executer7DoWrite;
wire [15:0] executer7WriteValues [32:0];

wire [15:0] rename_state_from_executers [7:0];

wire [2:0] jump_next_executer_index;
wire [31:0] instruction_jump_address_next_executer [7:0];
wire [7:0] jump_signal_executer;
wire [7:0] jump_signal_next_executer;
reg [31:0] instruction_jump_address_selected;

wire jump_triggering_next;
assign jump_triggering_next=jump_signal_next_executer[0] | jump_signal_next_executer[1] | jump_signal_next_executer[2] | jump_signal_next_executer[3] | jump_signal_next_executer[4] | jump_signal_next_executer[5] | jump_signal_next_executer[6] | jump_signal_next_executer[7];

reg jump_triggering_now=0;
always @(posedge main_clk) begin
	jump_triggering_now<=jump_triggering_next;
end

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
	if (!jump_triggering_next) instruction_jump_address_selected<=32'hx;
end

assign jump_next_executer_index={ // only should be considered valid if there is a single executer doing a jump next cycle
	jump_signal_next_executer[4] | jump_signal_next_executer[5] | jump_signal_next_executer[6] | jump_signal_next_executer[7],
	jump_signal_next_executer[2] | jump_signal_next_executer[3] | jump_signal_next_executer[6] | jump_signal_next_executer[7],
	jump_signal_next_executer[1] | jump_signal_next_executer[3] | jump_signal_next_executer[5] | jump_signal_next_executer[7]
};
wire [3:0] jump_index_next_for_executer={jump_triggering_next?1'b0:1'b1,jump_next_executer_index};
reg [3:0] jump_index_for_executer={1'b1,3'h0};


always @(posedge main_clk) begin
	jump_index_for_executer<=jump_index_next_for_executer;
end

wire [7:0] memory_dependency_clear;

wire [ 2:0] mem_stack_access_size_all [7:0];
wire [31:0] mem_target_address_all [7:0];

wire [15:0] mem_data_in_all [7:0][3:0];

wire [7:0] mem_is_access_write_all;
wire [7:0] mem_is_general_access_byte_operation_all;
wire [7:0] mem_is_general_access_requesting_all;
wire [7:0] mem_is_stack_access_requesting_all;
wire [7:0] mem_is_stack_access_overflowing_all;

wire [7:0] mem_is_general_or_stack_access_acknowledged_pulse;

wire [25:0] mem_target_address_instruction_fetch_0;
wire [25:0] mem_target_address_instruction_fetch_1;

wire mem_is_instruction_fetch_0_requesting;
wire mem_is_instruction_fetch_1_requesting;
wire mem_is_instruction_fetch_0_acknowledged_pulse;
wire mem_is_instruction_fetch_1_acknowledged_pulse;

wire [15:0] mem_data_out_type_0 [7:0];
wire [15:0] mem_data_out_type_1 [7:0];

wire mem_void_instruction_fetch;

wire [15:0] new_instruction_table [2:0];
wire [25:0] new_instruction_address_table [2:0];
wire [4:0] new_instructionID_table [2:0];

wire [32:0] generatedDependSelfRegRead_table [2:0];
wire [32:0] generatedDependSelfRegWrite_table [2:0];
wire [2:0] generatedDependSelfSpecial_table [2:0];

reg [15:0] rename_state_base=0;
wire [15:0] rename_state_walk [3:0];
wire [15:0] rename_state_in  [2:0];
wire [15:0] rename_state_out [2:0];

assign rename_state_walk[0]=rename_state_base;
assign rename_state_in[0][15:2]=rename_state_walk[0][15:2];
assign rename_state_in[1][15:2]=rename_state_walk[1][15:2];
assign rename_state_in[2][15:2]=rename_state_walk[2][15:2];

assign rename_state_out[0][15:2]=rename_state_walk[1][15:2];
assign rename_state_out[1][15:2]=rename_state_walk[2][15:2];
assign rename_state_out[2][15:2]=rename_state_walk[3][15:2];

assign rename_state_in[0][1:0]=0;
assign rename_state_in[1][1:0]=0;
assign rename_state_in[2][1:0]=0;

assign rename_state_out[0][1:0]=0;
assign rename_state_out[1][1:0]=0;
assign rename_state_out[2][1:0]=0;

dependancy_generation dependancy_generation_inst0(new_instruction_table[0],rename_state_walk[0],rename_state_walk[1],new_instructionID_table[0],generatedDependSelfRegRead_table[0],generatedDependSelfRegWrite_table[0],generatedDependSelfSpecial_table[0]);
dependancy_generation dependancy_generation_inst1(new_instruction_table[1],rename_state_walk[1],rename_state_walk[2],new_instructionID_table[1],generatedDependSelfRegRead_table[1],generatedDependSelfRegWrite_table[1],generatedDependSelfSpecial_table[1]);
dependancy_generation dependancy_generation_inst2(new_instruction_table[2],rename_state_walk[2],rename_state_walk[3],new_instructionID_table[2],generatedDependSelfRegRead_table[2],generatedDependSelfRegWrite_table[2],generatedDependSelfSpecial_table[2]);


wire [7:0] is_instructions_valid;
wire [7:0] is_instructions_valid_next;
wire [7:0] could_instruction_be_valid_next;

wire [1:0] ready_instruction_count_now;
wire [1:0] ready_instruction_count_next;
wire [1:0] used_ready_instruction_count;

always @(posedge main_clk) begin
	rename_state_base<=rename_state_walk[used_ready_instruction_count];
	if (jump_triggering_now) rename_state_base<=rename_state_from_executers[jump_index_for_executer];
	rename_state_base[1:0]<=2'b0;
end

wire temp_wire_pair0 [1:0];
wire [1:0] temp_wire_pair2;

assign temp_wire_pair0[0]=mem_is_instruction_fetch_0_acknowledged_pulse;
assign temp_wire_pair0[1]=mem_is_instruction_fetch_1_acknowledged_pulse;
assign mem_is_instruction_fetch_0_requesting=temp_wire_pair2[0];
assign mem_is_instruction_fetch_1_requesting=temp_wire_pair2[1];

instruction_cache instruction_cache_inst(
	.ready_instructions_extern(new_instruction_table),
	.ready_instructions_address_table(new_instruction_address_table),
	.ready_instruction_count_now_extern(ready_instruction_count_now),
	.ready_instruction_count_next_extern(ready_instruction_count_next),
	.data_in_raw(mem_data_out_type_0),
	.is_data_coming_in(temp_wire_pair0),
	.void_instruction_fetch_output(mem_void_instruction_fetch),
	.instruction_fetch_requesting_out(temp_wire_pair2),
	.instruction_fetch0_pointer_out(mem_target_address_instruction_fetch_0[25:1]),
	.instruction_fetch1_pointer_out(mem_target_address_instruction_fetch_1[25:1]),
	.jump_triggering(jump_triggering_now),
	.jump_address(instruction_jump_address_selected[25:1]),
	.used_ready_instruction_count(used_ready_instruction_count),
	.main_clk(main_clk)
);


assign mem_target_address_instruction_fetch_0[0]=1'b0;
assign mem_target_address_instruction_fetch_1[0]=1'b0;

wire [15:0] instant_updated_core_values [32:0];
wire [15:0] core_values [32:0];
assign core_values[31:0]=user_reg;
assign core_values[32]=stack_pointer;

reg_mux_full reg_mux_full_inst(
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
	user_reg<=instant_updated_core_values[31:0];
	stack_pointer   <=instant_updated_core_values[32];
	stack_pointer[0]<=1'b0;
	user_reg[16]<=16'hx;
	user_reg[17]<=16'hx;
end

assign debug_port_states2[7:0]=is_instructions_valid;
assign debug_port_states2[9:8]=ready_instruction_count_now;

wire [7:0] is_new_instruction_entering_this_cycle;
wire [7:0] is_instruction_finishing_this_cycle_pulse;

wire [32:0] dependRegRead [7:0];
wire [32:0] dependRegWrite [7:0];
wire [2:0] dependSpecial [7:0];

wire [32:0] dependRegRead_next [7:0];
wire [32:0] dependRegWrite_next [7:0];
wire [2:0] dependSpecial_next [7:0];
wire [2:0] dependSpecial_estimate [7:0];

wire [7:0] isAfter [7:0];
wire [7:0] isAfter_next [7:0];
wire [1:0] setIndexes [7:0];


scheduler scheduler_inst(
	used_ready_instruction_count,
	is_new_instruction_entering_this_cycle,
	isAfter,
	isAfter_next,
	setIndexes,
	
	is_instructions_valid_next,
	could_instruction_be_valid_next,
	jump_triggering_next,
	jump_triggering_now,
	ready_instruction_count_now,
	ready_instruction_count_next,
	
	main_clk
);



core_executer core_executer_inst0(
	3'h0,
	jump_index_for_executer,
	jump_index_next_for_executer,
	is_new_instruction_entering_this_cycle[0],
	is_instructions_valid[0],
	is_instructions_valid_next[0],
	could_instruction_be_valid_next[0],
	new_instruction_table[setIndexes[0]],
	new_instructionID_table[setIndexes[0]],
	new_instruction_address_table[setIndexes[0]],
	
	rename_state_in[setIndexes[0]],
	rename_state_out[setIndexes[0]],
	rename_state_from_executers[0],
	
	generatedDependSelfRegRead_table[setIndexes[0]],
	generatedDependSelfRegWrite_table[setIndexes[0]],
	generatedDependSelfSpecial_table[setIndexes[0]],
	
	dependRegRead[0],
	dependRegWrite[0],
	dependSpecial[0],
	
	dependRegRead_next[0],
	dependRegWrite_next[0],
	dependSpecial_next[0],
	dependSpecial_estimate[0],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	dependSpecial_estimate,
	
	isAfter[0],
	isAfter_next[0],
	
	instant_updated_core_values,
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
	mem_is_stack_access_overflowing_all[0],
	
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
	could_instruction_be_valid_next[1],
	new_instruction_table[setIndexes[1]],
	new_instructionID_table[setIndexes[1]],
	new_instruction_address_table[setIndexes[1]],
	
	rename_state_in[setIndexes[1]],
	rename_state_out[setIndexes[1]],
	rename_state_from_executers[1],
	
	generatedDependSelfRegRead_table[setIndexes[1]],
	generatedDependSelfRegWrite_table[setIndexes[1]],
	generatedDependSelfSpecial_table[setIndexes[1]],
	
	dependRegRead[1],
	dependRegWrite[1],
	dependSpecial[1],
	
	dependRegRead_next[1],
	dependRegWrite_next[1],
	dependSpecial_next[1],
	dependSpecial_estimate[1],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	dependSpecial_estimate,
	
	isAfter[1],
	isAfter_next[1],
	
	instant_updated_core_values,
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
	mem_is_stack_access_overflowing_all[1],
	
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
	could_instruction_be_valid_next[2],
	new_instruction_table[setIndexes[2]],
	new_instructionID_table[setIndexes[2]],
	new_instruction_address_table[setIndexes[2]],
	
	rename_state_in[setIndexes[2]],
	rename_state_out[setIndexes[2]],
	rename_state_from_executers[2],

	generatedDependSelfRegRead_table[setIndexes[2]],
	generatedDependSelfRegWrite_table[setIndexes[2]],
	generatedDependSelfSpecial_table[setIndexes[2]],
	
	dependRegRead[2],
	dependRegWrite[2],
	dependSpecial[2],
	
	dependRegRead_next[2],
	dependRegWrite_next[2],
	dependSpecial_next[2],
	dependSpecial_estimate[2],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	dependSpecial_estimate,
	
	isAfter[2],
	isAfter_next[2],
	
	instant_updated_core_values,
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
	mem_is_stack_access_overflowing_all[2],
	
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
	could_instruction_be_valid_next[3],
	new_instruction_table[setIndexes[3]],
	new_instructionID_table[setIndexes[3]],
	new_instruction_address_table[setIndexes[3]],
	
	rename_state_in[setIndexes[3]],
	rename_state_out[setIndexes[3]],
	rename_state_from_executers[3],

	generatedDependSelfRegRead_table[setIndexes[3]],
	generatedDependSelfRegWrite_table[setIndexes[3]],
	generatedDependSelfSpecial_table[setIndexes[3]],
	
	dependRegRead[3],
	dependRegWrite[3],
	dependSpecial[3],
	
	dependRegRead_next[3],
	dependRegWrite_next[3],
	dependSpecial_next[3],
	dependSpecial_estimate[3],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	dependSpecial_estimate,
	
	isAfter[3],
	isAfter_next[3],
	
	instant_updated_core_values,
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
	mem_is_stack_access_overflowing_all[3],
	
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
	could_instruction_be_valid_next[4],
	new_instruction_table[setIndexes[4]],
	new_instructionID_table[setIndexes[4]],
	new_instruction_address_table[setIndexes[4]],
	
	rename_state_in[setIndexes[4]],
	rename_state_out[setIndexes[4]],
	rename_state_from_executers[4],

	generatedDependSelfRegRead_table[setIndexes[4]],
	generatedDependSelfRegWrite_table[setIndexes[4]],
	generatedDependSelfSpecial_table[setIndexes[4]],
	
	dependRegRead[4],
	dependRegWrite[4],
	dependSpecial[4],
	
	dependRegRead_next[4],
	dependRegWrite_next[4],
	dependSpecial_next[4],
	dependSpecial_estimate[4],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	dependSpecial_estimate,
	
	isAfter[4],
	isAfter_next[4],
	
	instant_updated_core_values,
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
	mem_is_stack_access_overflowing_all[4],
	
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
	could_instruction_be_valid_next[5],
	new_instruction_table[setIndexes[5]],
	new_instructionID_table[setIndexes[5]],
	new_instruction_address_table[setIndexes[5]],
	
	rename_state_in[setIndexes[5]],
	rename_state_out[setIndexes[5]],
	rename_state_from_executers[5],

	generatedDependSelfRegRead_table[setIndexes[5]],
	generatedDependSelfRegWrite_table[setIndexes[5]],
	generatedDependSelfSpecial_table[setIndexes[5]],
	
	dependRegRead[5],
	dependRegWrite[5],
	dependSpecial[5],
	
	dependRegRead_next[5],
	dependRegWrite_next[5],
	dependSpecial_next[5],
	dependSpecial_estimate[5],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	dependSpecial_estimate,
	
	isAfter[5],
	isAfter_next[5],
	
	instant_updated_core_values,
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
	mem_is_stack_access_overflowing_all[5],
	
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
	could_instruction_be_valid_next[6],
	new_instruction_table[setIndexes[6]],
	new_instructionID_table[setIndexes[6]],
	new_instruction_address_table[setIndexes[6]],
	
	rename_state_in[setIndexes[6]],
	rename_state_out[setIndexes[6]],
	rename_state_from_executers[6],

	generatedDependSelfRegRead_table[setIndexes[6]],
	generatedDependSelfRegWrite_table[setIndexes[6]],
	generatedDependSelfSpecial_table[setIndexes[6]],
	
	dependRegRead[6],
	dependRegWrite[6],
	dependSpecial[6],
	
	dependRegRead_next[6],
	dependRegWrite_next[6],
	dependSpecial_next[6],
	dependSpecial_estimate[6],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	dependSpecial_estimate,
	
	isAfter[6],
	isAfter_next[6],
	
	instant_updated_core_values,
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
	mem_is_stack_access_overflowing_all[6],
	
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
	could_instruction_be_valid_next[7],
	new_instruction_table[setIndexes[7]],
	new_instructionID_table[setIndexes[7]],
	new_instruction_address_table[setIndexes[7]],
	
	rename_state_in[setIndexes[7]],
	rename_state_out[setIndexes[7]],
	rename_state_from_executers[7],

	generatedDependSelfRegRead_table[setIndexes[7]],
	generatedDependSelfRegWrite_table[setIndexes[7]],
	generatedDependSelfSpecial_table[setIndexes[7]],
	
	dependRegRead[7],
	dependRegWrite[7],
	dependSpecial[7],
	
	dependRegRead_next[7],
	dependRegWrite_next[7],
	dependSpecial_next[7],
	dependSpecial_estimate[7],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	dependSpecial_estimate,
	
	isAfter[7],
	isAfter_next[7],
	
	instant_updated_core_values,
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
	mem_is_stack_access_overflowing_all[7],
	
	mem_is_general_or_stack_access_acknowledged_pulse[7],
	memory_dependency_clear,
	
	is_instruction_finishing_this_cycle_pulse[7],
	
	instruction_jump_address_next_executer[7],
	jump_signal_executer[7],
	jump_signal_next_executer[7],
	
	main_clk
);
wire [7:0] errors;

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
	mem_is_stack_access_overflowing_all,
	
	mem_target_address_all,
	
	mem_data_in_all,
	
	mem_is_access_write_all,
	mem_is_general_access_byte_operation_all,
	mem_is_general_access_requesting_all,

	mem_is_general_or_stack_access_acknowledged_pulse,
	
	mem_target_address_instruction_fetch_0,
	mem_target_address_instruction_fetch_1,
	
	mem_is_instruction_fetch_0_requesting,
	mem_is_instruction_fetch_0_acknowledged_pulse,
	mem_is_instruction_fetch_1_requesting,
	mem_is_instruction_fetch_1_acknowledged_pulse,
	
	mem_void_instruction_fetch,
	
	mem_data_out_type_0,
	mem_data_out_type_1,
	
	memory_dependency_clear,
	
	data_out_io,
	data_in_io,
	address_io,
	control_io,
	
	debug_port_states0,
	debug_port_states1,
	main_clk
);



assign debug_instruction_fetch_address=mem_target_address_instruction_fetch_0;
assign debug_stack_pointer=stack_pointer;
assign debug_user_reg=user_reg[15:0];


endmodule
