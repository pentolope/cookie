`timescale 1 ps / 1 ps


module core_executer(
	input [2:0] selfIndex,
	input [3:0] jumpIndex, // if (jumpIndex[3]) then there is no jump. this is only valid on the first cycle of a jump
	input [3:0] jumpIndex_next,
	input is_new_instruction_entering_this_cycle,
	output is_instruction_valid_extern,
	output is_instruction_valid_next_extern,
	
	input [15:0] instructionIn_extern,
	input [ 4:0] instructionInID_extern,
	input [25:0] instructionAddressIn_extern,
	
	input [16:0] generatedDependSelfRegRead,
	input [16:0] generatedDependSelfRegWrite,
	input [2:0] generatedDependSelfSpecial, // .[0]=jump  , .[1]=mem read  , .[2]=mem write
	
	output [16:0] dependSelfRegRead_extern,
	output [16:0] dependSelfRegWrite_extern,
	output [2:0] dependSelfSpecial_extern,
	
	output [16:0] dependSelfRegRead_next_extern,
	output [16:0] dependSelfRegWrite_next_extern,
	output [2:0] dependSelfSpecial_next_extern,
	
	input [16:0] dependOtherRegRead [7:0],
	input [16:0] dependOtherRegWrite [7:0],
	input [2:0] dependOtherSpecial [7:0],

	input [16:0] dependOtherRegRead_next [7:0],
	input [16:0] dependOtherRegWrite_next [7:0],
	input [2:0] dependOtherSpecial_next [7:0],
	
	input [7:0] isAfter,
	input [7:0] isAfter_next,
	
	input [15:0] instant_user_reg [15:0],
	
	input [15:0] instant_stack_pointer,
	
	output [16:0] doWrite_extern, // doWrite[16] is stack pointer's doWrite
	output [15:0] writeValues_extern [16:0],
	
	output [ 2:0] mem_stack_access_size_extern,
	output [31:0] mem_target_address_extern,
	
	input  [15:0] mem_data_out [4:0],
	output [15:0] mem_data_in_extern [3:0],

	output mem_is_access_write_extern,
	output mem_is_general_access_byte_operation_extern,
	output mem_is_general_access_requesting_extern,
	output mem_is_stack_access_requesting_extern,
	
	input  mem_is_access_acknowledged_pulse,
	input [7:0] memory_dependency_clear,
	
	output is_instruction_finishing_this_cycle_pulse_extern, // single cycle pulse
	
	output [31:0] instruction_jump_address_next_extern,
	output jump_signal_extern,
	output jump_signal_next_extern,
	
	input main_clk
);

reg [16:0] doWrite=0;
reg [15:0] writeValues [16:0];
reg is_instruction_finishing_this_cycle_pulse=0;
assign doWrite_extern=doWrite;
assign is_instruction_finishing_this_cycle_pulse_extern=is_instruction_finishing_this_cycle_pulse;

lcell_16 lc_wv0(writeValues_extern[0],writeValues[0]);
lcell_16 lc_wv1(writeValues_extern[1],writeValues[1]);
lcell_16 lc_wv2(writeValues_extern[2],writeValues[2]);
lcell_16 lc_wv3(writeValues_extern[3],writeValues[3]);
lcell_16 lc_wv4(writeValues_extern[4],writeValues[4]);
lcell_16 lc_wv5(writeValues_extern[5],writeValues[5]);
lcell_16 lc_wv6(writeValues_extern[6],writeValues[6]);
lcell_16 lc_wv7(writeValues_extern[7],writeValues[7]);
lcell_16 lc_wv8(writeValues_extern[8],writeValues[8]);
lcell_16 lc_wv9(writeValues_extern[9],writeValues[9]);
lcell_16 lc_wv10(writeValues_extern[10],writeValues[10]);
lcell_16 lc_wv11(writeValues_extern[11],writeValues[11]);
lcell_16 lc_wv12(writeValues_extern[12],writeValues[12]);
lcell_16 lc_wv13(writeValues_extern[13],writeValues[13]);
lcell_16 lc_wv14(writeValues_extern[14],writeValues[14]);
lcell_16 lc_wv15(writeValues_extern[15],writeValues[15]);
lcell_16 lc_wv16(writeValues_extern[16],writeValues[16]);


reg [16:0] dependSelfRegRead=0;
reg [16:0] dependSelfRegWrite=0;
reg [2:0] dependSelfSpecial=0;

assign dependSelfRegRead_extern=dependSelfRegRead;
assign dependSelfRegWrite_extern=dependSelfRegWrite;
assign dependSelfSpecial_extern=dependSelfSpecial;

reg [16:0] dependSelfRegRead_next;
reg [16:0] dependSelfRegWrite_next;
reg [2:0] dependSelfSpecial_next;

assign dependSelfRegRead_next_extern=dependSelfRegRead_next;
assign dependSelfRegWrite_next_extern=dependSelfRegWrite_next;
assign dependSelfSpecial_next_extern=dependSelfSpecial_next;


reg [16:0] resolveDependSelfRegRead;
always_comb begin
	resolveDependSelfRegRead=0;
	
	if (dependSelfRegRead[0] && !(
		(isAfter[0] && dependOtherRegWrite[0][0]) ||
		(isAfter[1] && dependOtherRegWrite[1][0]) ||
		(isAfter[2] && dependOtherRegWrite[2][0]) ||
		(isAfter[3] && dependOtherRegWrite[3][0]) ||
		(isAfter[4] && dependOtherRegWrite[4][0]) ||
		(isAfter[5] && dependOtherRegWrite[5][0]) ||
		(isAfter[6] && dependOtherRegWrite[6][0]) ||
		(isAfter[7] && dependOtherRegWrite[7][0])
		)) resolveDependSelfRegRead[0]=1'b1;

	if (dependSelfRegRead[1] && !(
		(isAfter[0] && dependOtherRegWrite[0][1]) ||
		(isAfter[1] && dependOtherRegWrite[1][1]) ||
		(isAfter[2] && dependOtherRegWrite[2][1]) ||
		(isAfter[3] && dependOtherRegWrite[3][1]) ||
		(isAfter[4] && dependOtherRegWrite[4][1]) ||
		(isAfter[5] && dependOtherRegWrite[5][1]) ||
		(isAfter[6] && dependOtherRegWrite[6][1]) ||
		(isAfter[7] && dependOtherRegWrite[7][1])
		)) resolveDependSelfRegRead[1]=1'b1;

	if (dependSelfRegRead[2] && !(
		(isAfter[0] && dependOtherRegWrite[0][2]) ||
		(isAfter[1] && dependOtherRegWrite[1][2]) ||
		(isAfter[2] && dependOtherRegWrite[2][2]) ||
		(isAfter[3] && dependOtherRegWrite[3][2]) ||
		(isAfter[4] && dependOtherRegWrite[4][2]) ||
		(isAfter[5] && dependOtherRegWrite[5][2]) ||
		(isAfter[6] && dependOtherRegWrite[6][2]) ||
		(isAfter[7] && dependOtherRegWrite[7][2])
		)) resolveDependSelfRegRead[2]=1'b1;

	if (dependSelfRegRead[3] && !(
		(isAfter[0] && dependOtherRegWrite[0][3]) ||
		(isAfter[1] && dependOtherRegWrite[1][3]) ||
		(isAfter[2] && dependOtherRegWrite[2][3]) ||
		(isAfter[3] && dependOtherRegWrite[3][3]) ||
		(isAfter[4] && dependOtherRegWrite[4][3]) ||
		(isAfter[5] && dependOtherRegWrite[5][3]) ||
		(isAfter[6] && dependOtherRegWrite[6][3]) ||
		(isAfter[7] && dependOtherRegWrite[7][3])
		)) resolveDependSelfRegRead[3]=1'b1;

	if (dependSelfRegRead[4] && !(
		(isAfter[0] && dependOtherRegWrite[0][4]) ||
		(isAfter[1] && dependOtherRegWrite[1][4]) ||
		(isAfter[2] && dependOtherRegWrite[2][4]) ||
		(isAfter[3] && dependOtherRegWrite[3][4]) ||
		(isAfter[4] && dependOtherRegWrite[4][4]) ||
		(isAfter[5] && dependOtherRegWrite[5][4]) ||
		(isAfter[6] && dependOtherRegWrite[6][4]) ||
		(isAfter[7] && dependOtherRegWrite[7][4])
		)) resolveDependSelfRegRead[4]=1'b1;

	if (dependSelfRegRead[5] && !(
		(isAfter[0] && dependOtherRegWrite[0][5]) ||
		(isAfter[1] && dependOtherRegWrite[1][5]) ||
		(isAfter[2] && dependOtherRegWrite[2][5]) ||
		(isAfter[3] && dependOtherRegWrite[3][5]) ||
		(isAfter[4] && dependOtherRegWrite[4][5]) ||
		(isAfter[5] && dependOtherRegWrite[5][5]) ||
		(isAfter[6] && dependOtherRegWrite[6][5]) ||
		(isAfter[7] && dependOtherRegWrite[7][5])
		)) resolveDependSelfRegRead[5]=1'b1;

	if (dependSelfRegRead[6] && !(
		(isAfter[0] && dependOtherRegWrite[0][6]) ||
		(isAfter[1] && dependOtherRegWrite[1][6]) ||
		(isAfter[2] && dependOtherRegWrite[2][6]) ||
		(isAfter[3] && dependOtherRegWrite[3][6]) ||
		(isAfter[4] && dependOtherRegWrite[4][6]) ||
		(isAfter[5] && dependOtherRegWrite[5][6]) ||
		(isAfter[6] && dependOtherRegWrite[6][6]) ||
		(isAfter[7] && dependOtherRegWrite[7][6])
		)) resolveDependSelfRegRead[6]=1'b1;

	if (dependSelfRegRead[7] && !(
		(isAfter[0] && dependOtherRegWrite[0][7]) ||
		(isAfter[1] && dependOtherRegWrite[1][7]) ||
		(isAfter[2] && dependOtherRegWrite[2][7]) ||
		(isAfter[3] && dependOtherRegWrite[3][7]) ||
		(isAfter[4] && dependOtherRegWrite[4][7]) ||
		(isAfter[5] && dependOtherRegWrite[5][7]) ||
		(isAfter[6] && dependOtherRegWrite[6][7]) ||
		(isAfter[7] && dependOtherRegWrite[7][7])
		)) resolveDependSelfRegRead[7]=1'b1;

	if (dependSelfRegRead[8] && !(
		(isAfter[0] && dependOtherRegWrite[0][8]) ||
		(isAfter[1] && dependOtherRegWrite[1][8]) ||
		(isAfter[2] && dependOtherRegWrite[2][8]) ||
		(isAfter[3] && dependOtherRegWrite[3][8]) ||
		(isAfter[4] && dependOtherRegWrite[4][8]) ||
		(isAfter[5] && dependOtherRegWrite[5][8]) ||
		(isAfter[6] && dependOtherRegWrite[6][8]) ||
		(isAfter[7] && dependOtherRegWrite[7][8])
		)) resolveDependSelfRegRead[8]=1'b1;

	if (dependSelfRegRead[9] && !(
		(isAfter[0] && dependOtherRegWrite[0][9]) ||
		(isAfter[1] && dependOtherRegWrite[1][9]) ||
		(isAfter[2] && dependOtherRegWrite[2][9]) ||
		(isAfter[3] && dependOtherRegWrite[3][9]) ||
		(isAfter[4] && dependOtherRegWrite[4][9]) ||
		(isAfter[5] && dependOtherRegWrite[5][9]) ||
		(isAfter[6] && dependOtherRegWrite[6][9]) ||
		(isAfter[7] && dependOtherRegWrite[7][9])
		)) resolveDependSelfRegRead[9]=1'b1;

	if (dependSelfRegRead[10] && !(
		(isAfter[0] && dependOtherRegWrite[0][10]) ||
		(isAfter[1] && dependOtherRegWrite[1][10]) ||
		(isAfter[2] && dependOtherRegWrite[2][10]) ||
		(isAfter[3] && dependOtherRegWrite[3][10]) ||
		(isAfter[4] && dependOtherRegWrite[4][10]) ||
		(isAfter[5] && dependOtherRegWrite[5][10]) ||
		(isAfter[6] && dependOtherRegWrite[6][10]) ||
		(isAfter[7] && dependOtherRegWrite[7][10])
		)) resolveDependSelfRegRead[10]=1'b1;

	if (dependSelfRegRead[11] && !(
		(isAfter[0] && dependOtherRegWrite[0][11]) ||
		(isAfter[1] && dependOtherRegWrite[1][11]) ||
		(isAfter[2] && dependOtherRegWrite[2][11]) ||
		(isAfter[3] && dependOtherRegWrite[3][11]) ||
		(isAfter[4] && dependOtherRegWrite[4][11]) ||
		(isAfter[5] && dependOtherRegWrite[5][11]) ||
		(isAfter[6] && dependOtherRegWrite[6][11]) ||
		(isAfter[7] && dependOtherRegWrite[7][11])
		)) resolveDependSelfRegRead[11]=1'b1;

	if (dependSelfRegRead[12] && !(
		(isAfter[0] && dependOtherRegWrite[0][12]) ||
		(isAfter[1] && dependOtherRegWrite[1][12]) ||
		(isAfter[2] && dependOtherRegWrite[2][12]) ||
		(isAfter[3] && dependOtherRegWrite[3][12]) ||
		(isAfter[4] && dependOtherRegWrite[4][12]) ||
		(isAfter[5] && dependOtherRegWrite[5][12]) ||
		(isAfter[6] && dependOtherRegWrite[6][12]) ||
		(isAfter[7] && dependOtherRegWrite[7][12])
		)) resolveDependSelfRegRead[12]=1'b1;

	if (dependSelfRegRead[13] && !(
		(isAfter[0] && dependOtherRegWrite[0][13]) ||
		(isAfter[1] && dependOtherRegWrite[1][13]) ||
		(isAfter[2] && dependOtherRegWrite[2][13]) ||
		(isAfter[3] && dependOtherRegWrite[3][13]) ||
		(isAfter[4] && dependOtherRegWrite[4][13]) ||
		(isAfter[5] && dependOtherRegWrite[5][13]) ||
		(isAfter[6] && dependOtherRegWrite[6][13]) ||
		(isAfter[7] && dependOtherRegWrite[7][13])
		)) resolveDependSelfRegRead[13]=1'b1;

	if (dependSelfRegRead[14] && !(
		(isAfter[0] && dependOtherRegWrite[0][14]) ||
		(isAfter[1] && dependOtherRegWrite[1][14]) ||
		(isAfter[2] && dependOtherRegWrite[2][14]) ||
		(isAfter[3] && dependOtherRegWrite[3][14]) ||
		(isAfter[4] && dependOtherRegWrite[4][14]) ||
		(isAfter[5] && dependOtherRegWrite[5][14]) ||
		(isAfter[6] && dependOtherRegWrite[6][14]) ||
		(isAfter[7] && dependOtherRegWrite[7][14])
		)) resolveDependSelfRegRead[14]=1'b1;

	if (dependSelfRegRead[15] && !(
		(isAfter[0] && dependOtherRegWrite[0][15]) ||
		(isAfter[1] && dependOtherRegWrite[1][15]) ||
		(isAfter[2] && dependOtherRegWrite[2][15]) ||
		(isAfter[3] && dependOtherRegWrite[3][15]) ||
		(isAfter[4] && dependOtherRegWrite[4][15]) ||
		(isAfter[5] && dependOtherRegWrite[5][15]) ||
		(isAfter[6] && dependOtherRegWrite[6][15]) ||
		(isAfter[7] && dependOtherRegWrite[7][15])
		)) resolveDependSelfRegRead[15]=1'b1;

	if (dependSelfRegRead[16] && !(
		(isAfter[0] && dependOtherRegWrite[0][16]) ||
		(isAfter[1] && dependOtherRegWrite[1][16]) ||
		(isAfter[2] && dependOtherRegWrite[2][16]) ||
		(isAfter[3] && dependOtherRegWrite[3][16]) ||
		(isAfter[4] && dependOtherRegWrite[4][16]) ||
		(isAfter[5] && dependOtherRegWrite[5][16]) ||
		(isAfter[6] && dependOtherRegWrite[6][16]) ||
		(isAfter[7] && dependOtherRegWrite[7][16])
		)) resolveDependSelfRegRead[16]=1'b1;
end

reg [16:0] unreadyDependSelfRegWrite;
always_comb begin
	unreadyDependSelfRegWrite=0;
	
	if (dependSelfRegWrite[0] && (
		(isAfter[0] && (dependOtherRegRead[0][0] || dependOtherRegWrite[0][0])) ||
		(isAfter[1] && (dependOtherRegRead[1][0] || dependOtherRegWrite[1][0])) ||
		(isAfter[2] && (dependOtherRegRead[2][0] || dependOtherRegWrite[2][0])) ||
		(isAfter[3] && (dependOtherRegRead[3][0] || dependOtherRegWrite[3][0])) ||
		(isAfter[4] && (dependOtherRegRead[4][0] || dependOtherRegWrite[4][0])) ||
		(isAfter[5] && (dependOtherRegRead[5][0] || dependOtherRegWrite[5][0])) ||
		(isAfter[6] && (dependOtherRegRead[6][0] || dependOtherRegWrite[6][0])) ||
		(isAfter[7] && (dependOtherRegRead[7][0] || dependOtherRegWrite[7][0]))
		)) unreadyDependSelfRegWrite[0]=1'b1;

	if (dependSelfRegWrite[1] && (
		(isAfter[0] && (dependOtherRegRead[0][1] || dependOtherRegWrite[0][1])) ||
		(isAfter[1] && (dependOtherRegRead[1][1] || dependOtherRegWrite[1][1])) ||
		(isAfter[2] && (dependOtherRegRead[2][1] || dependOtherRegWrite[2][1])) ||
		(isAfter[3] && (dependOtherRegRead[3][1] || dependOtherRegWrite[3][1])) ||
		(isAfter[4] && (dependOtherRegRead[4][1] || dependOtherRegWrite[4][1])) ||
		(isAfter[5] && (dependOtherRegRead[5][1] || dependOtherRegWrite[5][1])) ||
		(isAfter[6] && (dependOtherRegRead[6][1] || dependOtherRegWrite[6][1])) ||
		(isAfter[7] && (dependOtherRegRead[7][1] || dependOtherRegWrite[7][1]))
		)) unreadyDependSelfRegWrite[1]=1'b1;

	if (dependSelfRegWrite[2] && (
		(isAfter[0] && (dependOtherRegRead[0][2] || dependOtherRegWrite[0][2])) ||
		(isAfter[1] && (dependOtherRegRead[1][2] || dependOtherRegWrite[1][2])) ||
		(isAfter[2] && (dependOtherRegRead[2][2] || dependOtherRegWrite[2][2])) ||
		(isAfter[3] && (dependOtherRegRead[3][2] || dependOtherRegWrite[3][2])) ||
		(isAfter[4] && (dependOtherRegRead[4][2] || dependOtherRegWrite[4][2])) ||
		(isAfter[5] && (dependOtherRegRead[5][2] || dependOtherRegWrite[5][2])) ||
		(isAfter[6] && (dependOtherRegRead[6][2] || dependOtherRegWrite[6][2])) ||
		(isAfter[7] && (dependOtherRegRead[7][2] || dependOtherRegWrite[7][2]))
		)) unreadyDependSelfRegWrite[2]=1'b1;

	if (dependSelfRegWrite[3] && (
		(isAfter[0] && (dependOtherRegRead[0][3] || dependOtherRegWrite[0][3])) ||
		(isAfter[1] && (dependOtherRegRead[1][3] || dependOtherRegWrite[1][3])) ||
		(isAfter[2] && (dependOtherRegRead[2][3] || dependOtherRegWrite[2][3])) ||
		(isAfter[3] && (dependOtherRegRead[3][3] || dependOtherRegWrite[3][3])) ||
		(isAfter[4] && (dependOtherRegRead[4][3] || dependOtherRegWrite[4][3])) ||
		(isAfter[5] && (dependOtherRegRead[5][3] || dependOtherRegWrite[5][3])) ||
		(isAfter[6] && (dependOtherRegRead[6][3] || dependOtherRegWrite[6][3])) ||
		(isAfter[7] && (dependOtherRegRead[7][3] || dependOtherRegWrite[7][3]))
		)) unreadyDependSelfRegWrite[3]=1'b1;

	if (dependSelfRegWrite[4] && (
		(isAfter[0] && (dependOtherRegRead[0][4] || dependOtherRegWrite[0][4])) ||
		(isAfter[1] && (dependOtherRegRead[1][4] || dependOtherRegWrite[1][4])) ||
		(isAfter[2] && (dependOtherRegRead[2][4] || dependOtherRegWrite[2][4])) ||
		(isAfter[3] && (dependOtherRegRead[3][4] || dependOtherRegWrite[3][4])) ||
		(isAfter[4] && (dependOtherRegRead[4][4] || dependOtherRegWrite[4][4])) ||
		(isAfter[5] && (dependOtherRegRead[5][4] || dependOtherRegWrite[5][4])) ||
		(isAfter[6] && (dependOtherRegRead[6][4] || dependOtherRegWrite[6][4])) ||
		(isAfter[7] && (dependOtherRegRead[7][4] || dependOtherRegWrite[7][4]))
		)) unreadyDependSelfRegWrite[4]=1'b1;

	if (dependSelfRegWrite[5] && (
		(isAfter[0] && (dependOtherRegRead[0][5] || dependOtherRegWrite[0][5])) ||
		(isAfter[1] && (dependOtherRegRead[1][5] || dependOtherRegWrite[1][5])) ||
		(isAfter[2] && (dependOtherRegRead[2][5] || dependOtherRegWrite[2][5])) ||
		(isAfter[3] && (dependOtherRegRead[3][5] || dependOtherRegWrite[3][5])) ||
		(isAfter[4] && (dependOtherRegRead[4][5] || dependOtherRegWrite[4][5])) ||
		(isAfter[5] && (dependOtherRegRead[5][5] || dependOtherRegWrite[5][5])) ||
		(isAfter[6] && (dependOtherRegRead[6][5] || dependOtherRegWrite[6][5])) ||
		(isAfter[7] && (dependOtherRegRead[7][5] || dependOtherRegWrite[7][5]))
		)) unreadyDependSelfRegWrite[5]=1'b1;

	if (dependSelfRegWrite[6] && (
		(isAfter[0] && (dependOtherRegRead[0][6] || dependOtherRegWrite[0][6])) ||
		(isAfter[1] && (dependOtherRegRead[1][6] || dependOtherRegWrite[1][6])) ||
		(isAfter[2] && (dependOtherRegRead[2][6] || dependOtherRegWrite[2][6])) ||
		(isAfter[3] && (dependOtherRegRead[3][6] || dependOtherRegWrite[3][6])) ||
		(isAfter[4] && (dependOtherRegRead[4][6] || dependOtherRegWrite[4][6])) ||
		(isAfter[5] && (dependOtherRegRead[5][6] || dependOtherRegWrite[5][6])) ||
		(isAfter[6] && (dependOtherRegRead[6][6] || dependOtherRegWrite[6][6])) ||
		(isAfter[7] && (dependOtherRegRead[7][6] || dependOtherRegWrite[7][6]))
		)) unreadyDependSelfRegWrite[6]=1'b1;

	if (dependSelfRegWrite[7] && (
		(isAfter[0] && (dependOtherRegRead[0][7] || dependOtherRegWrite[0][7])) ||
		(isAfter[1] && (dependOtherRegRead[1][7] || dependOtherRegWrite[1][7])) ||
		(isAfter[2] && (dependOtherRegRead[2][7] || dependOtherRegWrite[2][7])) ||
		(isAfter[3] && (dependOtherRegRead[3][7] || dependOtherRegWrite[3][7])) ||
		(isAfter[4] && (dependOtherRegRead[4][7] || dependOtherRegWrite[4][7])) ||
		(isAfter[5] && (dependOtherRegRead[5][7] || dependOtherRegWrite[5][7])) ||
		(isAfter[6] && (dependOtherRegRead[6][7] || dependOtherRegWrite[6][7])) ||
		(isAfter[7] && (dependOtherRegRead[7][7] || dependOtherRegWrite[7][7]))
		)) unreadyDependSelfRegWrite[7]=1'b1;

	if (dependSelfRegWrite[8] && (
		(isAfter[0] && (dependOtherRegRead[0][8] || dependOtherRegWrite[0][8])) ||
		(isAfter[1] && (dependOtherRegRead[1][8] || dependOtherRegWrite[1][8])) ||
		(isAfter[2] && (dependOtherRegRead[2][8] || dependOtherRegWrite[2][8])) ||
		(isAfter[3] && (dependOtherRegRead[3][8] || dependOtherRegWrite[3][8])) ||
		(isAfter[4] && (dependOtherRegRead[4][8] || dependOtherRegWrite[4][8])) ||
		(isAfter[5] && (dependOtherRegRead[5][8] || dependOtherRegWrite[5][8])) ||
		(isAfter[6] && (dependOtherRegRead[6][8] || dependOtherRegWrite[6][8])) ||
		(isAfter[7] && (dependOtherRegRead[7][8] || dependOtherRegWrite[7][8]))
		)) unreadyDependSelfRegWrite[8]=1'b1;

	if (dependSelfRegWrite[9] && (
		(isAfter[0] && (dependOtherRegRead[0][9] || dependOtherRegWrite[0][9])) ||
		(isAfter[1] && (dependOtherRegRead[1][9] || dependOtherRegWrite[1][9])) ||
		(isAfter[2] && (dependOtherRegRead[2][9] || dependOtherRegWrite[2][9])) ||
		(isAfter[3] && (dependOtherRegRead[3][9] || dependOtherRegWrite[3][9])) ||
		(isAfter[4] && (dependOtherRegRead[4][9] || dependOtherRegWrite[4][9])) ||
		(isAfter[5] && (dependOtherRegRead[5][9] || dependOtherRegWrite[5][9])) ||
		(isAfter[6] && (dependOtherRegRead[6][9] || dependOtherRegWrite[6][9])) ||
		(isAfter[7] && (dependOtherRegRead[7][9] || dependOtherRegWrite[7][9]))
		)) unreadyDependSelfRegWrite[9]=1'b1;

	if (dependSelfRegWrite[10] && (
		(isAfter[0] && (dependOtherRegRead[0][10] || dependOtherRegWrite[0][10])) ||
		(isAfter[1] && (dependOtherRegRead[1][10] || dependOtherRegWrite[1][10])) ||
		(isAfter[2] && (dependOtherRegRead[2][10] || dependOtherRegWrite[2][10])) ||
		(isAfter[3] && (dependOtherRegRead[3][10] || dependOtherRegWrite[3][10])) ||
		(isAfter[4] && (dependOtherRegRead[4][10] || dependOtherRegWrite[4][10])) ||
		(isAfter[5] && (dependOtherRegRead[5][10] || dependOtherRegWrite[5][10])) ||
		(isAfter[6] && (dependOtherRegRead[6][10] || dependOtherRegWrite[6][10])) ||
		(isAfter[7] && (dependOtherRegRead[7][10] || dependOtherRegWrite[7][10]))
		)) unreadyDependSelfRegWrite[10]=1'b1;

	if (dependSelfRegWrite[11] && (
		(isAfter[0] && (dependOtherRegRead[0][11] || dependOtherRegWrite[0][11])) ||
		(isAfter[1] && (dependOtherRegRead[1][11] || dependOtherRegWrite[1][11])) ||
		(isAfter[2] && (dependOtherRegRead[2][11] || dependOtherRegWrite[2][11])) ||
		(isAfter[3] && (dependOtherRegRead[3][11] || dependOtherRegWrite[3][11])) ||
		(isAfter[4] && (dependOtherRegRead[4][11] || dependOtherRegWrite[4][11])) ||
		(isAfter[5] && (dependOtherRegRead[5][11] || dependOtherRegWrite[5][11])) ||
		(isAfter[6] && (dependOtherRegRead[6][11] || dependOtherRegWrite[6][11])) ||
		(isAfter[7] && (dependOtherRegRead[7][11] || dependOtherRegWrite[7][11]))
		)) unreadyDependSelfRegWrite[11]=1'b1;

	if (dependSelfRegWrite[12] && (
		(isAfter[0] && (dependOtherRegRead[0][12] || dependOtherRegWrite[0][12])) ||
		(isAfter[1] && (dependOtherRegRead[1][12] || dependOtherRegWrite[1][12])) ||
		(isAfter[2] && (dependOtherRegRead[2][12] || dependOtherRegWrite[2][12])) ||
		(isAfter[3] && (dependOtherRegRead[3][12] || dependOtherRegWrite[3][12])) ||
		(isAfter[4] && (dependOtherRegRead[4][12] || dependOtherRegWrite[4][12])) ||
		(isAfter[5] && (dependOtherRegRead[5][12] || dependOtherRegWrite[5][12])) ||
		(isAfter[6] && (dependOtherRegRead[6][12] || dependOtherRegWrite[6][12])) ||
		(isAfter[7] && (dependOtherRegRead[7][12] || dependOtherRegWrite[7][12]))
		)) unreadyDependSelfRegWrite[12]=1'b1;

	if (dependSelfRegWrite[13] && (
		(isAfter[0] && (dependOtherRegRead[0][13] || dependOtherRegWrite[0][13])) ||
		(isAfter[1] && (dependOtherRegRead[1][13] || dependOtherRegWrite[1][13])) ||
		(isAfter[2] && (dependOtherRegRead[2][13] || dependOtherRegWrite[2][13])) ||
		(isAfter[3] && (dependOtherRegRead[3][13] || dependOtherRegWrite[3][13])) ||
		(isAfter[4] && (dependOtherRegRead[4][13] || dependOtherRegWrite[4][13])) ||
		(isAfter[5] && (dependOtherRegRead[5][13] || dependOtherRegWrite[5][13])) ||
		(isAfter[6] && (dependOtherRegRead[6][13] || dependOtherRegWrite[6][13])) ||
		(isAfter[7] && (dependOtherRegRead[7][13] || dependOtherRegWrite[7][13]))
		)) unreadyDependSelfRegWrite[13]=1'b1;

	if (dependSelfRegWrite[14] && (
		(isAfter[0] && (dependOtherRegRead[0][14] || dependOtherRegWrite[0][14])) ||
		(isAfter[1] && (dependOtherRegRead[1][14] || dependOtherRegWrite[1][14])) ||
		(isAfter[2] && (dependOtherRegRead[2][14] || dependOtherRegWrite[2][14])) ||
		(isAfter[3] && (dependOtherRegRead[3][14] || dependOtherRegWrite[3][14])) ||
		(isAfter[4] && (dependOtherRegRead[4][14] || dependOtherRegWrite[4][14])) ||
		(isAfter[5] && (dependOtherRegRead[5][14] || dependOtherRegWrite[5][14])) ||
		(isAfter[6] && (dependOtherRegRead[6][14] || dependOtherRegWrite[6][14])) ||
		(isAfter[7] && (dependOtherRegRead[7][14] || dependOtherRegWrite[7][14]))
		)) unreadyDependSelfRegWrite[14]=1'b1;

	if (dependSelfRegWrite[15] && (
		(isAfter[0] && (dependOtherRegRead[0][15] || dependOtherRegWrite[0][15])) ||
		(isAfter[1] && (dependOtherRegRead[1][15] || dependOtherRegWrite[1][15])) ||
		(isAfter[2] && (dependOtherRegRead[2][15] || dependOtherRegWrite[2][15])) ||
		(isAfter[3] && (dependOtherRegRead[3][15] || dependOtherRegWrite[3][15])) ||
		(isAfter[4] && (dependOtherRegRead[4][15] || dependOtherRegWrite[4][15])) ||
		(isAfter[5] && (dependOtherRegRead[5][15] || dependOtherRegWrite[5][15])) ||
		(isAfter[6] && (dependOtherRegRead[6][15] || dependOtherRegWrite[6][15])) ||
		(isAfter[7] && (dependOtherRegRead[7][15] || dependOtherRegWrite[7][15]))
		)) unreadyDependSelfRegWrite[15]=1'b1;

	if (dependSelfRegWrite[16] && (
		(isAfter[0] && (dependOtherRegRead[0][16] || dependOtherRegWrite[0][16])) ||
		(isAfter[1] && (dependOtherRegRead[1][16] || dependOtherRegWrite[1][16])) ||
		(isAfter[2] && (dependOtherRegRead[2][16] || dependOtherRegWrite[2][16])) ||
		(isAfter[3] && (dependOtherRegRead[3][16] || dependOtherRegWrite[3][16])) ||
		(isAfter[4] && (dependOtherRegRead[4][16] || dependOtherRegWrite[4][16])) ||
		(isAfter[5] && (dependOtherRegRead[5][16] || dependOtherRegWrite[5][16])) ||
		(isAfter[6] && (dependOtherRegRead[6][16] || dependOtherRegWrite[6][16])) ||
		(isAfter[7] && (dependOtherRegRead[7][16] || dependOtherRegWrite[7][16]))
		)) unreadyDependSelfRegWrite[16]=1'b1;
end

wire isUnblocked;
reg [3:0] isUnblockedPieces=0;
lcell_1 lc_isUnblocked(isUnblocked,(isUnblockedPieces[0] && isUnblockedPieces[1] && isUnblockedPieces[2] && isUnblockedPieces[3])?1'b1:1'b0);
always @(posedge main_clk) begin
	isUnblockedPieces[0]<=1;
	isUnblockedPieces[1]<=1;
	isUnblockedPieces[2]<=1;
	isUnblockedPieces[3]<=1;
	if (is_new_instruction_entering_this_cycle) isUnblockedPieces[1]<=0;
	if (dependSelfRegRead_next[7:0]!=8'h0) isUnblockedPieces[1]<=0;
	if (dependSelfRegRead_next[16:8]!=9'h0) isUnblockedPieces[0]<=0;
	if (unreadyDependSelfRegWrite!=17'h0) isUnblockedPieces[1]<=0; // this check using unreadyDependSelfRegWrite could be more advanced, an instruction could start without this (but especially for memory instructions, there would have to be some handling if it isn't ready to write when the data comes in).
	
	if (isAfter_next[0] && dependOtherSpecial_next[0][0]) isUnblockedPieces[2]<=0;
	if (isAfter_next[1] && dependOtherSpecial_next[1][0]) isUnblockedPieces[2]<=0;
	if (isAfter_next[2] && dependOtherSpecial_next[2][0]) isUnblockedPieces[2]<=0;
	if (isAfter_next[3] && dependOtherSpecial_next[3][0]) isUnblockedPieces[2]<=0;
	if (isAfter_next[4] && dependOtherSpecial_next[4][0]) isUnblockedPieces[3]<=0;
	if (isAfter_next[5] && dependOtherSpecial_next[5][0]) isUnblockedPieces[3]<=0;
	if (isAfter_next[6] && dependOtherSpecial_next[6][0]) isUnblockedPieces[3]<=0;
	if (isAfter_next[7] && dependOtherSpecial_next[7][0]) isUnblockedPieces[3]<=0;
	
	if (dependSelfSpecial_next[1]) begin
		if (isAfter_next[0] && dependOtherSpecial_next[0][2]) isUnblockedPieces[2]<=0;
		if (isAfter_next[1] && dependOtherSpecial_next[1][2]) isUnblockedPieces[2]<=0;
		if (isAfter_next[2] && dependOtherSpecial_next[2][2]) isUnblockedPieces[2]<=0;
		if (isAfter_next[3] && dependOtherSpecial_next[3][2]) isUnblockedPieces[2]<=0;
		if (isAfter_next[4] && dependOtherSpecial_next[4][2]) isUnblockedPieces[3]<=0;
		if (isAfter_next[5] && dependOtherSpecial_next[5][2]) isUnblockedPieces[3]<=0;
		if (isAfter_next[6] && dependOtherSpecial_next[6][2]) isUnblockedPieces[3]<=0;
		if (isAfter_next[7] && dependOtherSpecial_next[7][2]) isUnblockedPieces[3]<=0;
	end
	if (dependSelfSpecial_next[2]) begin
		if (isAfter_next[0] && (dependOtherSpecial_next[0][2] || dependOtherSpecial_next[0][1])) isUnblockedPieces[2]<=0;
		if (isAfter_next[1] && (dependOtherSpecial_next[1][2] || dependOtherSpecial_next[1][1])) isUnblockedPieces[2]<=0;
		if (isAfter_next[2] && (dependOtherSpecial_next[2][2] || dependOtherSpecial_next[2][1])) isUnblockedPieces[2]<=0;
		if (isAfter_next[3] && (dependOtherSpecial_next[3][2] || dependOtherSpecial_next[3][1])) isUnblockedPieces[2]<=0;
		if (isAfter_next[4] && (dependOtherSpecial_next[4][2] || dependOtherSpecial_next[4][1])) isUnblockedPieces[3]<=0;
		if (isAfter_next[5] && (dependOtherSpecial_next[5][2] || dependOtherSpecial_next[5][1])) isUnblockedPieces[3]<=0;
		if (isAfter_next[6] && (dependOtherSpecial_next[6][2] || dependOtherSpecial_next[6][1])) isUnblockedPieces[3]<=0;
		if (isAfter_next[7] && (dependOtherSpecial_next[7][2] || dependOtherSpecial_next[7][1])) isUnblockedPieces[3]<=0;
	end
end

reg jump_signal=0;
reg jump_signal_next;
assign jump_signal_extern=jump_signal;
assign jump_signal_next_extern=jump_signal_next;

reg void_current_instruction=0;
always @(posedge main_clk) void_current_instruction<=(!jumpIndex_next[3] && isAfter_next[jumpIndex_next[2:0]])?1'b1:1'b0;


reg [15:0] instructionIn=0;
reg [ 4:0] instructionInID=0;
reg [ 3:0] state=0;

reg [15:0] user_reg [15:0];
reg [15:0] stack_pointer;
reg [25:0] instructionAddressIn;


wire [15:0] vr0;
wire [15:0] vr1;
wire [15:0] vr2;

fast_ur_mux fast_ur_mux0(vr0,instructionIn[ 3:0],user_reg);
fast_ur_mux fast_ur_mux1(vr1,instructionIn[ 7:4],user_reg);
fast_ur_mux fast_ur_mux2(vr2,instructionIn[11:8],user_reg);



reg [31:0] mul32Temp;
reg [15:0] mul16Temp;

reg [15:0] temporary0;
reg [15:0] temporary1;

wire [18:0]temporary2;
reg [15:0] temporary3;
reg [15:0] temporary4;
reg [15:0] temporary5;
wire [17:0]temporary6;
reg [15:0] temporary7;
wire [18:0]temporary8;
wire [18:0]temporary9;
wire [18:0]temporaryA;
reg [15:0] temporaryB;


reg [16:0] adderOutput;

wire bitwise_lut [15:0];
assign bitwise_lut[4'b0000]=1'b0 & 1'b0;
assign bitwise_lut[4'b0001]=1'b0 & 1'b1;
assign bitwise_lut[4'b0010]=1'b1 & 1'b0;
assign bitwise_lut[4'b0011]=1'b1 & 1'b1;

assign bitwise_lut[4'b0100]=1'b0 | 1'b0;
assign bitwise_lut[4'b0101]=1'b0 | 1'b1;
assign bitwise_lut[4'b0110]=1'b1 | 1'b0;
assign bitwise_lut[4'b0111]=1'b1 | 1'b1;

assign bitwise_lut[4'b1000]=1'b0 ^ 1'b0;
assign bitwise_lut[4'b1001]=1'b0 ^ 1'b1;
assign bitwise_lut[4'b1010]=1'b1 ^ 1'b0;
assign bitwise_lut[4'b1011]=1'b1 ^ 1'b1;

assign bitwise_lut[4'b1100]=1'bx;
assign bitwise_lut[4'b1101]=1'bx;
assign bitwise_lut[4'b1110]=1'bx;
assign bitwise_lut[4'b1111]=1'bx;


wire adderControl0_lut [15:0]; // adderControl0_lut controls if vr2 is inverted
assign adderControl0_lut[4'b0000]=1'bx;
assign adderControl0_lut[4'b0001]=1'bx;
assign adderControl0_lut[4'b0010]=1'bx;
assign adderControl0_lut[4'b0011]=1'bx;

assign adderControl0_lut[4'b0100]=1'bx;
assign adderControl0_lut[4'b0101]=1'bx;
assign adderControl0_lut[4'b0110]=1'bx;
assign adderControl0_lut[4'b0111]=1'b1;

assign adderControl0_lut[4'b1000]=1'bx;
assign adderControl0_lut[4'b1001]=1'bx;
assign adderControl0_lut[4'b1010]=1'b0;
assign adderControl0_lut[4'b1011]=1'b0;

assign adderControl0_lut[4'b1100]=1'b1;
assign adderControl0_lut[4'b1101]=1'b1;
assign adderControl0_lut[4'b1110]=1'bx;
assign adderControl0_lut[4'b1111]=1'bx;


wire adderControl1_lut [15:0]; // adderControl1_lut controls if one is added (when subtracting)
assign adderControl1_lut[4'b0000]=1'bx;
assign adderControl1_lut[4'b0001]=1'bx;
assign adderControl1_lut[4'b0010]=1'bx;
assign adderControl1_lut[4'b0011]=1'bx;

assign adderControl1_lut[4'b0100]=1'bx;
assign adderControl1_lut[4'b0101]=1'bx;
assign adderControl1_lut[4'b0110]=1'bx;
assign adderControl1_lut[4'b0111]=1'b0;

assign adderControl1_lut[4'b1000]=1'bx;
assign adderControl1_lut[4'b1001]=1'bx;
assign adderControl1_lut[4'b1010]=1'b0;
assign adderControl1_lut[4'b1011]=1'b0;

assign adderControl1_lut[4'b1100]=1'b1;
assign adderControl1_lut[4'b1101]=1'b1;
assign adderControl1_lut[4'b1110]=1'bx;
assign adderControl1_lut[4'b1111]=1'bx;

wire adderControl2_lut [15:0]; // // adderControl2_lut controls if a third term is added
assign adderControl2_lut[4'b0000]=1'bx;
assign adderControl2_lut[4'b0001]=1'bx;
assign adderControl2_lut[4'b0010]=1'bx;
assign adderControl2_lut[4'b0011]=1'bx;

assign adderControl2_lut[4'b0100]=1'bx;
assign adderControl2_lut[4'b0101]=1'bx;
assign adderControl2_lut[4'b0110]=1'bx;
assign adderControl2_lut[4'b0111]=1'b1;

assign adderControl2_lut[4'b1000]=1'bx;
assign adderControl2_lut[4'b1001]=1'bx;
assign adderControl2_lut[4'b1010]=1'b0;
assign adderControl2_lut[4'b1011]=1'b1;

assign adderControl2_lut[4'b1100]=1'b0;
assign adderControl2_lut[4'b1101]=1'b0;
assign adderControl2_lut[4'b1110]=1'bx;
assign adderControl2_lut[4'b1111]=1'bx;


wire adderControl0_r=adderControl0_lut[instructionIn[15:12]];
wire adderControl1_r=adderControl1_lut[instructionIn[15:12]];
wire adderControl2_r=adderControl2_lut[instructionIn[15:12]];

lcell_19 lc_add0 (temporary8,{2'b0,temporary5,1'b1}+adderControl1_r);
lcell_19 lc_add1 (temporary9,{2'b0,temporary4,1'b0}+{2'b0,temporary3,1'b0});
lcell_19 lc_add2 (temporaryA,temporary8+temporary9);

assign temporary6=temporaryA[18:1];

always_comb begin
	temporary0[0]=bitwise_lut[{instructionIn[13:12],vr2[0],vr1[0]}];
	temporary0[1]=bitwise_lut[{instructionIn[13:12],vr2[1],vr1[1]}];
	temporary0[2]=bitwise_lut[{instructionIn[13:12],vr2[2],vr1[2]}];
	temporary0[3]=bitwise_lut[{instructionIn[13:12],vr2[3],vr1[3]}];
	temporary0[4]=bitwise_lut[{instructionIn[13:12],vr2[4],vr1[4]}];
	temporary0[5]=bitwise_lut[{instructionIn[13:12],vr2[5],vr1[5]}];
	temporary0[6]=bitwise_lut[{instructionIn[13:12],vr2[6],vr1[6]}];
	temporary0[7]=bitwise_lut[{instructionIn[13:12],vr2[7],vr1[7]}];
	temporary0[8]=bitwise_lut[{instructionIn[13:12],vr2[8],vr1[8]}];
	temporary0[9]=bitwise_lut[{instructionIn[13:12],vr2[9],vr1[9]}];
	temporary0[10]=bitwise_lut[{instructionIn[13:12],vr2[10],vr1[10]}];
	temporary0[11]=bitwise_lut[{instructionIn[13:12],vr2[11],vr1[11]}];
	temporary0[12]=bitwise_lut[{instructionIn[13:12],vr2[12],vr1[12]}];
	temporary0[13]=bitwise_lut[{instructionIn[13:12],vr2[13],vr1[13]}];
	temporary0[14]=bitwise_lut[{instructionIn[13:12],vr2[14],vr1[14]}];
	temporary0[15]=bitwise_lut[{instructionIn[13:12],vr2[15],vr1[15]}];
end
always_comb begin
	temporary3=vr1;
	temporary4={16{adderControl0_r}} ^ vr2;
	temporary5={16{adderControl2_r}} & (instructionIn[15]?user_reg[4'hF]:vr0);
end
always_comb begin
	adderOutput[15:0]=temporary6[15:0];
	adderOutput[16]=(temporary6[17] | temporary6[16])?1'b1:1'b0;
end
always_comb begin
	temporary7=stack_pointer - vr0;
	temporary7[0]=1'b0;
end
always_comb temporary1={instructionIn[11:4],1'b0} + user_reg[4'h1];

reg [15:0] mul16TempVal [2:0];
always @(posedge main_clk) mul16TempVal[0]<=vr0[ 7:0]*vr1[ 7:0];
always @(posedge main_clk) mul16TempVal[1]<=vr0[15:8]*vr1[ 7:0];
always @(posedge main_clk) mul16TempVal[2]<=vr0[ 7:0]*vr1[15:8];

always_comb mul16Temp[ 7:0]=mul16TempVal[0][ 7:0];
always_comb mul16Temp[15:8]=mul16TempVal[0][15:8]+mul16TempVal[1][ 7:0]+mul16TempVal[2][ 7:0];


reg [7:0] mul32TempArg0 [3:0];
reg [7:0] mul32TempArg1 [3:0];

always_comb mul32TempArg0[0]=vr0[ 7:0];
always_comb mul32TempArg0[1]=vr0[15:8];
always_comb mul32TempArg0[2]=vr1[ 7:0];
always_comb mul32TempArg0[3]=vr1[15:8];
always_comb mul32TempArg1[0]=user_reg[4'hD][ 7:0];
always_comb mul32TempArg1[1]=user_reg[4'hD][15:8];
always_comb mul32TempArg1[2]=user_reg[4'hE][ 7:0];
always_comb mul32TempArg1[3]=user_reg[4'hE][15:8];

reg [15:0] mul32TempVal0 [9:0];

always @(posedge main_clk) mul32TempVal0[0]<=mul32TempArg0[0]*mul32TempArg1[0];
always @(posedge main_clk) mul32TempVal0[1]<=mul32TempArg0[1]*mul32TempArg1[0];
always @(posedge main_clk) mul32TempVal0[2]<=mul32TempArg0[2]*mul32TempArg1[0];
always @(posedge main_clk) mul32TempVal0[3]<=mul32TempArg0[3]*mul32TempArg1[0];
always @(posedge main_clk) mul32TempVal0[4]<=mul32TempArg0[0]*mul32TempArg1[1];
always @(posedge main_clk) mul32TempVal0[5]<=mul32TempArg0[1]*mul32TempArg1[1];
always @(posedge main_clk) mul32TempVal0[6]<=mul32TempArg0[2]*mul32TempArg1[1];
always @(posedge main_clk) mul32TempVal0[7]<=mul32TempArg0[0]*mul32TempArg1[2];
always @(posedge main_clk) mul32TempVal0[8]<=mul32TempArg0[1]*mul32TempArg1[2];
always @(posedge main_clk) mul32TempVal0[9]<=mul32TempArg0[0]*mul32TempArg1[3];

reg [31:0] mul32TempVal1 [4:0];

always_comb mul32TempVal1[0][15: 0]=mul32TempVal0[0];
always_comb mul32TempVal1[0][31:16]=mul32TempVal0[2];
always_comb mul32TempVal1[1][ 7: 0]=0;
always_comb mul32TempVal1[1][23: 8]=mul32TempVal0[1];
always_comb mul32TempVal1[1][31:24]=mul32TempVal0[3][7:0];
always_comb mul32TempVal1[2][ 7: 0]=0;
always_comb mul32TempVal1[2][23: 8]=mul32TempVal0[4];
always_comb mul32TempVal1[2][31:24]=mul32TempVal0[6][7:0];
always_comb mul32TempVal1[3][15: 0]=0;
always_comb mul32TempVal1[3][31:16]=mul32TempVal0[5]+mul32TempVal0[7];
always_comb mul32TempVal1[4][23: 0]=0;
always_comb mul32TempVal1[4][31:24]=mul32TempVal0[8][7:0]+mul32TempVal0[9][7:0];

always_comb mul32Temp=(mul32TempVal1[0]+(mul32TempVal1[1]+mul32TempVal1[2]))+(mul32TempVal1[3]+mul32TempVal1[4]);


reg [16:0] divTemp0;
reg [ 1:0] divTemp2;
reg [15:0] divTemp3;
reg [15:0] divTemp4;
reg [15:0] divTemp5;

wire [16:0] divTemp6={1'b0,~vr1}+(2'b1+vr0[15]);
wire [15:0] divTemp7=({16{((divTemp6[16])?1'b1:1'b0)}} & divTemp6[15:0]) | ({16{((divTemp6[16])?1'b0:1'b1)}} & {15'h0,vr0[15]});

wire [16:0] divTable0 [2:0];
wire [16:0] divTable1 [2:0];

assign divTable0[0]={divTemp5,divTemp2[1]};
assign divTable0[1]=divTemp0+divTable0[0];
assign divTable0[2]=({16{((divTable0[1][16])?1'b1:1'b0)}} & divTable0[1][15:0]) | ({16{((divTable0[1][16])?1'b0:1'b1)}} & divTable0[0][15:0]);

assign divTable1[0]={divTable0[2][15:0],divTemp2[0]};
assign divTable1[1]=divTemp0+divTable1[0];
assign divTable1[2]=({16{((divTable1[1][16])?1'b1:1'b0)}} & divTable1[1][15:0]) | ({16{((divTable1[1][16])?1'b0:1'b1)}} & divTable1[0][15:0]);

wire [1:0] divPartialResult;
assign divPartialResult={divTable0[1][16],divTable1[1][16]};


reg [ 2:0] mem_stack_access_size;
reg [31:0] mem_target_address;

reg [15:0] mem_data_in [3:0];

reg mem_is_stack_access_requesting=0;
reg mem_is_general_access_byte_operation=0;
reg mem_is_access_write=0;
reg mem_is_general_access_requesting=0;

assign mem_stack_access_size_extern=mem_stack_access_size;
assign mem_target_address_extern=mem_target_address;

assign mem_data_in_extern=mem_data_in;

assign mem_is_access_write_extern=mem_is_access_write;
assign mem_is_stack_access_requesting_extern=mem_is_stack_access_requesting;

assign mem_is_general_access_byte_operation_extern=mem_is_general_access_byte_operation;
assign mem_is_general_access_requesting_extern=mem_is_general_access_requesting;


reg is_instruction_valid=0;
assign is_instruction_valid_extern=is_instruction_valid;
reg is_instruction_valid_next;
lcell_1 lc_is_instruction_valid_next(is_instruction_valid_next_extern,is_instruction_valid_next);

always @(posedge main_clk) is_instruction_valid<=is_instruction_valid_next;

wire [4:0] effectiveID;
lcell_5 lc_effectiveID(effectiveID,(isUnblocked && is_instruction_valid && !void_current_instruction)?instructionInID:5'h0F);

reg [31:0] instruction_jump_address_next;
assign instruction_jump_address_next_extern=instruction_jump_address_next;

reg j_co;
reg j_uc;
wire j_co_lc;
wire j_uc_lc;
lcell_1 lc_j_co(j_co_lc,j_co);
lcell_1 lc_j_uc(j_uc_lc,j_uc);



wire j_co_sat;
lcell_1 lc_j_co_sat(j_co_sat,(vr2==16'h0)?1'b1:1'b0);
lcell_1 lc_j_n(jump_signal_next,(j_uc_lc || (j_co_lc && j_co_sat))?1'b1:1'b0);

always_comb begin
	is_instruction_valid_next=is_instruction_valid;
	instruction_jump_address_next={vr1,vr0};
	j_co=0;
	j_uc=0;
	dependSelfRegRead_next=dependSelfRegRead & ~resolveDependSelfRegRead;
	dependSelfRegWrite_next=dependSelfRegWrite;
	dependSelfSpecial_next=dependSelfSpecial;
	
	unique case (effectiveID)
	5'h00:begin
		is_instruction_valid_next=0;
	end
	5'h01:begin
		is_instruction_valid_next=0;
	end
	5'h02:begin
		unique case (state)
		1:begin
		end
		2:begin
			is_instruction_valid_next=0;
		end
		endcase
	end
	5'h03:begin
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
		end
	end
	5'h04:begin
		is_instruction_valid_next=0;
	end
	5'h05:begin
		is_instruction_valid_next=0;
	end
	5'h06:begin
		is_instruction_valid_next=0;
	end
	5'h07:begin
		is_instruction_valid_next=0;
	end
	5'h08:begin
		unique case (state)
		1:begin
		end
		2:begin
			is_instruction_valid_next=0;
		end
		endcase
	end
	5'h09:begin
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
		end
	end
	5'h0A:begin
		is_instruction_valid_next=0;
	end
	5'h0B:begin
		is_instruction_valid_next=0;
	end
	5'h0C:begin
		is_instruction_valid_next=0;
	end
	5'h0D:begin
		is_instruction_valid_next=0;
	end
	5'h0E:begin
		is_instruction_valid_next=0;
		j_co=1;
	end
	5'h0F:begin
		// could not execute this cycle
	end
	5'h10:begin
		unique case (state)
		1:begin
			dependSelfRegWrite_next[16]=0;
		end
		2:begin
		end
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
		end
	end
	5'h11:begin
		unique case (state)
		1:begin
			dependSelfRegWrite_next[16]=0;
		end
		2:begin
		end
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
		end
	end
	5'h12:begin
		unique case (state)
		1:begin
			dependSelfRegWrite_next[16]=0;
		end
		2:begin
		end
		3:begin
			is_instruction_valid_next=0;
		end
		endcase
	end
	5'h13:begin
		unique case (state)
		1:begin
			dependSelfRegWrite_next[16]=0;
		end
		2:begin
		end
		3:begin
			is_instruction_valid_next=0;
		end
		endcase
	end
	5'h14:begin
		is_instruction_valid_next=0;
	end
	5'h15:begin
		is_instruction_valid_next=0;
	end
	5'h16:begin
		is_instruction_valid_next=0;
	end
	5'h17:begin
		unique case (state)
		1:begin
		end
		2:begin
			is_instruction_valid_next=0;
		end
		endcase
	end
	5'h18:begin
		unique case (state)
		1:begin
		end
		2:begin
			is_instruction_valid_next=0;
		end
		endcase
	end
	5'h19:begin
		unique case (state)
		1:begin
		end
		2:begin
		end
		3:begin
		end
		4:begin
		end
		5:begin
		end
		6:begin
		end
		7:begin
		end
		8:begin
		end
		9:begin
			is_instruction_valid_next=0;
		end
		endcase
	end
	5'h1A:begin
		unique case (state)
		1:begin
			dependSelfRegWrite_next[16]=0;
			dependSelfRegWrite_next[0]=0;
			dependSelfSpecial_next=0;
			j_uc=1;
		end
		2:begin
		end
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
		end
	end
	5'h1B:begin
		instruction_jump_address_next={mem_data_out[3],mem_data_out[4]};
		unique case (state)
		1:begin
		end
		2:begin
		end
		3:begin
			is_instruction_valid_next=0;
			j_uc=1;
		end
		endcase
	end
	5'h1C:begin
		unique case (state)
		1:begin
		end
		2:begin
			is_instruction_valid_next=0;
		end
		endcase
	end
	5'h1D:begin
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
		end
	end
	5'h1E:begin
		is_instruction_valid_next=0;
		j_uc=1;
	end
	5'h1F:begin
		is_instruction_valid_next=0;
	end
	endcase
	if (memory_dependency_clear[selfIndex]) begin
		dependSelfSpecial_next[1]=0;
		dependSelfSpecial_next[2]=0;
	end
	if (is_new_instruction_entering_this_cycle) begin
		is_instruction_valid_next=1;
		dependSelfRegRead_next=generatedDependSelfRegRead;
		dependSelfRegWrite_next=generatedDependSelfRegWrite;
		dependSelfSpecial_next=generatedDependSelfSpecial;
	end
	if (void_current_instruction) begin
		is_instruction_valid_next=0;
	end
	if (!is_instruction_valid_next) begin
		dependSelfRegRead_next=0;
		dependSelfRegWrite_next=0;
		dependSelfSpecial_next=0;
	end
end

reg [4:0] effectiveID_r=5'h0F;
reg [15:0] instructionIn_r;
reg [15:0] wv_0;
reg [15:0] wv_1;
reg [15:0] wv_2;
reg [15:0] wv_3;
reg [15:0] wv_4;
reg [15:0] wv_5;
reg [15:0] wv_6;
reg [15:0] wv_7;
reg [15:0] wv_8;
reg [15:0] wv_9;

always_comb begin
	temporaryB=16'hx;
	unique case (effectiveID[1:0])
	0:temporaryB=vr1;
	1:temporaryB={vr1[7:0],vr1[15:8]};
	2:temporaryB={1'b0,vr1[14:0]};
	3:temporaryB=16'hx;
	endcase
end

always @(posedge main_clk) begin
	effectiveID_r<=effectiveID;
	instructionIn_r<=instructionIn;
	
	wv_0<=effectiveID[4]?temporaryB:(effectiveID[2]?temporary0:(effectiveID[0]?{instructionIn[11:4],vr0[7:0]}:{8'h0,instructionIn[11:4]}));
	wv_1<=adderOutput[15:0];
	wv_2<={15'h0,adderOutput[16]};
	wv_3<=(effectiveID[3:0]==4'h9)? {divTemp3[15:1],divPartialResult[1]} :mem_data_out[0];
	wv_4<=(effectiveID[3:0]==4'h9)? divTable0[2][15:0]                   :mem_data_out[1];
	wv_5<=mem_data_out[2];
	wv_6<=mul32Temp[15: 0];
	wv_7<=mul32Temp[31:16];
	wv_8<=mul16Temp;
	wv_9<=16'hx;
	case (effectiveID[3:0])
	4'h0:wv_9<=stack_pointer -4'd2;
	4'h1:wv_9<=stack_pointer -4'd4;
	4'h2:wv_9<=stack_pointer +4'd2;
	4'h3:wv_9<=stack_pointer +4'd4;
	4'hA:wv_9<=stack_pointer -4'd8;
	4'hB:wv_9<=(user_reg[4'h0]-4'hA) + mem_data_out[0];
	4'hF:wv_9<=temporary7;
	endcase
end

reg [15:0] twv0;
reg [15:0] twv1;
reg twv1e;
wire [15:0] tcwv0;
wire [15:0] tcwv1;
wire tcwv1e;
lcell_16 lc_twv0(tcwv0,twv0);
lcell_16 lc_twv1(tcwv1,twv1);
lcell_1 lc_twv1e(tcwv1e,twv1e);


always_comb begin
	twv0=16'hx;
	twv1=16'hx;
	twv1e=0;
	unique case (effectiveID_r)
	5'h00:begin
		twv0=wv_0;
	end
	5'h01:begin
		twv0=wv_0;
	end
	5'h02:begin
		twv0=wv_3;
	end
	5'h03:begin
	end
	5'h04:begin
		twv0=wv_0;
	end
	5'h05:begin
		twv0=wv_0;
	end
	5'h06:begin
		twv0=wv_0;
	end
	5'h07:begin
		twv0=wv_2;
		twv1e=1;
		twv1=wv_1;
	end
	5'h08:begin
		twv0=wv_3;
	end
	5'h09:begin
	end
	5'h0A:begin
		twv0=wv_1;
	end
	5'h0B:begin
		twv0=wv_1;
	end
	5'h0C:begin
		twv0=wv_1;
	end
	5'h0D:begin
		twv0=wv_2;
	end
	5'h0E:begin
	end
	5'h0F:begin
		// could not execute this cycle
	end
	5'h10:begin
	end
	5'h11:begin
	end
	5'h12:begin
		twv0=wv_3;
	end
	5'h13:begin
		twv0=wv_3;
		twv1e=1;
		twv1=wv_4;
	end
	5'h14:begin
		twv0=wv_0;
	end
	5'h15:begin
		twv0=wv_0;
	end
	5'h16:begin
		twv0=wv_0;
	end
	5'h17:begin
		twv0=wv_8;
	end
	5'h18:begin
	end
	5'h19:begin
		twv0=wv_3;
		twv1e=1;
		twv1=wv_4;
	end
	5'h1A:begin
	end
	5'h1B:begin
	end
	5'h1C:begin
		twv0=wv_3;
	end
	5'h1D:begin
	end
	5'h1E:begin
	end
	5'h1F:begin
		twv0=wv_9;
	end
	endcase
end

always_comb begin
	writeValues[0]=tcwv0;
	writeValues[1]=tcwv0;
	writeValues[2]=tcwv0;
	writeValues[3]=tcwv0;
	writeValues[4]=tcwv0;
	writeValues[5]=tcwv0;
	writeValues[6]=tcwv0;
	writeValues[7]=tcwv0;
	writeValues[8]=tcwv0;
	writeValues[9]=tcwv0;
	writeValues[10]=tcwv0;
	writeValues[11]=tcwv0;
	writeValues[12]=tcwv0;
	writeValues[13]=tcwv0;
	writeValues[14]=tcwv0;
	writeValues[15]=tcwv0;
	if (tcwv1e) writeValues[instructionIn_r[7:4]]=tcwv1;
	
	unique case (effectiveID_r)
	5'h00:begin
	end
	5'h01:begin
	end
	5'h02:begin
	end
	5'h03:begin
	end
	5'h04:begin
	end
	5'h05:begin
	end
	5'h06:begin
	end
	5'h07:begin
	end
	5'h08:begin
	end
	5'h09:begin
	end
	5'h0A:begin
	end
	5'h0B:begin
		writeValues[15]=wv_2;
	end
	5'h0C:begin
	end
	5'h0D:begin
	end
	5'h0E:begin
	end
	5'h0F:begin
		// could not execute this cycle
	end
	5'h10:begin
	end
	5'h11:begin
	end
	5'h12:begin
	end
	5'h13:begin
	end
	5'h14:begin
	end
	5'h15:begin
	end
	5'h16:begin
	end
	5'h17:begin
	end
	5'h18:begin
		writeValues[13]=wv_6;
		writeValues[14]=wv_7;
	end
	5'h19:begin
	end
	5'h1A:begin
		writeValues[0]=wv_9;
	end
	5'h1B:begin
		writeValues[0]=wv_4;
		writeValues[1]=wv_5;
	end
	5'h1C:begin
	end
	5'h1D:begin
	end
	5'h1E:begin
	end
	5'h1F:begin
	end
	endcase
	writeValues[16]=wv_9;
	writeValues[16][0]=1'b0;
end

always @(posedge main_clk) begin
	dependSelfRegRead<=dependSelfRegRead_next;
	dependSelfRegWrite<=dependSelfRegWrite_next;
	dependSelfSpecial<=dependSelfSpecial_next;
	jump_signal<=jump_signal_next;
end
always @(posedge main_clk) begin
	is_instruction_finishing_this_cycle_pulse<=0;
	doWrite<=0;
	mem_data_in[0]<=16'hx;
	mem_data_in[1]<=16'hx;
	mem_data_in[2]<=16'hx;
	mem_data_in[3]<=16'hx;
	mem_stack_access_size<=3'hx;
	mem_is_stack_access_requesting<=0;
	mem_is_access_write<=1'hx;
	mem_is_general_access_byte_operation<=1'hx;
	mem_is_general_access_requesting<=0;
	
	if (resolveDependSelfRegRead[0]) user_reg[0]<=instant_user_reg[0];
	if (resolveDependSelfRegRead[1]) user_reg[1]<=instant_user_reg[1];
	if (resolveDependSelfRegRead[2]) user_reg[2]<=instant_user_reg[2];
	if (resolveDependSelfRegRead[3]) user_reg[3]<=instant_user_reg[3];
	if (resolveDependSelfRegRead[4]) user_reg[4]<=instant_user_reg[4];
	if (resolveDependSelfRegRead[5]) user_reg[5]<=instant_user_reg[5];
	if (resolveDependSelfRegRead[6]) user_reg[6]<=instant_user_reg[6];
	if (resolveDependSelfRegRead[7]) user_reg[7]<=instant_user_reg[7];
	if (resolveDependSelfRegRead[8]) user_reg[8]<=instant_user_reg[8];
	if (resolveDependSelfRegRead[9]) user_reg[9]<=instant_user_reg[9];
	if (resolveDependSelfRegRead[10]) user_reg[10]<=instant_user_reg[10];
	if (resolveDependSelfRegRead[11]) user_reg[11]<=instant_user_reg[11];
	if (resolveDependSelfRegRead[12]) user_reg[12]<=instant_user_reg[12];
	if (resolveDependSelfRegRead[13]) user_reg[13]<=instant_user_reg[13];
	if (resolveDependSelfRegRead[14]) user_reg[14]<=instant_user_reg[14];
	if (resolveDependSelfRegRead[15]) user_reg[15]<=instant_user_reg[15];
	if (resolveDependSelfRegRead[16]) stack_pointer<=instant_stack_pointer;
	
	unique case (effectiveID)
	5'h00:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h01:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h02:begin
		mem_target_address[15: 0]<=temporary1;
		mem_target_address[31:16]<=0;mem_target_address[0]<=0;
		mem_is_access_write<=0;
		mem_stack_access_size<=0;
		unique case (state)
		1:begin
			mem_is_stack_access_requesting<=1;
			if (mem_is_access_acknowledged_pulse) begin
				mem_is_stack_access_requesting<=0;
				state<=2;
			end
		end
		2:begin
			mem_is_stack_access_requesting<=0;
			doWrite[instructionIn[3:0]]<=1'b1;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
		endcase
	end
	5'h03:begin
		mem_data_in[0]<=vr0;
		mem_target_address[15: 0]<=temporary1;
		mem_target_address[31:16]<=0;mem_target_address[0]<=0;
		mem_is_access_write<=1;
		mem_stack_access_size<=0;
		mem_is_stack_access_requesting<=1;
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_stack_access_requesting<=0;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
	end
	5'h04:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h05:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h06:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h07:begin
		doWrite[instructionIn[7:4]]<=1'b1;
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h08:begin
		mem_target_address<={vr2,vr1};
		mem_is_general_access_byte_operation<=0;
		mem_is_access_write<=0;
		unique case (state)
		1:begin
			mem_is_general_access_requesting<=1;
			if (mem_is_access_acknowledged_pulse) begin
				mem_is_general_access_requesting<=0;
				state<=2;
			end
		end
		2:begin
			mem_is_general_access_requesting<=0;
			doWrite[instructionIn[3:0]]<=1'b1;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
		endcase
	end
	5'h09:begin
		mem_data_in[0]<=vr0;
		mem_target_address<={vr2,vr1};
		mem_is_general_access_byte_operation<=0;
		mem_is_general_access_requesting<=1;
		mem_is_access_write<=1;
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_general_access_requesting<=0;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;

		end
	end
	5'h0A:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h0B:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		doWrite[15]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h0C:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h0D:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h0E:begin
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h0F:begin
		// could not execute this cycle
	end
	5'h10:begin
		mem_data_in[0]<=vr0;
		mem_is_access_write<=1;
		mem_stack_access_size<=0;
		mem_is_stack_access_requesting<=1;
		unique case (state)
		1:begin
			mem_target_address[15: 0]<=stack_pointer -4'd2; // address probably does not need to be here
			mem_target_address[31:16]<=0;mem_target_address[0]<=0;
			doWrite[16]<=1'b1;
			state<=2;
		end
		2:begin
		end
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_stack_access_requesting<=0;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
	end
	5'h11:begin
		mem_data_in[0]<=vr0;
		mem_data_in[1]<=vr1;
		mem_is_access_write<=1;
		mem_stack_access_size<=1;
		mem_is_stack_access_requesting<=1;
		unique case (state)
		1:begin
			mem_target_address[15: 0]<=stack_pointer -4'd4; // address probably does not need to be here
			mem_target_address[31:16]<=0;mem_target_address[0]<=0;
			doWrite[16]<=1'b1;
			state<=2;
		end
		2:begin
		end
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_stack_access_requesting<=0;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
	end
	5'h12:begin
		mem_is_access_write<=0;
		mem_stack_access_size<=0;
		mem_is_stack_access_requesting<=1;
		unique case (state)
		1:begin
			mem_target_address[15: 0]<=stack_pointer; // address probably does not need to be here
			mem_target_address[31:16]<=0;mem_target_address[0]<=0;

			doWrite[16]<=1'b1;
			state<=2;
		end
		2:begin
			if (mem_is_access_acknowledged_pulse) begin
				mem_is_stack_access_requesting<=0;
				state<=3;
			end
		end
		3:begin
			mem_is_stack_access_requesting<=0;
			doWrite[instructionIn[3:0]]<=1'b1;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
		endcase
	end
	5'h13:begin
		mem_is_access_write<=0;
		mem_stack_access_size<=1;
		unique case (state)
		1:begin
			mem_is_stack_access_requesting<=1;
			mem_target_address[15: 0]<=stack_pointer; // address probably does not need to be here
			mem_target_address[31:16]<=0;mem_target_address[0]<=0;
			doWrite[16]<=1'b1;
			state<=2;
		end
		2:begin
			mem_is_stack_access_requesting<=1;
			if (mem_is_access_acknowledged_pulse) begin
				state<=3;
				mem_is_stack_access_requesting<=0;
			end
		end
		3:begin
			mem_is_stack_access_requesting<=0;
			doWrite[instructionIn[3:0]]<=1'b1;
			doWrite[instructionIn[7:4]]<=1'b1;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
		endcase
	end
	5'h14:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h15:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h16:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h17:begin
		unique case (state)
		1:begin
			state<=2;
		end
		2:begin
			doWrite[instructionIn[3:0]]<=1'b1;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
		endcase
	end
	5'h18:begin
		unique case (state)
		1:begin
			state<=2;
		end
		2:begin
			doWrite[13]<=1'b1;
			doWrite[14]<=1'b1;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
		endcase
	end
	5'h19:begin
		unique case (state)
		1:begin
			divTemp0<={1'b0,~vr1}+1'b1;
			divTemp2<=vr0[14:13];
			divTemp5<=divTemp7;
			divTemp3[15]<=divTemp6[16];
			state<=2;
		end
		2:begin
			divTemp2<=vr0[12:11];
			divTemp5<=divTable1[2][15:0];
			divTemp3[14:13]<=divPartialResult;
			state<=3;
		end
		3:begin
			divTemp2<=vr0[10: 9];
			divTemp5<=divTable1[2][15:0];
			divTemp3[12:11]<=divPartialResult;
			state<=4;
		end
		4:begin
			divTemp2<=vr0[8:7];
			divTemp5<=divTable1[2][15:0];
			divTemp3[10: 9]<=divPartialResult;
			state<=5;
		end
		5:begin
			divTemp2<=vr0[6:5];
			divTemp5<=divTable1[2][15:0];
			divTemp3[8:7]<=divPartialResult;
			state<=6;
		end
		6:begin
			divTemp2<=vr0[4:3];
			divTemp5<=divTable1[2][15:0];
			divTemp3[6:5]<=divPartialResult;
			state<=7;
		end
		7:begin
			divTemp2<=vr0[2:1];
			divTemp5<=divTable1[2][15:0];
			divTemp3[4:3]<=divPartialResult;
			state<=8;
		end
		8:begin
			divTemp2<={vr0[0],1'hx};
			divTemp5<=divTable1[2][15:0];
			divTemp3[2:1]<=divPartialResult;
			state<=9;
		end
		9:begin
			doWrite[instructionIn[3:0]]<=1'b1;
			doWrite[instructionIn[7:4]]<=1'b1;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
		endcase
	end
	5'h1A:begin
		mem_data_in[0]<=instructionAddressIn[15:0];
		mem_data_in[1]<={6'b0,instructionAddressIn[25:16]};
		mem_data_in[2]<=user_reg[4'h1];
		mem_data_in[3]<=user_reg[4'h0];
		mem_is_stack_access_requesting<=1;
		mem_is_access_write<=1;
		mem_stack_access_size<=3;
		unique case (state)
		1:begin
			mem_target_address[15: 0]<=stack_pointer -4'd8;
			mem_target_address[31:16]<=0;mem_target_address[0]<=0;
			state<=2;
			doWrite[16]<=1'b1;
			doWrite[0]<=1'b1;
		end
		2:begin
		end
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_stack_access_requesting<=0;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
	end
	5'h1B:begin
		mem_is_access_write<=0;
		mem_stack_access_size<=4;
		unique case (state)
		1:begin
			mem_is_stack_access_requesting<=1;
			mem_target_address[15: 0]<=user_reg[4'h0] -4'h8;
			mem_target_address[31:16]<=0;mem_target_address[0]<=0;
			state<=2;
		end
		2:begin
			mem_is_stack_access_requesting<=1;
			if (mem_is_access_acknowledged_pulse) begin
				mem_is_stack_access_requesting<=0;
				state<=3;
			end
		end
		3:begin
			mem_is_stack_access_requesting<=0;
			doWrite[16]<=1'b1;
			doWrite[0]<=1'b1;
			doWrite[1]<=1'b1;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
		endcase
	end
	5'h1C:begin
		mem_target_address<={vr1,user_reg[4'hD]};
		mem_is_general_access_byte_operation<=1;
		mem_is_access_write<=0;
		unique case (state)
		1:begin
			mem_is_general_access_requesting<=1;
			if (mem_is_access_acknowledged_pulse) begin
				mem_is_general_access_requesting<=0;
				state<=2;
			end
		end
		2:begin
			mem_is_general_access_requesting<=0;
			doWrite[instructionIn[3:0]]<=1'b1;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
		endcase
	end
	5'h1D:begin
		mem_data_in[0]<={8'h0,vr0[7:0]};
		mem_target_address<={vr1,user_reg[4'hD]};
		mem_is_general_access_byte_operation<=1;
		mem_is_general_access_requesting<=1;
		mem_is_access_write<=1;
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_general_access_requesting<=0;
			is_instruction_finishing_this_cycle_pulse<=1;
			state<=0;
		end
	end
	5'h1E:begin
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	5'h1F:begin
		doWrite[16]<=1'b1;
		doWrite[instructionIn[3:0]]<=1'b1;
		is_instruction_finishing_this_cycle_pulse<=1;
		state<=0;
	end
	endcase
	if (is_new_instruction_entering_this_cycle) begin
		instructionIn<=instructionIn_extern;
		instructionInID<=instructionInID_extern;
		instructionAddressIn<=instructionAddressIn_extern;
		state<=1;
		
		//user_reg<=instant_user_reg; // for now, this would not be needed. it might be helpful in the future if I remove a cycle off of the read dependencies being resolved
		//stack_pointer<=instant_stack_pointer;
	end
	if (void_current_instruction) begin
		state<=0;
	end
end


wire [15:0] simExecutingInstruction=((effectiveID==5'h0F)?(is_instruction_valid?16'hx:16'hz):instructionIn); // this is only used for the simulator



always @(posedge main_clk) begin
	assert (is_instruction_valid==((state!=4'd0)?1'b1:1'b0));
	assert (instructionIn!==16'hxxxx);
	assert (effectiveID!==5'hxx);
end



/*
    more significant bits                    less significant bits
# -  15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0
0 -   0,  0,s01,s00, i7, i6, i5, i4, i3, i2, i1, i0,r03,r02,r01,r00
1 - s03,s02,s01,s00,r23,r22,r21,r20,r13,r12,r11,r10,r03,r02,r01,r00        *Note:  s03,s02 != 0,0   and  s03,s02,s01,s00 != 1,1,1,1
2 -   1,  1,  1,  1,s03,s02,s01,s00,r13,r12,r11,r10,r03,r02,r01,r00

Instructions:

0 -     0,0, - immediate -> r0[7:0] , 0 -> r0[F:8]
0 -     0,1, - immediate -> r0[F:8] , r0[7:0] is unchanged
0 -     1,0, - read  stack word at (%1+(2*immediate)) into r0
0 -     1,1, - write stack word at (%1+(2*immediate)) with data in r0

1 - 0,1,0,0, - r1  and r2 -> r0
1 - 0,1,0,1, - r1  or  r2 -> r0
1 - 0,1,1,0, - r1  xor r2 -> r0
1 - 0,1,1,1, - r0 + r1 +~r2 -> r1, with carry stored to ones bit of r0, if carry would be larger then 1, r0 would still hold 1.
1 - 1,0,0,0, - memory read a  word into r0 at r1,r2  (must be aligned to word boundry)
1 - 1,0,0,1, - memory write the word in r0 at r1,r2  (must be aligned to word boundry)
1 - 1,0,1,0, - r1 + r2 -> r0
1 - 1,0,1,1, - r1 + r2 + %F -> r0, with carry stored to ones bit of %F, if carry would be larger then 1, r0 would still hold 1.
1 - 1,1,0,0, - r1 - r2 -> r0
1 - 1,1,0,1, - r1 - r2 (carry)-> r0
1 - 1,1,1,0, - conditional jump if(r2 == 0) to r0,r1 (must be aligned to word boundry)

2 - 0,0,0,0, - push r0 to stack
2 - 0,0,0,1, - push r0 then r1 to stack
2 - 0,0,1,0, - pop stack to r0
2 - 0,0,1,1, - pop stack to r0 then to r1
2 - 0,1,0,0, - mov r1 to r0
2 - 0,1,0,1, - swap bytes in r1, place result in r0 (r1 is not modified)
2 - 0,1,1,0, - shift r1 down one bit towards lower bits and store in r0 (r1 is not modified)
2 - 0,1,1,1, - r0 * r1 -> r0 (word multiply, the upper word is not generated)
2 - 1,0,0,0, - %D,%E * r0,r1 -> %D,%E  (32 bit multiplication, lower 32 bits are stored. %E is the upper word.)
2 - 1,0,0,1, - r0 / r1 -> r0 , r0 % r1 -> r1   (% is the remainder of the division)
2 - 1,0,1,0, - call to address at r0,r1 (must be aligned to word boundry)
2 - 1,0,1,1, - ret
2 - 1,1,0,0, - memory read byte into lower byte of r0 at %D,r1  (upper byte of r0 is set to 0)
2 - 1,1,0,1, - memory write byte in  lower byte of r0 at %D,r1  (upper byte of r0 is effectively ignored, however it should be 0)
2 - 1,1,1,0, - jump to r0,r1 (must be aligned to word boundry)
2 - 1,1,1,1, - SP - r0 -> r0 , then r0 -> SP


When CALL is executed:
  First, it pushes %0 to the stack 
  Then,  it pushes %1 to the stack
  Then,  it pushes the double word of the address the Instruction Pointer should return to on function return. (The upper word is pushed first.)
  Then,  the Stack_Pointer (which is pointing to the lower word of the return address) is put into %0
  Then,  the Instrution Pointer is set to the value in the argument registers

When RET_ is executed:
  First, it sets Stack_Pointer to %0
  Then,  it pops the next two words into the Instruction Pointer. ( first pop is the lower word. )
  Then,  it pops the next word into %1
  Then,  it pops the next word into %0
  Then,  it pops the next word into a temporary storage that will be called TempReg1
  Then,  it does [ Stack_Pointer + TempReg1 -> Stack_Pointer ]


*/


endmodule

