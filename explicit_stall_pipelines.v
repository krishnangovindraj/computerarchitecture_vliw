module pipleline_IF_ID( 
	input clk, input reset, input global_regWrite, input IF_flush, input stall,
	input [31:0] instr2Word, 
	output [15:0] p1_aluInstr, output [15:0] p1_memInstr );
	
	wire regWrite;
	assign regWrite = global_regWrite && ~stall;
	
	register16bit reg_aluInstr(clk, reset | IF_flush, regWrite , instr2Word[15:0], p1_aluInstr);
	register16bit reg_memInstr(clk, reset | IF_flush, regWrite , instr2Word[31:16], p1_memInstr);
endmodule

module pipeline_ID_EX( 
		input clk, input reset, input global_regWrite, input ID_Flush, input stall,
		input [2:0] alu_rn, alu_rm, alu_rd, mem_rn, mem_rd,
		output [2:0] p2_alu_rn, p2_alu_rm, p2_alu_rd, p2_mem_rn, p2_mem_rd,
		
		input [31:0] alu_reg_rm, alu_reg_rn, mem_reg_rn, mem_reg_rd, 
		output [31:0] p2_alu_reg_rm, p2_alu_reg_rns, p2_mem_reg_rn, p2_mem_reg_rd, 
		
		input [31:0] alu_sextImm3, mem_sextImm5,
		output [31:0] p2_alu_sextImm3, p2_mem_sextImm5,
		
		
		// signals in
		input memRead, memWrite, alu_regWrite, mem_regWrite,
		input aluOp, aluSrcB,
		input isBranch, isJump,
		input alu_undefinedInstruction, mem_undefinedInstruction,
		// signals out
		output p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite,
		output p2_aluOp, p2_aluSrcB,
		output p2_isBranch, p2_isJump,
		output p2_alu_undefinedInstruction, p2_mem_undefinedInstruction
	);
	
	wire regWrite;
	assign regWrite = global_regWrite && ~stall;
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
	
	// Signals
	register1bit  reg_memRead( clk, reset | ID_flush | stall, regWrite, 1'b1, memRead, p2_memRead);
	register1bit  reg_memWrite( clk, reset | ID_flush | stall, regWrite, 1'b1, memWrite, p2_memWrite);
	register1bit  reg_alu_regWrite( clk, reset | ID_flush | stall, regWrite, 1'b1, alu_regWrite, p2_alu_regWrite);
	register1bit  reg_mem_regWrite( clk, reset | ID_flush | stall, regWrite, 1'b1, mem_regWrite, p2_mem_regWrite);
	
	register1bit  reg_aluOp( clk, reset | ID_flush | stall, regWrite, 1'b1, aluOp, p2_aluOp);
	register1bit  reg_aluSrcB( clk, reset | ID_flush | stall, regWrite, 1'b1, aluSrcB, p2_aluSrcB);
	
	register1bit  reg_isBranch( clk, reset | ID_flush | stall, regWrite, 1'b1, isBranch, p2_isBranch);
	register1bit  reg_isJump( clk, reset | ID_flush | stall, regWrite, 1'b1, isJump, p2_isJump);
	
	register1bit  reg_flagWrite( clk, reset | ID_flush | stall, regWrite, 1'b1, flagWrite, p2_flagWrite);
	
	// Deprecated
	//register1bit  reg_alu_undefinedInstruction( clk, reset | ID_flush, regWrite, 1'b1, alu_undefinedInstruction, p2_alu_undefinedInstruction );
	//register1bit  reg_mem_undefinedInstruction( clk, reset | ID_flush, regWrite, 1'b1, mem_undefinedInstruction, p2_mem_undefinedInstruction );
	
endmodule


module pipeline_EX_MEM( 
	input clk, reset, global_regWrite, EX_flush, stall,
	
	input [2:0] alu_rd, mem_rd,
	input [31:0] aluOut, mem_reg_rd, mem_address,
		
		
	output [2:0] p3_alu_rd, p3_mem_rd,
	output [31:0] p3_alu_aluOut, p3_mem_reg_rd, p3_mem_address
);
	wire regWrite;
	assign regWrite = global_regWrite && ~stall;
	
	register3bit reg_alu_rd( clk, reset || EX_flush, regWrite, 1'b1, alu_rd, p3_alu_rd );
	register3bit reg_mem_rd( clk, reset || EX_flush, regWrite, 1'b1, mem_rd, p3_mem_rd );
	
	
	register32bit reg_alu_aluOut( clk, reset || EX_flush, regWrite, 1'b1, alu_aluOut, p3_alu_aluOut );
	register32bit reg_mem_reg_rd( clk, reset || EX_flush, regWrite, 1'b1, mem_reg_rd, p3_mem_reg_rd );
	register32bit reg_mem_address( clk, reset || EX_flush, regWrite, 1'b1, mem_address, p3_mem_address );
	
endmodule

module pipeline_MEM_WB(
		input clk, reset, global_regWrite, stall,
		
		input [2:0]  alu_rd, mem_rd,
		input [31:0] alu_aluOut, 
		input [31:0] mem_out,
		
		output [2:0] p4_alu_rd, p4_mem_rd,
		output [31:0] p4_alu_aluOut, 
		output [31:0] p4_mem_out
);
	wire regWrite;
	assign regWrite = global_regWrite && ~stall;
	
	register3bit reg_alu_rd( clk, reset, regWrite, 1'b1, alu_rd, p4_alu_rd );
	register3bit reg_mem_rd( clk, reset, regWrite, 1'b1, mem_rd, p4_mem_rd );
	
	register32bit reg_alu_aluOut( clk, reset, regWrite, 1'b1, alu_aluOut, p4_alu_aluOut );
	register32bit reg_mem_out( clk, reset, regWrite, 1'b1, mem_out, p4_mem_out );
	
endmodule
