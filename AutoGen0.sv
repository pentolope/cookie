
wire [1:0] lookup0 [23:0];
wire [4:0] lookup1 [95:0];
assign lookup0[0]=0;
assign lookup1[0]=18;
assign lookup1[1]=12;
assign lookup1[2]=6;
assign lookup1[3]=0;
assign lookup0[1]=1;
assign lookup1[4]=18;
assign lookup1[5]=12;
assign lookup1[6]=7;
assign lookup1[7]=1;
assign lookup0[2]=0;
assign lookup1[8]=19;
assign lookup1[9]=12;
assign lookup1[10]=6;
assign lookup1[11]=2;
assign lookup0[3]=2;
assign lookup1[12]=19;
assign lookup1[13]=13;
assign lookup1[14]=6;
assign lookup1[15]=3;
assign lookup0[4]=1;
assign lookup1[16]=18;
assign lookup1[17]=13;
assign lookup1[18]=7;
assign lookup1[19]=4;
assign lookup0[5]=2;
assign lookup1[20]=19;
assign lookup1[21]=13;
assign lookup1[22]=7;
assign lookup1[23]=5;
assign lookup0[6]=0;
assign lookup1[24]=20;
assign lookup1[25]=14;
assign lookup1[26]=6;
assign lookup1[27]=0;
assign lookup0[7]=1;
assign lookup1[28]=20;
assign lookup1[29]=14;
assign lookup1[30]=7;
assign lookup1[31]=1;
assign lookup0[8]=0;
assign lookup1[32]=21;
assign lookup1[33]=14;
assign lookup1[34]=8;
assign lookup1[35]=0;
assign lookup0[9]=3;
assign lookup1[36]=21;
assign lookup1[37]=15;
assign lookup1[38]=9;
assign lookup1[39]=0;
assign lookup0[10]=1;
assign lookup1[40]=20;
assign lookup1[41]=15;
assign lookup1[42]=10;
assign lookup1[43]=1;
assign lookup0[11]=3;
assign lookup1[44]=21;
assign lookup1[45]=15;
assign lookup1[46]=11;
assign lookup1[47]=1;
assign lookup0[12]=0;
assign lookup1[48]=22;
assign lookup1[49]=12;
assign lookup1[50]=8;
assign lookup1[51]=2;
assign lookup0[13]=2;
assign lookup1[52]=22;
assign lookup1[53]=13;
assign lookup1[54]=8;
assign lookup1[55]=3;
assign lookup0[14]=0;
assign lookup1[56]=23;
assign lookup1[57]=14;
assign lookup1[58]=8;
assign lookup1[59]=2;
assign lookup0[15]=3;
assign lookup1[60]=23;
assign lookup1[61]=15;
assign lookup1[62]=9;
assign lookup1[63]=2;
assign lookup0[16]=2;
assign lookup1[64]=22;
assign lookup1[65]=16;
assign lookup1[66]=9;
assign lookup1[67]=3;
assign lookup0[17]=3;
assign lookup1[68]=23;
assign lookup1[69]=17;
assign lookup1[70]=9;
assign lookup1[71]=3;
assign lookup0[18]=1;
assign lookup1[72]=18;
assign lookup1[73]=16;
assign lookup1[74]=10;
assign lookup1[75]=4;
assign lookup0[19]=2;
assign lookup1[76]=19;
assign lookup1[77]=16;
assign lookup1[78]=10;
assign lookup1[79]=5;
assign lookup0[20]=1;
assign lookup1[80]=20;
assign lookup1[81]=17;
assign lookup1[82]=10;
assign lookup1[83]=4;
assign lookup0[21]=3;
assign lookup1[84]=21;
assign lookup1[85]=17;
assign lookup1[86]=11;
assign lookup1[87]=4;
assign lookup0[22]=2;
assign lookup1[88]=22;
assign lookup1[89]=16;
assign lookup1[90]=11;
assign lookup1[91]=5;
assign lookup0[23]=3;
assign lookup1[92]=23;
assign lookup1[93]=17;
assign lookup1[94]=11;
assign lookup1[95]=5;
assign least_used_index_calc=lookup0[raw_perm_out];
assign raw_perm_in=lookup1[{raw_perm_out,used_index_delayed}];
