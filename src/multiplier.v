module multiplier(clk, reset, A, B, prod);
    input clk, reset;
    input [7:0] A, B;
    output reg [15:0] prod;

    reg [7:0] num;
    reg [7:0] multiplier;
    reg [3:0] count;

    always @(posedge clk or negedge reset)
    begin
        if (!reset)
        begin
            prod <= 16'b0;
            num <= 8'b0;
            multiplier <= 8'b0;
            count <= 4'b0;
        end
        else
        begin
            if (count == 0)
            begin
                num <= A;
                multiplier <= B;
                Product <= 16'b0;
                count <= 4'b1000;
            end
            else
            begin
                if (multiplier[0] == 1'b1)
                    Product <= Product + num;

                num <= num << 1;
                multiplier <= multiplier >> 1;
                count <= count - 1;
            end
        end
    end
endmodule

