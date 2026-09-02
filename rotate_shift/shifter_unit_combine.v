`timescale 1ns / 1ps

module shifter_unit_combine(
    input [15:0] data,
    input [15:0] shift_amt,
    input [2:0] shift_type,
    output [15:0] out
    );
    wire [15:0] lr_res,rr_res,rs_res,ls_res,as_res;
    left_rotate lr(.A(data),.S(shift_amt[3:0]),.Out(lr_res));
    rotator16bit rr(.A(data),.S(shift_amt[3:0]),.Out(rr_res));
    right_shift rs(.A(data),.S(shift_amt[3:0]),.Out(rs_res));
    left_shift ls(.A(data),.S(shift_amt[3:0]),.Out(ls_res));
    arithmetic_shift16 as(.A(data),.S(shift_amt[3:0]),.Out(as_res));
    reg [15:0] res;
  always @(*) begin
    case (shift_type) // encodin 3:0 sub op 3 upper bit decodes shift type 
    // rs-000,ls-001,as-010,rr-011,lr-100 ; with immediate will be sub op lsb will be 1 
    3'b100: res = lr_res;
    3'b011: res = rr_res;
    3'b000: begin
        if(shift_amt>16'd15)
         res = 16'h0000;
        else 
         res = rs_res;
        end
    3'b001: begin
        if(|shift_amt[15:4])
         res = 16'h0000;
        else 
        res = ls_res;
       end
    3'b010: begin //arithmetic right shift
         if(|shift_amt[15:4])//reduction operator all bits should be 0 if any one then shift result is all 0s
            res= data[15]? 16'hFFFF:16'h0000;
         else
            res= as_res;
         end
    default: res = 16'h0000;    
    endcase
  end
    assign  out = res;
endmodule
