`timescale 1 ps / 1 ps

module dispatcher(
	output [1:0] used_ready_instruction_count_extern,
	output [7:0] is_new_instruction_entering_this_cycle,
	output [7:0] isAfter_extern [7:0],
	output [7:0] isAfter_next_extern [7:0],
	output [1:0] setIndexes_extern [7:0],
	
	input [7:0] possible_remain_valid,
	input jump_triggering_now,
	input [1:0] ready_instruction_count_now,
	
	input main_clk
);

wire [11:0] lut0 [63:0];
assign lut0[6'b000000]=12'bxxxxxxxx0000;
assign lut0[6'b000001]=12'bxxxxxxxx0000;
assign lut0[6'b000010]=12'bxxxxxxxx0000;
assign lut0[6'b000011]=12'bxxxxxxxx0000;
assign lut0[6'b000100]=12'bxxxxxxxx0000;
assign lut0[6'b000101]=12'bxxxxxxxx0000;
assign lut0[6'b000110]=12'bxxxxxxxx0000;
assign lut0[6'b000111]=12'bxxxxxxxx0000;
assign lut0[6'b001000]=12'bxxxxxxxx0000;
assign lut0[6'b001001]=12'bxxxxxxxx0000;
assign lut0[6'b001010]=12'bxxxxxxxx0000;
assign lut0[6'b001011]=12'bxxxxxxxx0000;
assign lut0[6'b001100]=12'bxxxxxxxx0000;
assign lut0[6'b001101]=12'bxxxxxxxx0000;
assign lut0[6'b001110]=12'bxxxxxxxx0000;
assign lut0[6'b001111]=12'bxxxxxxxx0000;
assign lut0[6'b010001]=12'bxxxxxx000001;
assign lut0[6'b010010]=12'bxxxx00xx0010;
assign lut0[6'b010011]=12'bxxxxxx000001;
assign lut0[6'b010100]=12'bxx00xxxx0100;
assign lut0[6'b010101]=12'bxxxxxx000001;
assign lut0[6'b010110]=12'bxxxx00xx0010;
assign lut0[6'b010111]=12'bxxxxxx000001;
assign lut0[6'b011000]=12'b00xxxxxx1000;
assign lut0[6'b011001]=12'bxxxxxx000001;
assign lut0[6'b011010]=12'bxxxx00xx0010;
assign lut0[6'b011011]=12'bxxxxxx000001;
assign lut0[6'b011100]=12'bxx00xxxx0100;
assign lut0[6'b011101]=12'bxxxxxx000001;
assign lut0[6'b011110]=12'bxxxx00xx0010;
assign lut0[6'b011111]=12'bxxxxxx000001;
assign lut0[6'b100011]=12'bxxxx01000011;
assign lut0[6'b100101]=12'bxx01xx000101;
assign lut0[6'b100110]=12'bxx0100xx0110;
assign lut0[6'b100111]=12'bxxxx01000011;
assign lut0[6'b101001]=12'b01xxxx001001;
assign lut0[6'b101010]=12'b01xx00xx1010;
assign lut0[6'b101011]=12'bxxxx01000011;
assign lut0[6'b101100]=12'b0100xxxx1100;
assign lut0[6'b101101]=12'bxx01xx000101;
assign lut0[6'b101110]=12'bxx0100xx0110;
assign lut0[6'b101111]=12'bxxxx01000011;
assign lut0[6'b110111]=12'bxx1001000111;
assign lut0[6'b111011]=12'b10xx01001011;
assign lut0[6'b111101]=12'b1001xx001101;
assign lut0[6'b111110]=12'b100100xx1110;
assign lut0[6'b111111]=12'bxx1001000111;

assign lut0[6'b010000]=12'bxxxxxxxxxxxx;
assign lut0[6'b100000]=12'bxxxxxxxxxxxx;
assign lut0[6'b100001]=12'bxxxxxxxxxxxx;
assign lut0[6'b100010]=12'bxxxxxxxxxxxx;
assign lut0[6'b100100]=12'bxxxxxxxxxxxx;
assign lut0[6'b101000]=12'bxxxxxxxxxxxx;
assign lut0[6'b110000]=12'bxxxxxxxxxxxx;
assign lut0[6'b110001]=12'bxxxxxxxxxxxx;
assign lut0[6'b110010]=12'bxxxxxxxxxxxx;
assign lut0[6'b110011]=12'bxxxxxxxxxxxx;
assign lut0[6'b110100]=12'bxxxxxxxxxxxx;
assign lut0[6'b110101]=12'bxxxxxxxxxxxx;
assign lut0[6'b110110]=12'bxxxxxxxxxxxx;
assign lut0[6'b111000]=12'bxxxxxxxxxxxx;
assign lut0[6'b111001]=12'bxxxxxxxxxxxx;
assign lut0[6'b111010]=12'bxxxxxxxxxxxx;
assign lut0[6'b111100]=12'bxxxxxxxxxxxx;



wire [1:0] popcnt4 [15:0];
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
assign popcnt4[4'b1111]=3;



wire [1:0] popcntConsume0;
wire [1:0] popcntConsume1;
wire [2:0] popcntConsume2;
wire [1:0] popcntConsume3;


lcells #(2) lc_popcnt0(popcntConsume0,popcnt4[~possible_remain_valid[3:0]]);
lcells #(2) lc_popcnt1(popcntConsume1,popcnt4[~possible_remain_valid[7:4]]);

assign popcntConsume2=popcntConsume0 + popcntConsume1;
lcells #(2) lc_popcnt3(popcntConsume3,(popcntConsume2>2'd3)?(2'd3):(popcntConsume2[1:0]));
wire [1:0] used_ready_instruction_count;
lcells #(2) lc_used_ready_instruction_count(used_ready_instruction_count,(ready_instruction_count_now > popcntConsume3)?popcntConsume3:ready_instruction_count_now);
assign used_ready_instruction_count_extern=used_ready_instruction_count;

reg [1:0] count_for0a;
reg [1:0] count_for1a;
reg [1:0] count_for0;
reg [1:0] count_for1;

lcells #(2) lc_count_for0(count_for0,count_for0a);
lcells #(2) lc_count_for1(count_for1,count_for1a);

always_comb begin
	if (popcntConsume0 >= ready_instruction_count_now) begin
		count_for0a=ready_instruction_count_now;
		count_for1a=0;
	end else begin
		count_for0a=popcntConsume0;
		count_for1a=ready_instruction_count_now - popcntConsume0;
		if (count_for1a > popcntConsume1) count_for1a=popcntConsume1;
	end
	count_for0a=count_for0a & {2{!jump_triggering_now}};
	count_for1a=count_for1a & {2{!jump_triggering_now}};
end

wire [11:0] tmp0;
wire [11:0] tmp1;
wire [5:0] tmp2;
wire [5:0] tmp3;
lcells #(12) lc_g0(tmp0,lut0[tmp2]);
lcells #(12) lc_g1(tmp1,lut0[tmp3]);
assign tmp2[3:0]=~(possible_remain_valid[3:0]);
assign tmp2[5:4]=count_for0;
assign tmp3[3:0]=~(possible_remain_valid[7:4]);
assign tmp3[5:4]=count_for1;

wire [1:0] setIndexes [7:0];

lcells #(2) lc0_setIndexes(setIndexes_extern[0],setIndexes[0]);
lcells #(2) lc1_setIndexes(setIndexes_extern[1],setIndexes[1]);
lcells #(2) lc2_setIndexes(setIndexes_extern[2],setIndexes[2]);
lcells #(2) lc3_setIndexes(setIndexes_extern[3],setIndexes[3]);
lcells #(2) lc4_setIndexes(setIndexes_extern[4],setIndexes[4]);
lcells #(2) lc5_setIndexes(setIndexes_extern[5],setIndexes[5]);
lcells #(2) lc6_setIndexes(setIndexes_extern[6],setIndexes[6]);
lcells #(2) lc7_setIndexes(setIndexes_extern[7],setIndexes[7]);

assign is_new_instruction_entering_this_cycle[3:0]=tmp0[3:0];
assign setIndexes[0]=tmp0[ 5: 4];
assign setIndexes[1]=tmp0[ 7: 6];
assign setIndexes[2]=tmp0[ 9: 8];
assign setIndexes[3]=tmp0[11:10];

assign is_new_instruction_entering_this_cycle[7:4]=tmp1[3:0];
assign setIndexes[4]=tmp1[ 5: 4]+count_for0;
assign setIndexes[5]=tmp1[ 7: 6]+count_for0;
assign setIndexes[6]=tmp1[ 9: 8]+count_for0;
assign setIndexes[7]=tmp1[11:10]+count_for0;

////


reg [7:0] isAfter [7:0]='{127,63,31,15,7,3,1,0};
reg [7:0] isAfter_true [7:0];
reg [7:0] isAfter_temp [7:0];
reg [7:0] isAfter_next [7:0];

always_comb begin
	isAfter_true[0][0]=0;
	isAfter_true[0][1]= isAfter[0][1];
	isAfter_true[0][2]= isAfter[0][2];
	isAfter_true[0][3]= isAfter[0][3];
	isAfter_true[0][4]= isAfter[0][4];
	isAfter_true[0][5]= isAfter[0][5];
	isAfter_true[0][6]= isAfter[0][6];
	isAfter_true[0][7]= isAfter[0][7];
	isAfter_true[1][0]=!isAfter[0][1];
	isAfter_true[1][1]=0;
	isAfter_true[1][2]= isAfter[1][2];
	isAfter_true[1][3]= isAfter[1][3];
	isAfter_true[1][4]= isAfter[1][4];
	isAfter_true[1][5]= isAfter[1][5];
	isAfter_true[1][6]= isAfter[1][6];
	isAfter_true[1][7]= isAfter[1][7];
	isAfter_true[2][0]=!isAfter[0][2];
	isAfter_true[2][1]=!isAfter[1][2];
	isAfter_true[2][2]=0;
	isAfter_true[2][3]= isAfter[2][3];
	isAfter_true[2][4]= isAfter[2][4];
	isAfter_true[2][5]= isAfter[2][5];
	isAfter_true[2][6]= isAfter[2][6];
	isAfter_true[2][7]= isAfter[2][7];
	isAfter_true[3][0]=!isAfter[0][3];
	isAfter_true[3][1]=!isAfter[1][3];
	isAfter_true[3][2]=!isAfter[2][3];
	isAfter_true[3][3]=0;
	isAfter_true[3][4]= isAfter[3][4];
	isAfter_true[3][5]= isAfter[3][5];
	isAfter_true[3][6]= isAfter[3][6];
	isAfter_true[3][7]= isAfter[3][7];
	isAfter_true[4][0]=!isAfter[0][4];
	isAfter_true[4][1]=!isAfter[1][4];
	isAfter_true[4][2]=!isAfter[2][4];
	isAfter_true[4][3]=!isAfter[3][4];
	isAfter_true[4][4]=0;
	isAfter_true[4][5]= isAfter[4][5];
	isAfter_true[4][6]= isAfter[4][6];
	isAfter_true[4][7]= isAfter[4][7];
	isAfter_true[5][0]=!isAfter[0][5];
	isAfter_true[5][1]=!isAfter[1][5];
	isAfter_true[5][2]=!isAfter[2][5];
	isAfter_true[5][3]=!isAfter[3][5];
	isAfter_true[5][4]=!isAfter[4][5];
	isAfter_true[5][5]=0;
	isAfter_true[5][6]= isAfter[5][6];
	isAfter_true[5][7]= isAfter[5][7];
	isAfter_true[6][0]=!isAfter[0][6];
	isAfter_true[6][1]=!isAfter[1][6];
	isAfter_true[6][2]=!isAfter[2][6];
	isAfter_true[6][3]=!isAfter[3][6];
	isAfter_true[6][4]=!isAfter[4][6];
	isAfter_true[6][5]=!isAfter[5][6];
	isAfter_true[6][6]=0;
	isAfter_true[6][7]= isAfter[6][7];
	isAfter_true[7][0]=!isAfter[0][7];
	isAfter_true[7][1]=!isAfter[1][7];
	isAfter_true[7][2]=!isAfter[2][7];
	isAfter_true[7][3]=!isAfter[3][7];
	isAfter_true[7][4]=!isAfter[4][7];
	isAfter_true[7][5]=!isAfter[5][7];
	isAfter_true[7][6]=!isAfter[6][7];
	isAfter_true[7][7]=0;
end

always @(posedge main_clk) isAfter<=isAfter_next;

assign isAfter_extern=isAfter_true;
assign isAfter_next_extern=isAfter_next;

always_comb begin
	isAfter_temp=isAfter_true;
	if (is_new_instruction_entering_this_cycle[0]) begin
		isAfter_temp[0]=8'hFF;
		isAfter_temp[0][0]=1'b0;
		isAfter_temp[1][0]=1'b0;
		isAfter_temp[2][0]=1'b0;
		isAfter_temp[3][0]=1'b0;
		isAfter_temp[4][0]=1'b0;
		isAfter_temp[5][0]=1'b0;
		isAfter_temp[6][0]=1'b0;
		isAfter_temp[7][0]=1'b0;
	end
	if (is_new_instruction_entering_this_cycle[1]) begin
		isAfter_temp[1]=8'hFF;
		isAfter_temp[0][1]=1'b0;
		isAfter_temp[1][1]=1'b0;
		isAfter_temp[2][1]=1'b0;
		isAfter_temp[3][1]=1'b0;
		isAfter_temp[4][1]=1'b0;
		isAfter_temp[5][1]=1'b0;
		isAfter_temp[6][1]=1'b0;
		isAfter_temp[7][1]=1'b0;
	end
	if (is_new_instruction_entering_this_cycle[2]) begin
		isAfter_temp[2]=8'hFF;
		isAfter_temp[0][2]=1'b0;
		isAfter_temp[1][2]=1'b0;
		isAfter_temp[2][2]=1'b0;
		isAfter_temp[3][2]=1'b0;
		isAfter_temp[4][2]=1'b0;
		isAfter_temp[5][2]=1'b0;
		isAfter_temp[6][2]=1'b0;
		isAfter_temp[7][2]=1'b0;
	end
	if (is_new_instruction_entering_this_cycle[3]) begin
		isAfter_temp[3]=8'hFF;
		isAfter_temp[0][3]=1'b0;
		isAfter_temp[1][3]=1'b0;
		isAfter_temp[2][3]=1'b0;
		isAfter_temp[3][3]=1'b0;
		isAfter_temp[4][3]=1'b0;
		isAfter_temp[5][3]=1'b0;
		isAfter_temp[6][3]=1'b0;
		isAfter_temp[7][3]=1'b0;
	end
	if (is_new_instruction_entering_this_cycle[4]) begin
		isAfter_temp[4]=8'hFF;
		isAfter_temp[0][4]=1'b0;
		isAfter_temp[1][4]=1'b0;
		isAfter_temp[2][4]=1'b0;
		isAfter_temp[3][4]=1'b0;
		isAfter_temp[4][4]=1'b0;
		isAfter_temp[5][4]=1'b0;
		isAfter_temp[6][4]=1'b0;
		isAfter_temp[7][4]=1'b0;
	end
	if (is_new_instruction_entering_this_cycle[5]) begin
		isAfter_temp[5]=8'hFF;
		isAfter_temp[0][5]=1'b0;
		isAfter_temp[1][5]=1'b0;
		isAfter_temp[2][5]=1'b0;
		isAfter_temp[3][5]=1'b0;
		isAfter_temp[4][5]=1'b0;
		isAfter_temp[5][5]=1'b0;
		isAfter_temp[6][5]=1'b0;
		isAfter_temp[7][5]=1'b0;
	end
	if (is_new_instruction_entering_this_cycle[6]) begin
		isAfter_temp[6]=8'hFF;
		isAfter_temp[0][6]=1'b0;
		isAfter_temp[1][6]=1'b0;
		isAfter_temp[2][6]=1'b0;
		isAfter_temp[3][6]=1'b0;
		isAfter_temp[4][6]=1'b0;
		isAfter_temp[5][6]=1'b0;
		isAfter_temp[6][6]=1'b0;
		isAfter_temp[7][6]=1'b0;
	end
	if (is_new_instruction_entering_this_cycle[7]) begin
		isAfter_temp[7]=8'hFF;
		isAfter_temp[0][7]=1'b0;
		isAfter_temp[1][7]=1'b0;
		isAfter_temp[2][7]=1'b0;
		isAfter_temp[3][7]=1'b0;
		isAfter_temp[4][7]=1'b0;
		isAfter_temp[5][7]=1'b0;
		isAfter_temp[6][7]=1'b0;
		isAfter_temp[7][7]=1'b0;
	end
end


always_comb begin
	isAfter_next[0][0]=0;
	isAfter_next[0][1]= isAfter_temp[0][1];
	isAfter_next[0][2]= isAfter_temp[0][2];
	isAfter_next[0][3]= isAfter_temp[0][3];
	isAfter_next[0][4]= isAfter_temp[0][4];
	isAfter_next[0][5]= isAfter_temp[0][5];
	isAfter_next[0][6]= isAfter_temp[0][6];
	isAfter_next[0][7]= isAfter_temp[0][7];
	isAfter_next[1][0]=!isAfter_temp[0][1];
	isAfter_next[1][1]=0;
	isAfter_next[1][2]= isAfter_temp[1][2];
	isAfter_next[1][3]= isAfter_temp[1][3];
	isAfter_next[1][4]= isAfter_temp[1][4];
	isAfter_next[1][5]= isAfter_temp[1][5];
	isAfter_next[1][6]= isAfter_temp[1][6];
	isAfter_next[1][7]= isAfter_temp[1][7];
	isAfter_next[2][0]=!isAfter_temp[0][2];
	isAfter_next[2][1]=!isAfter_temp[1][2];
	isAfter_next[2][2]=0;
	isAfter_next[2][3]= isAfter_temp[2][3];
	isAfter_next[2][4]= isAfter_temp[2][4];
	isAfter_next[2][5]= isAfter_temp[2][5];
	isAfter_next[2][6]= isAfter_temp[2][6];
	isAfter_next[2][7]= isAfter_temp[2][7];
	isAfter_next[3][0]=!isAfter_temp[0][3];
	isAfter_next[3][1]=!isAfter_temp[1][3];
	isAfter_next[3][2]=!isAfter_temp[2][3];
	isAfter_next[3][3]=0;
	isAfter_next[3][4]= isAfter_temp[3][4];
	isAfter_next[3][5]= isAfter_temp[3][5];
	isAfter_next[3][6]= isAfter_temp[3][6];
	isAfter_next[3][7]= isAfter_temp[3][7];
	isAfter_next[4][0]=!isAfter_temp[0][4];
	isAfter_next[4][1]=!isAfter_temp[1][4];
	isAfter_next[4][2]=!isAfter_temp[2][4];
	isAfter_next[4][3]=!isAfter_temp[3][4];
	isAfter_next[4][4]=0;
	isAfter_next[4][5]= isAfter_temp[4][5];
	isAfter_next[4][6]= isAfter_temp[4][6];
	isAfter_next[4][7]= isAfter_temp[4][7];
	isAfter_next[5][0]=!isAfter_temp[0][5];
	isAfter_next[5][1]=!isAfter_temp[1][5];
	isAfter_next[5][2]=!isAfter_temp[2][5];
	isAfter_next[5][3]=!isAfter_temp[3][5];
	isAfter_next[5][4]=!isAfter_temp[4][5];
	isAfter_next[5][5]=0;
	isAfter_next[5][6]= isAfter_temp[5][6];
	isAfter_next[5][7]= isAfter_temp[5][7];
	isAfter_next[6][0]=!isAfter_temp[0][6];
	isAfter_next[6][1]=!isAfter_temp[1][6];
	isAfter_next[6][2]=!isAfter_temp[2][6];
	isAfter_next[6][3]=!isAfter_temp[3][6];
	isAfter_next[6][4]=!isAfter_temp[4][6];
	isAfter_next[6][5]=!isAfter_temp[5][6];
	isAfter_next[6][6]=0;
	isAfter_next[6][7]= isAfter_temp[6][7];
	isAfter_next[7][0]=!isAfter_temp[0][7];
	isAfter_next[7][1]=!isAfter_temp[1][7];
	isAfter_next[7][2]=!isAfter_temp[2][7];
	isAfter_next[7][3]=!isAfter_temp[3][7];
	isAfter_next[7][4]=!isAfter_temp[4][7];
	isAfter_next[7][5]=!isAfter_temp[5][7];
	isAfter_next[7][6]=!isAfter_temp[6][7];
	isAfter_next[7][7]=0;
end

endmodule

