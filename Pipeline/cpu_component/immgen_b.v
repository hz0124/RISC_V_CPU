module immgen_b (
    input wire [31:0] inst_i,
    output wire [31:0] imm_o
);
    // B-type immediate generation
    assign imm_o = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0}; // For B-type, use bits 31, 7, 30-25, 11-8 and append a zero bit at the end
    
endmodule