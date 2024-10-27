`timescale 1ns/1ns

module Signed_mult_test();
    reg clk = 1'b0, rst;
    reg[7:0] x=0, y=0, control_signals_in=0;
    wire[15:0] result;
    wire[7:0] control_signals_out;

    Signed_multiplier #(.WIDTH(8), .CONTROL_SIGNALS_WIDTH(8)) UUT (x, y, result, clk, rst, control_signals_in, control_signals_out);

    always begin
        #10 clk <= ~clk;
    end

    initial begin
        #2 rst = 1'b1;
        #3 rst = 1'b0;
        for(int i=1 ; i<11 ; i++)begin
            y = 2*i + 211;
            x = 3*i+ 217;
            control_signals_in = i;
            #20;
        end
        #4000 $stop;
    end
endmodule

