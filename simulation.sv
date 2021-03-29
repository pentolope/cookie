`timescale 1 ps / 1 ps

module fake_dram(
	input 		    [12:0]		DRAM_ADDR,
	input 		     [1:0]		DRAM_BA,
	input 		          		DRAM_CAS_N,
	input 		          		DRAM_CKE,
	input 		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	input 		          		DRAM_LDQM,
	input 		          		DRAM_RAS_N,
	input 		          		DRAM_UDQM,
	input 		          		DRAM_WE_N,

	input main_clk,
	
	input init_to_random

);

// doesn't test initialization, mode register, or most required delays

reg [15:0] mem [3:0][8191:0][1023:0];

reg bank_is_active [3:0];
reg [12:0] bank_active_row [3:0];

reg [1:0] active_bank=0;
reg [9:0] active_col=0;

reg [15:0] DRAM_DQ_source_pipe [1:0]='{0,0};

reg [15:0] DRAM_DQ_source=0;
reg [15:0] DRAM_DQ_oe=0;
reg [15:0] DRAM_DQ_source_2=0;
reg [15:0] DRAM_DQ_oe_2=0;
assign DRAM_DQ=DRAM_DQ_oe_2?DRAM_DQ_source_2:128'dz;

int i0;
int i1;
int i2;
initial begin
	for (i0=0;i0<4;i0=i0+1) begin
		bank_is_active[i0]=0;
		bank_active_row[i0]=0;
	end
	#1;
	if (init_to_random) begin
		$display("Initializing fake DRAM to RANDOM state...");
		for (i0=0;i0<4;i0=i0+1) begin
			for (i1=0;i1<8192;i1=i1+1) begin
				for (i2=0;i2<1024;i2=i2+1) begin
					mem[i0][i1][i2]=$urandom();
				end
			end
		end
		$display("Initializing fake DRAM to RANDOM state finished.");
	end else begin
		$display("Initializing fake DRAM to ZERO state...");
		for (i0=0;i0<4;i0=i0+1) begin
			for (i1=0;i1<8192;i1=i1+1) begin
				for (i2=0;i2<1024;i2=i2+1) begin
					mem[i0][i1][i2]=0;
				end
			end
		end
		$display("Initializing fake DRAM to ZERO state finished.");
	end
end

always @(posedge main_clk) begin
	DRAM_DQ_source_2<=DRAM_DQ_source;
	DRAM_DQ_oe_2<=DRAM_DQ_oe;
end

reg [19:0] state=0;

always @(posedge main_clk) begin
	unique case (state)
	0:begin
		DRAM_DQ_oe<=0;
	end
	1:begin
		// write (auto precharge) 1
		state<=2;
		mem[active_bank][bank_active_row[active_bank]][active_col+1]<=DRAM_DQ;
	end
	2:begin
		// write (auto precharge) 2
		state<=3;
		mem[active_bank][bank_active_row[active_bank]][active_col+2]<=DRAM_DQ;
	end
	3:begin
		// write (auto precharge) 3
		state<=4;
		mem[active_bank][bank_active_row[active_bank]][active_col+3]<=DRAM_DQ;
	end
	4:begin
		// write (auto precharge) 4
		state<=5;
		mem[active_bank][bank_active_row[active_bank]][active_col+4]<=DRAM_DQ;
	end
	5:begin
		// write (auto precharge) 5
		state<=6;
		mem[active_bank][bank_active_row[active_bank]][active_col+5]<=DRAM_DQ;
	end
	6:begin
		// write (auto precharge) 6
		state<=7;
		mem[active_bank][bank_active_row[active_bank]][active_col+6]<=DRAM_DQ;
	end
	7:begin
		// write (auto precharge) 7
		state<=0;
		mem[active_bank][bank_active_row[active_bank]][active_col+7]<=DRAM_DQ;
		bank_is_active[active_bank]<=0;
		bank_active_row[active_bank]<=0;
	end
	
	8:begin
		// write (no precharge) 1
		state<=9;
		mem[active_bank][bank_active_row[active_bank]][active_col+1]<=DRAM_DQ;
	end
	9:begin
		// write (no precharge) 2
		state<=10;
		mem[active_bank][bank_active_row[active_bank]][active_col+2]<=DRAM_DQ;
	end
	10:begin
		// write (no precharge) 3
		state<=11;
		mem[active_bank][bank_active_row[active_bank]][active_col+3]<=DRAM_DQ;
	end
	11:begin
		// write (no precharge) 4
		state<=12;
		mem[active_bank][bank_active_row[active_bank]][active_col+4]<=DRAM_DQ;
	end
	12:begin
		// write (no precharge) 5
		state<=13;
		mem[active_bank][bank_active_row[active_bank]][active_col+5]<=DRAM_DQ;
	end
	13:begin
		// write (no precharge) 6
		state<=14;
		mem[active_bank][bank_active_row[active_bank]][active_col+6]<=DRAM_DQ;
	end
	14:begin
		// write (no precharge) 7
		state<=0;
		mem[active_bank][bank_active_row[active_bank]][active_col+7]<=DRAM_DQ;
	end
	
	16:begin
		// read (auto precharge) 0
		state<=17;
		DRAM_DQ_oe<=1;
		DRAM_DQ_source<=mem[active_bank][bank_active_row[active_bank]][active_col+0];
	end
	17:begin
		// read (auto precharge) 1
		state<=18;
		DRAM_DQ_source<=mem[active_bank][bank_active_row[active_bank]][active_col+1];
	end
	18:begin
		// read (auto precharge) 2
		state<=19;
		DRAM_DQ_source<=mem[active_bank][bank_active_row[active_bank]][active_col+2];
	end
	19:begin
		// read (auto precharge) 3
		state<=20;
		DRAM_DQ_source<=mem[active_bank][bank_active_row[active_bank]][active_col+3];
	end
	20:begin
		// read (auto precharge) 4
		state<=21;
		DRAM_DQ_source<=mem[active_bank][bank_active_row[active_bank]][active_col+4];
	end
	21:begin
		// read (auto precharge) 5
		state<=22;
		DRAM_DQ_source<=mem[active_bank][bank_active_row[active_bank]][active_col+5];
	end
	22:begin
		// read (auto precharge) 6
		state<=23;
		DRAM_DQ_source<=mem[active_bank][bank_active_row[active_bank]][active_col+6];
	end
	23:begin
		// read (auto precharge) 7
		state<=0;
		DRAM_DQ_source<=mem[active_bank][bank_active_row[active_bank]][active_col+7];
		bank_is_active[active_bank]<=0;
		bank_active_row[active_bank]<=0;
	end
	
	endcase
	
	unique case ({DRAM_RAS_N,DRAM_CAS_N,DRAM_WE_N})
	0:begin
		// mode register set
	end
	1:begin
		// auto refresh
	end
	2:begin
		// precharge bank(s)
		if (DRAM_ADDR[10]) begin
			bank_is_active[0]<=0;
			bank_is_active[1]<=0;
			bank_is_active[2]<=0;
			bank_is_active[3]<=0;
			bank_active_row[0]<=0;
			bank_active_row[1]<=0;
			bank_active_row[2]<=0;
			bank_active_row[3]<=0;
		end else begin
			bank_is_active[DRAM_BA]<=0;
			bank_active_row[DRAM_BA]<=0;
		end
	end
	3:begin
		bank_is_active[DRAM_BA]<=1;
		bank_active_row[DRAM_BA]<=DRAM_ADDR;
	end
	4:begin
		if (DRAM_ADDR[10]) begin
			state<=1;
			active_bank<=DRAM_BA;
			active_col<=DRAM_ADDR[9:0];
			mem[DRAM_BA][bank_active_row[DRAM_BA]][DRAM_ADDR[9:0]]<=DRAM_DQ;
		end else begin
			$stop(); // unimplemented (write no precharge)
		end
	end
	5:begin
		if (DRAM_ADDR[10]) begin
			state<=16;
			active_bank<=DRAM_BA;
			active_col<=DRAM_ADDR[9:0];
		end else begin
			$stop(); // unimplemented (write no precharge)
		end
	end
	6:begin
		$stop(); // unimplemented (burst stop)
	end
	7:begin
		// nop
	end
	endcase
end


endmodule



module sim_enviroment(
);

wire 		    [12:0]		DRAM_ADDR;
wire 		     [1:0]		DRAM_BA;
wire 		          		DRAM_CAS_N;
wire 		          		DRAM_CKE;
wire 		          		DRAM_CS_N;
wire 		    [15:0]		DRAM_DQ;
wire 		          		DRAM_LDQM;
wire 		          		DRAM_RAS_N;
wire 		          		DRAM_UDQM;
wire 		          		DRAM_WE_N;
wire		     [3:0]		VGA_B;
wire		     [3:0]		VGA_G;
wire		     [3:0]		VGA_R;
wire		          		VGA_HS;
wire		          		VGA_VS;
wire		     [9:0]		LEDR;

wire ps2_at0_external_clock_pulldown;
wire ps2_at0_external_data_pulldown;
wire ps2_at0_external_clock_in;
wire ps2_at0_external_data_in;

wire sd_at0_clk_external;
wire sd_at0_chip_select_external;
wire sd_at0_data_external_mosi;
wire sd_at0_data_external_miso;

wire [7:0] debug_controller_state_now; // for sd card debug

wire [15:0] data_out_io;
wire [15:0] data_in_io;
wire [31:0] address_io;
wire [1:0] control_io;

wire [15:0] debug_user_reg [15:0];
wire [15:0] debug_stack_pointer;
wire [25:0] debug_instruction_fetch_address;
wire debug_scheduler=1'b0;

reg main_clk=0;
reg vga_clk=0;

int i;

initial begin
	#10;
	forever begin
		main_clk=~main_clk;
		#20;
	end
end

initial begin
	#12;
	forever begin
		vga_clk=~vga_clk;
		#143; // approximate ratio
	end
end

fake_dram fake__dram(
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
	
	main_clk,
	
	1'b0 // init_to_random
);

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
	debug_scheduler
);

memory_io memory__io(
	.data_out_io(data_out_io),
	.data_in_io(data_in_io),
	.address_io(address_io),
	.control_io(control_io),
	
	.VGA_B(VGA_B),.VGA_G(VGA_G),.VGA_R(VGA_R),.VGA_HS(VGA_HS),.VGA_VS(VGA_VS),
	
	.led_out_state(LEDR),
	
	.ps2_at0_external_clock_pulldown(ps2_at0_external_clock_pulldown),
	.ps2_at0_external_data_pulldown(ps2_at0_external_data_pulldown),
	.ps2_at0_external_clock_in(ps2_at0_external_clock_in),
	.ps2_at0_external_data_in(ps2_at0_external_data_in),
	
	.sd_at0_clk_external(sd_at0_clk_external),
	.sd_at0_chip_select_external(sd_at0_chip_select_external),
	.sd_at0_data_external_mosi(sd_at0_data_external_mosi),
	.sd_at0_data_external_miso(sd_at0_data_external_miso),
	
	.debug_controller_state_now(debug_controller_state_now),
	
	.vga_clk(vga_clk),
	.main_clk(main_clk)
);

initial begin // stopping timer
	#10;
	for (i=0;i<800;i=i+1) begin//131072
		#20;
	end
	$display("Stopping Normally due to cutoff timer.");
	$stop;
end


endmodule
