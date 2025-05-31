module register_file (
    input wire          clk,
    input wire          rst,
    input wire          regwrite,
    input wire  [4:0]   rs1,
    input wire  [4:0]   rs2,
    input wire  [4:0]   rd,
    input wire  [31:0]  wdata,
    output wire [31:0]  rdata1,
    output wire [31:0]  rdata2
);

    reg [31:0] regfile [0:31];

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] <= 32'b0; // Initialize all registers to zero
            end
        end
        else if (regwrite && rd != 5'b0) begin
            regfile[rd] <= wdata; // Write data to the register file
        end
    end

    assign rdata1 = regfile[rs1]; //Read data from register rs1
    assign rdata2 = regfile[rs2]; //Read data from register rs2
    
endmodule