module shiftReg_nbit(input16, clk, neg_reset, output16);
    input clk
    input neg_reset
    input [15:0] input8
    output [15:0] output8
    always @(posedge clk, negedge neg_reset)
    begin
        if(reset == 0)
            output16 <= 16'b0;
        else
            output16 <= input16;
    end
endmodule

