module hazard_detect_alu (
    input wire [4:0] IFID_rs1,
    input wire [4:0] IFID_rs2,
    input wire [4:0] IDEX_rd,
    input wire       IDEX_mem_en,
    input wire       IDEX_mem_write,
    input wire [6:0] opcode,
    output wire      stall_alu
);
    localparam R_ALU = 7'b0110011;
    localparam I_ALU = 7'b0010011;
    localparam LOAD  = 7'b0000011;
    localparam STORE = 7'b0100011;
    wire IDEX_mem_read = IDEX_mem_en && (~IDEX_mem_write);
    wire IFID_need_both = (opcode == R_ALU) || (opcode == STORE);
    wire IFID_need_single = (opcode == I_ALU) || (opcode == LOAD);
    wire rd_valid = (IDEX_rd != 5'b0);  // 排除x0
    wire hazard_rs1 = rd_valid && (IFID_rs1 == IDEX_rd);
    wire hazard_rs2 = rd_valid && (IFID_rs2 == IDEX_rd);

    wire eq_both = hazard_rs1 || hazard_rs2;
    wire eq_single = hazard_rs1;

    assign stall_alu = ((eq_both && IFID_need_both && IDEX_mem_read) ||
                        (eq_single && IFID_need_single && IDEX_mem_read)) ? 1'b1 : 1'b0;
endmodule