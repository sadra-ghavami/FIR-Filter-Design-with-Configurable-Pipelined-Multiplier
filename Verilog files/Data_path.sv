`timescale 1ns/1ns

module Data_path #(parameter WIDTH = 16, parameter LENGHT = 64)
       (clk, reset, inp, result, load_input, clr_input, clr_counter, inc_counter, counter_co, load_result, clr_result, output_valid, output_valid_out);
    
    parameter OUTPUT_WIDTH = 2*WIDTH + $clog2(LENGHT);
    parameter COUNTER_SIZE = $clog2(LENGHT);

    input clk, reset, load_input, clr_input, clr_counter, inc_counter, load_result, clr_result, output_valid;
    output counter_co, output_valid_out;
    input[WIDTH-1:0] inp;
    output[OUTPUT_WIDTH-1:0] result;

    wire co;
    wire[2*WIDTH-1:0] mult_out;
    wire[OUTPUT_WIDTH-1:0] adder_in, adder_out;
    wire[COUNTER_SIZE-1:0] counter_out;
    wire[WIDTH-1:0] MUX_out, coeffs, mult_in1, mult_in2;
    wire[WIDTH-1:0] x [0:LENGHT];
    wire[OUTPUT_WIDTH-1:0] temp_result;
    wire[2:0] control_reg_in, control_reg_out, control_signals_mult_out;

    assign control_reg_in[0] = load_result;
    assign control_reg_in[1] = clr_result;
    assign control_reg_in[2] = output_valid;

    genvar reg_var;
    assign x[0] = inp;
    generate
        for(reg_var=0 ; reg_var < LENGHT ; reg_var = reg_var+1)begin : input_registers
            Register #(.WIDTH(WIDTH)) inp_reg
                      (.par_in(x[reg_var]), .par_out(x[reg_var+1]), .clk(clk), .reset(reset), .load(load_input), .clear(clr_input));
        end: input_registers
    endgenerate 

    MUX #(.WIDTH(WIDTH), .INPUT_NUM(LENGHT)) multiplexer
         (.inputs(x[1:LENGHT]), .out_put(MUX_out), .select(counter_out));

    Counter #(.COUNT_NUM(LENGHT)) cnt
             (.clk(clk), .reset(reset), .counter(counter_out), .increament(inc_counter), .clear(clr_counter), .Co(counter_co));

    Register_files #(.WIDTH(WIDTH), .LENGTH(LENGHT)) reg_file
                    (.address(counter_out), .out_put(coeffs));

    Pipe_register #(.WIDTH(WIDTH)) mux_out_reg (.clk(clk), .rst(reset), .par_in(MUX_out), .par_out(mult_in2));
    Pipe_register #(.WIDTH(WIDTH)) coeff_reg(.clk(clk), .rst(reset), .par_in(coeffs), .par_out(mult_in1));
    Pipe_register #(.WIDTH(3)) control_reg(.clk(clk), .rst(reset), .par_in(control_reg_in), .par_out(control_reg_out));

    Signed_multiplier #(.WIDTH(WIDTH), .CONTROL_SIGNALS_WIDTH(3)) multiplier(.clk(clk), .rst(reset), .x(mult_in1), .y(mult_in2),
                        .result(mult_out), .control_signals_in(control_reg_out), .control_signals_out(control_signals_mult_out));

    assign adder_in = { {(OUTPUT_WIDTH-2*WIDTH){mult_out[2*WIDTH-1]}} , mult_out};

    Adder #(.INPUT_WIDTH(OUTPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH)) adder
           (.input_1(adder_in), .input_2(result), .out_put(adder_out));

    Register #(.WIDTH(OUTPUT_WIDTH)) result_reg
              (.par_in(adder_out), .par_out(result), .clk(clk), .reset(reset), .load(control_signals_mult_out[0]), .clear(control_signals_mult_out[1]));  

    assign output_valid_out = control_signals_mult_out[2];

endmodule
