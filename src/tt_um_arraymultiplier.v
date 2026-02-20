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

wire [7:0] A [0:8];               
wire [7:0] B [0:8]; 
wire [17:0] C [0:8];
wire [7:0] out_data;
wire out_valid;

<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    input_module i(clk, rst_n, ui_in, input_en, data_valid, input_done, A, B);
    matrix_mult m(clk, rst_n, calc_en, A, B, C, calc_done);
    output_module o(clk, rst_n, output_en, C, out_data, out_valid, output_done);
    
assign uo_out = out_data;
assign uio_out[0] = out_valid;
assign uio_out[7:1] = 7'b0;
=======
assign uo_out = out_data;
=======
assign uo_out = out_data;
=======
assign uo_out = out_data;

input_module u_input (
    .clk(clk),
    .reset(rst_n),
    .data_in(ui_in),
    .enable(input_en),
    .data_valid(data_valid),
    .done(input_done),
    .A(A),
    .B(B)
);

matrix_mult u_matrix_mult (
    .clk(clk),
    .reset(rst_n),
    .enable(calc_en),
    .A(A),
    .B(B),
    .C(C),
    .done(calc_done)
);

output_module u_output (
    .clk(clk),
    .reset(rst_n),
    .enable(output_en),
    .C(C),
    .out_data(out_data),
    .out_valid(out_valid),
    .done(output_done)
);
>>>>>>> Stashed changes

input_module u_input (
    .clk(clk),
    .reset(rst_n),
    .data_in(ui_in),
    .enable(input_en),
    .data_valid(data_valid),
    .done(input_done),
    .A(A),
    .B(B)
);

matrix_mult u_matrix_mult (
    .clk(clk),
    .reset(rst_n),
    .enable(calc_en),
    .A(A),
    .B(B),
    .C(C),
    .done(calc_done)
);

output_module u_output (
    .clk(clk),
    .reset(rst_n),
    .enable(output_en),
    .C(C),
    .out_data(out_data),
    .out_valid(out_valid),
    .done(output_done)
);
>>>>>>> Stashed changes

input_module u_input (
    .clk(clk),
    .reset(rst_n),
    .data_in(ui_in),
    .enable(input_en),
    .data_valid(data_valid),
    .done(input_done),
    .A(A),
    .B(B)
);

matrix_mult u_matrix_mult (
    .clk(clk),
    .reset(rst_n),
    .enable(calc_en),
    .A(A),
    .B(B),
    .C(C),
    .done(calc_done)
);

output_module u_output (
    .clk(clk),
    .reset(rst_n),
    .enable(output_en),
    .C(C),
    .out_data(out_data),
    .out_valid(out_valid),
    .done(output_done)
);

>>>>>>> Stashed changes

assign uio_oe = 8'b1;
    wire _unused = &{ena, uio_in[7:1], 1'b0};
endmodule
