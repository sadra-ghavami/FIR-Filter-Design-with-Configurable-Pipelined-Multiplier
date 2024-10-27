`timescale 1ns/1ns

module Full_adder(a, b, sum, cout, cin);
    input a, b, cin;
    output cout, sum;
    assign sum = a ^ b ^ cin;
    assign cout = ((a ^ b) & cin)|(a & b); 
endmodule
