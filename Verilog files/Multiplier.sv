`timescale 1ns/1ns

module Multiplier#(parameter WIDTH)
       (inp1, inp2, out_put, start, done, clk, reset);

    input signed[WIDTH-1:0] inp1, inp2;
    input start, clk, reset;
    output reg[2*WIDTH-1:0] out_put;
    output reg done;

    reg[2:0] ps, ns;
    reg signed [2*WIDTH-1:0] temp_result;
    assign temp_result = inp1 * inp2;

    always@(posedge clk, negedge reset) begin
        if(reset == 1'b0)begin
            ps <= 3'b0;
        end
        else begin
            ps <= ns;
        end
    end

    always@(ps, start)begin
        ns <= 3'd0;
        case(ps)
            3'b000: ns <= start ? 3'b001 : 3'b000;
            3'b001: ns <= 3'b010;
            3'b010: ns <= 3'b011;
            3'b011: ns <= 3'b100;
            3'b100: ns <= 3'b101;
            3'b101: ns <= 3'b000;
            default: ns <= 3'b000;
        endcase
    end

    always@(ps)begin
        //out_put <= 0;
        done <= 1'b0;
        case(ps)
            3'b101: begin
                        done <= 1'b1;
                        out_put <= temp_result;
            end
            default: done <= 1'b0;
        endcase
    end
endmodule
