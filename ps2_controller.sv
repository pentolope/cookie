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
	input  main_clk // 83 MHz
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
	The buffer size from host to the device is a size of 1.
	The buffer size from device to the host is a size of 1024.
	
	Reading from memory location `addr[000]` will yield the first unread byte that was sent by the ps2 device.
		Do not read `addr[000]` when `addr[010]==0`, the data returned is undefined.
		
	Writing  to  memory location `addr[000]` will indicate that the first unread byte sent from the ps2 device has now been read. The data for the write is ignored.
		Do not write to `addr[000]` when `addr[010]==0`
	
	Writing  to  memory location `addr[001]` will queue the byte value being written to be sent to the ps2 device.
		Do not write to `addr[001]` when `addr[011]==1`
	
	Reading from memory location `addr[010]` will yield a 0 or 1 that represents if the ps2 device has sent data that remains unread by the host.
	
	Reading from memory location `addr[011]` will yield a 0 or 1 that represents if a byte has been queued to send to the ps2 device.
	
	Reading from memory location `addr[100]` will yield a 0 or 1. This represents if the first unread byte from the device was transmitted with an incorrect parity ( 1==invalid parity , 0==valid parity ).

	Reading from memory location `addr[110]` will yield a 0 or 1. This represents if a byte from the ps2 device has been dropped due to buffer overflow ( 1==yes , 0==no ).
		The maxiumum buffer size is 1024 bytes. After the buffer is full, the controller will drop any other bytes that are sent.
		If a byte is dropped in this way, the controller will effectively set `addr[110]` to 1 (`addr[110]` is typically 0).
	
	Writing  to  memory location `addr[110]` will reset the "has byte been dropped" flag that is held in `addr[110]` to 0. The data for the write is ignored.
	
	Reading from memory location `addr[111]` will yield a 0 or 1. This represents if a transmission error has occured when sending or recieving data ( 1==yes , 0==no ).
	
	Writing  to  memory location `addr[111]` will reset the "has transmission error occured" flag that is held in `addr[111]` to 0. The data for the write is ignored.
	
	Reading from any memory location not listed here will yield undefined data.
	Writing  to  any memory location not listed here will be ignored.
		However, I would think that code clarity and efficiency reasons would be enough to never read or write to a memory location that is not listed here.
	
	The ps2 interface does not provide an easy way to determine if a device is actually connected. So this controller does not provide an easy way either.
	If a byte is queued to send to the device and it never gets sent, then there is no device present.
	
	A minimal procedure for reading bytes into `data` might be something like this (just make sure to handle if a byte was dropped, don't ignore it):
		while (`addr[010]!=0`){
			data[count++]=`addr[000]`;
			`addr[000]`=0;
		}
		bool did_drop_bytes=`addr[110]`;
		if (did_drop_bytes){
			`addr[110]`=0;
		}
		
	
	A minimal procedure for writing `count` bytes in `data` might be something like:
		for (int i=0;i<count;i++){
			while (`addr[011]`!=0){
			}
			`addr[001]`=data[i];
		}
	
*/


reg [6:0] microsecond_counter=0;
reg microsecond_tick=0; // length of one main_clk pulse every 1 microsecond

always @(posedge main_clk) begin
	microsecond_counter<=microsecond_counter+1'b1;
	microsecond_tick<=0;
	if (microsecond_counter==7'd61) begin//82
		microsecond_tick<=1;
		microsecond_counter<=0;
	end
end

reg external_clock_pulldown_r=0;
reg external_data_pulldown_r=0; // due to how the pulldown works, the data should be inverted when writing through this
assign external_clock_pulldown=external_clock_pulldown_r;
assign external_data_pulldown=external_data_pulldown_r;
reg external_clock_in_r=0;
reg external_data_in_r=0;
always @(posedge main_clk) external_clock_in_r<=external_clock_in;
always @(posedge main_clk) external_data_in_r<=external_data_in;


reg has_byte_to_send_to_device=0;

reg [8:0] read_byte=0; // includes if parity was correct at bit 8
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
	new_byte_from_device<=0;  // this is so that new_byte_from_device  is a single main_clk pulse
	sent_a_byte_to_device<=0; // this is so that sent_a_byte_to_device is a single main_clk pulse
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
					device_interop_bit_index<=0;
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
					read_byte[8]<=0;
					if ((!(read_byte[0]^read_byte[1]^read_byte[2]^read_byte[3]^read_byte[4]^read_byte[5]^read_byte[6]^read_byte[7]))!=external_data_in_r) begin
						read_byte[8]<=1; // parity check failed
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
			timeout_counter<=9'h1FF;// maxiumum delay is too long to have a timeout. Hot plugging a ps2 device is wrong anyway, so don't do that in the first place.
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

memory mapped interconnection is below
*/

reg [2:0] address_mmio_r=0;
reg is_mmio_write_r=0;
reg [7:0] data_write_mmio_r=0;
reg [7:0] data_read_mmio_r;

wire fifo_full;
wire fifo_empty;

assign data_read_mmio=data_read_mmio_r;
reg byte_read_by_host=0;
reg has_dropped_byte=0;

wire [8:0] first_unread_byte; // includes if parity was correct at bit 8
wire [3:0] case_val;
assign case_val={is_mmio_write_r,address_mmio_r};



always @(posedge main_clk) begin
	address_mmio_r<=address_mmio;
	is_mmio_write_r<=is_mmio_write && !is_mmio_write_r; // the `&& !is_mmio_write_r` part should be unnecessary
	data_write_mmio_r<=data_write_mmio;
	clear_had_transmit_error<=0;
	byte_read_by_host<=0;

	if (fifo_full && new_byte_from_device) begin
		has_dropped_byte<=1;
	end
	if (sent_a_byte_to_device) begin
		has_byte_to_send_to_device<=0;
	end
	data_read_mmio_r<=8'hFF; // could be made undefined
	if (case_val==4'b0000) begin
		data_read_mmio_r<=fifo_empty? 8'hED :first_unread_byte[7:0]; // ternary not needed
	end else if (case_val==4'b0010) begin
		data_read_mmio_r<=!fifo_empty;
	end else if (case_val==4'b0011) begin
		data_read_mmio_r<=has_byte_to_send_to_device;
	end else if (case_val==4'b0100) begin
		data_read_mmio_r<=first_unread_byte[8];
	end else if (case_val==4'b0110) begin
		data_read_mmio_r<=has_dropped_byte;
	end else if (case_val==4'b0111) begin
		data_read_mmio_r<=had_transmit_error;
	end else if (case_val==4'b1000) begin
		byte_read_by_host<=1;
	end else if (case_val==4'b1001) begin
		write_byte<=data_write_mmio_r;
		has_byte_to_send_to_device<=1;
	end else if (case_val==4'b1110) begin
		has_dropped_byte<=0;
	end else if (case_val==4'b1111) begin
		clear_had_transmit_error<=1;
	end
	
/*
	case ({is_mmio_write_r,address_mmio_r}) // don't make this unique
	4'b0000:data_read_mmio_r<=fifo_empty? 8'hED :first_unread_byte[7:0]; // ternary not needed
	4'b0010:data_read_mmio_r<=!fifo_empty;
	4'b0011:data_read_mmio_r<=has_byte_to_send_to_device;
	4'b0100:data_read_mmio_r<=first_unread_byte[8];
	4'b0110:data_read_mmio_r<=has_dropped_byte;
	4'b0111:data_read_mmio_r<=had_transmit_error;
	4'b1000:byte_read_by_host<=1;
	4'b1001:begin write_byte<=data_write_mmio_r;has_byte_to_send_to_device<=1;end
	4'b1110:has_dropped_byte<=0;
	4'b1111:clear_had_transmit_error<=1;
	default:begin end
	endcase
*/
end

ip_ps2_buffer ip_ps2_buffer_inst(
	.clock(main_clk),
	.data(read_byte),
	.rdreq(byte_read_by_host && !fifo_empty),
	.wrreq(new_byte_from_device && !fifo_full),
	.empty(fifo_empty),
	.full(fifo_full),
	.q(first_unread_byte)
);


endmodule
