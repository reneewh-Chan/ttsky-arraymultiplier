`timescale 1ns/1ps

module tb_nBit_Adder;
    // Testbench parameters
    parameter N = 16;
    
    // Testbench signals
    reg [N-1:0] A;
    reg [N-1:0] B;
    wire [N-1:0] S;
    wire Cout;
    
    // Test tracking
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // DUT instantiation
    bit16_Adder #(.N(N)) dut (
        .A(A),
        .B(B),
        .S(S),
        .Cout(Cout)
    );
    
    // Test stimulus
    initial begin
        $display("TEST START");
        $display("========================================");
        $display("   N-Bit Adder Testbench");
        $display("   Bit Width: %0d", N);
        $display("   Combinational Adder with Carry Out");
        $display("========================================");
        
        // Initialize
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        A = 0;
        B = 0;
        
        #10; // Small delay for initialization
        
        // Test 1: Zero addition
        $display("\n--- Test 1: Zero Addition ---");
        test_add(16'd0, 16'd0, "0 + 0");
        
        // Test 2: Identity (add zero)
        $display("\n--- Test 2: Identity Tests (Add Zero) ---");
        test_add(16'd1, 16'd0, "1 + 0");
        test_add(16'd0, 16'd1, "0 + 1");
        test_add(16'd12345, 16'd0, "12345 + 0");
        test_add(16'd0, 16'd54321, "0 + 54321");
        
        // Test 3: Small numbers
        $display("\n--- Test 3: Small Number Addition ---");
        test_add(16'd1, 16'd1, "1 + 1");
        test_add(16'd5, 16'd3, "5 + 3");
        test_add(16'd10, 16'd20, "10 + 20");
        test_add(16'd255, 16'd1, "255 + 1");
        
        // Test 4: Powers of 2
        $display("\n--- Test 4: Powers of 2 ---");
        test_add(16'd1, 16'd1, "1 + 1 = 2");
        test_add(16'd2, 16'd2, "2 + 2 = 4");
        test_add(16'd128, 16'd128, "128 + 128 = 256");
        test_add(16'd256, 16'd256, "256 + 256 = 512");
        test_add(16'd1024, 16'd1024, "1024 + 1024 = 2048");
        
        // Test 5: Carry propagation tests
        $display("\n--- Test 5: Carry Propagation ---");
        test_add(16'd255, 16'd1, "255 + 1 (carry at bit 8)");
        test_add(16'd4095, 16'd1, "4095 + 1 (carry at bit 12)");
        test_add(16'd32767, 16'd1, "32767 + 1 (carry at bit 15)");
        test_add(16'd65535, 16'd1, "65535 + 1 (overflow)");
        
        // Test 6: Maximum value tests
        $display("\n--- Test 6: Maximum Value Tests ---");
        test_add(16'd65535, 16'd0, "MAX + 0");
        test_add(16'd65535, 16'd65535, "MAX + MAX (overflow)");
        test_add(16'd32768, 16'd32767, "32768 + 32767");
        
        // Test 7: Mid-range values
        $display("\n--- Test 7: Mid-Range Values ---");
        test_add(16'd1000, 16'd2000, "1000 + 2000");
        test_add(16'd12345, 16'd54321, "12345 + 54321");
        test_add(16'd30000, 16'd30000, "30000 + 30000");
        test_add(16'd10000, 16'd20000, "10000 + 20000");
        
        // Test 8: Random values
        $display("\n--- Test 8: Random Values ---");
        test_add(16'd7, 16'd13, "7 + 13");
        test_add(16'd123, 16'd456, "123 + 456");
        test_add(16'd999, 16'd111, "999 + 111");
        test_add(16'd42, 16'd1337, "42 + 1337");
        test_add(16'd8192, 16'd4096, "8192 + 4096");
        
        // Test 9: Alternating bit patterns
        $display("\n--- Test 9: Bit Pattern Tests ---");
        test_add(16'hAAAA, 16'h5555, "0xAAAA + 0x5555 (alternating bits)");
        test_add(16'hFFFF, 16'h0001, "0xFFFF + 0x0001 (all ones + 1)");
        test_add(16'h00FF, 16'h00FF, "0x00FF + 0x00FF");
        test_add(16'hF0F0, 16'h0F0F, "0xF0F0 + 0x0F0F");
        
        // Test 10: Exhaustive carry-out tests
        $display("\n--- Test 10: Carry-Out Verification ---");
        test_add(16'd32768, 16'd32768, "32768 + 32768 (expect Cout=1)");
        test_add(16'd40000, 16'd30000, "40000 + 30000 (expect Cout=1)");
        test_add(16'd50000, 16'd20000, "50000 + 20000 (expect Cout=1)");
        test_add(16'd65535, 16'd65535, "65535 + 65535 (expect Cout=1)");
        
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
    
    // Task to perform a single addition test
    task test_add;
        input [N-1:0] a_val;
        input [N-1:0] b_val;
        input [255:0] test_name;
        reg [N:0] expected;
        reg [N-1:0] expected_sum;
        reg expected_cout;
        begin
            test_count = test_count + 1;
            
            // Apply inputs
            A = a_val;
            B = b_val;
            
            // Calculate expected result
            expected = a_val + b_val;
            expected_sum = expected[N-1:0];
            expected_cout = expected[N];
            
            // Wait for combinational logic to settle
            #1;
            
            // Check sum and carry
            if ((S === expected_sum) && (Cout === expected_cout)) begin
                $display("[%0t] PASS: %0s => %0d + %0d = %0d (S=%0d, Cout=%0d)", 
                         $time, test_name, a_val, b_val, expected, S, Cout);
                pass_count = pass_count + 1;
            end else begin
                if (S !== expected_sum) begin
                    $display("LOG: %0t : ERROR : tb_nBit_Adder : dut.S : expected_value: %0d actual_value: %0d", 
                             $time, expected_sum, S);
                end
                if (Cout !== expected_cout) begin
                    $display("LOG: %0t : ERROR : tb_nBit_Adder : dut.Cout : expected_value: %0b actual_value: %0b", 
                             $time, expected_cout, Cout);
                end
                $display("[%0t] FAIL: %0s => %0d + %0d = expected S=%0d, Cout=%0b, got S=%0d, Cout=%0b", 
                         $time, test_name, a_val, b_val, expected_sum, expected_cout, S, Cout);
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
