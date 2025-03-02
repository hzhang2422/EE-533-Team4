`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:41:34 02/21/2024 
// Design Name: 
// Module Name:    control_unit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module control_unit(
    input [6:0] opcode,
    input [2:0] func3,
    input bit30,
    output reg [2:0] ALUop,
    output reg sub,
    output reg ALUSel,
    output reg [1:0] branch,
    output reg memWrite,
    output reg WBSel,
    output reg regWrite,
    output reg pidi
    );

/////////////////////////////////Logic/////////////////////////////////////

    always@(*)
    begin
        if(opcode[3:0] == 4'b0011)
        begin
            case(opcode[6:4])
            //R-type
            3'b011:
            begin  
                ALUop       =   func3;
                sub         =   bit30;
                ALUSel      =   1'b0;
                branch      =   2'b00;
                memWrite    =   1'b0;
                WBSel       =   1'b0;
                regWrite    =   1'b1;
                pidi        =   1'b0;
            end

            //I-type: addi, slli, etc.
            3'b001:
            begin
                ALUop       =   func3;
                sub         =   1'b0;
                ALUSel      =   1'b1;
                branch      =   2'b00;
                memWrite    =   1'b0;
                WBSel       =   1'b0;
                regWrite    =   1'b1;
                pidi        =   1'b0;
            end

            //I-type: ld
            3'b000:
            begin
                ALUop       =   3'b000;
                sub         =   1'b0;
                ALUSel      =   1'b1;
                branch      =   2'b00;
                memWrite    =   1'b0;
                WBSel       =   1'b1;
                regWrite    =   1'b1;
                pidi        =   1'b0;
            end

            //B-type
            3'b110:
            begin
					//beq
					//if(func3 == 000)
					//begin
					//	ALUop       =   3'b000;
					//	sub         =   1'b0;
					//	ALUSel      =   1'b0;
					//	branch      =   2'b01;
					//	memWrite    =   1'b0;
					//	WBSel       =   1'b0;
					//	regWrite    =   1'b0;
					//	pidi        =   1'b0;
					//end
					//blt
					//else if (func3 == 100)
					//begin
						ALUop       =   3'b000;
						sub         =   1'b0;
						ALUSel      =   1'b0;
						branch      =   2'b10;
						memWrite    =   1'b0;
						WBSel       =   1'b0;
						regWrite    =   1'b0;
						pidi        =   1'b0;
					//end
            end
            
            //S-type: sd
            3'b010:
            begin
                ALUop       =   3'b000;
                sub         =   1'b0;
                ALUSel      =   1'b1;
                branch      =   2'b00;
                memWrite    =   1'b1;
                WBSel       =   1'b0;
                regWrite    =   1'b0;
                pidi        =   1'b0;
            end
            
            default:
            begin
                ALUop       =   3'b000;
                sub         =   1'b0;
                ALUSel      =   1'b0;
                branch      =   2'b00;
                memWrite    =   1'b0;
                WBSel       =   1'b0;
                regWrite    =   1'b0;
                pidi        =   1'b0;
            end
            endcase
        end

    else if(opcode == 7'b1111111)
        begin
            ALUop       =   3'b000;
            sub         =   1'b0;
            ALUSel      =   1'b0;
            branch      =   2'b01;
            memWrite    =   1'b0;
            WBSel       =   1'b0;
            regWrite    =   1'b0;
            pidi        =   1'b1;
        end

    else
        begin
            ALUop       =   3'b000;
            sub         =   1'b0;
            ALUSel      =   1'b0;
            branch      =   2'b00;
            memWrite    =   1'b0;
            WBSel       =   1'b0;
            regWrite    =   1'b0;
            pidi        =   1'b0;
        end
    end
endmodule
