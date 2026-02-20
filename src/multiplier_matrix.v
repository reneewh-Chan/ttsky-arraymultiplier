module matrix_mult_core_top (
    input wire clk,                    
    input wire reset,             
    input wire enable,                  
    input wire [7:0] A [0:8],         
    input wire [7:0] B [0:8],         
    output reg [17:0] C [0:8], 
    output reg done               
);

  
