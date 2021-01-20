

module instruction_categorizer(
	output [13:0] catagory_data_extern,
	input  [4:0] instruction_id
);

reg [13:0] catagory_data;
assign catagory_data_extern=catagory_data;

// catagory_data[ 0] if instruction may/will cause jump. will block all instructions that would go after.
// catagory_data[ 1] if instruction uses the stack pointer. only 1 instruction may use the stack pointer at one time [uses means it will read and write]
// catagory_data[ 2] if instruction reads  user_reg[ 1] in a specific way
// catagory_data[ 3] if instruction reads  user_reg[13] in a specific way
// catagory_data[ 4] if instruction uses   user_reg[13] and user_reg[14] in a specific way [uses means it will read and write]
// catagory_data[ 5] { unused }
// catagory_data[ 6] if instruction uses   user_reg[15] in a specific way [uses means it will read and write]
// catagory_data[ 7] if instruction reads  user_reg[r0]
// catagory_data[ 8] if instruction writes user_reg[r0]
// catagory_data[ 9] if instruction reads  user_reg[r1]
// catagory_data[10] if instruction writes user_reg[r1]
// catagory_data[11] if instruction reads  user_reg[r2]
// catagory_data[12] if instruction reads memory. All memory writes are blocked by a memory read. Memory reads may be issued out of order.
// catagory_data[13] if instruction writes memory. All memory read/writes are blocked by a memory write.



always_comb begin
	catagory_data=0;
	case (instruction_id) // sort-of cannot be unique because sometimes `instruction_id===5'hx` , which cases a warning in modelsim that I don't want to see. In those situations, the output is totally fine to be undefined as well, because it isn't used
	0:begin
		catagory_data[8]=1;
	end
	1:begin
		catagory_data[7]=1;
		catagory_data[8]=1;
	end
	2:begin
		catagory_data[8]=1;
		catagory_data[2]=1;
		catagory_data[12]=1;
	end
	3:begin
		catagory_data[7]=1;
		catagory_data[2]=1;
		catagory_data[13]=1;
	end
	4:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[11]=1;
	end
	5:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[11]=1;
	end
	6:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[11]=1;
	end
	7:begin
		catagory_data[7]=1;
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[10]=1;
		catagory_data[11]=1;
	end
	8:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[11]=1;
		catagory_data[12]=1;
	end
	9:begin
		catagory_data[7]=1;
		catagory_data[9]=1;
		catagory_data[11]=1;
		catagory_data[13]=1;
	end
	10:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[11]=1;
	end
	11:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[11]=1;
		catagory_data[6]=1;
	end
	12:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[11]=1;
	end
	13:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[11]=1;
	end
	14:begin
		catagory_data[0]=1;
		catagory_data[7]=1;
		catagory_data[9]=1;
		catagory_data[11]=1;
	end
	15:begin // case 15 is impossible
		catagory_data=14'hx;
	end
	16:begin
		catagory_data[1]=1;
		catagory_data[7]=1;
	end
	17:begin
		catagory_data[1]=1;
		catagory_data[7]=1;
		catagory_data[9]=1;
	end
	18:begin
		catagory_data[1]=1;
		catagory_data[8]=1;
	end
	19:begin
		catagory_data[1]=1;
		catagory_data[8]=1;
		catagory_data[10]=1;
	end
	20:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
	end
	21:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
	end
	22:begin
		catagory_data[8]=1;
		catagory_data[9]=1;
	end
	23:begin
		catagory_data[7]=1;
		catagory_data[8]=1;
		catagory_data[9]=1;
	end
	24:begin
		catagory_data[7]=1;
		catagory_data[9]=1;
		catagory_data[4]=1;
	end
	25:begin
		catagory_data[7]=1;
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[10]=1;
	end
	26:begin
		catagory_data[0]=1;
		catagory_data[1]=1;
		catagory_data[7]=1;
		catagory_data[9]=1;
	end
	27:begin
		catagory_data[0]=1;
		catagory_data[1]=1;
	end
	28:begin
		catagory_data[3]=1;
		catagory_data[8]=1;
		catagory_data[9]=1;
		catagory_data[12]=1;
	end
	29:begin
		catagory_data[3]=1;
		catagory_data[7]=1;
		catagory_data[9]=1;
		catagory_data[13]=1;
	end
	30:begin
		catagory_data[0]=1;
		catagory_data[7]=1;
		catagory_data[9]=1;
	end
	31:begin
		catagory_data[1]=1;
		catagory_data[7]=1;
		catagory_data[8]=1;
	end
	endcase
end
endmodule



module instruction_conflict_detector(
	output doInstructionsConflict0_extern, // general conflict
	output doInstructionsConflict1_extern,
	output doInstructionsConflict2_extern, // memory order conflict
	input  [13:0] instructionCurrentID_0_isCatagory, // this instruction is ordered before the other
	input  [13:0] instructionCurrentID_1_isCatagory, // this instruction is ordered after  the other
	input  [15:0] instructionCurrent_scheduler_0,
	input  [15:0] instructionCurrent_scheduler_1
);



reg doInstructionsConflict0;
reg doInstructionsConflict1;
reg doInstructionsConflict2;
assign doInstructionsConflict0_extern=doInstructionsConflict0;
assign doInstructionsConflict1_extern=doInstructionsConflict1;
assign doInstructionsConflict2_extern=doInstructionsConflict2;

always_comb begin
	doInstructionsConflict0=0;
	
	if (instructionCurrentID_0_isCatagory[0]) doInstructionsConflict0=1;
	
	if (instructionCurrentID_0_isCatagory[1] && instructionCurrentID_1_isCatagory[1]) doInstructionsConflict0=1;
	
	if (instructionCurrentID_0_isCatagory[2] && ((instructionCurrentID_1_isCatagory[ 8]) && (instructionCurrent_scheduler_1[ 3:0]==4'h1))) doInstructionsConflict0=1;
	if (instructionCurrentID_0_isCatagory[2] && ((instructionCurrentID_1_isCatagory[10]) && (instructionCurrent_scheduler_1[ 7:4]==4'h1))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[2] && ((instructionCurrentID_0_isCatagory[ 8]) && (instructionCurrent_scheduler_0[ 3:0]==4'h1))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[2] && ((instructionCurrentID_0_isCatagory[10]) && (instructionCurrent_scheduler_0[ 7:4]==4'h1))) doInstructionsConflict0=1;
	
	if (instructionCurrentID_0_isCatagory[3] && instructionCurrentID_1_isCatagory[4]) doInstructionsConflict0=1;
	if (instructionCurrentID_0_isCatagory[4] && instructionCurrentID_1_isCatagory[3]) doInstructionsConflict0=1;
	if (instructionCurrentID_0_isCatagory[4] && instructionCurrentID_1_isCatagory[4]) doInstructionsConflict0=1;
	
	if (instructionCurrentID_0_isCatagory[4] && ((instructionCurrentID_1_isCatagory[ 7] || instructionCurrentID_1_isCatagory[ 8]) && (instructionCurrent_scheduler_1[ 3:0]==4'hD))) doInstructionsConflict0=1;
	if (instructionCurrentID_0_isCatagory[4] && ((instructionCurrentID_1_isCatagory[ 9] || instructionCurrentID_1_isCatagory[10]) && (instructionCurrent_scheduler_1[ 7:4]==4'hD))) doInstructionsConflict0=1;
	if (instructionCurrentID_0_isCatagory[4] && ((instructionCurrentID_1_isCatagory[11]                                         ) && (instructionCurrent_scheduler_1[11:8]==4'hD))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[4] && ((instructionCurrentID_0_isCatagory[ 7] || instructionCurrentID_0_isCatagory[ 8]) && (instructionCurrent_scheduler_0[ 3:0]==4'hD))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[4] && ((instructionCurrentID_0_isCatagory[ 9] || instructionCurrentID_0_isCatagory[10]) && (instructionCurrent_scheduler_0[ 7:4]==4'hD))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[4] && ((instructionCurrentID_0_isCatagory[11]                                         ) && (instructionCurrent_scheduler_0[11:8]==4'hD))) doInstructionsConflict0=1;
	
	if (instructionCurrentID_0_isCatagory[4] && ((instructionCurrentID_1_isCatagory[ 7] || instructionCurrentID_1_isCatagory[ 8]) && (instructionCurrent_scheduler_1[ 3:0]==4'hE))) doInstructionsConflict0=1;
	if (instructionCurrentID_0_isCatagory[4] && ((instructionCurrentID_1_isCatagory[ 9] || instructionCurrentID_1_isCatagory[10]) && (instructionCurrent_scheduler_1[ 7:4]==4'hE))) doInstructionsConflict0=1;
	if (instructionCurrentID_0_isCatagory[4] && ((instructionCurrentID_1_isCatagory[11]                                         ) && (instructionCurrent_scheduler_1[11:8]==4'hE))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[4] && ((instructionCurrentID_0_isCatagory[ 7] || instructionCurrentID_0_isCatagory[ 8]) && (instructionCurrent_scheduler_0[ 3:0]==4'hE))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[4] && ((instructionCurrentID_0_isCatagory[ 9] || instructionCurrentID_0_isCatagory[10]) && (instructionCurrent_scheduler_0[ 7:4]==4'hE))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[4] && ((instructionCurrentID_0_isCatagory[11]                                         ) && (instructionCurrent_scheduler_0[11:8]==4'hE))) doInstructionsConflict0=1;
	
	if (instructionCurrentID_0_isCatagory[3] && ((instructionCurrentID_1_isCatagory[ 8]) && (instructionCurrent_scheduler_1[ 3:0]==4'hD))) doInstructionsConflict0=1;
	if (instructionCurrentID_0_isCatagory[3] && ((instructionCurrentID_1_isCatagory[10]) && (instructionCurrent_scheduler_1[ 7:4]==4'hD))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[3] && ((instructionCurrentID_0_isCatagory[ 8]) && (instructionCurrent_scheduler_0[ 3:0]==4'hD))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[3] && ((instructionCurrentID_0_isCatagory[10]) && (instructionCurrent_scheduler_0[ 7:4]==4'hD))) doInstructionsConflict0=1;
	
	if (instructionCurrentID_0_isCatagory[6] && ((instructionCurrentID_1_isCatagory[ 7] || instructionCurrentID_1_isCatagory[ 8]) && (instructionCurrent_scheduler_1[ 3:0]==4'hF))) doInstructionsConflict0=1;
	if (instructionCurrentID_0_isCatagory[6] && ((instructionCurrentID_1_isCatagory[ 9] || instructionCurrentID_1_isCatagory[10]) && (instructionCurrent_scheduler_1[ 7:4]==4'hF))) doInstructionsConflict0=1;
	if (instructionCurrentID_0_isCatagory[6] && ((instructionCurrentID_1_isCatagory[11]                                         ) && (instructionCurrent_scheduler_1[11:8]==4'hF))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[6] && ((instructionCurrentID_0_isCatagory[ 7] || instructionCurrentID_0_isCatagory[ 8]) && (instructionCurrent_scheduler_0[ 3:0]==4'hF))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[6] && ((instructionCurrentID_0_isCatagory[ 9] || instructionCurrentID_0_isCatagory[10]) && (instructionCurrent_scheduler_0[ 7:4]==4'hF))) doInstructionsConflict0=1;
	if (instructionCurrentID_1_isCatagory[6] && ((instructionCurrentID_0_isCatagory[11]                                         ) && (instructionCurrent_scheduler_0[11:8]==4'hF))) doInstructionsConflict0=1;
	
	if (instructionCurrentID_0_isCatagory[6] && instructionCurrentID_1_isCatagory[6]) doInstructionsConflict0=1;
	
	if ((instructionCurrentID_0_isCatagory[ 8] || instructionCurrentID_1_isCatagory[ 8]) && (instructionCurrentID_0_isCatagory[ 7] || instructionCurrentID_0_isCatagory[ 8]) && (instructionCurrentID_1_isCatagory[ 7] || instructionCurrentID_1_isCatagory[ 8]) && (instructionCurrent_scheduler_0[3:0]==instructionCurrent_scheduler_1[3:0])) doInstructionsConflict0=1;
	if ((instructionCurrentID_0_isCatagory[ 8] || instructionCurrentID_1_isCatagory[10]) && (instructionCurrentID_0_isCatagory[ 7] || instructionCurrentID_0_isCatagory[ 8]) && (instructionCurrentID_1_isCatagory[ 9] || instructionCurrentID_1_isCatagory[10]) && (instructionCurrent_scheduler_0[3:0]==instructionCurrent_scheduler_1[7:4])) doInstructionsConflict0=1;
	if ((instructionCurrentID_0_isCatagory[10] || instructionCurrentID_1_isCatagory[ 8]) && (instructionCurrentID_0_isCatagory[ 9] || instructionCurrentID_0_isCatagory[10]) && (instructionCurrentID_1_isCatagory[ 7] || instructionCurrentID_1_isCatagory[ 8]) && (instructionCurrent_scheduler_0[7:4]==instructionCurrent_scheduler_1[3:0])) doInstructionsConflict0=1;
	if ((instructionCurrentID_0_isCatagory[10] || instructionCurrentID_1_isCatagory[10]) && (instructionCurrentID_0_isCatagory[ 9] || instructionCurrentID_0_isCatagory[10]) && (instructionCurrentID_1_isCatagory[ 9] || instructionCurrentID_1_isCatagory[10]) && (instructionCurrent_scheduler_0[7:4]==instructionCurrent_scheduler_1[7:4])) doInstructionsConflict0=1;
	
	if ((instructionCurrentID_0_isCatagory[ 8]) && (instructionCurrentID_1_isCatagory[11]) && (instructionCurrent_scheduler_0[3:0]==instructionCurrent_scheduler_1[11:8])) doInstructionsConflict0=1;
	if ((instructionCurrentID_0_isCatagory[10]) && (instructionCurrentID_1_isCatagory[11]) && (instructionCurrent_scheduler_0[7:4]==instructionCurrent_scheduler_1[11:8])) doInstructionsConflict0=1;
	if ((instructionCurrentID_1_isCatagory[ 8]) && (instructionCurrentID_0_isCatagory[11]) && (instructionCurrent_scheduler_1[3:0]==instructionCurrent_scheduler_0[11:8])) doInstructionsConflict0=1;
	if ((instructionCurrentID_1_isCatagory[10]) && (instructionCurrentID_0_isCatagory[11]) && (instructionCurrent_scheduler_1[7:4]==instructionCurrent_scheduler_0[11:8])) doInstructionsConflict0=1;
end

always_comb begin
	doInstructionsConflict1=0;
end

always_comb begin
	doInstructionsConflict2=0;
	
	if (instructionCurrentID_0_isCatagory[12] && instructionCurrentID_1_isCatagory[13]) doInstructionsConflict2=1;
	if (instructionCurrentID_0_isCatagory[13] && instructionCurrentID_1_isCatagory[12]) doInstructionsConflict2=1;
	if (instructionCurrentID_0_isCatagory[13] && instructionCurrentID_1_isCatagory[13]) doInstructionsConflict2=1;
end

endmodule


module quad_instruction_conflict_detection(
	output [7:0] orderConflictsGeneratedValid [3:0],
	output [7:0] executionConflicts0GeneratedValid [3:0],
	output [7:0] executionConflicts1GeneratedValid [3:0],
	output [7:0] executionConflicts2GeneratedValid [3:0],

	input [1:0] new_instruction_index [3:0],
	input isInstructionValid_scheduler [3:0],
	input is_new_instruction_entering_this_cycle_pulse [3:0],
	input is_instruction_finishing_this_cycle_pulse [3:0],
	input [15:0] new_instruction_table [3:0],
	input [ 4:0] new_instructionID_table [3:0],
	input [15:0] instructionCurrent_scheduler_0_saved,
	input [15:0] instructionCurrent_scheduler_1_saved,
	input [15:0] instructionCurrent_scheduler_2_saved,
	input [15:0] instructionCurrent_scheduler_3_saved,
	input main_clk
);

wire isInstructionValid_scheduler_0=isInstructionValid_scheduler[0];
wire isInstructionValid_scheduler_1=isInstructionValid_scheduler[1];
wire isInstructionValid_scheduler_2=isInstructionValid_scheduler[2];
wire isInstructionValid_scheduler_3=isInstructionValid_scheduler[3];

wire is_new_instruction_entering_this_cycle_pulse_0=is_new_instruction_entering_this_cycle_pulse[0];
wire is_new_instruction_entering_this_cycle_pulse_1=is_new_instruction_entering_this_cycle_pulse[1];
wire is_new_instruction_entering_this_cycle_pulse_2=is_new_instruction_entering_this_cycle_pulse[2];
wire is_new_instruction_entering_this_cycle_pulse_3=is_new_instruction_entering_this_cycle_pulse[3];

wire is_instruction_finishing_this_cycle_pulse_0=is_instruction_finishing_this_cycle_pulse[0];
wire is_instruction_finishing_this_cycle_pulse_1=is_instruction_finishing_this_cycle_pulse[1];
wire is_instruction_finishing_this_cycle_pulse_2=is_instruction_finishing_this_cycle_pulse[2];
wire is_instruction_finishing_this_cycle_pulse_3=is_instruction_finishing_this_cycle_pulse[3];

wire [1:0] new_instruction_index0=new_instruction_index[0];
wire [1:0] new_instruction_index1=new_instruction_index[1];
wire [1:0] new_instruction_index2=new_instruction_index[2];
wire [1:0] new_instruction_index3=new_instruction_index[3];


reg [13:0] instructionCurrentIDisCatagoryNext [3:0];
reg [13:0] instructionCurrentIDisCatagory [3:0]='{0,0,0,0};
wire [13:0] instructionFutureIDisCatagory [3:0];

always @(posedge main_clk) instructionCurrentIDisCatagory<=instructionCurrentIDisCatagoryNext;

always_comb begin
	instructionCurrentIDisCatagoryNext[0]=is_new_instruction_entering_this_cycle_pulse_0?instructionFutureIDisCatagory[new_instruction_index0]:({14{!is_instruction_finishing_this_cycle_pulse_0}} & instructionCurrentIDisCatagory[0]);
	instructionCurrentIDisCatagoryNext[1]=is_new_instruction_entering_this_cycle_pulse_1?instructionFutureIDisCatagory[new_instruction_index1]:({14{!is_instruction_finishing_this_cycle_pulse_1}} & instructionCurrentIDisCatagory[1]);
	instructionCurrentIDisCatagoryNext[2]=is_new_instruction_entering_this_cycle_pulse_2?instructionFutureIDisCatagory[new_instruction_index2]:({14{!is_instruction_finishing_this_cycle_pulse_2}} & instructionCurrentIDisCatagory[2]);
	instructionCurrentIDisCatagoryNext[3]=is_new_instruction_entering_this_cycle_pulse_3?instructionFutureIDisCatagory[new_instruction_index3]:({14{!is_instruction_finishing_this_cycle_pulse_3}} & instructionCurrentIDisCatagory[3]);
end

instruction_categorizer instruction_categorizer_inst0(
	instructionFutureIDisCatagory[0],
	new_instructionID_table[0]
);// assume it is valid, because if it it isn't valid then the result won't be used

instruction_categorizer instruction_categorizer_inst1(
	instructionFutureIDisCatagory[1],
	new_instructionID_table[1]
);// assume it is valid, because if it it isn't valid then the result won't be used

instruction_categorizer instruction_categorizer_inst2(
	instructionFutureIDisCatagory[2],
	new_instructionID_table[2]
);// assume it is valid, because if it it isn't valid then the result won't be used

instruction_categorizer instruction_categorizer_inst3(
	instructionFutureIDisCatagory[3],
	new_instructionID_table[3]
);// assume it is valid, because if it it isn't valid then the result won't be used



wire [7:0] executionConflictsValidityMask;
assign executionConflictsValidityMask={4'hF,isInstructionValid_scheduler_3,isInstructionValid_scheduler_2,isInstructionValid_scheduler_1,isInstructionValid_scheduler_0};

wire [7:0] executionConflicts0GeneratedMaybeValid [3:0];
wire [7:0] executionConflicts1GeneratedMaybeValid [3:0];
wire [7:0] executionConflicts2GeneratedMaybeValid [3:0];

assign orderConflictsGeneratedValid[0][3:0]=executionConflictsValidityMask[3:0];
assign orderConflictsGeneratedValid[1][4:0]=executionConflictsValidityMask[4:0];
assign orderConflictsGeneratedValid[2][5:0]=executionConflictsValidityMask[5:0];
assign orderConflictsGeneratedValid[3][6:0]=executionConflictsValidityMask[6:0];
assign orderConflictsGeneratedValid[0][7:4]=0;
assign orderConflictsGeneratedValid[1][7:5]=0;
assign orderConflictsGeneratedValid[2][7:6]=0;
assign orderConflictsGeneratedValid[3][7  ]=0;

assign executionConflicts0GeneratedValid[0]=executionConflictsValidityMask & executionConflicts0GeneratedMaybeValid[0];
assign executionConflicts0GeneratedValid[1]=executionConflictsValidityMask & executionConflicts0GeneratedMaybeValid[1];
assign executionConflicts0GeneratedValid[2]=executionConflictsValidityMask & executionConflicts0GeneratedMaybeValid[2];
assign executionConflicts0GeneratedValid[3]=executionConflictsValidityMask & executionConflicts0GeneratedMaybeValid[3];
assign executionConflicts0GeneratedMaybeValid[0][7:4]=0;
assign executionConflicts0GeneratedMaybeValid[1][7:5]=0;
assign executionConflicts0GeneratedMaybeValid[2][7:6]=0;
assign executionConflicts0GeneratedMaybeValid[3][7  ]=0;

assign executionConflicts1GeneratedValid[0]=executionConflictsValidityMask & executionConflicts1GeneratedMaybeValid[0];
assign executionConflicts1GeneratedValid[1]=executionConflictsValidityMask & executionConflicts1GeneratedMaybeValid[1];
assign executionConflicts1GeneratedValid[2]=executionConflictsValidityMask & executionConflicts1GeneratedMaybeValid[2];
assign executionConflicts1GeneratedValid[3]=executionConflictsValidityMask & executionConflicts1GeneratedMaybeValid[3];
assign executionConflicts1GeneratedMaybeValid[0][7:4]=0;
assign executionConflicts1GeneratedMaybeValid[1][7:5]=0;
assign executionConflicts1GeneratedMaybeValid[2][7:6]=0;
assign executionConflicts1GeneratedMaybeValid[3][7  ]=0;

assign executionConflicts2GeneratedValid[0]=executionConflictsValidityMask & executionConflicts2GeneratedMaybeValid[0];
assign executionConflicts2GeneratedValid[1]=executionConflictsValidityMask & executionConflicts2GeneratedMaybeValid[1];
assign executionConflicts2GeneratedValid[2]=executionConflictsValidityMask & executionConflicts2GeneratedMaybeValid[2];
assign executionConflicts2GeneratedValid[3]=executionConflictsValidityMask & executionConflicts2GeneratedMaybeValid[3];
assign executionConflicts2GeneratedMaybeValid[0][7:4]=0;
assign executionConflicts2GeneratedMaybeValid[1][7:5]=0;
assign executionConflicts2GeneratedMaybeValid[2][7:6]=0;
assign executionConflicts2GeneratedMaybeValid[3][7  ]=0;


instruction_conflict_detector instruction_conflict_detector_inst00(
	executionConflicts0GeneratedMaybeValid[0][0],
	executionConflicts1GeneratedMaybeValid[0][0],
	executionConflicts2GeneratedMaybeValid[0][0],
	instructionCurrentIDisCatagory[0],
	instructionFutureIDisCatagory[0],
	instructionCurrent_scheduler_0_saved,
	new_instruction_table[0]
);
instruction_conflict_detector instruction_conflict_detector_inst01(
	executionConflicts0GeneratedMaybeValid[0][1],
	executionConflicts1GeneratedMaybeValid[0][1],
	executionConflicts2GeneratedMaybeValid[0][1],
	instructionCurrentIDisCatagory[1],
	instructionFutureIDisCatagory[0],
	instructionCurrent_scheduler_1_saved,
	new_instruction_table[0]
);
instruction_conflict_detector instruction_conflict_detector_inst02(
	executionConflicts0GeneratedMaybeValid[0][2],
	executionConflicts1GeneratedMaybeValid[0][2],
	executionConflicts2GeneratedMaybeValid[0][2],
	instructionCurrentIDisCatagory[2],
	instructionFutureIDisCatagory[0],
	instructionCurrent_scheduler_2_saved,
	new_instruction_table[0]
);
instruction_conflict_detector instruction_conflict_detector_inst03(
	executionConflicts0GeneratedMaybeValid[0][3],
	executionConflicts1GeneratedMaybeValid[0][3],
	executionConflicts2GeneratedMaybeValid[0][3],
	instructionCurrentIDisCatagory[3],
	instructionFutureIDisCatagory[0],
	instructionCurrent_scheduler_3_saved,
	new_instruction_table[0]
);
///
instruction_conflict_detector instruction_conflict_detector_inst10(
	executionConflicts0GeneratedMaybeValid[1][0],
	executionConflicts1GeneratedMaybeValid[1][0],
	executionConflicts2GeneratedMaybeValid[1][0],
	instructionCurrentIDisCatagory[0],
	instructionFutureIDisCatagory[1],
	instructionCurrent_scheduler_0_saved,
	new_instruction_table[1]
);
instruction_conflict_detector instruction_conflict_detector_inst11(
	executionConflicts0GeneratedMaybeValid[1][1],
	executionConflicts1GeneratedMaybeValid[1][1],
	executionConflicts2GeneratedMaybeValid[1][1],
	instructionCurrentIDisCatagory[1],
	instructionFutureIDisCatagory[1],
	instructionCurrent_scheduler_1_saved,
	new_instruction_table[1]
);
instruction_conflict_detector instruction_conflict_detector_inst12(
	executionConflicts0GeneratedMaybeValid[1][2],
	executionConflicts1GeneratedMaybeValid[1][2],
	executionConflicts2GeneratedMaybeValid[1][2],
	instructionCurrentIDisCatagory[2],
	instructionFutureIDisCatagory[1],
	instructionCurrent_scheduler_2_saved,
	new_instruction_table[1]
);
instruction_conflict_detector instruction_conflict_detector_inst13(
	executionConflicts0GeneratedMaybeValid[1][3],
	executionConflicts1GeneratedMaybeValid[1][3],
	executionConflicts2GeneratedMaybeValid[1][3],
	instructionCurrentIDisCatagory[3],
	instructionFutureIDisCatagory[1],
	instructionCurrent_scheduler_3_saved,
	new_instruction_table[1]
);
instruction_conflict_detector instruction_conflict_detector_inst14(
	executionConflicts0GeneratedMaybeValid[1][4],
	executionConflicts1GeneratedMaybeValid[1][4],
	executionConflicts2GeneratedMaybeValid[1][4],
	instructionFutureIDisCatagory[0],
	instructionFutureIDisCatagory[1],
	new_instruction_table[0],
	new_instruction_table[1]
);
///
instruction_conflict_detector instruction_conflict_detector_inst20(
	executionConflicts0GeneratedMaybeValid[2][0],
	executionConflicts1GeneratedMaybeValid[2][0],
	executionConflicts2GeneratedMaybeValid[2][0],
	instructionCurrentIDisCatagory[0],
	instructionFutureIDisCatagory[2],
	instructionCurrent_scheduler_0_saved,
	new_instruction_table[2]
);
instruction_conflict_detector instruction_conflict_detector_inst21(
	executionConflicts0GeneratedMaybeValid[2][1],
	executionConflicts1GeneratedMaybeValid[2][1],
	executionConflicts2GeneratedMaybeValid[2][1],
	instructionCurrentIDisCatagory[1],
	instructionFutureIDisCatagory[2],
	instructionCurrent_scheduler_1_saved,
	new_instruction_table[2]
);
instruction_conflict_detector instruction_conflict_detector_inst22(
	executionConflicts0GeneratedMaybeValid[2][2],
	executionConflicts1GeneratedMaybeValid[2][2],
	executionConflicts2GeneratedMaybeValid[2][2],
	instructionCurrentIDisCatagory[2],
	instructionFutureIDisCatagory[2],
	instructionCurrent_scheduler_2_saved,
	new_instruction_table[2]
);
instruction_conflict_detector instruction_conflict_detector_inst23(
	executionConflicts0GeneratedMaybeValid[2][3],
	executionConflicts1GeneratedMaybeValid[2][3],
	executionConflicts2GeneratedMaybeValid[2][3],
	instructionCurrentIDisCatagory[3],
	instructionFutureIDisCatagory[2],
	instructionCurrent_scheduler_3_saved,
	new_instruction_table[2]
);
instruction_conflict_detector instruction_conflict_detector_inst24(
	executionConflicts0GeneratedMaybeValid[2][4],
	executionConflicts1GeneratedMaybeValid[2][4],
	executionConflicts2GeneratedMaybeValid[2][4],
	instructionFutureIDisCatagory[0],
	instructionFutureIDisCatagory[2],
	new_instruction_table[0],
	new_instruction_table[2]
);
instruction_conflict_detector instruction_conflict_detector_inst25(
	executionConflicts0GeneratedMaybeValid[2][5],
	executionConflicts1GeneratedMaybeValid[2][5],
	executionConflicts2GeneratedMaybeValid[2][5],
	instructionFutureIDisCatagory[1],
	instructionFutureIDisCatagory[2],
	new_instruction_table[1],
	new_instruction_table[2]
);
///
instruction_conflict_detector instruction_conflict_detector_inst30(
	executionConflicts0GeneratedMaybeValid[3][0],
	executionConflicts1GeneratedMaybeValid[3][0],
	executionConflicts2GeneratedMaybeValid[3][0],
	instructionCurrentIDisCatagory[0],
	instructionFutureIDisCatagory[3],
	instructionCurrent_scheduler_0_saved,
	new_instruction_table[3]
);
instruction_conflict_detector instruction_conflict_detector_inst31(
	executionConflicts0GeneratedMaybeValid[3][1],
	executionConflicts1GeneratedMaybeValid[3][1],
	executionConflicts2GeneratedMaybeValid[3][1],
	instructionCurrentIDisCatagory[1],
	instructionFutureIDisCatagory[3],
	instructionCurrent_scheduler_1_saved,
	new_instruction_table[3]
);
instruction_conflict_detector instruction_conflict_detector_inst32(
	executionConflicts0GeneratedMaybeValid[3][2],
	executionConflicts1GeneratedMaybeValid[3][2],
	executionConflicts2GeneratedMaybeValid[3][2],
	instructionCurrentIDisCatagory[2],
	instructionFutureIDisCatagory[3],
	instructionCurrent_scheduler_2_saved,
	new_instruction_table[3]
);
instruction_conflict_detector instruction_conflict_detector_inst33( // instruction_conflict_detector_inst33 is effectivly not used because of how future instructions are inserted into the current instruction slots.
	executionConflicts0GeneratedMaybeValid[3][3],
	executionConflicts1GeneratedMaybeValid[3][3],
	executionConflicts2GeneratedMaybeValid[3][3],
	instructionCurrentIDisCatagory[3],
	instructionFutureIDisCatagory[3],
	instructionCurrent_scheduler_3_saved,
	new_instruction_table[3]
);
instruction_conflict_detector instruction_conflict_detector_inst34(
	executionConflicts0GeneratedMaybeValid[3][4],
	executionConflicts1GeneratedMaybeValid[3][4],
	executionConflicts2GeneratedMaybeValid[3][4],
	instructionFutureIDisCatagory[0],
	instructionFutureIDisCatagory[3],
	new_instruction_table[0],
	new_instruction_table[3]
);
instruction_conflict_detector instruction_conflict_detector_inst35(
	executionConflicts0GeneratedMaybeValid[3][5],
	executionConflicts1GeneratedMaybeValid[3][5],
	executionConflicts2GeneratedMaybeValid[3][5],
	instructionFutureIDisCatagory[1],
	instructionFutureIDisCatagory[3],
	new_instruction_table[1],
	new_instruction_table[3]
);
instruction_conflict_detector instruction_conflict_detector_inst36(
	executionConflicts0GeneratedMaybeValid[3][6],
	executionConflicts1GeneratedMaybeValid[3][6],
	executionConflicts2GeneratedMaybeValid[3][6],
	instructionFutureIDisCatagory[2],
	instructionFutureIDisCatagory[3],
	new_instruction_table[2],
	new_instruction_table[3]
);

endmodule

