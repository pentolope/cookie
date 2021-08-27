`timescale 1 ps / 1 ps

`include "instruction_cache_mux.sv"

module instruction_cache(
	output mem_is_instruction_fetch_requesting,
	output mem_is_hyper_instruction_fetch_0_requesting,
	output mem_is_hyper_instruction_fetch_1_requesting,
	output mem_void_hyper_instruction_fetch,
	output is_performing_jump_state_e,
	output is_performing_jump_e,
	output [4:0] fifo_instruction_cache_size_e,
	output [4:0] fifo_instruction_cache_size_next_e,
	output [25:0] mem_target_address_instruction_fetch,
	output [25:0] mem_target_address_hyper_instruction_fetch_0,
	output [25:0] mem_target_address_hyper_instruction_fetch_1,
	output [15:0] new_instruction_table [3:0],
	output [25:0] new_instruction_address_table [3:0],
	
	input  [4:0] fifo_instruction_cache_size_after_read,
	input  [2:0] fifo_instruction_cache_consume_count,
	input  mem_is_instruction_fetch_acknowledged_pulse,
	input  mem_is_hyper_instruction_fetch_0_acknowledged_pulse,
	input  mem_is_hyper_instruction_fetch_1_acknowledged_pulse,
	input  is_performing_jump_instant_on,
	input  [31:0] instruction_jump_address_selected,
	input  [15:0] mem_data_out_type_0 [7:0],
	input  [15:0] user_reg [15:0],
	input  main_clk
);

reg [4:0] fifo_instruction_cache_size=0;
assign fifo_instruction_cache_size_e=fifo_instruction_cache_size;

wire [25:0] target_address_instruction_fetch;
assign mem_target_address_instruction_fetch=target_address_instruction_fetch;

wire [2:0] instruction_fetch_returning_word_count=3'd7-target_address_instruction_fetch[3:1];
wire [3:0] instruction_fetch_returning_word_count_actual={1'b0,instruction_fetch_returning_word_count}+1'b1;

reg [25:0] target_address_hyper_instruction_fetch_0;
reg [25:0] target_address_hyper_instruction_fetch_1;

assign mem_target_address_hyper_instruction_fetch_0=target_address_hyper_instruction_fetch_0;
assign mem_target_address_hyper_instruction_fetch_1=target_address_hyper_instruction_fetch_1;

reg  is_hyper_instruction_fetch_0_requesting=0;
reg  is_hyper_instruction_fetch_1_requesting=0;
reg  will_hyper_instruction_fetch_1_request_after=0;
assign mem_is_hyper_instruction_fetch_0_requesting=is_hyper_instruction_fetch_0_requesting;
assign mem_is_hyper_instruction_fetch_1_requesting=is_hyper_instruction_fetch_1_requesting;

reg void_hyper_instruction_fetch=0;
assign mem_void_hyper_instruction_fetch=void_hyper_instruction_fetch;

reg [4:0] hyper_instruction_fetch_size;

reg is_instruction_cache_requesting=0;
reg [25:0] instruction_fetch_address=26'h7FE0;

reg is_performing_jump_state=0;
wire is_performing_jump=is_performing_jump_instant_on?1'b1:is_performing_jump_state;

assign is_performing_jump_state_e=is_performing_jump_state;
assign is_performing_jump_e=is_performing_jump;

reg [25:0] instruction_jump_address_saved=0;
wire [25:0] instruction_jump_address=is_performing_jump_instant_on?(instruction_jump_address_selected[25:0]):instruction_jump_address_saved;

reg isWaitingForJump=0;

reg hyper_jump_potentially_valid_type0=0; // type0 is if the hyper_jump_guess_address_saved is ready
reg hyper_jump_potentially_valid_type1=0; // type1 is if either source_table or address_table was just filled
reg hyper_jump_potentially_valid_type2=0; // type2 is if source_table should be used, otherwise address_table should be used
reg hyper_jump_potentially_valid_type3=0; // type3 is if this hyper jump calculation is instead from the alternative version, which means this hyper jump was initiated from the hyper jump data
reg [2:0] hyper_jump_look_index;
reg [3:0] hyper_jump_look_index_alt;

assign mem_is_instruction_fetch_requesting=is_instruction_cache_requesting;
assign target_address_instruction_fetch=instruction_fetch_address;

reg [15:0] hyper_instruction_fetch_storage [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
reg [31:0] hyper_jump_guess_address_table [7:0];
reg [7:0] hyper_jump_guess_source_table [7:0];
reg [31:0] hyper_jump_guess_address_saved=0;

wire [31:0] hyper_jump_guess_address_calc;
wire [31:0] hyper_jump_guess_address_calc_alt;
wire [15:0] fifo_instruction_cache_data_at_write_addr_m1;
wire [15:0] fifo_instruction_cache_data_at_write_addr_m2;
wire [15:0] fifo_instruction_cache_data_at_write_addr_m3;
wire [15:0] fifo_instruction_cache_data_at_write_addr_m4;

reg [4:0] fifo_instruction_cache_size_next;
assign fifo_instruction_cache_size_next_e=fifo_instruction_cache_size_next;
always_comb begin
	fifo_instruction_cache_size_next=fifo_instruction_cache_size_after_read;
	if (is_performing_jump) fifo_instruction_cache_size_next=0;
	
	if (is_instruction_cache_requesting) begin
		if (mem_is_instruction_fetch_acknowledged_pulse) begin
			if (!is_performing_jump) begin
				fifo_instruction_cache_size_next=fifo_instruction_cache_size_after_read+instruction_fetch_returning_word_count_actual;
			end
		end
	end else begin
		if (is_performing_jump) begin
			if (hyper_jump_potentially_valid_type0 && !is_hyper_instruction_fetch_0_requesting && instruction_jump_address[25:1]==hyper_jump_guess_address_saved[25:1]) begin
				fifo_instruction_cache_size_next=hyper_instruction_fetch_size;
			end
		end
	end
end

instruction_cache_mux instruction_cache_mux_inst(
	hyper_jump_guess_address_calc,
	hyper_jump_guess_address_calc_alt,
	fifo_instruction_cache_data_at_write_addr_m1,
	fifo_instruction_cache_data_at_write_addr_m2,
	fifo_instruction_cache_data_at_write_addr_m3,
	fifo_instruction_cache_data_at_write_addr_m4,
	new_instruction_table,
	new_instruction_address_table,
	
	hyper_instruction_fetch_storage,
	hyper_jump_guess_address_table,
	hyper_jump_guess_source_table,
	mem_data_out_type_0,
	fifo_instruction_cache_size,
	fifo_instruction_cache_size_after_read,
	fifo_instruction_cache_consume_count,
	instruction_fetch_address,
	hyper_jump_guess_address_saved,
	hyper_jump_potentially_valid_type0,
	hyper_jump_potentially_valid_type1,
	hyper_jump_potentially_valid_type2,
	hyper_jump_potentially_valid_type3,
	!is_instruction_cache_requesting && is_performing_jump && hyper_jump_potentially_valid_type0 && !is_hyper_instruction_fetch_0_requesting, // this doesn't bother to check if the hyper jump address is identical to the true address because that doesn't need to matter for if the hyper jump data is inserted into the instruction cache (there is nothing important there anyway)
	hyper_jump_look_index,
	hyper_jump_look_index_alt,
	user_reg,
	main_clk
);

always @(posedge main_clk) fifo_instruction_cache_size<=fifo_instruction_cache_size_next;


always @(posedge main_clk) begin
	will_hyper_instruction_fetch_1_request_after<=0;
	void_hyper_instruction_fetch<=0;
	instruction_jump_address_saved<=instruction_jump_address;
	instruction_jump_address_saved[0]<=1'b0;
	is_performing_jump_state<=is_performing_jump;
	
	is_hyper_instruction_fetch_0_requesting<=mem_is_hyper_instruction_fetch_0_acknowledged_pulse?1'b0:is_hyper_instruction_fetch_0_requesting;
	is_hyper_instruction_fetch_1_requesting<=mem_is_hyper_instruction_fetch_1_acknowledged_pulse?1'b0:(is_hyper_instruction_fetch_1_requesting | will_hyper_instruction_fetch_1_request_after);
	
	if (will_hyper_instruction_fetch_1_request_after) begin
		target_address_hyper_instruction_fetch_1<={target_address_hyper_instruction_fetch_0[25:4]+1'b1,4'b0};
	end
	
	if (hyper_jump_potentially_valid_type1) begin
		if (hyper_jump_potentially_valid_type3) begin
			hyper_jump_guess_address_saved<=hyper_jump_guess_address_calc_alt;
			target_address_hyper_instruction_fetch_0<={hyper_jump_guess_address_calc_alt[25:1],1'b0};
		end else begin
			hyper_jump_guess_address_saved<=hyper_jump_guess_address_calc;
			target_address_hyper_instruction_fetch_0<={hyper_jump_guess_address_calc[25:1],1'b0};
		end
		hyper_jump_potentially_valid_type2<=0;
		hyper_jump_potentially_valid_type1<=0;
		hyper_jump_potentially_valid_type0<=1;
		is_hyper_instruction_fetch_0_requesting<=1;
		is_hyper_instruction_fetch_1_requesting<=0;
		will_hyper_instruction_fetch_1_request_after<=1;
		hyper_instruction_fetch_size<=0;
	end
	if (mem_is_hyper_instruction_fetch_0_acknowledged_pulse) begin
		hyper_instruction_fetch_size<=(4'd7-target_address_hyper_instruction_fetch_0[3:1])+1'b1;
		hyper_instruction_fetch_storage[7:0]<=mem_data_out_type_0;
	end else if (mem_is_hyper_instruction_fetch_1_acknowledged_pulse && !is_hyper_instruction_fetch_0_requesting) begin
		hyper_instruction_fetch_size<=hyper_instruction_fetch_size+5'h8;
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
	
	if (is_instruction_cache_requesting) begin
		if (mem_is_instruction_fetch_acknowledged_pulse) begin
			if (is_performing_jump) begin
				is_performing_jump_state<=0;
				isWaitingForJump<=0;
				instruction_fetch_address<=instruction_jump_address;
				is_instruction_cache_requesting<=1;
			end else begin
				hyper_jump_guess_source_table[7]<=mem_data_out_type_0[7][7:0];
				hyper_jump_guess_source_table[6]<=mem_data_out_type_0[6][7:0];
				hyper_jump_guess_source_table[5]<=mem_data_out_type_0[5][7:0];
				hyper_jump_guess_source_table[4]<=mem_data_out_type_0[4][7:0];
				hyper_jump_guess_source_table[3]<=mem_data_out_type_0[3][7:0];
				hyper_jump_guess_source_table[2]<=mem_data_out_type_0[2][7:0];
				hyper_jump_guess_source_table[1]<=mem_data_out_type_0[1][7:0];
				hyper_jump_guess_source_table[0]<=mem_data_out_type_0[0][7:0];
				hyper_jump_guess_address_table[7]<={
					mem_data_out_type_0[6][11:4],
					mem_data_out_type_0[4][11:4],
					mem_data_out_type_0[5][11:4],
					mem_data_out_type_0[3][11:4]
				};
				hyper_jump_guess_address_table[6]<={
					mem_data_out_type_0[5][11:4],
					mem_data_out_type_0[3][11:4],
					mem_data_out_type_0[4][11:4],
					mem_data_out_type_0[2][11:4]
				};
				hyper_jump_guess_address_table[5]<={
					mem_data_out_type_0[4][11:4],
					mem_data_out_type_0[2][11:4],
					mem_data_out_type_0[3][11:4],
					mem_data_out_type_0[1][11:4]
				};
				hyper_jump_guess_address_table[4]<={
					mem_data_out_type_0[3][11:4],
					mem_data_out_type_0[1][11:4],
					mem_data_out_type_0[2][11:4],
					mem_data_out_type_0[0][11:4]
				};
				hyper_jump_guess_address_table[3]<={
					mem_data_out_type_0[2][11:4],
					mem_data_out_type_0[0][11:4],
					mem_data_out_type_0[1][11:4],
					fifo_instruction_cache_data_at_write_addr_m1[11:4]
				};
				hyper_jump_guess_address_table[2]<={
					mem_data_out_type_0[1][11:4],
					fifo_instruction_cache_data_at_write_addr_m1[11:4],
					mem_data_out_type_0[0][11:4],
					fifo_instruction_cache_data_at_write_addr_m2[11:4]
				};
				hyper_jump_guess_address_table[1]<={
					mem_data_out_type_0[0][11:4],
					fifo_instruction_cache_data_at_write_addr_m2[11:4],
					fifo_instruction_cache_data_at_write_addr_m1[11:4],
					fifo_instruction_cache_data_at_write_addr_m3[11:4]
				};
				hyper_jump_guess_address_table[0]<={
					fifo_instruction_cache_data_at_write_addr_m1[11:4],
					fifo_instruction_cache_data_at_write_addr_m3[11:4],
					fifo_instruction_cache_data_at_write_addr_m2[11:4],
					fifo_instruction_cache_data_at_write_addr_m4[11:4]
				};
				hyper_jump_potentially_valid_type3<=0;
				hyper_jump_potentially_valid_type2<=0;
				hyper_jump_potentially_valid_type1<=0;
				hyper_jump_potentially_valid_type0<=0;
				is_hyper_instruction_fetch_0_requesting<=0;
				is_hyper_instruction_fetch_1_requesting<=0;
				will_hyper_instruction_fetch_1_request_after<=0;
				void_hyper_instruction_fetch<=1;
				hyper_jump_look_index<=3'hx;
				
				if (instruction_fetch_returning_word_count>3'd6) begin
					if (mem_data_out_type_0[7][15:11]==5'h1F && (mem_data_out_type_0[7][10:8]==3'b010 || mem_data_out_type_0[7][10:8]==3'b011 || mem_data_out_type_0[7][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[7][10:8]!=3'b011) begin
							if (mem_data_out_type_0[6][15:13]==3'h0 && mem_data_out_type_0[5][15:13]==3'h0 && mem_data_out_type_0[4][15:13]==3'h0 && mem_data_out_type_0[3][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=7;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (instruction_fetch_returning_word_count>3'd5) begin
					if (mem_data_out_type_0[6][15:11]==5'h1F && (mem_data_out_type_0[6][10:8]==3'b010 || mem_data_out_type_0[6][10:8]==3'b011 || mem_data_out_type_0[6][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[6][10:8]!=3'b011) begin
							if (mem_data_out_type_0[5][15:13]==3'h0 && mem_data_out_type_0[4][15:13]==3'h0 && mem_data_out_type_0[3][15:13]==3'h0 && mem_data_out_type_0[2][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=6;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (instruction_fetch_returning_word_count>3'd4) begin
					if (mem_data_out_type_0[5][15:11]==5'h1F && (mem_data_out_type_0[5][10:8]==3'b010 || mem_data_out_type_0[5][10:8]==3'b011 || mem_data_out_type_0[5][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[5][10:8]!=3'b011) begin
							if (mem_data_out_type_0[4][15:13]==3'h0 && mem_data_out_type_0[3][15:13]==3'h0 && mem_data_out_type_0[2][15:13]==3'h0 && mem_data_out_type_0[1][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=5;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (instruction_fetch_returning_word_count>3'd3) begin
					if (mem_data_out_type_0[4][15:11]==5'h1F && (mem_data_out_type_0[4][10:8]==3'b010 || mem_data_out_type_0[4][10:8]==3'b011 || mem_data_out_type_0[4][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[4][10:8]!=3'b011) begin
							if (mem_data_out_type_0[3][15:13]==3'h0 && mem_data_out_type_0[2][15:13]==3'h0 && mem_data_out_type_0[1][15:13]==3'h0 && mem_data_out_type_0[0][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=4;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (instruction_fetch_returning_word_count>3'd2) begin
					if (mem_data_out_type_0[3][15:11]==5'h1F && (mem_data_out_type_0[3][10:8]==3'b010 || mem_data_out_type_0[3][10:8]==3'b011 || mem_data_out_type_0[3][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[3][10:8]!=3'b011) begin
							if (mem_data_out_type_0[2][15:13]==3'h0 && mem_data_out_type_0[1][15:13]==3'h0 && mem_data_out_type_0[0][15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m1[15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=3;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (instruction_fetch_returning_word_count>3'd1) begin
					if (mem_data_out_type_0[2][15:11]==5'h1F && (mem_data_out_type_0[2][10:8]==3'b010 || mem_data_out_type_0[2][10:8]==3'b011 || mem_data_out_type_0[2][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[2][10:8]!=3'b011) begin
							if (mem_data_out_type_0[1][15:13]==3'h0 && mem_data_out_type_0[0][15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m1[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m2[15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=2;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (instruction_fetch_returning_word_count>3'd0) begin
					if (mem_data_out_type_0[1][15:11]==5'h1F && (mem_data_out_type_0[1][10:8]==3'b010 || mem_data_out_type_0[1][10:8]==3'b011 || mem_data_out_type_0[1][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[1][10:8]!=3'b011) begin
							if (mem_data_out_type_0[0][15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m1[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m2[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m3[15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=1;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
					if (mem_data_out_type_0[0][15:11]==5'h1F && (mem_data_out_type_0[0][10:8]==3'b010 || mem_data_out_type_0[0][10:8]==3'b011 || mem_data_out_type_0[0][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (mem_data_out_type_0[0][10:8]!=3'b011) begin
							if (fifo_instruction_cache_data_at_write_addr_m1[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m2[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m3[15:13]==3'h0 && fifo_instruction_cache_data_at_write_addr_m4[15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index<=0;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				
				instruction_fetch_address<=instruction_fetch_address+{instruction_fetch_returning_word_count_actual,1'b0};
				is_instruction_cache_requesting<=0;
			end
		end
	end else begin
		if (is_performing_jump) begin
			is_performing_jump_state<=0;
			isWaitingForJump<=0;
			is_hyper_instruction_fetch_0_requesting<=0;
			is_hyper_instruction_fetch_1_requesting<=0;
			will_hyper_instruction_fetch_1_request_after<=0;
			void_hyper_instruction_fetch<=1;
			hyper_jump_potentially_valid_type3<=1;
			hyper_jump_potentially_valid_type2<=0;
			hyper_jump_potentially_valid_type1<=0;
			hyper_jump_potentially_valid_type0<=0;
			hyper_instruction_fetch_size<=0;
			hyper_jump_look_index_alt<=4'hx;
			
			if (hyper_jump_potentially_valid_type0 && !is_hyper_instruction_fetch_0_requesting && instruction_jump_address[25:1]==hyper_jump_guess_address_saved[25:1]) begin
				instruction_fetch_address<={hyper_jump_guess_address_saved[25:1]+hyper_instruction_fetch_size,1'b0};
				is_instruction_cache_requesting<=0;
				
				if (hyper_instruction_fetch_size>5'd15) begin
					if (hyper_instruction_fetch_storage[15][15:11]==5'h1F && (hyper_instruction_fetch_storage[15][10:8]==3'b010 || hyper_instruction_fetch_storage[15][10:8]==3'b011 || hyper_instruction_fetch_storage[15][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[15][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[14][15:13]==3'h0 && hyper_instruction_fetch_storage[13][15:13]==3'h0 && hyper_instruction_fetch_storage[12][15:13]==3'h0 && hyper_instruction_fetch_storage[11][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=15;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd14) begin
					if (hyper_instruction_fetch_storage[14][15:11]==5'h1F && (hyper_instruction_fetch_storage[14][10:8]==3'b010 || hyper_instruction_fetch_storage[14][10:8]==3'b011 || hyper_instruction_fetch_storage[14][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[14][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[13][15:13]==3'h0 && hyper_instruction_fetch_storage[12][15:13]==3'h0 && hyper_instruction_fetch_storage[11][15:13]==3'h0 && hyper_instruction_fetch_storage[10][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=14;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd13) begin
					if (hyper_instruction_fetch_storage[13][15:11]==5'h1F && (hyper_instruction_fetch_storage[13][10:8]==3'b010 || hyper_instruction_fetch_storage[13][10:8]==3'b011 || hyper_instruction_fetch_storage[13][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[13][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[12][15:13]==3'h0 && hyper_instruction_fetch_storage[11][15:13]==3'h0 && hyper_instruction_fetch_storage[10][15:13]==3'h0 && hyper_instruction_fetch_storage[9][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=13;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd12) begin
					if (hyper_instruction_fetch_storage[12][15:11]==5'h1F && (hyper_instruction_fetch_storage[12][10:8]==3'b010 || hyper_instruction_fetch_storage[12][10:8]==3'b011 || hyper_instruction_fetch_storage[12][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[12][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[11][15:13]==3'h0 && hyper_instruction_fetch_storage[10][15:13]==3'h0 && hyper_instruction_fetch_storage[9][15:13]==3'h0 && hyper_instruction_fetch_storage[8][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=12;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd11) begin
					if (hyper_instruction_fetch_storage[11][15:11]==5'h1F && (hyper_instruction_fetch_storage[11][10:8]==3'b010 || hyper_instruction_fetch_storage[11][10:8]==3'b011 || hyper_instruction_fetch_storage[11][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[11][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[10][15:13]==3'h0 && hyper_instruction_fetch_storage[9][15:13]==3'h0 && hyper_instruction_fetch_storage[8][15:13]==3'h0 && hyper_instruction_fetch_storage[7][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=11;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd10) begin
					if (hyper_instruction_fetch_storage[10][15:11]==5'h1F && (hyper_instruction_fetch_storage[10][10:8]==3'b010 || hyper_instruction_fetch_storage[10][10:8]==3'b011 || hyper_instruction_fetch_storage[10][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[10][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[9][15:13]==3'h0 && hyper_instruction_fetch_storage[8][15:13]==3'h0 && hyper_instruction_fetch_storage[7][15:13]==3'h0 && hyper_instruction_fetch_storage[6][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=10;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd9) begin
					if (hyper_instruction_fetch_storage[9][15:11]==5'h1F && (hyper_instruction_fetch_storage[9][10:8]==3'b010 || hyper_instruction_fetch_storage[9][10:8]==3'b011 || hyper_instruction_fetch_storage[9][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[9][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[8][15:13]==3'h0 && hyper_instruction_fetch_storage[7][15:13]==3'h0 && hyper_instruction_fetch_storage[6][15:13]==3'h0 && hyper_instruction_fetch_storage[5][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=9;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd8) begin
					if (hyper_instruction_fetch_storage[8][15:11]==5'h1F && (hyper_instruction_fetch_storage[8][10:8]==3'b010 || hyper_instruction_fetch_storage[8][10:8]==3'b011 || hyper_instruction_fetch_storage[8][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[8][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[7][15:13]==3'h0 && hyper_instruction_fetch_storage[6][15:13]==3'h0 && hyper_instruction_fetch_storage[5][15:13]==3'h0 && hyper_instruction_fetch_storage[4][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=8;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd7) begin
					if (hyper_instruction_fetch_storage[7][15:11]==5'h1F && (hyper_instruction_fetch_storage[7][10:8]==3'b010 || hyper_instruction_fetch_storage[7][10:8]==3'b011 || hyper_instruction_fetch_storage[7][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[7][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[6][15:13]==3'h0 && hyper_instruction_fetch_storage[5][15:13]==3'h0 && hyper_instruction_fetch_storage[4][15:13]==3'h0 && hyper_instruction_fetch_storage[3][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=7;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd6) begin
					if (hyper_instruction_fetch_storage[6][15:11]==5'h1F && (hyper_instruction_fetch_storage[6][10:8]==3'b010 || hyper_instruction_fetch_storage[6][10:8]==3'b011 || hyper_instruction_fetch_storage[6][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[6][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[5][15:13]==3'h0 && hyper_instruction_fetch_storage[4][15:13]==3'h0 && hyper_instruction_fetch_storage[3][15:13]==3'h0 && hyper_instruction_fetch_storage[2][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=6;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd5) begin
					if (hyper_instruction_fetch_storage[5][15:11]==5'h1F && (hyper_instruction_fetch_storage[5][10:8]==3'b010 || hyper_instruction_fetch_storage[5][10:8]==3'b011 || hyper_instruction_fetch_storage[5][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[5][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[4][15:13]==3'h0 && hyper_instruction_fetch_storage[3][15:13]==3'h0 && hyper_instruction_fetch_storage[2][15:13]==3'h0 && hyper_instruction_fetch_storage[1][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=5;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd4) begin
					if (hyper_instruction_fetch_storage[4][15:11]==5'h1F && (hyper_instruction_fetch_storage[4][10:8]==3'b010 || hyper_instruction_fetch_storage[4][10:8]==3'b011 || hyper_instruction_fetch_storage[4][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[4][10:8]!=3'b011) begin
							if (hyper_instruction_fetch_storage[3][15:13]==3'h0 && hyper_instruction_fetch_storage[2][15:13]==3'h0 && hyper_instruction_fetch_storage[1][15:13]==3'h0 && hyper_instruction_fetch_storage[0][15:13]==3'h0) begin
								hyper_jump_potentially_valid_type2<=0;
							end else begin
								hyper_jump_potentially_valid_type2<=1;
							end
							hyper_jump_look_index_alt<=4;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd3) begin
					if (hyper_instruction_fetch_storage[3][15:11]==5'h1F && (hyper_instruction_fetch_storage[3][10:8]==3'b010 || hyper_instruction_fetch_storage[3][10:8]==3'b011 || hyper_instruction_fetch_storage[3][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[3][10:8]!=3'b011) begin
							hyper_jump_potentially_valid_type2<=1;
							hyper_jump_look_index_alt<=3;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd2) begin
					if (hyper_instruction_fetch_storage[2][15:11]==5'h1F && (hyper_instruction_fetch_storage[2][10:8]==3'b010 || hyper_instruction_fetch_storage[2][10:8]==3'b011 || hyper_instruction_fetch_storage[2][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[2][10:8]!=3'b011) begin
							hyper_jump_potentially_valid_type2<=1;
							hyper_jump_look_index_alt<=2;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd1) begin
					if (hyper_instruction_fetch_storage[1][15:11]==5'h1F && (hyper_instruction_fetch_storage[1][10:8]==3'b010 || hyper_instruction_fetch_storage[1][10:8]==3'b011 || hyper_instruction_fetch_storage[1][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[1][10:8]!=3'b011) begin
							hyper_jump_potentially_valid_type2<=1;
							hyper_jump_look_index_alt<=1;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
				if (hyper_instruction_fetch_size>5'd0) begin // hyper_instruction_fetch_size should always be greater then 0, but just to make sure
					if (hyper_instruction_fetch_storage[0][15:11]==5'h1F && (hyper_instruction_fetch_storage[0][10:8]==3'b010 || hyper_instruction_fetch_storage[0][10:8]==3'b011 || hyper_instruction_fetch_storage[0][10:8]==3'b110)) begin
						isWaitingForJump<=1;
						if (hyper_instruction_fetch_storage[0][10:8]!=3'b011) begin
							hyper_jump_potentially_valid_type2<=1;
							hyper_jump_look_index_alt<=0;
							hyper_jump_potentially_valid_type1<=1;
						end
					end
				end
			end else begin
				instruction_fetch_address<=instruction_jump_address;
				is_instruction_cache_requesting<=1;
			end
		end else if (({1'b0,fifo_instruction_cache_size_after_read}+(5'd8-instruction_fetch_address[3:1]))<5'h10 && !isWaitingForJump) begin
			is_instruction_cache_requesting<=1;
		end
	end
	instruction_fetch_address[0]<=1'b0;
	hyper_jump_guess_address_saved[0]<=1'b0;
	target_address_hyper_instruction_fetch_0[0]<=1'b0;
	target_address_hyper_instruction_fetch_1[0]<=1'b0;
end


endmodule







