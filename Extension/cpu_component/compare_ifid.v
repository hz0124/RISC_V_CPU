module compare_ifid (
    input wire [31:0] a_in,
    input wire [31:0] b_in,
    output wire eq,
    output wire lt
);
    wire [31:0] result;
    assign result = a_in - b_in;
    assign eq = (result == 32'b0);
    assign lt = result[31];
endmodule