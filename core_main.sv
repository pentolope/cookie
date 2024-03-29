`timescale 1 ps / 1 ps

`include "utilities.sv"
`include "memory_interface.sv"
`include "instruction_cache.sv"
`include "dependancy_generation.sv"
`include "dispatcher.sv"
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

wire [32:0] executerDoWrite [7:0];
wire [15:0] executerWriteValues [7:0][32:0];

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
wire generatedDependSelfStackPointer_table [2:0];
wire [2:0] generatedDependSelfSpecial_table [2:0];

assign generatedDependSelfRegRead_table[0][32]=generatedDependSelfStackPointer_table[0];
assign generatedDependSelfRegRead_table[1][32]=generatedDependSelfStackPointer_table[1];
assign generatedDependSelfRegRead_table[2][32]=generatedDependSelfStackPointer_table[2];
assign generatedDependSelfRegWrite_table[0][32]=generatedDependSelfStackPointer_table[0];
assign generatedDependSelfRegWrite_table[1][32]=generatedDependSelfStackPointer_table[1];
assign generatedDependSelfRegWrite_table[2][32]=generatedDependSelfStackPointer_table[2];

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

dependancy_generation dependancy_generation_inst0(new_instruction_table[0],rename_state_walk[0],rename_state_walk[1],new_instructionID_table[0],generatedDependSelfRegRead_table[0][31:0],generatedDependSelfRegWrite_table[0][31:0],generatedDependSelfStackPointer_table[0],generatedDependSelfSpecial_table[0]);
dependancy_generation dependancy_generation_inst1(new_instruction_table[1],rename_state_walk[1],rename_state_walk[2],new_instructionID_table[1],generatedDependSelfRegRead_table[1][31:0],generatedDependSelfRegWrite_table[1][31:0],generatedDependSelfStackPointer_table[1],generatedDependSelfSpecial_table[1]);
dependancy_generation dependancy_generation_inst2(new_instruction_table[2],rename_state_walk[2],rename_state_walk[3],new_instructionID_table[2],generatedDependSelfRegRead_table[2][31:0],generatedDependSelfRegWrite_table[2][31:0],generatedDependSelfStackPointer_table[2],generatedDependSelfSpecial_table[2]);


wire [7:0] is_instructions_valid;
wire [7:0] is_instructions_valid_next;
wire [7:0] could_instruction_be_valid_next;

wire [1:0] ready_instruction_count_now;
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

wire [15:0] instant_updated_from_memory [32:0];
wire [15:0] instant_updated_core_values [32:0];
wire [15:0] core_values [32:0];
assign core_values[31:0]=user_reg;
assign core_values[32]=stack_pointer;


always @(posedge main_clk) begin
	assert ((executerDoWrite[0] & executerDoWrite[1])==0);
	assert ((executerDoWrite[0] & executerDoWrite[2])==0);
	assert ((executerDoWrite[0] & executerDoWrite[3])==0);
	assert ((executerDoWrite[0] & executerDoWrite[4])==0);
	assert ((executerDoWrite[0] & executerDoWrite[5])==0);
	assert ((executerDoWrite[0] & executerDoWrite[6])==0);
	assert ((executerDoWrite[0] & executerDoWrite[7])==0);
	assert ((executerDoWrite[1] & executerDoWrite[2])==0);
	assert ((executerDoWrite[1] & executerDoWrite[3])==0);
	assert ((executerDoWrite[1] & executerDoWrite[4])==0);
	assert ((executerDoWrite[1] & executerDoWrite[5])==0);
	assert ((executerDoWrite[1] & executerDoWrite[6])==0);
	assert ((executerDoWrite[1] & executerDoWrite[7])==0);
	assert ((executerDoWrite[2] & executerDoWrite[3])==0);
	assert ((executerDoWrite[2] & executerDoWrite[4])==0);
	assert ((executerDoWrite[2] & executerDoWrite[5])==0);
	assert ((executerDoWrite[2] & executerDoWrite[6])==0);
	assert ((executerDoWrite[2] & executerDoWrite[7])==0);
	assert ((executerDoWrite[3] & executerDoWrite[4])==0);
	assert ((executerDoWrite[3] & executerDoWrite[5])==0);
	assert ((executerDoWrite[3] & executerDoWrite[6])==0);
	assert ((executerDoWrite[3] & executerDoWrite[7])==0);
	assert ((executerDoWrite[4] & executerDoWrite[5])==0);
	assert ((executerDoWrite[4] & executerDoWrite[6])==0);
	assert ((executerDoWrite[4] & executerDoWrite[7])==0);
	assert ((executerDoWrite[5] & executerDoWrite[6])==0);
	assert ((executerDoWrite[5] & executerDoWrite[7])==0);
	assert ((executerDoWrite[6] & executerDoWrite[7])==0);
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
wire [7:0] possible_remain_valid;

dispatcher dispatcher_inst(
	used_ready_instruction_count,
	is_new_instruction_entering_this_cycle,
	isAfter,
	isAfter_next,
	setIndexes,
	
	possible_remain_valid,
	jump_triggering_now,
	ready_instruction_count_now,
	
	main_clk
);

wire [15:0] instructions [7:0];
wire [7:0] doSpecialWrite;


reg_mux_from_memory reg_mux_from_memory_inst(
	instant_updated_from_memory[31:0],
	
	core_values[31:0],
	instructions,
	rename_state_from_executers,
	doSpecialWrite,
	mem_data_out_type_1[3:0],
	(~mem_is_access_write_all) & mem_is_general_or_stack_access_acknowledged_pulse,
	main_clk
);

assign instant_updated_from_memory[32]=core_values[32];

reg_mux_full reg_mux_full_inst(
	instant_updated_core_values,
	instant_updated_from_memory,
	'{executerDoWrite[7],executerDoWrite[6],executerDoWrite[5],executerDoWrite[4],executerDoWrite[3],executerDoWrite[2],executerDoWrite[1],executerDoWrite[0]},
	executerWriteValues[0],
	executerWriteValues[1],
	executerWriteValues[2],
	executerWriteValues[3],
	executerWriteValues[4],
	executerWriteValues[5],
	executerWriteValues[6],
	executerWriteValues[7]
);



generate
genvar i;
for (i=0;i<8;i=i+1) begin : core_gen
core_executer #(i) core_executer_inst(
	jump_index_for_executer,
	jump_index_next_for_executer,
	is_new_instruction_entering_this_cycle[i],
	is_instructions_valid[i],
	possible_remain_valid[i],
	
	instructions[i],
	new_instruction_table[setIndexes[i]],
	new_instructionID_table[setIndexes[i]],
	new_instruction_address_table[setIndexes[i]],
	
	rename_state_in[setIndexes[i]],
	rename_state_out[setIndexes[i]],
	rename_state_from_executers[i],
	
	generatedDependSelfRegRead_table[setIndexes[i]],
	generatedDependSelfRegWrite_table[setIndexes[i]],
	generatedDependSelfSpecial_table[setIndexes[i]],
	
	dependRegRead[i],
	dependRegWrite[i],
	dependSpecial[i],
	
	dependRegRead_next[i],
	dependRegWrite_next[i],
	dependSpecial_next[i],
	dependSpecial_estimate[i],
	
	dependRegRead,
	dependRegWrite,
	dependSpecial,
	
	dependRegRead_next,
	dependRegWrite_next,
	dependSpecial_next,
	dependSpecial_estimate,
	
	isAfter[i],
	isAfter_next[i],
	
	instant_updated_core_values,
	
	doSpecialWrite[i],
	executerDoWrite[i],
	executerWriteValues[i],
	
	mem_stack_access_size_all[i],
	mem_target_address_all[i],
	
	mem_data_out_type_1[4:0],
	mem_data_in_all[i],
	
	mem_is_access_write_all[i],
	mem_is_general_access_byte_operation_all[i],
	mem_is_general_access_requesting_all[i],
	mem_is_stack_access_requesting_all[i],
	mem_is_stack_access_overflowing_all[i],
	
	mem_is_general_or_stack_access_acknowledged_pulse[i],
	memory_dependency_clear,
	
	instruction_jump_address_next_executer[i],
	jump_signal_executer[i],
	jump_signal_next_executer[i],
	main_clk
);

end
endgenerate

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
