module mux8to1_32bit( input [31:0] in0,in1,in2,in3,in4,in5,in6,in7, input [2:0] Sel, output reg [31:0] outBus );
	always@(in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7 or Sel)
	case (Sel)
			3'b000: outBus=in0;
			3'b001: outBus=in1;
			3'b010: outBus=in2;
			3'b011: outBus=in3;
			3'b100: outBus=in4;
			3'b101: outBus=in5;
			3'b110: outBus=in6;
			3'b111: outBus=in7;
	endcase
endmodule

module mux4to1_32bit( input [31:0] in0,in1,in2,in3, input [2:0] Sel, output reg [31:0] outBus );
	always@(in0 or in1 or in2 or in3 or Sel)
	case (Sel)
			2'b00: outBus=in0;
			2'b01: outBus=in1;
			2'b10: outBus=in2;
			2'b11: outBus=in3;
	endcase
endmodule

module mux2to1_32bit( input [31:0] in0,in1, input Sel, output reg [31:0] outBus );
	always@(in0 or in1 or Sel)
	case (Sel)
			1'b0: outBus=in0;
			1'b1: outBus=in1;
	endcase
endmodule


module mux2to1_1bit( input in0, in1, input Sel, output reg outBus );
	always@(in0 or in1 or Sel)
	case (Sel)
			1'b0: outBus=in0;
			1'b1: outBus=in1;
	endcase
endmodule



// Sign extension : 3,5,8,11 bits
module signExt3to32( input [2:0] offset, output reg [31:0] signExtOffset);
	//Write your code here
  always@(offset)
  begin
    case(offset[2])
      1'b0: signExtOffset = { 29'b00000000000000000000000000000, offset};
      1'b1: signExtOffset = { 29'b11111111111111111111111111111, offset};
    endcase
  end
endmodule

module signExt5to32( input [4:0] offset, output reg [31:0] signExtOffset);
	//Write your code here
  always@(offset)
  begin
    case(offset[4])
      1'b0: signExtOffset = { 27'b000000000000000000000000000, offset};
      1'b1: signExtOffset = { 27'b111111111111111111111111111, offset};
    endcase
  end
endmodule


module signExt8to32( input [7:0] offset, output reg [31:0] signExtOffset);
	//Write your code here
  always@(offset)
  begin
    case(offset[7])
      1'b0: signExtOffset = { 24'b00000000000000000000000, offset};
      1'b1: signExtOffset = { 24'b111111111111111111111111, offset};
    endcase
  end
endmodule

module signExt11to32( input [10:0] offset, output reg [31:0] signExtOffset);
	//Write your code here
  always@(offset)
  begin
    case(offset[10])
      1'b0: signExtOffset = { 21'b000000000000000000000, offset};
      1'b1: signExtOffset = { 21'b111111111111111111111, offset};
    endcase
  end
endmodule

module zeroExt8to32( input [7:0] offset, output reg [31:0] zeroExtOffset);
  always@(offset)
  begin
    zeroExtOffset = { 24'b000000000000000000000000, offset};
  end
endmodule



module decoder3to8( input [2:0] encoded, output reg [7:0] decOut);
	always@(encoded)
	begin
		case(encoded)
			3'b000: decOut=8'b00000001; 
			3'b001: decOut=8'b00000010;
			3'b010: decOut=8'b00000100;
			3'b011: decOut=8'b00001000;
			3'b100: decOut=8'b00010000;
			3'b101: decOut=8'b00100000;
			3'b110: decOut=8'b01000000;
			3'b111: decOut=8'b10000000;
		endcase
	end
endmodule

