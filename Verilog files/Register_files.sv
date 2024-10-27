`timescale 1ns/1ns

module Register_files#(parameter WIDTH = 16, parameter LENGTH = 6) 
        (address, out_put);

    parameter ADDRESS_BIT = $clog2(LENGTH);
    input[ADDRESS_BIT-1:0] address;
    output[WIDTH-1:0] out_put;

    reg signed [WIDTH - 1:0] data [0:LENGTH-1];

    initial
	    begin
		    $readmemb("coeffs.txt",data);
		    /*for( int j = 0 ; j < LENGTH ; j++)
			    data[j] = 0;
            */
	    end

    assign out_put = data[address];
  

endmodule
