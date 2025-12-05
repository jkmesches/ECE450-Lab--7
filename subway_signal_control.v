// Subway Signal Control Logic II
// Moore FSM Implementation

module subway_signal_control (
    input wire clk,           // Clock signal
    input wire reset,         // Global reset
    input wire P1,            // Photocell 1
    input wire P2,            // Photocell 2
    output reg D              // Direction signal output
);

    // State encoding (3-bit)
    localparam S0 = 3'b000;   // Initial state, D=1
    localparam S1 = 3'b001;   // Train entering from left, D=1
    localparam S2 = 3'b010;   // Train between sensors, D=1
    localparam S3 = 3'b011;   // Completing passage, D=1
    localparam S4 = 3'b100;   // After 2 L→R trains, D=0

    // State variables
    reg [2:0] state, next_state;
    wire A, B, C;           // Current state bits
    wire A_next, B_next, C_next;  // Next state bits

    // Decompose state into individual bits
    assign A = state[2];
    assign B = state[1];
    assign C = state[0];

    // Next state logic using minimized Boolean equations from prelab
    assign A_next = (~B & C & ~P1 & P2) | (B & C & P1 & ~P2) | (A & P1) | (A & ~P2);
    assign B_next = (~B & C & ~P1 & ~P2) | (B & ~C) | (B & ~P2) | (B & ~P1);
    assign C_next = (~P1 & P2) | (C & ~P2) | (C & ~P1);

    // Combine next state bits
    assign next_state = {A_next, B_next, C_next};

    // Sequential logic: state register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0;  // Reset to initial state
        else
            state <= next_state;
    end

    // Output logic (Moore machine - output depends only on state)
    always @(*) begin
        D = ~A;  // D = A̅ (from your prelab equation D = A̅)
    end

endmodule