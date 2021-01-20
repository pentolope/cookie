`timescale 1 ps / 1 ps

module split_cache_controller_segment(
	output [4:0] controller_state_next_extern,
	output lru_enable_write_extern,
	output use_multi_access_extern,
	output [3:0] instant_acknowledge_executer_extern,
	output instant_acknowledge_instruction_fetch_extern,
	output instant_acknowledge_hyper_instruction_fetch_0_extern,
	output instant_acknowledge_hyper_instruction_fetch_1_extern,
	output cache_no_write_override_extern,
	output [1:0] mask_type_extern,
	output [3:0] memory_dependency_clear_extern,
	output do_byte_operation_instant_extern,
	output do_partial_write_instant_extern,
	output [ 5:0] upper_target_address_instant_extern,
	output [ 2:0] stack_access_size_instant_extern,
	output [ 1:0] executer_index_instant_extern,
	output [25:0] cache_way_target_address_extern,
	output calculated_cache_fault_extern,
	
	input  [4:0] controller_state,
	input  raw_calculated_cache_fault,
	input  [3:0] is_stack_access_requesting,
	input  [3:0] is_general_access_requesting,
	input  [ 2:0] stack_access_size [3:0],
	input  [15:0] target_address_stack [3:0],
	input  [31:0] target_address_general [3:0],
	input  [25:0] target_address_hyper_instruction_fetch_0,
	input  [25:0] target_address_hyper_instruction_fetch_1,
	input  is_instruction_fetch_requesting,
	input  is_hyper_instruction_fetch_0_requesting,
	input  is_hyper_instruction_fetch_1_requesting,
	input  void_hyper_instruction_fetch,
	input  [25:0] target_address_instruction_fetch,
	input  [ 5:0] upper_target_address_saved,
	input [3:0] is_stack_access_write,
	input [3:0] is_general_access_write,
	input [3:0] is_general_access_byte_operation
);

reg [4:0] controller_state_next;
reg lru_enable_write;
reg use_multi_access;
reg [3:0] instant_acknowledge_executer;
reg instant_acknowledge_instruction_fetch;
reg instant_acknowledge_hyper_instruction_fetch_0;
reg instant_acknowledge_hyper_instruction_fetch_1;
reg mask_calculated_cache_fault;
reg cache_no_write_override;
reg allow_new_access;
reg [1:0] mask_type;
reg [3:0] new_access_ignore_index;
reg [3:0] memory_dependency_clear;
reg do_byte_operation_instant;
reg do_partial_write_instant;
reg [ 5:0] upper_target_address_instant;
reg [ 2:0] stack_access_size_instant;
reg [ 1:0] executer_index_instant;
reg [25:0] cache_way_target_address;



lcell_5 lcell_i0 (controller_state_next_extern,controller_state_next);
lcell_1 lcell_i1 (lru_enable_write_extern,lru_enable_write);
lcell_1 lcell_i2 (use_multi_access_extern,use_multi_access);
lcell_4 lcell_i3 (instant_acknowledge_executer_extern,instant_acknowledge_executer);
lcell_1 lcell_i4 (instant_acknowledge_instruction_fetch_extern,instant_acknowledge_instruction_fetch);
lcell_1 lcell_i5 (instant_acknowledge_hyper_instruction_fetch_0_extern,instant_acknowledge_hyper_instruction_fetch_0);
lcell_1 lcell_i6 (instant_acknowledge_hyper_instruction_fetch_1_extern,instant_acknowledge_hyper_instruction_fetch_1);
lcell_1 lcell_i7 (cache_no_write_override_extern,cache_no_write_override);
lcell_4 lcell_i8 (memory_dependency_clear_extern,memory_dependency_clear);
lcell_1 lcell_i9 (do_byte_operation_instant_extern,do_byte_operation_instant);
lcell_1 lcell_ia (do_partial_write_instant_extern,do_partial_write_instant);
lcell_6 lcell_ib (upper_target_address_instant_extern,upper_target_address_instant);
lcell_3 lcell_ic (stack_access_size_instant_extern,stack_access_size_instant);
lcell_2 lcell_id (executer_index_instant_extern,executer_index_instant);
lcell_26 lcell_ie (cache_way_target_address_extern,cache_way_target_address);

assign mask_type_extern=mask_type;


/*
assign controller_state_next_extern=controller_state_next;
assign lru_enable_write_extern=lru_enable_write;
assign use_multi_access_extern=use_multi_access;
assign instant_acknowledge_executer_extern=instant_acknowledge_executer;
assign instant_acknowledge_instruction_fetch_extern=instant_acknowledge_instruction_fetch;
assign instant_acknowledge_hyper_instruction_fetch_0_extern=instant_acknowledge_hyper_instruction_fetch_0;
assign instant_acknowledge_hyper_instruction_fetch_1_extern=instant_acknowledge_hyper_instruction_fetch_1;
assign cache_no_write_override_extern=cache_no_write_override;
assign mask_type_extern=mask_type;
assign memory_dependency_clear_extern=memory_dependency_clear;
assign do_byte_operation_instant_extern=do_byte_operation_instant;
assign do_partial_write_instant_extern=do_partial_write_instant;
assign upper_target_address_instant_extern=upper_target_address_instant;
assign stack_access_size_instant_extern=stack_access_size_instant;
assign executer_index_instant_extern=executer_index_instant;
assign cache_way_target_address_extern=cache_way_target_address;
*/

wire [15:0] target_address_stack_added [3:0];
lcell_16 lcell_ii0 (target_address_stack_added[0],target_address_stack[0]+{stack_access_size[0]-1'b1,1'b0});
lcell_16 lcell_ii1 (target_address_stack_added[1],target_address_stack[1]+{stack_access_size[1]-1'b1,1'b0});
lcell_16 lcell_ii2 (target_address_stack_added[2],target_address_stack[2]+{stack_access_size[2]-1'b1,1'b0});
lcell_16 lcell_ii3 (target_address_stack_added[3],target_address_stack[3]+{stack_access_size[3]-1'b1,1'b0});


wire calculated_cache_fault=raw_calculated_cache_fault && !mask_calculated_cache_fault;
assign calculated_cache_fault_extern=calculated_cache_fault;

always_comb begin
	controller_state_next=controller_state;
	lru_enable_write=0;
	use_multi_access=0;
	instant_acknowledge_executer=0;
	instant_acknowledge_instruction_fetch=0;
	instant_acknowledge_hyper_instruction_fetch_0=0;
	instant_acknowledge_hyper_instruction_fetch_1=0;
	mask_calculated_cache_fault=0;
	cache_no_write_override=0;
	allow_new_access=0;
	mask_type=3;
	new_access_ignore_index=4'h0;
	memory_dependency_clear=0;
	unique case (controller_state)
	5'h00:begin // no operation
		new_access_ignore_index=4'h0;
		allow_new_access=1;
		mask_calculated_cache_fault=1;
	end
	5'h01:begin // executer 0: multi lane stack access on first lane
		new_access_ignore_index=4'h1;
		use_multi_access=1;
		mask_type=0;
		if (!calculated_cache_fault) begin
			lru_enable_write=1;
			controller_state_next=5'h02;
		end
	end
	5'h02:begin // executer 0: multi lane stack access on second lane
		new_access_ignore_index=4'h1;
		use_multi_access=1;
		mask_type=1;
		if (!calculated_cache_fault) begin
			allow_new_access=1;
			instant_acknowledge_executer[0]=1'b1;
			lru_enable_write=1;
			controller_state_next=5'h00;
		end
	end
	5'h03:begin // executer 0: single lane stack access
		new_access_ignore_index=4'h1;
		mask_type=0;
		if (!calculated_cache_fault) begin
			allow_new_access=1;
			instant_acknowledge_executer[0]=1'b1;
			lru_enable_write=1;
			controller_state_next=5'h00;
		end
	end
	5'h04:begin // executer 0: general access
		new_access_ignore_index=4'h2;
		mask_type=2;
		if (upper_target_address_saved==6'h00) begin
			if (!calculated_cache_fault) begin
				allow_new_access=1;
				instant_acknowledge_executer[0]=1'b1;
				lru_enable_write=1;
				controller_state_next=5'h00;
			end
		end else begin
			mask_calculated_cache_fault=1;
			cache_no_write_override=1;
			allow_new_access=1;
			instant_acknowledge_executer[0]=1'b1;
			controller_state_next=5'h00;
			//  I/O mapped memory controlling is performed elsewhere
		end
	end
	5'h05:begin // executer 1: multi lane stack access on first lane
		new_access_ignore_index=4'h3;
		use_multi_access=1;
		mask_type=0;
		if (!calculated_cache_fault) begin
			lru_enable_write=1;
			controller_state_next=5'h02;
		end
	end
	5'h06:begin // executer 1: multi lane stack access on second lane
		new_access_ignore_index=4'h3;
		use_multi_access=1;
		mask_type=1;
		if (!calculated_cache_fault) begin
			allow_new_access=1;
			instant_acknowledge_executer[1]=1'b1;
			lru_enable_write=1;
			controller_state_next=5'h00;
		end
	end
	5'h07:begin // executer 1: single lane stack access
		new_access_ignore_index=4'h3;
		mask_type=0;
		if (!calculated_cache_fault) begin
			allow_new_access=1;
			instant_acknowledge_executer[1]=1'b1;
			lru_enable_write=1;
			controller_state_next=5'h00;
		end
	end
	5'h08:begin // executer 1: general access
		new_access_ignore_index=4'h4;
		mask_type=2;
		if (upper_target_address_saved==6'h00) begin
			if (!calculated_cache_fault) begin
				allow_new_access=1;
				instant_acknowledge_executer[1]=1'b1;
				lru_enable_write=1;
				controller_state_next=5'h00;
			end
		end else begin
			mask_calculated_cache_fault=1;
			cache_no_write_override=1;
			allow_new_access=1;
			instant_acknowledge_executer[1]=1'b1;
			controller_state_next=5'h00;
			//  I/O mapped memory controlling is performed elsewhere
		end
	end
	5'h09:begin // executer 2: multi lane stack access on first lane
		new_access_ignore_index=4'h5;
		use_multi_access=1;
		mask_type=0;
		if (!calculated_cache_fault) begin
			lru_enable_write=1;
			controller_state_next=5'h02;
		end
	end
	5'h0A:begin // executer 2: multi lane stack access on second lane
		new_access_ignore_index=4'h5;
		use_multi_access=1;
		mask_type=1;
		if (!calculated_cache_fault) begin
			allow_new_access=1;
			instant_acknowledge_executer[2]=1'b1;
			lru_enable_write=1;
			controller_state_next=5'h00;
		end
	end
	5'h0B:begin // executer 2: single lane stack access
		new_access_ignore_index=4'h5;
		mask_type=0;
		if (!calculated_cache_fault) begin
			allow_new_access=1;
			instant_acknowledge_executer[2]=1'b1;
			lru_enable_write=1;
			controller_state_next=5'h00;
		end
	end
	5'h0C:begin // executer 2: general access
		new_access_ignore_index=4'h6;
		mask_type=2;
		if (upper_target_address_saved==6'h00) begin
			if (!calculated_cache_fault) begin
				allow_new_access=1;
				instant_acknowledge_executer[2]=1'b1;
				lru_enable_write=1;
				controller_state_next=5'h00;
			end
		end else begin
			mask_calculated_cache_fault=1;
			cache_no_write_override=1;
			allow_new_access=1;
			instant_acknowledge_executer[2]=1'b1;
			controller_state_next=5'h00;
			//  I/O mapped memory controlling is performed elsewhere
		end
	end
	5'h0D:begin // executer 3: multi lane stack access on first lane
		new_access_ignore_index=4'h7;
		use_multi_access=1;
		mask_type=0;
		if (!calculated_cache_fault) begin
			lru_enable_write=1;
			controller_state_next=5'h02;
		end
	end
	5'h0E:begin // executer 3: multi lane stack access on second lane
		new_access_ignore_index=4'h7;
		use_multi_access=1;
		mask_type=1;
		if (!calculated_cache_fault) begin
			allow_new_access=1;
			instant_acknowledge_executer[3]=1'b1;
			lru_enable_write=1;
			controller_state_next=5'h00;
		end
	end
	5'h0F:begin // executer 3: single lane stack access
		new_access_ignore_index=4'h7;
		mask_type=0;
		if (!calculated_cache_fault) begin
			allow_new_access=1;
			instant_acknowledge_executer[3]=1'b1;
			lru_enable_write=1;
			controller_state_next=5'h00;
		end
	end
	5'h10:begin // executer 3: general access
		new_access_ignore_index=4'h8;
		mask_type=2;
		if (upper_target_address_saved==6'h00) begin
			if (!calculated_cache_fault) begin
				allow_new_access=1;
				instant_acknowledge_executer[3]=1'b1;
				lru_enable_write=1;
				controller_state_next=5'h00;
			end
		end else begin
			mask_calculated_cache_fault=1;
			cache_no_write_override=1;
			allow_new_access=1;
			instant_acknowledge_executer[3]=1'b1;
			controller_state_next=5'h00;
			//  I/O mapped memory controlling is performed elsewhere
		end
	end
	5'h11:begin // instruction fetch
		new_access_ignore_index=4'h9;
		mask_type=3;
		if (!calculated_cache_fault) begin
			allow_new_access=1;
			instant_acknowledge_instruction_fetch=1;
			lru_enable_write=1;
			controller_state_next=5'h00;
		end
	end
	5'h12:begin // hyper instruction fetch 0
		new_access_ignore_index=4'hA;
		mask_calculated_cache_fault=1;
		mask_type=3;
		allow_new_access=1;
		controller_state_next=5'h00;
		if (!void_hyper_instruction_fetch) begin
			if (!raw_calculated_cache_fault) begin
				instant_acknowledge_hyper_instruction_fetch_0=1;
				lru_enable_write=1;
			end
		end else begin
			new_access_ignore_index=4'h0;
		end
	end
	5'h13:begin // hyper instruction fetch 1
		new_access_ignore_index=4'hB;
		mask_calculated_cache_fault=1;
		mask_type=3;
		allow_new_access=1;
		controller_state_next=5'h00;
		if (!void_hyper_instruction_fetch) begin
			if (!raw_calculated_cache_fault) begin
				instant_acknowledge_hyper_instruction_fetch_1=1;
				lru_enable_write=1;
			end
		end else begin
			new_access_ignore_index=4'h0;
		end
	end
	endcase
	if (allow_new_access) begin
		         if (is_stack_access_requesting[0]   && new_access_ignore_index!=4'h1) begin
			memory_dependency_clear[0]=1'b1;
			if (({1'b0,target_address_stack[0][3:1]}+stack_access_size[0])>4'h8)
				controller_state_next=5'h01;
			else
				controller_state_next=5'h03;
		end else if (is_general_access_requesting[0] && new_access_ignore_index!=4'h2) begin
			memory_dependency_clear[0]=1'b1;
			controller_state_next=5'h04;
		end else if (is_stack_access_requesting[1]   && new_access_ignore_index!=4'h3) begin
			memory_dependency_clear[1]=1'b1;
			if (({1'b0,target_address_stack[1][3:1]}+stack_access_size[1])>4'h8)
				controller_state_next=5'h05;
			else
				controller_state_next=5'h07;
		end else if (is_general_access_requesting[1] && new_access_ignore_index!=4'h4) begin
			memory_dependency_clear[1]=1'b1;
			controller_state_next=5'h08;
		end else if (is_stack_access_requesting[2]   && new_access_ignore_index!=4'h5) begin
			memory_dependency_clear[2]=1'b1;
			if (({1'b0,target_address_stack[2][3:1]}+stack_access_size[2])>4'h8)
				controller_state_next=5'h09;
			else
				controller_state_next=5'h0B;
		end else if (is_general_access_requesting[2] && new_access_ignore_index!=4'h6) begin
			memory_dependency_clear[2]=1'b1;
			controller_state_next=5'h0C;
		end else if (is_stack_access_requesting[3]   && new_access_ignore_index!=4'h7) begin
			memory_dependency_clear[3]=1'b1;
			if (({1'b0,target_address_stack[3][3:1]}+stack_access_size[3])>4'h8)
				controller_state_next=5'h0D;
			else
				controller_state_next=5'h0F;
		end else if (is_general_access_requesting[3] && new_access_ignore_index!=4'h8) begin
			memory_dependency_clear[3]=1'b1;
			controller_state_next=5'h10;
		end else if (is_instruction_fetch_requesting && new_access_ignore_index!=4'h9) begin
			controller_state_next=5'h11;
		end else if (is_hyper_instruction_fetch_0_requesting && new_access_ignore_index!=4'hA) begin
			controller_state_next=5'h12;
		end else if (is_hyper_instruction_fetch_1_requesting && new_access_ignore_index!=4'hB) begin
			controller_state_next=5'h13;
		end
	end
	do_byte_operation_instant=0;
	do_partial_write_instant=0;
	upper_target_address_instant=0;
	stack_access_size_instant=3'hx;
	executer_index_instant=2'hx;
	unique case (controller_state_next)
	5'h00:begin // no operation
		cache_way_target_address=target_address_instruction_fetch; // not much of a reason why it cache_way_target_address is set to target_address_instruction_fetch
	end
	5'h01:begin // executer 0: multi lane stack access on first lane
		cache_way_target_address[15: 0]=target_address_stack[0];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[0];
		do_partial_write_instant=is_stack_access_write[0];
		executer_index_instant=0;
	end
	5'h02:begin // executer 0: multi lane stack access on second lane
		cache_way_target_address[15: 0]=target_address_stack_added[0];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[0];
		do_partial_write_instant=is_stack_access_write[0];
		executer_index_instant=0;
	end
	5'h03:begin // executer 0: single lane stack access
		cache_way_target_address[15: 0]=target_address_stack[0];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[0];
		do_partial_write_instant=is_stack_access_write[0];
		executer_index_instant=0;
	end
	5'h04:begin // executer 0: general access
		cache_way_target_address=target_address_general[0][25:0];
		upper_target_address_instant=target_address_general[0][31:26];
		do_byte_operation_instant=is_general_access_byte_operation[0];
		do_partial_write_instant=is_general_access_write[0];
		executer_index_instant=0;
	end
	5'h05:begin // executer 1: multi lane stack access on first lane
		cache_way_target_address[15: 0]=target_address_stack[1];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[1];
		do_partial_write_instant=is_stack_access_write[1];
		executer_index_instant=1;
	end
	5'h06:begin // executer 1: multi lane stack access on second lane
		cache_way_target_address[15: 0]=target_address_stack_added[1];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[1];
		do_partial_write_instant=is_stack_access_write[1];
		executer_index_instant=1;
	end
	5'h07:begin // executer 1: single lane stack access
		cache_way_target_address[15: 0]=target_address_stack[1];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[1];
		do_partial_write_instant=is_stack_access_write[1];
		executer_index_instant=1;
	end
	5'h08:begin // executer 1: general access
		cache_way_target_address=target_address_general[1][25:0];
		upper_target_address_instant=target_address_general[1][31:26];
		do_byte_operation_instant=is_general_access_byte_operation[1];
		do_partial_write_instant=is_general_access_write[1];
		executer_index_instant=1;
	end
	5'h09:begin // executer 2: multi lane stack access on first lane
		cache_way_target_address[15: 0]=target_address_stack[2];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[2];
		do_partial_write_instant=is_stack_access_write[2];
		executer_index_instant=2;
	end
	5'h0A:begin // executer 2: multi lane stack access on second lane
		cache_way_target_address[15: 0]=target_address_stack_added[2];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[2];
		do_partial_write_instant=is_stack_access_write[2];
		executer_index_instant=2;
	end
	5'h0B:begin // executer 2: single lane stack access
		cache_way_target_address[15: 0]=target_address_stack[2];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[2];
		do_partial_write_instant=is_stack_access_write[2];
		executer_index_instant=2;
	end
	5'h0C:begin // executer 2: general access
		cache_way_target_address=target_address_general[2][25:0];
		upper_target_address_instant=target_address_general[2][31:26];
		do_byte_operation_instant=is_general_access_byte_operation[2];
		do_partial_write_instant=is_general_access_write[2];
		executer_index_instant=2;
	end
	5'h0D:begin // executer 3: multi lane stack access on first lane
		cache_way_target_address[15: 0]=target_address_stack[3];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[3];
		do_partial_write_instant=is_stack_access_write[3];
		executer_index_instant=3;
	end
	5'h0E:begin // executer 3: multi lane stack access on second lane
		cache_way_target_address[15: 0]=target_address_stack_added[3];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[3];
		do_partial_write_instant=is_stack_access_write[3];
		executer_index_instant=3;
	end
	5'h0F:begin // executer 3: single lane stack access
		cache_way_target_address[15: 0]=target_address_stack[3];
		cache_way_target_address[25:16]=0;
		cache_way_target_address[0]=0;
		stack_access_size_instant=stack_access_size[3];
		do_partial_write_instant=is_stack_access_write[3];
		executer_index_instant=3;
	end
	5'h10:begin // executer 3: general access
		cache_way_target_address=target_address_general[3][25:0];
		upper_target_address_instant=target_address_general[3][31:26];
		do_byte_operation_instant=is_general_access_byte_operation[3];
		do_partial_write_instant=is_general_access_write[3];
		executer_index_instant=3;
	end
	5'h11:begin // instruction fetch
		cache_way_target_address=target_address_instruction_fetch;
		cache_way_target_address[0]=0;
	end
	5'h12:begin // hyper instruction fetch 0
		cache_way_target_address=target_address_hyper_instruction_fetch_0;
		cache_way_target_address[0]=0;
	end
	5'h13:begin // hyper instruction fetch 1
		cache_way_target_address=target_address_hyper_instruction_fetch_1;
		cache_way_target_address[0]=0;
	end
	endcase
end
endmodule


module split_cache_controller(
	output [4:0] controller_state_next_extern,
	output lru_enable_write_extern,
	output use_multi_access_extern,
	output [3:0] instant_acknowledge_executer_extern,
	output instant_acknowledge_instruction_fetch_extern,
	output instant_acknowledge_hyper_instruction_fetch_0_extern,
	output instant_acknowledge_hyper_instruction_fetch_1_extern,
	output cache_no_write_override_extern,
	output [1:0] mask_type_extern,
	output [3:0] memory_dependency_clear_extern,
	output do_byte_operation_instant_extern,
	output do_partial_write_instant_extern,
	output [ 5:0] upper_target_address_instant_extern,
	output [ 2:0] stack_access_size_instant_extern,
	output [ 1:0] executer_index_instant_extern,
	output [25:0] cache_way_target_address_extern,
	output calculated_cache_fault_extern,
	
	input  [4:0] controller_state,
	input  raw_calculated_cache_fault,
	input  [3:0] is_stack_access_requesting,
	input  [3:0] is_general_access_requesting,
	input  [ 2:0] stack_access_size [3:0],
	input  [15:0] target_address_stack [3:0],
	input  [31:0] target_address_general [3:0],
	input  [25:0] target_address_hyper_instruction_fetch_0,
	input  [25:0] target_address_hyper_instruction_fetch_1,
	input  is_instruction_fetch_requesting,
	input  is_hyper_instruction_fetch_0_requesting,
	input  is_hyper_instruction_fetch_1_requesting,
	input  void_hyper_instruction_fetch,
	input  [25:0] target_address_instruction_fetch,
	input  [ 5:0] upper_target_address_saved,
	input [3:0] is_stack_access_write,
	input [3:0] is_general_access_write,
	input [3:0] is_general_access_byte_operation
);


wire [4:0] controller_state_next_0;
wire lru_enable_write_0;
wire use_multi_access_0;
wire [3:0] instant_acknowledge_executer_0;
wire instant_acknowledge_instruction_fetch_0;
wire instant_acknowledge_hyper_instruction_fetch_0_0;
wire instant_acknowledge_hyper_instruction_fetch_1_0;
wire cache_no_write_override_0;
wire [1:0] mask_type_0;
wire [3:0] memory_dependency_clear_0;
wire do_byte_operation_instant_0;
wire do_partial_write_instant_0;
wire [ 5:0] upper_target_address_instant_0;
wire [ 2:0] stack_access_size_instant_0;
wire [ 1:0] executer_index_instant_0;
wire [25:0] cache_way_target_address_0;
wire calculated_cache_fault_0;

wire [4:0] controller_state_next_1;
wire lru_enable_write_1;
wire use_multi_access_1;
wire [3:0] instant_acknowledge_executer_1;
wire instant_acknowledge_instruction_fetch_1;
wire instant_acknowledge_hyper_instruction_fetch_0_1;
wire instant_acknowledge_hyper_instruction_fetch_1_1;
wire cache_no_write_override_1;
wire [1:0] mask_type_1;
wire [3:0] memory_dependency_clear_1;
wire do_byte_operation_instant_1;
wire do_partial_write_instant_1;
wire [ 5:0] upper_target_address_instant_1;
wire [ 2:0] stack_access_size_instant_1;
wire [ 1:0] executer_index_instant_1;
wire [25:0] cache_way_target_address_1;
wire calculated_cache_fault_1;


assign controller_state_next_extern=raw_calculated_cache_fault?controller_state_next_1:controller_state_next_0;
assign lru_enable_write_extern=raw_calculated_cache_fault?lru_enable_write_1:lru_enable_write_0;
assign use_multi_access_extern=raw_calculated_cache_fault?use_multi_access_1:use_multi_access_0;
assign instant_acknowledge_executer_extern=raw_calculated_cache_fault?instant_acknowledge_executer_1:instant_acknowledge_executer_0;
assign instant_acknowledge_instruction_fetch_extern=raw_calculated_cache_fault?instant_acknowledge_instruction_fetch_1:instant_acknowledge_instruction_fetch_0;
assign instant_acknowledge_hyper_instruction_fetch_0_extern=raw_calculated_cache_fault?instant_acknowledge_hyper_instruction_fetch_0_1:instant_acknowledge_hyper_instruction_fetch_0_0;
assign instant_acknowledge_hyper_instruction_fetch_1_extern=raw_calculated_cache_fault?instant_acknowledge_hyper_instruction_fetch_1_1:instant_acknowledge_hyper_instruction_fetch_1_0;
assign cache_no_write_override_extern=raw_calculated_cache_fault?cache_no_write_override_1:cache_no_write_override_0;
assign mask_type_extern=raw_calculated_cache_fault?mask_type_1:mask_type_0;
assign memory_dependency_clear_extern=raw_calculated_cache_fault?memory_dependency_clear_1:memory_dependency_clear_0;
assign do_byte_operation_instant_extern=raw_calculated_cache_fault?do_byte_operation_instant_1:do_byte_operation_instant_0;
assign do_partial_write_instant_extern=raw_calculated_cache_fault?do_partial_write_instant_1:do_partial_write_instant_0;
assign upper_target_address_instant_extern=raw_calculated_cache_fault?upper_target_address_instant_1:upper_target_address_instant_0;
assign stack_access_size_instant_extern=raw_calculated_cache_fault?stack_access_size_instant_1:stack_access_size_instant_0;
assign executer_index_instant_extern=raw_calculated_cache_fault?executer_index_instant_1:executer_index_instant_0;
assign cache_way_target_address_extern=raw_calculated_cache_fault?cache_way_target_address_1:cache_way_target_address_0;
assign calculated_cache_fault_extern=raw_calculated_cache_fault?calculated_cache_fault_1:calculated_cache_fault_0;


split_cache_controller_segment split_cache_controller_segment_0(
	controller_state_next_0,
	lru_enable_write_0,
	use_multi_access_0,
	instant_acknowledge_executer_0,
	instant_acknowledge_instruction_fetch_0,
	instant_acknowledge_hyper_instruction_fetch_0_0,
	instant_acknowledge_hyper_instruction_fetch_1_0,
	cache_no_write_override_0,
	mask_type_0,
	memory_dependency_clear_0,
	do_byte_operation_instant_0,
	do_partial_write_instant_0,
	upper_target_address_instant_0,
	stack_access_size_instant_0,
	executer_index_instant_0,
	cache_way_target_address_0,
	calculated_cache_fault_0,
	
	controller_state,
	1'b0,
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

split_cache_controller_segment split_cache_controller_segment_1(
	controller_state_next_1,
	lru_enable_write_1,
	use_multi_access_1,
	instant_acknowledge_executer_1,
	instant_acknowledge_instruction_fetch_1,
	instant_acknowledge_hyper_instruction_fetch_0_1,
	instant_acknowledge_hyper_instruction_fetch_1_1,
	cache_no_write_override_1,
	mask_type_1,
	memory_dependency_clear_1,
	do_byte_operation_instant_1,
	do_partial_write_instant_1,
	upper_target_address_instant_1,
	stack_access_size_instant_1,
	executer_index_instant_1,
	cache_way_target_address_1,
	calculated_cache_fault_1,
	
	controller_state,
	1'b1,
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

endmodule
