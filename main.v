module mainModule(input clk, input reset);
	
	wire [31:0] instr2Word; 				// Leaving IF
	wire [31:0] branchTarget, jumpTarget;	// Entering IF from ID
	wire [15:0] p1_alu_instr, p1_mem_instr; // Leaving p1
	

	// Control signals
	wire memRead, memWrite, alu_regWrite, mem_regWrite;
	wire output aluOp, output aluSrcB;
	wire isBranch, isJump;
	wire alu_undefinedInstruction, mem_undefinedInstruction;
	
	
	IFStage ifStage(
		clk, reset, // From outside world
		pcWrite, 	branchTarget, jumpTarget, // From other stages
		input p2_isBranch, p2_alu_flag_N, isJump, isException, // OR the two
		output [31:0] instr2Word
	);
	
	
endmodule
