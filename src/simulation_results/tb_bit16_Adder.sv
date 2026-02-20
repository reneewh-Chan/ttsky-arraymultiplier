`timescale 1ns/1ps

module tb_bit16_Adder;

    parameter N = 16;

    reg  [N-1:0] A, B;
    wire [N-1:0] S;
    wire Cout;

    // Reference model
    reg [N:0] expected;

    integer i;

    // Instantiate DUT
    bit16_Adder #(N) DUT (
        .A(A),
        .B(B),
        .S(S),
        .Cout(Cout)
    );

    // Task to check results
    task check;
    begin
        expected = A + B;

        #1; // allow combinational logic to settle

        if ({Cout, S} !== expected)
        begin
            $display("ERROR:");
            $display("A = %h", A);
            $display("B = %h", B);
            $display("Expected = %h", expected);
            $display("Got      = %h", {Cout, S});
            $stop;
        end
    end
    endtask

    initial
    begin
        $display("=======================================");
        $display("Starting bit16_Adder Testbench");
        $display("=======================================");

        // -----------------------------------
        // Directed Corner Cases
        // -----------------------------------

        A = 0; B = 0; check();
        A = 16'hFFFF; B = 0; check();
        A = 0; B = 16'hFFFF; check();
        A = 16'hFFFF; B = 16'hFFFF; check();

        A = 16'h0001; B = 16'h0001; check();
        A = 16'h7FFF; B = 16'h0001; check();
        A = 16'h8000; B = 16'h8000; check();

        A = 16'hAAAA; B = 16'h5555; check();
        A = 16'h5555; B = 16'hAAAA; check();

        // -----------------------------------
        // Walking Bit Tests
        // -----------------------------------

        for (i = 0; i < N; i = i + 1)
        begin
            A = (1 << i);
            B = 0;
            check();

            A = 0;
            B = (1 << i);
            check();

            A = (1 << i);
            B = (1 << i);
            check();
        end

        // -----------------------------------
        // Small Pattern Sweep
        // (excellent bug detector)
        // -----------------------------------

        for (i = 0; i < 256; i = i + 1)
        begin
            A = i;
            B = 255 - i;
            check();
        end

        // -----------------------------------
        // Random Stress Testing
        // -----------------------------------

        $display("Running random tests...");

        for (i = 0; i < 10000; i = i + 1)
        begin
            A = $random;
            B = $random;
            check();
        end

        // -----------------------------------
        // Finished
        // -----------------------------------

        $display("=======================================");
        $display("ALL TESTS PASSED");
        $display("=======================================");

        $finish;
    end

    initial begin
        $dumpfile("dumpfile.fst");
        $dumpvars(0);
    end

endmodule
