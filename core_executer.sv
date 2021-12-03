`timescale 1 ps / 1 ps


module core_executer(
	input [2:0] selfIndex,
	input [3:0] jumpIndex, // if (jumpIndex[3]) then there is no jump. this is only valid on the first cycle of a jump
	input [3:0] jumpIndex_next,
	input is_new_instruction_entering_this_cycle,
	output is_instruction_valid_extern,
	output is_instruction_valid_next_extern,
	output could_instruction_be_valid_next_extern,
	
	input [15:0] instructionIn_extern,
	input [ 4:0] instructionInID_extern,
	input [25:0] instructionAddressIn_extern,
	
	input [15:0] generated_rename_state_in,
	input [15:0] generated_rename_state_out,
	output [15:0] external_rename_state_out,
	
	input [32:0] generatedDependSelfRegRead,
	input [32:0] generatedDependSelfRegWrite,
	input [2:0] generatedDependSelfSpecial, // .[0]=jump  , .[1]=mem read  , .[2]=mem write
	
	output [32:0] dependSelfRegRead_extern,
	output [32:0] dependSelfRegWrite_extern,
	output [2:0] dependSelfSpecial_extern,
	
	output [32:0] dependSelfRegRead_next_extern,
	output [32:0] dependSelfRegWrite_next_extern,
	output [2:0] dependSelfSpecial_next_extern,
	output [2:0] dependSelfSpecial_estimate_extern,
	
	input [32:0] dependOtherRegRead [7:0],
	input [32:0] dependOtherRegWrite [7:0],
	input [2:0] dependOtherSpecial [7:0],

	input [32:0] dependOtherRegRead_next [7:0],
	input [32:0] dependOtherRegWrite_next [7:0],
	input [2:0] dependOtherSpecial_next [7:0],
	input [2:0] dependOtherSpecial_estimate [7:0],
	
	input [7:0] isAfter,
	input [7:0] isAfter_next,
	
	input [15:0] instant_core_values [32:0],
	
	output [32:0] doWrite_extern, // doWrite[32] is stack pointer's doWrite
	output [15:0] writeValues_extern [32:0],
	
	output [ 2:0] mem_stack_access_size_extern,
	output [31:0] mem_target_address_extern,
	
	input  [15:0] mem_data_out [4:0],
	output [15:0] mem_data_in_extern [3:0],

	output mem_is_access_write_extern,
	output mem_is_general_access_byte_operation_extern,
	output mem_is_general_access_requesting_extern,
	output mem_is_stack_access_requesting_extern,
	output mem_is_stack_access_overflowing_extern,
	
	input  mem_is_access_acknowledged_pulse,
	input [7:0] memory_dependency_clear,
	
	output is_instruction_finishing_this_cycle_pulse_extern, // single cycle pulse
	
	output [31:0] instruction_jump_address_next_extern,
	output jump_signal_extern,
	output jump_signal_next_extern,
	
	input main_clk
);

reg [15:0] rename_state_in=0;
reg [15:0] rename_state_out=0;

assign external_rename_state_out=rename_state_out;

reg [16:0] doWrite=0;
reg [15:0] writeValues [16:0];
reg [15:0] writeValues_a [16:0];
wire [15:0] writeValues_e [16:0];
reg is_instruction_finishing_this_cycle_pulse=0;
assign doWrite_extern[32]=doWrite[16];
assign doWrite_extern[ 1: 0]=doWrite[1:0];
assign doWrite_extern[17:16]=2'b0;
assign doWrite_extern[15: 2]=doWrite[15:2] & ~(rename_state_out[15:2]);
assign doWrite_extern[31:18]=doWrite[15:2] &  (rename_state_out[15:2]);

assign is_instruction_finishing_this_cycle_pulse_extern=is_instruction_finishing_this_cycle_pulse;

lcell_16 lc_wv0(writeValues_e[0],writeValues[0]);
lcell_16 lc_wv1(writeValues_e[1],writeValues[1]);
lcell_16 lc_wv2(writeValues_e[2],writeValues[2]);
lcell_16 lc_wv3(writeValues_e[3],writeValues[3]);
lcell_16 lc_wv4(writeValues_e[4],writeValues[4]);
lcell_16 lc_wv5(writeValues_e[5],writeValues[5]);
lcell_16 lc_wv6(writeValues_e[6],writeValues[6]);
lcell_16 lc_wv7(writeValues_e[7],writeValues[7]);
lcell_16 lc_wv8(writeValues_e[8],writeValues[8]);
lcell_16 lc_wv9(writeValues_e[9],writeValues[9]);
lcell_16 lc_wv10(writeValues_e[10],writeValues[10]);
lcell_16 lc_wv11(writeValues_e[11],writeValues[11]);
lcell_16 lc_wv12(writeValues_e[12],writeValues[12]);
lcell_16 lc_wv13(writeValues_e[13],writeValues[13]);
lcell_16 lc_wv14(writeValues_e[14],writeValues[14]);
lcell_16 lc_wv15(writeValues_e[15],writeValues[15]);
lcell_16 lc_wv16(writeValues_e[16],writeValues[16]);
assign writeValues_extern[0]=writeValues_e[0];assign writeValues_extern[16]=writeValues_e[0];
assign writeValues_extern[1]=writeValues_e[1];assign writeValues_extern[17]=writeValues_e[1];
assign writeValues_extern[2]=writeValues_e[2];assign writeValues_extern[18]=writeValues_e[2];
assign writeValues_extern[3]=writeValues_e[3];assign writeValues_extern[19]=writeValues_e[3];
assign writeValues_extern[4]=writeValues_e[4];assign writeValues_extern[20]=writeValues_e[4];
assign writeValues_extern[5]=writeValues_e[5];assign writeValues_extern[21]=writeValues_e[5];
assign writeValues_extern[6]=writeValues_e[6];assign writeValues_extern[22]=writeValues_e[6];
assign writeValues_extern[7]=writeValues_e[7];assign writeValues_extern[23]=writeValues_e[7];
assign writeValues_extern[8]=writeValues_e[8];assign writeValues_extern[24]=writeValues_e[8];
assign writeValues_extern[9]=writeValues_e[9];assign writeValues_extern[25]=writeValues_e[9];
assign writeValues_extern[10]=writeValues_e[10];assign writeValues_extern[26]=writeValues_e[10];
assign writeValues_extern[11]=writeValues_e[11];assign writeValues_extern[27]=writeValues_e[11];
assign writeValues_extern[12]=writeValues_e[12];assign writeValues_extern[28]=writeValues_e[12];
assign writeValues_extern[13]=writeValues_e[13];assign writeValues_extern[29]=writeValues_e[13];
assign writeValues_extern[14]=writeValues_e[14];assign writeValues_extern[30]=writeValues_e[14];
assign writeValues_extern[15]=writeValues_e[15];assign writeValues_extern[31]=writeValues_e[15];

assign writeValues_extern[32]=writeValues_e[16];

reg [32:0] dependSelfRegRead=0;
reg [32:0] dependSelfRegWrite=0;
reg [2:0] dependSelfSpecial=0;

assign dependSelfRegRead_extern=dependSelfRegRead;
assign dependSelfRegWrite_extern=dependSelfRegWrite;
assign dependSelfSpecial_extern=dependSelfSpecial;

reg [32:0] dependSelfRegRead_next;
reg [32:0] dependSelfRegWrite_next;
reg [2:0] dependSelfSpecial_next;
reg [2:0] dependSelfSpecial_estimate;

assign dependSelfRegRead_next_extern=dependSelfRegRead_next;
assign dependSelfRegWrite_next_extern=dependSelfRegWrite_next;
assign dependSelfSpecial_next_extern=dependSelfSpecial_next;

//assign dependSelfSpecial_estimate_extern=dependSelfSpecial_estimate;// temp
//assign dependSelfSpecial_estimate_extern=dependSelfSpecial_next;//temp
assign dependSelfSpecial_estimate_extern[0]=dependSelfSpecial_next[0];
assign dependSelfSpecial_estimate_extern[2:1]=dependSelfSpecial_estimate[2:1];

reg [32:0] resolveDependSelfRegRead;
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

	if (dependSelfRegRead[18] && !(
		(isAfter[0] && dependOtherRegWrite[0][18]) ||
		(isAfter[1] && dependOtherRegWrite[1][18]) ||
		(isAfter[2] && dependOtherRegWrite[2][18]) ||
		(isAfter[3] && dependOtherRegWrite[3][18]) ||
		(isAfter[4] && dependOtherRegWrite[4][18]) ||
		(isAfter[5] && dependOtherRegWrite[5][18]) ||
		(isAfter[6] && dependOtherRegWrite[6][18]) ||
		(isAfter[7] && dependOtherRegWrite[7][18])
		)) resolveDependSelfRegRead[18]=1'b1;

	if (dependSelfRegRead[19] && !(
		(isAfter[0] && dependOtherRegWrite[0][19]) ||
		(isAfter[1] && dependOtherRegWrite[1][19]) ||
		(isAfter[2] && dependOtherRegWrite[2][19]) ||
		(isAfter[3] && dependOtherRegWrite[3][19]) ||
		(isAfter[4] && dependOtherRegWrite[4][19]) ||
		(isAfter[5] && dependOtherRegWrite[5][19]) ||
		(isAfter[6] && dependOtherRegWrite[6][19]) ||
		(isAfter[7] && dependOtherRegWrite[7][19])
		)) resolveDependSelfRegRead[19]=1'b1;

	if (dependSelfRegRead[20] && !(
		(isAfter[0] && dependOtherRegWrite[0][20]) ||
		(isAfter[1] && dependOtherRegWrite[1][20]) ||
		(isAfter[2] && dependOtherRegWrite[2][20]) ||
		(isAfter[3] && dependOtherRegWrite[3][20]) ||
		(isAfter[4] && dependOtherRegWrite[4][20]) ||
		(isAfter[5] && dependOtherRegWrite[5][20]) ||
		(isAfter[6] && dependOtherRegWrite[6][20]) ||
		(isAfter[7] && dependOtherRegWrite[7][20])
		)) resolveDependSelfRegRead[20]=1'b1;

	if (dependSelfRegRead[21] && !(
		(isAfter[0] && dependOtherRegWrite[0][21]) ||
		(isAfter[1] && dependOtherRegWrite[1][21]) ||
		(isAfter[2] && dependOtherRegWrite[2][21]) ||
		(isAfter[3] && dependOtherRegWrite[3][21]) ||
		(isAfter[4] && dependOtherRegWrite[4][21]) ||
		(isAfter[5] && dependOtherRegWrite[5][21]) ||
		(isAfter[6] && dependOtherRegWrite[6][21]) ||
		(isAfter[7] && dependOtherRegWrite[7][21])
		)) resolveDependSelfRegRead[21]=1'b1;

	if (dependSelfRegRead[22] && !(
		(isAfter[0] && dependOtherRegWrite[0][22]) ||
		(isAfter[1] && dependOtherRegWrite[1][22]) ||
		(isAfter[2] && dependOtherRegWrite[2][22]) ||
		(isAfter[3] && dependOtherRegWrite[3][22]) ||
		(isAfter[4] && dependOtherRegWrite[4][22]) ||
		(isAfter[5] && dependOtherRegWrite[5][22]) ||
		(isAfter[6] && dependOtherRegWrite[6][22]) ||
		(isAfter[7] && dependOtherRegWrite[7][22])
		)) resolveDependSelfRegRead[22]=1'b1;

	if (dependSelfRegRead[23] && !(
		(isAfter[0] && dependOtherRegWrite[0][23]) ||
		(isAfter[1] && dependOtherRegWrite[1][23]) ||
		(isAfter[2] && dependOtherRegWrite[2][23]) ||
		(isAfter[3] && dependOtherRegWrite[3][23]) ||
		(isAfter[4] && dependOtherRegWrite[4][23]) ||
		(isAfter[5] && dependOtherRegWrite[5][23]) ||
		(isAfter[6] && dependOtherRegWrite[6][23]) ||
		(isAfter[7] && dependOtherRegWrite[7][23])
		)) resolveDependSelfRegRead[23]=1'b1;

	if (dependSelfRegRead[24] && !(
		(isAfter[0] && dependOtherRegWrite[0][24]) ||
		(isAfter[1] && dependOtherRegWrite[1][24]) ||
		(isAfter[2] && dependOtherRegWrite[2][24]) ||
		(isAfter[3] && dependOtherRegWrite[3][24]) ||
		(isAfter[4] && dependOtherRegWrite[4][24]) ||
		(isAfter[5] && dependOtherRegWrite[5][24]) ||
		(isAfter[6] && dependOtherRegWrite[6][24]) ||
		(isAfter[7] && dependOtherRegWrite[7][24])
		)) resolveDependSelfRegRead[24]=1'b1;

	if (dependSelfRegRead[25] && !(
		(isAfter[0] && dependOtherRegWrite[0][25]) ||
		(isAfter[1] && dependOtherRegWrite[1][25]) ||
		(isAfter[2] && dependOtherRegWrite[2][25]) ||
		(isAfter[3] && dependOtherRegWrite[3][25]) ||
		(isAfter[4] && dependOtherRegWrite[4][25]) ||
		(isAfter[5] && dependOtherRegWrite[5][25]) ||
		(isAfter[6] && dependOtherRegWrite[6][25]) ||
		(isAfter[7] && dependOtherRegWrite[7][25])
		)) resolveDependSelfRegRead[25]=1'b1;

	if (dependSelfRegRead[26] && !(
		(isAfter[0] && dependOtherRegWrite[0][26]) ||
		(isAfter[1] && dependOtherRegWrite[1][26]) ||
		(isAfter[2] && dependOtherRegWrite[2][26]) ||
		(isAfter[3] && dependOtherRegWrite[3][26]) ||
		(isAfter[4] && dependOtherRegWrite[4][26]) ||
		(isAfter[5] && dependOtherRegWrite[5][26]) ||
		(isAfter[6] && dependOtherRegWrite[6][26]) ||
		(isAfter[7] && dependOtherRegWrite[7][26])
		)) resolveDependSelfRegRead[26]=1'b1;

	if (dependSelfRegRead[27] && !(
		(isAfter[0] && dependOtherRegWrite[0][27]) ||
		(isAfter[1] && dependOtherRegWrite[1][27]) ||
		(isAfter[2] && dependOtherRegWrite[2][27]) ||
		(isAfter[3] && dependOtherRegWrite[3][27]) ||
		(isAfter[4] && dependOtherRegWrite[4][27]) ||
		(isAfter[5] && dependOtherRegWrite[5][27]) ||
		(isAfter[6] && dependOtherRegWrite[6][27]) ||
		(isAfter[7] && dependOtherRegWrite[7][27])
		)) resolveDependSelfRegRead[27]=1'b1;

	if (dependSelfRegRead[28] && !(
		(isAfter[0] && dependOtherRegWrite[0][28]) ||
		(isAfter[1] && dependOtherRegWrite[1][28]) ||
		(isAfter[2] && dependOtherRegWrite[2][28]) ||
		(isAfter[3] && dependOtherRegWrite[3][28]) ||
		(isAfter[4] && dependOtherRegWrite[4][28]) ||
		(isAfter[5] && dependOtherRegWrite[5][28]) ||
		(isAfter[6] && dependOtherRegWrite[6][28]) ||
		(isAfter[7] && dependOtherRegWrite[7][28])
		)) resolveDependSelfRegRead[28]=1'b1;

	if (dependSelfRegRead[29] && !(
		(isAfter[0] && dependOtherRegWrite[0][29]) ||
		(isAfter[1] && dependOtherRegWrite[1][29]) ||
		(isAfter[2] && dependOtherRegWrite[2][29]) ||
		(isAfter[3] && dependOtherRegWrite[3][29]) ||
		(isAfter[4] && dependOtherRegWrite[4][29]) ||
		(isAfter[5] && dependOtherRegWrite[5][29]) ||
		(isAfter[6] && dependOtherRegWrite[6][29]) ||
		(isAfter[7] && dependOtherRegWrite[7][29])
		)) resolveDependSelfRegRead[29]=1'b1;

	if (dependSelfRegRead[30] && !(
		(isAfter[0] && dependOtherRegWrite[0][30]) ||
		(isAfter[1] && dependOtherRegWrite[1][30]) ||
		(isAfter[2] && dependOtherRegWrite[2][30]) ||
		(isAfter[3] && dependOtherRegWrite[3][30]) ||
		(isAfter[4] && dependOtherRegWrite[4][30]) ||
		(isAfter[5] && dependOtherRegWrite[5][30]) ||
		(isAfter[6] && dependOtherRegWrite[6][30]) ||
		(isAfter[7] && dependOtherRegWrite[7][30])
		)) resolveDependSelfRegRead[30]=1'b1;

	if (dependSelfRegRead[31] && !(
		(isAfter[0] && dependOtherRegWrite[0][31]) ||
		(isAfter[1] && dependOtherRegWrite[1][31]) ||
		(isAfter[2] && dependOtherRegWrite[2][31]) ||
		(isAfter[3] && dependOtherRegWrite[3][31]) ||
		(isAfter[4] && dependOtherRegWrite[4][31]) ||
		(isAfter[5] && dependOtherRegWrite[5][31]) ||
		(isAfter[6] && dependOtherRegWrite[6][31]) ||
		(isAfter[7] && dependOtherRegWrite[7][31])
		)) resolveDependSelfRegRead[31]=1'b1;

	if (dependSelfRegRead[32] && !(
		(isAfter[0] && dependOtherRegWrite[0][32]) ||
		(isAfter[1] && dependOtherRegWrite[1][32]) ||
		(isAfter[2] && dependOtherRegWrite[2][32]) ||
		(isAfter[3] && dependOtherRegWrite[3][32]) ||
		(isAfter[4] && dependOtherRegWrite[4][32]) ||
		(isAfter[5] && dependOtherRegWrite[5][32]) ||
		(isAfter[6] && dependOtherRegWrite[6][32]) ||
		(isAfter[7] && dependOtherRegWrite[7][32])
		)) resolveDependSelfRegRead[32]=1'b1;
end

reg [32:0] unreadyDependSelfRegWrite;
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

	if (dependSelfRegWrite[18] && (
		(isAfter[0] && (dependOtherRegRead[0][18] || dependOtherRegWrite[0][18])) ||
		(isAfter[1] && (dependOtherRegRead[1][18] || dependOtherRegWrite[1][18])) ||
		(isAfter[2] && (dependOtherRegRead[2][18] || dependOtherRegWrite[2][18])) ||
		(isAfter[3] && (dependOtherRegRead[3][18] || dependOtherRegWrite[3][18])) ||
		(isAfter[4] && (dependOtherRegRead[4][18] || dependOtherRegWrite[4][18])) ||
		(isAfter[5] && (dependOtherRegRead[5][18] || dependOtherRegWrite[5][18])) ||
		(isAfter[6] && (dependOtherRegRead[6][18] || dependOtherRegWrite[6][18])) ||
		(isAfter[7] && (dependOtherRegRead[7][18] || dependOtherRegWrite[7][18]))
		)) unreadyDependSelfRegWrite[18]=1'b1;

	if (dependSelfRegWrite[19] && (
		(isAfter[0] && (dependOtherRegRead[0][19] || dependOtherRegWrite[0][19])) ||
		(isAfter[1] && (dependOtherRegRead[1][19] || dependOtherRegWrite[1][19])) ||
		(isAfter[2] && (dependOtherRegRead[2][19] || dependOtherRegWrite[2][19])) ||
		(isAfter[3] && (dependOtherRegRead[3][19] || dependOtherRegWrite[3][19])) ||
		(isAfter[4] && (dependOtherRegRead[4][19] || dependOtherRegWrite[4][19])) ||
		(isAfter[5] && (dependOtherRegRead[5][19] || dependOtherRegWrite[5][19])) ||
		(isAfter[6] && (dependOtherRegRead[6][19] || dependOtherRegWrite[6][19])) ||
		(isAfter[7] && (dependOtherRegRead[7][19] || dependOtherRegWrite[7][19]))
		)) unreadyDependSelfRegWrite[19]=1'b1;

	if (dependSelfRegWrite[20] && (
		(isAfter[0] && (dependOtherRegRead[0][20] || dependOtherRegWrite[0][20])) ||
		(isAfter[1] && (dependOtherRegRead[1][20] || dependOtherRegWrite[1][20])) ||
		(isAfter[2] && (dependOtherRegRead[2][20] || dependOtherRegWrite[2][20])) ||
		(isAfter[3] && (dependOtherRegRead[3][20] || dependOtherRegWrite[3][20])) ||
		(isAfter[4] && (dependOtherRegRead[4][20] || dependOtherRegWrite[4][20])) ||
		(isAfter[5] && (dependOtherRegRead[5][20] || dependOtherRegWrite[5][20])) ||
		(isAfter[6] && (dependOtherRegRead[6][20] || dependOtherRegWrite[6][20])) ||
		(isAfter[7] && (dependOtherRegRead[7][20] || dependOtherRegWrite[7][20]))
		)) unreadyDependSelfRegWrite[20]=1'b1;

	if (dependSelfRegWrite[21] && (
		(isAfter[0] && (dependOtherRegRead[0][21] || dependOtherRegWrite[0][21])) ||
		(isAfter[1] && (dependOtherRegRead[1][21] || dependOtherRegWrite[1][21])) ||
		(isAfter[2] && (dependOtherRegRead[2][21] || dependOtherRegWrite[2][21])) ||
		(isAfter[3] && (dependOtherRegRead[3][21] || dependOtherRegWrite[3][21])) ||
		(isAfter[4] && (dependOtherRegRead[4][21] || dependOtherRegWrite[4][21])) ||
		(isAfter[5] && (dependOtherRegRead[5][21] || dependOtherRegWrite[5][21])) ||
		(isAfter[6] && (dependOtherRegRead[6][21] || dependOtherRegWrite[6][21])) ||
		(isAfter[7] && (dependOtherRegRead[7][21] || dependOtherRegWrite[7][21]))
		)) unreadyDependSelfRegWrite[21]=1'b1;

	if (dependSelfRegWrite[22] && (
		(isAfter[0] && (dependOtherRegRead[0][22] || dependOtherRegWrite[0][22])) ||
		(isAfter[1] && (dependOtherRegRead[1][22] || dependOtherRegWrite[1][22])) ||
		(isAfter[2] && (dependOtherRegRead[2][22] || dependOtherRegWrite[2][22])) ||
		(isAfter[3] && (dependOtherRegRead[3][22] || dependOtherRegWrite[3][22])) ||
		(isAfter[4] && (dependOtherRegRead[4][22] || dependOtherRegWrite[4][22])) ||
		(isAfter[5] && (dependOtherRegRead[5][22] || dependOtherRegWrite[5][22])) ||
		(isAfter[6] && (dependOtherRegRead[6][22] || dependOtherRegWrite[6][22])) ||
		(isAfter[7] && (dependOtherRegRead[7][22] || dependOtherRegWrite[7][22]))
		)) unreadyDependSelfRegWrite[22]=1'b1;

	if (dependSelfRegWrite[23] && (
		(isAfter[0] && (dependOtherRegRead[0][23] || dependOtherRegWrite[0][23])) ||
		(isAfter[1] && (dependOtherRegRead[1][23] || dependOtherRegWrite[1][23])) ||
		(isAfter[2] && (dependOtherRegRead[2][23] || dependOtherRegWrite[2][23])) ||
		(isAfter[3] && (dependOtherRegRead[3][23] || dependOtherRegWrite[3][23])) ||
		(isAfter[4] && (dependOtherRegRead[4][23] || dependOtherRegWrite[4][23])) ||
		(isAfter[5] && (dependOtherRegRead[5][23] || dependOtherRegWrite[5][23])) ||
		(isAfter[6] && (dependOtherRegRead[6][23] || dependOtherRegWrite[6][23])) ||
		(isAfter[7] && (dependOtherRegRead[7][23] || dependOtherRegWrite[7][23]))
		)) unreadyDependSelfRegWrite[23]=1'b1;

	if (dependSelfRegWrite[24] && (
		(isAfter[0] && (dependOtherRegRead[0][24] || dependOtherRegWrite[0][24])) ||
		(isAfter[1] && (dependOtherRegRead[1][24] || dependOtherRegWrite[1][24])) ||
		(isAfter[2] && (dependOtherRegRead[2][24] || dependOtherRegWrite[2][24])) ||
		(isAfter[3] && (dependOtherRegRead[3][24] || dependOtherRegWrite[3][24])) ||
		(isAfter[4] && (dependOtherRegRead[4][24] || dependOtherRegWrite[4][24])) ||
		(isAfter[5] && (dependOtherRegRead[5][24] || dependOtherRegWrite[5][24])) ||
		(isAfter[6] && (dependOtherRegRead[6][24] || dependOtherRegWrite[6][24])) ||
		(isAfter[7] && (dependOtherRegRead[7][24] || dependOtherRegWrite[7][24]))
		)) unreadyDependSelfRegWrite[24]=1'b1;

	if (dependSelfRegWrite[25] && (
		(isAfter[0] && (dependOtherRegRead[0][25] || dependOtherRegWrite[0][25])) ||
		(isAfter[1] && (dependOtherRegRead[1][25] || dependOtherRegWrite[1][25])) ||
		(isAfter[2] && (dependOtherRegRead[2][25] || dependOtherRegWrite[2][25])) ||
		(isAfter[3] && (dependOtherRegRead[3][25] || dependOtherRegWrite[3][25])) ||
		(isAfter[4] && (dependOtherRegRead[4][25] || dependOtherRegWrite[4][25])) ||
		(isAfter[5] && (dependOtherRegRead[5][25] || dependOtherRegWrite[5][25])) ||
		(isAfter[6] && (dependOtherRegRead[6][25] || dependOtherRegWrite[6][25])) ||
		(isAfter[7] && (dependOtherRegRead[7][25] || dependOtherRegWrite[7][25]))
		)) unreadyDependSelfRegWrite[25]=1'b1;

	if (dependSelfRegWrite[26] && (
		(isAfter[0] && (dependOtherRegRead[0][26] || dependOtherRegWrite[0][26])) ||
		(isAfter[1] && (dependOtherRegRead[1][26] || dependOtherRegWrite[1][26])) ||
		(isAfter[2] && (dependOtherRegRead[2][26] || dependOtherRegWrite[2][26])) ||
		(isAfter[3] && (dependOtherRegRead[3][26] || dependOtherRegWrite[3][26])) ||
		(isAfter[4] && (dependOtherRegRead[4][26] || dependOtherRegWrite[4][26])) ||
		(isAfter[5] && (dependOtherRegRead[5][26] || dependOtherRegWrite[5][26])) ||
		(isAfter[6] && (dependOtherRegRead[6][26] || dependOtherRegWrite[6][26])) ||
		(isAfter[7] && (dependOtherRegRead[7][26] || dependOtherRegWrite[7][26]))
		)) unreadyDependSelfRegWrite[26]=1'b1;

	if (dependSelfRegWrite[27] && (
		(isAfter[0] && (dependOtherRegRead[0][27] || dependOtherRegWrite[0][27])) ||
		(isAfter[1] && (dependOtherRegRead[1][27] || dependOtherRegWrite[1][27])) ||
		(isAfter[2] && (dependOtherRegRead[2][27] || dependOtherRegWrite[2][27])) ||
		(isAfter[3] && (dependOtherRegRead[3][27] || dependOtherRegWrite[3][27])) ||
		(isAfter[4] && (dependOtherRegRead[4][27] || dependOtherRegWrite[4][27])) ||
		(isAfter[5] && (dependOtherRegRead[5][27] || dependOtherRegWrite[5][27])) ||
		(isAfter[6] && (dependOtherRegRead[6][27] || dependOtherRegWrite[6][27])) ||
		(isAfter[7] && (dependOtherRegRead[7][27] || dependOtherRegWrite[7][27]))
		)) unreadyDependSelfRegWrite[27]=1'b1;

	if (dependSelfRegWrite[28] && (
		(isAfter[0] && (dependOtherRegRead[0][28] || dependOtherRegWrite[0][28])) ||
		(isAfter[1] && (dependOtherRegRead[1][28] || dependOtherRegWrite[1][28])) ||
		(isAfter[2] && (dependOtherRegRead[2][28] || dependOtherRegWrite[2][28])) ||
		(isAfter[3] && (dependOtherRegRead[3][28] || dependOtherRegWrite[3][28])) ||
		(isAfter[4] && (dependOtherRegRead[4][28] || dependOtherRegWrite[4][28])) ||
		(isAfter[5] && (dependOtherRegRead[5][28] || dependOtherRegWrite[5][28])) ||
		(isAfter[6] && (dependOtherRegRead[6][28] || dependOtherRegWrite[6][28])) ||
		(isAfter[7] && (dependOtherRegRead[7][28] || dependOtherRegWrite[7][28]))
		)) unreadyDependSelfRegWrite[28]=1'b1;

	if (dependSelfRegWrite[29] && (
		(isAfter[0] && (dependOtherRegRead[0][29] || dependOtherRegWrite[0][29])) ||
		(isAfter[1] && (dependOtherRegRead[1][29] || dependOtherRegWrite[1][29])) ||
		(isAfter[2] && (dependOtherRegRead[2][29] || dependOtherRegWrite[2][29])) ||
		(isAfter[3] && (dependOtherRegRead[3][29] || dependOtherRegWrite[3][29])) ||
		(isAfter[4] && (dependOtherRegRead[4][29] || dependOtherRegWrite[4][29])) ||
		(isAfter[5] && (dependOtherRegRead[5][29] || dependOtherRegWrite[5][29])) ||
		(isAfter[6] && (dependOtherRegRead[6][29] || dependOtherRegWrite[6][29])) ||
		(isAfter[7] && (dependOtherRegRead[7][29] || dependOtherRegWrite[7][29]))
		)) unreadyDependSelfRegWrite[29]=1'b1;

	if (dependSelfRegWrite[30] && (
		(isAfter[0] && (dependOtherRegRead[0][30] || dependOtherRegWrite[0][30])) ||
		(isAfter[1] && (dependOtherRegRead[1][30] || dependOtherRegWrite[1][30])) ||
		(isAfter[2] && (dependOtherRegRead[2][30] || dependOtherRegWrite[2][30])) ||
		(isAfter[3] && (dependOtherRegRead[3][30] || dependOtherRegWrite[3][30])) ||
		(isAfter[4] && (dependOtherRegRead[4][30] || dependOtherRegWrite[4][30])) ||
		(isAfter[5] && (dependOtherRegRead[5][30] || dependOtherRegWrite[5][30])) ||
		(isAfter[6] && (dependOtherRegRead[6][30] || dependOtherRegWrite[6][30])) ||
		(isAfter[7] && (dependOtherRegRead[7][30] || dependOtherRegWrite[7][30]))
		)) unreadyDependSelfRegWrite[30]=1'b1;

	if (dependSelfRegWrite[31] && (
		(isAfter[0] && (dependOtherRegRead[0][31] || dependOtherRegWrite[0][31])) ||
		(isAfter[1] && (dependOtherRegRead[1][31] || dependOtherRegWrite[1][31])) ||
		(isAfter[2] && (dependOtherRegRead[2][31] || dependOtherRegWrite[2][31])) ||
		(isAfter[3] && (dependOtherRegRead[3][31] || dependOtherRegWrite[3][31])) ||
		(isAfter[4] && (dependOtherRegRead[4][31] || dependOtherRegWrite[4][31])) ||
		(isAfter[5] && (dependOtherRegRead[5][31] || dependOtherRegWrite[5][31])) ||
		(isAfter[6] && (dependOtherRegRead[6][31] || dependOtherRegWrite[6][31])) ||
		(isAfter[7] && (dependOtherRegRead[7][31] || dependOtherRegWrite[7][31]))
		)) unreadyDependSelfRegWrite[31]=1'b1;

	if (dependSelfRegWrite[32] && (
		(isAfter[0] && (dependOtherRegRead[0][32] || dependOtherRegWrite[0][32])) ||
		(isAfter[1] && (dependOtherRegRead[1][32] || dependOtherRegWrite[1][32])) ||
		(isAfter[2] && (dependOtherRegRead[2][32] || dependOtherRegWrite[2][32])) ||
		(isAfter[3] && (dependOtherRegRead[3][32] || dependOtherRegWrite[3][32])) ||
		(isAfter[4] && (dependOtherRegRead[4][32] || dependOtherRegWrite[4][32])) ||
		(isAfter[5] && (dependOtherRegRead[5][32] || dependOtherRegWrite[5][32])) ||
		(isAfter[6] && (dependOtherRegRead[6][32] || dependOtherRegWrite[6][32])) ||
		(isAfter[7] && (dependOtherRegRead[7][32] || dependOtherRegWrite[7][32]))
		)) unreadyDependSelfRegWrite[32]=1'b1;
end

reg isUnblocked=0;
reg isMemUnblocked=0;
wire willMemBeUnblocked;
wire [7:0] isMemUnblockedSourceValues;
wire [41:0] isUnblockedSourceValues;
wire [37:0] isUnblockedSourceValues0_lc;
wire [ 1:0] isUnblockedSourceValues1_lc;

assign isUnblockedSourceValues[32:0]=(dependSelfRegRead & ~resolveDependSelfRegRead) | unreadyDependSelfRegWrite;
assign isUnblockedSourceValues[33]=is_new_instruction_entering_this_cycle;


assign isUnblockedSourceValues[34]=(isAfter_next[0] && dependOtherSpecial_estimate[0][0])? 1'b1:1'b0;
assign isUnblockedSourceValues[35]=(isAfter_next[1] && dependOtherSpecial_estimate[1][0])? 1'b1:1'b0;
assign isUnblockedSourceValues[36]=(isAfter_next[2] && dependOtherSpecial_estimate[2][0])? 1'b1:1'b0;
assign isUnblockedSourceValues[37]=(isAfter_next[3] && dependOtherSpecial_estimate[3][0])? 1'b1:1'b0;
assign isUnblockedSourceValues[38]=(isAfter_next[4] && dependOtherSpecial_estimate[4][0])? 1'b1:1'b0;
assign isUnblockedSourceValues[39]=(isAfter_next[5] && dependOtherSpecial_estimate[5][0])? 1'b1:1'b0;
assign isUnblockedSourceValues[40]=(isAfter_next[6] && dependOtherSpecial_estimate[6][0])? 1'b1:1'b0;
assign isUnblockedSourceValues[41]=(isAfter_next[7] && dependOtherSpecial_estimate[7][0])? 1'b1:1'b0;

assign isMemUnblockedSourceValues[0]=(isAfter_next[0] && ((dependSelfSpecial[2] && dependOtherSpecial_estimate[0][1]) || ((dependSelfSpecial[2] || dependSelfSpecial[1]) && dependOtherSpecial_estimate[0][2])))? 1'b1:1'b0;
assign isMemUnblockedSourceValues[1]=(isAfter_next[1] && ((dependSelfSpecial[2] && dependOtherSpecial_estimate[1][1]) || ((dependSelfSpecial[2] || dependSelfSpecial[1]) && dependOtherSpecial_estimate[1][2])))? 1'b1:1'b0;
assign isMemUnblockedSourceValues[2]=(isAfter_next[2] && ((dependSelfSpecial[2] && dependOtherSpecial_estimate[2][1]) || ((dependSelfSpecial[2] || dependSelfSpecial[1]) && dependOtherSpecial_estimate[2][2])))? 1'b1:1'b0;
assign isMemUnblockedSourceValues[3]=(isAfter_next[3] && ((dependSelfSpecial[2] && dependOtherSpecial_estimate[3][1]) || ((dependSelfSpecial[2] || dependSelfSpecial[1]) && dependOtherSpecial_estimate[3][2])))? 1'b1:1'b0;
assign isMemUnblockedSourceValues[4]=(isAfter_next[4] && ((dependSelfSpecial[2] && dependOtherSpecial_estimate[4][1]) || ((dependSelfSpecial[2] || dependSelfSpecial[1]) && dependOtherSpecial_estimate[4][2])))? 1'b1:1'b0;
assign isMemUnblockedSourceValues[5]=(isAfter_next[5] && ((dependSelfSpecial[2] && dependOtherSpecial_estimate[5][1]) || ((dependSelfSpecial[2] || dependSelfSpecial[1]) && dependOtherSpecial_estimate[5][2])))? 1'b1:1'b0;
assign isMemUnblockedSourceValues[6]=(isAfter_next[6] && ((dependSelfSpecial[2] && dependOtherSpecial_estimate[6][1]) || ((dependSelfSpecial[2] || dependSelfSpecial[1]) && dependOtherSpecial_estimate[6][2])))? 1'b1:1'b0;
assign isMemUnblockedSourceValues[7]=(isAfter_next[7] && ((dependSelfSpecial[2] && dependOtherSpecial_estimate[7][1]) || ((dependSelfSpecial[2] || dependSelfSpecial[1]) && dependOtherSpecial_estimate[7][2])))? 1'b1:1'b0;

lcell_1 lcWillMemBeUnblocked(willMemBeUnblocked,(isMemUnblockedSourceValues==8'h0)? 1'b1:1'b0);
always @(posedge main_clk) begin
	isMemUnblocked<=willMemBeUnblocked;
end


lcell unblocked0_lc(.out(isUnblockedSourceValues0_lc[0]), .in(isUnblockedSourceValues[0]));
lcell unblocked1_lc(.out(isUnblockedSourceValues0_lc[1]), .in(isUnblockedSourceValues[1]));
lcell unblocked2_lc(.out(isUnblockedSourceValues0_lc[2]), .in(isUnblockedSourceValues[2]));
lcell unblocked3_lc(.out(isUnblockedSourceValues0_lc[3]), .in(isUnblockedSourceValues[3]));
lcell unblocked4_lc(.out(isUnblockedSourceValues0_lc[4]), .in(isUnblockedSourceValues[4]));
lcell unblocked5_lc(.out(isUnblockedSourceValues0_lc[5]), .in(isUnblockedSourceValues[5]));
lcell unblocked6_lc(.out(isUnblockedSourceValues0_lc[6]), .in(isUnblockedSourceValues[6]));
lcell unblocked7_lc(.out(isUnblockedSourceValues0_lc[7]), .in(isUnblockedSourceValues[7]));
lcell unblocked8_lc(.out(isUnblockedSourceValues0_lc[8]), .in(isUnblockedSourceValues[8]));
lcell unblocked9_lc(.out(isUnblockedSourceValues0_lc[9]), .in(isUnblockedSourceValues[9]));
lcell unblocked10_lc(.out(isUnblockedSourceValues0_lc[10]), .in(isUnblockedSourceValues[10]));
lcell unblocked11_lc(.out(isUnblockedSourceValues0_lc[11]), .in(isUnblockedSourceValues[11]));
lcell unblocked12_lc(.out(isUnblockedSourceValues0_lc[12]), .in(isUnblockedSourceValues[12]));
lcell unblocked13_lc(.out(isUnblockedSourceValues0_lc[13]), .in(isUnblockedSourceValues[13]));
lcell unblocked14_lc(.out(isUnblockedSourceValues0_lc[14]), .in(isUnblockedSourceValues[14]));
lcell unblocked15_lc(.out(isUnblockedSourceValues0_lc[15]), .in(isUnblockedSourceValues[15]));
lcell unblocked16_lc(.out(isUnblockedSourceValues0_lc[16]), .in(isUnblockedSourceValues[16]));
lcell unblocked17_lc(.out(isUnblockedSourceValues0_lc[17]), .in(isUnblockedSourceValues[17]));
lcell unblocked18_lc(.out(isUnblockedSourceValues0_lc[18]), .in(isUnblockedSourceValues[18]));
lcell unblocked19_lc(.out(isUnblockedSourceValues0_lc[19]), .in(isUnblockedSourceValues[19]));
lcell unblocked20_lc(.out(isUnblockedSourceValues0_lc[20]), .in(isUnblockedSourceValues[20]));
lcell unblocked21_lc(.out(isUnblockedSourceValues0_lc[21]), .in(isUnblockedSourceValues[21]));
lcell unblocked22_lc(.out(isUnblockedSourceValues0_lc[22]), .in(isUnblockedSourceValues[22]));
lcell unblocked23_lc(.out(isUnblockedSourceValues0_lc[23]), .in(isUnblockedSourceValues[23]));
lcell unblocked24_lc(.out(isUnblockedSourceValues0_lc[24]), .in(isUnblockedSourceValues[24]));
lcell unblocked25_lc(.out(isUnblockedSourceValues0_lc[25]), .in(isUnblockedSourceValues[25]));
lcell unblocked26_lc(.out(isUnblockedSourceValues0_lc[26]), .in(isUnblockedSourceValues[26]));
lcell unblocked27_lc(.out(isUnblockedSourceValues0_lc[27]), .in(isUnblockedSourceValues[27]));
lcell unblocked28_lc(.out(isUnblockedSourceValues0_lc[28]), .in(isUnblockedSourceValues[28]));
lcell unblocked29_lc(.out(isUnblockedSourceValues0_lc[29]), .in(isUnblockedSourceValues[29]));
lcell unblocked30_lc(.out(isUnblockedSourceValues0_lc[30]), .in(isUnblockedSourceValues[30]));
lcell unblocked31_lc(.out(isUnblockedSourceValues0_lc[31]), .in(isUnblockedSourceValues[31]));
lcell unblocked32_lc(.out(isUnblockedSourceValues0_lc[32]), .in(isUnblockedSourceValues[32]));
lcell unblocked33_lc(.out(isUnblockedSourceValues0_lc[33]), .in(isUnblockedSourceValues[33]));

lcell unblocked34_lc(.out(isUnblockedSourceValues0_lc[34]), .in(isUnblockedSourceValues[34] | isUnblockedSourceValues[35]));
lcell unblocked35_lc(.out(isUnblockedSourceValues0_lc[35]), .in(isUnblockedSourceValues[36] | isUnblockedSourceValues[37]));
lcell unblocked36_lc(.out(isUnblockedSourceValues0_lc[36]), .in(isUnblockedSourceValues[38] | isUnblockedSourceValues[39]));
lcell unblocked37_lc(.out(isUnblockedSourceValues0_lc[37]), .in(isUnblockedSourceValues[40] | isUnblockedSourceValues[41]));

lcell unblocked38_lc(.out(isUnblockedSourceValues1_lc[0]), .in((isUnblockedSourceValues0_lc[33: 0]==34'h0)? 1'b0:1'b1));
lcell unblocked39_lc(.out(isUnblockedSourceValues1_lc[1]), .in((isUnblockedSourceValues0_lc[37:34]== 4'h0)? 1'b0:1'b1));


always @(posedge main_clk) begin
	//isUnblockedSourceValues_r<=isUnblockedSourceValues0_lc;
	isUnblocked<=(isUnblockedSourceValues1_lc==2'h0)? 1'b1:1'b0;
end

reg jump_signal=0;
reg jump_signal_next;
assign jump_signal_extern=jump_signal;
assign jump_signal_next_extern=jump_signal_next;

reg [7:0] isAfter_forVoidSelf;
always_comb begin
	isAfter_forVoidSelf=isAfter_next;
	isAfter_forVoidSelf[selfIndex]=is_new_instruction_entering_this_cycle;
end

reg void_current_instruction=0;
//always @(posedge main_clk) void_current_instruction<=(!jumpIndex_next[3] && (isAfter[jumpIndex_next[2:0]] || (jumpIndex_next[2:0]==selfIndex && is_new_instruction_entering_this_cycle)))?1'b1:1'b0;
always @(posedge main_clk) void_current_instruction<=(!jumpIndex_next[3] && (isAfter_forVoidSelf[jumpIndex_next[2:0]]))?1'b1:1'b0;

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


wire [15:0] user_reg_D;
wire [15:0] user_reg_E;
lcell_16 lc_user_reg_D(user_reg_D,user_reg[4'hD]);
lcell_16 lc_user_reg_E(user_reg_E,user_reg[4'hE]);

reg [7:0] mul32TempArg0 [3:0];
reg [7:0] mul32TempArg1 [3:0];

always_comb mul32TempArg0[0]=vr0[ 7:0];
always_comb mul32TempArg0[1]=vr0[15:8];
always_comb mul32TempArg0[2]=vr1[ 7:0];
always_comb mul32TempArg0[3]=vr1[15:8];
always_comb mul32TempArg1[0]=user_reg_D[ 7:0];
always_comb mul32TempArg1[1]=user_reg_D[15:8];
always_comb mul32TempArg1[2]=user_reg_E[ 7:0];
always_comb mul32TempArg1[3]=user_reg_E[15:8];

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

/////

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
always @(posedge main_clk) begin if (mem_is_stack_access_requesting) assert(isMemUnblocked);end
always @(posedge main_clk) begin if (mem_is_general_access_requesting) assert(isMemUnblocked);end

reg is_instruction_valid=0;
assign is_instruction_valid_extern=is_instruction_valid;
reg is_instruction_valid_next;
reg could_instruction_be_valid_next; // could_instruction_be_valid_next is an estimation for the scheduler. If 0, it is guaranteed that is_instruction_valid_next is 0. If 1, then is_instruction_valid_next is probably 1 but might be 0.
lcell_1 lc_is_instruction_valid_next(is_instruction_valid_next_extern,is_instruction_valid_next);
lcell_1 lc_could_instruction_be_valid_next(could_instruction_be_valid_next_extern,could_instruction_be_valid_next);

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

wire special_estimate_id;
lcell_1 lc_special_estimate_id(special_estimate_id,(instructionInID==5'h0E)? 1'b1:1'b0);

lcell_1 lc_special_estimate_nj(dependSelfSpecial_estimate[0],(special_estimate_id && isUnblocked && is_instruction_valid)? 1'b0:dependSelfSpecial[0]);

always @(posedge main_clk) begin
	if (!is_new_instruction_entering_this_cycle) begin
		if (dependSelfSpecial_next[0]) assert (dependSelfSpecial_estimate[0]);
		if (dependSelfSpecial_next[1]) assert (dependSelfSpecial_estimate[1]);
		if (dependSelfSpecial_next[2]) assert (dependSelfSpecial_estimate[2]);
	end
end

wire j_co_sat;
lcell_1 lc_j_co_sat(j_co_sat,(vr2==16'h0)?1'b1:1'b0);
lcell_1 lc_j_n(jump_signal_next,(j_uc_lc || (j_co_lc && j_co_sat))?1'b1:1'b0);

always_comb begin
	is_instruction_valid_next=is_instruction_valid;
	could_instruction_be_valid_next=is_instruction_valid;
	instruction_jump_address_next={vr1,vr0};
	j_co=0;
	j_uc=0;
	dependSelfRegRead_next=dependSelfRegRead & ~resolveDependSelfRegRead;
	dependSelfRegWrite_next=dependSelfRegWrite;
	dependSelfSpecial_next=dependSelfSpecial;
	dependSelfSpecial_estimate[2:1]=dependSelfSpecial[2:1];
	
	unique case (effectiveID)
	5'h00:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h01:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h02:begin
		unique case (state)
		1:begin
		end
		2:begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
		endcase
	end
	5'h03:begin
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
	end
	5'h04:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h05:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h06:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h07:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h08:begin
		unique case (state)
		1:begin
		end
		2:begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
		endcase
	end
	5'h09:begin
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
	end
	5'h0A:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h0B:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h0C:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h0D:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h0E:begin
		is_instruction_valid_next=0;
		j_co=1;
		could_instruction_be_valid_next=0;
	end
	5'h0F:begin
		// could not execute this cycle
	end
	5'h10:begin
		unique case (state)
		1:begin
			dependSelfRegWrite_next[32]=0;
		end
		2:begin
		end
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
	end
	5'h11:begin
		unique case (state)
		1:begin
			dependSelfRegWrite_next[32]=0;
		end
		2:begin
		end
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
	end
	5'h12:begin
		unique case (state)
		1:begin
			dependSelfRegWrite_next[32]=0;
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
			dependSelfRegWrite_next[32]=0;
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
		could_instruction_be_valid_next=0;
	end
	5'h15:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h16:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	5'h17:begin
		unique case (state)
		1:begin
		end
		2:begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
		endcase
	end
	5'h18:begin
		unique case (state)
		1:begin
		end
		2:begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
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
			dependSelfRegWrite_next[32]=0;
			dependSelfRegWrite_next[0]=0;dependSelfRegWrite_next[16]=0;
			dependSelfSpecial_next[0]=0;
			j_uc=1;
		end
		2:begin
		end
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
	end
	5'h1B:begin
		instruction_jump_address_next={mem_data_out[1],mem_data_out[0]};
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
			could_instruction_be_valid_next=0;
		end
		endcase
	end
	5'h1D:begin
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
	end
	5'h1E:begin
		is_instruction_valid_next=0;
		j_uc=1;
		could_instruction_be_valid_next=0;
	end
	5'h1F:begin
		is_instruction_valid_next=0;
		could_instruction_be_valid_next=0;
	end
	endcase
	if (memory_dependency_clear[selfIndex]) begin
		dependSelfSpecial_next[1]=0;
		dependSelfSpecial_next[2]=0;
		dependSelfSpecial_estimate[1]=0;
		dependSelfSpecial_estimate[2]=0;
	end
	if (is_new_instruction_entering_this_cycle) begin
		is_instruction_valid_next=1;
		could_instruction_be_valid_next=1;
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
	assert(dependSelfRegRead_next[17:16]==2'b0);
	assert(dependSelfRegWrite_next[17:16]==2'b0);
	dependSelfRegRead_next[17:16]=2'b0;
	dependSelfRegWrite_next[17:16]=2'b0;
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

reg [15:0] mem_data_out_r [4:0];
always @(posedge main_clk) mem_data_out_r<=mem_data_out;

always_comb begin
	temporaryB=16'hx;
	unique case (effectiveID[1:0])
	0:temporaryB=vr1;
	1:temporaryB={vr1[7:0],vr1[15:8]};
	2:temporaryB={1'b0,vr1[15:1]};
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
	wv_5<=mul32Temp[15: 0];
	wv_6<=mul32Temp[31:16];
	wv_7<=mul16Temp;
	wv_8<=16'hx;
	case (effectiveID[3:0])
	4'h0:wv_8<=stack_pointer -4'd2;
	4'h1:wv_8<=stack_pointer -4'd4;
	4'h2:wv_8<=stack_pointer +4'd2;
	4'h3:wv_8<=stack_pointer +4'd4;
	4'hA:wv_8<=stack_pointer -4'd8;
	4'hB:wv_8<=(user_reg[4'h0]+4'hA) + mem_data_out[4];
	4'hF:wv_8<=temporary7;
	endcase
end

reg [2:0] twv0i=0;
reg twv1i=0;
wire [15:0] wv_table0 [5:0];
wire [15:0] wv_table1 [1:0];
assign wv_table0[0]=wv_0;
assign wv_table0[1]=wv_1;
assign wv_table0[2]=wv_2;
assign wv_table0[3]=wv_3;
assign wv_table0[4]=wv_7;
assign wv_table0[5]=wv_8;

assign wv_table1[0]=wv_1;
assign wv_table1[1]=wv_4;


always @(posedge main_clk) begin
	twv0i<=3'hx;
	twv1i<=1'hx;
	unique case (effectiveID)
	5'h00:begin
		twv0i<=0;
	end
	5'h01:begin
		twv0i<=0;
	end
	5'h02:begin
		twv0i<=3;
	end
	5'h03:begin
	end
	5'h04:begin
		twv0i<=0;
	end
	5'h05:begin
		twv0i<=0;
	end
	5'h06:begin
		twv0i<=0;
	end
	5'h07:begin
		twv0i<=2;
		twv1i<=0;
	end
	5'h08:begin
		twv0i<=3;
	end
	5'h09:begin
	end
	5'h0A:begin
		twv0i<=1;
	end
	5'h0B:begin
		twv0i<=1;
	end
	5'h0C:begin
		twv0i<=1;
	end
	5'h0D:begin
		twv0i<=2;
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
		twv0i<=3;
	end
	5'h13:begin
		twv0i<=3;
		twv1i<=1;
	end
	5'h14:begin
		twv0i<=0;
	end
	5'h15:begin
		twv0i<=0;
	end
	5'h16:begin
		twv0i<=0;
	end
	5'h17:begin
		twv0i<=4;
	end
	5'h18:begin
	end
	5'h19:begin
		twv0i<=3;
		twv1i<=1;
	end
	5'h1A:begin
	end
	5'h1B:begin
	end
	5'h1C:begin
		twv0i<=3;
	end
	5'h1D:begin
	end
	5'h1E:begin
	end
	5'h1F:begin
		twv0i<=5;
	end
	endcase
end


reg [15:0] twv0;
reg [15:0] twv1;
reg twv1e;
wire [15:0] tcwv0;
wire [15:0] tcwv1;
wire tcwv1e;

lcell_16 lc_twv0(tcwv0,wv_table0[twv0i]);
lcell_16 lc_twv1(tcwv1,wv_table1[twv1i]);
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
		twv0=wv_7;
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
		twv0=wv_8;
	end
	endcase
end


wire [15:0] writeValueMap1 [15:0][3:0];
reg [1:0] writeValueIndex1 [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
assign writeValueMap1[0][0]=tcwv0;
assign writeValueMap1[0][1]=tcwv1;
assign writeValueMap1[0][2]=wv_8;
assign writeValueMap1[0][3]=mem_data_out_r[3];
assign writeValueMap1[1][0]=tcwv0;
assign writeValueMap1[1][1]=tcwv1;
assign writeValueMap1[1][3:2]='{mem_data_out_r[2],mem_data_out_r[2]};
assign writeValueMap1[2][0]=tcwv0;
assign writeValueMap1[2][1]=tcwv1;
assign writeValueMap1[2][3:2]='{16'hx,16'hx};
assign writeValueMap1[3][0]=tcwv0;
assign writeValueMap1[3][1]=tcwv1;
assign writeValueMap1[3][3:2]='{16'hx,16'hx};
assign writeValueMap1[4][0]=tcwv0;
assign writeValueMap1[4][1]=tcwv1;
assign writeValueMap1[4][3:2]='{16'hx,16'hx};
assign writeValueMap1[5][0]=tcwv0;
assign writeValueMap1[5][1]=tcwv1;
assign writeValueMap1[5][3:2]='{16'hx,16'hx};
assign writeValueMap1[6][0]=tcwv0;
assign writeValueMap1[6][1]=tcwv1;
assign writeValueMap1[6][3:2]='{16'hx,16'hx};
assign writeValueMap1[7][0]=tcwv0;
assign writeValueMap1[7][1]=tcwv1;
assign writeValueMap1[7][3:2]='{16'hx,16'hx};
assign writeValueMap1[8][0]=tcwv0;
assign writeValueMap1[8][1]=tcwv1;
assign writeValueMap1[8][3:2]='{16'hx,16'hx};
assign writeValueMap1[9][0]=tcwv0;
assign writeValueMap1[9][1]=tcwv1;
assign writeValueMap1[9][3:2]='{16'hx,16'hx};
assign writeValueMap1[10][0]=tcwv0;
assign writeValueMap1[10][1]=tcwv1;
assign writeValueMap1[10][3:2]='{16'hx,16'hx};
assign writeValueMap1[11][0]=tcwv0;
assign writeValueMap1[11][1]=tcwv1;
assign writeValueMap1[11][3:2]='{16'hx,16'hx};
assign writeValueMap1[12][0]=tcwv0;
assign writeValueMap1[12][1]=tcwv1;
assign writeValueMap1[12][3:2]='{16'hx,16'hx};
assign writeValueMap1[13][0]=tcwv0;
assign writeValueMap1[13][1]=tcwv1;
assign writeValueMap1[13][3:2]='{wv_5,wv_5};
assign writeValueMap1[14][0]=tcwv0;
assign writeValueMap1[14][1]=tcwv1;
assign writeValueMap1[14][3:2]='{wv_6,wv_6};
assign writeValueMap1[15][0]=tcwv0;
assign writeValueMap1[15][1]=tcwv1;
assign writeValueMap1[15][3:2]='{wv_2,wv_2};


always @(posedge main_clk) begin
	writeValueIndex1<='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	if (effectiveID==5'h07 || effectiveID==5'h13 || effectiveID==5'h19) writeValueIndex1[instructionIn[7:4]][0]<=1'b1;
	
	unique case (effectiveID)
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
		writeValueIndex1[15][1]<=1'b1;
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
		writeValueIndex1[13][1]<=1'b1;
		writeValueIndex1[14][1]<=1'b1;
	end
	5'h19:begin
	end
	5'h1A:begin
		writeValueIndex1[0][1]<=1'b1;
	end
	5'h1B:begin
		writeValueIndex1[0][1]<=1'b1;
		writeValueIndex1[0][0]<=1'b1;
		writeValueIndex1[1][1]<=1'b1;
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
end
always_comb begin
	writeValues[16]=wv_8;
	writeValues[16][0]=1'b0;
	
	writeValues[0]=writeValueMap1[0][writeValueIndex1[0]];
	writeValues[1]=writeValueMap1[1][writeValueIndex1[1]];
	writeValues[2]=writeValueMap1[2][writeValueIndex1[2]];
	writeValues[3]=writeValueMap1[3][writeValueIndex1[3]];
	writeValues[4]=writeValueMap1[4][writeValueIndex1[4]];
	writeValues[5]=writeValueMap1[5][writeValueIndex1[5]];
	writeValues[6]=writeValueMap1[6][writeValueIndex1[6]];
	writeValues[7]=writeValueMap1[7][writeValueIndex1[7]];
	writeValues[8]=writeValueMap1[8][writeValueIndex1[8]];
	writeValues[9]=writeValueMap1[9][writeValueIndex1[9]];
	writeValues[10]=writeValueMap1[10][writeValueIndex1[10]];
	writeValues[11]=writeValueMap1[11][writeValueIndex1[11]];
	writeValues[12]=writeValueMap1[12][writeValueIndex1[12]];
	writeValues[13]=writeValueMap1[13][writeValueIndex1[13]];
	writeValues[14]=writeValueMap1[14][writeValueIndex1[14]];
	writeValues[15]=writeValueMap1[15][writeValueIndex1[15]];
end

always_comb begin
	writeValues_a[0]=tcwv0;
	writeValues_a[1]=tcwv0;
	writeValues_a[2]=tcwv0;
	writeValues_a[3]=tcwv0;
	writeValues_a[4]=tcwv0;
	writeValues_a[5]=tcwv0;
	writeValues_a[6]=tcwv0;
	writeValues_a[7]=tcwv0;
	writeValues_a[8]=tcwv0;
	writeValues_a[9]=tcwv0;
	writeValues_a[10]=tcwv0;
	writeValues_a[11]=tcwv0;
	writeValues_a[12]=tcwv0;
	writeValues_a[13]=tcwv0;
	writeValues_a[14]=tcwv0;
	writeValues_a[15]=tcwv0;
	if (tcwv1e) writeValues_a[instructionIn_r[7:4]]=tcwv1;
	
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
		writeValues_a[15]=wv_2;
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
		writeValues_a[13]=wv_5;
		writeValues_a[14]=wv_6;
	end
	5'h19:begin
	end
	5'h1A:begin
		writeValues_a[0]=wv_8;
	end
	5'h1B:begin
		writeValues_a[0]=mem_data_out_r[3];
		writeValues_a[1]=mem_data_out_r[2];
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
	writeValues_a[16]=wv_8;
	writeValues_a[16][0]=1'b0;
end

always @(posedge main_clk) begin
	assert (tcwv0===twv0);
	assert (tcwv1===twv1);
	assert (writeValues_a[0]===writeValues[0]);
	assert (writeValues_a[1]===writeValues[1]);
	assert (writeValues_a[2]===writeValues[2]);
	assert (writeValues_a[3]===writeValues[3]);
	assert (writeValues_a[4]===writeValues[4]);
	assert (writeValues_a[5]===writeValues[5]);
	assert (writeValues_a[6]===writeValues[6]);
	assert (writeValues_a[7]===writeValues[7]);
	assert (writeValues_a[8]===writeValues[8]);
	assert (writeValues_a[9]===writeValues[9]);
	assert (writeValues_a[10]===writeValues[10]);
	assert (writeValues_a[11]===writeValues[11]);
	assert (writeValues_a[12]===writeValues[12]);
	assert (writeValues_a[13]===writeValues[13]);
	assert (writeValues_a[14]===writeValues[14]);
	assert (writeValues_a[15]===writeValues[15]);
	assert (writeValues_a[16]===writeValues[16]);
end

reg [3:0] stack_access_overflow_detection_temp;
reg stack_access_overflow_detection=0;
reg stack_access_overflow_detection_next;
reg [31:0] mem_target_address_next;
assign mem_is_stack_access_overflowing_extern=stack_access_overflow_detection;

always_comb begin
	stack_access_overflow_detection_temp=4'hx;
	stack_access_overflow_detection_next=stack_access_overflow_detection;
	mem_target_address_next=mem_target_address;
	if (state[1:0]==2'h1) begin // state[3:2] does not matter
		case (effectiveID)
		5'h02:begin
			stack_access_overflow_detection_next=0;
			mem_target_address_next[15: 0]=temporary1;
			mem_target_address_next[31:16]=0;mem_target_address_next[0]=0;
		end
		5'h03:begin
			stack_access_overflow_detection_next=0;
			mem_target_address_next[15: 0]=temporary1;
			mem_target_address_next[31:16]=0;mem_target_address_next[0]=0;
		end
		5'h08:begin
			mem_target_address_next={vr2,vr1};
		end
		5'h09:begin
			mem_target_address_next={vr2,vr1};
		end
		5'h10:begin
			stack_access_overflow_detection_next=0;
			mem_target_address_next[15: 0]=stack_pointer -4'd2;
			mem_target_address_next[31:16]=0;mem_target_address_next[0]=0;
		end
		5'h11:begin
			stack_access_overflow_detection_temp=stack_pointer -4'd4;
			stack_access_overflow_detection_temp=3'd1 + {1'b0,stack_access_overflow_detection_temp[3:1]};
			stack_access_overflow_detection_next=stack_access_overflow_detection_temp[3];
			mem_target_address_next[15: 0]=stack_pointer -4'd4;
			mem_target_address_next[31:16]=0;mem_target_address_next[0]=0;
		end
		5'h12:begin
			stack_access_overflow_detection_next=0;
			mem_target_address_next[15: 0]=stack_pointer;
			mem_target_address_next[31:16]=0;mem_target_address_next[0]=0;
		end
		5'h13:begin
			stack_access_overflow_detection_temp=stack_pointer;
			stack_access_overflow_detection_temp=3'd1 + {1'b0,stack_access_overflow_detection_temp[3:1]};
			stack_access_overflow_detection_next=stack_access_overflow_detection_temp[3];
			mem_target_address_next[15: 0]=stack_pointer;
			mem_target_address_next[31:16]=0;mem_target_address_next[0]=0;
		end
		5'h1A:begin
			stack_access_overflow_detection_temp=stack_pointer -4'd8;
			stack_access_overflow_detection_temp=3'd3 + {1'b0,stack_access_overflow_detection_temp[3:1]};
			stack_access_overflow_detection_next=stack_access_overflow_detection_temp[3];
			mem_target_address_next[15: 0]=stack_pointer -4'd8;
			mem_target_address_next[31:16]=0;mem_target_address_next[0]=0;
		end
		5'h1B:begin
			stack_access_overflow_detection_temp=user_reg[4'h0];
			stack_access_overflow_detection_temp=3'd4 + {1'b0,stack_access_overflow_detection_temp[3:1]};
			stack_access_overflow_detection_next=stack_access_overflow_detection_temp[3];
			mem_target_address_next[15: 0]=user_reg[4'h0];
			mem_target_address_next[31:16]=0;mem_target_address_next[0]=0;
		end
		5'h1C:begin
			mem_target_address_next={vr1,user_reg[4'hD]};
		end
		5'h1D:begin
			mem_target_address_next={vr1,user_reg[4'hD]};
		end
		endcase
	end
	stack_access_overflow_detection_temp=4'hx;
end

always @(posedge main_clk) begin
	dependSelfRegRead<=dependSelfRegRead_next;
	dependSelfRegWrite<=dependSelfRegWrite_next;
	dependSelfSpecial<=dependSelfSpecial_next;
	jump_signal<=jump_signal_next;
	stack_access_overflow_detection<=stack_access_overflow_detection_next;
	mem_target_address<=mem_target_address_next;
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
	
	if (resolveDependSelfRegRead[32]) stack_pointer<=instant_core_values[32];
	if (resolveDependSelfRegRead[0]) user_reg[0]<=instant_core_values[0];
	if (resolveDependSelfRegRead[1]) user_reg[1]<=instant_core_values[1];
	
	if (resolveDependSelfRegRead[2] || resolveDependSelfRegRead[18]) user_reg[2]<=dependSelfRegRead[2]?instant_core_values[2]:instant_core_values[18];
	if (resolveDependSelfRegRead[3] || resolveDependSelfRegRead[19]) user_reg[3]<=dependSelfRegRead[3]?instant_core_values[3]:instant_core_values[19];
	if (resolveDependSelfRegRead[4] || resolveDependSelfRegRead[20]) user_reg[4]<=dependSelfRegRead[4]?instant_core_values[4]:instant_core_values[20];
	if (resolveDependSelfRegRead[5] || resolveDependSelfRegRead[21]) user_reg[5]<=dependSelfRegRead[5]?instant_core_values[5]:instant_core_values[21];
	if (resolveDependSelfRegRead[6] || resolveDependSelfRegRead[22]) user_reg[6]<=dependSelfRegRead[6]?instant_core_values[6]:instant_core_values[22];
	if (resolveDependSelfRegRead[7] || resolveDependSelfRegRead[23]) user_reg[7]<=dependSelfRegRead[7]?instant_core_values[7]:instant_core_values[23];
	if (resolveDependSelfRegRead[8] || resolveDependSelfRegRead[24]) user_reg[8]<=dependSelfRegRead[8]?instant_core_values[8]:instant_core_values[24];
	if (resolveDependSelfRegRead[9] || resolveDependSelfRegRead[25]) user_reg[9]<=dependSelfRegRead[9]?instant_core_values[9]:instant_core_values[25];
	if (resolveDependSelfRegRead[10] || resolveDependSelfRegRead[26]) user_reg[10]<=dependSelfRegRead[10]?instant_core_values[10]:instant_core_values[26];
	if (resolveDependSelfRegRead[11] || resolveDependSelfRegRead[27]) user_reg[11]<=dependSelfRegRead[11]?instant_core_values[11]:instant_core_values[27];
	if (resolveDependSelfRegRead[12] || resolveDependSelfRegRead[28]) user_reg[12]<=dependSelfRegRead[12]?instant_core_values[12]:instant_core_values[28];
	if (resolveDependSelfRegRead[13] || resolveDependSelfRegRead[29]) user_reg[13]<=dependSelfRegRead[13]?instant_core_values[13]:instant_core_values[29];
	if (resolveDependSelfRegRead[14] || resolveDependSelfRegRead[30]) user_reg[14]<=dependSelfRegRead[14]?instant_core_values[14]:instant_core_values[30];
	if (resolveDependSelfRegRead[15] || resolveDependSelfRegRead[31]) user_reg[15]<=dependSelfRegRead[15]?instant_core_values[15]:instant_core_values[31];
	
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
		mem_is_access_write<=0;
		mem_stack_access_size<=0;
		unique case (state)
		1:begin
			mem_is_stack_access_requesting<=willMemBeUnblocked;
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
		mem_is_access_write<=1;
		mem_stack_access_size<=0;
		mem_is_stack_access_requesting<=willMemBeUnblocked;
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
		mem_is_general_access_byte_operation<=0;
		mem_is_access_write<=0;
		unique case (state)
		1:begin
			mem_is_general_access_requesting<=willMemBeUnblocked;
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
		mem_is_general_access_byte_operation<=0;
		mem_is_general_access_requesting<=willMemBeUnblocked;
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
		mem_is_stack_access_requesting<=willMemBeUnblocked;
		unique case (state)
		1:begin
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
		mem_data_in[0]<=vr1;
		mem_data_in[1]<=vr0;
		mem_is_access_write<=1;
		mem_stack_access_size<=1;
		mem_is_stack_access_requesting<=willMemBeUnblocked;
		unique case (state)
		1:begin
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
		mem_is_stack_access_requesting<=willMemBeUnblocked;
		unique case (state)
		1:begin
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
			mem_is_stack_access_requesting<=willMemBeUnblocked;
			doWrite[16]<=1'b1;
			state<=2;
		end
		2:begin
			mem_is_stack_access_requesting<=willMemBeUnblocked;
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
		mem_is_stack_access_requesting<=willMemBeUnblocked;
		mem_is_access_write<=1;
		mem_stack_access_size<=3;
		unique case (state)
		1:begin
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
			mem_is_stack_access_requesting<=willMemBeUnblocked;
			state<=2;
		end
		2:begin
			mem_is_stack_access_requesting<=willMemBeUnblocked;
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
		mem_is_general_access_byte_operation<=1;
		mem_is_access_write<=0;
		unique case (state)
		1:begin
			mem_is_general_access_requesting<=willMemBeUnblocked;
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
		mem_is_general_access_byte_operation<=1;
		mem_is_general_access_requesting<=willMemBeUnblocked;
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
		rename_state_in<=generated_rename_state_in;
		rename_state_out<=generated_rename_state_out;
		state<=1;
	end
	if (void_current_instruction) begin
		state<=0;
	end
	stack_pointer[0]<=1'b0;
end


always @(posedge main_clk) begin
	if (effectiveID!=5'h0F) assert (state!=4'h0);
	if (effectiveID==5'h0F) assert (state==4'h0 || state==4'h1);
	if (effectiveID==5'h0F) assert(!mem_is_stack_access_requesting);
	if (effectiveID==5'h0F) assert(!mem_is_general_access_requesting);
end

wire [15:0] simExecutingInstruction=((effectiveID==5'h0F)?(is_instruction_valid?16'hx:16'hz):(isMemUnblocked?instructionIn:{instructionIn[15:8],8'hxx})); // this is only used for the simulator



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

