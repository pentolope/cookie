`timescale 1 ps / 1 ps

module cache_LRU_sub_read_through_write(
input  main_clk,
input  [4:0] perm_in,
input  [10:0] read_addr,
input  [10:0] write_addr,
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


module cache_LRU(
	output [1:0] least_used_index,

	input  [10:0] addr,
	input  [1:0] used_index,
	input  enable_write,
	input  main_clk
);

reg  [1:0] used_index_delayed;
reg  enable_write_delayed=0;
wire [10:0] read_addr;assign read_addr=addr;
reg  [10:0] write_addr=0;
wire [4:0] raw_perm_out;
wire [4:0] raw_perm_in;
wire [1:0] least_used_index_calc;

lcells #(2) lc_lru_out(least_used_index,least_used_index_calc);

`include "AutoGen0.sv"


always @(posedge main_clk) begin
	enable_write_delayed<=enable_write;
	used_index_delayed<=used_index;
	write_addr<=read_addr;
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
