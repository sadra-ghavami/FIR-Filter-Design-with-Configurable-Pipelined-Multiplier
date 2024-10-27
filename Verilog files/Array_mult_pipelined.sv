`timescale 1ns/1ns

module Array_mult_pipelined#(parameter WIDTH, parameter CONTROL_SIGNALS_WIDTH) (x, y, result, clk, rst, control_signals_in, control_signals_out);
    input clk, rst;
    input[WIDTH-1:0] x, y;
    input[CONTROL_SIGNALS_WIDTH-1:0] control_signals_in;
    output[CONTROL_SIGNALS_WIDTH-1:0] control_signals_out;
    output[(2*WIDTH)-1:0] result;


    //pipeline registers
    wire [WIDTH-1:0] x_reg [0:WIDTH-1];
    wire [WIDTH-1:0] y_reg [0:WIDTH-1];
    wire[CONTROL_SIGNALS_WIDTH-1:0] control_regs [0:2*WIDTH-1];
    wire [(2*WIDTH)-1:0] result_regs_input[0:2*WIDTH-2];
    wire [(2*WIDTH)-1:0] result_regs_output[0:2*WIDTH-1];
    wire [WIDTH-2:0]carry_regs_input[0:2*WIDTH-2];
    wire [WIDTH-2:0]carry_regs_output[0:2*WIDTH-2];

    genvar i;
    assign x_reg[0] = x;
    assign y_reg[0] = y;
    assign control_regs[0] = control_signals_in;
    assign carry_regs_output[0] = 0;
    generate
        assign result_regs_output[0][2*WIDTH-1] = 1'b0;

        for (i=0 ; i<2*WIDTH-1 ; i=i+1) begin: bind_result_registers
           Pipe_register#(.WIDTH(2*WIDTH)) result_registers(.clk(clk), .rst(rst), .par_in(result_regs_input[i]), .par_out(result_regs_output[i+1]));
           Pipe_register#(.WIDTH(CONTROL_SIGNALS_WIDTH)) control_registers(.clk(clk), .rst(rst), .par_in(control_regs[i]), .par_out(control_regs[i+1]));
        end:bind_result_registers

        for(i=0 ; i<2*WIDTH-2; i=i+1)begin: bind_carry_registers
            Pipe_register#(.WIDTH(WIDTH-1)) carry_registers(.clk(clk), .rst(rst), .par_in(carry_regs_input[i]), .par_out(carry_regs_output[i+1]));
        end: bind_carry_registers

        for(i=0; i<WIDTH-1; i=i+1)begin: bind_x_y_registers
            Pipe_register#(.WIDTH(WIDTH)) x_register(.clk(clk), .rst(rst), .par_in(x_reg[i]), .par_out(x_reg[i+1]));
            Pipe_register#(.WIDTH(WIDTH)) y_register(.clk(clk), .rst(rst), .par_in(y_reg[i]), .par_out(y_reg[i+1]));
        end: bind_x_y_registers

        for(i=0 ; i<WIDTH ; i=i+1)begin: AND_gates
            assign result_regs_output[0][i] = x_reg[0][0] & y_reg[0][i];
        end: AND_gates

        for(i=WIDTH; i<2*WIDTH-1; i++)begin: result_propagation
            assign result_regs_output[0][i] = x_reg[0][i-WIDTH+1] & y_reg[0][WIDTH-1];
        end: result_propagation
    endgenerate
    //

    //Full adders
    genvar j,k;
    generate
        assign result_regs_input[WIDTH-1][2*WIDTH-1] = result_regs_output[WIDTH-1][2*WIDTH-1];

        for(j=0; j<WIDTH-1; j=j+1)begin: First_Part_FA_outer_loop

            for(k=0; k<WIDTH-1; k=k+1)begin: Fisrt_part_FA_inner_loop
                Full_adder full_adders(.a(x_reg[j][j+1]&y_reg[j][k]), .b(result_regs_output[j][k+j+1]), .sum(result_regs_input[j][k+j+1]), .cin(carry_regs_output[j][k]), .cout(carry_regs_input[j][k]));
            end: Fisrt_part_FA_inner_loop

            for(k=0; k<=j; k=k+1)begin: result_propagation_1_1
                assign result_regs_input[j][k] = result_regs_output[j][k];
            end: result_propagation_1_1

            for(k=WIDTH+j; k<2*WIDTH; k=k+1)begin: result_propagation_1_2
                assign result_regs_input[j][k] = result_regs_output[j][k];
            end: result_propagation_1_2

        end: First_Part_FA_outer_loop
        //
        
        for(j=0; j<WIDTH-1; j=j+1)begin: Mid_FA
            Full_adder mid_column(.a(result_regs_output[WIDTH-1][j+WIDTH]), .b(1'b0), .cin(carry_regs_output[WIDTH-1][j]), .cout(carry_regs_input[WIDTH-1][j]), .sum(result_regs_input[WIDTH-1][WIDTH+j]));
        end: Mid_FA

        for(j=0; j<WIDTH; j=j+1)begin: Mid_result_propagation
            assign result_regs_input[WIDTH-1][j] = result_regs_output[WIDTH-1][j]; 
        end: Mid_result_propagation

        //
        for(j=0; j<WIDTH-1; j=j+1)begin: second_part_FA
            for(k=0; k<WIDTH-1-j; k=k+1)begin: Last_part_FA
                Full_adder last_part(.a(result_regs_output[WIDTH+j][WIDTH+1+k+j]), .b(1'b0), .cin(carry_regs_output[WIDTH+j][k]), .cout(carry_regs_input[WIDTH+j][k]), .sum(result_regs_input[WIDTH+j][WIDTH+1+k+j]));
            end: Last_part_FA
            
            for(k=0; k<WIDTH+1+j; k=k+1)begin:result_propagation_2
                assign result_regs_input[WIDTH+j][k] = result_regs_output[WIDTH+j][k];
            end:result_propagation_2

        end: second_part_FA

    endgenerate

    assign result = result_regs_output[2*WIDTH-1];
    assign control_signals_out = control_regs[2*WIDTH-1];
    
endmodule
