/*
	This file currently contains mockups for the memories. 
	
*/
module instructionMem(input clk, input reset, input [31:0] PC, input [31:0] writeData, output reg hit, output reg [31:0] instr2Word);
	// DUMMY FOR NOW!
	always@(negedge clk)
	begin
		hit = 1'b1;
		case(PC[5:2])
			4'b0000: instr2Word = 32'hf0_f0_f0_f0; 
			4'b0001: instr2Word = 32'h01_01_01_01; 
			4'b0010: instr2Word = 32'h02_02_02_02;
			4'b0011: instr2Word = 32'h03_03_03_03;
			
			4'b0100: instr2Word = 32'h04_04_04_04;
			4'b0101: instr2Word = 32'h05_05_05_05;
			4'b0110: instr2Word = 32'h06_06_06_06;
			4'b0111: instr2Word = 32'h07_07_07_07;
			
			4'b1000: instr2Word = 32'h08_08_08_08;
			4'b1001: instr2Word = 32'h09_09_09_09;
			4'b1010: instr2Word = 32'h0a_0a_0a_0a;
			4'b1011: instr2Word = 32'h0b_0b_0b_0b;
			
			4'b1100: instr2Word = 32'h0c_0c_0c_0c;
			4'b1101: instr2Word = 32'h0d_0d_0d_0d;
			4'b1110: instr2Word = 32'h0e_0e_0e_0e;
			4'b1111: instr2Word = 32'h0f_0f_0f_0f;
		endcase
	end
	
endmodule


module dataMem(input clk, input reset, input [31:0] memAddress, input [7:0] writeData, output reg hit, output [7:0] memOut);
	// DUMMY FOR NOW!
	always@(memAddress)
		hit = 1'b1;
	
	wire [7:0] decOut;
	wire [7:0] outR0, outR1, outR2, outR3, outR4, outR5, outR6, outR7;
	decoder3to8 dm_decoder( memAddress[2:0], decOut);
	register8bit dm0( clk, reset, regWrite, decOut[0], writeData, outR0 );
	register8bit dm1( clk, reset, regWrite, decOut[1], writeData, outR1 );
	register8bit dm2( clk, reset, regWrite, decOut[2], writeData, outR2 );
	register8bit dm3( clk, reset, regWrite, decOut[3], writeData, outR3 );
	register8bit dm4( clk, reset, regWrite, decOut[4], writeData, outR4 );
	register8bit dm5( clk, reset, regWrite, decOut[5], writeData, outR5 );
	register8bit dm6( clk, reset, regWrite, decOut[6], writeData, outR6 );
	register8bit dm7( clk, reset, regWrite, decOut[7], writeData, outR7 );
	
	mux8to1_8bit dm_mux( outR0, outR1, outR2, outR3, outR4, outR5, outR6, outR7, memAddress[2:0], memOut);
endmodule

