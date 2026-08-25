`timescale 1ns / 1ps


module cska_16bit_sub(
    input [15:0] A,
    input [15:0] B,
    output [15:0] Diff,
    output Bin_msb,
    output Bout
    );
    wire [15:0]w;
    assign w = ~B;
    wire Cin;
    assign Cin = 1'b1;// always cin = 1 as for subtraction we need to do 2s complement not and then add 1
    wire cout,cin_msb;
    Cska_adder16_bit cska1(A,w,Cin,Diff,cout,cin_msb);
    assign Bout = ~cout; // when doing subtraction uding 2s complement final bout = ~cout of addition
    assign Bin_msb = ~cin_msb;
    
endmodule
