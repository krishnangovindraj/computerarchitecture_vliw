/*
module testStage;

	reg clk;
	reg reset;
  
	always
	#5 clk=~clk; 
	
	initial
	begin
		clk=0; reset=1;
		#10  reset=0;
		
		
		#100 $finish; 
	end
	
endmodule
	



*/
module testIF;

	reg clk;
	reg reset;
	// inputs
	reg p1_pipeline_regWrite, IF_flush, pcWrite;
	reg [1:0] pcSrc;
	reg [31:0] p2_pc_branchTarget, pc_jumpTarget;
	
	// outputs
	wire [15:0] p1_aluInstr, p1_memInstr;
	wire [31:0] p1_pc_plus4;
	
	IFStage the_IFStage(
		clk, reset, p1_pipeline_regWrite, IF_flush, 
		pcWrite, 	p2_pc_branchTarget, pc_jumpTarget, 
		pcSrc, // From other stages
		p1_aluInstr, p1_memInstr, p1_pc_plus4
	);
	
	
  
	always
	#5 clk=~clk; 
	
	
	initial
	begin
		clk=0; reset=1; 
		p1_pipeline_regWrite = 1'b1;
		IF_flush = 1'b0;
		pcWrite = 1'b1;
		pcSrc = 2'b00;
		p2_pc_branchTarget 	= 32'b0000_0000_0000_0000_0000_0000_1010_1010;
		pc_jumpTarget 		= 32'b0000_0000_0000_0000_0000_0000_1000_1000;
		
		#10  reset=0;
		
		#30
		pcSrc = 2'b01;
		#20
		pcSrc = 2'b10;
		#20
		pcSrc = 2'b11;
		#20
		pcSrc = 2'b00;
		
		#20 
		IF_flush = 1'b1;
		
		#50 $finish; 
	end
	
endmodule
	

module testID;

	reg clk;
	reg reset;
	// inputs
	reg p2_pipeline_regWrite, p2_pipeline_stall;
	reg [15:0] p1_aluInstr, p1_memInstr;
	reg p3_flag_v, p3_flag_n;
	reg p4_flag_z, p4_flag_n, p4_flag_c, p4_flag_v;
	reg p4_mem_regWrite, p4_alu_regWrite;
	reg [2:0] p4_alu_rd, p4_mem_rd;
	reg [31:0] p4_alu_aluOut, p4_mem_memOut;
	
	// outputs 
	wire [2:0] p2_alu_rm, p2_alu_rn, p2_alu_rd, p2_mem_rn, p2_mem_rd;
	wire [31:0] p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd;
	wire [31:0] p2_alu_imm, p2_memOffset;
	wire [31:0] p2_pc_branchTarget, pc_jumpTarget;
		
	
		//flags
		wire flag_z, flag_n, flag_c, flag_v; 	// Formality to check flags
		
		
		// Signals
		wire p2_memRead, p2_memWrite, p2_alu_regWrite, p2_mem_regWrite, p2_flag_regWrite;
		wire p2_aluOp, p2_aluSrcB;
		wire p2_isBranch, p2_isJump;
		wire [1:0] pcSrc;
		
		// Flush signals
		wire IF_flush, ID_flush, EX_flush;
	
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
	
	
	
  
	always
	#5 clk=~clk; 
	
	
	initial
	begin
		clk=0; reset=1; 
		
		p2_pipeline_regWrite=1;
		p2_pipeline_stall = 0;
		p1_aluInstr = 16'b0;
		p1_memInstr = 16'b0;
		p3_flag_v = 0;  p3_flag_n=0;
		p4_flag_z = 0;p4_flag_n = 0; p4_flag_c = 0; p4_flag_v = 0;
		
		p4_mem_regWrite=0; p4_alu_regWrite=0;
		p4_alu_aluOut =0; p4_mem_memOut=0;
		
		#10  reset=0;
		
		#10  // Set the flag registers
		p4_flag_z = 1;p4_flag_n = 0; p4_flag_c = 1; p4_flag_v = 0;
		#10 
		p4_flag_z = 0;p4_flag_n = 1; p4_flag_c = 0; p4_flag_v = 1;
		#10
		p4_flag_z = 1;p4_flag_n = 1; p4_flag_c = 1; p4_flag_v = 1;
		// 40 ns have elapsed
		#50 
		p4_mem_regWrite = 1'b1; p4_alu_regWrite = 1'b1;
		#10// 100 ns
			// Write some data into the registers
			p4_alu_rd= 3'd0; p4_mem_rd = 3'd1; 
			p4_alu_aluOut = 32'h0000_f0f0;
			p4_mem_memOut = 32'h0000_1111;
		
		#10 
			p4_alu_rd= 3'd2; p4_mem_rd = 3'd3; 
			p4_alu_aluOut = 32'h0000_2222;
			p4_mem_memOut = 32'h0000_3333;
			
		
		#10
			p4_alu_rd= 3'd4; p4_mem_rd = 3'd5; 
			p4_alu_aluOut = 32'h0000_4444;
			p4_mem_memOut = 32'h0000_5555;
			
		
		#10
			p4_alu_rd= 3'd6; p4_mem_rd = 3'd7; 
			p4_alu_aluOut = 32'h0000_6666;
			p4_mem_memOut = 32'h0000_7777;
			
		
		// 130 seconds elapsed. Try reading them back
		#10 
			p4_mem_regWrite = 1'b1; p4_alu_regWrite = 1'b1;
		#10
			p1_aluInstr = 16'b000_001_000010100_1; p1_memInstr = 16'b01010_010_011_01100; // cmp a0, a1; store 10, a2, a3
			
		#20 
			p1_aluInstr = 16'b100_101_000010100_1; p1_memInstr = 16'b01010_110_111_01101; // cmp a0, a1; load 10, a2, a3
		
		// 170 up. Try new instructions for the control signals
		#20
			p1_aluInstr = 16'b000_001_000010100_1; p1_memInstr = 16'b01010_000_000_01100; // cmp a0, a1; store 10, a0, a0
			
		#20
			p1_aluInstr = 16'b100_110_111_01_00011; p1_memInstr = 16'b00010001000_1111_0; // shift a4, a6, a7; jmp 136
		#20
			// Try the stall ?
			p2_pipeline_stall = 1'b1;
			
		#50 $finish; 
	end
	
endmodule
	

