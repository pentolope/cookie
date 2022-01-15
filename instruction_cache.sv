`timescale 1 ps / 1 ps

module hyperfetch_generation(
	output haltingjump_known_out,
	output hyperjump_known_out,
	output [24:0] hyperfetch_address_out,
	input [15:0] instruction_data [14:0],
	input [3:0] valid_size
);

reg [31:0] hyperfetch_address;
reg haltingjump_known;
reg hyperjump_known;
assign hyperfetch_address_out=hyperfetch_address[25:1];
assign haltingjump_known_out=haltingjump_known;
assign hyperjump_known_out=hyperjump_known;

always_comb begin
	hyperjump_known=0;
	haltingjump_known=0;
	hyperfetch_address=32'hx;
	if (valid_size==4'hF && (instruction_data[4'hE][15:11]==5'h1F && (instruction_data[4'hE][10:9]==2'b01 || instruction_data[4'hE][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'hD][15:13]==3'b0 && instruction_data[4'hC][15:13]==3'b0 && instruction_data[4'hB][15:13]==3'b0 && instruction_data[4'hA][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'hA][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'hC][11:4];
			hyperfetch_address[23:16]=instruction_data[4'hB][11:4];
			hyperfetch_address[31:24]=instruction_data[4'hD][11:4];
		end
	end
	if (valid_size>=4'hE && (instruction_data[4'hD][15:11]==5'h1F && (instruction_data[4'hD][10:9]==2'b01 || instruction_data[4'hD][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'hC][15:13]==3'b0 && instruction_data[4'hB][15:13]==3'b0 && instruction_data[4'hA][15:13]==3'b0 && instruction_data[4'h9][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'h9][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'hB][11:4];
			hyperfetch_address[23:16]=instruction_data[4'hA][11:4];
			hyperfetch_address[31:24]=instruction_data[4'hC][11:4];
		end
	end
	if (valid_size>=4'hD && (instruction_data[4'hC][15:11]==5'h1F && (instruction_data[4'hC][10:9]==2'b01 || instruction_data[4'hC][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'hB][15:13]==3'b0 && instruction_data[4'hA][15:13]==3'b0 && instruction_data[4'h9][15:13]==3'b0 && instruction_data[4'h8][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'h8][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'hA][11:4];
			hyperfetch_address[23:16]=instruction_data[4'h9][11:4];
			hyperfetch_address[31:24]=instruction_data[4'hB][11:4];
		end
	end
	if (valid_size>=4'hC && (instruction_data[4'hB][15:11]==5'h1F && (instruction_data[4'hB][10:9]==2'b01 || instruction_data[4'hB][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'hA][15:13]==3'b0 && instruction_data[4'h9][15:13]==3'b0 && instruction_data[4'h8][15:13]==3'b0 && instruction_data[4'h7][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'h7][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'h9][11:4];
			hyperfetch_address[23:16]=instruction_data[4'h8][11:4];
			hyperfetch_address[31:24]=instruction_data[4'hA][11:4];
		end
	end
	if (valid_size>=4'hB && (instruction_data[4'hA][15:11]==5'h1F && (instruction_data[4'hA][10:9]==2'b01 || instruction_data[4'hA][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'h9][15:13]==3'b0 && instruction_data[4'h8][15:13]==3'b0 && instruction_data[4'h7][15:13]==3'b0 && instruction_data[4'h6][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'h6][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'h8][11:4];
			hyperfetch_address[23:16]=instruction_data[4'h7][11:4];
			hyperfetch_address[31:24]=instruction_data[4'h9][11:4];
		end
	end
	if (valid_size>=4'hA && (instruction_data[4'h9][15:11]==5'h1F && (instruction_data[4'h9][10:9]==2'b01 || instruction_data[4'h9][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'h8][15:13]==3'b0 && instruction_data[4'h7][15:13]==3'b0 && instruction_data[4'h6][15:13]==3'b0 && instruction_data[4'h5][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'h5][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'h7][11:4];
			hyperfetch_address[23:16]=instruction_data[4'h6][11:4];
			hyperfetch_address[31:24]=instruction_data[4'h8][11:4];
		end
	end
	if (valid_size>=4'h9 && (instruction_data[4'h8][15:11]==5'h1F && (instruction_data[4'h8][10:9]==2'b01 || instruction_data[4'h8][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'h7][15:13]==3'b0 && instruction_data[4'h6][15:13]==3'b0 && instruction_data[4'h5][15:13]==3'b0 && instruction_data[4'h4][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'h4][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'h6][11:4];
			hyperfetch_address[23:16]=instruction_data[4'h5][11:4];
			hyperfetch_address[31:24]=instruction_data[4'h7][11:4];
		end
	end
	if (valid_size>=4'h8 && (instruction_data[4'h7][15:11]==5'h1F && (instruction_data[4'h7][10:9]==2'b01 || instruction_data[4'h7][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'h6][15:13]==3'b0 && instruction_data[4'h5][15:13]==3'b0 && instruction_data[4'h4][15:13]==3'b0 && instruction_data[4'h3][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'h3][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'h5][11:4];
			hyperfetch_address[23:16]=instruction_data[4'h4][11:4];
			hyperfetch_address[31:24]=instruction_data[4'h6][11:4];
		end
	end
	if (valid_size>=4'h7 && (instruction_data[4'h6][15:11]==5'h1F && (instruction_data[4'h6][10:9]==2'b01 || instruction_data[4'h6][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'h5][15:13]==3'b0 && instruction_data[4'h4][15:13]==3'b0 && instruction_data[4'h3][15:13]==3'b0 && instruction_data[4'h2][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'h2][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'h4][11:4];
			hyperfetch_address[23:16]=instruction_data[4'h3][11:4];
			hyperfetch_address[31:24]=instruction_data[4'h5][11:4];
		end
	end
	if (valid_size>=4'h6 && (instruction_data[4'h5][15:11]==5'h1F && (instruction_data[4'h5][10:9]==2'b01 || instruction_data[4'h5][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'h4][15:13]==3'b0 && instruction_data[4'h3][15:13]==3'b0 && instruction_data[4'h2][15:13]==3'b0 && instruction_data[4'h1][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'h1][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'h3][11:4];
			hyperfetch_address[23:16]=instruction_data[4'h2][11:4];
			hyperfetch_address[31:24]=instruction_data[4'h4][11:4];
		end
	end
	if (valid_size>=4'h5 && (instruction_data[4'h4][15:11]==5'h1F && (instruction_data[4'h4][10:9]==2'b01 || instruction_data[4'h4][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
		if (instruction_data[4'h3][15:13]==3'b0 && instruction_data[4'h2][15:13]==3'b0 && instruction_data[4'h1][15:13]==3'b0 && instruction_data[4'h0][15:13]==3'b0) begin
			hyperjump_known=1;
			hyperfetch_address[ 7: 0]=instruction_data[4'h0][11:4];
			hyperfetch_address[15: 8]=instruction_data[4'h2][11:4];
			hyperfetch_address[23:16]=instruction_data[4'h1][11:4];
			hyperfetch_address[31:24]=instruction_data[4'h3][11:4];
		end
	end
	if (valid_size>=4'h4 && (instruction_data[4'h3][15:11]==5'h1F && (instruction_data[4'h3][10:9]==2'b01 || instruction_data[4'h3][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
	end
	if (valid_size>=4'h3 && (instruction_data[4'h2][15:11]==5'h1F && (instruction_data[4'h2][10:9]==2'b01 || instruction_data[4'h2][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
	end
	if (valid_size>=4'h2 && (instruction_data[4'h1][15:11]==5'h1F && (instruction_data[4'h1][10:9]==2'b01 || instruction_data[4'h1][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
	end
	if (valid_size>=4'h1 && (instruction_data[4'h0][15:11]==5'h1F && (instruction_data[4'h0][10:9]==2'b01 || instruction_data[4'h0][10:8]==3'b110))) begin
		haltingjump_known=1;
		hyperjump_known=0;
	end
end
endmodule


module instruction_cache(
	output [15:0] ready_instructions_extern [2:0],
	output [25:0] ready_instructions_address_table [2:0],
	output [1:0] ready_instruction_count_now_extern,
	output [1:0] ready_instruction_count_next_extern,

	input  [15:0] data_in_raw  [7:0],
	input is_data_coming_in [1:0],
	output void_instruction_fetch_output,
	output [1:0] instruction_fetch_requesting_out,
	output [24:0] instruction_fetch0_pointer_out,
	output [24:0] instruction_fetch1_pointer_out,
	input jump_triggering,
	input [24:0] jump_address,
	input [1:0] used_ready_instruction_count,
	input main_clk
);

reg [24:0] instruction_pointer_out=25'h3FF0;

reg [15:0] ready_instructions [2:0]='{0,0,0};
reg [1:0] ready_instruction_count_now=0;
reg [1:0] ready_instruction_count_next;

assign ready_instructions_extern[0]=ready_instructions[0][15:0];
assign ready_instructions_extern[1]=ready_instructions[1][15:0];
assign ready_instructions_extern[2]=ready_instructions[2][15:0];

assign ready_instructions_address_table[0][25:1]=instruction_pointer_out+3'h1;// this starts at +1 because the executers want the address after their instruction
assign ready_instructions_address_table[1][25:1]=instruction_pointer_out+3'h2;
assign ready_instructions_address_table[2][25:1]=instruction_pointer_out+3'h3;

assign ready_instructions_address_table[0][0]=1'b0;
assign ready_instructions_address_table[1][0]=1'b0;
assign ready_instructions_address_table[2][0]=1'b0;

assign ready_instruction_count_now_extern=ready_instruction_count_now;
assign ready_instruction_count_next_extern=ready_instruction_count_next;


always @(posedge main_clk) begin
	ready_instruction_count_now<=ready_instruction_count_next;
end

wire [1:0] ready_left;assign ready_left=ready_instruction_count_now - used_ready_instruction_count;
wire [1:0] ready_fill_request;assign ready_fill_request=(used_ready_instruction_count - ready_instruction_count_now) - 2'b1;
wire [1:0] old_gen_ready_fill_request;assign old_gen_ready_fill_request=2'd3 - ready_left;
always @(posedge main_clk) assert(ready_fill_request==old_gen_ready_fill_request);

reg [15:0] prepared_instructions [15:0];
reg [3:0] prepared_instruction_count=0;
reg [3:0] circular_prepared_instruction_read=0;
reg [3:0] circular_prepared_instruction_write=0;

wire [3:0] circular_prepared_instruction_read_table [3:0];
wire [3:0] circular_prepared_instruction_write_table [7:0];
assign circular_prepared_instruction_read_table[0]=circular_prepared_instruction_read;
assign circular_prepared_instruction_read_table[1]=circular_prepared_instruction_read+4'h1;
assign circular_prepared_instruction_read_table[2]=circular_prepared_instruction_read+4'h2;
assign circular_prepared_instruction_read_table[3]=circular_prepared_instruction_read+4'h3;
assign circular_prepared_instruction_write_table[0]=circular_prepared_instruction_write;
assign circular_prepared_instruction_write_table[1]=circular_prepared_instruction_write+4'h1;
assign circular_prepared_instruction_write_table[2]=circular_prepared_instruction_write+4'h2;
assign circular_prepared_instruction_write_table[3]=circular_prepared_instruction_write+4'h3;
assign circular_prepared_instruction_write_table[4]=circular_prepared_instruction_write+4'h4;
assign circular_prepared_instruction_write_table[5]=circular_prepared_instruction_write+4'h5;
assign circular_prepared_instruction_write_table[6]=circular_prepared_instruction_write+4'h6;
assign circular_prepared_instruction_write_table[7]=circular_prepared_instruction_write+4'h7;

wire [15:0] circular_prepared_instruction_read_table_at_prepared_instructions [3:0];
assign circular_prepared_instruction_read_table_at_prepared_instructions[0]=prepared_instructions[circular_prepared_instruction_read_table[0]];
assign circular_prepared_instruction_read_table_at_prepared_instructions[1]=prepared_instructions[circular_prepared_instruction_read_table[1]];
assign circular_prepared_instruction_read_table_at_prepared_instructions[2]=prepared_instructions[circular_prepared_instruction_read_table[2]];
assign circular_prepared_instruction_read_table_at_prepared_instructions[3]=prepared_instructions[circular_prepared_instruction_read_table[3]];


wire [1:0] ready_fill_satisfied;assign ready_fill_satisfied=(ready_fill_request<=prepared_instruction_count)?(ready_fill_request): // could also be less then
	((prepared_instruction_count[3:2]==2'b00)?(prepared_instruction_count[1:0]):(2'b11));

wire [3:0] buffer_size_avalible;
wire [15:0] buffer_instructions [7:0];


wire [3:0] prepared_left;assign prepared_left=prepared_instruction_count - ready_fill_satisfied;

wire [3:0] garenteed_prepared_avalible_space;assign garenteed_prepared_avalible_space=4'hF - prepared_instruction_count; // this is not updated for the amount going into ready_instructions so this value may be lower then the amount of actual space avalible

wire [3:0] buffer_size_used;assign buffer_size_used=(garenteed_prepared_avalible_space>=buffer_size_avalible)?(buffer_size_avalible):(garenteed_prepared_avalible_space);

always_comb begin
	ready_instruction_count_next=ready_left + ready_fill_satisfied;
	if (jump_triggering) ready_instruction_count_next=0;
end

// is_data_coming_in[0] must have a memory priority higher then is_data_coming_in[1]

reg void_instruction_fetch=0;
assign void_instruction_fetch_output=void_instruction_fetch;

/*

inst0 = circular_address[1:0]==0
inst1 = circular_address[1:0]==1
inst2 = circular_address[1:0]==2
inst3 = circular_address[1:0]==3

3,2,1,0
^ ^ ^ ^ circular_address[5:2]

*/

reg used_buffer_bypass; // combinational
reg placing_data_in_buffer; // combinational
reg placed_data_in_buffer_last_cycle=0;
always @(posedge main_clk) placed_data_in_buffer_last_cycle<=placing_data_in_buffer;

reg [3:0] hyperfetch_buffer_size=0; // size is literally what it is
reg [15:0] hyperfetch_buffer [14:0];

reg [5:0] circular_address_read=0;
reg [5:0] circular_address_write=0;

reg [5:0] buffer_size=0; // size is literally what it is
reg [5:0] buffer_size_next;
reg waiting_on_jump=0;
reg waiting_on_hyperfetch=0;

reg [24:0] instruction_fetch0_pointer=25'h3FF0;
reg [24:0] instruction_fetch1_pointer=25'hx;
reg [1:0] instruction_fetch_requesting=2'b01;

always @(posedge main_clk) begin
	assert(!(instruction_fetch_requesting[0] && is_data_coming_in[1]));// otherwise memory priority is out of order
end

assign instruction_fetch0_pointer_out=instruction_fetch0_pointer;
assign instruction_fetch1_pointer_out=instruction_fetch1_pointer;
assign instruction_fetch_requesting_out=instruction_fetch_requesting;

wire [2:0] data_in_size; // data_in_size is actually one larger then indicated
assign data_in_size=is_data_coming_in[1]?(3'd7-instruction_fetch1_pointer[2:0]):(3'd7-instruction_fetch0_pointer[2:0]);
wire [7:0] data_in_size_at_least;
assign data_in_size_at_least[0]=1'b1;
assign data_in_size_at_least[1]=(data_in_size>=3'd1)? 1'b1:1'b0;
assign data_in_size_at_least[2]=(data_in_size>=3'd2)? 1'b1:1'b0;
assign data_in_size_at_least[3]=(data_in_size>=3'd3)? 1'b1:1'b0;
assign data_in_size_at_least[4]=(data_in_size>=3'd4)? 1'b1:1'b0;
assign data_in_size_at_least[5]=(data_in_size>=3'd5)? 1'b1:1'b0;
assign data_in_size_at_least[6]=(data_in_size>=3'd6)? 1'b1:1'b0;
assign data_in_size_at_least[7]=(data_in_size==3'd7)? 1'b1:1'b0;

reg [3:0] recent_jump_data_size [3:0]='{0,0,0,0};

reg [1:0] recent_jump_circular_position=0;
reg [15:0] recent_jump_data_raw [3:0][14:0];
reg [14:0] recent_jump_data_valid [3:0]='{0,0,0,0}; // one bit for each word
reg [24:0] recent_jump_addresses [3:0]='{0,0,0,0}; // jump addresses may be the same, there needs to be some handling for that. not complex handling, just a simple way
reg [3:0] recent_jump_update_offset [1:0][3:0];
reg [3:0] recent_jump_matchy [1:0]='{0,0};
/*
recent_jump_matchy[0][0] is for (recent_jump_addresses[0] near instruction_fetch0_pointer)
recent_jump_matchy[1][0] is for (recent_jump_addresses[0] near instruction_fetch1_pointer)
recent_jump_matchy[0][1] is for (recent_jump_addresses[1] near instruction_fetch0_pointer)
recent_jump_matchy[1][1] is for (recent_jump_addresses[1] near instruction_fetch1_pointer)
recent_jump_matchy[0][2] is for (recent_jump_addresses[2] near instruction_fetch0_pointer)
recent_jump_matchy[1][2] is for (recent_jump_addresses[2] near instruction_fetch1_pointer)
recent_jump_matchy[0][3] is for (recent_jump_addresses[3] near instruction_fetch0_pointer)
recent_jump_matchy[1][3] is for (recent_jump_addresses[3] near instruction_fetch1_pointer)
*/
wire [3:0] recent_jump_update_possible [1:0];
wire [3:0] recent_jump_size_and_diff_equal [1:0]; // this check is important for the hyperfetch calculation

assign recent_jump_size_and_diff_equal[0][0]=(recent_jump_data_size[0]<4'h9 && recent_jump_data_size[0]==recent_jump_update_offset[0][0])? 1'b1:1'b0;
assign recent_jump_size_and_diff_equal[0][1]=(recent_jump_data_size[1]<4'h9 && recent_jump_data_size[1]==recent_jump_update_offset[0][1])? 1'b1:1'b0;
assign recent_jump_size_and_diff_equal[0][2]=(recent_jump_data_size[2]<4'h9 && recent_jump_data_size[2]==recent_jump_update_offset[0][2])? 1'b1:1'b0;
assign recent_jump_size_and_diff_equal[0][3]=(recent_jump_data_size[3]<4'h9 && recent_jump_data_size[3]==recent_jump_update_offset[0][3])? 1'b1:1'b0;
assign recent_jump_size_and_diff_equal[1][0]=(recent_jump_data_size[0]<4'h9 && recent_jump_data_size[0]==recent_jump_update_offset[1][0])? 1'b1:1'b0;
assign recent_jump_size_and_diff_equal[1][1]=(recent_jump_data_size[1]<4'h9 && recent_jump_data_size[1]==recent_jump_update_offset[1][1])? 1'b1:1'b0;
assign recent_jump_size_and_diff_equal[1][2]=(recent_jump_data_size[2]<4'h9 && recent_jump_data_size[2]==recent_jump_update_offset[1][2])? 1'b1:1'b0;
assign recent_jump_size_and_diff_equal[1][3]=(recent_jump_data_size[3]<4'h9 && recent_jump_data_size[3]==recent_jump_update_offset[1][3])? 1'b1:1'b0;
assign recent_jump_update_possible[0]={4{(is_data_coming_in[0])? 1'b1:1'b0}} & recent_jump_matchy[0] & recent_jump_size_and_diff_equal[0];
assign recent_jump_update_possible[1]={4{(is_data_coming_in[1])? 1'b1:1'b0}} & recent_jump_matchy[1] & recent_jump_size_and_diff_equal[1];

reg [15:0] hyperfetch_detection_helper_data [3:0]='{16'b1xxxxxxxxxxxxxxx,16'hx,16'hx,16'hx};// just enough to garentee rejection from the hyperfetch detection system
reg [15:0] hyperfetch_detection_temp_data [11:0];
reg hyperfetch_detection_temp_data_is_load [11:0];
reg [31:0] hyperfetch_suggestion_on_input_temp;
reg [24:0] hyperfetch_suggestion_on_input;
reg hyperfetch_suggestion_on_input_validity;
reg haltingjump_on_input_known;
reg hyperfetch_address_valid=0;

reg [24:0] extra_hyperjump_addresses [4:0]='{0,0,0,0,0};
reg [4:0] extra_hyperjump_known=0;
reg [4:0] extra_haltingjump_known=0;

wire [24:0] extra_hyperjump_addresses_test [4:0];
wire [4:0] extra_hyperjump_known_test;
wire [4:0] extra_haltingjump_known_test;


reg [24:0] extra_hyperjump_addresses_including_input [4:0];
wire [4:0] extra_hyperjump_known_including_input;
wire [4:0] extra_haltingjump_known_including_input;


reg [4:0] extra_hyperfetch_suggestion_on_input_validity;
reg [4:0] extra_haltingjump_on_input_known;
assign extra_haltingjump_known_including_input=extra_haltingjump_known | extra_haltingjump_on_input_known;
assign extra_hyperjump_known_including_input= extra_hyperjump_known | extra_hyperfetch_suggestion_on_input_validity;

reg [15:0] extra_hyperfetch_detection_temp_data [4:0][3:0];

reg [3:0] extra_hyperfetch_detection_temp_validity [4:0]; // quartus crashes if I use a 2d packed array here... I'm serious, it strait up has an internal error if this is a 2d packed array.

always_comb begin
	extra_hyperfetch_detection_temp_data[0]='{16'hx,16'hx,16'hx,16'hx};
	extra_hyperfetch_detection_temp_validity[0]=0;
	case (recent_jump_data_size[0]) // not unique
	1:begin extra_hyperfetch_detection_temp_data[0][3]=recent_jump_data_raw[0][0];extra_hyperfetch_detection_temp_validity[0][3]=1'b1;end
	2:begin extra_hyperfetch_detection_temp_data[0][3:2]=recent_jump_data_raw[0][1:0];extra_hyperfetch_detection_temp_validity[0][3:2]=2'b11;end
	3:begin extra_hyperfetch_detection_temp_data[0][3:1]=recent_jump_data_raw[0][2:0];extra_hyperfetch_detection_temp_validity[0][3:1]=3'b111;end
	4:begin extra_hyperfetch_detection_temp_data[0][3:0]=recent_jump_data_raw[0][3:0];extra_hyperfetch_detection_temp_validity[0][3:0]=4'b1111;end
	5:begin extra_hyperfetch_detection_temp_data[0][3:0]=recent_jump_data_raw[0][4:1];extra_hyperfetch_detection_temp_validity[0][3:0]=4'b1111;end
	6:begin extra_hyperfetch_detection_temp_data[0][3:0]=recent_jump_data_raw[0][5:2];extra_hyperfetch_detection_temp_validity[0][3:0]=4'b1111;end
	7:begin extra_hyperfetch_detection_temp_data[0][3:0]=recent_jump_data_raw[0][6:3];extra_hyperfetch_detection_temp_validity[0][3:0]=4'b1111;end
	8:begin extra_hyperfetch_detection_temp_data[0][3:0]=recent_jump_data_raw[0][7:4];extra_hyperfetch_detection_temp_validity[0][3:0]=4'b1111;end
	default:begin end
	endcase
	extra_hyperfetch_detection_temp_data[0][0][15]= | extra_hyperfetch_detection_temp_data[0][0][15:13];extra_hyperfetch_detection_temp_data[0][0][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[0][1][15]= | extra_hyperfetch_detection_temp_data[0][1][15:13];extra_hyperfetch_detection_temp_data[0][1][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[0][2][15]= | extra_hyperfetch_detection_temp_data[0][2][15:13];extra_hyperfetch_detection_temp_data[0][2][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[0][3][15]= | extra_hyperfetch_detection_temp_data[0][3][15:13];extra_hyperfetch_detection_temp_data[0][3][14:13]=2'b00;

	extra_hyperfetch_detection_temp_data[1]='{16'hx,16'hx,16'hx,16'hx};
	extra_hyperfetch_detection_temp_validity[1]=0;
	case (recent_jump_data_size[1]) // not unique
	1:begin extra_hyperfetch_detection_temp_data[1][3]=recent_jump_data_raw[1][0];extra_hyperfetch_detection_temp_validity[1][3]=1'b1;end
	2:begin extra_hyperfetch_detection_temp_data[1][3:2]=recent_jump_data_raw[1][1:0];extra_hyperfetch_detection_temp_validity[1][3:2]=2'b11;end
	3:begin extra_hyperfetch_detection_temp_data[1][3:1]=recent_jump_data_raw[1][2:0];extra_hyperfetch_detection_temp_validity[1][3:1]=3'b111;end
	4:begin extra_hyperfetch_detection_temp_data[1][3:0]=recent_jump_data_raw[1][3:0];extra_hyperfetch_detection_temp_validity[1][3:0]=4'b1111;end
	5:begin extra_hyperfetch_detection_temp_data[1][3:0]=recent_jump_data_raw[1][4:1];extra_hyperfetch_detection_temp_validity[1][3:0]=4'b1111;end
	6:begin extra_hyperfetch_detection_temp_data[1][3:0]=recent_jump_data_raw[1][5:2];extra_hyperfetch_detection_temp_validity[1][3:0]=4'b1111;end
	7:begin extra_hyperfetch_detection_temp_data[1][3:0]=recent_jump_data_raw[1][6:3];extra_hyperfetch_detection_temp_validity[1][3:0]=4'b1111;end
	8:begin extra_hyperfetch_detection_temp_data[1][3:0]=recent_jump_data_raw[1][7:4];extra_hyperfetch_detection_temp_validity[1][3:0]=4'b1111;end
	default:begin end
	endcase
	extra_hyperfetch_detection_temp_data[1][0][15]= | extra_hyperfetch_detection_temp_data[1][0][15:13];extra_hyperfetch_detection_temp_data[1][0][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[1][1][15]= | extra_hyperfetch_detection_temp_data[1][1][15:13];extra_hyperfetch_detection_temp_data[1][1][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[1][2][15]= | extra_hyperfetch_detection_temp_data[1][2][15:13];extra_hyperfetch_detection_temp_data[1][2][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[1][3][15]= | extra_hyperfetch_detection_temp_data[1][3][15:13];extra_hyperfetch_detection_temp_data[1][3][14:13]=2'b00;

	extra_hyperfetch_detection_temp_data[2]='{16'hx,16'hx,16'hx,16'hx};
	extra_hyperfetch_detection_temp_validity[2]=0;
	case (recent_jump_data_size[2]) // not unique
	1:begin extra_hyperfetch_detection_temp_data[2][3]=recent_jump_data_raw[2][0];extra_hyperfetch_detection_temp_validity[2][3]=1'b1;end
	2:begin extra_hyperfetch_detection_temp_data[2][3:2]=recent_jump_data_raw[2][1:0];extra_hyperfetch_detection_temp_validity[2][3:2]=2'b11;end
	3:begin extra_hyperfetch_detection_temp_data[2][3:1]=recent_jump_data_raw[2][2:0];extra_hyperfetch_detection_temp_validity[2][3:1]=3'b111;end
	4:begin extra_hyperfetch_detection_temp_data[2][3:0]=recent_jump_data_raw[2][3:0];extra_hyperfetch_detection_temp_validity[2][3:0]=4'b1111;end
	5:begin extra_hyperfetch_detection_temp_data[2][3:0]=recent_jump_data_raw[2][4:1];extra_hyperfetch_detection_temp_validity[2][3:0]=4'b1111;end
	6:begin extra_hyperfetch_detection_temp_data[2][3:0]=recent_jump_data_raw[2][5:2];extra_hyperfetch_detection_temp_validity[2][3:0]=4'b1111;end
	7:begin extra_hyperfetch_detection_temp_data[2][3:0]=recent_jump_data_raw[2][6:3];extra_hyperfetch_detection_temp_validity[2][3:0]=4'b1111;end
	8:begin extra_hyperfetch_detection_temp_data[2][3:0]=recent_jump_data_raw[2][7:4];extra_hyperfetch_detection_temp_validity[2][3:0]=4'b1111;end
	default:begin end
	endcase
	extra_hyperfetch_detection_temp_data[2][0][15]= | extra_hyperfetch_detection_temp_data[2][0][15:13];extra_hyperfetch_detection_temp_data[2][0][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[2][1][15]= | extra_hyperfetch_detection_temp_data[2][1][15:13];extra_hyperfetch_detection_temp_data[2][1][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[2][2][15]= | extra_hyperfetch_detection_temp_data[2][2][15:13];extra_hyperfetch_detection_temp_data[2][2][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[2][3][15]= | extra_hyperfetch_detection_temp_data[2][3][15:13];extra_hyperfetch_detection_temp_data[2][3][14:13]=2'b00;

	extra_hyperfetch_detection_temp_data[3]='{16'hx,16'hx,16'hx,16'hx};
	extra_hyperfetch_detection_temp_validity[3]=0;
	case (recent_jump_data_size[3]) // not unique
	1:begin extra_hyperfetch_detection_temp_data[3][3]=recent_jump_data_raw[3][0];extra_hyperfetch_detection_temp_validity[3][3]=1'b1;end
	2:begin extra_hyperfetch_detection_temp_data[3][3:2]=recent_jump_data_raw[3][1:0];extra_hyperfetch_detection_temp_validity[3][3:2]=2'b11;end
	3:begin extra_hyperfetch_detection_temp_data[3][3:1]=recent_jump_data_raw[3][2:0];extra_hyperfetch_detection_temp_validity[3][3:1]=3'b111;end
	4:begin extra_hyperfetch_detection_temp_data[3][3:0]=recent_jump_data_raw[3][3:0];extra_hyperfetch_detection_temp_validity[3][3:0]=4'b1111;end
	5:begin extra_hyperfetch_detection_temp_data[3][3:0]=recent_jump_data_raw[3][4:1];extra_hyperfetch_detection_temp_validity[3][3:0]=4'b1111;end
	6:begin extra_hyperfetch_detection_temp_data[3][3:0]=recent_jump_data_raw[3][5:2];extra_hyperfetch_detection_temp_validity[3][3:0]=4'b1111;end
	7:begin extra_hyperfetch_detection_temp_data[3][3:0]=recent_jump_data_raw[3][6:3];extra_hyperfetch_detection_temp_validity[3][3:0]=4'b1111;end
	8:begin extra_hyperfetch_detection_temp_data[3][3:0]=recent_jump_data_raw[3][7:4];extra_hyperfetch_detection_temp_validity[3][3:0]=4'b1111;end
	default:begin end
	endcase
	extra_hyperfetch_detection_temp_data[3][0][15]= | extra_hyperfetch_detection_temp_data[3][0][15:13];extra_hyperfetch_detection_temp_data[3][0][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[3][1][15]= | extra_hyperfetch_detection_temp_data[3][1][15:13];extra_hyperfetch_detection_temp_data[3][1][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[3][2][15]= | extra_hyperfetch_detection_temp_data[3][2][15:13];extra_hyperfetch_detection_temp_data[3][2][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[3][3][15]= | extra_hyperfetch_detection_temp_data[3][3][15:13];extra_hyperfetch_detection_temp_data[3][3][14:13]=2'b00;

	extra_hyperfetch_detection_temp_data[4]='{16'hx,16'hx,16'hx,16'hx};
	extra_hyperfetch_detection_temp_validity[4]=0;
	case (hyperfetch_buffer_size) // not unique
	1:begin extra_hyperfetch_detection_temp_data[4][3]=hyperfetch_buffer[0];extra_hyperfetch_detection_temp_validity[4][3]=1'b1;end
	2:begin extra_hyperfetch_detection_temp_data[4][3:2]=hyperfetch_buffer[1:0];extra_hyperfetch_detection_temp_validity[4][3:2]=2'b11;end
	3:begin extra_hyperfetch_detection_temp_data[4][3:1]=hyperfetch_buffer[2:0];extra_hyperfetch_detection_temp_validity[4][3:1]=3'b111;end
	4:begin extra_hyperfetch_detection_temp_data[4][3:0]=hyperfetch_buffer[3:0];extra_hyperfetch_detection_temp_validity[4][3:0]=4'b1111;end
	5:begin extra_hyperfetch_detection_temp_data[4][3:0]=hyperfetch_buffer[4:1];extra_hyperfetch_detection_temp_validity[4][3:0]=4'b1111;end
	6:begin extra_hyperfetch_detection_temp_data[4][3:0]=hyperfetch_buffer[5:2];extra_hyperfetch_detection_temp_validity[4][3:0]=4'b1111;end
	7:begin extra_hyperfetch_detection_temp_data[4][3:0]=hyperfetch_buffer[6:3];extra_hyperfetch_detection_temp_validity[4][3:0]=4'b1111;end
	8:begin extra_hyperfetch_detection_temp_data[4][3:0]=hyperfetch_buffer[7:4];extra_hyperfetch_detection_temp_validity[4][3:0]=4'b1111;end
	default:begin end
	endcase
	extra_hyperfetch_detection_temp_data[4][0][15]= | extra_hyperfetch_detection_temp_data[4][0][15:13];extra_hyperfetch_detection_temp_data[4][0][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[4][1][15]= | extra_hyperfetch_detection_temp_data[4][1][15:13];extra_hyperfetch_detection_temp_data[4][1][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[4][2][15]= | extra_hyperfetch_detection_temp_data[4][2][15:13];extra_hyperfetch_detection_temp_data[4][2][14:13]=2'b00;
	extra_hyperfetch_detection_temp_data[4][3][15]= | extra_hyperfetch_detection_temp_data[4][3][15:13];extra_hyperfetch_detection_temp_data[4][3][14:13]=2'b00;


	hyperfetch_detection_temp_data[3:0]='{16'hx,16'hx,16'hx,16'hx}; // I just use hyperfetch_detection_temp_data for pleasant indexes
	hyperfetch_detection_temp_data[11:4]=data_in_raw[7:0];
	
	hyperfetch_detection_temp_data_is_load[4]=(hyperfetch_detection_temp_data[4][15:13]==3'b0)? 1'b1:1'b0;
	hyperfetch_detection_temp_data_is_load[5]=(hyperfetch_detection_temp_data[5][15:13]==3'b0)? 1'b1:1'b0;
	hyperfetch_detection_temp_data_is_load[6]=(hyperfetch_detection_temp_data[6][15:13]==3'b0)? 1'b1:1'b0;
	hyperfetch_detection_temp_data_is_load[7]=(hyperfetch_detection_temp_data[7][15:13]==3'b0)? 1'b1:1'b0;
	hyperfetch_detection_temp_data_is_load[8]=(hyperfetch_detection_temp_data[8][15:13]==3'b0)? 1'b1:1'b0;
	hyperfetch_detection_temp_data_is_load[9]=(hyperfetch_detection_temp_data[9][15:13]==3'b0)? 1'b1:1'b0;
	hyperfetch_detection_temp_data_is_load[10]=(hyperfetch_detection_temp_data[10][15:13]==3'b0)? 1'b1:1'b0;
	hyperfetch_detection_temp_data_is_load[11]=(hyperfetch_detection_temp_data[11][15:13]==3'b0)? 1'b1:1'b0;
	
	hyperfetch_suggestion_on_input_validity=0;
	haltingjump_on_input_known=0;
	extra_haltingjump_on_input_known=5'h0;
	hyperfetch_suggestion_on_input_temp=32'hx;
	hyperfetch_suggestion_on_input=25'hx;
	
	extra_hyperjump_addresses_including_input=extra_hyperjump_addresses;
	extra_hyperfetch_suggestion_on_input_validity=0;
	
	if (is_data_coming_in[0] || is_data_coming_in[1]) begin
		if (data_in_size_at_least[7] && (hyperfetch_detection_temp_data[11][15:11]==5'h1F && (hyperfetch_detection_temp_data[11][10:9]==2'b01 || hyperfetch_detection_temp_data[11][10:8]==3'b110))) begin
			haltingjump_on_input_known=1;
			if (recent_jump_data_size[0]<4'd8) extra_haltingjump_on_input_known[0]=1'b1;
			if (recent_jump_data_size[1]<4'd8) extra_haltingjump_on_input_known[1]=1'b1;
			if (recent_jump_data_size[2]<4'd8) extra_haltingjump_on_input_known[2]=1'b1;
			if (recent_jump_data_size[3]<4'd8) extra_haltingjump_on_input_known[3]=1'b1;
			if (hyperfetch_buffer_size  <4'd8) extra_haltingjump_on_input_known[4]=1'b1;
			hyperfetch_suggestion_on_input_validity=0;
			extra_hyperfetch_suggestion_on_input_validity=0;
			if (hyperfetch_detection_temp_data_is_load[10] && hyperfetch_detection_temp_data_is_load[ 9] && hyperfetch_detection_temp_data_is_load[ 8] && hyperfetch_detection_temp_data_is_load[ 7]) begin
				hyperfetch_suggestion_on_input_validity=1;
				hyperfetch_suggestion_on_input_temp[ 7: 0]=hyperfetch_detection_temp_data[ 7][11:4];
				hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[ 9][11:4];
				hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_temp_data[ 8][11:4];
				hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[10][11:4];
				hyperfetch_suggestion_on_input=hyperfetch_suggestion_on_input_temp[25:1];
				if (recent_jump_data_size[0]<4'd8 && !extra_hyperjump_known[0]) begin extra_hyperfetch_suggestion_on_input_validity[0]=1'b1;extra_hyperjump_addresses_including_input[0]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (recent_jump_data_size[1]<4'd8 && !extra_hyperjump_known[1]) begin extra_hyperfetch_suggestion_on_input_validity[1]=1'b1;extra_hyperjump_addresses_including_input[1]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (recent_jump_data_size[2]<4'd8 && !extra_hyperjump_known[2]) begin extra_hyperfetch_suggestion_on_input_validity[2]=1'b1;extra_hyperjump_addresses_including_input[2]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (recent_jump_data_size[3]<4'd8 && !extra_hyperjump_known[3]) begin extra_hyperfetch_suggestion_on_input_validity[3]=1'b1;extra_hyperjump_addresses_including_input[3]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (hyperfetch_buffer_size  <4'd8 && !extra_hyperjump_known[4]) begin extra_hyperfetch_suggestion_on_input_validity[4]=1'b1;extra_hyperjump_addresses_including_input[4]=hyperfetch_suggestion_on_input_temp[25:1];end
			end
		end
		if (data_in_size_at_least[6] && (hyperfetch_detection_temp_data[10][15:11]==5'h1F && (hyperfetch_detection_temp_data[10][10:9]==2'b01 || hyperfetch_detection_temp_data[10][10:8]==3'b110))) begin
			haltingjump_on_input_known=1;
			extra_haltingjump_on_input_known=5'h1F;
			hyperfetch_suggestion_on_input_validity=0;
			extra_hyperfetch_suggestion_on_input_validity=0;
			if (hyperfetch_detection_temp_data_is_load[9] && hyperfetch_detection_temp_data_is_load[8] && hyperfetch_detection_temp_data_is_load[7] && hyperfetch_detection_temp_data_is_load[6]) begin
				hyperfetch_suggestion_on_input_validity=1;
				hyperfetch_suggestion_on_input_temp[ 7: 0]=hyperfetch_detection_temp_data[6][11:4];
				hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[8][11:4];
				hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_temp_data[7][11:4];
				hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[9][11:4];
				hyperfetch_suggestion_on_input=hyperfetch_suggestion_on_input_temp[25:1];
				if (!extra_hyperjump_known[0]) begin extra_hyperfetch_suggestion_on_input_validity[0]=1'b1;extra_hyperjump_addresses_including_input[0]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[1]) begin extra_hyperfetch_suggestion_on_input_validity[1]=1'b1;extra_hyperjump_addresses_including_input[1]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[2]) begin extra_hyperfetch_suggestion_on_input_validity[2]=1'b1;extra_hyperjump_addresses_including_input[2]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[3]) begin extra_hyperfetch_suggestion_on_input_validity[3]=1'b1;extra_hyperjump_addresses_including_input[3]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[4]) begin extra_hyperfetch_suggestion_on_input_validity[4]=1'b1;extra_hyperjump_addresses_including_input[4]=hyperfetch_suggestion_on_input_temp[25:1];end
			end
		end
		if (data_in_size_at_least[5] && (hyperfetch_detection_temp_data[9][15:11]==5'h1F && (hyperfetch_detection_temp_data[9][10:9]==2'b01 || hyperfetch_detection_temp_data[9][10:8]==3'b110))) begin
			haltingjump_on_input_known=1;
			extra_haltingjump_on_input_known=5'h1F;
			hyperfetch_suggestion_on_input_validity=0;
			extra_hyperfetch_suggestion_on_input_validity=0;
			if (hyperfetch_detection_temp_data_is_load[8] && hyperfetch_detection_temp_data_is_load[7] && hyperfetch_detection_temp_data_is_load[6] && hyperfetch_detection_temp_data_is_load[5]) begin
				hyperfetch_suggestion_on_input_validity=1;
				hyperfetch_suggestion_on_input_temp[ 7: 0]=hyperfetch_detection_temp_data[5][11:4];
				hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[7][11:4];
				hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_temp_data[6][11:4];
				hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[8][11:4];
				hyperfetch_suggestion_on_input=hyperfetch_suggestion_on_input_temp[25:1];
				if (!extra_hyperjump_known[0]) begin extra_hyperfetch_suggestion_on_input_validity[0]=1'b1;extra_hyperjump_addresses_including_input[0]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[1]) begin extra_hyperfetch_suggestion_on_input_validity[1]=1'b1;extra_hyperjump_addresses_including_input[1]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[2]) begin extra_hyperfetch_suggestion_on_input_validity[2]=1'b1;extra_hyperjump_addresses_including_input[2]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[3]) begin extra_hyperfetch_suggestion_on_input_validity[3]=1'b1;extra_hyperjump_addresses_including_input[3]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[4]) begin extra_hyperfetch_suggestion_on_input_validity[4]=1'b1;extra_hyperjump_addresses_including_input[4]=hyperfetch_suggestion_on_input_temp[25:1];end
			end
		end
		if (data_in_size_at_least[4] && (hyperfetch_detection_temp_data[8][15:11]==5'h1F && (hyperfetch_detection_temp_data[8][10:9]==2'b01 || hyperfetch_detection_temp_data[8][10:8]==3'b110))) begin
			haltingjump_on_input_known=1;
			extra_haltingjump_on_input_known=5'h1F;
			hyperfetch_suggestion_on_input_validity=0;
			extra_hyperfetch_suggestion_on_input_validity=0;
			if (hyperfetch_detection_temp_data_is_load[7] && hyperfetch_detection_temp_data_is_load[6] && hyperfetch_detection_temp_data_is_load[5] && hyperfetch_detection_temp_data_is_load[4]) begin
				hyperfetch_suggestion_on_input_validity=1;
				hyperfetch_suggestion_on_input_temp[ 7: 0]=hyperfetch_detection_temp_data[4][11:4];
				hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[6][11:4];
				hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_temp_data[5][11:4];
				hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[7][11:4];
				hyperfetch_suggestion_on_input=hyperfetch_suggestion_on_input_temp[25:1];
				if (!extra_hyperjump_known[0]) begin extra_hyperfetch_suggestion_on_input_validity[0]=1'b1;extra_hyperjump_addresses_including_input[0]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[1]) begin extra_hyperfetch_suggestion_on_input_validity[1]=1'b1;extra_hyperjump_addresses_including_input[1]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[2]) begin extra_hyperfetch_suggestion_on_input_validity[2]=1'b1;extra_hyperjump_addresses_including_input[2]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[3]) begin extra_hyperfetch_suggestion_on_input_validity[3]=1'b1;extra_hyperjump_addresses_including_input[3]=hyperfetch_suggestion_on_input_temp[25:1];end
				if (!extra_hyperjump_known[4]) begin extra_hyperfetch_suggestion_on_input_validity[4]=1'b1;extra_hyperjump_addresses_including_input[4]=hyperfetch_suggestion_on_input_temp[25:1];end
			end
		end
		if (data_in_size_at_least[3] && (hyperfetch_detection_temp_data[7][15:11]==5'h1F && (hyperfetch_detection_temp_data[7][10:9]==2'b01 || hyperfetch_detection_temp_data[7][10:8]==3'b110))) begin
			haltingjump_on_input_known=1;
			extra_haltingjump_on_input_known=5'h1F;
			hyperfetch_suggestion_on_input_validity=0;
			extra_hyperfetch_suggestion_on_input_validity=0;
			if (hyperfetch_detection_temp_data_is_load[6] && hyperfetch_detection_temp_data_is_load[5] && hyperfetch_detection_temp_data_is_load[4]) begin
				if (hyperfetch_detection_helper_data[3][15:13]==3'b0) begin
					hyperfetch_suggestion_on_input_validity=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=hyperfetch_detection_helper_data[3][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[5][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[6][11:4];
					hyperfetch_suggestion_on_input=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[0] && (extra_hyperfetch_detection_temp_data[0][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[0][3])) begin
					extra_hyperfetch_suggestion_on_input_validity[0]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[0][3][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[5][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[6][11:4];
					extra_hyperjump_addresses_including_input[0]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[1] && (extra_hyperfetch_detection_temp_data[1][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[1][3])) begin
					extra_hyperfetch_suggestion_on_input_validity[1]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[1][3][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[5][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[6][11:4];
					extra_hyperjump_addresses_including_input[1]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[2] && (extra_hyperfetch_detection_temp_data[2][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[2][3])) begin
					extra_hyperfetch_suggestion_on_input_validity[2]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[2][3][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[5][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[6][11:4];
					extra_hyperjump_addresses_including_input[2]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[3] && (extra_hyperfetch_detection_temp_data[3][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[3][3])) begin
					extra_hyperfetch_suggestion_on_input_validity[3]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[3][3][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[5][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[6][11:4];
					extra_hyperjump_addresses_including_input[3]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[4] && (extra_hyperfetch_detection_temp_data[4][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[4][3])) begin
					extra_hyperfetch_suggestion_on_input_validity[4]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[4][3][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[5][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[6][11:4];
					extra_hyperjump_addresses_including_input[4]=hyperfetch_suggestion_on_input_temp[25:1];
				end
			end
		end
		if (data_in_size_at_least[2] && (hyperfetch_detection_temp_data[6][15:11]==5'h1F && (hyperfetch_detection_temp_data[6][10:9]==2'b01 || hyperfetch_detection_temp_data[6][10:8]==3'b110))) begin
			haltingjump_on_input_known=1;
			extra_haltingjump_on_input_known=5'h1F;
			hyperfetch_suggestion_on_input_validity=0;
			extra_hyperfetch_suggestion_on_input_validity=0;
			if (hyperfetch_detection_temp_data_is_load[5] && hyperfetch_detection_temp_data_is_load[4]) begin
				if (hyperfetch_detection_helper_data[3][15:13]==3'b0 && hyperfetch_detection_helper_data[2][15:13]==3'b0) begin
					hyperfetch_suggestion_on_input_validity=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=hyperfetch_detection_helper_data[2][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_helper_data[3][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[5][11:4];
					hyperfetch_suggestion_on_input=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[0] && (extra_hyperfetch_detection_temp_data[0][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[0][3]) && (extra_hyperfetch_detection_temp_data[0][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[0][2])) begin
					extra_hyperfetch_suggestion_on_input_validity[0]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[0][2][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[0][3][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[5][11:4];
					extra_hyperjump_addresses_including_input[0]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[1] && (extra_hyperfetch_detection_temp_data[1][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[1][3]) && (extra_hyperfetch_detection_temp_data[1][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[1][2])) begin
					extra_hyperfetch_suggestion_on_input_validity[1]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[1][2][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[1][3][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[5][11:4];
					extra_hyperjump_addresses_including_input[1]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[2] && (extra_hyperfetch_detection_temp_data[2][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[2][3]) && (extra_hyperfetch_detection_temp_data[2][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[2][2])) begin
					extra_hyperfetch_suggestion_on_input_validity[2]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[2][2][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[2][3][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[5][11:4];
					extra_hyperjump_addresses_including_input[2]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[3] && (extra_hyperfetch_detection_temp_data[3][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[3][3]) && (extra_hyperfetch_detection_temp_data[3][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[3][2])) begin
					extra_hyperfetch_suggestion_on_input_validity[3]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[3][2][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[3][3][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[5][11:4];
					extra_hyperjump_addresses_including_input[3]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[4] && (extra_hyperfetch_detection_temp_data[4][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[4][3]) && (extra_hyperfetch_detection_temp_data[4][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[4][2])) begin
					extra_hyperfetch_suggestion_on_input_validity[4]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[4][2][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[4][3][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[5][11:4];
					extra_hyperjump_addresses_including_input[4]=hyperfetch_suggestion_on_input_temp[25:1];
				end
			end
		end
		if (data_in_size_at_least[1] && (hyperfetch_detection_temp_data[5][15:11]==5'h1F && (hyperfetch_detection_temp_data[5][10:9]==2'b01 || hyperfetch_detection_temp_data[5][10:8]==3'b110))) begin
			haltingjump_on_input_known=1;
			extra_haltingjump_on_input_known=5'h1F;
			hyperfetch_suggestion_on_input_validity=0;
			extra_hyperfetch_suggestion_on_input_validity=0;
			if (hyperfetch_detection_temp_data_is_load[4]) begin
				if (hyperfetch_detection_helper_data[3][15:13]==3'b0 && hyperfetch_detection_helper_data[2][15:13]==3'b0 && hyperfetch_detection_helper_data[1][15:13]==3'b0) begin
					hyperfetch_suggestion_on_input_validity=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=hyperfetch_detection_helper_data[1][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_helper_data[3][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_helper_data[2][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[4][11:4];
					hyperfetch_suggestion_on_input=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[0] && (extra_hyperfetch_detection_temp_data[0][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[0][3]) && (extra_hyperfetch_detection_temp_data[0][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[0][2]) && (extra_hyperfetch_detection_temp_data[0][1][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[0][1])) begin
					extra_hyperfetch_suggestion_on_input_validity[0]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[0][1][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=extra_hyperfetch_detection_temp_data[0][3][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[0][2][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[4][11:4];
					extra_hyperjump_addresses_including_input[0]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[1] && (extra_hyperfetch_detection_temp_data[1][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[1][3]) && (extra_hyperfetch_detection_temp_data[1][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[1][2]) && (extra_hyperfetch_detection_temp_data[1][1][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[1][1])) begin
					extra_hyperfetch_suggestion_on_input_validity[1]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[1][1][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=extra_hyperfetch_detection_temp_data[1][3][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[1][2][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[4][11:4];
					extra_hyperjump_addresses_including_input[1]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[2] && (extra_hyperfetch_detection_temp_data[2][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[2][3]) && (extra_hyperfetch_detection_temp_data[2][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[2][2]) && (extra_hyperfetch_detection_temp_data[2][1][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[2][1])) begin
					extra_hyperfetch_suggestion_on_input_validity[2]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[2][1][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=extra_hyperfetch_detection_temp_data[2][3][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[2][2][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[4][11:4];
					extra_hyperjump_addresses_including_input[2]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[3] && (extra_hyperfetch_detection_temp_data[3][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[3][3]) && (extra_hyperfetch_detection_temp_data[3][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[3][2]) && (extra_hyperfetch_detection_temp_data[3][1][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[3][1])) begin
					extra_hyperfetch_suggestion_on_input_validity[3]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[3][1][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=extra_hyperfetch_detection_temp_data[3][3][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[3][2][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[4][11:4];
					extra_hyperjump_addresses_including_input[3]=hyperfetch_suggestion_on_input_temp[25:1];
				end
				if (!extra_hyperjump_known[4] && (extra_hyperfetch_detection_temp_data[4][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[4][3]) && (extra_hyperfetch_detection_temp_data[4][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[4][2]) && (extra_hyperfetch_detection_temp_data[4][1][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[4][1])) begin
					extra_hyperfetch_suggestion_on_input_validity[4]=1;
					hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[4][1][11:4];
					hyperfetch_suggestion_on_input_temp[15: 8]=extra_hyperfetch_detection_temp_data[4][3][11:4];
					hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[4][2][11:4];
					hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_temp_data[4][11:4];
					extra_hyperjump_addresses_including_input[4]=hyperfetch_suggestion_on_input_temp[25:1];
				end
			end
		end
		if (data_in_size_at_least[0] && (hyperfetch_detection_temp_data[4][15:11]==5'h1F && (hyperfetch_detection_temp_data[4][10:9]==2'b01 || hyperfetch_detection_temp_data[4][10:8]==3'b110))) begin
			haltingjump_on_input_known=1;
			extra_haltingjump_on_input_known=5'h1F;
			hyperfetch_suggestion_on_input_validity=0;
			extra_hyperfetch_suggestion_on_input_validity=0;
			if (hyperfetch_detection_helper_data[3][15:13]==3'b0 && hyperfetch_detection_helper_data[2][15:13]==3'b0 && hyperfetch_detection_helper_data[1][15:13]==3'b0 && hyperfetch_detection_helper_data[0][15:13]==3'b0) begin
				hyperfetch_suggestion_on_input_validity=1;
				hyperfetch_suggestion_on_input_temp[ 7: 0]=hyperfetch_detection_helper_data[0][11:4];
				hyperfetch_suggestion_on_input_temp[15: 8]=hyperfetch_detection_helper_data[2][11:4];
				hyperfetch_suggestion_on_input_temp[23:16]=hyperfetch_detection_helper_data[1][11:4];
				hyperfetch_suggestion_on_input_temp[31:24]=hyperfetch_detection_helper_data[3][11:4];
				hyperfetch_suggestion_on_input=hyperfetch_suggestion_on_input_temp[25:1];
			end
			if (!extra_hyperjump_known[0] && (extra_hyperfetch_detection_temp_data[0][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[0][3]) && (extra_hyperfetch_detection_temp_data[0][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[0][2]) && (extra_hyperfetch_detection_temp_data[0][1][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[0][1]) && (extra_hyperfetch_detection_temp_data[0][0][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[0][0])) begin
				extra_hyperfetch_suggestion_on_input_validity[0]=1;
				hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[0][0][11:4];
				hyperfetch_suggestion_on_input_temp[15: 8]=extra_hyperfetch_detection_temp_data[0][2][11:4];
				hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[0][1][11:4];
				hyperfetch_suggestion_on_input_temp[31:24]=extra_hyperfetch_detection_temp_data[0][3][11:4];
				extra_hyperjump_addresses_including_input[0]=hyperfetch_suggestion_on_input_temp[25:1];
			end
			if (!extra_hyperjump_known[1] && (extra_hyperfetch_detection_temp_data[1][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[1][3]) && (extra_hyperfetch_detection_temp_data[1][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[1][2]) && (extra_hyperfetch_detection_temp_data[1][1][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[1][1]) && (extra_hyperfetch_detection_temp_data[1][0][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[1][0])) begin
				extra_hyperfetch_suggestion_on_input_validity[1]=1;
				hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[1][0][11:4];
				hyperfetch_suggestion_on_input_temp[15: 8]=extra_hyperfetch_detection_temp_data[1][2][11:4];
				hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[1][1][11:4];
				hyperfetch_suggestion_on_input_temp[31:24]=extra_hyperfetch_detection_temp_data[1][3][11:4];
				extra_hyperjump_addresses_including_input[1]=hyperfetch_suggestion_on_input_temp[25:1];
			end
			if (!extra_hyperjump_known[2] && (extra_hyperfetch_detection_temp_data[2][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[2][3]) && (extra_hyperfetch_detection_temp_data[2][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[2][2]) && (extra_hyperfetch_detection_temp_data[2][1][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[2][1]) && (extra_hyperfetch_detection_temp_data[2][0][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[2][0])) begin
				extra_hyperfetch_suggestion_on_input_validity[2]=1;
				hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[2][0][11:4];
				hyperfetch_suggestion_on_input_temp[15: 8]=extra_hyperfetch_detection_temp_data[2][2][11:4];
				hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[2][1][11:4];
				hyperfetch_suggestion_on_input_temp[31:24]=extra_hyperfetch_detection_temp_data[2][3][11:4];
				extra_hyperjump_addresses_including_input[2]=hyperfetch_suggestion_on_input_temp[25:1];
			end
			if (!extra_hyperjump_known[3] && (extra_hyperfetch_detection_temp_data[3][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[3][3]) && (extra_hyperfetch_detection_temp_data[3][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[3][2]) && (extra_hyperfetch_detection_temp_data[3][1][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[3][1]) && (extra_hyperfetch_detection_temp_data[3][0][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[3][0])) begin
				extra_hyperfetch_suggestion_on_input_validity[3]=1;
				hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[3][0][11:4];
				hyperfetch_suggestion_on_input_temp[15: 8]=extra_hyperfetch_detection_temp_data[3][2][11:4];
				hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[3][1][11:4];
				hyperfetch_suggestion_on_input_temp[31:24]=extra_hyperfetch_detection_temp_data[3][3][11:4];
				extra_hyperjump_addresses_including_input[3]=hyperfetch_suggestion_on_input_temp[25:1];
			end
			if (!extra_hyperjump_known[4] && (extra_hyperfetch_detection_temp_data[4][3][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[4][3]) && (extra_hyperfetch_detection_temp_data[4][2][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[4][2]) && (extra_hyperfetch_detection_temp_data[4][1][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[4][1]) && (extra_hyperfetch_detection_temp_data[4][0][15:13]==3'b0 && extra_hyperfetch_detection_temp_validity[4][0])) begin
				extra_hyperfetch_suggestion_on_input_validity[4]=1;
				hyperfetch_suggestion_on_input_temp[ 7: 0]=extra_hyperfetch_detection_temp_data[4][0][11:4];
				hyperfetch_suggestion_on_input_temp[15: 8]=extra_hyperfetch_detection_temp_data[4][2][11:4];
				hyperfetch_suggestion_on_input_temp[23:16]=extra_hyperfetch_detection_temp_data[4][1][11:4];
				hyperfetch_suggestion_on_input_temp[31:24]=extra_hyperfetch_detection_temp_data[4][3][11:4];
				extra_hyperjump_addresses_including_input[4]=hyperfetch_suggestion_on_input_temp[25:1];
			end
		end
	end
	hyperfetch_suggestion_on_input_validity=hyperfetch_suggestion_on_input_validity & haltingjump_on_input_known; // probably not needed, but just to make sure
	extra_hyperfetch_suggestion_on_input_validity=extra_hyperfetch_suggestion_on_input_validity & extra_haltingjump_on_input_known; // probably not needed, but just to make sure
	
	extra_hyperfetch_suggestion_on_input_validity=extra_hyperfetch_suggestion_on_input_validity & ~extra_haltingjump_known;// if a halting jump is already known in that buffer then don't accept the new hyperfetch information because it won't occur
end


wire [24:0] recent_jump_address_difference [1:0][3:0];
assign recent_jump_address_difference[0][0]=instruction_fetch0_pointer - recent_jump_addresses[0];
assign recent_jump_address_difference[1][0]=instruction_fetch1_pointer - recent_jump_addresses[0];
assign recent_jump_address_difference[0][1]=instruction_fetch0_pointer - recent_jump_addresses[1];
assign recent_jump_address_difference[1][1]=instruction_fetch1_pointer - recent_jump_addresses[1];
assign recent_jump_address_difference[0][2]=instruction_fetch0_pointer - recent_jump_addresses[2];
assign recent_jump_address_difference[1][2]=instruction_fetch1_pointer - recent_jump_addresses[2];
assign recent_jump_address_difference[0][3]=instruction_fetch0_pointer - recent_jump_addresses[3];
assign recent_jump_address_difference[1][3]=instruction_fetch1_pointer - recent_jump_addresses[3];



hyperfetch_generation hyperfetch_generation_inst0(
	.haltingjump_known_out(extra_haltingjump_known_test[0]),
	.hyperjump_known_out(extra_hyperjump_known_test[0]),
	.hyperfetch_address_out(extra_hyperjump_addresses_test[0]),
	.instruction_data(recent_jump_data_raw[0]),
	.valid_size(recent_jump_data_size[0])
);

hyperfetch_generation hyperfetch_generation_inst1(
	.haltingjump_known_out(extra_haltingjump_known_test[1]),
	.hyperjump_known_out(extra_hyperjump_known_test[1]),
	.hyperfetch_address_out(extra_hyperjump_addresses_test[1]),
	.instruction_data(recent_jump_data_raw[1]),
	.valid_size(recent_jump_data_size[1])
);

hyperfetch_generation hyperfetch_generation_inst2(
	.haltingjump_known_out(extra_haltingjump_known_test[2]),
	.hyperjump_known_out(extra_hyperjump_known_test[2]),
	.hyperfetch_address_out(extra_hyperjump_addresses_test[2]),
	.instruction_data(recent_jump_data_raw[2]),
	.valid_size(recent_jump_data_size[2])
);

hyperfetch_generation hyperfetch_generation_inst3(
	.haltingjump_known_out(extra_haltingjump_known_test[3]),
	.hyperjump_known_out(extra_hyperjump_known_test[3]),
	.hyperfetch_address_out(extra_hyperjump_addresses_test[3]),
	.instruction_data(recent_jump_data_raw[3]),
	.valid_size(recent_jump_data_size[3])
);

hyperfetch_generation hyperfetch_generation_inst4(
	.haltingjump_known_out(extra_haltingjump_known_test[4]),
	.hyperjump_known_out(extra_hyperjump_known_test[4]),
	.hyperfetch_address_out(extra_hyperjump_addresses_test[4]),
	.instruction_data(hyperfetch_buffer),
	.valid_size(hyperfetch_buffer_size)
);

always @(posedge main_clk) begin
	assert (extra_haltingjump_known_test==extra_haltingjump_known);
	assert (extra_hyperjump_known_test==extra_hyperjump_known);
	if (extra_hyperjump_known[0]) assert (extra_hyperjump_addresses_test[0]==extra_hyperjump_addresses[0]);
	if (extra_hyperjump_known[1]) assert (extra_hyperjump_addresses_test[1]==extra_hyperjump_addresses[1]);
	if (extra_hyperjump_known[2]) assert (extra_hyperjump_addresses_test[2]==extra_hyperjump_addresses[2]);
	if (extra_hyperjump_known[3]) assert (extra_hyperjump_addresses_test[3]==extra_hyperjump_addresses[3]);
	if (extra_hyperjump_known[4]) assert (extra_hyperjump_addresses_test[4]==extra_hyperjump_addresses[4]);
end

reg fetch_tradeoff_toggle=0;
reg [15:0] ready_instructions_next [2:0];

always_comb begin
	ready_instructions_next=ready_instructions;
	unique case (used_ready_instruction_count)
	0:begin
	end
	1:begin
		ready_instructions_next[0]=ready_instructions_next[1];
		ready_instructions_next[1]=ready_instructions_next[2];
		ready_instructions_next[2]=16'hx;
	end
	2:begin
		ready_instructions_next[0]=ready_instructions_next[2];
		ready_instructions_next[2:1]='{16'hx,16'hx};
	end
	3:begin
		ready_instructions_next[2:0]='{16'hx,16'hx,16'hx};
	end
	endcase
	unique case (ready_fill_satisfied)
	0:begin
	end
	1:begin
		unique case (ready_left)
		0:ready_instructions_next[0]=circular_prepared_instruction_read_table_at_prepared_instructions[0];
		1:ready_instructions_next[1]=circular_prepared_instruction_read_table_at_prepared_instructions[0];
		2:ready_instructions_next[2]=circular_prepared_instruction_read_table_at_prepared_instructions[0];
		endcase
	end
	2:begin
		unique case (ready_left)
		0:ready_instructions_next[1:0]=circular_prepared_instruction_read_table_at_prepared_instructions[1:0];
		1:ready_instructions_next[2:1]=circular_prepared_instruction_read_table_at_prepared_instructions[1:0];
		endcase
	end
	3:begin
		unique case (ready_left)
		0:ready_instructions_next[2:0]=circular_prepared_instruction_read_table_at_prepared_instructions[2:0];
		endcase
	end
	endcase
end


reg [5:0] circular_address_write_next;
reg [5:0] circular_address_read_next;

wire [15:0] circular_prepared_instruction_write_decoded;
decode4 decode4_cpiwd(circular_prepared_instruction_write_decoded,circular_prepared_instruction_write);

wire [7:0] buffer_size_used_grlc;
wire [7:0] buffer_size_used_gr;
lcells #(8) lc_buffsizegr(buffer_size_used_grlc,buffer_size_used_gr);
assign buffer_size_used_gr[0]=(buffer_size_used>=4'h1)? 1'b1:1'b0;
assign buffer_size_used_gr[1]=(buffer_size_used>=4'h2)? 1'b1:1'b0;
assign buffer_size_used_gr[2]=(buffer_size_used>=4'h3)? 1'b1:1'b0;
assign buffer_size_used_gr[3]=(buffer_size_used>=4'h4)? 1'b1:1'b0;
assign buffer_size_used_gr[4]=(buffer_size_used>=4'h5)? 1'b1:1'b0;
assign buffer_size_used_gr[5]=(buffer_size_used>=4'h6)? 1'b1:1'b0;
assign buffer_size_used_gr[6]=(buffer_size_used>=4'h7)? 1'b1:1'b0;
assign buffer_size_used_gr[7]=(buffer_size_used==4'h8)? 1'b1:1'b0;

wire [15:0] circular_prepared_instruction_write_enable;
wire [15:0] circular_prepared_instruction_write_enable_lc;
lcells #(16) lc_cpiwe(circular_prepared_instruction_write_enable_lc,circular_prepared_instruction_write_enable);

assign circular_prepared_instruction_write_enable[0]=((circular_prepared_instruction_write_decoded[0] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[15] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[14] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[13] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[12] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[11] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[10] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[9] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[1]=((circular_prepared_instruction_write_decoded[1] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[0] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[15] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[14] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[13] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[12] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[11] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[10] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[2]=((circular_prepared_instruction_write_decoded[2] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[1] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[0] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[15] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[14] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[13] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[12] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[11] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[3]=((circular_prepared_instruction_write_decoded[3] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[2] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[1] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[0] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[15] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[14] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[13] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[12] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[4]=((circular_prepared_instruction_write_decoded[4] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[3] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[2] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[1] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[0] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[15] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[14] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[13] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[5]=((circular_prepared_instruction_write_decoded[5] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[4] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[3] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[2] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[1] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[0] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[15] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[14] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[6]=((circular_prepared_instruction_write_decoded[6] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[5] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[4] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[3] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[2] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[1] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[0] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[15] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[7]=((circular_prepared_instruction_write_decoded[7] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[6] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[5] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[4] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[3] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[2] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[1] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[0] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[8]=((circular_prepared_instruction_write_decoded[8] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[7] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[6] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[5] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[4] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[3] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[2] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[1] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[9]=((circular_prepared_instruction_write_decoded[9] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[8] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[7] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[6] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[5] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[4] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[3] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[2] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[10]=((circular_prepared_instruction_write_decoded[10] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[9] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[8] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[7] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[6] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[5] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[4] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[3] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[11]=((circular_prepared_instruction_write_decoded[11] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[10] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[9] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[8] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[7] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[6] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[5] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[4] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[12]=((circular_prepared_instruction_write_decoded[12] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[11] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[10] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[9] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[8] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[7] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[6] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[5] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[13]=((circular_prepared_instruction_write_decoded[13] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[12] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[11] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[10] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[9] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[8] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[7] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[6] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[14]=((circular_prepared_instruction_write_decoded[14] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[13] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[12] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[11] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[10] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[9] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[8] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[7] && buffer_size_used_grlc[7]))? 1'b1:1'b0;
assign circular_prepared_instruction_write_enable[15]=((circular_prepared_instruction_write_decoded[15] && buffer_size_used_grlc[0]) || (circular_prepared_instruction_write_decoded[14] && buffer_size_used_grlc[1]) || (circular_prepared_instruction_write_decoded[13] && buffer_size_used_grlc[2]) || (circular_prepared_instruction_write_decoded[12] && buffer_size_used_grlc[3]) || (circular_prepared_instruction_write_decoded[11] && buffer_size_used_grlc[4]) || (circular_prepared_instruction_write_decoded[10] && buffer_size_used_grlc[5]) || (circular_prepared_instruction_write_decoded[9] && buffer_size_used_grlc[6]) || (circular_prepared_instruction_write_decoded[8] && buffer_size_used_grlc[7]))? 1'b1:1'b0;

reg [15:0] circular_prepared_instruction_write_values [7:0];
reg [15:0] circular_prepared_instruction_write_values_old [15:0];
wire [15:0] circular_prepared_instruction_write_values_lc [15:0];
always_comb begin
	circular_prepared_instruction_write_values_old='{16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx};
	unique case (circular_prepared_instruction_write)
	0:circular_prepared_instruction_write_values_old[7:0]=buffer_instructions;
	1:circular_prepared_instruction_write_values_old[8:1]=buffer_instructions;
	2:circular_prepared_instruction_write_values_old[9:2]=buffer_instructions;
	3:circular_prepared_instruction_write_values_old[10:3]=buffer_instructions;
	4:circular_prepared_instruction_write_values_old[11:4]=buffer_instructions;
	5:circular_prepared_instruction_write_values_old[12:5]=buffer_instructions;
	6:circular_prepared_instruction_write_values_old[13:6]=buffer_instructions;
	7:circular_prepared_instruction_write_values_old[14:7]=buffer_instructions;
	8:circular_prepared_instruction_write_values_old[15:8]=buffer_instructions;
	9:begin circular_prepared_instruction_write_values_old[15:9]=buffer_instructions[6:0];circular_prepared_instruction_write_values_old[0]=buffer_instructions[7];end
	10:begin circular_prepared_instruction_write_values_old[15:10]=buffer_instructions[5:0];circular_prepared_instruction_write_values_old[1:0]=buffer_instructions[7:6];end
	11:begin circular_prepared_instruction_write_values_old[15:11]=buffer_instructions[4:0];circular_prepared_instruction_write_values_old[2:0]=buffer_instructions[7:5];end
	12:begin circular_prepared_instruction_write_values_old[15:12]=buffer_instructions[3:0];circular_prepared_instruction_write_values_old[3:0]=buffer_instructions[7:4];end
	13:begin circular_prepared_instruction_write_values_old[15:13]=buffer_instructions[2:0];circular_prepared_instruction_write_values_old[4:0]=buffer_instructions[7:3];end
	14:begin circular_prepared_instruction_write_values_old[15:14]=buffer_instructions[1:0];circular_prepared_instruction_write_values_old[5:0]=buffer_instructions[7:2];end
	15:begin circular_prepared_instruction_write_values_old[15]=buffer_instructions[0];circular_prepared_instruction_write_values_old[6:0]=buffer_instructions[7:1];end
	endcase
end
always_comb begin
	circular_prepared_instruction_write_values='{16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx};
	unique case (circular_prepared_instruction_write[2:0])
	0:begin circular_prepared_instruction_write_values[7:0]=buffer_instructions;end
	1:begin circular_prepared_instruction_write_values[7:1]=buffer_instructions[6:0];circular_prepared_instruction_write_values[0]=buffer_instructions[7];end
	2:begin circular_prepared_instruction_write_values[7:2]=buffer_instructions[5:0];circular_prepared_instruction_write_values[1:0]=buffer_instructions[7:6];end
	3:begin circular_prepared_instruction_write_values[7:3]=buffer_instructions[4:0];circular_prepared_instruction_write_values[2:0]=buffer_instructions[7:5];end
	4:begin circular_prepared_instruction_write_values[7:4]=buffer_instructions[3:0];circular_prepared_instruction_write_values[3:0]=buffer_instructions[7:4];end
	5:begin circular_prepared_instruction_write_values[7:5]=buffer_instructions[2:0];circular_prepared_instruction_write_values[4:0]=buffer_instructions[7:3];end
	6:begin circular_prepared_instruction_write_values[7:6]=buffer_instructions[1:0];circular_prepared_instruction_write_values[5:0]=buffer_instructions[7:2];end
	7:begin circular_prepared_instruction_write_values[7]=buffer_instructions[0];circular_prepared_instruction_write_values[6:0]=buffer_instructions[7:1];end
	endcase
end
always @(posedge main_clk) begin
	if (circular_prepared_instruction_write_enable[0]) assert(circular_prepared_instruction_write_values[0]===circular_prepared_instruction_write_values_old[0]);
	if (circular_prepared_instruction_write_enable[1]) assert(circular_prepared_instruction_write_values[1]===circular_prepared_instruction_write_values_old[1]);
	if (circular_prepared_instruction_write_enable[2]) assert(circular_prepared_instruction_write_values[2]===circular_prepared_instruction_write_values_old[2]);
	if (circular_prepared_instruction_write_enable[3]) assert(circular_prepared_instruction_write_values[3]===circular_prepared_instruction_write_values_old[3]);
	if (circular_prepared_instruction_write_enable[4]) assert(circular_prepared_instruction_write_values[4]===circular_prepared_instruction_write_values_old[4]);
	if (circular_prepared_instruction_write_enable[5]) assert(circular_prepared_instruction_write_values[5]===circular_prepared_instruction_write_values_old[5]);
	if (circular_prepared_instruction_write_enable[6]) assert(circular_prepared_instruction_write_values[6]===circular_prepared_instruction_write_values_old[6]);
	if (circular_prepared_instruction_write_enable[7]) assert(circular_prepared_instruction_write_values[7]===circular_prepared_instruction_write_values_old[7]);
	if (circular_prepared_instruction_write_enable[8]) assert(circular_prepared_instruction_write_values[0]===circular_prepared_instruction_write_values_old[8]);
	if (circular_prepared_instruction_write_enable[9]) assert(circular_prepared_instruction_write_values[1]===circular_prepared_instruction_write_values_old[9]);
	if (circular_prepared_instruction_write_enable[10]) assert(circular_prepared_instruction_write_values[2]===circular_prepared_instruction_write_values_old[10]);
	if (circular_prepared_instruction_write_enable[11]) assert(circular_prepared_instruction_write_values[3]===circular_prepared_instruction_write_values_old[11]);
	if (circular_prepared_instruction_write_enable[12]) assert(circular_prepared_instruction_write_values[4]===circular_prepared_instruction_write_values_old[12]);
	if (circular_prepared_instruction_write_enable[13]) assert(circular_prepared_instruction_write_values[5]===circular_prepared_instruction_write_values_old[13]);
	if (circular_prepared_instruction_write_enable[14]) assert(circular_prepared_instruction_write_values[6]===circular_prepared_instruction_write_values_old[14]);
	if (circular_prepared_instruction_write_enable[15]) assert(circular_prepared_instruction_write_values[7]===circular_prepared_instruction_write_values_old[15]);
end


lcells #(16) lc0(circular_prepared_instruction_write_values_lc[0],circular_prepared_instruction_write_values[0]);
lcells #(16) lc1(circular_prepared_instruction_write_values_lc[1],circular_prepared_instruction_write_values[1]);
lcells #(16) lc2(circular_prepared_instruction_write_values_lc[2],circular_prepared_instruction_write_values[2]);
lcells #(16) lc3(circular_prepared_instruction_write_values_lc[3],circular_prepared_instruction_write_values[3]);
lcells #(16) lc4(circular_prepared_instruction_write_values_lc[4],circular_prepared_instruction_write_values[4]);
lcells #(16) lc5(circular_prepared_instruction_write_values_lc[5],circular_prepared_instruction_write_values[5]);
lcells #(16) lc6(circular_prepared_instruction_write_values_lc[6],circular_prepared_instruction_write_values[6]);
lcells #(16) lc7(circular_prepared_instruction_write_values_lc[7],circular_prepared_instruction_write_values[7]);
assign circular_prepared_instruction_write_values_lc[8]=circular_prepared_instruction_write_values_lc[0];
assign circular_prepared_instruction_write_values_lc[9]=circular_prepared_instruction_write_values_lc[1];
assign circular_prepared_instruction_write_values_lc[10]=circular_prepared_instruction_write_values_lc[2];
assign circular_prepared_instruction_write_values_lc[11]=circular_prepared_instruction_write_values_lc[3];
assign circular_prepared_instruction_write_values_lc[12]=circular_prepared_instruction_write_values_lc[4];
assign circular_prepared_instruction_write_values_lc[13]=circular_prepared_instruction_write_values_lc[5];
assign circular_prepared_instruction_write_values_lc[14]=circular_prepared_instruction_write_values_lc[6];
assign circular_prepared_instruction_write_values_lc[15]=circular_prepared_instruction_write_values_lc[7];

reg update_hyperfetch_helper_trigger=0;
reg update_hyperfetch_helper_trigger_NOW=0;

reg void_instruction_fetch_NTCNC;
reg [3:0] recent_jump_matchy_NTCNC [1:0];
reg [3:0] recent_jump_update_offset_NTCNC [1:0][3:0];
reg [24:0] instruction_pointer_out_NTCNC;
reg [3:0] circular_prepared_instruction_read_NTCNC;
reg [3:0] circular_prepared_instruction_write_NTCNC;
reg [15:0] ready_instructions_NTCNC [2:0];
reg [5:0] circular_address_read_NTCNC;
reg [5:0] circular_address_write_NTCNC;
reg [15:0] prepared_instructions_NTCNC [15:0];
reg [24:0] instruction_fetch0_pointer_NTCNC;
reg [24:0] instruction_fetch1_pointer_NTCNC;
reg [1:0] instruction_fetch_requesting_NTCNC;
reg fetch_tradeoff_toggle_NTCNC;
reg [3:0] prepared_instruction_count_NTCNC;
reg [15:0] hyperfetch_buffer_NTCNC [14:0];
reg [3:0] hyperfetch_buffer_size_NTCNC;
reg [15:0] hyperfetch_detection_helper_data_NTCNC [3:0];
reg [5:0] buffer_size_NTCNC;
reg waiting_on_jump_NTCNC;
reg waiting_on_hyperfetch_NTCNC;
reg [15:0] recent_jump_data_raw_NTCNC [3:0][14:0];
reg [14:0] recent_jump_data_valid_NTCNC [3:0];
reg [1:0] recent_jump_circular_position_NTCNC;
reg [24:0] recent_jump_addresses_NTCNC [3:0];
reg hyperfetch_address_valid_NTCNC;
reg [24:0] extra_hyperjump_addresses_NTCNC [4:0];
reg [4:0] extra_hyperjump_known_NTCNC;
reg [4:0] extra_haltingjump_known_NTCNC;
reg [3:0] recent_jump_data_size_NTCNC [3:0];
reg update_hyperfetch_helper_trigger_NTCNC;


always @(posedge main_clk) begin
	void_instruction_fetch<=void_instruction_fetch_NTCNC;
	recent_jump_matchy<=recent_jump_matchy_NTCNC;
	recent_jump_update_offset<=recent_jump_update_offset_NTCNC;
	instruction_pointer_out<=instruction_pointer_out_NTCNC;
	circular_prepared_instruction_read<=circular_prepared_instruction_read_NTCNC;
	circular_prepared_instruction_write<=circular_prepared_instruction_write_NTCNC;
	ready_instructions<=ready_instructions_NTCNC;
	circular_address_read<=circular_address_read_NTCNC;
	circular_address_write<=circular_address_write_NTCNC;
	prepared_instructions<=prepared_instructions_NTCNC;
	instruction_fetch0_pointer<=instruction_fetch0_pointer_NTCNC;
	instruction_fetch1_pointer<=instruction_fetch1_pointer_NTCNC;
	instruction_fetch_requesting<=instruction_fetch_requesting_NTCNC;
	fetch_tradeoff_toggle<=fetch_tradeoff_toggle_NTCNC;
	prepared_instruction_count<=prepared_instruction_count_NTCNC;
	hyperfetch_buffer<=hyperfetch_buffer_NTCNC;
	hyperfetch_buffer_size<=hyperfetch_buffer_size_NTCNC;
	hyperfetch_detection_helper_data<=hyperfetch_detection_helper_data_NTCNC;
	buffer_size<=buffer_size_NTCNC;
	waiting_on_jump<=waiting_on_jump_NTCNC;
	waiting_on_hyperfetch<=waiting_on_hyperfetch_NTCNC;
	recent_jump_data_raw<=recent_jump_data_raw_NTCNC;
	recent_jump_data_valid<=recent_jump_data_valid_NTCNC;
	recent_jump_circular_position<=recent_jump_circular_position_NTCNC;
	recent_jump_addresses<=recent_jump_addresses_NTCNC;
	hyperfetch_address_valid<=hyperfetch_address_valid_NTCNC;
	extra_hyperjump_addresses<=extra_hyperjump_addresses_NTCNC;
	extra_hyperjump_known<=extra_hyperjump_known_NTCNC;
	extra_haltingjump_known<=extra_haltingjump_known_NTCNC;
	recent_jump_data_size<=recent_jump_data_size_NTCNC;
	update_hyperfetch_helper_trigger<=update_hyperfetch_helper_trigger_NTCNC;
end

always_comb begin
	void_instruction_fetch_NTCNC=void_instruction_fetch;
	recent_jump_matchy_NTCNC=recent_jump_matchy;
	recent_jump_update_offset_NTCNC=recent_jump_update_offset;
	instruction_pointer_out_NTCNC=instruction_pointer_out;
	circular_prepared_instruction_read_NTCNC=circular_prepared_instruction_read;
	circular_prepared_instruction_write_NTCNC=circular_prepared_instruction_write;
	ready_instructions_NTCNC=ready_instructions;
	circular_address_read_NTCNC=circular_address_read;
	circular_address_write_NTCNC=circular_address_write;
	prepared_instructions_NTCNC=prepared_instructions;
	instruction_fetch0_pointer_NTCNC=instruction_fetch0_pointer;
	instruction_fetch1_pointer_NTCNC=instruction_fetch1_pointer;
	instruction_fetch_requesting_NTCNC=instruction_fetch_requesting;
	fetch_tradeoff_toggle_NTCNC=fetch_tradeoff_toggle;
	prepared_instruction_count_NTCNC=prepared_instruction_count;
	hyperfetch_buffer_NTCNC=hyperfetch_buffer;
	hyperfetch_buffer_size_NTCNC=hyperfetch_buffer_size;
	hyperfetch_detection_helper_data_NTCNC=hyperfetch_detection_helper_data;
	buffer_size_NTCNC=buffer_size;
	waiting_on_jump_NTCNC=waiting_on_jump;
	waiting_on_hyperfetch_NTCNC=waiting_on_hyperfetch;
	recent_jump_data_raw_NTCNC=recent_jump_data_raw;
	recent_jump_data_valid_NTCNC=recent_jump_data_valid;
	recent_jump_circular_position_NTCNC=recent_jump_circular_position;
	recent_jump_addresses_NTCNC=recent_jump_addresses;
	hyperfetch_address_valid_NTCNC=hyperfetch_address_valid;
	extra_hyperjump_addresses_NTCNC=extra_hyperjump_addresses;
	extra_hyperjump_known_NTCNC=extra_hyperjump_known;
	extra_haltingjump_known_NTCNC=extra_haltingjump_known;

	void_instruction_fetch_NTCNC=0;
	update_hyperfetch_helper_trigger_NTCNC=0;
	update_hyperfetch_helper_trigger_NOW=0;
	
	recent_jump_matchy_NTCNC[0][0]=(recent_jump_address_difference[0][0][24:4]==21'h0)? 1'b1:1'b0;
	recent_jump_matchy_NTCNC[1][0]=(recent_jump_address_difference[1][0][24:4]==21'h0)? 1'b1:1'b0;
	recent_jump_matchy_NTCNC[0][1]=(recent_jump_address_difference[0][1][24:4]==21'h0)? 1'b1:1'b0;
	recent_jump_matchy_NTCNC[1][1]=(recent_jump_address_difference[1][1][24:4]==21'h0)? 1'b1:1'b0;
	recent_jump_matchy_NTCNC[0][2]=(recent_jump_address_difference[0][2][24:4]==21'h0)? 1'b1:1'b0;
	recent_jump_matchy_NTCNC[1][2]=(recent_jump_address_difference[1][2][24:4]==21'h0)? 1'b1:1'b0;
	recent_jump_matchy_NTCNC[0][3]=(recent_jump_address_difference[0][3][24:4]==21'h0)? 1'b1:1'b0;
	recent_jump_matchy_NTCNC[1][3]=(recent_jump_address_difference[1][3][24:4]==21'h0)? 1'b1:1'b0;
	
	recent_jump_update_offset_NTCNC[0][0]=recent_jump_address_difference[0][0][3:0];
	recent_jump_update_offset_NTCNC[1][0]=recent_jump_address_difference[1][0][3:0];
	recent_jump_update_offset_NTCNC[0][1]=recent_jump_address_difference[0][1][3:0];
	recent_jump_update_offset_NTCNC[1][1]=recent_jump_address_difference[1][1][3:0];
	recent_jump_update_offset_NTCNC[0][2]=recent_jump_address_difference[0][2][3:0];
	recent_jump_update_offset_NTCNC[1][2]=recent_jump_address_difference[1][2][3:0];
	recent_jump_update_offset_NTCNC[0][3]=recent_jump_address_difference[0][3][3:0];
	recent_jump_update_offset_NTCNC[1][3]=recent_jump_address_difference[1][3][3:0];
	
	instruction_pointer_out_NTCNC=instruction_pointer_out + used_ready_instruction_count;
	
	prepared_instruction_count_NTCNC=prepared_left + buffer_size_used;
	
	circular_prepared_instruction_read_NTCNC=circular_prepared_instruction_read + ready_fill_satisfied;
	circular_prepared_instruction_write_NTCNC=circular_prepared_instruction_write + buffer_size_used;
	ready_instructions_NTCNC=ready_instructions_next;
	circular_address_read_NTCNC=circular_address_read_next;
	circular_address_write_NTCNC=circular_address_write_next;
	
	if (circular_prepared_instruction_write_enable_lc[0]) prepared_instructions_NTCNC[0]=circular_prepared_instruction_write_values_lc[0];
	if (circular_prepared_instruction_write_enable_lc[1]) prepared_instructions_NTCNC[1]=circular_prepared_instruction_write_values_lc[1];
	if (circular_prepared_instruction_write_enable_lc[2]) prepared_instructions_NTCNC[2]=circular_prepared_instruction_write_values_lc[2];
	if (circular_prepared_instruction_write_enable_lc[3]) prepared_instructions_NTCNC[3]=circular_prepared_instruction_write_values_lc[3];
	if (circular_prepared_instruction_write_enable_lc[4]) prepared_instructions_NTCNC[4]=circular_prepared_instruction_write_values_lc[4];
	if (circular_prepared_instruction_write_enable_lc[5]) prepared_instructions_NTCNC[5]=circular_prepared_instruction_write_values_lc[5];
	if (circular_prepared_instruction_write_enable_lc[6]) prepared_instructions_NTCNC[6]=circular_prepared_instruction_write_values_lc[6];
	if (circular_prepared_instruction_write_enable_lc[7]) prepared_instructions_NTCNC[7]=circular_prepared_instruction_write_values_lc[7];
	if (circular_prepared_instruction_write_enable_lc[8]) prepared_instructions_NTCNC[8]=circular_prepared_instruction_write_values_lc[8];
	if (circular_prepared_instruction_write_enable_lc[9]) prepared_instructions_NTCNC[9]=circular_prepared_instruction_write_values_lc[9];
	if (circular_prepared_instruction_write_enable_lc[10]) prepared_instructions_NTCNC[10]=circular_prepared_instruction_write_values_lc[10];
	if (circular_prepared_instruction_write_enable_lc[11]) prepared_instructions_NTCNC[11]=circular_prepared_instruction_write_values_lc[11];
	if (circular_prepared_instruction_write_enable_lc[12]) prepared_instructions_NTCNC[12]=circular_prepared_instruction_write_values_lc[12];
	if (circular_prepared_instruction_write_enable_lc[13]) prepared_instructions_NTCNC[13]=circular_prepared_instruction_write_values_lc[13];
	if (circular_prepared_instruction_write_enable_lc[14]) prepared_instructions_NTCNC[14]=circular_prepared_instruction_write_values_lc[14];
	if (circular_prepared_instruction_write_enable_lc[15]) prepared_instructions_NTCNC[15]=circular_prepared_instruction_write_values_lc[15];
	
	if (instruction_fetch_requesting==2'b01 && waiting_on_jump) begin
		instruction_fetch1_pointer_NTCNC={instruction_fetch0_pointer[24:3]+1'b1,3'b0};
		instruction_fetch_requesting_NTCNC[1]=1'b1;
		recent_jump_matchy_NTCNC[1]=4'h0;
	end
	if (!(instruction_fetch_requesting[1])  && fetch_tradeoff_toggle==1'b0 && !(buffer_size[5]) && !waiting_on_jump) begin
		instruction_fetch1_pointer_NTCNC={instruction_fetch0_pointer[24:3]+1'b1,3'b0};
		instruction_fetch_requesting_NTCNC[1]=1'b1;
		fetch_tradeoff_toggle_NTCNC=1;
		recent_jump_matchy_NTCNC[1]=4'h0;
	end
	if (instruction_fetch_requesting==2'b00 && fetch_tradeoff_toggle==1'b1 && !(buffer_size[5]) && !waiting_on_jump) begin
		instruction_fetch0_pointer_NTCNC={instruction_fetch0_pointer[24:3]+2'd2,3'b0};
		instruction_fetch_requesting_NTCNC[0]=1'b1;
		fetch_tradeoff_toggle_NTCNC=0;
		recent_jump_matchy_NTCNC[0]=4'h0;
	end
	if (is_data_coming_in[0]) begin
		instruction_fetch_requesting_NTCNC[0]=1'b0;
	end
	if (is_data_coming_in[1]) begin
		instruction_fetch_requesting_NTCNC[1]=1'b0;
	end
	if (is_data_coming_in[0] || is_data_coming_in[1]) begin
		if (used_buffer_bypass) begin
			circular_prepared_instruction_read_NTCNC=0;
			prepared_instructions_NTCNC[7:0]=data_in_raw;
			prepared_instruction_count_NTCNC=data_in_size+4'd1;
			circular_prepared_instruction_write_NTCNC=data_in_size+4'd1;
			update_hyperfetch_helper_trigger_NOW=1;
		end else begin
			if (waiting_on_jump) begin
				extra_haltingjump_known_NTCNC[4]=extra_haltingjump_known_including_input[4];
				extra_hyperjump_known_NTCNC[4]=extra_hyperjump_known_including_input[4];
				if (extra_hyperfetch_suggestion_on_input_validity[4]) begin
					extra_hyperjump_addresses_NTCNC[4]=extra_hyperjump_addresses_including_input[4];
				end
				if (is_data_coming_in[0]) begin
					hyperfetch_buffer_NTCNC[7:0]=data_in_raw;
					hyperfetch_buffer_size_NTCNC=data_in_size + 4'd1;
				end else begin
					assert(hyperfetch_buffer_size!=4'h0); // otherwise it was recieved in the wrong order and something is wrong with memory priority
					hyperfetch_buffer_size_NTCNC=hyperfetch_buffer_size + data_in_size + 4'd1;
					unique case (hyperfetch_buffer_size - 4'd1)
					0:begin hyperfetch_buffer_NTCNC[ 8:1]=data_in_raw[7:0];end
					1:begin hyperfetch_buffer_NTCNC[ 9:2]=data_in_raw[7:0];end
					2:begin hyperfetch_buffer_NTCNC[10:3]=data_in_raw[7:0];end
					3:begin hyperfetch_buffer_NTCNC[11:4]=data_in_raw[7:0];end
					4:begin hyperfetch_buffer_NTCNC[12:5]=data_in_raw[7:0];end
					5:begin hyperfetch_buffer_NTCNC[13:6]=data_in_raw[7:0];end
					6:begin hyperfetch_buffer_NTCNC[14:7]=data_in_raw[7:0];end
					7:begin hyperfetch_buffer_NTCNC[14:8]=data_in_raw[6:0];hyperfetch_buffer_size_NTCNC=15;end
					endcase
				end
			end else begin
				update_hyperfetch_helper_trigger_NOW=1;
			end
		end
	end
	buffer_size_NTCNC=buffer_size_next;
	if (haltingjump_on_input_known && !waiting_on_jump) begin
		waiting_on_jump_NTCNC=1;
		void_instruction_fetch_NTCNC=1;
		instruction_fetch_requesting_NTCNC=2'b00;
		hyperfetch_buffer_size_NTCNC=0;
		hyperfetch_address_valid_NTCNC=0;
		recent_jump_matchy_NTCNC[0]=4'h0;
		extra_haltingjump_known_NTCNC[4]=1'b0;
		extra_hyperjump_known_NTCNC[4]=1'b0;
		if (hyperfetch_suggestion_on_input_validity) begin
			instruction_fetch0_pointer_NTCNC=hyperfetch_suggestion_on_input;
			instruction_fetch_requesting_NTCNC=2'b01;
			hyperfetch_address_valid_NTCNC=1;
		end
	end
	
	if (recent_jump_update_possible[0][0] || recent_jump_update_possible[1][0]) begin
		extra_haltingjump_known_NTCNC[0]=extra_haltingjump_known_including_input[0];
		extra_hyperjump_known_NTCNC[0]=extra_hyperjump_known_including_input[0];
		if (extra_hyperfetch_suggestion_on_input_validity[0]) begin
			extra_hyperjump_addresses_NTCNC[0]=extra_hyperjump_addresses_including_input[0];
		end
		case (recent_jump_update_offset[recent_jump_update_possible[1][0]][0])
		4'h0:begin recent_jump_data_raw_NTCNC[0][ 7:0]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[0][ 7:0]=data_in_size_at_least[7:0];end
		4'h1:begin recent_jump_data_raw_NTCNC[0][ 8:1]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[0][ 8:1]=data_in_size_at_least[7:0];end
		4'h2:begin recent_jump_data_raw_NTCNC[0][ 9:2]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[0][ 9:2]=data_in_size_at_least[7:0];end
		4'h3:begin recent_jump_data_raw_NTCNC[0][10:3]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[0][10:3]=data_in_size_at_least[7:0];end
		4'h4:begin recent_jump_data_raw_NTCNC[0][11:4]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[0][11:4]=data_in_size_at_least[7:0];end
		4'h5:begin recent_jump_data_raw_NTCNC[0][12:5]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[0][12:5]=data_in_size_at_least[7:0];end
		4'h6:begin recent_jump_data_raw_NTCNC[0][13:6]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[0][13:6]=data_in_size_at_least[7:0];end
		4'h7:begin recent_jump_data_raw_NTCNC[0][14:7]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[0][14:7]=data_in_size_at_least[7:0];end
		4'h8:begin recent_jump_data_raw_NTCNC[0][14:8]=data_in_raw[6:0];recent_jump_data_valid_NTCNC[0][14:8]=data_in_size_at_least[6:0];end
		endcase
	end
	if (recent_jump_update_possible[0][1] || recent_jump_update_possible[1][1]) begin
		extra_haltingjump_known_NTCNC[1]=extra_haltingjump_known_including_input[1];
		extra_hyperjump_known_NTCNC[1]=extra_hyperjump_known_including_input[1];
		if (extra_hyperfetch_suggestion_on_input_validity[1]) begin
			extra_hyperjump_addresses_NTCNC[1]=extra_hyperjump_addresses_including_input[1];
		end
		case (recent_jump_update_offset[recent_jump_update_possible[1][1]][1])
		4'h0:begin recent_jump_data_raw_NTCNC[1][ 7:0]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[1][ 7:0]=data_in_size_at_least[7:0];end
		4'h1:begin recent_jump_data_raw_NTCNC[1][ 8:1]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[1][ 8:1]=data_in_size_at_least[7:0];end
		4'h2:begin recent_jump_data_raw_NTCNC[1][ 9:2]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[1][ 9:2]=data_in_size_at_least[7:0];end
		4'h3:begin recent_jump_data_raw_NTCNC[1][10:3]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[1][10:3]=data_in_size_at_least[7:0];end
		4'h4:begin recent_jump_data_raw_NTCNC[1][11:4]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[1][11:4]=data_in_size_at_least[7:0];end
		4'h5:begin recent_jump_data_raw_NTCNC[1][12:5]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[1][12:5]=data_in_size_at_least[7:0];end
		4'h6:begin recent_jump_data_raw_NTCNC[1][13:6]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[1][13:6]=data_in_size_at_least[7:0];end
		4'h7:begin recent_jump_data_raw_NTCNC[1][14:7]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[1][14:7]=data_in_size_at_least[7:0];end
		4'h8:begin recent_jump_data_raw_NTCNC[1][14:8]=data_in_raw[6:0];recent_jump_data_valid_NTCNC[1][14:8]=data_in_size_at_least[6:0];end
		endcase
	end
	if (recent_jump_update_possible[0][2] || recent_jump_update_possible[1][2]) begin
		extra_haltingjump_known_NTCNC[2]=extra_haltingjump_known_including_input[2];
		extra_hyperjump_known_NTCNC[2]=extra_hyperjump_known_including_input[2];
		if (extra_hyperfetch_suggestion_on_input_validity[2]) begin
			extra_hyperjump_addresses_NTCNC[2]=extra_hyperjump_addresses_including_input[2];
		end
		case (recent_jump_update_offset[recent_jump_update_possible[1][2]][2])
		4'h0:begin recent_jump_data_raw_NTCNC[2][ 7:0]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[2][ 7:0]=data_in_size_at_least[7:0];end
		4'h1:begin recent_jump_data_raw_NTCNC[2][ 8:1]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[2][ 8:1]=data_in_size_at_least[7:0];end
		4'h2:begin recent_jump_data_raw_NTCNC[2][ 9:2]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[2][ 9:2]=data_in_size_at_least[7:0];end
		4'h3:begin recent_jump_data_raw_NTCNC[2][10:3]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[2][10:3]=data_in_size_at_least[7:0];end
		4'h4:begin recent_jump_data_raw_NTCNC[2][11:4]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[2][11:4]=data_in_size_at_least[7:0];end
		4'h5:begin recent_jump_data_raw_NTCNC[2][12:5]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[2][12:5]=data_in_size_at_least[7:0];end
		4'h6:begin recent_jump_data_raw_NTCNC[2][13:6]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[2][13:6]=data_in_size_at_least[7:0];end
		4'h7:begin recent_jump_data_raw_NTCNC[2][14:7]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[2][14:7]=data_in_size_at_least[7:0];end
		4'h8:begin recent_jump_data_raw_NTCNC[2][14:8]=data_in_raw[6:0];recent_jump_data_valid_NTCNC[2][14:8]=data_in_size_at_least[6:0];end
		endcase
	end
	if (recent_jump_update_possible[0][3] || recent_jump_update_possible[1][3]) begin
		extra_haltingjump_known_NTCNC[3]=extra_haltingjump_known_including_input[3];
		extra_hyperjump_known_NTCNC[3]=extra_hyperjump_known_including_input[3];
		if (extra_hyperfetch_suggestion_on_input_validity[3]) begin
			extra_hyperjump_addresses_NTCNC[3]=extra_hyperjump_addresses_including_input[3];
		end
		case (recent_jump_update_offset[recent_jump_update_possible[1][3]][3])
		4'h0:begin recent_jump_data_raw_NTCNC[3][ 7:0]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[3][ 7:0]=data_in_size_at_least[7:0];end
		4'h1:begin recent_jump_data_raw_NTCNC[3][ 8:1]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[3][ 8:1]=data_in_size_at_least[7:0];end
		4'h2:begin recent_jump_data_raw_NTCNC[3][ 9:2]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[3][ 9:2]=data_in_size_at_least[7:0];end
		4'h3:begin recent_jump_data_raw_NTCNC[3][10:3]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[3][10:3]=data_in_size_at_least[7:0];end
		4'h4:begin recent_jump_data_raw_NTCNC[3][11:4]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[3][11:4]=data_in_size_at_least[7:0];end
		4'h5:begin recent_jump_data_raw_NTCNC[3][12:5]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[3][12:5]=data_in_size_at_least[7:0];end
		4'h6:begin recent_jump_data_raw_NTCNC[3][13:6]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[3][13:6]=data_in_size_at_least[7:0];end
		4'h7:begin recent_jump_data_raw_NTCNC[3][14:7]=data_in_raw[7:0];recent_jump_data_valid_NTCNC[3][14:7]=data_in_size_at_least[7:0];end
		4'h8:begin recent_jump_data_raw_NTCNC[3][14:8]=data_in_raw[6:0];recent_jump_data_valid_NTCNC[3][14:8]=data_in_size_at_least[6:0];end
		endcase
	end
	
	
	if (waiting_on_hyperfetch && instruction_fetch_requesting==2'b00) begin
		hyperfetch_buffer_size_NTCNC=0;
		waiting_on_hyperfetch_NTCNC=0;
		circular_prepared_instruction_read_NTCNC=0;
		circular_prepared_instruction_write_NTCNC=hyperfetch_buffer_size;
		prepared_instruction_count_NTCNC=hyperfetch_buffer_size;
		prepared_instructions_NTCNC[14:0]=hyperfetch_buffer[14:0];
		instruction_fetch_requesting_NTCNC=2'b01;
		if (extra_hyperjump_known[4]) begin
			instruction_fetch0_pointer_NTCNC=extra_hyperjump_addresses[4];
		end else begin
			instruction_fetch0_pointer_NTCNC=instruction_fetch0_pointer+hyperfetch_buffer_size;
		end
		hyperfetch_address_valid_NTCNC=extra_hyperjump_known[4];
		extra_haltingjump_known_NTCNC[4]=1'b0;
		extra_hyperjump_known_NTCNC[4]=1'b0;
		waiting_on_jump_NTCNC=extra_haltingjump_known[4];
		recent_jump_matchy_NTCNC[0]=4'h0;
		update_hyperfetch_helper_trigger_NTCNC=1;
		hyperfetch_detection_helper_data_NTCNC[3:0]='{16'b1xxxxxxxxxxxxxxx,16'hx,16'hx,16'hx};// just enough to garentee rejection from the hyperfetch detection system
		assert(!fetch_tradeoff_toggle);
	end
	if (jump_triggering) begin
		hyperfetch_buffer_size_NTCNC=0;
		circular_prepared_instruction_read_NTCNC=0;
		circular_prepared_instruction_write_NTCNC=0;
		prepared_instruction_count_NTCNC=0;
		void_instruction_fetch_NTCNC=1;
		instruction_fetch_requesting_NTCNC=2'b01;
		waiting_on_hyperfetch_NTCNC=0;
		waiting_on_jump_NTCNC=0;
		fetch_tradeoff_toggle_NTCNC=0;
		recent_jump_matchy_NTCNC[0]=4'h0;
		instruction_pointer_out_NTCNC=jump_address;
		hyperfetch_detection_helper_data_NTCNC[3:0]='{16'b1xxxxxxxxxxxxxxx,16'hx,16'hx,16'hx};// just enough to garentee rejection from the hyperfetch detection system
		
		if (jump_address==recent_jump_addresses[0] && recent_jump_data_valid[0][0]) begin
			prepared_instruction_count_NTCNC=recent_jump_data_size[0];
			circular_prepared_instruction_write_NTCNC=recent_jump_data_size[0];
			prepared_instructions_NTCNC[14:0]=recent_jump_data_raw[0][14:0];
			if (extra_hyperjump_known[0]) begin
				instruction_fetch0_pointer_NTCNC=extra_hyperjump_addresses[0];
			end else begin
				instruction_fetch0_pointer_NTCNC=recent_jump_addresses[0]+recent_jump_data_size[0];
			end
			hyperfetch_address_valid_NTCNC=extra_hyperjump_known[0];
			extra_haltingjump_known_NTCNC[4]=1'b0;
			extra_hyperjump_known_NTCNC[4]=1'b0;
			waiting_on_jump_NTCNC=extra_haltingjump_known[0];
			update_hyperfetch_helper_trigger_NTCNC=1;
		end else if (jump_address==recent_jump_addresses[1] && recent_jump_data_valid[1][0]) begin
			prepared_instruction_count_NTCNC=recent_jump_data_size[1];
			circular_prepared_instruction_write_NTCNC=recent_jump_data_size[1];
			prepared_instructions_NTCNC[14:0]=recent_jump_data_raw[1][14:0];
			if (extra_hyperjump_known[1]) begin
				instruction_fetch0_pointer_NTCNC=extra_hyperjump_addresses[1];
			end else begin
				instruction_fetch0_pointer_NTCNC=recent_jump_addresses[1]+recent_jump_data_size[1];
			end
			hyperfetch_address_valid_NTCNC=extra_hyperjump_known[1];
			extra_haltingjump_known_NTCNC[4]=1'b0;
			extra_hyperjump_known_NTCNC[4]=1'b0;
			waiting_on_jump_NTCNC=extra_haltingjump_known[1];
			update_hyperfetch_helper_trigger_NTCNC=1;
		end else if (jump_address==recent_jump_addresses[2] && recent_jump_data_valid[2][0]) begin
			prepared_instruction_count_NTCNC=recent_jump_data_size[2];
			circular_prepared_instruction_write_NTCNC=recent_jump_data_size[2];
			prepared_instructions_NTCNC[14:0]=recent_jump_data_raw[2][14:0];
			if (extra_hyperjump_known[2]) begin
				instruction_fetch0_pointer_NTCNC=extra_hyperjump_addresses[2];
			end else begin
				instruction_fetch0_pointer_NTCNC=recent_jump_addresses[2]+recent_jump_data_size[2];
			end
			hyperfetch_address_valid_NTCNC=extra_hyperjump_known[2];
			extra_haltingjump_known_NTCNC[4]=1'b0;
			extra_hyperjump_known_NTCNC[4]=1'b0;
			waiting_on_jump_NTCNC=extra_haltingjump_known[2];
			update_hyperfetch_helper_trigger_NTCNC=1;
		end else if (jump_address==recent_jump_addresses[3] && recent_jump_data_valid[3][0]) begin
			prepared_instruction_count_NTCNC=recent_jump_data_size[3];
			circular_prepared_instruction_write_NTCNC=recent_jump_data_size[3];
			prepared_instructions_NTCNC[14:0]=recent_jump_data_raw[3][14:0];
			if (extra_hyperjump_known[3]) begin
				instruction_fetch0_pointer_NTCNC=extra_hyperjump_addresses[3];
			end else begin
				instruction_fetch0_pointer_NTCNC=recent_jump_addresses[3]+recent_jump_data_size[3];
			end
			hyperfetch_address_valid_NTCNC=extra_hyperjump_known[3];
			extra_haltingjump_known_NTCNC[4]=1'b0;
			extra_hyperjump_known_NTCNC[4]=1'b0;
			waiting_on_jump_NTCNC=extra_haltingjump_known[3];
			update_hyperfetch_helper_trigger_NTCNC=1;
		end else if (jump_address==instruction_fetch0_pointer && hyperfetch_address_valid) begin
			if (instruction_fetch_requesting!=2'b00) begin
				waiting_on_jump_NTCNC=1; // waiting_on_jump isn't actually what is happening, but it is going to be used to achieve the correct behaviour
				waiting_on_hyperfetch_NTCNC=1;
				void_instruction_fetch_NTCNC=0;
				instruction_fetch_requesting_NTCNC=instruction_fetch_requesting; // this is important, because normally these requests are changed. but here, they should stay the same
				hyperfetch_buffer_size_NTCNC=hyperfetch_buffer_size;
			end else begin
				prepared_instruction_count_NTCNC=hyperfetch_buffer_size;
				circular_prepared_instruction_write_NTCNC=hyperfetch_buffer_size;
				prepared_instructions_NTCNC[14:0]=hyperfetch_buffer[14:0];
				if (extra_hyperjump_known[4]) begin
					instruction_fetch0_pointer_NTCNC=extra_hyperjump_addresses[4];
				end else begin
					instruction_fetch0_pointer_NTCNC=instruction_fetch0_pointer+hyperfetch_buffer_size;
				end
				hyperfetch_address_valid_NTCNC=extra_hyperjump_known[4];
				extra_haltingjump_known_NTCNC[4]=1'b0;
				extra_hyperjump_known_NTCNC[4]=1'b0;
				waiting_on_jump_NTCNC=extra_haltingjump_known[4];
				update_hyperfetch_helper_trigger_NTCNC=1;
			end
		end else begin
			hyperfetch_address_valid_NTCNC=0;
			extra_haltingjump_known_NTCNC[4]=1'b0;
			extra_hyperjump_known_NTCNC[4]=1'b0;
			instruction_fetch0_pointer_NTCNC=jump_address;
			recent_jump_circular_position_NTCNC=recent_jump_circular_position+2'b1;
			recent_jump_addresses_NTCNC[recent_jump_circular_position]=jump_address;
			recent_jump_data_valid_NTCNC[recent_jump_circular_position]=15'h0;
			unique case (recent_jump_circular_position)
			0:begin extra_haltingjump_known_NTCNC[0]=1'b0;extra_hyperjump_known_NTCNC[0]=1'b0;end
			1:begin extra_haltingjump_known_NTCNC[1]=1'b0;extra_hyperjump_known_NTCNC[1]=1'b0;end
			2:begin extra_haltingjump_known_NTCNC[2]=1'b0;extra_hyperjump_known_NTCNC[2]=1'b0;end
			3:begin extra_haltingjump_known_NTCNC[3]=1'b0;extra_hyperjump_known_NTCNC[3]=1'b0;end
			endcase
		end
	end
	
	assert(!(update_hyperfetch_helper_trigger && update_hyperfetch_helper_trigger_NOW)); // otherwise the memory system responded to a request way too fast (faster then it should be able to)
	
	unique case ({update_hyperfetch_helper_trigger,update_hyperfetch_helper_trigger_NOW})
	0:begin end
	1:begin
		unique case (data_in_size)
		0:begin
			hyperfetch_detection_helper_data_NTCNC[2:0]=hyperfetch_detection_helper_data[3:1];
			hyperfetch_detection_helper_data_NTCNC[  3]=data_in_raw[  0];
		end
		1:begin
			hyperfetch_detection_helper_data_NTCNC[1:0]=hyperfetch_detection_helper_data[3:2];
			hyperfetch_detection_helper_data_NTCNC[3:2]=data_in_raw[1:0];
		end
		2:begin
			hyperfetch_detection_helper_data_NTCNC[  0]=hyperfetch_detection_helper_data[  3];
			hyperfetch_detection_helper_data_NTCNC[3:1]=data_in_raw[2:0];
		end
		3:begin
			hyperfetch_detection_helper_data_NTCNC[3:0]=data_in_raw[3:0];
		end
		4:begin
			hyperfetch_detection_helper_data_NTCNC[3:0]=data_in_raw[4:1];
		end
		5:begin
			hyperfetch_detection_helper_data_NTCNC[3:0]=data_in_raw[5:2];
		end
		6:begin
			hyperfetch_detection_helper_data_NTCNC[3:0]=data_in_raw[6:3];
		end
		7:begin
			hyperfetch_detection_helper_data_NTCNC[3:0]=data_in_raw[7:4];
		end
		endcase
	end
	2:begin
		case (prepared_instruction_count)
		 4:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[3:0];
		 5:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[4:1];
		 6:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[5:2];
		 7:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[6:3];
		 8:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[7:4];
		 9:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[8:5];
		10:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[9:6];
		11:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[10:7];
		12:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[11:8];
		13:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[12:9];
		14:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[13:10];
		15:hyperfetch_detection_helper_data_NTCNC[3:0]=prepared_instructions[14:11];
		endcase
	end
	endcase
	
	// the transform below is valid due to how it is used. it reduces register usage.
	hyperfetch_detection_helper_data_NTCNC[0][15]=hyperfetch_detection_helper_data_NTCNC[0][15] | hyperfetch_detection_helper_data_NTCNC[0][14] | hyperfetch_detection_helper_data_NTCNC[0][13];hyperfetch_detection_helper_data_NTCNC[0][14:13]=2'b00;
	hyperfetch_detection_helper_data_NTCNC[1][15]=hyperfetch_detection_helper_data_NTCNC[1][15] | hyperfetch_detection_helper_data_NTCNC[1][14] | hyperfetch_detection_helper_data_NTCNC[1][13];hyperfetch_detection_helper_data_NTCNC[1][14:13]=2'b00;
	hyperfetch_detection_helper_data_NTCNC[2][15]=hyperfetch_detection_helper_data_NTCNC[2][15] | hyperfetch_detection_helper_data_NTCNC[2][14] | hyperfetch_detection_helper_data_NTCNC[2][13];hyperfetch_detection_helper_data_NTCNC[2][14:13]=2'b00;
	hyperfetch_detection_helper_data_NTCNC[3][15]=hyperfetch_detection_helper_data_NTCNC[3][15] | hyperfetch_detection_helper_data_NTCNC[3][14] | hyperfetch_detection_helper_data_NTCNC[3][13];hyperfetch_detection_helper_data_NTCNC[3][14:13]=2'b00;
end

always_comb begin
	     if (!(recent_jump_data_valid_NTCNC[0][ 0])) recent_jump_data_size_NTCNC[0]=0;
	else if (!(recent_jump_data_valid_NTCNC[0][ 1])) recent_jump_data_size_NTCNC[0]=1;
	else if (!(recent_jump_data_valid_NTCNC[0][ 2])) recent_jump_data_size_NTCNC[0]=2;
	else if (!(recent_jump_data_valid_NTCNC[0][ 3])) recent_jump_data_size_NTCNC[0]=3;
	else if (!(recent_jump_data_valid_NTCNC[0][ 4])) recent_jump_data_size_NTCNC[0]=4;
	else if (!(recent_jump_data_valid_NTCNC[0][ 5])) recent_jump_data_size_NTCNC[0]=5;
	else if (!(recent_jump_data_valid_NTCNC[0][ 6])) recent_jump_data_size_NTCNC[0]=6;
	else if (!(recent_jump_data_valid_NTCNC[0][ 7])) recent_jump_data_size_NTCNC[0]=7;
	else if (!(recent_jump_data_valid_NTCNC[0][ 8])) recent_jump_data_size_NTCNC[0]=8;
	else if (!(recent_jump_data_valid_NTCNC[0][ 9])) recent_jump_data_size_NTCNC[0]=9;
	else if (!(recent_jump_data_valid_NTCNC[0][10])) recent_jump_data_size_NTCNC[0]=10;
	else if (!(recent_jump_data_valid_NTCNC[0][11])) recent_jump_data_size_NTCNC[0]=11;
	else if (!(recent_jump_data_valid_NTCNC[0][12])) recent_jump_data_size_NTCNC[0]=12;
	else if (!(recent_jump_data_valid_NTCNC[0][13])) recent_jump_data_size_NTCNC[0]=13;
	else if (!(recent_jump_data_valid_NTCNC[0][14])) recent_jump_data_size_NTCNC[0]=14;
	else                                             recent_jump_data_size_NTCNC[0]=15;
end
always_comb begin
	     if (!(recent_jump_data_valid_NTCNC[1][ 0])) recent_jump_data_size_NTCNC[1]=0;
	else if (!(recent_jump_data_valid_NTCNC[1][ 1])) recent_jump_data_size_NTCNC[1]=1;
	else if (!(recent_jump_data_valid_NTCNC[1][ 2])) recent_jump_data_size_NTCNC[1]=2;
	else if (!(recent_jump_data_valid_NTCNC[1][ 3])) recent_jump_data_size_NTCNC[1]=3;
	else if (!(recent_jump_data_valid_NTCNC[1][ 4])) recent_jump_data_size_NTCNC[1]=4;
	else if (!(recent_jump_data_valid_NTCNC[1][ 5])) recent_jump_data_size_NTCNC[1]=5;
	else if (!(recent_jump_data_valid_NTCNC[1][ 6])) recent_jump_data_size_NTCNC[1]=6;
	else if (!(recent_jump_data_valid_NTCNC[1][ 7])) recent_jump_data_size_NTCNC[1]=7;
	else if (!(recent_jump_data_valid_NTCNC[1][ 8])) recent_jump_data_size_NTCNC[1]=8;
	else if (!(recent_jump_data_valid_NTCNC[1][ 9])) recent_jump_data_size_NTCNC[1]=9;
	else if (!(recent_jump_data_valid_NTCNC[1][10])) recent_jump_data_size_NTCNC[1]=10;
	else if (!(recent_jump_data_valid_NTCNC[1][11])) recent_jump_data_size_NTCNC[1]=11;
	else if (!(recent_jump_data_valid_NTCNC[1][12])) recent_jump_data_size_NTCNC[1]=12;
	else if (!(recent_jump_data_valid_NTCNC[1][13])) recent_jump_data_size_NTCNC[1]=13;
	else if (!(recent_jump_data_valid_NTCNC[1][14])) recent_jump_data_size_NTCNC[1]=14;
	else                                             recent_jump_data_size_NTCNC[1]=15;
end
always_comb begin
	     if (!(recent_jump_data_valid_NTCNC[2][ 0])) recent_jump_data_size_NTCNC[2]=0;
	else if (!(recent_jump_data_valid_NTCNC[2][ 1])) recent_jump_data_size_NTCNC[2]=1;
	else if (!(recent_jump_data_valid_NTCNC[2][ 2])) recent_jump_data_size_NTCNC[2]=2;
	else if (!(recent_jump_data_valid_NTCNC[2][ 3])) recent_jump_data_size_NTCNC[2]=3;
	else if (!(recent_jump_data_valid_NTCNC[2][ 4])) recent_jump_data_size_NTCNC[2]=4;
	else if (!(recent_jump_data_valid_NTCNC[2][ 5])) recent_jump_data_size_NTCNC[2]=5;
	else if (!(recent_jump_data_valid_NTCNC[2][ 6])) recent_jump_data_size_NTCNC[2]=6;
	else if (!(recent_jump_data_valid_NTCNC[2][ 7])) recent_jump_data_size_NTCNC[2]=7;
	else if (!(recent_jump_data_valid_NTCNC[2][ 8])) recent_jump_data_size_NTCNC[2]=8;
	else if (!(recent_jump_data_valid_NTCNC[2][ 9])) recent_jump_data_size_NTCNC[2]=9;
	else if (!(recent_jump_data_valid_NTCNC[2][10])) recent_jump_data_size_NTCNC[2]=10;
	else if (!(recent_jump_data_valid_NTCNC[2][11])) recent_jump_data_size_NTCNC[2]=11;
	else if (!(recent_jump_data_valid_NTCNC[2][12])) recent_jump_data_size_NTCNC[2]=12;
	else if (!(recent_jump_data_valid_NTCNC[2][13])) recent_jump_data_size_NTCNC[2]=13;
	else if (!(recent_jump_data_valid_NTCNC[2][14])) recent_jump_data_size_NTCNC[2]=14;
	else                                             recent_jump_data_size_NTCNC[2]=15;
end
always_comb begin
	     if (!(recent_jump_data_valid_NTCNC[3][ 0])) recent_jump_data_size_NTCNC[3]=0;
	else if (!(recent_jump_data_valid_NTCNC[3][ 1])) recent_jump_data_size_NTCNC[3]=1;
	else if (!(recent_jump_data_valid_NTCNC[3][ 2])) recent_jump_data_size_NTCNC[3]=2;
	else if (!(recent_jump_data_valid_NTCNC[3][ 3])) recent_jump_data_size_NTCNC[3]=3;
	else if (!(recent_jump_data_valid_NTCNC[3][ 4])) recent_jump_data_size_NTCNC[3]=4;
	else if (!(recent_jump_data_valid_NTCNC[3][ 5])) recent_jump_data_size_NTCNC[3]=5;
	else if (!(recent_jump_data_valid_NTCNC[3][ 6])) recent_jump_data_size_NTCNC[3]=6;
	else if (!(recent_jump_data_valid_NTCNC[3][ 7])) recent_jump_data_size_NTCNC[3]=7;
	else if (!(recent_jump_data_valid_NTCNC[3][ 8])) recent_jump_data_size_NTCNC[3]=8;
	else if (!(recent_jump_data_valid_NTCNC[3][ 9])) recent_jump_data_size_NTCNC[3]=9;
	else if (!(recent_jump_data_valid_NTCNC[3][10])) recent_jump_data_size_NTCNC[3]=10;
	else if (!(recent_jump_data_valid_NTCNC[3][11])) recent_jump_data_size_NTCNC[3]=11;
	else if (!(recent_jump_data_valid_NTCNC[3][12])) recent_jump_data_size_NTCNC[3]=12;
	else if (!(recent_jump_data_valid_NTCNC[3][13])) recent_jump_data_size_NTCNC[3]=13;
	else if (!(recent_jump_data_valid_NTCNC[3][14])) recent_jump_data_size_NTCNC[3]=14;
	else                                             recent_jump_data_size_NTCNC[3]=15;
end


reg [3:0] address_0a;
reg [3:0] address_0b;
reg [3:0] address_1a;
reg [3:0] address_1b;
reg [3:0] address_2a;
reg [3:0] address_2b;
reg [3:0] address_3a;
reg [3:0] address_3b;

reg [15:0] data_0a;
reg [15:0] data_0b;
reg [15:0] data_1a;
reg [15:0] data_1b;
reg [15:0] data_2a;
reg [15:0] data_2b;
reg [15:0] data_3a;
reg [15:0] data_3b;

reg wren_0a;
reg wren_0b;
reg wren_1a;
reg wren_1b;
reg wren_2a;
reg wren_2b;
reg wren_3a;
reg wren_3b;

wire [15:0] q_0a;
wire [15:0] q_0b;
wire [15:0] q_1a;
wire [15:0] q_1b;
wire [15:0] q_2a;
wire [15:0] q_2b;
wire [15:0] q_3a;
wire [15:0] q_3b;


reg [5:0] temp_value0 [7:0];

always_comb begin
	wren_0a=0;
	wren_0b=0;
	wren_1a=0;
	wren_1b=0;
	wren_2a=0;
	wren_2b=0;
	wren_3a=0;
	wren_3b=0;
	data_0a=16'hx;
	data_0b=16'hx;
	data_1a=16'hx;
	data_1b=16'hx;
	data_2a=16'hx;
	data_2b=16'hx;
	data_3a=16'hx;
	data_3b=16'hx;
	used_buffer_bypass=0;
	placing_data_in_buffer=0;
	if ((is_data_coming_in[0] || is_data_coming_in[1]) && !waiting_on_jump) begin
		if (buffer_size==6'h0 && prepared_instruction_count==4'h0) begin
			used_buffer_bypass=1;
		end else begin
			placing_data_in_buffer=1;
		end
	end
	circular_address_write_next=circular_address_write;
	circular_address_read_next=circular_address_read + buffer_size_used;
	buffer_size_next=buffer_size - buffer_size_used;
	if ((is_data_coming_in[0] || is_data_coming_in[1]) && !used_buffer_bypass && !waiting_on_jump) begin
		buffer_size_next=buffer_size_next + (data_in_size + 4'b1);
		circular_address_write_next=circular_address_write_next + (data_in_size + 4'd1);
	end
	if (jump_triggering) begin
		circular_address_write_next=0;
		circular_address_read_next=0;
		buffer_size_next=0;
	end
	temp_value0[0]=placing_data_in_buffer?circular_address_write:circular_address_read_next; // using the next value for read and current value for write is intended
	temp_value0[1]=temp_value0[0]+3'h1;
	temp_value0[2]=temp_value0[0]+3'h2;
	temp_value0[3]=temp_value0[0]+3'h3;
	temp_value0[4]=temp_value0[0]+3'h4;
	temp_value0[5]=temp_value0[0]+3'h5;
	temp_value0[6]=temp_value0[0]+3'h6;
	temp_value0[7]=temp_value0[0]+3'h7;
	unique case (temp_value0[0][1:0])
	0:begin
		data_0a=data_in_raw[0];address_0a[3:0]=temp_value0[0][5:2];wren_0a=data_in_size_at_least[0];
		data_1a=data_in_raw[1];address_1a[3:0]=temp_value0[1][5:2];wren_1a=data_in_size_at_least[1];
		data_2a=data_in_raw[2];address_2a[3:0]=temp_value0[2][5:2];wren_2a=data_in_size_at_least[2];
		data_3a=data_in_raw[3];address_3a[3:0]=temp_value0[3][5:2];wren_3a=data_in_size_at_least[3];
		data_0b=data_in_raw[4];address_0b[3:0]=temp_value0[4][5:2];wren_0b=data_in_size_at_least[4];
		data_1b=data_in_raw[5];address_1b[3:0]=temp_value0[5][5:2];wren_1b=data_in_size_at_least[5];
		data_2b=data_in_raw[6];address_2b[3:0]=temp_value0[6][5:2];wren_2b=data_in_size_at_least[6];
		data_3b=data_in_raw[7];address_3b[3:0]=temp_value0[7][5:2];wren_3b=data_in_size_at_least[7];
	end
	1:begin
		data_0a=data_in_raw[7];address_0a[3:0]=temp_value0[7][5:2];wren_0a=data_in_size_at_least[7];
		data_1a=data_in_raw[0];address_1a[3:0]=temp_value0[0][5:2];wren_1a=data_in_size_at_least[0];
		data_2a=data_in_raw[1];address_2a[3:0]=temp_value0[1][5:2];wren_2a=data_in_size_at_least[1];
		data_3a=data_in_raw[2];address_3a[3:0]=temp_value0[2][5:2];wren_3a=data_in_size_at_least[2];
		data_0b=data_in_raw[3];address_0b[3:0]=temp_value0[3][5:2];wren_0b=data_in_size_at_least[3];
		data_1b=data_in_raw[4];address_1b[3:0]=temp_value0[4][5:2];wren_1b=data_in_size_at_least[4];
		data_2b=data_in_raw[5];address_2b[3:0]=temp_value0[5][5:2];wren_2b=data_in_size_at_least[5];
		data_3b=data_in_raw[6];address_3b[3:0]=temp_value0[6][5:2];wren_3b=data_in_size_at_least[6];
	end
	2:begin
		data_0a=data_in_raw[6];address_0a[3:0]=temp_value0[6][5:2];wren_0a=data_in_size_at_least[6];
		data_1a=data_in_raw[7];address_1a[3:0]=temp_value0[7][5:2];wren_1a=data_in_size_at_least[7];
		data_2a=data_in_raw[0];address_2a[3:0]=temp_value0[0][5:2];wren_2a=data_in_size_at_least[0];
		data_3a=data_in_raw[1];address_3a[3:0]=temp_value0[1][5:2];wren_3a=data_in_size_at_least[1];
		data_0b=data_in_raw[2];address_0b[3:0]=temp_value0[2][5:2];wren_0b=data_in_size_at_least[2];
		data_1b=data_in_raw[3];address_1b[3:0]=temp_value0[3][5:2];wren_1b=data_in_size_at_least[3];
		data_2b=data_in_raw[4];address_2b[3:0]=temp_value0[4][5:2];wren_2b=data_in_size_at_least[4];
		data_3b=data_in_raw[5];address_3b[3:0]=temp_value0[5][5:2];wren_3b=data_in_size_at_least[5];
	end
	3:begin
		data_0a=data_in_raw[5];address_0a[3:0]=temp_value0[5][5:2];wren_0a=data_in_size_at_least[5];
		data_1a=data_in_raw[6];address_1a[3:0]=temp_value0[6][5:2];wren_1a=data_in_size_at_least[6];
		data_2a=data_in_raw[7];address_2a[3:0]=temp_value0[7][5:2];wren_2a=data_in_size_at_least[7];
		data_3a=data_in_raw[0];address_3a[3:0]=temp_value0[0][5:2];wren_3a=data_in_size_at_least[0];
		data_0b=data_in_raw[1];address_0b[3:0]=temp_value0[1][5:2];wren_0b=data_in_size_at_least[1];
		data_1b=data_in_raw[2];address_1b[3:0]=temp_value0[2][5:2];wren_1b=data_in_size_at_least[2];
		data_2b=data_in_raw[3];address_2b[3:0]=temp_value0[3][5:2];wren_2b=data_in_size_at_least[3];
		data_3b=data_in_raw[4];address_3b[3:0]=temp_value0[4][5:2];wren_3b=data_in_size_at_least[4];
	end
	endcase
	if (!placing_data_in_buffer) begin
		wren_0a=0;
		wren_0b=0;
		wren_1a=0;
		wren_1b=0;
		wren_2a=0;
		wren_2b=0;
		wren_3a=0;
		wren_3b=0;
	end
end

reg [15:0] data_out_temp [7:0];
reg [3:0] data_out_size_comb;
assign buffer_size_avalible=data_out_size_comb;
assign buffer_instructions[0][15:0]=data_out_temp[0];
assign buffer_instructions[1][15:0]=data_out_temp[1];
assign buffer_instructions[2][15:0]=data_out_temp[2];
assign buffer_instructions[3][15:0]=data_out_temp[3];
assign buffer_instructions[4][15:0]=data_out_temp[4];
assign buffer_instructions[5][15:0]=data_out_temp[5];
assign buffer_instructions[6][15:0]=data_out_temp[6];
assign buffer_instructions[7][15:0]=data_out_temp[7];

always_comb begin
	if (placed_data_in_buffer_last_cycle) begin
		data_out_size_comb=0;
		data_out_temp='{16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx};
	end else begin
		data_out_size_comb=(buffer_size>6'd8)? 4'd8:buffer_size[3:0];
		unique case (circular_address_read[1:0])
		0:begin
			data_out_temp[0]=q_0a;
			data_out_temp[1]=q_1a;
			data_out_temp[2]=q_2a;
			data_out_temp[3]=q_3a;
			data_out_temp[4]=q_0b;
			data_out_temp[5]=q_1b;
			data_out_temp[6]=q_2b;
			data_out_temp[7]=q_3b;
		end
		1:begin
			data_out_temp[7]=q_0a;
			data_out_temp[0]=q_1a;
			data_out_temp[1]=q_2a;
			data_out_temp[2]=q_3a;
			data_out_temp[3]=q_0b;
			data_out_temp[4]=q_1b;
			data_out_temp[5]=q_2b;
			data_out_temp[6]=q_3b;
		end
		2:begin
			data_out_temp[6]=q_0a;
			data_out_temp[7]=q_1a;
			data_out_temp[0]=q_2a;
			data_out_temp[1]=q_3a;
			data_out_temp[2]=q_0b;
			data_out_temp[3]=q_1b;
			data_out_temp[4]=q_2b;
			data_out_temp[5]=q_3b;
		end
		3:begin
			data_out_temp[5]=q_0a;
			data_out_temp[6]=q_1a;
			data_out_temp[7]=q_2a;
			data_out_temp[0]=q_3a;
			data_out_temp[1]=q_0b;
			data_out_temp[2]=q_1b;
			data_out_temp[3]=q_2b;
			data_out_temp[4]=q_3b;
		end
		endcase
	end
	if (jump_triggering) data_out_size_comb=0; // might not be needed
end


ip_instruction_cache_ram ip_instruction_cache_ram_inst0(
	.address_a(address_0a),
	.address_b(address_0b),
	.clock(main_clk),
	.data_a(data_0a),
	.data_b(data_0b),
	.wren_a(wren_0a),
	.wren_b(wren_0b),
	.q_a(q_0a),
	.q_b(q_0b)
);
ip_instruction_cache_ram ip_instruction_cache_ram_inst1(
	.address_a(address_1a),
	.address_b(address_1b),
	.clock(main_clk),
	.data_a(data_1a),
	.data_b(data_1b),
	.wren_a(wren_1a),
	.wren_b(wren_1b),
	.q_a(q_1a),
	.q_b(q_1b)
);
ip_instruction_cache_ram ip_instruction_cache_ram_inst2(
	.address_a(address_2a),
	.address_b(address_2b),
	.clock(main_clk),
	.data_a(data_2a),
	.data_b(data_2b),
	.wren_a(wren_2a),
	.wren_b(wren_2b),
	.q_a(q_2a),
	.q_b(q_2b)
);
ip_instruction_cache_ram ip_instruction_cache_ram_inst3(
	.address_a(address_3a),
	.address_b(address_3b),
	.clock(main_clk),
	.data_a(data_3a),
	.data_b(data_3b),
	.wren_a(wren_3a),
	.wren_b(wren_3b),
	.q_a(q_3a),
	.q_b(q_3b)
);




endmodule
