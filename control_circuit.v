
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
