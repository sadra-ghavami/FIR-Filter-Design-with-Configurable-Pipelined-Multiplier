`timescale 1ns/1ns

module Adder_testbench();
    reg[31:0] inp1, inp2;
    wire[32:0] out1;
    Adder #(.INPUT_WIDTH(32), .OUTPUT_WIDTH(33)) 
        test_adder(.input_1(inp1), .input_2(inp2), .out_put(out1));
    
    initial begin
        #10 inp1 = 32'h80000000; inp2 = 32'h80000001;
        #10 $stop;
    end

endmodule
