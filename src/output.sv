module output_module (
    input wire clk,
    input wire reset,
    input wire enable,                    
    input wire [17:0] C0, C1, C2, C3, C4, C5, C6, C7, C8,
    output reg [7:0] out_data,
    output reg out_valid,         
    output reg done           
);

  reg [4:0] count;

always @(*) begin
    out_data = 8'b0;
    case (count)
        0: out_data = C0[7:0];
        1: out_data = C0[15:8];
        2: out_data = {6'b0, C0[17:16]};
        3: out_data = C1[7:0];
        4: out_data = C1[15:8];
        5: out_data = {6'b0, C1[17:16]};
        6: out_data = C2[7:0];
        7: out_data = C2[15:8];
        8: out_data = {6'b0, C2[17:16]};
        9: out_data = C3[7:0];
        10: out_data = C3[15:8];
        11: out_data = {6'b0, C3[17:16]};
        12: out_data = C4[7:0];
        13: out_data = C4[15:8];
        14: out_data = {6'b0, C4[17:16]};
        15: out_data = C5[7:0];
        16: out_data = C5[15:8];
        17: out_data = {6'b0, C5[17:16]};
        18: out_data = C6[7:0];
        19: out_data = C6[15:8];
        20: out_data = {6'b0, C6[17:16]};
        21: out_data = C7[7:0];
        22: out_data = C7[15:8];
        23: out_data = {6'b0, C7[17:16]};
        24: out_data = C8[7:0];
        25: out_data = C8[15:8];
        26: out_data = {6'b0, C8[17:16]};
        default: out_data = 8'b0;
    endcase
end

  always @(posedge clk or negedge reset) 
  begin
    if (!reset) 
    begin
        count <= 0;
        out_valid <= 1'b0;
        done <= 1'b0;
    end 
    else if (enable) 
    begin
      if (count < 27) 
      begin
          out_valid <= 1'b1;
          count <= count + 1;
          if (count == 26) 
          begin
              done <= 1'b1;      
          end 
          else 
          begin
              done <= 1'b0;
          end
      end 
      else 
      begin
          out_valid <= 1'b0;
          done <= 1'b1; 
      end
    end
    else 
    begin
        count <= 0;
        out_valid <= 1'b0;
        done <= 1'b0;
    end
  end

endmodule
