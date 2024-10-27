`timescale 1ns/1ns

module MUX_testbench();
    reg [2:0] select;
    wire[31:0] out_put;
    reg [31:0] inputs [0:4];
    genvar i;
    generate
        for(i=0 ; i<4; i = i+1) begin
           assign inputs[i] = i; 
        end
    endgenerate
    /*
    assign inputs[0] = 32'b0;
    assign inputs[1] = 32'd1;
    assign inputs[2] = 32'd2;
    assign inputs[3] = 32'd3;
    */
    MUX #(.WIDTH(32), .INPUT_NUM(5))
        test_mux(.inputs(inputs), .select(select), .out_put(out_put));

    initial begin
        #5 select = 3'b0;
        #5 select = 3'h1;
        #5 select = 3'h2;
        #5 select = 3'h3;
        #5 select = 3'h4;
        #5 inputs[4] = 32'b0;
        #5 $stop;
    end    

endmodule
