`timescale 1 ps / 1 ps

`include "HardFloat/HardFloat_primitives.v"
`include "HardFloat/HardFloat_rawFN.v"
`include "HardFloat/isSigNaNRecFN.v"
`include "HardFloat/fNToRecFN.v"
`include "HardFloat/addRecFN.v"
`include "HardFloat/mulRecFN.v"
`include "HardFloat/compareRecFN.v"
`include "HardFloat/recFNToFN.v"

module hardfloat_mmio(
	output [15:0] data_read_mmio,
	input  [15:0] data_write_mmio,
	input  [4:0]  address_mmio,
	input         is_mmio_write,
	input         is_mmio_byte,
	input         main_clk
);

localparam [2:0] OP_ADD = 3'd0;
localparam [2:0] OP_SUB = 3'd1;
localparam [2:0] OP_MUL = 3'd2;
localparam [2:0] OP_EQ  = 3'd3;
localparam [2:0] OP_LT  = 3'd4;
localparam [2:0] OP_LE  = 3'd5;

reg [31:0] operand_a_r = 32'h0;
reg [31:0] operand_b_r = 32'h0;
reg [31:0] result_r = 32'h0;
reg [2:0]  last_opcode_r = OP_ADD;
reg [15:0] flags_r = 16'h0;
reg        result_ready_r = 1'b0;

wire [32:0] rec_a;
wire [32:0] rec_b;

fNToRecFN #(8, 24) to_rec_a_inst(.in(operand_a_r), .out(rec_a));
fNToRecFN #(8, 24) to_rec_b_inst(.in(operand_b_r), .out(rec_b));

wire [32:0] rec_add;
wire [4:0]  exc_add;
addRecFN #(8, 24) add_rec_inst(
	.control(1'b0),
	.subOp(1'b0),
	.a(rec_a),
	.b(rec_b),
	.roundingMode(`round_near_even),
	.out(rec_add),
	.exceptionFlags(exc_add)
);

wire [32:0] rec_sub;
wire [4:0]  exc_sub;
addRecFN #(8, 24) sub_rec_inst(
	.control(1'b0),
	.subOp(1'b1),
	.a(rec_a),
	.b(rec_b),
	.roundingMode(`round_near_even),
	.out(rec_sub),
	.exceptionFlags(exc_sub)
);

wire [32:0] rec_mul;
wire [4:0]  exc_mul;
mulRecFN #(8, 24) mul_rec_inst(
	.control(1'b0),
	.a(rec_a),
	.b(rec_b),
	.roundingMode(`round_near_even),
	.out(rec_mul),
	.exceptionFlags(exc_mul)
);

wire cmp_lt;
wire cmp_eq;
wire cmp_gt;
wire [4:0] exc_cmp;
compareRecFN #(8, 24) compare_rec_inst(
	.a(rec_a),
	.b(rec_b),
	.signaling(1'b0),
	.lt(cmp_lt),
	.eq(cmp_eq),
	.gt(cmp_gt),
	.exceptionFlags(exc_cmp)
);

wire [31:0] fn_add;
wire [31:0] fn_sub;
wire [31:0] fn_mul;
recFNToFN #(8, 24) add_to_fn_inst(.in(rec_add), .out(fn_add));
recFNToFN #(8, 24) sub_to_fn_inst(.in(rec_sub), .out(fn_sub));
recFNToFN #(8, 24) mul_to_fn_inst(.in(rec_mul), .out(fn_mul));

reg [15:0] data_read_mmio_r = 16'h0;
assign data_read_mmio = data_read_mmio_r;

always_comb begin
	case (address_mmio[4:1])
		4'd0: data_read_mmio_r = {11'h0, last_opcode_r, result_ready_r, 1'b0};
		4'd1: data_read_mmio_r = operand_a_r[15:0];
		4'd2: data_read_mmio_r = operand_a_r[31:16];
		4'd3: data_read_mmio_r = operand_b_r[15:0];
		4'd4: data_read_mmio_r = operand_b_r[31:16];
		4'd5: data_read_mmio_r = result_r[15:0];
		4'd6: data_read_mmio_r = result_r[31:16];
		4'd7: data_read_mmio_r = flags_r;
		default: data_read_mmio_r = 16'h0;
	endcase
end

always @(posedge main_clk) begin
	if (is_mmio_write && !is_mmio_byte) begin
		case (address_mmio[4:1])
			4'd0: begin
				if (data_write_mmio[0]) begin
					last_opcode_r <= data_write_mmio[3:1];
					result_ready_r <= 1'b1;
					case (data_write_mmio[3:1])
						OP_ADD: begin
							result_r <= fn_add;
							flags_r <= {11'h0, exc_add};
						end
						OP_SUB: begin
							result_r <= fn_sub;
							flags_r <= {11'h0, exc_sub};
						end
						OP_MUL: begin
							result_r <= fn_mul;
							flags_r <= {11'h0, exc_mul};
						end
						OP_EQ: begin
							result_r <= {31'h0, cmp_eq};
							flags_r <= {8'h0, cmp_gt, cmp_eq, cmp_lt, exc_cmp};
						end
						OP_LT: begin
							result_r <= {31'h0, cmp_lt};
							flags_r <= {8'h0, cmp_gt, cmp_eq, cmp_lt, exc_cmp};
						end
						OP_LE: begin
							result_r <= {31'h0, (cmp_lt | cmp_eq)};
							flags_r <= {8'h0, cmp_gt, cmp_eq, cmp_lt, exc_cmp};
						end
						default: begin
							result_r <= 32'h0;
							flags_r <= 16'h0;
						end
					endcase
				end else if (data_write_mmio[1]) begin
					result_ready_r <= 1'b0;
				end
			end
			4'd1: operand_a_r[15:0] <= data_write_mmio;
			4'd2: operand_a_r[31:16] <= data_write_mmio;
			4'd3: operand_b_r[15:0] <= data_write_mmio;
			4'd4: operand_b_r[31:16] <= data_write_mmio;
			default: begin
				// read-only or unused words
			end
		endcase
	end
end

endmodule
