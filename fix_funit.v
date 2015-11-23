// p2_alu_regWrite, 
module forwarding_unit(
		input p3_alu_regWrite, input p4_alu_regWrite, input p4_mem_regWrite,input p2_alu_regWrite,input [4:0] p1_aluOpcode,input [4:0] p1_memOpcode,
		input [4:0] p2_aluOpcode,input [4:0] p2_memOpcode,input [2:0] p4_opcodeM_rd /* I[7:5] */ , input [2:0] p4_opcodeA_rd /* I[25:23] */, 
		input [2:0] p3_opcodeA_rd /* I[25:23] */, input [2:0] p2_opcodeM_rd /* I[7:5] */ ,input [2:0] p2_opcodeA_rm /* I[31:29] */ ,
		input [2:0] p2_opcodeA_rn /* I[28:26] */ ,input [2:0] p2_opcodeM_rn /* I[10:8] */ ,
		output reg [1:0] fA , output reg [1:0] fB, output reg [1:0] fC, output reg fD, output reg fE,output reg [1:0] N_flag_mux
	);
	
	
endmodule
