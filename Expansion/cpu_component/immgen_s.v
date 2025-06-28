module immgen_s (
    input wire [31:0] inst_i,
    output wire [31:0] imm_o
);
    // S-type immediate generation
    assign imm_o = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]}; // Concatenate the relevant bits for S-type instruction

endmodule