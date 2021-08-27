`timescale 1 ps / 1 ps


module crc7_bit(
	output [6:0] crc_out,
	input  [6:0] crc_in,
	input  vb // vb is the bit that the crc is being calculated on
);
assign crc_out={crc_in[5:0],1'b0} ^ ({7{vb ^ crc_in[6]}} & 7'b000_1001);
endmodule

module crc16_bit(
	output [15:0] crc_out,
	input  [15:0] crc_in,
	input  vb // vb is the bit that the crc is being calculated on
);
assign crc_out={crc_in[14:0],1'b0} ^ ({16{vb ^ crc_in[15]}} & 16'b0001_0000_0010_0001);
endmodule

module crc7_byte(
	output [6:0] crc_out,
	input  [6:0] crc_in,
	input  [7:0] vbyte // vb is the byte that the crc is being calculated on
);
wire [6:0] crc_temp [8:0];
assign crc_temp[8]=crc_in;
assign crc_out=crc_temp[0];
crc7_bit crc7_bit7(crc_temp[7],crc_temp[8],vbyte[7]);
crc7_bit crc7_bit6(crc_temp[6],crc_temp[7],vbyte[6]);
crc7_bit crc7_bit5(crc_temp[5],crc_temp[6],vbyte[5]);
crc7_bit crc7_bit4(crc_temp[4],crc_temp[5],vbyte[4]);
crc7_bit crc7_bit3(crc_temp[3],crc_temp[4],vbyte[3]);
crc7_bit crc7_bit2(crc_temp[2],crc_temp[3],vbyte[2]);
crc7_bit crc7_bit1(crc_temp[1],crc_temp[2],vbyte[1]);
crc7_bit crc7_bit0(crc_temp[0],crc_temp[1],vbyte[0]);
endmodule

module crc16_byte(
	output [15:0] crc_out,
	input  [15:0] crc_in,
	input  [7:0] vbyte // vb is the byte that the crc is being calculated on
);
wire [15:0] crc_temp [8:0];
assign crc_temp[8]=crc_in;
assign crc_out=crc_temp[0];
crc16_bit crc16_bit7(crc_temp[7],crc_temp[8],vbyte[7]);
crc16_bit crc16_bit6(crc_temp[6],crc_temp[7],vbyte[6]);
crc16_bit crc16_bit5(crc_temp[5],crc_temp[6],vbyte[5]);
crc16_bit crc16_bit4(crc_temp[4],crc_temp[5],vbyte[4]);
crc16_bit crc16_bit3(crc_temp[3],crc_temp[4],vbyte[3]);
crc16_bit crc16_bit2(crc_temp[2],crc_temp[3],vbyte[2]);
crc16_bit crc16_bit1(crc_temp[1],crc_temp[2],vbyte[1]);
crc16_bit crc16_bit0(crc_temp[0],crc_temp[1],vbyte[0]);
endmodule

module sd_card_controller(
	output clk_external,
	output chip_select_external,
	output data_external_mosi,
	input  data_external_miso,
	
	output [7:0] debug_controller_state_now,

	output [15:0] data_read_mmio,
	input  [15:0] data_write_mmio,
	input  [12:0] address_mmio,
	input  is_mmio_byte,
	input  is_mmio_write,
	input  main_clk // 83 MHz
);

/*
Special considerations for sd card controller:
	This memory will react identically to typical memory when read/written to, including word/byte accesses.
	Some specific memory locations should never be written to (see access protocol).
	When this controller is in certain stages of processing a command, accessing certain areas of memory results in undefined behaviour  (see access protocol).

Access protocol for sd card controller:
	All memory addresses and data will be referenced in binary. Bits which represent "any value" or "don't care" will be "x". Data is suffixed with a "b" to help indicate that it is in binary.
	All memory address values do not include the bits required to select the sd card controller, because that is already assumed to be the case.
	
	This controller might not work correctly when connecting or unconnecting an sd card while the FPGA is already on. I make no guarantees on that.
	
	This controller performs all of the initialization for the sd card. It also handles sending various other commands to the sd card to complete the commands that are given through it's command communication port with the CPU.
	Once the controller is finished initializing the sd card, the CPU can trigger read/write block commands that this controller will perform.
	Currently, I plan on having the controller use only single block read/write commands, and having it issue multiple commands for multiple sectors.
		There are some weird things with multiple block read/write commands that I don't want to figure out right now.
	
	This controller provides a command communication port located in `addr[0000_xxxxxxxxx]` .
	All other addresses in range are data sections. There are 15 data sections, with the upper 4 bits of the 13bit address denoting which data section the address falls in.
	Obviously, since the command communication port is located at `addr[0000_xxxxxxxxx]`, the first data section is located in `addr[0001_xxxxxxxxx]` and the last is located in `addr[1111_xxxxxxxxx]` .
	
	The byte at `addr[0000_000000000]` may be written with a 0b or 1b.
		A 0b at this byte indicates that this is a read command.
		A 1b at this byte indicates that this is a write command.
	
	The byte at `addr[0000_000000001]` should never be written. It has no purpose.
	
	The byte at `addr[0000_000000010]` may be written with a 0b or 1b. A change of value at this memory location is a trigger point for the controller to progress between different stages of processing a command.
		Changing the value from 0b->1b should only be done when `addr[0000_000000100]==100b` . It causes the controller to begin processing a read/write command.
		Changing the value from 1b->0b should only be done when `addr[0000_000000100]==011b || addr[0000_000000100]==110b` . It causes the controller to acknowledge the finalization handshake.
	
	The byte at `addr[0000_000000011]` should never be written. It has no purpose.
	
	The byte at `addr[0000_000000100]` should never be written. It will contain 000b, 001b, 010b, 011b, 100b, 101b, or 110b.
		A 000b at this byte indicates that the controller is performing initialization. 
			Do not modify any memory location.
		A 001b at this byte indicates that the controller has seen that there is a new command and is in the early stages of processing it.
			Do not write to any memory location that is associated with the command.
		A 010b at this byte indicates that the controller has fully read the command.
			Any value in `addr[0000_xxxxxxxxx]` area may be written with new values, with the exception of `addr[0000_00000001x]` and `addr[0000_00000011x]` .
			Any data sections associated with the command that was already given should not be modified.
		A 011b at this byte indicates that the controller has finished processing the command that it was given.
			The controller will wait until `addr[0000_000000010]==0b` , then it will set `addr[0000_000000100]==100b`
		A 100b at this byte indicates that the controller is currently not processing a command.
			Nearly any memory location can be written or read when this is the case.
		A 101b at this byte indicates that the controller could not establish communication with the sd card. 
			There may not be a card, or the card isn't supported. Any pending command may not have been completed successfully. 
			Do not modify any memory location, INCLUDING `addr[0000_000000010]`.
		A 110b at this byte indicates that the controller performed a reset and it needs `addr[0000_000000010]` set to 0.
			The reset was performed due to unexpected card behaviour. This may have been caused by the card being removed and another inserted.
			The controller is waiting for acknowledgment that the pending command may not have been completed successfully.
			Do not modify any memory location, EXCEPT `addr[0000_000000010]`.
	
	The byte at `addr[0000_000000101]` should never be written. It has no purpose.
	
	The word at `addr[0000_00000011x]` contains the error value.
		It is written by the controller when `addr[0000_000000100]==010b` and `addr[0000_000000100]==001b` and after a full reset.
		It may be read when `addr[0000_000000100]==100b` .
		The error value should always be checked and handled after every command because the value is always overrwitten when a new command is being processed.
		Note that some values of `addr[0000_000000100]` indicate that the pending command may not have completed successfully.
		The values of `addr[0000_000000100]` take precedence over `addr[0000_00000011x]` in all cases for determining why the last command may not have succeeded.
		If `addr[0000_000000100]` or `addr[0000_00000011x]` indicate that the last command may not have succeeded, then the last command may not have succeeded. It doesn't matter if one of them indicate success.
		
		A 0 at this word indicates that no error occured and the command completed successfully (unless `addr[0000_000000100]` indicates otherwise).
		All other values indicate probable failure. In the future, this word will be the value of the sd card status.
	
	The double word at `addr[0000_0000010xx]` contains a list of data sections that are included with the read/write command.
		The list contains 4bit items and is 0 terminated. the 4 less significant bits of each byte are ordered before the 4 more significant bits.
		For example, `addr[0000_000001000]==0000_0010b`
			would indicate an access of length 1 where data section 2 would be read or written (depending on `addr[0000_000000000]` value)
		For example, `addr[0000_000001000]==0101_0010b` and `addr[0000_000001010]==0000_0001b`
			would indicate an access of length 3 where data sections 2,5,1 (in that order) would be read or written (depending on `addr[0000_000000000]` value)
		Although each data section could be mentioned in the list more then once, it is recommanded that each is only listed once at most.
		If the same section is listed more then once on a read command, the behaviour is undefined regarding what data is written to that section.
		If the list of sections contains 0 as the first 4 bit item, the controller will not perform a typical operation.
			Instead, it will check if the card responds normally to a simple check status command.
			If the card responds normally then the command is considered to have succeeded.
			If the card doesn't respond or responds abnormally then the command is considered to have failed, and the controller will attempt a full reset.
	
	The double word at `addr[0000_0000011xx]` contains the target block address to read/write.
		The value is little endian.
		A change in the one's bit causes the adjacent block to be read/written.
		This allows a range of values that can access 2 Terabytes. I don't think I am going to approach that limit.
	
	The double word at `addr[0000_0000100xx]` is the highest block address which the sd card has.
	
*/

reg  [11:0] address_controller_at_mmio=0;
reg  [15:0] data_write_controller_at_mmio=0;
wire [15:0] data_read_controller_at_mmio;
reg  write_enable_controller_at_mmio=0;


reg clk_speed_is_fast=0; // If 0, clock runs at initialization speed. If 1, clock runs at typical speed.
wire [8:0] clk_div_factor;
assign clk_div_factor=clk_speed_is_fast ? 9'd4 : 9'd396 ; // the actual division factor is twice the value in clk_div_factor, because the sd card's clock flips (0->1 or 1->0) when clk_counter>=clk_div_factor.

reg [8:0] clk_counter=0;
reg data_bit_miso=0;
reg data_bit_mosi=0;
assign data_external_mosi=data_bit_mosi;
reg clk_external_r=0;
assign clk_external=clk_external_r;
reg clk_external_prior_value=0;
reg is_clk_external_falling_next=0;
reg is_clk_external_rising_next=0;
reg is_clk_external_changing_next=0;
reg did_clk_external_fall=0;
reg did_clk_external_rise=0;

always @(posedge main_clk) begin
	clk_counter<=clk_counter+1'b1;
	clk_external_r<=clk_external_prior_value;
	is_clk_external_falling_next<=0;
	is_clk_external_rising_next<=0;
	is_clk_external_changing_next<=0;
	did_clk_external_fall<=is_clk_external_falling_next;
	did_clk_external_rise<=is_clk_external_rising_next;
	data_bit_miso<=data_external_miso;
	if (clk_counter>=clk_div_factor) begin
		clk_counter<=1; // clk_counter gets 1 (and not 0) for proper division of the clock
		clk_external_prior_value<= ~clk_external_prior_value;
		is_clk_external_changing_next<=1;
		if ( clk_external_prior_value) is_clk_external_falling_next<=1;
		if (!clk_external_prior_value) is_clk_external_rising_next<=1;
	end
end

reg is_command_write=0;
reg [31:0] target_base_block_address=0;
reg [31:0] transfer_section_list=0;

reg [3:0] storage_write_responce;
reg storage_bad_status;

wire [6:0] walking_crc7_output;
reg [6:0] walking_crc7_register=0;
wire [15:0] walking_crc16_output;
reg [15:0] walking_crc16_register=0;
reg [7:0] crc_byte=0; // both crc generators use the same byte

reg is_sd_card_byte_address=0; // does the attached card use byte addresses
reg is_sd_card_mmc_card=0; // is the attached sd card actually an mmc card
reg is_sd_card_standard_v1=0; // is the attached sd card an sd card and does it follow standard 1 (otherwise it is either an mmc card or it is an sd card that follows standard 2+)
reg delayed_init_check=0; // this is used once when doing an initialization check

reg [127:0] card_csd_content=0;
reg [31:0] highest_block_address=0;

reg [31:0] calculated_highest_block_address_result;
reg [40:0] calculated_highest_block_address_temp_blklen;
reg [40:0] calculated_highest_block_address_temp_mult;
reg [40:0] calculated_highest_block_address_temp_blknr;
reg [40:0] calculated_highest_block_address_temp_cap_0;
reg [40:0] calculated_highest_block_address_temp_cap_1;


always @(posedge main_clk) begin // this doesn't need to be async because the controller isn't that fast
	calculated_highest_block_address_temp_blklen<=0;
	calculated_highest_block_address_temp_mult<=0;
	calculated_highest_block_address_temp_blknr<=0;
	calculated_highest_block_address_temp_blklen[card_csd_content[83:80]]<=1'b1;
	calculated_highest_block_address_temp_mult[card_csd_content[49:47]+4'd2]<=1'b1;
	calculated_highest_block_address_temp_blknr<=(card_csd_content[73:62]+40'd1)*calculated_highest_block_address_temp_mult;
	calculated_highest_block_address_temp_cap_0<=calculated_highest_block_address_temp_blknr*calculated_highest_block_address_temp_blklen;
	calculated_highest_block_address_temp_cap_1<=(card_csd_content[69:48]+40'd1)*40'd524288;
	calculated_highest_block_address_result<=((is_sd_card_mmc_card || is_sd_card_standard_v1)?calculated_highest_block_address_temp_cap_0[40:9]:calculated_highest_block_address_temp_cap_1[40:9])-1'b1;
end

reg [5:0] command_id=0;
reg [31:0] command_arg=0;

reg [7:0] general_use_counter=0;
reg [7:0] controller_state_now=0;
reg [7:0] controller_state_after_command_sent=0;

assign debug_controller_state_now=controller_state_now;


reg perform_controller_process=0; // pulses on once for every byte that goes to/from SPI. It is also timed in a sweet spot that allows processing on the previous byte in to effect the next byte out.
reg chip_select_external_r=1;
assign chip_select_external=chip_select_external_r;
reg chip_select_next=1;
reg [7:0] final_byte_going_out=0; // this will hold the byte that is going to go out to the card
reg [7:0] final_byte_came_in=0;   // this will hold the byte that just came in from the card
reg [2:0] final_bit_counter=7;

always @(posedge main_clk) begin
	if (is_clk_external_falling_next) begin
		data_bit_mosi<=final_byte_going_out[final_bit_counter];
		if (final_bit_counter==3'd7) begin
			chip_select_external_r<=chip_select_next;
		end
	end
end
always @(posedge main_clk) begin
	perform_controller_process<=0;
	if (did_clk_external_rise) begin
		assert (!is_clk_external_falling_next);
		final_bit_counter<=final_bit_counter-1'b1;
		final_byte_came_in[final_bit_counter]<=data_bit_miso;
		if (final_bit_counter==3'd0) begin
			perform_controller_process<=1;
		end
	end
end
always @(posedge main_clk) begin
	write_enable_controller_at_mmio<=0;
	if (perform_controller_process) begin
		chip_select_next<=1;
		final_byte_going_out<=8'hFF;
		assert (!is_clk_external_falling_next);
		case (controller_state_now)
		0:begin // full reset
			controller_state_now<=1;
			general_use_counter<=0;
			is_sd_card_byte_address<=0;
			is_sd_card_mmc_card<=0;
			is_sd_card_standard_v1<=0;
			clk_speed_is_fast<=0;
		end
		1:begin // power on delay
			command_id<=0;
			command_arg<=0;
			controller_state_after_command_sent<=8;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				controller_state_now<=2;
				general_use_counter<=0;
			end
		end
		2:begin // issue command : byte 0
			chip_select_next<=0;
			walking_crc7_register<=0;
			crc_byte<=8'h40 | command_id;
			final_byte_going_out<=8'h40 | command_id;
			controller_state_now<=3;
		end
		3:begin // issue command : byte 1
			chip_select_next<=0;
			walking_crc7_register<=walking_crc7_output;
			crc_byte<=command_arg[31:24];
			final_byte_going_out<=command_arg[31:24];
			controller_state_now<=4;
		end
		4:begin // issue command : byte 2
			chip_select_next<=0;
			walking_crc7_register<=walking_crc7_output;
			crc_byte<=command_arg[23:16];
			final_byte_going_out<=command_arg[23:16];
			controller_state_now<=5;
		end
		5:begin // issue command : byte 3
			chip_select_next<=0;
			walking_crc7_register<=walking_crc7_output;
			crc_byte<=command_arg[15:8];
			final_byte_going_out<=command_arg[15:8];
			controller_state_now<=6;
		end
		6:begin // issue command : byte 4
			chip_select_next<=0;
			walking_crc7_register<=walking_crc7_output;
			crc_byte<=command_arg[7:0];
			final_byte_going_out<=command_arg[7:0];
			controller_state_now<=7;
		end
		7:begin // issue command : byte 5
			chip_select_next<=0;
			final_byte_going_out<={walking_crc7_output,1'b1};
			controller_state_now<=controller_state_after_command_sent;
		end
		8:begin // recieve responce to cmd0
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout
				controller_state_now<=39;
			end else if (final_byte_came_in==8'h01) begin
				controller_state_now<=9;
				general_use_counter<=0;
			end
		end
		9:begin // send cmd8 (part of initialization)
			command_id<=8;
			command_arg<=12'h1AA;
			controller_state_after_command_sent<=10;
			controller_state_now<=2;
		end
		10:begin // recieve responce for cmd8 (byte 0)
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, so initialization tries something else
				controller_state_now<=40;
				general_use_counter<=0;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h01) begin
					controller_state_now<=11;
					general_use_counter<=0;
				end else begin
					// error of some sort, so initialization tries something else
					controller_state_now<=40;
					general_use_counter<=0;
				end
			end
		end
		11:begin // recieve responce for cmd8 (byte 1)
			chip_select_next<=0;
			controller_state_now<=12;
		end
		12:begin // recieve responce for cmd8 (byte 2)
			chip_select_next<=0;
			controller_state_now<=13;
		end
		13:begin // recieve responce for cmd8 (byte 3)
			chip_select_next<=0;
			controller_state_now<=14;
			delayed_init_check<=(final_byte_came_in[3:0]!=4'h1)?1'b1:1'b0;
		end
		14:begin // recieve responce for cmd8 (byte 4)
			chip_select_next<=0;
			controller_state_now<=15;
			delayed_init_check<=delayed_init_check | (final_byte_came_in!=8'hAA)?1'b1:1'b0;
		end
		15:begin
			if (delayed_init_check) begin
				// bad answer to cmd8, initialization failure
				controller_state_now<=39;
			end else begin
				// answer to cmd8 is good
				controller_state_now<=16;
			end
		end
		16:begin // send cmd55 (next command is application specific)
			command_id<=55;
			command_arg<=0;
			controller_state_after_command_sent<=17;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		17:begin // wait for responce to cmd55
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, initialization fails
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h01 || final_byte_came_in==8'h00) begin
					controller_state_now<=18;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					controller_state_now<=39;
				end
			end
		end
		18:begin // send (a)cmd 41 (initialization related command)
			command_id<=41;
			command_arg<=32'h40_00_00_00;
			controller_state_after_command_sent<=19;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		19:begin // recieve (a)cmd 41 responce
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, initialization fails
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=21;
					general_use_counter<=0;
				end else if (final_byte_came_in==8'h01) begin
					controller_state_now<=20;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					controller_state_now<=39;
				end
			end
		end
		20:begin // wait for some time before sending acmd 41 again
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				general_use_counter<=0;
				controller_state_now<=16;
			end
		end
		21:begin // send cmd 58
			command_id<=58;
			command_arg<=0;
			controller_state_after_command_sent<=22;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		22:begin // recieve responce for cmd 58 (byte 4)
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, initialization fails
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=23;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					controller_state_now<=39;
				end
			end
		end
		23:begin // recieve responce for cmd 58 (byte 3)
			chip_select_next<=0;
			controller_state_now<=24;
			is_sd_card_byte_address<=!final_byte_came_in[6];
		end
		24:begin // recieve responce for cmd 58 (byte 2)
			chip_select_next<=0;
			controller_state_now<=25;
			delayed_init_check<=!(final_byte_came_in[5] & final_byte_came_in[4]);
		end
		25:begin // recieve responce for cmd 58 (byte 1)
			chip_select_next<=0;
			controller_state_now<=26;
		end
		26:begin // recieve responce for cmd 58 (byte 0)
			chip_select_next<=0;
			controller_state_now<=27;
		end
		27:begin // interpret responce for cmd 58
			if (delayed_init_check) begin
				// card doesn't support voltage range. initialization fails
				controller_state_now<=39;
			end else begin
				// card does support voltage range
				controller_state_now<=28; // initialization (likely) success, go set block size and enable crc
			end
		end
		28:begin // send cmd 16 (set block size)
			command_id<=16;
			command_arg<=32'h00_00_02_00;
			controller_state_after_command_sent<=29;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		29:begin // recieve responce for cmd 16 (set block size)
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, initialization fails
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=30;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					controller_state_now<=39;
				end
			end
		end
		30:begin // send cmd 59 (enable crc protection)
			command_id<=59;
			command_arg<=1;
			controller_state_after_command_sent<=31;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		31:begin
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, initialization fails
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=50; // initialization of the sd card (or mmc card) is complete
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					controller_state_now<=39;
				end
			end
		end
		/*  32<->38 is skipped in case I need to add something later that I want to put here */
		39:begin // indicate card communication failure and reset
			address_controller_at_mmio<=12'b0000_00000010;
			data_write_controller_at_mmio<=3'b101;
			write_enable_controller_at_mmio<=1;
			controller_state_now<=0;
		end
		40:begin // send cmd55 (next command is application specific)
			is_sd_card_byte_address<=1;
			command_id<=55;
			command_arg<=0;
			controller_state_after_command_sent<=41;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		41:begin // wait for responce to cmd55
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, initialization fails
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h01 || final_byte_came_in==8'h00) begin
					controller_state_now<=42;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					controller_state_now<=39;
				end
			end
		end
		42:begin // send (a)cmd 41 (initialization related command)
			command_id<=41;
			command_arg<=0;
			controller_state_after_command_sent<=43;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		43:begin // recieve (a)cmd 41 responce
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, initialization tries something else
				controller_state_now<=45;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=28; // initialization (likely) success, go set block size and enable crc
					general_use_counter<=0;
					is_sd_card_standard_v1<=1;
				end else if (final_byte_came_in==8'h01) begin
					controller_state_now<=44;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization tries something else
					controller_state_now<=45;
				end
			end
		end
		44:begin // wait for some time before sending acmd 41 again
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				general_use_counter<=0;
				controller_state_now<=40;
			end
		end
		45:begin // send cmd 1 (mmc initialization, first send)
			is_sd_card_mmc_card<=1;
			command_id<=1;
			command_arg<=0;
			controller_state_after_command_sent<=46;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		46:begin // recieve cmd 1 responce
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, initialization fails
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				controller_state_now<=47; // result is mostly unchecked on first attempt of cmd 1 . I read somewhere that this was sometimes important because the mmc card might not reset the "invalid instruction flag" from the previous invalid instruction
				general_use_counter<=0;
			end
		end
		47:begin // send cmd 1 (mmc initialization, later send(s))
			command_id<=1;
			command_arg<=0;
			controller_state_after_command_sent<=48;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		48:begin // recieve cmd 1 responce
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, initialization fails
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=28; // initialization (likely) success, go set block size and enable crc
					general_use_counter<=0;
				end else if (final_byte_came_in==8'h01) begin
					controller_state_now<=49;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					controller_state_now<=39;
				end
			end
		end
		49:begin // wait for some time before sending cmd 1 again
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				general_use_counter<=0;
				controller_state_now<=47;
			end
		end
		50:begin
			// card initialization complete.
			// send cmd 9 to determine card size
			command_id<=9;
			command_arg<=0;
			controller_state_after_command_sent<=51;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		51:begin // wait for responce to cmd 9
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, could not communicate with card
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=52;
					general_use_counter<=0;
				end else begin
					// error of some sort, try again
					controller_state_now<=50;
				end
			end
		end
		52:begin // wait for data block of cmd 9 responce
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, could not communicate with card
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'hFE) begin
					controller_state_now<=53;
					general_use_counter<=0;
				end else begin
					// error of some sort, the data block didn't start with a data block start.
					// I am going to catagorize this as "could not communicate with card" and have it do a full reset
					controller_state_now<=39;
				end
			end
		end
		53:begin // cmd 9 responce --> card_csd_content (Byte 15)
			chip_select_next<=0;
			card_csd_content[127:120]<=final_byte_came_in;
			controller_state_now<=54;
		end
		54:begin // cmd 9 responce --> card_csd_content (Byte 14)
			chip_select_next<=0;
			card_csd_content[119:112]<=final_byte_came_in;
			controller_state_now<=55;
		end
		55:begin // cmd 9 responce --> card_csd_content (Byte 13)
			chip_select_next<=0;
			card_csd_content[111:104]<=final_byte_came_in;
			controller_state_now<=56;
		end
		56:begin // cmd 9 responce --> card_csd_content (Byte 12)
			chip_select_next<=0;
			card_csd_content[103: 96]<=final_byte_came_in;
			controller_state_now<=57;
		end
		57:begin // cmd 9 responce --> card_csd_content (Byte 11)
			chip_select_next<=0;
			card_csd_content[ 95: 88]<=final_byte_came_in;
			controller_state_now<=58;
		end
		58:begin // cmd 9 responce --> card_csd_content (Byte 10)
			chip_select_next<=0;
			card_csd_content[ 87: 80]<=final_byte_came_in;
			controller_state_now<=59;
		end
		59:begin // cmd 9 responce --> card_csd_content (Byte 9)
			chip_select_next<=0;
			card_csd_content[ 79: 72]<=final_byte_came_in;
			controller_state_now<=60;
		end
		60:begin // cmd 9 responce --> card_csd_content (Byte 8)
			chip_select_next<=0;
			card_csd_content[ 71: 64]<=final_byte_came_in;
			controller_state_now<=61;
		end
		61:begin // cmd 9 responce --> card_csd_content (Byte 7)
			chip_select_next<=0;
			card_csd_content[ 63: 56]<=final_byte_came_in;
			controller_state_now<=62;
		end
		62:begin // cmd 9 responce --> card_csd_content (Byte 6)
			chip_select_next<=0;
			card_csd_content[ 55: 48]<=final_byte_came_in;
			controller_state_now<=63;
		end
		63:begin // cmd 9 responce --> card_csd_content (Byte 5)
			chip_select_next<=0;
			card_csd_content[ 47: 40]<=final_byte_came_in;
			controller_state_now<=64;
		end
		64:begin // cmd 9 responce --> card_csd_content (Byte 4)
			chip_select_next<=0;
			card_csd_content[ 39: 32]<=final_byte_came_in;
			controller_state_now<=65;
		end
		65:begin // cmd 9 responce --> card_csd_content (Byte 3)
			chip_select_next<=0;
			card_csd_content[ 31: 24]<=final_byte_came_in;
			controller_state_now<=66;
		end
		66:begin // cmd 9 responce --> card_csd_content (Byte 2)
			chip_select_next<=0;
			card_csd_content[ 23: 16]<=final_byte_came_in;
			controller_state_now<=67;
		end
		67:begin // cmd 9 responce --> card_csd_content (Byte 1)
			chip_select_next<=0;
			card_csd_content[ 15:  8]<=final_byte_came_in;
			controller_state_now<=68;
		end
		68:begin // cmd 9 responce --> card_csd_content (Byte 0)
			chip_select_next<=0;
			card_csd_content[  7:  0]<=final_byte_came_in;
			controller_state_now<=69;
		end
		69:begin // cmd 9 responce (crc16 byte 0, unchecked because clock speed is still low so it's not really needed)
			chip_select_next<=0;
			controller_state_now<=70;
		end
		70:begin // cmd 9 responce (crc16 byte 1, unchecked because clock speed is still low so it's not really needed)
			chip_select_next<=0;
			controller_state_now<=71;
		end
		71:begin // using cmd 9 responce, calculate the number of blocks on the card (512bit blocks)
			highest_block_address<=calculated_highest_block_address_result;
			controller_state_now<=72;
		end
		72:begin // increase clock speed
			clk_speed_is_fast<=1;
			controller_state_now<=73;
		end
		73:begin // write word 1 of highest block size into mmio contents
			address_controller_at_mmio<=12'b0000_00001001;
			data_write_controller_at_mmio<=highest_block_address[31:16];
			write_enable_controller_at_mmio<=1;
			controller_state_now<=74;
		end
		74:begin // write word 0 of highest block size into mmio contents
			address_controller_at_mmio<=12'b0000_00001001;
			data_write_controller_at_mmio<=highest_block_address[15: 0];
			write_enable_controller_at_mmio<=1;
			controller_state_now<=75;
		end
		75:begin // clear error value
			address_controller_at_mmio<=12'b0000_00000011;
			data_write_controller_at_mmio<=0;
			write_enable_controller_at_mmio<=1;
			controller_state_now<=76;
		end
		76:begin // detect command request status after reset
			address_controller_at_mmio<=12'b0000_00000001;
			controller_state_now<=77;
		end
		77:begin // branch based on command request status after reset
			write_enable_controller_at_mmio<=1;
			address_controller_at_mmio<=12'b0000_00000010;
			if (data_read_controller_at_mmio[0]) begin
				// a command was in progress when the controller reset
				// Indicate that the command may not have been completed and request that the CPU acknowledge that by stopping the request
				data_write_controller_at_mmio<=3'b110;
				controller_state_now<=78;
			end else begin
				// no command was being executed when the controller reset. Go to idle state
				data_write_controller_at_mmio<=3'b100;
				controller_state_now<=80;
			end
		end
		78:begin // start detection of if acknowledgment is known
			address_controller_at_mmio<=12'b0000_00000001;
			controller_state_now<=79;
		end
		79:begin // wait until acknowledged
			if (!data_read_controller_at_mmio[0]) controller_state_now<=80;
		end
		80:begin // set to idle
			write_enable_controller_at_mmio<=1;
			address_controller_at_mmio<=12'b0000_00000010;
			data_write_controller_at_mmio<=3'b100;
			controller_state_now<=81;
		end
		81:begin // start detection of if command is being requested
			address_controller_at_mmio<=12'b0000_00000001;
			controller_state_now<=82;
		end
		82:begin // wait for command request in idle state
			if (data_read_controller_at_mmio[0]) begin
				write_enable_controller_at_mmio<=1;
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b001;
				controller_state_now<=83;
			end
		end
		83:begin // read command request (clear previous errors)
			address_controller_at_mmio<=12'b0000_00000011;
			data_write_controller_at_mmio<=0;
			write_enable_controller_at_mmio<=1;
			controller_state_now<=84;
		end
		84:begin // read command request (start reading command)
			address_controller_at_mmio<=12'b0000_00000000;
			controller_state_now<=85;
		end
		85:begin // read command request (is write command)
			address_controller_at_mmio<=12'b0000_00000111;
			is_command_write<=data_read_controller_at_mmio[0];
			controller_state_now<=86;
		end
		86:begin // read command request (base target address word 1)
			address_controller_at_mmio<=12'b0000_00000110;
			target_base_block_address[31:16]<=data_read_controller_at_mmio;
			controller_state_now<=87;
		end
		87:begin // read command request (base target address word 0)
			address_controller_at_mmio<=12'b0000_00000100;
			target_base_block_address[15: 0]<=data_read_controller_at_mmio;
			controller_state_now<=88;
		end
		88:begin // read command request (transfer section list word 0)
			address_controller_at_mmio<=12'b0000_00000101;
			transfer_section_list[15: 0]<=data_read_controller_at_mmio;
			controller_state_now<=89;
		end
		89:begin // read command request (transfer section list word 1). And branch to command type
			write_enable_controller_at_mmio<=1;
			address_controller_at_mmio<=12'b0000_00000010;
			data_write_controller_at_mmio<=3'b010;
			
			transfer_section_list[31:16]<=data_read_controller_at_mmio;
			if (transfer_section_list[3:0]==4'h0) begin
				// do a check status on the sd/mmc card
				controller_state_now<=90;
			end else if (is_command_write) begin
				// do a write command
				controller_state_now<=114;
			end else begin
				// do a read command
				controller_state_now<=120;
			end
		end
		90:begin // send cmd 13 (send status)
			command_id<=13;
			command_arg<=0;
			controller_state_after_command_sent<=91;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		91:begin // recieve cmd 13 responce (byte 0)
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, could not communicate with card
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=92;
					general_use_counter<=0;
				end else begin
					// error of some sort, try once again
					controller_state_now<=93;
				end
			end
		end
		92:begin // recieve cmd 13 responce (byte 1)
			chip_select_next<=0;
			if (final_byte_came_in==8'h00) begin
				controller_state_now<=97;
			end else begin
				// error of some sort, try once again
				controller_state_now<=93;
			end
		end
		93:begin // wait one byte then resend cmd 13
			controller_state_now<=94;
		end
		94:begin // re-send cmd 13 (send status)
			command_id<=13;
			command_arg<=0;
			controller_state_after_command_sent<=95;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		95:begin // recieve cmd 13 responce (byte 0)
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, could not communicate with card
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=96;
					general_use_counter<=0;
				end else begin
					// error of some sort, either could not communicate with card or it isn't initialized (which would mean it was taken out and another inserted)
					controller_state_now<=39;
				end
			end
		end
		96:begin // recieve cmd 13 responce (byte 1)
			chip_select_next<=0;
			if (final_byte_came_in==8'h00) begin
				controller_state_now<=97;
			end else begin
				// error of some sort, either could not communicate with card or it isn't initialized (which would mean it was taken out and another inserted)
				controller_state_now<=39;
			end
		end
		97:begin // sending cmd 13 yielded a successful responce
			write_enable_controller_at_mmio<=1;
			address_controller_at_mmio<=12'b0000_00000010;
			data_write_controller_at_mmio<=3'b011;
			controller_state_now<=78;
		end
		/* 98<->99 are left blank in case I want to add something later */
		100:begin // write block subroutine (enter state, does not send command)
			chip_select_next<=0;
			final_byte_going_out<=8'hFE;
			general_use_counter<=0;
			controller_state_now<=101;
			address_controller_at_mmio<=0;
			walking_crc16_register<=0;
			crc_byte<=0;
			address_controller_at_mmio[11:8]<=transfer_section_list[ 3: 0];
			transfer_section_list[ 3: 0]<=transfer_section_list[ 7: 4];
			transfer_section_list[ 7: 4]<=transfer_section_list[11: 8];
			transfer_section_list[11: 8]<=transfer_section_list[15:12];
			transfer_section_list[15:12]<=transfer_section_list[19:16];
			transfer_section_list[19:16]<=transfer_section_list[23:20];
			transfer_section_list[23:20]<=transfer_section_list[27:24];
			transfer_section_list[27:24]<=transfer_section_list[31:28];
			transfer_section_list[31:28]<=0;
		end
		101:begin // write block subroutine (even byte)
			chip_select_next<=0;
			final_byte_going_out<=data_read_controller_at_mmio[ 7:0];
			crc_byte<=data_read_controller_at_mmio[ 7:0];
			walking_crc16_register<=walking_crc16_output;
			controller_state_now<=102;
		end
		102:begin // write block subroutine (odd  byte)
			chip_select_next<=0;
			final_byte_going_out<=data_read_controller_at_mmio[15:8];
			crc_byte<=data_read_controller_at_mmio[15:8];
			walking_crc16_register<=walking_crc16_output;
			general_use_counter<=general_use_counter+1'b1;
			address_controller_at_mmio[7:0]<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				controller_state_now<=103;
			end else begin
				controller_state_now<=101;
			end
		end
		103:begin // send crc16 byte 1
			general_use_counter<=0;
			chip_select_next<=0;
			final_byte_going_out<=walking_crc16_output[15:8];
			controller_state_now<=104;
		end
		104:begin // send crc16 byte 0
			chip_select_next<=0;
			final_byte_going_out<=walking_crc16_output[ 7:0];
			controller_state_now<=105;
		end
		105:begin // delay for data responce
			chip_select_next<=0;
			controller_state_now<=106;
		end
		106:begin // store write data responce
			chip_select_next<=0;
			storage_write_responce[2:0]<=final_byte_came_in[3:1];
			storage_write_responce[3]<=(!final_byte_came_in[4] && final_byte_came_in[0])?1'b1:1'b0;
			controller_state_now<=107;
		end
		107:begin // wait for busy clear
			chip_select_next<=0;
			if (final_byte_came_in==8'hFF) controller_state_now<=108;
		end
		108:begin // send cmd 13 (send status)
			command_id<=13;
			command_arg<=0;
			controller_state_after_command_sent<=109;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		109:begin // recieve cmd 13 responce (byte 0)
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, could not communicate with card
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				storage_bad_status<=(final_byte_came_in!=8'h00)?1'b1:1'b0;
				controller_state_now<=110;
			end
		end
		110:begin // recieve cmd 13 responce (byte 1) and detect write successfulness
			chip_select_next<=0;
			if (storage_write_responce==4'b1101) begin // write rejected due to crc error
				controller_state_now<=111;
			end else if (storage_write_responce==4'b1010 && !(storage_bad_status | ((final_byte_came_in!=8'h00)?1'b1:1'b0))) begin // write accepted and responce valid
				controller_state_now<=112;
			end else begin // then either there was a write error (4'b1110) or the responce is invalid. Those cases are treated the same
				controller_state_now<=111;
			end
		end
		111:begin // signal failure to write in error value
			address_controller_at_mmio<=12'b0000_00000011;
			data_write_controller_at_mmio<=16'b1;
			write_enable_controller_at_mmio<=1;
			controller_state_now<=113;
		end
		112:begin // signal success to write in error value
			address_controller_at_mmio<=12'b0000_00000011;
			data_write_controller_at_mmio<=16'b0;
			write_enable_controller_at_mmio<=1;
			controller_state_now<=113;
			if (transfer_section_list[ 3: 0]!=4'h0) begin
				target_base_block_address<=target_base_block_address+1'b1;
				controller_state_now<=114; // then start another write at the next address
			end
		end
		113:begin // signal write command finished
			address_controller_at_mmio<=12'b0000_00000010;
			data_write_controller_at_mmio<=3'b011;
			write_enable_controller_at_mmio<=1;
			controller_state_now<=78;
		end
		114:begin // send write command
			command_id<=24;
			command_arg<=is_sd_card_byte_address?{target_base_block_address[22:0],9'b0}:target_base_block_address;
			controller_state_after_command_sent<=115;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		115:begin // recieve write command responce
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, could not communicate with card
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=116;
					general_use_counter<=0;
				end else begin
					// error of some sort, failure to write
					controller_state_now<=111;
				end
			end
		end
		116:begin // delay before start to write
			controller_state_now<=100;
		end
		/* 117<->119 are left blank in case I want to add something later */
		120:begin // send read command
			command_id<=17;
			command_arg<=is_sd_card_byte_address?{target_base_block_address[22:0],9'b0}:target_base_block_address;
			controller_state_after_command_sent<=121;
			controller_state_now<=2;
			general_use_counter<=0;
		end
		121:begin
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, could not communicate with card
				controller_state_now<=39;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=122;
				end else begin
					// error of some sort, failure to read
					controller_state_now<=128;
				end
			end
		end
		122:begin // wait until data start token
			chip_select_next<=0;
			if (final_byte_came_in==8'hFF) begin
				// still waiting... but since the potential delay is so long I can't put in a timeout
			end else if (final_byte_came_in==8'hFE) begin
				// got data start token
				controller_state_now<=123;
				address_controller_at_mmio<=0;
				walking_crc16_register<=0;
				crc_byte<=0;
				general_use_counter<=0;
				address_controller_at_mmio[11:8]<=transfer_section_list[ 3: 0];
				transfer_section_list[ 3: 0]<=transfer_section_list[ 7: 4];
				transfer_section_list[ 7: 4]<=transfer_section_list[11: 8];
				transfer_section_list[11: 8]<=transfer_section_list[15:12];
				transfer_section_list[15:12]<=transfer_section_list[19:16];
				transfer_section_list[19:16]<=transfer_section_list[23:20];
				transfer_section_list[23:20]<=transfer_section_list[27:24];
				transfer_section_list[27:24]<=transfer_section_list[31:28];
				transfer_section_list[31:28]<=0;
			end else begin
				controller_state_now<=39; // that's not the data start token or busy token, so it is invalid
			end
		end
		123:begin // read block subroutine (even byte)
			chip_select_next<=0;
			crc_byte<=final_byte_came_in;
			walking_crc16_register<=walking_crc16_output;
			controller_state_now<=124;
		end
		124:begin // read block subroutine (odd  byte)
			chip_select_next<=0;
			crc_byte<=final_byte_came_in;
			walking_crc16_register<=walking_crc16_output;
			general_use_counter<=general_use_counter+1'b1;
			address_controller_at_mmio[7:0]<=general_use_counter;
			data_write_controller_at_mmio<={final_byte_came_in,crc_byte};
			write_enable_controller_at_mmio<=1;
			if (general_use_counter==8'hFF) begin
				controller_state_now<=125;
			end else begin
				controller_state_now<=123;
			end
		end
		125:begin // read crc16 byte 1
			chip_select_next<=0;
			storage_bad_status<=(walking_crc16_output[15:8]!=final_byte_came_in)?1'b1:1'b0;
			controller_state_now<=126;
		end
		126:begin // read crc16 byte 0
			chip_select_next<=0; // cs probably not needed
			storage_bad_status<=storage_bad_status || (walking_crc16_output[7:0]!=final_byte_came_in)?1'b1:1'b0;
			controller_state_now<=127;
		end
		127:begin // decide read success
			if (storage_bad_status) begin
				controller_state_now<=128;
			end else begin
				controller_state_now<=129;
			end
		end
		128:begin // signal failure to read in error value
			address_controller_at_mmio<=12'b0000_00000011;
			data_write_controller_at_mmio<=16'b1;
			write_enable_controller_at_mmio<=1;
			controller_state_now<=130;
		end
		129:begin // signal success to read in error value
			address_controller_at_mmio<=12'b0000_00000011;
			data_write_controller_at_mmio<=16'b0;
			write_enable_controller_at_mmio<=1;
			controller_state_now<=130;
			target_base_block_address<=target_base_block_address+1'b1;
			if (transfer_section_list[ 3: 0]!=4'h0) begin
				controller_state_now<=120; // then start another read at the next address
			end
		end
		130:begin // signal read command finished
			address_controller_at_mmio<=12'b0000_00000010;
			data_write_controller_at_mmio<=3'b011;
			write_enable_controller_at_mmio<=1;
			controller_state_now<=78;
		end
		endcase
	end
end


crc7_byte crc7_byte_inst(
	walking_crc7_output,
	walking_crc7_register,
	crc_byte
);

crc16_byte crc16_byte_inst(
	walking_crc16_output,
	walking_crc16_register,
	crc_byte
);

sd_card_mmio sd_card_mmio_inst( // this memory has registered outputs, which is different from most other ip memory
	.address_a(address_mmio[12:1]),
	.address_b(address_controller_at_mmio),
	.byteena_a({(is_mmio_byte?address_mmio[0]:1'b1),(is_mmio_byte?!address_mmio[0]:1'b1)}),
	.clock(main_clk),
	.data_a(data_write_mmio),
	.data_b(data_write_controller_at_mmio),
	.wren_a(is_mmio_write),
	.wren_b(write_enable_controller_at_mmio),
	.q_a(data_read_mmio),
	.q_b(data_read_controller_at_mmio)
);

endmodule
