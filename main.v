module mainModule(input clk, input reset);
	
	// Flush / Stall signals
	wire IF_flush, ID_flush, EX_flush; 
	wire pcWrite, p1_pipeline_regWrite;
	wire p2_pipeline_regWrite, p2_pipeline_stall;
	
	
	
	// Forwarding mux selectors
	wire [1:0]  f_mem_reg_rn_sel, f_alu_reg_rm_sel, f_alu_reg_rn_sel;	// Do we need an extra bit for alu_reg_rm ?
	wire f_mem_reg_rd_sel, f_memStage_mem_rd_sel;
	
	
	
	// PC Related
	wire [31:0] p2_pc_branchTarget, pc_jumpTarget; 
	wire [1:0] pcSrc;
	
	
	// IF Related
	wire [15:0] p1_aluInstr, p1_memInstr; // Leaving p1
	wire [31:0] p1_pc_plus4;
	IFStage the_IFStage(
		clk, reset, p1_pipeline_regWrite, IF_flush, 
		pcWrite, 	p2_pc_branchTarget, pc_jumpTarget, 
		pcSrc, // From other stages
		p1_aluInstr, p1_memInstr, p1_pc_plus4
	);
	
	
	
	// Control signals
	wire p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, p2_flag_regWrite;
	wire p2_aluOp, p2_aluSrcB;
	wire p2_isBranch, p2_isJump; 
	// wire [1:0] pcSrc; 	// Declared in IF stage
	
	wire p3_memRead, p3_memWrite, p3_alu_regWrite, p3_mem_regWrite;
	wire p4_alu_regWrite, p4_mem_regWrite;
	
	// Register selectors
	wire [2:0] p2_alu_rm, p2_alu_rn, p2_alu_rd, p2_mem_rn, p2_mem_rd;
	wire [2:0] p3_alu_rd, p3_mem_rd;
	wire [2:0] p4_alu_rd, p4_mem_rd;
	
	// Major data flow
	wire [31:0] p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd; // Shrinking p2_mem_rd in EX instantiation
	wire [31:0] p2_alu_imm, p2_memOffset;
	// wire [31:0] p2_pc_branchTarget, pc_jumpTarget; 			// Declared above near IF stage
	
	wire [7:0] p3_mem_reg_rd;
	wire [31:0] p3_alu_aluOut, p3_mem_address;
	wire [31:0] p4_alu_aluOut, p4_mem_memOut;
		
		
	
	// Forwarded data flow
	wire [31:0] f_mem_reg_rn_1, f_mem_reg_rn_2, f_mem_reg_rn_3;	// forwarding for mem_rn
	wire [7:0] f_mem_reg_rd_1;									// forwarding for mem_rd
	wire [31:0] f_alu_reg_rm_1, f_alu_reg_rm_2, f_alu_reg_rm_3;	// forwarding for alu_rm
	wire [31:0] f_alu_reg_rn_1, f_alu_reg_rn_2, f_alu_reg_rn_3; 	// forwarding for alu_rn
	wire [7:0] f_memStage_mem_reg_rd;	
	
	
	//  Flag register related
	wire flag_z, flag_n, flag_c, flag_v;
	wire p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v;
	wire p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v;
	
	
	
	
	
	IDStage theIDStage(
		clk, reset, p2_pipeline_regWrite, p2_pipeline_stall, // ID_Flush is generated here itself, but p2_stall isn't
		
		p1_aluInstr, p1_memInstr,
		p3_flag_v, p3_flag_n, // p2_isBranch, // Already declared in the pipeline output vars				// Look down
		p4_mem_regWrite, p4_alu_regWrite,
		p4_alu_rd, p4_mem_rd,  
		p4_alu_aluOut, p4_mem_memOut,
		p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v,
		// Our output
		p2_alu_rm, p2_alu_rn, p2_alu_rd, p2_mem_rn, p2_mem_rd, 
		p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd, 
		p2_alu_imm, p2_memOffset, 
		p2_pc_branchTarget, pc_jumpTarget,
		
		//flags
		flag_z, flag_n, flag_c, flag_v, 	// Formality to check flags
		
		
		// Signals
		p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, p2_flag_regWrite,
		p2_aluOp, p2_aluSrcB,
		p2_isBranch, p2_isJump, pcSrc,															// p2_isBranch is here
		
		// Flush signals
		IF_flush, ID_flush, EX_flush
		// output p2_alu_undefinedInstruction, p2_mem_undefinedInstruction, 	// Deprecated
	);
	

	EXStage theEXStage(clk, reset, p3_pipeline_regWrite, EX_flush,

		p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, p2_flag_regWrite,
		p2_aluOp, p2_aluSrcB, 
		// p2_isBranch, p2_isJump, // Not needed
		
		p2_alu_rn, p2_alu_rm, p2_alu_rd, p2_mem_rn, p2_mem_rd,
		p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, 
		p2_mem_reg_rd[7:0],  									// Shrinking it here
		p2_alu_imm, p2_memOffset, 
		
		f_mem_reg_rd_sel, 										// Forwarding mux selectors
		f_mem_reg_rn_sel, f_alu_reg_rm_sel, f_alu_reg_rn_sel,	// Do we need an extra bit for alu_reg_rm ?
		f_mem_reg_rn_1, f_mem_reg_rn_2, f_mem_reg_rn_3,	// forwarding for mem_rn
		f_mem_reg_rd_1,									// forwarding for mem_rd
		f_alu_reg_rm_1, f_alu_reg_rm_2, f_alu_reg_rm_3,	// forwarding for alu_rm
		f_alu_reg_rn_1, f_alu_reg_rn_2, f_alu_reg_rn_3, 	// forwarding for alu_rn
		
		
		p3_memRead, p3_memWrite, p3_alu_regWrite, p3_mem_regWrite,
		p3_alu_rd, p3_mem_rd,
		p3_mem_reg_rd,
		p3_alu_aluOut, p3_mem_address,
		p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v
	);

	
	// MEM stage
	MEMStage theMEMStage( 
		clk, reset, 1'b1,
		
		p3_alu_regWrite, p3_mem_regWrite,
		p3_alu_rd, p3_mem_rd,
		p3_mem_reg_rd, 
		p3_alu_aluOut, p3_mem_address,
		
		f_memStage_mem_rd_sel,
		f_memStage_mem_reg_rd[7:0],
		
		p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v,
		
		p4_alu_regWrite, p4_mem_regWrite,
		p4_alu_rd, p4_mem_rd,
		p4_alu_aluOut,
		p4_mem_memOut,
		p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v
		
	);


	// Forwarding unit
	forwarding_unit the_forwarding_unit(
		p3_alu_regWrite, p4_alu_regWrite, p4_mem_regWrite, p2_alu_regWrite,
		// input [4:0] p1_aluOpcode,input [4:0] p1_memOpcode,  input [4:0] p2_aluOpcode,input [4:0] p2_memOpcode, // Not needed
		p4_mem_rd, p4_alu_rd, 
		p3_alu_rd,
		p2_mem_rd, p2_alu_rm ,
		p2_alu_rn, p2_mem_rn,
		
		f_alu_reg_rn_sel , f_alu_reg_rm_sel, f_mem_reg_rn_sel, f_mem_reg_rd_sel, f_memStage_mem_rd_sel // ,output reg [1:0] N_flag_mux); // Deprecated
	); 	
	
	// Hazard detection;	
	 hazard_detection the_hazard_detection(
		p3_mem_regWrite, p3_mem_rd,
		p2_alu_rm, p2_alu_rn, p2_mem_rn,
		pcWrite, p1_pipeline_regWrite, p2_pipeline_stall
	);	

endmodule
