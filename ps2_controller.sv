`timescale 1 ps / 1 ps

module ps2_controller(
	output external_clock_pulldown,
	output external_data_pulldown,
	input external_clock_in,
	input external_data_in,
	
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
		bool did_drop_bytes=`addr[110]`;
		if (did_drop_bytes){
			`addr[110]`=0;
		}
		
	
	A minimal procedure for writing `count` bytes in `data` might be something like (it's performance could be improved with the assumption that `addr[011]` will only increase by 1 when 1 byte is written):
		for (int i=0;i<count;i++){
			while (`addr[011]`==255){
			}
			`addr[001]`=data[i];
		}
	
*/


// TODO: lots of things...


reg [6:0] microsecond_counter=0;
reg microsecond_tick=0; // length of one 90MHz pulse every 1 microsecond

always @(posedge main_clk) begin
	microsecond_counter<=microsecond_counter+1'b1;
	microsecond_tick<=0;
	if (microsecond_counter==7'd89) begin
		microsecond_tick<=1;
		microsecond_counter<=0;
	end
end

reg external_clock_pulldown_r=0;
reg external_data_pulldown_r=0; // due to how the pulldown works, the data should be inverted when writting through this
assign external_clock_pulldown=external_clock_pulldown_r;
assign external_data_pulldown=external_data_pulldown_r;
reg external_clock_in_r=0;
reg external_data_in_r=0;
always @(posedge main_clk) external_clock_in_r<=external_clock_in;
always @(posedge main_clk) external_data_in_r<=external_data_in;


wire has_byte_to_send_to_device;

reg [7:0] read_byte=0;
reg [7:0] write_byte=0;
reg [3:0] state_device_interop=0; // this state machine is updated every microsecond and it interacts with the device
reg [3:0] device_interop_bit_index=0;
reg new_byte_from_device=0;
reg sent_a_byte_to_device=0;
reg [8:0] host_clock_inhibit_cooldown=0;
reg [3:0] data_change_cooldown=0;
reg [8:0] timeout_counter=9'h1FF;
reg had_transmit_error=0;
reg clear_had_transmit_error=0;

always @(posedge main_clk) begin
	new_byte_from_device<=0;  // this is so that new_byte_from_device  is a single 90MHz pulse
	sent_a_byte_to_device<=0; // this is so that sent_a_byte_to_device is a single 90MHz pulse
	if (clear_had_transmit_error) begin
		had_transmit_error<=0;
	end
	if (microsecond_tick) begin
		timeout_counter<=timeout_counter-1'b1;
		unique case (state_device_interop)
		0:begin // waiting for clock to go high, no data being transfered
			if (data_change_cooldown==4'd0) begin
				if (external_clock_in_r) begin
					state_device_interop<=1;
					timeout_counter<=9'h1FF;
				end
			end else if (data_change_cooldown==4'd1) begin
				data_change_cooldown<=0;
				if (external_clock_in_r) begin
					had_transmit_error<=1; // clock changed too fast
				end
				if (!external_data_in_r) begin
					state_device_interop<=2;
					timeout_counter<=9'h1FF;
				end
			end else begin
				data_change_cooldown<=data_change_cooldown-1'b1;
				if (external_clock_in_r) begin
					had_transmit_error<=1; // clock changed too fast
				end
			end
			if (timeout_counter==9'd0) begin
				state_device_interop<=1;
				external_clock_pulldown_r<=0;
				external_data_pulldown_r<=0;
				had_transmit_error<=1; // timeout
				timeout_counter<=9'h1FF;
			end
		end
		1:begin // waiting for clock to go low, no data being transfered
			if (has_byte_to_send_to_device) begin
				// It is important that this case takes priority over `!external_clock_in_r` case.
				// The reason is because of the possibility of timing out during host->device transmission as the device starts generating a clock for the host->device transmission.
				host_clock_inhibit_cooldown<=500;
				external_clock_pulldown_r<=1;
				state_device_interop<=5;
				timeout_counter<=9'h1FF;
			end else if (!external_clock_in_r) begin
				state_device_interop<=0;
				data_change_cooldown<=15;
			end
			timeout_counter<=9'h1FF; // cannot timeout
		end
		2:begin // waiting for clock to go high, data is being transfered from device
			if (data_change_cooldown==4'd0) begin
				if (external_clock_in_r) begin
					timeout_counter<=9'h1FF;
					state_device_interop<=3;
					if (device_interop_bit_index==4'd10) state_device_interop<=4;
				end
			end else if (data_change_cooldown==4'd1) begin
				data_change_cooldown<=0;
				device_interop_bit_index<=device_interop_bit_index+1'b1;
				unique case (device_interop_bit_index)
				0:read_byte[0]<=external_data_in_r;
				1:read_byte[1]<=external_data_in_r;
				2:read_byte[2]<=external_data_in_r;
				3:read_byte[3]<=external_data_in_r;
				4:read_byte[4]<=external_data_in_r;
				5:read_byte[5]<=external_data_in_r;
				6:read_byte[6]<=external_data_in_r;
				7:read_byte[7]<=external_data_in_r;
				8:begin
					if ((!(read_byte[0]^read_byte[1]^read_byte[2]^read_byte[3]^read_byte[4]^read_byte[5]^read_byte[6]^read_byte[7]))!=external_data_in_r) begin
						had_transmit_error<=1; // parity check failed
					end
				end
				9:begin
					if (!external_data_in_r) begin
						had_transmit_error<=1; // stop bit wrong
					end
				end
				endcase
				if (external_clock_in_r) begin
					had_transmit_error<=1; // clock changed too fast
				end
			end else begin
				data_change_cooldown<=data_change_cooldown-1'b1;
				if (external_clock_in_r) begin
					had_transmit_error<=1; // clock changed too fast
				end
			end
			if (timeout_counter==9'd0) begin
				state_device_interop<=1;
				external_clock_pulldown_r<=0;
				external_data_pulldown_r<=0;
				had_transmit_error<=1; // timeout
				timeout_counter<=9'h1FF;
			end
		end
		3:begin // waiting for clock to go low, data is being transfered from device
			if (!external_clock_in_r) begin
				state_device_interop<=2;
				timeout_counter<=9'h1FF;
				data_change_cooldown<=15;
			end
			if (timeout_counter==9'd0) begin
				state_device_interop<=1;
				external_clock_pulldown_r<=0;
				external_data_pulldown_r<=0;
				had_transmit_error<=1; // timeout
				timeout_counter<=9'h1FF;
			end
		end
		4:begin // after device->host transmission, notify the host controller about the new byte
			device_interop_bit_index<=0;
			new_byte_from_device<=1;
			state_device_interop<=1;
			timeout_counter<=9'h1FF;
		end
		5:begin // continue using clock inhibit for about 500 microseconds to start host->device transmission, and pull data line down for about the last 30 microseconds
			host_clock_inhibit_cooldown<=host_clock_inhibit_cooldown-1'b1;
			if (host_clock_inhibit_cooldown==9'd30) begin
				external_data_pulldown_r<=1;
			end
			if (host_clock_inhibit_cooldown==9'd0) begin
				state_device_interop<=6;
				timeout_counter<=9'h1FF;
				external_clock_pulldown_r<=0;
				host_clock_inhibit_cooldown<=0;
			end
			// couldn't timeout on this state, progression is controlled internally
		end
		6:begin // delay state to help ensure that the clock has had time to rise from being pulled down
			timeout_counter<=9'h1FF;
			if (external_clock_in_r) state_device_interop<=7;
			// this stage wouldn't make much sense to time out in
		end
		7:begin // wait for clock to be generated (go from high->low) by device for host->device transmission
			if (!external_clock_in_r) begin
				state_device_interop<=8;
				data_change_cooldown<=15;
				device_interop_bit_index<=0;
			end
			if (timeout_counter==9'd0) begin // technically, I think this timeout might be too short. But I think it should work, because it would just abort transmission and then retry.
				state_device_interop<=1;
				external_clock_pulldown_r<=0;
				external_data_pulldown_r<=0;
				had_transmit_error<=1; // timeout
				timeout_counter<=9'h1FF;
			end
		end
		8:begin
			if (data_change_cooldown==4'd0) begin
				if (external_clock_in_r) begin
					timeout_counter<=9'h1FF;
					state_device_interop<=9;
					if (device_interop_bit_index==4'd11) state_device_interop<=10;
				end
			end else if (data_change_cooldown==4'd1) begin
				data_change_cooldown<=0;
				device_interop_bit_index<=device_interop_bit_index+1'b1;
				unique case (device_interop_bit_index)
				0:external_data_pulldown_r<=!write_byte[0];
				1:external_data_pulldown_r<=!write_byte[1];
				2:external_data_pulldown_r<=!write_byte[2];
				3:external_data_pulldown_r<=!write_byte[3];
				4:external_data_pulldown_r<=!write_byte[4];
				5:external_data_pulldown_r<=!write_byte[5];
				6:external_data_pulldown_r<=!write_byte[6];
				7:external_data_pulldown_r<=!write_byte[7];
				8:external_data_pulldown_r<=(write_byte[0]^write_byte[1]^write_byte[2]^write_byte[3]^write_byte[4]^write_byte[5]^write_byte[6]^write_byte[7]);
				9:external_data_pulldown_r<=0;
				10:begin
					external_data_pulldown_r<=0;
					if (external_data_in_r) begin
						had_transmit_error<=1; // no ack bit - therefore, retry transmission immediately
						host_clock_inhibit_cooldown<=500;
						external_clock_pulldown_r<=1;
						state_device_interop<=5;
						timeout_counter<=9'h1FF;
					end
				end
				endcase
				if (external_clock_in_r) begin
					had_transmit_error<=1; // clock changed too fast
				end
			end else begin
				data_change_cooldown<=data_change_cooldown-1'b1;
				if (external_clock_in_r) begin
					had_transmit_error<=1; // clock changed too fast
				end
			end
			if (timeout_counter==9'd0) begin
				state_device_interop<=1;
				external_clock_pulldown_r<=0;
				external_data_pulldown_r<=0;
				had_transmit_error<=1; // timeout
				timeout_counter<=9'h1FF;
			end
		end
		9:begin
			if (!external_clock_in_r) begin
				state_device_interop<=8;
				timeout_counter<=9'h1FF;
				data_change_cooldown<=15;
			end
			if (timeout_counter==9'd0) begin
				state_device_interop<=1;
				external_clock_pulldown_r<=0;
				external_data_pulldown_r<=0;
				had_transmit_error<=1; // timeout
				timeout_counter<=9'h1FF;
			end
		end
		10:begin // notify the host controller about a byte being sent to the device
			sent_a_byte_to_device<=1;
			state_device_interop<=11;
			external_clock_pulldown_r<=0;
			external_data_pulldown_r<=0;
		end
		11:begin // just chill out and do nothing for a microsecond or so, then go back to the waiting state
			state_device_interop<=1;
		end
		endcase
	end
end

/*
device transmission state machine is above

interconnect statemachine is below
*/





endmodule
