module MEMStage( 
		input clk, reset,
		
		input [2:0] p3_alu_rd, p3_mem_rd,
		input [7:0] p3_mem_reg_rd, 
		input [31:0] p3_alu_aluOut, p3_mem_address,
		
		input f_memStage_mem_rd_sel,
		input [31:0] f_memStage_mem_reg_rd,
		
		input p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v,
		
		output [2:0] p4_alu_rd, p4_mem_rd,
		output [31:0] p4_alu_aluOut, 
		output [31:0] p4_mem_memOut,
		output p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v
		
);
	
	wire [31:0] selected_mem_rd;
	mux2to1_32bit( p3_mem_reg_rd, f_memStage_mem_reg_rd, f_memStage_mem_rd_sel, selected_mem_rd );

	wire [7:0] mem_memOut;
	wire [31:0] mem_memOut_zeroExt;
	dataMem dataMemory( clk, reset, p3_mem_address, selected_mem_rd, hit, mem_memOut );
	zeroExt8to32( mem_memOut, mem_memOut_zeroExt );
	
	pipeline_MEM_WB p4( 
		clk, reset,
		p3_alu_rd, p3_mem_rd,
		p3_alu_aluOut, mem_memOut,
		p3_flag_z, p3_flag_n, p3_flag_c, p3_flag_v,
		
		p4_alu_rd, p4_mem_rd,
		p4_alu_aluOut, p4_mem_memOut,
		p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v
	);
	
endmodule
