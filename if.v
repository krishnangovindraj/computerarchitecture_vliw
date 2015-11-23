`define EXCEPTION_HANDLER_ADDRESS 32'b00000000_11111111_00000000_11111111

module IFStage(
		// From outside world
		input clk, input reset, input p1_pipeline_regWrite, input IF_flush,
		// From other stages
		input pcWrite, 	input [31:0] pc_branchTarget, pc_jumpTarget, 
		input p2_isBranch, p2_alu_flag_N, isJump, isException, // OR the two
		output [15:0] p1_aluInstr, p1_memInstr
	);
	
	//Moved to in
	
	//IF Stage
	wire [31:0] pc_out;
	wire [31:0] pc_writeData;

	register32bit PC( clk, reset, pcWrite, 1'b1, pc_writeData, pc_out );
	
	// PC increment
	wire [31:0] pc_plus4;
	adder32bit adder_pc( pc_out, 32'd4 , pc_plus4 );
	
	
	// PC value selector
	wire [1:0] pc_writeData_sel;
	assign pc_writeData_sel[0] = ( p2_isBranch & p2_alu_flag_N ) | isException;
	assign pc_writeData_sel[1] =   isJump | isException;
	
	mux4to1_32bit mux_pc_writeData( pc_plus4, pc_branchTarget,  pc_jumpTarget, EXCEPTION_HANDLER_ADDRESS, pc_writeData_sel, pc_writeData );
	
	
	// Instruction memory
	wire [31:0] instr2Word;
	wire instrMem_hit;
	instructionMem instructionMemory(clk, reset, pc_out, instrMem_hit, instr2Word);
	
	// P1
	pipleline_IF_ID p1(clk, reset, IF_flush, p1_pipeline_regWrite, instr2Word, p1_aluInstr, p1_memInstr);
	
endmodule
