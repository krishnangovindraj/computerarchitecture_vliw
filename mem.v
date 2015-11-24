module MEMStage( 
		input clk, reset, p4_pipeline_regWrite, 
		
		input p3_alu_regWrite, p3_mem_regWrite,
		input [2:0] p3_alu_rd, p3_mem_rd,
		input [7:0] p3_mem_reg_rd, 
		input [31:0] p3_alu_aluOut, p3_mem_address,
		
		input f_memStage_mem_rd_sel,
		input [7:0] f_memStage_mem_reg_rd,
		
		input p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v,
		
		output p4_alu_regWrite, p4_mem_regWrite,
		output [2:0] p4_alu_rd, p4_mem_rd,
		output [31:0] p4_alu_aluOut, 
		output [31:0] p4_mem_memOut,
		output p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v
		
);
	
	wire [7:0] selected_mem_rd;
	mux2to1_8bit mux_f_memStage_mem_rd( p3_mem_reg_rd, f_memStage_mem_reg_rd, f_memStage_mem_rd_sel, selected_mem_rd );

	wire [7:0] mem_memOut_8bit;
	wire [31:0] mem_memOut;
	dataMem dataMemory( clk, reset, p3_mem_address, selected_mem_rd, hit, mem_memOut_8bit );
	zeroExt8to32 zExt_memOut( mem_memOut_8bit, mem_memOut );
	
		
	pipeline_MEM_WB p4( 
		clk, reset, p4_pipeline_regWrite, 
		p3_alu_regWrite, p3_mem_regWrite,
		p3_alu_rd, p3_mem_rd,
		p3_alu_aluOut, mem_memOut,
		p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v,
		
		p4_alu_regWrite, p4_mem_regWrite,
		p4_alu_rd, p4_mem_rd,
		p4_alu_aluOut, p4_mem_memOut,
		p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v
	);
	
endmodule
