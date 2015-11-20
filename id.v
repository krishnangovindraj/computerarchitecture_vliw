
module controlCircuit(
		input [6:0] p1_aluOpcode, input [4:0] p1_memOpcode,
		output memRead, memWrite, alu_regWrite, mem_regWrite, 
		output aluOp, output aluSrcB, 
		output isBranch, output isJump,
		output alu_undefinedInstruction, output mem_undefinedInstruction
	);
	// These 2 can be derived directly from the opcode
	assign aluOp = p1_aluOpcode[5];
	assign aluSrcB = p1_aluOpcode[6];
	
	always@(p1_aluOpcode)
	begin
		case(p1_aluOpcode[4:0])
			case 5'b00011: 
				begin
					alu_regWrite = 1;	// addImm, subImm, subReg
					alu_undefinedInstruction = 0;
				end
			case 5'b01000: 
			begin
					alu_regWrite = 0;	// addImm, subImm, subReg
					alu_undefinedInstruction = 0;
				end
				
			default: 
				begin
					alu_regWrite = 0;
					alu_undefinedInstruction = 1;
				end
		endcase
	end
	
	always@(p1_memOpcode)
	begin
		case(p1_memOpcode[4:0])
			case 5'b01100:  // storeb
				begin
					memRead = 0;
					memWrite = 1;
					mem_regWrite = 0;
					mem_undefinedInstruction = 0;
					isJump = 0;
					isBranch = 0;
				end
			case 5'b01101: //loadb
				begin
					memRead = 1;
					memWrite = 0;
					mem_regWrite = 1;
					mem_undefinedInstruction = 0;
					isJump = 0;
					isBranch = 0;
				end
				
			case 5'b11010: //branch
				begin
					memRead = 0;
					memWrite = 0;
					mem_regWrite = 0;
					mem_undefinedInstruction = 0;
					isJump = 0;
					isBranch = 1;
				end
				
			case 5'b11110: //jump
				begin
					memRead = 0;
					memWrite = 0;
					mem_regWrite = 0;
					mem_undefinedInstruction = 0;
					isJump = 1;
					isBranch = 0;
				end
			default:
				begin
					memRead = 0;
					memWrite = 0;
					mem_regWrite = 0;
					mem_undefinedInstruction = 1;
					isJump = 0;
					isBranch = 0;
				end
		endcase
	end	
	
	
endmodule


module IDStage(
		input clk, input reset, input p2_pipeline_regWrite,
		
		input [15:0] p1_aluInstr, p1_memInstr,
		input p4_mem_regWrite, p4_alu_regWrite, input [31:0] p4_alu_writeData, p4_mem_writeData
	
		// Our output
		output [2:0] p2_alu_rm, p2_alu_rn, p2_alu_rd, p2_mem_rn, p2_mem_rd, 
		output [31:0] p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd, 
		output [31:0] p2_alu_sext3_imm, p2_mem_sext5_memOffset, p2_mem_shiftedSext8_branchOffset, 		
		output [31:0] mem_shiftedSext11_jumpOffset,
		
		
		// Signals
		output memRead, memWrite, alu_regWrite, mem_regWrite,
		output aluOp, aluSrcB,
		output isBranch, isJump
		output alu_undefinedInstruction, mem_undefinedInstruction
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
	wire memRead, memWrite, alu_regWrite, mem_regWrite;
	wire aluOp, aluSrcB; 
	wire isBranch, isJump;
	wire alu_undefinedInstruction, mem_undefinedInstruction;
	
	controlCircuit ctrlCkt(
		p1_aluInstr[6:0] , p1_memInstr[4:0],
		memRead, memWrite, alu_regWrite, mem_regWrite, 
		aluOp[1:0], aluSrcB, 
		isBranch,isJump,
		alu_undefinedInstruction, mem_undefinedInstruction
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
		clk, reset, p2_pipeline_regWrite, 
		p1_aluInstr[15:13], p1_aluInstr[12:10], p1_aluInstr[9:7], p1_memInstr[10:8], p1_memInstr[7:5],	// input
		p2_alu_rm, p2_alu_rn, p2_alu_rd, p2_mem_rn, p2_mem_rd,											// output
		
		alu_reg_rm, alu_reg_rn, mem_reg_rn, mem_reg_rd, 							// input
		p2_alu_reg_rm, p2_alu_reg_rn, p2_mem_reg_rn, p2_mem_reg_rd, 				// output
		
		alu_sext3_imm, mem_sext5_memOffset, mem_shiftedSext8_branchOffset, 			// input
		p2_alu_sext3_imm, p2_mem_sext5_memOffset, p2_mem_shiftedSext8_branchOffset	// output
	);
endmodule
