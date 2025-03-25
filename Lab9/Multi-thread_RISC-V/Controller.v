module Controller (
	input		[6:0]	opcode,
	input		[2:0]	func3,
	input		[6:0]	func7,
	
	output				Reg_Write,
	output				Mem_Read,
	output				Mem_Write,
	output				Mem_to_Reg,
	output	reg [3:0]	Alu_Ctrl,
	output				Alu_Src2,
	output				Jump,
	output				Branch
);

	// Load word
	wire LW = (opcode == 7'b0000011);
	
	// Store word
	wire SW = (opcode == 7'b0100011);
	
	// I-type
	wire I_type = (opcode == 7'b0010011);
	
	// R-type
	wire R_type = (opcode == 7'b0110011);
	
	// Jump
	wire JAL = (opcode == 7'b1101111);
	wire JALR = (opcode == 7'b1100111);
	
	// Branch
	wire BR = (opcode == 7'b1100011);
	
	
	always @(*) begin
		Alu_Ctrl = 4'b0000;
		
		case (opcode)
			7'b0000011: begin // LW
				Alu_Ctrl = 4'b0001; 
			end
			
			7'b0100011: begin // SW
				Alu_Ctrl = 4'b0001;
			end
			
			7'b0010011: begin // I-type
				case (func3)
					3'b000: Alu_Ctrl = 4'b0001; //ADDI
					3'b010: Alu_Ctrl = 4'b0111; //SLTI
					3'b011: Alu_Ctrl = 4'b1000; //SLTIU
					3'b100: Alu_Ctrl = 4'b0101; //XORI
					3'b110: Alu_Ctrl = 4'b0100; //ORI
					3'b111: Alu_Ctrl = 4'b0011; //ANDI
					3'b001: Alu_Ctrl = 4'b0110; //SLLI
					default: Alu_Ctrl = 4'b0000;
				endcase
			end
			
			7'b0110011: begin // R-type
				case (func3)
					3'b000: Alu_Ctrl = (func7==7'b0100000) ? 4'b0010 : 4'b0001; //SUB ADD
					3'b001: Alu_Ctrl = 4'b0110; //SLL
					3'b010: Alu_Ctrl = 4'b0111; //SLT
					3'b011: Alu_Ctrl = 4'b1000; //SLTU
					3'b100: Alu_Ctrl = 4'b0101; //XOR
					3'b101: Alu_Ctrl = (func7==7'b0100000) ? 4'b1010 : 4'b1001; //SRA SRL
					3'b110:	Alu_Ctrl = 4'b0100; //OR
					3'b111: Alu_Ctrl = 4'b0011; //AND
					default: Alu_Ctrl = 4'b0000;
				endcase
			end
			
			default: Alu_Ctrl = 4'b0000;
		endcase
	end
	
	assign Reg_Write = LW || I_type || R_type || JAL || JALR;
	assign Mem_Read = LW;
	assign Mem_Write = SW;
	assign Mem_to_Reg = LW;
	assign Alu_Src2 = LW || SW || I_type;
	assign Jump = JAL || JALR;
	assign Branch = BR;
	
	
endmodule