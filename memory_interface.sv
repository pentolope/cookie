`timescale 1 ps / 1 ps

`include "memory_system.sv"

module memory_interface(
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,
	
	// for all memory access ports, once a request has begun to be issued, it should not be changed before it is acknowledged. instruction_fetch has a void signal that allows it to change
	
	input  [ 2:0] stack_access_size [7:0], // stack_access_size value signifies a number of words one greater then it's value
	input  [7:0] is_stack_access_requesting_extern,
	input  [7:0] is_stack_access_overflowing_extern,
	
	input  [31:0] target_address_executer [7:0],
	// target_address_executer is allowed to access I/O mapped memory regions and can be any type of memory access only when is_general_access_requesting , not when is_stack_access_requesting
	input  [15:0] data_in [7:0][3:0],
	
	input  [7:0] is_access_write,
	input  [7:0] is_general_access_byte_operation,
	input  [7:0] is_general_access_requesting_extern,

	output [7:0] is_general_or_stack_access_acknowledged_pulse_extern,
	
	input  [25:0] target_address_instruction_fetch_0,
	input  [25:0] target_address_instruction_fetch_1,
	// target_address_instruction_fetch_x is not allowed to access I/O mapped memory regions, and must be aligned to word boundries. 
	// the entire cache lane at and past the requested word is given. The amount of valid words returned is trivial to calculate from the address, so it is not given.
	// target_address_instruction_fetch_0 will always be served before target_address_instruction_fetch_1
	// these accesses use data_out_type_0_extern
	input  is_instruction_fetch_0_requesting_extern,
	output is_instruction_fetch_0_acknowledged_pulse_extern,
	input  is_instruction_fetch_1_requesting_extern,
	output is_instruction_fetch_1_acknowledged_pulse_extern,
	
	input void_instruction_fetch,   // when on, this will void any in-progress instruction fetch requests. This is needed to ensure validity in some cases. it does NOT void the request that is being requested on the same cycle that this is on
	
	output [15:0] data_out_type_0_extern [7:0], // type_0 is for instruction fetch [note that type_0 is NOT delayed after it's acknowledgement, it's data is given on the same clock cycle]
	output [15:0] data_out_type_1_extern [7:0], // type_1 is for executers [note that type_1 is delayed by one clock cycle past it's acknowledgement]
	
	output [7:0] memory_dependency_clear_extern,
	
	input  [15:0] data_out_io_extern,
	output [15:0] data_in_io_extern,
	output [31:0] address_io_extern,
	output [1:0] control_io_extern,
	
	output [9:0] debug_port_states0,
	output [9:0] debug_port_states1,
	
	input  main_clk
);

wire [7:0] is_stack_access_overflowing=is_stack_access_overflowing_extern;

reg is_instruction_fetch_0_acknowledged_pulse_delayed=0;
reg is_instruction_fetch_1_acknowledged_pulse_delayed=0;

reg is_instruction_fetch_0_acknowledged_pulse;
reg is_instruction_fetch_1_acknowledged_pulse;
reg [7:0] is_general_or_stack_access_acknowledged_pulse;
reg [7:0] memory_dependency_clear=0;

reg [7:0] resolving_memory_access_from_executer=0; // this is not turned on when the request is an IO request
reg [1:0] resolving_memory_access_from_instruction_fetch=0;

assign debug_port_states0={is_instruction_fetch_1_requesting_extern,is_instruction_fetch_0_requesting_extern,(is_stack_access_requesting_extern | is_general_access_requesting_extern)};
assign debug_port_states1={resolving_memory_access_from_instruction_fetch,resolving_memory_access_from_executer};

assign is_instruction_fetch_0_acknowledged_pulse_extern=is_instruction_fetch_0_acknowledged_pulse_delayed & ~void_instruction_fetch;
assign is_instruction_fetch_1_acknowledged_pulse_extern=is_instruction_fetch_1_acknowledged_pulse_delayed & ~void_instruction_fetch & ~is_instruction_fetch_0_requesting_extern;
assign is_general_or_stack_access_acknowledged_pulse_extern=is_general_or_stack_access_acknowledged_pulse;
assign memory_dependency_clear_extern=memory_dependency_clear;

wire is_instruction_fetch_0_requesting=void_instruction_fetch?is_instruction_fetch_0_requesting_extern:(is_instruction_fetch_0_requesting_extern & ~resolving_memory_access_from_instruction_fetch[0]);
wire is_instruction_fetch_1_requesting=void_instruction_fetch?is_instruction_fetch_1_requesting_extern:(is_instruction_fetch_1_requesting_extern & ~resolving_memory_access_from_instruction_fetch[1]);
wire [7:0] is_stack_access_requesting;
wire [7:0] is_general_access_requesting;
assign is_stack_access_requesting=is_stack_access_requesting_extern & ~resolving_memory_access_from_executer;
assign is_general_access_requesting=is_general_access_requesting_extern & ~resolving_memory_access_from_executer;

always @(posedge main_clk) begin
	is_instruction_fetch_0_acknowledged_pulse_delayed<=is_instruction_fetch_0_acknowledged_pulse & ~void_instruction_fetch;
	is_instruction_fetch_1_acknowledged_pulse_delayed<=is_instruction_fetch_1_acknowledged_pulse & ~void_instruction_fetch;
end

reg [15:0] data_out_io=0;
reg [15:0] data_in_io=0;
reg [31:0] address_io=0;
reg [1:0] control_io=0;
reg [2:0] executer_index_for_io=0;
reg [2:0] state_for_io=0;
reg state_for_io_is_5=0;
reg state_for_io_is_7=0;
assign data_in_io_extern=data_in_io;
assign address_io_extern=address_io;
assign control_io_extern=control_io;


reg  [1:0] tick_tock_phase0=0;
wire [1:0] tick_tock_phase1;
wire [1:0] tick_tock_phase2;
reg  [1:0] tick_tock_phase3=0;
wire tick_tock_phase2_moved;


reg [4:0] tt_access_index [3:0]='{0,0,0,0};

reg [30:0] tt_address [1:0]='{0,0};
reg [15:0] tt_data [1:0][3:0];
reg tt_is_byte_op [1:0]='{0,0};
reg tt_is_write_op [1:0]='{0,0};

reg [1:0] tt_move [1:0]='{0,0};
reg tt_secondary [1:0]='{0,0};

reg [2:0] tt_access_length [1:0]='{0,0};
// access_length is only required to be correct for writes and multi-cache-lane reads, otherwise it may be assigned 7 .
// (well, the value set here technically doesn't matter for multi-cache-lane reads but the access length does matter for those).
// Also, it's value signifies a number of words one greater then it's value.


wire [15:0] cd_access_out_full_data [7:0];
reg [15:0] cd_access_out_full_data_saved [7:0];
reg [15:0] cd_access_out_full_data_delayed [7:0];
assign data_out_type_0_extern=cd_access_out_full_data_delayed;
assign data_out_type_1_extern=cd_access_out_full_data_saved;

always @(posedge main_clk) cd_access_out_full_data_delayed<=cd_access_out_full_data;

reg [7:0] is_stack_access_overflowing_a; // this is if the stack access will need two accesses for two cache lanes [does not check if the access is actually requesting]

reg [2:0] stack_access_size0 [7:0]; // if overflowed, this is the size of the first (lower) access
reg [2:0] stack_access_size1 [7:0]; // if overflowed, this is the size of the second (upper) access

reg [3:0] temp_stack_max_address [7:0];
always_comb begin
	temp_stack_max_address[0]=stack_access_size[0]+{1'b0,target_address_executer[0][3:1]};
	temp_stack_max_address[1]=stack_access_size[1]+{1'b0,target_address_executer[1][3:1]};
	temp_stack_max_address[2]=stack_access_size[2]+{1'b0,target_address_executer[2][3:1]};
	temp_stack_max_address[3]=stack_access_size[3]+{1'b0,target_address_executer[3][3:1]};
	is_stack_access_overflowing_a[0]=temp_stack_max_address[0][3];
	is_stack_access_overflowing_a[1]=temp_stack_max_address[1][3];
	is_stack_access_overflowing_a[2]=temp_stack_max_address[2][3];
	is_stack_access_overflowing_a[3]=temp_stack_max_address[3][3];
	
	stack_access_size0[0]=3'd7-target_address_executer[0][3:1];
	stack_access_size0[1]=3'd7-target_address_executer[1][3:1];
	stack_access_size0[2]=3'd7-target_address_executer[2][3:1];
	stack_access_size0[3]=3'd7-target_address_executer[3][3:1];
	stack_access_size1[0]=(stack_access_size[0]-stack_access_size0[0])-3'b1;
	stack_access_size1[1]=(stack_access_size[1]-stack_access_size0[1])-3'b1;
	stack_access_size1[2]=(stack_access_size[2]-stack_access_size0[2])-3'b1;
	stack_access_size1[3]=(stack_access_size[3]-stack_access_size0[3])-3'b1;
	
	temp_stack_max_address[4]=stack_access_size[4]+{1'b0,target_address_executer[4][3:1]};
	temp_stack_max_address[5]=stack_access_size[5]+{1'b0,target_address_executer[5][3:1]};
	temp_stack_max_address[6]=stack_access_size[6]+{1'b0,target_address_executer[6][3:1]};
	temp_stack_max_address[7]=stack_access_size[7]+{1'b0,target_address_executer[7][3:1]};
	is_stack_access_overflowing_a[4]=temp_stack_max_address[4][3];
	is_stack_access_overflowing_a[5]=temp_stack_max_address[5][3];
	is_stack_access_overflowing_a[6]=temp_stack_max_address[6][3];
	is_stack_access_overflowing_a[7]=temp_stack_max_address[7][3];
	
	stack_access_size0[4]=3'd7-target_address_executer[4][3:1];
	stack_access_size0[5]=3'd7-target_address_executer[5][3:1];
	stack_access_size0[6]=3'd7-target_address_executer[6][3:1];
	stack_access_size0[7]=3'd7-target_address_executer[7][3:1];
	stack_access_size1[4]=(stack_access_size[4]-stack_access_size0[4])-3'b1;
	stack_access_size1[5]=(stack_access_size[5]-stack_access_size0[5])-3'b1;
	stack_access_size1[6]=(stack_access_size[6]-stack_access_size0[6])-3'b1;
	stack_access_size1[7]=(stack_access_size[7]-stack_access_size0[7])-3'b1;
end

reg instruction_fetch_mux_value;
wire instruction_fetch_mux_value_a;
wire [25:0] muxed_instruction_fetch_address;
wire [25:0] muxed_instruction_fetch_address_temp [1:0];
assign muxed_instruction_fetch_address_temp[0]=target_address_instruction_fetch_0;
assign muxed_instruction_fetch_address_temp[1]=target_address_instruction_fetch_1;
lcell_26 lc_instruction_fetch_mux_address(muxed_instruction_fetch_address,muxed_instruction_fetch_address_temp[instruction_fetch_mux_value_a]);


reg [4:0] next_new_index_working;
wire [4:0] next_new_index;
//lcell_5 lc_next_new_index(next_new_index,next_new_index_working);
reg current_0;
reg current_1;
reg current_1or0;
wire current_0_lc;
wire current_1_lc;
wire current_1or0_lc;
reg [1:0] phase_diff;
lcell_1 cur0(current_0_lc,current_0);
lcell_1 cur1(current_1_lc,current_1);
lcell_1 cur2(current_1or0_lc,current_1or0);

always_comb begin
	phase_diff=tick_tock_phase0 - tick_tock_phase1;
	current_0=(phase_diff==2'd0)? 1'b1:1'b0;
	current_1=(phase_diff==2'd1)? 1'b1:1'b0;
	current_1or0=(current_0 || current_1)? 1'b1:1'b0;
end
always @(posedge main_clk) assert (phase_diff!=2'd3);

wire [2:0] lut0 [15:0];
assign lut0[4'b0000]=3'b000;
assign lut0[4'b0001]=3'b100;
assign lut0[4'b0010]=3'b101;
assign lut0[4'b0011]=3'b100;
assign lut0[4'b0100]=3'b110;
assign lut0[4'b0101]=3'b100;
assign lut0[4'b0110]=3'b101;
assign lut0[4'b0111]=3'b100;
assign lut0[4'b1000]=3'b111;
assign lut0[4'b1001]=3'b100;
assign lut0[4'b1010]=3'b101;
assign lut0[4'b1011]=3'b100;
assign lut0[4'b1100]=3'b110;
assign lut0[4'b1101]=3'b100;
assign lut0[4'b1110]=3'b101;
assign lut0[4'b1111]=3'b100;

wire [7:0] suggest0;
wire [7:0] suggest0_lc;
assign suggest0[7]=(is_general_access_requesting[7] & !target_address_executer[7][31]) | (is_stack_access_requesting[7] & !is_stack_access_overflowing[7]);
assign suggest0[6]=(is_general_access_requesting[6] & !target_address_executer[6][31]) | (is_stack_access_requesting[6] & !is_stack_access_overflowing[6]);
assign suggest0[5]=(is_general_access_requesting[5] & !target_address_executer[5][31]) | (is_stack_access_requesting[5] & !is_stack_access_overflowing[5]);
assign suggest0[4]=(is_general_access_requesting[4] & !target_address_executer[4][31]) | (is_stack_access_requesting[4] & !is_stack_access_overflowing[4]);
assign suggest0[3]=(is_general_access_requesting[3] & !target_address_executer[3][31]) | (is_stack_access_requesting[3] & !is_stack_access_overflowing[3]);
assign suggest0[2]=(is_general_access_requesting[2] & !target_address_executer[2][31]) | (is_stack_access_requesting[2] & !is_stack_access_overflowing[2]);
assign suggest0[1]=(is_general_access_requesting[1] & !target_address_executer[1][31]) | (is_stack_access_requesting[1] & !is_stack_access_overflowing[1]);
assign suggest0[0]=(is_general_access_requesting[0] & !target_address_executer[0][31]) | (is_stack_access_requesting[0] & !is_stack_access_overflowing[0]);
lcell_8 sug0(suggest0_lc,suggest0);

wire [7:0] suggest1;
wire [7:0] suggest1_lc;
assign suggest1[7]=(is_stack_access_requesting[7] & is_stack_access_overflowing[7]);
assign suggest1[6]=(is_stack_access_requesting[6] & is_stack_access_overflowing[6]);
assign suggest1[5]=(is_stack_access_requesting[5] & is_stack_access_overflowing[5]);
assign suggest1[4]=(is_stack_access_requesting[4] & is_stack_access_overflowing[4]);
assign suggest1[3]=(is_stack_access_requesting[3] & is_stack_access_overflowing[3]);
assign suggest1[2]=(is_stack_access_requesting[2] & is_stack_access_overflowing[2]);
assign suggest1[1]=(is_stack_access_requesting[1] & is_stack_access_overflowing[1]);
assign suggest1[0]=(is_stack_access_requesting[0] & is_stack_access_overflowing[0]);
lcell_8 sug1(suggest1_lc,suggest1);

wire [2:0] suggest2 [3:0];
lcell_3 sug2_0(suggest2[0],lut0[suggest0_lc[3:0]]);
lcell_3 sug2_1(suggest2[1],lut0[suggest0_lc[7:4]]);
lcell_3 sug2_2(suggest2[2],lut0[suggest1_lc[3:0]]);
lcell_3 sug2_3(suggest2[3],lut0[suggest1_lc[7:4]]);

wire [3:0] suggest3 [1:0];
lcell_4 sug3_0(suggest3[0],suggest2[0][2]? {suggest2[0][2],1'b0,suggest2[0][1:0]} : {suggest2[1][2],1'b1,suggest2[1][1:0]} );
lcell_4 sug3_1(suggest3[1],((!current_1_lc)? 4'b1111:4'b0000) & (suggest2[2][2]? {suggest2[2][2],1'b0,suggest2[2][1:0]} : {suggest2[3][2],1'b1,suggest2[3][1:0]} ));

wire either_fetch;
lcell_1 either(either_fetch,is_instruction_fetch_0_requesting | is_instruction_fetch_1_requesting);

wire [3:0] suggest4;
lcell_3 sug4_0(suggest4[2:0],(suggest3[1][3] | suggest3[0][3])? suggest3[suggest3[1][3]][2:0] : {2'b10,!is_instruction_fetch_0_requesting});
lcell_1 sug4_1(suggest4[3]  ,(suggest3[1][3] | suggest3[0][3] | either_fetch) & current_1or0_lc);

wire [3:0] suggest5;
lcell_1 sug5_0(suggest5[0],(suggest3[1][3] | suggest3[0][3]) & current_1or0_lc);
lcell_1 sug5_1(suggest5[1],is_general_access_requesting[suggest3[suggest3[1][3]][2:0]]);
lcell_1 sug5_2(suggest5[2],is_stack_access_requesting[suggest3[suggest3[1][3]][2:0]]);
lcell_1 sug5_3(suggest5[3],is_stack_access_overflowing[suggest3[suggest3[1][3]][2:0]]);

wire [4:0] suggest6;
assign suggest6[2:0]={3{suggest4[3]}} & suggest4[2:0];
assign suggest6[3]=suggest5[0] & (suggest5[1] | (suggest5[2] & suggest5[3]));
assign suggest6[4]=(suggest3[1][3] | suggest3[0][3]) & current_1or0_lc & suggest5[2];


lcell_5 lc_next_new_index(next_new_index,suggest6);

wire is_accepting_any;
assign is_accepting_any=suggest4[3];
wire is_accepting_multi;
lcell_1 is_accepting_multi_any(is_accepting_multi,suggest5[0] & suggest5[2] & suggest5[3]);
wire [3:0] is_accepting_into_alt;
lcell_1 is_accepting_into_alt0(is_accepting_into_alt[0],((tick_tock_phase0==2'd3 && is_accepting_multi))? 1'b1:1'b0);
lcell_1 is_accepting_into_alt1(is_accepting_into_alt[1],((tick_tock_phase0==2'd0 && is_accepting_multi))? 1'b1:1'b0);
lcell_1 is_accepting_into_alt2(is_accepting_into_alt[2],((tick_tock_phase0==2'd1 && is_accepting_multi))? 1'b1:1'b0);
lcell_1 is_accepting_into_alt3(is_accepting_into_alt[3],((tick_tock_phase0==2'd2 && is_accepting_multi))? 1'b1:1'b0);
wire [3:0] is_accepting_into_typical;
lcell_1 is_accepting_into_typical0(is_accepting_into_typical[0],((tick_tock_phase0==2'd3 && is_accepting_multi) || (tick_tock_phase0==2'd0 && is_accepting_any))? 1'b1:1'b0);
lcell_1 is_accepting_into_typical1(is_accepting_into_typical[1],((tick_tock_phase0==2'd0 && is_accepting_multi) || (tick_tock_phase0==2'd1 && is_accepting_any))? 1'b1:1'b0);
lcell_1 is_accepting_into_typical2(is_accepting_into_typical[2],((tick_tock_phase0==2'd1 && is_accepting_multi) || (tick_tock_phase0==2'd2 && is_accepting_any))? 1'b1:1'b0);
lcell_1 is_accepting_into_typical3(is_accepting_into_typical[3],((tick_tock_phase0==2'd2 && is_accepting_multi) || (tick_tock_phase0==2'd3 && is_accepting_any))? 1'b1:1'b0);
wire [3:0] is_using_void;
lcell_1 is_using_void0(is_using_void[0],((tt_access_index[0]==5'd4 || tt_access_index[0]==5'd5) && void_instruction_fetch)? 1'b1:1'b0);
lcell_1 is_using_void1(is_using_void[1],((tt_access_index[1]==5'd4 || tt_access_index[1]==5'd5) && void_instruction_fetch)? 1'b1:1'b0);
lcell_1 is_using_void2(is_using_void[2],((tt_access_index[2]==5'd4 || tt_access_index[2]==5'd5) && void_instruction_fetch)? 1'b1:1'b0);
lcell_1 is_using_void3(is_using_void[3],((tt_access_index[3]==5'd4 || tt_access_index[3]==5'd5) && void_instruction_fetch)? 1'b1:1'b0);
wire [3:0] is_accepting_into_partial;
lcell_1 is_accepting_into_partial0(is_accepting_into_partial[0],((tick_tock_phase0==2'd0 && is_accepting_any) || is_using_void[0])? 1'b1:1'b0);
lcell_1 is_accepting_into_partial1(is_accepting_into_partial[1],((tick_tock_phase0==2'd1 && is_accepting_any) || is_using_void[1])? 1'b1:1'b0);
lcell_1 is_accepting_into_partial2(is_accepting_into_partial[2],((tick_tock_phase0==2'd2 && is_accepting_any) || is_using_void[2])? 1'b1:1'b0);
lcell_1 is_accepting_into_partial3(is_accepting_into_partial[3],((tick_tock_phase0==2'd3 && is_accepting_any) || is_using_void[3])? 1'b1:1'b0);
wire [3:0] is_accepting_into_any;
lcell_1 is_accepting_into_any0(is_accepting_into_any[0],(is_accepting_into_partial[0] || (tick_tock_phase0==2'd3 && is_accepting_multi))? 1'b1:1'b0);
lcell_1 is_accepting_into_any1(is_accepting_into_any[1],(is_accepting_into_partial[1] || (tick_tock_phase0==2'd0 && is_accepting_multi))? 1'b1:1'b0);
lcell_1 is_accepting_into_any2(is_accepting_into_any[2],(is_accepting_into_partial[2] || (tick_tock_phase0==2'd1 && is_accepting_multi))? 1'b1:1'b0);
lcell_1 is_accepting_into_any3(is_accepting_into_any[3],(is_accepting_into_partial[3] || (tick_tock_phase0==2'd2 && is_accepting_multi))? 1'b1:1'b0);


assign instruction_fetch_mux_value_a= !is_instruction_fetch_0_requesting;

always @(posedge main_clk) begin
	if (is_stack_access_requesting[0]) assert(is_stack_access_overflowing[0]==is_stack_access_overflowing_a[0]);
	if (is_stack_access_requesting[1]) assert(is_stack_access_overflowing[1]==is_stack_access_overflowing_a[1]);
	if (is_stack_access_requesting[2]) assert(is_stack_access_overflowing[2]==is_stack_access_overflowing_a[2]);
	if (is_stack_access_requesting[3]) assert(is_stack_access_overflowing[3]==is_stack_access_overflowing_a[3]);
	if (is_stack_access_requesting[4]) assert(is_stack_access_overflowing[4]==is_stack_access_overflowing_a[4]);
	if (is_stack_access_requesting[5]) assert(is_stack_access_overflowing[5]==is_stack_access_overflowing_a[5]);
	if (is_stack_access_requesting[6]) assert(is_stack_access_overflowing[6]==is_stack_access_overflowing_a[6]);
	if (is_stack_access_requesting[7]) assert(is_stack_access_overflowing[7]==is_stack_access_overflowing_a[7]);
	
	if (next_new_index==5'd4 || next_new_index==5'd5) begin
		assert(instruction_fetch_mux_value==instruction_fetch_mux_value_a);
	end
	if (suggest4[3]) begin
		assert(suggest4[2:0]==next_new_index[2:0]);
	end
	assert(next_new_index==next_new_index_working);
end

always_comb begin
	next_new_index_working=0;
	instruction_fetch_mux_value=1'hx;
	if (current_1or0) begin
		if (is_instruction_fetch_1_requesting) begin next_new_index_working= 5;instruction_fetch_mux_value=1'h1;end
		if (is_instruction_fetch_0_requesting) begin next_new_index_working= 4;instruction_fetch_mux_value=1'h0;end
		
		if (is_general_access_requesting[7] && !target_address_executer[7][31]) begin next_new_index_working=15;instruction_fetch_mux_value=1'hx;end
		if (is_general_access_requesting[6] && !target_address_executer[6][31]) begin next_new_index_working=14;instruction_fetch_mux_value=1'hx;end
		if (is_general_access_requesting[5] && !target_address_executer[5][31]) begin next_new_index_working=13;instruction_fetch_mux_value=1'hx;end
		if (is_general_access_requesting[4] && !target_address_executer[4][31]) begin next_new_index_working=12;instruction_fetch_mux_value=1'hx;end
		
		if (is_general_access_requesting[3] && !target_address_executer[3][31]) begin next_new_index_working=11;instruction_fetch_mux_value=1'hx;end
		if (is_general_access_requesting[2] && !target_address_executer[2][31]) begin next_new_index_working=10;instruction_fetch_mux_value=1'hx;end
		if (is_general_access_requesting[1] && !target_address_executer[1][31]) begin next_new_index_working= 9;instruction_fetch_mux_value=1'hx;end
		if (is_general_access_requesting[0] && !target_address_executer[0][31]) begin next_new_index_working= 8;instruction_fetch_mux_value=1'hx;end

		if (  is_stack_access_requesting[7] && !is_stack_access_overflowing[7]) begin next_new_index_working=23;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[6] && !is_stack_access_overflowing[6]) begin next_new_index_working=22;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[5] && !is_stack_access_overflowing[5]) begin next_new_index_working=21;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[4] && !is_stack_access_overflowing[4]) begin next_new_index_working=20;instruction_fetch_mux_value=1'hx;end
		
		if (  is_stack_access_requesting[3] && !is_stack_access_overflowing[3]) begin next_new_index_working=19;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[2] && !is_stack_access_overflowing[2]) begin next_new_index_working=18;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[1] && !is_stack_access_overflowing[1]) begin next_new_index_working=17;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[0] && !is_stack_access_overflowing[0]) begin next_new_index_working=16;instruction_fetch_mux_value=1'hx;end
	end
	if (current_0) begin
		if (  is_stack_access_requesting[7] &&  is_stack_access_overflowing[7]) begin next_new_index_working=31;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[6] &&  is_stack_access_overflowing[6]) begin next_new_index_working=30;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[5] &&  is_stack_access_overflowing[5]) begin next_new_index_working=29;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[4] &&  is_stack_access_overflowing[4]) begin next_new_index_working=28;instruction_fetch_mux_value=1'hx;end

		if (  is_stack_access_requesting[3] &&  is_stack_access_overflowing[3]) begin next_new_index_working=27;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[2] &&  is_stack_access_overflowing[2]) begin next_new_index_working=26;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[1] &&  is_stack_access_overflowing[1]) begin next_new_index_working=25;instruction_fetch_mux_value=1'hx;end
		if (  is_stack_access_requesting[0] &&  is_stack_access_overflowing[0]) begin next_new_index_working=24;instruction_fetch_mux_value=1'hx;end
	end
end

reg [7:0] is_first_overflowed_stack_ready;
reg is_waiting_on_second_overflowed_stack=0;


reg perform_io_mem_read_output;


wire [31:0] muxed_target_address_executer;
wire [15:0] muxed_data_in [3:0];

wire [2:0] muxed_access_length;
wire [2:0] muxed_access_length0;
wire [2:0] muxed_access_length1;
wire muxed_is_byte_op;
wire muxed_is_write_op;

mem_inter_mux mem_inter_mux_inst(
	muxed_target_address_executer,
	muxed_data_in,
	muxed_access_length,
	muxed_access_length0,
	muxed_access_length1,
	muxed_is_byte_op,
	muxed_is_write_op,
	
	target_address_executer,
	data_in,
	stack_access_size,
	stack_access_size0,
	stack_access_size1,
	is_general_access_byte_operation,
	is_access_write,
	
	suggest4[2:0]
);
reg [4:0] tt_access_index_at_phase3=0;
wire [4:0] effective_tt_access_index_at_phase3;
assign effective_tt_access_index_at_phase3=tt_access_index_at_phase3 & {5{tick_tock_phase2_moved}};
reg [4:0] tt_access_index_at_phase3_test;
always_comb tt_access_index_at_phase3_test=tt_access_index[tick_tock_phase3];
always @(posedge main_clk) begin
	if (tick_tock_phase3!=tick_tock_phase2) begin
		assert(tt_access_index_at_phase3_test===tt_access_index_at_phase3);
		assert(tick_tock_phase2_moved===1'b1);
	end else begin
		assert(tick_tock_phase2_moved===1'b0);
	end
end
wire is_ack_executer_for_mem_access;
assign is_ack_executer_for_mem_access=(tick_tock_phase2_moved && tt_access_index_at_phase3>=5'd8 && tt_access_index_at_phase3<=5'd23)? 1'b1:1'b0;

wire [4:0] tt_access_index_at_phase2;
assign tt_access_index_at_phase2=tt_access_index[tick_tock_phase2];
always @(posedge main_clk) begin
	tt_access_index_at_phase3<=tt_access_index_at_phase2;
	if (void_instruction_fetch && (tt_access_index_at_phase2==5'd4 || tt_access_index_at_phase2==5'd5)) tt_access_index_at_phase3<=0;
end

wire [7:0] raw_out_index0;
wire [7:0] raw_out_index1;
decode3 lc_decode3_raw_out_index0(raw_out_index0,effective_tt_access_index_at_phase3[2:0]);
decode3 lc_decode3_raw_out_index1(raw_out_index1,executer_index_for_io);
wire [4:0] raw_out_info;
wire [4:0] raw_out_info_lc;
assign raw_out_info[0]=(effective_tt_access_index_at_phase3[4:2]!=3'h0)? 1'b1:1'b0;
assign raw_out_info[1]=effective_tt_access_index_at_phase3[4] ^ effective_tt_access_index_at_phase3[3];
assign raw_out_info[2]=effective_tt_access_index_at_phase3[4] & effective_tt_access_index_at_phase3[3];
assign raw_out_info[3]=(!raw_out_info_lc[0] && state_for_io_is_5 && !is_waiting_on_second_overflowed_stack)? 1'b1:1'b0;
assign raw_out_info[4]=(((!raw_out_info_lc[0] && state_for_io_is_5 && !is_waiting_on_second_overflowed_stack) || state_for_io_is_7))? 1'b1:1'b0;
lcell_5 lc_raw_out_info(raw_out_info_lc,raw_out_info);

lcell_8 lc_is_general_or_stack_access_acknowledged_pulse(is_general_or_stack_access_acknowledged_pulse,(raw_out_index0 & {8{raw_out_info_lc[1]}}) | (raw_out_index1 & {8{raw_out_info_lc[4]}}));
lcell_8 lc_is_first_overflowed_stack_ready(is_first_overflowed_stack_ready,(raw_out_index0 & {8{raw_out_info[2]}}));

assign is_instruction_fetch_0_acknowledged_pulse=(effective_tt_access_index_at_phase3==5'd4)? 1'b1:1'b0;
assign is_instruction_fetch_1_acknowledged_pulse=(effective_tt_access_index_at_phase3==5'd5)? 1'b1:1'b0;
assign perform_io_mem_read_output=raw_out_info[3];

/*
always_comb begin
	perform_io_mem_read_output=1'b0;
	is_instruction_fetch_0_acknowledged_pulse=1'b0;
	is_instruction_fetch_1_acknowledged_pulse=1'b0;
	is_general_or_stack_access_acknowledged_pulse=8'b0;
	is_first_overflowed_stack_ready=8'b0;
	if (tick_tock_phase3!=tick_tock_phase2) begin
		unique case (tt_access_index_at_phase3)
		 0:begin end // yes, 0 is possible, it happens when an instruction fetch is voided
		 4:is_instruction_fetch_0_acknowledged_pulse=!void_instruction_fetch;
		 5:is_instruction_fetch_1_acknowledged_pulse=!void_instruction_fetch;

		 8:is_general_or_stack_access_acknowledged_pulse[0]=1'b1;
		 9:is_general_or_stack_access_acknowledged_pulse[1]=1'b1;
		10:is_general_or_stack_access_acknowledged_pulse[2]=1'b1;
		11:is_general_or_stack_access_acknowledged_pulse[3]=1'b1;
		12:is_general_or_stack_access_acknowledged_pulse[4]=1'b1;
		13:is_general_or_stack_access_acknowledged_pulse[5]=1'b1;
		14:is_general_or_stack_access_acknowledged_pulse[6]=1'b1;
		15:is_general_or_stack_access_acknowledged_pulse[7]=1'b1;

		16:is_general_or_stack_access_acknowledged_pulse[0]=1'b1;
		17:is_general_or_stack_access_acknowledged_pulse[1]=1'b1;
		18:is_general_or_stack_access_acknowledged_pulse[2]=1'b1;
		19:is_general_or_stack_access_acknowledged_pulse[3]=1'b1;
		20:is_general_or_stack_access_acknowledged_pulse[4]=1'b1;
		21:is_general_or_stack_access_acknowledged_pulse[5]=1'b1;
		22:is_general_or_stack_access_acknowledged_pulse[6]=1'b1;
		23:is_general_or_stack_access_acknowledged_pulse[7]=1'b1;

		24:is_first_overflowed_stack_ready[0]=1'b1;
		25:is_first_overflowed_stack_ready[1]=1'b1;
		26:is_first_overflowed_stack_ready[2]=1'b1;
		27:is_first_overflowed_stack_ready[3]=1'b1;
		28:is_first_overflowed_stack_ready[4]=1'b1;
		29:is_first_overflowed_stack_ready[5]=1'b1;
		30:is_first_overflowed_stack_ready[6]=1'b1;
		31:is_first_overflowed_stack_ready[7]=1'b1;
		endcase
	end else if ((state_for_io==3'd5) && !is_waiting_on_second_overflowed_stack) begin
		perform_io_mem_read_output=1'b1;
		is_general_or_stack_access_acknowledged_pulse[executer_index_for_io]=1'b1;
	end
	if (state_for_io==3'd7) begin
		is_general_or_stack_access_acknowledged_pulse[executer_index_for_io]=1'b1;
	end
end
*/

reg [1:0] next_overflowed_stack_shift_value=2'hx;

always @(posedge main_clk) begin
	tick_tock_phase3<=tick_tock_phase2;
	
	is_waiting_on_second_overflowed_stack<=(is_ack_executer_for_mem_access)? 1'b0:(is_waiting_on_second_overflowed_stack || (is_first_overflowed_stack_ready!=8'd0));
	
	if (is_ack_executer_for_mem_access && is_waiting_on_second_overflowed_stack) begin
		unique case (next_overflowed_stack_shift_value)
		0:cd_access_out_full_data_saved[4:1]<=cd_access_out_full_data[3:0];
		1:cd_access_out_full_data_saved[4:2]<=cd_access_out_full_data[2:0];
		2:cd_access_out_full_data_saved[4:3]<=cd_access_out_full_data[1:0];
		3:cd_access_out_full_data_saved[4  ]<=cd_access_out_full_data[  0];
		endcase
	end else if (is_ack_executer_for_mem_access) begin
		cd_access_out_full_data_saved<=cd_access_out_full_data;
	end else if (is_first_overflowed_stack_ready!=8'd0) begin
		cd_access_out_full_data_saved<=cd_access_out_full_data;
		next_overflowed_stack_shift_value<=stack_access_size0[tt_access_index_at_phase3[2:0]][1:0];
	end
	if (perform_io_mem_read_output) begin
		cd_access_out_full_data_saved[0]<=data_out_io;
	end
end

wire [31:0] muxed_tt_address;
lcell_32 lc_muxed_tt_address(muxed_tt_address,(next_new_index[4:3]==2'd0)?muxed_instruction_fetch_address:muxed_target_address_executer);
wire [2:0] muxed_tt_access_length;
lcell_3 lc_tt_muxed_access_length(muxed_tt_access_length,
	((next_new_index[4:3]==2'd0)? 3'd7:3'd0) | 
	((next_new_index[4:3]==2'd2)? muxed_access_length :3'd0) | 
	((next_new_index[4:3]==2'd3)? muxed_access_length0:3'd0)
);
wire muxed_tt_is_byte_op;
lcell_1 lc_muxed_tt_is_byte_op(muxed_tt_is_byte_op,(next_new_index[4:3]==2'd1)? muxed_is_byte_op:1'd0);
wire muxed_tt_is_write_op;
lcell_1 lc_muxed_tt_is_write_op(muxed_tt_is_write_op,(next_new_index[4:3]!=2'd0)? muxed_is_write_op:1'd0);

wire [2:0] swap0_tt_access_length;
wire [2:0] swap1_tt_access_length;
wire [15:0] swap0_tt_data [3:0];
wire [15:0] swap1_tt_data [3:0];

assign swap0_tt_access_length= (tick_tock_phase0[0])?muxed_access_length1:muxed_tt_access_length;
assign swap1_tt_access_length=!(tick_tock_phase0[0])?muxed_access_length1:muxed_tt_access_length;

wire write_new_request_at0;
wire write_new_request_at1;
lcell_1 lc_write_new_request_at0(write_new_request_at0,(next_new_index[4:2]!=3'd0 && (next_new_index[4:3]==2'd3 || tick_tock_phase0[0]==1'b0))? 1'b1:1'b0);
lcell_1 lc_write_new_request_at1(write_new_request_at1,(next_new_index[4:2]!=3'd0 && (next_new_index[4:3]==2'd3 || tick_tock_phase0[0]==1'b1))? 1'b1:1'b0);

always @(posedge main_clk) begin
	if (void_instruction_fetch) begin
		resolving_memory_access_from_instruction_fetch[0]<=1'b0;
		resolving_memory_access_from_instruction_fetch[1]<=1'b0;
		/*
		if (tt_access_index[0]==5'd4 || tt_access_index[0]==5'd5) tt_access_index[0]<=5'd0;
		if (tt_access_index[1]==5'd4 || tt_access_index[1]==5'd5) tt_access_index[1]<=5'd0;
		if (tt_access_index[2]==5'd4 || tt_access_index[2]==5'd5) tt_access_index[2]<=5'd0;
		if (tt_access_index[3]==5'd4 || tt_access_index[3]==5'd5) tt_access_index[3]<=5'd0;
		*/
	end
	tick_tock_phase0<=(tick_tock_phase0 + write_new_request_at0) + write_new_request_at1;
	/*
	if (write_new_request_at0 || write_new_request_at1) begin
		unique case ({((write_new_request_at0 && write_new_request_at1)? 1'b1:1'b0),tick_tock_phase0})
		3'b000:begin tt_access_index[0]<=next_new_index;end
		3'b001:begin tt_access_index[1]<=next_new_index;end
		3'b010:begin tt_access_index[2]<=next_new_index;end
		3'b011:begin tt_access_index[3]<=next_new_index;end
		3'b100:begin tt_access_index[0]<=next_new_index;tt_access_index[1]<=next_new_index ^ 5'd8;end
		3'b101:begin tt_access_index[1]<=next_new_index;tt_access_index[2]<=next_new_index ^ 5'd8;end
		3'b110:begin tt_access_index[2]<=next_new_index;tt_access_index[3]<=next_new_index ^ 5'd8;end
		3'b111:begin tt_access_index[3]<=next_new_index;tt_access_index[0]<=next_new_index ^ 5'd8;end
		endcase
	end
	*/
	if (is_accepting_into_any[0]) tt_access_index[0]<=is_accepting_into_typical[0]?(next_new_index ^ (is_accepting_into_alt[0]? 5'd8:5'd0)):(5'd0);
	if (is_accepting_into_any[1]) tt_access_index[1]<=is_accepting_into_typical[1]?(next_new_index ^ (is_accepting_into_alt[1]? 5'd8:5'd0)):(5'd0);
	if (is_accepting_into_any[2]) tt_access_index[2]<=is_accepting_into_typical[2]?(next_new_index ^ (is_accepting_into_alt[2]? 5'd8:5'd0)):(5'd0);
	if (is_accepting_into_any[3]) tt_access_index[3]<=is_accepting_into_typical[3]?(next_new_index ^ (is_accepting_into_alt[3]? 5'd8:5'd0)):(5'd0);
	if (write_new_request_at0) begin
		tt_address[0]<=muxed_tt_address[30:0];
		tt_data[0]<=muxed_data_in;
		tt_access_length[0]<=swap0_tt_access_length;
		tt_is_write_op[0]<=muxed_tt_is_write_op;
		tt_is_byte_op[0]<=muxed_tt_is_byte_op;
		tt_move[0]<=3;
		tt_secondary[0]<=0;
	end
	if (write_new_request_at1) begin
		tt_address[1]<=muxed_tt_address[30:0];
		tt_data[1]<=muxed_data_in;
		tt_access_length[1]<=swap1_tt_access_length;
		tt_is_write_op[1]<=muxed_tt_is_write_op;
		tt_is_byte_op[1]<=muxed_tt_is_byte_op;
		tt_move[1]<=3;
		tt_secondary[1]<=0;
	end
	if (write_new_request_at0 && write_new_request_at1) begin
		if (tick_tock_phase0[0]) begin tt_move[0]<=muxed_access_length0[1:0];tt_secondary[0]<=1;end
		else                     begin tt_move[1]<=muxed_access_length0[1:0];tt_secondary[1]<=1;end
	end
	if (next_new_index[4:2]==3'd0) assert (next_new_index==5'd0);
	
	memory_dependency_clear<=0;
	if (next_new_index>=5'd8) memory_dependency_clear[next_new_index[2:0]]<=1'b1;
	
	if (is_general_or_stack_access_acknowledged_pulse[0]) resolving_memory_access_from_executer[0]<=1'b0;
	if (is_general_or_stack_access_acknowledged_pulse[1]) resolving_memory_access_from_executer[1]<=1'b0;
	if (is_general_or_stack_access_acknowledged_pulse[2]) resolving_memory_access_from_executer[2]<=1'b0;
	if (is_general_or_stack_access_acknowledged_pulse[3]) resolving_memory_access_from_executer[3]<=1'b0;
	if (is_general_or_stack_access_acknowledged_pulse[4]) resolving_memory_access_from_executer[4]<=1'b0;
	if (is_general_or_stack_access_acknowledged_pulse[5]) resolving_memory_access_from_executer[5]<=1'b0;
	if (is_general_or_stack_access_acknowledged_pulse[6]) resolving_memory_access_from_executer[6]<=1'b0;
	if (is_general_or_stack_access_acknowledged_pulse[7]) resolving_memory_access_from_executer[7]<=1'b0;
	if (is_instruction_fetch_0_acknowledged_pulse_delayed) resolving_memory_access_from_instruction_fetch[0]<=1'b0;
	if (is_instruction_fetch_1_acknowledged_pulse_delayed) resolving_memory_access_from_instruction_fetch[1]<=1'b0;
	
	unique case (next_new_index)
	 0:begin end
	 4:resolving_memory_access_from_instruction_fetch[0]<=1'b1;
	 5:resolving_memory_access_from_instruction_fetch[1]<=1'b1;

	 8:resolving_memory_access_from_executer[0]<=1'b1;
	 9:resolving_memory_access_from_executer[1]<=1'b1;
	10:resolving_memory_access_from_executer[2]<=1'b1;
	11:resolving_memory_access_from_executer[3]<=1'b1;
	12:resolving_memory_access_from_executer[4]<=1'b1;
	13:resolving_memory_access_from_executer[5]<=1'b1;
	14:resolving_memory_access_from_executer[6]<=1'b1;
	15:resolving_memory_access_from_executer[7]<=1'b1;

	16:resolving_memory_access_from_executer[0]<=1'b1;
	17:resolving_memory_access_from_executer[1]<=1'b1;
	18:resolving_memory_access_from_executer[2]<=1'b1;
	19:resolving_memory_access_from_executer[3]<=1'b1;
	20:resolving_memory_access_from_executer[4]<=1'b1;
	21:resolving_memory_access_from_executer[5]<=1'b1;
	22:resolving_memory_access_from_executer[6]<=1'b1;
	23:resolving_memory_access_from_executer[7]<=1'b1;

	24:resolving_memory_access_from_executer[0]<=1'b1;
	25:resolving_memory_access_from_executer[1]<=1'b1;
	26:resolving_memory_access_from_executer[2]<=1'b1;
	27:resolving_memory_access_from_executer[3]<=1'b1;
	28:resolving_memory_access_from_executer[4]<=1'b1;
	29:resolving_memory_access_from_executer[5]<=1'b1;
	30:resolving_memory_access_from_executer[6]<=1'b1;
	31:resolving_memory_access_from_executer[7]<=1'b1;
	endcase
	
	unique case (state_for_io)
	0:begin
		     if (is_general_access_requesting[0] && target_address_executer[0][31]) begin state_for_io<=1;executer_index_for_io<=0;memory_dependency_clear[0]<=1'b1;end
		else if (is_general_access_requesting[1] && target_address_executer[1][31]) begin state_for_io<=1;executer_index_for_io<=1;memory_dependency_clear[1]<=1'b1;end
		else if (is_general_access_requesting[2] && target_address_executer[2][31]) begin state_for_io<=1;executer_index_for_io<=2;memory_dependency_clear[2]<=1'b1;end
		else if (is_general_access_requesting[3] && target_address_executer[3][31]) begin state_for_io<=1;executer_index_for_io<=3;memory_dependency_clear[3]<=1'b1;end
		else if (is_general_access_requesting[4] && target_address_executer[4][31]) begin state_for_io<=1;executer_index_for_io<=4;memory_dependency_clear[4]<=1'b1;end
		else if (is_general_access_requesting[5] && target_address_executer[5][31]) begin state_for_io<=1;executer_index_for_io<=5;memory_dependency_clear[5]<=1'b1;end
		else if (is_general_access_requesting[6] && target_address_executer[6][31]) begin state_for_io<=1;executer_index_for_io<=6;memory_dependency_clear[6]<=1'b1;end
		else if (is_general_access_requesting[7] && target_address_executer[7][31]) begin state_for_io<=1;executer_index_for_io<=7;memory_dependency_clear[7]<=1'b1;end
	end
	1:begin
		state_for_io<=2;
		address_io[30:0]<=target_address_executer[executer_index_for_io][30:0];
		address_io[31]<=1;
		data_in_io<=data_in[executer_index_for_io][0];
		control_io[0]<=is_general_access_byte_operation[executer_index_for_io];
		control_io[1]<=is_access_write[executer_index_for_io];
	end
	2:begin
		state_for_io<=3;
		address_io[31]<=0;
	end
	3:begin
		state_for_io<=4;
	end
	4:begin
		data_out_io<=data_out_io_extern;
		if (control_io[1]) begin
			state_for_io<=7;
			state_for_io_is_7<=1;
		end else begin
			state_for_io<=5;
			state_for_io_is_5<=1;
		end
	end
	5:begin
		if (perform_io_mem_read_output) begin
			state_for_io<=6;
			state_for_io_is_5<=0;
		end
	end
	6:begin
		state_for_io<=0;
	end
	7:begin
		state_for_io<=0;
		state_for_io_is_7<=0;
	end
	endcase
end

memory_system memory_system_inst(
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
	
	tick_tock_phase0,
	tick_tock_phase1,
	tick_tock_phase2,
	tick_tock_phase2_moved,
	
	tt_address,
	tt_data[0],
	tt_data[1],
	tt_move,
	tt_secondary,
	tt_access_length,
	tt_is_byte_op,
	tt_is_write_op,
	
	cd_access_out_full_data,
	
	main_clk
);

endmodule