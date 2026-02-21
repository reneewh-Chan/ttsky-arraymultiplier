module input_module(
    input wire        clk,      
    input wire        reset,      
    input wire [7:0]  data_in,  
    input wire        enable,
    input wire        data_valid,
    output reg        done,   
    output reg [7:0]  A0, A1, A2, A3, A4, A5, A6, A7, A8,
    output reg [7:0]  B0, B1, B2, B3, B4, B5, B6, B7, B8
);

    reg [4:0] count;

always @(posedge clk or negedge reset)
begin
    if (!reset) 
    begin
        count <= 0;
        done <= 0;
        A0 <= 8'd0; A1 <= 8'd0; A2 <= 8'd0; A3 <= 8'd0; A4 <= 8'd0;
        A5 <= 8'd0; A6 <= 8'd0; A7 <= 8'd0; A8 <= 8'd0;
        B0 <= 8'd0; B1 <= 8'd0; B2 <= 8'd0; B3 <= 8'd0; B4 <= 8'd0;
        B5 <= 8'd0; B6 <= 8'd0; B7 <= 8'd0; B8 <= 8'd0;
    end 
    else if (enable && data_valid && !done) 
    begin
        case (count)
            5'd0:  A0 <= data_in;
            5'd1:  A1 <= data_in;
            5'd2:  A2 <= data_in;
            5'd3:  A3 <= data_in;
            5'd4:  A4 <= data_in;
            5'd5:  A5 <= data_in;
            5'd6:  A6 <= data_in;
            5'd7:  A7 <= data_in;
            5'd8:  A8 <= data_in;
            5'd9:  B0 <= data_in;
            5'd10: B1 <= data_in;
            5'd11: B2 <= data_in;
            5'd12: B3 <= data_in;
            5'd13: B4 <= data_in;
            5'd14: B5 <= data_in;
            5'd15: B6 <= data_in;
            5'd16: B7 <= data_in;
            5'd17: B8 <= data_in;
        endcase
        
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
