// Testbench for Subway Signal Control Logic
`timescale 1ns/1ps

module subway_signal_control_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg P1, P2;
    wire D;

    // Instantiate the Unit Under Test (UUT)
    subway_signal_control uut (
        .clk(clk),
        .reset(reset),
        .P1(P1),
        .P2(P2),
        .D(D)
    );

    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize signals
        reset = 1;
        P1 = 0;
        P2 = 0;
        
        // Create VCD file for waveform viewing
        $dumpfile("subway_signal.vcd");
        $dumpvars(0, subway_signal_control_tb);
        
        // Display header
        $display("Time\tReset\tP1\tP2\tState\tD");
        $display("----\t-----\t--\t--\t-----\t-");
        $monitor("%4t\t%b\t%b\t%b\t%b\t%b", 
                 $time, reset, P1, P2, uut.state, D);

        // Release reset
        #20 reset = 0;
        
        // Test Case 1: First train passes left-to-right
        $display("\n=== Test 1: First L->R train ===");
        #10 P2 = 1; P1 = 0;  // Train enters from left
        #20 P2 = 1; P1 = 1;  // Train between sensors
        #20 P2 = 0; P1 = 1;  // Train exits right
        #20 P2 = 0; P1 = 0;  // Train cleared
        
        // Test Case 2: Second train passes left-to-right
        $display("\n=== Test 2: Second L->R train ===");
        #20 P2 = 1; P1 = 0;  // Train enters from left
        #20 P2 = 1; P1 = 1;  // Train between sensors
        #20 P2 = 0; P1 = 1;  // Train exits right
        #20 P2 = 0; P1 = 0;  // Train cleared (D should now be 0)
        
        // Test Case 3: Train must now pass right-to-left
        $display("\n=== Test 3: R->L train (required) ===");
        #20 P1 = 1; P2 = 0;  // Train enters from right
        #20 P1 = 1; P2 = 1;  // Train between sensors
        #20 P1 = 0; P2 = 1;  // Train exits left
        #20 P1 = 0; P2 = 0;  // Train cleared (D should be 1 again)
        
        // Test Case 4: Train stops in middle and reverses
        $display("\n=== Test 4: Train reverses (should not count) ===");
        #20 P2 = 1; P1 = 0;  // Train enters from left
        #20 P2 = 1; P1 = 1;  // Train stops between sensors
        #20 P2 = 1; P1 = 0;  // Train backs up
        #20 P2 = 0; P1 = 0;  // Train exits back left
        
        // Test Case 5: Verify pattern continues
        $display("\n=== Test 5: Continue pattern ===");
        #20 P2 = 1; P1 = 0;
        #20 P2 = 0; P1 = 1;
        #20 P2 = 0; P1 = 0;
        
        #50 $finish;
    end

endmodule