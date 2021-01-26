`timescale 1 ps / 1 ps

module ps2_controller(
	output [7:0] data_read_mmio,
	input  [7:0] data_write_mmio,
	input  [2:0] address_mmio,
	input  is_mmio_write,
	input  main_clk // 90 MHz
);

/*
Special considerations for ps2 controller:
	This memory will NOT behave like normal memory. See the access protocol.
	Only byte accesses should be used when accessing this controller.
	Word accesses are NOT ignored but are considered invalid.

Access protocol for ps2 controller:
	All memory addresses will be referenced in binary.
	All memory data will be referenced in decimal.
	All memory address values do not include the bits required to select the ps2 controller, because that is already assumed to be the case.
	All memory accesses mentioned here are byte accesses, because word accesses are invalid.
	
	This controller operates as 2 first in first out buffers, going to and from the device.
	
	Reading from memory location `addr[000]` will yield the first unread byte that was sent by the ps2 device.
		Do not read `addr[000]` when `addr[010]==0`, the data returned in undefined.
		
	Writing  to  memory location `addr[000]` will indicate that the first unread byte sent from the ps2 device has now been read. The data for the write is ignored.
		Do not write to `addr[000]` when `addr[010]==0`
	
	Writing  to  memory location `addr[001]` will queue the byte value being written to be sent to the ps2 device.
		Do not write to `addr[000]` when `addr[011]==255`
	
	Reading from memory location `addr[010]` will yield a byte that represents the number of bytes the ps2 device has sent that remain unread by the host.
	
	Reading from memory location `addr[011]` will yield a byte that represents the number of bytes the host has queued to send to the ps2 device.

	Reading from memory location `addr[100]` will yield a 0 or 1. This represents if a device is connected to the ps2 port ( 1==connected , 0==unconnected ).
		Performing any operation when no ps2 device is connected is silly, but still defined.
			Queued bytes are discarded (including any new bytes that would be queued).
			Bytes that remain unread can still be read normally.
			Obviously, no new bytes could be recieved without a ps2 device.
		The controller will correctly handle situations where the ps2 plug is connected or disconnected during operation.
			However, it should be noted that technically ps2 plugs are not physically designed to be connected or disconnected during operation, so I make no promises that the device or host circuitry won't be damaged by doing such a thing.
	
	Reading from memory location `addr[110]` will yield a 0 or 1. This represents if a byte from the ps2 device has been dropped due to buffer overflow ( 1==yes , 0==no ).
		The maxiumum buffer size is 255 bytes. After the buffer is full, the controller will drop any other bytes that are sent.
		If a byte is dropped in this way, the controller will effectively set `addr[110]` to 1 (`addr[110]` is typically 0).
	
	Writing  to  memory location `addr[110]` will reset the "has byte been dropped" flag that is held in `addr[110]` to 0. The data for the write is ignored.
	
	Reading from any memory location not listed here will yield undefined data.
	Writing  to  any memory location not listed here will be ignored.
		However, I would think that code clarity and efficiency reasons would be enough to never read or write to a memory location that is not listed here.
	
	
	A minimal procedure for reading bytes into `data` might be something like this (just make sure to handle if a byte was dropped, don't ignore it):
		while (`addr[010]!=0`){
			data[count++]=`addr[000]`;
			`addr[000]`=0;
		}
		bool dropped_byte=`addr[110]`;
		if (dropped_byte){
			`addr[110]`=0;
		}
		
	
	A minimal procedure for writing `count` bytes in `data` might be something like (it's performance could be improved with the assumption that `addr[011]` will only increase by 1 when 1 byte is written):
		for (int i=0;i<count;i++){
			while (`addr[011]`==255){
			}
			`addr[001]`=data[i];
		}
	
*/


// TODO: everything...


endmodule
