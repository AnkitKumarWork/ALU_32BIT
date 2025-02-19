`timescale 1ns / 1ps

module ALU_8_BIT_TB;

// Inputs
reg in_clk;
reg in_wdt_rst;
reg [4:0] alu_sel;
reg signed [7:0] in_1;
reg signed [7:0] in_2;
reg in_carry;

// Outputs
wire signed [7:0] out_alu;
wire zero_flag;
wire sign_flag;
wire parity_flag;
wire overflow_flag;
wire carry_flag;
wire Auxiliary_Carry_flag;

// Instantiate the ALU module
ALU_8_BIT uut (
    .in_clk(in_clk),
    .in_wdt_rst(in_wdt_rst),
    .alu_sel(alu_sel),
    .in_1(in_1),
    .in_2(in_2),
    .in_carry(in_carry),
    .out_alu(out_alu),
    .zero_flag(zero_flag),
    .sign_flag(sign_flag),
    .parity_flag(parity_flag),
    .overflow_flag(overflow_flag),
    .carry_flag(carry_flag),
    .Auxiliary_Carry_flag(Auxiliary_Carry_flag)
);

// Clock generation
always #25 in_clk = ~in_clk; // 20 MHz clock (50 ns period)

initial begin
    // Initialize Inputs
    in_clk = 0;
    in_wdt_rst = 0;
    alu_sel = 5'b00000;
    in_1 = 0;
    in_2 = 0;
    in_carry = 0;

    // Reset the Watchdog Timer
    #10;
    in_wdt_rst = 1;
    #50; // Hold reset for a few clock cycles
    in_wdt_rst = 0;

    // Test Case 1: Signed Addition with Carry
    alu_sel = 5'b00001; // Addition with Carry
    in_1 = 8'sb0111_1111; // 127
    in_2 = 8'sb0000_1001; // 1
    in_carry = 1;
    #100; // Wait for result
    $display("Addition with Carry: out_alu=%d, carry_flag=%b, Auxiliary_Carry_flag=%b", out_alu, carry_flag, Auxiliary_Carry_flag);

    // Test Case 2: Signed Subtraction with Borrow
    alu_sel = 5'b00010; // Subtraction
    in_1 = 8'sb0000_0000; // 0
    in_2 = 8'sb0000_0001; // 1
    in_carry = 0;
    #100; // Wait for result
    $display("Subtraction with Borrow: out_alu=%d, carry_flag=%b, Auxiliary_Carry_flag=%b", out_alu, carry_flag, Auxiliary_Carry_flag);

    // Test Case 3: Auxiliary Carry in Addition
    alu_sel = 5'b00000; // Addition
    in_1 = 8'sb0000_1111; // 15
    in_2 = 8'sb0000_1001; // 1
    in_carry = 0;
    #100; // Wait for result
    $display("Auxiliary Carry in Addition: out_alu=%d, Auxiliary_Carry_flag=%b", out_alu, Auxiliary_Carry_flag);

    // Finish Simulation
    #500;
    $finish;
end

endmodule
