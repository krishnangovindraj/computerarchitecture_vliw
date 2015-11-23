module forwarding_unit(input p3_alu_regWrite, input p4_alu_regWrite, input p4_mem_regWrite,input p2_alu_regWrite,input [4:0] p1_aluOpcode,input [4:0] p1_memOpcode,
		input [4:0] p2_aluOpcode,input [4:0] p2_memOpcode,input [2:0] p4_opcodeM_rd /* I[7:5] */ , input [2:0] p4_opcodeA_rd /* I[25:23] */, 
		input [2:0] p3_opcodeA_rd /* I[25:23] */, input [2:0] p2_opcodeM_rd /* I[7:5] */ ,input [2:0] p2_opcodeA_rm /* I[31:29] */ ,
		input [2:0] p2_opcodeA_rn /* I[28:26] */ ,input [2:0] p2_opcodeM_rn /* I[10:8] */ ,
		output reg [1:0] fA , output reg [1:0] fB, output reg [1:0] fC, output reg fD, output reg fE); // ,output reg [1:0] N_flag_mux); // Deprecated
		
		always @ ( p4_opcodeM_rd or p4_opcodeA_rd or p3_opcodeA_rd or p2_opcodeM_rd or p2_opcodeA_rm or p2_opcodeA_rn or p2_opcodeM_rn)
		
		begin

		// when no dependencies all are from id/ex
		fA = 0 ; fB = 0 ; fC = 0 ; fD = 0; fE = 0; 
					
		// fA = alu_rn
		if( p3_alu_regWrite == 1 && p3_opcodeA_rd != 0 && p3_opcodeA_rd == p2_opcodeA_rn )	// (add,X) < (add,X)
			fA = 1;
		else if( p4_mem_regWrite == 1 && p4_opcodeM_rd != 0 && p4_opcodeM_rd == p2_opcodeA_rn )	// (add,X) < (X,X) < (X,lw) // We give mem precedence
			fA = 3;
		else if( p4_alu_regWrite == 1 && p4_opcodeA_rd != 0 && p4_opcodeA_rd == p2_opcodeA_rn )	// (add,X) < (X,X) < (add,X)
			fA = 2;
		
		
		// fB = alu_rm
		if( p3_alu_regWrite == 1 &&  p3_opcodeA_rd != 0 && p3_opcodeA_rd == p2_opcodeA_rm )	// (add,X) < (add,X)	// Would this mess up with immediate? No, Because we have a mux after this
			fB = 1;
		else if( p4_mem_regWrite == 1 && p4_opcodeM_rd != 0 && p4_opcodeM_rd == p2_opcodeA_rm )	// (X,lw) < (X,X) < (add,X) // We give mem precedence
			fB = 3;
		else if( p4_alu_regWrite == 1 && p4_opcodeA_rd != 0 && p4_opcodeA_rd == p2_opcodeA_rm )	// (add,X) < (X,X) < (add,X)
			fB = 2;
		
		//fC = mem_rn
		if( p3_alu_regWrite == 1 &&  p3_opcodeA_rd != 0 && p3_opcodeA_rd == p2_opcodeM_rn )		// (add,X) < (X,lw)	// Would this mess up with immediate? No, Because we have a mux after this
			fC = 1;
		else if( p4_mem_regWrite == 1 && p4_opcodeM_rd != 0 && p4_opcodeM_rd == p2_opcodeM_rn )	// (X,lw) < (X,X) < (X,lw) // We give mem precedence
			fC = 3;
		else if( p4_alu_regWrite == 1 && p4_opcodeA_rd != 0 && p4_opcodeA_rd == p2_opcodeM_rn )	// (add,X) < (X,X) < (X,lw)
			fC = 2;
			
		
		//fD = EX_mem_rd
		if( p3_alu_regWrite == 1 &&  p3_opcodeA_rd != 0 && p3_opcodeA_rd == p2_opcodeM_rd )		// (add,X) < (X,sw)	// Would this mess up with immediate? No, Because we have a mux after this
			fD = 1;
		else if( p4_mem_regWrite == 1 && p4_opcodeM_rd != 0 && p4_opcodeM_rd == p2_opcodeM_rd )	// (X,lw) < (X,X) < (X,sw) // We give mem precedence
			fD = 3;
		else if( p4_alu_regWrite == 1 && p4_opcodeA_rd != 0 && p4_opcodeA_rd == p2_opcodeM_rd )	// (add,X) < (X,X) < (X,sw)
			fD = 2;
		
		
		
		// fE = MEM_mem_rd
		
		// (add,X), (X, sw) ( A_WB to M_MEM ) dependency already done in fD
		if( p4_mem_regWrite == 1 && p4_opcodeM_rd != 0 && p4_opcodeM_rd == p2_opcodeM_rd ) // ( X, lw ) < ( X, sw ) 
			fE = 1;
		
		
	end
endmodule

// We'll still stall if the dependent instruction has been flushed out. But that's too complicated to fix now.
/*
	p2_stall sets all the ID_EX control signals to 0 as well as the ID_EX regWrite to 0 ( so that it doesn't get overwritten )
	Other 2 are self explanatory.
*/
module hazard_detection(
		input p3_mem_regWrite, input [2:0] p3_mem_rd,
		input [2:0] p2_alu_rm, input [2:0] p2_alu_rn, input [2:0] p2_mem_rn,
		output reg PCWrite_HU, output reg p1_regWrite_HU, output reg p2_stall
	);
		
		integer stall =0;
		
		always @ (p3_mem_regWrite or p2_alu_rn or p2_alu_rm or p2_mem_rn )	 // p2_mem_rd can be fixed by forwarding
		begin
			//when there is no hazard
			PCWrite_HU = 1;  p1_regWrite_HU = 1;  stall = 0; 
			
			if ( p3_mem_regWrite == 1 && p3_mem_rd !=0 && (p2_alu_rm == p3_mem_rd || p2_alu_rn == p3_mem_rd || p2_alu_rm == p3_mem_rd ) )
				begin 
					PCWrite_HU = 0;  
					p1_regWrite_HU = 0;  
					p2_stall = 1; 
				end	
		end
endmodule
