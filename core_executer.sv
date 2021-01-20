`timescale 1 ps / 1 ps


module fast_ur_mux(
	output [15:0] o, // output value
	input  [ 3:0] i, // value from instruction
	input  [15:0] u [15:0] // instant user reg
);
wire [7:0] d;
lcell_1 is0(d[ 0],!i[3] & !i[2] & !i[1]);
lcell_1 is1(d[ 1],!i[3] & !i[2] &  i[1]);
lcell_1 is2(d[ 2],!i[3] &  i[2] & !i[1]);
lcell_1 is3(d[ 3],!i[3] &  i[2] &  i[1]);
lcell_1 is4(d[ 4], i[3] & !i[2] & !i[1]);
lcell_1 is5(d[ 5], i[3] & !i[2] &  i[1]);
lcell_1 is6(d[ 6], i[3] &  i[2] & !i[1]);
lcell_1 is7(d[ 7], i[3] &  i[2] &  i[1]);

wire [15:0] ov0 [7:0];
wire [15:0] ov1 [4:0];

lcell_16 lc_uc0(ov0[0],i[0]?u[ 1]:u[ 0]);
lcell_16 lc_uc1(ov0[1],i[0]?u[ 3]:u[ 2]);
lcell_16 lc_uc2(ov0[2],i[0]?u[ 5]:u[ 4]);
lcell_16 lc_uc3(ov0[3],i[0]?u[ 7]:u[ 6]);
lcell_16 lc_uc4(ov0[4],i[0]?u[ 9]:u[ 8]);
lcell_16 lc_uc5(ov0[5],i[0]?u[11]:u[10]);
lcell_16 lc_uc6(ov0[6],i[0]?u[13]:u[12]);
lcell_16 lc_uc7(ov0[7],i[0]?u[15]:u[14]);

fast_ur_mux_slice fast_ur_mux_slice3 (
	ov1[3],
	{d[ 7],d[ 6]},
	'{ov0[ 7],ov0[ 6]}
);
fast_ur_mux_slice fast_ur_mux_slice2 (
	ov1[2],
	{d[ 5],d[ 4]},
	'{ov0[ 5],ov0[ 4]}
);
fast_ur_mux_slice fast_ur_mux_slice1 (
	ov1[1],
	{d[ 3],d[ 2]},
	'{ov0[ 3],ov0[ 2]}
);
fast_ur_mux_slice fast_ur_mux_slice0 (
	ov1[0],
	{d[ 1],d[ 0]},
	'{ov0[ 1],ov0[ 0]}
);

lcell_16 lc_ic(o, ov1[3] | ov1[2] | ov1[1] | ov1[0]);
endmodule



module core_executer(
	input [15:0] instructionIn_extern,
	input [ 4:0] instructionInID_extern,
	input [25:0] instructionAddress,
	
	input doExecute,
	input willExecute,

	input [15:0] user_reg [15:0],
	input [15:0] instant_user_reg [15:0],
	
	input [15:0] next_stack_pointer,
	input [15:0] stack_pointer,
	input [15:0] stack_pointer_m2,
	input [15:0] stack_pointer_m4,
	input [15:0] stack_pointer_m6,
	input [15:0] stack_pointer_m8,
	input [15:0] stack_pointer_p2,
	input [15:0] stack_pointer_p4,
	
	output [16:0] doWrite_w, // doWrite[16] is stack pointer's doWrite
	output [15:0] writeValues_w [16:0],
	
	output [ 2:0] mem_stack_access_size_extern,
	output [15:0] mem_target_address_stack_extern,
	output [31:0] mem_target_address_general_extern,
	
	input  [15:0] mem_data_out_small,
	input  [15:0] mem_data_out_large [4:0],
	output [15:0] mem_data_in_extern [3:0],

	output mem_is_stack_access_write_extern,
	output mem_is_stack_access_requesting_extern,

	output mem_is_general_access_write_extern,
	output mem_is_general_access_byte_operation_extern,
	output mem_is_general_access_requesting_extern,
	
	input  mem_is_access_acknowledged_pulse,
	input  mem_will_access_be_acknowledged_pulse,
	
	output is_instruction_finishing_this_cycle_pulse_extern, // single cycle pulse
	output will_instruction_finish_next_cycle_pulse_extern,
	
	output [31:0] instruction_jump_address_extern,
	output jump_signal_extern,
	
	input main_clk
);

wire [15:0] instructionIn;
wire [ 4:0] instructionInID;

lcell_16 lc_instruct_full (instructionIn,instructionIn_extern);
lcell_5  lc_instruct_id (instructionInID,instructionInID_extern);

reg [15:0] doWrite=0;
reg [15:0] writeValues [15:0];
reg doWrite_sp=0;
reg [15:0] writeValue_sp;
assign doWrite_w[15:0]=doWrite;
assign doWrite_w[16]=doWrite_sp;
assign writeValues_w[15:0]=writeValues[15:0];
assign writeValues_w[16]=writeValue_sp;

reg jump_signal=0;
reg will_jump_next_cycle;
always @(posedge main_clk) jump_signal<=will_jump_next_cycle;
assign jump_signal_extern=jump_signal;

reg will_instruction_finish_next_cycle_pulse;
reg is_instruction_finishing_this_cycle_pulse=0;
assign will_instruction_finish_next_cycle_pulse_extern=will_instruction_finish_next_cycle_pulse;
assign is_instruction_finishing_this_cycle_pulse_extern=is_instruction_finishing_this_cycle_pulse;
always @(posedge main_clk) is_instruction_finishing_this_cycle_pulse<=will_instruction_finish_next_cycle_pulse;

reg [ 2:0] mem_stack_access_size;
reg [15:0] mem_target_address_stack;
reg [31:0] mem_target_address_general;

reg [15:0] mem_data_in [3:0];

reg mem_is_stack_access_write;
reg mem_is_stack_access_requesting;
reg mem_is_general_access_byte_operation;
reg mem_is_general_access_write;
reg mem_is_general_access_requesting;

assign mem_stack_access_size_extern=mem_stack_access_size;
assign mem_target_address_stack_extern=mem_target_address_stack;
assign mem_target_address_general_extern=mem_target_address_general;


assign mem_data_in_extern=mem_data_in;

assign mem_is_stack_access_write_extern=mem_is_stack_access_write;
assign mem_is_stack_access_requesting_extern=mem_is_stack_access_requesting;

assign mem_is_general_access_byte_operation_extern=mem_is_general_access_byte_operation;
assign mem_is_general_access_write_extern=mem_is_general_access_write;
assign mem_is_general_access_requesting_extern=mem_is_general_access_requesting;


reg [31:0] instruction_jump_address;
assign instruction_jump_address_extern=instruction_jump_address;


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

reg [16:0] adderOutput;


reg [15:0] mem_data_out_large_r [4:0];
always @(posedge main_clk) mem_data_out_large_r<=mem_data_out_large;

reg [15:0] mem_data_out_small_r;
always @(posedge main_clk) mem_data_out_small_r<=mem_data_out_small;


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


reg [2:0] step=0;
reg [2:0] stepNext;

wire [15:0] nvr0;//=instant_user_reg[instructionIn[ 3:0]];
wire [15:0] nvr1;//=instant_user_reg[instructionIn[ 7:4]];
wire [15:0] nvr2;//=instant_user_reg[instructionIn[11:8]];

//lcell_16 lcell_nvr0(nvr0,instant_user_reg[instructionIn[ 3:0]]);
//lcell_16 lcell_nvr1(nvr1,instant_user_reg[instructionIn[ 7:4]]);
//lcell_16 lcell_nvr2(nvr2,instant_user_reg[instructionIn[11:8]]);

fast_ur_mux fast_ur_mux0(nvr0,instructionIn[ 3:0],instant_user_reg);
fast_ur_mux fast_ur_mux1(nvr1,instructionIn[ 7:4],instant_user_reg);
fast_ur_mux fast_ur_mux2(nvr2,instructionIn[11:8],instant_user_reg);


always @(posedge main_clk) begin
	assert (nvr0==instant_user_reg[instructionIn[ 3:0]]);
	assert (nvr1==instant_user_reg[instructionIn[ 7:4]]);
	assert (nvr2==instant_user_reg[instructionIn[11:8]]);
end

reg [15:0] vr0=16'hFFFF;
reg [15:0] vr1=16'hFFFF;
reg [15:0] vr2=0;
/*
Initial value for vr0 and vr1 is to prevent packing into the multiplier blocks.
I don't understand why quartus really wants to do that, it requires creating a duplicate register anyway and decreases system performance.
*/

reg [15:0] instructionCurrent=0;
reg [4:0] instructionCurrentID=0;

reg adderControl0_r;
reg adderControl1_r;
reg adderControl2_r;

always @(posedge main_clk) instructionCurrent<=instructionIn;
always @(posedge main_clk) instructionCurrentID<=instructionInID;

always @(posedge main_clk) adderControl0_r<=adderControl0_lut[instructionIn[15:12]];
always @(posedge main_clk) adderControl1_r<=adderControl1_lut[instructionIn[15:12]];
always @(posedge main_clk) adderControl2_r<=adderControl2_lut[instructionIn[15:12]];
always @(posedge main_clk) step<=stepNext;

lcell_19 lc_add0 (temporary8,{2'b0,temporary5,1'b1}+adderControl1_r);
lcell_19 lc_add1 (temporary9,{2'b0,temporary4,1'b0}+{2'b0,temporary3,1'b0});
lcell_19 lc_add2 (temporaryA,temporary8+temporary9);

assign temporary6=temporaryA[18:1];

always @(posedge main_clk) begin
	vr0<=nvr0;
	vr1<=nvr1;
	vr2<=nvr2;
end

reg sim_is_first=0; // `sim_is_first` is used only for simulation testing
always @(posedge main_clk) sim_is_first<=1;

always @(posedge main_clk) begin
	if (sim_is_first) begin
		if (user_reg[instructionCurrent[ 3:0]]!=vr0) begin $stop(); end
		if (user_reg[instructionCurrent[ 7:4]]!=vr1) begin $stop(); end
		if (user_reg[instructionCurrent[11:8]]!=vr2) begin $stop(); end
	end
end

always_comb begin
	temporary0[0]=bitwise_lut[{instructionIn[13:12],nvr2[0],nvr1[0]}];
	temporary0[1]=bitwise_lut[{instructionIn[13:12],nvr2[1],nvr1[1]}];
	temporary0[2]=bitwise_lut[{instructionIn[13:12],nvr2[2],nvr1[2]}];
	temporary0[3]=bitwise_lut[{instructionIn[13:12],nvr2[3],nvr1[3]}];
	temporary0[4]=bitwise_lut[{instructionIn[13:12],nvr2[4],nvr1[4]}];
	temporary0[5]=bitwise_lut[{instructionIn[13:12],nvr2[5],nvr1[5]}];
	temporary0[6]=bitwise_lut[{instructionIn[13:12],nvr2[6],nvr1[6]}];
	temporary0[7]=bitwise_lut[{instructionIn[13:12],nvr2[7],nvr1[7]}];
	temporary0[8]=bitwise_lut[{instructionIn[13:12],nvr2[8],nvr1[8]}];
	temporary0[9]=bitwise_lut[{instructionIn[13:12],nvr2[9],nvr1[9]}];
	temporary0[10]=bitwise_lut[{instructionIn[13:12],nvr2[10],nvr1[10]}];
	temporary0[11]=bitwise_lut[{instructionIn[13:12],nvr2[11],nvr1[11]}];
	temporary0[12]=bitwise_lut[{instructionIn[13:12],nvr2[12],nvr1[12]}];
	temporary0[13]=bitwise_lut[{instructionIn[13:12],nvr2[13],nvr1[13]}];
	temporary0[14]=bitwise_lut[{instructionIn[13:12],nvr2[14],nvr1[14]}];
	temporary0[15]=bitwise_lut[{instructionIn[13:12],nvr2[15],nvr1[15]}];
end
always_comb begin
	temporary3=vr1;
	temporary4={16{adderControl0_r}} ^ vr2;
	temporary5={16{adderControl2_r}} & (instructionCurrent[15]?user_reg[4'hF]:vr0);
end
always_comb begin
	adderOutput[15:0]=temporary6[15:0];
	adderOutput[16]=(temporary6[17] | temporary6[16])?1'b1:1'b0;
end
always_comb begin
	temporary7=stack_pointer - vr0;
	temporary7[0]=1'b0;
end

always_comb begin
	temporary1={instructionIn[11:4],1'b0} + instant_user_reg[4'h1];
end

reg [31:0] mul32Temp;

reg [15:0] mul16Temp;

reg [16:0] divTemp0;
reg [15:0] divTemp1;
reg [ 2:0] divTemp2;
reg [15:0] divTemp3;
reg [15:0] divTemp4;
reg [15:0] divTemp5;

wire [16:0] divTemp6={1'b0,~vr1}+(2'b1+vr0[15]);
wire [15:0] divTemp7=({16{((divTemp6[16])?1'b1:1'b0)}} & divTemp6[15:0]) | ({16{((divTemp6[16])?1'b0:1'b1)}} & {15'h0,vr0[15]});

wire [16:0] divTable0 [2:0];
wire [16:0] divTable1 [2:0];
wire [16:0] divTable2 [2:0];

assign divTable0[0]={divTemp5,divTemp2[2]};
assign divTable0[1]=divTemp0+divTable0[0];
assign divTable0[2]=({16{((divTable0[1][16])?1'b1:1'b0)}} & divTable0[1][15:0]) | ({16{((divTable0[1][16])?1'b0:1'b1)}} & divTable0[0][15:0]);

assign divTable1[0]={divTable0[2][15:0],divTemp2[1]};
assign divTable1[1]=divTemp0+divTable1[0];
assign divTable1[2]=({16{((divTable1[1][16])?1'b1:1'b0)}} & divTable1[1][15:0]) | ({16{((divTable1[1][16])?1'b0:1'b1)}} & divTable1[0][15:0]);

assign divTable2[0]={divTable1[2][15:0],divTemp2[0]};
assign divTable2[1]=divTemp0+divTable2[0];
assign divTable2[2]=({16{((divTable2[1][16])?1'b1:1'b0)}} & divTable2[1][15:0]) | ({16{((divTable2[1][16])?1'b0:1'b1)}} & divTable2[0][15:0]);

wire [2:0] divPartialResult;
assign divPartialResult={divTable0[1][16],divTable1[1][16],divTable2[1][16]};

always @(posedge main_clk) begin
	if (step!=3'd0) begin
		assert (doExecute);
	end
end

reg wa0=0; // if r0 is being set by alternative register
reg wa1=0; // r0
reg wa2=0; // if r1 is being set by alternative register
reg wa3=0; // r1
reg wa4=0; // 0 or 13
reg wa5=0; // 1 or 14 or 15

reg wb0; // discern if wa4 is for 0
reg wb1; // discern if wa4 is for 13
reg wb2; // discern if wa5 is for 1
reg wb3; // discern if wa5 is for 14
reg wb4; // discern if wa5 is for 15

reg [15:0] wv0;
reg [15:0] wv1;
reg [15:0] wv2;
reg [15:0] wv3;
reg [15:0] wv4;
reg [15:0] wv5;

reg [15:0] wt;

always_comb begin
	wt=wa0?wv1:wv0;
	writeValues='{wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt};
	if (wa3) writeValues[instructionCurrent[7:4]]=wa2?wv3:wv2;
	if (wa4) writeValues[ 0]=wv4;
	if (wa4) writeValues[13]=wv4;
	if (wa5) writeValues[ 1]=wv5;
	if (wa5) writeValues[14]=wv5;
	if (wa5) writeValues[15]=wv5;
end
always_comb begin
	doWrite=0;
	if (wa1) doWrite[instructionCurrent[3:0]]=1'b1;
	if (wa3) doWrite[instructionCurrent[7:4]]=1'b1;
	if (wa4 & wb0) doWrite[ 0]=1'b1;
	if (wa4 & wb1) doWrite[13]=1'b1;
	if (wa5 & wb2) doWrite[ 1]=1'b1;
	if (wa5 & wb3) doWrite[14]=1'b1;
	if (wa5 & wb4) doWrite[15]=1'b1;
end


always @(posedge main_clk) begin
	mem_is_stack_access_write<=0;
	mem_is_stack_access_requesting<=0;
	mem_is_general_access_byte_operation<=0;
	mem_is_general_access_write<=0;
	mem_is_general_access_requesting<=0;
	mem_stack_access_size<=3'hx;
	mem_target_address_general<=32'hx;
	mem_target_address_stack<=16'hx;
	doWrite_sp<=0;
	writeValue_sp<=16'hx;
	wv0<=16'hx;
	wv1<=16'hx;
	wv2<=16'hx;
	wv3<=16'hx;
	wv4<=16'hx;
	wv5<=16'hx;
	wa0<=0;
	wa1<=0;
	wa2<=0;
	wa3<=0;
	wa4<=0;
	wa5<=0;
	wb0<=1'bx;
	wb1<=1'bx;
	wb2<=1'bx;
	wb3<=1'bx;
	wb4<=1'bx;
	if (willExecute) begin
		unique case (instructionInID)
		0:begin
			wa0<=1;
			wv1<={8'h0,instructionIn[11:4]};
			wa1<=1;
		end
		1:begin
			wa0<=1;
			wv1<={instructionIn[11:4],nvr0[7:0]};
			wa1<=1;
		end
		2:begin
			mem_is_stack_access_write<=0;
			mem_stack_access_size<=1;
			mem_target_address_stack<=temporary1;
			unique case (stepNext)
			0:begin
				mem_is_stack_access_requesting<=1;
			end
			1:begin
				wv0<=mem_data_out_large[0];
				wa1<=1;
			end
			endcase
		end
		3:begin
			mem_is_stack_access_write<=1;
			mem_is_stack_access_requesting<=1;
			mem_stack_access_size<=1;
			mem_target_address_stack<=temporary1;
		end
		4:begin
			wa0<=1;
			wv1<=temporary0;
			wa1<=1;
		end
		5:begin
			wa0<=1;
			wv1<=temporary0;
			wa1<=1;
		end
		6:begin
			wa0<=1;
			wv1<=temporary0;
			wa1<=1;
		end
		7:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv1<={15'h0,adderOutput[16]};
				wa1<=1;
				wv2<=adderOutput[15:0];
				wa3<=1;
			end
			endcase
		end
		8:begin
			mem_is_general_access_byte_operation<=0;
			mem_is_general_access_write<=0;
			mem_target_address_general<={nvr2,nvr1};
			mem_target_address_general[0]<=1'b0;
			unique case (stepNext)
			0:begin
				mem_is_general_access_requesting<=1;
			end
			1:begin
				wv0<=mem_data_out_small;
				wa1<=1;
			end
			endcase
		end
		9:begin
			mem_is_general_access_requesting<=1;
			mem_is_general_access_byte_operation<=0;
			mem_is_general_access_write<=1;
			mem_target_address_general<={nvr2,nvr1};
			mem_target_address_general[0]<=1'b0;
		end
		10:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv1<=adderOutput[15:0];
				wa1<=1;
			end
			endcase
		end
		11:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv1<=adderOutput[15:0];
				wv5<={15'h0,adderOutput[16]};
				wa1<=1;
				wa5<=1;
				wb2<=0;
				wb3<=0;
				wb4<=1;
			end
			endcase
		end
		12:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv1<=adderOutput[15:0];
				wa1<=1;
			end
			endcase
		end
		13:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv1<={15'h0,adderOutput[16]};
				wa1<=1;
			end
			endcase
		end
		14:begin
			instruction_jump_address<={nvr1,nvr0};
		end
		16:begin
			mem_is_stack_access_write<=1;
			mem_stack_access_size<=1;
			mem_is_stack_access_requesting<=1;
			mem_target_address_stack<=next_stack_pointer-4'd2;
			if (mem_will_access_be_acknowledged_pulse) begin
				writeValue_sp<=stack_pointer_m2;
				doWrite_sp<=1'b1;
				
				assert (next_stack_pointer==stack_pointer); // and that stack_pointer's instant_override is not active
			end
		end
		17:begin
			mem_is_stack_access_write<=1;
			mem_stack_access_size<=2;
			mem_is_stack_access_requesting<=1;
			mem_target_address_stack<=next_stack_pointer-4'd4;
			if (mem_will_access_be_acknowledged_pulse) begin
				writeValue_sp<=stack_pointer_p4;
				doWrite_sp<=1'b1;
				
				assert (next_stack_pointer==stack_pointer); // and that stack_pointer's instant_override is not active
			end
		end
		18:begin
			mem_is_stack_access_write<=0;
			mem_stack_access_size<=1;
			mem_target_address_stack<=next_stack_pointer;
			unique case (stepNext)
			0:begin
				mem_is_stack_access_requesting<=1;
			end
			1:begin
				doWrite_sp<=1'b1;
				wv0<=mem_data_out_large[0];
				wa1<=1;
				writeValue_sp<=stack_pointer_p2;
				
				assert (next_stack_pointer==stack_pointer); // and that stack_pointer's instant_override is not active
			end
			endcase
		end
		19:begin
			mem_is_stack_access_write<=0;
			mem_stack_access_size<=2;
			mem_target_address_stack<=next_stack_pointer;
			wa2<=1;
			unique case (stepNext)
			0:begin
				mem_is_stack_access_requesting<=1;
			end
			1:begin
				doWrite_sp<=1'b1;
				wv0<=mem_data_out_large[0];
				wv3<=mem_data_out_large[1];
				wa1<=1;
				wa3<=1;
				writeValue_sp<=stack_pointer_p4;
				
				assert (next_stack_pointer==stack_pointer); // and that stack_pointer's instant_override is not active
			end
			endcase
		end
		20:begin
			wv0<=nvr1;
			wa1<=1;
		end
		21:begin
			wv0<={nvr1[ 7:0],nvr1[15:8]};
			wa1<=1;
		end
		22:begin
			wv0<={1'b0,nvr1[15:1]};
			wa1<=1;
		end
		23:begin
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv0<=mul16Temp;
				wa1<=1;
			end
			endcase
		end
		24:begin
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv4<=mul32Temp[15: 0];
				wv5<=mul32Temp[31:16];
				wa4<=1;
				wa5<=1;
				
				wb2<=0;
				wb3<=1;
				wb4<=0;
			end
			endcase
		end
		25:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
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
				wv1<={divTemp3[15:3],divPartialResult};
				wv2<=divTable2[2][15:0];
				wa1<=1;
				wa3<=1;
				
				wb0<=0;
				wb1<=1;
			end
			endcase
		end
		26:begin
			mem_is_stack_access_write<=1;
			mem_stack_access_size<=4;
			mem_target_address_stack<=next_stack_pointer-4'd8;
			unique case (stepNext)
			0:begin
				mem_is_stack_access_requesting<=1;
			end
			1:begin
				doWrite_sp<=1'b1;
				instruction_jump_address<={nvr1,nvr0};
				writeValue_sp<=stack_pointer_m8;
				wv4<=stack_pointer_m8;
				wa4<=1;
				wb0<=1;
				wb1<=0;
				
				assert (next_stack_pointer==stack_pointer); // and that stack_pointer's instant_override is not active
			end
			endcase
		end
		27:begin
			mem_is_stack_access_write<=0;
			mem_stack_access_size<=5;
			mem_target_address_stack<=instant_user_reg[4'h0]-4'h8;
			
			// this is able to use user_reg[4'h0] and ignore the instant_override because it is known to take more then one cycle before this value is used (so there is no override at the time this value is used)
			unique case (stepNext)
			0:begin
				mem_is_stack_access_requesting<=1;
			end
			1:begin
			end
			2:begin
				instruction_jump_address<={mem_data_out_large_r[3],mem_data_out_large_r[4]};
				doWrite_sp<=1'b1;
				writeValue_sp<=(user_reg[4'h0]-4'hA) + mem_data_out_large_r[0];
				wv4<=mem_data_out_large_r[1];
				wv5<=mem_data_out_large_r[2];
				wa4<=1;
				wa5<=1;
				wb0<=1;
				wb1<=0;
				wb2<=1;
				wb3<=0;
				wb4<=0;
			end
			endcase
		end
		28:begin
			mem_is_general_access_byte_operation<=1;
			mem_is_general_access_write<=0;
			mem_target_address_general<={nvr1,instant_user_reg[4'hD]};
			unique case (stepNext)
			0:begin
				mem_is_general_access_requesting<=1;
			end
			1:begin
				wv0<=mem_data_out_small;
				wa1<=1;
			end
			endcase
		end
		29:begin
			mem_is_general_access_byte_operation<=1;
			mem_is_general_access_write<=1;
			mem_is_general_access_requesting<=1;
			mem_target_address_general<={nvr1,instant_user_reg[4'hD]};
		end
		30:begin
			instruction_jump_address<={nvr1,nvr0};
		end
		31:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				doWrite_sp<=1'b1;
				writeValue_sp<=temporary7;
				wv1<=temporary7;
				wa1<=1;
			end
			endcase
		end
		endcase
	end
	
	// the one's bit of this should always be zero
	instruction_jump_address[0]<=1'b0;
	mem_target_address_stack[0]<=1'b0;
end



always_comb begin
	mem_data_in='{16'hx,16'hx,16'hx,16'hx};
	
	if (doExecute) begin
		unique case (instructionCurrentID)
		0:begin
		end
		1:begin
		end
		2:begin
		end
		3:begin
			mem_data_in[0]=vr0;
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
			mem_data_in[0]=vr0;
		end
		10:begin
		end
		11:begin
		end
		12:begin
		end
		13:begin
		end
		14:begin
		end
		16:begin
			mem_data_in[0]=vr0;
		end
		17:begin
			mem_data_in[0]=vr0;
			mem_data_in[1]=vr1;
		end
		18:begin
		end
		19:begin
		end
		20:begin
		end
		21:begin
		end
		22:begin
		end
		23:begin
		end
		24:begin
		end
		25:begin
		end
		26:begin
			mem_data_in[0]={instructionAddress[15:1],1'b0};
			mem_data_in[1]={7'b0,instructionAddress[24:16]};
			mem_data_in[2]=user_reg[4'h1];
			mem_data_in[3]=user_reg[4'h0];
		end
		27:begin
		end
		28:begin
		end
		29:begin
			mem_data_in[0]=vr0;
		end
		30:begin
		end
		31:begin
		end
		endcase
	end
end

always_comb begin
	mul16Temp=vr1*vr0;
	mul32Temp={vr1,vr0}*{user_reg[4'hE],user_reg[4'hD]};
end


always_comb begin
	if (doExecute) begin
		stepNext=0;
		unique case (instructionCurrentID)
		0:begin
		end
		1:begin
		end
		2:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
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
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		8:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		9:begin
		end
		10:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		11:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		12:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		13:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		14:begin
		end
		16:begin
		end
		17:begin
		end
		18:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		19:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		20:begin
		end
		21:begin
		end
		22:begin
		end
		23:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		24:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		25:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=2;
			end
			2:begin
				stepNext=3;
			end
			3:begin
				stepNext=4;
			end
			4:begin
				stepNext=5;
			end
			5:begin
				stepNext=6;
			end
			6:begin
				stepNext=0;
			end
			endcase
		end
		26:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		27:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=2;
			end
			2:begin
				stepNext=0;
			end
			endcase
		end
		28:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		29:begin
		end
		30:begin
		end
		31:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		endcase
	end else begin
		stepNext=step;
	end
end

reg future_sig_helper [3:0];

wire future_sig_helper0a [3:0];
wire future_sig_helper1a [2:0];
wire future_sig_helper2a [1:0];

wire future_sig_helper0b [3:0];
wire future_sig_helper1b [2:0];
wire future_sig_helper2b [1:0];
assign future_sig_helper0b=future_sig_helper;
assign future_sig_helper1b[0]=willExecute;
assign future_sig_helper1b[1]=mem_will_access_be_acknowledged_pulse;
assign future_sig_helper1b[2]=!(| nvr2);

lcell lc00 (.in(future_sig_helper0b[0]),.out(future_sig_helper0a[0]));
lcell lc01 (.in(future_sig_helper0b[1]),.out(future_sig_helper0a[1]));
lcell lc02 (.in(future_sig_helper0b[2]),.out(future_sig_helper0a[2]));
lcell lc03 (.in(future_sig_helper0b[3]),.out(future_sig_helper0a[3]));

lcell lc10 (.in(future_sig_helper1b[0]),.out(future_sig_helper1a[0]));
lcell lc11 (.in(future_sig_helper1b[1]),.out(future_sig_helper1a[1]));
lcell lc12 (.in(future_sig_helper1b[2]),.out(future_sig_helper1a[2]));

lcell lc20 (.in(future_sig_helper2b[0]),.out(future_sig_helper2a[0]));
lcell lc21 (.in(future_sig_helper2b[1]),.out(future_sig_helper2a[1]));

assign future_sig_helper2b[0]=(future_sig_helper0a[0] | future_sig_helper0a[1]) & (future_sig_helper0a[0]?future_sig_helper1a[0]:1'b1) & (future_sig_helper0a[1]?future_sig_helper1a[1]:1'b1);
assign future_sig_helper2b[1]=(future_sig_helper0a[2] | future_sig_helper0a[3]) & (future_sig_helper0a[2]?future_sig_helper1a[0]:1'b1) & (future_sig_helper0a[3]?future_sig_helper1a[2]:1'b1);

assign will_instruction_finish_next_cycle_pulse=future_sig_helper2a[0];
assign will_jump_next_cycle=future_sig_helper2a[1];


always_comb begin
	future_sig_helper='{0,0,0,0};
	unique case (instructionInID)
	0:begin
		future_sig_helper[0]=1;
	end
	1:begin
		future_sig_helper[0]=1;
	end
	2:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	3:begin
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	4:begin
		future_sig_helper[0]=1;
	end
	5:begin
		future_sig_helper[0]=1;
	end
	6:begin
		future_sig_helper[0]=1;
	end
	7:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	8:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	9:begin
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	10:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	11:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	12:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	13:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	14:begin
			future_sig_helper[0]=1;
			future_sig_helper[2]=1;
			future_sig_helper[3]=1;
	end
	16:begin
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	17:begin
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	18:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	19:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	20:begin
		future_sig_helper[0]=1;
	end
	21:begin
		future_sig_helper[0]=1;
	end
	22:begin
		future_sig_helper[0]=1;
	end
	23:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	24:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	25:begin
		unique case (stepNext)
		0:begin
		end
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
			future_sig_helper[0]=1;
		end
		endcase
	end
	26:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
			future_sig_helper[2]=1;
		end
		endcase
	end
	27:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
		end
		2:begin
			future_sig_helper[0]=1;
			future_sig_helper[2]=1;
		end
		endcase
	end
	28:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	29:begin
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	30:begin
		future_sig_helper[0]=1;
		future_sig_helper[2]=1;
	end
	31:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	endcase
end


always @(posedge main_clk) begin
	if (doExecute && instructionCurrentID==5'd25) begin
		// this is only actually used for division
		unique case (step)
		0:begin
			divTemp0<={1'b0,~vr1}+1'b1;
			divTemp1<=vr0;
			divTemp2<=vr0[14:12];
			divTemp5<=divTemp7;
			divTemp3[15]<=divTemp6[16];
		end
		1:begin
			divTemp2<=divTemp1[11:9];
			divTemp5<=divTable2[2][15:0];
			divTemp3[14:12]<=divPartialResult;
		end
		2:begin
			divTemp2<=divTemp1[8:6];
			divTemp5<=divTable2[2][15:0];
			divTemp3[11:9]<=divPartialResult;
		end
		3:begin
			divTemp2<=divTemp1[5:3];
			divTemp5<=divTable2[2][15:0];
			divTemp3[8:6]<=divPartialResult;
		end
		4:begin
			divTemp2<=divTemp1[2:0];
			divTemp5<=divTable2[2][15:0];
			divTemp3[5:3]<=divPartialResult;
		end
		5:begin
		end
		6:begin
		end
		endcase
	end
end

endmodule

