`timescale 1 ps / 1 ps


`include "internal_memory.sv"
`include "vga_driver.sv"
`include "instruction_cache.sv"
`include "scheduler.sv"
`include "core_executer.sv"


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

reg [15:0] stack_pointer=16'h0000;
reg [15:0] stack_pointer_m2=16'hFFFE;
reg [15:0] stack_pointer_m4=16'hFFFC;
reg [15:0] stack_pointer_m6=16'hFFFA;
reg [15:0] stack_pointer_m8=16'hFFF8;

reg [15:0] stack_pointer_p2=16'h0002;
reg [15:0] stack_pointer_p4=16'h0004;

reg [15:0] user_reg [15:0]='{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};


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

wire [3:0] memory_dependency_clear;

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
wire [15:0] new_instruction_table [3:0];
wire [25:0] new_instruction_address_table [3:0];

wire [4:0] fifo_instruction_cache_size;
wire [4:0] fifo_instruction_cache_size_after_read;
wire [2:0] fifo_instruction_cache_consume_count;


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
	new_instruction_table,
	new_instruction_address_table,
	
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


wire [4:0] new_instructionID_table [3:0];
assign new_instructionID_table[0]=(& new_instruction_table[0][15:12])?{1'b1,new_instruction_table[0][11:8]}:{1'b0,new_instruction_table[0][15:12]};
assign new_instructionID_table[1]=(& new_instruction_table[1][15:12])?{1'b1,new_instruction_table[1][11:8]}:{1'b0,new_instruction_table[1][15:12]};
assign new_instructionID_table[2]=(& new_instruction_table[2][15:12])?{1'b1,new_instruction_table[2][11:8]}:{1'b0,new_instruction_table[2][15:12]};
assign new_instructionID_table[3]=(& new_instruction_table[3][15:12])?{1'b1,new_instruction_table[3][11:8]}:{1'b0,new_instruction_table[3][15:12]};

wire [15:0] instructionCurrent_scheduler [3:0];
wire [4:0] instructionCurrentID_scheduler [3:0];

wire [25:0] current_instruction_address_table [3:0];

wire executerEnable [3:0];
wire executerWillBeEnabled [3:0];

wire is_instruction_finishing_this_cycle_pulse_0;
wire is_instruction_finishing_this_cycle_pulse_1;
wire is_instruction_finishing_this_cycle_pulse_2;
wire is_instruction_finishing_this_cycle_pulse_3;

wire will_instruction_finish_next_cycle_pulse_0;
wire will_instruction_finish_next_cycle_pulse_1;
wire will_instruction_finish_next_cycle_pulse_2;
wire will_instruction_finish_next_cycle_pulse_3;


scheduler scheduler_inst(
	executerEnable,
	executerWillBeEnabled,
	instructionCurrent_scheduler,
	instructionCurrentID_scheduler,
	current_instruction_address_table,
	fifo_instruction_cache_size_after_read,
	fifo_instruction_cache_consume_count,
	
	is_performing_jump_instant_on,
	is_performing_jump_state,
	jump_executer_index,
	fifo_instruction_cache_size,
	new_instruction_table,
	new_instructionID_table,
	new_instruction_address_table,
	memory_dependency_clear,
	'{is_instruction_finishing_this_cycle_pulse_3,is_instruction_finishing_this_cycle_pulse_2,is_instruction_finishing_this_cycle_pulse_1,is_instruction_finishing_this_cycle_pulse_0},
	'{ will_instruction_finish_next_cycle_pulse_3, will_instruction_finish_next_cycle_pulse_2, will_instruction_finish_next_cycle_pulse_1, will_instruction_finish_next_cycle_pulse_0},
	debug_scheduler,
	main_clk
);


core_executer core_executer_inst0(
	instructionCurrent_scheduler[0],
	instructionCurrentID_scheduler[0],
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
	instructionCurrent_scheduler[1],
	instructionCurrentID_scheduler[1],
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
	instructionCurrent_scheduler[2],
	instructionCurrentID_scheduler[2],
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
	instructionCurrent_scheduler[3],
	instructionCurrentID_scheduler[3],
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



assign debug_instruction_fetch_address=mem_target_address_instruction_fetch;
assign debug_stack_pointer=stack_pointer;
assign debug_user_reg=user_reg;


endmodule
