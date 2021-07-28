`timescale 1 ps / 1 ps

module cache_way(
	output [10:0] out_addr_at_in_way_index, // `address[25:15]` for the way located by `in_way_index` and `target_address[14: 4]`
	
	output out_soft_fault,
	output out_hard_fault,
	output out_any_fault,
	output out_was_hard_fault_starting,
	output out_was_hard_faulting,
	
	output [ 1:0] out_way_index,
	
	input  [ 1:0] in_way_index,
	
	input  [30:0] target_address,
	input is_hyper_fetch,
	input is_no_access,
	
	input do_write,
	input main_clk
);

reg was_hard_fault_starting=0;
reg was_hard_faulting=0;
assign out_was_hard_fault_starting=was_hard_fault_starting;
assign out_was_hard_faulting=was_hard_faulting;

wire possible_soft_fault;
wire possible_hard_fault;
wire possible_any_fault;
wire soft_fault;
wire hard_fault;
wire any_fault;
assign soft_fault=was_hard_fault_starting?1'b0:possible_soft_fault; // don't need to check previous value, it is already known here
assign hard_fault=was_hard_fault_starting?1'b1:possible_hard_fault; // don't need to check previous value, it is already known here
assign any_fault =was_hard_fault_starting?1'b1:possible_any_fault;  // don't need to check previous value, it is already known here
assign out_soft_fault=soft_fault;
assign out_hard_fault=hard_fault;
assign out_any_fault=any_fault;


reg [1:0] out_fault_modification=0;
reg [10:0] saved_target=0;
reg [3:0] saved_bypass_data=0;
reg [1:0] in_way_index_r=0;

reg [10:0] raw_out0_r=0;
reg [10:0] raw_out1_r=0;
reg [10:0] raw_out2_r=0;
reg [10:0] raw_out3_r=0;

wire [10:0] raw_out0;
wire [10:0] raw_out1;
wire [10:0] raw_out2;
wire [10:0] raw_out3;

wire [3:0] match;
wire [1:0] calc_way_index;
reg [1:0] calc_way_index_r=0;

assign out_way_index=was_hard_fault_starting?calc_way_index_r:calc_way_index;


always @(posedge main_clk) begin
	in_way_index_r<=in_way_index;
	calc_way_index_r<=calc_way_index;
	saved_target<=target_address[25:15];
	out_fault_modification<=0;
	if (is_hyper_fetch) out_fault_modification<=2;
	if (is_no_access) out_fault_modification<=1;
end

always @(posedge main_clk) begin
	if (!was_hard_fault_starting) begin
		raw_out0_r<=raw_out0;
		raw_out1_r<=raw_out1;
		raw_out2_r<=raw_out2;
		raw_out3_r<=raw_out3;
	end
end

lcell_13 lc_out_addr_at_in_way_index(out_addr_at_in_way_index,
	((in_way_index_r==2'd0)?raw_out0_r:11'd0) | 
	((in_way_index_r==2'd1)?raw_out1_r:11'd0) | 
	((in_way_index_r==2'd2)?raw_out2_r:11'd0) | 
	((in_way_index_r==2'd3)?raw_out3_r:11'd0)
);

// [25:15]
// [14: 4]

ip_cache_addr_way0 ip_cache_addr_way0_inst(
	main_clk,
	target_address[25:15],
	target_address[14: 4],
	target_address[14: 4],
	do_write && (in_way_index_r==2'd0),
	raw_out0
);

ip_cache_addr_way1 ip_cache_addr_way1_inst(
	main_clk,
	target_address[25:15],
	target_address[14: 4],
	target_address[14: 4],
	do_write && (in_way_index_r==2'd1),
	raw_out1
);

ip_cache_addr_way2 ip_cache_addr_way2_inst(
	main_clk,
	target_address[25:15],
	target_address[14: 4],
	target_address[14: 4],
	do_write && (in_way_index_r==2'd2),
	raw_out2
);

ip_cache_addr_way3 ip_cache_addr_way3_inst(
	main_clk,
	target_address[25:15],
	target_address[14: 4],
	target_address[14: 4],
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


lcell_4 lc_match(match,{
	((raw_out3==saved_target)?1'b1:1'b0),
	((raw_out2==saved_target)?1'b1:1'b0),
	((raw_out1==saved_target)?1'b1:1'b0),
	((raw_out0==saved_target)?1'b1:1'b0)
});

lcell_2 lc_calc_way_index(calc_way_index,way_index_lookup[{match[3],match[2],match[1]}]);

wire fault;

lcell_1 lc_general_fault(fault,(!match[0] && !match[1] && !match[2] && !match[3]));

assign possible_any_fault=(fault || out_fault_modification[0]);
assign possible_soft_fault=(fault && out_fault_modification[1]);
assign possible_hard_fault=(fault && out_fault_modification==2'd0);

always @(posedge main_clk) was_hard_faulting<=hard_fault;

always @(posedge main_clk) begin
	if (hard_fault) was_hard_fault_starting<=1;
	if (was_hard_faulting) was_hard_fault_starting<=0;
end


endmodule
