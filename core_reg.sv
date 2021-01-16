`timescale 1 ps / 1 ps



`include "vga_driver.sv"


module division_remainder(
output [15:0] quotient,
output [15:0] remainder,

input  [15:0] dividend,
input  [15:0] divisor
);
/*
assign quotient=  dividend / divisor;
assign remainder= dividend % divisor;
*/


wire [16:0] su;
wire [16:0] st [15:0];
wire [15:0] sf [15:0];

assign su={1'b0,~divisor}+1'b1;

assign st[0]=su+{15'b0,dividend[15]};
assign sf[0]=({16{st[0][16]}}&st[0][15:0])|({16{~st[0][16]}}&{15'b0,dividend[15]});

assign st[1]=su+{sf[0][14:0],dividend[14]};
assign sf[1]=({16{st[1][16]}}&st[1][15:0])|({16{~st[1][16]}}&{sf[0][14:0],dividend[14]});

assign st[2]=su+{sf[1][14:0],dividend[13]};
assign sf[2]=({16{st[2][16]}}&st[2][15:0])|({16{~st[2][16]}}&{sf[1][14:0],dividend[13]});

assign st[3]=su+{sf[2][14:0],dividend[12]};
assign sf[3]=({16{st[3][16]}}&st[3][15:0])|({16{~st[3][16]}}&{sf[2][14:0],dividend[12]});

assign st[4]=su+{sf[3][14:0],dividend[11]};
assign sf[4]=({16{st[4][16]}}&st[4][15:0])|({16{~st[4][16]}}&{sf[3][14:0],dividend[11]});

assign st[5]=su+{sf[4][14:0],dividend[10]};
assign sf[5]=({16{st[5][16]}}&st[5][15:0])|({16{~st[5][16]}}&{sf[4][14:0],dividend[10]});

assign st[6]=su+{sf[5][14:0],dividend[9]};
assign sf[6]=({16{st[6][16]}}&st[6][15:0])|({16{~st[6][16]}}&{sf[5][14:0],dividend[9]});

assign st[7]=su+{sf[6][14:0],dividend[8]};
assign sf[7]=({16{st[7][16]}}&st[7][15:0])|({16{~st[7][16]}}&{sf[6][14:0],dividend[8]});

assign st[8]=su+{sf[7][14:0],dividend[7]};
assign sf[8]=({16{st[8][16]}}&st[8][15:0])|({16{~st[8][16]}}&{sf[7][14:0],dividend[7]});

assign st[9]=su+{sf[8][14:0],dividend[6]};
assign sf[9]=({16{st[9][16]}}&st[9][15:0])|({16{~st[9][16]}}&{sf[8][14:0],dividend[6]});

assign st[10]=su+{sf[9][14:0],dividend[5]};
assign sf[10]=({16{st[10][16]}}&st[10][15:0])|({16{~st[10][16]}}&{sf[9][14:0],dividend[5]});

assign st[11]=su+{sf[10][14:0],dividend[4]};
assign sf[11]=({16{st[11][16]}}&st[11][15:0])|({16{~st[11][16]}}&{sf[10][14:0],dividend[4]});

assign st[12]=su+{sf[11][14:0],dividend[3]};
assign sf[12]=({16{st[12][16]}}&st[12][15:0])|({16{~st[12][16]}}&{sf[11][14:0],dividend[3]});

assign st[13]=su+{sf[12][14:0],dividend[2]};
assign sf[13]=({16{st[13][16]}}&st[13][15:0])|({16{~st[13][16]}}&{sf[12][14:0],dividend[2]});

assign st[14]=su+{sf[13][14:0],dividend[1]};
assign sf[14]=({16{st[14][16]}}&st[14][15:0])|({16{~st[14][16]}}&{sf[13][14:0],dividend[1]});

assign st[15]=su+{sf[14][14:0],dividend[0]};
assign sf[15]=({16{st[15][16]}}&st[15][15:0])|({16{~st[15][16]}}&{sf[14][14:0],dividend[0]});


assign quotient={st[0][16],st[1][16],st[2][16],st[3][16],st[4][16],st[5][16],st[6][16],st[7][16],st[8][16],st[9][16],st[10][16],st[11][16],st[12][16],st[13][16],st[14][16],st[15][16]};
assign remainder=sf[15];

endmodule


module generate_hex_display_base10(
output [7:0] hex_display [5:0],
input [15:0] number
);

wire [15:0] numberAtStage [5:0];
wire [15:0] digit_binary_full [5:0];
wire [ 3:0] digit_binary [5:0];

assign digit_binary[0]=digit_binary_full[0][3:0];
assign digit_binary[1]=digit_binary_full[1][3:0];
assign digit_binary[2]=digit_binary_full[2][3:0];
assign digit_binary[3]=digit_binary_full[3][3:0];
assign digit_binary[4]=digit_binary_full[4][3:0];
assign digit_binary[5]=digit_binary_full[5][3:0];



division_remainder hex_display0(
	numberAtStage[0],
	digit_binary_full[0],
	
	number,
	16'd10
);
division_remainder hex_display1(
	numberAtStage[1],
	digit_binary_full[1],
	
	numberAtStage[0],
	16'd10
);
division_remainder hex_display2(
	numberAtStage[2],
	digit_binary_full[2],
	
	numberAtStage[1],
	16'd10
);
division_remainder hex_display3(
	numberAtStage[3],
	digit_binary_full[3],
	
	numberAtStage[2],
	16'd10
);
division_remainder hex_display4(
	numberAtStage[4],
	digit_binary_full[4],
	
	numberAtStage[3],
	16'd10
);

assign numberAtStage[5]=0;
assign digit_binary_full[5]=numberAtStage[4];

wire [6:0] hex_display_lut [15:0];
assign hex_display_lut[4'h0] = 7'b_0111111;
assign hex_display_lut[4'h1] = 7'b_0000110;	
assign hex_display_lut[4'h2] = 7'b_1011011; 	
assign hex_display_lut[4'h3] = 7'b_1001111; 	
assign hex_display_lut[4'h4] = 7'b_1100110; 	
assign hex_display_lut[4'h5] = 7'b_1101101; 	
assign hex_display_lut[4'h6] = 7'b_1111101; 	
assign hex_display_lut[4'h7] = 7'b_0000111; 	
assign hex_display_lut[4'h8] = 7'b_1111111; 	
assign hex_display_lut[4'h9] = 7'b_1100111; 
assign hex_display_lut[4'ha] = 7'b_1110111;
assign hex_display_lut[4'hb] = 7'b_1111100;
assign hex_display_lut[4'hc] = 7'b_0111001;
assign hex_display_lut[4'hd] = 7'b_1011110;
assign hex_display_lut[4'he] = 7'b_1111001;
assign hex_display_lut[4'hf] = 7'b_1110001;

/*
 ---t----
 |	    |
 lt	   rt
 |	    |
 ---m----
 |	    |
 lb	   rb
 |	    |
 ---b --d

hex={d,m,lt,lb,b,rb,rt,t}  (I think...)

hex display is active low, but the lut is coded as active high
*/
wire [7:0] hex_display_pre_inv [5:0];


// idk if that is the correct order (as in if the ones digit is on the right side 7seg)
assign hex_display_pre_inv[0][6:0]=hex_display_lut[digit_binary[5]];
assign hex_display_pre_inv[1][6:0]=(digit_binary[0]==4'd0 && digit_binary[1]==4'd0 && digit_binary[2]==4'd0 && digit_binary[3]==4'd0 && digit_binary[4]==4'd0)?7'b0:hex_display_lut[digit_binary[4]];
assign hex_display_pre_inv[2][6:0]=(digit_binary[0]==4'd0 && digit_binary[1]==4'd0 && digit_binary[2]==4'd0 && digit_binary[3]==4'd0)?7'b0:hex_display_lut[digit_binary[3]];
assign hex_display_pre_inv[3][6:0]=(digit_binary[0]==4'd0 && digit_binary[1]==4'd0 && digit_binary[2]==4'd0)?7'b0:hex_display_lut[digit_binary[2]];
assign hex_display_pre_inv[4][6:0]=(digit_binary[0]==4'd0 && digit_binary[1]==4'd0)?7'b0:hex_display_lut[digit_binary[1]];
assign hex_display_pre_inv[5][6:0]=(digit_binary[0]==4'd0)?7'b0:hex_display_lut[digit_binary[0]];

assign hex_display_pre_inv[0][7]=1'b0;
assign hex_display_pre_inv[1][7]=1'b0;
assign hex_display_pre_inv[2][7]=1'b0;
assign hex_display_pre_inv[3][7]=1'b0;
assign hex_display_pre_inv[4][7]=1'b0;
assign hex_display_pre_inv[5][7]=1'b0;


assign hex_display[0]=~(hex_display_pre_inv[0]);
assign hex_display[1]=~(hex_display_pre_inv[1]);
assign hex_display[2]=~(hex_display_pre_inv[2]);
assign hex_display[3]=~(hex_display_pre_inv[3]);
assign hex_display[4]=~(hex_display_pre_inv[4]);
assign hex_display[5]=~(hex_display_pre_inv[5]);

endmodule


module generate_hex_display_base16(
output [7:0] hex_display [5:0],
input [15:0] number
);

wire [6:0] hex_display_lut [15:0];
assign hex_display_lut[4'h0] = 7'b_0111111;
assign hex_display_lut[4'h1] = 7'b_0000110;	
assign hex_display_lut[4'h2] = 7'b_1011011; 	
assign hex_display_lut[4'h3] = 7'b_1001111; 	
assign hex_display_lut[4'h4] = 7'b_1100110; 	
assign hex_display_lut[4'h5] = 7'b_1101101; 	
assign hex_display_lut[4'h6] = 7'b_1111101; 	
assign hex_display_lut[4'h7] = 7'b_0000111; 	
assign hex_display_lut[4'h8] = 7'b_1111111; 	
assign hex_display_lut[4'h9] = 7'b_1100111; 
assign hex_display_lut[4'ha] = 7'b_1110111;
assign hex_display_lut[4'hb] = 7'b_1111100;
assign hex_display_lut[4'hc] = 7'b_0111001;
assign hex_display_lut[4'hd] = 7'b_1011110;
assign hex_display_lut[4'he] = 7'b_1111001;
assign hex_display_lut[4'hf] = 7'b_1110001;

/*
 ---t----
 |	    |
 lt	   rt
 |	    |
 ---m----
 |	    |
 lb	   rb
 |	    |
 ---b --d

hex={d,m,lt,lb,b,rb,rt,t}  (I think...)

hex display is active low, but the lut is coded as active high
*/
wire [7:0] hex_display_pre_inv [5:0];


// idk if that is the correct order (as in if the ones digit is on the right side 7seg)
assign hex_display_pre_inv[0][6:0]=hex_display_lut[number[15:12]];
assign hex_display_pre_inv[1][6:0]=hex_display_lut[number[11: 8]];
assign hex_display_pre_inv[2][6:0]=hex_display_lut[number[ 7: 4]];
assign hex_display_pre_inv[3][6:0]=hex_display_lut[number[ 3: 0]];
assign hex_display_pre_inv[4][6:0]=7'b0;
assign hex_display_pre_inv[5][6:0]=7'b0;

assign hex_display_pre_inv[0][7]=1'b0;
assign hex_display_pre_inv[1][7]=1'b0;
assign hex_display_pre_inv[2][7]=1'b0;
assign hex_display_pre_inv[3][7]=1'b0;
assign hex_display_pre_inv[4][7]=1'b0;
assign hex_display_pre_inv[5][7]=1'b0;


assign hex_display[0]=~(hex_display_pre_inv[0]);
assign hex_display[1]=~(hex_display_pre_inv[1]);
assign hex_display[2]=~(hex_display_pre_inv[2]);
assign hex_display[3]=~(hex_display_pre_inv[3]);
assign hex_display[4]=~(hex_display_pre_inv[4]);
assign hex_display[5]=~(hex_display_pre_inv[5]);

endmodule

/*
This is some temporary notes for figuring out how the hex display worked:

		4'h0: oSEG = 0 1 1 1 1 1 1;
		4'h1: oSEG = 0 0 0 0 1 1 0;	
		4'h2: oSEG = 1 0 1 1 0 1 1; 	
		4'h3: oSEG = 1 0 0 1 1 1 1; 	
		4'h4: oSEG = 1 1 0 0 1 1 0; 	
		4'h5: oSEG = 1 1 0 1 1 0 1; 	
		4'h6: oSEG = 1 1 1 1 1 0 1; 	
		4'h7: oSEG = 0 0 0 0 1 1 1; 	
		4'h8: oSEG = 1 1 1 1 1 1 1; 	
		4'h9: oSEG = 1 1 0 0 1 1 1; 
		4'ha: oSEG = 1 1 1 0 1 1 1;
		4'hb: oSEG = 1 1 1 1 1 0 0;
		4'hc: oSEG = 0 1 1 1 0 0 1;
		4'hd: oSEG = 1 0 1 1 1 1 0;
		4'he: oSEG = 1 1 1 1 0 0 1;
		4'hf: oSEG = 1 1 1 0 0 0 1;
		                         ^
 ---t----
 |	    |
 lt	   rt
 |	    |
 ---m----
 |	    |
 lb	   rb
 |	    |
 ---b---d

		
		hex={d,m,lt,lb,b,rb,rt,t}

*/



module core_executer(
	input [15:0] instructionIn,
	input [ 4:0] instructionInID,
	input [25:0] instructionAddress,
	
	input doExecute,
	input willExecute,

	input [15:0] user_reg [15:0],
	input user_reg_wide_or [15:0],
	
	input [15:0] instant_user_reg [15:0],
	input instant_user_reg_wide_or [15:0],
	input instant_user_reg_override_active [15:0],

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


reg [16:0] doWrite;
reg [15:0] writeValues [16:0];
assign doWrite_w=doWrite;
assign writeValues_w=writeValues;

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


assign temporary2=(adderControl1_r +({2'b0,temporary3,1'b1}+{2'b0,temporary4,1'b0}))+{2'b0,temporary5,1'b0};
assign temporary6=temporary2[18:1];


//reg conditional_jump_signal;

always @(posedge main_clk) begin
	vr0<=instant_user_reg_override_active[instructionIn[ 3:0]]?instant_user_reg[instructionIn[ 3:0]]:user_reg[instructionIn[ 3:0]];
	vr1<=instant_user_reg_override_active[instructionIn[ 7:4]]?instant_user_reg[instructionIn[ 7:4]]:user_reg[instructionIn[ 7:4]];
	vr2<=instant_user_reg_override_active[instructionIn[11:8]]?instant_user_reg[instructionIn[11:8]]:user_reg[instructionIn[11:8]];
	
	//conditional_jump_signal<=!(instant_user_reg_override_active[instructionIn[11:8]]?instant_user_reg_wide_or[instructionIn[11:8]]:user_reg_wide_or[instructionIn[11:8]]); // if wide_or is 0 then jump is 1
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
	temporary0[0]=bitwise_lut[{instructionCurrent[13:12],vr2[0],vr1[0]}];
	temporary0[1]=bitwise_lut[{instructionCurrent[13:12],vr2[1],vr1[1]}];
	temporary0[2]=bitwise_lut[{instructionCurrent[13:12],vr2[2],vr1[2]}];
	temporary0[3]=bitwise_lut[{instructionCurrent[13:12],vr2[3],vr1[3]}];
	temporary0[4]=bitwise_lut[{instructionCurrent[13:12],vr2[4],vr1[4]}];
	temporary0[5]=bitwise_lut[{instructionCurrent[13:12],vr2[5],vr1[5]}];
	temporary0[6]=bitwise_lut[{instructionCurrent[13:12],vr2[6],vr1[6]}];
	temporary0[7]=bitwise_lut[{instructionCurrent[13:12],vr2[7],vr1[7]}];
	temporary0[8]=bitwise_lut[{instructionCurrent[13:12],vr2[8],vr1[8]}];
	temporary0[9]=bitwise_lut[{instructionCurrent[13:12],vr2[9],vr1[9]}];
	temporary0[10]=bitwise_lut[{instructionCurrent[13:12],vr2[10],vr1[10]}];
	temporary0[11]=bitwise_lut[{instructionCurrent[13:12],vr2[11],vr1[11]}];
	temporary0[12]=bitwise_lut[{instructionCurrent[13:12],vr2[12],vr1[12]}];
	temporary0[13]=bitwise_lut[{instructionCurrent[13:12],vr2[13],vr1[13]}];
	temporary0[14]=bitwise_lut[{instructionCurrent[13:12],vr2[14],vr1[14]}];
	temporary0[15]=bitwise_lut[{instructionCurrent[13:12],vr2[15],vr1[15]}];
	
	temporary3=vr1;
	temporary4={16{adderControl0_r}} ^ vr2;
	temporary5={16{adderControl2_r}} & (instructionCurrent[15]?user_reg[4'hF]:vr0);
end


always @(posedge main_clk) begin
	adderOutput[15:0]<=temporary6[15:0];
	adderOutput[16]<=(temporary6[17] | temporary6[16])?1'b1:1'b0;
	
	temporary7<=stack_pointer - vr0;
	temporary7[0]<=1'b0;
end

always_comb begin
	temporary1={instructionCurrent[11:4],1'b0} + user_reg[4'h1];
end

reg [31:0] mul32Temp;

reg [15:0] mul16Temp;

reg [16:0] divTemp0;
reg [15:0] divTemp1;
reg [ 2:0] divTemp2;
reg [15:0] divTemp3;
reg [15:0] divTemp4;
reg [15:0] divTemp5;

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


reg [15:0] destinationValue0; // to user_reg[instructionCurrent[3:0]]
reg [15:0] destinationValue1; // to user_reg[instructionCurrent[7:4]]
reg [15:0] destinationValue2; // to user_reg[4'hD]
reg [15:0] destinationValue3; // to user_reg[4'hE]
reg [15:0] destinationValue4; // to user_reg[4'hF]
reg [15:0] destinationValue5; // to stack_pointer
reg [15:0] destinationValue6; // to user_reg[4'h0]
reg [15:0] destinationValue7; // to user_reg[4'h1]

reg doWriteDestinationValue0;
reg doWriteDestinationValue1;
reg doWriteDestinationValue2;
reg doWriteDestinationValue3;
reg doWriteDestinationValue4;
reg doWriteDestinationValue5;
reg doWriteDestinationValue6;
reg doWriteDestinationValue7;

reg [15:0] writeDestinationValue0_target;
reg [15:0] writeDestinationValue1_target;

always_comb begin
	writeDestinationValue0_target[4'h0]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'h0)?1'b1:1'b0;
	writeDestinationValue1_target[4'h0]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'h0)?1'b1:1'b0;
	writeDestinationValue0_target[4'h1]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'h1)?1'b1:1'b0;
	writeDestinationValue1_target[4'h1]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'h1)?1'b1:1'b0;
	writeDestinationValue0_target[4'h2]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'h2)?1'b1:1'b0;
	writeDestinationValue1_target[4'h2]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'h2)?1'b1:1'b0;
	writeDestinationValue0_target[4'h3]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'h3)?1'b1:1'b0;
	writeDestinationValue1_target[4'h3]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'h3)?1'b1:1'b0;
	writeDestinationValue0_target[4'h4]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'h4)?1'b1:1'b0;
	writeDestinationValue1_target[4'h4]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'h4)?1'b1:1'b0;
	writeDestinationValue0_target[4'h5]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'h5)?1'b1:1'b0;
	writeDestinationValue1_target[4'h5]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'h5)?1'b1:1'b0;
	writeDestinationValue0_target[4'h6]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'h6)?1'b1:1'b0;
	writeDestinationValue1_target[4'h6]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'h6)?1'b1:1'b0;
	writeDestinationValue0_target[4'h7]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'h7)?1'b1:1'b0;
	writeDestinationValue1_target[4'h7]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'h7)?1'b1:1'b0;
	writeDestinationValue0_target[4'h8]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'h8)?1'b1:1'b0;
	writeDestinationValue1_target[4'h8]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'h8)?1'b1:1'b0;
	writeDestinationValue0_target[4'h9]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'h9)?1'b1:1'b0;
	writeDestinationValue1_target[4'h9]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'h9)?1'b1:1'b0;
	writeDestinationValue0_target[4'hA]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'hA)?1'b1:1'b0;
	writeDestinationValue1_target[4'hA]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'hA)?1'b1:1'b0;
	writeDestinationValue0_target[4'hB]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'hB)?1'b1:1'b0;
	writeDestinationValue1_target[4'hB]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'hB)?1'b1:1'b0;
	writeDestinationValue0_target[4'hC]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'hC)?1'b1:1'b0;
	writeDestinationValue1_target[4'hC]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'hC)?1'b1:1'b0;
	writeDestinationValue0_target[4'hD]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'hD)?1'b1:1'b0;
	writeDestinationValue1_target[4'hD]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'hD)?1'b1:1'b0;
	writeDestinationValue0_target[4'hE]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'hE)?1'b1:1'b0;
	writeDestinationValue1_target[4'hE]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'hE)?1'b1:1'b0;
	writeDestinationValue0_target[4'hF]=(doWriteDestinationValue0 && instructionCurrent[3:0]==4'hF)?1'b1:1'b0;
	writeDestinationValue1_target[4'hF]=(doWriteDestinationValue1 && instructionCurrent[7:4]==4'hF)?1'b1:1'b0;
end

always_comb begin
	doWrite[0]=(writeDestinationValue0_target[4'h0] || writeDestinationValue1_target[4'h0] || doWriteDestinationValue6)?1'b1:1'b0;
	doWrite[1]=(writeDestinationValue0_target[4'h1] || writeDestinationValue1_target[4'h1] || doWriteDestinationValue7)?1'b1:1'b0;
	
	doWrite[2]=(writeDestinationValue0_target[4'h2] || writeDestinationValue1_target[4'h2])?1'b1:1'b0;
	doWrite[3]=(writeDestinationValue0_target[4'h3] || writeDestinationValue1_target[4'h3])?1'b1:1'b0;
	doWrite[4]=(writeDestinationValue0_target[4'h4] || writeDestinationValue1_target[4'h4])?1'b1:1'b0;
	doWrite[5]=(writeDestinationValue0_target[4'h5] || writeDestinationValue1_target[4'h5])?1'b1:1'b0;
	doWrite[6]=(writeDestinationValue0_target[4'h6] || writeDestinationValue1_target[4'h6])?1'b1:1'b0;
	doWrite[7]=(writeDestinationValue0_target[4'h7] || writeDestinationValue1_target[4'h7])?1'b1:1'b0;
	doWrite[8]=(writeDestinationValue0_target[4'h8] || writeDestinationValue1_target[4'h8])?1'b1:1'b0;
	doWrite[9]=(writeDestinationValue0_target[4'h9] || writeDestinationValue1_target[4'h9])?1'b1:1'b0;
	doWrite[10]=(writeDestinationValue0_target[4'hA] || writeDestinationValue1_target[4'hA])?1'b1:1'b0;
	doWrite[11]=(writeDestinationValue0_target[4'hB] || writeDestinationValue1_target[4'hB])?1'b1:1'b0;
	doWrite[12]=(writeDestinationValue0_target[4'hC] || writeDestinationValue1_target[4'hC])?1'b1:1'b0;
	
	doWrite[13]=(writeDestinationValue0_target[4'hD] || writeDestinationValue1_target[4'hD] || doWriteDestinationValue2)?1'b1:1'b0;
	doWrite[14]=(writeDestinationValue0_target[4'hE] || writeDestinationValue1_target[4'hE] || doWriteDestinationValue3)?1'b1:1'b0;
	doWrite[15]=(writeDestinationValue0_target[4'hF] || writeDestinationValue1_target[4'hF] || doWriteDestinationValue4)?1'b1:1'b0;

	doWrite[16]=(doWriteDestinationValue5)?1'b1:1'b0;
end

always_comb begin
	writeValues[0]=doWriteDestinationValue6?destinationValue6:(writeDestinationValue1_target[4'h0]?destinationValue1:destinationValue0);
	writeValues[1]=doWriteDestinationValue7?destinationValue7:(writeDestinationValue1_target[4'h1]?destinationValue1:destinationValue0);
	
	writeValues[2]=writeDestinationValue1_target[4'h2]?destinationValue1:destinationValue0;
	writeValues[3]=writeDestinationValue1_target[4'h3]?destinationValue1:destinationValue0;
	writeValues[4]=writeDestinationValue1_target[4'h4]?destinationValue1:destinationValue0;
	writeValues[5]=writeDestinationValue1_target[4'h5]?destinationValue1:destinationValue0;
	writeValues[6]=writeDestinationValue1_target[4'h6]?destinationValue1:destinationValue0;
	writeValues[7]=writeDestinationValue1_target[4'h7]?destinationValue1:destinationValue0;
	writeValues[8]=writeDestinationValue1_target[4'h8]?destinationValue1:destinationValue0;
	writeValues[9]=writeDestinationValue1_target[4'h9]?destinationValue1:destinationValue0;
	writeValues[10]=writeDestinationValue1_target[4'hA]?destinationValue1:destinationValue0;
	writeValues[11]=writeDestinationValue1_target[4'hB]?destinationValue1:destinationValue0;
	writeValues[12]=writeDestinationValue1_target[4'hC]?destinationValue1:destinationValue0;
	
	writeValues[13]=doWriteDestinationValue2?destinationValue2:(writeDestinationValue1_target[4'hD]?destinationValue1:destinationValue0);
	writeValues[14]=doWriteDestinationValue3?destinationValue3:(writeDestinationValue1_target[4'hE]?destinationValue1:destinationValue0);
	writeValues[15]=doWriteDestinationValue4?destinationValue4:(writeDestinationValue1_target[4'hF]?destinationValue1:destinationValue0);

	writeValues[16]=destinationValue5;
end




always_comb begin
	mem_is_stack_access_write=0;
	mem_is_stack_access_requesting=0;
	mem_is_general_access_byte_operation=0;
	mem_is_general_access_write=0;
	mem_is_general_access_requesting=0;
	mem_stack_access_size=3'hx;
	mem_target_address_stack=16'hx;
	mem_target_address_general=32'hx;
	mem_data_in='{16'hx,16'hx,16'hx,16'hx};
	instruction_jump_address=32'hx;
	doWriteDestinationValue0=0;
	doWriteDestinationValue1=0;
	doWriteDestinationValue2=0;
	doWriteDestinationValue3=0;
	doWriteDestinationValue4=0;
	doWriteDestinationValue5=0;
	doWriteDestinationValue6=0;
	doWriteDestinationValue7=0;
	destinationValue0=16'hx;
	destinationValue1=16'hx;
	destinationValue2=16'hx;
	destinationValue3=16'hx;
	destinationValue4=16'hx;
	destinationValue5=16'hx;
	destinationValue6=16'hx;
	destinationValue7=16'hx;
	if (doExecute) begin
		unique case (instructionCurrentID)
		0:begin
			destinationValue0={8'h0,instructionCurrent[11:4]};
			doWriteDestinationValue0=1;
		end
		1:begin
			destinationValue0={instructionCurrent[11:4],vr0[7:0]};
			doWriteDestinationValue0=1;
		end
		2:begin
			mem_is_stack_access_write=0;
			mem_stack_access_size=1;
			mem_target_address_stack=temporary1;
			destinationValue0=mem_data_out_large_r[0];
			unique case (step)
			0:begin
				mem_is_stack_access_requesting=1;
			end
			1:begin
				doWriteDestinationValue0=1;
			end
			endcase
		end
		3:begin
			mem_is_stack_access_write=1;
			mem_is_stack_access_requesting=1;
			mem_stack_access_size=1;
			mem_target_address_stack=temporary1;
			mem_data_in[0]=vr0;
		end
		4:begin
			doWriteDestinationValue0=1;
			destinationValue0=temporary0;
		end
		5:begin
			doWriteDestinationValue0=1;
			destinationValue0=temporary0;
		end
		6:begin
			doWriteDestinationValue0=1;
			destinationValue0=temporary0;
		end
		7:begin
			destinationValue1=adderOutput[15:0];
			destinationValue0={15'h0,adderOutput[16]};
			unique case (step)
			0:begin
			end
			1:begin
				doWriteDestinationValue0=1;
				doWriteDestinationValue1=1;
			end
			endcase
		end
		8:begin
			mem_is_general_access_byte_operation=0;
			mem_is_general_access_write=0;
			mem_target_address_general={vr2,vr1};
			mem_target_address_general[0]=1'b0;
			destinationValue0=mem_data_out_small_r;
			unique case (step)
			0:begin
				mem_is_general_access_requesting=1;
			end
			1:begin
				doWriteDestinationValue0=1;
			end
			endcase
		end
		9:begin
			mem_is_general_access_requesting=1;
			mem_is_general_access_byte_operation=0;
			mem_is_general_access_write=1;
			mem_target_address_general={vr2,vr1};
			mem_target_address_general[0]=1'b0;
			mem_data_in[0]=vr0;
		end
		10:begin
			destinationValue0=adderOutput[15:0];
			unique case (step)
			0:begin
			end
			1:begin
				doWriteDestinationValue0=1;
			end
			endcase
		end
		11:begin
			destinationValue4={15'h0,adderOutput[16]};
			destinationValue0=adderOutput[15:0];
			unique case (step)
			0:begin
			end
			1:begin
				doWriteDestinationValue0=1;
				doWriteDestinationValue4=1;
			end
			endcase
		end
		12:begin
			destinationValue0=adderOutput[15:0];
			unique case (step)
			0:begin
			end
			1:begin
				doWriteDestinationValue0=1;
			end
			endcase
		end
		13:begin
			destinationValue0={15'h0,adderOutput[16]};
			unique case (step)
			0:begin
			end
			1:begin
				doWriteDestinationValue0=1;
			end
			endcase
		end
		14:begin
			instruction_jump_address={vr1,vr0};
		end
		16:begin
			mem_is_stack_access_write=1;
			mem_target_address_stack=stack_pointer_m2;
			mem_stack_access_size=1;
			mem_is_stack_access_requesting=1;
			mem_data_in[0]=vr0;
			destinationValue5=stack_pointer_m2;
			if (mem_is_access_acknowledged_pulse) begin
				doWriteDestinationValue5=1;
			end
		end
		17:begin
			mem_is_stack_access_write=1;
			mem_target_address_stack=stack_pointer_m4;
			mem_stack_access_size=2;
			mem_is_stack_access_requesting=1;
			mem_data_in[0]=vr0;
			mem_data_in[1]=vr1;
			destinationValue5=stack_pointer_m4;
			if (mem_is_access_acknowledged_pulse) begin
				doWriteDestinationValue5=1;
			end
		end
		18:begin
			mem_is_stack_access_write=0;
			mem_target_address_stack=stack_pointer;
			mem_stack_access_size=1;
			destinationValue5=stack_pointer_p2;
			destinationValue0=mem_data_out_large_r[0];
			unique case (step)
			0:begin
				mem_is_stack_access_requesting=1;
			end
			1:begin
				doWriteDestinationValue5=1;
				doWriteDestinationValue0=1;
			end
			endcase
		end
		19:begin
			mem_is_stack_access_write=0;
			mem_target_address_stack=stack_pointer;
			mem_stack_access_size=2;
			destinationValue5=stack_pointer_p4;
			destinationValue0=mem_data_out_large_r[0];
			destinationValue1=mem_data_out_large_r[1];
			unique case (step)
			0:begin
				mem_is_stack_access_requesting=1;
			end
			1:begin
				doWriteDestinationValue5=1;
				doWriteDestinationValue0=1;
				doWriteDestinationValue1=1;
			end
			endcase
		end
		20:begin
			destinationValue0=vr1;
			doWriteDestinationValue0=1;
		end
		21:begin
			destinationValue0[ 7:0]=vr1[15:8];
			destinationValue0[15:8]=vr1[ 7:0];
			doWriteDestinationValue0=1;
		end
		22:begin
			destinationValue0={1'b0,vr1[15:1]};
			doWriteDestinationValue0=1;
		end
		23:begin
			destinationValue0=mul16Temp;
			unique case (step)
			0:begin
			end
			1:begin
				doWriteDestinationValue0=1;
			end
			endcase
		end
		24:begin
			destinationValue2=mul32Temp[15: 0];
			destinationValue3=mul32Temp[31:16];
			unique case (step)
			0:begin
			end
			1:begin
				doWriteDestinationValue2=1;
				doWriteDestinationValue3=1;
			end
			endcase
		end
		25:begin
			destinationValue0={divTemp3[15:1],divPartialResult[2]};
			destinationValue1=divTable0[2][15:0];
			unique case (step)
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
				doWriteDestinationValue0=1;
				doWriteDestinationValue1=1;
			end
			endcase
		end
		26:begin
			destinationValue5=stack_pointer_m8;
			destinationValue6=stack_pointer_m8;
			mem_is_stack_access_write=1;
			mem_target_address_stack=stack_pointer_m8;
			mem_stack_access_size=4;
			instruction_jump_address={vr1,vr0};
			mem_data_in[0]={instructionAddress[15:1],1'b0};
			mem_data_in[1]={7'b0,instructionAddress[24:16]};
			mem_data_in[2]=user_reg[4'h1];
			mem_data_in[3]=user_reg[4'h0];
			unique case (step)
			0:begin
				mem_is_stack_access_requesting=1;
			end
			1:begin
				doWriteDestinationValue5=1;
				doWriteDestinationValue6=1;
			end
			endcase
		end
		27:begin
			mem_is_stack_access_write=0;
			mem_target_address_stack=user_reg[4'h0]-4'h8;
			destinationValue5=(user_reg[4'h0]-4'hA) + mem_data_out_large_r[0];
			destinationValue6=mem_data_out_large_r[1];
			destinationValue7=mem_data_out_large_r[2];
			mem_stack_access_size=5;
			instruction_jump_address={mem_data_out_large_r[3],mem_data_out_large_r[4]};
			unique case (step)
			0:begin
				mem_is_stack_access_requesting=1;
			end
			1:begin
				doWriteDestinationValue5=1;
				doWriteDestinationValue6=1;
				doWriteDestinationValue7=1;
			end
			endcase
		end
		28:begin
			mem_is_general_access_byte_operation=1;
			mem_is_general_access_write=0;
			mem_target_address_general={vr1,user_reg[4'hD]};
			destinationValue0=mem_data_out_small_r;
			unique case (step)
			0:begin
				mem_is_general_access_requesting=1;
			end
			1:begin
				doWriteDestinationValue0=1;
			end
			endcase
		end
		29:begin
			mem_is_general_access_byte_operation=1;
			mem_is_general_access_write=1;
			mem_target_address_general={vr1,user_reg[4'hD]};
			mem_is_general_access_requesting=1;
			mem_data_in[0]=vr0;
		end
		30:begin
			instruction_jump_address={vr1,vr0};
		end
		31:begin
			destinationValue0=temporary7;
			destinationValue5=temporary7;
			unique case (step)
			0:begin
			end
			1:begin
				doWriteDestinationValue0=1;
				doWriteDestinationValue5=1;
			end
			endcase
		end
		endcase
	end
	
	// the one's bit of these should always be zero
	mem_target_address_stack[0]=1'b0;
	instruction_jump_address[0]=1'b0;
end

always @(posedge main_clk) begin
	mul16Temp<=vr1*vr0;
	mul32Temp<={vr1,vr0}*{user_reg[4'hE],user_reg[4'hD]};
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
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
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
assign future_sig_helper1b[2]=!(| vr2);

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


//assign will_instruction_finish_next_cycle_pulse=(future_sig_helper[0] | future_sig_helper[1]) & (future_sig_helper[0]?willExecute:1'b1) & (future_sig_helper[1]?mem_will_access_be_acknowledged_pulse:1'b1);
//assign will_jump_next_cycle=(future_sig_helper[2] | future_sig_helper[3]) & (future_sig_helper[2]?willExecute:1'b1) & (future_sig_helper[3]?(!(instant_user_reg_override_active[instructionIn[11:8]]?instant_user_reg_wide_or[instructionIn[11:8]]:user_reg_wide_or[instructionIn[11:8]])):1'b1);


always_comb begin
	future_sig_helper='{0,0,0,0};
	//will_jump_next_cycle=0;
	//will_instruction_finish_next_cycle_pulse=0;
	unique case (instructionInID)
	0:begin
		//will_instruction_finish_next_cycle_pulse=willExecute;
		future_sig_helper[0]=1;
	end
	1:begin
		//will_instruction_finish_next_cycle_pulse=willExecute;
		future_sig_helper[0]=1;
	end
	2:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	3:begin
		//will_instruction_finish_next_cycle_pulse=willExecute & mem_will_access_be_acknowledged_pulse;
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	4:begin
		//will_instruction_finish_next_cycle_pulse=willExecute;
		future_sig_helper[0]=1;
	end
	5:begin
		//will_instruction_finish_next_cycle_pulse=willExecute;
		future_sig_helper[0]=1;
	end
	6:begin
		//will_instruction_finish_next_cycle_pulse=willExecute;
		future_sig_helper[0]=1;
	end
	7:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	8:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	9:begin
		//will_instruction_finish_next_cycle_pulse=willExecute & mem_will_access_be_acknowledged_pulse;
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	10:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	11:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	12:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	13:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	14:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			//will_jump_next_cycle=willExecute & !(instant_user_reg_override_active[instructionIn[11:8]]?instant_user_reg_wide_or[instructionIn[11:8]]:user_reg_wide_or[instructionIn[11:8]]); // if wide_or is 0 then jump is 1
			future_sig_helper[0]=1;
			future_sig_helper[2]=1;
			future_sig_helper[3]=1;
		end
		endcase
	end
	16:begin
		//will_instruction_finish_next_cycle_pulse=willExecute & mem_will_access_be_acknowledged_pulse;
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	17:begin
		//will_instruction_finish_next_cycle_pulse=willExecute & mem_will_access_be_acknowledged_pulse;
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	18:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	19:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	20:begin
		//will_instruction_finish_next_cycle_pulse=willExecute;
		future_sig_helper[0]=1;
	end
	21:begin
		//will_instruction_finish_next_cycle_pulse=willExecute;
		future_sig_helper[0]=1;
	end
	22:begin
		//will_instruction_finish_next_cycle_pulse=willExecute;
		future_sig_helper[0]=1;
	end
	23:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	24:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
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
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	26:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
			//will_jump_next_cycle=willExecute;
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
			//will_instruction_finish_next_cycle_pulse=willExecute;
			//will_jump_next_cycle=willExecute;
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
			//will_instruction_finish_next_cycle_pulse=willExecute;
			future_sig_helper[0]=1;
		end
		endcase
	end
	29:begin
		//will_instruction_finish_next_cycle_pulse=willExecute & mem_will_access_be_acknowledged_pulse;
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	30:begin
		//will_instruction_finish_next_cycle_pulse=willExecute;
		//will_jump_next_cycle=willExecute;
		future_sig_helper[0]=1;
		future_sig_helper[2]=1;
	end
	31:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			//will_instruction_finish_next_cycle_pulse=willExecute;
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
			divTemp2<=vr0[15:13];
			divTemp5<=0;
		end
		1:begin
			divTemp2<=divTemp1[12:10];
			divTemp5<=divTable2[2][15:0];
			divTemp3[15:13]<=divPartialResult;
		end
		2:begin
			divTemp2<=divTemp1[9:7];
			divTemp5<=divTable2[2][15:0];
			divTemp3[12:10]<=divPartialResult;
		end
		3:begin
			divTemp2<=divTemp1[6:4];
			divTemp5<=divTable2[2][15:0];
			divTemp3[9:7]<=divPartialResult;
		end
		4:begin
			divTemp2<=divTemp1[3:1];
			divTemp5<=divTable2[2][15:0];
			divTemp3[6:4]<=divPartialResult;
		end
		5:begin
			divTemp2<={divTemp1[0],2'bxx};
			divTemp5<=divTable2[2][15:0];
			divTemp3[3:1]<=divPartialResult;
		end
		6:begin
			divTemp2<=3'hx;
			divTemp5<=16'hx;
		end
		endcase
	end
end

endmodule



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

	output [7:0] hex_display [5:0],
	
	input 		     [9:0]		SW,

	input vga_clk,
	input main_clk,
	
	output [15:0] debug_user_reg [15:0],
	output [15:0] debug_stack_pointer,
	output [25:0] debug_instruction_fetch_address,
	input debug_scheduler

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

always_comb begin
	orderConflictsAdapted=orderConflictsSaved;
	orderConflictsAdapted[0][0]=1'b1;
	orderConflictsAdapted[1][1]=1'b1;
	orderConflictsAdapted[2][2]=1'b1;
	orderConflictsAdapted[3][3]=1'b1;
end



reg [15:0] stack_pointer=16'h0000;
reg [15:0] stack_pointer_m2=16'hFFFE;
reg [15:0] stack_pointer_m4=16'hFFFC;
reg [15:0] stack_pointer_m6=16'hFFFA;
reg [15:0] stack_pointer_m8=16'hFFF8;

reg [15:0] stack_pointer_p2=16'h0002;
reg [15:0] stack_pointer_p4=16'h0004;

reg [15:0] user_reg [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

wire user_reg_wide_or [15:0];
assign user_reg_wide_or[0]=(| user_reg[0]);
assign user_reg_wide_or[1]=(| user_reg[1]);
assign user_reg_wide_or[2]=(| user_reg[2]);
assign user_reg_wide_or[3]=(| user_reg[3]);
assign user_reg_wide_or[4]=(| user_reg[4]);
assign user_reg_wide_or[5]=(| user_reg[5]);
assign user_reg_wide_or[6]=(| user_reg[6]);
assign user_reg_wide_or[7]=(| user_reg[7]);
assign user_reg_wide_or[8]=(| user_reg[8]);
assign user_reg_wide_or[9]=(| user_reg[9]);
assign user_reg_wide_or[10]=(| user_reg[10]);
assign user_reg_wide_or[11]=(| user_reg[11]);
assign user_reg_wide_or[12]=(| user_reg[12]);
assign user_reg_wide_or[13]=(| user_reg[13]);
assign user_reg_wide_or[14]=(| user_reg[14]);
assign user_reg_wide_or[15]=(| user_reg[15]);



generate_hex_display_base10 generate_hex_display_inst(
	hex_display,
	user_reg[SW[3:0]]
);

reg is_new_instruction_entering_this_cycle_pulse_0; // only valid if `is_performing_jump==0`
reg is_new_instruction_entering_this_cycle_pulse_1; // only valid if `is_performing_jump==0`
reg is_new_instruction_entering_this_cycle_pulse_2; // only valid if `is_performing_jump==0`
reg is_new_instruction_entering_this_cycle_pulse_3; // only valid if `is_performing_jump==0`

wire is_instruction_finishing_this_cycle_pulse_0;
wire is_instruction_finishing_this_cycle_pulse_1;
wire is_instruction_finishing_this_cycle_pulse_2;
wire is_instruction_finishing_this_cycle_pulse_3;

wire will_instruction_finish_next_cycle_pulse_0;
wire will_instruction_finish_next_cycle_pulse_1;
wire will_instruction_finish_next_cycle_pulse_2;
wire will_instruction_finish_next_cycle_pulse_3;

reg [15:0] instructionCurrent_scheduler_0_saved=0;
reg [15:0] instructionCurrent_scheduler_1_saved=0;
reg [15:0] instructionCurrent_scheduler_2_saved=0;
reg [15:0] instructionCurrent_scheduler_3_saved=0;

reg [15:0] instructionCurrent_scheduler_0;
reg [15:0] instructionCurrent_scheduler_1;
reg [15:0] instructionCurrent_scheduler_2;
reg [15:0] instructionCurrent_scheduler_3;

reg executerEnable [3:0]='{0,0,0,0};
reg executerWillBeEnabled [3:0];

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


//assign isInstructionValid_scheduler_0_future2=is_instruction_finishing_this_cycle_pulse_0?1'b0:isInstructionValid_scheduler_0;
//assign isInstructionValid_scheduler_1_future2=is_instruction_finishing_this_cycle_pulse_1?1'b0:isInstructionValid_scheduler_1;
//assign isInstructionValid_scheduler_2_future2=is_instruction_finishing_this_cycle_pulse_2?1'b0:isInstructionValid_scheduler_2;
//assign isInstructionValid_scheduler_3_future2=is_instruction_finishing_this_cycle_pulse_3?1'b0:isInstructionValid_scheduler_3;

always @(posedge main_clk) begin
	isInstructionValid_scheduler_0<=isInstructionValid_scheduler_0_future4;
	isInstructionValid_scheduler_1<=isInstructionValid_scheduler_1_future4;
	isInstructionValid_scheduler_2<=isInstructionValid_scheduler_2_future4;
	isInstructionValid_scheduler_3<=isInstructionValid_scheduler_3_future4;
	
	instructionCurrent_scheduler_0_saved<=instructionCurrent_scheduler_0;
	instructionCurrent_scheduler_1_saved<=instructionCurrent_scheduler_1;
	instructionCurrent_scheduler_2_saved<=instructionCurrent_scheduler_2;
	instructionCurrent_scheduler_3_saved<=instructionCurrent_scheduler_3;
	
	isInstructionValid_scheduler_0_future2<=will_instruction_finish_next_cycle_pulse_0?1'b0:isInstructionValid_scheduler_0_future4;
	isInstructionValid_scheduler_1_future2<=will_instruction_finish_next_cycle_pulse_1?1'b0:isInstructionValid_scheduler_1_future4;
	isInstructionValid_scheduler_2_future2<=will_instruction_finish_next_cycle_pulse_2?1'b0:isInstructionValid_scheduler_2_future4;
	isInstructionValid_scheduler_3_future2<=will_instruction_finish_next_cycle_pulse_3?1'b0:isInstructionValid_scheduler_3_future4;
	
	if (isInstructionValid_scheduler_0_future2 != (is_instruction_finishing_this_cycle_pulse_0?1'b0:isInstructionValid_scheduler_0)) begin $stop(); end
	if (isInstructionValid_scheduler_1_future2 != (is_instruction_finishing_this_cycle_pulse_1?1'b0:isInstructionValid_scheduler_1)) begin $stop(); end
	if (isInstructionValid_scheduler_2_future2 != (is_instruction_finishing_this_cycle_pulse_2?1'b0:isInstructionValid_scheduler_2)) begin $stop(); end
	if (isInstructionValid_scheduler_3_future2 != (is_instruction_finishing_this_cycle_pulse_3?1'b0:isInstructionValid_scheduler_3)) begin $stop(); end
end



reg [25:0] current_instruction_address_table [3:0];


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
wire [2:0] mem_instruction_fetch_returning_word_count=3'd7-mem_target_address_instruction_fetch[3:1];
wire [3:0] mem_instruction_fetch_returning_word_count_actual={1'b0,mem_instruction_fetch_returning_word_count}+1'b1;

wire [15:0] mem_data_out_type_0 [7:0];
wire [15:0] mem_data_out_type_1 [7:0];

reg [25:0] mem_target_address_hyper_instruction_fetch_0;
reg [25:0] mem_target_address_hyper_instruction_fetch_1;

reg  mem_is_hyper_instruction_fetch_0_requesting=0;
wire mem_is_hyper_instruction_fetch_0_acknowledged_pulse;

reg  mem_is_hyper_instruction_fetch_1_requesting=0;
wire mem_is_hyper_instruction_fetch_1_acknowledged_pulse;

reg [15:0] hyper_instruction_fetch_storage [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

reg mem_void_hyper_instruction_fetch=0;

///

reg [15:0] fifo_instruction_cache_data_old [3:0];
reg [15:0] fifo_instruction_cache_data [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
reg [25:0] fifo_instruction_cache_addresses [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

/*
fifo_instruction_cache_data_old[3:0] is (or will be) used for hyper jump and is not included in the size
fifo_instruction_cache_data[3:0]     is used for scheduler
*/


reg [4:0] fifo_instruction_cache_size=0;
reg [4:0] fifo_instruction_cache_size_after_read;
reg [2:0] fifo_instruction_cache_consume_count;
reg [2:0] fifo_instruction_cache_size_converted;


reg [15:0] fifo_instruction_cache_data_at_write_addr_m1;
reg [15:0] fifo_instruction_cache_data_at_write_addr_m2;
reg [15:0] fifo_instruction_cache_data_at_write_addr_m3;
reg [15:0] fifo_instruction_cache_data_at_write_addr_m4;

always_comb begin
	if (fifo_instruction_cache_size_after_read==5'd0)
		fifo_instruction_cache_data_at_write_addr_m1=fifo_instruction_cache_data_old[3];
	else
		fifo_instruction_cache_data_at_write_addr_m1=fifo_instruction_cache_data[fifo_instruction_cache_size_after_read-5'd1];

	if (fifo_instruction_cache_size_after_read <5'd2)
		fifo_instruction_cache_data_at_write_addr_m2=fifo_instruction_cache_data_old[5'd3-fifo_instruction_cache_size_after_read];
	else
		fifo_instruction_cache_data_at_write_addr_m2=fifo_instruction_cache_data[fifo_instruction_cache_size_after_read-5'd2];

	if (fifo_instruction_cache_size_after_read <5'd3)
		fifo_instruction_cache_data_at_write_addr_m3=fifo_instruction_cache_data_old[5'd3-fifo_instruction_cache_size_after_read];
	else
		fifo_instruction_cache_data_at_write_addr_m3=fifo_instruction_cache_data[fifo_instruction_cache_size_after_read-5'd3];

	if (fifo_instruction_cache_size_after_read <5'd4)
		fifo_instruction_cache_data_at_write_addr_m4=fifo_instruction_cache_data_old[5'd3-fifo_instruction_cache_size_after_read];
	else
		fifo_instruction_cache_data_at_write_addr_m4=fifo_instruction_cache_data[fifo_instruction_cache_size_after_read-5'd4];
end


reg is_instruction_cache_requesting=0;
reg [25:0] instruction_fetch_address=0;

wire [1:0] jump_executer_index={jump_signal_executer[2] | jump_signal_executer[3],jump_signal_executer[1] | jump_signal_executer[3]}; // only should be considered valid if there is a single executer doing a jump this cycle

reg is_performing_jump_state=0;
wire is_performing_jump_instant_on=jump_signal_executer[0] | jump_signal_executer[1] | jump_signal_executer[2] | jump_signal_executer[3];
wire is_performing_jump=is_performing_jump_instant_on?1'b1:is_performing_jump_state;

reg [25:0] instruction_jump_address_saved=0;
//wire [25:0] instruction_jump_address=is_performing_jump_instant_on?(instruction_jump_address_executer[jump_executer_index][25:0]):instruction_jump_address_saved;
wire [25:0] instruction_jump_address=is_performing_jump_instant_on?(instruction_jump_address_selected[25:0]):instruction_jump_address_saved;

assign mem_is_instruction_fetch_requesting=is_instruction_cache_requesting;
assign mem_target_address_instruction_fetch=instruction_fetch_address;

reg isWaitingForJump=0;


reg [31:0] hyper_jump_guess_address_table [7:0];
reg [7:0] hyper_jump_guess_source_table [7:0];

reg [31:0] hyper_jump_guess_address_single;
reg [7:0] hyper_jump_guess_source_single;

reg hyper_jump_potentially_valid_type0=0; // type0 is if the hyper_jump_guess_address_saved is ready
reg hyper_jump_potentially_valid_type1=0; // type1 is if either source_table or address_table was just filled
reg hyper_jump_potentially_valid_type2=0; // type2 is if source_table should be used, otherwise address_table should be used
reg [2:0] hyper_jump_look_index;
wire [31:0] hyper_jump_guess_address_calc=hyper_jump_potentially_valid_type2?({user_reg[hyper_jump_guess_source_table[hyper_jump_look_index][7:4]],user_reg[hyper_jump_guess_source_table[hyper_jump_look_index][3:0]]}):(hyper_jump_guess_address_table[hyper_jump_look_index]);

//wire [31:0] hyper_jump_guess_address_calc=hyper_jump_potentially_valid_type2?({user_reg[hyper_jump_guess_source_single[7:4]],user_reg[hyper_jump_guess_source_single[3:0]]}):(hyper_jump_guess_address_single);

reg [31:0] hyper_jump_guess_address_saved;
reg [4:0] hyper_instruction_fetch_size;


always @(posedge main_clk) begin
	instruction_jump_address_saved<=instruction_jump_address;
	instruction_jump_address_saved[0]<=1'b0;
	is_performing_jump_state<=is_performing_jump;
	fifo_instruction_cache_size<=fifo_instruction_cache_size_after_read;
	
	mem_is_hyper_instruction_fetch_0_requesting<=mem_is_hyper_instruction_fetch_0_acknowledged_pulse?1'b0:mem_is_hyper_instruction_fetch_0_requesting;
	mem_is_hyper_instruction_fetch_1_requesting<=mem_is_hyper_instruction_fetch_1_acknowledged_pulse?1'b0:mem_is_hyper_instruction_fetch_1_requesting;
	
	if (mem_void_hyper_instruction_fetch) mem_void_hyper_instruction_fetch<=0;
	
	if (hyper_jump_potentially_valid_type1) begin
		hyper_jump_guess_address_saved<=hyper_jump_guess_address_calc;
		mem_target_address_hyper_instruction_fetch_0<={hyper_jump_guess_address_calc[25:1],1'b0};
		mem_target_address_hyper_instruction_fetch_1<={hyper_jump_guess_address_calc[25:4]+1'b1,4'b0};
		hyper_jump_potentially_valid_type2<=0;
		hyper_jump_potentially_valid_type1<=0;
		hyper_jump_potentially_valid_type0<=1;
		mem_is_hyper_instruction_fetch_0_requesting<=1;
		mem_is_hyper_instruction_fetch_1_requesting<=1;
		hyper_instruction_fetch_size<=0;
	end
	if (mem_is_hyper_instruction_fetch_0_acknowledged_pulse) begin
		hyper_instruction_fetch_size<=hyper_instruction_fetch_size+mem_instruction_fetch_returning_word_count_actual;
		hyper_instruction_fetch_storage[7:0]<=mem_data_out_type_0;
	end else if (mem_is_hyper_instruction_fetch_1_acknowledged_pulse) begin
		hyper_instruction_fetch_size<=hyper_instruction_fetch_size+mem_instruction_fetch_returning_word_count_actual;
		unique case (hyper_instruction_fetch_size)
		1:hyper_instruction_fetch_storage[ 8:1]<=mem_data_out_type_0;
		2:hyper_instruction_fetch_storage[ 9:2]<=mem_data_out_type_0;
		3:hyper_instruction_fetch_storage[10:3]<=mem_data_out_type_0;
		4:hyper_instruction_fetch_storage[11:4]<=mem_data_out_type_0;
		5:hyper_instruction_fetch_storage[12:5]<=mem_data_out_type_0;
		6:hyper_instruction_fetch_storage[13:6]<=mem_data_out_type_0;
		7:hyper_instruction_fetch_storage[14:7]<=mem_data_out_type_0;
		8:hyper_instruction_fetch_storage[15:8]<=mem_data_out_type_0;
		endcase
	end
	
	if (is_performing_jump) fifo_instruction_cache_size<=0;
	
	unique case (fifo_instruction_cache_consume_count)
	0:begin
	end
	1:begin
		fifo_instruction_cache_data_old[2:0]<=fifo_instruction_cache_data_old[3:1];
		fifo_instruction_cache_data_old[3]<=fifo_instruction_cache_data[0];
		fifo_instruction_cache_data[14:0]<=fifo_instruction_cache_data[15:1];
		fifo_instruction_cache_addresses[14:0]<=fifo_instruction_cache_addresses[15:1];
	end
	2:begin
		fifo_instruction_cache_data_old[1:0]<=fifo_instruction_cache_data_old[3:2];
		fifo_instruction_cache_data_old[3:2]<=fifo_instruction_cache_data[1:0];
		fifo_instruction_cache_data[13:0]<=fifo_instruction_cache_data[15:2];
		fifo_instruction_cache_addresses[13:0]<=fifo_instruction_cache_addresses[15:2];
	end
	3:begin
		fifo_instruction_cache_data_old[0]<=fifo_instruction_cache_data_old[3];
		fifo_instruction_cache_data_old[3:1]<=fifo_instruction_cache_data[2:0];
		fifo_instruction_cache_data[12:0]<=fifo_instruction_cache_data[15:3];
		fifo_instruction_cache_addresses[12:0]<=fifo_instruction_cache_addresses[15:3];
	end
	4:begin
		fifo_instruction_cache_data_old[3:0]<=fifo_instruction_cache_data[3:0];
		fifo_instruction_cache_data[11:0]<=fifo_instruction_cache_data[15:4];
		fifo_instruction_cache_addresses[11:0]<=fifo_instruction_cache_addresses[15:4];
	end
	endcase
	
	if (is_instruction_cache_requesting) begin
		if (mem_is_instruction_fetch_acknowledged_pulse) begin
			if (is_performing_jump) begin
				is_performing_jump_state<=0;
				isWaitingForJump<=0;
				instruction_fetch_address<=instruction_jump_address;
				is_instruction_cache_requesting<=1;
			end else begin
				/*
				if (
				(                                                   mem_data_out_type_0[0][15:11]==5'h1F && (mem_data_out_type_0[0][10:8]==3'b010 || mem_data_out_type_0[0][10:8]==3'b011 || mem_data_out_type_0[0][10:8]==3'b110)) ||
				(mem_instruction_fetch_returning_word_count>3'd0 && mem_data_out_type_0[1][15:11]==5'h1F && (mem_data_out_type_0[1][10:8]==3'b010 || mem_data_out_type_0[1][10:8]==3'b011 || mem_data_out_type_0[1][10:8]==3'b110)) ||
				(mem_instruction_fetch_returning_word_count>3'd1 && mem_data_out_type_0[2][15:11]==5'h1F && (mem_data_out_type_0[2][10:8]==3'b010 || mem_data_out_type_0[2][10:8]==3'b011 || mem_data_out_type_0[2][10:8]==3'b110)) ||
				(mem_instruction_fetch_returning_word_count>3'd2 && mem_data_out_type_0[3][15:11]==5'h1F && (mem_data_out_type_0[3][10:8]==3'b010 || mem_data_out_type_0[3][10:8]==3'b011 || mem_data_out_type_0[3][10:8]==3'b110)) ||
				(mem_instruction_fetch_returning_word_count>3'd3 && mem_data_out_type_0[4][15:11]==5'h1F && (mem_data_out_type_0[4][10:8]==3'b010 || mem_data_out_type_0[4][10:8]==3'b011 || mem_data_out_type_0[4][10:8]==3'b110)) ||
				(mem_instruction_fetch_returning_word_count>3'd4 && mem_data_out_type_0[5][15:11]==5'h1F && (mem_data_out_type_0[5][10:8]==3'b010 || mem_data_out_type_0[5][10:8]==3'b011 || mem_data_out_type_0[5][10:8]==3'b110)) ||
				(mem_instruction_fetch_returning_word_count>3'd5 && mem_data_out_type_0[6][15:11]==5'h1F && (mem_data_out_type_0[6][10:8]==3'b010 || mem_data_out_type_0[6][10:8]==3'b011 || mem_data_out_type_0[6][10:8]==3'b110)) ||
				(mem_instruction_fetch_returning_word_count>3'd6 && mem_data_out_type_0[7][15:11]==5'h1F && (mem_data_out_type_0[7][10:8]==3'b010 || mem_data_out_type_0[7][10:8]==3'b011 || mem_data_out_type_0[7][10:8]==3'b110))
				) isWaitingForJump<=1;
				*/
				hyper_jump_guess_source_table[7]<=mem_data_out_type_0[7][7:0];
				hyper_jump_guess_source_table[6]<=mem_data_out_type_0[6][7:0];
				hyper_jump_guess_source_table[5]<=mem_data_out_type_0[5][7:0];
				hyper_jump_guess_source_table[4]<=mem_data_out_type_0[4][7:0];
				hyper_jump_guess_source_table[3]<=mem_data_out_type_0[3][7:0];
				hyper_jump_guess_source_table[2]<=mem_data_out_type_0[2][7:0];
				hyper_jump_guess_source_table[1]<=mem_data_out_type_0[1][7:0];
				hyper_jump_guess_source_table[0]<=mem_data_out_type_0[0][7:0];
				hyper_jump_guess_address_table[7]<={mem_data_out_type_0[6][11:4],mem_data_out_type_0[5][11:4],mem_data_out_type_0[4][11:4],mem_data_out_type_0[3][11:4]};
				hyper_jump_guess_address_table[6]<={mem_data_out_type_0[5][11:4],mem_data_out_type_0[4][11:4],mem_data_out_type_0[3][11:4],mem_data_out_type_0[2][11:4]};
				hyper_jump_guess_address_table[5]<={mem_data_out_type_0[4][11:4],mem_data_out_type_0[3][11:4],mem_data_out_type_0[2][11:4],mem_data_out_type_0[1][11:4]};
				hyper_jump_guess_address_table[4]<={mem_data_out_type_0[3][11:4],mem_data_out_type_0[2][11:4],mem_data_out_type_0[1][11:4],mem_data_out_type_0[0][11:4]};
				hyper_jump_guess_address_table[3]<={mem_data_out_type_0[2][11:4],mem_data_out_type_0[1][11:4],mem_data_out_type_0[0][11:4],fifo_instruction_cache_data_at_write_addr_m1[11:4]};
				hyper_jump_guess_address_table[2]<={mem_data_out_type_0[1][11:4],mem_data_out_type_0[0][11:4],fifo_instruction_cache_data_at_write_addr_m1[11:4],fifo_instruction_cache_data_at_write_addr_m2[11:4]};
				hyper_jump_guess_address_table[1]<={mem_data_out_type_0[0][11:4],fifo_instruction_cache_data_at_write_addr_m1[11:4],fifo_instruction_cache_data_at_write_addr_m2[11:4],fifo_instruction_cache_data_at_write_addr_m3[11:4]};
				hyper_jump_guess_address_table[0]<={fifo_instruction_cache_data_at_write_addr_m1[11:4],fifo_instruction_cache_data_at_write_addr_m2[11:4],fifo_instruction_cache_data_at_write_addr_m3[11:4],fifo_instruction_cache_data_at_write_addr_m4[11:4]};
				hyper_jump_potentially_valid_type2<=0;
				hyper_jump_potentially_valid_type1<=0;
				hyper_jump_potentially_valid_type0<=0;
				mem_is_hyper_instruction_fetch_0_requesting<=0;
				mem_is_hyper_instruction_fetch_1_requesting<=0;
				mem_void_hyper_instruction_fetch<=1;
				hyper_jump_look_index<=3'hx;
				hyper_jump_guess_address_single<=32'hx;
				hyper_jump_guess_source_single<=8'hx;
				
				if (mem_instruction_fetch_returning_word_count>3'd6) begin
					fifo_instruction_cache_data[fifo_instruction_cache_size_after_read+4'h7]<=mem_data_out_type_0[7];
					fifo_instruction_cache_addresses[fifo_instruction_cache_size_after_read+4'h7]<=instruction_fetch_address+6'hE;
					if (mem_data_out_type_0[7][15:11]==5'h1F && (mem_data_out_type_0[7][10:8]==3'b010 || mem_data_out_type_0[7][10:8]==3'b011 || mem_data_out_type_0[7][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[7][10:8]!=3'b011) begin
							if (mem_data_out_type_0[6][15:13]==3'h0 && mem_data_out_type_0[5][15:13]==3'h0 && mem_data_out_type_0[4][15:13]==3'h0 && mem_data_out_type_0[3][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=7;
							hyper_jump_guess_address_single<={mem_data_out_type_0[6][11:4],mem_data_out_type_0[5][11:4],mem_data_out_type_0[4][11:4],mem_data_out_type_0[3][11:4]};
							hyper_jump_guess_source_single<=mem_data_out_type_0[7][7:0];
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (mem_instruction_fetch_returning_word_count>3'd5) begin
					fifo_instruction_cache_data[fifo_instruction_cache_size_after_read+4'h6]<=mem_data_out_type_0[6];
					fifo_instruction_cache_addresses[fifo_instruction_cache_size_after_read+4'h6]<=instruction_fetch_address+6'hC;
					if (mem_data_out_type_0[6][15:11]==5'h1F && (mem_data_out_type_0[6][10:8]==3'b010 || mem_data_out_type_0[6][10:8]==3'b011 || mem_data_out_type_0[6][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[6][10:8]!=3'b011) begin
							if (mem_data_out_type_0[5][15:13]==3'h0 && mem_data_out_type_0[4][15:13]==3'h0 && mem_data_out_type_0[3][15:13]==3'h0 && mem_data_out_type_0[2][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=6;
							hyper_jump_guess_address_single<={mem_data_out_type_0[5][11:4],mem_data_out_type_0[4][11:4],mem_data_out_type_0[3][11:4],mem_data_out_type_0[2][11:4]};
							hyper_jump_guess_source_single<=mem_data_out_type_0[6][7:0];
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (mem_instruction_fetch_returning_word_count>3'd4) begin
					fifo_instruction_cache_data[fifo_instruction_cache_size_after_read+4'h5]<=mem_data_out_type_0[5];
					fifo_instruction_cache_addresses[fifo_instruction_cache_size_after_read+4'h5]<=instruction_fetch_address+6'hA;
					if (mem_data_out_type_0[5][15:11]==5'h1F && (mem_data_out_type_0[5][10:8]==3'b010 || mem_data_out_type_0[5][10:8]==3'b011 || mem_data_out_type_0[5][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[5][10:8]!=3'b011) begin
							if (mem_data_out_type_0[4][15:13]==3'h0 && mem_data_out_type_0[3][15:13]==3'h0 && mem_data_out_type_0[2][15:13]==3'h0 && mem_data_out_type_0[1][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=5;
							hyper_jump_guess_address_single<={mem_data_out_type_0[4][11:4],mem_data_out_type_0[3][11:4],mem_data_out_type_0[2][11:4],mem_data_out_type_0[1][11:4]};
							hyper_jump_guess_source_single<=mem_data_out_type_0[5][7:0];
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (mem_instruction_fetch_returning_word_count>3'd3) begin
					fifo_instruction_cache_data[fifo_instruction_cache_size_after_read+4'h4]<=mem_data_out_type_0[4];
					fifo_instruction_cache_addresses[fifo_instruction_cache_size_after_read+4'h4]<=instruction_fetch_address+6'h8;
					if (mem_data_out_type_0[4][15:11]==5'h1F && (mem_data_out_type_0[4][10:8]==3'b010 || mem_data_out_type_0[4][10:8]==3'b011 || mem_data_out_type_0[4][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[4][10:8]!=3'b011) begin
							if (mem_data_out_type_0[3][15:13]==3'h0 && mem_data_out_type_0[2][15:13]==3'h0 && mem_data_out_type_0[1][15:13]==3'h0 && mem_data_out_type_0[0][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=4;
							hyper_jump_guess_address_single<={mem_data_out_type_0[3][11:4],mem_data_out_type_0[2][11:4],mem_data_out_type_0[1][11:4],mem_data_out_type_0[0][11:4]};
							hyper_jump_guess_source_single<=mem_data_out_type_0[4][7:0];
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (mem_instruction_fetch_returning_word_count>3'd2) begin
					fifo_instruction_cache_data[fifo_instruction_cache_size_after_read+4'h3]<=mem_data_out_type_0[3];
					fifo_instruction_cache_addresses[fifo_instruction_cache_size_after_read+4'h3]<=instruction_fetch_address+6'h6;
					if (mem_data_out_type_0[3][15:11]==5'h1F && (mem_data_out_type_0[3][10:8]==3'b010 || mem_data_out_type_0[3][10:8]==3'b011 || mem_data_out_type_0[3][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[3][10:8]!=3'b011) begin
							if (mem_data_out_type_0[2][15:13]==3'h0 && mem_data_out_type_0[1][15:13]==3'h0 && mem_data_out_type_0[0][15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m1[15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=3;
							hyper_jump_guess_address_single<={mem_data_out_type_0[2][11:4],mem_data_out_type_0[1][11:4],mem_data_out_type_0[0][11:4],fifo_instruction_cache_data_at_write_addr_m1[11:4]};
							hyper_jump_guess_source_single<=mem_data_out_type_0[3][7:0];
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (mem_instruction_fetch_returning_word_count>3'd1) begin
					fifo_instruction_cache_data[fifo_instruction_cache_size_after_read+4'h2]<=mem_data_out_type_0[2];
					fifo_instruction_cache_addresses[fifo_instruction_cache_size_after_read+4'h2]<=instruction_fetch_address+6'h4;
					if (mem_data_out_type_0[2][15:11]==5'h1F && (mem_data_out_type_0[2][10:8]==3'b010 || mem_data_out_type_0[2][10:8]==3'b011 || mem_data_out_type_0[2][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[2][10:8]!=3'b011) begin
							if (mem_data_out_type_0[1][15:13]==3'h0 && mem_data_out_type_0[0][15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m1[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m2[15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=2;
							hyper_jump_guess_address_single<={mem_data_out_type_0[1][11:4],mem_data_out_type_0[0][11:4],fifo_instruction_cache_data_at_write_addr_m1[11:4],fifo_instruction_cache_data_at_write_addr_m2[11:4]};
							hyper_jump_guess_source_single<=mem_data_out_type_0[2][7:0];
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (mem_instruction_fetch_returning_word_count>3'd0) begin
					fifo_instruction_cache_data[fifo_instruction_cache_size_after_read+4'h1]<=mem_data_out_type_0[1];
					fifo_instruction_cache_addresses[fifo_instruction_cache_size_after_read+4'h1]<=instruction_fetch_address+6'h2;
					if (mem_data_out_type_0[1][15:11]==5'h1F && (mem_data_out_type_0[1][10:8]==3'b010 || mem_data_out_type_0[1][10:8]==3'b011 || mem_data_out_type_0[1][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[1][10:8]!=3'b011) begin
							if (mem_data_out_type_0[0][15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m1[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m2[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m3[15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=1;
							hyper_jump_guess_address_single<={mem_data_out_type_0[0][11:4],fifo_instruction_cache_data_at_write_addr_m1[11:4],fifo_instruction_cache_data_at_write_addr_m2[11:4],fifo_instruction_cache_data_at_write_addr_m3[11:4]};
							hyper_jump_guess_source_single<=mem_data_out_type_0[1][7:0];
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
					fifo_instruction_cache_data[fifo_instruction_cache_size_after_read+4'h0]<=mem_data_out_type_0[0];
					fifo_instruction_cache_addresses[fifo_instruction_cache_size_after_read+4'h0]<=instruction_fetch_address+6'h0;
					if (mem_data_out_type_0[0][15:11]==5'h1F && (mem_data_out_type_0[0][10:8]==3'b010 || mem_data_out_type_0[0][10:8]==3'b011 || mem_data_out_type_0[0][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[0][10:8]!=3'b011) begin
							if (fifo_instruction_cache_data_at_write_addr_m1[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m2[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m3[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m4[15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=0;
							hyper_jump_guess_address_single<={fifo_instruction_cache_data_at_write_addr_m1[11:4],fifo_instruction_cache_data_at_write_addr_m2[11:4],fifo_instruction_cache_data_at_write_addr_m3[11:4],fifo_instruction_cache_data_at_write_addr_m4[11:4]};
							hyper_jump_guess_source_single<=mem_data_out_type_0[0][7:0];
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				
				fifo_instruction_cache_size<=fifo_instruction_cache_size_after_read+mem_instruction_fetch_returning_word_count_actual;
				instruction_fetch_address<=instruction_fetch_address+{mem_instruction_fetch_returning_word_count_actual,1'b0};
				is_instruction_cache_requesting<=0;
			end
		end
	end else begin
		if (is_performing_jump) begin
			is_performing_jump_state<=0;
			isWaitingForJump<=0;
			mem_is_hyper_instruction_fetch_0_requesting<=0;
			mem_is_hyper_instruction_fetch_1_requesting<=0;
			mem_void_hyper_instruction_fetch<=1;
			hyper_jump_potentially_valid_type2<=0;
			hyper_jump_potentially_valid_type1<=0;
			hyper_jump_potentially_valid_type0<=0;
			hyper_instruction_fetch_size<=0;
			
			if (hyper_jump_potentially_valid_type0 && !mem_is_hyper_instruction_fetch_0_requesting && instruction_jump_address[25:1]==hyper_jump_guess_address_saved[25:1]) begin
				instruction_fetch_address<={hyper_jump_guess_address_saved[25:1]+hyper_instruction_fetch_size,1'b0};
				fifo_instruction_cache_size<=hyper_instruction_fetch_size;
				fifo_instruction_cache_addresses[0]<=hyper_jump_guess_address_saved[25:0]+{4'h0,1'b0};
				fifo_instruction_cache_addresses[1]<=hyper_jump_guess_address_saved[25:0]+{4'h1,1'b0};
				fifo_instruction_cache_addresses[2]<=hyper_jump_guess_address_saved[25:0]+{4'h2,1'b0};
				fifo_instruction_cache_addresses[3]<=hyper_jump_guess_address_saved[25:0]+{4'h3,1'b0};
				fifo_instruction_cache_addresses[4]<=hyper_jump_guess_address_saved[25:0]+{4'h4,1'b0};
				fifo_instruction_cache_addresses[5]<=hyper_jump_guess_address_saved[25:0]+{4'h5,1'b0};
				fifo_instruction_cache_addresses[6]<=hyper_jump_guess_address_saved[25:0]+{4'h6,1'b0};
				fifo_instruction_cache_addresses[7]<=hyper_jump_guess_address_saved[25:0]+{4'h7,1'b0};
				fifo_instruction_cache_addresses[8]<=hyper_jump_guess_address_saved[25:0]+{4'h8,1'b0};
				fifo_instruction_cache_addresses[9]<=hyper_jump_guess_address_saved[25:0]+{4'h9,1'b0};
				fifo_instruction_cache_addresses[10]<=hyper_jump_guess_address_saved[25:0]+{4'hA,1'b0};
				fifo_instruction_cache_addresses[11]<=hyper_jump_guess_address_saved[25:0]+{4'hB,1'b0};
				fifo_instruction_cache_addresses[12]<=hyper_jump_guess_address_saved[25:0]+{4'hC,1'b0};
				fifo_instruction_cache_addresses[13]<=hyper_jump_guess_address_saved[25:0]+{4'hD,1'b0};
				fifo_instruction_cache_addresses[14]<=hyper_jump_guess_address_saved[25:0]+{4'hE,1'b0};
				fifo_instruction_cache_addresses[15]<=hyper_jump_guess_address_saved[25:0]+{4'hF,1'b0};
				
				fifo_instruction_cache_data[15:0]<=hyper_instruction_fetch_storage[15:0]; // todo: do jump analysis on this data
			end else begin
				instruction_fetch_address<=instruction_jump_address;
				is_instruction_cache_requesting<=1;
			end
		end else if (({1'b0,fifo_instruction_cache_size_after_read}+(5'd8-instruction_fetch_address[4:1]))<5'h10 && !isWaitingForJump) begin
			is_instruction_cache_requesting<=1;
		end
	end
	instruction_fetch_address[0]<=1'b0;
	hyper_jump_guess_address_saved[0]<=1'b0;
	mem_target_address_hyper_instruction_fetch_0[0]<=1'b0;
	mem_target_address_hyper_instruction_fetch_1[0]<=1'b0;
	fifo_instruction_cache_addresses[0][0]<=1'b0;
	fifo_instruction_cache_addresses[1][0]<=1'b0;
	fifo_instruction_cache_addresses[2][0]<=1'b0;
	fifo_instruction_cache_addresses[3][0]<=1'b0;
	fifo_instruction_cache_addresses[4][0]<=1'b0;
	fifo_instruction_cache_addresses[5][0]<=1'b0;
	fifo_instruction_cache_addresses[6][0]<=1'b0;
	fifo_instruction_cache_addresses[7][0]<=1'b0;
	fifo_instruction_cache_addresses[8][0]<=1'b0;
	fifo_instruction_cache_addresses[9][0]<=1'b0;
	fifo_instruction_cache_addresses[10][0]<=1'b0;
	fifo_instruction_cache_addresses[11][0]<=1'b0;
	fifo_instruction_cache_addresses[12][0]<=1'b0;
	fifo_instruction_cache_addresses[13][0]<=1'b0;
	fifo_instruction_cache_addresses[14][0]<=1'b0;
	fifo_instruction_cache_addresses[15][0]<=1'b0;
end

reg [4:0] instructionCurrentID_scheduler_0;
reg [4:0] instructionCurrentID_scheduler_1;
reg [4:0] instructionCurrentID_scheduler_2;
reg [4:0] instructionCurrentID_scheduler_3;

reg [1:0] new_instruction_index0;
reg [1:0] new_instruction_index1;
reg [1:0] new_instruction_index2;
reg [1:0] new_instruction_index3;

wire [15:0] new_instruction_table [3:0];
assign new_instruction_table[0]=fifo_instruction_cache_data[0];
assign new_instruction_table[1]=fifo_instruction_cache_data[1];
assign new_instruction_table[2]=fifo_instruction_cache_data[2];
assign new_instruction_table[3]=fifo_instruction_cache_data[3];

wire [25:0] new_instruction_address_table [3:0];
assign new_instruction_address_table[0]=fifo_instruction_cache_addresses[0];
assign new_instruction_address_table[1]=fifo_instruction_cache_addresses[1];
assign new_instruction_address_table[2]=fifo_instruction_cache_addresses[2];
assign new_instruction_address_table[3]=fifo_instruction_cache_addresses[3];

wire [4:0] new_instructionID_table [3:0];
assign new_instructionID_table[0]=(& new_instruction_table[0][15:12])?{1'b1,new_instruction_table[0][11:8]}:{1'b0,new_instruction_table[0][15:12]};
assign new_instructionID_table[1]=(& new_instruction_table[1][15:12])?{1'b1,new_instruction_table[1][11:8]}:{1'b0,new_instruction_table[1][15:12]};
assign new_instructionID_table[2]=(& new_instruction_table[2][15:12])?{1'b1,new_instruction_table[2][11:8]}:{1'b0,new_instruction_table[2][15:12]};
assign new_instructionID_table[3]=(& new_instruction_table[3][15:12])?{1'b1,new_instruction_table[3][11:8]}:{1'b0,new_instruction_table[3][15:12]};

wire [4:0] current_instructionID_table [3:0];
assign current_instructionID_table[0]=(& instructionCurrent_scheduler_0_saved[15:12])?{1'b1,instructionCurrent_scheduler_0_saved[11:8]}:{1'b0,instructionCurrent_scheduler_0_saved[15:12]};
assign current_instructionID_table[1]=(& instructionCurrent_scheduler_1_saved[15:12])?{1'b1,instructionCurrent_scheduler_1_saved[11:8]}:{1'b0,instructionCurrent_scheduler_1_saved[15:12]};
assign current_instructionID_table[2]=(& instructionCurrent_scheduler_2_saved[15:12])?{1'b1,instructionCurrent_scheduler_2_saved[11:8]}:{1'b0,instructionCurrent_scheduler_2_saved[15:12]};
assign current_instructionID_table[3]=(& instructionCurrent_scheduler_3_saved[15:12])?{1'b1,instructionCurrent_scheduler_3_saved[11:8]}:{1'b0,instructionCurrent_scheduler_3_saved[15:12]};


reg [13:0] instructionCurrentIDisCatagoryNext [3:0];
reg [13:0] instructionCurrentIDisCatagory [3:0]='{0,0,0,0};
wire [13:0] instructionFutureIDisCatagory [3:0];

always @(posedge main_clk) instructionCurrentIDisCatagory<=instructionCurrentIDisCatagoryNext;

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
	
	instructionCurrentIDisCatagoryNext[0]=is_new_instruction_entering_this_cycle_pulse_0?instructionFutureIDisCatagory[new_instruction_index0]:({14{!is_instruction_finishing_this_cycle_pulse_0}} & instructionCurrentIDisCatagory[0]);
	instructionCurrentIDisCatagoryNext[1]=is_new_instruction_entering_this_cycle_pulse_1?instructionFutureIDisCatagory[new_instruction_index1]:({14{!is_instruction_finishing_this_cycle_pulse_1}} & instructionCurrentIDisCatagory[1]);
	instructionCurrentIDisCatagoryNext[2]=is_new_instruction_entering_this_cycle_pulse_2?instructionFutureIDisCatagory[new_instruction_index2]:({14{!is_instruction_finishing_this_cycle_pulse_2}} & instructionCurrentIDisCatagory[2]);
	instructionCurrentIDisCatagoryNext[3]=is_new_instruction_entering_this_cycle_pulse_3?instructionFutureIDisCatagory[new_instruction_index3]:({14{!is_instruction_finishing_this_cycle_pulse_3}} & instructionCurrentIDisCatagory[3]);
	
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



reg executerDoWrite [16:0];
reg [15:0] executerWriteValuesSelected [16:0];
reg executerWriteWideOrSelected [15:0];

always_comb begin
	executerDoWrite[0]=(executer3DoWrite[0] | executer2DoWrite[0] | executer1DoWrite[0] | executer0DoWrite[0])?1'b1:1'b0;
	executerDoWrite[1]=(executer3DoWrite[1] | executer2DoWrite[1] | executer1DoWrite[1] | executer0DoWrite[1])?1'b1:1'b0;
	executerDoWrite[2]=(executer3DoWrite[2] | executer2DoWrite[2] | executer1DoWrite[2] | executer0DoWrite[2])?1'b1:1'b0;
	executerDoWrite[3]=(executer3DoWrite[3] | executer2DoWrite[3] | executer1DoWrite[3] | executer0DoWrite[3])?1'b1:1'b0;
	executerDoWrite[4]=(executer3DoWrite[4] | executer2DoWrite[4] | executer1DoWrite[4] | executer0DoWrite[4])?1'b1:1'b0;
	executerDoWrite[5]=(executer3DoWrite[5] | executer2DoWrite[5] | executer1DoWrite[5] | executer0DoWrite[5])?1'b1:1'b0;
	executerDoWrite[6]=(executer3DoWrite[6] | executer2DoWrite[6] | executer1DoWrite[6] | executer0DoWrite[6])?1'b1:1'b0;
	executerDoWrite[7]=(executer3DoWrite[7] | executer2DoWrite[7] | executer1DoWrite[7] | executer0DoWrite[7])?1'b1:1'b0;
	executerDoWrite[8]=(executer3DoWrite[8] | executer2DoWrite[8] | executer1DoWrite[8] | executer0DoWrite[8])?1'b1:1'b0;
	executerDoWrite[9]=(executer3DoWrite[9] | executer2DoWrite[9] | executer1DoWrite[9] | executer0DoWrite[9])?1'b1:1'b0;
	executerDoWrite[10]=(executer3DoWrite[10] | executer2DoWrite[10] | executer1DoWrite[10] | executer0DoWrite[10])?1'b1:1'b0;
	executerDoWrite[11]=(executer3DoWrite[11] | executer2DoWrite[11] | executer1DoWrite[11] | executer0DoWrite[11])?1'b1:1'b0;
	executerDoWrite[12]=(executer3DoWrite[12] | executer2DoWrite[12] | executer1DoWrite[12] | executer0DoWrite[12])?1'b1:1'b0;
	executerDoWrite[13]=(executer3DoWrite[13] | executer2DoWrite[13] | executer1DoWrite[13] | executer0DoWrite[13])?1'b1:1'b0;
	executerDoWrite[14]=(executer3DoWrite[14] | executer2DoWrite[14] | executer1DoWrite[14] | executer0DoWrite[14])?1'b1:1'b0;
	executerDoWrite[15]=(executer3DoWrite[15] | executer2DoWrite[15] | executer1DoWrite[15] | executer0DoWrite[15])?1'b1:1'b0;
	executerDoWrite[16]=(executer3DoWrite[16] | executer2DoWrite[16] | executer1DoWrite[16] | executer0DoWrite[16])?1'b1:1'b0;
end

always_comb begin
	executerWriteValuesSelected[0]=(executer0WriteValues[0] & {16{executer0DoWrite[0]}}) | (executer1WriteValues[0] & {16{executer1DoWrite[0]}}) | (executer2WriteValues[0] & {16{executer2DoWrite[0]}}) | (executer3WriteValues[0] & {16{executer3DoWrite[0]}});
	executerWriteValuesSelected[1]=(executer0WriteValues[1] & {16{executer0DoWrite[1]}}) | (executer1WriteValues[1] & {16{executer1DoWrite[1]}}) | (executer2WriteValues[1] & {16{executer2DoWrite[1]}}) | (executer3WriteValues[1] & {16{executer3DoWrite[1]}});
	executerWriteValuesSelected[2]=(executer0WriteValues[2] & {16{executer0DoWrite[2]}}) | (executer1WriteValues[2] & {16{executer1DoWrite[2]}}) | (executer2WriteValues[2] & {16{executer2DoWrite[2]}}) | (executer3WriteValues[2] & {16{executer3DoWrite[2]}});
	executerWriteValuesSelected[3]=(executer0WriteValues[3] & {16{executer0DoWrite[3]}}) | (executer1WriteValues[3] & {16{executer1DoWrite[3]}}) | (executer2WriteValues[3] & {16{executer2DoWrite[3]}}) | (executer3WriteValues[3] & {16{executer3DoWrite[3]}});
	executerWriteValuesSelected[4]=(executer0WriteValues[4] & {16{executer0DoWrite[4]}}) | (executer1WriteValues[4] & {16{executer1DoWrite[4]}}) | (executer2WriteValues[4] & {16{executer2DoWrite[4]}}) | (executer3WriteValues[4] & {16{executer3DoWrite[4]}});
	executerWriteValuesSelected[5]=(executer0WriteValues[5] & {16{executer0DoWrite[5]}}) | (executer1WriteValues[5] & {16{executer1DoWrite[5]}}) | (executer2WriteValues[5] & {16{executer2DoWrite[5]}}) | (executer3WriteValues[5] & {16{executer3DoWrite[5]}});
	executerWriteValuesSelected[6]=(executer0WriteValues[6] & {16{executer0DoWrite[6]}}) | (executer1WriteValues[6] & {16{executer1DoWrite[6]}}) | (executer2WriteValues[6] & {16{executer2DoWrite[6]}}) | (executer3WriteValues[6] & {16{executer3DoWrite[6]}});
	executerWriteValuesSelected[7]=(executer0WriteValues[7] & {16{executer0DoWrite[7]}}) | (executer1WriteValues[7] & {16{executer1DoWrite[7]}}) | (executer2WriteValues[7] & {16{executer2DoWrite[7]}}) | (executer3WriteValues[7] & {16{executer3DoWrite[7]}});
	executerWriteValuesSelected[8]=(executer0WriteValues[8] & {16{executer0DoWrite[8]}}) | (executer1WriteValues[8] & {16{executer1DoWrite[8]}}) | (executer2WriteValues[8] & {16{executer2DoWrite[8]}}) | (executer3WriteValues[8] & {16{executer3DoWrite[8]}});
	executerWriteValuesSelected[9]=(executer0WriteValues[9] & {16{executer0DoWrite[9]}}) | (executer1WriteValues[9] & {16{executer1DoWrite[9]}}) | (executer2WriteValues[9] & {16{executer2DoWrite[9]}}) | (executer3WriteValues[9] & {16{executer3DoWrite[9]}});
	executerWriteValuesSelected[10]=(executer0WriteValues[10] & {16{executer0DoWrite[10]}}) | (executer1WriteValues[10] & {16{executer1DoWrite[10]}}) | (executer2WriteValues[10] & {16{executer2DoWrite[10]}}) | (executer3WriteValues[10] & {16{executer3DoWrite[10]}});
	executerWriteValuesSelected[11]=(executer0WriteValues[11] & {16{executer0DoWrite[11]}}) | (executer1WriteValues[11] & {16{executer1DoWrite[11]}}) | (executer2WriteValues[11] & {16{executer2DoWrite[11]}}) | (executer3WriteValues[11] & {16{executer3DoWrite[11]}});
	executerWriteValuesSelected[12]=(executer0WriteValues[12] & {16{executer0DoWrite[12]}}) | (executer1WriteValues[12] & {16{executer1DoWrite[12]}}) | (executer2WriteValues[12] & {16{executer2DoWrite[12]}}) | (executer3WriteValues[12] & {16{executer3DoWrite[12]}});
	executerWriteValuesSelected[13]=(executer0WriteValues[13] & {16{executer0DoWrite[13]}}) | (executer1WriteValues[13] & {16{executer1DoWrite[13]}}) | (executer2WriteValues[13] & {16{executer2DoWrite[13]}}) | (executer3WriteValues[13] & {16{executer3DoWrite[13]}});
	executerWriteValuesSelected[14]=(executer0WriteValues[14] & {16{executer0DoWrite[14]}}) | (executer1WriteValues[14] & {16{executer1DoWrite[14]}}) | (executer2WriteValues[14] & {16{executer2DoWrite[14]}}) | (executer3WriteValues[14] & {16{executer3DoWrite[14]}});
	executerWriteValuesSelected[15]=(executer0WriteValues[15] & {16{executer0DoWrite[15]}}) | (executer1WriteValues[15] & {16{executer1DoWrite[15]}}) | (executer2WriteValues[15] & {16{executer2DoWrite[15]}}) | (executer3WriteValues[15] & {16{executer3DoWrite[15]}});
	executerWriteValuesSelected[16]=(executer0WriteValues[16] & {16{executer0DoWrite[16]}}) | (executer1WriteValues[16] & {16{executer1DoWrite[16]}}) | (executer2WriteValues[16] & {16{executer2DoWrite[16]}}) | (executer3WriteValues[16] & {16{executer3DoWrite[16]}});
end

always_comb begin
	executerWriteWideOrSelected[0]=((|(executer0WriteValues[0])) & executer0DoWrite[0]) | ((|(executer1WriteValues[0])) & executer1DoWrite[0]) | ((|(executer2WriteValues[0])) & executer2DoWrite[0]) | ((|(executer3WriteValues[0])) & executer3DoWrite[0]);
	executerWriteWideOrSelected[1]=((|(executer0WriteValues[1])) & executer0DoWrite[1]) | ((|(executer1WriteValues[1])) & executer1DoWrite[1]) | ((|(executer2WriteValues[1])) & executer2DoWrite[1]) | ((|(executer3WriteValues[1])) & executer3DoWrite[1]);
	executerWriteWideOrSelected[2]=((|(executer0WriteValues[2])) & executer0DoWrite[2]) | ((|(executer1WriteValues[2])) & executer1DoWrite[2]) | ((|(executer2WriteValues[2])) & executer2DoWrite[2]) | ((|(executer3WriteValues[2])) & executer3DoWrite[2]);
	executerWriteWideOrSelected[3]=((|(executer0WriteValues[3])) & executer0DoWrite[3]) | ((|(executer1WriteValues[3])) & executer1DoWrite[3]) | ((|(executer2WriteValues[3])) & executer2DoWrite[3]) | ((|(executer3WriteValues[3])) & executer3DoWrite[3]);
	executerWriteWideOrSelected[4]=((|(executer0WriteValues[4])) & executer0DoWrite[4]) | ((|(executer1WriteValues[4])) & executer1DoWrite[4]) | ((|(executer2WriteValues[4])) & executer2DoWrite[4]) | ((|(executer3WriteValues[4])) & executer3DoWrite[4]);
	executerWriteWideOrSelected[5]=((|(executer0WriteValues[5])) & executer0DoWrite[5]) | ((|(executer1WriteValues[5])) & executer1DoWrite[5]) | ((|(executer2WriteValues[5])) & executer2DoWrite[5]) | ((|(executer3WriteValues[5])) & executer3DoWrite[5]);
	executerWriteWideOrSelected[6]=((|(executer0WriteValues[6])) & executer0DoWrite[6]) | ((|(executer1WriteValues[6])) & executer1DoWrite[6]) | ((|(executer2WriteValues[6])) & executer2DoWrite[6]) | ((|(executer3WriteValues[6])) & executer3DoWrite[6]);
	executerWriteWideOrSelected[7]=((|(executer0WriteValues[7])) & executer0DoWrite[7]) | ((|(executer1WriteValues[7])) & executer1DoWrite[7]) | ((|(executer2WriteValues[7])) & executer2DoWrite[7]) | ((|(executer3WriteValues[7])) & executer3DoWrite[7]);
	executerWriteWideOrSelected[8]=((|(executer0WriteValues[8])) & executer0DoWrite[8]) | ((|(executer1WriteValues[8])) & executer1DoWrite[8]) | ((|(executer2WriteValues[8])) & executer2DoWrite[8]) | ((|(executer3WriteValues[8])) & executer3DoWrite[8]);
	executerWriteWideOrSelected[9]=((|(executer0WriteValues[9])) & executer0DoWrite[9]) | ((|(executer1WriteValues[9])) & executer1DoWrite[9]) | ((|(executer2WriteValues[9])) & executer2DoWrite[9]) | ((|(executer3WriteValues[9])) & executer3DoWrite[9]);
	executerWriteWideOrSelected[10]=((|(executer0WriteValues[10])) & executer0DoWrite[10]) | ((|(executer1WriteValues[10])) & executer1DoWrite[10]) | ((|(executer2WriteValues[10])) & executer2DoWrite[10]) | ((|(executer3WriteValues[10])) & executer3DoWrite[10]);
	executerWriteWideOrSelected[11]=((|(executer0WriteValues[11])) & executer0DoWrite[11]) | ((|(executer1WriteValues[11])) & executer1DoWrite[11]) | ((|(executer2WriteValues[11])) & executer2DoWrite[11]) | ((|(executer3WriteValues[11])) & executer3DoWrite[11]);
	executerWriteWideOrSelected[12]=((|(executer0WriteValues[12])) & executer0DoWrite[12]) | ((|(executer1WriteValues[12])) & executer1DoWrite[12]) | ((|(executer2WriteValues[12])) & executer2DoWrite[12]) | ((|(executer3WriteValues[12])) & executer3DoWrite[12]);
	executerWriteWideOrSelected[13]=((|(executer0WriteValues[13])) & executer0DoWrite[13]) | ((|(executer1WriteValues[13])) & executer1DoWrite[13]) | ((|(executer2WriteValues[13])) & executer2DoWrite[13]) | ((|(executer3WriteValues[13])) & executer3DoWrite[13]);
	executerWriteWideOrSelected[14]=((|(executer0WriteValues[14])) & executer0DoWrite[14]) | ((|(executer1WriteValues[14])) & executer1DoWrite[14]) | ((|(executer2WriteValues[14])) & executer2DoWrite[14]) | ((|(executer3WriteValues[14])) & executer3DoWrite[14]);
	executerWriteWideOrSelected[15]=((|(executer0WriteValues[15])) & executer0DoWrite[15]) | ((|(executer1WriteValues[15])) & executer1DoWrite[15]) | ((|(executer2WriteValues[15])) & executer2DoWrite[15]) | ((|(executer3WriteValues[15])) & executer3DoWrite[15]);
end


always @(posedge main_clk) begin
	assert ((executer0DoWrite & executer1DoWrite)==0);
	assert ((executer0DoWrite & executer2DoWrite)==0);
	assert ((executer0DoWrite & executer3DoWrite)==0);
	assert ((executer1DoWrite & executer2DoWrite)==0);
	assert ((executer1DoWrite & executer3DoWrite)==0);
	assert ((executer2DoWrite & executer3DoWrite)==0);
end


always @(posedge main_clk) begin
	if (executerDoWrite[0]) begin user_reg[0]<=executerWriteValuesSelected[0];end
	if (executerDoWrite[1]) begin user_reg[1]<=executerWriteValuesSelected[1];end
	if (executerDoWrite[2]) begin user_reg[2]<=executerWriteValuesSelected[2];end
	if (executerDoWrite[3]) begin user_reg[3]<=executerWriteValuesSelected[3];end
	if (executerDoWrite[4]) begin user_reg[4]<=executerWriteValuesSelected[4];end
	if (executerDoWrite[5]) begin user_reg[5]<=executerWriteValuesSelected[5];end
	if (executerDoWrite[6]) begin user_reg[6]<=executerWriteValuesSelected[6];end
	if (executerDoWrite[7]) begin user_reg[7]<=executerWriteValuesSelected[7];end
	if (executerDoWrite[8]) begin user_reg[8]<=executerWriteValuesSelected[8];end
	if (executerDoWrite[9]) begin user_reg[9]<=executerWriteValuesSelected[9];end
	if (executerDoWrite[10]) begin user_reg[10]<=executerWriteValuesSelected[10];end
	if (executerDoWrite[11]) begin user_reg[11]<=executerWriteValuesSelected[11];end
	if (executerDoWrite[12]) begin user_reg[12]<=executerWriteValuesSelected[12];end
	if (executerDoWrite[13]) begin user_reg[13]<=executerWriteValuesSelected[13];end
	if (executerDoWrite[14]) begin user_reg[14]<=executerWriteValuesSelected[14];end
	if (executerDoWrite[15]) begin user_reg[15]<=executerWriteValuesSelected[15];end
	if (executerDoWrite[16]) begin
		stack_pointer   <=executerWriteValuesSelected[16];
		stack_pointer_m2<=executerWriteValuesSelected[16]-5'd2;
		stack_pointer_m4<=executerWriteValuesSelected[16]-5'd4;
		stack_pointer_m6<=executerWriteValuesSelected[16]-5'd6;
		stack_pointer_m8<=executerWriteValuesSelected[16]-5'd8;
		stack_pointer_p2<=executerWriteValuesSelected[16]+5'd2;
		stack_pointer_p4<=executerWriteValuesSelected[16]+5'd4;
	end
	stack_pointer[0]   <=1'b0;
	stack_pointer_m2[0]<=1'b0;
	stack_pointer_m4[0]<=1'b0;
	stack_pointer_m6[0]<=1'b0;
	stack_pointer_m8[0]<=1'b0;
	stack_pointer_p2[0]<=1'b0;
	stack_pointer_p4[0]<=1'b0;
end


core_executer core_executer_inst0(
	instructionCurrent_scheduler_0,
	instructionCurrentID_scheduler_0,
	current_instruction_address_table[0],
	executerEnable[0],
	executerWillBeEnabled[0],
	user_reg,
	user_reg_wide_or,
	
	executerWriteValuesSelected[15:0],
	executerWriteWideOrSelected[15:0],
	executerDoWrite[15:0],
	
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
	instructionCurrent_scheduler_1,
	instructionCurrentID_scheduler_1,
	current_instruction_address_table[1],
	executerEnable[1],
	executerWillBeEnabled[1],
	user_reg,
	user_reg_wide_or,
	
	executerWriteValuesSelected[15:0],
	executerWriteWideOrSelected[15:0],
	executerDoWrite[15:0],
	
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
	instructionCurrent_scheduler_2,
	instructionCurrentID_scheduler_2,
	current_instruction_address_table[2],
	executerEnable[2],
	executerWillBeEnabled[2],
	user_reg,
	user_reg_wide_or,
	
	executerWriteValuesSelected[15:0],
	executerWriteWideOrSelected[15:0],
	executerDoWrite[15:0],
	
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
	instructionCurrent_scheduler_3,
	instructionCurrentID_scheduler_3,
	current_instruction_address_table[3],
	executerEnable[3],
	executerWillBeEnabled[3],
	user_reg,
	user_reg_wide_or,
	
	executerWriteValuesSelected[15:0],
	executerWriteWideOrSelected[15:0],
	executerDoWrite[15:0],
	
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

wire [3:0] memory_dependency_clear;

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

wire [7:0] orderConflictsGeneratedValid [3:0];

wire [7:0] executionConflicts0GeneratedMaybeValid [3:0];
wire [7:0] executionConflicts0GeneratedValid [3:0];

wire [7:0] executionConflicts1GeneratedMaybeValid [3:0];
wire [7:0] executionConflicts1GeneratedValid [3:0];

wire [7:0] executionConflicts2GeneratedMaybeValid [3:0];
wire [7:0] executionConflicts2GeneratedValid [3:0];

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


wire [7:0] instructionNotFininshingMask;
assign instructionNotFininshingMask={4'hF,!is_instruction_finishing_this_cycle_pulse_3,!is_instruction_finishing_this_cycle_pulse_2,!is_instruction_finishing_this_cycle_pulse_1,!is_instruction_finishing_this_cycle_pulse_0};

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




assign debug_instruction_fetch_address=instruction_fetch_address;
assign debug_stack_pointer=stack_pointer;
assign debug_user_reg=user_reg;


endmodule





