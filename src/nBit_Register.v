module nBit_register(
    input reg input8, 
    input wire clk, 
    input wire reset, 
    output wire output8);
    always_ff(posedge clk)
    begin
        if(reset == 0)
            output8 <= 1'b00000000;
        else
            output8 <= input8;
    end
endmodule
