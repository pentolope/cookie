`timescale 1 ps / 1 ps

module cache_data(
	output out_dirty, // out_dirty only refers to the single_access_out_full_data
	
	output [15:0] multi_access_out_full_data_extern [7:0],
	output [15:0] single_access_out_full_data_extern [7:0],
	input  [15:0] access_mask,
	output [127:0] raw_out_full_data_extern,
	
	input  [15:0] access_in_full_data [7:0],
	input  [127:0] raw_in_full_data,
	
	input  [8:0] target_segment,
	input  [1:0] target_way_read,
	input  [1:0] target_way_write,
	
	input  do_full_write,
	input  do_partial_write,
	input  do_byte_operation,
	
	input  override_no_write, // unless do_full_write
	input  calculated_cache_fault,
	
	input  main_clk
);

reg [15:0] multi_access_out_full_data [7:0];
reg [15:0] single_access_out_full_data [7:0];
reg [127:0] raw_out_full_data;


assign raw_out_full_data_extern=raw_out_full_data;
assign single_access_out_full_data_extern=single_access_out_full_data;
assign multi_access_out_full_data_extern=multi_access_out_full_data;

reg [15:0] masked_out_full_data [7:0];

reg [15:0] access_mask_r;
reg [15:0] single_access_out_full_data_r [7:0];
reg do_byte_operation_r=0;

always_comb begin
	masked_out_full_data[0]={({8{access_mask_r[ 1]}}),({8{access_mask_r[ 0]}})} & raw_out_full_data[ 15:  0];
	masked_out_full_data[1]={({8{access_mask_r[ 3]}}),({8{access_mask_r[ 2]}})} & raw_out_full_data[ 31: 16];
	masked_out_full_data[2]={({8{access_mask_r[ 5]}}),({8{access_mask_r[ 4]}})} & raw_out_full_data[ 47: 32];
	masked_out_full_data[3]={({8{access_mask_r[ 7]}}),({8{access_mask_r[ 6]}})} & raw_out_full_data[ 63: 48];
	masked_out_full_data[4]={({8{access_mask_r[ 9]}}),({8{access_mask_r[ 8]}})} & raw_out_full_data[ 79: 64];
	masked_out_full_data[5]={({8{access_mask_r[11]}}),({8{access_mask_r[10]}})} & raw_out_full_data[ 95: 80];
	masked_out_full_data[6]={({8{access_mask_r[13]}}),({8{access_mask_r[12]}})} & raw_out_full_data[111: 96];
	masked_out_full_data[7]={({8{access_mask_r[15]}}),({8{access_mask_r[14]}})} & raw_out_full_data[127:112];
end

wire do_write=do_full_write | (do_partial_write & !override_no_write & !calculated_cache_fault);

reg [127:0] write_data;
reg [15:0] byte_enable;

always_comb begin
	if (do_full_write) begin
		write_data=raw_in_full_data;
	end else begin
		write_data[ 15:  0]=access_in_full_data[0];
		write_data[ 31: 16]=access_in_full_data[1];
		write_data[ 47: 32]=access_in_full_data[2];
		write_data[ 63: 48]=access_in_full_data[3];
		write_data[ 79: 64]=access_in_full_data[4];
		write_data[ 95: 80]=access_in_full_data[5];
		write_data[111: 96]=access_in_full_data[6];
		write_data[127:112]=access_in_full_data[7];
	end
end

always_comb begin
	byte_enable[0]=access_mask[0];
	byte_enable[1]=access_mask[1];
	byte_enable[2]=access_mask[2];
	byte_enable[3]=access_mask[3];
	byte_enable[4]=access_mask[4];
	byte_enable[5]=access_mask[5];
	byte_enable[6]=access_mask[6];
	byte_enable[7]=access_mask[7];
	byte_enable[8]=access_mask[8];
	byte_enable[9]=access_mask[9];
	byte_enable[10]=access_mask[10];
	byte_enable[11]=access_mask[11];
	byte_enable[12]=access_mask[12];
	byte_enable[13]=access_mask[13];
	byte_enable[14]=access_mask[14];
	byte_enable[15]=access_mask[15];
	byte_enable=byte_enable | {16{do_full_write}};
end

reg [2:0] word_offset=0;

reg [3:0] temp0_word_size=0;
reg [3:0] temp1_word_size=0;
reg [3:0] temp2_word_size=0;
reg [2:0] word_size=0; // word_size is one cycle behind word_offset

always_comb begin
	unique case({(access_mask[ 5] | access_mask[ 4]),(access_mask[ 3] | access_mask[ 2]),(access_mask[ 1] | access_mask[ 0])})
	3'b000:temp0_word_size<=0;
	3'b001:temp0_word_size<=1;
	3'b010:temp0_word_size<=1;
	3'b011:temp0_word_size<=2;
	3'b100:temp0_word_size<=1;
	3'b101:temp0_word_size<=2;
	3'b110:temp0_word_size<=2;
	3'b111:temp0_word_size<=3;
	endcase
	unique case({(access_mask[11] | access_mask[10]),(access_mask[ 9] | access_mask[ 8]),(access_mask[ 7] | access_mask[ 6])})
	3'b000:temp1_word_size<=0;
	3'b001:temp1_word_size<=1;
	3'b010:temp1_word_size<=1;
	3'b011:temp1_word_size<=2;
	3'b100:temp1_word_size<=1;
	3'b101:temp1_word_size<=2;
	3'b110:temp1_word_size<=2;
	3'b111:temp1_word_size<=3;
	endcase
	unique case({(access_mask[15] | access_mask[14]),(access_mask[13] | access_mask[12])})
	2'b00:temp2_word_size<=0;
	2'b01:temp2_word_size<=1;
	2'b10:temp2_word_size<=1;
	2'b11:temp2_word_size<=2;
	endcase
end

always @(posedge main_clk) begin
	if (!calculated_cache_fault) begin
		access_mask_r<=access_mask;
		single_access_out_full_data_r<=single_access_out_full_data;
		do_byte_operation_r<=do_byte_operation;
		
		word_size <= (temp0_word_size + temp1_word_size + temp2_word_size) - 4'h1; // "truncated value with size 4 to match size of target (3)" warning is expected here. It is fine
		
		word_offset<=3'h0;
		if (access_mask[15] | access_mask[14]) word_offset<=3'h7;
		if (access_mask[13] | access_mask[12]) word_offset<=3'h6;
		if (access_mask[11] | access_mask[10]) word_offset<=3'h5;
		if (access_mask[ 9] | access_mask[ 8]) word_offset<=3'h4;
		if (access_mask[ 7] | access_mask[ 6]) word_offset<=3'h3;
		if (access_mask[ 5] | access_mask[ 4]) word_offset<=3'h2;
		if (access_mask[ 3] | access_mask[ 2]) word_offset<=3'h1;
		if (access_mask[ 1] | access_mask[ 0]) word_offset<=3'h0;
	end
end


always_comb begin
	single_access_out_full_data[0]=0;
	single_access_out_full_data[1]=0;
	single_access_out_full_data[2]=0;
	single_access_out_full_data[3]=0;
	single_access_out_full_data[4]=0;
	single_access_out_full_data[5]=0;
	single_access_out_full_data[6]=0;
	single_access_out_full_data[7]=0;
	
	unique case (word_offset)
	0:begin
		single_access_out_full_data[0]=masked_out_full_data[0];
		single_access_out_full_data[1]=masked_out_full_data[1];
		single_access_out_full_data[2]=masked_out_full_data[2];
		single_access_out_full_data[3]=masked_out_full_data[3];
		single_access_out_full_data[4]=masked_out_full_data[4];
		single_access_out_full_data[5]=masked_out_full_data[5];
		single_access_out_full_data[6]=masked_out_full_data[6];
		single_access_out_full_data[7]=masked_out_full_data[7];
	end
	1:begin
		single_access_out_full_data[0]=masked_out_full_data[1];
		single_access_out_full_data[1]=masked_out_full_data[2];
		single_access_out_full_data[2]=masked_out_full_data[3];
		single_access_out_full_data[3]=masked_out_full_data[4];
		single_access_out_full_data[4]=masked_out_full_data[5];
		single_access_out_full_data[5]=masked_out_full_data[6];
		single_access_out_full_data[6]=masked_out_full_data[7];
	end
	2:begin
		single_access_out_full_data[0]=masked_out_full_data[2];
		single_access_out_full_data[1]=masked_out_full_data[3];
		single_access_out_full_data[2]=masked_out_full_data[4];
		single_access_out_full_data[3]=masked_out_full_data[5];
		single_access_out_full_data[4]=masked_out_full_data[6];
		single_access_out_full_data[5]=masked_out_full_data[7];
	end
	3:begin
		single_access_out_full_data[0]=masked_out_full_data[3];
		single_access_out_full_data[1]=masked_out_full_data[4];
		single_access_out_full_data[2]=masked_out_full_data[5];
		single_access_out_full_data[3]=masked_out_full_data[6];
		single_access_out_full_data[4]=masked_out_full_data[7];
	end
	4:begin
		single_access_out_full_data[0]=masked_out_full_data[4];
		single_access_out_full_data[1]=masked_out_full_data[5];
		single_access_out_full_data[2]=masked_out_full_data[6];
		single_access_out_full_data[3]=masked_out_full_data[7];
	end
	5:begin
		single_access_out_full_data[0]=masked_out_full_data[5];
		single_access_out_full_data[1]=masked_out_full_data[6];
		single_access_out_full_data[2]=masked_out_full_data[7];
	end
	6:begin
		single_access_out_full_data[0]=masked_out_full_data[6];
		single_access_out_full_data[1]=masked_out_full_data[7];
	end
	7:begin
		single_access_out_full_data[0]=masked_out_full_data[7];
	end
	endcase
	
	if (do_byte_operation_r) begin
		single_access_out_full_data[0][ 7: 0]=single_access_out_full_data[0][ 7: 0] | single_access_out_full_data[0][15: 8];
		single_access_out_full_data[0][15: 8]=8'h0;
	end
end



always_comb begin
	multi_access_out_full_data=single_access_out_full_data_r;
	
	unique case (word_size)
	0:begin
		multi_access_out_full_data[1]=single_access_out_full_data[0];
		multi_access_out_full_data[2]=single_access_out_full_data[1];
		multi_access_out_full_data[3]=single_access_out_full_data[2];
		multi_access_out_full_data[4]=single_access_out_full_data[3];
		multi_access_out_full_data[5]=single_access_out_full_data[4];
		multi_access_out_full_data[6]=single_access_out_full_data[5];
		multi_access_out_full_data[7]=single_access_out_full_data[6];
	end
	1:begin
		multi_access_out_full_data[2]=single_access_out_full_data[0];
		multi_access_out_full_data[3]=single_access_out_full_data[1];
		multi_access_out_full_data[4]=single_access_out_full_data[2];
		multi_access_out_full_data[5]=single_access_out_full_data[3];
		multi_access_out_full_data[6]=single_access_out_full_data[4];
		multi_access_out_full_data[7]=single_access_out_full_data[5];
	end
	2:begin
		multi_access_out_full_data[3]=single_access_out_full_data[0];
		multi_access_out_full_data[4]=single_access_out_full_data[1];
		multi_access_out_full_data[5]=single_access_out_full_data[2];
		multi_access_out_full_data[6]=single_access_out_full_data[3];
		multi_access_out_full_data[7]=single_access_out_full_data[4];
	end
	3:begin
		multi_access_out_full_data[4]=single_access_out_full_data[4];
		multi_access_out_full_data[5]=single_access_out_full_data[5];
		multi_access_out_full_data[6]=single_access_out_full_data[6];
		multi_access_out_full_data[7]=single_access_out_full_data[7];
	end
	4:begin
		multi_access_out_full_data[5]=single_access_out_full_data[5];
		multi_access_out_full_data[6]=single_access_out_full_data[6];
		multi_access_out_full_data[7]=single_access_out_full_data[7];
	end
	5:begin
		multi_access_out_full_data[6]=single_access_out_full_data[6];
		multi_access_out_full_data[7]=single_access_out_full_data[7];
	end
	6:begin
		multi_access_out_full_data[7]=single_access_out_full_data[7];
	end
	7:begin
	end
	endcase
end

ip_cache_data ip_cache_data_inst(
	byte_enable,
	main_clk,
	write_data,
	{
		target_way_read,
		target_segment
	},
	{
		target_way_write,
		target_segment
	},
	do_write,
	raw_out_full_data
);


ip_cache_dirty ip_cache_dirty_inst(
	main_clk,
	do_write && !do_full_write,
	{
		target_way_read,
		target_segment
	},
	{
		target_way_write,
		target_segment
	},
	do_write,
	out_dirty
);

endmodule

