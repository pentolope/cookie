`timescale 1 ps / 1 ps

module vga_memory_system(
	input  io_do_write,
	input  io_do_byte_op,
	input  [14:0] io_addr,
	input  [15:0] io_write_data,
	output [15:0] io_read_data,
	
	input  start_character_processing,
	input  [12:0] character_index,
	input  [ 4:0] row_font_count,
	input  [ 4:0] row_index,
	output [ 7:0] background_color,
	output [ 7:0] foreground_color,
	output [ 7:0] font_info,
	output [ 7:0] mode_info,
	input  [14:0] raw_mode_addr_in,
	output [ 7:0] raw_mode_data_out,
	input  increment_frame_counter,
	
	input main_clk,
	input VGA_CLK
);

wire [1:0] byte_enable;
assign byte_enable[0]=io_do_byte_op?!io_addr[0]:1'b1;
assign byte_enable[1]=io_do_byte_op? io_addr[0]:1'b1;

reg [14:0] read_addr_async;
reg [14:0] read_addr_r=0;
always @(posedge VGA_CLK) read_addr_r<=read_addr_async;

wire [15:0] raw_read0;
wire [15:0] raw_read1;
reg [7:0] vga_read_byte;

always_comb begin
	vga_read_byte=read_addr_r[0]?raw_read1[15:8]:raw_read1[ 7:0];
end
assign raw_mode_data_out=vga_read_byte;

reg [7:0] frame_counter_0=0;
reg [7:0] frame_counter_1=0;
reg [7:0] frame_counter_2=0;
reg [7:0] frame_counter_3=0;
reg [7:0] frame_counter_4=0;

always @(posedge VGA_CLK) frame_counter_0<=frame_counter_0+(increment_frame_counter?1'b1:1'b0);
always @(posedge VGA_CLK) frame_counter_1<=frame_counter_0^(frame_counter_0>>1); // binary to graycode
always @(posedge main_clk) frame_counter_2<=frame_counter_1; // clock domain cross where the timing doesn't really matter, so it has a false path set for timing analysis.
always @(posedge main_clk) frame_counter_3<=frame_counter_2; // additional register after clock domain cross to help prevent weird behaviour.
always @(posedge main_clk) begin
	// graycode to binary
	frame_counter_4[0]<= ^(frame_counter_3 >> 0);
	frame_counter_4[1]<= ^(frame_counter_3 >> 1);
	frame_counter_4[2]<= ^(frame_counter_3 >> 2);
	frame_counter_4[3]<= ^(frame_counter_3 >> 3);
	frame_counter_4[4]<= ^(frame_counter_3 >> 4);
	frame_counter_4[5]<= ^(frame_counter_3 >> 5);
	frame_counter_4[6]<= ^(frame_counter_3 >> 6);
	frame_counter_4[7]<= ^(frame_counter_3 >> 7);
end

reg override_to_frame_counter=0;
reg [15:0] io_read_data_r=0;
always @(posedge main_clk) override_to_frame_counter<=(io_addr==15'd20478 && io_do_byte_op==1'b1)?1'b1:1'b0;
always @(posedge main_clk) begin
	if (override_to_frame_counter) begin
		io_read_data_r<={frame_counter_4,frame_counter_4};
	end else begin
		io_read_data_r<=raw_read0;
	end
end
assign io_read_data=io_read_data_r;

vga_memory vga_memory_inst0(
	byte_enable,
	io_write_data,
	io_addr[14:1],
	main_clk,
	io_addr[14:1],
	main_clk,
	io_do_write,
	raw_read0
);

vga_memory vga_memory_inst1(
	byte_enable,
	io_write_data,
	read_addr_async[14:1],
	VGA_CLK,
	io_addr[14:1],
	main_clk,
	io_do_write,
	raw_read1
);

reg [7:0] character_code_async;
reg [7:0] background_color_async;
reg [7:0] foreground_color_async;
reg [7:0] font_info_async;
reg [7:0] mode_info_async;

reg [7:0] character_code_r=0;
reg [7:0] background_color_r=0;
reg [7:0] foreground_color_r=0;
reg [7:0] font_info_r=0;
reg [7:0] mode_info_r=0;

always @(posedge VGA_CLK) background_color_r<=background_color_async;
always @(posedge VGA_CLK) foreground_color_r<=foreground_color_async;
always @(posedge VGA_CLK) font_info_r<=font_info_async;
always @(posedge VGA_CLK) mode_info_r<=mode_info_async;
always @(posedge VGA_CLK) character_code_r<=character_code_async;

assign background_color=background_color_r;
assign foreground_color=foreground_color_r;
assign font_info=font_info_r;
assign mode_info=mode_info_r;

reg [3:0] state=0;
reg [3:0] state_curr;
reg [3:0] state_next;
always @(posedge VGA_CLK) state<=state_next;

reg [14:0] font_base_addr_r=0;
reg [14:0] font_base_addr_async;
always @(posedge VGA_CLK) font_base_addr_r<=font_base_addr_async;

wire [14:0] extended_addresses [4:0];
assign extended_addresses[0]=15'd20479;
assign extended_addresses[1]=15'd20477;
assign extended_addresses[2]=15'd20476;
assign extended_addresses[3]=raw_mode_addr_in;

reg [1:0] extended_addresses_index;

reg [14:0] address_of_character_in_font=0;
always @(posedge VGA_CLK) begin
	if (state_curr==4'd2) begin
		address_of_character_in_font<=({8'h0,character_code_r} * row_font_count) + (row_index + font_base_addr_r);
	end
end

always_comb begin
	background_color_async=background_color_r;
	foreground_color_async=foreground_color_r;
	font_info_async=font_info_r;
	mode_info_async=mode_info_r;
	character_code_async=character_code_r;
	font_base_addr_async=font_base_addr_r;
	
	state_curr=state;
	state_next=state+1'b1;
	if (state==4'd8) state_next=4'd8;
	if (start_character_processing) state_next=4'd1;
	if (start_character_processing) state_curr=4'd0;
	
	extended_addresses_index=(state_curr[3])?(2'b11):(state_curr[1:0]);

	if (state_curr[2] || state_curr[3]) begin
		read_addr_async=extended_addresses[extended_addresses_index];
	end else begin
		read_addr_async=(state_curr[1:0]==2'd3)?(address_of_character_in_font):(character_index + {character_index,1'b0} + state_curr[1:0]);
	end
	
	unique case (state_curr[2:0])
	0:begin
	end
	1:begin
		character_code_async=vga_read_byte;
	end
	2:begin
		foreground_color_async=vga_read_byte;
	end
	3:begin
		background_color_async=vga_read_byte;
	end
	4:begin
		font_info_async=vga_read_byte;
	end
	5:begin
		mode_info_async=vga_read_byte;
	end
	6:begin
		font_base_addr_async[14:8]=vga_read_byte[6:0];
	end
	7:begin
		font_base_addr_async[7:0]=vga_read_byte;
	end
	endcase
end
endmodule

module vga_driver(
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		     [3:0]		VGA_R,
	output		          		VGA_HS,
	output		          		VGA_VS,
	
	input  io_do_write,
	input  io_do_byte_op,
	input  [14:0] io_addr,
	input  [15:0] io_write_data,
	output [15:0] io_read_data,
	input  main_clk,
	input  VGA_CLK
);

/*
mode_info (at address 20479):

mode_info[3:0]+5'd3== the height of the font, also known as the number of rows per character.
mode_info[3:0]== If 0, treat memory space as raw colors on a 160*120 screen (with each logical pixel spanning 4x4 real pixels). Otherwise, treat memory space as data for text mode.
mode_info[4]== If 1, treat the font as a 8 pixel width font. Otherwise, treat the font as a 9 pixel width font by inserting one pixel of background color after the font pixels.
mode_info[5]== (currently unused)
mode_info[6]== (currently unused)
mode_info[7]== (currently unused)
*/
/*
Frame counter can be read at 20478 (must perform byte read). It cannot be written to. Attempting to write to it will write to the underlying memory location, which is not where the value of the frame counter is stored.
*/
/*
Font memory address offset can be set at address 20476,20477  (it is a 15 bit value, little endian as always).
*/
/*
If I ever wanted to give this a further update, I might be able to make text mode double buffered because there might be enough memory for that. 
I would have to have a place in memory to put an offset to the part of the buffer which will act as the character/color definition area.
This idea is currently NOT implemented.
*/

/*
Currently, raw mode is UNTESTED
*/


reg update_mode_info=0;
wire [7:0] mode_info_async;
reg  [7:0] mode_info=0;
reg using_raw_mode=0;
reg [4:0] row_font_count=0;
reg [4:0] row_font_count_m1=0;
always @(posedge VGA_CLK) begin
	if (update_mode_info) begin
		mode_info<=mode_info_async;
		using_raw_mode<=(mode_info_async[3:0]==4'b0)?1'b1:1'b0;
		row_font_count   <=mode_info_async[3:0]+5'd3;
		row_font_count_m1<=mode_info_async[3:0]+5'd2;
	end
end


reg  [14:0] raw_mode_addr_in=0;
wire [7:0] raw_mode_data_out_async;
reg  [7:0] raw_mode_data_out_r [1:0]='{0,0};
always @(posedge VGA_CLK) raw_mode_data_out_r[1]<=raw_mode_data_out_async;
always @(posedge VGA_CLK) raw_mode_data_out_r[0]<=raw_mode_data_out_r[1];


wire [7:0] font_info_async;
wire [7:0] background_color_async;
wire [7:0] foreground_color_async;
reg  [4:0] row_index=0;
reg  [12:0] character_index_unstable=0;
reg  [12:0] character_index_stable=0;
reg  increment_frame_counter=0;
reg  start_character_processing=0;

reg [9:0] horizontal_state=0;
reg [9:0] vertical_state=0;
reg [9:0] horizontal_state_next;
reg [9:0] vertical_state_next;
reg enable_pixel_next;
reg enable_pixel=0;
reg enable_out=0;

reg [3:0] horizontal_index_font_character_state_sub=0;
reg [3:0] horizontal_index_font_character_state_sub_next;
reg [4:0] vertical_index_font_character_state_sub=0;
reg [4:0] vertical_index_font_character_state_sub_next;
reg enable_font_character_next;
reg enable_font_character=0;
reg trigger_new_character_next;
reg trigger_new_character=0;
reg trigger_character_index_backup;

always @(posedge VGA_CLK) enable_font_character<=enable_font_character_next;
always @(posedge VGA_CLK) enable_pixel<=enable_pixel_next;
always @(posedge VGA_CLK) horizontal_state<=horizontal_state_next;
always @(posedge VGA_CLK) vertical_state<=vertical_state_next;
always @(posedge VGA_CLK) horizontal_index_font_character_state_sub<=horizontal_index_font_character_state_sub_next;
always @(posedge VGA_CLK) vertical_index_font_character_state_sub<=vertical_index_font_character_state_sub_next;
always @(posedge VGA_CLK) trigger_new_character<=trigger_new_character_next;

always @(posedge VGA_CLK) enable_out=using_raw_mode?enable_pixel:enable_font_character;

always @(posedge VGA_CLK) begin
	if (trigger_new_character_next) begin
		character_index_unstable<=character_index_unstable+1'b1;
	end
	if (mode_info[4]) begin
		if (trigger_character_index_backup) character_index_unstable<=character_index_unstable-13'd79;
	end else begin
		if (trigger_character_index_backup) character_index_unstable<=character_index_unstable-13'd70;
	end
	if (horizontal_state_next==10'd0 && vertical_state_next==10'd0) begin
		character_index_unstable<=0;
	end
end

always_comb enable_pixel_next=(vertical_state_next<10'd480 && horizontal_state_next<10'd640)?1'b1:1'b0;
always_comb enable_font_character_next=(enable_pixel_next && (mode_info[4] || horizontal_state_next!=10'd639))?1'b1:1'b0;

always_comb begin
	if (horizontal_state==10'd799) begin
		horizontal_state_next=0;
		if (vertical_state==10'd524) begin
			vertical_state_next=0;
		end else begin
			vertical_state_next=vertical_state+1'b1;
		end
	end else begin
		horizontal_state_next=horizontal_state+1'b1;
		vertical_state_next=vertical_state;
	end
end
always_comb begin
	horizontal_index_font_character_state_sub_next=horizontal_index_font_character_state_sub;
	vertical_index_font_character_state_sub_next=vertical_index_font_character_state_sub;
	trigger_new_character_next=0;
	trigger_character_index_backup=0;
	if (enable_font_character_next) begin
		if (enable_font_character) begin
			if (horizontal_index_font_character_state_sub==((mode_info[4])?(4'd7):(4'd8))) begin
				trigger_new_character_next=1;
				horizontal_index_font_character_state_sub_next=0;
			end else begin
				horizontal_index_font_character_state_sub_next=horizontal_index_font_character_state_sub+1'b1;
			end
		end else begin
			trigger_new_character_next=1;
			horizontal_index_font_character_state_sub_next=0;
			if (vertical_index_font_character_state_sub==row_font_count_m1) begin
				vertical_index_font_character_state_sub_next=0;
			end else begin
				vertical_index_font_character_state_sub_next=vertical_index_font_character_state_sub+1'b1;
				trigger_character_index_backup=1;
			end
		end
	end
	if (horizontal_state_next==10'd0 && vertical_state_next==10'd0) begin
		trigger_new_character_next=1;
		horizontal_index_font_character_state_sub_next=0;
		vertical_index_font_character_state_sub_next=0;
	end
end

reg new_raw_pixel=0;
always @(posedge VGA_CLK) new_raw_pixel<=(horizontal_state[1:0]==2'b00)?1'b1:1'b0;
always @(posedge VGA_CLK) raw_mode_addr_in<=({8'h0,vertical_state_next[8:2]} * 15'd160) + horizontal_state_next[9:2];

reg generated_horizontal_sync=0;
reg generated_verticle_sync=0;
always @(posedge VGA_CLK) begin
	generated_horizontal_sync<=1;
	generated_verticle_sync<=1;
	if (horizontal_state>=10'd656 && horizontal_state<10'd752) generated_horizontal_sync<=0;
	if (vertical_state>=10'd490 && vertical_state<10'd492) generated_verticle_sync<=0;
end

reg [3:0] delay_chain [5:0]='{0,0,0,0,0,0};
always @(posedge VGA_CLK) begin
	delay_chain[4:0]<=delay_chain[5:1];
	delay_chain[5][0]<=using_raw_mode?new_raw_pixel:start_character_processing;
	delay_chain[5][1]<=generated_horizontal_sync;
	delay_chain[5][2]<=generated_verticle_sync;
	delay_chain[5][3]<=enable_out;
end
reg [7:0] data_buff [8:0]='{0,0,0,0,0,0,0,0,0};

reg [3:0] VGA_B_r=0;
reg [3:0] VGA_G_r=0;
reg [3:0] VGA_R_r=0;
reg VGA_HS_r [1:0]='{0,0};
reg VGA_VS_r [1:0]='{0,0};
assign VGA_B=VGA_B_r;
assign VGA_G=VGA_G_r;
assign VGA_R=VGA_R_r;
assign VGA_HS=VGA_HS_r[0];
assign VGA_VS=VGA_VS_r[0];

always @(posedge VGA_CLK) begin
	VGA_HS_r[0]<=VGA_HS_r[1];
	VGA_VS_r[0]<=VGA_VS_r[1];
end

reg [4:0] walk_buff=0;
always @(posedge VGA_CLK) begin
	VGA_HS_r[1]<=delay_chain[0][1];
	VGA_VS_r[1]<=delay_chain[0][2];
	if (using_raw_mode) begin
		walk_buff<=walk_buff+1'b1;
		if (delay_chain[0][0]) begin
			data_buff[0]<=raw_mode_data_out_r[0];
			data_buff[1]<=raw_mode_data_out_r[0];
			data_buff[2]<=raw_mode_data_out_r[0];
			data_buff[3]<=raw_mode_data_out_r[0];
			walk_buff<=0;
		end
		if (!delay_chain[0][3]) begin
			walk_buff<=15;
		end
	end else begin
		if (delay_chain[0][0]) begin
			data_buff[0]<=font_info_async[0]?foreground_color_async:background_color_async;
			data_buff[1]<=font_info_async[1]?foreground_color_async:background_color_async;
			data_buff[2]<=font_info_async[2]?foreground_color_async:background_color_async;
			data_buff[3]<=font_info_async[3]?foreground_color_async:background_color_async;
			data_buff[4]<=font_info_async[4]?foreground_color_async:background_color_async;
			data_buff[5]<=font_info_async[5]?foreground_color_async:background_color_async;
			data_buff[6]<=font_info_async[6]?foreground_color_async:background_color_async;
			data_buff[7]<=font_info_async[7]?foreground_color_async:background_color_async;
			data_buff[8]<=background_color_async;
			walk_buff<=0;
		end else begin
			walk_buff<=walk_buff+1'b1;
		end
		if (!delay_chain[0][3]) begin
			walk_buff<=15;
		end
	end
end
reg [7:0] data_at_walk_buff;
always_comb begin
	if (walk_buff<4'd9) begin
		data_at_walk_buff=data_buff[walk_buff];
	end else begin
		data_at_walk_buff=0;
	end
end
always @(posedge VGA_CLK) begin
	VGA_B_r[3:2]<=data_at_walk_buff[1:0];
	VGA_B_r[1:0]<=data_at_walk_buff[1:0];
	VGA_G_r[3:1]<=data_at_walk_buff[4:2];
	VGA_G_r[0]<=data_at_walk_buff[2];
	VGA_R_r[3:1]<=data_at_walk_buff[7:5];
	VGA_R_r[0]<=data_at_walk_buff[5];
end
always @(posedge VGA_CLK) begin
	update_mode_info<=0;
	increment_frame_counter<=0;
	start_character_processing<=0;
	
	if (trigger_new_character && !using_raw_mode) begin
		start_character_processing<=1;
		row_index<=vertical_index_font_character_state_sub;
		character_index_stable<=character_index_unstable;
	end
	if (horizontal_state==10'd648 && vertical_state==10'd479) begin
		start_character_processing<=1; // this is used to ensure that mode info gets updated when in raw mode.
	end
	if (horizontal_state==10'd660 && vertical_state==10'd479) begin
		increment_frame_counter<=1;
		update_mode_info<=1;
	end
end


vga_memory_system vga_memory_system_inst(
	.io_do_write(io_do_write),
	.io_do_byte_op(io_do_byte_op),
	.io_addr(io_addr),
	.io_write_data(io_write_data),
	.io_read_data(io_read_data),
	
	.start_character_processing(start_character_processing),
	.character_index(character_index_stable),
	.row_font_count(row_font_count),
	.row_index(row_index),
	.background_color(background_color_async),
	.foreground_color(foreground_color_async),
	.font_info(font_info_async),
	.mode_info(mode_info_async),
	.raw_mode_addr_in(raw_mode_addr_in),
	.raw_mode_data_out(raw_mode_data_out_async),
	.increment_frame_counter(increment_frame_counter),
	
	.main_clk(main_clk),
	.VGA_CLK(VGA_CLK)
);

endmodule
