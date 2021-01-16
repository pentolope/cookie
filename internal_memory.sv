`timescale 1 ps / 1 ps




module dram_controller(
	input  [12:0] addr_req_read_dram_side_dram,
	input  [12:0] addr_req_write_dram_side_dram,
	input  [ 8:0] addr_req_common_side_dram,
	output [127:0] lane_from_dram_to_cache_side_dram,
	input  [127:0] lane_from_cache_to_dram_side_dram,
	input  dram_controller_entry_dirty_side_dram,
	
	input  dram_controller_req_read_pulse_side_dram, // single cycle pulse
	output dram_controller_ack_read_pulse_side_dram, // single cycle pulse
	
	
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
	input  main_clk
);

reg DRAM_DQ_oe_r=0; // 0==high-z  ;  1==driven by DRAM_DQ_rOUT
reg [12:0] DRAM_ADDR_r=0;
reg [1:0] DRAM_BA_r=0;
reg DRAM_CAS_r=1;
reg DRAM_RAS_r=1;
reg DRAM_WE_r=1;
reg DRAM_DQM_r=1;

assign DRAM_ADDR=DRAM_ADDR_r;
assign DRAM_BA=DRAM_BA_r;
assign DRAM_CAS_N=DRAM_CAS_r;
assign DRAM_CKE=1;
assign DRAM_CS_N=0;
assign DRAM_LDQM=DRAM_DQM_r;
assign DRAM_RAS_N=DRAM_RAS_r;
assign DRAM_UDQM=DRAM_DQM_r;
assign DRAM_WE_N=DRAM_WE_r;


reg [15:0] DRAM_DQ_rIN=0;
reg [15:0] DRAM_DQ_rOUT=0;

assign DRAM_DQ=DRAM_DQ_oe_r ? DRAM_DQ_rOUT : 16'hz ;

always @(posedge main_clk) DRAM_DQ_rIN<=DRAM_DQ;


reg [127:0] lane_from_dram_to_cache=0;
reg [127:0] lane_from_cache_to_dram=0;

assign lane_from_dram_to_cache_side_dram=lane_from_dram_to_cache;


reg [2:0] bank_status_general [3:0]='{0,0,0,0}; // the value here is a cooldown/delay counter for when the bank can be accessed again

//reg [15:0] initializer_countdown_internal=16'hFFFF;
reg [15:0] initializer_countdown_internal=16'h8070; // this is for simulation to make it turn on faster


reg [14:0] initializer_countdown=15'h3FFF;

always @(posedge main_clk) begin
	if (initializer_countdown_internal[15]) initializer_countdown_internal<=initializer_countdown_internal-1'd1;
end

always @(posedge main_clk) initializer_countdown<=initializer_countdown_internal[14:0];


reg dram_controller_ack_read_pulse_r=0;
assign dram_controller_ack_read_pulse_side_dram=dram_controller_ack_read_pulse_r;

reg dram_controller_req_read_pending_state=0;
wire dram_controller_req_read_pending=(dram_controller_ack_read_pulse_side_dram | dram_controller_req_read_pulse_side_dram)?dram_controller_req_read_pulse_side_dram:dram_controller_req_read_pending_state;

always @(posedge main_clk) begin
	dram_controller_req_read_pending_state<=dram_controller_req_read_pending;
end




reg [9:0] refresh_counter=0;
reg refresh_req=0;
reg refresh_ack=0;
always @(posedge main_clk) begin
	refresh_counter<=refresh_counter+1'd1;
	// send refresh every 976 cycles. However, because of potential delays, it is sent slightly more frequently (960 cycles).
	// this needs to be recalculated
	if (refresh_ack) refresh_req<=0;
	if (refresh_counter==10'd960) begin
		refresh_req<=1;
		refresh_counter<=0;
	end
end




wire [21:0] addr_req_read;
assign addr_req_read={addr_req_read_dram_side_dram,addr_req_common_side_dram};
wire [21:0] addr_req_write;
assign addr_req_write={addr_req_write_dram_side_dram,addr_req_common_side_dram};

wire [21:0] addr_prefetch_next;
assign addr_prefetch_next=addr_req_read+1'b1;


reg [21:0]  addr_prefetched=0;
reg [127:0] lane_prefetched=0;
reg prefeched_is_valid=0;

reg [21:0]  addr_for_read=0;
reg [12:0]  addr_for_write_upper=0;
wire [21:0]  addr_for_write;
assign addr_for_write={addr_for_write_upper,addr_for_read[8:0]};
reg  write_needed_because_dirty=0;


// have address line up like this: {col[6:4],row[12:7],col[3:0],row[6:0],bank[1:0]}=={addr_req_rwr[12:0],addr_req_common[8:0]}
// means that same bank will always be accessed for a read/write pair. this costs some efficiency, though it does make the controller somewhat easier.
// all nearby addresses (for prefetch) are avalible through accessing alternative banks, increasing efficiency (prefetch could always occur at nearly no cycle cost)
// the most likely faults would occur on banks not accessed recently (except possible collision from prefetch), increasing efficiency for turnaround time

wire [6:0] dram_addr_col_for_read_from_unsaved;
wire [6:0] dram_addr_col_for_read_from_saved;
wire [12:0] dram_addr_row_for_read_from_unsaved;
wire [12:0] dram_addr_row_for_read_from_saved;
wire [1:0] dram_addr_bank_for_read_from_unsaved;
wire [1:0] dram_addr_bank_for_read_from_saved;

assign dram_addr_col_for_read_from_unsaved={addr_req_read[21:19],addr_req_read[12:9]};
assign dram_addr_col_for_read_from_saved  ={addr_for_read[21:19],addr_for_read[12:9]};
assign dram_addr_row_for_read_from_unsaved={addr_req_read[18:13],addr_req_read[ 8:2]};
assign dram_addr_row_for_read_from_saved  ={addr_for_read[18:13],addr_for_read[ 8:2]};
assign dram_addr_bank_for_read_from_unsaved=addr_req_read[1:0];
assign dram_addr_bank_for_read_from_saved  =addr_for_read[1:0];

wire [6:0] dram_addr_col_for_write_from_saved;
wire [12:0] dram_addr_row_for_write_from_saved;
wire [1:0] dram_addr_bank_for_write_from_saved;

assign dram_addr_col_for_write_from_saved  ={addr_for_write[21:19],addr_for_write[12:9]};
assign dram_addr_row_for_write_from_saved  ={addr_for_write[18:13],addr_for_write[ 8:2]};
assign dram_addr_bank_for_write_from_saved  =addr_for_write[1:0];

wire [6:0] dram_addr_col_for_prefetch_from_saved;
wire [12:0] dram_addr_row_for_prefetch_from_saved;
wire [1:0] dram_addr_bank_for_prefetch_from_saved;

assign dram_addr_col_for_prefetch_from_saved  ={addr_prefetched[21:19],addr_prefetched[12:9]};
assign dram_addr_row_for_prefetch_from_saved  ={addr_prefetched[18:13],addr_prefetched[ 8:2]};
assign dram_addr_bank_for_prefetch_from_saved  =addr_prefetched[1:0];



reg [5:0] controller_state=0;


always @(posedge main_clk) begin
	controller_state<=controller_state; // assignment not needed, it is implied
	
	dram_controller_ack_read_pulse_r<=0;
	DRAM_DQ_oe_r<=0;
	DRAM_ADDR_r<=0;
	DRAM_BA_r<=0;
	DRAM_CAS_r<=1;
	DRAM_RAS_r<=1;
	DRAM_WE_r<=1;
	DRAM_DQM_r<=1;
	if (bank_status_general[0]!=0) bank_status_general[0]<=bank_status_general[0]-1'd1;
	if (bank_status_general[1]!=0) bank_status_general[1]<=bank_status_general[1]-1'd1;
	if (bank_status_general[2]!=0) bank_status_general[2]<=bank_status_general[2]-1'd1;
	if (bank_status_general[3]!=0) bank_status_general[3]<=bank_status_general[3]-1'd1;
	
	unique case (controller_state)
	0:begin // initialize
		if          (initializer_countdown==15'd93) begin
			DRAM_RAS_r<=0;
			DRAM_WE_r <=0;
			DRAM_ADDR_r[10]<=1'b1;
		end else if (initializer_countdown==15'd90) begin
			DRAM_CAS_r<=0;
			DRAM_RAS_r<=0;
		end else if (initializer_countdown==15'd80) begin
			DRAM_CAS_r<=0;
			DRAM_RAS_r<=0;
		end else if (initializer_countdown==15'd70) begin
			DRAM_CAS_r<=0;
			DRAM_RAS_r<=0;
		end else if (initializer_countdown==15'd60) begin
			DRAM_CAS_r<=0;
			DRAM_RAS_r<=0;
		end else if (initializer_countdown==15'd50) begin
			DRAM_CAS_r<=0;
			DRAM_RAS_r<=0;
		end else if (initializer_countdown==15'd40) begin
			DRAM_CAS_r<=0;
			DRAM_RAS_r<=0;
		end else if (initializer_countdown==15'd30) begin
			DRAM_CAS_r<=0;
			DRAM_RAS_r<=0;
		end else if (initializer_countdown==15'd20) begin
			DRAM_CAS_r<=0;
			DRAM_RAS_r<=0;
		end else if (initializer_countdown==15'd10) begin
			DRAM_CAS_r<=0;
			DRAM_RAS_r<=0;
			DRAM_WE_r <=0;
			DRAM_ADDR_r<=13'b000000_010_0_011; // mode register set
		end else if (initializer_countdown==15'd1 ) begin
			controller_state<=1;
		end
	end
	1:begin
		if (refresh_req) begin
			// if a refresh_req is active, no req_read are serviced until after it is performed
			if ((bank_status_general[0]==0) && (bank_status_general[1]==0) && (bank_status_general[2]==0) && (bank_status_general[3]==0)) begin
				controller_state<=2;
				refresh_ack<=1;
			end
		end else if (dram_controller_req_read_pending) begin
			controller_state<=3;
		end
	end
	2:begin
		bank_status_general[0]<=7;// the delay required is 8, but 7 is set on purpose. 
		bank_status_general[1]<=7;// 8-1 is because of how delays work using this system of decrementing.
		bank_status_general[2]<=7;// setting a 7 causes the system to wait for 8 cycles beyond the current cycle, because the current cycle is not counted
		bank_status_general[3]<=7;// :::::::this delay needs to be recalculated
		DRAM_CAS_r<=0;
		DRAM_RAS_r<=0;
		controller_state<=1;
	end
	3:begin
		if (prefeched_is_valid && (addr_prefetched==addr_req_read)) begin
			controller_state<=40;
			addr_for_read<=addr_req_read;
		end else if (bank_status_general[addr_req_read_dram_side_dram[1:0]]==0) begin
			controller_state<=4;
			prefeched_is_valid<=1; // prefetch will occur, bank is garenteed to be ready when it is needed (todo: check that)
			addr_prefetched<=addr_prefetch_next;
			addr_for_read<=addr_req_read;
			DRAM_RAS_r<=0;// activate command
			DRAM_ADDR_r<=dram_addr_row_for_read_from_unsaved;
			DRAM_BA_r<=dram_addr_bank_for_read_from_unsaved;
		end
	end
	4:begin
		controller_state<=5;
	end
	5:begin
		controller_state<=6;
		DRAM_CAS_r<=0;// read command
		DRAM_BA_r<=dram_addr_bank_for_read_from_saved;
		DRAM_ADDR_r[2:0]<=3'd0;
		DRAM_ADDR_r[9:3]<=dram_addr_col_for_read_from_saved;
		DRAM_ADDR_r[10]<=1'b1;
		DRAM_DQM_r<=0;
	end
	6:begin
		controller_state<=7;
		DRAM_DQM_r<=0;
		
		// might be able to be sooner
		addr_for_write_upper<=addr_req_write_dram_side_dram;
		write_needed_because_dirty<=dram_controller_entry_dirty_side_dram;
		lane_from_cache_to_dram<=lane_from_cache_to_dram_side_dram;
	end
	7:begin
		controller_state<=8;
		DRAM_DQM_r<=0;
	end
	8:begin
		controller_state<=9;
		DRAM_DQM_r<=0;
	end
	9:begin
		controller_state<=10;
		DRAM_DQM_r<=0;
	end
	10:begin
		controller_state<=11;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 15:  0]<=DRAM_DQ_rIN;
	end
	11:begin
		controller_state<=12;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 31: 16]<=DRAM_DQ_rIN;
		DRAM_RAS_r<=0;// activate command
		DRAM_ADDR_r<=dram_addr_row_for_prefetch_from_saved;
		DRAM_BA_r<=dram_addr_bank_for_prefetch_from_saved;
	end
	12:begin
		controller_state<=13;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 47: 32]<=DRAM_DQ_rIN;
	end
	13:begin
		controller_state<=14;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 63: 48]<=DRAM_DQ_rIN;
		DRAM_CAS_r<=0;// read command
		DRAM_BA_r<=dram_addr_bank_for_prefetch_from_saved;
		DRAM_ADDR_r[2:0]<=3'd0;
		DRAM_ADDR_r[9:3]<=dram_addr_col_for_prefetch_from_saved;
		DRAM_ADDR_r[10]<=1'b1;
	end
	14:begin
		controller_state<=15;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 79: 64]<=DRAM_DQ_rIN;
	end
	15:begin
		controller_state<=16;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 95: 80]<=DRAM_DQ_rIN;
	end
	16:begin
		controller_state<=17;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[111: 96]<=DRAM_DQ_rIN;
	end
	17:begin
		controller_state<=18;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[127:112]<=DRAM_DQ_rIN;
	end
	18:begin
		controller_state<=19;
		DRAM_DQM_r<=0;
		lane_prefetched[ 15:  0]<=DRAM_DQ_rIN;
		dram_controller_ack_read_pulse_r<=1;
	end
	19:begin
		controller_state<=20;
		DRAM_DQM_r<=0;
		lane_prefetched[ 31: 16]<=DRAM_DQ_rIN;
	end
	20:begin
		controller_state<=21;
		DRAM_DQM_r<=0;
		lane_prefetched[ 47: 32]<=DRAM_DQ_rIN;
	end
	21:begin
		controller_state<=22;
		DRAM_DQM_r<=0;
		lane_prefetched[ 63: 48]<=DRAM_DQ_rIN;
	end
	22:begin
		controller_state<=23;
		lane_prefetched[ 79: 64]<=DRAM_DQ_rIN;
		
		if (write_needed_because_dirty) begin
			DRAM_RAS_r<=0;// activate command
			DRAM_ADDR_r<=dram_addr_row_for_write_from_saved;
			DRAM_BA_r<=dram_addr_bank_for_write_from_saved;
		end
	end
	23:begin
		controller_state<=24;
		lane_prefetched[ 95: 80]<=DRAM_DQ_rIN;
	end
	24:begin
		controller_state<=25;
		lane_prefetched[111: 96]<=DRAM_DQ_rIN;
	end
	25:begin
		lane_prefetched[127:112]<=DRAM_DQ_rIN;
		
		if (write_needed_because_dirty) begin
			controller_state<=28;
			DRAM_CAS_r<=0;// write command
			DRAM_WE_r<=0;
			DRAM_BA_r<=dram_addr_bank_for_write_from_saved;
			DRAM_ADDR_r[2:0]<=3'd0;
			DRAM_ADDR_r[9:3]<=dram_addr_col_for_write_from_saved;
			DRAM_ADDR_r[10]<=1'b1;
			
			DRAM_DQM_r<=0;
			DRAM_DQ_oe_r<=1;
			DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 15:  0];
		end else begin
			controller_state<=1;
			bank_status_general[dram_addr_bank_for_prefetch_from_saved]<=7; // delay here is just a placeholder
		end
	end
	28:begin
		controller_state<=29;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 31: 16];
	end
	29:begin
		controller_state<=30;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 47: 32];
	end
	30:begin
		controller_state<=31;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 63: 48];
	end
	31:begin
		controller_state<=32;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 79: 64];
	end
	32:begin
		controller_state<=33;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 95: 80];
	end
	33:begin
		controller_state<=34;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[111: 96];
	end
	34:begin
		controller_state<=1;
		bank_status_general[dram_addr_bank_for_write_from_saved]<=7; // delay here is just a placeholder
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[127:112];
	end
	
	40:begin
		controller_state<=41;
		lane_from_dram_to_cache<=lane_prefetched;
		prefeched_is_valid<=0;
	end
	41:begin
		controller_state<=42;
	end
	42:begin
		// might be able to be sooner
		dram_controller_ack_read_pulse_r<=1;
		lane_from_cache_to_dram<=lane_from_cache_to_dram_side_dram;
		addr_for_write_upper<=addr_req_write_dram_side_dram;
		
		if (dram_controller_entry_dirty_side_dram) begin
			controller_state<=43;
		end else begin
			controller_state<=1;
		end
	end
	43:begin
		if (bank_status_general[dram_addr_bank_for_write_from_saved]==0) begin
			controller_state<=44;
			
			DRAM_RAS_r<=0;// activate command
			DRAM_ADDR_r<=dram_addr_row_for_write_from_saved;
			DRAM_BA_r<=dram_addr_bank_for_write_from_saved;
		end
	end
	44:begin
		controller_state<=45;
	end
	45:begin
		controller_state<=46;
		
		DRAM_CAS_r<=0;// write command
		DRAM_WE_r<=0;
		DRAM_BA_r<=dram_addr_bank_for_write_from_saved;
		DRAM_ADDR_r[2:0]<=3'd0;
		DRAM_ADDR_r[9:3]<=dram_addr_col_for_write_from_saved;
		DRAM_ADDR_r[10]<=1'b1;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 15:  0];
	end
	46:begin
		controller_state<=47;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 31: 16];
	end
	47:begin
		controller_state<=48;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 47: 32];
	end
	48:begin
		controller_state<=49;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 63: 48];
	end
	49:begin
		controller_state<=50;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 79: 64];
	end
	50:begin
		controller_state<=51;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[ 95: 80];
	end
	51:begin
		controller_state<=52;
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[111: 96];
	end
	52:begin
		controller_state<=1;
		bank_status_general[dram_addr_bank_for_write_from_saved]<=7; // delay here is just a placeholder
		
		DRAM_DQM_r<=0;
		DRAM_DQ_oe_r<=1;
		DRAM_DQ_rOUT<=lane_from_cache_to_dram[127:112];
	end
	endcase
end



endmodule


module cache_LRU_sub_read_through_write(
input  main_clk,
input  [4:0] perm_in,
input  [8:0] read_addr,
input  [8:0] write_addr,
input  enable_write,
output [4:0] perm_out
);

reg [4:0] perm_in_r=0;
reg do_override=0;

always @(posedge main_clk) begin
	perm_in_r<=perm_in;
	do_override<=(enable_write && (write_addr==read_addr))?1'b1:1'b0;
end

wire [4:0] raw_perm_out;

assign perm_out=do_override?perm_in_r:raw_perm_out;

`ifdef USE_FORMAL
fo_cache_LRU fo_cache_LRU_inst(
`else
ip_cache_LRU ip_cache_LRU_inst(
`endif
	main_clk,
	perm_in,
	read_addr,
	write_addr,
	enable_write,
	raw_perm_out
);

endmodule



module cache_LRU_old( // more tested
	output [1:0] least_used_index,

	input  [8:0] addr,
	input  [1:0] used_index,
	input  enable_write,
	input  main_clk
);

reg  [1:0] used_index_r;
reg  [1:0] used_index_delayed;
reg  enable_write_r=0;
reg  enable_write_delayed=0;
wire enable_write_delayed_w;assign enable_write_delayed_w=enable_write_delayed;
reg  [8:0] read_addr=0;
wire [8:0] read_addr_w;assign read_addr_w=read_addr;
reg  [8:0] write_addr=0;
wire [8:0] write_addr_w;assign write_addr_w=write_addr;
wire [4:0] raw_perm_out;
wire [4:0] raw_perm_in;
reg  [1:0] least_used_index_calc_r;
assign least_used_index=least_used_index_calc_r;
wire [1:0] least_used_index_calc;


`include "AutoGen0.sv"


always @(posedge main_clk) begin
	enable_write_r<=enable_write;
	enable_write_delayed<=enable_write_r;
	used_index_r<=used_index;
	used_index_delayed<=used_index_r;
	read_addr<=addr;
	write_addr<=read_addr;
	least_used_index_calc_r<=least_used_index_calc;
end

cache_LRU_sub_read_through_write cache_LRU_sub_read_through_write_inst(
	main_clk,
	raw_perm_in,
	read_addr_w,
	write_addr_w,
	enable_write_delayed_w,
	raw_perm_out
);

endmodule


module cache_LRU( // not really tested, but would be one cycle faster (so that dram controller could be a little faster)
	output [1:0] least_used_index,

	input  [8:0] addr,
	input  [1:0] used_index,
	input  enable_write,
	input  main_clk
);

reg  [1:0] used_index_delayed;
reg  enable_write_delayed=0;
wire [8:0] read_addr;assign read_addr=addr;
reg  [8:0] write_addr=0;
wire [4:0] raw_perm_out;
wire [4:0] raw_perm_in;
reg  [1:0] least_used_index_calc_r;
assign least_used_index=least_used_index_calc_r;
wire [1:0] least_used_index_calc;


`include "AutoGen0.sv"


always @(posedge main_clk) begin
	enable_write_delayed<=enable_write;
	used_index_delayed<=used_index;
	write_addr<=read_addr;
	least_used_index_calc_r<=least_used_index_calc;
end

cache_LRU_sub_read_through_write cache_LRU_sub_read_through_write_inst(
	main_clk,
	raw_perm_in,
	read_addr,
	write_addr,
	enable_write_delayed,
	raw_perm_out
);

endmodule


module cache_data(
	output out_dirty, // out_dirty only refers to the single_access_out_full_data
	
	output [15:0] multi_access_out_full_data_extern [7:0],
	output [15:0] single_access_out_full_data_extern [7:0],
	input  [15:0] access_mask,
	output [127:0] raw_out_full_data_extern,
	
	input  [15:0] access_in_full_data [7:0],
	input  [127:0] raw_in_full_data,
	
	input  [8:0] target_segment,
	input  [1:0] target_way_read,
	input  [1:0] target_way_write,
	
	input  do_full_write,
	input  do_partial_write,
	input  do_byte_operation,
	
	input  override_no_write, // unless do_full_write
	input  calculated_cache_fault,
	
	input  main_clk

`ifdef USE_FORMAL
,input formal_init_finished
,input init_set_cache_sig
,input [10:0] formal_init_addr
,input [127:0] formal_init_data
`endif

);

reg [15:0] multi_access_out_full_data [7:0];
reg [15:0] single_access_out_full_data [7:0];
reg [127:0] raw_out_full_data;


assign raw_out_full_data_extern=raw_out_full_data;
assign single_access_out_full_data_extern=single_access_out_full_data;
assign multi_access_out_full_data_extern=multi_access_out_full_data;

reg [15:0] masked_out_full_data [7:0];

reg [15:0] access_mask_r;
reg [15:0] single_access_out_full_data_r [7:0];
reg do_byte_operation_r=0;

always_comb begin
	masked_out_full_data[0]={({8{access_mask_r[ 1]}}),({8{access_mask_r[ 0]}})} & raw_out_full_data[ 15:  0];
	masked_out_full_data[1]={({8{access_mask_r[ 3]}}),({8{access_mask_r[ 2]}})} & raw_out_full_data[ 31: 16];
	masked_out_full_data[2]={({8{access_mask_r[ 5]}}),({8{access_mask_r[ 4]}})} & raw_out_full_data[ 47: 32];
	masked_out_full_data[3]={({8{access_mask_r[ 7]}}),({8{access_mask_r[ 6]}})} & raw_out_full_data[ 63: 48];
	masked_out_full_data[4]={({8{access_mask_r[ 9]}}),({8{access_mask_r[ 8]}})} & raw_out_full_data[ 79: 64];
	masked_out_full_data[5]={({8{access_mask_r[11]}}),({8{access_mask_r[10]}})} & raw_out_full_data[ 95: 80];
	masked_out_full_data[6]={({8{access_mask_r[13]}}),({8{access_mask_r[12]}})} & raw_out_full_data[111: 96];
	masked_out_full_data[7]={({8{access_mask_r[15]}}),({8{access_mask_r[14]}})} & raw_out_full_data[127:112];
end

wire do_write=do_full_write | (do_partial_write & !override_no_write & !calculated_cache_fault);

reg [127:0] write_data;
reg [15:0] byte_enable;

always_comb begin
	if (do_full_write) begin
		write_data=raw_in_full_data;
	end else begin
		write_data[ 15:  0]=access_in_full_data[0];
		write_data[ 31: 16]=access_in_full_data[1];
		write_data[ 47: 32]=access_in_full_data[2];
		write_data[ 63: 48]=access_in_full_data[3];
		write_data[ 79: 64]=access_in_full_data[4];
		write_data[ 95: 80]=access_in_full_data[5];
		write_data[111: 96]=access_in_full_data[6];
		write_data[127:112]=access_in_full_data[7];
	end
end

always_comb begin
	byte_enable[0]=access_mask[0];
	byte_enable[1]=access_mask[1];
	byte_enable[2]=access_mask[2];
	byte_enable[3]=access_mask[3];
	byte_enable[4]=access_mask[4];
	byte_enable[5]=access_mask[5];
	byte_enable[6]=access_mask[6];
	byte_enable[7]=access_mask[7];
	byte_enable[8]=access_mask[8];
	byte_enable[9]=access_mask[9];
	byte_enable[10]=access_mask[10];
	byte_enable[11]=access_mask[11];
	byte_enable[12]=access_mask[12];
	byte_enable[13]=access_mask[13];
	byte_enable[14]=access_mask[14];
	byte_enable[15]=access_mask[15];
	byte_enable=byte_enable | {16{do_full_write}};
end

reg [2:0] word_offset=0;

reg [3:0] temp0_word_size=0;
reg [3:0] temp1_word_size=0;
reg [3:0] temp2_word_size=0;
reg [2:0] word_size=0; // word_size is one cycle behind word_offset

always_comb begin
	unique case({(access_mask[ 5] | access_mask[ 4]),(access_mask[ 3] | access_mask[ 2]),(access_mask[ 1] | access_mask[ 0])})
	3'b000:temp0_word_size<=0;
	3'b001:temp0_word_size<=1;
	3'b010:temp0_word_size<=1;
	3'b011:temp0_word_size<=2;
	3'b100:temp0_word_size<=1;
	3'b101:temp0_word_size<=2;
	3'b110:temp0_word_size<=2;
	3'b111:temp0_word_size<=3;
	endcase
	unique case({(access_mask[11] | access_mask[10]),(access_mask[ 9] | access_mask[ 8]),(access_mask[ 7] | access_mask[ 6])})
	3'b000:temp1_word_size<=0;
	3'b001:temp1_word_size<=1;
	3'b010:temp1_word_size<=1;
	3'b011:temp1_word_size<=2;
	3'b100:temp1_word_size<=1;
	3'b101:temp1_word_size<=2;
	3'b110:temp1_word_size<=2;
	3'b111:temp1_word_size<=3;
	endcase
	unique case({(access_mask[15] | access_mask[14]),(access_mask[13] | access_mask[12])})
	2'b00:temp2_word_size<=0;
	2'b01:temp2_word_size<=1;
	2'b10:temp2_word_size<=1;
	2'b11:temp2_word_size<=2;
	endcase
end

always @(posedge main_clk) begin
	if (!calculated_cache_fault) begin
		access_mask_r<=access_mask;
		single_access_out_full_data_r<=single_access_out_full_data;
		do_byte_operation_r<=do_byte_operation;
		
		word_size <= (temp0_word_size + temp1_word_size + temp2_word_size) - 4'h1; // "truncated value with size 4 to match size of target (3)" warning is expected here. It is fine
		
		word_offset<=3'h0;
		if (access_mask[15] | access_mask[14]) word_offset<=3'h7;
		if (access_mask[13] | access_mask[12]) word_offset<=3'h6;
		if (access_mask[11] | access_mask[10]) word_offset<=3'h5;
		if (access_mask[ 9] | access_mask[ 8]) word_offset<=3'h4;
		if (access_mask[ 7] | access_mask[ 6]) word_offset<=3'h3;
		if (access_mask[ 5] | access_mask[ 4]) word_offset<=3'h2;
		if (access_mask[ 3] | access_mask[ 2]) word_offset<=3'h1;
		if (access_mask[ 1] | access_mask[ 0]) word_offset<=3'h0;
	end
end


always_comb begin
	single_access_out_full_data[0]=0;
	single_access_out_full_data[1]=0;
	single_access_out_full_data[2]=0;
	single_access_out_full_data[3]=0;
	single_access_out_full_data[4]=0;
	single_access_out_full_data[5]=0;
	single_access_out_full_data[6]=0;
	single_access_out_full_data[7]=0;
	
	unique case (word_offset)
	0:begin
		single_access_out_full_data[0]=masked_out_full_data[0];
		single_access_out_full_data[1]=masked_out_full_data[1];
		single_access_out_full_data[2]=masked_out_full_data[2];
		single_access_out_full_data[3]=masked_out_full_data[3];
		single_access_out_full_data[4]=masked_out_full_data[4];
		single_access_out_full_data[5]=masked_out_full_data[5];
		single_access_out_full_data[6]=masked_out_full_data[6];
		single_access_out_full_data[7]=masked_out_full_data[7];
	end
	1:begin
		single_access_out_full_data[0]=masked_out_full_data[1];
		single_access_out_full_data[1]=masked_out_full_data[2];
		single_access_out_full_data[2]=masked_out_full_data[3];
		single_access_out_full_data[3]=masked_out_full_data[4];
		single_access_out_full_data[4]=masked_out_full_data[5];
		single_access_out_full_data[5]=masked_out_full_data[6];
		single_access_out_full_data[6]=masked_out_full_data[7];
	end
	2:begin
		single_access_out_full_data[0]=masked_out_full_data[2];
		single_access_out_full_data[1]=masked_out_full_data[3];
		single_access_out_full_data[2]=masked_out_full_data[4];
		single_access_out_full_data[3]=masked_out_full_data[5];
		single_access_out_full_data[4]=masked_out_full_data[6];
		single_access_out_full_data[5]=masked_out_full_data[7];
	end
	3:begin
		single_access_out_full_data[0]=masked_out_full_data[3];
		single_access_out_full_data[1]=masked_out_full_data[4];
		single_access_out_full_data[2]=masked_out_full_data[5];
		single_access_out_full_data[3]=masked_out_full_data[6];
		single_access_out_full_data[4]=masked_out_full_data[7];
	end
	4:begin
		single_access_out_full_data[0]=masked_out_full_data[4];
		single_access_out_full_data[1]=masked_out_full_data[5];
		single_access_out_full_data[2]=masked_out_full_data[6];
		single_access_out_full_data[3]=masked_out_full_data[7];
	end
	5:begin
		single_access_out_full_data[0]=masked_out_full_data[5];
		single_access_out_full_data[1]=masked_out_full_data[6];
		single_access_out_full_data[2]=masked_out_full_data[7];
	end
	6:begin
		single_access_out_full_data[0]=masked_out_full_data[6];
		single_access_out_full_data[1]=masked_out_full_data[7];
	end
	7:begin
		single_access_out_full_data[0]=masked_out_full_data[7];
	end
	endcase
	
	if (do_byte_operation_r) begin
		single_access_out_full_data[0][ 7: 0]=single_access_out_full_data[0][ 7: 0] | single_access_out_full_data[0][15: 8];
		single_access_out_full_data[0][15: 8]=8'h0;
	end
end



always_comb begin
	multi_access_out_full_data=single_access_out_full_data_r;
	
	unique case (word_size)
	0:begin
		multi_access_out_full_data[1]=single_access_out_full_data[0];
		multi_access_out_full_data[2]=single_access_out_full_data[1];
		multi_access_out_full_data[3]=single_access_out_full_data[2];
		multi_access_out_full_data[4]=single_access_out_full_data[3];
		multi_access_out_full_data[5]=single_access_out_full_data[4];
		multi_access_out_full_data[6]=single_access_out_full_data[5];
		multi_access_out_full_data[7]=single_access_out_full_data[6];
	end
	1:begin
		multi_access_out_full_data[2]=single_access_out_full_data[0];
		multi_access_out_full_data[3]=single_access_out_full_data[1];
		multi_access_out_full_data[4]=single_access_out_full_data[2];
		multi_access_out_full_data[5]=single_access_out_full_data[3];
		multi_access_out_full_data[6]=single_access_out_full_data[4];
		multi_access_out_full_data[7]=single_access_out_full_data[5];
	end
	2:begin
		multi_access_out_full_data[3]=single_access_out_full_data[0];
		multi_access_out_full_data[4]=single_access_out_full_data[1];
		multi_access_out_full_data[5]=single_access_out_full_data[2];
		multi_access_out_full_data[6]=single_access_out_full_data[3];
		multi_access_out_full_data[7]=single_access_out_full_data[4];
	end
	3:begin
		multi_access_out_full_data[4]=single_access_out_full_data[4];
		multi_access_out_full_data[5]=single_access_out_full_data[5];
		multi_access_out_full_data[6]=single_access_out_full_data[6];
		multi_access_out_full_data[7]=single_access_out_full_data[7];
	end
	4:begin
		multi_access_out_full_data[5]=single_access_out_full_data[5];
		multi_access_out_full_data[6]=single_access_out_full_data[6];
		multi_access_out_full_data[7]=single_access_out_full_data[7];
	end
	5:begin
		multi_access_out_full_data[6]=single_access_out_full_data[6];
		multi_access_out_full_data[7]=single_access_out_full_data[7];
	end
	6:begin
		multi_access_out_full_data[7]=single_access_out_full_data[7];
	end
	7:begin
	end
	endcase
end



`ifdef USE_FORMAL
fo_cache_data fo_cache_data_inst(
`else
ip_cache_data ip_cache_data_inst(
`endif
	byte_enable,
	main_clk,
	write_data,
	{
		target_way_read,
		target_segment
	},
	{
		target_way_write,
		target_segment
	},
	do_write,
	raw_out_full_data
`ifdef USE_FORMAL
,formal_init_finished
,init_set_cache_sig
,formal_init_addr
,formal_init_data
`endif
);

`ifdef USE_FORMAL
fo_cache_dirty fo_cache_dirty_inst(
`else
ip_cache_dirty ip_cache_dirty_inst(
`endif
	main_clk,
	do_write && !do_full_write,
	{
		target_way_read,
		target_segment
	},
	{
		target_way_write,
		target_segment
	},
	do_write,
	out_dirty
);

endmodule




module cache_way(
	output [12:0] out_addr_at_in_way_index, // `address[25:13]` for the way located by `in_way_index` and `target_address[12: 4]`
	
	output out_fault,
	output [ 1:0] out_way_index,
	
	input  [ 1:0] in_way_index,
	
	input  [25:0] target_address,
	
	input do_write,
	input main_clk

`ifdef USE_FORMAL
,input formal_init_finished
,input init_set_way_sig
,input [  8:0] formal_init_addr
,input [127:0] formal_init_data
`endif

);

reg [12:0] saved_target=0;
reg [3:0] saved_bypass_data=0;

wire [12:0] out0;
wire [12:0] out1;
wire [12:0] out2;
wire [12:0] out3;

wire [12:0] raw_out0;
wire [12:0] raw_out1;
wire [12:0] raw_out2;
wire [12:0] raw_out3;

assign out0=(saved_bypass_data[0])?saved_target:raw_out0;
assign out1=(saved_bypass_data[1])?saved_target:raw_out1;
assign out2=(saved_bypass_data[2])?saved_target:raw_out2;
assign out3=(saved_bypass_data[3])?saved_target:raw_out3;



always @(posedge main_clk) begin
	saved_target<=target_address[25:13];
	saved_bypass_data<={
		((do_write && (in_way_index==2'd3))?1'b1:1'b0),
		((do_write && (in_way_index==2'd2))?1'b1:1'b0),
		((do_write && (in_way_index==2'd1))?1'b1:1'b0),
		((do_write && (in_way_index==2'd0))?1'b1:1'b0)
	};
end

assign out_addr_at_in_way_index=
	((in_way_index==2'd0)?out0:13'd0) | 
	((in_way_index==2'd1)?out1:13'd0) | 
	((in_way_index==2'd2)?out2:13'd0) | 
	((in_way_index==2'd3)?out3:13'd0);

// [25:13]
// [12: 4]



`ifdef USE_FORMAL
fo_cache_addr_wayx fo_cache_addr_way0_inst(
`else
ip_cache_addr_way0 ip_cache_addr_way0_inst(
`endif
	main_clk,
	target_address[25:13],
	target_address[12: 4],
	target_address[12: 4],
	do_write && (in_way_index==2'd0),
	raw_out0
`ifdef USE_FORMAL
,formal_init_finished
,formal_init_sig
,formal_init_addr
,formal_init_data[ 12:  0]
,2'd0
`endif
);



`ifdef USE_FORMAL
fo_cache_addr_wayx fo_cache_addr_way1_inst(
`else
ip_cache_addr_way1 ip_cache_addr_way1_inst(
`endif
	main_clk,
	target_address[25:13],
	target_address[12: 4],
	target_address[12: 4],
	do_write && (in_way_index==2'd1),
	raw_out1
`ifdef USE_FORMAL
,formal_init_finished
,formal_init_sig
,formal_init_addr
,formal_init_data[ 44: 32]
,2'd1
`endif
);



`ifdef USE_FORMAL
fo_cache_addr_wayx fo_cache_addr_way2_inst(
`else
ip_cache_addr_way2 ip_cache_addr_way2_inst(
`endif
	main_clk,
	target_address[25:13],
	target_address[12: 4],
	target_address[12: 4],
	do_write && (in_way_index==2'd2),
	raw_out2
`ifdef USE_FORMAL
,formal_init_finished
,formal_init_sig
,formal_init_addr
,formal_init_data[ 76: 64]
,2'd2
`endif
);



`ifdef USE_FORMAL
fo_cache_addr_wayx fo_cache_addr_way3_inst(
`else
ip_cache_addr_way3 ip_cache_addr_way3_inst(
`endif
	main_clk,
	target_address[25:13],
	target_address[12: 4],
	target_address[12: 4],
	do_write && (in_way_index==2'd3),
	raw_out3
`ifdef USE_FORMAL
,formal_init_finished
,formal_init_sig
,formal_init_addr
,formal_init_data[108: 96]
,2'd3
`endif
);

`ifdef USE_FORMAL
always_comb begin
	if (init_set_way_sig) begin
		assume (formal_init_data[ 12:  0]!=formal_init_data[ 44: 32]);
		assume (formal_init_data[ 12:  0]!=formal_init_data[ 76: 64]);
		assume (formal_init_data[ 12:  0]!=formal_init_data[108: 96]);

		assume (formal_init_data[ 44: 32]!=formal_init_data[ 76: 64]);
		assume (formal_init_data[ 44: 32]!=formal_init_data[108: 96]);
		
		assume (formal_init_data[ 76: 64]!=formal_init_data[108: 96]);
	end
end
`endif

wire [1:0] way_index_lookup [7:0];
assign way_index_lookup[{1'b0,1'b0,1'b0}]=2'd0;
assign way_index_lookup[{1'b0,1'b0,1'b1}]=2'd1;
assign way_index_lookup[{1'b0,1'b1,1'b0}]=2'd2;
assign way_index_lookup[{1'b0,1'b1,1'b1}]=2'd1;
assign way_index_lookup[{1'b1,1'b0,1'b0}]=2'd3;
assign way_index_lookup[{1'b1,1'b0,1'b1}]=2'd1;
assign way_index_lookup[{1'b1,1'b1,1'b0}]=2'd2;
assign way_index_lookup[{1'b1,1'b1,1'b1}]=2'd1;

wire [3:0] match;
assign match={
	((out3==saved_target)?1'b1:1'b0),
	((out2==saved_target)?1'b1:1'b0),
	((out1==saved_target)?1'b1:1'b0),
	((out0==saved_target)?1'b1:1'b0)
};
assign out_way_index=way_index_lookup[{match[3],match[2],match[1]}];
assign out_fault=!match[0] & !match[1] & !match[2] & !match[3];

endmodule

`ifdef USE_FORMAL
module lcell(input in,output out);
assign out=in;
endmodule
`endif


module lcell_1(output o,input  i);
lcell lc0 (.in(i),.out(o));
endmodule
module lcell_2(output [1:0] o,input  [1:0] i);
lcell lc0 (.in(i[0]),.out(o[0]));
lcell lc1 (.in(i[1]),.out(o[1]));
endmodule
module lcell_3(output [2:0] o,input  [2:0] i);
lcell lc0 (.in(i[0]),.out(o[0]));
lcell lc1 (.in(i[1]),.out(o[1]));
lcell lc2 (.in(i[2]),.out(o[2]));
endmodule
module lcell_4(output [3:0] o,input  [3:0] i);
lcell lc0 (.in(i[0]),.out(o[0]));
lcell lc1 (.in(i[1]),.out(o[1]));
lcell lc2 (.in(i[2]),.out(o[2]));
lcell lc3 (.in(i[3]),.out(o[3]));
endmodule
module lcell_5(output [4:0] o,input  [4:0] i);
lcell lc0 (.in(i[0]),.out(o[0]));
lcell lc1 (.in(i[1]),.out(o[1]));
lcell lc2 (.in(i[2]),.out(o[2]));
lcell lc3 (.in(i[3]),.out(o[3]));
lcell lc4 (.in(i[4]),.out(o[4]));
endmodule
module lcell_6(output [5:0] o,input  [5:0] i);
lcell lc0 (.in(i[0]),.out(o[0]));
lcell lc1 (.in(i[1]),.out(o[1]));
lcell lc2 (.in(i[2]),.out(o[2]));
lcell lc3 (.in(i[3]),.out(o[3]));
lcell lc4 (.in(i[4]),.out(o[4]));
lcell lc5 (.in(i[5]),.out(o[5]));
endmodule
module lcell_16(output [15:0] o,input  [15:0] i);
lcell lc0 (.in(i[0]),.out(o[0]));
lcell lc1 (.in(i[1]),.out(o[1]));
lcell lc2 (.in(i[2]),.out(o[2]));
lcell lc3 (.in(i[3]),.out(o[3]));
lcell lc4 (.in(i[4]),.out(o[4]));
lcell lc5 (.in(i[5]),.out(o[5]));
lcell lc6 (.in(i[6]),.out(o[6]));
lcell lc7 (.in(i[7]),.out(o[7]));
lcell lc8 (.in(i[8]),.out(o[8]));
lcell lc9 (.in(i[9]),.out(o[9]));
lcell lc10 (.in(i[10]),.out(o[10]));
lcell lc11 (.in(i[11]),.out(o[11]));
lcell lc12 (.in(i[12]),.out(o[12]));
lcell lc13 (.in(i[13]),.out(o[13]));
lcell lc14 (.in(i[14]),.out(o[14]));
lcell lc15 (.in(i[15]),.out(o[15]));
endmodule
module lcell_26(output [25:0] o,input  [25:0] i);
lcell lc0 (.in(i[0]),.out(o[0]));
lcell lc1 (.in(i[1]),.out(o[1]));
lcell lc2 (.in(i[2]),.out(o[2]));
lcell lc3 (.in(i[3]),.out(o[3]));
lcell lc4 (.in(i[4]),.out(o[4]));
lcell lc5 (.in(i[5]),.out(o[5]));
lcell lc6 (.in(i[6]),.out(o[6]));
lcell lc7 (.in(i[7]),.out(o[7]));
lcell lc8 (.in(i[8]),.out(o[8]));
lcell lc9 (.in(i[9]),.out(o[9]));
lcell lc10 (.in(i[10]),.out(o[10]));
lcell lc11 (.in(i[11]),.out(o[11]));
lcell lc12 (.in(i[12]),.out(o[12]));
lcell lc13 (.in(i[13]),.out(o[13]));
lcell lc14 (.in(i[14]),.out(o[14]));
lcell lc15 (.in(i[15]),.out(o[15]));
lcell lc16 (.in(i[16]),.out(o[16]));
lcell lc17 (.in(i[17]),.out(o[17]));
lcell lc18 (.in(i[18]),.out(o[18]));
lcell lc19 (.in(i[19]),.out(o[19]));
lcell lc20 (.in(i[20]),.out(o[20]));
lcell lc21 (.in(i[21]),.out(o[21]));
lcell lc22 (.in(i[22]),.out(o[22]));
lcell lc23 (.in(i[23]),.out(o[23]));
lcell lc24 (.in(i[24]),.out(o[24]));
lcell lc25 (.in(i[25]),.out(o[25]));
endmodule




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
			// todo: actually do something when I/O mapped memory is read from or written to
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
			// todo: actually do something when I/O mapped memory is read from or written to
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
			// todo: actually do something when I/O mapped memory is read from or written to
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
			// todo: actually do something when I/O mapped memory is read from or written to
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


module full_memory(
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

`ifdef USE_FORMAL
,input formal_init_finished
,input init_set_cache_sig
,input init_set_way_sig
,input [ 10:0] formal_init_addr
,input [127:0] formal_init_data
`endif


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

`ifdef USE_FORMAL
,formal_init_finished
,init_set_way_sig
,formal_init_addr[8:0]
,formal_init_data
`endif


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

`ifdef USE_FORMAL
,formal_init_finished
,init_set_cache_sig
,formal_init_addr
,formal_init_data
`endif


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








