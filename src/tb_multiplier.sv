`timescale 1ns/1ps

module tb_multiplier;
    // Testbench signals
    reg clock;
    reg reset;
    reg [7:0] A;
    reg [7:0] B;
    wire [15:0] prod;
    
    // Test tracking
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // DUT instantiation
    multiplier dut (
        .clk(clock),
        .reset(reset),
        .A(A),
        .B(B),
        .prod(prod)
    );
    
    // Clock generation (10ns period = 100MHz)
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end
    
    // Test stimulus
    initial begin
        $display("TEST START");
        $display("========================================");
        $display("   Multiplier Testbench");
        $display("   8-bit x 8-bit = 16-bit");
        $display("   Latency: 8 clock cycles");
        $display("========================================");
        
        // Initialize signals
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        A = 8'h00;
        B = 8'h00;
        reset = 1'b1;
        
        // Apply reset
        $display("\n[%0t] Applying reset...", $time);
        @(negedge clock);
        reset = 1'b0;
        repeat(2) @(negedge clock);
        reset = 1'b1;
        @(negedge clock);
        $display("[%0t] Reset complete", $time);
        
        // Test 1: Zero multiplication
        $display("\n--- Test 1: Zero Tests ---");
        test_multiply(8'd0, 8'd0, "0 x 0");
        test_multiply(8'd0, 8'd255, "0 x 255");
        test_multiply(8'd123, 8'd0, "123 x 0");
        
        // Test 2: Identity (multiply by 1)
        $display("\n--- Test 2: Identity Tests ---");
        test_multiply(8'd1, 8'd1, "1 x 1");
        test_multiply(8'd1, 8'd255, "1 x 255");
        test_multiply(8'd100, 8'd1, "100 x 1");
        
        // Test 3: Powers of 2
        $display("\n--- Test 3: Powers of 2 ---");
        test_multiply(8'd2, 8'd2, "2 x 2");
        test_multiply(8'd4, 8'd4, "4 x 4");
        test_multiply(8'd16, 8'd16, "16 x 16");
        test_multiply(8'd128, 8'd2, "128 x 2");
        
        // Test 4: Maximum values
        $display("\n--- Test 4: Maximum Value Tests ---");
        test_multiply(8'd255, 8'd255, "255 x 255 (max)");
        test_multiply(8'd255, 8'd1, "255 x 1");
        test_multiply(8'd255, 8'd2, "255 x 2");
        
        // Test 5: Mid-range values
        $display("\n--- Test 5: Mid-range Tests ---");
        test_multiply(8'd10, 8'd20, "10 x 20");
        test_multiply(8'd15, 8'd17, "15 x 17");
        test_multiply(8'd100, 8'd100, "100 x 100");
        test_multiply(8'd50, 8'd60, "50 x 60");
        
        // Test 6: Random tests
        $display("\n--- Test 6: Random Tests ---");
        test_multiply(8'd37, 8'd83, "37 x 83");
        test_multiply(8'd199, 8'd3, "199 x 3");
        test_multiply(8'd7, 8'd13, "7 x 13");
        test_multiply(8'd250, 8'd4, "250 x 4");
        test_multiply(8'd64, 8'd32, "64 x 32");
        
        // Test 7: Back-to-back operations
        $display("\n--- Test 7: Back-to-Back Operations ---");
        test_multiply(8'd5, 8'd6, "5 x 6 (back-to-back)");
        test_multiply(8'd7, 8'd8, "7 x 8 (back-to-back)");
        test_multiply(8'd9, 8'd10, "9 x 10 (back-to-back)");
        
        // Test summary
        $display("\n========================================");
        $display("   TEST SUMMARY");
        $display("========================================");
        $display("Total Tests:  %0d", test_count);
        $display("Passed:       %0d", pass_count);
        $display("Failed:       %0d", fail_count);
        $display("========================================");
        
        if (fail_count == 0) begin
            $display("\nTEST PASSED");
        end else begin
            $display("\nERROR");
            $error("TEST FAILED - %0d test(s) failed", fail_count);
        end
        
        #100;
        $finish;
    end
    
    // Task to perform a single multiplication test
    task test_multiply;
        input [7:0] a_val;
        input [7:0] b_val;
        input [255:0] test_name;
        reg [15:0] expected;
        integer i;
        begin
            test_count = test_count + 1;
            expected = a_val * b_val;
            
            // Wait for count to reach 0 from previous test
            repeat(1) @(posedge clock);
            
            // Apply inputs on negedge (count=0 now, will load on next posedge)
            @(negedge clock);
            A = a_val;
            B = b_val;
            
            // Next posedge: count=0, so it loads inputs and sets count=8
            // Then wait 8 more posedges for processing (count: 8->7->...->1)
            repeat(9) @(posedge clock);
            
            // Check result (count should be 1, product is ready)
            #1; // Small delay for signal to settle
            
            if (prod === expected) begin
                $display("[%0t] PASS: %0s => %0d x %0d = %0d (got %0d)", 
                         $time, test_name, a_val, b_val, expected, prod);
                pass_count = pass_count + 1;
            end else begin
                $display("LOG: %0t : ERROR : tb_multiplier : dut.prod : expected_value: %0d actual_value: %0d", 
                         $time, expected, prod);
                $display("[%0t] FAIL: %0s => %0d x %0d = expected %0d, got %0d", 
                         $time, test_name, a_val, b_val, expected, prod);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    // Timeout watchdog
    initial begin
        #100000; // 100us timeout
        $display("\nERROR: Simulation timeout!");
        $fatal(1, "Testbench timeout - simulation ran too long");
    end
    
    // Waveform dump
    initial begin
        $dumpfile("dumpfile.fst");
        $dumpvars(0);
    end

endmodule
