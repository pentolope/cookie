`timescale 1 ps / 1 ps

`include "instruction_conflict_detection.sv"

module scheduler(
	output executerEnable_e [3:0],
	output executerWillBeEnabled_e [3:0],
	output [15:0] instructionCurrent_scheduler [3:0],
	output [ 4:0] instructionCurrentID_scheduler [3:0],
	output [25:0] current_instruction_address_table_e [3:0],
	output [ 4:0] fifo_instruction_cache_size_after_read_e,
	output [ 2:0] fifo_instruction_cache_consume_count_e,
	
	input  is_performing_jump_instant_on,
	input  is_performing_jump_state,
	input  [ 1:0] jump_executer_index,
	input  [ 4:0] fifo_instruction_cache_size,
	input  [15:0] new_instruction_table [3:0],
	input  [ 4:0] new_instructionID_table [3:0],
	input  [25:0] new_instruction_address_table [3:0],
	input  [ 3:0] memory_dependency_clear,
	input  is_instruction_finishing_this_cycle_pulse [3:0],
	input  will_instruction_finish_next_cycle_pulse [3:0],
	input  debug_scheduler,
	input  main_clk
);

reg [3:0] orderConflictsAdapted [3:0];

reg [3:0] orderConflictsSaved [3:0]='{0,0,0,0};
reg [3:0] orderConflictsNext [3:0];
wire [3:0] orderConflictsNextTrue [3:0];
reg [7:0] orderConflictsAbove [3:0];

reg [3:0] executionConflicts0Saved [3:0]='{0,0,0,0};
reg [3:0] executionConflicts0Next [3:0];
wire [3:0] executionConflicts0NextTrue [3:0];
reg [7:0] executionConflicts0Above [3:0];

reg [3:0] executionConflicts1Saved [3:0]='{0,0,0,0};
reg [3:0] executionConflicts1Next [3:0];
wire [3:0] executionConflicts1NextTrue [3:0];
reg [7:0] executionConflicts1Above [3:0];

reg [3:0] executionConflicts2Saved [3:0]='{0,0,0,0};
reg [3:0] executionConflicts2Next [3:0];
wire [3:0] executionConflicts2NextTrue [3:0];
reg [7:0] executionConflicts2Above [3:0];

`include "AutoGen3.sv"

reg is_new_instruction_entering_this_cycle_pulse_0; // only valid if `is_performing_jump_instant_on==0`
reg is_new_instruction_entering_this_cycle_pulse_1; // only valid if `is_performing_jump_instant_on==0`
reg is_new_instruction_entering_this_cycle_pulse_2; // only valid if `is_performing_jump_instant_on==0`
reg is_new_instruction_entering_this_cycle_pulse_3; // only valid if `is_performing_jump_instant_on==0`

reg [15:0] instructionCurrent_scheduler_0_saved=0;
reg [15:0] instructionCurrent_scheduler_1_saved=0;
reg [15:0] instructionCurrent_scheduler_2_saved=0;
reg [15:0] instructionCurrent_scheduler_3_saved=0;

reg [15:0] instructionCurrent_scheduler_0;
reg [15:0] instructionCurrent_scheduler_1;
reg [15:0] instructionCurrent_scheduler_2;
reg [15:0] instructionCurrent_scheduler_3;

assign instructionCurrent_scheduler[0]=instructionCurrent_scheduler_0;
assign instructionCurrent_scheduler[1]=instructionCurrent_scheduler_1;
assign instructionCurrent_scheduler[2]=instructionCurrent_scheduler_2;
assign instructionCurrent_scheduler[3]=instructionCurrent_scheduler_3;


reg [4:0] fifo_instruction_cache_size_after_read;
reg [2:0] fifo_instruction_cache_consume_count;
reg [2:0] fifo_instruction_cache_size_converted;

assign fifo_instruction_cache_size_after_read_e=fifo_instruction_cache_size_after_read;
assign fifo_instruction_cache_consume_count_e=fifo_instruction_cache_consume_count;

reg executerEnable [3:0]='{0,0,0,0};
reg executerWillBeEnabled [3:0];

assign executerEnable_e=executerEnable;
assign executerWillBeEnabled_e=executerWillBeEnabled;

always @(posedge main_clk) executerEnable<=executerWillBeEnabled;

reg isInstructionValid_scheduler_0=0;
reg isInstructionValid_scheduler_0_future2=0;
reg isInstructionValid_scheduler_0_future3;
reg isInstructionValid_scheduler_0_future4;

reg isInstructionValid_scheduler_1=0;
reg isInstructionValid_scheduler_1_future2=0;
reg isInstructionValid_scheduler_1_future3;
reg isInstructionValid_scheduler_1_future4;

reg isInstructionValid_scheduler_2=0;
reg isInstructionValid_scheduler_2_future2=0;
reg isInstructionValid_scheduler_2_future3;
reg isInstructionValid_scheduler_2_future4;

reg isInstructionValid_scheduler_3=0;
reg isInstructionValid_scheduler_3_future2=0;
reg isInstructionValid_scheduler_3_future3;
reg isInstructionValid_scheduler_3_future4;

always @(posedge main_clk) begin
	isInstructionValid_scheduler_0<=isInstructionValid_scheduler_0_future4;
	isInstructionValid_scheduler_1<=isInstructionValid_scheduler_1_future4;
	isInstructionValid_scheduler_2<=isInstructionValid_scheduler_2_future4;
	isInstructionValid_scheduler_3<=isInstructionValid_scheduler_3_future4;
	
	instructionCurrent_scheduler_0_saved<=instructionCurrent_scheduler_0;
	instructionCurrent_scheduler_1_saved<=instructionCurrent_scheduler_1;
	instructionCurrent_scheduler_2_saved<=instructionCurrent_scheduler_2;
	instructionCurrent_scheduler_3_saved<=instructionCurrent_scheduler_3;
	
	isInstructionValid_scheduler_0_future2<=will_instruction_finish_next_cycle_pulse[0]?1'b0:isInstructionValid_scheduler_0_future4;
	isInstructionValid_scheduler_1_future2<=will_instruction_finish_next_cycle_pulse[1]?1'b0:isInstructionValid_scheduler_1_future4;
	isInstructionValid_scheduler_2_future2<=will_instruction_finish_next_cycle_pulse[2]?1'b0:isInstructionValid_scheduler_2_future4;
	isInstructionValid_scheduler_3_future2<=will_instruction_finish_next_cycle_pulse[3]?1'b0:isInstructionValid_scheduler_3_future4;
	
	assert (isInstructionValid_scheduler_0_future2 == (is_instruction_finishing_this_cycle_pulse[0]?1'b0:isInstructionValid_scheduler_0));
	assert (isInstructionValid_scheduler_1_future2 == (is_instruction_finishing_this_cycle_pulse[1]?1'b0:isInstructionValid_scheduler_1));
	assert (isInstructionValid_scheduler_2_future2 == (is_instruction_finishing_this_cycle_pulse[2]?1'b0:isInstructionValid_scheduler_2));
	assert (isInstructionValid_scheduler_3_future2 == (is_instruction_finishing_this_cycle_pulse[3]?1'b0:isInstructionValid_scheduler_3));
end

reg [25:0] current_instruction_address_table [3:0]='{0,0,0,0};
assign current_instruction_address_table_e=current_instruction_address_table;

reg [4:0] instructionCurrentID_scheduler_0;
reg [4:0] instructionCurrentID_scheduler_1;
reg [4:0] instructionCurrentID_scheduler_2;
reg [4:0] instructionCurrentID_scheduler_3;

assign instructionCurrentID_scheduler[0]=instructionCurrentID_scheduler_0;
assign instructionCurrentID_scheduler[1]=instructionCurrentID_scheduler_1;
assign instructionCurrentID_scheduler[2]=instructionCurrentID_scheduler_2;
assign instructionCurrentID_scheduler[3]=instructionCurrentID_scheduler_3;


reg [1:0] new_instruction_index0;
reg [1:0] new_instruction_index1;
reg [1:0] new_instruction_index2;
reg [1:0] new_instruction_index3;

wire [4:0] current_instructionID_table [3:0];
assign current_instructionID_table[0]=(& instructionCurrent_scheduler_0_saved[15:12])?{1'b1,instructionCurrent_scheduler_0_saved[11:8]}:{1'b0,instructionCurrent_scheduler_0_saved[15:12]};
assign current_instructionID_table[1]=(& instructionCurrent_scheduler_1_saved[15:12])?{1'b1,instructionCurrent_scheduler_1_saved[11:8]}:{1'b0,instructionCurrent_scheduler_1_saved[15:12]};
assign current_instructionID_table[2]=(& instructionCurrent_scheduler_2_saved[15:12])?{1'b1,instructionCurrent_scheduler_2_saved[11:8]}:{1'b0,instructionCurrent_scheduler_2_saved[15:12]};
assign current_instructionID_table[3]=(& instructionCurrent_scheduler_3_saved[15:12])?{1'b1,instructionCurrent_scheduler_3_saved[11:8]}:{1'b0,instructionCurrent_scheduler_3_saved[15:12]};



wire [2:0] popcnt4 [15:0];
assign popcnt4[4'b0000]=0;
assign popcnt4[4'b0001]=1;
assign popcnt4[4'b0010]=1;
assign popcnt4[4'b0011]=2;
assign popcnt4[4'b0100]=1;
assign popcnt4[4'b0101]=2;
assign popcnt4[4'b0110]=2;
assign popcnt4[4'b0111]=3;
assign popcnt4[4'b1000]=1;
assign popcnt4[4'b1001]=2;
assign popcnt4[4'b1010]=2;
assign popcnt4[4'b1011]=3;
assign popcnt4[4'b1100]=2;
assign popcnt4[4'b1101]=3;
assign popcnt4[4'b1110]=3;
assign popcnt4[4'b1111]=4;

wire [2:0] popcntConsume=popcnt4[{!isInstructionValid_scheduler_3_future2,!isInstructionValid_scheduler_2_future2,!isInstructionValid_scheduler_1_future2,!isInstructionValid_scheduler_0_future2}];

always_comb begin
	new_instruction_index0=2'hx;
	new_instruction_index1=2'hx;
	new_instruction_index2=2'hx;
	new_instruction_index3=2'hx;
	is_new_instruction_entering_this_cycle_pulse_0=0;
	is_new_instruction_entering_this_cycle_pulse_1=0;
	is_new_instruction_entering_this_cycle_pulse_2=0;
	is_new_instruction_entering_this_cycle_pulse_3=0;
	
	fifo_instruction_cache_size_converted[2]=(|(fifo_instruction_cache_size[4:2]))?1'b1:1'b0;
	fifo_instruction_cache_size_converted[1]=(fifo_instruction_cache_size[1] & !fifo_instruction_cache_size_converted[2])?1'b1:1'b0;
	fifo_instruction_cache_size_converted[0]=(fifo_instruction_cache_size[0] & !fifo_instruction_cache_size_converted[2])?1'b1:1'b0;
	
	if (fifo_instruction_cache_size > popcntConsume) begin // could also be viewed as `fifo_instruction_cache_size >= popcntConsume`
		fifo_instruction_cache_consume_count=popcntConsume;
		fifo_instruction_cache_size_after_read=fifo_instruction_cache_size-popcntConsume;
	end else begin
		fifo_instruction_cache_consume_count=fifo_instruction_cache_size[2:0];
		fifo_instruction_cache_size_after_read=0;
	end
	
`include "AutoGen1.sv"
	
	instructionCurrent_scheduler_0=is_new_instruction_entering_this_cycle_pulse_0?new_instruction_table[new_instruction_index0]:instructionCurrent_scheduler_0_saved;
	instructionCurrent_scheduler_1=is_new_instruction_entering_this_cycle_pulse_1?new_instruction_table[new_instruction_index1]:instructionCurrent_scheduler_1_saved;
	instructionCurrent_scheduler_2=is_new_instruction_entering_this_cycle_pulse_2?new_instruction_table[new_instruction_index2]:instructionCurrent_scheduler_2_saved;
	instructionCurrent_scheduler_3=is_new_instruction_entering_this_cycle_pulse_3?new_instruction_table[new_instruction_index3]:instructionCurrent_scheduler_3_saved;
	
	instructionCurrentID_scheduler_0=is_new_instruction_entering_this_cycle_pulse_0?new_instructionID_table[new_instruction_index0]:current_instructionID_table[0];
	instructionCurrentID_scheduler_1=is_new_instruction_entering_this_cycle_pulse_1?new_instructionID_table[new_instruction_index1]:current_instructionID_table[1];
	instructionCurrentID_scheduler_2=is_new_instruction_entering_this_cycle_pulse_2?new_instructionID_table[new_instruction_index2]:current_instructionID_table[2];
	instructionCurrentID_scheduler_3=is_new_instruction_entering_this_cycle_pulse_3?new_instructionID_table[new_instruction_index3]:current_instructionID_table[3];
	
	isInstructionValid_scheduler_0_future3=is_new_instruction_entering_this_cycle_pulse_0?1'b1:isInstructionValid_scheduler_0_future2;
	isInstructionValid_scheduler_1_future3=is_new_instruction_entering_this_cycle_pulse_1?1'b1:isInstructionValid_scheduler_1_future2;
	isInstructionValid_scheduler_2_future3=is_new_instruction_entering_this_cycle_pulse_2?1'b1:isInstructionValid_scheduler_2_future2;
	isInstructionValid_scheduler_3_future3=is_new_instruction_entering_this_cycle_pulse_3?1'b1:isInstructionValid_scheduler_3_future2;
end

always @(posedge main_clk) begin
	if (is_new_instruction_entering_this_cycle_pulse_0) current_instruction_address_table[0]<=new_instruction_address_table[new_instruction_index0];
	if (is_new_instruction_entering_this_cycle_pulse_1) current_instruction_address_table[1]<=new_instruction_address_table[new_instruction_index1];
	if (is_new_instruction_entering_this_cycle_pulse_2) current_instruction_address_table[2]<=new_instruction_address_table[new_instruction_index2];
	if (is_new_instruction_entering_this_cycle_pulse_3) current_instruction_address_table[3]<=new_instruction_address_table[new_instruction_index3];
end

wire [7:0] orderConflictsGeneratedValid [3:0];
wire [7:0] executionConflicts0GeneratedValid [3:0];
wire [7:0] executionConflicts1GeneratedValid [3:0];
wire [7:0] executionConflicts2GeneratedValid [3:0];

quad_instruction_conflict_detection quad_instruction_conflict_detection_inst(
	orderConflictsGeneratedValid,
	executionConflicts0GeneratedValid,
	executionConflicts1GeneratedValid,
	executionConflicts2GeneratedValid,
	
	'{
		new_instruction_index3,
		new_instruction_index2,
		new_instruction_index1,
		new_instruction_index0
	},
	'{
		isInstructionValid_scheduler_3,
		isInstructionValid_scheduler_2,
		isInstructionValid_scheduler_1,
		isInstructionValid_scheduler_0
	},
	'{
		is_new_instruction_entering_this_cycle_pulse_3,
		is_new_instruction_entering_this_cycle_pulse_2,
		is_new_instruction_entering_this_cycle_pulse_1,
		is_new_instruction_entering_this_cycle_pulse_0
	},
	'{
		is_instruction_finishing_this_cycle_pulse[3],
		is_instruction_finishing_this_cycle_pulse[2],
		is_instruction_finishing_this_cycle_pulse[1],
		is_instruction_finishing_this_cycle_pulse[0]
	},
	new_instruction_table,
	new_instructionID_table,
	instructionCurrent_scheduler_0_saved,
	instructionCurrent_scheduler_1_saved,
	instructionCurrent_scheduler_2_saved,
	instructionCurrent_scheduler_3_saved,
	main_clk
);


wire [7:0] instructionNotFininshingMask;
assign instructionNotFininshingMask={4'hF,!is_instruction_finishing_this_cycle_pulse[3],!is_instruction_finishing_this_cycle_pulse[2],!is_instruction_finishing_this_cycle_pulse[1],!is_instruction_finishing_this_cycle_pulse[0]};

wire [7:0] memDependNotClearedMask;
assign memDependNotClearedMask={4'hF,!memory_dependency_clear[3],!memory_dependency_clear[2],!memory_dependency_clear[1],!memory_dependency_clear[0]};

always_comb begin
	orderConflictsNext[0]=instructionNotFininshingMask[3:0] & orderConflictsSaved[0];
	orderConflictsNext[1]=instructionNotFininshingMask[3:0] & orderConflictsSaved[1];
	orderConflictsNext[2]=instructionNotFininshingMask[3:0] & orderConflictsSaved[2];
	orderConflictsNext[3]=instructionNotFininshingMask[3:0] & orderConflictsSaved[3];
	
	executionConflicts0Next[0]=instructionNotFininshingMask[3:0] & executionConflicts0Saved[0];
	executionConflicts0Next[1]=instructionNotFininshingMask[3:0] & executionConflicts0Saved[1];
	executionConflicts0Next[2]=instructionNotFininshingMask[3:0] & executionConflicts0Saved[2];
	executionConflicts0Next[3]=instructionNotFininshingMask[3:0] & executionConflicts0Saved[3];

	executionConflicts1Next[0]=instructionNotFininshingMask[3:0] & executionConflicts1Saved[0];
	executionConflicts1Next[1]=instructionNotFininshingMask[3:0] & executionConflicts1Saved[1];
	executionConflicts1Next[2]=instructionNotFininshingMask[3:0] & executionConflicts1Saved[2];
	executionConflicts1Next[3]=instructionNotFininshingMask[3:0] & executionConflicts1Saved[3];

	executionConflicts2Next[0]=instructionNotFininshingMask[3:0] & executionConflicts2Saved[0];
	executionConflicts2Next[1]=instructionNotFininshingMask[3:0] & executionConflicts2Saved[1];
	executionConflicts2Next[2]=instructionNotFininshingMask[3:0] & executionConflicts2Saved[2];
	executionConflicts2Next[3]=instructionNotFininshingMask[3:0] & executionConflicts2Saved[3];
	
	orderConflictsAbove[0]=instructionNotFininshingMask & orderConflictsGeneratedValid[0];
	orderConflictsAbove[1]=instructionNotFininshingMask & orderConflictsGeneratedValid[1];
	orderConflictsAbove[2]=instructionNotFininshingMask & orderConflictsGeneratedValid[2];
	orderConflictsAbove[3]=instructionNotFininshingMask & orderConflictsGeneratedValid[3];

	executionConflicts0Above[0]=instructionNotFininshingMask & executionConflicts0GeneratedValid[0];
	executionConflicts0Above[1]=instructionNotFininshingMask & executionConflicts0GeneratedValid[1];
	executionConflicts0Above[2]=instructionNotFininshingMask & executionConflicts0GeneratedValid[2];
	executionConflicts0Above[3]=instructionNotFininshingMask & executionConflicts0GeneratedValid[3];

	executionConflicts1Above[0]=instructionNotFininshingMask & executionConflicts1GeneratedValid[0];
	executionConflicts1Above[1]=instructionNotFininshingMask & executionConflicts1GeneratedValid[1];
	executionConflicts1Above[2]=instructionNotFininshingMask & executionConflicts1GeneratedValid[2];
	executionConflicts1Above[3]=instructionNotFininshingMask & executionConflicts1GeneratedValid[3];

	executionConflicts2Above[0]=memDependNotClearedMask & executionConflicts2GeneratedValid[0];
	executionConflicts2Above[1]=memDependNotClearedMask & executionConflicts2GeneratedValid[1];
	executionConflicts2Above[2]=memDependNotClearedMask & executionConflicts2GeneratedValid[2];
	executionConflicts2Above[3]=memDependNotClearedMask & executionConflicts2GeneratedValid[3];
end

always_comb begin
	orderConflictsAdapted=orderConflictsSaved;
	orderConflictsAdapted[0][0]=1'b1;
	orderConflictsAdapted[1][1]=1'b1;
	orderConflictsAdapted[2][2]=1'b1;
	orderConflictsAdapted[3][3]=1'b1;
end

always_comb begin
	isInstructionValid_scheduler_0_future4=((is_performing_jump_instant_on && (is_new_instruction_entering_this_cycle_pulse_0 || orderConflictsAdapted[0][jump_executer_index])) || (is_performing_jump_state && is_new_instruction_entering_this_cycle_pulse_0))?1'b0:isInstructionValid_scheduler_0_future3;
	isInstructionValid_scheduler_1_future4=((is_performing_jump_instant_on && (is_new_instruction_entering_this_cycle_pulse_1 || orderConflictsAdapted[1][jump_executer_index])) || (is_performing_jump_state && is_new_instruction_entering_this_cycle_pulse_1))?1'b0:isInstructionValid_scheduler_1_future3;
	isInstructionValid_scheduler_2_future4=((is_performing_jump_instant_on && (is_new_instruction_entering_this_cycle_pulse_2 || orderConflictsAdapted[2][jump_executer_index])) || (is_performing_jump_state && is_new_instruction_entering_this_cycle_pulse_2))?1'b0:isInstructionValid_scheduler_2_future3;
	isInstructionValid_scheduler_3_future4=((is_performing_jump_instant_on && (is_new_instruction_entering_this_cycle_pulse_3 || orderConflictsAdapted[3][jump_executer_index])) || (is_performing_jump_state && is_new_instruction_entering_this_cycle_pulse_3))?1'b0:isInstructionValid_scheduler_3_future3;
end

always @(posedge main_clk) begin
	orderConflictsSaved<=orderConflictsNextTrue;

	executionConflicts0Saved<=executionConflicts0NextTrue;
	executionConflicts1Saved<=executionConflicts1NextTrue;
	executionConflicts2Saved<=executionConflicts2NextTrue;
end

always_comb begin
	if (debug_scheduler) begin
		executerWillBeEnabled[0]=(isInstructionValid_scheduler_0_future4 && executionConflicts0NextTrue[0]==4'h0 && executionConflicts1NextTrue[0]==4'h0 && executionConflicts2NextTrue[0]==4'h0 && orderConflictsNextTrue[0]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[1]=(isInstructionValid_scheduler_1_future4 && executionConflicts0NextTrue[1]==4'h0 && executionConflicts1NextTrue[1]==4'h0 && executionConflicts2NextTrue[1]==4'h0 && orderConflictsNextTrue[1]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[2]=(isInstructionValid_scheduler_2_future4 && executionConflicts0NextTrue[2]==4'h0 && executionConflicts1NextTrue[2]==4'h0 && executionConflicts2NextTrue[2]==4'h0 && orderConflictsNextTrue[2]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[3]=(isInstructionValid_scheduler_3_future4 && executionConflicts0NextTrue[3]==4'h0 && executionConflicts1NextTrue[3]==4'h0 && executionConflicts2NextTrue[3]==4'h0 && orderConflictsNextTrue[3]==4'h0)?1'b1:1'b0;
	end else begin
		executerWillBeEnabled[0]=(isInstructionValid_scheduler_0_future4 && executionConflicts0NextTrue[0]==4'h0 && executionConflicts1NextTrue[0]==4'h0 && executionConflicts2NextTrue[0]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[1]=(isInstructionValid_scheduler_1_future4 && executionConflicts0NextTrue[1]==4'h0 && executionConflicts1NextTrue[1]==4'h0 && executionConflicts2NextTrue[1]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[2]=(isInstructionValid_scheduler_2_future4 && executionConflicts0NextTrue[2]==4'h0 && executionConflicts1NextTrue[2]==4'h0 && executionConflicts2NextTrue[2]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[3]=(isInstructionValid_scheduler_3_future4 && executionConflicts0NextTrue[3]==4'h0 && executionConflicts1NextTrue[3]==4'h0 && executionConflicts2NextTrue[3]==4'h0)?1'b1:1'b0;
	end
end



reg [15:0] executingInstructionsSimView [3:0];
reg [15:0] allInstructionsSimView [3:0];

always_comb begin
	if (executerEnable[0]) executingInstructionsSimView[0]=instructionCurrent_scheduler_0_saved;
	else executingInstructionsSimView[0]=16'hx;
	if (executerEnable[1]) executingInstructionsSimView[1]=instructionCurrent_scheduler_1_saved;
	else executingInstructionsSimView[1]=16'hx;
	if (executerEnable[2]) executingInstructionsSimView[2]=instructionCurrent_scheduler_2_saved;
	else executingInstructionsSimView[2]=16'hx;
	if (executerEnable[3]) executingInstructionsSimView[3]=instructionCurrent_scheduler_3_saved;
	else executingInstructionsSimView[3]=16'hx;
	
	allInstructionsSimView[0]=instructionCurrent_scheduler_0_saved;
	allInstructionsSimView[1]=instructionCurrent_scheduler_1_saved;
	allInstructionsSimView[2]=instructionCurrent_scheduler_2_saved;
	allInstructionsSimView[3]=instructionCurrent_scheduler_3_saved;
end



endmodule