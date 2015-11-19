`define EXCEPTION_HANDLER_ADDRESS 32'b00000000_11111111_00000000_11111111


module registerSet( 
		input clk, input reset,
		input alu_regWrite, input mem_regWrite, input [7:0] decOut1, input [7:0] decOut2, 
		input [31:0] writeData_1, input [31:0] writeData_2,  
		output [31:0] outR0,outR1,outR2,outR3,outR4,outR5,outR6,outR7 
	);
	wire [7:0] decOut;
	assign decOut[0] = decOut1[0] | decOut2[0];
	assign decOut[1] = decOut1[1] | decOut2[1];
	assign decOut[2] = decOut1[2] | decOut2[2];
	assign decOut[3] = decOut1[3] | decOut2[3];
	assign decOut[4] = decOut1[4] | decOut2[4];
	assign decOut[5] = decOut1[5] | decOut2[5];
	assign decOut[6] = decOut1[6] | decOut2[6];
	assign decOut[7] = decOut1[7] | decOut2[7];
	
	register32bit_2WriteData r0 (clk, reset, alu_regWrite, mem_regWrite, decOut[0] , decOut2[0], writeData_1, writeData_2 , outR0 );
	register32bit_2WriteData r1 (clk, reset, alu_regWrite, mem_regWrite, decOut[1] , decOut2[1], writeData_1, writeData_2 , outR1 );
	register32bit_2WriteData r2 (clk, reset, alu_regWrite, mem_regWrite, decOut[2] , decOut2[2], writeData_1, writeData_2 , outR2 );
	register32bit_2WriteData r3 (clk, reset, alu_regWrite, mem_regWrite, decOut[3] , decOut2[3], writeData_1, writeData_2 , outR3 );
	register32bit_2WriteData r4 (clk, reset, alu_regWrite, mem_regWrite, decOut[4] , decOut2[4], writeData_1, writeData_2 , outR4 );
	register32bit_2WriteData r5 (clk, reset, alu_regWrite, mem_regWrite, decOut[5] , decOut2[5], writeData_1, writeData_2 , outR5 );
	register32bit_2WriteData r6 (clk, reset, alu_regWrite, mem_regWrite, decOut[6] , decOut2[6], writeData_1, writeData_2 , outR6 );
	register32bit_2WriteData r7 (clk, reset, alu_regWrite, mem_regWrite, decOut[7] , decOut2[7], writeData_1, writeData_2 , outR7 );
endmodule

module registerFile(
	input clk, input reset, 
	input mem_regWrite, input [2:0] mem_rn, mem_rd, input [31:0] mem_writeData,
	input alu_regWrite, input [2:0] alu_rm, alu_rn, alu_rd, input [31:0] alu_writeData,
	
	output [31:0] mem_reg_rn, mem_reg_rd, 
	output [31:0] alu_reg_rm, alu_reg_rn
	);
	
	wire [31:0] outR0,outR1,outR2,outR3,outR4,outR5,outR6,outR7;
	
	
	wire [7:0] alu_decOut, mem_decOut;
	decoder3to8 alu_decoder(alu_rd, alu_decOut);
	decoder3to8 mem_decoder(mem_rd, mem_decOut);
	
	registerSet rSet0( clk, reset, alu_regWrite,mem_regWrite, alu_decOut, mem_decOut, alu_writeData, mem_writeData, outR0,outR1,outR2,outR3,outR4,outR5,outR6,outR7 ); 
	// regWrite can be 1'b1 since the decoder does the work
	
	mux8to1_32bit mux_mrn( outR0,outR1,outR2,outR3,outR4,outR5,outR6,outR7, mem_rn, mem_reg_rn );
	mux8to1_32bit mux_mrd( outR0,outR1,outR2,outR3,outR4,outR5,outR6,outR7, mem_rd, mem_reg_rd );
	
	mux8to1_32bit mux_arn( outR0,outR1,outR2,outR3,outR4,outR5,outR6,outR7,alu_rn, alu_reg_rn );
	mux8to1_32bit mux_arm( outR0,outR1,outR2,outR3,outR4,outR5,outR6,outR7,alu_rm, alu_reg_rm );
	
endmodule
//Register File Design Ends


module instructionMem(input clk, input reset, input [31:0] PC, output reg [31:0] instr2Word);
	// DUMMY FOR NOW!
	always@(negedge clk)
	begin
		case(PC[1:0])
			2'b00: instr2Word = 00000000_00000000__00000000_00000000;
			2'b01: instr2Word = 00000000_00000000__00000000_00000000;
			2'b10: instr2Word = 00000000_00000000__00000000_00000000;
			2'b11: instr2Word = 00000000_00000000__00000000_00000000;
		endcase
	end
	
endmodule

module IF_ID( input clk, input reset, input regWrite, input [31:0] instr2Word, output [15:0] p1_aluInstr, output [15:0] p1_memInstr );
	register16bit reg_aluInstr(clk, reset, regWrite, instr2Word[15:0], p1_aluInstr);
	register16bit reg_memInstr(clk, reset, regWrite, instr2Word[31:16], p1_memInstr);
endmodule

module controlCircuit(
		input [6:0] p1_aluOpcode, input [4:0] p1_memOpcode,
		output memRead, memWrite, alu_regWrite, mem_regWrite, 
		output [1:0] aluOp, output aluSrcB, 
		output isBranch, output isJump,
		output alu_undefinedInstruction, output mem_undefinedInstruction
	);
	// These 2 can be derived directly from the opcode
	assign aluOp = p1_aluOpcode[6:5];
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

module IFIDSTAGE(
		// From outside world
		input clk, input reset,
		// From other stages
		input pcWrite, 		input pc_writeData_sel, 	input [31:0] pc_writeData_bgt, // pc_writeData_jmp, 
		input mem_regWrite, alu_regWrite, input [31:0] alu_writeData, mem_writeData,
		// Our output
		output [31:0] PC_out, alu_reg_rm, alu_reg_rn, mem_reg_rn, mem_reg_rd, 
		output [31:0] alu_sextImm3, mem_sextImm5, mem_sextImm8, mem_sextImm11,
		output [2:0] alu_rm, alu_rn, alu_rd, mem_rn, mem_rd
	);
	
	//IF Stage
	wire [31:0] pc_plus4;
	wire [31:0] pc_out ;


	wire [31:0] pc_writeData_jmp;
	signExt11to32 mem_signExt11( p1_memInstr[15:5], mem_sextImm11 );
	assign pc_writeData_jmp = {mem_sextImm11[30:0],1'b0};	// if p1_memInstr is fine, this is fine.
	
	adder32bit adder_pc( pc_out, 32'd4 , pc_plus4 );
	
	wire [31:0] pc_writeData; 
	mux4to1_32bit mux_pc_writeData( pc_plus4, EXCEPTION_HANDLER_ADDRESS, pc_writeData_jmp, pc_writeData_bgt,  pc_writeData_sel, pc_writeData );
	
	register32bit PC( clk, reset, pcWrite, 1'b1, pc_writeData, pc_out );
	
	
	wire [31:0] instr2Word;
	instructionMem instructionMemory(clk, reset, pc_out, instr2Word);
	
	wire [15:0] p1_aluInstr, p1_memInstr;
	IF_ID p1(clk, reset, regWrite, instr2Word, p1_aluInstr, p1_memInstr);
	
	// ID Stage
	
	registerFile rFile( clk, reset, 
		mem_regWrite, p1_memInstr[10:8], p1_memInstr[7:5], mem_writeData,
		alu_regWrite, p1_aluInstr[15:13], p1_aluInstr[12:10], p1_aluInstr[9:7], alu_writeData,
	
		mem_reg_rn, mem_reg_rd, 
		alu_reg_rm, alu_reg_rn
	);
	
	// Sign extended
	signExt3to32 alu_signExt3( p1_aluInstr[15:13], alu_sextImm3 );
	
	signExt5to32 mem_signExt5( p1_memInstr[15:13], mem_sextImm5 );
	signExt8to32 mem_signExt8( p1_memInstr[15:8], mem_sextImm8 );
	
endmodule
