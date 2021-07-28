`timescale 1 ps / 1 ps

module cache_data(
	output out_dirty,
	
	output [15:0] access_out_full_data_extern [7:0],
	output [127:0] raw_out_full_data_extern,
	
	input  [15:0] access_in_full_data [3:0],
	input  [127:0] raw_in_full_data,
	
	input  [10:0] target_segment,
	input  [1:0] target_way,
	
	input  do_partial_write,
	input  do_byte_operation,
	
	input  byte_operation_polarity, // 0==lower byte , 1==upper byte
	input  [2:0] word_offset,
	input  [2:0] access_length, // access_length signifies a number of words one greater then it's value
	
	input  do_full_write, // do_full_write uses raw_in and ignores typical access mechanics
	input  any_fault,
	
	input  main_clk
);

reg [15:0] access_out_full_data [7:0];
wire [127:0] raw_out_full_data;

assign raw_out_full_data_extern=raw_out_full_data;
assign access_out_full_data_extern=access_out_full_data;

reg [7:0] word_mask;

reg do_byte_operation_r=0;
reg byte_operation_polarity_r=0;
reg [2:0] word_offset_r=0;
always @(posedge main_clk) word_offset_r<=word_offset;
always @(posedge main_clk) do_byte_operation_r<=do_byte_operation;
always @(posedge main_clk) byte_operation_polarity_r<=byte_operation_polarity;

wire do_write;
reg [15:0] byte_enable;
reg [1:0] byte_pair;

assign do_write=do_full_write | (do_partial_write & !any_fault);

reg [127:0] write_data;

always_comb begin
	write_data=128'hx;
	if (do_full_write) begin
		write_data=raw_in_full_data;
	end else if (do_byte_operation) begin
		write_data={16{access_in_full_data[0][7:0]}};
	end else begin
		unique case (word_offset)
		0:begin
			write_data[ 15:  0]=access_in_full_data[0];
			write_data[ 31: 16]=access_in_full_data[1];
			write_data[ 47: 32]=access_in_full_data[2];
			write_data[ 63: 48]=access_in_full_data[3];
		end
		1:begin
			write_data[ 31: 16]=access_in_full_data[0];
			write_data[ 47: 32]=access_in_full_data[1];
			write_data[ 63: 48]=access_in_full_data[2];
			write_data[ 79: 64]=access_in_full_data[3];
		end
		2:begin
			write_data[ 47: 32]=access_in_full_data[0];
			write_data[ 63: 48]=access_in_full_data[1];
			write_data[ 79: 64]=access_in_full_data[2];
			write_data[ 95: 80]=access_in_full_data[3];
		end
		3:begin
			write_data[ 63: 48]=access_in_full_data[0];
			write_data[ 79: 64]=access_in_full_data[1];
			write_data[ 95: 80]=access_in_full_data[2];
			write_data[111: 96]=access_in_full_data[3];
		end
		4:begin
			write_data[ 79: 64]=access_in_full_data[0];
			write_data[ 95: 80]=access_in_full_data[1];
			write_data[111: 96]=access_in_full_data[2];
			write_data[127:112]=access_in_full_data[3];
		end
		5:begin
			write_data[ 95: 80]=access_in_full_data[0];
			write_data[111: 96]=access_in_full_data[1];
			write_data[127:112]=access_in_full_data[2];
		end
		6:begin
			write_data[111: 96]=access_in_full_data[0];
			write_data[127:112]=access_in_full_data[1];
		end
		7:begin
			write_data[127:112]=access_in_full_data[0];
		end
		endcase
	end
end

always_comb begin
	byte_pair[0]=(do_byte_operation?!byte_operation_polarity:1'b1)?1'b1:1'b0;
	byte_pair[1]=(do_byte_operation? byte_operation_polarity:1'b1)?1'b1:1'b0;
	word_mask=8'hxx;
	unique case (access_length)
	0:word_mask=8'b00_00_00_01;
	1:word_mask=8'b00_00_00_11;
	2:word_mask=8'b00_00_01_11;
	3:word_mask=8'b00_00_11_11;
	4:word_mask=8'b00_01_11_11;
	5:word_mask=8'b00_11_11_11;
	6:word_mask=8'b01_11_11_11;
	7:word_mask=8'b11_11_11_11;
	endcase
	
	word_mask=word_mask << word_offset;
	
	byte_enable[ 1: 0]={2{word_mask[0]}};
	byte_enable[ 3: 2]={2{word_mask[1]}};
	byte_enable[ 5: 4]={2{word_mask[2]}};
	byte_enable[ 7: 6]={2{word_mask[3]}};
	byte_enable[ 9: 8]={2{word_mask[4]}};
	byte_enable[11:10]={2{word_mask[5]}};
	byte_enable[13:12]={2{word_mask[6]}};
	byte_enable[15:14]={2{word_mask[7]}};
	
	byte_enable=(byte_enable & {8{byte_pair}}) | {16{do_full_write}};
end


always_comb begin
	access_out_full_data[0]=16'hx;
	access_out_full_data[1]=16'hx;
	access_out_full_data[2]=16'hx;
	access_out_full_data[3]=16'hx;
	access_out_full_data[4]=16'hx;
	access_out_full_data[5]=16'hx;
	access_out_full_data[6]=16'hx;
	access_out_full_data[7]=16'hx;
	
	unique case (word_offset_r)
	0:begin
		access_out_full_data[0]=raw_out_full_data[ 15:  0];
		access_out_full_data[1]=raw_out_full_data[ 31: 16];
		access_out_full_data[2]=raw_out_full_data[ 47: 32];
		access_out_full_data[3]=raw_out_full_data[ 63: 48];
		access_out_full_data[4]=raw_out_full_data[ 79: 64];
		access_out_full_data[5]=raw_out_full_data[ 95: 80];
		access_out_full_data[6]=raw_out_full_data[111: 96];
		access_out_full_data[7]=raw_out_full_data[127:112];
	end
	1:begin
		access_out_full_data[0]=raw_out_full_data[ 31: 16];
		access_out_full_data[1]=raw_out_full_data[ 47: 32];
		access_out_full_data[2]=raw_out_full_data[ 63: 48];
		access_out_full_data[3]=raw_out_full_data[ 79: 64];
		access_out_full_data[4]=raw_out_full_data[ 95: 80];
		access_out_full_data[5]=raw_out_full_data[111: 96];
		access_out_full_data[6]=raw_out_full_data[127:112];
	end
	2:begin
		access_out_full_data[0]=raw_out_full_data[ 47: 32];
		access_out_full_data[1]=raw_out_full_data[ 63: 48];
		access_out_full_data[2]=raw_out_full_data[ 79: 64];
		access_out_full_data[3]=raw_out_full_data[ 95: 80];
		access_out_full_data[4]=raw_out_full_data[111: 96];
		access_out_full_data[5]=raw_out_full_data[127:112];
	end
	3:begin
		access_out_full_data[0]=raw_out_full_data[ 63: 48];
		access_out_full_data[1]=raw_out_full_data[ 79: 64];
		access_out_full_data[2]=raw_out_full_data[ 95: 80];
		access_out_full_data[3]=raw_out_full_data[111: 96];
		access_out_full_data[4]=raw_out_full_data[127:112];
	end
	4:begin
		access_out_full_data[0]=raw_out_full_data[ 79: 64];
		access_out_full_data[1]=raw_out_full_data[ 95: 80];
		access_out_full_data[2]=raw_out_full_data[111: 96];
		access_out_full_data[3]=raw_out_full_data[127:112];
	end
	5:begin
		access_out_full_data[0]=raw_out_full_data[ 95: 80];
		access_out_full_data[1]=raw_out_full_data[111: 96];
		access_out_full_data[2]=raw_out_full_data[127:112];
	end
	6:begin
		access_out_full_data[0]=raw_out_full_data[111: 96];
		access_out_full_data[1]=raw_out_full_data[127:112];
	end
	7:begin
		access_out_full_data[0]=raw_out_full_data[127:112];
	end
	endcase
	
	if (do_byte_operation_r) begin
		access_out_full_data[0][ 7: 0]=byte_operation_polarity_r ? access_out_full_data[0][15: 8] : access_out_full_data[0][ 7: 0] ;
		access_out_full_data[0][15: 8]=8'h0;
	end
end


ip_cache_data ip_cache_data_inst(
	byte_enable,
	main_clk,
	write_data,
	{
		target_way,
		target_segment
	},
	{
		target_way,
		target_segment
	},
	do_write,
	raw_out_full_data
);


ip_cache_dirty ip_cache_dirty_inst(
	main_clk,
	do_write && !do_full_write,
	{
		target_way,
		target_segment
	},
	{
		target_way,
		target_segment
	},
	do_write,
	out_dirty
);

endmodule

