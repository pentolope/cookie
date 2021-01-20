`timescale 1 ps / 1 ps


`include "internal_memory.sv"
`include "vga_driver.sv"
`include "instruction_cache.sv"
`include "instruction_conflict_detection.sv"


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

/*
 ---t----
 |	    |
 lt	   rt
 |	    |
 ---m----
 |	    |
 lb	   rb
 |	    |
 ---b --d
hex={d,m,lt,lb,b,rb,rt,t}  (I think...)
hex display is active low, but the lut is coded as active high
*/
wire [7:0] hex_display_pre_inv [5:0];


// idk if that is the correct order (as in if the ones digit is on the right side 7seg)
assign hex_display_pre_inv[0][6:0]=hex_display_lut[digit_binary[5]];
assign hex_display_pre_inv[1][6:0]=(digit_binary[0]==4'd0 && digit_binary[1]==4'd0 && digit_binary[2]==4'd0 && digit_binary[3]==4'd0 && digit_binary[4]==4'd0)?7'b0:hex_display_lut[digit_binary[4]];
assign hex_display_pre_inv[2][6:0]=(digit_binary[0]==4'd0 && digit_binary[1]==4'd0 && digit_binary[2]==4'd0 && digit_binary[3]==4'd0)?7'b0:hex_display_lut[digit_binary[3]];
assign hex_display_pre_inv[3][6:0]=(digit_binary[0]==4'd0 && digit_binary[1]==4'd0 && digit_binary[2]==4'd0)?7'b0:hex_display_lut[digit_binary[2]];
assign hex_display_pre_inv[4][6:0]=(digit_binary[0]==4'd0 && digit_binary[1]==4'd0)?7'b0:hex_display_lut[digit_binary[1]];
assign hex_display_pre_inv[5][6:0]=(digit_binary[0]==4'd0)?7'b0:hex_display_lut[digit_binary[0]];

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

/*
 ---t----
 |	    |
 lt	   rt
 |	    |
 ---m----
 |	    |
 lb	   rb
 |	    |
 ---b --d
hex={d,m,lt,lb,b,rb,rt,t}  (I think...)
hex display is active low, but the lut is coded as active high
*/
wire [7:0] hex_display_pre_inv [5:0];


// idk if that is the correct order (as in if the ones digit is on the right side 7seg)
assign hex_display_pre_inv[0][6:0]=hex_display_lut[number[15:12]];
assign hex_display_pre_inv[1][6:0]=hex_display_lut[number[11: 8]];
assign hex_display_pre_inv[2][6:0]=hex_display_lut[number[ 7: 4]];
assign hex_display_pre_inv[3][6:0]=hex_display_lut[number[ 3: 0]];
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

/*
This is some temporary notes for figuring out how the hex display worked:
		4'h0: oSEG = 0 1 1 1 1 1 1;
		4'h1: oSEG = 0 0 0 0 1 1 0;	
		4'h2: oSEG = 1 0 1 1 0 1 1; 	
		4'h3: oSEG = 1 0 0 1 1 1 1; 	
		4'h4: oSEG = 1 1 0 0 1 1 0; 	
		4'h5: oSEG = 1 1 0 1 1 0 1; 	
		4'h6: oSEG = 1 1 1 1 1 0 1; 	
		4'h7: oSEG = 0 0 0 0 1 1 1; 	
		4'h8: oSEG = 1 1 1 1 1 1 1; 	
		4'h9: oSEG = 1 1 0 0 1 1 1; 
		4'ha: oSEG = 1 1 1 0 1 1 1;
		4'hb: oSEG = 1 1 1 1 1 0 0;
		4'hc: oSEG = 0 1 1 1 0 0 1;
		4'hd: oSEG = 1 0 1 1 1 1 0;
		4'he: oSEG = 1 1 1 1 0 0 1;
		4'hf: oSEG = 1 1 1 0 0 0 1;
		                         ^
 ---t----
 |	    |
 lt	   rt
 |	    |
 ---m----
 |	    |
 lb	   rb
 |	    |
 ---b---d
		
		hex={d,m,lt,lb,b,rb,rt,t}
*/

module recomb_mux_slice(
	output o, // output
	input b, // before
	input r, // any override active is on
	input [3:0] a, // override active
	input [3:0] i // instant values
);
wire im0;
wire im1;
lcell_1 lcim0 (im0,(a[1] & i[1])|(a[0] & i[0])); // could try re-arranging the order. like maybe having 3 and 1 together would be better
lcell_1 lcim1 (im1,(a[3] & i[3])|(a[2] & i[2]));
lcell_1 lco (o,r ?(im0 | im1):b);
endmodule

module recomb_mux(
	output [15:0] o, // output
	input [15:0] b, // before
	input [3:0] a, // override active
	input [15:0] i [3:0] // instant values
);
wire [3:0] ac;
lcell_4 lc_ac (ac,a);
wire r; // any override active is on
lcell_1 lcr (r,(ac[3] | ac[2] | ac[1] | ac[0]));
wire [15:0] ic [3:0];
lcell_16 lc_ic0 (ic[0],i[0]);
lcell_16 lc_ic1 (ic[1],i[1]);
lcell_16 lc_ic2 (ic[2],i[2]);
lcell_16 lc_ic3 (ic[3],i[3]);
recomb_mux_slice slice_0 (o[0],b[0],r,ac,{ic[3][0],ic[2][0],ic[1][0],ic[0][0]});
recomb_mux_slice slice_1 (o[1],b[1],r,ac,{ic[3][1],ic[2][1],ic[1][1],ic[0][1]});
recomb_mux_slice slice_2 (o[2],b[2],r,ac,{ic[3][2],ic[2][2],ic[1][2],ic[0][2]});
recomb_mux_slice slice_3 (o[3],b[3],r,ac,{ic[3][3],ic[2][3],ic[1][3],ic[0][3]});
recomb_mux_slice slice_4 (o[4],b[4],r,ac,{ic[3][4],ic[2][4],ic[1][4],ic[0][4]});
recomb_mux_slice slice_5 (o[5],b[5],r,ac,{ic[3][5],ic[2][5],ic[1][5],ic[0][5]});
recomb_mux_slice slice_6 (o[6],b[6],r,ac,{ic[3][6],ic[2][6],ic[1][6],ic[0][6]});
recomb_mux_slice slice_7 (o[7],b[7],r,ac,{ic[3][7],ic[2][7],ic[1][7],ic[0][7]});
recomb_mux_slice slice_8 (o[8],b[8],r,ac,{ic[3][8],ic[2][8],ic[1][8],ic[0][8]});
recomb_mux_slice slice_9 (o[9],b[9],r,ac,{ic[3][9],ic[2][9],ic[1][9],ic[0][9]});
recomb_mux_slice slice_10 (o[10],b[10],r,ac,{ic[3][10],ic[2][10],ic[1][10],ic[0][10]});
recomb_mux_slice slice_11 (o[11],b[11],r,ac,{ic[3][11],ic[2][11],ic[1][11],ic[0][11]});
recomb_mux_slice slice_12 (o[12],b[12],r,ac,{ic[3][12],ic[2][12],ic[1][12],ic[0][12]});
recomb_mux_slice slice_13 (o[13],b[13],r,ac,{ic[3][13],ic[2][13],ic[1][13],ic[0][13]});
recomb_mux_slice slice_14 (o[14],b[14],r,ac,{ic[3][14],ic[2][14],ic[1][14],ic[0][14]});
recomb_mux_slice slice_15 (o[15],b[15],r,ac,{ic[3][15],ic[2][15],ic[1][15],ic[0][15]});
endmodule

module recomb_mux_all_user_reg(
	output [15:0] o [15:0], // output
	input  [15:0] b [15:0], // before
	input  [15:0] a [3:0], // override active
	input  [15:0] i0 [15:0], // instant values from executer 0
	input  [15:0] i1 [15:0], // instant values from executer 1
	input  [15:0] i2 [15:0], // instant values from executer 2
	input  [15:0] i3 [15:0]  // instant values from executer 3
);
recomb_mux recomb_mux_0(
	o[0],
	b[0],
	{a[3][0],a[2][0],a[1][0],a[0][0]},
	'{i3[0],i2[0],i1[0],i0[0]}
);
recomb_mux recomb_mux_1(
	o[1],
	b[1],
	{a[3][1],a[2][1],a[1][1],a[0][1]},
	'{i3[1],i2[1],i1[1],i0[1]}
);
recomb_mux recomb_mux_2(
	o[2],
	b[2],
	{a[3][2],a[2][2],a[1][2],a[0][2]},
	'{i3[2],i2[2],i1[2],i0[2]}
);
recomb_mux recomb_mux_3(
	o[3],
	b[3],
	{a[3][3],a[2][3],a[1][3],a[0][3]},
	'{i3[3],i2[3],i1[3],i0[3]}
);
recomb_mux recomb_mux_4(
	o[4],
	b[4],
	{a[3][4],a[2][4],a[1][4],a[0][4]},
	'{i3[4],i2[4],i1[4],i0[4]}
);
recomb_mux recomb_mux_5(
	o[5],
	b[5],
	{a[3][5],a[2][5],a[1][5],a[0][5]},
	'{i3[5],i2[5],i1[5],i0[5]}
);
recomb_mux recomb_mux_6(
	o[6],
	b[6],
	{a[3][6],a[2][6],a[1][6],a[0][6]},
	'{i3[6],i2[6],i1[6],i0[6]}
);
recomb_mux recomb_mux_7(
	o[7],
	b[7],
	{a[3][7],a[2][7],a[1][7],a[0][7]},
	'{i3[7],i2[7],i1[7],i0[7]}
);
recomb_mux recomb_mux_8(
	o[8],
	b[8],
	{a[3][8],a[2][8],a[1][8],a[0][8]},
	'{i3[8],i2[8],i1[8],i0[8]}
);
recomb_mux recomb_mux_9(
	o[9],
	b[9],
	{a[3][9],a[2][9],a[1][9],a[0][9]},
	'{i3[9],i2[9],i1[9],i0[9]}
);
recomb_mux recomb_mux_10(
	o[10],
	b[10],
	{a[3][10],a[2][10],a[1][10],a[0][10]},
	'{i3[10],i2[10],i1[10],i0[10]}
);
recomb_mux recomb_mux_11(
	o[11],
	b[11],
	{a[3][11],a[2][11],a[1][11],a[0][11]},
	'{i3[11],i2[11],i1[11],i0[11]}
);
recomb_mux recomb_mux_12(
	o[12],
	b[12],
	{a[3][12],a[2][12],a[1][12],a[0][12]},
	'{i3[12],i2[12],i1[12],i0[12]}
);
recomb_mux recomb_mux_13(
	o[13],
	b[13],
	{a[3][13],a[2][13],a[1][13],a[0][13]},
	'{i3[13],i2[13],i1[13],i0[13]}
);
recomb_mux recomb_mux_14(
	o[14],
	b[14],
	{a[3][14],a[2][14],a[1][14],a[0][14]},
	'{i3[14],i2[14],i1[14],i0[14]}
);
recomb_mux recomb_mux_15(
	o[15],
	b[15],
	{a[3][15],a[2][15],a[1][15],a[0][15]},
	'{i3[15],i2[15],i1[15],i0[15]}
);
endmodule

module fast_ur_mux_slice(
	output [15:0] o, // output value
	input  [ 1:0] i, // 2 selection values
	input  [15:0] u [1:0] // 2 instant user reg values
);
lcell_16 lc_ic(
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
lcell_1 is0(d[ 0],!i[3] & !i[2] & !i[1] & !i[0]);
lcell_1 is1(d[ 1],!i[3] & !i[2] & !i[1] &  i[0]);
lcell_1 is2(d[ 2],!i[3] & !i[2] &  i[1] & !i[0]);
lcell_1 is3(d[ 3],!i[3] & !i[2] &  i[1] &  i[0]);
lcell_1 is4(d[ 4],!i[3] &  i[2] & !i[1] & !i[0]);
lcell_1 is5(d[ 5],!i[3] &  i[2] & !i[1] &  i[0]);
lcell_1 is6(d[ 6],!i[3] &  i[2] &  i[1] & !i[0]);
lcell_1 is7(d[ 7],!i[3] &  i[2] &  i[1] &  i[0]);
lcell_1 is8(d[ 8], i[3] & !i[2] & !i[1] & !i[0]);
lcell_1 is9(d[ 9], i[3] & !i[2] & !i[1] &  i[0]);
lcell_1 isA(d[10], i[3] & !i[2] &  i[1] & !i[0]);
lcell_1 isB(d[11], i[3] & !i[2] &  i[1] &  i[0]);
lcell_1 isC(d[12], i[3] &  i[2] & !i[1] & !i[0]);
lcell_1 isD(d[13], i[3] &  i[2] & !i[1] &  i[0]);
lcell_1 isE(d[14], i[3] &  i[2] &  i[1] & !i[0]);
lcell_1 isF(d[15], i[3] &  i[2] &  i[1] &  i[0]);

endmodule

module fast_ur_mux(
	output [15:0] o, // output value
	input  [ 3:0] i, // value from instruction
	input  [15:0] u [15:0] // instant user reg
);
wire [7:0] d;
lcell_1 is0(d[ 0],!i[3] & !i[2] & !i[1]);
lcell_1 is1(d[ 1],!i[3] & !i[2] &  i[1]);
lcell_1 is2(d[ 2],!i[3] &  i[2] & !i[1]);
lcell_1 is3(d[ 3],!i[3] &  i[2] &  i[1]);
lcell_1 is4(d[ 4], i[3] & !i[2] & !i[1]);
lcell_1 is5(d[ 5], i[3] & !i[2] &  i[1]);
lcell_1 is6(d[ 6], i[3] &  i[2] & !i[1]);
lcell_1 is7(d[ 7], i[3] &  i[2] &  i[1]);

wire [15:0] ov0 [7:0];
wire [15:0] ov1 [4:0];

lcell_16 lc_uc0(ov0[0],i[0]?u[ 1]:u[ 0]);
lcell_16 lc_uc1(ov0[1],i[0]?u[ 3]:u[ 2]);
lcell_16 lc_uc2(ov0[2],i[0]?u[ 5]:u[ 4]);
lcell_16 lc_uc3(ov0[3],i[0]?u[ 7]:u[ 6]);
lcell_16 lc_uc4(ov0[4],i[0]?u[ 9]:u[ 8]);
lcell_16 lc_uc5(ov0[5],i[0]?u[11]:u[10]);
lcell_16 lc_uc6(ov0[6],i[0]?u[13]:u[12]);
lcell_16 lc_uc7(ov0[7],i[0]?u[15]:u[14]);

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

lcell_16 lc_ic(o, ov1[3] | ov1[2] | ov1[1] | ov1[0]);
endmodule



module core_executer(
	input [15:0] instructionIn_extern,
	input [ 4:0] instructionInID_extern,
	input [25:0] instructionAddress,
	
	input doExecute,
	input willExecute,

	input [15:0] user_reg [15:0],
	input [15:0] instant_user_reg [15:0],
	
	input [15:0] next_stack_pointer,
	input [15:0] stack_pointer,
	input [15:0] stack_pointer_m2,
	input [15:0] stack_pointer_m4,
	input [15:0] stack_pointer_m6,
	input [15:0] stack_pointer_m8,
	input [15:0] stack_pointer_p2,
	input [15:0] stack_pointer_p4,
	
	output [16:0] doWrite_w, // doWrite[16] is stack pointer's doWrite
	output [15:0] writeValues_w [16:0],
	
	output [ 2:0] mem_stack_access_size_extern,
	output [15:0] mem_target_address_stack_extern,
	output [31:0] mem_target_address_general_extern,
	
	input  [15:0] mem_data_out_small,
	input  [15:0] mem_data_out_large [4:0],
	output [15:0] mem_data_in_extern [3:0],

	output mem_is_stack_access_write_extern,
	output mem_is_stack_access_requesting_extern,

	output mem_is_general_access_write_extern,
	output mem_is_general_access_byte_operation_extern,
	output mem_is_general_access_requesting_extern,
	
	input  mem_is_access_acknowledged_pulse,
	input  mem_will_access_be_acknowledged_pulse,
	
	output is_instruction_finishing_this_cycle_pulse_extern, // single cycle pulse
	output will_instruction_finish_next_cycle_pulse_extern,
	
	output [31:0] instruction_jump_address_extern,
	output jump_signal_extern,
	
	input main_clk
);

wire [15:0] instructionIn;
wire [ 4:0] instructionInID;

lcell_16 lc_instruct_full (instructionIn,instructionIn_extern);
lcell_5  lc_instruct_id (instructionInID,instructionInID_extern);

reg [15:0] doWrite=0;
reg [15:0] writeValues [15:0];
reg doWrite_sp=0;
reg [15:0] writeValue_sp;
assign doWrite_w[15:0]=doWrite;
assign doWrite_w[16]=doWrite_sp;
assign writeValues_w[15:0]=writeValues[15:0];
assign writeValues_w[16]=writeValue_sp;

reg jump_signal=0;
reg will_jump_next_cycle;
always @(posedge main_clk) jump_signal<=will_jump_next_cycle;
assign jump_signal_extern=jump_signal;

reg will_instruction_finish_next_cycle_pulse;
reg is_instruction_finishing_this_cycle_pulse=0;
assign will_instruction_finish_next_cycle_pulse_extern=will_instruction_finish_next_cycle_pulse;
assign is_instruction_finishing_this_cycle_pulse_extern=is_instruction_finishing_this_cycle_pulse;
always @(posedge main_clk) is_instruction_finishing_this_cycle_pulse<=will_instruction_finish_next_cycle_pulse;

reg [ 2:0] mem_stack_access_size;
reg [15:0] mem_target_address_stack;
reg [31:0] mem_target_address_general;

reg [15:0] mem_data_in [3:0];

reg mem_is_stack_access_write;
reg mem_is_stack_access_requesting;
reg mem_is_general_access_byte_operation;
reg mem_is_general_access_write;
reg mem_is_general_access_requesting;

assign mem_stack_access_size_extern=mem_stack_access_size;
assign mem_target_address_stack_extern=mem_target_address_stack;
assign mem_target_address_general_extern=mem_target_address_general;


assign mem_data_in_extern=mem_data_in;

assign mem_is_stack_access_write_extern=mem_is_stack_access_write;
assign mem_is_stack_access_requesting_extern=mem_is_stack_access_requesting;

assign mem_is_general_access_byte_operation_extern=mem_is_general_access_byte_operation;
assign mem_is_general_access_write_extern=mem_is_general_access_write;
assign mem_is_general_access_requesting_extern=mem_is_general_access_requesting;


reg [31:0] instruction_jump_address;
assign instruction_jump_address_extern=instruction_jump_address;


reg [15:0] temporary0;
reg [15:0] temporary1;

wire [18:0]temporary2;
reg [15:0] temporary3;
reg [15:0] temporary4;
reg [15:0] temporary5;
wire [17:0]temporary6;
reg [15:0] temporary7;
wire [18:0]temporary8;
wire [18:0]temporary9;
wire [18:0]temporaryA;

reg [16:0] adderOutput;


reg [15:0] mem_data_out_large_r [4:0];
always @(posedge main_clk) mem_data_out_large_r<=mem_data_out_large;

reg [15:0] mem_data_out_small_r;
always @(posedge main_clk) mem_data_out_small_r<=mem_data_out_small;


wire bitwise_lut [15:0];
assign bitwise_lut[4'b0000]=1'b0 & 1'b0;
assign bitwise_lut[4'b0001]=1'b0 & 1'b1;
assign bitwise_lut[4'b0010]=1'b1 & 1'b0;
assign bitwise_lut[4'b0011]=1'b1 & 1'b1;

assign bitwise_lut[4'b0100]=1'b0 | 1'b0;
assign bitwise_lut[4'b0101]=1'b0 | 1'b1;
assign bitwise_lut[4'b0110]=1'b1 | 1'b0;
assign bitwise_lut[4'b0111]=1'b1 | 1'b1;

assign bitwise_lut[4'b1000]=1'b0 ^ 1'b0;
assign bitwise_lut[4'b1001]=1'b0 ^ 1'b1;
assign bitwise_lut[4'b1010]=1'b1 ^ 1'b0;
assign bitwise_lut[4'b1011]=1'b1 ^ 1'b1;

assign bitwise_lut[4'b1100]=1'bx;
assign bitwise_lut[4'b1101]=1'bx;
assign bitwise_lut[4'b1110]=1'bx;
assign bitwise_lut[4'b1111]=1'bx;


wire adderControl0_lut [15:0]; // adderControl0_lut controls if vr2 is inverted
assign adderControl0_lut[4'b0000]=1'bx;
assign adderControl0_lut[4'b0001]=1'bx;
assign adderControl0_lut[4'b0010]=1'bx;
assign adderControl0_lut[4'b0011]=1'bx;

assign adderControl0_lut[4'b0100]=1'bx;
assign adderControl0_lut[4'b0101]=1'bx;
assign adderControl0_lut[4'b0110]=1'bx;
assign adderControl0_lut[4'b0111]=1'b1;

assign adderControl0_lut[4'b1000]=1'bx;
assign adderControl0_lut[4'b1001]=1'bx;
assign adderControl0_lut[4'b1010]=1'b0;
assign adderControl0_lut[4'b1011]=1'b0;

assign adderControl0_lut[4'b1100]=1'b1;
assign adderControl0_lut[4'b1101]=1'b1;
assign adderControl0_lut[4'b1110]=1'bx;
assign adderControl0_lut[4'b1111]=1'bx;


wire adderControl1_lut [15:0]; // adderControl1_lut controls if one is added (when subtracting)
assign adderControl1_lut[4'b0000]=1'bx;
assign adderControl1_lut[4'b0001]=1'bx;
assign adderControl1_lut[4'b0010]=1'bx;
assign adderControl1_lut[4'b0011]=1'bx;

assign adderControl1_lut[4'b0100]=1'bx;
assign adderControl1_lut[4'b0101]=1'bx;
assign adderControl1_lut[4'b0110]=1'bx;
assign adderControl1_lut[4'b0111]=1'b0;

assign adderControl1_lut[4'b1000]=1'bx;
assign adderControl1_lut[4'b1001]=1'bx;
assign adderControl1_lut[4'b1010]=1'b0;
assign adderControl1_lut[4'b1011]=1'b0;

assign adderControl1_lut[4'b1100]=1'b1;
assign adderControl1_lut[4'b1101]=1'b1;
assign adderControl1_lut[4'b1110]=1'bx;
assign adderControl1_lut[4'b1111]=1'bx;

wire adderControl2_lut [15:0]; // // adderControl2_lut controls if a third term is added
assign adderControl2_lut[4'b0000]=1'bx;
assign adderControl2_lut[4'b0001]=1'bx;
assign adderControl2_lut[4'b0010]=1'bx;
assign adderControl2_lut[4'b0011]=1'bx;

assign adderControl2_lut[4'b0100]=1'bx;
assign adderControl2_lut[4'b0101]=1'bx;
assign adderControl2_lut[4'b0110]=1'bx;
assign adderControl2_lut[4'b0111]=1'b1;

assign adderControl2_lut[4'b1000]=1'bx;
assign adderControl2_lut[4'b1001]=1'bx;
assign adderControl2_lut[4'b1010]=1'b0;
assign adderControl2_lut[4'b1011]=1'b1;

assign adderControl2_lut[4'b1100]=1'b0;
assign adderControl2_lut[4'b1101]=1'b0;
assign adderControl2_lut[4'b1110]=1'bx;
assign adderControl2_lut[4'b1111]=1'bx;


reg [2:0] step=0;
reg [2:0] stepNext;

wire [15:0] nvr0;//=instant_user_reg[instructionIn[ 3:0]];
wire [15:0] nvr1;//=instant_user_reg[instructionIn[ 7:4]];
wire [15:0] nvr2;//=instant_user_reg[instructionIn[11:8]];

//lcell_16 lcell_nvr0(nvr0,instant_user_reg[instructionIn[ 3:0]]);
//lcell_16 lcell_nvr1(nvr1,instant_user_reg[instructionIn[ 7:4]]);
//lcell_16 lcell_nvr2(nvr2,instant_user_reg[instructionIn[11:8]]);

fast_ur_mux fast_ur_mux0(nvr0,instructionIn[ 3:0],instant_user_reg);
fast_ur_mux fast_ur_mux1(nvr1,instructionIn[ 7:4],instant_user_reg);
fast_ur_mux fast_ur_mux2(nvr2,instructionIn[11:8],instant_user_reg);


always @(posedge main_clk) begin
	assert (nvr0==instant_user_reg[instructionIn[ 3:0]]);
	assert (nvr1==instant_user_reg[instructionIn[ 7:4]]);
	assert (nvr2==instant_user_reg[instructionIn[11:8]]);
end

reg [15:0] vr0=16'hFFFF;
reg [15:0] vr1=16'hFFFF;
reg [15:0] vr2=0;
/*
Initial value for vr0 and vr1 is to prevent packing into the multiplier blocks.
I don't understand why quartus really wants to do that, it requires creating a duplicate register anyway and decreases system performance.
*/

reg [15:0] instructionCurrent=0;
reg [4:0] instructionCurrentID=0;

reg adderControl0_r;
reg adderControl1_r;
reg adderControl2_r;

always @(posedge main_clk) instructionCurrent<=instructionIn;
always @(posedge main_clk) instructionCurrentID<=instructionInID;

always @(posedge main_clk) adderControl0_r<=adderControl0_lut[instructionIn[15:12]];
always @(posedge main_clk) adderControl1_r<=adderControl1_lut[instructionIn[15:12]];
always @(posedge main_clk) adderControl2_r<=adderControl2_lut[instructionIn[15:12]];
always @(posedge main_clk) step<=stepNext;

lcell_19 lc_add0 (temporary8,{2'b0,temporary5,1'b1}+adderControl1_r);
lcell_19 lc_add1 (temporary9,{2'b0,temporary4,1'b0}+{2'b0,temporary3,1'b0});
lcell_19 lc_add2 (temporaryA,temporary8+temporary9);

assign temporary6=temporaryA[18:1];

always @(posedge main_clk) begin
	vr0<=nvr0;
	vr1<=nvr1;
	vr2<=nvr2;
end

reg sim_is_first=0; // `sim_is_first` is used only for simulation testing
always @(posedge main_clk) sim_is_first<=1;

always @(posedge main_clk) begin
	if (sim_is_first) begin
		if (user_reg[instructionCurrent[ 3:0]]!=vr0) begin $stop(); end
		if (user_reg[instructionCurrent[ 7:4]]!=vr1) begin $stop(); end
		if (user_reg[instructionCurrent[11:8]]!=vr2) begin $stop(); end
	end
end

always_comb begin
	temporary0[0]=bitwise_lut[{instructionIn[13:12],nvr2[0],nvr1[0]}];
	temporary0[1]=bitwise_lut[{instructionIn[13:12],nvr2[1],nvr1[1]}];
	temporary0[2]=bitwise_lut[{instructionIn[13:12],nvr2[2],nvr1[2]}];
	temporary0[3]=bitwise_lut[{instructionIn[13:12],nvr2[3],nvr1[3]}];
	temporary0[4]=bitwise_lut[{instructionIn[13:12],nvr2[4],nvr1[4]}];
	temporary0[5]=bitwise_lut[{instructionIn[13:12],nvr2[5],nvr1[5]}];
	temporary0[6]=bitwise_lut[{instructionIn[13:12],nvr2[6],nvr1[6]}];
	temporary0[7]=bitwise_lut[{instructionIn[13:12],nvr2[7],nvr1[7]}];
	temporary0[8]=bitwise_lut[{instructionIn[13:12],nvr2[8],nvr1[8]}];
	temporary0[9]=bitwise_lut[{instructionIn[13:12],nvr2[9],nvr1[9]}];
	temporary0[10]=bitwise_lut[{instructionIn[13:12],nvr2[10],nvr1[10]}];
	temporary0[11]=bitwise_lut[{instructionIn[13:12],nvr2[11],nvr1[11]}];
	temporary0[12]=bitwise_lut[{instructionIn[13:12],nvr2[12],nvr1[12]}];
	temporary0[13]=bitwise_lut[{instructionIn[13:12],nvr2[13],nvr1[13]}];
	temporary0[14]=bitwise_lut[{instructionIn[13:12],nvr2[14],nvr1[14]}];
	temporary0[15]=bitwise_lut[{instructionIn[13:12],nvr2[15],nvr1[15]}];
end
always_comb begin
	temporary3=vr1;
	temporary4={16{adderControl0_r}} ^ vr2;
	temporary5={16{adderControl2_r}} & (instructionCurrent[15]?user_reg[4'hF]:vr0);
end
always_comb begin
	adderOutput[15:0]=temporary6[15:0];
	adderOutput[16]=(temporary6[17] | temporary6[16])?1'b1:1'b0;
end
always_comb begin
	temporary7=stack_pointer - vr0;
	temporary7[0]=1'b0;
end

always_comb begin
	temporary1={instructionIn[11:4],1'b0} + instant_user_reg[4'h1];
end

reg [31:0] mul32Temp;

reg [15:0] mul16Temp;

reg [16:0] divTemp0;
reg [15:0] divTemp1;
reg [ 2:0] divTemp2;
reg [15:0] divTemp3;
reg [15:0] divTemp4;
reg [15:0] divTemp5;

wire [16:0] divTemp6={1'b0,~vr1}+(2'b1+vr0[15]);
wire [15:0] divTemp7=({16{((divTemp6[16])?1'b1:1'b0)}} & divTemp6[15:0]) | ({16{((divTemp6[16])?1'b0:1'b1)}} & {15'h0,vr0[15]});

wire [16:0] divTable0 [2:0];
wire [16:0] divTable1 [2:0];
wire [16:0] divTable2 [2:0];

assign divTable0[0]={divTemp5,divTemp2[2]};
assign divTable0[1]=divTemp0+divTable0[0];
assign divTable0[2]=({16{((divTable0[1][16])?1'b1:1'b0)}} & divTable0[1][15:0]) | ({16{((divTable0[1][16])?1'b0:1'b1)}} & divTable0[0][15:0]);

assign divTable1[0]={divTable0[2][15:0],divTemp2[1]};
assign divTable1[1]=divTemp0+divTable1[0];
assign divTable1[2]=({16{((divTable1[1][16])?1'b1:1'b0)}} & divTable1[1][15:0]) | ({16{((divTable1[1][16])?1'b0:1'b1)}} & divTable1[0][15:0]);

assign divTable2[0]={divTable1[2][15:0],divTemp2[0]};
assign divTable2[1]=divTemp0+divTable2[0];
assign divTable2[2]=({16{((divTable2[1][16])?1'b1:1'b0)}} & divTable2[1][15:0]) | ({16{((divTable2[1][16])?1'b0:1'b1)}} & divTable2[0][15:0]);

wire [2:0] divPartialResult;
assign divPartialResult={divTable0[1][16],divTable1[1][16],divTable2[1][16]};

always @(posedge main_clk) begin
	if (step!=3'd0) begin
		assert (doExecute);
	end
end

reg wa0=0; // if r0 is being set by alternative register
reg wa1=0; // r0
reg wa2=0; // if r1 is being set by alternative register
reg wa3=0; // r1
reg wa4=0; // 0 or 13
reg wa5=0; // 1 or 14 or 15

reg wb0; // discern if wa4 is for 0
reg wb1; // discern if wa4 is for 13
reg wb2; // discern if wa5 is for 1
reg wb3; // discern if wa5 is for 14
reg wb4; // discern if wa5 is for 15

reg [15:0] wv0;
reg [15:0] wv1;
reg [15:0] wv2;
reg [15:0] wv3;
reg [15:0] wv4;
reg [15:0] wv5;

reg [15:0] wt;

always_comb begin
	wt=wa0?wv1:wv0;
	writeValues='{wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt,wt};
	if (wa3) writeValues[instructionCurrent[7:4]]=wa2?wv3:wv2;
	if (wa4) writeValues[ 0]=wv4;
	if (wa4) writeValues[13]=wv4;
	if (wa5) writeValues[ 1]=wv5;
	if (wa5) writeValues[14]=wv5;
	if (wa5) writeValues[15]=wv5;
end
always_comb begin
	doWrite=0;
	if (wa1) doWrite[instructionCurrent[3:0]]=1'b1;
	if (wa3) doWrite[instructionCurrent[7:4]]=1'b1;
	if (wa4 & wb0) doWrite[ 0]=1'b1;
	if (wa4 & wb1) doWrite[13]=1'b1;
	if (wa5 & wb2) doWrite[ 1]=1'b1;
	if (wa5 & wb3) doWrite[14]=1'b1;
	if (wa5 & wb4) doWrite[15]=1'b1;
end


always @(posedge main_clk) begin
	mem_is_stack_access_write<=0;
	mem_is_stack_access_requesting<=0;
	mem_is_general_access_byte_operation<=0;
	mem_is_general_access_write<=0;
	mem_is_general_access_requesting<=0;
	mem_stack_access_size<=3'hx;
	mem_target_address_general<=32'hx;
	mem_target_address_stack<=16'hx;
	doWrite_sp<=0;
	writeValue_sp<=16'hx;
	wv0<=16'hx;
	wv1<=16'hx;
	wv2<=16'hx;
	wv3<=16'hx;
	wv4<=16'hx;
	wv5<=16'hx;
	wa0<=0;
	wa1<=0;
	wa2<=0;
	wa3<=0;
	wa4<=0;
	wa5<=0;
	wb0<=1'bx;
	wb1<=1'bx;
	wb2<=1'bx;
	wb3<=1'bx;
	wb4<=1'bx;
	if (willExecute) begin
		unique case (instructionInID)
		0:begin
			wa0<=1;
			wv1<={8'h0,instructionIn[11:4]};
			wa1<=1;
		end
		1:begin
			wa0<=1;
			wv1<={instructionIn[11:4],nvr0[7:0]};
			wa1<=1;
		end
		2:begin
			mem_is_stack_access_write<=0;
			mem_stack_access_size<=1;
			mem_target_address_stack<=temporary1;
			unique case (stepNext)
			0:begin
				mem_is_stack_access_requesting<=1;
			end
			1:begin
				wv0<=mem_data_out_large[0];
				wa1<=1;
			end
			endcase
		end
		3:begin
			mem_is_stack_access_write<=1;
			mem_is_stack_access_requesting<=1;
			mem_stack_access_size<=1;
			mem_target_address_stack<=temporary1;
		end
		4:begin
			wa0<=1;
			wv1<=temporary0;
			wa1<=1;
		end
		5:begin
			wa0<=1;
			wv1<=temporary0;
			wa1<=1;
		end
		6:begin
			wa0<=1;
			wv1<=temporary0;
			wa1<=1;
		end
		7:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv1<={15'h0,adderOutput[16]};
				wa1<=1;
				wv2<=adderOutput[15:0];
				wa3<=1;
			end
			endcase
		end
		8:begin
			mem_is_general_access_byte_operation<=0;
			mem_is_general_access_write<=0;
			mem_target_address_general<={nvr2,nvr1};
			mem_target_address_general[0]<=1'b0;
			unique case (stepNext)
			0:begin
				mem_is_general_access_requesting<=1;
			end
			1:begin
				wv0<=mem_data_out_small;
				wa1<=1;
			end
			endcase
		end
		9:begin
			mem_is_general_access_requesting<=1;
			mem_is_general_access_byte_operation<=0;
			mem_is_general_access_write<=1;
			mem_target_address_general<={nvr2,nvr1};
			mem_target_address_general[0]<=1'b0;
		end
		10:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv1<=adderOutput[15:0];
				wa1<=1;
			end
			endcase
		end
		11:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv1<=adderOutput[15:0];
				wv5<={15'h0,adderOutput[16]};
				wa1<=1;
				wa5<=1;
				wb2<=0;
				wb3<=0;
				wb4<=1;
			end
			endcase
		end
		12:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv1<=adderOutput[15:0];
				wa1<=1;
			end
			endcase
		end
		13:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv1<={15'h0,adderOutput[16]};
				wa1<=1;
			end
			endcase
		end
		14:begin
			instruction_jump_address<={nvr1,nvr0};
		end
		16:begin
			mem_is_stack_access_write<=1;
			mem_stack_access_size<=1;
			mem_is_stack_access_requesting<=1;
			mem_target_address_stack<=next_stack_pointer-4'd2;
			if (mem_will_access_be_acknowledged_pulse) begin
				writeValue_sp<=stack_pointer_m2;
				doWrite_sp<=1'b1;
				
				assert (next_stack_pointer==stack_pointer); // and that stack_pointer's instant_override is not active
			end
		end
		17:begin
			mem_is_stack_access_write<=1;
			mem_stack_access_size<=2;
			mem_is_stack_access_requesting<=1;
			mem_target_address_stack<=next_stack_pointer-4'd4;
			if (mem_will_access_be_acknowledged_pulse) begin
				writeValue_sp<=stack_pointer_p4;
				doWrite_sp<=1'b1;
				
				assert (next_stack_pointer==stack_pointer); // and that stack_pointer's instant_override is not active
			end
		end
		18:begin
			mem_is_stack_access_write<=0;
			mem_stack_access_size<=1;
			mem_target_address_stack<=next_stack_pointer;
			unique case (stepNext)
			0:begin
				mem_is_stack_access_requesting<=1;
			end
			1:begin
				doWrite_sp<=1'b1;
				wv0<=mem_data_out_large[0];
				wa1<=1;
				writeValue_sp<=stack_pointer_p2;
				
				assert (next_stack_pointer==stack_pointer); // and that stack_pointer's instant_override is not active
			end
			endcase
		end
		19:begin
			mem_is_stack_access_write<=0;
			mem_stack_access_size<=2;
			mem_target_address_stack<=next_stack_pointer;
			wa2<=1;
			unique case (stepNext)
			0:begin
				mem_is_stack_access_requesting<=1;
			end
			1:begin
				doWrite_sp<=1'b1;
				wv0<=mem_data_out_large[0];
				wv3<=mem_data_out_large[1];
				wa1<=1;
				wa3<=1;
				writeValue_sp<=stack_pointer_p4;
				
				assert (next_stack_pointer==stack_pointer); // and that stack_pointer's instant_override is not active
			end
			endcase
		end
		20:begin
			wv0<=nvr1;
			wa1<=1;
		end
		21:begin
			wv0<={nvr1[ 7:0],nvr1[15:8]};
			wa1<=1;
		end
		22:begin
			wv0<={1'b0,nvr1[15:1]};
			wa1<=1;
		end
		23:begin
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv0<=mul16Temp;
				wa1<=1;
			end
			endcase
		end
		24:begin
			unique case (stepNext)
			0:begin
			end
			1:begin
				wv4<=mul32Temp[15: 0];
				wv5<=mul32Temp[31:16];
				wa4<=1;
				wa5<=1;
				
				wb2<=0;
				wb3<=1;
				wb4<=0;
			end
			endcase
		end
		25:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
			end
			2:begin
			end
			3:begin
			end
			4:begin
			end
			5:begin
			end
			6:begin
				wv1<={divTemp3[15:3],divPartialResult};
				wv2<=divTable2[2][15:0];
				wa1<=1;
				wa3<=1;
				
				wb0<=0;
				wb1<=1;
			end
			endcase
		end
		26:begin
			mem_is_stack_access_write<=1;
			mem_stack_access_size<=4;
			mem_target_address_stack<=next_stack_pointer-4'd8;
			unique case (stepNext)
			0:begin
				mem_is_stack_access_requesting<=1;
			end
			1:begin
				doWrite_sp<=1'b1;
				instruction_jump_address<={nvr1,nvr0};
				writeValue_sp<=stack_pointer_m8;
				wv4<=stack_pointer_m8;
				wa4<=1;
				wb0<=1;
				wb1<=0;
				
				assert (next_stack_pointer==stack_pointer); // and that stack_pointer's instant_override is not active
			end
			endcase
		end
		27:begin
			mem_is_stack_access_write<=0;
			mem_stack_access_size<=5;
			mem_target_address_stack<=instant_user_reg[4'h0]-4'h8;
			
			// this is able to use user_reg[4'h0] and ignore the instant_override because it is known to take more then one cycle before this value is used (so there is no override at the time this value is used)
			unique case (stepNext)
			0:begin
				mem_is_stack_access_requesting<=1;
			end
			1:begin
			end
			2:begin
				instruction_jump_address<={mem_data_out_large_r[3],mem_data_out_large_r[4]};
				doWrite_sp<=1'b1;
				writeValue_sp<=(user_reg[4'h0]-4'hA) + mem_data_out_large_r[0];
				wv4<=mem_data_out_large_r[1];
				wv5<=mem_data_out_large_r[2];
				wa4<=1;
				wa5<=1;
				wb0<=1;
				wb1<=0;
				wb2<=1;
				wb3<=0;
				wb4<=0;
			end
			endcase
		end
		28:begin
			mem_is_general_access_byte_operation<=1;
			mem_is_general_access_write<=0;
			mem_target_address_general<={nvr1,instant_user_reg[4'hD]};
			unique case (stepNext)
			0:begin
				mem_is_general_access_requesting<=1;
			end
			1:begin
				wv0<=mem_data_out_small;
				wa1<=1;
			end
			endcase
		end
		29:begin
			mem_is_general_access_byte_operation<=1;
			mem_is_general_access_write<=1;
			mem_is_general_access_requesting<=1;
			mem_target_address_general<={nvr1,instant_user_reg[4'hD]};
		end
		30:begin
			instruction_jump_address<={nvr1,nvr0};
		end
		31:begin
			wa0<=1;
			unique case (stepNext)
			0:begin
			end
			1:begin
				doWrite_sp<=1'b1;
				writeValue_sp<=temporary7;
				wv1<=temporary7;
				wa1<=1;
			end
			endcase
		end
		endcase
	end
	
	// the one's bit of this should always be zero
	instruction_jump_address[0]<=1'b0;
	mem_target_address_stack[0]<=1'b0;
end



always_comb begin
	mem_data_in='{16'hx,16'hx,16'hx,16'hx};
	
	if (doExecute) begin
		unique case (instructionCurrentID)
		0:begin
		end
		1:begin
		end
		2:begin
		end
		3:begin
			mem_data_in[0]=vr0;
		end
		4:begin
		end
		5:begin
		end
		6:begin
		end
		7:begin
		end
		8:begin
		end
		9:begin
			mem_data_in[0]=vr0;
		end
		10:begin
		end
		11:begin
		end
		12:begin
		end
		13:begin
		end
		14:begin
		end
		16:begin
			mem_data_in[0]=vr0;
		end
		17:begin
			mem_data_in[0]=vr0;
			mem_data_in[1]=vr1;
		end
		18:begin
		end
		19:begin
		end
		20:begin
		end
		21:begin
		end
		22:begin
		end
		23:begin
		end
		24:begin
		end
		25:begin
		end
		26:begin
			mem_data_in[0]={instructionAddress[15:1],1'b0};
			mem_data_in[1]={7'b0,instructionAddress[24:16]};
			mem_data_in[2]=user_reg[4'h1];
			mem_data_in[3]=user_reg[4'h0];
		end
		27:begin
		end
		28:begin
		end
		29:begin
			mem_data_in[0]=vr0;
		end
		30:begin
		end
		31:begin
		end
		endcase
	end
end

always_comb begin
	mul16Temp=vr1*vr0;
	mul32Temp={vr1,vr0}*{user_reg[4'hE],user_reg[4'hD]};
end


always_comb begin
	if (doExecute) begin
		stepNext=0;
		unique case (instructionCurrentID)
		0:begin
		end
		1:begin
		end
		2:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		3:begin
		end
		4:begin
		end
		5:begin
		end
		6:begin
		end
		7:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		8:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		9:begin
		end
		10:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		11:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		12:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		13:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		14:begin
		end
		16:begin
		end
		17:begin
		end
		18:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		19:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		20:begin
		end
		21:begin
		end
		22:begin
		end
		23:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		24:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		25:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=2;
			end
			2:begin
				stepNext=3;
			end
			3:begin
				stepNext=4;
			end
			4:begin
				stepNext=5;
			end
			5:begin
				stepNext=6;
			end
			6:begin
				stepNext=0;
			end
			endcase
		end
		26:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		27:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=2;
			end
			2:begin
				stepNext=0;
			end
			endcase
		end
		28:begin
			unique case (step)
			0:begin
				if (mem_is_access_acknowledged_pulse) stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		29:begin
		end
		30:begin
		end
		31:begin
			unique case (step)
			0:begin
				stepNext=1;
			end
			1:begin
				stepNext=0;
			end
			endcase
		end
		endcase
	end else begin
		stepNext=step;
	end
end

reg future_sig_helper [3:0];

wire future_sig_helper0a [3:0];
wire future_sig_helper1a [2:0];
wire future_sig_helper2a [1:0];

wire future_sig_helper0b [3:0];
wire future_sig_helper1b [2:0];
wire future_sig_helper2b [1:0];
assign future_sig_helper0b=future_sig_helper;
assign future_sig_helper1b[0]=willExecute;
assign future_sig_helper1b[1]=mem_will_access_be_acknowledged_pulse;
assign future_sig_helper1b[2]=!(| nvr2);

lcell lc00 (.in(future_sig_helper0b[0]),.out(future_sig_helper0a[0]));
lcell lc01 (.in(future_sig_helper0b[1]),.out(future_sig_helper0a[1]));
lcell lc02 (.in(future_sig_helper0b[2]),.out(future_sig_helper0a[2]));
lcell lc03 (.in(future_sig_helper0b[3]),.out(future_sig_helper0a[3]));

lcell lc10 (.in(future_sig_helper1b[0]),.out(future_sig_helper1a[0]));
lcell lc11 (.in(future_sig_helper1b[1]),.out(future_sig_helper1a[1]));
lcell lc12 (.in(future_sig_helper1b[2]),.out(future_sig_helper1a[2]));

lcell lc20 (.in(future_sig_helper2b[0]),.out(future_sig_helper2a[0]));
lcell lc21 (.in(future_sig_helper2b[1]),.out(future_sig_helper2a[1]));

assign future_sig_helper2b[0]=(future_sig_helper0a[0] | future_sig_helper0a[1]) & (future_sig_helper0a[0]?future_sig_helper1a[0]:1'b1) & (future_sig_helper0a[1]?future_sig_helper1a[1]:1'b1);
assign future_sig_helper2b[1]=(future_sig_helper0a[2] | future_sig_helper0a[3]) & (future_sig_helper0a[2]?future_sig_helper1a[0]:1'b1) & (future_sig_helper0a[3]?future_sig_helper1a[2]:1'b1);

assign will_instruction_finish_next_cycle_pulse=future_sig_helper2a[0];
assign will_jump_next_cycle=future_sig_helper2a[1];


always_comb begin
	future_sig_helper='{0,0,0,0};
	unique case (instructionInID)
	0:begin
		future_sig_helper[0]=1;
	end
	1:begin
		future_sig_helper[0]=1;
	end
	2:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	3:begin
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	4:begin
		future_sig_helper[0]=1;
	end
	5:begin
		future_sig_helper[0]=1;
	end
	6:begin
		future_sig_helper[0]=1;
	end
	7:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	8:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	9:begin
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	10:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	11:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	12:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	13:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	14:begin
			future_sig_helper[0]=1;
			future_sig_helper[2]=1;
			future_sig_helper[3]=1;
	end
	16:begin
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	17:begin
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	18:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	19:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	20:begin
		future_sig_helper[0]=1;
	end
	21:begin
		future_sig_helper[0]=1;
	end
	22:begin
		future_sig_helper[0]=1;
	end
	23:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	24:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	25:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
		end
		2:begin
		end
		3:begin
		end
		4:begin
		end
		5:begin
		end
		6:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	26:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
			future_sig_helper[2]=1;
		end
		endcase
	end
	27:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
		end
		2:begin
			future_sig_helper[0]=1;
			future_sig_helper[2]=1;
		end
		endcase
	end
	28:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	29:begin
		future_sig_helper[0]=1;
		future_sig_helper[1]=1;
	end
	30:begin
		future_sig_helper[0]=1;
		future_sig_helper[2]=1;
	end
	31:begin
		unique case (stepNext)
		0:begin
		end
		1:begin
			future_sig_helper[0]=1;
		end
		endcase
	end
	endcase
end


always @(posedge main_clk) begin
	if (doExecute && instructionCurrentID==5'd25) begin
		// this is only actually used for division
		unique case (step)
		0:begin
			divTemp0<={1'b0,~vr1}+1'b1;
			divTemp1<=vr0;
			divTemp2<=vr0[14:12];
			divTemp5<=divTemp7;
			divTemp3[15]<=divTemp6[16];
		end
		1:begin
			divTemp2<=divTemp1[11:9];
			divTemp5<=divTable2[2][15:0];
			divTemp3[14:12]<=divPartialResult;
		end
		2:begin
			divTemp2<=divTemp1[8:6];
			divTemp5<=divTable2[2][15:0];
			divTemp3[11:9]<=divPartialResult;
		end
		3:begin
			divTemp2<=divTemp1[5:3];
			divTemp5<=divTable2[2][15:0];
			divTemp3[8:6]<=divPartialResult;
		end
		4:begin
			divTemp2<=divTemp1[2:0];
			divTemp5<=divTable2[2][15:0];
			divTemp3[5:3]<=divPartialResult;
		end
		5:begin
		end
		6:begin
		end
		endcase
	end
end

endmodule




module core_main(
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

	input vga_clk,
	input main_clk,
	
	output [15:0] debug_user_reg [15:0],
	output [15:0] debug_stack_pointer,
	output [25:0] debug_instruction_fetch_address,
	input debug_scheduler

);


reg [3:0] orderConflictsAdapted [3:0];

reg [3:0] orderConflictsSaved [3:0]='{0,0,0,0};
reg [3:0] orderConflictsNext [3:0];
wire [3:0] orderConflictsNextTrue [3:0];
reg [7:0] orderConflictsAbove [3:0];

reg [3:0] executionConflicts0Saved [3:0]='{0,0,0,0};
reg [3:0] executionConflicts0Next [3:0];
wire [3:0] executionConflicts0NextTrue [3:0];
reg [7:0] executionConflicts0Above [3:0];

reg [3:0] executionConflicts1Saved [3:0]='{0,0,0,0};
reg [3:0] executionConflicts1Next [3:0];
wire [3:0] executionConflicts1NextTrue [3:0];
reg [7:0] executionConflicts1Above [3:0];

reg [3:0] executionConflicts2Saved [3:0]='{0,0,0,0};
reg [3:0] executionConflicts2Next [3:0];
wire [3:0] executionConflicts2NextTrue [3:0];
reg [7:0] executionConflicts2Above [3:0];


`include "AutoGen3.sv"

always_comb begin
	orderConflictsAdapted=orderConflictsSaved;
	orderConflictsAdapted[0][0]=1'b1;
	orderConflictsAdapted[1][1]=1'b1;
	orderConflictsAdapted[2][2]=1'b1;
	orderConflictsAdapted[3][3]=1'b1;
end



reg [15:0] stack_pointer=16'h0000;
reg [15:0] stack_pointer_m2=16'hFFFE;
reg [15:0] stack_pointer_m4=16'hFFFC;
reg [15:0] stack_pointer_m6=16'hFFFA;
reg [15:0] stack_pointer_m8=16'hFFF8;

reg [15:0] stack_pointer_p2=16'h0002;
reg [15:0] stack_pointer_p4=16'h0004;

reg [15:0] user_reg [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

reg is_new_instruction_entering_this_cycle_pulse_0; // only valid if `is_performing_jump==0`
reg is_new_instruction_entering_this_cycle_pulse_1; // only valid if `is_performing_jump==0`
reg is_new_instruction_entering_this_cycle_pulse_2; // only valid if `is_performing_jump==0`
reg is_new_instruction_entering_this_cycle_pulse_3; // only valid if `is_performing_jump==0`

wire is_instruction_finishing_this_cycle_pulse_0;
wire is_instruction_finishing_this_cycle_pulse_1;
wire is_instruction_finishing_this_cycle_pulse_2;
wire is_instruction_finishing_this_cycle_pulse_3;

wire will_instruction_finish_next_cycle_pulse_0;
wire will_instruction_finish_next_cycle_pulse_1;
wire will_instruction_finish_next_cycle_pulse_2;
wire will_instruction_finish_next_cycle_pulse_3;

reg [15:0] instructionCurrent_scheduler_0_saved=0;
reg [15:0] instructionCurrent_scheduler_1_saved=0;
reg [15:0] instructionCurrent_scheduler_2_saved=0;
reg [15:0] instructionCurrent_scheduler_3_saved=0;

reg [15:0] instructionCurrent_scheduler_0;
reg [15:0] instructionCurrent_scheduler_1;
reg [15:0] instructionCurrent_scheduler_2;
reg [15:0] instructionCurrent_scheduler_3;

reg executerEnable [3:0]='{0,0,0,0};
reg executerWillBeEnabled [3:0];

always @(posedge main_clk) executerEnable<=executerWillBeEnabled;

reg isInstructionValid_scheduler_0=0;
reg isInstructionValid_scheduler_0_future2=0;
reg isInstructionValid_scheduler_0_future3;
reg isInstructionValid_scheduler_0_future4;

reg isInstructionValid_scheduler_1=0;
reg isInstructionValid_scheduler_1_future2=0;
reg isInstructionValid_scheduler_1_future3;
reg isInstructionValid_scheduler_1_future4;

reg isInstructionValid_scheduler_2=0;
reg isInstructionValid_scheduler_2_future2=0;
reg isInstructionValid_scheduler_2_future3;
reg isInstructionValid_scheduler_2_future4;

reg isInstructionValid_scheduler_3=0;
reg isInstructionValid_scheduler_3_future2=0;
reg isInstructionValid_scheduler_3_future3;
reg isInstructionValid_scheduler_3_future4;

always @(posedge main_clk) begin
	isInstructionValid_scheduler_0<=isInstructionValid_scheduler_0_future4;
	isInstructionValid_scheduler_1<=isInstructionValid_scheduler_1_future4;
	isInstructionValid_scheduler_2<=isInstructionValid_scheduler_2_future4;
	isInstructionValid_scheduler_3<=isInstructionValid_scheduler_3_future4;
	
	instructionCurrent_scheduler_0_saved<=instructionCurrent_scheduler_0;
	instructionCurrent_scheduler_1_saved<=instructionCurrent_scheduler_1;
	instructionCurrent_scheduler_2_saved<=instructionCurrent_scheduler_2;
	instructionCurrent_scheduler_3_saved<=instructionCurrent_scheduler_3;
	
	isInstructionValid_scheduler_0_future2<=will_instruction_finish_next_cycle_pulse_0?1'b0:isInstructionValid_scheduler_0_future4;
	isInstructionValid_scheduler_1_future2<=will_instruction_finish_next_cycle_pulse_1?1'b0:isInstructionValid_scheduler_1_future4;
	isInstructionValid_scheduler_2_future2<=will_instruction_finish_next_cycle_pulse_2?1'b0:isInstructionValid_scheduler_2_future4;
	isInstructionValid_scheduler_3_future2<=will_instruction_finish_next_cycle_pulse_3?1'b0:isInstructionValid_scheduler_3_future4;
	
	assert (isInstructionValid_scheduler_0_future2 == (is_instruction_finishing_this_cycle_pulse_0?1'b0:isInstructionValid_scheduler_0));
	assert (isInstructionValid_scheduler_1_future2 == (is_instruction_finishing_this_cycle_pulse_1?1'b0:isInstructionValid_scheduler_1));
	assert (isInstructionValid_scheduler_2_future2 == (is_instruction_finishing_this_cycle_pulse_2?1'b0:isInstructionValid_scheduler_2));
	assert (isInstructionValid_scheduler_3_future2 == (is_instruction_finishing_this_cycle_pulse_3?1'b0:isInstructionValid_scheduler_3));
end



reg [25:0] current_instruction_address_table [3:0];


wire [16:0] executer0DoWrite;
wire [15:0] executer0WriteValues [16:0];
wire [16:0] executer1DoWrite;
wire [15:0] executer1WriteValues [16:0];
wire [16:0] executer2DoWrite;
wire [15:0] executer2WriteValues [16:0];
wire [16:0] executer3DoWrite;
wire [15:0] executer3WriteValues [16:0];

wire [31:0] instruction_jump_address_executer [3:0];
wire jump_signal_executer [3:0];
wire [31:0] instruction_jump_address_selected=
	(instruction_jump_address_executer[0] & {32{jump_signal_executer[0]}}) | 
	(instruction_jump_address_executer[1] & {32{jump_signal_executer[1]}}) | 
	(instruction_jump_address_executer[2] & {32{jump_signal_executer[2]}}) | 
	(instruction_jump_address_executer[3] & {32{jump_signal_executer[3]}});


///

wire [ 2:0] mem_stack_access_size_all [3:0];
wire [15:0] mem_target_address_stack_all [3:0];
wire [31:0] mem_target_address_general_all [3:0];

wire [15:0] mem_data_in_all [3:0][3:0];

wire [3:0] mem_is_stack_access_write_all;
wire [3:0] mem_is_stack_access_requesting_all;

wire [3:0] mem_is_general_access_write_all;
wire [3:0] mem_is_general_access_byte_operation_all;
wire [3:0] mem_is_general_access_requesting_all;

wire [3:0] mem_is_general_or_stack_access_acknowledged_pulse;
wire [3:0] mem_will_general_or_stack_access_be_acknowledged_pulse;

///


wire [25:0] mem_target_address_instruction_fetch;

wire mem_is_instruction_fetch_requesting;
wire mem_is_instruction_fetch_acknowledged_pulse;

wire [15:0] mem_data_out_type_0 [7:0];
wire [15:0] mem_data_out_type_1 [7:0];

wire [25:0] mem_target_address_hyper_instruction_fetch_0;
wire [25:0] mem_target_address_hyper_instruction_fetch_1;

wire mem_is_hyper_instruction_fetch_0_requesting;
wire mem_is_hyper_instruction_fetch_0_acknowledged_pulse;

wire mem_is_hyper_instruction_fetch_1_requesting;
wire mem_is_hyper_instruction_fetch_1_acknowledged_pulse;


wire mem_void_hyper_instruction_fetch;

///
wire [15:0] fifo_instruction_cache_data [15:0];
wire [25:0] fifo_instruction_cache_addresses [15:0];

wire[4:0] fifo_instruction_cache_size;
reg [4:0] fifo_instruction_cache_size_after_read;
reg [2:0] fifo_instruction_cache_consume_count;
reg [2:0] fifo_instruction_cache_size_converted;


wire [1:0] jump_executer_index={jump_signal_executer[2] | jump_signal_executer[3],jump_signal_executer[1] | jump_signal_executer[3]}; // only should be considered valid if there is a single executer doing a jump this cycle
wire is_performing_jump_instant_on=jump_signal_executer[0] | jump_signal_executer[1] | jump_signal_executer[2] | jump_signal_executer[3];
wire is_performing_jump_state;
wire is_performing_jump;

instruction_cache instruction_cache_inst(
	mem_is_instruction_fetch_requesting,
	mem_is_hyper_instruction_fetch_0_requesting,
	mem_is_hyper_instruction_fetch_1_requesting,
	mem_void_hyper_instruction_fetch,
	is_performing_jump_state,
	is_performing_jump,
	fifo_instruction_cache_size,
	mem_target_address_instruction_fetch,
	mem_target_address_hyper_instruction_fetch_0,
	mem_target_address_hyper_instruction_fetch_1,
	fifo_instruction_cache_data,
	fifo_instruction_cache_addresses,
	
	fifo_instruction_cache_size_after_read,
	fifo_instruction_cache_consume_count,
	mem_is_instruction_fetch_acknowledged_pulse,
	mem_is_hyper_instruction_fetch_0_acknowledged_pulse,
	mem_is_hyper_instruction_fetch_1_acknowledged_pulse,
	is_performing_jump_instant_on,
	jump_executer_index,
	instruction_jump_address_selected,
	mem_data_out_type_0,
	user_reg,
	main_clk
);


reg [4:0] instructionCurrentID_scheduler_0;
reg [4:0] instructionCurrentID_scheduler_1;
reg [4:0] instructionCurrentID_scheduler_2;
reg [4:0] instructionCurrentID_scheduler_3;

reg [1:0] new_instruction_index0;
reg [1:0] new_instruction_index1;
reg [1:0] new_instruction_index2;
reg [1:0] new_instruction_index3;

wire [15:0] new_instruction_table [3:0];
assign new_instruction_table[0]=fifo_instruction_cache_data[0];
assign new_instruction_table[1]=fifo_instruction_cache_data[1];
assign new_instruction_table[2]=fifo_instruction_cache_data[2];
assign new_instruction_table[3]=fifo_instruction_cache_data[3];

wire [25:0] new_instruction_address_table [3:0];
assign new_instruction_address_table[0]=fifo_instruction_cache_addresses[0];
assign new_instruction_address_table[1]=fifo_instruction_cache_addresses[1];
assign new_instruction_address_table[2]=fifo_instruction_cache_addresses[2];
assign new_instruction_address_table[3]=fifo_instruction_cache_addresses[3];

wire [4:0] new_instructionID_table [3:0];
assign new_instructionID_table[0]=(& new_instruction_table[0][15:12])?{1'b1,new_instruction_table[0][11:8]}:{1'b0,new_instruction_table[0][15:12]};
assign new_instructionID_table[1]=(& new_instruction_table[1][15:12])?{1'b1,new_instruction_table[1][11:8]}:{1'b0,new_instruction_table[1][15:12]};
assign new_instructionID_table[2]=(& new_instruction_table[2][15:12])?{1'b1,new_instruction_table[2][11:8]}:{1'b0,new_instruction_table[2][15:12]};
assign new_instructionID_table[3]=(& new_instruction_table[3][15:12])?{1'b1,new_instruction_table[3][11:8]}:{1'b0,new_instruction_table[3][15:12]};

wire [4:0] current_instructionID_table [3:0];
assign current_instructionID_table[0]=(& instructionCurrent_scheduler_0_saved[15:12])?{1'b1,instructionCurrent_scheduler_0_saved[11:8]}:{1'b0,instructionCurrent_scheduler_0_saved[15:12]};
assign current_instructionID_table[1]=(& instructionCurrent_scheduler_1_saved[15:12])?{1'b1,instructionCurrent_scheduler_1_saved[11:8]}:{1'b0,instructionCurrent_scheduler_1_saved[15:12]};
assign current_instructionID_table[2]=(& instructionCurrent_scheduler_2_saved[15:12])?{1'b1,instructionCurrent_scheduler_2_saved[11:8]}:{1'b0,instructionCurrent_scheduler_2_saved[15:12]};
assign current_instructionID_table[3]=(& instructionCurrent_scheduler_3_saved[15:12])?{1'b1,instructionCurrent_scheduler_3_saved[11:8]}:{1'b0,instructionCurrent_scheduler_3_saved[15:12]};



wire [2:0] popcnt4 [15:0];
assign popcnt4[4'b0000]=0;
assign popcnt4[4'b0001]=1;
assign popcnt4[4'b0010]=1;
assign popcnt4[4'b0011]=2;
assign popcnt4[4'b0100]=1;
assign popcnt4[4'b0101]=2;
assign popcnt4[4'b0110]=2;
assign popcnt4[4'b0111]=3;
assign popcnt4[4'b1000]=1;
assign popcnt4[4'b1001]=2;
assign popcnt4[4'b1010]=2;
assign popcnt4[4'b1011]=3;
assign popcnt4[4'b1100]=2;
assign popcnt4[4'b1101]=3;
assign popcnt4[4'b1110]=3;
assign popcnt4[4'b1111]=4;

wire [2:0] popcntConsume=popcnt4[{!isInstructionValid_scheduler_3_future2,!isInstructionValid_scheduler_2_future2,!isInstructionValid_scheduler_1_future2,!isInstructionValid_scheduler_0_future2}];

always_comb begin
	new_instruction_index0=2'hx;
	new_instruction_index1=2'hx;
	new_instruction_index2=2'hx;
	new_instruction_index3=2'hx;
	is_new_instruction_entering_this_cycle_pulse_0=0;
	is_new_instruction_entering_this_cycle_pulse_1=0;
	is_new_instruction_entering_this_cycle_pulse_2=0;
	is_new_instruction_entering_this_cycle_pulse_3=0;
	
	fifo_instruction_cache_size_converted[2]=(|(fifo_instruction_cache_size[4:2]))?1'b1:1'b0;
	fifo_instruction_cache_size_converted[1]=(fifo_instruction_cache_size[1] & !fifo_instruction_cache_size_converted[2])?1'b1:1'b0;
	fifo_instruction_cache_size_converted[0]=(fifo_instruction_cache_size[0] & !fifo_instruction_cache_size_converted[2])?1'b1:1'b0;
	
	if (fifo_instruction_cache_size > popcntConsume) begin // could also be viewed as `fifo_instruction_cache_size >= popcntConsume`
		fifo_instruction_cache_consume_count=popcntConsume;
		fifo_instruction_cache_size_after_read=fifo_instruction_cache_size-popcntConsume;
	end else begin
		fifo_instruction_cache_consume_count=fifo_instruction_cache_size[2:0];
		fifo_instruction_cache_size_after_read=0;
	end
	
`include "AutoGen1.sv"
	
	instructionCurrent_scheduler_0=is_new_instruction_entering_this_cycle_pulse_0?new_instruction_table[new_instruction_index0]:instructionCurrent_scheduler_0_saved;
	instructionCurrent_scheduler_1=is_new_instruction_entering_this_cycle_pulse_1?new_instruction_table[new_instruction_index1]:instructionCurrent_scheduler_1_saved;
	instructionCurrent_scheduler_2=is_new_instruction_entering_this_cycle_pulse_2?new_instruction_table[new_instruction_index2]:instructionCurrent_scheduler_2_saved;
	instructionCurrent_scheduler_3=is_new_instruction_entering_this_cycle_pulse_3?new_instruction_table[new_instruction_index3]:instructionCurrent_scheduler_3_saved;
	
	instructionCurrentID_scheduler_0=is_new_instruction_entering_this_cycle_pulse_0?new_instructionID_table[new_instruction_index0]:current_instructionID_table[0];
	instructionCurrentID_scheduler_1=is_new_instruction_entering_this_cycle_pulse_1?new_instructionID_table[new_instruction_index1]:current_instructionID_table[1];
	instructionCurrentID_scheduler_2=is_new_instruction_entering_this_cycle_pulse_2?new_instructionID_table[new_instruction_index2]:current_instructionID_table[2];
	instructionCurrentID_scheduler_3=is_new_instruction_entering_this_cycle_pulse_3?new_instructionID_table[new_instruction_index3]:current_instructionID_table[3];
	
	isInstructionValid_scheduler_0_future3=is_new_instruction_entering_this_cycle_pulse_0?1'b1:isInstructionValid_scheduler_0_future2;
	isInstructionValid_scheduler_1_future3=is_new_instruction_entering_this_cycle_pulse_1?1'b1:isInstructionValid_scheduler_1_future2;
	isInstructionValid_scheduler_2_future3=is_new_instruction_entering_this_cycle_pulse_2?1'b1:isInstructionValid_scheduler_2_future2;
	isInstructionValid_scheduler_3_future3=is_new_instruction_entering_this_cycle_pulse_3?1'b1:isInstructionValid_scheduler_3_future2;
end

always @(posedge main_clk) begin
	if (is_new_instruction_entering_this_cycle_pulse_0) current_instruction_address_table[0]<=new_instruction_address_table[new_instruction_index0];
	if (is_new_instruction_entering_this_cycle_pulse_1) current_instruction_address_table[1]<=new_instruction_address_table[new_instruction_index1];
	if (is_new_instruction_entering_this_cycle_pulse_2) current_instruction_address_table[2]<=new_instruction_address_table[new_instruction_index2];
	if (is_new_instruction_entering_this_cycle_pulse_3) current_instruction_address_table[3]<=new_instruction_address_table[new_instruction_index3];
end

wire [15:0] instant_updated_core_values [16:0];

recomb_mux_all_user_reg recomb_mux_full(
	instant_updated_core_values[15:0],
	user_reg,
	'{executer3DoWrite[15:0],executer2DoWrite[15:0],executer1DoWrite[15:0],executer0DoWrite[15:0]},
	executer0WriteValues[15:0],
	executer1WriteValues[15:0],
	executer2WriteValues[15:0],
	executer3WriteValues[15:0]
);
recomb_mux recomb_mux_16(
	instant_updated_core_values[16],
	stack_pointer,
	{executer3DoWrite[16] , executer2DoWrite[16] , executer1DoWrite[16] , executer0DoWrite[16]},
	'{executer3WriteValues[16],executer2WriteValues[16],executer1WriteValues[16],executer0WriteValues[16]}
);


always @(posedge main_clk) begin
	assert ((executer0DoWrite & executer1DoWrite)==0);
	assert ((executer0DoWrite & executer2DoWrite)==0);
	assert ((executer0DoWrite & executer3DoWrite)==0);
	assert ((executer1DoWrite & executer2DoWrite)==0);
	assert ((executer1DoWrite & executer3DoWrite)==0);
	assert ((executer2DoWrite & executer3DoWrite)==0);
end


always @(posedge main_clk) begin
	user_reg<=instant_updated_core_values[15:0];
	stack_pointer   <=instant_updated_core_values[16];
	stack_pointer_m2<=instant_updated_core_values[16]-5'd2;
	stack_pointer_m4<=instant_updated_core_values[16]-5'd4;
	stack_pointer_m6<=instant_updated_core_values[16]-5'd6;
	stack_pointer_m8<=instant_updated_core_values[16]-5'd8;
	stack_pointer_p2<=instant_updated_core_values[16]+5'd2;
	stack_pointer_p4<=instant_updated_core_values[16]+5'd4;
	stack_pointer[0]   <=1'b0;
	stack_pointer_m2[0]<=1'b0;
	stack_pointer_m4[0]<=1'b0;
	stack_pointer_m6[0]<=1'b0;
	stack_pointer_m8[0]<=1'b0;
	stack_pointer_p2[0]<=1'b0;
	stack_pointer_p4[0]<=1'b0;
end


core_executer core_executer_inst0(
	instructionCurrent_scheduler_0,
	instructionCurrentID_scheduler_0,
	current_instruction_address_table[0],
	executerEnable[0],
	executerWillBeEnabled[0],
	user_reg,
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	stack_pointer,
	stack_pointer_m2,
	stack_pointer_m4,
	stack_pointer_m6,
	stack_pointer_m8,
	stack_pointer_p2,
	stack_pointer_p4,
	executer0DoWrite,
	executer0WriteValues,
	
	mem_stack_access_size_all[0],
	mem_target_address_stack_all[0],
	mem_target_address_general_all[0],
	
	mem_data_out_type_1[0],
	mem_data_out_type_1[4:0],
	mem_data_in_all[0],
	
	mem_is_stack_access_write_all[0],
	mem_is_stack_access_requesting_all[0],
	mem_is_general_access_write_all[0],
	mem_is_general_access_byte_operation_all[0],
	mem_is_general_access_requesting_all[0],
	mem_is_general_or_stack_access_acknowledged_pulse[0],
	mem_will_general_or_stack_access_be_acknowledged_pulse[0],
	
	is_instruction_finishing_this_cycle_pulse_0,
	will_instruction_finish_next_cycle_pulse_0,
	
	instruction_jump_address_executer[0],
	jump_signal_executer[0],
	
	main_clk
);

core_executer core_executer_inst1(
	instructionCurrent_scheduler_1,
	instructionCurrentID_scheduler_1,
	current_instruction_address_table[1],
	executerEnable[1],
	executerWillBeEnabled[1],
	user_reg,
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	stack_pointer,
	stack_pointer_m2,
	stack_pointer_m4,
	stack_pointer_m6,
	stack_pointer_m8,
	stack_pointer_p2,
	stack_pointer_p4,
	executer1DoWrite,
	executer1WriteValues,
	
	mem_stack_access_size_all[1],
	mem_target_address_stack_all[1],
	mem_target_address_general_all[1],
	
	mem_data_out_type_1[0],
	mem_data_out_type_1[4:0],
	mem_data_in_all[1],
	
	mem_is_stack_access_write_all[1],
	mem_is_stack_access_requesting_all[1],
	mem_is_general_access_write_all[1],
	mem_is_general_access_byte_operation_all[1],
	mem_is_general_access_requesting_all[1],
	mem_is_general_or_stack_access_acknowledged_pulse[1],
	mem_will_general_or_stack_access_be_acknowledged_pulse[1],
	
	is_instruction_finishing_this_cycle_pulse_1,
	will_instruction_finish_next_cycle_pulse_1,
	
	instruction_jump_address_executer[1],
	jump_signal_executer[1],
	
	main_clk
);

core_executer core_executer_inst2(
	instructionCurrent_scheduler_2,
	instructionCurrentID_scheduler_2,
	current_instruction_address_table[2],
	executerEnable[2],
	executerWillBeEnabled[2],
	user_reg,
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	stack_pointer,
	stack_pointer_m2,
	stack_pointer_m4,
	stack_pointer_m6,
	stack_pointer_m8,
	stack_pointer_p2,
	stack_pointer_p4,
	executer2DoWrite,
	executer2WriteValues,
	
	mem_stack_access_size_all[2],
	mem_target_address_stack_all[2],
	mem_target_address_general_all[2],
	
	mem_data_out_type_1[0],
	mem_data_out_type_1[4:0],
	mem_data_in_all[2],
	
	mem_is_stack_access_write_all[2],
	mem_is_stack_access_requesting_all[2],
	mem_is_general_access_write_all[2],
	mem_is_general_access_byte_operation_all[2],
	mem_is_general_access_requesting_all[2],
	mem_is_general_or_stack_access_acknowledged_pulse[2],
	mem_will_general_or_stack_access_be_acknowledged_pulse[2],
	
	is_instruction_finishing_this_cycle_pulse_2,
	will_instruction_finish_next_cycle_pulse_2,
	
	instruction_jump_address_executer[2],
	jump_signal_executer[2],
	
	main_clk
);

core_executer core_executer_inst3(
	instructionCurrent_scheduler_3,
	instructionCurrentID_scheduler_3,
	current_instruction_address_table[3],
	executerEnable[3],
	executerWillBeEnabled[3],
	user_reg,
	instant_updated_core_values[15:0],
	
	instant_updated_core_values[16],
	stack_pointer,
	stack_pointer_m2,
	stack_pointer_m4,
	stack_pointer_m6,
	stack_pointer_m8,
	stack_pointer_p2,
	stack_pointer_p4,
	executer3DoWrite,
	executer3WriteValues,
	
	mem_stack_access_size_all[3],
	mem_target_address_stack_all[3],
	mem_target_address_general_all[3],
	
	mem_data_out_type_1[0],
	mem_data_out_type_1[4:0],
	mem_data_in_all[3],
	
	mem_is_stack_access_write_all[3],
	mem_is_stack_access_requesting_all[3],
	mem_is_general_access_write_all[3],
	mem_is_general_access_byte_operation_all[3],
	mem_is_general_access_requesting_all[3],
	mem_is_general_or_stack_access_acknowledged_pulse[3],
	mem_will_general_or_stack_access_be_acknowledged_pulse[3],
	
	is_instruction_finishing_this_cycle_pulse_3,
	will_instruction_finish_next_cycle_pulse_3,
	
	instruction_jump_address_executer[3],
	jump_signal_executer[3],
	
	main_clk
);

wire [3:0] memory_dependency_clear;

full_memory full_memory_inst(
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
	
	VGA_B,
	VGA_G,
	VGA_R,
	VGA_HS,
	VGA_VS,
	
	// for all memory access ports, once a request has begun to be issued, it should not be changed before it is acknowledged. hyper_instruction_fetch has a void signal that allows it to change
	
	mem_stack_access_size_all,
	mem_target_address_stack_all,
	mem_is_stack_access_write_all,
	mem_is_stack_access_requesting_all,
	
	mem_target_address_general_all,
	// target_address_general is allowed to access I/O mapped memory regions and can be any type of memory access 
	mem_data_in_all,
	
	mem_is_general_access_write_all,
	mem_is_general_access_byte_operation_all,
	mem_is_general_access_requesting_all,

	mem_is_general_or_stack_access_acknowledged_pulse,
	mem_will_general_or_stack_access_be_acknowledged_pulse,
	
	mem_target_address_hyper_instruction_fetch_0,
	mem_target_address_hyper_instruction_fetch_1,
	// target_address_hyper_instruction_fetch_x is very similiar to target_address_instruction_fetch
	// However, it will NEVER cause a cache fault to DRAM because it is a suggestion to read memory when it is unknown if memory at that location will actually be needed.
	// This request is always serviced at miniumum priority, therefore all other accesses will occur before either of these accesses occure.
	// Further, if target_address_hyper_instruction_fetch_0 is not in cache, then target_address_hyper_instruction_fetch_1 will not be accessed.
	// target_address_hyper_instruction_fetch_0 will always be served before target_address_hyper_instruction_fetch_1
	// these accesses use data_out_type_0_extern
	
	mem_is_hyper_instruction_fetch_0_requesting,
	mem_is_hyper_instruction_fetch_0_acknowledged_pulse,
	mem_is_hyper_instruction_fetch_1_requesting,
	mem_is_hyper_instruction_fetch_1_acknowledged_pulse,
	
	mem_void_hyper_instruction_fetch, // when on, this will void any in-progress hyper instruction fetches. This is needed to ensure validity in some edge cases. it does NOT void the request that is being requested on the same cycle that this is on
	
	mem_target_address_instruction_fetch,
	// target_address_instruction_fetch is not allowed to access I/O mapped memory regions, and must be a word read. 
	// the entire cache lane is given for where the word read falls. The amount of valid words returned is trivial to calculate elsewhere, so it is not given
	// this access uses data_out_type_0_extern
	
	mem_is_instruction_fetch_requesting,
	mem_is_instruction_fetch_acknowledged_pulse,
	
	mem_data_out_type_0, // type_0 always uses the single access
	mem_data_out_type_1, // type_1 potentially uses the multi access
	
	memory_dependency_clear,
	
	vga_clk,
	main_clk
);



wire [7:0] instructionNotFininshingMask;
assign instructionNotFininshingMask={4'hF,!is_instruction_finishing_this_cycle_pulse_3,!is_instruction_finishing_this_cycle_pulse_2,!is_instruction_finishing_this_cycle_pulse_1,!is_instruction_finishing_this_cycle_pulse_0};

wire [7:0] memDependNotClearedMask;
assign memDependNotClearedMask={4'hF,!memory_dependency_clear[3],!memory_dependency_clear[2],!memory_dependency_clear[1],!memory_dependency_clear[0]};

wire [7:0] orderConflictsGeneratedValid [3:0];
wire [7:0] executionConflicts0GeneratedValid [3:0];
wire [7:0] executionConflicts1GeneratedValid [3:0];
wire [7:0] executionConflicts2GeneratedValid [3:0];


quad_instruction_conflict_detection quad_instruction_conflict_detection_inst(
	orderConflictsGeneratedValid,
	executionConflicts0GeneratedValid,
	executionConflicts1GeneratedValid,
	executionConflicts2GeneratedValid,
	
	'{
		new_instruction_index3,
		new_instruction_index2,
		new_instruction_index1,
		new_instruction_index0
	},
	'{
		isInstructionValid_scheduler_3,
		isInstructionValid_scheduler_2,
		isInstructionValid_scheduler_1,
		isInstructionValid_scheduler_0
	},
	'{
		is_new_instruction_entering_this_cycle_pulse_3,
		is_new_instruction_entering_this_cycle_pulse_2,
		is_new_instruction_entering_this_cycle_pulse_1,
		is_new_instruction_entering_this_cycle_pulse_0
	},
	'{
		is_instruction_finishing_this_cycle_pulse_3,
		is_instruction_finishing_this_cycle_pulse_2,
		is_instruction_finishing_this_cycle_pulse_1,
		is_instruction_finishing_this_cycle_pulse_0
	},
	new_instruction_table,
	new_instructionID_table,
	instructionCurrent_scheduler_0_saved,
	instructionCurrent_scheduler_1_saved,
	instructionCurrent_scheduler_2_saved,
	instructionCurrent_scheduler_3_saved,
	main_clk
);

always_comb begin
	orderConflictsNext[0]=instructionNotFininshingMask[3:0] & orderConflictsSaved[0];
	orderConflictsNext[1]=instructionNotFininshingMask[3:0] & orderConflictsSaved[1];
	orderConflictsNext[2]=instructionNotFininshingMask[3:0] & orderConflictsSaved[2];
	orderConflictsNext[3]=instructionNotFininshingMask[3:0] & orderConflictsSaved[3];
	
	executionConflicts0Next[0]=instructionNotFininshingMask[3:0] & executionConflicts0Saved[0];
	executionConflicts0Next[1]=instructionNotFininshingMask[3:0] & executionConflicts0Saved[1];
	executionConflicts0Next[2]=instructionNotFininshingMask[3:0] & executionConflicts0Saved[2];
	executionConflicts0Next[3]=instructionNotFininshingMask[3:0] & executionConflicts0Saved[3];

	executionConflicts1Next[0]=instructionNotFininshingMask[3:0] & executionConflicts1Saved[0];
	executionConflicts1Next[1]=instructionNotFininshingMask[3:0] & executionConflicts1Saved[1];
	executionConflicts1Next[2]=instructionNotFininshingMask[3:0] & executionConflicts1Saved[2];
	executionConflicts1Next[3]=instructionNotFininshingMask[3:0] & executionConflicts1Saved[3];

	executionConflicts2Next[0]=instructionNotFininshingMask[3:0] & executionConflicts2Saved[0];
	executionConflicts2Next[1]=instructionNotFininshingMask[3:0] & executionConflicts2Saved[1];
	executionConflicts2Next[2]=instructionNotFininshingMask[3:0] & executionConflicts2Saved[2];
	executionConflicts2Next[3]=instructionNotFininshingMask[3:0] & executionConflicts2Saved[3];
	
	orderConflictsAbove[0]=instructionNotFininshingMask & orderConflictsGeneratedValid[0];
	orderConflictsAbove[1]=instructionNotFininshingMask & orderConflictsGeneratedValid[1];
	orderConflictsAbove[2]=instructionNotFininshingMask & orderConflictsGeneratedValid[2];
	orderConflictsAbove[3]=instructionNotFininshingMask & orderConflictsGeneratedValid[3];

	executionConflicts0Above[0]=instructionNotFininshingMask & executionConflicts0GeneratedValid[0];
	executionConflicts0Above[1]=instructionNotFininshingMask & executionConflicts0GeneratedValid[1];
	executionConflicts0Above[2]=instructionNotFininshingMask & executionConflicts0GeneratedValid[2];
	executionConflicts0Above[3]=instructionNotFininshingMask & executionConflicts0GeneratedValid[3];

	executionConflicts1Above[0]=instructionNotFininshingMask & executionConflicts1GeneratedValid[0];
	executionConflicts1Above[1]=instructionNotFininshingMask & executionConflicts1GeneratedValid[1];
	executionConflicts1Above[2]=instructionNotFininshingMask & executionConflicts1GeneratedValid[2];
	executionConflicts1Above[3]=instructionNotFininshingMask & executionConflicts1GeneratedValid[3];

	executionConflicts2Above[0]=memDependNotClearedMask & executionConflicts2GeneratedValid[0];
	executionConflicts2Above[1]=memDependNotClearedMask & executionConflicts2GeneratedValid[1];
	executionConflicts2Above[2]=memDependNotClearedMask & executionConflicts2GeneratedValid[2];
	executionConflicts2Above[3]=memDependNotClearedMask & executionConflicts2GeneratedValid[3];
end

always_comb begin
	isInstructionValid_scheduler_0_future4=((is_performing_jump_instant_on && (is_new_instruction_entering_this_cycle_pulse_0 || orderConflictsAdapted[0][jump_executer_index])) || (is_performing_jump_state && is_new_instruction_entering_this_cycle_pulse_0))?1'b0:isInstructionValid_scheduler_0_future3;
	isInstructionValid_scheduler_1_future4=((is_performing_jump_instant_on && (is_new_instruction_entering_this_cycle_pulse_1 || orderConflictsAdapted[1][jump_executer_index])) || (is_performing_jump_state && is_new_instruction_entering_this_cycle_pulse_1))?1'b0:isInstructionValid_scheduler_1_future3;
	isInstructionValid_scheduler_2_future4=((is_performing_jump_instant_on && (is_new_instruction_entering_this_cycle_pulse_2 || orderConflictsAdapted[2][jump_executer_index])) || (is_performing_jump_state && is_new_instruction_entering_this_cycle_pulse_2))?1'b0:isInstructionValid_scheduler_2_future3;
	isInstructionValid_scheduler_3_future4=((is_performing_jump_instant_on && (is_new_instruction_entering_this_cycle_pulse_3 || orderConflictsAdapted[3][jump_executer_index])) || (is_performing_jump_state && is_new_instruction_entering_this_cycle_pulse_3))?1'b0:isInstructionValid_scheduler_3_future3;
end

always @(posedge main_clk) begin
	orderConflictsSaved<=orderConflictsNextTrue;

	executionConflicts0Saved<=executionConflicts0NextTrue;
	executionConflicts1Saved<=executionConflicts1NextTrue;
	executionConflicts2Saved<=executionConflicts2NextTrue;
end

always_comb begin
	if (debug_scheduler) begin
		executerWillBeEnabled[0]=(isInstructionValid_scheduler_0_future4 && executionConflicts0NextTrue[0]==4'h0 && executionConflicts1NextTrue[0]==4'h0 && executionConflicts2NextTrue[0]==4'h0 && orderConflictsNextTrue[0]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[1]=(isInstructionValid_scheduler_1_future4 && executionConflicts0NextTrue[1]==4'h0 && executionConflicts1NextTrue[1]==4'h0 && executionConflicts2NextTrue[1]==4'h0 && orderConflictsNextTrue[1]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[2]=(isInstructionValid_scheduler_2_future4 && executionConflicts0NextTrue[2]==4'h0 && executionConflicts1NextTrue[2]==4'h0 && executionConflicts2NextTrue[2]==4'h0 && orderConflictsNextTrue[2]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[3]=(isInstructionValid_scheduler_3_future4 && executionConflicts0NextTrue[3]==4'h0 && executionConflicts1NextTrue[3]==4'h0 && executionConflicts2NextTrue[3]==4'h0 && orderConflictsNextTrue[3]==4'h0)?1'b1:1'b0;
	end else begin
		executerWillBeEnabled[0]=(isInstructionValid_scheduler_0_future4 && executionConflicts0NextTrue[0]==4'h0 && executionConflicts1NextTrue[0]==4'h0 && executionConflicts2NextTrue[0]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[1]=(isInstructionValid_scheduler_1_future4 && executionConflicts0NextTrue[1]==4'h0 && executionConflicts1NextTrue[1]==4'h0 && executionConflicts2NextTrue[1]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[2]=(isInstructionValid_scheduler_2_future4 && executionConflicts0NextTrue[2]==4'h0 && executionConflicts1NextTrue[2]==4'h0 && executionConflicts2NextTrue[2]==4'h0)?1'b1:1'b0;
		executerWillBeEnabled[3]=(isInstructionValid_scheduler_3_future4 && executionConflicts0NextTrue[3]==4'h0 && executionConflicts1NextTrue[3]==4'h0 && executionConflicts2NextTrue[3]==4'h0)?1'b1:1'b0;
	end
end



reg [15:0] executingInstructionsSimView [3:0];
reg [15:0] allInstructionsSimView [3:0];

always_comb begin
	if (executerEnable[0]) executingInstructionsSimView[0]=instructionCurrent_scheduler_0_saved;
	else executingInstructionsSimView[0]=16'hx;
	if (executerEnable[1]) executingInstructionsSimView[1]=instructionCurrent_scheduler_1_saved;
	else executingInstructionsSimView[1]=16'hx;
	if (executerEnable[2]) executingInstructionsSimView[2]=instructionCurrent_scheduler_2_saved;
	else executingInstructionsSimView[2]=16'hx;
	if (executerEnable[3]) executingInstructionsSimView[3]=instructionCurrent_scheduler_3_saved;
	else executingInstructionsSimView[3]=16'hx;
	
	allInstructionsSimView[0]=instructionCurrent_scheduler_0_saved;
	allInstructionsSimView[1]=instructionCurrent_scheduler_1_saved;
	allInstructionsSimView[2]=instructionCurrent_scheduler_2_saved;
	allInstructionsSimView[3]=instructionCurrent_scheduler_3_saved;
end




assign debug_instruction_fetch_address=mem_target_address_instruction_fetch;
assign debug_stack_pointer=stack_pointer;
assign debug_user_reg=user_reg;


endmodule