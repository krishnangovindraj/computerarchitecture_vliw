/*
	Conditions for overflow and carry: http://teaching.idallen.com/dat2343/10f/notes/040_overflow.txt
*/


module alu(
		input [31:0] aluIn1, input [31:0] aluIn2, input aluOp, output reg [31:0] aluOut, 
		output reg flag_z, output reg flag_n, output reg flag_c, output reg flag_v
);
 	reg [31:0] signedAluIn2;
	
	always@(aluIn1 or aluIn2 or aluOp)
	begin
		case(aluOp)
			1'b0: signedAluIn2 = aluIn2;
			1'b1: signedAluIn2 = -aluIn2;
		endcase
		
		{flag_c,aluOut} = aluIn1 + signedAluIn2;
		
		flag_z = (aluOut == 0)?1'b1:1'b0;
		flag_n = (aluOut < 0)?1'b1:1'b0;
		flag_v = ( (aluIn1[31]==0 && signedAluIn2[31]==0 && aluOut[31]==1 ) || (aluIn1[31]==1 && signedAluIn2[31]==1 && aluOut[31]==0 ) )?1:0;
	end
endmodule

module adder32bit(input [31:0] op1, input [31:0] op2, output reg [31:0] res);
	always@(op1 or op2)
		res = op1 + op2;
endmodule

