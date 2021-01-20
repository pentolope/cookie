`timescale 1 ps / 1 ps

module cache_LRU_sub_read_through_write(
input  main_clk,
input  [4:0] perm_in,
input  [8:0] read_addr,
input  [8:0] write_addr,
input  enable_write,
output [4:0] perm_out
);

reg [4:0] perm_in_r=0;
reg do_override=0;

always @(posedge main_clk) begin
	perm_in_r<=perm_in;
	do_override<=(enable_write && (write_addr==read_addr))?1'b1:1'b0;
end

wire [4:0] raw_perm_out;

assign perm_out=do_override?perm_in_r:raw_perm_out;

ip_cache_LRU ip_cache_LRU_inst(
	main_clk,
	perm_in,
	read_addr,
	write_addr,
	enable_write,
	raw_perm_out
);

endmodule



module cache_LRU_old( // more tested
	output [1:0] least_used_index,

	input  [8:0] addr,
	input  [1:0] used_index,
	input  enable_write,
	input  main_clk
);

reg  [1:0] used_index_r;
reg  [1:0] used_index_delayed;
reg  enable_write_r=0;
reg  enable_write_delayed=0;
wire enable_write_delayed_w;assign enable_write_delayed_w=enable_write_delayed;
reg  [8:0] read_addr=0;
wire [8:0] read_addr_w;assign read_addr_w=read_addr;
reg  [8:0] write_addr=0;
wire [8:0] write_addr_w;assign write_addr_w=write_addr;
wire [4:0] raw_perm_out;
wire [4:0] raw_perm_in;
reg  [1:0] least_used_index_calc_r;
assign least_used_index=least_used_index_calc_r;
wire [1:0] least_used_index_calc;


`include "AutoGen0.sv"


always @(posedge main_clk) begin
	enable_write_r<=enable_write;
	enable_write_delayed<=enable_write_r;
	used_index_r<=used_index;
	used_index_delayed<=used_index_r;
	read_addr<=addr;
	write_addr<=read_addr;
	least_used_index_calc_r<=least_used_index_calc;
end

cache_LRU_sub_read_through_write cache_LRU_sub_read_through_write_inst(
	main_clk,
	raw_perm_in,
	read_addr_w,
	write_addr_w,
	enable_write_delayed_w,
	raw_perm_out
);

endmodule


module cache_LRU( // not really tested, but would be one cycle faster (so that dram controller could be a little faster)
	output [1:0] least_used_index,

	input  [8:0] addr,
	input  [1:0] used_index,
	input  enable_write,
	input  main_clk
);

reg  [1:0] used_index_delayed;
reg  enable_write_delayed=0;
wire [8:0] read_addr;assign read_addr=addr;
reg  [8:0] write_addr=0;
wire [4:0] raw_perm_out;
wire [4:0] raw_perm_in;
reg  [1:0] least_used_index_calc_r;
assign least_used_index=least_used_index_calc_r;
wire [1:0] least_used_index_calc;


`include "AutoGen0.sv"


always @(posedge main_clk) begin
	enable_write_delayed<=enable_write;
	used_index_delayed<=used_index;
	write_addr<=read_addr;
	least_used_index_calc_r<=least_used_index_calc;
end

cache_LRU_sub_read_through_write cache_LRU_sub_read_through_write_inst(
	main_clk,
	raw_perm_in,
	read_addr,
	write_addr,
	enable_write_delayed,
	raw_perm_out
);

endmodule
