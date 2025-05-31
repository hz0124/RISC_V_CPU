module alu_control (
    input wire [2:0] alu_op,
    input wire [6:0] funct7,
    input wire [2:0] funct3,
    output wire [3:0] alu_ctrl
);
    
    reg [3:0] alu_ctrl_r;
    assign alu_ctrl = alu_ctrl_r;

    always @(*) begin
        case (alu_op)
            3'b000: begin
                alu_ctrl_r = 4'b0010; // ADD for LOAD/STORE
            end
            3'b001: begin
                alu_ctrl_r = 4'b0110; // SUB for BEQ/BLT
            end 
            3'b010: begin
                case (funct3)
                    3'b000: alu_ctrl_r = (funct7[5] == 1'b0) ? 4'b0010 : 4'b0110; // ADD or SUB
                    3'b001: alu_ctrl_r = 4'b0011; // SLL
                    3'b100: alu_ctrl_r = 4'b1000; // XOR
                    3'b101: alu_ctrl_r = (funct7[5] == 1'b0) ? 4'b1010 : 4'b1011; // SRL or SRA
                    3'b111: alu_ctrl_r = 4'b0000; // AND
                    3'b110: alu_ctrl_r = 4'b0001; // OR
                    default: alu_ctrl_r = 4'b1111; // Default case for safety
                endcase
            end
            3'b011: begin
                case (funct3)
                    3'b000: alu_ctrl_r = 4'b0010; // ADD for I-type ALU
                    3'b001: alu_ctrl_r = 4'b0011; // SLL for I-type ALU
                    3'b100: alu_ctrl_r = 4'b1000; // XOR for I-type ALU
                    3'b101: alu_ctrl_r = (funct7[5] == 1'b0) ? 4'b1010 : 4'b1011; // SRL or SRA for I-type ALU 
                    3'b111: alu_ctrl_r = 4'b0000; // AND for I-type ALU
                    3'b110: alu_ctrl_r = 4'b0001; // OR for I-type ALU
                    default: alu_ctrl_r = 4'b1111; // Default case for safety
                endcase
            end
            default: begin
                alu_ctrl_r = 4'b1111; // Default case for safety
            end
        endcase
    end

endmodule