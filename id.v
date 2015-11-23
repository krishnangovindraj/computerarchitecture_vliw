module IDStage(
		input clk, input reset, input p2_pipeline_regWrite, input p2_pipeline_stall, // ID_Flush is generated here itself, but p2_stall isn't
		
		input [15:0] p1_aluInstr, p1_memInstr,
		input p3_flag_v, p3_flag_n, // p2_isBranch, // Already declared in the pipeline output vars				// Look down
		input p4_mem_regWrite, p4_alu_regWrite, input [31:0] p4_alu_writeData, p4_mem_writeData,
		input p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v,
		// Our output
		output [2:0] p2_alu_rm, p2_alu_rn, p2_alu_rd, p2_mem_rn, p2_mem_rd, 
		output [31:0] p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd, 
		output [31:0] p2_alu_sext3_imm, p2_mem_sext5_memOffset, p2_mem_shiftedSext8_branchOffset, 		
		output [31:0] mem_shiftedSext11_jumpOffset,
		
		output flag_z, flag_n, flag_c, flag_v, 	// Formality to check flags
		
		
		// Signals
		output p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, p2_flag_regWrite,
		output p2_aluOp, p2_aluSrcB,
		output p2_isBranch, p2_isJump, output reg [1:0] pcSrc,														// p2_isBranch is here
		
		// Flush signals
		output IF_flush, output reg ID_flush, output reg EX_flush
		// output p2_alu_undefinedInstruction, p2_mem_undefinedInstruction, 	// Deprecated
	);
	// ID Stage
	
	// Branch & Jump targets
	wire [31:0] mem_sext11_jumpOffset, mem_sext8_branchOffset;
	wire [31:0] mem_shiftedSext8_branchOffset; // , mem_shiftedSext11_jumpOffset; // Straight output
	
	
	signExt11to32 mem_signExt11( p1_memInstr[15:5], mem_sext11_jumpOffset );
	signExt8to32 mem_signExt8( p1_memInstr[15:8], mem_sext8_branchOffset );
	
	assign mem_shiftedSext11_jumpOffset = {mem_sext11_jumpOffset[30:0],1'b0};
	assign mem_shiftedSext8_branchOffset = {mem_sext8_branchOffset[30:0],1'b0};	
	
	
	// Control circuit signals
	wire memRead, memWrite, alu_regWrite, mem_regWrite, flag_regWrite;
	wire aluOp, aluSrcB; 
	wire isBranch, isJump;
	wire alu_undefinedInstruction, mem_undefinedInstruction;
	
	controlCircuit ctrlCkt(
		p1_aluInstr[6:0] , p1_memInstr[4:0],
		p3_flag_v, p3_flag_n, p2_isBranch,
		
		memRead, memWrite, alu_regWrite, mem_regWrite, flag_regWrite,
		aluOp, aluSrcB, 
		isBranch, isJump, pcSrc,
		IF_flush, ID_flush, EX_flush
	);
	
	// Flag register
	flagRegister4bit flag_register( clk, reset, 
		p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v,
		flag_z, flag_n, flag_c, flag_v
	);

	// Register files
	wire [31:0] alu_reg_rm, alu_reg_rn, mem_reg_rn, mem_reg_rd;
	
	registerFile rFile( clk, reset, 
		mem_regWrite, p1_memInstr[10:8], p1_memInstr[7:5], mem_writeData,
		alu_regWrite, p1_aluInstr[15:13], p1_aluInstr[12:10], p1_aluInstr[9:7], alu_writeData,
	
		mem_reg_rn, mem_reg_rd, 
		alu_reg_rm, alu_reg_rn
	);
	
	// Sign extended mem address & Immediate data
	signExt3to32 alu_signExt3( p1_aluInstr[15:13], alu_sext3_imm );
	signExt5to32 mem_signExt5( p1_memInstr[15:13], mem_sext5_memOffset );
	
	
	pipeline_ID_EX p2( 
		clk, reset, p2_pipeline_regWrite, ID_Flush, p2_pipeline_stall,
		p1_aluInstr[15:13], p1_aluInstr[12:10], p1_aluInstr[9:7], p1_memInstr[10:8], p1_memInstr[7:5],	// input
		p2_alu_rm, p2_alu_rn, p2_alu_rd, p2_mem_rn, p2_mem_rd,											// output
		
		alu_reg_rm, alu_reg_rn, mem_reg_rn, mem_reg_rd, 							// input
		p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd, 				// output
		
		alu_sext3_imm, mem_sext5_memOffset, 			// input
		p2_alu_sext3_imm, p2_mem_sext5_memOffset, 		// output
		
		
		// signals in
		
		memRead, memWrite, alu_regWrite, mem_regWrite, flag_regWrite,
		aluOp, aluSrcB, 
		isBranch, isJump, pcSrc,
		// signals out
		p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, p2_flag_regWrite,
		p2_aluOp, p2_aluSrcB,
		p2_isBranch, p2_isJump, p2_pcSrc
	);
	
endmodule
