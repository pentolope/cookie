`timescale 1 ps / 1 ps

`include "vga_driver.sv"

module memory_io(
	output [15:0] data_out_io,
	input  [15:0] data_in_io,
	input  [31:0] address_out_io,
	input  [ 1:0] control_out_io, // {do_partial_write_instant,do_byte_operation_instant}
	
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		     [3:0]		VGA_R,
	output		          		VGA_HS,
	output		          		VGA_VS,
	
	input vga_clk,
	input main_clk
);
wire [15:0] data_in_io_modified={(control_out_io[0]?data_in_io[7:0]:data_in_io[15:8]),(data_in_io[7:0])};
//reg [15:0] data_in_io_r=0;
reg [31:0] address_out_io_r=0;
reg [ 1:0] control_out_io_r=0;
//reg [15:0] data_in_io_rr=0;
reg [31:0] address_out_io_rr=0;
reg [ 1:0] control_out_io_rr=0;
always @(posedge main_clk) begin
	//data_in_io_r<=data_in_io_modified;
	address_out_io_r<=address_out_io;
	control_out_io_r<=control_out_io;
	
	//data_in_io_rr<=data_in_io_r;
	address_out_io_rr<=address_out_io_r;
	control_out_io_rr<=control_out_io_r;
end

wire [15:0] out_mux [63:0];
wire [15:0] nearly_data_out_io=out_mux[address_out_io_rr[31:26]];
assign data_out_io=control_out_io_rr[0]?(address_out_io_rr[0]?{8'h0,nearly_data_out_io[15:8]}:{8'h0,nearly_data_out_io[ 7:0]}):nearly_data_out_io;
assign out_mux[0]=16'hx;






vga_driver vga_driver_inst(
	VGA_B,
	VGA_G,
	VGA_R,
	VGA_HS,
	VGA_VS,
	control_out_io[1] && !control_out_io[1] && address_out_io[31:26]==6'd1, // vga_do_write
	address_out_io[16:1], // vga_write_addr
	data_in_io[11:0], // vga_write_data
	main_clk,
	vga_clk
);


endmodule

