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
    wire [7:0] mult_a [0:8];
    wire [7:0] mult_b [0:8];
wire [15:0] prod [0:8]; 
reg [17:0] acc [0:8];     

    
mux3_1 a0 (k, A[0], A[1], A[2], mult_a[0]);
mux3_1 b0 (k, B[0], B[3], B[6], mult_b[0]);
multiplier u0 (mult_a[0], mult_b[0], prod[0]);

mux3_1 a1 (k, A[0], A[1], A[2], mult_a[1]);
mux3_1 b1 (k, B[1], B[4], B[7], mult_b[1]);
multiplier u1 (mult_a[1], mult_b[1], prod[1]);

mux3_1 a2 (k, A[0], A[1], A[2], mult_a[2]);
mux3_1 b2 (k, B[2], B[5], B[8], mult_b[2]);
multiplier u2 (mult_a[2], mult_b[2], prod[2]);

mux3_1 a3 (k, A[3], A[4], A[5], mult_a[3]);
mux3_1 b3 (k, B[0], B[3], B[6], mult_b[3]);
multiplier u3 (mult_a[3], mult_b[3], prod[3]);

mux3_1 a4 (k, A[3], A[4], A[5], mult_a[4]);
mux3_1 b4 (k, B[1], B[4], B[7], mult_b[4]);
multiplier u4 (mult_a[4], mult_b[4], prod[4]);

mux3_1 a5 (k, A[3], A[4], A[5], mult_a[5]);
mux3_1 b5 (k, B[2], B[5], B[8], mult_b[5]);
multiplier u5 (mult_a[5], mult_b[5], prod[5]);

mux3_1 a6 (k, A[6], A[7], A[8], mult_a[6]);
mux3_1 b6 (k, B[0], B[3], B[6], mult_b[6]);
multiplier u6 (mult_a[6], mult_b[6], prod[6]);

mux3_1 a7 (k, A[6], A[7], A[8], mult_a[7]);
mux3_1 b7 (k, B[1], B[4], B[7], mult_b[7]);
multiplier u7 (mult_a[7], mult_b[7], prod[7]);

mux3_1 a8 (k, A[6], A[7], A[8], mult_a[8]);
mux3_1 b8 (k, B[2], B[5], B[8], mult_b[8]);
multiplier u8 (mult_a[8], mult_b[8], prod[8]);


always @(posedge clk or negedge reset) 
begin
    if (!reset) 
    begin
        k <= 0;
        done <= 0;
        for (int idx = 0; idx < 9; idx = idx + 1) 
        begin
            acc[idx] <= 0;
            C[idx]   <= 0;
        end
    end 
    else if (enable) 
    begin
        if (k < 2)
        begin
            for (int idx = 0; idx < 9; idx = idx + 1) 
            begin
               acc[idx] <= acc[idx] + prod[idx];
            end
            k <= k + 1;
            done <= 0;
        end 
        else if (k == 2) 
        begin
            for (int idx = 0; idx < 9; idx = idx + 1) 
            begin
                C[idx] <= acc[idx] + prod[idx];
                acc[idx] <= 0;  
            end
            done <= 1; 
            k <= 3;
        end
    end
    else
    begin
        k <= 0;
        done <= 0;
        for (int idx = 0; idx < 9; idx = idx + 1) 
        begin
            acc[idx] <= 0;
        end
    end
end

endmodule





    
  
