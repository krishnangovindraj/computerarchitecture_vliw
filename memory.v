/*
	This file currently contains mockups for the memories. 
	
*/
module instructionMem(input clk, input reset, input [31:0] PC, output hit, output reg [31:0] instr2Word);
	// DUMMY FOR NOW!
	always@(negedge clk)
	begin
		hit = 1'b1;
		case(PC[3:0])
			4'b0000: instr2Word = 001_000_001_10_00011__00000000_00000000;  // add $1, $0, 1
			4'b0001: instr2Word = 00000000_00000000__00000000_00000000;
			4'b0010: instr2Word = 00000000_00000000__00000000_00000000;
			4'b0011: instr2Word = 00000000_00000000__00000000_00000000;
			
			4'b0100: instr2Word = 00000000_00000000__00000000_00000000;
			4'b0101: instr2Word = 00000000_00000000__00000000_00000000;
			4'b0110: instr2Word = 00000000_00000000__00000000_00000000;
			4'b0111: instr2Word = 00000000_00000000__00000000_00000000;
			
			4'b1000: instr2Word = 00000000_00000000__00000000_00000000;
			4'b1001: instr2Word = 00000000_00000000__00000000_00000000;
			4'b1010: instr2Word = 00000000_00000000__00000000_00000000;
			4'b1011: instr2Word = 00000000_00000000__00000000_00000000;
			
			4'b1100: instr2Word = 00000000_00000000__00000000_00000000;
			4'b1101: instr2Word = 00000000_00000000__00000000_00000000;
			4'b1110: instr2Word = 00000000_00000000__00000000_00000000;
			4'b1111: instr2Word = 00000000_00000000__00000000_00000000;
		endcase
	end
	
endmodule


module dataMem(input clk, input reset, input [31:0] memAddress, output hit, output reg [7:0] memOut);
	// DUMMY FOR NOW!
	always@(negedge clk)
	begin
		hit = 1'b1;
		memOut = memAddress[7:0];	
	end
endmodule

