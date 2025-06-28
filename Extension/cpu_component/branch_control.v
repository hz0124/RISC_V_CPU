module branch_control (
    input wire branch,
    input wire [2:0] fun3,
    input wire zero,
    input wire sign,
    input wire jal,
    output wire [1:0] taken_type // 00: not taken, 01: branch taken, 10: jal taken
);

    localparam BEQ = 3'b000;
    localparam BLT = 3'b100;
    
    assign taken_type = (branch && zero && (fun3 == BEQ)) ? 2'b01 : // branch taken
                        (branch && sign && (fun3 == BLT)) ? 2'b01 : // branch taken
                        (jal) ? 2'b10 : // jal taken
                        2'b00; // not taken

endmodule