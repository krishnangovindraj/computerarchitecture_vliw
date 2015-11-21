module alu(input [31:0] aluIn1, input [31:0] aluIn2, input aluOp, output reg [31:0] aluOut, output flag_z, output flag_n, output flag_c, output flag_v);
 reg [31:0] temp;
	always@(aluIn1 or aluOp)
	begin
		case(aluOp)
			1'b0: aluOut = aluIn1 + aluIn2;
			1'b1: aluOut = aluIn1 - aluIn2;
		endcase
		if(aluOut == 0)
			flag_z = 1;
		else if(aluOut < 0)
			flag_n = 1;
		//else if(aluIn1 )
		//else if(aluIn1 )		
	end
endmodule