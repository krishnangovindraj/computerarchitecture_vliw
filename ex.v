module EXStage(input clk, input reset, input p3_pipeline_regWrite, input EX_flush,

		input p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, p2_flag_regWrite,
		input p2_aluOp, p2_aluSrcB, 
		// input p2_isBranch, p2_isJump, // Not needed
		
		
		input [2:0] p2_alu_rn, p2_alu_rm, p2_alu_rd, p2_mem_rn, p2_mem_rd,
		input [31:0] p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd, 
		input [31:0] p2_alu_sextImm3, p2_mem_sextImm5,
		
		input 		 f_mem_reg_rd_sel, 										// Forwarding mux selectors
		input [1:0]  f_mem_reg_rn_sel, f_alu_reg_rm_sel, f_alu_reg_rn_sel,	// Do we need an extra bit for alu_reg_rm ?
		input [31:0] f_mem_reg_rn_1, f_mem_reg_rn_2, f_mem_reg_rn_3,	// forwarding for mem_rn
		input [31:0] f_mem_reg_rd_1,									// forwarding for mem_rd
		input [31:0] f_alu_reg_rm_1, f_alu_reg_rm_2, f_alu_reg_rm_3,	// forwarding for alu_rm
		input [31:0] f_alu_reg_rn_1, f_alu_reg_rn_2, f_alu_reg_rn_3, 	// forwarding for alu_rn
		
		
		output p3_memRead, p3_memWrite, p3_alu_regWrite, p3_mem_regWrite,
		output [2:0] p3_alu_rd, p3_mem_rd,
		output [7:0] p3_mem_reg_rd,
		output [31:0] p3_alu_aluOut, p3_mem_address,
		output p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v
);
	// MEM line
	wire [31:0] selected_mem_reg_rn;
	mux4to1_32bit mux_mem_reg_rn( p2_mem_reg_rn, f_mem_reg_rn_1, f_mem_reg_rn_2, f_mem_reg_rn_3, f_mem_reg_rn_sel, selected_mem_reg_rn );
	
	wire [7:0] selected_mem_reg_rd;
	mux2to1_32bit mux_mem_reg_rd( p2_mem_reg_rd, f_mem_reg_rd_1, f_mem_reg_rd_sel, selected_mem_reg_rd );
	
	wire [31:0] mem_address;
	adder32bit memAddressAdder(p2_mem_sextImm5, selected_mem_reg_rn, mem_address);
	
	// ALU line
	wire [31:0] aluIn1;
	mux4to1_32bit mux_alu_reg_rn( p2_alu_reg_rn, f_alu_reg_rn_1, f_alu_reg_rn_2, f_alu_reg_rn_3, f_alu_reg_rn_sel, aluIn1 );
	
	wire [31:0] selected_alu_reg_rm;
	wire [31:0] aluIn2;
	mux4to1_32bit mux_alu_reg_rm( p2_alu_reg_rm, f_alu_reg_rm_1, f_alu_reg_rm_2, f_alu_reg_rm_3, f_alu_reg_rm_sel, selected_alu_reg_rm );
	mux2to1_32bit mux_alu_rm_imm( selected_alu_reg_rm, p2_alu_sextImm3, p2_aluSrcB, aluIn2 );

	wire [31:0] aluOut;
	wire alu_flag_z, alu_flag_n, alu_flag_c, alu_flag_v;
	alu theALU(
		aluIn1, aluIn2, p2_aluOp, aluOut, 
		alu_flag_z, alu_flag_n, alu_flag_c, alu_flag_v
	);
	
	pipeline_EX_MEM p3( 
		clk, rest, p3_pipeline_regWrite, EX_flush,
		
		p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, p2_flag_regWrite,
		alu_rd, mem_rd,
		mem_reg_rd, 
		aluOut, mem_address,
		alu_flag_z, alu_flag_n, alu_flag_c, alu_flag_v,
		
		p3_memRead, p3_memWrite, p3_alu_regWrite, p3_mem_regWrite,
		p3_alu_rd, p3_mem_rd,
		p3_mem_reg_rd, 
		p3_alu_aluOut, p3_mem_address,
		p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v
	);	
	
	
endmodule
