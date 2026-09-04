`timescale 1ns / 1ps

module booth_multiplier_16bit(
    input  [15:0] A,
    input  [15:0] B,
    input  is_signed,
    output [31:0] out
);
    integer i;
    //signed
    reg [33:0] p;
    reg [16:0] M;
    //unsigned
    reg [32:0] p1;
    reg [15:0] M1;
    
    always @(*) begin
        if (is_signed)begin
            M = {A[15], A};           
        // initialize values as AC = 0, Q = B, Q(-1) = 0
        p = {17'b0, B, 1'b0};

        for (i = 0; i < 16; i = i + 1) begin
            case (p[1:0])//qn and q(-1)

                2'b01:p[33:17] = p[33:17] + M;
                2'b10: p[33:17] = p[33:17] - M;
                default: ;                  
            endcase            
            p = {p[33], p[33:1]};
        end
    end
    else begin//for unsigned no extra sign biit in accumulator
       assign M1 = A;
        p1 = {16'b0, B, 1'b0};

        for (i = 0; i < 16; i = i + 1) begin
           case (p1[1:0])
              2'b01: p1[32:17] = p1[32:17] + M1;
              2'b10: p1[32:17] = p1[32:17] - M1;
                default: ;
           endcase
                // Arithmetic right shift
           p1 = {p1[32], p1[32:1]};    
        end
      end
    end  
    // Final result=[AC,Q]
     assign out = is_signed ? p[32:1] : p1[32:1];
endmodule