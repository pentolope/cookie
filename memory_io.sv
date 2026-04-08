`timescale 1 ps / 1 ps

`include "vga_driver.sv"
`include "sd_card_controller.sv"
`include "ps2_controller.sv"
`include "hardfloat_mmio.sv"

module stat_manager(
	output [15:0] data_out_io,
	input  [15:0] data_in_io_r,
	input  [31:0] address_io_r,
	input  [ 1:0] control_io_r, // {do_partial_write_instant,do_byte_operation_instant}
	
	/*
	[0] = cache_fault_waiting
	[1] = cache_fault_pulse
	[2] = cache_fault_prefetch_nonbusy_on_success_pulse
	[3] = cache_fault_prefetch_nonbusy_on_fail_pulse
	[4] = cache_fault_prefetch_busy_on_success_pulse
	[5] = cache_fault_prefetch_busy_on_fail_pulse
	[6] = hyperfetch_success_no_wait_pulse
	[7] = hyperfetch_success_with_wait_pulse
	[8] = recent_jump_success_pulse
	[9] = instruction_prefetch_fail_pulse
	*/
	input  [9:0] stat_signals_0,
	
	// pulses when execution cores run instructions
	input  [7:0] stat_signals_1,
	
	input main_clk
);


reg [15:0] data_out_io_r = 0;
reg stat_counter_freeze_r = 0;
reg stat_counter_reset_r = 0;

assign data_out_io = data_out_io_r;

wire [63:0] mux_counters [12:0];
wire [63:0] mux_out_full_counter;
wire [15:0] mux_word_counter [3:0];
wire [15:0] mux_out_word_counter;

assign mux_out_full_counter = mux_counters[address_io_r[6:3]];
assign mux_word_counter[0] = mux_out_full_counter[15: 0];
assign mux_word_counter[1] = mux_out_full_counter[31:16];
assign mux_word_counter[2] = mux_out_full_counter[47:32];
assign mux_word_counter[3] = mux_out_full_counter[63:48];
assign mux_out_word_counter = mux_word_counter[address_io_r[2:1]];

// Read the places to write to
assign mux_counters[0][    0] = stat_counter_freeze_r;
assign mux_counters[0][15: 1] = 15'h0;
assign mux_counters[0][31:16] = 16'hxxxxxxxxxxxxxxxx;
assign mux_counters[0][47:32] = 16'hxxxxxxxxxxxxxxxx;
assign mux_counters[0][63:48] = 16'hxxxxxxxxxxxxxxxx;

// total cycle counter
stat_counter_64_1 stat_counter_inst_1(
	.counter_out(mux_counters[1]),
	.stat_signal(1'b1),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// instruction run count
stat_counter_64_8 stat_counter_inst_2(
	.counter_out(mux_counters[2]),
	.stat_signal(stat_signals_1),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// cycles spent in cache fault
stat_counter_64_1 stat_counter_inst_3(
	.counter_out(mux_counters[3]),
	.stat_signal(stat_signals_0[0]),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// cache fault count
assign mux_counters[4][63:32] = 32'hxxxxxxxx;
stat_counter_32_1 stat_counter_inst_4(
	.counter_out(mux_counters[4][31:0]),
	.stat_signal(stat_signals_0[1]),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// cache fault prefetch nonbusy on success count
assign mux_counters[5][63:32] = 32'hxxxxxxxx;
stat_counter_32_1 stat_counter_inst_5(
	.counter_out(mux_counters[5][31:0]),
	.stat_signal(stat_signals_0[2]),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// cache fault prefetch nonbusy on fail count
assign mux_counters[6][63:32] = 32'hxxxxxxxx;
stat_counter_32_1 stat_counter_inst_6(
	.counter_out(mux_counters[6][31:0]),
	.stat_signal(stat_signals_0[3]),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// cache fault prefetch busy on success count
assign mux_counters[7][63:32] = 32'hxxxxxxxx;
stat_counter_32_1 stat_counter_inst_7(
	.counter_out(mux_counters[7][31:0]),
	.stat_signal(stat_signals_0[4]),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// cache fault prefetch busy on fail count
assign mux_counters[8][63:32] = 32'hxxxxxxxx;
stat_counter_32_1 stat_counter_inst_8(
	.counter_out(mux_counters[8][31:0]),
	.stat_signal(stat_signals_0[5]),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// hyperfetch no wait success count
stat_counter_64_1 stat_counter_inst_9(
	.counter_out(mux_counters[9]),
	.stat_signal(stat_signals_0[6]),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// hyperfetch with wait success count
stat_counter_64_1 stat_counter_inst_10(
	.counter_out(mux_counters[10]),
	.stat_signal(stat_signals_0[7]),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// recent jump success count
stat_counter_64_1 stat_counter_inst_11(
	.counter_out(mux_counters[11]),
	.stat_signal(stat_signals_0[8]),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);

// instruction prefetch fail count
stat_counter_64_1 stat_counter_inst_12(
	.counter_out(mux_counters[12]),
	.stat_signal(stat_signals_0[9]),
	.freeze_it(stat_counter_freeze_r),
	.reset_it(stat_counter_reset_r),
	.main_clk(main_clk)
);


always @(posedge main_clk) begin
	stat_counter_reset_r <= 1'b0;
	
	if (address_io_r[31] == 1'b1 && address_io_r[25:23]==3'd4) begin
		if (control_io_r[1]==1'b1) begin
			if (address_io_r[15:0] == 16'h00) begin
				stat_counter_freeze_r <= data_in_io_r[0];
			end else if (address_io_r[15:0] == 16'h04) begin
				stat_counter_reset_r <= 1'b1;
			end
		end
	end
	
	data_out_io_r <= mux_out_word_counter;
end

endmodule

module memory_io(
	output [15:0] data_out_io,
	input  [15:0] data_in_io,
	input  [31:0] address_io,
	input  [ 1:0] control_io, // {do_partial_write_instant,do_byte_operation_instant}
	
	input  [9:0] stat_signals_0, // see stat_manager
	input  [7:0] stat_signals_1, // see stat_manager

	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		     [3:0]		VGA_R,
	output		          		VGA_HS,
	output		          		VGA_VS,
	
	output [9:0] led_out_state,
	
	output ps2_at0_external_clock_pulldown,
	output ps2_at0_external_data_pulldown,
	input ps2_at0_external_clock_in,
	input ps2_at0_external_data_in,
	
	output sd_at0_clk_external,
	output sd_at0_chip_select_external,
	output sd_at0_data_external_mosi,
	input  sd_at0_data_external_miso,
	
	input VGA_CLK,
	input main_clk
);

/*

Address access mapping:
	address_io[31]    determines if any IO device is accessed ( 0==no , 1==yes )
	address_io[25:23] determines which IO device is accessed
	address_io[25:23]==0 : LEDs on circuit board
	address_io[25:23]==1 : VGA's VRAM
	address_io[25:23]==2 : sd card controller
	address_io[25:23]==3 : ps2 controller
	address_io[25:23]==4 : stat counters
	address_io[25:23]==5 : HardFloat helper

Typical considerations for IO mapped devices:
	All IO devices will not "react" (change state) due to a memory read. However, they may change state due to other factors, which could change the resulting value of the read.
	Some IO devices will operate identically to memory with word/byte and read/write accesses (as long as the address is within the range of the device's memory area).

Warning for ignoring IO mapped device's protocols:
	For all IO devices, software is responsible for adhering to the protocols of when certain memory words/bytes are allowed to be read and written.
	Failing to adhere to the protocols of a particular device will result in undefined behavior.
	In the worst of cases, this undefined behavior may result in unexpected result data, dropped requests, or endlessly unresponsive controllers.

Special considerations for VGA's VRAM:
	When address 32766 (within it's IO address area) is read with a byte access it will give the frame counter instead of the contents of memory at that location.
	See `vga_driver.sv` for more information on what addresses do what.

Special considerations for sd card controller:
	See `sd_card_controller.sv`

Special considerations for ps2 controller:
	See `ps2_controller.sv`

Special considerations for stat counters:
	Use word accesses only.
	Do not attempt to write to counters, only write to control words.

Special considerations for HardFloat helper:
	Use word accesses only.
	The device is command based and only runs an operation when command word bit 0 is written as 1.

Access protocol for VGA's VRAM:
	Read and Write is allowed for byte and word access. Anything can be written at any time.
	Modifying the mode info or font address offset will probably cause temporary visual glitches for 1-2 frames. This is normal and unavoidable since there is not enough memory for double buffering.
	Modifying other data may cause temporary visual glitches (primarily tearing) for 1 frame. This is normal and unavoidable since there is not enough memory for double buffering.
	To avoid most visual glitches, modify memory soon after the frame counter is incremented. This is because the frame counter gets incremented immediately after the visual area is streamed over the vga cable. There is about 1.42ms before visual data will begin streaming again.
	See `vga_driver.sv` for more information on what address do what.

Access protocol for sd card controller:
	See `sd_card_controller.sv`

Access protocol for ps2 controller:
	See `ps2_controller.sv`

Access protocol for stat counters:
	Write 1 to address 0x00 to freeze counters. This prevents counting and stablizes the counters so that they can be read without error.
	Perform 4 read accesses to counters and discard results.
	Read any stat counters:
		64 bit counter at 0x08 is total cycle counter
		64 bit counter at 0x10 is instruction run count
		64 bit counter at 0x18 is cycles spent in cache fault
		32 bit counter at 0x20 is cache fault count
		32 bit counter at 0x28 is cache fault prefetch nonbusy on success count
		32 bit counter at 0x30 is cache fault prefetch nonbusy on fail count
		32 bit counter at 0x38 is cache fault prefetch busy on success count
		32 bit counter at 0x40 is cache fault prefetch busy on fail count
		64 bit counter at 0x48 is hyperfetch success no wait count
		64 bit counter at 0x50 is hyperfetch success with wait count
		64 bit counter at 0x58 is recent jump success count
		64 bit counter at 0x60 is instruction prefetch fail count

	You may write any value to address 0x04 to reset counters to 0.
	Write 0 to address 0x00 to unfreeze counters. This enables counting.

Access protocol for HardFloat helper:
	Write operands as IEEE-754 single precision:
		0x02: operand A low 16 bits
		0x04: operand A high 16 bits
		0x06: operand B low 16 bits
		0x08: operand B high 16 bits
	Write command word at 0x00 with bit0=1 to start an operation. Opcode in bits [3:1]:
		0=ADD, 1=SUB, 2=MUL, 3=EQ, 4=LT, 5=LE, 6=DIV
	Read back:
		0x00 status/control: bit0=busy (division in-flight), bit1=result_ready, bits[4:2]=last opcode
		0x0A result low 16 bits
		0x0C result high 16 bits
		0x0E flags (exception flags in [4:0], compare bits in [7:5] for compare operations)
	Write command word with bit1=1 to clear result_ready.
*/

wire [15:0] data_in_io_modified={(control_io[0]?data_in_io[7:0]:data_in_io[15:8]),(data_in_io[7:0])};
reg [31:0] address_io_r=0;
reg [ 1:0] control_io_r=0;
reg [15:0] data_in_io_r=0;
reg [31:0] address_io_rr=0;
reg [ 1:0] control_io_rr=0;
reg [15:0] data_in_io_modified_r=0;
always @(posedge main_clk) begin
	data_in_io_modified_r<=data_in_io_modified;
	address_io_r<=address_io;
	control_io_r<=control_io;
	data_in_io_r<=data_in_io;
	
	address_io_rr<=address_io_r;
	control_io_rr<=control_io_r;
end

wire [15:0] out_mux [7:0];
wire [15:0] nearly_data_out_io=out_mux[address_io_rr[25:23]];
assign data_out_io=control_io_rr[0]?(address_io_rr[0]?{8'h0,nearly_data_out_io[15:8]}:{8'h0,nearly_data_out_io[ 7:0]}):nearly_data_out_io;
assign out_mux[0]=16'h0; // LEDs on circuit board cannot be read
// out_mux[1] is VGA memory
// out_mux[2] is sd card controller
// out_mux[3] is ps2 controller
// out_mux[4] is stat counters
// out_mux[5] is HardFloat helper
assign out_mux[6]=16'h0; // not connected
assign out_mux[7]=16'h0; // not connected


reg [9:0] led_state=0;
assign led_out_state=led_state;
always @(posedge main_clk) begin
	// LEDs
	if (control_io_r[1] && address_io_r[31] && address_io_r[25:23]==3'd0 && address_io_r[3:0]<4'd10) begin
		led_state[address_io_r[3:0]]=data_in_io_modified_r[0];
	end
end

vga_driver vga_driver_inst(
	.VGA_B(VGA_B),.VGA_G(VGA_G),.VGA_R(VGA_R),.VGA_HS(VGA_HS),.VGA_VS(VGA_VS),
	
	.io_do_write(control_io[1] && address_io[31] && address_io[25:23]==3'd1),
	.io_do_byte_op(control_io[0]),
	.io_addr(address_io[14:0]),
	.io_write_data(data_in_io_modified),
	.io_read_data(out_mux[1]),
	.main_clk(main_clk),
	.VGA_CLK(VGA_CLK)
);

sd_card_controller sd_card_controller_inst(
	.clk_external(sd_at0_clk_external),
	.chip_select_external(sd_at0_chip_select_external),
	.data_external_mosi(sd_at0_data_external_mosi),
	.data_external_miso(sd_at0_data_external_miso),
	
	.data_read_mmio(out_mux[2]),
	.data_write_mmio(data_in_io_modified),
	.address_mmio(address_io[12:0]),
	.is_mmio_write(control_io[1] && address_io[31] && address_io[25:23]==3'd2),
	.is_mmio_byte(control_io[0]),
	.main_clk(main_clk)
);

ps2_controller ps2_controller_inst(
	.external_clock_pulldown(ps2_at0_external_clock_pulldown),
	.external_data_pulldown(ps2_at0_external_data_pulldown),
	.external_clock_in(ps2_at0_external_clock_in),
	.external_data_in(ps2_at0_external_data_in),
	
	.data_read_mmio(out_mux[3][7:0]),
	.data_write_mmio(data_in_io_modified[7:0]),
	.address_mmio(address_io[2:0]),
	.is_mmio_write(control_io[1] && address_io[31] && address_io[25:23]==3'd3),
	.main_clk(main_clk)
);
assign out_mux[3][15:8]=out_mux[3][7:0];



hardfloat_mmio hardfloat_mmio_inst(
	.data_read_mmio(out_mux[5]),
	.data_write_mmio(data_in_io_modified),
	.address_mmio(address_io[4:0]),
	.is_mmio_write(control_io[1] && address_io[31] && address_io[25:23]==3'd5),
	.is_mmio_byte(control_io[0]),
	.main_clk(main_clk)
);

stat_manager stat_manager_inst(
	.data_out_io(out_mux[4]),
	
	.data_in_io_r(data_in_io_r),
	.address_io_r(address_io_r),
	.control_io_r(control_io_r),
	.stat_signals_0(stat_signals_0),
	.stat_signals_1(stat_signals_1),
	.main_clk(main_clk)
);

endmodule
