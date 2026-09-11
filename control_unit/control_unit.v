`timescale 1ns / 1ps

module control_unit(
input [15:0] instruction,
input Z,N,C,V, //these are comparator generated outputs and need to be recieved from comparator ouputs only .and later based on opcode we will decide
//whether to use comparator as our flag update source or alu add and sub// flags from the flag register
input EQ,GT,LT,// flags signals coming directly from comparaator so beq,blt,bgt must be done after the comparator is done
output reg B_operand,// select what will be the b operand(register value or immediate) in operation of a and b
output reg wr_signal,
output reg use_carry_flg, // for adcs and sbb we need borrow and carry in
output reg[2:0] shift_type,
output reg [3:0]alu_op,
output reg [3:0] extract_imm,
output reg branching,
output reg[7:0] offset,//jump amount for pc
output reg flag_write,
output reg flag_source,
output reg cmp_signed
    );
wire [3:0]opcode,sub_op;
assign opcode = instruction[15:12];
assign sub_op = instruction[11:8];
always @(*)begin
B_operand = 1'b0;
branching = 1'b0;
offset = 8'b0;
wr_signal = 1'b0;
use_carry_flg = 1'b0;
shift_type = 3'b000;
alu_op = 4'b0000;
extract_imm = 4'b0000;
flag_write = 1'b0;
cmp_signed = 1'b0;
flag_source = 1'b0;
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
  4'b0010:begin
  case(sub_op)
    4'b0000:begin//unconditional jump
    branching = 1'b1;
    offset= instruction[7:0];
    end
    4'b0001:begin
    branching= Z? 1'b1 : 1'b0;
    offset= instruction[7:0];
    end  
    4'b0010:begin
    branching= Z? 1'b0 : 1'b1;
    offset= instruction[7:0];
    end  
    4'b0011:begin
    branching= C? 1'b1 : 1'b0;
    offset= instruction[7:0];
    end  
    4'b0100:begin
    branching= C? 1'b0 : 1'b1;
    offset= instruction[7:0];
    end  
    4'b0101:begin
    branching= V? 1'b1 : 1'b0;
    offset= instruction[7:0];
    end  
    4'b0110:begin
    branching= V? 1'b0 : 1'b1;
    offset= instruction[7:0];
    end  
    4'b1010:begin
    branching= GT? 1'b1 : 1'b0;
    offset= instruction[7:0];
    end  
    4'b1011:begin
    branching= LT? 1'b1 : 1'b0;
    offset= instruction[7:0];
    end  
    4'b1000:begin//BEQ
    branching= EQ? 1'b1 : 1'b0;
    offset= instruction[7:0];
    end  
    4'b1001:begin//BNE
    branching= EQ? 1'b0 : 1'b1;
    offset= instruction[7:0];
    end  
    4'b1100:begin//BGE -GREATER THAN OR EQUAL TO
    branching= (GT | EQ)? 1'b1 : 1'b0;
    offset= instruction[7:0];
    end  
    4'b1101:begin// BLE- LESS THAN OR EQUAL TO
    branching= (LT | EQ)? 1'b1 : 1'b0;
    offset= instruction[7:0];
    end  
    4'b1110:begin//cmp
    cmp_signed = 1'b0;
    flag_write = 1'b1;
    flag_source = 1'b1;
    alu_op = 4'b0111;
    end
    4'b1111:begin//cmps
    cmp_signed = 1'b1;
    flag_write = 1'b1;
    flag_source = 1'b1;
    alu_op = 4'b0111;
    end  
    
  endcase  
 end 
  
     
     
    endcase
 endmodule