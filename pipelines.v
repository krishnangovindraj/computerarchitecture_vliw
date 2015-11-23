module pipleline_IF_ID( 
		input clk, input reset, input regWrite, input IF_flush,
		input [31:0] instr2Word, input [31:0] pc_plus4, 
		output [15:0] p1_aluInstr, output [15:0] p1_memInstr, output [31:0] p1_pc_plus4
	);
	register16bit reg_aluInstr(clk, reset | IF_flush, regWrite, 1'b1, instr2Word[15:0], p1_aluInstr);
	register16bit reg_memInstr(clk, reset | IF_flush, regWrite, 1'b1, instr2Word[31:16], p1_memInstr);
	register32bit reg_pc_plus4(clk, reset | IF_flush, regWrite, 1'b1, pc_plus4 , p1_pc_plus4);
endmodule

module pipeline_ID_EX( 
		input clk, input reset, input regWrite, input ID_flush, input p2_pipeline_stall,
		input [2:0] alu_rn, alu_rm, alu_rd, mem_rn, mem_rd,
		output [2:0] p2_alu_rn, p2_alu_rm, p2_alu_rd, p2_mem_rn, p2_mem_rd,
		
		input [31:0] alu_reg_rm, alu_reg_rn, mem_reg_rn, mem_reg_rd, 
		output [31:0] p2_alu_reg_rm, p2_alu_reg_rns, p2_mem_reg_rn, p2_mem_reg_rd, 
		
		input [31:0] alu_sextImm3, mem_sextImm5,
		output [31:0] p2_alu_sextImm3, p2_mem_sextImm5,
		
		// signals in
		input memRead, memWrite, alu_regWrite, mem_regWrite, flag_regWrite,
		input aluOp, aluSrcB,
		input isBranch, isJump, pcSrc,
		// signals out
		output p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, p2_flag_regWrite,
		output p2_aluOp, p2_aluSrcB,
		output p2_isBranch, p2_isJump, p2_pcSrc
	);
	
	wire signal_reset = reset | ID_flush | p2_pipeline_stall;
	
	
	register3bit reg_alu_rn( clk, reset, regWrite, 1'b1, alu_rn, p2_alu_rn );
	register3bit reg_alu_rm( clk, reset, regWrite, 1'b1, alu_rm, p2_alu_rm );
	register3bit reg_alu_rd( clk, reset, regWrite, 1'b1, alu_rd, p2_alu_rd );
	
	register3bit reg_mem_rn( clk, reset, regWrite, 1'b1, mem_rn, p2_mem_rn );
	register3bit reg_mem_rd( clk, reset, regWrite, 1'b1, mem_rd, p2_mem_rd );
	
	
	register32bit reg_alu_reg_rn( clk, reset, regWrite, 1'b1, alu_reg_rn, p2_alu_reg_rn );
	register32bit reg_alu_reg_rm( clk, reset, regWrite, 1'b1, alu_reg_rm, p2_alu_reg_rm );
	
	register32bit reg_mem_reg_rn( clk, reset, regWrite, 1'b1, mem_reg_rn, p2_mem_reg_rn );
	register32bit reg_mem_reg_rd( clk, reset, regWrite, 1'b1, mem_reg_rd, p2_mem_reg_rd );
	
	
	register32bit reg_alu_sextImm3( clk, reset, regWrite, 1'b1, alu_sextImm3, p2_alu_sextImm3 );
	register32bit reg_mem_sextImm5( clk, reset, regWrite, 1'b1, mem_sextImm5, p2_mem_sextImm5 );
	register32bit reg_mem_sextImm8( clk, reset, regWrite, 1'b1, mem_sextImm8, p2_mem_sextImm8 );
	
	// Signals // ID_flush resets only the signals.
	register1bit  reg_memRead( clk, signal_reset, regWrite, 1'b1, memRead, p2_memRead);
	register1bit  reg_memWrite( clk, signal_reset, regWrite, 1'b1, memWrite, p2_memWrite);
	register1bit  reg_alu_regWrite( clk, signal_reset, regWrite, 1'b1, alu_regWrite, p2_alu_regWrite);
	register1bit  reg_mem_regWrite( clk, signal_reset, regWrite, 1'b1, mem_regWrite, p2_mem_regWrite);
	register1bit  reg_mem_flag_regWrite( clk, signal_reset, regWrite, 1'b1, flag_regWrite, p2_flag_regWrite);
	
	register1bit  reg_aluOp( clk, signal_reset, regWrite, 1'b1, aluOp, p2_aluOp);
	register1bit  reg_aluSrcB( clk, signal_reset, regWrite, 1'b1, aluSrcB, p2_aluSrcB);
	
	register1bit  reg_isBranch( clk, signal_reset, regWrite, 1'b1, isBranch, p2_isBranch);
	register1bit  reg_isJump( clk, signal_reset, regWrite, 1'b1, isJump, p2_isJump);
	
	register1bit  reg_flagWrite( clk, signal_reset, regWrite, 1'b1, flagWrite, p2_flagWrite);
	
	// Deprecated
	//register1bit  reg_alu_undefinedInstruction( clk, reset | ID_flush, regWrite, 1'b1, alu_undefinedInstruction, p2_alu_undefinedInstruction );
	//register1bit  reg_mem_undefinedInstruction( clk, reset | ID_flush, regWrite, 1'b1, mem_undefinedInstruction, p2_mem_undefinedInstruction );
	
endmodule


module pipeline_EX_MEM( 
	input clk, reset, regWrite, EX_flush,
	
	input p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, p2_flag_regWrite,
	input [2:0] alu_rd, mem_rd,
	input [31:0] aluOut, mem_reg_rd, mem_address,
	input alu_flag_z, alu_flag_n, alu_flag_c, alu_flag_v,
	
	output p3_memRead, p3_memWrite, p3_alu_regWrite, p3_mem_regWrite,
	output [2:0] p3_alu_rd, p3_mem_rd,
	output [31:0] p3_alu_aluOut, p3_mem_reg_rd, p3_mem_address,
	output p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v
);
	
	// Signals 
	register1bit  reg_memRead( clk, reset, regWrite, 1'b1, p2_memRead, p3_memRead );
	register1bit  reg_memWrite( clk, reset, regWrite, 1'b1, p2_memWrite, p3_memWrite);
	register1bit  reg_alu_regWrite( clk, reset, regWrite, 1'b1, p2_alu_regWrite, p3_alu_regWrite);
	register1bit  reg_mem_regWrite( clk, reset, regWrite, 1'b1, p2_mem_regWrite, p3_mem_regWrite);
	
	
	register3bit reg_alu_rd( clk, reset | EX_flush, regWrite, 1'b1, alu_rd, p3_alu_rd );
	register3bit reg_mem_rd( clk, reset | EX_flush, regWrite, 1'b1, mem_rd, p3_mem_rd );
	
	
	register32bit reg_alu_aluOut( clk, reset | EX_flush, regWrite, 1'b1, alu_aluOut, p3_alu_aluOut );
	register32bit reg_mem_reg_rd( clk, reset | EX_flush, regWrite, 1'b1, mem_reg_rd, p3_mem_reg_rd );
	register32bit reg_mem_address( clk, reset | EX_flush, regWrite, 1'b1, mem_address, p3_mem_address );
	
	register1bit reg_flag_z( clk, reset, regWrite & p2_flag_regWrite & EX_Flush , 1'b1, alu_flag_z, p3_flag_z); // All 3 &
	register1bit reg_flag_n( clk, reset, regWrite & p2_flag_regWrite & EX_Flush , 1'b1, alu_flag_n, p3_flag_n); // All 3 &
	register1bit reg_flag_c( clk, reset, regWrite & p2_flag_regWrite & EX_Flush , 1'b1, alu_flag_c, p3_flag_c); // All 3 &
	register1bit reg_flag_v( clk, reset, regWrite & p2_flag_regWrite & EX_Flush , 1'b1, alu_flag_v, p3_flag_v); // All 3 &
	
endmodule

module pipeline_MEM_WB(
		input clk, reset, regWrite,
		
		input p3_alu_regWrite, p3_mem_regWrite,
		input [2:0]  alu_rd, mem_rd,
		input [31:0] alu_aluOut, mem_memOut,
		input p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v,
		
		output p4_alu_regWrite, p4_mem_regWrite,
		output [2:0] p4_alu_rd, p4_mem_rd,
		output [31:0] p4_alu_aluOut, p4_mem_memOut,
		output p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v
);
	
	register1bit  reg_alu_regWrite( clk, reset, regWrite, 1'b1, p3_alu_regWrite, p4_alu_regWrite);
	register1bit  reg_mem_regWrite( clk, reset, regWrite, 1'b1, p3_mem_regWrite, p4_mem_regWrite);
	
	register3bit reg_alu_rd( clk, reset, regWrite, 1'b1, alu_rd, p4_alu_rd );
	register3bit reg_mem_rd( clk, reset, regWrite, 1'b1, mem_rd, p4_mem_rd );
	
	register32bit reg_alu_aluOut( clk, reset, regWrite, 1'b1, alu_aluOut, p4_alu_aluOut );
	register32bit reg_mem_memOut( clk, reset, regWrite, 1'b1, mem_memOut, p4_mem_memOut );
	
	// Flag registers
	register1bit reg_flag_z( clk, reset, regWrite , 1'b1, p3_flag_z, p4_flag_z); // Here, just regWrite is enough. Little hacky, i know.
	register1bit reg_flag_n( clk, reset, regWrite , 1'b1, p3_flag_n, p4_flag_n); // Here, just regWrite is enough
	register1bit reg_flag_c( clk, reset, regWrite , 1'b1, p3_flag_c, p4_flag_c); // Here, just regWrite is enough
	register1bit reg_flag_v( clk, reset, regWrite , 1'b1, p3_flag_v, p4_flag_v); // Here, just regWrite is enough
	
endmodule
