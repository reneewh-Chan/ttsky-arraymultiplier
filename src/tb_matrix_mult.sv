`timescale 1ns / 1ps
`default_nettype none

module tb_matrix_mult;

    // Clock and reset
    reg clock;
    reg reset;
    
    // DUT inputs
    reg enable;
    reg [7:0] A [0:8];
    reg [7:0] B [0:8];
    
    // DUT outputs
    wire [17:0] C [0:8];
    wire done;
    
    // Test control variables
    integer i, j, k_idx;
    integer errors;
    integer test_num;
    
    // Golden reference model
    reg [17:0] expected_C [0:8];
    
    // Instantiate the DUT
    matrix_mult dut (
        .clk(clock),
        .reset(reset),
        .enable(enable),
        .A(A),
        .B(B),
        .C(C),
        .done(done)
    );
    
    // Clock generation - 10ns period (100 MHz)
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end
    
    // Task: Apply reset
    task apply_reset;
        begin
            $display("LOG: %0t : INFO : tb_matrix_mult : Applying reset", $time);
            reset = 1'b0;
            enable = 1'b0;
            #40;
            reset = 1'b1;
            #20;
            
            // Verify reset state
            if (done !== 1'b0) begin
                $display("LOG: %0t : ERROR : tb_matrix_mult : dut.done : expected_value: 0 actual_value: %0d", $time, done);
                errors = errors + 1;
            end
            
            for (i = 0; i < 9; i = i + 1) begin
                if (C[i] !== 18'd0) begin
                    $display("LOG: %0t : ERROR : tb_matrix_mult : dut.C[%0d] : expected_value: 0 actual_value: %0d", $time, i, C[i]);
                    errors = errors + 1;
                end
            end
        end
    endtask
    
    // Task: Compute expected result using golden reference model
    task compute_golden_reference;
        integer row, col, k;
        reg [17:0] sum;
        begin
            // 3x3 matrix multiplication: C = A × B
            // Matrix layout: [0 1 2]   [row 0]
            //                [3 4 5]   [row 1]
            //                [6 7 8]   [row 2]
            
            for (row = 0; row < 3; row = row + 1) begin
                for (col = 0; col < 3; col = col + 1) begin
                    sum = 18'd0;
                    for (k = 0; k < 3; k = k + 1) begin
                        sum = sum + (A[row*3 + k] * B[k*3 + col]);
                    end
                    expected_C[row*3 + col] = sum;
                end
            end
        end
    endtask
    
    // Task: Wait for computation to complete
    task wait_for_done;
        input integer max_cycles;
        integer cycle_count;
        begin
            cycle_count = 0;
            while (done == 1'b0 && cycle_count < max_cycles) begin
                @(posedge clock);
                cycle_count = cycle_count + 1;
            end
            
            if (done == 1'b1) begin
                $display("LOG: %0t : INFO : tb_matrix_mult : dut.done : expected_value: 1 actual_value: %0d (completed in %0d cycles)", 
                         $time, done, cycle_count);
            end else begin
                $display("LOG: %0t : ERROR : tb_matrix_mult : dut.done : expected_value: 1 actual_value: %0d (timeout after %0d cycles)", 
                         $time, done, max_cycles);
                errors = errors + 1;
            end
        end
    endtask
    
    // Task: Verify results against golden reference
    task verify_results;
        begin
            compute_golden_reference();
            
            for (i = 0; i < 9; i = i + 1) begin
                if (C[i] !== expected_C[i]) begin
                    $display("LOG: %0t : ERROR : tb_matrix_mult : dut.C[%0d] : expected_value: %0d actual_value: %0d", 
                             $time, i, expected_C[i], C[i]);
                    errors = errors + 1;
                end else begin
                    $display("LOG: %0t : INFO : tb_matrix_mult : dut.C[%0d] : expected_value: %0d actual_value: %0d (PASS)", 
                             $time, i, expected_C[i], C[i]);
                end
            end
        end
    endtask
    
    // Task: Print matrices
    task print_matrices;
        input [8*20:1] label;
        begin
            $display("=== %s ===", label);
            $display("Matrix A:");
            $display("  [%3d %3d %3d]", A[0], A[1], A[2]);
            $display("  [%3d %3d %3d]", A[3], A[4], A[5]);
            $display("  [%3d %3d %3d]", A[6], A[7], A[8]);
            $display("Matrix B:");
            $display("  [%3d %3d %3d]", B[0], B[1], B[2]);
            $display("  [%3d %3d %3d]", B[3], B[4], B[5]);
            $display("  [%3d %3d %3d]", B[6], B[7], B[8]);
            $display("Expected C:");
            $display("  [%5d %5d %5d]", expected_C[0], expected_C[1], expected_C[2]);
            $display("  [%5d %5d %5d]", expected_C[3], expected_C[4], expected_C[5]);
            $display("  [%5d %5d %5d]", expected_C[6], expected_C[7], expected_C[8]);
            $display("Actual C:");
            $display("  [%5d %5d %5d]", C[0], C[1], C[2]);
            $display("  [%5d %5d %5d]", C[3], C[4], C[5]);
            $display("  [%5d %5d %5d]", C[6], C[7], C[8]);
        end
    endtask
    
    // Task: Run a matrix multiplication test
    task run_test;
        input [8*50:1] test_name;
        begin
            $display("\n========================================");
            $display("LOG: %0t : INFO : tb_matrix_mult : %s", $time, test_name);
            $display("========================================");
            
            compute_golden_reference();
            print_matrices(test_name);
            
            // Start computation
            @(posedge clock);
            enable = 1'b1;
            
            // Wait for completion
            wait_for_done(20);
            
            enable = 1'b0;
            
            // Verify results
            verify_results();
            
            // Wait before next test
            repeat(5) @(posedge clock);
        end
    endtask
    
    // Main test stimulus
    initial begin
        $display("TEST START");
        
        // Initialize
        reset = 1'b0;
        enable = 1'b0;
        errors = 0;
        test_num = 0;
        
        // Initialize matrices
        for (i = 0; i < 9; i = i + 1) begin
            A[i] = 8'd0;
            B[i] = 8'd0;
        end
        
        // Initial reset
        apply_reset();
        
        // ========================================
        // Test 1: Simple known values
        // ========================================
        test_num = test_num + 1;
        A[0] = 8'd1; A[1] = 8'd2; A[2] = 8'd3;
        A[3] = 8'd4; A[4] = 8'd5; A[5] = 8'd6;
        A[6] = 8'd7; A[7] = 8'd8; A[8] = 8'd9;
        
        B[0] = 8'd9; B[1] = 8'd8; B[2] = 8'd7;
        B[3] = 8'd6; B[4] = 8'd5; B[5] = 8'd4;
        B[6] = 8'd3; B[7] = 8'd2; B[8] = 8'd1;
        
        run_test("Test 1: Simple known values");
        apply_reset();
        
        // ========================================
        // Test 2: Identity matrix × arbitrary matrix
        // ========================================
        test_num = test_num + 1;
        // Identity matrix
        A[0] = 8'd1; A[1] = 8'd0; A[2] = 8'd0;
        A[3] = 8'd0; A[4] = 8'd1; A[5] = 8'd0;
        A[6] = 8'd0; A[7] = 8'd0; A[8] = 8'd1;
        
        B[0] = 8'd5; B[1] = 8'd6; B[2] = 8'd7;
        B[3] = 8'd8; B[4] = 8'd9; B[5] = 8'd10;
        B[6] = 8'd11; B[7] = 8'd12; B[8] = 8'd13;
        
        run_test("Test 2: Identity × Matrix");
        apply_reset();
        
        // ========================================
        // Test 3: Zero matrices
        // ========================================
        test_num = test_num + 1;
        for (i = 0; i < 9; i = i + 1) begin
            A[i] = 8'd0;
            B[i] = 8'd0;
        end
        
        run_test("Test 3: Zero matrices");
        apply_reset();
        
        // ========================================
        // Test 4: All ones
        // ========================================
        test_num = test_num + 1;
        for (i = 0; i < 9; i = i + 1) begin
            A[i] = 8'd1;
            B[i] = 8'd1;
        end
        
        run_test("Test 4: All ones");
        apply_reset();
        
        // ========================================
        // Test 5: Maximum values (overflow test)
        // ========================================
        test_num = test_num + 1;
        for (i = 0; i < 9; i = i + 1) begin
            A[i] = 8'd255;
            B[i] = 8'd255;
        end
        
        run_test("Test 5: Maximum values");
        apply_reset();
        
        // ========================================
        // Test 6: Diagonal matrices
        // ========================================
        test_num = test_num + 1;
        A[0] = 8'd2; A[1] = 8'd0; A[2] = 8'd0;
        A[3] = 8'd0; A[4] = 8'd3; A[5] = 8'd0;
        A[6] = 8'd0; A[7] = 8'd0; A[8] = 8'd4;
        
        B[0] = 8'd5; B[1] = 8'd0; B[2] = 8'd0;
        B[3] = 8'd0; B[4] = 8'd6; B[5] = 8'd0;
        B[6] = 8'd0; B[7] = 8'd0; B[8] = 8'd7;
        
        run_test("Test 6: Diagonal matrices");
        apply_reset();
        
        // ========================================
        // Test 7: Sparse matrix (single non-zero)
        // ========================================
        test_num = test_num + 1;
        for (i = 0; i < 9; i = i + 1) begin
            A[i] = 8'd0;
            B[i] = 8'd0;
        end
        A[4] = 8'd10;  // Center element
        B[4] = 8'd20;  // Center element
        
        run_test("Test 7: Sparse matrix");
        apply_reset();
        
        // ========================================
        // Test 8: Powers of 2
        // ========================================
        test_num = test_num + 1;
        A[0] = 8'd1;   A[1] = 8'd2;   A[2] = 8'd4;
        A[3] = 8'd8;   A[4] = 8'd16;  A[5] = 8'd32;
        A[6] = 8'd64;  A[7] = 8'd128; A[8] = 8'd1;
        
        B[0] = 8'd128; B[1] = 8'd64;  B[2] = 8'd32;
        B[3] = 8'd16;  B[4] = 8'd8;   B[5] = 8'd4;
        B[6] = 8'd2;   B[7] = 8'd1;   B[8] = 8'd128;
        
        run_test("Test 8: Powers of 2");
        apply_reset();
        
        // ========================================
        // Test 9: Alternating pattern
        // ========================================
        test_num = test_num + 1;
        for (i = 0; i < 9; i = i + 1) begin
            A[i] = (i[0]) ? 8'd100 : 8'd50;
            B[i] = (i[0]) ? 8'd2 : 8'd3;
        end
        
        run_test("Test 9: Alternating pattern");
        apply_reset();
        
        // ========================================
        // Test 10: Reset during computation
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_matrix_mult : Test 10: Reset during computation", $time);
        $display("========================================");
        
        A[0] = 8'd1; A[1] = 8'd2; A[2] = 8'd3;
        A[3] = 8'd4; A[4] = 8'd5; A[5] = 8'd6;
        A[6] = 8'd7; A[7] = 8'd8; A[8] = 8'd9;
        
        B[0] = 8'd1; B[1] = 8'd1; B[2] = 8'd1;
        B[3] = 8'd1; B[4] = 8'd1; B[5] = 8'd1;
        B[6] = 8'd1; B[7] = 8'd1; B[8] = 8'd1;
        
        @(posedge clock);
        enable = 1'b1;
        
        // Wait 2 cycles then reset
        repeat(2) @(posedge clock);
        $display("LOG: %0t : INFO : tb_matrix_mult : Applying reset mid-computation", $time);
        reset = 1'b0;
        enable = 1'b0;
        #20;
        reset = 1'b1;
        #20;
        
        // Verify reset worked
        if (done == 1'b0) begin
            $display("LOG: %0t : INFO : tb_matrix_mult : dut.done : expected_value: 0 actual_value: %0d (correctly reset)", $time, done);
        end else begin
            $display("LOG: %0t : ERROR : tb_matrix_mult : dut.done : expected_value: 0 actual_value: %0d", $time, done);
            errors = errors + 1;
        end
        
        repeat(5) @(posedge clock);
        
        // ========================================
        // Test 11: Multiple back-to-back computations
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_matrix_mult : Test 11: Back-to-back computations", $time);
        $display("========================================");
        
        // First computation
        A[0] = 8'd1; A[1] = 8'd0; A[2] = 8'd0;
        A[3] = 8'd0; A[4] = 8'd1; A[5] = 8'd0;
        A[6] = 8'd0; A[7] = 8'd0; A[8] = 8'd1;
        
        B[0] = 8'd2; B[1] = 8'd3; B[2] = 8'd4;
        B[3] = 8'd5; B[4] = 8'd6; B[5] = 8'd7;
        B[6] = 8'd8; B[7] = 8'd9; B[8] = 8'd10;
        
        @(posedge clock);
        enable = 1'b1;
        wait_for_done(20);
        enable = 1'b0;
        verify_results();
        
        // Immediately start second computation
        B[0] = 8'd10; B[1] = 8'd9; B[2] = 8'd8;
        B[3] = 8'd7;  B[4] = 8'd6; B[5] = 8'd5;
        B[6] = 8'd4;  B[7] = 8'd3; B[8] = 8'd2;
        
        @(posedge clock);
        enable = 1'b1;
        wait_for_done(20);
        enable = 1'b0;
        verify_results();
        
        repeat(5) @(posedge clock);
        
        // ========================================
        // Test 12: Enable held high (edge case)
        // ========================================
        test_num = test_num + 1;
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_matrix_mult : Test 12: Enable held high", $time);
        $display("========================================");
        
        apply_reset();
        
        A[0] = 8'd2; A[1] = 8'd2; A[2] = 8'd2;
        A[3] = 8'd2; A[4] = 8'd2; A[5] = 8'd2;
        A[6] = 8'd2; A[7] = 8'd2; A[8] = 8'd2;
        
        B[0] = 8'd3; B[1] = 8'd3; B[2] = 8'd3;
        B[3] = 8'd3; B[4] = 8'd3; B[5] = 8'd3;
        B[6] = 8'd3; B[7] = 8'd3; B[8] = 8'd3;
        
        @(posedge clock);
        enable = 1'b1;
        repeat(3) @(posedge clock);  // Keep enable high
        enable = 1'b0;
        
        // Should still complete or restart
        repeat(20) @(posedge clock);
        
        $display("LOG: %0t : INFO : tb_matrix_mult : Enable held high test completed (done=%0d)", $time, done);
        
        repeat(5) @(posedge clock);
        
        // ========================================
        // Final Report
        // ========================================
        $display("\n========================================");
        $display("LOG: %0t : INFO : tb_matrix_mult : Test Summary", $time);
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
    
    // Timeout watchdog
    initial begin
        #100000;  // 100 microseconds timeout
        $display("LOG: %0t : ERROR : tb_matrix_mult : simulation_timeout : expected_value: completion actual_value: timeout", $time);
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
