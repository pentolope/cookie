`timescale 1 ps / 1 ps

module dependancy_generation(
	input [15:0] new_instruction,
	input [15:0] rename_state_in,
	
	output [15:0] rename_state_out_extern,
	output [4:0] new_instructionID_extern,
	output [31:0] generatedDependSelfRegRead_extern,
	output [31:0] generatedDependSelfRegWrite_extern,
	output generatedDependSelfStackPointer_extern,
	output [2:0] generatedDependSelfSpecial_extern
);

reg [15:0] generatedDependSelfRegRead;
reg [15:0] generatedDependSelfRegWrite;
reg generatedDependSelfStackPointer;
reg [2:0] generatedDependSelfSpecial;  // .[0]=jump  , .[1]=mem read  , .[2]=mem write

reg [31:0] generatedDependSelfRegReadRenamed;
reg [31:0] generatedDependSelfRegWriteRenamed;
reg [15:0] rename_state_out;

reg [4:0] new_instructionID;
reg [4:0] new_instructionIDc;
always_comb new_instructionID=(& new_instruction[15:12])?{1'b1,new_instruction[11:8]}:{1'b0,new_instruction[15:12]};
lcells #(5) lc_id(new_instructionIDc,new_instructionID);
assign new_instructionID_extern=new_instructionIDc;

assign generatedDependSelfRegRead_extern[17:16]=2'd0;
assign generatedDependSelfRegWrite_extern[17:16]=2'd0;

lcells #(16) lc_read0(generatedDependSelfRegRead_extern[15:0],generatedDependSelfRegReadRenamed[15:0]);
lcells #(14) lc_read1(generatedDependSelfRegRead_extern[31:18],generatedDependSelfRegReadRenamed[31:18]);
lcells #(16) lc_write0(generatedDependSelfRegWrite_extern[15:0],generatedDependSelfRegWriteRenamed[15:0]);
lcells #(14) lc_write1(generatedDependSelfRegWrite_extern[31:18],generatedDependSelfRegWriteRenamed[31:18]);

lcells #(3) lc_special(generatedDependSelfSpecial_extern,generatedDependSelfSpecial);
lcells #(14) lc_rename(rename_state_out_extern[15:2],rename_state_out[15:2]);
assign rename_state_out_extern[1:0]=2'd0;

lcells #(1) lc_stack_pointer(generatedDependSelfStackPointer_extern,generatedDependSelfStackPointer);

always_comb begin
	generatedDependSelfRegRead=0;
	generatedDependSelfRegWrite=0;
	generatedDependSelfSpecial=0;
	generatedDependSelfStackPointer=0;
	case (new_instructionIDc)
	5'h00:begin
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h01:begin
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h02:begin
		generatedDependSelfRegRead[1]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
		generatedDependSelfSpecial[1]=1'b1;
	end
	5'h03:begin
		generatedDependSelfRegRead[1]=1'b1;
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfSpecial[2]=1'b1;
	end
	5'h04:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h05:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h06:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h07:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h08:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
		generatedDependSelfSpecial[1]=1'b1;
	end
	5'h09:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfSpecial[2]=1'b1;
	end
	5'h0A:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h0B:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[15]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegWrite[15]=1'b1;
	end
	5'h0C:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h0D:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h0E:begin
		generatedDependSelfRegRead[new_instruction[11:8]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfSpecial[0]=1'b1;
	end
	5'h0F:begin // this is not actually possible
		generatedDependSelfRegRead=16'hx;
		generatedDependSelfRegWrite=16'hx;
		generatedDependSelfSpecial=2'hx;
	end
	5'h10:begin
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfStackPointer=1'b1;
		generatedDependSelfSpecial[2]=1'b1;
	end
	5'h11:begin
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfStackPointer=1'b1;
		generatedDependSelfSpecial[2]=1'b1;
	end
	5'h12:begin
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
		generatedDependSelfStackPointer=1'b1;
		generatedDependSelfSpecial[1]=1'b1;
	end
	5'h13:begin
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[7:4]]=1'b1;
		generatedDependSelfStackPointer=1'b1;
		generatedDependSelfSpecial[1]=1'b1;
	end
	5'h14:begin
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h15:begin
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h16:begin
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h17:begin
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h18:begin
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegRead[13]=1'b1;
		generatedDependSelfRegRead[14]=1'b1;
		generatedDependSelfRegWrite[13]=1'b1;
		generatedDependSelfRegWrite[14]=1'b1;
	end
	5'h19:begin
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
	end
	5'h1A:begin
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegRead[0]=1'b1;
		generatedDependSelfRegRead[1]=1'b1;
		generatedDependSelfRegWrite[0]=1'b1;
		generatedDependSelfSpecial[0]=1'b1;
		generatedDependSelfSpecial[2]=1'b1;
		generatedDependSelfStackPointer=1'b1;
	end
	5'h1B:begin
		generatedDependSelfRegRead[0]=1'b1;
		generatedDependSelfRegWrite[0]=1'b1;
		generatedDependSelfRegWrite[1]=1'b1;
		generatedDependSelfSpecial[0]=1'b1;
		generatedDependSelfSpecial[1]=1'b1;
		generatedDependSelfStackPointer=1'b1; // this introduces a false dependency. the return instruction does not need to read the stack pointer. it does need to write however, and due to now things work, this should have no performance downsides
	end
	5'h1C:begin
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[13]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
		generatedDependSelfSpecial[1]=1'b1;
	end
	5'h1D:begin
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[13]=1'b1;
		generatedDependSelfSpecial[2]=1'b1;
	end
	5'h1E:begin
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfSpecial[0]=1'b1;
	end
	5'h1F:begin
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
		generatedDependSelfStackPointer=1'b1;
	end
	endcase
end


always_comb begin
	// register 0 does not deserve renaming capability because of how it is typically used
	generatedDependSelfRegReadRenamed[16]=1'b0;
	generatedDependSelfRegWriteRenamed[16]=1'b0;
	generatedDependSelfRegReadRenamed[0]=generatedDependSelfRegRead[0];
	generatedDependSelfRegWriteRenamed[0]=generatedDependSelfRegWrite[0];
	rename_state_out[0]= rename_state_in[0];
end

always_comb begin
	// register 1 does not deserve renaming capability because of how it is typically used
	generatedDependSelfRegReadRenamed[17]=1'b0;
	generatedDependSelfRegWriteRenamed[17]=1'b0;
	generatedDependSelfRegReadRenamed[1]=generatedDependSelfRegRead[1];
	generatedDependSelfRegWriteRenamed[1]=generatedDependSelfRegWrite[1];
	rename_state_out[1]= rename_state_in[1];
end

always_comb begin
	generatedDependSelfRegReadRenamed[2]=1'b0;generatedDependSelfRegReadRenamed[18]=1'b0;
	generatedDependSelfRegWriteRenamed[2]=1'b0;generatedDependSelfRegWriteRenamed[18]=1'b0;
	if (rename_state_in[2])
		generatedDependSelfRegReadRenamed[18]=generatedDependSelfRegRead[2];
	else
		generatedDependSelfRegReadRenamed[2]=generatedDependSelfRegRead[2];
	if (generatedDependSelfRegWrite[2] && !generatedDependSelfRegRead[2])
		rename_state_out[2]=!rename_state_in[2];
	else
		rename_state_out[2]= rename_state_in[2];
	if (rename_state_out[2])
		generatedDependSelfRegWriteRenamed[18]=generatedDependSelfRegWrite[2];
	else
		generatedDependSelfRegWriteRenamed[2]=generatedDependSelfRegWrite[2];
end

always_comb begin
	generatedDependSelfRegReadRenamed[3]=1'b0;generatedDependSelfRegReadRenamed[19]=1'b0;
	generatedDependSelfRegWriteRenamed[3]=1'b0;generatedDependSelfRegWriteRenamed[19]=1'b0;
	if (rename_state_in[3])
		generatedDependSelfRegReadRenamed[19]=generatedDependSelfRegRead[3];
	else
		generatedDependSelfRegReadRenamed[3]=generatedDependSelfRegRead[3];
	if (generatedDependSelfRegWrite[3] && !generatedDependSelfRegRead[3])
		rename_state_out[3]=!rename_state_in[3];
	else
		rename_state_out[3]= rename_state_in[3];
	if (rename_state_out[3])
		generatedDependSelfRegWriteRenamed[19]=generatedDependSelfRegWrite[3];
	else
		generatedDependSelfRegWriteRenamed[3]=generatedDependSelfRegWrite[3];
end

always_comb begin
	generatedDependSelfRegReadRenamed[4]=1'b0;generatedDependSelfRegReadRenamed[20]=1'b0;
	generatedDependSelfRegWriteRenamed[4]=1'b0;generatedDependSelfRegWriteRenamed[20]=1'b0;
	if (rename_state_in[4])
		generatedDependSelfRegReadRenamed[20]=generatedDependSelfRegRead[4];
	else
		generatedDependSelfRegReadRenamed[4]=generatedDependSelfRegRead[4];
	if (generatedDependSelfRegWrite[4] && !generatedDependSelfRegRead[4])
		rename_state_out[4]=!rename_state_in[4];
	else
		rename_state_out[4]= rename_state_in[4];
	if (rename_state_out[4])
		generatedDependSelfRegWriteRenamed[20]=generatedDependSelfRegWrite[4];
	else
		generatedDependSelfRegWriteRenamed[4]=generatedDependSelfRegWrite[4];
end

always_comb begin
	generatedDependSelfRegReadRenamed[5]=1'b0;generatedDependSelfRegReadRenamed[21]=1'b0;
	generatedDependSelfRegWriteRenamed[5]=1'b0;generatedDependSelfRegWriteRenamed[21]=1'b0;
	if (rename_state_in[5])
		generatedDependSelfRegReadRenamed[21]=generatedDependSelfRegRead[5];
	else
		generatedDependSelfRegReadRenamed[5]=generatedDependSelfRegRead[5];
	if (generatedDependSelfRegWrite[5] && !generatedDependSelfRegRead[5])
		rename_state_out[5]=!rename_state_in[5];
	else
		rename_state_out[5]= rename_state_in[5];
	if (rename_state_out[5])
		generatedDependSelfRegWriteRenamed[21]=generatedDependSelfRegWrite[5];
	else
		generatedDependSelfRegWriteRenamed[5]=generatedDependSelfRegWrite[5];
end

always_comb begin
	generatedDependSelfRegReadRenamed[6]=1'b0;generatedDependSelfRegReadRenamed[22]=1'b0;
	generatedDependSelfRegWriteRenamed[6]=1'b0;generatedDependSelfRegWriteRenamed[22]=1'b0;
	if (rename_state_in[6])
		generatedDependSelfRegReadRenamed[22]=generatedDependSelfRegRead[6];
	else
		generatedDependSelfRegReadRenamed[6]=generatedDependSelfRegRead[6];
	if (generatedDependSelfRegWrite[6] && !generatedDependSelfRegRead[6])
		rename_state_out[6]=!rename_state_in[6];
	else
		rename_state_out[6]= rename_state_in[6];
	if (rename_state_out[6])
		generatedDependSelfRegWriteRenamed[22]=generatedDependSelfRegWrite[6];
	else
		generatedDependSelfRegWriteRenamed[6]=generatedDependSelfRegWrite[6];
end

always_comb begin
	generatedDependSelfRegReadRenamed[7]=1'b0;generatedDependSelfRegReadRenamed[23]=1'b0;
	generatedDependSelfRegWriteRenamed[7]=1'b0;generatedDependSelfRegWriteRenamed[23]=1'b0;
	if (rename_state_in[7])
		generatedDependSelfRegReadRenamed[23]=generatedDependSelfRegRead[7];
	else
		generatedDependSelfRegReadRenamed[7]=generatedDependSelfRegRead[7];
	if (generatedDependSelfRegWrite[7] && !generatedDependSelfRegRead[7])
		rename_state_out[7]=!rename_state_in[7];
	else
		rename_state_out[7]= rename_state_in[7];
	if (rename_state_out[7])
		generatedDependSelfRegWriteRenamed[23]=generatedDependSelfRegWrite[7];
	else
		generatedDependSelfRegWriteRenamed[7]=generatedDependSelfRegWrite[7];
end

always_comb begin
	generatedDependSelfRegReadRenamed[8]=1'b0;generatedDependSelfRegReadRenamed[24]=1'b0;
	generatedDependSelfRegWriteRenamed[8]=1'b0;generatedDependSelfRegWriteRenamed[24]=1'b0;
	if (rename_state_in[8])
		generatedDependSelfRegReadRenamed[24]=generatedDependSelfRegRead[8];
	else
		generatedDependSelfRegReadRenamed[8]=generatedDependSelfRegRead[8];
	if (generatedDependSelfRegWrite[8] && !generatedDependSelfRegRead[8])
		rename_state_out[8]=!rename_state_in[8];
	else
		rename_state_out[8]= rename_state_in[8];
	if (rename_state_out[8])
		generatedDependSelfRegWriteRenamed[24]=generatedDependSelfRegWrite[8];
	else
		generatedDependSelfRegWriteRenamed[8]=generatedDependSelfRegWrite[8];
end

always_comb begin
	generatedDependSelfRegReadRenamed[9]=1'b0;generatedDependSelfRegReadRenamed[25]=1'b0;
	generatedDependSelfRegWriteRenamed[9]=1'b0;generatedDependSelfRegWriteRenamed[25]=1'b0;
	if (rename_state_in[9])
		generatedDependSelfRegReadRenamed[25]=generatedDependSelfRegRead[9];
	else
		generatedDependSelfRegReadRenamed[9]=generatedDependSelfRegRead[9];
	if (generatedDependSelfRegWrite[9] && !generatedDependSelfRegRead[9])
		rename_state_out[9]=!rename_state_in[9];
	else
		rename_state_out[9]= rename_state_in[9];
	if (rename_state_out[9])
		generatedDependSelfRegWriteRenamed[25]=generatedDependSelfRegWrite[9];
	else
		generatedDependSelfRegWriteRenamed[9]=generatedDependSelfRegWrite[9];
end

always_comb begin
	generatedDependSelfRegReadRenamed[10]=1'b0;generatedDependSelfRegReadRenamed[26]=1'b0;
	generatedDependSelfRegWriteRenamed[10]=1'b0;generatedDependSelfRegWriteRenamed[26]=1'b0;
	if (rename_state_in[10])
		generatedDependSelfRegReadRenamed[26]=generatedDependSelfRegRead[10];
	else
		generatedDependSelfRegReadRenamed[10]=generatedDependSelfRegRead[10];
	if (generatedDependSelfRegWrite[10] && !generatedDependSelfRegRead[10])
		rename_state_out[10]=!rename_state_in[10];
	else
		rename_state_out[10]= rename_state_in[10];
	if (rename_state_out[10])
		generatedDependSelfRegWriteRenamed[26]=generatedDependSelfRegWrite[10];
	else
		generatedDependSelfRegWriteRenamed[10]=generatedDependSelfRegWrite[10];
end

always_comb begin
	generatedDependSelfRegReadRenamed[11]=1'b0;generatedDependSelfRegReadRenamed[27]=1'b0;
	generatedDependSelfRegWriteRenamed[11]=1'b0;generatedDependSelfRegWriteRenamed[27]=1'b0;
	if (rename_state_in[11])
		generatedDependSelfRegReadRenamed[27]=generatedDependSelfRegRead[11];
	else
		generatedDependSelfRegReadRenamed[11]=generatedDependSelfRegRead[11];
	if (generatedDependSelfRegWrite[11] && !generatedDependSelfRegRead[11])
		rename_state_out[11]=!rename_state_in[11];
	else
		rename_state_out[11]= rename_state_in[11];
	if (rename_state_out[11])
		generatedDependSelfRegWriteRenamed[27]=generatedDependSelfRegWrite[11];
	else
		generatedDependSelfRegWriteRenamed[11]=generatedDependSelfRegWrite[11];
end

always_comb begin
	generatedDependSelfRegReadRenamed[12]=1'b0;generatedDependSelfRegReadRenamed[28]=1'b0;
	generatedDependSelfRegWriteRenamed[12]=1'b0;generatedDependSelfRegWriteRenamed[28]=1'b0;
	if (rename_state_in[12])
		generatedDependSelfRegReadRenamed[28]=generatedDependSelfRegRead[12];
	else
		generatedDependSelfRegReadRenamed[12]=generatedDependSelfRegRead[12];
	if (generatedDependSelfRegWrite[12] && !generatedDependSelfRegRead[12])
		rename_state_out[12]=!rename_state_in[12];
	else
		rename_state_out[12]= rename_state_in[12];
	if (rename_state_out[12])
		generatedDependSelfRegWriteRenamed[28]=generatedDependSelfRegWrite[12];
	else
		generatedDependSelfRegWriteRenamed[12]=generatedDependSelfRegWrite[12];
end

always_comb begin
	generatedDependSelfRegReadRenamed[13]=1'b0;generatedDependSelfRegReadRenamed[29]=1'b0;
	generatedDependSelfRegWriteRenamed[13]=1'b0;generatedDependSelfRegWriteRenamed[29]=1'b0;
	if (rename_state_in[13])
		generatedDependSelfRegReadRenamed[29]=generatedDependSelfRegRead[13];
	else
		generatedDependSelfRegReadRenamed[13]=generatedDependSelfRegRead[13];
	if (generatedDependSelfRegWrite[13] && !generatedDependSelfRegRead[13])
		rename_state_out[13]=!rename_state_in[13];
	else
		rename_state_out[13]= rename_state_in[13];
	if (rename_state_out[13])
		generatedDependSelfRegWriteRenamed[29]=generatedDependSelfRegWrite[13];
	else
		generatedDependSelfRegWriteRenamed[13]=generatedDependSelfRegWrite[13];
end

always_comb begin
	generatedDependSelfRegReadRenamed[14]=1'b0;generatedDependSelfRegReadRenamed[30]=1'b0;
	generatedDependSelfRegWriteRenamed[14]=1'b0;generatedDependSelfRegWriteRenamed[30]=1'b0;
	if (rename_state_in[14])
		generatedDependSelfRegReadRenamed[30]=generatedDependSelfRegRead[14];
	else
		generatedDependSelfRegReadRenamed[14]=generatedDependSelfRegRead[14];
	if (generatedDependSelfRegWrite[14] && !generatedDependSelfRegRead[14])
		rename_state_out[14]=!rename_state_in[14];
	else
		rename_state_out[14]= rename_state_in[14];
	if (rename_state_out[14])
		generatedDependSelfRegWriteRenamed[30]=generatedDependSelfRegWrite[14];
	else
		generatedDependSelfRegWriteRenamed[14]=generatedDependSelfRegWrite[14];
end

always_comb begin
	generatedDependSelfRegReadRenamed[15]=1'b0;generatedDependSelfRegReadRenamed[31]=1'b0;
	generatedDependSelfRegWriteRenamed[15]=1'b0;generatedDependSelfRegWriteRenamed[31]=1'b0;
	if (rename_state_in[15])
		generatedDependSelfRegReadRenamed[31]=generatedDependSelfRegRead[15];
	else
		generatedDependSelfRegReadRenamed[15]=generatedDependSelfRegRead[15];
	if (generatedDependSelfRegWrite[15] && !generatedDependSelfRegRead[15])
		rename_state_out[15]=!rename_state_in[15];
	else
		rename_state_out[15]= rename_state_in[15];
	if (rename_state_out[15])
		generatedDependSelfRegWriteRenamed[31]=generatedDependSelfRegWrite[15];
	else
		generatedDependSelfRegWriteRenamed[15]=generatedDependSelfRegWrite[15];
end

endmodule
