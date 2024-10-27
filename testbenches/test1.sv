`timescale  1ns/1ns

module test1();
    reg clk = 1'b0, reset = 1'b0, input_valid, output_valid, ready_for_input;
    reg[15:0] FIR_input=0;
    wire[37:0] FIR_output;

    FIR_filter #(.WIDTH(16), .LENGHT(64)) filter
                (.clk(clk), .reset(reset), .FIR_input(FIR_input), .input_valid(input_valid),
                 .FIR_output(FIR_output), .output_valid(output_valid), .ready_for_input(ready_for_input));
    
    reg[15:0] inputs [0:221183];
    reg[37:0] expected_values [0:221183];
    integer output_file;

    initial begin
        $readmemb("inputs.txt", inputs);
        $readmemb("outputs.txt", expected_values);
    end

    always begin
        #10 clk <= ~clk;
    end

    initial begin
        output_file = $fopen("FIR_output.txt");
        #2 reset = 1'b1; // active high reset
           input_valid = 1'b0;
        #5 reset = 1'b0;
        for(int i=0 ; i<100 ; i++)begin
            #60 FIR_input = inputs[i];
                input_valid = 1'b1;
            #40 input_valid = 1'b0;
            @(posedge output_valid)begin
                $fwrite(output_file, "%b\n", FIR_output);
                if(FIR_output != expected_values[i])begin
                    $display("Error in sample %d \n the output is : %b and the expected output is : %b", i+1, FIR_output, expected_values[i]);
                end
                else begin
                    $display("pass sample %d \n the output is : %b and the expected output is : %b", i+1, FIR_output, expected_values[i]);
                end
            end
        end
        $fclose(output_file);
        #20 $stop;
    end
endmodule
