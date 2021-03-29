`timescale 1 ps / 1 ps

module dependancy_generation(
	input [15:0] new_instruction,
	
	output [4:0] new_instructionID_extern,
	output [16:0] generatedDependSelfRegRead_extern,
	output [16:0] generatedDependSelfRegWrite_extern,
	output [2:0] generatedDependSelfSpecial_extern
);

reg [16:0] generatedDependSelfRegRead;
reg [16:0] generatedDependSelfRegWrite;
reg [2:0] generatedDependSelfSpecial;  // .[0]=jump  , .[1]=mem read  , .[2]=mem write

reg [4:0] new_instructionID;
reg [4:0] new_instructionIDc;
always_comb new_instructionID=(& new_instruction[15:12])?{1'b1,new_instruction[11:8]}:{1'b0,new_instruction[15:12]};
lcell_5 lc_id(new_instructionIDc,new_instructionID);
assign new_instructionID_extern=new_instructionIDc;

lcell_17 lc_read(generatedDependSelfRegRead_extern,generatedDependSelfRegRead);
lcell_17 lc_write(generatedDependSelfRegWrite_extern,generatedDependSelfRegWrite);
lcell_3 lc_special(generatedDependSelfSpecial_extern,generatedDependSelfSpecial);

always_comb begin
	generatedDependSelfRegRead=0;
	generatedDependSelfRegWrite=0;
	generatedDependSelfSpecial=0;
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
		generatedDependSelfRegRead=17'hx;
		generatedDependSelfRegWrite=17'hx;
		generatedDependSelfSpecial=2'hx;
	end
	5'h10:begin
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegRead[16]=1'b1;
		generatedDependSelfRegWrite[16]=1'b1;
		generatedDependSelfSpecial[2]=1'b1;
	end
	5'h11:begin
		generatedDependSelfRegRead[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegRead[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[16]=1'b1;
		generatedDependSelfRegWrite[16]=1'b1;
		generatedDependSelfSpecial[2]=1'b1;
	end
	5'h12:begin
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegRead[16]=1'b1;
		generatedDependSelfRegWrite[16]=1'b1;
		generatedDependSelfSpecial[1]=1'b1;
	end
	5'h13:begin
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegWrite[new_instruction[7:4]]=1'b1;
		generatedDependSelfRegRead[16]=1'b1;
		generatedDependSelfRegWrite[16]=1'b1;
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
		generatedDependSelfRegRead[16]=1'b1;
		generatedDependSelfRegWrite[0]=1'b1;
		generatedDependSelfRegWrite[16]=1'b1;
		generatedDependSelfSpecial[0]=1'b1;
		generatedDependSelfSpecial[2]=1'b1;
	end
	5'h1B:begin
		generatedDependSelfRegRead[0]=1'b1;
		generatedDependSelfRegWrite[0]=1'b1;
		generatedDependSelfRegWrite[1]=1'b1;
		generatedDependSelfRegWrite[16]=1'b1;
		generatedDependSelfSpecial[0]=1'b1;
		generatedDependSelfSpecial[1]=1'b1;
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
		generatedDependSelfRegRead[16]=1'b1;
		generatedDependSelfRegWrite[new_instruction[3:0]]=1'b1;
		generatedDependSelfRegWrite[16]=1'b1;
	end
	endcase
	//generatedDependSelfRegRead=17'h1FFFF; // temp
end


endmodule
