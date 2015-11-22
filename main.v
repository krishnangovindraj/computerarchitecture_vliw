module mainModule(input clk, input reset);
	
	wire [31:0] instr2Word; 				// Leaving IF
	wire [31:0] branchTarget, jumpTarget;	// Entering IF from ID
	wire [31:0] p4_alu_writeData;
	wire [15:0] p1_alu_instr, p1_mem_instr; // Leaving p1
	wire [2:0] p2_alu_rm, p2_alu_rn, p2_alu_rd, p2_mem_rn, p2_mem_rd;
	wire [31:0] p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd;
	wire [31:0] p2_alu_sext3_imm, p2_mem_sext5_memOffset, p2_mem_shiftedSext8_branchOffset, mem_shiftedSext11_jumpOffset;		


	// pretty much just copying what was in EX module here and removing input and all


	wire f_mem_reg_rd_sel; 										// Forwarding mux selectors
	wire [1:0]  f_mem_reg_rn_sel, f_alu_reg_rm_sel, f_alu_reg_rn_sel;	// Do we need an extra bit for alu_reg_rm ?
	wire [31:0] f_mem_reg_rn_1, f_mem_reg_rn_2, f_mem_reg_rn_3;	// forwarding for mem_rn
	wire [31:0] f_mem_reg_rd_1;								// forwarding for mem_rd
	wire [31:0] f_alu_reg_rm_1, f_alu_reg_rm_2, f_alu_reg_rm_3;	// forwarding for alu_rm
	wire [31:0] f_alu_reg_rn_1, f_alu_reg_rn_2, f_alu_reg_rn_3; 	// forwarding for alu_rn
		
		
	wire [2:0] p3_alu_rd, p3_mem_rd;
	wire [7:0] p3_mem_reg_rd;
	wire [31:0] p3_alu_aluOut, p3_mem_address;

	// Control signals
	wire memRead, memWrite, alu_regWrite, mem_regWrite, p1_pipeline_regWrite, pcWrite;
	wire p2_pipeline_regWrite,  p2_alu_flag_N;
	wire p4_mem_regWrite, p4_alu_regWrite, p4_mem_writeData;
	wire p2_aluOp, p2_aluSrcB;
	wire p2_isBranch, p2_isJump, isException;
	wire p2_alu_undefinedInstruction, p2_mem_undefinedInstruction;


	// MEM stuff 


	wire f_mem_address_sel;
	wire [31:0] f_mem_address;
		
	wire [2:0] p4_alu_rd, p4_mem_rd;
	wire [31:0] p4_alu_aluOut;
	wire [31:0] p4_mem_out;
	
	IFStage ifstage(
		// From outside world
		clk, reset, p1_pipeline_regWrite,
		// From other stages
		pcWrite, branchTarget,jumpTarget, 
		isBranch, p2_alu_flag_N, isJump, isException, // OR the two
		p1_aluInstr, p1_memInstr
	);

	IDStage idstage(
		clk, reset, p2_pipeline_regWrite,
		
		p1_aluInstr, p1_memInstr,
		p4_mem_regWrite, p4_alu_regWrite, p4_alu_writeData, p4_mem_writeData,
	
		// Our output
		p2_alu_rm, p2_alu_rn, p2_alu_rd, p2_mem_rn, p2_mem_rd, 
		p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd, 
		p2_alu_sext3_imm, p2_mem_sext5_memOffset, p2_mem_shiftedSext8_branchOffset, 		
		mem_shiftedSext11_jumpOffset,
		
		
		// Signals
		p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite,
		p2_aluOp, p2_aluSrcB,
		p2_isBranch, p2_isJump,
		p2_alu_undefinedInstruction, p2_mem_undefinedInstruction
	);
	EXStage exstage(clk, reset, 

		p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, 
		p2_aluOp, p2_aluSrcB, 
		p2_isBranch, p2_isJump,
		p2_alu_rn, p2_alu_rm, p2_alu_rd, p2_mem_rn, p2_mem_rd,
		p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd, 
		p2_alu_sextImm3, p2_mem_sextImm5,
		
		f_mem_reg_rd_sel, 										// Forwarding mux selectors
		f_mem_reg_rn_sel, f_alu_reg_rm_sel, f_alu_reg_rn_sel,	// Do we need an extra bit for alu_reg_rm ?
		f_mem_reg_rn_1, f_mem_reg_rn_2, f_mem_reg_rn_3,	// forwarding for mem_rn
		f_mem_reg_rd_1,									// forwarding for mem_rd
		f_alu_reg_rm_1, f_alu_reg_rm_2, f_alu_reg_rm_3,	// forwarding for alu_rm
		f_alu_reg_rn_1, f_alu_reg_rn_2, f_alu_reg_rn_3, 	// forwarding for alu_rn
		
		
		p3_alu_rd, p3_mem_rd,
		p3_mem_reg_rd, 
		p3_alu_aluOut, p3_mem_address
	);
	MEMStage memstage( 
		clk, reset,
		
		p3_alu_rd, p3_mem_rd,
		p3_mem_reg_rd, 
		p3_alu_aluOut, p3_mem_address,
		
		f_mem_address_sel,
		f_mem_address,
		
		p4_alu_rd, p4_mem_rd,
		p4_alu_aluOut, 
		p4_mem_out
	);
	
			

endmodule
