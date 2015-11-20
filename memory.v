/*
	This file currently contains mockups for the memories. 
	
*/
module instructionMem(input clk, input reset, input [31:0] PC, output hit, output reg [31:0] instr2Word);
	// DUMMY FOR NOW!
	always@(negedge clk)
	begin
		hit = 1'b1;
		case(PC[1:0])
			2'b00: instr2Word = 00000000_00000000__00000000_00000000;
			2'b01: instr2Word = 00000000_00000000__00000000_00000000;
			2'b10: instr2Word = 00000000_00000000__00000000_00000000;
			2'b11: instr2Word = 00000000_00000000__00000000_00000000;
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

