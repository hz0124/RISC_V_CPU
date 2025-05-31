module forwarding_alu (
    input wire [4:0] IDEX_rs1,
    input wire [4:0] IDEX_rs2,
    input wire [4:0] EXMEM_rd,
    input wire [4:0] MEMWB_rd,
    input wire EXMEM_reg_write,
    input wire MEMWB_reg_write,
    output wire [1:0] forward_a,
    output wire [1:0] forward_b
);
    reg [1:0] fwd_a, fwd_b;
    always @(*) begin
        if ((EXMEM_rd == IDEX_rs1) && EXMEM_reg_write && (EXMEM_rd != 5'b0)) begin
            fwd_a = 2'b10; // Forward from EX/MEM stage
        end 
        else if ((MEMWB_rd == IDEX_rs1) && MEMWB_reg_write && (MEMWB_rd != 5'b0)) begin
            fwd_a = 2'b01; // Forward from MEM/WB stage
        end 
        else begin
            fwd_a = 2'b00; // No forwarding
        end 
    end
    always @(*) begin
        if ((EXMEM_rd == IDEX_rs2) && EXMEM_reg_write && (EXMEM_rd != 5'b0)) begin
            fwd_b = 2'b10; // Forward from EX/MEM stage
        end 
        else if ((MEMWB_rd == IDEX_rs2) && MEMWB_reg_write && (MEMWB_rd != 5'b0)) begin
            fwd_b = 2'b01; // Forward from MEM/WB stage
        end 
        else begin
            fwd_b = 2'b00; // No forwarding
        end 
    end

    assign forward_a = fwd_a;
    assign forward_b = fwd_b;
endmodule