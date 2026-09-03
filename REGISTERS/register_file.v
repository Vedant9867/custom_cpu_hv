`timescale 1ns / 1ps

module register_file(
    input [3:0] rd_ad1,
    input [3:0] rd_ad2,
    input clck,
    input [3:0] wr_ad,
    input [15:0] wr_data,
    input wr_signal,
    output [15:0] rd_data1,
    output [15:0] rd_data2
    );
    reg [15:0] register[0:15]; // array of 15 register 
    assign rd_data1 = register[rd_ad1];
    assign rd_data2 = register[rd_ad2];
    
    always @(posedge clck) begin
      if(wr_signal)
        register[wr_ad]<= wr_data;
    end
endmodule
