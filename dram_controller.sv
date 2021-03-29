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

assign DRAM_DQ=DRAM_DQ_oe_r ? DRAM_DQ_rOUT : 16'hZZZZ ;

always @(posedge main_clk) DRAM_DQ_rIN<=DRAM_DQ;


reg [127:0] lane_from_dram_to_cache=0;
reg [127:0] lane_from_cache_to_dram=0;

assign lane_from_dram_to_cache_side_dram=lane_from_dram_to_cache;


reg [2:0] bank_status_general [3:0]='{0,0,0,0}; // the value here is a cooldown/delay counter for when the bank can be accessed again

reg [15:0] initializer_countdown_internal=16'hFFFF;

//reg [15:0] initializer_countdown_internal=16'h8070; // this is for simulation to make it turn on faster



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
	if (refresh_counter==10'd660) begin // temp change to 660 for testing
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
			if (prefeched_is_valid && (addr_prefetched==addr_req_read)) begin
				controller_state<=40;
				addr_for_read<=addr_req_read;
				prefeched_is_valid<=0;
			end else if (bank_status_general[dram_addr_bank_for_read_from_unsaved]==0) begin
				controller_state<=4;
				prefeched_is_valid<=1; // prefetch will occur, bank is garenteed to be ready when it is needed (todo: check that)
				addr_prefetched<=addr_prefetch_next;
				addr_for_read<=addr_req_read;
				DRAM_RAS_r<=0;// activate command
				DRAM_ADDR_r<=dram_addr_row_for_read_from_unsaved;
				DRAM_BA_r<=dram_addr_bank_for_read_from_unsaved;
			end
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
	4:begin
		controller_state<=5;
		
		addr_for_write_upper<=addr_req_write_dram_side_dram;
		write_needed_because_dirty<=dram_controller_entry_dirty_side_dram;
		lane_from_cache_to_dram<=lane_from_cache_to_dram_side_dram;
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
		lane_from_dram_to_cache[ 15:  0]<=DRAM_DQ_rIN;
	end
	10:begin
		controller_state<=11;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 31: 16]<=DRAM_DQ_rIN;
	end
	11:begin
		controller_state<=12;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 47: 32]<=DRAM_DQ_rIN;
		DRAM_RAS_r<=0;// activate command
		DRAM_ADDR_r<=dram_addr_row_for_prefetch_from_saved;
		DRAM_BA_r<=dram_addr_bank_for_prefetch_from_saved;
	end
	12:begin
		controller_state<=13;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 63: 48]<=DRAM_DQ_rIN;
	end
	13:begin
		controller_state<=14;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 79: 64]<=DRAM_DQ_rIN;
		DRAM_CAS_r<=0;// read command
		DRAM_BA_r<=dram_addr_bank_for_prefetch_from_saved;
		DRAM_ADDR_r[2:0]<=3'd0;
		DRAM_ADDR_r[9:3]<=dram_addr_col_for_prefetch_from_saved;
		DRAM_ADDR_r[10]<=1'b1;
	end
	14:begin
		controller_state<=15;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[ 95: 80]<=DRAM_DQ_rIN;
	end
	15:begin
		controller_state<=16;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[111: 96]<=DRAM_DQ_rIN;
	end
	16:begin
		controller_state<=17;
		DRAM_DQM_r<=0;
		lane_from_dram_to_cache[127:112]<=DRAM_DQ_rIN;
		dram_controller_ack_read_pulse_r<=1;
	end
	17:begin
		controller_state<=18;
		DRAM_DQM_r<=0;
		lane_prefetched[ 15:  0]<=DRAM_DQ_rIN;
	end
	18:begin
		controller_state<=19;
		DRAM_DQM_r<=0;
		lane_prefetched[ 31: 16]<=DRAM_DQ_rIN;
	end
	19:begin
		controller_state<=20;
		DRAM_DQM_r<=0;
		lane_prefetched[ 47: 32]<=DRAM_DQ_rIN;
		
	end
	20:begin
		controller_state<=21;
		DRAM_DQM_r<=0;
		lane_prefetched[ 63: 48]<=DRAM_DQ_rIN;
	end
	21:begin
		controller_state<=22;
		DRAM_DQM_r<=0;
		lane_prefetched[ 79: 64]<=DRAM_DQ_rIN;
	end
	22:begin
		controller_state<=23;
		lane_prefetched[ 95: 80]<=DRAM_DQ_rIN;
		
		if (write_needed_because_dirty) begin
			DRAM_RAS_r<=0;// activate command
			DRAM_ADDR_r<=dram_addr_row_for_write_from_saved;
			DRAM_BA_r<=dram_addr_bank_for_write_from_saved;
		end
	end
	23:begin
		controller_state<=24;
		lane_prefetched[111: 96]<=DRAM_DQ_rIN;
	end
	24:begin
		lane_prefetched[127:112]<=DRAM_DQ_rIN;
		controller_state<=25;
	end
	25:begin
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
		lane_from_dram_to_cache<=lane_prefetched;
		addr_for_write_upper<=addr_req_write_dram_side_dram;
		lane_from_cache_to_dram<=lane_from_cache_to_dram_side_dram;
		dram_controller_ack_read_pulse_r<=1;
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
