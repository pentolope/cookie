`timescale 1 ps / 1 ps

module lcells #(parameter size) (output [size-1:0] o,input  [size-1:0] i);
generate
genvar k;
for (k=0;k<size;k=k+1) begin : c
	lcell lc(.out(o[k]),.in(i[k]));
end
endgenerate
endmodule

module lcell_4_16(output [15:0] o [3:0],input  [15:0] i [3:0]);
lcells #(16) lc0(o[0],i[0]);
lcells #(16) lc1(o[1],i[1]);
lcells #(16) lc2(o[2],i[2]);
lcells #(16) lc3(o[3],i[3]);
endmodule

module division_remainder(
	output [15:0] quotient,
	output [15:0] remainder,

	input  [15:0] dividend,
	input  [15:0] divisor
);
/*
assign quotient=  dividend / divisor;
assign remainder= dividend % divisor;
*/


wire [16:0] su;
wire [16:0] st [15:0];
wire [15:0] sf [15:0];

assign su={1'b0,~divisor}+1'b1;

assign st[0]=su+{15'b0,dividend[15]};
assign sf[0]=({16{st[0][16]}}&st[0][15:0])|({16{~st[0][16]}}&{15'b0,dividend[15]});

assign st[1]=su+{sf[0][14:0],dividend[14]};
assign sf[1]=({16{st[1][16]}}&st[1][15:0])|({16{~st[1][16]}}&{sf[0][14:0],dividend[14]});

assign st[2]=su+{sf[1][14:0],dividend[13]};
assign sf[2]=({16{st[2][16]}}&st[2][15:0])|({16{~st[2][16]}}&{sf[1][14:0],dividend[13]});

assign st[3]=su+{sf[2][14:0],dividend[12]};
assign sf[3]=({16{st[3][16]}}&st[3][15:0])|({16{~st[3][16]}}&{sf[2][14:0],dividend[12]});

assign st[4]=su+{sf[3][14:0],dividend[11]};
assign sf[4]=({16{st[4][16]}}&st[4][15:0])|({16{~st[4][16]}}&{sf[3][14:0],dividend[11]});

assign st[5]=su+{sf[4][14:0],dividend[10]};
assign sf[5]=({16{st[5][16]}}&st[5][15:0])|({16{~st[5][16]}}&{sf[4][14:0],dividend[10]});

assign st[6]=su+{sf[5][14:0],dividend[9]};
assign sf[6]=({16{st[6][16]}}&st[6][15:0])|({16{~st[6][16]}}&{sf[5][14:0],dividend[9]});

assign st[7]=su+{sf[6][14:0],dividend[8]};
assign sf[7]=({16{st[7][16]}}&st[7][15:0])|({16{~st[7][16]}}&{sf[6][14:0],dividend[8]});

assign st[8]=su+{sf[7][14:0],dividend[7]};
assign sf[8]=({16{st[8][16]}}&st[8][15:0])|({16{~st[8][16]}}&{sf[7][14:0],dividend[7]});

assign st[9]=su+{sf[8][14:0],dividend[6]};
assign sf[9]=({16{st[9][16]}}&st[9][15:0])|({16{~st[9][16]}}&{sf[8][14:0],dividend[6]});

assign st[10]=su+{sf[9][14:0],dividend[5]};
assign sf[10]=({16{st[10][16]}}&st[10][15:0])|({16{~st[10][16]}}&{sf[9][14:0],dividend[5]});

assign st[11]=su+{sf[10][14:0],dividend[4]};
assign sf[11]=({16{st[11][16]}}&st[11][15:0])|({16{~st[11][16]}}&{sf[10][14:0],dividend[4]});

assign st[12]=su+{sf[11][14:0],dividend[3]};
assign sf[12]=({16{st[12][16]}}&st[12][15:0])|({16{~st[12][16]}}&{sf[11][14:0],dividend[3]});

assign st[13]=su+{sf[12][14:0],dividend[2]};
assign sf[13]=({16{st[13][16]}}&st[13][15:0])|({16{~st[13][16]}}&{sf[12][14:0],dividend[2]});

assign st[14]=su+{sf[13][14:0],dividend[1]};
assign sf[14]=({16{st[14][16]}}&st[14][15:0])|({16{~st[14][16]}}&{sf[13][14:0],dividend[1]});

assign st[15]=su+{sf[14][14:0],dividend[0]};
assign sf[15]=({16{st[15][16]}}&st[15][15:0])|({16{~st[15][16]}}&{sf[14][14:0],dividend[0]});


assign quotient={st[0][16],st[1][16],st[2][16],st[3][16],st[4][16],st[5][16],st[6][16],st[7][16],st[8][16],st[9][16],st[10][16],st[11][16],st[12][16],st[13][16],st[14][16],st[15][16]};
assign remainder=sf[15];

endmodule


module generate_hex_display_base10(
	output [7:0] hex_display [5:0],
	input [15:0] number
);

wire [15:0] numberAtStage [5:0];
wire [15:0] digit_binary_full [5:0];
wire [ 3:0] digit_binary [5:0];

assign digit_binary[0]=digit_binary_full[0][3:0];
assign digit_binary[1]=digit_binary_full[1][3:0];
assign digit_binary[2]=digit_binary_full[2][3:0];
assign digit_binary[3]=digit_binary_full[3][3:0];
assign digit_binary[4]=digit_binary_full[4][3:0];
assign digit_binary[5]=digit_binary_full[5][3:0];

division_remainder hex_display0(
	numberAtStage[0],
	digit_binary_full[0],
	
	number,
	16'd10
);
division_remainder hex_display1(
	numberAtStage[1],
	digit_binary_full[1],
	
	numberAtStage[0],
	16'd10
);
division_remainder hex_display2(
	numberAtStage[2],
	digit_binary_full[2],
	
	numberAtStage[1],
	16'd10
);
division_remainder hex_display3(
	numberAtStage[3],
	digit_binary_full[3],
	
	numberAtStage[2],
	16'd10
);
division_remainder hex_display4(
	numberAtStage[4],
	digit_binary_full[4],
	
	numberAtStage[3],
	16'd10
);

assign numberAtStage[5]=0;
assign digit_binary_full[5]=numberAtStage[4];

wire [6:0] hex_display_lut [15:0];
assign hex_display_lut[4'h0] = 7'b_0111111;
assign hex_display_lut[4'h1] = 7'b_0000110;	
assign hex_display_lut[4'h2] = 7'b_1011011; 	
assign hex_display_lut[4'h3] = 7'b_1001111; 	
assign hex_display_lut[4'h4] = 7'b_1100110; 	
assign hex_display_lut[4'h5] = 7'b_1101101; 	
assign hex_display_lut[4'h6] = 7'b_1111101; 	
assign hex_display_lut[4'h7] = 7'b_0000111; 	
assign hex_display_lut[4'h8] = 7'b_1111111; 	
assign hex_display_lut[4'h9] = 7'b_1100111; 
assign hex_display_lut[4'ha] = 7'b_1110111;
assign hex_display_lut[4'hb] = 7'b_1111100;
assign hex_display_lut[4'hc] = 7'b_0111001;
assign hex_display_lut[4'hd] = 7'b_1011110;
assign hex_display_lut[4'he] = 7'b_1111001;
assign hex_display_lut[4'hf] = 7'b_1110001;

// hex display is active low, but the lut is coded as active high
wire [7:0] hex_display_pre_inv [5:0];

assign hex_display_pre_inv[0][6:0]=hex_display_lut[digit_binary[0]];
assign hex_display_pre_inv[1][6:0]=(digit_binary[5]==4'd0 && digit_binary[4]==4'd0 && digit_binary[3]==4'd0 && digit_binary[2]==4'd0 && digit_binary[1]==4'd0)?7'b0:hex_display_lut[digit_binary[1]];
assign hex_display_pre_inv[2][6:0]=(digit_binary[5]==4'd0 && digit_binary[4]==4'd0 && digit_binary[3]==4'd0 && digit_binary[2]==4'd0)?7'b0:hex_display_lut[digit_binary[2]];
assign hex_display_pre_inv[3][6:0]=(digit_binary[5]==4'd0 && digit_binary[4]==4'd0 && digit_binary[3]==4'd0)?7'b0:hex_display_lut[digit_binary[3]];
assign hex_display_pre_inv[4][6:0]=(digit_binary[5]==4'd0 && digit_binary[4]==4'd0)?7'b0:hex_display_lut[digit_binary[4]];
assign hex_display_pre_inv[5][6:0]=(digit_binary[5]==4'd0)?7'b0:hex_display_lut[digit_binary[5]];

assign hex_display_pre_inv[0][7]=1'b0;
assign hex_display_pre_inv[1][7]=1'b0;
assign hex_display_pre_inv[2][7]=1'b0;
assign hex_display_pre_inv[3][7]=1'b0;
assign hex_display_pre_inv[4][7]=1'b0;
assign hex_display_pre_inv[5][7]=1'b0;

assign hex_display[0]=~(hex_display_pre_inv[0]);
assign hex_display[1]=~(hex_display_pre_inv[1]);
assign hex_display[2]=~(hex_display_pre_inv[2]);
assign hex_display[3]=~(hex_display_pre_inv[3]);
assign hex_display[4]=~(hex_display_pre_inv[4]);
assign hex_display[5]=~(hex_display_pre_inv[5]);

endmodule


module generate_hex_display_base16(
output [7:0] hex_display [5:0],
input [15:0] number
);

wire [6:0] hex_display_lut [15:0];
assign hex_display_lut[4'h0] = 7'b_0111111;
assign hex_display_lut[4'h1] = 7'b_0000110;	
assign hex_display_lut[4'h2] = 7'b_1011011; 	
assign hex_display_lut[4'h3] = 7'b_1001111; 	
assign hex_display_lut[4'h4] = 7'b_1100110; 	
assign hex_display_lut[4'h5] = 7'b_1101101; 	
assign hex_display_lut[4'h6] = 7'b_1111101; 	
assign hex_display_lut[4'h7] = 7'b_0000111; 	
assign hex_display_lut[4'h8] = 7'b_1111111; 	
assign hex_display_lut[4'h9] = 7'b_1100111; 
assign hex_display_lut[4'ha] = 7'b_1110111;
assign hex_display_lut[4'hb] = 7'b_1111100;
assign hex_display_lut[4'hc] = 7'b_0111001;
assign hex_display_lut[4'hd] = 7'b_1011110;
assign hex_display_lut[4'he] = 7'b_1111001;
assign hex_display_lut[4'hf] = 7'b_1110001;

// hex display is active low, but the lut is coded as active high

wire [7:0] hex_display_pre_inv [5:0];

assign hex_display_pre_inv[0][6:0]=hex_display_lut[number[ 3: 0]];
assign hex_display_pre_inv[1][6:0]=hex_display_lut[number[ 7: 4]];
assign hex_display_pre_inv[2][6:0]=hex_display_lut[number[11: 8]];
assign hex_display_pre_inv[3][6:0]=hex_display_lut[number[15:12]];
assign hex_display_pre_inv[4][6:0]=7'b0;
assign hex_display_pre_inv[5][6:0]=7'b0;

assign hex_display_pre_inv[0][7]=1'b0;
assign hex_display_pre_inv[1][7]=1'b0;
assign hex_display_pre_inv[2][7]=1'b0;
assign hex_display_pre_inv[3][7]=1'b0;
assign hex_display_pre_inv[4][7]=1'b0;
assign hex_display_pre_inv[5][7]=1'b0;

assign hex_display[0]=~(hex_display_pre_inv[0]);
assign hex_display[1]=~(hex_display_pre_inv[1]);
assign hex_display[2]=~(hex_display_pre_inv[2]);
assign hex_display[3]=~(hex_display_pre_inv[3]);
assign hex_display[4]=~(hex_display_pre_inv[4]);
assign hex_display[5]=~(hex_display_pre_inv[5]);

endmodule

module reg_mux_single(
	output o, // output
	input b, // before
	input r, // any override active is on
	input [7:0] a, // override active
	input [7:0] i // instant values
);
wire [4:0] im;
lcell lcv0(.out(im[0]), .in((a[1] & i[1]) | (a[0] & i[0])));
lcell lcv1(.out(im[1]), .in((a[3] & i[3]) | (a[2] & i[2])));
lcell lcv2(.out(im[2]), .in((a[5] & i[5]) | (a[4] & i[4])));
lcell lcv3(.out(im[3]), .in((a[7] & i[7]) | (a[6] & i[6])));
lcell lcv4(.out(im[4]), .in(im[3] | im[2] | im[1] | im[0]));
lcell lcvo(.out(o), .in(r ? im[4] : b));
endmodule

module reg_mux_slice(
	output [15:0] o,     // output
	input [15:0] b,      // before
	input [7:0] a,       // override active
	input [15:0] i [7:0] // instant values
);
wire [7:0] ac;
lcells #(8) lc_ac (ac,a);
wire r; // any override active is on
lcell lcr (.out(r), .in(ac[7] | ac[6] | ac[5] | ac[4] | ac[3] | ac[2] | ac[1] | ac[0]));
generate
genvar k;
for (k=0;k<16;k=k+1) begin : gen
	reg_mux_single single_bit (o[k],b[k],r,ac,{i[7][k],i[6][k],i[5][k],i[4][k],i[3][k],i[2][k],i[1][k],i[0][k]});
end
endgenerate
endmodule

module reg_mux_full(
	output [15:0] o [32:0],  // output
	input  [15:0] b [32:0],  // before
	input  [32:0] a [7:0],   // override active
	input  [15:0] i0 [32:0], // instant values from executer 0
	input  [15:0] i1 [32:0], // instant values from executer 1
	input  [15:0] i2 [32:0], // instant values from executer 2
	input  [15:0] i3 [32:0], // instant values from executer 3
	input  [15:0] i4 [32:0], // instant values from executer 4
	input  [15:0] i5 [32:0], // instant values from executer 5
	input  [15:0] i6 [32:0], // instant values from executer 6
	input  [15:0] i7 [32:0]  // instant values from executer 7
);
generate
genvar k;
for (k=0;k<33;k=k+1) begin : gen
if (k!=16 && k!=17) begin
	reg_mux_slice slice(
		o[k],
		b[k],
		{a[7][k],a[6][k],a[5][k],a[4][k],a[3][k],a[2][k],a[1][k],a[0][k]},
		'{i7[k],i6[k],i5[k],i4[k],i3[k],i2[k],i1[k],i0[k]}
	);
end end
endgenerate

endmodule

module fast_ur_mux_slice(
	output [15:0] o, // output value
	input  [ 1:0] i, // 2 selection values
	input  [15:0] u [1:0] // 2 instant user reg values
);
lcells #(16) lc_ic(
	o,
	{
	(i[1] & u[1][15]) | (i[0] & u[0][15]),
	(i[1] & u[1][14]) | (i[0] & u[0][14]),
	(i[1] & u[1][13]) | (i[0] & u[0][13]),
	(i[1] & u[1][12]) | (i[0] & u[0][12]),
	(i[1] & u[1][11]) | (i[0] & u[0][11]),
	(i[1] & u[1][10]) | (i[0] & u[0][10]),
	(i[1] & u[1][ 9]) | (i[0] & u[0][ 9]),
	(i[1] & u[1][ 8]) | (i[0] & u[0][ 8]),
	(i[1] & u[1][ 7]) | (i[0] & u[0][ 7]),
	(i[1] & u[1][ 6]) | (i[0] & u[0][ 6]),
	(i[1] & u[1][ 5]) | (i[0] & u[0][ 5]),
	(i[1] & u[1][ 4]) | (i[0] & u[0][ 4]),
	(i[1] & u[1][ 3]) | (i[0] & u[0][ 3]),
	(i[1] & u[1][ 2]) | (i[0] & u[0][ 2]),
	(i[1] & u[1][ 1]) | (i[0] & u[0][ 1]),
	(i[1] & u[1][ 0]) | (i[0] & u[0][ 0])
	}
);
endmodule

module decode4(
	output [15:0] d, // output value
	input  [ 3:0] i  // selection value
);
lcell is0(.out(d[ 0]), .in(!i[3] & !i[2] & !i[1] & !i[0]));
lcell is1(.out(d[ 1]), .in(!i[3] & !i[2] & !i[1] &  i[0]));
lcell is2(.out(d[ 2]), .in(!i[3] & !i[2] &  i[1] & !i[0]));
lcell is3(.out(d[ 3]), .in(!i[3] & !i[2] &  i[1] &  i[0]));
lcell is4(.out(d[ 4]), .in(!i[3] &  i[2] & !i[1] & !i[0]));
lcell is5(.out(d[ 5]), .in(!i[3] &  i[2] & !i[1] &  i[0]));
lcell is6(.out(d[ 6]), .in(!i[3] &  i[2] &  i[1] & !i[0]));
lcell is7(.out(d[ 7]), .in(!i[3] &  i[2] &  i[1] &  i[0]));
lcell is8(.out(d[ 8]), .in( i[3] & !i[2] & !i[1] & !i[0]));
lcell is9(.out(d[ 9]), .in( i[3] & !i[2] & !i[1] &  i[0]));
lcell isA(.out(d[10]), .in( i[3] & !i[2] &  i[1] & !i[0]));
lcell isB(.out(d[11]), .in( i[3] & !i[2] &  i[1] &  i[0]));
lcell isC(.out(d[12]), .in( i[3] &  i[2] & !i[1] & !i[0]));
lcell isD(.out(d[13]), .in( i[3] &  i[2] & !i[1] &  i[0]));
lcell isE(.out(d[14]), .in( i[3] &  i[2] &  i[1] & !i[0]));
lcell isF(.out(d[15]), .in( i[3] &  i[2] &  i[1] &  i[0]));

endmodule

module decode3(
	output [7:0] d, // output value
	input  [2:0] i  // selection value
);
lcell is0(.out(d[ 0]), .in(!i[2] & !i[1] & !i[0]));
lcell is1(.out(d[ 1]), .in(!i[2] & !i[1] &  i[0]));
lcell is2(.out(d[ 2]), .in(!i[2] &  i[1] & !i[0]));
lcell is3(.out(d[ 3]), .in(!i[2] &  i[1] &  i[0]));
lcell is4(.out(d[ 4]), .in( i[2] & !i[1] & !i[0]));
lcell is5(.out(d[ 5]), .in( i[2] & !i[1] &  i[0]));
lcell is6(.out(d[ 6]), .in( i[2] &  i[1] & !i[0]));
lcell is7(.out(d[ 7]), .in( i[2] &  i[1] &  i[0]));

endmodule


module fast_ur_mux(
	output [15:0] o, // output value
	input         i, // value from instruction
	input  [ 7:0] d, // value from helper decoder
	input  [15:0] u [15:0] // instant user reg
);

wire [15:0] ov0 [7:0];
wire [15:0] ov1 [4:0];

lcells #(16) lc_uc0(ov0[0],i?u[ 1]:u[ 0]);
lcells #(16) lc_uc1(ov0[1],i?u[ 3]:u[ 2]);
lcells #(16) lc_uc2(ov0[2],i?u[ 5]:u[ 4]);
lcells #(16) lc_uc3(ov0[3],i?u[ 7]:u[ 6]);
lcells #(16) lc_uc4(ov0[4],i?u[ 9]:u[ 8]);
lcells #(16) lc_uc5(ov0[5],i?u[11]:u[10]);
lcells #(16) lc_uc6(ov0[6],i?u[13]:u[12]);
lcells #(16) lc_uc7(ov0[7],i?u[15]:u[14]);

fast_ur_mux_slice fast_ur_mux_slice3 (
	ov1[3],
	{d[ 7],d[ 6]},
	'{ov0[ 7],ov0[ 6]}
);
fast_ur_mux_slice fast_ur_mux_slice2 (
	ov1[2],
	{d[ 5],d[ 4]},
	'{ov0[ 5],ov0[ 4]}
);
fast_ur_mux_slice fast_ur_mux_slice1 (
	ov1[1],
	{d[ 3],d[ 2]},
	'{ov0[ 3],ov0[ 2]}
);
fast_ur_mux_slice fast_ur_mux_slice0 (
	ov1[0],
	{d[ 1],d[ 0]},
	'{ov0[ 1],ov0[ 0]}
);

lcells #(16) lc_ic(o, ov1[3] | ov1[2] | ov1[1] | ov1[0]);
endmodule


module mem_inter_mux(
	output [31:0] o0,
	output [15:0] o2 [3:0],
	output [2:0] o4,
	output [2:0] o5,
	output [2:0] o6,
	output o7,
	output o8,

	input [31:0] i0 [7:0],
	input [15:0] i2 [7:0][3:0],
	input [2:0] i4 [7:0],
	input [2:0] i5 [7:0],
	input [2:0] i6 [7:0],
	input [7:0] i7,
	input [7:0] i8,
	
	input [2:0] s
);
wire [31:0] ic0 [7:0];
wire [15:0] ic2 [7:0][3:0];
wire [2:0] ic4 [7:0];
wire [2:0] ic5 [7:0];
wire [2:0] ic6 [7:0];
wire [2:0] sc;

lcells #(32) lc0_0(ic0[0],i0[0]);
lcells #(32) lc1_0(ic0[1],i0[1]);
lcells #(32) lc2_0(ic0[2],i0[2]);
lcells #(32) lc3_0(ic0[3],i0[3]);

lcell_4_16 lc8_0(ic2[0],i2[0]);
lcell_4_16 lc9_0(ic2[1],i2[1]);
lcell_4_16 lc10_0(ic2[2],i2[2]);
lcell_4_16 lc11_0(ic2[3],i2[3]);

lcells #(3) lc16_0(ic4[0],i4[0]);
lcells #(3) lc17_0(ic4[1],i4[1]);
lcells #(3) lc18_0(ic4[2],i4[2]);
lcells #(3) lc19_0(ic4[3],i4[3]);

lcells #(3) lc20_0(ic5[0],i5[0]);
lcells #(3) lc21_0(ic5[1],i5[1]);
lcells #(3) lc22_0(ic5[2],i5[2]);
lcells #(3) lc23_0(ic5[3],i5[3]);

lcells #(3) lc24_0(ic6[0],i6[0]);
lcells #(3) lc25_0(ic6[1],i6[1]);
lcells #(3) lc26_0(ic6[2],i6[2]);
lcells #(3) lc27_0(ic6[3],i6[3]);


lcells #(32) lc0_1(ic0[4],i0[4]);
lcells #(32) lc1_1(ic0[5],i0[5]);
lcells #(32) lc2_1(ic0[6],i0[6]);
lcells #(32) lc3_1(ic0[7],i0[7]);

lcell_4_16 lc8_1(ic2[4],i2[4]);
lcell_4_16 lc9_1(ic2[5],i2[5]);
lcell_4_16 lc10_1(ic2[6],i2[6]);
lcell_4_16 lc11_1(ic2[7],i2[7]);

lcells #(3) lc16_1(ic4[4],i4[4]);
lcells #(3) lc17_1(ic4[5],i4[5]);
lcells #(3) lc18_1(ic4[6],i4[6]);
lcells #(3) lc19_1(ic4[7],i4[7]);

lcells #(3) lc20_1(ic5[4],i5[4]);
lcells #(3) lc21_1(ic5[5],i5[5]);
lcells #(3) lc22_1(ic5[6],i5[6]);
lcells #(3) lc23_1(ic5[7],i5[7]);

lcells #(3) lc24_1(ic6[4],i6[4]);
lcells #(3) lc25_1(ic6[5],i6[5]);
lcells #(3) lc26_1(ic6[6],i6[6]);
lcells #(3) lc27_1(ic6[7],i6[7]);


assign sc=s;
wire [7:0] sd;
decode3 lc_decode3_s(sd,sc);

assign o0=ic0[sc];

wire [63:0] t0 [7:0];
wire [63:0] t1;
wire [15:0] t2 [3:0];
assign t0[0][63:48]=ic2[0][3];
assign t0[0][47:32]=ic2[0][2];
assign t0[0][31:16]=ic2[0][1];
assign t0[0][15: 0]=ic2[0][0];
assign t0[1][63:48]=ic2[1][3];
assign t0[1][47:32]=ic2[1][2];
assign t0[1][31:16]=ic2[1][1];
assign t0[1][15: 0]=ic2[1][0];
assign t0[2][63:48]=ic2[2][3];
assign t0[2][47:32]=ic2[2][2];
assign t0[2][31:16]=ic2[2][1];
assign t0[2][15: 0]=ic2[2][0];
assign t0[3][63:48]=ic2[3][3];
assign t0[3][47:32]=ic2[3][2];
assign t0[3][31:16]=ic2[3][1];
assign t0[3][15: 0]=ic2[3][0];
assign t0[4][63:48]=ic2[4][3];
assign t0[4][47:32]=ic2[4][2];
assign t0[4][31:16]=ic2[4][1];
assign t0[4][15: 0]=ic2[4][0];
assign t0[5][63:48]=ic2[5][3];
assign t0[5][47:32]=ic2[5][2];
assign t0[5][31:16]=ic2[5][1];
assign t0[5][15: 0]=ic2[5][0];
assign t0[6][63:48]=ic2[6][3];
assign t0[6][47:32]=ic2[6][2];
assign t0[6][31:16]=ic2[6][1];
assign t0[6][15: 0]=ic2[6][0];
assign t0[7][63:48]=ic2[7][3];
assign t0[7][47:32]=ic2[7][2];
assign t0[7][31:16]=ic2[7][1];
assign t0[7][15: 0]=ic2[7][0];
assign t1=
	(t0[0]&{64{sd[0]}})|
	(t0[1]&{64{sd[1]}})|
	(t0[2]&{64{sd[2]}})|
	(t0[3]&{64{sd[3]}})|
	(t0[4]&{64{sd[4]}})|
	(t0[5]&{64{sd[5]}})|
	(t0[6]&{64{sd[6]}})|
	(t0[7]&{64{sd[7]}});
assign t2[3]=t1[63:48];
assign t2[2]=t1[47:32];
assign t2[1]=t1[31:16];
assign t2[0]=t1[15: 0];
assign o2=t2;

lcells #(3) lc_muxed_access_length(o4,ic4[sc]);
lcells #(3) lc_muxed_access_length0(o5,ic5[sc]);
lcells #(3) lc_muxed_access_length1(o6,ic6[sc]);
lcells #(1) lc_muxed_is_byte_op(o7,i7[sc]);
lcells #(1) lc_muxed_is_write_op(o8,i8[sc]);

endmodule

module reg_mux_from_memory(
	output [15:0] final_result [31:0],
	
	input [15:0] default_values [31:0],
	input [15:0] instructions [7:0],
	input [15:0] rename_state_from_executers [7:0],
	input [7:0] doSpecialWrite,
	input [15:0] mem_data [3:0],
	input [7:0] memory_read_acknowledge,
	input main_clk
);

wire [15:0] special_sv [1:0]; // for reg 0 and reg 1, since they do a special thing for the return instruction
wire [15:0] sv [31:0];
wire [7:0] uses_vr1_data;
wire [7:0] is_return_data;
wire is_return_future;
reg is_return=0;

wire [2:0] ex_index_future;
reg  [7:0] ex_index_decoded;

lcells #(1) lc_is_return_future(is_return_future,is_return_data[ex_index_future]);

lcells #(3) lc_ex_index_future(ex_index_future,(memory_read_acknowledge[1]? 3'd1:3'd0) | (memory_read_acknowledge[2]? 3'd2:3'd0) | (memory_read_acknowledge[3]? 3'd3:3'd0) | (memory_read_acknowledge[4]? 3'd4:3'd0) | (memory_read_acknowledge[5]? 3'd5:3'd0) | (memory_read_acknowledge[6]? 3'd6:3'd0) | (memory_read_acknowledge[7]? 3'd7:3'd0));

always @(posedge main_clk) begin
	is_return<=is_return_future;
	ex_index_decoded<=0;
	ex_index_decoded[ex_index_future]<=1'b1;
end


wire write_verifed;
lcell lc_write_verifed(.out(write_verifed),.in(|(doSpecialWrite & ex_index_decoded)));

reg uses_vr1=0;
always @(posedge main_clk) uses_vr1<=uses_vr1_data[ex_index_future];

wire [15:0] rename_state_at_ex_index_future;
assign rename_state_at_ex_index_future=rename_state_from_executers[ex_index_future];
wire [7:0] instruction_info_at_ex_index_future;
lcells #(8) lc_instruction_info_at_ex_index_future(instruction_info_at_ex_index_future,instructions[ex_index_future][7:0]);

reg [15:0] target_index_decoded [1:0];
reg [1:0] renamed_vr=0;
always @(posedge main_clk) begin
	target_index_decoded[0]<=0;
	target_index_decoded[1]<=0;
	if (is_return_future) begin
		renamed_vr[0]<=1'b0;
		renamed_vr[1]<=1'b0;
	end else begin
		target_index_decoded[0][instruction_info_at_ex_index_future[3:0]]<=1'b1;
		target_index_decoded[1][instruction_info_at_ex_index_future[7:4]]<=1'b1;
		renamed_vr[0]<=rename_state_at_ex_index_future[instruction_info_at_ex_index_future[3:0]];
		renamed_vr[1]<=rename_state_at_ex_index_future[instruction_info_at_ex_index_future[7:4]];
	end
end


wire [31:0] dec5_vr [1:0]; // not actually the decoded value, it is slightly different
lcells #(16) lc_0(dec5_vr[0][15: 0],({16{write_verifed & !renamed_vr[0]}} & target_index_decoded[0]      ) | dec5_vr[1][15: 0]);
lcells #(14) lc_1(dec5_vr[0][31:18],({14{write_verifed &  renamed_vr[0]}} & target_index_decoded[0][15:2]) | dec5_vr[1][31:18]);
lcells #(16) lc_2(dec5_vr[1][15: 0],({16{write_verifed & !renamed_vr[1] & uses_vr1}} & target_index_decoded[1]      ));
lcells #(14) lc_3(dec5_vr[1][31:18],({14{write_verifed &  renamed_vr[1] & uses_vr1}} & target_index_decoded[1][15:2]));

lcells #(16) lc_4(special_sv[0],(write_verifed && is_return)?mem_data[3]:default_values[0]);
lcells #(16) lc_5(special_sv[1],(write_verifed && is_return)?mem_data[2]:default_values[1]);

generate
genvar i;
for (i=0;i<8;i=i+1) begin : gen1
	assign uses_vr1_data[i]=(instructions[i][15:8]==8'hF3)? 1'b1:1'b0;
	assign is_return_data[i]=(instructions[i][15:8]==8'hFB)? 1'b1:1'b0;
end
for (i=0;i<32;i=i+1) begin : gen2
	if (i!=16 && i!=17) begin
		lcells #(16) lc_sv(sv[i],dec5_vr[1][i]?mem_data[1]:mem_data[0]);
		if (i==0 || i==1) begin
			lcells #(16) lc_final(final_result[i],dec5_vr[0][i]?sv[i]:special_sv[i]);
		end else begin
			lcells #(16) lc_final(final_result[i],dec5_vr[0][i]?sv[i]:default_values[i]);
		end
	end
end
endgenerate

endmodule











