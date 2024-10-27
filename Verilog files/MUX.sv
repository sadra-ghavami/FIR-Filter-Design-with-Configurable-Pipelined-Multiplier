`timescale 1ns/1ns

module MUX
    #(parameter WIDTH = 16, parameter INPUT_NUM = 16)
    (inputs, out_put, select);

    parameter SELECT_WIDTH = $clog2(INPUT_NUM);

    input [WIDTH-1:0] inputs[0:INPUT_NUM-1];
    input [SELECT_WIDTH-1:0]select;
    output [WIDTH-1:0] out_put;

    assign out_put = inputs[select];
   

endmodule