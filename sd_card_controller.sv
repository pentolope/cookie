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

	output [15:0] data_read_mmio,
	input  [15:0] data_write_mmio,
	input  [12:0] address_mmio,
	input  is_mmio_byte,
	input  is_mmio_write,
	input  main_clk // 90 MHz
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
		Changing the value from 1b->0b should only be done when `addr[0000_000000100]==011b` . It causes the controller to acknowledge the finalization handshake.
	
	The byte at `addr[0000_000000011]` should never be written. It has no purpose.
	
	The byte at `addr[0000_000000100]` should never be written. It will contain 000b, 001b, 010b, 011b, 100b or 101b.
		A 000b at this byte indicates that the controller is performing initialization. Do not modify any memory location.
		A 001b at this byte indicates that the controller has seen that there is a new command and is in the early stages of processing it. Do not write to any memory location that is associated with the command.
		A 010b at this byte indicates that the controller has fully read the command. Any value in `addr[0000_xxxxxxxxx]` area may be written with new values, with the exception of `addr[0000_00000001x]` and `addr[0000_00000011x]` .
			Any data sections associated with the command that was already given should not be modified.
		A 011b at this byte indicates that the controller has finished processing the command that it was given. The controller will wait until `addr[0000_000000010]==0b` , then it will set `addr[0000_000000100]==00b`
		A 100b at this byte indicates that the controller is currently not processing a command. Nearly any memory location can be written or read when this is the case.
		A 101b at this byte indicates that the controller could not establish communication with the sd card. There may not be a card, or the card isn't supported.
	
	The byte at `addr[0000_000000101]` should never be written. It has no purpose.
	
	The byte at `addr[0000_000000110]` contains the error value.
		It is written by the controller when `addr[0000_000000100]==010b` .
		It may be read or overwritten when `addr[0000_000000100]==100b` .
		A command that succeeds after a failing command will overwrite the error value to a 0b. Therefore, The error value should always be checked and handled after every command.
		A 000b at this byte indicates that no error occured and the command completed successfully.
		A 001b at this byte indicates that the command could not be executed because there is no sd card connected.
		A 010b at this byte indicates that the command could not be executed because the sd card initialization failed.
		A 011b at this byte indicates that an unknown error occured and it is unknown if the command succeeded.
		A 100b at this byte indicates that the command could not execute because the target block address is out of range.
		A 101b at this byte indicates that the command contained no data sections to read/write, so nothing would be performed by the command.
		All other values for this byte are reserved for future use.
		
	The byte at `addr[0000_000000111]` should never be written. It has no purpose.
	
	The double word at `addr[0000_0000010xx]` contains a list of data sections that are included with the read/write command.
		The list contains 4bit items and is 0 terminated.
		For example, `addr[0000_000001000]==0000_0010b` would indicate an access of length 1 where data section 2 would be read or written (depending on `addr[0000_000000000]` value)
		For example, `addr[0000_000001000]==0101_0010b` and `addr[0000_000001000]==xxxx_0001b` would indicate an access of length 3 where data sections 2,5,1 (in that order) would be read or written (depending on `addr[0000_000000000]` value)
		Each data section should only be mentioned in the list once.
	
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


reg [8:0] clk_div_factor=450; // the actual division factor is twice the value stored in clk_div_factor, because the sd card's clock flips (0->1 or 1->0) when clk_counter>=clk_div_factor.
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

wire [6:0] walking_crc7_output;
reg [6:0] walking_crc7_register=0;
wire [15:0] walking_crc16_output;
reg [15:0] walking_crc16_register=0;
reg [7:0] crc_byte=0; // both crc generators use the same byte. It is also used as a temporary storage byte when receiving a block from the sd card

reg is_sd_card_byte_address=0; // does the attached card use byte addresses
reg is_sd_card_mmc_card=0; // is the attached sd card actually an mmc card
reg delayed_init_check=0; // this is used once when doing an initialization check

reg [5:0] command_id=0;
reg [31:0] command_arg=0;

reg [7:0] general_use_counter=0;
reg [7:0] controller_state_now=0;
reg [7:0] controller_state_after_command_sent=0;
reg [7:0] controller_state_after_block_transmit=0;

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
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
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
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
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
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h01 || final_byte_came_in==8'h00) begin
					controller_state_now<=18;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					address_controller_at_mmio<=12'b0000_00000010;
					data_write_controller_at_mmio<=3'b101;
					write_enable_controller_at_mmio<=1;
					controller_state_now<=0;
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
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=21;
					general_use_counter<=0;
				end else if (final_byte_came_in==8'h01) begin
					controller_state_now<=20;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					address_controller_at_mmio<=12'b0000_00000010;
					data_write_controller_at_mmio<=3'b101;
					write_enable_controller_at_mmio<=1;
					controller_state_now<=0;
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
		22:begin // recieve responce for cmd 58 (byte 0)
			chip_select_next<=0;
			general_use_counter<=general_use_counter+1'b1;
			if (general_use_counter==8'hFF) begin
				// timeout, initialization fails
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=23;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					address_controller_at_mmio<=12'b0000_00000010;
					data_write_controller_at_mmio<=3'b101;
					write_enable_controller_at_mmio<=1;
					controller_state_now<=0;
				end
			end
		end
		23:begin // recieve responce for cmd 58 (byte 1)
			chip_select_next<=0;
			controller_state_now<=24;
			is_sd_card_byte_address<=!final_byte_came_in[6];
		end
		24:begin // recieve responce for cmd 58 (byte 2)
			chip_select_next<=0;
			controller_state_now<=25;
			delayed_init_check<=!(final_byte_came_in[5] & final_byte_came_in[4]);
		end
		25:begin // recieve responce for cmd 58 (byte 3)
			chip_select_next<=0;
			controller_state_now<=26;
		end
		26:begin // recieve responce for cmd 58 (byte 4)
			chip_select_next<=0;
			controller_state_now<=27;
		end
		27:begin // interpret responce for cmd 58
			if (delayed_init_check) begin
				// card doesn't support voltage range. initialization fails
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
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
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=30;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					address_controller_at_mmio<=12'b0000_00000010;
					data_write_controller_at_mmio<=3'b101;
					write_enable_controller_at_mmio<=1;
					controller_state_now<=0;
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
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=50; // initialization of the sd card (or mmc card) is complete
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					address_controller_at_mmio<=12'b0000_00000010;
					data_write_controller_at_mmio<=3'b101;
					write_enable_controller_at_mmio<=1;
					controller_state_now<=0;
				end
			end
		end
		/*  32<->39 is skipped in case I need to add something later that I want to put here */
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
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h01 || final_byte_came_in==8'h00) begin
					controller_state_now<=42;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					address_controller_at_mmio<=12'b0000_00000010;
					data_write_controller_at_mmio<=3'b101;
					write_enable_controller_at_mmio<=1;
					controller_state_now<=0;
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
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
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
				address_controller_at_mmio<=12'b0000_00000010;
				data_write_controller_at_mmio<=3'b101;
				write_enable_controller_at_mmio<=1;
				controller_state_now<=0;
			end else if (final_byte_came_in!=8'hFF) begin
				if (final_byte_came_in==8'h00) begin
					controller_state_now<=28; // initialization (likely) success, go set block size and enable crc
					general_use_counter<=0;
				end else if (final_byte_came_in==8'h01) begin
					controller_state_now<=49;
					general_use_counter<=0;
				end else begin
					// error of some sort, initialization fails
					address_controller_at_mmio<=12'b0000_00000010;
					data_write_controller_at_mmio<=3'b101;
					write_enable_controller_at_mmio<=1;
					controller_state_now<=0;
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
			// todo: determine physical size of card and write to mmio memory, then indicate that the controller is ready
			
		end
		endcase
	end
end

// TODO: some stuff...

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
