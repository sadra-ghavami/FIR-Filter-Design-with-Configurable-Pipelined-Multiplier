`timescale 1ns/1ns

module Signed_multiplier#(parameter WIDTH=16, parameter CONTROL_SIGNALS_WIDTH =3) (x, y, result, clk, rst, control_signals_in, control_signals_out);
    input clk, rst;
    input[WIDTH-1:0] x, y;
    input[CONTROL_SIGNALS_WIDTH-1:0] control_signals_in;
    output[CONTROL_SIGNALS_WIDTH-1:0] control_signals_out;
    output[(2*WIDTH)-1:0] result;

    wire[2*WIDTH-1:0] x_sign_extended, y_sign_extended;
    wire[4*WIDTH-1:0] result_extended;
    assign x_sign_extended = {{WIDTH{x[WIDTH-1]}}, x};
    assign y_sign_extended = {{WIDTH{y[WIDTH-1]}}, y};
    Array_mult_pipelined#(.WIDTH(2*WIDTH), .CONTROL_SIGNALS_WIDTH(CONTROL_SIGNALS_WIDTH)) mult (.x(x_sign_extended),
                          .y(y_sign_extended), .result(result_extended), .clk(clk), .rst(rst),
                          .control_signals_in(control_signals_in), .control_signals_out(control_signals_out));
    assign result = result_extended[2*WIDTH-1:0];

endmodule
