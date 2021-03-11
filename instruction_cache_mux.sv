`timescale 1 ps / 1 ps

module instruction_cache_mux(
	output [31:0] hyper_jump_guess_address_calc,
	output [31:0] hyper_jump_guess_address_calc_alt,
	output [15:0] fifo_instruction_cache_data_at_write_addr_m1,
	output [15:0] fifo_instruction_cache_data_at_write_addr_m2,
	output [15:0] fifo_instruction_cache_data_at_write_addr_m3,
	output [15:0] fifo_instruction_cache_data_at_write_addr_m4,
	output [15:0] new_instruction_table [3:0],
	output [25:0] new_instruction_address_table [3:0],

	input  [15:0] hyper_instruction_fetch_storage [15:0],
	input  [31:0] hyper_jump_guess_address_table [7:0],
	input  [7:0] hyper_jump_guess_source_table [7:0],
	input  [15:0] mem_data_out_type_0 [7:0],
	input  [4:0] fifo_instruction_cache_size_after_read,
	input  [2:0] fifo_instruction_cache_consume_count,
	input  [25:0] instruction_fetch_address,
	input  [31:0] hyper_jump_guess_address_saved,
	input  hyper_jump_potentially_valid_type0, // type0 is if the hyper_jump_guess_address_saved is ready
	input  hyper_jump_potentially_valid_type1, // type1 is if either source_table or address_table was just filled
	input  hyper_jump_potentially_valid_type2, // type2 is if source_table should be used, otherwise address_table should be used
	input  hyper_jump_potentially_valid_type3, // type3 is if this hyper jump calculation is instead from the alternative version, which means this hyper jump was initiated from the hyper jump data
	input  insert_hyper_jump_data_into_instruction_cache,
	input  [2:0] hyper_jump_look_index,
	input  [3:0] hyper_jump_look_index_alt,
	input  [15:0] user_reg [15:0],
	input  main_clk
);

reg [15:0] fifo_instruction_cache_data_old [3:0]='{0,0,0,0};
reg [15:0] fifo_instruction_cache_data [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
reg [25:0] fifo_instruction_cache_addresses [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

/*
fifo_instruction_cache_data_old[3:0] is used for hyper jump
fifo_instruction_cache_data[3:0]     is used for scheduler
*/

assign new_instruction_table[3:0]=fifo_instruction_cache_data[3:0];
assign new_instruction_address_table[3:0]=fifo_instruction_cache_addresses[3:0];

always @(posedge main_clk) begin
	unique case (fifo_instruction_cache_consume_count)
	0:begin
	end
	1:begin
		fifo_instruction_cache_data_old[2:0]<=fifo_instruction_cache_data_old[3:1];
		fifo_instruction_cache_data_old[3]<=fifo_instruction_cache_data[0];
	end
	2:begin
		fifo_instruction_cache_data_old[1:0]<=fifo_instruction_cache_data_old[3:2];
		fifo_instruction_cache_data_old[3:2]<=fifo_instruction_cache_data[1:0];
	end
	3:begin
		fifo_instruction_cache_data_old[0]<=fifo_instruction_cache_data_old[3];
		fifo_instruction_cache_data_old[3:1]<=fifo_instruction_cache_data[2:0];
	end
	4:begin
		fifo_instruction_cache_data_old[3:0]<=fifo_instruction_cache_data[3:0];
	end
	endcase
end

wire [31:0] hyper_jump_guess_address_table_alt [15:0];
wire [7:0] hyper_jump_guess_source_table_alt [15:0];

assign hyper_jump_guess_source_table_alt[15]=hyper_instruction_fetch_storage[15][7:0];
assign hyper_jump_guess_source_table_alt[14]=hyper_instruction_fetch_storage[14][7:0];
assign hyper_jump_guess_source_table_alt[13]=hyper_instruction_fetch_storage[13][7:0];
assign hyper_jump_guess_source_table_alt[12]=hyper_instruction_fetch_storage[12][7:0];
assign hyper_jump_guess_source_table_alt[11]=hyper_instruction_fetch_storage[11][7:0];
assign hyper_jump_guess_source_table_alt[10]=hyper_instruction_fetch_storage[10][7:0];
assign hyper_jump_guess_source_table_alt[ 9]=hyper_instruction_fetch_storage[ 9][7:0];
assign hyper_jump_guess_source_table_alt[ 8]=hyper_instruction_fetch_storage[ 8][7:0];
assign hyper_jump_guess_source_table_alt[ 7]=hyper_instruction_fetch_storage[ 7][7:0];
assign hyper_jump_guess_source_table_alt[ 6]=hyper_instruction_fetch_storage[ 6][7:0];
assign hyper_jump_guess_source_table_alt[ 5]=hyper_instruction_fetch_storage[ 5][7:0];
assign hyper_jump_guess_source_table_alt[ 4]=hyper_instruction_fetch_storage[ 4][7:0];
assign hyper_jump_guess_source_table_alt[ 3]=hyper_instruction_fetch_storage[ 3][7:0];
assign hyper_jump_guess_source_table_alt[ 2]=hyper_instruction_fetch_storage[ 2][7:0];
assign hyper_jump_guess_source_table_alt[ 1]=hyper_instruction_fetch_storage[ 1][7:0];
assign hyper_jump_guess_source_table_alt[ 0]=hyper_instruction_fetch_storage[ 0][7:0];

assign hyper_jump_guess_address_table_alt[15]={hyper_instruction_fetch_storage[14][11:4],hyper_instruction_fetch_storage[13][11:4],hyper_instruction_fetch_storage[12][11:4],hyper_instruction_fetch_storage[11][11:4]};
assign hyper_jump_guess_address_table_alt[14]={hyper_instruction_fetch_storage[13][11:4],hyper_instruction_fetch_storage[12][11:4],hyper_instruction_fetch_storage[11][11:4],hyper_instruction_fetch_storage[10][11:4]};
assign hyper_jump_guess_address_table_alt[13]={hyper_instruction_fetch_storage[12][11:4],hyper_instruction_fetch_storage[11][11:4],hyper_instruction_fetch_storage[10][11:4],hyper_instruction_fetch_storage[ 9][11:4]};
assign hyper_jump_guess_address_table_alt[12]={hyper_instruction_fetch_storage[11][11:4],hyper_instruction_fetch_storage[10][11:4],hyper_instruction_fetch_storage[ 9][11:4],hyper_instruction_fetch_storage[ 8][11:4]};
assign hyper_jump_guess_address_table_alt[11]={hyper_instruction_fetch_storage[10][11:4],hyper_instruction_fetch_storage[ 9][11:4],hyper_instruction_fetch_storage[ 8][11:4],hyper_instruction_fetch_storage[ 7][11:4]};
assign hyper_jump_guess_address_table_alt[10]={hyper_instruction_fetch_storage[ 9][11:4],hyper_instruction_fetch_storage[ 8][11:4],hyper_instruction_fetch_storage[ 7][11:4],hyper_instruction_fetch_storage[ 6][11:4]};
assign hyper_jump_guess_address_table_alt[ 9]={hyper_instruction_fetch_storage[ 8][11:4],hyper_instruction_fetch_storage[ 7][11:4],hyper_instruction_fetch_storage[ 6][11:4],hyper_instruction_fetch_storage[ 5][11:4]};
assign hyper_jump_guess_address_table_alt[ 8]={hyper_instruction_fetch_storage[ 7][11:4],hyper_instruction_fetch_storage[ 6][11:4],hyper_instruction_fetch_storage[ 5][11:4],hyper_instruction_fetch_storage[ 4][11:4]};
assign hyper_jump_guess_address_table_alt[ 7]={hyper_instruction_fetch_storage[ 6][11:4],hyper_instruction_fetch_storage[ 5][11:4],hyper_instruction_fetch_storage[ 4][11:4],hyper_instruction_fetch_storage[ 3][11:4]};
assign hyper_jump_guess_address_table_alt[ 6]={hyper_instruction_fetch_storage[ 5][11:4],hyper_instruction_fetch_storage[ 4][11:4],hyper_instruction_fetch_storage[ 3][11:4],hyper_instruction_fetch_storage[ 2][11:4]};
assign hyper_jump_guess_address_table_alt[ 5]={hyper_instruction_fetch_storage[ 4][11:4],hyper_instruction_fetch_storage[ 3][11:4],hyper_instruction_fetch_storage[ 2][11:4],hyper_instruction_fetch_storage[ 1][11:4]};
assign hyper_jump_guess_address_table_alt[ 4]={hyper_instruction_fetch_storage[ 3][11:4],hyper_instruction_fetch_storage[ 2][11:4],hyper_instruction_fetch_storage[ 1][11:4],hyper_instruction_fetch_storage[ 0][11:4]};
assign hyper_jump_guess_address_table_alt[ 3]={8'hx,8'hx,8'hx,8'hx};
assign hyper_jump_guess_address_table_alt[ 2]={8'hx,8'hx,8'hx,8'hx};
assign hyper_jump_guess_address_table_alt[ 1]={8'hx,8'hx,8'hx,8'hx};
assign hyper_jump_guess_address_table_alt[ 0]={8'hx,8'hx,8'hx,8'hx};

assign hyper_jump_guess_address_calc=hyper_jump_potentially_valid_type2?({user_reg[hyper_jump_guess_source_table[hyper_jump_look_index][7:4]],user_reg[hyper_jump_guess_source_table[hyper_jump_look_index][3:0]]}):(hyper_jump_guess_address_table[hyper_jump_look_index]);
assign hyper_jump_guess_address_calc_alt=hyper_jump_potentially_valid_type2?({user_reg[hyper_jump_guess_source_table_alt[hyper_jump_look_index_alt][7:4]],user_reg[hyper_jump_guess_source_table_alt[hyper_jump_look_index_alt][3:0]]}):(hyper_jump_guess_address_table_alt[hyper_jump_look_index_alt]);

assign fifo_instruction_cache_data_at_write_addr_m1=(fifo_instruction_cache_size_after_read==5'd0)?fifo_instruction_cache_data_old[5'd3                                       ]:fifo_instruction_cache_data[fifo_instruction_cache_size_after_read-5'd1];
assign fifo_instruction_cache_data_at_write_addr_m2=(fifo_instruction_cache_size_after_read <5'd1)?fifo_instruction_cache_data_old[5'd3-fifo_instruction_cache_size_after_read]:fifo_instruction_cache_data[fifo_instruction_cache_size_after_read-5'd2];
assign fifo_instruction_cache_data_at_write_addr_m3=(fifo_instruction_cache_size_after_read <5'd2)?fifo_instruction_cache_data_old[5'd3-fifo_instruction_cache_size_after_read]:fifo_instruction_cache_data[fifo_instruction_cache_size_after_read-5'd3];
assign fifo_instruction_cache_data_at_write_addr_m4=(fifo_instruction_cache_size_after_read <5'd3)?fifo_instruction_cache_data_old[5'd3-fifo_instruction_cache_size_after_read]:fifo_instruction_cache_data[fifo_instruction_cache_size_after_read-5'd4];

wire [2:0] fifo_instruction_cache_consume_count_p1=1'b1+fifo_instruction_cache_consume_count;

wire [25:0] instruction_fetch_address_added [7:0];
assign instruction_fetch_address_added[0]=instruction_fetch_address+5'h0;
assign instruction_fetch_address_added[1]=instruction_fetch_address+5'h2;
assign instruction_fetch_address_added[2]=instruction_fetch_address+5'h4;
assign instruction_fetch_address_added[3]=instruction_fetch_address+5'h6;
assign instruction_fetch_address_added[4]=instruction_fetch_address+5'h8;
assign instruction_fetch_address_added[5]=instruction_fetch_address+5'hA;
assign instruction_fetch_address_added[6]=instruction_fetch_address+5'hC;
assign instruction_fetch_address_added[7]=instruction_fetch_address+5'hE;

wire [25:0] hyper_jump_guess_address_added [15:0];
assign hyper_jump_guess_address_added[ 0]=hyper_jump_guess_address_saved[25:0]+5'h00;
assign hyper_jump_guess_address_added[ 1]=hyper_jump_guess_address_saved[25:0]+5'h02;
assign hyper_jump_guess_address_added[ 2]=hyper_jump_guess_address_saved[25:0]+5'h04;
assign hyper_jump_guess_address_added[ 3]=hyper_jump_guess_address_saved[25:0]+5'h06;
assign hyper_jump_guess_address_added[ 4]=hyper_jump_guess_address_saved[25:0]+5'h08;
assign hyper_jump_guess_address_added[ 5]=hyper_jump_guess_address_saved[25:0]+5'h0A;
assign hyper_jump_guess_address_added[ 6]=hyper_jump_guess_address_saved[25:0]+5'h0C;
assign hyper_jump_guess_address_added[ 7]=hyper_jump_guess_address_saved[25:0]+5'h0E;
assign hyper_jump_guess_address_added[ 8]=hyper_jump_guess_address_saved[25:0]+5'h10;
assign hyper_jump_guess_address_added[ 9]=hyper_jump_guess_address_saved[25:0]+5'h12;
assign hyper_jump_guess_address_added[10]=hyper_jump_guess_address_saved[25:0]+5'h14;
assign hyper_jump_guess_address_added[11]=hyper_jump_guess_address_saved[25:0]+5'h16;
assign hyper_jump_guess_address_added[12]=hyper_jump_guess_address_saved[25:0]+5'h18;
assign hyper_jump_guess_address_added[13]=hyper_jump_guess_address_saved[25:0]+5'h1A;
assign hyper_jump_guess_address_added[14]=hyper_jump_guess_address_saved[25:0]+5'h1C;
assign hyper_jump_guess_address_added[15]=hyper_jump_guess_address_saved[25:0]+5'h1E;

reg [4:0] fifo_instruction_cache_indexes_future [15:0];

wire [15:0] fifo_instruction_cache_data_future_0 [13:0];
wire [15:0] fifo_instruction_cache_data_future_1 [13:0];
wire [15:0] fifo_instruction_cache_data_future_2 [13:0];
wire [15:0] fifo_instruction_cache_data_future_3 [13:0];
wire [15:0] fifo_instruction_cache_data_future_4 [13:0];
wire [15:0] fifo_instruction_cache_data_future_5 [13:0];
wire [15:0] fifo_instruction_cache_data_future_6 [13:0];
wire [15:0] fifo_instruction_cache_data_future_7 [13:0];
wire [15:0] fifo_instruction_cache_data_future_8 [13:0];
wire [15:0] fifo_instruction_cache_data_future_9 [13:0];
wire [15:0] fifo_instruction_cache_data_future_A [13:0];
wire [15:0] fifo_instruction_cache_data_future_B [13:0];
wire [15:0] fifo_instruction_cache_data_future_C [13:0];
wire [15:0] fifo_instruction_cache_data_future_D [13:0];
wire [15:0] fifo_instruction_cache_data_future_E [13:0];
wire [15:0] fifo_instruction_cache_data_future_F [13:0];

wire [25:0] fifo_instruction_cache_addresses_future_0 [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_1 [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_2 [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_3 [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_4 [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_5 [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_6 [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_7 [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_8 [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_9 [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_A [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_B [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_C [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_D [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_E [13:0];
wire [25:0] fifo_instruction_cache_addresses_future_F [13:0];

always_comb begin
	fifo_instruction_cache_indexes_future[4'h0]=(fifo_instruction_cache_size_after_read>5'h0)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'h0));
	fifo_instruction_cache_indexes_future[4'h1]=(fifo_instruction_cache_size_after_read>5'h1)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'h1));
	fifo_instruction_cache_indexes_future[4'h2]=(fifo_instruction_cache_size_after_read>5'h2)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'h2));
	fifo_instruction_cache_indexes_future[4'h3]=(fifo_instruction_cache_size_after_read>5'h3)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'h3));
	fifo_instruction_cache_indexes_future[4'h4]=(fifo_instruction_cache_size_after_read>5'h4)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'h4));
	fifo_instruction_cache_indexes_future[4'h5]=(fifo_instruction_cache_size_after_read>5'h5)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'h5));
	fifo_instruction_cache_indexes_future[4'h6]=(fifo_instruction_cache_size_after_read>5'h6)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'h6));
	fifo_instruction_cache_indexes_future[4'h7]=(fifo_instruction_cache_size_after_read>5'h7)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'h7));
	fifo_instruction_cache_indexes_future[4'h8]=(fifo_instruction_cache_size_after_read>5'h8)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'h8));
	fifo_instruction_cache_indexes_future[4'h9]=(fifo_instruction_cache_size_after_read>5'h9)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'h9));
	fifo_instruction_cache_indexes_future[4'hA]=(fifo_instruction_cache_size_after_read>5'hA)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'hA));
	fifo_instruction_cache_indexes_future[4'hB]=(fifo_instruction_cache_size_after_read>5'hB)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'hB));
	fifo_instruction_cache_indexes_future[4'hC]=(fifo_instruction_cache_size_after_read>5'hC)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'hC));
	fifo_instruction_cache_indexes_future[4'hD]=(fifo_instruction_cache_size_after_read>5'hD)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'hD));
	fifo_instruction_cache_indexes_future[4'hE]=(fifo_instruction_cache_size_after_read>5'hE)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'hE));
	fifo_instruction_cache_indexes_future[4'hF]=(fifo_instruction_cache_size_after_read>5'hF)?fifo_instruction_cache_consume_count_p1:(4'd6-(fifo_instruction_cache_size_after_read-4'hF));
	
	if (insert_hyper_jump_data_into_instruction_cache) begin
	// this doesn't bother to check if the hyper jump address is identical because that doesn't need to matter for if the hyper jump data is inserted into the instruction cache (there is nothing important there anyway)
		fifo_instruction_cache_indexes_future[4'h0]=0;
		fifo_instruction_cache_indexes_future[4'h1]=0;
		fifo_instruction_cache_indexes_future[4'h2]=0;
		fifo_instruction_cache_indexes_future[4'h3]=0;
		fifo_instruction_cache_indexes_future[4'h4]=0;
		fifo_instruction_cache_indexes_future[4'h5]=0;
		fifo_instruction_cache_indexes_future[4'h6]=0;
		fifo_instruction_cache_indexes_future[4'h7]=0;
		fifo_instruction_cache_indexes_future[4'h8]=0;
		fifo_instruction_cache_indexes_future[4'h9]=0;
		fifo_instruction_cache_indexes_future[4'hA]=0;
		fifo_instruction_cache_indexes_future[4'hB]=0;
		fifo_instruction_cache_indexes_future[4'hC]=0;
		fifo_instruction_cache_indexes_future[4'hD]=0;
		fifo_instruction_cache_indexes_future[4'hE]=0;
		fifo_instruction_cache_indexes_future[4'hF]=0;
	end
end
always @(posedge main_clk) begin
	fifo_instruction_cache_data[4'h0]<=fifo_instruction_cache_data_future_0[fifo_instruction_cache_indexes_future[4'h0]];
	fifo_instruction_cache_data[4'h1]<=fifo_instruction_cache_data_future_1[fifo_instruction_cache_indexes_future[4'h1]];
	fifo_instruction_cache_data[4'h2]<=fifo_instruction_cache_data_future_2[fifo_instruction_cache_indexes_future[4'h2]];
	fifo_instruction_cache_data[4'h3]<=fifo_instruction_cache_data_future_3[fifo_instruction_cache_indexes_future[4'h3]];
	fifo_instruction_cache_data[4'h4]<=fifo_instruction_cache_data_future_4[fifo_instruction_cache_indexes_future[4'h4]];
	fifo_instruction_cache_data[4'h5]<=fifo_instruction_cache_data_future_5[fifo_instruction_cache_indexes_future[4'h5]];
	fifo_instruction_cache_data[4'h6]<=fifo_instruction_cache_data_future_6[fifo_instruction_cache_indexes_future[4'h6]];
	fifo_instruction_cache_data[4'h7]<=fifo_instruction_cache_data_future_7[fifo_instruction_cache_indexes_future[4'h7]];
	fifo_instruction_cache_data[4'h8]<=fifo_instruction_cache_data_future_8[fifo_instruction_cache_indexes_future[4'h8]];
	fifo_instruction_cache_data[4'h9]<=fifo_instruction_cache_data_future_9[fifo_instruction_cache_indexes_future[4'h9]];
	fifo_instruction_cache_data[4'hA]<=fifo_instruction_cache_data_future_A[fifo_instruction_cache_indexes_future[4'hA]];
	fifo_instruction_cache_data[4'hB]<=fifo_instruction_cache_data_future_B[fifo_instruction_cache_indexes_future[4'hB]];
	fifo_instruction_cache_data[4'hC]<=fifo_instruction_cache_data_future_C[fifo_instruction_cache_indexes_future[4'hC]];
	fifo_instruction_cache_data[4'hD]<=fifo_instruction_cache_data_future_D[fifo_instruction_cache_indexes_future[4'hD]];
	fifo_instruction_cache_data[4'hE]<=fifo_instruction_cache_data_future_E[fifo_instruction_cache_indexes_future[4'hE]];
	fifo_instruction_cache_data[4'hF]<=fifo_instruction_cache_data_future_F[fifo_instruction_cache_indexes_future[4'hF]];
	
	fifo_instruction_cache_addresses[4'h0]<=fifo_instruction_cache_addresses_future_0[fifo_instruction_cache_indexes_future[4'h0]];
	fifo_instruction_cache_addresses[4'h1]<=fifo_instruction_cache_addresses_future_1[fifo_instruction_cache_indexes_future[4'h1]];
	fifo_instruction_cache_addresses[4'h2]<=fifo_instruction_cache_addresses_future_2[fifo_instruction_cache_indexes_future[4'h2]];
	fifo_instruction_cache_addresses[4'h3]<=fifo_instruction_cache_addresses_future_3[fifo_instruction_cache_indexes_future[4'h3]];
	fifo_instruction_cache_addresses[4'h4]<=fifo_instruction_cache_addresses_future_4[fifo_instruction_cache_indexes_future[4'h4]];
	fifo_instruction_cache_addresses[4'h5]<=fifo_instruction_cache_addresses_future_5[fifo_instruction_cache_indexes_future[4'h5]];
	fifo_instruction_cache_addresses[4'h6]<=fifo_instruction_cache_addresses_future_6[fifo_instruction_cache_indexes_future[4'h6]];
	fifo_instruction_cache_addresses[4'h7]<=fifo_instruction_cache_addresses_future_7[fifo_instruction_cache_indexes_future[4'h7]];
	fifo_instruction_cache_addresses[4'h8]<=fifo_instruction_cache_addresses_future_8[fifo_instruction_cache_indexes_future[4'h8]];
	fifo_instruction_cache_addresses[4'h9]<=fifo_instruction_cache_addresses_future_9[fifo_instruction_cache_indexes_future[4'h9]];
	fifo_instruction_cache_addresses[4'hA]<=fifo_instruction_cache_addresses_future_A[fifo_instruction_cache_indexes_future[4'hA]];
	fifo_instruction_cache_addresses[4'hB]<=fifo_instruction_cache_addresses_future_B[fifo_instruction_cache_indexes_future[4'hB]];
	fifo_instruction_cache_addresses[4'hC]<=fifo_instruction_cache_addresses_future_C[fifo_instruction_cache_indexes_future[4'hC]];
	fifo_instruction_cache_addresses[4'hD]<=fifo_instruction_cache_addresses_future_D[fifo_instruction_cache_indexes_future[4'hD]];
	fifo_instruction_cache_addresses[4'hE]<=fifo_instruction_cache_addresses_future_E[fifo_instruction_cache_indexes_future[4'hE]];
	fifo_instruction_cache_addresses[4'hF]<=fifo_instruction_cache_addresses_future_F[fifo_instruction_cache_indexes_future[4'hF]];
	
	fifo_instruction_cache_addresses[4'h0][0]<=1'b0;
	fifo_instruction_cache_addresses[4'h1][0]<=1'b0;
	fifo_instruction_cache_addresses[4'h2][0]<=1'b0;
	fifo_instruction_cache_addresses[4'h3][0]<=1'b0;
	fifo_instruction_cache_addresses[4'h4][0]<=1'b0;
	fifo_instruction_cache_addresses[4'h5][0]<=1'b0;
	fifo_instruction_cache_addresses[4'h6][0]<=1'b0;
	fifo_instruction_cache_addresses[4'h7][0]<=1'b0;
	fifo_instruction_cache_addresses[4'h8][0]<=1'b0;
	fifo_instruction_cache_addresses[4'h9][0]<=1'b0;
	fifo_instruction_cache_addresses[4'hA][0]<=1'b0;
	fifo_instruction_cache_addresses[4'hB][0]<=1'b0;
	fifo_instruction_cache_addresses[4'hC][0]<=1'b0;
	fifo_instruction_cache_addresses[4'hD][0]<=1'b0;
	fifo_instruction_cache_addresses[4'hE][0]<=1'b0;
	fifo_instruction_cache_addresses[4'hF][0]<=1'b0;
end

assign fifo_instruction_cache_addresses_future_0[0]=hyper_jump_guess_address_added[0];
assign fifo_instruction_cache_addresses_future_0[1]=fifo_instruction_cache_addresses[0];
assign fifo_instruction_cache_addresses_future_0[2]=fifo_instruction_cache_addresses[1];
assign fifo_instruction_cache_addresses_future_0[3]=fifo_instruction_cache_addresses[2];
assign fifo_instruction_cache_addresses_future_0[4]=fifo_instruction_cache_addresses[3];
assign fifo_instruction_cache_addresses_future_0[5]=fifo_instruction_cache_addresses[4];
assign fifo_instruction_cache_addresses_future_0[6]=instruction_fetch_address_added[0];
assign fifo_instruction_cache_addresses_future_0[7]=16'hx;
assign fifo_instruction_cache_addresses_future_0[8]=16'hx;
assign fifo_instruction_cache_addresses_future_0[9]=16'hx;
assign fifo_instruction_cache_addresses_future_0[10]=16'hx;
assign fifo_instruction_cache_addresses_future_0[11]=16'hx;
assign fifo_instruction_cache_addresses_future_0[12]=16'hx;
assign fifo_instruction_cache_addresses_future_0[13]=16'hx;

assign fifo_instruction_cache_addresses_future_1[0]=hyper_jump_guess_address_added[1];
assign fifo_instruction_cache_addresses_future_1[1]=fifo_instruction_cache_addresses[1];
assign fifo_instruction_cache_addresses_future_1[2]=fifo_instruction_cache_addresses[2];
assign fifo_instruction_cache_addresses_future_1[3]=fifo_instruction_cache_addresses[3];
assign fifo_instruction_cache_addresses_future_1[4]=fifo_instruction_cache_addresses[4];
assign fifo_instruction_cache_addresses_future_1[5]=fifo_instruction_cache_addresses[5];
assign fifo_instruction_cache_addresses_future_1[6]=instruction_fetch_address_added[0];
assign fifo_instruction_cache_addresses_future_1[7]=instruction_fetch_address_added[1];
assign fifo_instruction_cache_addresses_future_1[8]=16'hx;
assign fifo_instruction_cache_addresses_future_1[9]=16'hx;
assign fifo_instruction_cache_addresses_future_1[10]=16'hx;
assign fifo_instruction_cache_addresses_future_1[11]=16'hx;
assign fifo_instruction_cache_addresses_future_1[12]=16'hx;
assign fifo_instruction_cache_addresses_future_1[13]=16'hx;

assign fifo_instruction_cache_addresses_future_2[0]=hyper_jump_guess_address_added[2];
assign fifo_instruction_cache_addresses_future_2[1]=fifo_instruction_cache_addresses[2];
assign fifo_instruction_cache_addresses_future_2[2]=fifo_instruction_cache_addresses[3];
assign fifo_instruction_cache_addresses_future_2[3]=fifo_instruction_cache_addresses[4];
assign fifo_instruction_cache_addresses_future_2[4]=fifo_instruction_cache_addresses[5];
assign fifo_instruction_cache_addresses_future_2[5]=fifo_instruction_cache_addresses[6];
assign fifo_instruction_cache_addresses_future_2[6]=instruction_fetch_address_added[0];
assign fifo_instruction_cache_addresses_future_2[7]=instruction_fetch_address_added[1];
assign fifo_instruction_cache_addresses_future_2[8]=instruction_fetch_address_added[2];
assign fifo_instruction_cache_addresses_future_2[9]=16'hx;
assign fifo_instruction_cache_addresses_future_2[10]=16'hx;
assign fifo_instruction_cache_addresses_future_2[11]=16'hx;
assign fifo_instruction_cache_addresses_future_2[12]=16'hx;
assign fifo_instruction_cache_addresses_future_2[13]=16'hx;

assign fifo_instruction_cache_addresses_future_3[0]=hyper_jump_guess_address_added[3];
assign fifo_instruction_cache_addresses_future_3[1]=fifo_instruction_cache_addresses[3];
assign fifo_instruction_cache_addresses_future_3[2]=fifo_instruction_cache_addresses[4];
assign fifo_instruction_cache_addresses_future_3[3]=fifo_instruction_cache_addresses[5];
assign fifo_instruction_cache_addresses_future_3[4]=fifo_instruction_cache_addresses[6];
assign fifo_instruction_cache_addresses_future_3[5]=fifo_instruction_cache_addresses[7];
assign fifo_instruction_cache_addresses_future_3[6]=instruction_fetch_address_added[0];
assign fifo_instruction_cache_addresses_future_3[7]=instruction_fetch_address_added[1];
assign fifo_instruction_cache_addresses_future_3[8]=instruction_fetch_address_added[2];
assign fifo_instruction_cache_addresses_future_3[9]=instruction_fetch_address_added[3];
assign fifo_instruction_cache_addresses_future_3[10]=16'hx;
assign fifo_instruction_cache_addresses_future_3[11]=16'hx;
assign fifo_instruction_cache_addresses_future_3[12]=16'hx;
assign fifo_instruction_cache_addresses_future_3[13]=16'hx;

assign fifo_instruction_cache_addresses_future_4[0]=hyper_jump_guess_address_added[4];
assign fifo_instruction_cache_addresses_future_4[1]=fifo_instruction_cache_addresses[4];
assign fifo_instruction_cache_addresses_future_4[2]=fifo_instruction_cache_addresses[5];
assign fifo_instruction_cache_addresses_future_4[3]=fifo_instruction_cache_addresses[6];
assign fifo_instruction_cache_addresses_future_4[4]=fifo_instruction_cache_addresses[7];
assign fifo_instruction_cache_addresses_future_4[5]=fifo_instruction_cache_addresses[8];
assign fifo_instruction_cache_addresses_future_4[6]=instruction_fetch_address_added[0];
assign fifo_instruction_cache_addresses_future_4[7]=instruction_fetch_address_added[1];
assign fifo_instruction_cache_addresses_future_4[8]=instruction_fetch_address_added[2];
assign fifo_instruction_cache_addresses_future_4[9]=instruction_fetch_address_added[3];
assign fifo_instruction_cache_addresses_future_4[10]=instruction_fetch_address_added[4];
assign fifo_instruction_cache_addresses_future_4[11]=16'hx;
assign fifo_instruction_cache_addresses_future_4[12]=16'hx;
assign fifo_instruction_cache_addresses_future_4[13]=16'hx;

assign fifo_instruction_cache_addresses_future_5[0]=hyper_jump_guess_address_added[5];
assign fifo_instruction_cache_addresses_future_5[1]=fifo_instruction_cache_addresses[5];
assign fifo_instruction_cache_addresses_future_5[2]=fifo_instruction_cache_addresses[6];
assign fifo_instruction_cache_addresses_future_5[3]=fifo_instruction_cache_addresses[7];
assign fifo_instruction_cache_addresses_future_5[4]=fifo_instruction_cache_addresses[8];
assign fifo_instruction_cache_addresses_future_5[5]=fifo_instruction_cache_addresses[9];
assign fifo_instruction_cache_addresses_future_5[6]=instruction_fetch_address_added[0];
assign fifo_instruction_cache_addresses_future_5[7]=instruction_fetch_address_added[1];
assign fifo_instruction_cache_addresses_future_5[8]=instruction_fetch_address_added[2];
assign fifo_instruction_cache_addresses_future_5[9]=instruction_fetch_address_added[3];
assign fifo_instruction_cache_addresses_future_5[10]=instruction_fetch_address_added[4];
assign fifo_instruction_cache_addresses_future_5[11]=instruction_fetch_address_added[5];
assign fifo_instruction_cache_addresses_future_5[12]=16'hx;
assign fifo_instruction_cache_addresses_future_5[13]=16'hx;

assign fifo_instruction_cache_addresses_future_6[0]=hyper_jump_guess_address_added[6];
assign fifo_instruction_cache_addresses_future_6[1]=fifo_instruction_cache_addresses[6];
assign fifo_instruction_cache_addresses_future_6[2]=fifo_instruction_cache_addresses[7];
assign fifo_instruction_cache_addresses_future_6[3]=fifo_instruction_cache_addresses[8];
assign fifo_instruction_cache_addresses_future_6[4]=fifo_instruction_cache_addresses[9];
assign fifo_instruction_cache_addresses_future_6[5]=fifo_instruction_cache_addresses[10];
assign fifo_instruction_cache_addresses_future_6[6]=instruction_fetch_address_added[0];
assign fifo_instruction_cache_addresses_future_6[7]=instruction_fetch_address_added[1];
assign fifo_instruction_cache_addresses_future_6[8]=instruction_fetch_address_added[2];
assign fifo_instruction_cache_addresses_future_6[9]=instruction_fetch_address_added[3];
assign fifo_instruction_cache_addresses_future_6[10]=instruction_fetch_address_added[4];
assign fifo_instruction_cache_addresses_future_6[11]=instruction_fetch_address_added[5];
assign fifo_instruction_cache_addresses_future_6[12]=instruction_fetch_address_added[6];
assign fifo_instruction_cache_addresses_future_6[13]=16'hx;

assign fifo_instruction_cache_addresses_future_7[0]=hyper_jump_guess_address_added[7];
assign fifo_instruction_cache_addresses_future_7[1]=fifo_instruction_cache_addresses[7];
assign fifo_instruction_cache_addresses_future_7[2]=fifo_instruction_cache_addresses[8];
assign fifo_instruction_cache_addresses_future_7[3]=fifo_instruction_cache_addresses[9];
assign fifo_instruction_cache_addresses_future_7[4]=fifo_instruction_cache_addresses[10];
assign fifo_instruction_cache_addresses_future_7[5]=fifo_instruction_cache_addresses[11];
assign fifo_instruction_cache_addresses_future_7[6]=instruction_fetch_address_added[0];
assign fifo_instruction_cache_addresses_future_7[7]=instruction_fetch_address_added[1];
assign fifo_instruction_cache_addresses_future_7[8]=instruction_fetch_address_added[2];
assign fifo_instruction_cache_addresses_future_7[9]=instruction_fetch_address_added[3];
assign fifo_instruction_cache_addresses_future_7[10]=instruction_fetch_address_added[4];
assign fifo_instruction_cache_addresses_future_7[11]=instruction_fetch_address_added[5];
assign fifo_instruction_cache_addresses_future_7[12]=instruction_fetch_address_added[6];
assign fifo_instruction_cache_addresses_future_7[13]=instruction_fetch_address_added[7];

assign fifo_instruction_cache_addresses_future_8[0]=hyper_jump_guess_address_added[8];
assign fifo_instruction_cache_addresses_future_8[1]=fifo_instruction_cache_addresses[8];
assign fifo_instruction_cache_addresses_future_8[2]=fifo_instruction_cache_addresses[9];
assign fifo_instruction_cache_addresses_future_8[3]=fifo_instruction_cache_addresses[10];
assign fifo_instruction_cache_addresses_future_8[4]=fifo_instruction_cache_addresses[11];
assign fifo_instruction_cache_addresses_future_8[5]=fifo_instruction_cache_addresses[12];
assign fifo_instruction_cache_addresses_future_8[6]=instruction_fetch_address_added[0];
assign fifo_instruction_cache_addresses_future_8[7]=instruction_fetch_address_added[1];
assign fifo_instruction_cache_addresses_future_8[8]=instruction_fetch_address_added[2];
assign fifo_instruction_cache_addresses_future_8[9]=instruction_fetch_address_added[3];
assign fifo_instruction_cache_addresses_future_8[10]=instruction_fetch_address_added[4];
assign fifo_instruction_cache_addresses_future_8[11]=instruction_fetch_address_added[5];
assign fifo_instruction_cache_addresses_future_8[12]=instruction_fetch_address_added[6];
assign fifo_instruction_cache_addresses_future_8[13]=instruction_fetch_address_added[7];

assign fifo_instruction_cache_addresses_future_9[0]=hyper_jump_guess_address_added[9];
assign fifo_instruction_cache_addresses_future_9[1]=fifo_instruction_cache_addresses[9];
assign fifo_instruction_cache_addresses_future_9[2]=fifo_instruction_cache_addresses[10];
assign fifo_instruction_cache_addresses_future_9[3]=fifo_instruction_cache_addresses[11];
assign fifo_instruction_cache_addresses_future_9[4]=fifo_instruction_cache_addresses[12];
assign fifo_instruction_cache_addresses_future_9[5]=fifo_instruction_cache_addresses[13];
assign fifo_instruction_cache_addresses_future_9[6]=16'hx;
assign fifo_instruction_cache_addresses_future_9[7]=instruction_fetch_address_added[1];
assign fifo_instruction_cache_addresses_future_9[8]=instruction_fetch_address_added[2];
assign fifo_instruction_cache_addresses_future_9[9]=instruction_fetch_address_added[3];
assign fifo_instruction_cache_addresses_future_9[10]=instruction_fetch_address_added[4];
assign fifo_instruction_cache_addresses_future_9[11]=instruction_fetch_address_added[5];
assign fifo_instruction_cache_addresses_future_9[12]=instruction_fetch_address_added[6];
assign fifo_instruction_cache_addresses_future_9[13]=instruction_fetch_address_added[7];

assign fifo_instruction_cache_addresses_future_A[0]=hyper_jump_guess_address_added[10];
assign fifo_instruction_cache_addresses_future_A[1]=fifo_instruction_cache_addresses[10];
assign fifo_instruction_cache_addresses_future_A[2]=fifo_instruction_cache_addresses[11];
assign fifo_instruction_cache_addresses_future_A[3]=fifo_instruction_cache_addresses[12];
assign fifo_instruction_cache_addresses_future_A[4]=fifo_instruction_cache_addresses[13];
assign fifo_instruction_cache_addresses_future_A[5]=fifo_instruction_cache_addresses[14];
assign fifo_instruction_cache_addresses_future_A[6]=16'hx;
assign fifo_instruction_cache_addresses_future_A[7]=16'hx;
assign fifo_instruction_cache_addresses_future_A[8]=instruction_fetch_address_added[2];
assign fifo_instruction_cache_addresses_future_A[9]=instruction_fetch_address_added[3];
assign fifo_instruction_cache_addresses_future_A[10]=instruction_fetch_address_added[4];
assign fifo_instruction_cache_addresses_future_A[11]=instruction_fetch_address_added[5];
assign fifo_instruction_cache_addresses_future_A[12]=instruction_fetch_address_added[6];
assign fifo_instruction_cache_addresses_future_A[13]=instruction_fetch_address_added[7];

assign fifo_instruction_cache_addresses_future_B[0]=hyper_jump_guess_address_added[11];
assign fifo_instruction_cache_addresses_future_B[1]=fifo_instruction_cache_addresses[11];
assign fifo_instruction_cache_addresses_future_B[2]=fifo_instruction_cache_addresses[12];
assign fifo_instruction_cache_addresses_future_B[3]=fifo_instruction_cache_addresses[13];
assign fifo_instruction_cache_addresses_future_B[4]=fifo_instruction_cache_addresses[14];
assign fifo_instruction_cache_addresses_future_B[5]=fifo_instruction_cache_addresses[15];
assign fifo_instruction_cache_addresses_future_B[6]=16'hx;
assign fifo_instruction_cache_addresses_future_B[7]=16'hx;
assign fifo_instruction_cache_addresses_future_B[8]=16'hx;
assign fifo_instruction_cache_addresses_future_B[9]=instruction_fetch_address_added[3];
assign fifo_instruction_cache_addresses_future_B[10]=instruction_fetch_address_added[4];
assign fifo_instruction_cache_addresses_future_B[11]=instruction_fetch_address_added[5];
assign fifo_instruction_cache_addresses_future_B[12]=instruction_fetch_address_added[6];
assign fifo_instruction_cache_addresses_future_B[13]=instruction_fetch_address_added[7];

assign fifo_instruction_cache_addresses_future_C[0]=hyper_jump_guess_address_added[12];
assign fifo_instruction_cache_addresses_future_C[1]=fifo_instruction_cache_addresses[12];
assign fifo_instruction_cache_addresses_future_C[2]=fifo_instruction_cache_addresses[13];
assign fifo_instruction_cache_addresses_future_C[3]=fifo_instruction_cache_addresses[14];
assign fifo_instruction_cache_addresses_future_C[4]=fifo_instruction_cache_addresses[15];
assign fifo_instruction_cache_addresses_future_C[5]=16'hx;
assign fifo_instruction_cache_addresses_future_C[6]=16'hx;
assign fifo_instruction_cache_addresses_future_C[7]=16'hx;
assign fifo_instruction_cache_addresses_future_C[8]=16'hx;
assign fifo_instruction_cache_addresses_future_C[9]=16'hx;
assign fifo_instruction_cache_addresses_future_C[10]=instruction_fetch_address_added[4];
assign fifo_instruction_cache_addresses_future_C[11]=instruction_fetch_address_added[5];
assign fifo_instruction_cache_addresses_future_C[12]=instruction_fetch_address_added[6];
assign fifo_instruction_cache_addresses_future_C[13]=instruction_fetch_address_added[7];

assign fifo_instruction_cache_addresses_future_D[0]=hyper_jump_guess_address_added[13];
assign fifo_instruction_cache_addresses_future_D[1]=fifo_instruction_cache_addresses[13];
assign fifo_instruction_cache_addresses_future_D[2]=fifo_instruction_cache_addresses[14];
assign fifo_instruction_cache_addresses_future_D[3]=fifo_instruction_cache_addresses[15];
assign fifo_instruction_cache_addresses_future_D[4]=16'hx;
assign fifo_instruction_cache_addresses_future_D[5]=16'hx;
assign fifo_instruction_cache_addresses_future_D[6]=16'hx;
assign fifo_instruction_cache_addresses_future_D[7]=16'hx;
assign fifo_instruction_cache_addresses_future_D[8]=16'hx;
assign fifo_instruction_cache_addresses_future_D[9]=16'hx;
assign fifo_instruction_cache_addresses_future_D[10]=16'hx;
assign fifo_instruction_cache_addresses_future_D[11]=instruction_fetch_address_added[5];
assign fifo_instruction_cache_addresses_future_D[12]=instruction_fetch_address_added[6];
assign fifo_instruction_cache_addresses_future_D[13]=instruction_fetch_address_added[7];

assign fifo_instruction_cache_addresses_future_E[0]=hyper_jump_guess_address_added[14];
assign fifo_instruction_cache_addresses_future_E[1]=fifo_instruction_cache_addresses[14];
assign fifo_instruction_cache_addresses_future_E[2]=fifo_instruction_cache_addresses[15];
assign fifo_instruction_cache_addresses_future_E[3]=16'hx;
assign fifo_instruction_cache_addresses_future_E[4]=16'hx;
assign fifo_instruction_cache_addresses_future_E[5]=16'hx;
assign fifo_instruction_cache_addresses_future_E[6]=16'hx;
assign fifo_instruction_cache_addresses_future_E[7]=16'hx;
assign fifo_instruction_cache_addresses_future_E[8]=16'hx;
assign fifo_instruction_cache_addresses_future_E[9]=16'hx;
assign fifo_instruction_cache_addresses_future_E[10]=16'hx;
assign fifo_instruction_cache_addresses_future_E[11]=16'hx;
assign fifo_instruction_cache_addresses_future_E[12]=instruction_fetch_address_added[6];
assign fifo_instruction_cache_addresses_future_E[13]=instruction_fetch_address_added[7];

assign fifo_instruction_cache_addresses_future_F[0]=hyper_jump_guess_address_added[15];
assign fifo_instruction_cache_addresses_future_F[1]=fifo_instruction_cache_addresses[15];
assign fifo_instruction_cache_addresses_future_F[2]=16'hx;
assign fifo_instruction_cache_addresses_future_F[3]=16'hx;
assign fifo_instruction_cache_addresses_future_F[4]=16'hx;
assign fifo_instruction_cache_addresses_future_F[5]=16'hx;
assign fifo_instruction_cache_addresses_future_F[6]=16'hx;
assign fifo_instruction_cache_addresses_future_F[7]=16'hx;
assign fifo_instruction_cache_addresses_future_F[8]=16'hx;
assign fifo_instruction_cache_addresses_future_F[9]=16'hx;
assign fifo_instruction_cache_addresses_future_F[10]=16'hx;
assign fifo_instruction_cache_addresses_future_F[11]=16'hx;
assign fifo_instruction_cache_addresses_future_F[12]=16'hx;
assign fifo_instruction_cache_addresses_future_F[13]=instruction_fetch_address_added[7];

///////

assign fifo_instruction_cache_data_future_0[0]=hyper_instruction_fetch_storage[0];
assign fifo_instruction_cache_data_future_0[1]=fifo_instruction_cache_data[0];
assign fifo_instruction_cache_data_future_0[2]=fifo_instruction_cache_data[1];
assign fifo_instruction_cache_data_future_0[3]=fifo_instruction_cache_data[2];
assign fifo_instruction_cache_data_future_0[4]=fifo_instruction_cache_data[3];
assign fifo_instruction_cache_data_future_0[5]=fifo_instruction_cache_data[4];
assign fifo_instruction_cache_data_future_0[6]=mem_data_out_type_0[0];
assign fifo_instruction_cache_data_future_0[7]=16'hx;
assign fifo_instruction_cache_data_future_0[8]=16'hx;
assign fifo_instruction_cache_data_future_0[9]=16'hx;
assign fifo_instruction_cache_data_future_0[10]=16'hx;
assign fifo_instruction_cache_data_future_0[11]=16'hx;
assign fifo_instruction_cache_data_future_0[12]=16'hx;
assign fifo_instruction_cache_data_future_0[13]=16'hx;

assign fifo_instruction_cache_data_future_1[0]=hyper_instruction_fetch_storage[1];
assign fifo_instruction_cache_data_future_1[1]=fifo_instruction_cache_data[1];
assign fifo_instruction_cache_data_future_1[2]=fifo_instruction_cache_data[2];
assign fifo_instruction_cache_data_future_1[3]=fifo_instruction_cache_data[3];
assign fifo_instruction_cache_data_future_1[4]=fifo_instruction_cache_data[4];
assign fifo_instruction_cache_data_future_1[5]=fifo_instruction_cache_data[5];
assign fifo_instruction_cache_data_future_1[6]=mem_data_out_type_0[0];
assign fifo_instruction_cache_data_future_1[7]=mem_data_out_type_0[1];
assign fifo_instruction_cache_data_future_1[8]=16'hx;
assign fifo_instruction_cache_data_future_1[9]=16'hx;
assign fifo_instruction_cache_data_future_1[10]=16'hx;
assign fifo_instruction_cache_data_future_1[11]=16'hx;
assign fifo_instruction_cache_data_future_1[12]=16'hx;
assign fifo_instruction_cache_data_future_1[13]=16'hx;

assign fifo_instruction_cache_data_future_2[0]=hyper_instruction_fetch_storage[2];
assign fifo_instruction_cache_data_future_2[1]=fifo_instruction_cache_data[2];
assign fifo_instruction_cache_data_future_2[2]=fifo_instruction_cache_data[3];
assign fifo_instruction_cache_data_future_2[3]=fifo_instruction_cache_data[4];
assign fifo_instruction_cache_data_future_2[4]=fifo_instruction_cache_data[5];
assign fifo_instruction_cache_data_future_2[5]=fifo_instruction_cache_data[6];
assign fifo_instruction_cache_data_future_2[6]=mem_data_out_type_0[0];
assign fifo_instruction_cache_data_future_2[7]=mem_data_out_type_0[1];
assign fifo_instruction_cache_data_future_2[8]=mem_data_out_type_0[2];
assign fifo_instruction_cache_data_future_2[9]=16'hx;
assign fifo_instruction_cache_data_future_2[10]=16'hx;
assign fifo_instruction_cache_data_future_2[11]=16'hx;
assign fifo_instruction_cache_data_future_2[12]=16'hx;
assign fifo_instruction_cache_data_future_2[13]=16'hx;

assign fifo_instruction_cache_data_future_3[0]=hyper_instruction_fetch_storage[3];
assign fifo_instruction_cache_data_future_3[1]=fifo_instruction_cache_data[3];
assign fifo_instruction_cache_data_future_3[2]=fifo_instruction_cache_data[4];
assign fifo_instruction_cache_data_future_3[3]=fifo_instruction_cache_data[5];
assign fifo_instruction_cache_data_future_3[4]=fifo_instruction_cache_data[6];
assign fifo_instruction_cache_data_future_3[5]=fifo_instruction_cache_data[7];
assign fifo_instruction_cache_data_future_3[6]=mem_data_out_type_0[0];
assign fifo_instruction_cache_data_future_3[7]=mem_data_out_type_0[1];
assign fifo_instruction_cache_data_future_3[8]=mem_data_out_type_0[2];
assign fifo_instruction_cache_data_future_3[9]=mem_data_out_type_0[3];
assign fifo_instruction_cache_data_future_3[10]=16'hx;
assign fifo_instruction_cache_data_future_3[11]=16'hx;
assign fifo_instruction_cache_data_future_3[12]=16'hx;
assign fifo_instruction_cache_data_future_3[13]=16'hx;

assign fifo_instruction_cache_data_future_4[0]=hyper_instruction_fetch_storage[4];
assign fifo_instruction_cache_data_future_4[1]=fifo_instruction_cache_data[4];
assign fifo_instruction_cache_data_future_4[2]=fifo_instruction_cache_data[5];
assign fifo_instruction_cache_data_future_4[3]=fifo_instruction_cache_data[6];
assign fifo_instruction_cache_data_future_4[4]=fifo_instruction_cache_data[7];
assign fifo_instruction_cache_data_future_4[5]=fifo_instruction_cache_data[8];
assign fifo_instruction_cache_data_future_4[6]=mem_data_out_type_0[0];
assign fifo_instruction_cache_data_future_4[7]=mem_data_out_type_0[1];
assign fifo_instruction_cache_data_future_4[8]=mem_data_out_type_0[2];
assign fifo_instruction_cache_data_future_4[9]=mem_data_out_type_0[3];
assign fifo_instruction_cache_data_future_4[10]=mem_data_out_type_0[4];
assign fifo_instruction_cache_data_future_4[11]=16'hx;
assign fifo_instruction_cache_data_future_4[12]=16'hx;
assign fifo_instruction_cache_data_future_4[13]=16'hx;

assign fifo_instruction_cache_data_future_5[0]=hyper_instruction_fetch_storage[5];
assign fifo_instruction_cache_data_future_5[1]=fifo_instruction_cache_data[5];
assign fifo_instruction_cache_data_future_5[2]=fifo_instruction_cache_data[6];
assign fifo_instruction_cache_data_future_5[3]=fifo_instruction_cache_data[7];
assign fifo_instruction_cache_data_future_5[4]=fifo_instruction_cache_data[8];
assign fifo_instruction_cache_data_future_5[5]=fifo_instruction_cache_data[9];
assign fifo_instruction_cache_data_future_5[6]=mem_data_out_type_0[0];
assign fifo_instruction_cache_data_future_5[7]=mem_data_out_type_0[1];
assign fifo_instruction_cache_data_future_5[8]=mem_data_out_type_0[2];
assign fifo_instruction_cache_data_future_5[9]=mem_data_out_type_0[3];
assign fifo_instruction_cache_data_future_5[10]=mem_data_out_type_0[4];
assign fifo_instruction_cache_data_future_5[11]=mem_data_out_type_0[5];
assign fifo_instruction_cache_data_future_5[12]=16'hx;
assign fifo_instruction_cache_data_future_5[13]=16'hx;

assign fifo_instruction_cache_data_future_6[0]=hyper_instruction_fetch_storage[6];
assign fifo_instruction_cache_data_future_6[1]=fifo_instruction_cache_data[6];
assign fifo_instruction_cache_data_future_6[2]=fifo_instruction_cache_data[7];
assign fifo_instruction_cache_data_future_6[3]=fifo_instruction_cache_data[8];
assign fifo_instruction_cache_data_future_6[4]=fifo_instruction_cache_data[9];
assign fifo_instruction_cache_data_future_6[5]=fifo_instruction_cache_data[10];
assign fifo_instruction_cache_data_future_6[6]=mem_data_out_type_0[0];
assign fifo_instruction_cache_data_future_6[7]=mem_data_out_type_0[1];
assign fifo_instruction_cache_data_future_6[8]=mem_data_out_type_0[2];
assign fifo_instruction_cache_data_future_6[9]=mem_data_out_type_0[3];
assign fifo_instruction_cache_data_future_6[10]=mem_data_out_type_0[4];
assign fifo_instruction_cache_data_future_6[11]=mem_data_out_type_0[5];
assign fifo_instruction_cache_data_future_6[12]=mem_data_out_type_0[6];
assign fifo_instruction_cache_data_future_6[13]=16'hx;

assign fifo_instruction_cache_data_future_7[0]=hyper_instruction_fetch_storage[7];
assign fifo_instruction_cache_data_future_7[1]=fifo_instruction_cache_data[7];
assign fifo_instruction_cache_data_future_7[2]=fifo_instruction_cache_data[8];
assign fifo_instruction_cache_data_future_7[3]=fifo_instruction_cache_data[9];
assign fifo_instruction_cache_data_future_7[4]=fifo_instruction_cache_data[10];
assign fifo_instruction_cache_data_future_7[5]=fifo_instruction_cache_data[11];
assign fifo_instruction_cache_data_future_7[6]=mem_data_out_type_0[0];
assign fifo_instruction_cache_data_future_7[7]=mem_data_out_type_0[1];
assign fifo_instruction_cache_data_future_7[8]=mem_data_out_type_0[2];
assign fifo_instruction_cache_data_future_7[9]=mem_data_out_type_0[3];
assign fifo_instruction_cache_data_future_7[10]=mem_data_out_type_0[4];
assign fifo_instruction_cache_data_future_7[11]=mem_data_out_type_0[5];
assign fifo_instruction_cache_data_future_7[12]=mem_data_out_type_0[6];
assign fifo_instruction_cache_data_future_7[13]=mem_data_out_type_0[7];

assign fifo_instruction_cache_data_future_8[0]=hyper_instruction_fetch_storage[8];
assign fifo_instruction_cache_data_future_8[1]=fifo_instruction_cache_data[8];
assign fifo_instruction_cache_data_future_8[2]=fifo_instruction_cache_data[9];
assign fifo_instruction_cache_data_future_8[3]=fifo_instruction_cache_data[10];
assign fifo_instruction_cache_data_future_8[4]=fifo_instruction_cache_data[11];
assign fifo_instruction_cache_data_future_8[5]=fifo_instruction_cache_data[12];
assign fifo_instruction_cache_data_future_8[6]=mem_data_out_type_0[0];
assign fifo_instruction_cache_data_future_8[7]=mem_data_out_type_0[1];
assign fifo_instruction_cache_data_future_8[8]=mem_data_out_type_0[2];
assign fifo_instruction_cache_data_future_8[9]=mem_data_out_type_0[3];
assign fifo_instruction_cache_data_future_8[10]=mem_data_out_type_0[4];
assign fifo_instruction_cache_data_future_8[11]=mem_data_out_type_0[5];
assign fifo_instruction_cache_data_future_8[12]=mem_data_out_type_0[6];
assign fifo_instruction_cache_data_future_8[13]=mem_data_out_type_0[7];

assign fifo_instruction_cache_data_future_9[0]=hyper_instruction_fetch_storage[9];
assign fifo_instruction_cache_data_future_9[1]=fifo_instruction_cache_data[9];
assign fifo_instruction_cache_data_future_9[2]=fifo_instruction_cache_data[10];
assign fifo_instruction_cache_data_future_9[3]=fifo_instruction_cache_data[11];
assign fifo_instruction_cache_data_future_9[4]=fifo_instruction_cache_data[12];
assign fifo_instruction_cache_data_future_9[5]=fifo_instruction_cache_data[13];
assign fifo_instruction_cache_data_future_9[6]=16'hx;
assign fifo_instruction_cache_data_future_9[7]=mem_data_out_type_0[1];
assign fifo_instruction_cache_data_future_9[8]=mem_data_out_type_0[2];
assign fifo_instruction_cache_data_future_9[9]=mem_data_out_type_0[3];
assign fifo_instruction_cache_data_future_9[10]=mem_data_out_type_0[4];
assign fifo_instruction_cache_data_future_9[11]=mem_data_out_type_0[5];
assign fifo_instruction_cache_data_future_9[12]=mem_data_out_type_0[6];
assign fifo_instruction_cache_data_future_9[13]=mem_data_out_type_0[7];

assign fifo_instruction_cache_data_future_A[0]=hyper_instruction_fetch_storage[10];
assign fifo_instruction_cache_data_future_A[1]=fifo_instruction_cache_data[10];
assign fifo_instruction_cache_data_future_A[2]=fifo_instruction_cache_data[11];
assign fifo_instruction_cache_data_future_A[3]=fifo_instruction_cache_data[12];
assign fifo_instruction_cache_data_future_A[4]=fifo_instruction_cache_data[13];
assign fifo_instruction_cache_data_future_A[5]=fifo_instruction_cache_data[14];
assign fifo_instruction_cache_data_future_A[6]=16'hx;
assign fifo_instruction_cache_data_future_A[7]=16'hx;
assign fifo_instruction_cache_data_future_A[8]=mem_data_out_type_0[2];
assign fifo_instruction_cache_data_future_A[9]=mem_data_out_type_0[3];
assign fifo_instruction_cache_data_future_A[10]=mem_data_out_type_0[4];
assign fifo_instruction_cache_data_future_A[11]=mem_data_out_type_0[5];
assign fifo_instruction_cache_data_future_A[12]=mem_data_out_type_0[6];
assign fifo_instruction_cache_data_future_A[13]=mem_data_out_type_0[7];

assign fifo_instruction_cache_data_future_B[0]=hyper_instruction_fetch_storage[11];
assign fifo_instruction_cache_data_future_B[1]=fifo_instruction_cache_data[11];
assign fifo_instruction_cache_data_future_B[2]=fifo_instruction_cache_data[12];
assign fifo_instruction_cache_data_future_B[3]=fifo_instruction_cache_data[13];
assign fifo_instruction_cache_data_future_B[4]=fifo_instruction_cache_data[14];
assign fifo_instruction_cache_data_future_B[5]=fifo_instruction_cache_data[15];
assign fifo_instruction_cache_data_future_B[6]=16'hx;
assign fifo_instruction_cache_data_future_B[7]=16'hx;
assign fifo_instruction_cache_data_future_B[8]=16'hx;
assign fifo_instruction_cache_data_future_B[9]=mem_data_out_type_0[3];
assign fifo_instruction_cache_data_future_B[10]=mem_data_out_type_0[4];
assign fifo_instruction_cache_data_future_B[11]=mem_data_out_type_0[5];
assign fifo_instruction_cache_data_future_B[12]=mem_data_out_type_0[6];
assign fifo_instruction_cache_data_future_B[13]=mem_data_out_type_0[7];

assign fifo_instruction_cache_data_future_C[0]=hyper_instruction_fetch_storage[12];
assign fifo_instruction_cache_data_future_C[1]=fifo_instruction_cache_data[12];
assign fifo_instruction_cache_data_future_C[2]=fifo_instruction_cache_data[13];
assign fifo_instruction_cache_data_future_C[3]=fifo_instruction_cache_data[14];
assign fifo_instruction_cache_data_future_C[4]=fifo_instruction_cache_data[15];
assign fifo_instruction_cache_data_future_C[5]=16'hx;
assign fifo_instruction_cache_data_future_C[6]=16'hx;
assign fifo_instruction_cache_data_future_C[7]=16'hx;
assign fifo_instruction_cache_data_future_C[8]=16'hx;
assign fifo_instruction_cache_data_future_C[9]=16'hx;
assign fifo_instruction_cache_data_future_C[10]=mem_data_out_type_0[4];
assign fifo_instruction_cache_data_future_C[11]=mem_data_out_type_0[5];
assign fifo_instruction_cache_data_future_C[12]=mem_data_out_type_0[6];
assign fifo_instruction_cache_data_future_C[13]=mem_data_out_type_0[7];

assign fifo_instruction_cache_data_future_D[0]=hyper_instruction_fetch_storage[13];
assign fifo_instruction_cache_data_future_D[1]=fifo_instruction_cache_data[13];
assign fifo_instruction_cache_data_future_D[2]=fifo_instruction_cache_data[14];
assign fifo_instruction_cache_data_future_D[3]=fifo_instruction_cache_data[15];
assign fifo_instruction_cache_data_future_D[4]=16'hx;
assign fifo_instruction_cache_data_future_D[5]=16'hx;
assign fifo_instruction_cache_data_future_D[6]=16'hx;
assign fifo_instruction_cache_data_future_D[7]=16'hx;
assign fifo_instruction_cache_data_future_D[8]=16'hx;
assign fifo_instruction_cache_data_future_D[9]=16'hx;
assign fifo_instruction_cache_data_future_D[10]=16'hx;
assign fifo_instruction_cache_data_future_D[11]=mem_data_out_type_0[5];
assign fifo_instruction_cache_data_future_D[12]=mem_data_out_type_0[6];
assign fifo_instruction_cache_data_future_D[13]=mem_data_out_type_0[7];

assign fifo_instruction_cache_data_future_E[0]=hyper_instruction_fetch_storage[14];
assign fifo_instruction_cache_data_future_E[1]=fifo_instruction_cache_data[14];
assign fifo_instruction_cache_data_future_E[2]=fifo_instruction_cache_data[15];
assign fifo_instruction_cache_data_future_E[3]=16'hx;
assign fifo_instruction_cache_data_future_E[4]=16'hx;
assign fifo_instruction_cache_data_future_E[5]=16'hx;
assign fifo_instruction_cache_data_future_E[6]=16'hx;
assign fifo_instruction_cache_data_future_E[7]=16'hx;
assign fifo_instruction_cache_data_future_E[8]=16'hx;
assign fifo_instruction_cache_data_future_E[9]=16'hx;
assign fifo_instruction_cache_data_future_E[10]=16'hx;
assign fifo_instruction_cache_data_future_E[11]=16'hx;
assign fifo_instruction_cache_data_future_E[12]=mem_data_out_type_0[6];
assign fifo_instruction_cache_data_future_E[13]=mem_data_out_type_0[7];

assign fifo_instruction_cache_data_future_F[0]=hyper_instruction_fetch_storage[15];
assign fifo_instruction_cache_data_future_F[1]=fifo_instruction_cache_data[15];
assign fifo_instruction_cache_data_future_F[2]=16'hx;
assign fifo_instruction_cache_data_future_F[3]=16'hx;
assign fifo_instruction_cache_data_future_F[4]=16'hx;
assign fifo_instruction_cache_data_future_F[5]=16'hx;
assign fifo_instruction_cache_data_future_F[6]=16'hx;
assign fifo_instruction_cache_data_future_F[7]=16'hx;
assign fifo_instruction_cache_data_future_F[8]=16'hx;
assign fifo_instruction_cache_data_future_F[9]=16'hx;
assign fifo_instruction_cache_data_future_F[10]=16'hx;
assign fifo_instruction_cache_data_future_F[11]=16'hx;
assign fifo_instruction_cache_data_future_F[12]=16'hx;
assign fifo_instruction_cache_data_future_F[13]=mem_data_out_type_0[7];


endmodule

