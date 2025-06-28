module control (
    input wire [6:0]  opcode,
    output wire       branch, 
    output wire       jal,
    output wire       mem_en,
    output wire       mem_to_reg,
    output wire [2:0] alu_op,
    output wire       mem_write,
    output wire       alu_src,
    output wire       reg_write,
    output wire       Jal_reg_write,
    output wire [1:0] imm_sel,
    output wire       is_an_inst
);

    localparam R_ALU = 7'b0110011;
    localparam I_ALU = 7'b0010011;
    localparam LOAD  = 7'b0000011;
    localparam STORE = 7'b0100011;
    localparam BRANCH = 7'b1100011;
    localparam JAL = 7'b1101111;

    assign branch = (opcode == BRANCH);
    assign jal = (opcode == JAL);
    assign mem_en = (opcode == LOAD) || (opcode == STORE);
    assign mem_to_reg = (opcode == LOAD);

    reg [2:0] alu_op_r;
    assign alu_op = alu_op_r;

    always @* begin
        case (opcode)
            R_ALU:   alu_op_r = 3'b010;
            I_ALU:   alu_op_r = 3'b011;
            LOAD,
            STORE:   alu_op_r = 3'b000;
            BRANCH:  alu_op_r = 3'b001;
            default: alu_op_r = 3'b100; // Default case for safety
        endcase
    end

    assign mem_write = (opcode == STORE);
    assign alu_src = (opcode == I_ALU) || (opcode == LOAD) || (opcode == STORE);
    assign reg_write = (opcode == R_ALU) || (opcode == I_ALU) || (opcode == LOAD) || (opcode == JAL);
    assign Jal_reg_write = (opcode == JAL);
    assign imm_sel = (opcode == LOAD) ? 2'b00 : // L-type
              (opcode == STORE) ? 2'b01 : // S-type
              (opcode == BRANCH) ? 2'b10 : // B-type
              (opcode == JAL) ? 2'b11 : // J-type
              2'b00; // Default case for safety
    assign is_an_inst = ((opcode == R_ALU) || (opcode == I_ALU) || (opcode == LOAD) || 
                        (opcode == STORE) || (opcode == BRANCH) || (opcode == JAL) || (opcode == 7'b0)); 
    
endmodule