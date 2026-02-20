/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_arraymultiplier (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

parameter IDLE = 3'd0, INPUT = 3'd1, COMPUTE = 3'd2, OUTPUT = 3'd3, DONE = 3'd4;
reg [2:0] state, next_state;
wire input_en, calc_en, output_en;
wire start, input_done, calc_done, output_done;

assign uio_oe = 8'b1;
wire data_valid = uio_in[0];
assign start = uio_in[1]; 
    
always @(*)
begin
    next_state = state;
    case (state)
            IDLE:    if (start) next_state = INPUT;
            INPUT:   if (input_done) next_state = COMPUTE;
            COMPUTE: if (calc_done) next_state = OUTPUT;
            OUTPUT:  if (output_done) next_state = DONE;
            DONE:    next_state = DONE;
    endcase
end
    
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) state <= IDLE;
    else state <= next_state;
end

    
assign input_en  = (state == INPUT);
assign calc_en   = (state == COMPUTE);
assign output_en = (state == OUTPUT);

wire [7:0] A [0:8];               
wire [7:0] B [0:8]; 
wire [17:0] C [0:8];    

input_module()
calculation()
output_module()

// List all unused inputs to prevent warnings
wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
