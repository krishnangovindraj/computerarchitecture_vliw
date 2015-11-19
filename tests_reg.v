module testRegFile;
	reg r_mem_regWrite; 
	reg [2:0] r_mem_rn, r_mem_rs, r_mem_rd; 
	reg [31:0] r_mem_writeData;
	reg r_alu_regWrite; 
	reg [2:0] r_alu_rn, r_alu_rm, r_alu_rd; 
	reg [31:0] r_alu_writeData;
	
	reg [31:0] r_mem_reg_rn, r_mem_reg_rd; 
	reg [31:0] r_alu_reg_rn, r_alu_reg_rm;
	
	reg clk;
	reg reset;
  
  wire mem_regWrite; 
	wire [2:0] mem_rn, mem_rs, mem_rd; 
	wire [31:0] mem_writeData;
	wire alu_regWrite; 
	wire [2:0] alu_rn, alu_rm, alu_rd; 
	wire [31:0] alu_writeData;
	
	wire [31:0] mem_reg_rn, mem_reg_rd; 
	wire [31:0] alu_reg_rn, alu_reg_rm;
		
	assign mem_regWrite = r_mem_regWrite ; 
  assign mem_rn = r_mem_rn;
  assign mem_rd = r_mem_rd; 
  assign mem_writeData = r_mem_writeData;
	
  assign alu_regWrite = r_alu_regWrite ; 
  assign alu_rn  = r_alu_rn  ;
  assign alu_rm = r_alu_rm ;
  assign alu_rd  = r_alu_rd ; 
  assign  alu_writeData = r_alu_writeData ;

  assign mem_reg_rn = r_mem_reg_rn ;
  assign mem_reg_rd = r_mem_reg_rd; 
  assign alu_reg_rn = r_alu_reg_rn;
  assign alu_reg_rm  = r_alu_reg_rm;
	
	registerFile rFile(
		 clk,  reset, 
		 mem_regWrite,   mem_rn, mem_rd,   mem_writeData,
		 alu_regWrite,   alu_rn, alu_rm, alu_rd,   alu_writeData,
		 mem_reg_rn, mem_reg_rd, 
		 alu_reg_rn, alu_reg_rm 
	);
	
	always
	#5 clk=~clk; 
	
	always
	begin
		#10 r_mem_writeData = r_mem_writeData + 2; r_alu_writeData = r_alu_writeData + 4; r_alu_rd = r_alu_rd+1; r_mem_rd = r_mem_rd+1;

	end
	
	initial
	begin
		clk=0; reset=1;
		r_mem_regWrite = 0; r_alu_regWrite = 0; r_alu_writeData = 32'd0; r_mem_writeData = 32'd256;
		r_alu_rn = 0; r_alu_rm = 0; r_mem_rn = 0; 
		r_alu_rd = 0; r_mem_rd = 4 ;
		#10  reset=0;
		r_mem_regWrite = 1;
		r_alu_regWrite = 1;
		
		#100 $finish; 
	end
	
endmodule
