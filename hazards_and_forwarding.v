module forwarding_unit(
		input p3_alu_regWrite, input p4_alu_regWrite, input p4_mem_regWrite,input p2_alu_regWrite,
		// input [4:0] p1_aluOpcode,input [4:0] p1_memOpcode,  input [4:0] p2_aluOpcode,input [4:0] p2_memOpcode, // Not needed
		input [2:0] p4_mem_rd, input [2:0] p4_alu_rd, 
		input [2:0] p3_alu_rd,
		input [2:0] p2_mem_rd,input [2:0] p2_alu_rm ,
		input [2:0] p2_alu_rn,input [2:0] p2_mem_rn,
		
		output reg [1:0] f_alu_reg_rn_sel , output reg [1:0] f_alu_reg_rm_sel, output reg [1:0] f_mem_reg_rn_sel, output reg f_mem_reg_rd_sel, output reg f_memStage_mem_rd_sel // ,output reg [1:0] N_flag_mux); // Deprecated
	); 
		
		always @ ( p4_mem_rd or p4_alu_rd or p3_alu_rd or p2_mem_rd or p2_alu_rm or p2_alu_rn or p2_mem_rn)
		
		begin

		// when no dependencies all are from id/ex
		f_alu_reg_rn_sel = 0 ; f_alu_reg_rm_sel = 0 ; f_mem_reg_rn_sel = 0 ; f_mem_reg_rd_sel = 0; f_memStage_mem_rd_sel = 0; 
					
		// f_alu_reg_rn_sel = alu_rn
		if( p3_alu_regWrite == 1 && p3_alu_rd != 0 && p3_alu_rd == p2_alu_rn )	// (add,X) < (add,X)
			f_alu_reg_rn_sel = 1;
		else if( p4_mem_regWrite == 1 && p4_mem_rd != 0 && p4_mem_rd == p2_alu_rn )	// (add,X) < (X,X) < (X,lw) // We give mem precedence
			f_alu_reg_rn_sel = 3;
		else if( p4_alu_regWrite == 1 && p4_alu_rd != 0 && p4_alu_rd == p2_alu_rn )	// (add,X) < (X,X) < (add,X)
			f_alu_reg_rn_sel = 2;
		
		
		// f_alu_reg_rm_sel = alu_rm
		if( p3_alu_regWrite == 1 &&  p3_alu_rd != 0 && p3_alu_rd == p2_alu_rm )	// (add,X) < (add,X)	// Would this mess up with immediate? No, Because we have a mux after this
			f_alu_reg_rm_sel = 1;
		else if( p4_mem_regWrite == 1 && p4_mem_rd != 0 && p4_mem_rd == p2_alu_rm )	// (X,lw) < (X,X) < (add,X) // We give mem precedence
			f_alu_reg_rm_sel = 3;
		else if( p4_alu_regWrite == 1 && p4_alu_rd != 0 && p4_alu_rd == p2_alu_rm )	// (add,X) < (X,X) < (add,X)
			f_alu_reg_rm_sel = 2;
		
		//f_mem_reg_rn_sel = mem_rn
		if( p3_alu_regWrite == 1 &&  p3_alu_rd != 0 && p3_alu_rd == p2_mem_rn )		// (add,X) < (X,lw)	// Would this mess up with immediate? No, Because we have a mux after this
			f_mem_reg_rn_sel = 1;
		else if( p4_mem_regWrite == 1 && p4_mem_rd != 0 && p4_mem_rd == p2_mem_rn )	// (X,lw) < (X,X) < (X,lw) // We give mem precedence
			f_mem_reg_rn_sel = 3;
		else if( p4_alu_regWrite == 1 && p4_alu_rd != 0 && p4_alu_rd == p2_mem_rn )	// (add,X) < (X,X) < (X,lw)
			f_mem_reg_rn_sel = 2;
			
		
		//f_mem_reg_rd_sel = EX_mem_rd
		if( p3_alu_regWrite == 1 &&  p3_alu_rd != 0 && p3_alu_rd == p2_mem_rd )		// (add,X) < (X,sw)	// Would this mess up with immediate? No, Because we have a mux after this
			f_mem_reg_rd_sel = 1;
		else if( p4_mem_regWrite == 1 && p4_mem_rd != 0 && p4_mem_rd == p2_mem_rd )	// (X,lw) < (X,X) < (X,sw) // We give mem precedence
			f_mem_reg_rd_sel = 3;
		else if( p4_alu_regWrite == 1 && p4_alu_rd != 0 && p4_alu_rd == p2_mem_rd )	// (add,X) < (X,X) < (X,sw)
			f_mem_reg_rd_sel = 2;
		
		
		
		// f_memStage_mem_rd_sel = MEM_mem_rd
		
		// (add,X), (X, sw) ( A_WB to M_MEM ) dependency already done in f_mem_reg_rd_sel
		if( p4_mem_regWrite == 1 && p4_mem_rd != 0 && p4_mem_rd == p2_mem_rd ) // ( X, lw ) < ( X, sw ) 
			f_memStage_mem_rd_sel = 1;
		
		
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
