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

parameter INPUT = 2'd0, COMPUTE = 2'd1, OUTPUT = 2'd2, DONE = 2'd3;
reg [1:0] state, next_state;
wire input_en, calc_en, output_en;
wire input_done, calc_done, output_done;
wire data_valid;

assign data_valid = uio_in[0];

    
always @(*)
begin
    next_state = state;
    case (state)
            INPUT:   if (input_done) next_state = COMPUTE;
            COMPUTE: if (calc_done) next_state = OUTPUT;
            OUTPUT:  if (output_done) next_state = DONE;
            DONE:    next_state = DONE;
    endcase
end
    
always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) state <= INPUT;
    else state <= next_state;
end

    
assign input_en  = (state == INPUT);
assign calc_en   = (state == COMPUTE);
assign output_en = (state == OUTPUT);

// Flattened array signals (individual wires for Yosys compatibility)
wire [7:0] A0, A1, A2, A3, A4, A5, A6, A7, A8;
wire [7:0] B0, B1, B2, B3, B4, B5, B6, B7, B8;
wire [17:0] C0, C1, C2, C3, C4, C5, C6, C7, C8;
wire [7:0] out_data;
wire out_valid;
    
assign uo_out = out_data;
assign uio_out[0] = out_valid;
assign uio_out[7:1] = 7'b0;

input_module u_input (
    .clk(clk),
    .reset(rst_n),
    .data_in(ui_in),
    .enable(input_en),
    .data_valid(data_valid),
    .done(input_done),
    .A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .A5(A5), .A6(A6), .A7(A7), .A8(A8),
    .B0(B0), .B1(B1), .B2(B2), .B3(B3), .B4(B4), .B5(B5), .B6(B6), .B7(B7), .B8(B8)
);

matrix_mult u_matrix_mult (
    .clk(clk),
    .reset(rst_n),
    .enable(calc_en),
    .A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .A5(A5), .A6(A6), .A7(A7), .A8(A8),
    .B0(B0), .B1(B1), .B2(B2), .B3(B3), .B4(B4), .B5(B5), .B6(B6), .B7(B7), .B8(B8),
    .C0(C0), .C1(C1), .C2(C2), .C3(C3), .C4(C4), .C5(C5), .C6(C6), .C7(C7), .C8(C8),
    .done(calc_done)
);

output_module u_output (
    .clk(clk),
    .reset(rst_n),
    .enable(output_en),
    .C0(C0), .C1(C1), .C2(C2), .C3(C3), .C4(C4), .C5(C5), .C6(C6), .C7(C7), .C8(C8),
    .out_data(out_data),
    .out_valid(out_valid),
    .done(output_done)
);

assign uio_oe = 8'b1;
    wire _unused = &{ena, uio_in[7:1], 1'b0};
endmodule
