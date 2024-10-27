`timescale 1ns/1ns

module Register#(parameter WIDTH)
       (par_in, par_out, clk, reset, load, clear);

        input [WIDTH-1:0] par_in;
        input clk, reset, load, clear;
        output reg[WIDTH-1:0] par_out;

        always @(posedge clk, posedge reset) begin
            if(reset) begin //asynchornous active-low reset
                par_out <= 0; 
            end
            else if(clear) begin
                    par_out <= 0;
            end
            else if(load) begin
                    par_out <= par_in;
            end
        end

endmodule
