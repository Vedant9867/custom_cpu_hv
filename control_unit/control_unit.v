`timescale 1ns / 1ps

module control_unit(
input [15:0] instruction,
output reg B_operand,// select what will be the b operand(register value or immediate) in operation of a and b
output reg wr_signal,
output reg use_carry_flg, // for adcs and sbb we need borrow and carry in
output reg[2:0] shift_type,
output reg [3:0]alu_op,
output reg [3:0] extract_imm
    );
wire [3:0]opcode,sub_op;
assign opcode = instruction[15:12];
assign sub_op = instruction[11:8];
always @(*)begin
B_operand = 1'b0;
wr_signal = 1'b0;
use_carry_flg = 1'b0;
shift_type = 3'b000;
alu_op = 4'b0000;
extract_imm = 4'b0000;
  case(opcode)
   4'b0100:begin // ADD
      case(sub_op)
      4'b0000:begin// SIMPLE ADD R1,R2
         B_operand = 1'b0;// why i will interface this with b_select_imm of alu which selects imm when 1
         wr_signal = 1'b1;
         use_carry_flg = 1'b0; // for add with carry or sub with borrow
         alu_op = 4'b0000;
      end
      4'b0001:begin//  ADC R1,R2
         B_operand = 1'b0;// why i will interface this with b_select_imm of alu which selects imm when 1
         wr_signal = 1'b1;
         use_carry_flg = 1'b1; // for add with carry or sub with borrow
         alu_op = 4'b0000;
      end   
      4'b0010:begin// ADI R1,#IMM
         B_operand = 1'b1;
         wr_signal = 1'b1;
         use_carry_flg = 1'b0;
         alu_op = 4'b0000;   
      end 
     endcase
    end
  4'b0011:begin
    case(sub_op)

        4'b0000: begin // L-shift R1, R2
            B_operand = 1'b0;
            wr_signal = 1'b1;
            shift_type = 3'b000;
            alu_op = 4'b1000;
        end

        4'b0001: begin // L-shift R1, imm
            B_operand = 1'b1;
            wr_signal = 1'b1;
            shift_type = 3'b000;
            alu_op = 4'b1000;
        end

        4'b0010: begin   // r-shift R1, R2
            B_operand = 1'b0;
            wr_signal = 1'b1;
            shift_type = 3'b001;
            alu_op = 4'b1000;
        end

        4'b0011: begin// R-shift R1, #imm
            B_operand = 1'b1;
            wr_signal = 1'b1;
            shift_type = 3'b001;
            alu_op = 4'b1000;
        end

        4'b0100: begin// A-shift R1, R2
            B_operand = 1'b0;
            wr_signal = 1'b1;
            shift_type = 3'b010;
            alu_op = 4'b1000;
        end

        4'b0101: begin // A-shift R1, #imm
            B_operand = 1'b1;
            wr_signal = 1'b1;
            shift_type = 3'b010;
            alu_op = 4'b1000;
        end

        4'b0110: begin   // R-rotate R1, R2
            B_operand = 1'b0;
            wr_signal = 1'b1;
            shift_type = 3'b011;
            alu_op = 4'b1000;
        end

        4'b0111: begin  // R-rotate R1, #imm
            B_operand = 1'b1;
            wr_signal = 1'b1;
            shift_type = 3'b011;
            alu_op = 4'b1000;
        end

        4'b1000: begin  // L-rotate R1, R2
            B_operand = 1'b0;
            wr_signal = 1'b1;
            shift_type = 3'b100;
            alu_op = 4'b1000;
        end

        4'b1001: begin // L-rotate R1, #imm
            B_operand = 1'b1;
            wr_signal = 1'b1;
            shift_type = 3'b100;
            alu_op = 4'b1000;
        end
    endcase
end
  
     
     
    endcase
 endmodule