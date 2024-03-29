`timescale 1 ps / 1 ps


`define ENABLE_ADC_CLOCK
`define ENABLE_CLOCK1
`define ENABLE_CLOCK2
`define ENABLE_SDRAM
`define ENABLE_HEX0
`define ENABLE_HEX1
`define ENABLE_HEX2
`define ENABLE_HEX3
`define ENABLE_HEX4
`define ENABLE_HEX5
`define ENABLE_KEY
`define ENABLE_LED
`define ENABLE_SW
`define ENABLE_VGA
//`define ENABLE_ACCELEROMETER
`define ENABLE_ARDUINO
`define ENABLE_GPIO

`include "core_main.sv"
`include "memory_io.sv"
`include "simulation.sv"

module top_cookie(

	//////////// ADC CLOCK: 3.3-V LVTTL //////////
`ifdef ENABLE_ADC_CLOCK
	input 		          		ADC_CLK_10,
`endif
	//////////// CLOCK 1: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK1
	input 		          		MAX10_CLK1_50,
`endif
	//////////// CLOCK 2: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK2
	input 		          		MAX10_CLK2_50,
`endif

	//////////// SDRAM: 3.3-V LVTTL //////////
`ifdef ENABLE_SDRAM
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,
`endif

	//////////// SEG7: 3.3-V LVTTL //////////
`ifdef ENABLE_HEX0
	output		     [7:0]		HEX0,
`endif
`ifdef ENABLE_HEX1
	output		     [7:0]		HEX1,
`endif
`ifdef ENABLE_HEX2
	output		     [7:0]		HEX2,
`endif
`ifdef ENABLE_HEX3
	output		     [7:0]		HEX3,
`endif
`ifdef ENABLE_HEX4
	output		     [7:0]		HEX4,
`endif
`ifdef ENABLE_HEX5
	output		     [7:0]		HEX5,
`endif

	//////////// KEY: 3.3 V SCHMITT TRIGGER //////////
`ifdef ENABLE_KEY
	input 		     [1:0]		KEY,
`endif

	//////////// LED: 3.3-V LVTTL //////////
`ifdef ENABLE_LED
	output		     [9:0]		LEDR,
`endif

	//////////// SW: 3.3-V LVTTL //////////
`ifdef ENABLE_SW
	input 		     [9:0]		SW,
`endif

	//////////// VGA: 3.3-V LVTTL //////////
`ifdef ENABLE_VGA
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,
`endif

	//////////// Accelerometer: 3.3-V LVTTL //////////
`ifdef ENABLE_ACCELEROMETER
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,
`endif

	//////////// Arduino: 3.3-V LVTTL //////////
`ifdef ENABLE_ARDUINO
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,
`endif

	//////////// GPIO : 3.3-V LVTTL //////////
`ifdef ENABLE_GPIO
	inout 		    [35:0]		GPIO
`endif
);


wire reference_clock;
assign reference_clock=MAX10_CLK1_50;

wire main_clk; // 83.3333MHz
assign DRAM_CLK=main_clk;

wire vga_clk; // 25.175MHz


ip_pll_internal ip_pll_internal_inst(
	reference_clock,
	main_clk
);

ip_pll_vga ip_pll_vga_inst(
	reference_clock,
	vga_clk
);

wire [7:0] hex_display [5:0];
assign HEX0=hex_display[0];
assign HEX1=hex_display[1];
assign HEX2=hex_display[2];
assign HEX3=hex_display[3];
assign HEX4=hex_display[4];
assign HEX5=hex_display[5];

wire [15:0] data_out_io;
wire [15:0] data_in_io;
wire [31:0] address_io;
wire [1:0] control_io;

wire [15:0] debug_user_reg [15:0];
wire [15:0] debug_stack_pointer;
wire [25:0] debug_instruction_fetch_address;
wire [9:0] led_state;
//assign LEDR[9:0]=led_state;
wire [9:0] debug_port_states0;
wire [9:0] debug_port_states1;
wire [9:0] debug_port_states2;
wire [9:0] led_mux [3:0];
assign led_mux[0]=led_state;
assign led_mux[1]=debug_port_states2;
assign led_mux[2]=debug_port_states0;
assign led_mux[3]=debug_port_states1;
assign LEDR[9:0]=led_mux[SW[9:8]];

core_main core__main(
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_CKE,
	DRAM_CS_N,
	DRAM_DQ,
	DRAM_LDQM,
	DRAM_RAS_N,
	DRAM_UDQM,
	DRAM_WE_N,
	
	data_out_io,
	data_in_io,
	address_io,
	control_io,
	
	main_clk,
	
	debug_user_reg,
	debug_stack_pointer,
	debug_instruction_fetch_address,
	debug_port_states2,
	debug_port_states0,
	debug_port_states1
);

generate_hex_display_base16 generate_hex_display_inst(
	hex_display,
	debug_user_reg[SW[3:0]]
);


wire ps2_at0_external_clock_pulldown;
wire ps2_at0_external_data_pulldown;
wire ps2_at0_external_clock_in;
wire ps2_at0_external_data_in;
assign ARDUINO_IO[14]=ps2_at0_external_data_pulldown;  // ARDUINO_IO[14]
assign ps2_at0_external_data_in=ARDUINO_IO[15];        // ARDUINO_IO[15]
assign ARDUINO_IO[13]=ps2_at0_external_clock_pulldown; // ARDUINO_IO[13]
assign ps2_at0_external_clock_in=ARDUINO_IO[12];       // ARDUINO_IO[12]

wire sd_at0_clk_external;
wire sd_at0_chip_select_external;
wire sd_at0_data_external_mosi;
wire sd_at0_data_external_miso;
assign sd_at0_data_external_miso=ARDUINO_IO[5];    // ARDUINO_IO[5]
assign ARDUINO_IO[4]=sd_at0_clk_external;          // ARDUINO_IO[4]
assign ARDUINO_IO[3]=sd_at0_data_external_mosi;    // ARDUINO_IO[3]
assign ARDUINO_IO[2]=sd_at0_chip_select_external;  // ARDUINO_IO[2]

memory_io memory__io(
	.data_out_io(data_out_io),
	.data_in_io(data_in_io),
	.address_io(address_io),
	.control_io(control_io),
	
	.VGA_B(VGA_B),.VGA_G(VGA_G),.VGA_R(VGA_R),.VGA_HS(VGA_HS),.VGA_VS(VGA_VS),
	
	.led_out_state(led_state),
	
	.ps2_at0_external_clock_pulldown(ps2_at0_external_clock_pulldown),
	.ps2_at0_external_data_pulldown(ps2_at0_external_data_pulldown),
	.ps2_at0_external_clock_in(ps2_at0_external_clock_in),
	.ps2_at0_external_data_in(ps2_at0_external_data_in),
	
	.sd_at0_clk_external(sd_at0_clk_external),
	.sd_at0_chip_select_external(sd_at0_chip_select_external),
	.sd_at0_data_external_mosi(sd_at0_data_external_mosi),
	.sd_at0_data_external_miso(sd_at0_data_external_miso),
	
	.VGA_CLK(vga_clk),
	.main_clk(main_clk)
);

endmodule

