`timescale 1 ps / 1 ps

`include "dram_controller.sv"
`include "cache_lru.sv"
`include "cache_data.sv"
`include "cache_way.sv"
`include "cache_controller.sv"


module memory_system(
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
	
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		     [3:0]		VGA_R,
	output		          		VGA_HS,
	output		          		VGA_VS,
	
	// for all memory access ports, once a request has begun to be issued, it should not be changed before it is acknowledged. hyper_instruction_fetch has a void signal that allows it to change
	
	input  [ 2:0] stack_access_size [3:0],
	input  [15:0] target_address_stack [3:0],
	input  [3:0] is_stack_access_write,
	input  [3:0] is_stack_access_requesting_extern,
	
	input  [31:0] target_address_general [3:0],
	// target_address_general is allowed to access I/O mapped memory regions and can be any type of memory access 
	input  [15:0] data_in [3:0][3:0],
	
	input  [3:0] is_general_access_write,
	input  [3:0] is_general_access_byte_operation,
	input  [3:0] is_general_access_requesting_extern,

	output [3:0] is_general_or_stack_access_acknowledged_pulse_extern,
	output [3:0] will_general_or_stack_access_be_acknowledged_pulse_extern,
	
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
	// the entire cache lane is given for where the word read falls. The amount of valid words returned is trivial to calculate elsewhere, so it is not given
	// this access uses data_out_type_0_extern
	
	input  is_instruction_fetch_requesting_extern,
	output is_instruction_fetch_acknowledged_pulse_extern,
	
	output [15:0] data_out_type_0_extern [7:0], // type_0 always uses the single access
	output [15:0] data_out_type_1_extern [7:0], // type_1 potentially uses the multi access
	
	output [3:0] memory_dependency_clear_extern,
	
	input  vga_clk,
	input  main_clk
);

reg was_cache_faulting=0;
reg is_cache_fault_start;
reg is_cache_fault_end;
reg is_cache_fault_start_state=0;
reg is_cache_fault_end_state=0;
reg mask_calculated_cache_fault;

wire calculated_cache_fault;

always @(posedge main_clk) is_cache_fault_start_state<=is_cache_fault_start;
always @(posedge main_clk) is_cache_fault_end_state<=is_cache_fault_end;

wire is_cache_being_filled; // this is referring to being filled from DRAM

reg [15:0] vga_write_addr;
reg [11:0] vga_write_data;
reg vga_do_write;

wire [1:0] lru_least_used_index;

wire [12:0] calculated_out_addr_at_in_way_index;
wire raw_calculated_cache_fault;
wire [1:0] calculated_cache_way;
reg [25:0] cache_way_target_address;
reg [25:0] cache_data_target_address=0;

reg [5:0] upper_target_address_instant;
reg [5:0] upper_target_address_saved=0;

reg do_byte_operation_instant;
reg do_byte_operation_saved=0;

reg do_partial_write_instant;
reg do_partial_write_saved=0;

always @(posedge main_clk) was_cache_faulting<=calculated_cache_fault;
always @(posedge main_clk) upper_target_address_saved<=upper_target_address_instant;
always @(posedge main_clk) do_byte_operation_saved<=do_byte_operation_instant;
always @(posedge main_clk) do_partial_write_saved<=do_partial_write_instant;

always_comb begin
	is_cache_fault_start=is_cache_fault_start_state;
	if (calculated_cache_fault) is_cache_fault_start=1'b1;
	if (was_cache_faulting) is_cache_fault_start=1'b0;
end

always_comb begin
	is_cache_fault_end=is_cache_fault_end_state;
	if (was_cache_faulting) is_cache_fault_end=1'b1;
	if (calculated_cache_fault) is_cache_fault_end=1'b0;
end

always @(posedge main_clk) cache_data_target_address<=cache_way_target_address;

reg [ 2:0] stack_access_size_instant;
reg [ 2:0] stack_access_size_saved;
always @(posedge main_clk) stack_access_size_saved<=stack_access_size_instant;

reg [ 1:0] executer_index_instant;
reg [ 1:0] executer_index_saved;
always @(posedge main_clk) executer_index_saved<=executer_index_instant;

reg [15:0] data_in_saved [3:0][3:0];
always @(posedge main_clk) data_in_saved<=data_in;


wire [15:0] data_in_at_index [3:0];
assign data_in_at_index=data_in_saved[executer_index_saved];

wire cd_out_dirty;
wire [15:0] cd_multi_access_out_full_data [7:0]; // this refers to multi cycle
wire [15:0] cd_single_access_out_full_data [7:0]; // this refers to single cycle
reg [15:0] cd_access_in_full_data [7:0];
reg [15:0] cd_access_mask;
wire [127:0] cd_raw_out_full_data;
wire [127:0] cd_raw_in_full_data;
wire [8:0] cd_target_segment;
wire [1:0] cd_target_way_read;
wire [1:0] cd_target_way_write;
wire cd_do_partial_write;
wire cd_do_byte_operation;

reg lru_enable_write;

reg cache_no_write_override; // this is for not writing the cache when an I/O mapped memory access occures

assign cd_target_way_read=calculated_cache_way;
assign cd_target_way_write=is_cache_being_filled?lru_least_used_index:calculated_cache_way;

assign cd_target_segment=cache_data_target_address[12:4];
assign cd_do_partial_write=do_partial_write_saved;
assign cd_do_byte_operation=do_byte_operation_saved;


reg [3:0] instant_acknowledge_executer;
reg instant_acknowledge_instruction_fetch;
reg instant_acknowledge_hyper_instruction_fetch_0;
reg instant_acknowledge_hyper_instruction_fetch_1;

reg [3:0] acknowledge_executer_r=0;
reg acknowledge_instruction_fetch_r=0;
reg acknowledge_hyper_instruction_fetch_0_r=0;
reg acknowledge_hyper_instruction_fetch_1_r=0;

always @(posedge main_clk) begin
	acknowledge_executer_r<=instant_acknowledge_executer;
	acknowledge_instruction_fetch_r<=instant_acknowledge_instruction_fetch;
	acknowledge_hyper_instruction_fetch_0_r<=instant_acknowledge_hyper_instruction_fetch_0;
	acknowledge_hyper_instruction_fetch_1_r<=instant_acknowledge_hyper_instruction_fetch_1;
end

assign is_general_or_stack_access_acknowledged_pulse_extern=acknowledge_executer_r;
assign will_general_or_stack_access_be_acknowledged_pulse_extern=instant_acknowledge_executer;

assign is_instruction_fetch_acknowledged_pulse_extern=acknowledge_instruction_fetch_r;
assign is_hyper_instruction_fetch_0_acknowledged_pulse_extern=acknowledge_hyper_instruction_fetch_0_r & ~void_hyper_instruction_fetch;
assign is_hyper_instruction_fetch_1_acknowledged_pulse_extern=acknowledge_hyper_instruction_fetch_1_r & ~void_hyper_instruction_fetch;

wire [3:0] is_general_access_requesting;
wire [3:0] is_stack_access_requesting;

assign is_general_access_requesting=is_general_access_requesting_extern & ~(acknowledge_executer_r);
assign is_stack_access_requesting=is_stack_access_requesting_extern & ~(acknowledge_executer_r);


wire is_instruction_fetch_requesting=is_instruction_fetch_requesting_extern & ~acknowledge_instruction_fetch_r;
wire is_hyper_instruction_fetch_0_requesting=is_hyper_instruction_fetch_0_requesting_extern & ~acknowledge_hyper_instruction_fetch_0_r;
wire is_hyper_instruction_fetch_1_requesting=is_hyper_instruction_fetch_1_requesting_extern & ~acknowledge_hyper_instruction_fetch_1_r;

reg use_multi_access;
reg use_multi_access_r=0;

always @(posedge main_clk) use_multi_access_r<=use_multi_access;

reg [15:0] data_out_type_0 [7:0];
reg [15:0] data_out_type_1 [7:0];

always_comb begin
	data_out_type_0=cd_single_access_out_full_data;
	if (use_multi_access_r) begin
		data_out_type_1=cd_multi_access_out_full_data;
	end else begin
		data_out_type_1=cd_single_access_out_full_data;
	end
end

assign data_out_type_0_extern=data_out_type_0;
assign data_out_type_1_extern=data_out_type_1;

reg allow_new_access;
reg [3:0] new_access_ignore_index;

wire [3:0] memory_dependency_clear;
reg [3:0] memory_dependency_clear_r=0;

always @(posedge main_clk) memory_dependency_clear_r<=memory_dependency_clear;
assign memory_dependency_clear_extern=memory_dependency_clear_r;

reg [1:0] mask_type;

always_comb begin
	cd_access_mask = 0;
	cd_access_in_full_data = '{16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx,16'hx};
	unique case (mask_type)
	0:begin
		unique case (cache_data_target_address[3:1])
		0:begin
			cd_access_mask[ 0]=1'b1;
			cd_access_mask[ 2]=(stack_access_size_saved>3'h1)?1'b1:1'b0;
			cd_access_mask[ 4]=(stack_access_size_saved>3'h2)?1'b1:1'b0;
			cd_access_mask[ 6]=(stack_access_size_saved>3'h3)?1'b1:1'b0;
			cd_access_mask[ 8]=(stack_access_size_saved>3'h4)?1'b1:1'b0;
			cd_access_in_full_data[0]=data_in_at_index[0];
			cd_access_in_full_data[1]=data_in_at_index[1];
			cd_access_in_full_data[2]=data_in_at_index[2];
			cd_access_in_full_data[3]=data_in_at_index[3];
		end
		1:begin
			cd_access_mask[ 2]=1'b1;
			cd_access_mask[ 4]=(stack_access_size_saved>3'h1)?1'b1:1'b0;
			cd_access_mask[ 6]=(stack_access_size_saved>3'h2)?1'b1:1'b0;
			cd_access_mask[ 8]=(stack_access_size_saved>3'h3)?1'b1:1'b0;
			cd_access_mask[10]=(stack_access_size_saved>3'h4)?1'b1:1'b0;
			cd_access_in_full_data[1]=data_in_at_index[0];
			cd_access_in_full_data[2]=data_in_at_index[1];
			cd_access_in_full_data[3]=data_in_at_index[2];
			cd_access_in_full_data[4]=data_in_at_index[3];
		end
		2:begin
			cd_access_mask[ 4]=1'b1;
			cd_access_mask[ 6]=(stack_access_size_saved>3'h1)?1'b1:1'b0;
			cd_access_mask[ 8]=(stack_access_size_saved>3'h2)?1'b1:1'b0;
			cd_access_mask[10]=(stack_access_size_saved>3'h3)?1'b1:1'b0;
			cd_access_mask[12]=(stack_access_size_saved>3'h4)?1'b1:1'b0;
			cd_access_in_full_data[2]=data_in_at_index[0];
			cd_access_in_full_data[3]=data_in_at_index[1];
			cd_access_in_full_data[4]=data_in_at_index[2];
			cd_access_in_full_data[5]=data_in_at_index[3];
		end
		3:begin
			cd_access_mask[ 6]=1'b1;
			cd_access_mask[ 8]=(stack_access_size_saved>3'h1)?1'b1:1'b0;
			cd_access_mask[10]=(stack_access_size_saved>3'h2)?1'b1:1'b0;
			cd_access_mask[12]=(stack_access_size_saved>3'h3)?1'b1:1'b0;
			cd_access_mask[14]=(stack_access_size_saved>3'h4)?1'b1:1'b0;
			cd_access_in_full_data[3]=data_in_at_index[0];
			cd_access_in_full_data[4]=data_in_at_index[1];
			cd_access_in_full_data[5]=data_in_at_index[2];
			cd_access_in_full_data[6]=data_in_at_index[3];
		end
		4:begin
			cd_access_mask[ 8]=1'b1;
			cd_access_mask[10]=(stack_access_size_saved>3'h1)?1'b1:1'b0;
			cd_access_mask[12]=(stack_access_size_saved>3'h2)?1'b1:1'b0;
			cd_access_mask[14]=(stack_access_size_saved>3'h3)?1'b1:1'b0;
			cd_access_in_full_data[4]=data_in_at_index[0];
			cd_access_in_full_data[5]=data_in_at_index[1];
			cd_access_in_full_data[6]=data_in_at_index[2];
			cd_access_in_full_data[7]=data_in_at_index[3];
		end
		5:begin
			cd_access_mask[10]=1'b1;
			cd_access_mask[12]=(stack_access_size_saved>3'h1)?1'b1:1'b0;
			cd_access_mask[14]=(stack_access_size_saved>3'h2)?1'b1:1'b0;
			cd_access_in_full_data[5]=data_in_at_index[0];
			cd_access_in_full_data[6]=data_in_at_index[1];
			cd_access_in_full_data[7]=data_in_at_index[2];
		end
		6:begin
			cd_access_mask[12]=1'b1;
			cd_access_mask[14]=(stack_access_size_saved>3'h1)?1'b1:1'b0;
			cd_access_in_full_data[6]=data_in_at_index[0];
			cd_access_in_full_data[7]=data_in_at_index[1];
		end
		7:begin
			cd_access_mask[14]=1'b1;
			cd_access_in_full_data[7]=data_in_at_index[0];
		end
		endcase
		cd_access_mask[ 1]=cd_access_mask[ 0];cd_access_mask[ 3]=cd_access_mask[ 2];cd_access_mask[ 5]=cd_access_mask[ 4];cd_access_mask[ 7]=cd_access_mask[ 6];cd_access_mask[ 9]=cd_access_mask[ 8];cd_access_mask[11]=cd_access_mask[10];cd_access_mask[13]=cd_access_mask[12];cd_access_mask[15]=cd_access_mask[14];
	end
	1:begin
		unique case (cache_data_target_address[3:1])
		0:begin
			cd_access_mask[ 0]=1'b1;
			unique case (stack_access_size_saved)
			2:begin
				cd_access_in_full_data[0]=data_in_at_index[1];
			end
			4:begin
				cd_access_in_full_data[0]=data_in_at_index[3];
			end
			5:begin
			end
			endcase
		end
		1:begin
			cd_access_mask[ 0]=1'b1;
			cd_access_mask[ 2]=1'b1;
			unique case (stack_access_size_saved)
			4:begin
				cd_access_in_full_data[0]=data_in_at_index[2];
				cd_access_in_full_data[1]=data_in_at_index[3];
			end
			5:begin
			end
			endcase
		end
		2:begin
			cd_access_mask[ 0]=1'b1;
			cd_access_mask[ 2]=1'b1;
			cd_access_mask[ 4]=1'b1;
			unique case (stack_access_size_saved)
			4:begin
				cd_access_in_full_data[0]=data_in_at_index[1];
				cd_access_in_full_data[1]=data_in_at_index[2];
				cd_access_in_full_data[2]=data_in_at_index[3];
			end
			5:begin
			end
			endcase
		end
		3:begin
			cd_access_mask[ 0]=1'b1;
			cd_access_mask[ 2]=1'b1;
			cd_access_mask[ 4]=1'b1;
			cd_access_mask[ 6]=1'b1;
			unique case (stack_access_size_saved)
			5:begin
			end
			endcase
		end
		// other situations are impossible
		endcase
		cd_access_mask[ 1]=cd_access_mask[ 0];cd_access_mask[ 3]=cd_access_mask[ 2];cd_access_mask[ 5]=cd_access_mask[ 4];cd_access_mask[ 7]=cd_access_mask[ 6];cd_access_mask[ 9]=cd_access_mask[ 8];cd_access_mask[11]=cd_access_mask[10];cd_access_mask[13]=cd_access_mask[12];cd_access_mask[15]=cd_access_mask[14];
	end
	2:begin
		cd_access_in_full_data[0]=data_in_at_index[0];
		cd_access_in_full_data[1]=data_in_at_index[0];
		cd_access_in_full_data[2]=data_in_at_index[0];
		cd_access_in_full_data[3]=data_in_at_index[0];
		cd_access_in_full_data[4]=data_in_at_index[0];
		cd_access_in_full_data[5]=data_in_at_index[0];
		cd_access_in_full_data[6]=data_in_at_index[0];
		cd_access_in_full_data[7]=data_in_at_index[0];
		if (do_byte_operation_saved) begin
			cd_access_in_full_data[0][15:8]=data_in_at_index[0][7:0];
			cd_access_in_full_data[1][15:8]=data_in_at_index[0][7:0];
			cd_access_in_full_data[2][15:8]=data_in_at_index[0][7:0];
			cd_access_in_full_data[3][15:8]=data_in_at_index[0][7:0];
			cd_access_in_full_data[4][15:8]=data_in_at_index[0][7:0];
			cd_access_in_full_data[5][15:8]=data_in_at_index[0][7:0];
			cd_access_in_full_data[6][15:8]=data_in_at_index[0][7:0];
			cd_access_in_full_data[7][15:8]=data_in_at_index[0][7:0];
		end
		unique case (cache_data_target_address[3:1])
		0:cd_access_mask[ 0]=1'b1;
		1:cd_access_mask[ 2]=1'b1;
		2:cd_access_mask[ 4]=1'b1;
		3:cd_access_mask[ 6]=1'b1;
		4:cd_access_mask[ 8]=1'b1;
		5:cd_access_mask[10]=1'b1;
		6:cd_access_mask[12]=1'b1;
		7:cd_access_mask[14]=1'b1;
		endcase
		cd_access_mask[ 1]=cd_access_mask[ 0];cd_access_mask[ 3]=cd_access_mask[ 2];cd_access_mask[ 5]=cd_access_mask[ 4];cd_access_mask[ 7]=cd_access_mask[ 6];cd_access_mask[ 9]=cd_access_mask[ 8];cd_access_mask[11]=cd_access_mask[10];cd_access_mask[13]=cd_access_mask[12];cd_access_mask[15]=cd_access_mask[14];
		if (do_byte_operation_saved) begin
			if (cache_data_target_address[0]) begin
				cd_access_mask[ 1]=1'b0;cd_access_mask[ 3]=1'b0;cd_access_mask[ 5]=1'b0;cd_access_mask[ 7]=1'b0;cd_access_mask[ 9]=1'b0;cd_access_mask[11]=1'b0;cd_access_mask[13]=1'b0;cd_access_mask[15]=1'b0;
			end else begin
				cd_access_mask[ 0]=1'b0;cd_access_mask[ 2]=1'b0;cd_access_mask[ 4]=1'b0;cd_access_mask[ 6]=1'b0;cd_access_mask[ 8]=1'b0;cd_access_mask[10]=1'b0;cd_access_mask[12]=1'b0;cd_access_mask[14]=1'b0;
			end
		end
	end
	3:begin
		unique case (cache_data_target_address[3:1])
		0:begin
			cd_access_mask[ 0]=1'b1;
			cd_access_mask[ 2]=1'b1;
			cd_access_mask[ 4]=1'b1;
			cd_access_mask[ 6]=1'b1;
			cd_access_mask[ 8]=1'b1;
			cd_access_mask[10]=1'b1;
			cd_access_mask[12]=1'b1;
			cd_access_mask[14]=1'b1;
		end
		1:begin
			cd_access_mask[ 2]=1'b1;
			cd_access_mask[ 4]=1'b1;
			cd_access_mask[ 6]=1'b1;
			cd_access_mask[ 8]=1'b1;
			cd_access_mask[10]=1'b1;
			cd_access_mask[12]=1'b1;
			cd_access_mask[14]=1'b1;
		end
		2:begin
			cd_access_mask[ 4]=1'b1;
			cd_access_mask[ 6]=1'b1;
			cd_access_mask[ 8]=1'b1;
			cd_access_mask[10]=1'b1;
			cd_access_mask[12]=1'b1;
			cd_access_mask[14]=1'b1;
		end
		3:begin
			cd_access_mask[ 6]=1'b1;
			cd_access_mask[ 8]=1'b1;
			cd_access_mask[10]=1'b1;
			cd_access_mask[12]=1'b1;
			cd_access_mask[14]=1'b1;
		end
		4:begin
			cd_access_mask[ 8]=1'b1;
			cd_access_mask[10]=1'b1;
			cd_access_mask[12]=1'b1;
			cd_access_mask[14]=1'b1;
		end
		5:begin
			cd_access_mask[10]=1'b1;
			cd_access_mask[12]=1'b1;
			cd_access_mask[14]=1'b1;
		end
		6:begin
			cd_access_mask[12]=1'b1;
			cd_access_mask[14]=1'b1;
		end
		7:begin
			cd_access_mask[14]=1'b1;
		end
		endcase
		cd_access_mask[ 1]=cd_access_mask[ 0];cd_access_mask[ 3]=cd_access_mask[ 2];cd_access_mask[ 5]=cd_access_mask[ 4];cd_access_mask[ 7]=cd_access_mask[ 6];cd_access_mask[ 9]=cd_access_mask[ 8];cd_access_mask[11]=cd_access_mask[10];cd_access_mask[13]=cd_access_mask[12];cd_access_mask[15]=cd_access_mask[14];
	end
	endcase
end

reg [4:0] controller_state_next;
reg [4:0] controller_state=0;

always @(posedge main_clk) controller_state<=controller_state_next;

split_cache_controller split_cache_controller(
	controller_state_next,
	lru_enable_write,
	use_multi_access,
	instant_acknowledge_executer,
	instant_acknowledge_instruction_fetch,
	instant_acknowledge_hyper_instruction_fetch_0,
	instant_acknowledge_hyper_instruction_fetch_1,
	cache_no_write_override,
	mask_type,
	memory_dependency_clear,
	do_byte_operation_instant,
	do_partial_write_instant,
	upper_target_address_instant,
	stack_access_size_instant,
	executer_index_instant,
	cache_way_target_address,
	calculated_cache_fault,
	
	controller_state,
	raw_calculated_cache_fault,
	is_stack_access_requesting,
	is_general_access_requesting,
	stack_access_size,
	target_address_stack,
	target_address_general,
	target_address_hyper_instruction_fetch_0,
	target_address_hyper_instruction_fetch_1,
	is_instruction_fetch_requesting,
	is_hyper_instruction_fetch_0_requesting,
	is_hyper_instruction_fetch_1_requesting,
	void_hyper_instruction_fetch,
	target_address_instruction_fetch,
	upper_target_address_saved,
	is_stack_access_write,
	is_general_access_write,
	is_general_access_byte_operation
);


cache_way cache_way(
	calculated_out_addr_at_in_way_index,
	raw_calculated_cache_fault,
	calculated_cache_way,
	lru_least_used_index, // cache way to set
	cache_way_target_address,
	is_cache_being_filled, // do_set_cache_way
	main_clk
);

cache_data cache_data_inst(
	cd_out_dirty,

	cd_multi_access_out_full_data,
	cd_single_access_out_full_data,
	cd_access_mask,
	cd_raw_out_full_data,
	
	cd_access_in_full_data,
	cd_raw_in_full_data,

	cd_target_segment,
	cd_target_way_read,
	cd_target_way_write,

	is_cache_being_filled, // do_full_write
	cd_do_partial_write,
	cd_do_byte_operation,
	
	cache_no_write_override, // this does an override so that no write operation occures unless a do_full_write is performed
	calculated_cache_fault,
	main_clk
);

cache_LRU cache_LRU_inst(
	lru_least_used_index,

	cd_target_segment, // lru_addr
	cd_target_way_write, // lru_used_index
	lru_enable_write,
	main_clk
);


dram_controller dram_controller_inst(
	cache_data_target_address[25:13],
	calculated_out_addr_at_in_way_index,
	cache_data_target_address[12: 4],
	cd_raw_in_full_data,
	cd_raw_out_full_data,
	cd_out_dirty,
	
	is_cache_fault_start,
	is_cache_being_filled,
	
	
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
	
	main_clk
);

/*
vga_driver vga_driver_inst(
	VGA_B,
	VGA_G,
	VGA_R,
	VGA_HS,
	VGA_VS,
	
	vga_do_write,
	vga_write_addr,
	vga_write_data,
	main_clk,
	vga_clk
);
*/


endmodule











