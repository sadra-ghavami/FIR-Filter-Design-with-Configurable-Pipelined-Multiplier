`timescale 1ns/1ns

module Counter #(parameter COUNT_NUM = 64)
       (clk, reset, counter, increament, clear, Co);

    localparam COUNTER_BIT = $clog2(COUNT_NUM);
    localparam LOAD_NUMBER = (2**COUNTER_BIT) - COUNT_NUM;

    input clk, reset, increament, clear;
    output [COUNTER_BIT-1:0] counter;
    output Co;

    reg[COUNTER_BIT-1:0] temp_counter;
    
    always@(posedge clk, posedge reset) begin
        if(reset)begin
            temp_counter <= LOAD_NUMBER;
        end
        else if(clear)begin
            temp_counter <= LOAD_NUMBER;
        end
        else if(increament)begin
            temp_counter <= temp_counter + 1;
        end
    end

    assign Co = &{temp_counter};
    assign counter = temp_counter - LOAD_NUMBER;

endmodule
