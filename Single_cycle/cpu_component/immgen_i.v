module immgen_i (
    input wire [31:0] inst_i,
    output wire [31:0] imm_o
);
    // L-type immediate generation
    assign imm_o = {{20{inst_i[31]}}, inst_i[31:20]}; // For L-type, use bits 31-20; for B-type, use bits 31-25 and 11-7 concatenated
    
endmodule