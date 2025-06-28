module hazard_detect_branch (
    input wire [4:0] IFID_rs1,
    input wire [4:0] IFID_rs2,
    input wire [4:0] IDEX_rd,
    input wire       IDEX_reg_write,
    input wire [4:0] EXMEM_rd,
    input wire       EXMEM_reg_write,
    input wire       EXMEM_mem_en,
    input wire       EXMEM_mem_write,
    input wire       branch,
    output wire      stall_branch
);
    wire next_rd_valid = (IDEX_rd != 5'b0) && (IDEX_reg_write); // 排除x0
    wire hazard_next = next_rd_valid && ((IFID_rs1 == IDEX_rd) || (IFID_rs2 == IDEX_rd));
    wire EXMEM_read = EXMEM_mem_en && (~EXMEM_mem_write);
    wire second_rd_valid = (EXMEM_rd != 5'b0) && (EXMEM_reg_write) && (EXMEM_read); // 排除x0
    wire hazard_second = second_rd_valid && ((IFID_rs1 == EXMEM_rd) || (IFID_rs2 == EXMEM_rd));
    assign stall_branch = (branch && (hazard_next || hazard_second)) ? 1'b1 : 1'b0;
endmodule