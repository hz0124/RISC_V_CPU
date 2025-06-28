module btb_control #(
    parameter TAG_WIDTH = 32,
    parameter PC_WIDTH = 32,
    parameter TAKEN_WIDTH = 1,
    parameter VALID_WIDTH = 1,
    parameter ENTRY_COUNT = 16
) (
    input  wire [1:0] taken_type,
    input  wire       IFID_hit,
    input  wire       IFID_taken_predicted,
    output wire       flush,
    output wire       new_entry
);
    wire taken = (taken_type == 2'b01) || (taken_type == 2'b10);
    assign flush = (IFID_hit && (taken != IFID_taken_predicted)) || (!IFID_hit && (taken_type != 2'b00));
    assign new_entry = !IFID_hit && (taken_type != 2'b00);

endmodule