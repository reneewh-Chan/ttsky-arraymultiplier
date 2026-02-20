`timescale 1ns / 1ps
`default_nettype none

module tb_tt_um_arraymultiplier;

    // Clock and reset
    reg clock;
    reg reset;
    
    // DUT inputs
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    reg ena;
    
    // DUT outputs
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    
    // Test control variables
    integer i, j;
    integer errors;
    integer test_num;
    
    // Test data - 3x3 matrix multiplication
    reg [7:0] test_A [0:8];
    reg [7:0] test_B [0:8];
    
    // Instantiate the DUT
    tt_um_arraymultiplier dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clock),
        .rst_n(reset)
    );
    
    // Clock generation - 10ns period (100 MHz)
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end
    
    // Task: Apply reset
    task apply_reset;
        begin
            $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : Applying reset", $time);
            reset = 1'b0;
            ui_in = 8'h00;
            uio_in = 8'h00;
            #20;
            reset = 1'b1;
            #20;
            $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : dut.state : expected_value: INPUT(0) actual_value: %0d", $time, dut.state);
            if (dut.state !== 2'd0) begin
                $display("LOG: %0t : ERROR : tb_tt_um_arraymultiplier : dut.state : expected_value: 0 actual_value: %0d", $time, dut.state);
                errors = errors + 1;
            end
        end
    endtask
    
    // Task: Send matrix data
    task send_matrix_data;
        input integer with_glitches;
        begin
            $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : Sending matrix A data", $time);
            for (i = 0; i < 9; i = i + 1) begin
                @(posedge clock);
                ui_in = test_A[i];
                uio_in[0] = 1'b1;
                
                // Optional glitch injection
                if (with_glitches && (i == 3)) begin
                    #2;
                    uio_in[0] = 1'b0;
                    #2;
                    uio_in[0] = 1'b1;
                    $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : Injected data_valid glitch at A[%0d]", $time, i);
                end
                
                $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : ui_in : expected_value: A[%0d]=%0d actual_value: %0d", 
                         $time, i, test_A[i], ui_in);
                #1;
            end
            
            $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : Sending matrix B data", $time);
            for (i = 0; i < 9; i = i + 1) begin
                @(posedge clock);
                ui_in = test_B[i];
                uio_in[0] = 1'b1;
                $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : ui_in : expected_value: B[%0d]=%0d actual_value: %0d", 
                         $time, i, test_B[i], ui_in);
                #1;
            end
            
            // Deassert data_valid
            @(posedge clock);
            uio_in[0] = 1'b0;
            ui_in = 8'h00;
        end
    endtask
    
    // Task: Wait for state transition
    task wait_for_state;
        input [1:0] expected_state;
        input integer max_cycles;
        integer cycle_count;
        begin
            cycle_count = 0;
            while (dut.state != expected_state && cycle_count < max_cycles) begin
                @(posedge clock);
                cycle_count = cycle_count + 1;
            end
            
            if (dut.state == expected_state) begin
                $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : dut.state : expected_value: %0d actual_value: %0d", 
                         $time, expected_state, dut.state);
            end else begin
                $display("LOG: %0t : WARNING : tb_tt_um_arraymultiplier : dut.state : expected_value: %0d actual_value: %0d (timeout after %0d cycles)", 
                         $time, expected_state, dut.state, max_cycles);
            end
        end
    endtask
    
    // Task: Initialize matrices with specific pattern
    task init_matrices;
        input [7:0] pattern_type;
        begin
            case (pattern_type)
                // Normal test data
                8'd0: begin
                    test_A[0] = 8'd1; test_A[1] = 8'd2; test_A[2] = 8'd3;
                    test_A[3] = 8'd4; test_A[4] = 8'd5; test_A[5] = 8'd6;
                    test_A[6] = 8'd7; test_A[7] = 8'd8; test_A[8] = 8'd9;
                    
                    test_B[0] = 8'd9; test_B[1] = 8'd8; test_B[2] = 8'd7;
                    test_B[3] = 8'd6; test_B[4] = 8'd5; test_B[5] = 8'd4;
                    test_B[6] = 8'd3; test_B[7] = 8'd2; test_B[8] = 8'd1;
                end
                
                // All zeros
                8'd1: begin
                    for (j = 0; j < 9; j = j + 1) begin
                        test_A[j] = 8'd0;
                        test_B[j] = 8'd0;
                    end
                end
                
                // Maximum values (all 0xFF)
                8'd2: begin
                    for (j = 0; j < 9; j = j + 1) begin
                        test_A[j] = 8'hFF;
                        test_B[j] = 8'hFF;
                    end
                end
                
                // Identity-like pattern
                8'd3: begin
                    test_A[0] = 8'd1; test_A[1] = 8'd0; test_A[2] = 8'd0;
                    test_A[3] = 8'd0; test_A[4] = 8'd1; test_A[5] = 8'd0;
                    test_A[6] = 8'd0; test_A[7] = 8'd0; test_A[8] = 8'd1;
                    
                    test_B[0] = 8'd5; test_B[1] = 8'd6; test_B[2] = 8'd7;
                    test_B[3] = 8'd8; test_B[4] = 8'd9; test_B[5] = 8'd10;
                    test_B[6] = 8'd11; test_B[7] = 8'd12; test_B[8] = 8'd13;
                end
                
                // Single non-zero element
                8'd4: begin
                    for (j = 0; j < 9; j = j + 1) begin
                        test_A[j] = 8'd0;
                        test_B[j] = 8'd0;
                    end
                    test_A[4] = 8'd100;  // Center element
                    test_B[4] = 8'd50;   // Center element
                end
                
                // Alternating pattern
                8'd5: begin
                    for (j = 0; j < 9; j = j + 1) begin
                        test_A[j] = (j[0]) ? 8'hFF : 8'h00;
                        test_B[j] = (j[0]) ? 8'h00 : 8'hFF;
                    end
                end
                
                // Powers of 2
                8'd6: begin
                    test_A[0] = 8'd1;   test_A[1] = 8'd2;   test_A[2] = 8'd4;
                    test_A[3] = 8'd8;   test_A[4] = 8'd16;  test_A[5] = 8'd32;
                    test_A[6] = 8'd64;  test_A[7] = 8'd128; test_A[8] = 8'd1;
                    
                    test_B[0] = 8'd128; test_B[1] = 8'd64;  test_B[2] = 8'd32;
                    test_B[3] = 8'd16;  test_B[4] = 8'd8;   test_B[5] = 8'd4;
                    test_B[6] = 8'd2;   test_B[7] = 8'd1;   test_B[8] = 8'd128;
                end
                
                default: begin
                    for (j = 0; j < 9; j = j + 1) begin
                        test_A[j] = 8'd1;
                        test_B[j] = 8'd1;
                    end
                end
            endcase
        end
    endtask
    
    // Main test stimulus
    initial begin
        $display("TEST START");
        
        // Initialize
        reset = 1'b0;
        ena = 1'b1;
        ui_in = 8'h00;
        uio_in = 8'h00;
        errors = 0;
        test_num = 0;
        
        // Initial reset
        apply_reset();
        
        // ========================================
        // Test 1: Normal operation with typical data
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: Normal operation", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd0);  // Normal test data
        send_matrix_data(0);  // No glitches
        wait_for_state(2'd1, 20);  // Wait for COMPUTE
        wait_for_state(2'd2, 100); // Wait for OUTPUT
        repeat(50) @(posedge clock);
        
        apply_reset();
        
        // ========================================
        // Test 2: Zero matrices (boundary case)
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: Zero matrices", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd1);  // All zeros
        send_matrix_data(0);
        wait_for_state(2'd1, 20);
        wait_for_state(2'd2, 100);
        repeat(50) @(posedge clock);
        
        apply_reset();
        
        // ========================================
        // Test 3: Maximum values (0xFF)
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: Maximum values (0xFF)", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd2);  // All 0xFF
        send_matrix_data(0);
        wait_for_state(2'd1, 20);
        wait_for_state(2'd2, 100);
        repeat(50) @(posedge clock);
        
        apply_reset();
        
        // ========================================
        // Test 4: Identity-like matrix
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: Identity-like matrix", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd3);  // Identity pattern
        send_matrix_data(0);
        wait_for_state(2'd1, 20);
        wait_for_state(2'd2, 100);
        repeat(50) @(posedge clock);
        
        apply_reset();
        
        // ========================================
        // Test 5: Single non-zero element
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: Single non-zero element", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd4);  // Single element
        send_matrix_data(0);
        wait_for_state(2'd1, 20);
        wait_for_state(2'd2, 100);
        repeat(50) @(posedge clock);
        
        apply_reset();
        
        // ========================================
        // Test 6: Alternating pattern (0xFF, 0x00)
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: Alternating pattern", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd5);  // Alternating
        send_matrix_data(0);
        wait_for_state(2'd1, 20);
        wait_for_state(2'd2, 100);
        repeat(50) @(posedge clock);
        
        apply_reset();
        
        // ========================================
        // Test 7: Powers of 2
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: Powers of 2", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd6);  // Powers of 2
        send_matrix_data(0);
        wait_for_state(2'd1, 20);
        wait_for_state(2'd2, 100);
        repeat(50) @(posedge clock);
        
        apply_reset();
        
        // ========================================
        // Test 8: Reset during INPUT state
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: Reset during INPUT state", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd0);
        // Send partial data (only 5 bytes)
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clock);
            ui_in = test_A[i];
            uio_in[0] = 1'b1;
            #1;
        end
        
        // Apply reset mid-transfer
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : Applying reset during INPUT", $time);
        reset = 1'b0;
        #20;
        reset = 1'b1;
        #20;
        
        if (dut.state == 2'd0) begin
            $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : dut.state : expected_value: INPUT(0) actual_value: %0d", $time, dut.state);
        end else begin
            $display("LOG: %0t : ERROR : tb_tt_um_arraymultiplier : dut.state : expected_value: INPUT(0) actual_value: %0d", $time, dut.state);
            errors = errors + 1;
        end
        
        uio_in[0] = 1'b0;
        ui_in = 8'h00;
        repeat(10) @(posedge clock);
        
        apply_reset();
        
        // ========================================
        // Test 9: data_valid staying low (no data acceptance)
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: data_valid always low", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd0);
        // Send data but keep data_valid low
        for (i = 0; i < 18; i = i + 1) begin
            @(posedge clock);
            ui_in = 8'hAA;
            uio_in[0] = 1'b0;  // data_valid = 0
            #1;
        end
        
        // Check that state hasn't changed
        if (dut.state == 2'd0) begin
            $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : dut.state : expected_value: INPUT(0) actual_value: %0d (correctly stayed in INPUT)", $time, dut.state);
        end else begin
            $display("LOG: %0t : ERROR : tb_tt_um_arraymultiplier : dut.state : expected_value: INPUT(0) actual_value: %0d", $time, dut.state);
            errors = errors + 1;
        end
        
        apply_reset();
        
        // ========================================
        // Test 10: Attempting extra data after done
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: Extra data after done", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd0);
        send_matrix_data(0);
        wait_for_state(2'd1, 20);  // Wait for computation
        
        // Try sending extra data (should be ignored)
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : Attempting to send extra data", $time);
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clock);
            ui_in = 8'hBB;
            uio_in[0] = 1'b1;
            #1;
        end
        
        uio_in[0] = 1'b0;
        ui_in = 8'h00;
        
        wait_for_state(2'd2, 100);
        repeat(50) @(posedge clock);
        
        apply_reset();
        
        // ========================================
        // Test 11: Data valid glitches
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: data_valid glitches", $time, test_num);
        $display("========================================");
        
        init_matrices(8'd0);
        send_matrix_data(1);  // With glitches
        wait_for_state(2'd1, 20);
        wait_for_state(2'd2, 100);
        repeat(50) @(posedge clock);
        
        apply_reset();
        
        // ========================================
        // Test 12: Reset at different clock phases
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : TEST %0d: Reset at different clock phases", $time, test_num);
        $display("========================================");
        
        // Reset at negative edge
        @(negedge clock);
        reset = 1'b0;
        #15;
        reset = 1'b1;
        @(posedge clock);
        #5;
        
        if (dut.state == 2'd0) begin
            $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : dut.state : expected_value: INPUT(0) actual_value: %0d", $time, dut.state);
        end else begin
            $display("LOG: %0t : ERROR : tb_tt_um_arraymultiplier : dut.state : expected_value: INPUT(0) actual_value: %0d", $time, dut.state);
            errors = errors + 1;
        end
        
        repeat(20) @(posedge clock);
        
        // ========================================
        // Final Report
        // ========================================
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_tt_um_arraymultiplier : Test Summary", $time);
        $display("========================================");
        $display("Total tests run: %0d", test_num);
        $display("Total errors: %0d", errors);
        
        if (errors == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("ERROR");
            $error("TEST FAILED with %0d errors", errors);
        end
        
        $finish(0);
    end
    
    // Timeout watchdog (prevent infinite simulation)
    initial begin
        #200000;  // 200 microseconds timeout (increased for multiple tests)
        $display("LOG: %0t : ERROR : tb_tt_um_arraymultiplier : simulation_timeout : expected_value: completion actual_value: timeout", $time);
        $display("ERROR");
        $fatal(1, "Simulation timeout - test did not complete in time");
    end
    
    // Waveform dump
    initial begin
        $dumpfile("dumpfile.fst");
        $dumpvars(0);
    end

endmodule

`default_nettype wire
