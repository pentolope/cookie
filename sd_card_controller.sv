`timescale 1 ps / 1 ps

module sd_card_controller(
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
	
	This controller does NOT support connecting or unconnecting an sd card during operation. { currently, I don't plan on dealing with that crazyness }
	Therefore, this controller assumes that if no card is present at startup, then there will never  be a card connected while the FPGA remains on.
	Therefore, this controller assumes that if a  card is present at startup, then there will always be a card connected while the FPGA remains on.
	
	This controller performs all of the initialization for the sd card. It also handles sending various other commands to the sd card to complete the commands that are given through it's command communication port with the CPU.
	Once the controller is finished initializing the sd card, the CPU can trigger read/write sector commands that this controller will perform.
	Currently, I plan on having the controller use only single sector read/write commands, and having it issue multiple commands for multiple sectors.
		There are some weird things with multiple sector read/write commands that I don't want to figure out right now.
	
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
	
	The byte at `addr[0000_000000100]` should never be written. It will contain 000b, 001b, 010b, 011b or 100b.
		A 000b at this byte indicates that the controller is performing initialization. Do not modify any memory location.
		A 001b at this byte indicates that the controller has seen that there is a new command and is in the early stages of processing it. Do not write to any memory location that is associated with the command.
		A 010b at this byte indicates that the controller has fully read the command. Any value in `addr[0000_xxxxxxxxx]` area may be written with new values, with the exception of `addr[0000_00000001x]` and `addr[0000_00000011x]` .
			Any data sections associated with the command that was already given should not be modified.
		A 011b at this byte indicates that the controller has finished processing the command that it was given. The controller will wait until `addr[0000_000000010]==0b` , then it will set `addr[0000_000000100]==00b`
		A 100b at this byte indicates that the controller is currently not processing a command. Nearly any memory location can be written or read when this is the case.
	
	The byte at `addr[0000_000000101]` should never be written. It has no purpose.
	
	The byte at `addr[0000_000000110]` contains the error value.
		It is written by the controller when `addr[0000_000000100]==010b` .
		It may be read or overwritten when `addr[0000_000000100]==100b` .
		A command that succeeds after a failing command will overwrite the error value to a 0b. Therefore, The error value should always be checked and handled after every command.
		A 000b at this byte indicates that no error occured and the command completed successfully.
		A 001b at this byte indicates that the command could not be executed because there is no sd card connected.
		A 010b at this byte indicates that the command could not be executed because the sd card initialization failed.
		A 011b at this byte indicates that an unknown error occured and it is unknown if the command succeeded.
		A 100b at this byte indicates that the command could not execute because the target sector address is out of range.
		A 101b at this byte indicates that the command contained no data sections to read/write, so nothing would be performed by the command.
		All other values for this byte are reserved for future use.
		
	The byte at `addr[0000_000000111]` should never be written. It has no purpose.
	
	The double word at `addr[0000_0000010xx]` contains a list of data sections that are included with the read/write command.
		The list contains 4bit items and is 0 terminated.
		For example, `addr[0000_000001000]==0000_0010b` would indicate an access of length 1 where data section 2 would be read or written (depending on `addr[0000_000000000]` value)
		For example, `addr[0000_000001000]==0101_0010b` and `addr[0000_000001000]==xxxx_0001b` would indicate an access of length 3 where data sections 2,5,1 (in that order) would be read or written (depending on `addr[0000_000000000]` value)
		Each data section should only be mentioned in the list once.
	
	The double word at `addr[0000_0000011xx]` contains the target sector address to read/write.
		The value is little endian.
		A change in the one's bit causes the adjacent sector to be read/written.
		This allows a range of values that can access 2 Terabytes. I don't think I am going to approach that limit.
	
	The double word at `addr[0000_0000100xx]` is the highest sector address which the sd card has.
	
*/

reg  [11:0] address_controller_at_mmio=0;
reg  [15:0] data_write_controller_at_mmio=0;
wire [15:0] data_read_controller_at_mmio;
reg  write_enable_controller_at_mmio=0;


// TODO: nearly everything...




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
