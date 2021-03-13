`timescale 1 ps / 1 ps

module cache_way(
	output [12:0] out_addr_at_in_way_index, // `address[25:13]` for the way located by `in_way_index` and `target_address[12: 4]`
	
	output out_fault,
	output [ 1:0] out_way_index,
	
	input  [ 1:0] in_way_index,
	
	input  [25:0] target_address,
	
	input do_write,
	input main_clk
);

reg [12:0] saved_target=0;
reg [3:0] saved_bypass_data=0;
reg [1:0] in_way_index_r=0;

reg [12:0] raw_out0_r=0;
reg [12:0] raw_out1_r=0;
reg [12:0] raw_out2_r=0;
reg [12:0] raw_out3_r=0;

wire [12:0] raw_out0;
wire [12:0] raw_out1;
wire [12:0] raw_out2;
wire [12:0] raw_out3;

always @(posedge main_clk) begin
	raw_out0_r<=raw_out0;
	raw_out1_r<=raw_out1;
	raw_out2_r<=raw_out2;
	raw_out3_r<=raw_out3;
	saved_target<=target_address[25:13];
	in_way_index_r<=in_way_index;
end

assign out_addr_at_in_way_index=
	((in_way_index_r==2'd0)?raw_out0_r:13'd0) | 
	((in_way_index_r==2'd1)?raw_out1_r:13'd0) | 
	((in_way_index_r==2'd2)?raw_out2_r:13'd0) | 
	((in_way_index_r==2'd3)?raw_out3_r:13'd0);

// [25:13]
// [12: 4]

ip_cache_addr_way0 ip_cache_addr_way0_inst(
	main_clk,
	target_address[25:13],
	target_address[12: 4],
	target_address[12: 4],
	do_write && (in_way_index_r==2'd0),
	raw_out0
);

ip_cache_addr_way1 ip_cache_addr_way1_inst(
	main_clk,
	target_address[25:13],
	target_address[12: 4],
	target_address[12: 4],
	do_write && (in_way_index_r==2'd1),
	raw_out1
);

ip_cache_addr_way2 ip_cache_addr_way2_inst(
	main_clk,
	target_address[25:13],
	target_address[12: 4],
	target_address[12: 4],
	do_write && (in_way_index_r==2'd2),
	raw_out2
);

ip_cache_addr_way3 ip_cache_addr_way3_inst(
	main_clk,
	target_address[25:13],
	target_address[12: 4],
	target_address[12: 4],
	do_write && (in_way_index_r==2'd3),
	raw_out3
);

wire [1:0] way_index_lookup [7:0];
assign way_index_lookup[{1'b0,1'b0,1'b0}]=2'd0;
assign way_index_lookup[{1'b0,1'b0,1'b1}]=2'd1;
assign way_index_lookup[{1'b0,1'b1,1'b0}]=2'd2;
assign way_index_lookup[{1'b0,1'b1,1'b1}]=2'd1;
assign way_index_lookup[{1'b1,1'b0,1'b0}]=2'd3;
assign way_index_lookup[{1'b1,1'b0,1'b1}]=2'd1;
assign way_index_lookup[{1'b1,1'b1,1'b0}]=2'd2;
assign way_index_lookup[{1'b1,1'b1,1'b1}]=2'd1;

wire [3:0] match;
assign match={
	((raw_out3==saved_target)?1'b1:1'b0),
	((raw_out2==saved_target)?1'b1:1'b0),
	((raw_out1==saved_target)?1'b1:1'b0),
	((raw_out0==saved_target)?1'b1:1'b0)
};
assign out_way_index=way_index_lookup[{match[3],match[2],match[1]}];
assign out_fault=!match[0] & !match[1] & !match[2] & !match[3];

endmodule
