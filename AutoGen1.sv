
wire [32:0] dependencyCalculationTemporary0 [3:0];
wire [32:0] dependencyCalculationTemporary1 [7:0];
wire [32:0] dependencyCalculationTemporary2 [1:0];
generate
genvar regIterationVar;
for (regIterationVar=0;regIterationVar<33;regIterationVar=regIterationVar+1) begin : generated
if (regIterationVar!=16 && regIterationVar!=17) begin
	if (selfIndex==3'd0) begin
		lcell dependency_lc_0(.in((isAfter[4] & dependOtherRegWrite[4][regIterationVar])),.out(dependencyCalculationTemporary0[0][regIterationVar]));
		lcell dependency_lc_1(.in(dependencyCalculationTemporary1[2][regIterationVar]|dependencyCalculationTemporary1[4][regIterationVar]|dependencyCalculationTemporary1[6][regIterationVar]|dependencyCalculationTemporary2[1][regIterationVar]),.out(dependencyCalculationTemporary2[0][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd1 || selfIndex==3'd2 || selfIndex==3'd3 || selfIndex==3'd4 || selfIndex==3'd5 || selfIndex==3'd6) begin
		lcell dependency_lc_2(.in(isAfter[7] & (dependOtherRegRead[7][regIterationVar] | dependOtherRegWrite[7][regIterationVar])),.out(dependencyCalculationTemporary1[7][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd1 || selfIndex==3'd2 || selfIndex==3'd3 || selfIndex==3'd4 || selfIndex==3'd5 || selfIndex==3'd6 || selfIndex==3'd7) begin
		lcell dependency_lc_3(.in(dependencyCalculationTemporary0[0][regIterationVar]|dependencyCalculationTemporary0[1][regIterationVar]|dependencyCalculationTemporary0[2][regIterationVar]|dependencyCalculationTemporary0[3][regIterationVar]),.out(readBlockedByDepend[regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd1 || selfIndex==3'd2 || selfIndex==3'd3 || selfIndex==3'd4 || selfIndex==3'd5 || selfIndex==3'd7) begin
		lcell dependency_lc_4(.in(isAfter[6] & (dependOtherRegRead[6][regIterationVar] | dependOtherRegWrite[6][regIterationVar])),.out(dependencyCalculationTemporary1[6][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd1 || selfIndex==3'd2 || selfIndex==3'd3 || selfIndex==3'd4 || selfIndex==3'd6 || selfIndex==3'd7) begin
		lcell dependency_lc_5(.in(isAfter[5] & (dependOtherRegRead[5][regIterationVar] | dependOtherRegWrite[5][regIterationVar])),.out(dependencyCalculationTemporary1[5][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd1 || selfIndex==3'd2 || selfIndex==3'd3 || selfIndex==3'd5 || selfIndex==3'd6 || selfIndex==3'd7) begin
		lcell dependency_lc_6(.in(isAfter[4] & (dependOtherRegRead[4][regIterationVar] | dependOtherRegWrite[4][regIterationVar])),.out(dependencyCalculationTemporary1[4][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd1 || selfIndex==3'd2 || selfIndex==3'd4 || selfIndex==3'd5 || selfIndex==3'd6) begin
		lcell dependency_lc_7(.in((isAfter[3] & dependOtherRegWrite[3][regIterationVar])|(isAfter[7] & dependOtherRegWrite[7][regIterationVar])),.out(dependencyCalculationTemporary0[3][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd1 || selfIndex==3'd2 || selfIndex==3'd4 || selfIndex==3'd5 || selfIndex==3'd6 || selfIndex==3'd7) begin
		lcell dependency_lc_8(.in(isAfter[3] & (dependOtherRegRead[3][regIterationVar] | dependOtherRegWrite[3][regIterationVar])),.out(dependencyCalculationTemporary1[3][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd1 || selfIndex==3'd3 || selfIndex==3'd4 || selfIndex==3'd5 || selfIndex==3'd6 || selfIndex==3'd7) begin
		lcell dependency_lc_9(.in(isAfter[2] & (dependOtherRegRead[2][regIterationVar] | dependOtherRegWrite[2][regIterationVar])),.out(dependencyCalculationTemporary1[2][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd1 || selfIndex==3'd3 || selfIndex==3'd4 || selfIndex==3'd5 || selfIndex==3'd7) begin
		lcell dependency_lc_10(.in((isAfter[2] & dependOtherRegWrite[2][regIterationVar])|(isAfter[6] & dependOtherRegWrite[6][regIterationVar])),.out(dependencyCalculationTemporary0[2][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd2 || selfIndex==3'd3 || selfIndex==3'd4 || selfIndex==3'd5 || selfIndex==3'd6 || selfIndex==3'd7) begin
		lcell dependency_lc_11(.in(isAfter[1] & (dependOtherRegRead[1][regIterationVar] | dependOtherRegWrite[1][regIterationVar])),.out(dependencyCalculationTemporary1[1][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd2 || selfIndex==3'd3 || selfIndex==3'd4 || selfIndex==3'd6 || selfIndex==3'd7) begin
		lcell dependency_lc_12(.in((isAfter[1] & dependOtherRegWrite[1][regIterationVar])|(isAfter[5] & dependOtherRegWrite[5][regIterationVar])),.out(dependencyCalculationTemporary0[1][regIterationVar]));
	end
	if (selfIndex==3'd0 || selfIndex==3'd2 || selfIndex==3'd4 || selfIndex==3'd6) begin
		lcell dependency_lc_13(.in(dependencyCalculationTemporary1[1][regIterationVar]|dependencyCalculationTemporary1[3][regIterationVar]|dependencyCalculationTemporary1[5][regIterationVar]|dependencyCalculationTemporary1[7][regIterationVar]),.out(dependencyCalculationTemporary2[1][regIterationVar]));
	end
	if (selfIndex==3'd1) begin
		lcell dependency_lc_14(.in((isAfter[5] & dependOtherRegWrite[5][regIterationVar])),.out(dependencyCalculationTemporary0[1][regIterationVar]));
		lcell dependency_lc_15(.in(dependencyCalculationTemporary1[3][regIterationVar]|dependencyCalculationTemporary1[5][regIterationVar]|dependencyCalculationTemporary1[7][regIterationVar]|dependencyCalculationTemporary2[0][regIterationVar]),.out(dependencyCalculationTemporary2[1][regIterationVar]));
	end
	if (selfIndex==3'd1 || selfIndex==3'd2 || selfIndex==3'd3 || selfIndex==3'd4 || selfIndex==3'd5 || selfIndex==3'd6 || selfIndex==3'd7) begin
		lcell dependency_lc_16(.in(isAfter[0] & (dependOtherRegRead[0][regIterationVar] | dependOtherRegWrite[0][regIterationVar])),.out(dependencyCalculationTemporary1[0][regIterationVar]));
	end
	if (selfIndex==3'd1 || selfIndex==3'd2 || selfIndex==3'd3 || selfIndex==3'd5 || selfIndex==3'd6 || selfIndex==3'd7) begin
		lcell dependency_lc_17(.in((isAfter[0] & dependOtherRegWrite[0][regIterationVar])|(isAfter[4] & dependOtherRegWrite[4][regIterationVar])),.out(dependencyCalculationTemporary0[0][regIterationVar]));
	end
	if (selfIndex==3'd1 || selfIndex==3'd3 || selfIndex==3'd5 || selfIndex==3'd7) begin
		lcell dependency_lc_18(.in(dependencyCalculationTemporary1[0][regIterationVar]|dependencyCalculationTemporary1[2][regIterationVar]|dependencyCalculationTemporary1[4][regIterationVar]|dependencyCalculationTemporary1[6][regIterationVar]),.out(dependencyCalculationTemporary2[0][regIterationVar]));
	end
	if (selfIndex==3'd2) begin
		lcell dependency_lc_19(.in((isAfter[6] & dependOtherRegWrite[6][regIterationVar])),.out(dependencyCalculationTemporary0[2][regIterationVar]));
		lcell dependency_lc_20(.in(dependencyCalculationTemporary1[0][regIterationVar]|dependencyCalculationTemporary1[4][regIterationVar]|dependencyCalculationTemporary1[6][regIterationVar]|dependencyCalculationTemporary2[1][regIterationVar]),.out(dependencyCalculationTemporary2[0][regIterationVar]));
	end
	if (selfIndex==3'd3) begin
		lcell dependency_lc_21(.in((isAfter[7] & dependOtherRegWrite[7][regIterationVar])),.out(dependencyCalculationTemporary0[3][regIterationVar]));
		lcell dependency_lc_22(.in(dependencyCalculationTemporary1[1][regIterationVar]|dependencyCalculationTemporary1[5][regIterationVar]|dependencyCalculationTemporary1[7][regIterationVar]|dependencyCalculationTemporary2[0][regIterationVar]),.out(dependencyCalculationTemporary2[1][regIterationVar]));
	end
	if (selfIndex==3'd4) begin
		lcell dependency_lc_23(.in((isAfter[0] & dependOtherRegWrite[0][regIterationVar])),.out(dependencyCalculationTemporary0[0][regIterationVar]));
		lcell dependency_lc_24(.in(dependencyCalculationTemporary1[0][regIterationVar]|dependencyCalculationTemporary1[2][regIterationVar]|dependencyCalculationTemporary1[6][regIterationVar]|dependencyCalculationTemporary2[1][regIterationVar]),.out(dependencyCalculationTemporary2[0][regIterationVar]));
	end
	if (selfIndex==3'd5) begin
		lcell dependency_lc_25(.in((isAfter[1] & dependOtherRegWrite[1][regIterationVar])),.out(dependencyCalculationTemporary0[1][regIterationVar]));
		lcell dependency_lc_26(.in(dependencyCalculationTemporary1[1][regIterationVar]|dependencyCalculationTemporary1[3][regIterationVar]|dependencyCalculationTemporary1[7][regIterationVar]|dependencyCalculationTemporary2[0][regIterationVar]),.out(dependencyCalculationTemporary2[1][regIterationVar]));
	end
	if (selfIndex==3'd6) begin
		lcell dependency_lc_27(.in((isAfter[2] & dependOtherRegWrite[2][regIterationVar])),.out(dependencyCalculationTemporary0[2][regIterationVar]));
		lcell dependency_lc_28(.in(dependencyCalculationTemporary1[0][regIterationVar]|dependencyCalculationTemporary1[2][regIterationVar]|dependencyCalculationTemporary1[4][regIterationVar]|dependencyCalculationTemporary2[1][regIterationVar]),.out(dependencyCalculationTemporary2[0][regIterationVar]));
	end
	if (selfIndex==3'd7) begin
		lcell dependency_lc_29(.in((isAfter[3] & dependOtherRegWrite[3][regIterationVar])),.out(dependencyCalculationTemporary0[3][regIterationVar]));
		lcell dependency_lc_30(.in(dependencyCalculationTemporary1[1][regIterationVar]|dependencyCalculationTemporary1[3][regIterationVar]|dependencyCalculationTemporary1[5][regIterationVar]|dependencyCalculationTemporary2[0][regIterationVar]),.out(dependencyCalculationTemporary2[1][regIterationVar]));
	end
end end
if (selfIndex==3'd0 || selfIndex==3'd2 || selfIndex==3'd4 || selfIndex==3'd6) begin
	assign writeBlockedByDepend[32:18]=dependencyCalculationTemporary2[0][32:18];
	assign writeBlockedByDepend[15: 0]=dependencyCalculationTemporary2[0][15: 0];
	assign writeBlockedByDepend[32:18]=dependencyCalculationTemporary2[0][32:18];
	assign writeBlockedByDepend[15: 0]=dependencyCalculationTemporary2[0][15: 0];
	assign writeBlockedByDepend[32:18]=dependencyCalculationTemporary2[0][32:18];
	assign writeBlockedByDepend[15: 0]=dependencyCalculationTemporary2[0][15: 0];
	assign writeBlockedByDepend[32:18]=dependencyCalculationTemporary2[0][32:18];
	assign writeBlockedByDepend[15: 0]=dependencyCalculationTemporary2[0][15: 0];
end
if (selfIndex==3'd1 || selfIndex==3'd3 || selfIndex==3'd5 || selfIndex==3'd7) begin
	assign writeBlockedByDepend[32:18]=dependencyCalculationTemporary2[1][32:18];
	assign writeBlockedByDepend[15: 0]=dependencyCalculationTemporary2[1][15: 0];
	assign writeBlockedByDepend[32:18]=dependencyCalculationTemporary2[1][32:18];
	assign writeBlockedByDepend[15: 0]=dependencyCalculationTemporary2[1][15: 0];
	assign writeBlockedByDepend[32:18]=dependencyCalculationTemporary2[1][32:18];
	assign writeBlockedByDepend[15: 0]=dependencyCalculationTemporary2[1][15: 0];
	assign writeBlockedByDepend[32:18]=dependencyCalculationTemporary2[1][32:18];
	assign writeBlockedByDepend[15: 0]=dependencyCalculationTemporary2[1][15: 0];
end
endgenerate
