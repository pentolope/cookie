`timescale 1 ps / 1 ps


module scheduler(
	output [4:0] fifo_instruction_cache_size_after_read_extern,
	output [2:0] fifo_instruction_cache_consume_count_extern,
	output [7:0] is_new_instruction_entering_this_cycle_extern,
	output [7:0] isAfter_extern [7:0],
	output [7:0] isAfter_next_extern [7:0],
	output [1:0] setIndexes_extern [7:0],
	
	input [7:0] is_instructions_valid_next,
	input is_performing_jump_next_instant_on,
	input [4:0] fifo_instruction_cache_size,
	input [4:0] fifo_instruction_cache_size_next,
	
	input main_clk
);

reg [7:0] is_new_instruction_entering_this_cycle;
reg [7:0] instructions_might_be_valid_next=0;
reg [7:0] is_instructions_valid=0;
always @(posedge main_clk) is_instructions_valid<=is_instructions_valid_next;
always_comb instructions_might_be_valid_next=is_instructions_valid | is_new_instruction_entering_this_cycle;


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

wire [2:0] popcntConsume_next0;
wire [2:0] popcntConsume_next1;
wire [3:0] popcntConsume_next2;
wire [2:0] popcntConsume_next3;

lcell_3 lc_popcnt0(popcntConsume_next0,popcnt4[~instructions_might_be_valid_next[3:0]]);
lcell_3 lc_popcnt1(popcntConsume_next1,popcnt4[~instructions_might_be_valid_next[7:4]]);

assign popcntConsume_next2=popcntConsume_next0 + popcntConsume_next1;
assign popcntConsume_next3=(popcntConsume_next2>3'd3)?(3'd4):({1'b0,popcntConsume_next2[1:0]});

reg [2:0] fifo_instruction_cache_consume_count=0;
reg [2:0] fifo_instruction_cache_consume_count_next;
assign fifo_instruction_cache_consume_count_extern=fifo_instruction_cache_consume_count;

reg [1:0] setIndexes [7:0];

lcell_2 lc0_setIndexes(setIndexes_extern[0],setIndexes[0]);
lcell_2 lc1_setIndexes(setIndexes_extern[1],setIndexes[1]);
lcell_2 lc2_setIndexes(setIndexes_extern[2],setIndexes[2]);
lcell_2 lc3_setIndexes(setIndexes_extern[3],setIndexes[3]);
lcell_2 lc4_setIndexes(setIndexes_extern[4],setIndexes[4]);
lcell_2 lc5_setIndexes(setIndexes_extern[5],setIndexes[5]);
lcell_2 lc6_setIndexes(setIndexes_extern[6],setIndexes[6]);
lcell_2 lc7_setIndexes(setIndexes_extern[7],setIndexes[7]);

assign is_new_instruction_entering_this_cycle_extern=is_new_instruction_entering_this_cycle;

reg [4:0] fifo_instruction_cache_size_after_read=0;
assign fifo_instruction_cache_size_after_read_extern=fifo_instruction_cache_size_after_read;
always @(posedge main_clk) begin
	fifo_instruction_cache_size_after_read<=fifo_instruction_cache_size_next -fifo_instruction_cache_consume_count_next;
end

always_comb begin
	if (fifo_instruction_cache_size_next > popcntConsume_next3) begin // could also be viewed as `fifo_instruction_cache_size_next >= popcntConsume_next3`
		fifo_instruction_cache_consume_count_next=popcntConsume_next3;
	end else begin
		fifo_instruction_cache_consume_count_next=fifo_instruction_cache_size_next[2:0];
	end
	fifo_instruction_cache_consume_count_next=fifo_instruction_cache_consume_count_next & {3{!is_performing_jump_next_instant_on}};
end
always @(posedge main_clk) begin
	fifo_instruction_cache_consume_count<=fifo_instruction_cache_consume_count_next;
end

reg [2:0] count_left;

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
	is_new_instruction_entering_this_cycle=8'h0;
	setIndexes='{2'hx,2'hx,2'hx,2'hx,2'hx,2'hx,2'hx,2'hx};
	count_left=fifo_instruction_cache_consume_count;
	if (count_left!=3'h0 && !is_instructions_valid[0]) begin
		is_new_instruction_entering_this_cycle[0]=1'b1;
		setIndexes[0]=fifo_instruction_cache_consume_count -count_left;
		count_left=count_left-1'd1;
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
	if (count_left!=3'h0 && !is_instructions_valid[1]) begin
		is_new_instruction_entering_this_cycle[1]=1'b1;
		setIndexes[1]=fifo_instruction_cache_consume_count -count_left;
		count_left=count_left-1'd1;
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
	if (count_left!=3'h0 && !is_instructions_valid[2]) begin
		is_new_instruction_entering_this_cycle[2]=1'b1;
		setIndexes[2]=fifo_instruction_cache_consume_count -count_left;
		count_left=count_left-1'd1;
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
	if (count_left!=3'h0 && !is_instructions_valid[3]) begin
		is_new_instruction_entering_this_cycle[3]=1'b1;
		setIndexes[3]=fifo_instruction_cache_consume_count -count_left;
		count_left=count_left-1'd1;
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
	if (count_left!=3'h0 && !is_instructions_valid[4]) begin
		is_new_instruction_entering_this_cycle[4]=1'b1;
		setIndexes[4]=fifo_instruction_cache_consume_count -count_left;
		count_left=count_left-1'd1;
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
	if (count_left!=3'h0 && !is_instructions_valid[5]) begin
		is_new_instruction_entering_this_cycle[5]=1'b1;
		setIndexes[5]=fifo_instruction_cache_consume_count -count_left;
		count_left=count_left-1'd1;
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
	if (count_left!=3'h0 && !is_instructions_valid[6]) begin
		is_new_instruction_entering_this_cycle[6]=1'b1;
		setIndexes[6]=fifo_instruction_cache_consume_count -count_left;
		count_left=count_left-1'd1;
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
	if (count_left!=3'h0 && !is_instructions_valid[7]) begin
		is_new_instruction_entering_this_cycle[7]=1'b1;
		setIndexes[7]=fifo_instruction_cache_consume_count -count_left;
		count_left=count_left-1'd1;
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

