`timescale 1 ps / 1 ps


module core_executer #(parameter selfIndex) (
	input [3:0] jumpIndex, // if (jumpIndex[3]) then there is no jump. this is only valid on the first cycle of a jump
	input [3:0] jumpIndex_next,
	input is_new_instruction_entering_this_cycle,
	output is_instruction_valid_extern,
	output is_instruction_valid_next_extern,
	output could_instruction_be_valid_next_extern,
	output possible_remain_valid,
	
	output [15:0] instructionOut_extern,
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
	
	output doSpecialWrite_extern,
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
	
	output [31:0] instruction_jump_address_next_extern,
	output jump_signal_extern,
	output jump_signal_next_extern,
	
	input main_clk
);

genvar i;

wire [4:0] effectiveID;

reg [15:0] rename_state_out=0;
reg [15:0] rename_state_outr=0;
always @(posedge main_clk) rename_state_outr<=rename_state_out;
assign external_rename_state_out=rename_state_out;

reg doSpecialWrite=0;
assign doSpecialWrite_extern=doSpecialWrite;


reg [16:0] doWrite=0;
wire [15:0] writeValues [16:0];
wire [15:0] writeValues_e [16:0];
assign doWrite_extern[32]=doWrite[16];
assign doWrite_extern[ 1: 0]=doWrite[1:0];
assign doWrite_extern[17:16]=2'b0;
assign doWrite_extern[15: 2]=doWrite[15:2] & ~(rename_state_outr[15:2]);
assign doWrite_extern[31:18]=doWrite[15:2] &  (rename_state_outr[15:2]);

generate
for (i=0;i<17;i=i+1) begin : gen0
	lcells #(16) lc_wv(writeValues_e[i],writeValues[i]);
	assign writeValues_extern[i+16]=writeValues_e[i];
	if (i!=16) assign writeValues_extern[i]=writeValues_e[i];
end
endgenerate

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

assign dependSelfSpecial_estimate_extern[2:0]=dependSelfSpecial_estimate[2:0];


wire [32:0] readBlockedByDepend;
wire [32:0] writeBlockedByDepend;
assign readBlockedByDepend[17:16]=2'd0;
assign writeBlockedByDepend[17:16]=2'd0;

wire [32:0] resolveDependSelfRegRead;
assign resolveDependSelfRegRead=dependSelfRegRead & ~readBlockedByDepend;

`include "AutoGen1.sv"


reg isUnblocked=0;
reg isMemUnblocked=0;
wire willMemBeUnblocked;
wire [7:0] isMemUnblockedSourceValues;
wire [41:0] isUnblockedSourceValues;
wire [37:0] isUnblockedSourceValues0_lc;
wire [ 1:0] isUnblockedSourceValues1_lc;

assign isUnblockedSourceValues[32:0]=(dependSelfRegRead & readBlockedByDepend) | (dependSelfRegWrite & writeBlockedByDepend);
assign isUnblockedSourceValues[33]=is_new_instruction_entering_this_cycle;

generate
for (i=0;i<8;i=i+1) begin : gen1
	assign isUnblockedSourceValues[34+i]=(isAfter_next[i] && dependOtherSpecial_estimate[i][0])? 1'b1:1'b0;
	assign isMemUnblockedSourceValues[i]=(isAfter_next[i] && ((dependSelfSpecial[2] && dependOtherSpecial_estimate[i][1]) || ((dependSelfSpecial[2] || dependSelfSpecial[1]) && dependOtherSpecial_estimate[i][2])))? 1'b1:1'b0;
end
endgenerate

lcells #(1) lcWillMemBeUnblocked(willMemBeUnblocked,(isMemUnblockedSourceValues==8'h0 && !is_new_instruction_entering_this_cycle)? 1'b1:1'b0);
always @(posedge main_clk) begin
	isMemUnblocked<=willMemBeUnblocked;
end

lcells #(34) unblocked_lc(isUnblockedSourceValues0_lc[33:0],isUnblockedSourceValues[33:0]);

lcells #(1) unblocked34_lc(isUnblockedSourceValues0_lc[34], (isUnblockedSourceValues[34] | isUnblockedSourceValues[35]));
lcells #(1) unblocked35_lc(isUnblockedSourceValues0_lc[35], (isUnblockedSourceValues[36] | isUnblockedSourceValues[37]));
lcells #(1) unblocked36_lc(isUnblockedSourceValues0_lc[36], (isUnblockedSourceValues[38] | isUnblockedSourceValues[39]));
lcells #(1) unblocked37_lc(isUnblockedSourceValues0_lc[37], (isUnblockedSourceValues[40] | isUnblockedSourceValues[41]));

lcells #(1) unblocked38_lc(isUnblockedSourceValues1_lc[0], (isUnblockedSourceValues0_lc[33: 0]==34'h0)? 1'b0:1'b1);
lcells #(1) unblocked39_lc(isUnblockedSourceValues1_lc[1], (isUnblockedSourceValues0_lc[37:34]== 4'h0)? 1'b0:1'b1);


always @(posedge main_clk) begin
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
always @(posedge main_clk) void_current_instruction<=(!jumpIndex_next[3] && (isAfter_forVoidSelf[jumpIndex_next[2:0]]))?1'b1:1'b0;

reg [15:0] instructionIn=0;
reg [ 4:0] instructionInID=0;
reg [ 3:0] state=0;
assign instructionOut_extern=instructionIn;

reg [15:0] user_reg [15:0];
reg [15:0] stack_pointer;
reg [25:0] instructionAddressIn;

wire [7:0] fast_ur_mux_decoder_incoming [2:0];
reg [7:0] fast_ur_mux_helper_decoder [2:0];
decode3 fast_ur_mux_decode0(fast_ur_mux_decoder_incoming[0],instructionIn[ 3:1]);
decode3 fast_ur_mux_decode1(fast_ur_mux_decoder_incoming[1],instructionIn[ 7:5]);
decode3 fast_ur_mux_decode2(fast_ur_mux_decoder_incoming[2],instructionIn[11:9]);


reg did_new_instruction_enter_last_cycle=0;
always @(posedge main_clk) did_new_instruction_enter_last_cycle<=is_new_instruction_entering_this_cycle;

always @(posedge main_clk) begin
	if (did_new_instruction_enter_last_cycle) begin
		fast_ur_mux_helper_decoder<=fast_ur_mux_decoder_incoming; // It is acceptable to delay this like so. On the first cycle the executer is prevented from executing anyway.
	end
end

wire [15:0] vr0;
wire [15:0] vr1;
wire [15:0] vr2;

fast_ur_mux fast_ur_mux0(vr0,instructionIn[0],fast_ur_mux_helper_decoder[0],user_reg);
fast_ur_mux fast_ur_mux1(vr1,instructionIn[4],fast_ur_mux_helper_decoder[1],user_reg);
fast_ur_mux fast_ur_mux2(vr2,instructionIn[8],fast_ur_mux_helper_decoder[2],user_reg);

wire [15:0] user_reg_D;
wire [15:0] user_reg_E;
lcells #(16) lc_user_reg_D(user_reg_D,user_reg[4'hD]);// doing this seems to prevent quartus from packing these registers into multiplier blocks, which is what I want
lcells #(16) lc_user_reg_E(user_reg_E,user_reg[4'hE]);

wire [7:0] mul32TempArg0 [3:0];
wire [7:0] mul32TempArg1 [3:0];

assign mul32TempArg0[0]=vr0[ 7:0];
assign mul32TempArg0[1]=vr0[15:8];
assign mul32TempArg0[2]=vr1[ 7:0];
assign mul32TempArg0[3]=vr1[15:8];
assign mul32TempArg1[0]=user_reg_D[ 7:0];
assign mul32TempArg1[1]=user_reg_D[15:8];
assign mul32TempArg1[2]=user_reg_E[ 7:0];
assign mul32TempArg1[3]=user_reg_E[15:8];

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

wire [31:0] mul32TempVal1 [4:0];

assign mul32TempVal1[0][15: 0]=mul32TempVal0[0];
assign mul32TempVal1[0][31:16]=mul32TempVal0[2];
assign mul32TempVal1[1][ 7: 0]=0;
assign mul32TempVal1[1][23: 8]=mul32TempVal0[1];
assign mul32TempVal1[1][31:24]=mul32TempVal0[3][7:0];
assign mul32TempVal1[2][ 7: 0]=0;
assign mul32TempVal1[2][23: 8]=mul32TempVal0[4];
assign mul32TempVal1[2][31:24]=mul32TempVal0[6][7:0];
assign mul32TempVal1[3][15: 0]=0;
assign mul32TempVal1[3][31:16]=mul32TempVal0[5]+mul32TempVal0[7];
assign mul32TempVal1[4][23: 0]=0;
assign mul32TempVal1[4][31:24]=mul32TempVal0[8][7:0]+mul32TempVal0[9][7:0];

wire [31:0] mul32Temp;
assign mul32Temp=(mul32TempVal1[0]+(mul32TempVal1[1]+mul32TempVal1[2]))+(mul32TempVal1[3]+mul32TempVal1[4]);

wire [15:0] mul16Temp;

wire [15:0] temporary0;
wire [15:0] temporary1;

wire [18:0] temporary2;
wire [15:0] temporary3;
wire [15:0] temporary4;
wire [15:0] temporary5;
wire [17:0] temporary6;
reg  [15:0] temporary7;
wire [18:0] temporary8;
wire [17:0] temporary9;
wire [17:0] temporaryA;
reg  [15:0] temporaryB;
wire [15:0] temporaryC;
wire [15:0] temporaryD;

wire [16:0] adderOutput;

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

// It is acceptable to delay this like so. On the first cycle the executer is prevented from executing anyway.
reg adderControl0_r=0;always @(posedge main_clk) begin adderControl0_r<=adderControl0_lut[instructionIn[15:12]];end
reg adderControl1_r=0;always @(posedge main_clk) begin adderControl1_r<=adderControl1_lut[instructionIn[15:12]];end
reg adderControl2_r=0;always @(posedge main_clk) begin adderControl2_r<=adderControl2_lut[instructionIn[15:12]];end

lcells #(19) lc_add0 (temporary8,{2'b0,temporary5,1'b1}+adderControl1_r);
lcells #(18) lc_add1 (temporary9,{2'b0,temporary4}+{2'b0,temporary3});
lcells #(18) lc_add2 (temporaryA,temporary8[18:1]+temporary9);

assign temporary6=temporaryA;

generate
for (i=0;i<16;i=i+1) begin : gen2
	assign temporary0[i]=bitwise_lut[{instructionIn[13:12],vr2[i],vr1[i]}];
end
endgenerate

assign temporary3=vr1;
assign temporary4={16{adderControl0_r}} ^ vr2;
assign temporary5={16{adderControl2_r}} & (instructionIn[15]?user_reg[4'hF]:vr0);
assign adderOutput[15:0]=temporary6[15:0];
assign adderOutput[16]=(temporary6[17] | temporary6[16])?1'b1:1'b0;
assign temporary1={instructionIn[11:4],1'b0} + user_reg[4'h1];

always_comb begin
	temporary7=16'hx;
	case (instructionInID[3:0])
	4'h0:temporary7=16'd0 -16'd2;
	4'h1:temporary7=16'd0 -16'd4;
	4'h2:temporary7=16'd2;
	4'h3:temporary7=16'd4;
	4'hA:temporary7=16'd0 -16'd8;
	4'hF:temporary7=16'd0 - {vr0[15:1],1'b0};
	endcase
end
lcells #(15) lc_temporaryC(temporaryC[15:1],temporary7[15:1]);
lcells #(15) lc_temporaryD(temporaryD[15:1],stack_pointer[15:1] + temporaryC[15:1]);
assign temporaryD[0]=1'b0;

reg [15:0] mul16TempVal [2:0];
always @(posedge main_clk) mul16TempVal[0]<=vr0[ 7:0]*vr1[ 7:0];
always @(posedge main_clk) mul16TempVal[1]<=vr0[15:8]*vr1[ 7:0];
always @(posedge main_clk) mul16TempVal[2]<=vr0[ 7:0]*vr1[15:8];

assign mul16Temp[ 7:0]=mul16TempVal[0][ 7:0];
assign mul16Temp[15:8]=mul16TempVal[0][15:8]+mul16TempVal[1][ 7:0]+mul16TempVal[2][ 7:0];



/////


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
lcells #(1) lc_is_instruction_valid_next(is_instruction_valid_next_extern,is_instruction_valid_next);
lcells #(1) lc_could_instruction_be_valid_next(could_instruction_be_valid_next_extern,could_instruction_be_valid_next);

always @(posedge main_clk) is_instruction_valid<=is_instruction_valid_next;

lcells #(5) lc_effectiveID(effectiveID,(isUnblocked && is_instruction_valid && !void_current_instruction)?instructionInID:5'h0F);

always @(posedge main_clk) begin if (^effectiveID===1'bx) $stop; end

reg [31:0] instruction_jump_address_next;
assign instruction_jump_address_next_extern=instruction_jump_address_next;

reg is_one_cycle_instruction=0;

lcells #(1) lc_possible_remain_valid(possible_remain_valid,did_new_instruction_enter_last_cycle | (is_instruction_valid?(isUnblocked?(is_one_cycle_instruction?(1'b0):(1'b1)):1'b1):1'b0));

always @(posedge main_clk) begin
	is_one_cycle_instruction<=0;
	unique case (instructionInID)
	5'h00:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h01:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h02:begin
	end
	5'h03:begin
	end
	5'h04:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h05:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h06:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h07:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h08:begin
	end
	5'h09:begin
	end
	5'h0A:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h0B:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h0C:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h0D:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h0E:begin
		// although this does finish in one cycle, it is the conditional jump instruction. due to particular details with jumping and voiding, it cannot use is_one_cycle_instruction
	end
	5'h0F:begin
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
		is_one_cycle_instruction<=1'b1;
	end
	5'h15:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h16:begin
		is_one_cycle_instruction<=1'b1;
	end
	5'h17:begin
	end
	5'h18:begin
	end
	5'h19:begin
	end
	5'h1A:begin
	end
	5'h1B:begin
	end
	5'h1C:begin
	end
	5'h1D:begin
	end
	5'h1E:begin
		// although this does finish in one cycle, it is the jump instruction.
	end
	5'h1F:begin
		is_one_cycle_instruction<=1'b1;
	end
	endcase
end

reg j_co;
reg j_uc;
wire j_co_lc;
wire j_uc_lc;
lcells #(1) lc_j_co(j_co_lc,j_co);
lcells #(1) lc_j_uc(j_uc_lc,j_uc);

reg special_estimate_id=0;
always @(posedge main_clk) begin
	special_estimate_id<=(instructionInID==5'h0E)? 1'b1:1'b0;
	if (is_new_instruction_entering_this_cycle) special_estimate_id<=0;
end

lcells #(1) lc_special_estimate_nj(dependSelfSpecial_estimate[0],(special_estimate_id && isUnblocked && is_instruction_valid)? 1'b0:dependSelfSpecial[0]);

always @(posedge main_clk) begin
	if (!is_new_instruction_entering_this_cycle) begin
		if (dependSelfSpecial_next[0]) assert (dependSelfSpecial_estimate[0]);
		if (dependSelfSpecial_next[1]) assert (dependSelfSpecial_estimate[1]);
		if (dependSelfSpecial_next[2]) assert (dependSelfSpecial_estimate[2]);
	end
end

wire j_co_sat;
lcells #(1) lc_j_co_sat(j_co_sat,(vr2==16'h0)?1'b1:1'b0);
lcells #(1) lc_j_n(jump_signal_next,(j_uc_lc || (j_co_lc && j_co_sat))?1'b1:1'b0);

always_comb begin
	is_instruction_valid_next=is_instruction_valid;
	could_instruction_be_valid_next=is_instruction_valid;
	instruction_jump_address_next={vr1,vr0};
	j_co=0;
	j_uc=0;
	dependSelfRegRead_next=dependSelfRegRead & readBlockedByDepend;
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
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
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
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
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
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
	end
	5'h13:begin
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
		if (mem_is_access_acknowledged_pulse) begin
			is_instruction_valid_next=0;
			could_instruction_be_valid_next=0;
		end
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


reg [16:0] divTemp0;
reg [ 1:0] divTemp1;
reg [15:0] divTemp2;
reg [15:0] divTemp3;

wire [16:0] divTemp4;assign divTemp4={1'b0,~vr1}+(2'b1+vr0[15]);
wire [15:0] divTemp5;assign divTemp5=({16{((divTemp4[16])?1'b1:1'b0)}} & divTemp4[15:0]) | ({16{((divTemp4[16])?1'b0:1'b1)}} & {15'h0,vr0[15]});

wire [16:0] divTable0 [2:0];
wire [16:0] divTable1 [2:0];

assign divTable0[0]={divTemp3,divTemp1[1]};
assign divTable0[1]=divTemp0+divTable0[0];
assign divTable0[2]=({16{((divTable0[1][16])?1'b1:1'b0)}} & divTable0[1][15:0]) | ({16{((divTable0[1][16])?1'b0:1'b1)}} & divTable0[0][15:0]);

assign divTable1[0]={divTable0[2][15:0],divTemp1[0]};
assign divTable1[1]=divTemp0+divTable1[0];
assign divTable1[2]=({16{((divTable1[1][16])?1'b1:1'b0)}} & divTable1[1][15:0]) | ({16{((divTable1[1][16])?1'b0:1'b1)}} & divTable1[0][15:0]);

wire [1:0] divPartialResult;
assign divPartialResult={divTable0[1][16],divTable1[1][16]};


reg [15:0] wv_0;
reg [15:0] wv_1;
reg [15:0] wv_2;
reg [15:0] wv_3;
reg [15:0] wv_4;
reg [15:0] wv_5;
reg [15:0] wv_6;

always_comb begin
	temporaryB=16'hx;
	case (instructionInID[1:0])
	0:temporaryB=vr1;
	1:temporaryB={vr1[7:0],vr1[15:8]};
	2:temporaryB={1'b0,vr1[15:1]};
	endcase
end


wire [15:0] wv_0_temp [4:0];
lcells #(16) lc_wv_0_temp_0(wv_0_temp[0],instructionInID[0]?{instructionIn[11:4],vr0[7:0]}:{8'h0,instructionIn[11:4]});
lcells #(16) lc_wv_0_temp_1(wv_0_temp[1],temporary0);
lcells #(16) lc_wv_0_temp_2(wv_0_temp[2],temporaryB);
lcells #(16) lc_wv_0_temp_3(wv_0_temp[3],instructionInID[2]?wv_0_temp[1]:wv_0_temp[0]);
lcells #(16) lc_wv_0_temp_4(wv_0_temp[4],instructionInID[4]?wv_0_temp[2]:wv_0_temp[3]);


wire [15:0] wv_7_temp [1:0];
wire [15:0] wv_8_temp [1:0];
lcells #(16) lc_wv_7_temp_0(wv_7_temp[0],{divTemp2[15:1],divPartialResult[1]});
lcells #(16) lc_wv_7_temp_1(wv_7_temp[1],mul16Temp);
lcells #(16) lc_wv_8_temp_0(wv_8_temp[0],temporaryD);
lcells #(16) lc_wv_8_temp_1(wv_8_temp[1],(user_reg[4'h0] + (mem_data_out[4]+4'hA)));

wire wv_8_sw;
lcell lc_wv_8_sw(.out(wv_8_sw),.in((instructionInID[3:0]==4'hB)? 1'b1:1'b0));
wire wv_3_sw;
lcell lc_wv_3_sw(.out(wv_3_sw),.in((instructionInID==5'h17 || instructionInID==5'h19)? 1'b1:1'b0));

wire [15:0] wv_3_temp [1:0];
assign wv_3_temp[0][0]=1'b0;
lcells #(15) lc_wv_3_temp_0(wv_3_temp[0][15:1],wv_8_temp[wv_8_sw][15:1]);
lcells #(16) lc_wv_3_temp_1(wv_3_temp[1],wv_7_temp[instructionInID[2]]);

always @(posedge main_clk) begin
	wv_0<=wv_0_temp[4];
	wv_1<=adderOutput[15:0];
	wv_2<={15'h0,adderOutput[16]};
	wv_3<=wv_3_temp[wv_3_sw];
	wv_4<=divTable0[2][15:0];
	wv_5<=mul32Temp[15: 0];
	wv_6<=mul32Temp[31:16];
end

reg [1:0] twv0i=0;
reg twv1i=0;
wire [15:0] wv_table0 [3:0];
wire [15:0] wv_table1 [1:0];
assign wv_table0[0]=wv_0;
assign wv_table0[1]=wv_1;
assign wv_table0[2]=wv_2;
assign wv_table0[3]=wv_3;

assign wv_table1[0]=wv_1;
assign wv_table1[1]=wv_4;


wire [15:0] tcwv0;
wire [15:0] tcwv1;

lcells #(16) lc_twv0(tcwv0,wv_table0[twv0i]);
lcells #(16) lc_twv1(tcwv1,wv_table1[twv1i]);

wire [15:0] writeValueMap [15:0][3:0];
reg [1:0] writeValueIndex [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
assign writeValueMap[0][0]=tcwv0;
assign writeValueMap[0][1]=tcwv1;
assign writeValueMap[0][3:2]='{16'hx,16'hx};
assign writeValueMap[1][0]=tcwv0;
assign writeValueMap[1][1]=tcwv1;
assign writeValueMap[1][3:2]='{16'hx,16'hx};
assign writeValueMap[2][0]=tcwv0;
assign writeValueMap[2][1]=tcwv1;
assign writeValueMap[2][3:2]='{16'hx,16'hx};
assign writeValueMap[3][0]=tcwv0;
assign writeValueMap[3][1]=tcwv1;
assign writeValueMap[3][3:2]='{16'hx,16'hx};
assign writeValueMap[4][0]=tcwv0;
assign writeValueMap[4][1]=tcwv1;
assign writeValueMap[4][3:2]='{16'hx,16'hx};
assign writeValueMap[5][0]=tcwv0;
assign writeValueMap[5][1]=tcwv1;
assign writeValueMap[5][3:2]='{16'hx,16'hx};
assign writeValueMap[6][0]=tcwv0;
assign writeValueMap[6][1]=tcwv1;
assign writeValueMap[6][3:2]='{16'hx,16'hx};
assign writeValueMap[7][0]=tcwv0;
assign writeValueMap[7][1]=tcwv1;
assign writeValueMap[7][3:2]='{16'hx,16'hx};
assign writeValueMap[8][0]=tcwv0;
assign writeValueMap[8][1]=tcwv1;
assign writeValueMap[8][3:2]='{16'hx,16'hx};
assign writeValueMap[9][0]=tcwv0;
assign writeValueMap[9][1]=tcwv1;
assign writeValueMap[9][3:2]='{16'hx,16'hx};
assign writeValueMap[10][0]=tcwv0;
assign writeValueMap[10][1]=tcwv1;
assign writeValueMap[10][3:2]='{16'hx,16'hx};
assign writeValueMap[11][0]=tcwv0;
assign writeValueMap[11][1]=tcwv1;
assign writeValueMap[11][3:2]='{16'hx,16'hx};
assign writeValueMap[12][0]=tcwv0;
assign writeValueMap[12][1]=tcwv1;
assign writeValueMap[12][3:2]='{16'hx,16'hx};
assign writeValueMap[13][0]=tcwv0;
assign writeValueMap[13][1]=tcwv1;
assign writeValueMap[13][3:2]='{wv_5,wv_5};
assign writeValueMap[14][0]=tcwv0;
assign writeValueMap[14][1]=tcwv1;
assign writeValueMap[14][3:2]='{wv_6,wv_6};
assign writeValueMap[15][0]=tcwv0;
assign writeValueMap[15][1]=tcwv1;
assign writeValueMap[15][3:2]='{wv_2,wv_2};


always @(posedge main_clk) begin
	twv0i<=2'hx;
	twv1i<=0;
	
	writeValueIndex<='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	if (instructionInID==5'h07 || instructionInID==5'h19) writeValueIndex[instructionIn[7:4]][0]<=1'b1;
	
	unique case (instructionInID)
	5'h00:begin
		twv0i<=0;
	end
	5'h01:begin
		twv0i<=0;
	end
	5'h02:begin
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
	end
	5'h08:begin
	end
	5'h09:begin
	end
	5'h0A:begin
		twv0i<=1;
	end
	5'h0B:begin
		twv0i<=1;
		writeValueIndex[15][1]<=1'b1;
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
		// don't care
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
		twv0i<=0;
	end
	5'h15:begin
		twv0i<=0;
	end
	5'h16:begin
		twv0i<=0;
	end
	5'h17:begin
		twv0i<=3;
	end
	5'h18:begin
		writeValueIndex[13][1]<=1'b1;
		writeValueIndex[14][1]<=1'b1;
	end
	5'h19:begin
		twv0i<=3;
		twv1i<=1;
	end
	5'h1A:begin
		twv0i<=3;
	end
	5'h1B:begin
	end
	5'h1C:begin
	end
	5'h1D:begin
	end
	5'h1E:begin
	end
	5'h1F:begin
		twv0i<=3;
	end
	endcase
end

assign writeValues[16][15:1]=wv_3[15:1];
assign writeValues[16][0]=1'b0;
generate
for (i=0;i<16;i=i+1) begin : gen3
	assign writeValues[i]=writeValueMap[i][writeValueIndex[i]];
end
endgenerate

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
	doSpecialWrite<=1'b0;
	
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
		state<=0;
	end
	5'h01:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h02:begin
		mem_is_access_write<=0;
		mem_stack_access_size<=0;
		mem_is_stack_access_requesting<=willMemBeUnblocked;
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_stack_access_requesting<=0;
			doSpecialWrite<=1'b1;
			state<=0;
		end
	end
	5'h03:begin
		mem_data_in[0]<=vr0;
		mem_is_access_write<=1;
		mem_stack_access_size<=0;
		mem_is_stack_access_requesting<=willMemBeUnblocked;
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_stack_access_requesting<=0;
			state<=0;
		end
	end
	5'h04:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h05:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h06:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h07:begin
		doWrite[instructionIn[7:4]]<=1'b1;
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h08:begin
		mem_is_general_access_byte_operation<=0;
		mem_is_access_write<=0;
		mem_is_general_access_requesting<=willMemBeUnblocked;
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_general_access_requesting<=0;
			doSpecialWrite<=1'b1;
			state<=0;
		end
	end
	5'h09:begin
		mem_data_in[0]<=vr0;
		mem_is_general_access_byte_operation<=0;
		mem_is_general_access_requesting<=willMemBeUnblocked;
		mem_is_access_write<=1;
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_general_access_requesting<=0;
			state<=0;
		end
	end
	5'h0A:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h0B:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		doWrite[15]<=1'b1;
		state<=0;
	end
	5'h0C:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h0D:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h0E:begin
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
		end
		endcase
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_stack_access_requesting<=0;
			doSpecialWrite<=1'b1;
			state<=0;
		end
	end
	5'h13:begin
		mem_is_access_write<=0;
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
			doSpecialWrite<=1'b1;
			state<=0;
		end
	end
	5'h14:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h15:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h16:begin
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	5'h17:begin
		unique case (state)
		1:begin
			state<=2;
		end
		2:begin
			doWrite[instructionIn[3:0]]<=1'b1;
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
			state<=0;
		end
		endcase
	end
	5'h19:begin
		unique case (state)
		1:begin
			divTemp0<={1'b0,~vr1}+1'b1;
			divTemp1<=vr0[14:13];
			divTemp3<=divTemp5;
			divTemp2[15]<=divTemp4[16];
			state<=2;
		end
		2:begin
			divTemp1<=vr0[12:11];
			divTemp3<=divTable1[2][15:0];
			divTemp2[14:13]<=divPartialResult;
			state<=3;
		end
		3:begin
			divTemp1<=vr0[10: 9];
			divTemp3<=divTable1[2][15:0];
			divTemp2[12:11]<=divPartialResult;
			state<=4;
		end
		4:begin
			divTemp1<=vr0[8:7];
			divTemp3<=divTable1[2][15:0];
			divTemp2[10: 9]<=divPartialResult;
			state<=5;
		end
		5:begin
			divTemp1<=vr0[6:5];
			divTemp3<=divTable1[2][15:0];
			divTemp2[8:7]<=divPartialResult;
			state<=6;
		end
		6:begin
			divTemp1<=vr0[4:3];
			divTemp3<=divTable1[2][15:0];
			divTemp2[6:5]<=divPartialResult;
			state<=7;
		end
		7:begin
			divTemp1<=vr0[2:1];
			divTemp3<=divTable1[2][15:0];
			divTemp2[4:3]<=divPartialResult;
			state<=8;
		end
		8:begin
			divTemp1<={vr0[0],1'hx};
			divTemp3<=divTable1[2][15:0];
			divTemp2[2:1]<=divPartialResult;
			state<=9;
		end
		9:begin
			doWrite[instructionIn[3:0]]<=1'b1;
			doWrite[instructionIn[7:4]]<=1'b1;
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
				doSpecialWrite<=1'b1;
				state<=3;
			end
		end
		3:begin
			mem_is_stack_access_requesting<=0;
			doWrite[16]<=1'b1;
			state<=0;
		end
		endcase
	end
	5'h1C:begin
		mem_is_general_access_byte_operation<=1;
		mem_is_access_write<=0;
		mem_is_general_access_requesting<=willMemBeUnblocked;
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_general_access_requesting<=0;
			doSpecialWrite<=1'b1;
			state<=0;
		end
	end
	5'h1D:begin
		mem_data_in[0]<={8'h0,vr0[7:0]};
		mem_is_general_access_byte_operation<=1;
		mem_is_general_access_requesting<=willMemBeUnblocked;
		mem_is_access_write<=1;
		if (mem_is_access_acknowledged_pulse) begin
			mem_is_general_access_requesting<=0;
			state<=0;
		end
	end
	5'h1E:begin
		state<=0;
	end
	5'h1F:begin
		doWrite[16]<=1'b1;
		doWrite[instructionIn[3:0]]<=1'b1;
		state<=0;
	end
	endcase
	if (is_new_instruction_entering_this_cycle) begin
		instructionIn<=instructionIn_extern;
		instructionInID<=instructionInID_extern;
		instructionAddressIn<=instructionAddressIn_extern;
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

reg simValueForVisualization=0;
always @(*) simValueForVisualization<=#1 ~simValueForVisualization | is_new_instruction_entering_this_cycle;
wire [15:0] simExecutingInstruction=((effectiveID==5'h0F)?(is_instruction_valid?((did_new_instruction_enter_last_cycle?simValueForVisualization:1'b1)?16'hx:16'hz):16'hz):(isMemUnblocked?instructionIn:{instructionIn[15:8],8'hxx})); // this is only used for the simulator



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
1 - 1,0,0,0, - memory read a  word into r0 at r1,r2  (must be aligned to word boundary)
1 - 1,0,0,1, - memory write the word in r0 at r1,r2  (must be aligned to word boundary)
1 - 1,0,1,0, - r1 + r2 -> r0
1 - 1,0,1,1, - r1 + r2 + %F -> r0, with carry stored to ones bit of %F, if carry would be larger then 1, r0 would still hold 1.
1 - 1,1,0,0, - r1 - r2 -> r0
1 - 1,1,0,1, - r1 - r2 (carry)-> r0
1 - 1,1,1,0, - conditional jump if(r2 == 0) to r0,r1 (must be aligned to word boundary)

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
2 - 1,0,1,0, - call to address at r0,r1 (must be aligned to word boundary)
2 - 1,0,1,1, - ret
2 - 1,1,0,0, - memory read byte into lower byte of r0 at %D,r1  (upper byte of r0 is set to 0)
2 - 1,1,0,1, - memory write byte in  lower byte of r0 at %D,r1  (upper byte of r0 is effectively ignored, however it should be 0)
2 - 1,1,1,0, - jump to r0,r1 (must be aligned to word boundary)
2 - 1,1,1,1, - SP - r0 -> r0 , then r0 -> SP


When CALL is executed:
  First, it pushes %0 to the stack 
  Then,  it pushes %1 to the stack
  Then,  it pushes the double word of the address the Instruction Pointer should return to on function return. (The upper word is pushed first.)
  Then,  the Stack_Pointer (which is pointing to the lower word of the return address) is put into %0
  Then,  the Instruction Pointer is set to the value in the argument registers

When RET_ is executed:
  First, it sets Stack_Pointer to %0
  Then,  it pops the next two words into the Instruction Pointer. ( first pop is the lower word. )
  Then,  it pops the next word into %1
  Then,  it pops the next word into %0
  Then,  it pops the next word into a temporary storage that will be called TempReg1
  Then,  it does [ Stack_Pointer + TempReg1 -> Stack_Pointer ]


*/


endmodule

