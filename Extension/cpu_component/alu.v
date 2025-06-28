module alu (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_ctrl,
    output wire [31:0] result
);

    reg [31:0] result_r;
    assign result = result_r;

    wire [63:0] mul_result;

    multiplier mult (
        .a(a),
        .b(b),
        .result(mul_result)
    );

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result_r = a & b; // AND
            4'b0001: result_r = a | b; // OR
            4'b0010: result_r = a + b; // ADD
            4'b0011: result_r = a << b[4:0]; // SLL
            4'b1000: result_r = a ^ b; // XOR
            4'b1010: result_r = a >> b[4:0]; // SRL
            4'b1011: result_r = $signed(a) >>> b[4:0]; // SRA
            4'b0110: result_r = a - b; // SUB
            4'b0100: result_r = mul_result[31:0]; // MUL (lower 32 bits)
            4'b0101: result_r = mul_result[63:32]; // MULH (upper 32 bits)
            default: result_r = 32'h00000000; // Default case for safety
        endcase
    end
    
endmodule