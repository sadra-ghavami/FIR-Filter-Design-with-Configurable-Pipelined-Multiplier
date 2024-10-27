`timescale 1ns/1ns

module Controller(clk, reset, input_valid, output_valid, ready_for_input, clr_input, load_input, counter_co, clr_counter, inc_counter, load_result, clr_result);
    
    input clk, reset, input_valid, counter_co;
    output reg clr_input, load_input, clr_result, load_result, clr_counter, inc_counter, output_valid, ready_for_input;

    parameter INITIAL_STATE = 3'b000;
    parameter WAIT_STATE = 3'b001;
    parameter LOADING_STATE = 3'b010;
    parameter CALCULATION_STATE = 3'b011;
    parameter OUTPUT_STATE = 3'b100;

    reg[2:0] present_state, next_state;

    always@(posedge clk, posedge reset)begin
        if(reset)begin
            present_state <= INITIAL_STATE;
        end
        else begin
            present_state <= next_state;
        end
    end

    always@(present_state, input_valid, counter_co)begin
        case(present_state)
            INITIAL_STATE: next_state <= WAIT_STATE;
            WAIT_STATE: next_state <= input_valid ? LOADING_STATE : WAIT_STATE;
            LOADING_STATE: next_state <= CALCULATION_STATE;
            CALCULATION_STATE: next_state <= counter_co ? OUTPUT_STATE : CALCULATION_STATE;
            OUTPUT_STATE: next_state <= WAIT_STATE;
            default: next_state <= INITIAL_STATE;
        endcase
    end

    always@(present_state)begin
        {clr_input, load_input, clr_result, load_result, clr_counter, inc_counter, output_valid, ready_for_input} = 8'b0;
        case(present_state)
            INITIAL_STATE: {clr_counter, clr_result, clr_input} = 3'b111;
            WAIT_STATE: {clr_result, ready_for_input} = 2'b11;
            LOADING_STATE: load_input = 1'b1;
            CALCULATION_STATE: {load_result, inc_counter} = 2'b11;
            OUTPUT_STATE: {clr_counter, output_valid} = 2'b11;
            default: {clr_input, load_input, clr_result, load_result, clr_counter, inc_counter, output_valid, ready_for_input} = 8'b0;
        endcase
    end
endmodule
