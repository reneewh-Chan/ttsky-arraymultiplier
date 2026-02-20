module input_module(
    input wire        clk,      
    input wire        reset,      
    input wire [7:0]  data_in,     
    input wire        data_valid,
    output reg        done,   
    output reg [7:0]  A [0:8], 
    output reg [7:0]  B [0:8]
);

    reg [4:0] count;

always @(posedge clk or negedge reset)
begin
    if (!reset) 
    begin
        count <= 0;
        done <= 0;
        for (int i = 0; i < 9; i++) 
        begin
            A[i] <= 8'd0;
            B[i] <= 8'd0;
        end
    end 
    else if (data_valid && !done) 
    begin
        if (count <= 8)
        begin
            A[count] <= data_in;
        end
        else
        begin
            B[count - 9] <= data_in;
        end
        
        if (count == 17) 
        begin
            done <= 1'b1;
        end 
        else 
        begin
            count <= count + 1;
        end
    end
end

endmodule



