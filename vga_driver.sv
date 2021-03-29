`timescale 1 ps / 1 ps

module vga_driver(
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		     [3:0]		VGA_R,
	output		          		VGA_HS,
	output		          		VGA_VS,
	
	input do_write,
	input [15:0] write_addr,
	input [11:0] write_data,
	input main_clk,
	input vga_clk
);

reg do_write_r=0;
reg [15:0] write_addr_r=0;
reg [11:0] write_data_r=0;

always @(posedge main_clk) begin
	do_write_r<=do_write;
	write_addr_r<=write_addr;
	write_data_r<=write_data;
end

reg  [15:0] read_addr;
wire [11:0] read_data;
reg  [11:0] read_data_r=0;

reg [2:0] horizontal_sync_pulse_delay_chain=3'b111;
reg [2:0] vertical_sync_pulse_delay_chain=0;
reg [1:0] enable_output_delay_chain=0;

reg horizontal_sync_pulse;
reg vertical_sync_pulse;
reg enable_output;

reg [8:0] horizontal_state=0;
reg [8:0] vertical_state=0;

reg [8:0] horizontal_state_next;
reg [8:0] vertical_state_next;


always @(posedge vga_clk) begin
	read_data_r<={12{enable_output_delay_chain[1]}} & read_data;
end

assign VGA_R=read_data_r[ 3:0];
assign VGA_G=read_data_r[ 7:4];
assign VGA_B=read_data_r[11:8];
assign VGA_HS=horizontal_sync_pulse_delay_chain[2];
assign VGA_VS=vertical_sync_pulse_delay_chain[2];


always @(posedge vga_clk) begin
	enable_output_delay_chain[1]<=enable_output_delay_chain[0];
	enable_output_delay_chain[0]<=enable_output;
	
	vertical_sync_pulse_delay_chain[2]<=vertical_sync_pulse_delay_chain[1];
	vertical_sync_pulse_delay_chain[1]<=vertical_sync_pulse_delay_chain[0];
	vertical_sync_pulse_delay_chain[0]<=vertical_sync_pulse; // Polarity of vertical sync pulse is positive
	
	horizontal_sync_pulse_delay_chain[2]<=horizontal_sync_pulse_delay_chain[1];
	horizontal_sync_pulse_delay_chain[1]<=horizontal_sync_pulse_delay_chain[0];
	horizontal_sync_pulse_delay_chain[0]<=! horizontal_sync_pulse; // Polarity of horizontal sync pulse is negative
end

always_comb begin
	horizontal_state_next=horizontal_state+1'd1;
	vertical_state_next=vertical_state;
	if (horizontal_state>=9'd399) begin
		horizontal_state_next=0;
		vertical_state_next=vertical_state+1'd1;
		if (vertical_state>=9'd448) begin
			vertical_state_next=0;
		end
	end
end

always @(posedge vga_clk) begin
	horizontal_state<=horizontal_state_next;
	vertical_state<=vertical_state_next;
end

always @(posedge vga_clk) begin
	if (horizontal_state>=9'd400) begin $stop(); end
	if (vertical_state>=9'd449) begin $stop(); end
end

reg [8:0] tmp_horizontal_state_offset;
reg [8:0] tmp_vertical_state_offset0;
reg [15:0] tmp_vertical_state_offset1;


always_comb begin
	tmp_horizontal_state_offset=horizontal_state-9'd24;
	tmp_vertical_state_offset0=vertical_state-9'd34;
	tmp_vertical_state_offset0={1'b0,tmp_vertical_state_offset0[8:1]}; // divide by 2, because displaying each memory location twice
	tmp_vertical_state_offset1={tmp_vertical_state_offset0[7:0],6'b0}+{tmp_vertical_state_offset0[7:0],8'b0}; // multiply by 320
	read_addr=tmp_horizontal_state_offset+tmp_vertical_state_offset1;
end


always_comb begin
	horizontal_sync_pulse=(horizontal_state>=9'd352)?1'b1:1'b0;
end

always_comb begin
	vertical_sync_pulse=(vertical_state>=9'd446 && vertical_state<9'd448)?1'b1:1'b0;
end

always_comb begin
	enable_output=((horizontal_state>=9'd24 && horizontal_state<9'd344) && (vertical_state>=9'd34 && vertical_state<9'd434))?1'b1:1'b0;
end

/*

 Polarity of horizontal sync pulse is negative.
 Back porch 24 cycles
 Visible area 320 cycles
 Front porch 8 cycles
 Sync pulse 48 cycles
 Whole line 400 cycles

 Vertical timing (frame)
 Polarity of vertical sync pulse is positive.
 Back porch 34 lines
 Visible area 400 lines (display each memory line twice)
 Front porch 12 lines
 Sync pulse 2 lines
 Back porch 1 lines
 Whole frame 449 lines

*/



mem_pixel_array mem_pixel_array_inst(
	write_data_r,
	read_addr,
	vga_clk,
	write_addr_r,
	main_clk,
	do_write_r && write_addr_r<16'd64000,
	read_data
);


endmodule







