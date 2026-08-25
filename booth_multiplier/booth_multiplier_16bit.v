`timescale 1ns / 1ps

module booth_multiplier_16bit(
    input  [15:0] A,
    input  [15:0] B,
    input  is_signed,
    output [31:0] out
);
    integer i;
    reg [32:0] p;
    reg [16:0] M;
    always @(*) begin
        if (is_signed)
            M = {A[15], A};     
        else
            M = {1'b0, A};      
        // initialize values as AC = 0, Q = B, Q(-1) = 0
        p = {16'b0, B, 1'b0};

        for (i = 0; i < 16; i = i + 1) begin
            case (p[1:0])//qn and q(-1)

                2'b01:p[32:17] = p[32:17] + M;
                2'b10: p[32:17] = p[32:17] - M;
                default: ;                  
            endcase            
            p = {p[32], p[32:1]};
        end
    end
    // Final result=[AC,Q]
    assign out = p[32:1];
endmodule