module immgen_j (
    input wire [31:0] inst_i,
    output wire [31:0] imm_o
);

    // JAL immediate generation
    assign imm_o = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
    
endmodule