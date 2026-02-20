module input_buffer (
    input wire        clk,      
    input wire        reset,      
    input wire [7:0]  data_in,     
    input wire        data_valid，
    output reg        done,   
    output reg [7:0]  stored_data [0:17] 
);

  reg [4:0] count; 

  always @(posedge clk or negedge reset) begin
    if (!reset) begin
            count <= 0;
            done <= 0;
        end else if (data_valid && !done) begin
            stored_data[cnt] <= data_in;
            if (cnt == 17) begin
                done <= 1'b1;
                count <= count;
            end else begin
                count <= count + 1;
            end
        end
    end

endmodule
