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
	
	// for all memory access ports, once a request has begun to be issued, it should not be changed before it is acknowledged. hyper_instruction_fetch has a void signal that allows it to change
	
	input  [ 2:0] stack_access_size [7:0], // stack_access_size value signifies a number of words one greater then it's value
	input  [7:0] is_stack_access_requesting_extern,
	
	input  [31:0] target_address_executer [7:0],
	// target_address_executer is allowed to access I/O mapped memory regions and can be any type of memory access only when is_general_access_requesting , not when is_stack_access_requesting
	input  [15:0] data_in [7:0][3:0],
	
	input  [7:0] is_access_write,
	input  [7:0] is_general_access_byte_operation,
	input  [7:0] is_general_access_requesting_extern,

	output [7:0] is_general_or_stack_access_acknowledged_pulse_extern,
	
	input  [25:0] target_address_hyper_instruction_fetch_0,
	input  [25:0] target_address_hyper_instruction_fetch_1,
	// target_address_hyper_instruction_fetch_x is very similiar to target_address_instruction_fetch
	// However, it will NEVER cause a cache fault to DRAM because it is a suggestion to read memory when it is unknown if memory at that location will actually be needed.
	// This request is always serviced at miniumum priority, therefore all other accesses will occur before either of these accesses occure.
	// Further, if target_address_hyper_instruction_fetch_0 is not in cache, then target_address_hyper_instruction_fetch_1 will not be accessed.
	// target_address_hyper_instruction_fetch_0 will always be served before target_address_hyper_instruction_fetch_1
	// these accesses use data_out_type_0_extern
	
	input  is_hyper_instruction_fetch_0_requesting_extern,
	output is_hyper_instruction_fetch_0_acknowledged_pulse_extern,
	input  is_hyper_instruction_fetch_1_requesting_extern,
	output is_hyper_instruction_fetch_1_acknowledged_pulse_extern,
	
	input void_hyper_instruction_fetch, // when on, this will void any in-progress hyper instruction fetches. This is needed to ensure validity in some edge cases. it does NOT void the request that is being requested on the same cycle that this is on
	
	input  [25:0] target_address_instruction_fetch,
	// target_address_instruction_fetch is not allowed to access I/O mapped memory regions, and must be a word read. 
	// the entire cache lane at and past the requested word is given. The amount of valid words returned is trivial to calculate elsewhere, so it is not given
	// this access uses data_out_type_0_extern
	
	input  is_instruction_fetch_requesting_extern,
	output is_instruction_fetch_acknowledged_pulse_extern,
	
	output [15:0] data_out_type_0_extern [7:0], // type_0 is for instruction fetch [note that type_0 is NOT delayed after it's acknowledgement, it's data is given on the same clock cycle]
	output [15:0] data_out_type_1_extern [7:0], // type_1 is for executers [note that type_1 is delayed by one clock cycle past it's acknowledgement]
	
	output [7:0] memory_dependency_clear_extern,
	
	input  [15:0] data_out_io_extern,
	output [15:0] data_in_io_extern,
	output [31:0] address_io_extern,
	output [1:0] control_io_extern,
	
	input  main_clk
);

reg is_instruction_fetch_acknowledged_pulse_delayed=0;
reg is_hyper_instruction_fetch_0_acknowledged_pulse_delayed=0;
reg is_hyper_instruction_fetch_1_acknowledged_pulse_delayed=0;

reg is_instruction_fetch_acknowledged_pulse;
reg is_hyper_instruction_fetch_0_acknowledged_pulse;
reg is_hyper_instruction_fetch_1_acknowledged_pulse;
reg [7:0] is_general_or_stack_access_acknowledged_pulse;
reg [7:0] memory_dependency_clear=0;

assign is_instruction_fetch_acknowledged_pulse_extern=is_instruction_fetch_acknowledged_pulse_delayed;
assign is_hyper_instruction_fetch_0_acknowledged_pulse_extern=is_hyper_instruction_fetch_0_acknowledged_pulse_delayed & ~void_hyper_instruction_fetch;
assign is_hyper_instruction_fetch_1_acknowledged_pulse_extern=is_hyper_instruction_fetch_1_acknowledged_pulse_delayed & ~void_hyper_instruction_fetch;
assign is_general_or_stack_access_acknowledged_pulse_extern=is_general_or_stack_access_acknowledged_pulse;
assign memory_dependency_clear_extern=memory_dependency_clear;

wire is_instruction_fetch_requesting=is_instruction_fetch_requesting_extern & ~is_instruction_fetch_acknowledged_pulse & ~is_instruction_fetch_acknowledged_pulse_delayed;
wire is_hyper_instruction_fetch_0_requesting=is_hyper_instruction_fetch_0_requesting_extern & ~is_hyper_instruction_fetch_0_acknowledged_pulse & ~is_hyper_instruction_fetch_0_acknowledged_pulse_delayed;
wire is_hyper_instruction_fetch_1_requesting=is_hyper_instruction_fetch_1_requesting_extern & ~is_hyper_instruction_fetch_1_acknowledged_pulse & ~is_hyper_instruction_fetch_1_acknowledged_pulse_delayed;
wire [7:0] is_stack_access_requesting=is_stack_access_requesting_extern & ~is_general_or_stack_access_acknowledged_pulse;
wire [7:0] is_general_access_requesting=is_general_access_requesting_extern & ~is_general_or_stack_access_acknowledged_pulse;

always @(posedge main_clk) begin
	is_instruction_fetch_acknowledged_pulse_delayed<=is_instruction_fetch_acknowledged_pulse;
	is_hyper_instruction_fetch_0_acknowledged_pulse_delayed<=is_hyper_instruction_fetch_0_acknowledged_pulse;
	is_hyper_instruction_fetch_1_acknowledged_pulse_delayed<=is_hyper_instruction_fetch_1_acknowledged_pulse;
end

reg [15:0] data_out_io=0;
reg [15:0] data_in_io=0;
reg [31:0] address_io=0;
reg [1:0] control_io=0;
reg [2:0] executer_index_for_io=0;
reg [2:0] state_for_io=0;
assign data_in_io_extern=data_in_io;
assign address_io_extern=address_io;
assign control_io_extern=control_io;


reg  [1:0] tick_tock_phase0=0;
wire [1:0] tick_tock_phase2;
reg  [1:0] tick_tock_phase3=0;


reg [30:0] tt_address [1:0]='{0,0};
reg [15:0] tt_data [1:0][3:0];
reg [2:0] tt_access_length [1:0]='{0,0}; // access_length is only required to be correct for writes, otherwise it may be assigned 7 . Also, it's value signifies a number of words one greater then it's value
reg tt_is_hyperfetch [1:0]='{0,0};
reg tt_is_byte_op [1:0]='{0,0};
reg tt_is_write_op [1:0]='{0,0};
reg [4:0] tt_access_index [1:0]='{0,0};


wire soft_fault;
wire [15:0] cd_access_out_full_data [7:0];
reg [15:0] cd_access_out_full_data_saved [7:0];
reg [15:0] cd_access_out_full_data_delayed [7:0];
assign data_out_type_0_extern=cd_access_out_full_data_delayed;
assign data_out_type_1_extern=cd_access_out_full_data_saved;

always @(posedge main_clk) cd_access_out_full_data_delayed<=cd_access_out_full_data;

reg [7:0] is_stack_access_overflowing; // this is if the stack access will need two accesses for two cache lanes [does not check if the access is actually requesting]

reg [2:0] stack_access_size0 [7:0]; // if overflowed, this is the size of the second (lower) access
reg [2:0] stack_access_size1 [7:0]; // if overflowed, this is the size of the first (upper) access
reg [31:0] target_address_executer_alt [7:0]; // if overflowed, this is the address for the first (upper) access
reg [15:0] data_in_alt [7:0][3:0]; // if overflowed, this is the data for the first (upper) access

reg [3:0] temp_stack_max_address [7:0];
always_comb begin
	temp_stack_max_address[0]=stack_access_size[0]+{1'b0,target_address_executer[0][3:1]};
	temp_stack_max_address[1]=stack_access_size[1]+{1'b0,target_address_executer[1][3:1]};
	temp_stack_max_address[2]=stack_access_size[2]+{1'b0,target_address_executer[2][3:1]};
	temp_stack_max_address[3]=stack_access_size[3]+{1'b0,target_address_executer[3][3:1]};
	is_stack_access_overflowing[0]=temp_stack_max_address[0][3];
	is_stack_access_overflowing[1]=temp_stack_max_address[1][3];
	is_stack_access_overflowing[2]=temp_stack_max_address[2][3];
	is_stack_access_overflowing[3]=temp_stack_max_address[3][3];
	
	stack_access_size0[0]=3'd7-target_address_executer[0][3:1];
	stack_access_size0[1]=3'd7-target_address_executer[1][3:1];
	stack_access_size0[2]=3'd7-target_address_executer[2][3:1];
	stack_access_size0[3]=3'd7-target_address_executer[3][3:1];
	stack_access_size1[0]=stack_access_size[0]-stack_access_size0[0];
	stack_access_size1[1]=stack_access_size[1]-stack_access_size0[1];
	stack_access_size1[2]=stack_access_size[2]-stack_access_size0[2];
	stack_access_size1[3]=stack_access_size[3]-stack_access_size0[3];
	
	target_address_executer_alt[0]=target_address_executer[0][30:0]+5'd16;
	target_address_executer_alt[1]=target_address_executer[1][30:0]+5'd16;
	target_address_executer_alt[2]=target_address_executer[2][30:0]+5'd16;
	target_address_executer_alt[3]=target_address_executer[3][30:0]+5'd16;
	target_address_executer_alt[0][3:0]=4'd0;
	target_address_executer_alt[1][3:0]=4'd0;
	target_address_executer_alt[2][3:0]=4'd0;
	target_address_executer_alt[3][3:0]=4'd0;
	
	data_in_alt[0]='{16'hx,16'hx,16'hx,16'hx};
	case (stack_access_size0[0][1:0])
	0:data_in_alt[0][2:0]=data_in[0][3:1];
	1:data_in_alt[0][1:0]=data_in[0][3:2];
	2:data_in_alt[0][  0]=data_in[0][3  ];
	3:begin end
	endcase
	data_in_alt[1]='{16'hx,16'hx,16'hx,16'hx};
	case (stack_access_size0[1][1:0])
	0:data_in_alt[1][2:0]=data_in[1][3:1];
	1:data_in_alt[1][1:0]=data_in[1][3:2];
	2:data_in_alt[1][  0]=data_in[1][3  ];
	3:begin end
	endcase
	data_in_alt[2]='{16'hx,16'hx,16'hx,16'hx};
	case (stack_access_size0[2][1:0])
	0:data_in_alt[2][2:0]=data_in[2][3:1];
	1:data_in_alt[2][1:0]=data_in[2][3:2];
	2:data_in_alt[2][  0]=data_in[2][3  ];
	3:begin end
	endcase
	data_in_alt[3]='{16'hx,16'hx,16'hx,16'hx};
	case (stack_access_size0[3][1:0])
	0:data_in_alt[3][2:0]=data_in[3][3:1];
	1:data_in_alt[3][1:0]=data_in[3][3:2];
	2:data_in_alt[3][  0]=data_in[3][3  ];
	3:begin end
	endcase
	
	temp_stack_max_address[4]=stack_access_size[4]+{1'b0,target_address_executer[4][3:1]};
	temp_stack_max_address[5]=stack_access_size[5]+{1'b0,target_address_executer[5][3:1]};
	temp_stack_max_address[6]=stack_access_size[6]+{1'b0,target_address_executer[6][3:1]};
	temp_stack_max_address[7]=stack_access_size[7]+{1'b0,target_address_executer[7][3:1]};
	is_stack_access_overflowing[4]=temp_stack_max_address[4][3];
	is_stack_access_overflowing[5]=temp_stack_max_address[5][3];
	is_stack_access_overflowing[6]=temp_stack_max_address[6][3];
	is_stack_access_overflowing[7]=temp_stack_max_address[7][3];
	
	stack_access_size0[4]=3'd7-target_address_executer[4][3:1];
	stack_access_size0[5]=3'd7-target_address_executer[5][3:1];
	stack_access_size0[6]=3'd7-target_address_executer[6][3:1];
	stack_access_size0[7]=3'd7-target_address_executer[7][3:1];
	stack_access_size1[4]=stack_access_size[4]-stack_access_size0[4];
	stack_access_size1[5]=stack_access_size[5]-stack_access_size0[5];
	stack_access_size1[6]=stack_access_size[6]-stack_access_size0[6];
	stack_access_size1[7]=stack_access_size[7]-stack_access_size0[7];
	
	target_address_executer_alt[4]=target_address_executer[4][30:0]+5'd16;
	target_address_executer_alt[5]=target_address_executer[5][30:0]+5'd16;
	target_address_executer_alt[6]=target_address_executer[6][30:0]+5'd16;
	target_address_executer_alt[7]=target_address_executer[7][30:0]+5'd16;
	target_address_executer_alt[4][3:0]=4'd0;
	target_address_executer_alt[5][3:0]=4'd0;
	target_address_executer_alt[6][3:0]=4'd0;
	target_address_executer_alt[7][3:0]=4'd0;
	
	data_in_alt[4]='{16'hx,16'hx,16'hx,16'hx};
	case (stack_access_size0[4][1:0])
	0:data_in_alt[4][2:0]=data_in[4][3:1];
	1:data_in_alt[4][1:0]=data_in[4][3:2];
	2:data_in_alt[4][  0]=data_in[4][3  ];
	3:begin end
	endcase
	data_in_alt[5]='{16'hx,16'hx,16'hx,16'hx};
	case (stack_access_size0[5][1:0])
	0:data_in_alt[5][2:0]=data_in[5][3:1];
	1:data_in_alt[5][1:0]=data_in[5][3:2];
	2:data_in_alt[5][  0]=data_in[5][3  ];
	3:begin end
	endcase
	data_in_alt[6]='{16'hx,16'hx,16'hx,16'hx};
	case (stack_access_size0[6][1:0])
	0:data_in_alt[6][2:0]=data_in[6][3:1];
	1:data_in_alt[6][1:0]=data_in[6][3:2];
	2:data_in_alt[6][  0]=data_in[6][3  ];
	3:begin end
	endcase
	data_in_alt[7]='{16'hx,16'hx,16'hx,16'hx};
	case (stack_access_size0[7][1:0])
	0:data_in_alt[7][2:0]=data_in[7][3:1];
	1:data_in_alt[7][1:0]=data_in[7][3:2];
	2:data_in_alt[7][  0]=data_in[7][3  ];
	3:begin end
	endcase
	
end

reg [4:0] next_new_index_working;
wire [4:0] next_new_index;
lcell_5 lc_next_new_index(next_new_index,next_new_index_working);
reg current_0;
reg current_1;
reg [4:0] current_index;
reg [1:0] phase_diff;

always_comb begin
	phase_diff=tick_tock_phase0 - tick_tock_phase2;
	current_0=(phase_diff==2'd0)?1'b1:1'b0;
	current_1=(phase_diff==2'd1)?1'b1:1'b0;
	current_index=tt_access_index[tick_tock_phase2[0]] & {5{current_1}};
end
always_comb begin
	next_new_index_working=0;
	if (current_0 || current_1) begin
		if (current_index!=5'd3  && is_hyper_instruction_fetch_1_requesting) next_new_index_working= 3;
		if (current_index!=5'd2  && is_hyper_instruction_fetch_0_requesting) next_new_index_working= 2;
		
		if (current_index!=5'd15 && is_general_access_requesting[7] && !target_address_executer[7][31]) next_new_index_working=15;
		if (current_index!=5'd14 && is_general_access_requesting[6] && !target_address_executer[6][31]) next_new_index_working=14;
		if (current_index!=5'd13 && is_general_access_requesting[5] && !target_address_executer[5][31]) next_new_index_working=13;
		if (current_index!=5'd12 && is_general_access_requesting[4] && !target_address_executer[4][31]) next_new_index_working=12;
		
		if (current_index!=5'd11 && is_general_access_requesting[3] && !target_address_executer[3][31]) next_new_index_working=11;
		if (current_index!=5'd10 && is_general_access_requesting[2] && !target_address_executer[2][31]) next_new_index_working=10;
		if (current_index!=5'd9  && is_general_access_requesting[1] && !target_address_executer[1][31]) next_new_index_working= 9;
		if (current_index!=5'd8  && is_general_access_requesting[0] && !target_address_executer[0][31]) next_new_index_working= 8;

		if (current_index!=5'd23 && is_stack_access_requesting[7] && !is_stack_access_overflowing[7]) next_new_index_working=23;
		if (current_index!=5'd22 && is_stack_access_requesting[6] && !is_stack_access_overflowing[6]) next_new_index_working=22;
		if (current_index!=5'd21 && is_stack_access_requesting[5] && !is_stack_access_overflowing[5]) next_new_index_working=21;
		if (current_index!=5'd20 && is_stack_access_requesting[4] && !is_stack_access_overflowing[4]) next_new_index_working=20;
		
		if (current_index!=5'd19 && is_stack_access_requesting[3] && !is_stack_access_overflowing[3]) next_new_index_working=19;
		if (current_index!=5'd18 && is_stack_access_requesting[2] && !is_stack_access_overflowing[2]) next_new_index_working=18;
		if (current_index!=5'd17 && is_stack_access_requesting[1] && !is_stack_access_overflowing[1]) next_new_index_working=17;
		if (current_index!=5'd16 && is_stack_access_requesting[0] && !is_stack_access_overflowing[0]) next_new_index_working=16;
		
		if (current_index!=5'd1  && is_instruction_fetch_requesting) next_new_index_working= 1;
	end
	if (current_0) begin
		if (is_stack_access_requesting[7] && is_stack_access_overflowing[7]) next_new_index_working=31;
		if (is_stack_access_requesting[6] && is_stack_access_overflowing[6]) next_new_index_working=30;
		if (is_stack_access_requesting[5] && is_stack_access_overflowing[5]) next_new_index_working=29;
		if (is_stack_access_requesting[4] && is_stack_access_overflowing[4]) next_new_index_working=28;

		if (is_stack_access_requesting[3] && is_stack_access_overflowing[3]) next_new_index_working=27;
		if (is_stack_access_requesting[2] && is_stack_access_overflowing[2]) next_new_index_working=26;
		if (is_stack_access_requesting[1] && is_stack_access_overflowing[1]) next_new_index_working=25;
		if (is_stack_access_requesting[0] && is_stack_access_overflowing[0]) next_new_index_working=24;
	end
end

reg [7:0] is_first_overflowed_stack_ready;
reg is_waiting_on_second_overflowed_stack=0;


reg perform_io_mem_read_output;


wire [31:0] muxed_target_address_executer;
wire [31:0] muxed_target_address_executer_alt;
wire [15:0] muxed_data_in [3:0];
wire [15:0] muxed_data_in_alt [3:0];
wire [2:0] muxed_access_length;
wire [2:0] muxed_access_length0;
wire [2:0] muxed_access_length1;
wire muxed_is_byte_op;
wire muxed_is_write_op;

mem_inter_mux mem_inter_mux_inst(
	muxed_target_address_executer,
	muxed_target_address_executer_alt,
	muxed_data_in,
	muxed_data_in_alt,
	muxed_access_length,
	muxed_access_length0,
	muxed_access_length1,
	muxed_is_byte_op,
	muxed_is_write_op,
	
	target_address_executer,
	target_address_executer_alt,
	data_in,
	data_in_alt,
	stack_access_size,
	stack_access_size0,
	stack_access_size1,
	is_general_access_byte_operation,
	is_access_write,
	
	next_new_index[2:0]
);

always_comb begin
	perform_io_mem_read_output=1'b0;
	is_instruction_fetch_acknowledged_pulse=1'b0;
	is_hyper_instruction_fetch_0_acknowledged_pulse=1'b0;
	is_hyper_instruction_fetch_1_acknowledged_pulse=1'b0;
	is_general_or_stack_access_acknowledged_pulse=8'b0;
	is_first_overflowed_stack_ready=8'b0;
	if (tick_tock_phase3!=tick_tock_phase2) begin
		unique case (tt_access_index[tick_tock_phase3[0]])
		 0:begin end // yes, 0 is possible, it happens when a hyper instruction fetch is voided
		 1:is_instruction_fetch_acknowledged_pulse=1'b1;
		 2:is_hyper_instruction_fetch_0_acknowledged_pulse=!soft_fault && !void_hyper_instruction_fetch;
		 3:is_hyper_instruction_fetch_1_acknowledged_pulse=!soft_fault && !void_hyper_instruction_fetch;

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
	end else if (state_for_io==3'd5) begin
		perform_io_mem_read_output=1'b1;
		is_general_or_stack_access_acknowledged_pulse[executer_index_for_io]=1'b1;
	end
	if (state_for_io==3'd7) begin
		is_general_or_stack_access_acknowledged_pulse[executer_index_for_io]=1'b1;
	end
end

always @(posedge main_clk) begin
	memory_dependency_clear<=0;
	if (next_new_index>=5'd8) memory_dependency_clear[next_new_index[2:0]]<=1'b1;
	if (state_for_io==3'd1) memory_dependency_clear[executer_index_for_io]<=1'b1;
end

always @(posedge main_clk) begin
	tick_tock_phase3<=tick_tock_phase2;
	
	is_waiting_on_second_overflowed_stack<=(is_general_or_stack_access_acknowledged_pulse!=8'd0)?1'b0:(is_waiting_on_second_overflowed_stack || (is_first_overflowed_stack_ready!=8'd0));
	
	if ((is_general_or_stack_access_acknowledged_pulse!=8'd0) || (is_first_overflowed_stack_ready!=8'd0)) begin
		cd_access_out_full_data_saved<=cd_access_out_full_data;
	end
	
	if ((is_general_or_stack_access_acknowledged_pulse!=8'd0) && is_waiting_on_second_overflowed_stack) begin
		unique case (tt_access_length[tick_tock_phase3[0]][1:0])
		0:cd_access_out_full_data_saved[7:1]<=cd_access_out_full_data_saved[6:0];
		1:cd_access_out_full_data_saved[7:2]<=cd_access_out_full_data_saved[5:0];
		2:cd_access_out_full_data_saved[7:3]<=cd_access_out_full_data_saved[4:0];
		3:cd_access_out_full_data_saved[7:4]<=cd_access_out_full_data_saved[3:0];
		endcase
	end
	if (perform_io_mem_read_output) begin
		cd_access_out_full_data_saved[0]<=data_out_io;
	end
end

always @(posedge main_clk) begin
	unique case (state_for_io)
	0:begin
		if (is_general_access_requesting[7] && target_address_executer[7][31]) begin state_for_io<=1;executer_index_for_io<=7;end
		if (is_general_access_requesting[6] && target_address_executer[6][31]) begin state_for_io<=1;executer_index_for_io<=6;end
		if (is_general_access_requesting[5] && target_address_executer[5][31]) begin state_for_io<=1;executer_index_for_io<=5;end
		if (is_general_access_requesting[4] && target_address_executer[4][31]) begin state_for_io<=1;executer_index_for_io<=4;end
		if (is_general_access_requesting[3] && target_address_executer[3][31]) begin state_for_io<=1;executer_index_for_io<=3;end
		if (is_general_access_requesting[2] && target_address_executer[2][31]) begin state_for_io<=1;executer_index_for_io<=2;end
		if (is_general_access_requesting[1] && target_address_executer[1][31]) begin state_for_io<=1;executer_index_for_io<=1;end
		if (is_general_access_requesting[0] && target_address_executer[0][31]) begin state_for_io<=1;executer_index_for_io<=0;end
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
		if (control_io[1]) state_for_io<=7;
		else state_for_io<=5;
	end
	5:begin
		if (perform_io_mem_read_output) begin
			state_for_io<=6;
		end
	end
	6:begin
		state_for_io<=0;
	end
	7:begin
		state_for_io<=0;
	end
	endcase
end


always @(posedge main_clk) begin
	if (void_hyper_instruction_fetch) begin
		if (tt_access_index[0]==5'd2 || tt_access_index[0]==5'd3) tt_access_index[0]<=5'd0;
		if (tt_access_index[1]==5'd2 || tt_access_index[1]==5'd3) tt_access_index[1]<=5'd0;
	end
	
	if (next_new_index>=5'd24) begin
		tt_access_index[tick_tock_phase0[0]]<=next_new_index -5'd8;
		tt_access_index[tick_tock_phase0[0] ^ 1'b1]<=next_new_index;
	end else if (next_new_index!=5'd0) begin
		tt_access_index[tick_tock_phase0[0]]<=next_new_index;
	end
	
	if (next_new_index!=5'd0 && next_new_index<5'd24) tick_tock_phase0<=tick_tock_phase0+1'd1;
	if (next_new_index>=5'd24) tick_tock_phase0<=tick_tock_phase0+2'd2;
	
	if (tick_tock_phase0[0]) begin
		unique case (next_new_index[4:3])
		0:begin
			unique case (next_new_index[1:0])
			0:begin
			end
			1:begin
				tt_address[1]<=target_address_instruction_fetch;
				tt_data[1]<='{16'hx,16'hx,16'hx,16'hx};
				tt_access_length[1]<=7;
				tt_is_hyperfetch[1]<=0;
				tt_is_byte_op[1]<=0;
				tt_is_write_op[1]<=0;
			end
			2:begin
				tt_address[1]<=target_address_hyper_instruction_fetch_0;
				tt_data[1]<='{16'hx,16'hx,16'hx,16'hx};
				tt_access_length[1]<=7;
				tt_is_hyperfetch[1]<=1;
				tt_is_byte_op[1]<=0;
				tt_is_write_op[1]<=0;
			end
			3:begin
				tt_address[1]<=target_address_hyper_instruction_fetch_1;
				tt_data[1]<='{16'hx,16'hx,16'hx,16'hx};
				tt_access_length[1]<=7;
				tt_is_hyperfetch[1]<=1;
				tt_is_byte_op[1]<=0;
				tt_is_write_op[1]<=0;
			end
			endcase
		end
		1:begin
			tt_address[1]<=muxed_target_address_executer[30:0];
			tt_data[1]<=muxed_data_in;
			tt_access_length[1]<=0;
			tt_is_hyperfetch[1]<=0;
			tt_is_byte_op[1]<=muxed_is_byte_op;
			tt_is_write_op[1]<=muxed_is_write_op;
		end
		2:begin
			tt_address[1]<=muxed_target_address_executer[30:0];
			tt_data[1]<=muxed_data_in;
			tt_access_length[1]<=muxed_access_length;
			tt_is_hyperfetch[1]<=0;
			tt_is_byte_op[1]<=0;
			tt_is_write_op[1]<=muxed_is_write_op;
		end
		3:begin
			tt_address[0]<=muxed_target_address_executer[30:0];
			tt_data[0]<=muxed_data_in;
			tt_access_length[0]<=muxed_access_length0;
			tt_is_hyperfetch[0]<=0;
			tt_is_byte_op[0]<=0;
			tt_is_write_op[0]<=muxed_is_write_op;
			
			tt_address[1]<=muxed_target_address_executer_alt[30:0];
			tt_data[1]<=muxed_data_in_alt;
			tt_access_length[1]<=muxed_access_length1;
			tt_is_hyperfetch[1]<=0;
			tt_is_byte_op[1]<=0;
			tt_is_write_op[1]<=muxed_is_write_op;
		end
		endcase
	end else begin
		unique case (next_new_index[4:3])
		0:begin
			unique case (next_new_index[1:0])
			0:begin
			end
			1:begin
				tt_address[0]<=target_address_instruction_fetch;
				tt_data[0]<='{16'hx,16'hx,16'hx,16'hx};
				tt_access_length[0]<=7;
				tt_is_hyperfetch[0]<=0;
				tt_is_byte_op[0]<=0;
				tt_is_write_op[0]<=0;
			end
			2:begin
				tt_address[0]<=target_address_hyper_instruction_fetch_0;
				tt_data[0]<='{16'hx,16'hx,16'hx,16'hx};
				tt_access_length[0]<=7;
				tt_is_hyperfetch[0]<=1;
				tt_is_byte_op[0]<=0;
				tt_is_write_op[0]<=0;
			end
			3:begin
				tt_address[0]<=target_address_hyper_instruction_fetch_1;
				tt_data[0]<='{16'hx,16'hx,16'hx,16'hx};
				tt_access_length[0]<=7;
				tt_is_hyperfetch[0]<=1;
				tt_is_byte_op[0]<=0;
				tt_is_write_op[0]<=0;
			end
			endcase
		end
		1:begin
			tt_address[0]<=muxed_target_address_executer[30:0];
			tt_data[0]<=muxed_data_in;
			tt_access_length[0]<=0;
			tt_is_hyperfetch[0]<=0;
			tt_is_byte_op[0]<=muxed_is_byte_op;
			tt_is_write_op[0]<=muxed_is_write_op;
		end
		2:begin
			tt_address[0]<=muxed_target_address_executer[30:0];
			tt_data[0]<=muxed_data_in;
			tt_access_length[0]<=muxed_access_length;
			tt_is_hyperfetch[0]<=0;
			tt_is_byte_op[0]<=0;
			tt_is_write_op[0]<=muxed_is_write_op;
		end
		3:begin
			tt_address[1]<=muxed_target_address_executer[30:0];
			tt_data[1]<=muxed_data_in;
			tt_access_length[1]<=muxed_access_length0;
			tt_is_hyperfetch[1]<=0;
			tt_is_byte_op[1]<=0;
			tt_is_write_op[1]<=muxed_is_write_op;
			
			tt_address[0]<=muxed_target_address_executer_alt[30:0];
			tt_data[0]<=muxed_data_in_alt;
			tt_access_length[0]<=muxed_access_length1;
			tt_is_hyperfetch[0]<=0;
			tt_is_byte_op[0]<=0;
			tt_is_write_op[0]<=muxed_is_write_op;
		end
		endcase
	end
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
	tick_tock_phase2,
	
	tt_address,
	tt_data,
	tt_access_length,
	tt_is_hyperfetch,
	tt_is_byte_op,
	tt_is_write_op,
	
	soft_fault,
	cd_access_out_full_data,
	
	main_clk
);

endmodule