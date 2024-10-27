`timescale 1ns/1ns

module Pipe_register#(parameter WIDTH)(clk, rst, par_in, par_out);
    input clk, rst;
    input[WIDTH-1:0] par_in;
    output reg[WIDTH-1:0] par_out;

    always @(posedge clk, posedge rst) begin
        if(rst)begin
            par_out <= 0;
        end
        else begin
            par_out <= par_in;
        end
    end
endmodule