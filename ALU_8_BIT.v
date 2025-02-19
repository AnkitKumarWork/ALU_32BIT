module ALU_8_BIT (
    input in_clk,
    input in_wdt_rst,
    input [4:0] alu_sel,
    input signed [7:0] in_1, // Signed input 1
    input signed [7:0] in_2, // Signed input 2
    input in_carry,
    output reg signed [7:0] out_alu, // Signed output
    output reg zero_flag,
    output reg sign_flag,
    output reg parity_flag,
    output reg overflow_flag,
    output reg carry_flag,
    output reg Auxiliary_Carry_flag
);
parameter in_clock_frequency = 5_000_000; // 5 MHz (integer value)
parameter wdt_timeout_period = 10_000;     // 10 ms timeout expressed in microseconds
parameter max_count_value = (in_clock_frequency / 1_000_000) * wdt_timeout_period; // Total count for 10 ms
reg [31:0] count_value;
reg out_alu_rst;
reg signed [7:0] Accumulator_reg; // Signed accumulator register

always @(posedge in_clk or posedge in_wdt_rst)
begin
    if (in_wdt_rst) begin
        count_value = 32'b0;
        out_alu = 8'b0;
        Accumulator_reg = 8'b0;
        out_alu_rst = 1'b0;
    end else if (count_value >= max_count_value) begin
        out_alu_rst = 1'b1;
        count_value = 32'b0;
    end else begin
        count_value = count_value + 1;
    end
end

always @(alu_sel, in_1, in_2, in_carry, out_alu_rst)
begin
    if (out_alu_rst == 1'b0) begin
        case (alu_sel)
            // Signed Arithmetic Operations
            5'b00000: Accumulator_reg = in_1 + in_2;                // Signed Addition
            5'b00001: Accumulator_reg = in_1 + in_2 + in_carry;     // Signed Addition with Carry
            5'b00010: Accumulator_reg = in_1 - in_2;                // Signed Subtraction
            5'b00011: Accumulator_reg = in_1 * in_2;                // Signed Multiplication
            5'b00100: Accumulator_reg = in_1 / in_2;                // Signed Division
            5'b00101: Accumulator_reg = in_1 % in_2;                // Signed Modulus
            // Logical Operations (Bitwise remain the same, signedness doesn't matter)
            5'b00110: Accumulator_reg = in_1 & in_2;                // AND
            5'b00111: Accumulator_reg = in_1 | in_2;                // OR
            5'b01000: Accumulator_reg = in_1 ^ in_2;                // XOR
            5'b01001: Accumulator_reg = ~(in_1 | in_2);             // NOR
            // Shift Operations (Signed shifts)
            5'b01100: Accumulator_reg = in_1 << in_2;               // Logical Left Shift
            5'b01101: Accumulator_reg = in_1 >> in_2;               // Logical Right Shift
            5'b01110: Accumulator_reg = in_1 >>> in_2;              // Arithmetic Right Shift
            // Comparison Operations
            5'b01111: Accumulator_reg = (in_1 == in_2) ? 1 : 0;     // Equal
            5'b10000: Accumulator_reg = (in_1 < in_2) ? 1 : 0;      // Less Than (Signed)
            5'b10001: Accumulator_reg = (in_1 > in_2) ? 1 : 0;      // Greater Than (Signed)
            5'b10010: Accumulator_reg = (in_1 <= in_2) ? 1 : 0;     // Less Than or Equal (Signed)
            5'b10011: Accumulator_reg = (in_1 >= in_2) ? 1 : 0;     // Greater Than or Equal (Signed)
            // Other Operations
            5'b10100: Accumulator_reg = ~in_1;                      // Bitwise NOT
            5'b10101: Accumulator_reg = in_1;                       // Pass Input 1
            5'b10110: Accumulator_reg = in_2;                       // Pass Input 2
            default: Accumulator_reg = 0;                           // Default Case
        endcase
        out_alu = Accumulator_reg;
                   // Flags Calculation
      zero_flag = (Accumulator_reg == 8'b0) ? 1'b1 : 1'b0;
      sign_flag = (Accumulator_reg[7] == 1'b1) ? 1'b1 : 1'b0;                       // MSB is sign bit
      parity_flag = ~^Accumulator_reg;                                              // XOR all bits for parity
      overflow_flag = (alu_sel == 5'b00000 || alu_sel == 5'b00010) &&               // Only for add/sub
                      ((in_1[7] == in_2[7]) && (Accumulator_reg[7] != in_1[7]));
      carry_flag = (alu_sel == 5'b00000 || alu_sel == 5'b00010) && 
                   (Accumulator_reg > 8'b1111_1111);                                // Check for carry in signed addition
   //   Auxiliary_Carry_flag = ({in_1[3] + in_2[3]} == 2'b10);                      // Check lower nibble carry
    end else begin
        zero_flag = 1'b0;
        sign_flag = 1'b0;
        parity_flag = 1'b0;
        carry_flag = 1'b0;
        Auxiliary_Carry_flag = 1'b0;
        overflow_flag = 1'b0;
        out_alu = 8'b0;
    end

end
endmodule
