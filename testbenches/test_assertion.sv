`timescale 1ns/1ns

module test_assertion();

    reg clk = 1'b0, reset = 1'b0, input_valid, output_valid, ready_for_input;
    reg[15:0] FIR_input=0;
    wire[37:0] FIR_output;

    FIR_filter #(.WIDTH(16), .LENGHT(5)) filter
                (.clk(clk), .reset(reset), .FIR_input(FIR_input), .input_valid(input_valid),
                 .FIR_output(FIR_output), .output_valid(output_valid), .ready_for_input(ready_for_input));
    
    reg[15:0] inputs [0:221183];
    reg[37:0] expected_values [0:221183];
    integer output_file;

    always begin
        #10 clk <= ~clk;
    end


    initial begin
        $readmemb("inputs.txt", inputs);
        $readmemb("outputs.txt", expected_values);
    end

    Loading : assert property (@(posedge clk) filter.load_input |=> filter.load_result)begin
                $display($stime,,,"\t\ttime  %m\nPASS: transition from loading to calculation state");
            end
            else begin
                 $display($stime,,,"\t\ttime:  %m\nFAIL: transition from loading to calculation state");
            end

    counter: assert property (@(posedge clk) filter.load_input |-> ##5 filter.counter_co) begin
                $display($stime,,,"\t\ttime %m\nPASS: Counter cout has been asserted after 5 clock cycle");
            end
            else begin
                $display($stime,,,"\t\ttime %m\nFAIL: Counter cout hasn't been asserted yet after 5 clock cycle");
            end

    Clear_result: assert property (@(posedge clk) filter.output_valid_interconnect |=> (filter.ready_for_input and filter.clr_result)) begin
            $display($stime,,,"\t\ttime  %m\nPASS: finish calculation -> waiting for new data");
        end
        else begin
            $display($stime,,,"\t\ttime  %m\nFail: finish calculation -> waiting for new data");
        end

    output_valid_pipeline: assert property (@(posedge clk) filter.output_valid_interconnect |-> ##64 output_valid) begin
        $display($stime,,, "\t\ttime %m\nPipeline works correctly");
    end
    else begin
        $display($stime,,, "\t\ttime %m\nPipeline doesn't work correctly");
    end

    //assertion for transition between loading and calculation states in controller
    sequence high_co_in_calculation_state;
        (filter.control.present_state == filter.control.CALCULATION_STATE) and filter.counter_co;
    endsequence

    sequence low_co_in_calculation_state;
        (filter.control.present_state == filter.control.CALCULATION_STATE) and (filter.counter_co == 1'b0);
    endsequence

    sequence calculation_state_to_output;
        high_co_in_calculation_state ##1 filter.control.present_state == filter.control.OUTPUT_STATE; 
    endsequence

    sequence calculation_state_to_itself;
        low_co_in_calculation_state ##1 filter.control.present_state == filter.control.CALCULATION_STATE; 
    endsequence

    property loading_and_calculation_state;
        @(posedge clk) (filter.control.present_state == filter.control.LOADING_STATE) |=> calculation_state_to_output or calculation_state_to_itself;
    endproperty
        
    loading_to_calculation_state: assert property(loading_and_calculation_state) begin
        $display($stime,,,"\t\ttime  %m\nPASS: transition between loading and calculating state");
    end
    else begin
        $display($stime,,,"\t\ttime  %m\nPASS: transition between loading and calculating state");
    end
    //end assertion

    integer i;
    initial begin
        #2 reset = 1'b1; // active high reset
           input_valid = 1'b0;
        #5 reset = 1'b0;
        for(i=0; i<20; i++)begin
            #20 FIR_input = inputs[i];
                input_valid = 1'b1;
            #60 input_valid = 1'b0;
            @(posedge ready_for_input);
        end
        #20 $stop;
    end

endmodule