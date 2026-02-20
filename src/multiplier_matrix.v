module matrix_mult (
    input wire clk,                    
    input wire reset,             
    input wire enable,                  
    input wire [7:0] A [0:8],         
    input wire [7:0] B [0:8],         
    output reg [17:0] C [0:8], 
    output reg done               
);
    
reg [1:0] k;                                   

wire [15:0] prod [0:8]; 

3-to-1

always @(posedge clk or negedge rst_n) 
begin
    if (!reset) 
    begin
        k <= 0;
        done <= 0;
    end 
    else if (enable) 
    begin
        k <= 0;
        done <= 0;
    end 
    if (k < 2) 
    begin

    k <= k + 1;
    end 
    else if (k == 2) 
    begin

    
        done <= 1;  
    end
    end

endmodule





    
  
