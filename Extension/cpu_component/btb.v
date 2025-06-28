module btb #(
    parameter TAG_WIDTH = 32,
    parameter PC_WIDTH = 32,
    parameter TAKEN_WIDTH = 1,
    parameter VALID_WIDTH = 1,
    parameter ENTRY_COUNT = 16
) (
    input  wire                                                     clk,
    input  wire                                                     rst_n,
    input  wire [PC_WIDTH-1:0]                                      pc_current,
    input  wire [PC_WIDTH-1:0]                                      IFID_pc,
    input  wire [PC_WIDTH-1:0]                                      next_pc_truth,    
    input  wire                                                     btb_change_valid,
    input  wire                                                     new_entry,
    input  wire [$clog2(ENTRY_COUNT)-1:0]                           idx_change,
    output wire [PC_WIDTH-1:0]                                      pc_predicted,
    output wire                                                     hit,
    output wire                                                     taken_predicted,
    output wire [$clog2(ENTRY_COUNT)-1:0]                           idx_predicted  // 添加索引输出
);

    // 存储结构
    reg [TAG_WIDTH-1:0] tag_table [0:ENTRY_COUNT-1];
    reg [PC_WIDTH-1:0] pc_table [0:ENTRY_COUNT-1];
    reg [ENTRY_COUNT-1:0] valid_table;
    reg [ENTRY_COUNT-1:0] taken_table;
    reg [$clog2(ENTRY_COUNT)-1:0] new_entry_idx;

    // 匹配逻辑
    wire [ENTRY_COUNT-1:0] match_array;
    genvar i;
    generate
        for (i = 0; i < ENTRY_COUNT; i = i + 1) begin 
            assign match_array[i] = (tag_table[i] == pc_current[TAG_WIDTH-1:0]) && valid_table[i];
        end
    endgenerate

    // 优先级掩码（低位优先）
    wire [ENTRY_COUNT-1:0] mask_array;
    assign mask_array[0] = match_array[0];
    generate
        for (i = 1; i < ENTRY_COUNT; i = i + 1) begin
            assign mask_array[i] = match_array[i] && ~(|match_array[i-1:0]);
        end
    endgenerate

    // 将one-hot编码转换为二进制索引
    reg [$clog2(ENTRY_COUNT)-1:0] idx_reg;
    
    integer j;
    always @(*) begin
        idx_reg = 0; // 默认值
        for (j = 0; j < ENTRY_COUNT; j = j + 1) begin
            if (mask_array[j]) begin
                idx_reg = j;
            end
        end
    end
    
    assign idx_predicted = idx_reg;
    
    assign hit = |mask_array;
    assign pc_predicted = hit ? pc_table[idx_reg] : {PC_WIDTH{1'b0}};
    assign taken_predicted = hit ? taken_table[idx_reg] : 1'b0;

    // BTB更新逻辑
    wire [TAG_WIDTH-1:0] tag_change;
    wire [PC_WIDTH-1:0] pc_change;
    wire [$clog2(ENTRY_COUNT)-1:0] change_index;
    
    assign tag_change = IFID_pc[TAG_WIDTH-1:0];
    assign pc_change = next_pc_truth;
    assign change_index = new_entry ? new_entry_idx : idx_change;
    
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin  
            for (j = 0; j < ENTRY_COUNT; j = j + 1) begin
                tag_table[j] <= {TAG_WIDTH{1'b0}};
                pc_table[j] <= {PC_WIDTH{1'b0}};
                valid_table[j] <= 1'b0;
                taken_table[j] <= 1'b0;
            end
            new_entry_idx <= {($clog2(ENTRY_COUNT)){1'b0}};
        end else begin
            if (btb_change_valid && !new_entry) begin
                taken_table[change_index] <= !taken_table[change_index]; // 切换预测值
            end
            else if (new_entry) begin
                tag_table[new_entry_idx] <= tag_change;
                pc_table[new_entry_idx] <= pc_change;
                valid_table[new_entry_idx] <= 1'b1; // 新条目有效
                taken_table[new_entry_idx] <= 1'b1; // 使用预测的值
                new_entry_idx <= (new_entry_idx + 1) % ENTRY_COUNT; // 循环使用索引
            end
        end 
    end
endmodule