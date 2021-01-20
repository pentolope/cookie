`timescale 1 ps / 1 ps


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
module lcell_19(output [18:0] o,input  [18:0] i);
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
