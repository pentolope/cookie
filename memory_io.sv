`timescale 1 ps / 1 ps

`include "vga_driver.sv"
`include "sd_card_controller.sv"
`include "ps2_controller.sv"

module memory_io(
	output [15:0] data_out_io,
	input  [15:0] data_in_io,
	input  [31:0] address_io,
	input  [ 1:0] control_io, // {do_partial_write_instant,do_byte_operation_instant}
	
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		     [3:0]		VGA_R,
	output		          		VGA_HS,
	output		          		VGA_VS,
	
	output [9:0] led_out_state,
	
	output ps2_at0_external_clock_pulldown,
	output ps2_at0_external_data_pulldown,
	input ps2_at0_external_clock_in,
	input ps2_at0_external_data_in,
	
	output sd_at0_clk_external,
	output sd_at0_chip_select_external,
	output sd_at0_data_external_mosi,
	input  sd_at0_data_external_miso,
	
	output [7:0] debug_controller_state_now,
	
	input vga_clk,
	input main_clk
);

/*

Address access mapping:
	address_io[31]    determines if any IO device is accessed ( 0==no , 1==yes )
	address_io[25:23] determines which IO device is accessed
	address_io[25:23]==0 : LEDs on circuit board
	address_io[25:23]==1 : VGA's VRAM
	address_io[25:23]==2 : sd card controller
	address_io[25:23]==3 : ps2 controller

Typical considerations for IO mapped devices:
	All IO devices will not "react" (change state) due to a memory read. However, they may change state due to other factors, which could change the resulting value of the read.
	Some IO devices will operate identically to memory with word/byte and read/write accesses (as long as the address is within the range of the device's memory area).

Warning for ignoring IO mapped device's protocols:
	For all IO devices, software is responsible for adhering to the protocols of when certain memory words/bytes are allowed to be read and written.
	Failing to adhere to the protocols of a particular device will result in undefined behavior.
	In the worst of cases, this undefined behavior may result in unexpected result data, dropped requests, or endlessly unresponsive controllers.

Special considerations for VGA's VRAM:
	The VGA's VRAM will ignore the upper 4 bits of input data.
	The VGA's VRAM will only accept word writes. It cannot be read and will ignore any byte access.
	Consequently, the VGA's VRAM will ignore the one's bit of the address.

Special considerations for sd card controller:
	See sd_card_controller.sv

Special considerations for ps2 controller:
	See ps2_controller.sv

Access protocol for VGA's VRAM:
	Any memory location in the VGA's VRAM may be written with a word at any time.
	After writing, the new pixel value will be visible on the display as soon as possible.

Access protocol for sd card controller:
	See sd_card_controller.sv

Access protocol for ps2 controller:
	See ps2_controller.sv

*/

wire [15:0] data_in_io_modified={(control_io[0]?data_in_io[7:0]:data_in_io[15:8]),(data_in_io[7:0])};
reg [31:0] address_io_r=0;
reg [ 1:0] control_io_r=0;
reg [31:0] address_io_rr=0;
reg [ 1:0] control_io_rr=0;
reg [15:0] data_in_io_modified_r=0;
always @(posedge main_clk) begin
	data_in_io_modified_r<=data_in_io_modified;
	address_io_r<=address_io;
	control_io_r<=control_io;
	
	address_io_rr<=address_io_r;
	control_io_rr<=control_io_r;
end

wire [15:0] out_mux [7:0];
wire [15:0] nearly_data_out_io=out_mux[address_io_rr[25:23]];
assign data_out_io=control_io_rr[0]?(address_io_rr[0]?{8'h0,nearly_data_out_io[15:8]}:{8'h0,nearly_data_out_io[ 7:0]}):nearly_data_out_io;
assign out_mux[0]=16'h0; // LEDs on circuit board cannot be read
assign out_mux[1]=16'h0; // VGA's VRAM cannot be read
// out_mux[2] is sd card controller
// out_mux[3] is ps2 controller

reg [9:0] led_state=0;
assign led_out_state=led_state;
always @(posedge main_clk) begin
	// LEDs
	if (control_io_r[1] && address_io_r[31] && address_io_r[25:23]==3'd0 && address_io_r[3:0]<4'd10) begin
		led_state[address_io_r[3:0]]=data_in_io_modified_r[0];
	end
end

vga_driver vga_driver_inst(
	.VGA_B(VGA_B),.VGA_G(VGA_G),.VGA_R(VGA_R),.VGA_HS(VGA_HS),.VGA_VS(VGA_VS),
	
	.do_write(control_io[1] && address_io[31] && address_io[25:23]==3'd1 && !control_io[1]),
	.write_addr(address_io[16:1]),
	.write_data(data_in_io[11:0]),
	.main_clk(main_clk),
	.vga_clk(vga_clk)
);

sd_card_controller sd_card_controller_inst(
	.clk_external(sd_at0_clk_external),
	.chip_select_external(sd_at0_chip_select_external),
	.data_external_mosi(sd_at0_data_external_mosi),
	.data_external_miso(sd_at0_data_external_miso),
	
	.debug_controller_state_now(debug_controller_state_now),
	
	.data_read_mmio(out_mux[2]),
	.data_write_mmio(data_in_io_modified),
	.address_mmio(address_io[12:0]),
	.is_mmio_write(control_io[1] && address_io[31] && address_io[25:23]==3'd2),
	.is_mmio_byte(control_io[0]),
	.main_clk(main_clk)
);

ps2_controller ps2_controller_inst(
	.external_clock_pulldown(ps2_at0_external_clock_pulldown),
	.external_data_pulldown(ps2_at0_external_data_pulldown),
	.external_clock_in(ps2_at0_external_clock_in),
	.external_data_in(ps2_at0_external_data_in),
	
	.data_read_mmio(out_mux[3][7:0]),
	.data_write_mmio(data_in_io_modified[7:0]),
	.address_mmio(address_io[2:0]),
	.is_mmio_write(control_io[1] && address_io[31] && address_io[25:23]==3'd3),
	.main_clk(main_clk)
);
assign out_mux[3][15:8]=out_mux[3][7:0];

endmodule
