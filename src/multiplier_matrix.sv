module matrix_mult (
    input wire clk,                    
    input wire reset,             
    input wire enable,                  
    input wire [7:0] A0, A1, A2, A3, A4, A5, A6, A7, A8,
    input wire [7:0] B0, B1, B2, B3, B4, B5, B6, B7, B8,
    output reg [17:0] C0, C1, C2, C3, C4, C5, C6, C7, C8,
    output reg done               
);
    
reg [1:0] k;                                   
wire [7:0] mult_a0, mult_a1, mult_a2, mult_a3, mult_a4, mult_a5, mult_a6, mult_a7, mult_a8;
wire [7:0] mult_b0, mult_b1, mult_b2, mult_b3, mult_b4, mult_b5, mult_b6, mult_b7, mult_b8;
wire [15:0] prod0, prod1, prod2, prod3, prod4, prod5, prod6, prod7, prod8;
reg [17:0] acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8;

// Matrix multiplication units    
mux3_1 a0 (k, A0, A1, A2, mult_a0); // first row of A
mux3_1 b0 (k, B0, B3, B6, mult_b0); // first column of B
multiplier u0 (mult_a0, mult_b0, prod0);

mux3_1 a1 (k, A0, A1, A2, mult_a1); // first row of A
mux3_1 b1 (k, B1, B4, B7, mult_b1); // second column of B
multiplier u1 (mult_a1, mult_b1, prod1);

mux3_1 a2 (k, A0, A1, A2, mult_a2); // first row of A
mux3_1 b2 (k, B2, B5, B8, mult_b2); // third column of B
multiplier u2 (mult_a2, mult_b2, prod2);

mux3_1 a3 (k, A3, A4, A5, mult_a3); // second row of A
mux3_1 b3 (k, B0, B3, B6, mult_b3); // first column of B
multiplier u3 (mult_a3, mult_b3, prod3); 

mux3_1 a4 (k, A3, A4, A5, mult_a4); // second row of A
mux3_1 b4 (k, B1, B4, B7, mult_b4); // second column of B
multiplier u4 (mult_a4, mult_b4, prod4);

mux3_1 a5 (k, A3, A4, A5, mult_a5); // second row of A
mux3_1 b5 (k, B2, B5, B8, mult_b5); // third column of B
multiplier u5 (mult_a5, mult_b5, prod5);

mux3_1 a6 (k, A6, A7, A8, mult_a6); // third row of A
mux3_1 b6 (k, B0, B3, B6, mult_b6); // first column of B
multiplier u6 (mult_a6, mult_b6, prod6);

mux3_1 a7 (k, A6, A7, A8, mult_a7); // third row of A
mux3_1 b7 (k, B1, B4, B7, mult_b7); // second column of B
multiplier u7 (mult_a7, mult_b7, prod7);

mux3_1 a8 (k, A6, A7, A8, mult_a8); // third row of A
mux3_1 b8 (k, B2, B5, B8, mult_b8); // third column of B
multiplier u8 (mult_a8, mult_b8, prod8);


always @(posedge clk or negedge reset) 
begin
    if (!reset) 
    begin
        k <= 0;
        done <= 0;
        acc0 <= 0; acc1 <= 0; acc2 <= 0; acc3 <= 0; acc4 <= 0;
        acc5 <= 0; acc6 <= 0; acc7 <= 0; acc8 <= 0;
        C0 <= 0; C1 <= 0; C2 <= 0; C3 <= 0; C4 <= 0;
        C5 <= 0; C6 <= 0; C7 <= 0; C8 <= 0;
    end 
    else if (enable) 
    begin
        if (k < 2)
        begin
            acc0 <= acc0 + prod0;
            acc1 <= acc1 + prod1;
            acc2 <= acc2 + prod2;
            acc3 <= acc3 + prod3;
            acc4 <= acc4 + prod4;
            acc5 <= acc5 + prod5;
            acc6 <= acc6 + prod6;
            acc7 <= acc7 + prod7;
            acc8 <= acc8 + prod8;
            k <= k + 1;
            done <= 0;
        end 
        else if (k == 2) 
        begin
            C0 <= acc0 + prod0;
            C1 <= acc1 + prod1;
            C2 <= acc2 + prod2;
            C3 <= acc3 + prod3;
            C4 <= acc4 + prod4;
            C5 <= acc5 + prod5;
            C6 <= acc6 + prod6;
            C7 <= acc7 + prod7;
            C8 <= acc8 + prod8;
            acc0 <= 0; acc1 <= 0; acc2 <= 0; acc3 <= 0; acc4 <= 0;
            acc5 <= 0; acc6 <= 0; acc7 <= 0; acc8 <= 0;
            done <= 1; 
            k <= 3;
        end
    end
    else
    begin
        k <= 0;
        done <= 0;
        acc0 <= 0; acc1 <= 0; acc2 <= 0; acc3 <= 0; acc4 <= 0;
        acc5 <= 0; acc6 <= 0; acc7 <= 0; acc8 <= 0;
    end
end

endmodule
