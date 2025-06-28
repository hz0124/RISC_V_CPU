module riscv(

	input wire				 clk,
	input wire				 rst,         // high is reset
	
    // inst_mem
	input wire[31:0]         inst_i,
	output wire[31:0]        inst_addr_o,
	output wire              inst_ce_o,

    // data_mem
	input wire[31:0]         data_i,      // load data from data_mem
	output wire              data_we_o,
    output wire              data_ce_o,
	output wire[31:0]        data_addr_o,
	output wire[31:0]        data_o       // store data to  data_mem

);

	// NOP instruction
	localparam NOP = 32'h00000013; // NOP instruction (addi x0, x0, 0)

	reg  [31:0] pc;
	// IF/ID pipeline register
	reg  [31:0] IFID_inst;
	reg  [31:0] IFID_pc;

	// ID/EX pipeline register
	reg         IDEX_mem_en;
	reg         IDEX_mem_to_reg;
	reg         IDEX_mem_write;
	reg  [2:0]  IDEX_alu_op;
	reg         IDEX_alu_src;
	reg         IDEX_reg_write;
	reg         IDEX_Jal_reg_write;
	reg [31:0]  IDEX_pc;
	reg [4:0]   IDEX_rs1;
	reg [4:0]   IDEX_rs2;
	reg [31:0]  IDEX_rdata1;
	reg [31:0]  IDEX_rdata2;
	reg [4:0]   IDEX_rd;
	reg [31:0]  IDEX_imm;
	reg [2:0]   IDEX_fun3;
	reg [6:0]   IDEX_fun7;


	// EX/MEM pipeline register
	reg         EXMEM_mem_en;
	reg         EXMEM_mem_to_reg;
	reg         EXMEM_mem_write;
	reg [31:0]  EXMEM_alu_result;
	reg         EXMEM_reg_write;
	reg [4:0]   EXMEM_rd;
	reg [31:0]  EXMEM_rdata2;
	reg [31:0]  EXMEM_pc;
	reg         EXMEM_Jal_reg_write;

	// MEM/WB pipeline register
	reg         MEMWB_mem_to_reg;
	reg [31:0]  MEMWB_alu_result;
	reg [31:0]  MEMWB_mem_data;
	reg         MEMWB_reg_write;
	reg [4:0]   MEMWB_rd;
	reg [31:0]  MEMWB_pc;
	reg         MEMWB_Jal_reg_write;
	
	// Register file signals
	wire        reg_write;
	wire [4:0]  rs1;
	wire [4:0]  rs2;
	wire [4:0]  rd;
	wire [31:0] wdata;
	wire [31:0] rdata1;
	wire [31:0] rdata2;

	// Control signals
	wire [6:0]  opcode;
	wire        branch;
	wire        jal;
	wire        mem_en;
	wire        mem_to_reg;
	wire [2:0]  alu_op;
	wire        mem_write;
	wire        alu_src;
	wire        Jal_reg_write;
	wire [1:0]  imm_sel;
	wire        is_an_inst;

	// Forwarding for branch signals
	wire [1:0]  forward_a;
	wire [1:0]  forward_b;

	// Hazard detection signals for branch and ALU
	wire 	  	stall_branch;
	wire 	  	stall_alu;

	// Immediate generation
	wire [31:0] imm_i;
	wire [31:0] imm_s;
	wire [31:0] imm_b;
	wire [31:0] imm_j;

	wire [31:0] imm;

	// Comparator for branch target address
	wire [31:0] comp_ain;
	wire [31:0] comp_bin;
	wire        comp_eq;
	wire        comp_lt;

	// Branch control signals
	wire [1:0]  taken_type;

	// Function3 and Function7 fields
	wire [2:0]  fun3;
	wire [6:0]  fun7;

	// ALU control signals
	wire [3:0]  alu_ctrl;

	// Forwarding logic for ALU inputs
	wire [1:0]  IDEX_forward_a;
	wire [1:0]  IDEX_forward_b;

	// Write back data
	wire [4:0]  w_rd;
	wire        w_reg_write;

	 

	assign inst_addr_o = pc;
	assign inst_ce_o = 1'b1; // Always enable instruction memory

	assign opcode = IFID_inst[6:0];
	assign rs1 = IFID_inst[19:15];
	assign rs2 = IFID_inst[24:20];
	assign rd = IFID_inst[11:7];
	assign fun3 = IFID_inst[14:12];
	assign fun7 = IFID_inst[31:25];

	assign comp_ain = (forward_a == 2'b10) ? EXMEM_alu_result :
					  (forward_a == 2'b01) ? wdata : rdata1;

	assign comp_bin = (forward_b == 2'b10) ? EXMEM_alu_result :
					  (forward_b == 2'b01) ? wdata : rdata2;


	// Register file write data
	register_file regfile (
		.clk(clk),
		.rst(rst),
		.regwrite(w_reg_write),
		.rs1(rs1),
		.rs2(rs2),
		.rd(w_rd),
		.wdata(wdata),
		.rdata1(rdata1),
		.rdata2(rdata2)
	);

	// Control unit
	control ctrl (
		.opcode(opcode),
		.branch(branch),
		.jal(jal),
		.mem_en(mem_en),
		.mem_to_reg(mem_to_reg),
		.alu_op(alu_op),
		.mem_write(mem_write),
		.alu_src(alu_src),
		.reg_write(reg_write),
		.Jal_reg_write(Jal_reg_write),
		.imm_sel(imm_sel),
		.is_an_inst(is_an_inst)
	);

	// Immediate generation modules
	immgen_i immgen_i (
		.inst_i(IFID_inst),
		.imm_o(imm_i)
	);

	immgen_s immgen_s (
		.inst_i(IFID_inst),
		.imm_o(imm_s)
	);

	immgen_b immgen_b (
		.inst_i(IFID_inst),
		.imm_o(imm_b)
	);

	immgen_j immgen_j (
		.inst_i(IFID_inst),
		.imm_o(imm_j)
	);

	// Immediate selection based on control signals
	assign imm = (imm_sel == 2'b00) ? imm_i :
				 (imm_sel == 2'b01) ? imm_s :
				 (imm_sel == 2'b10) ? imm_b : imm_j;

	hazard_detect_alu hazard_alu (
		.IFID_rs1(rs1),
		.IFID_rs2(rs2),
		.IDEX_rd(IDEX_rd),
		.IDEX_mem_en(IDEX_mem_en),
		.IDEX_mem_write(IDEX_mem_write),
		.opcode(opcode),
		.stall_alu(stall_alu)
	);

	forwarding_branch forwarding_b (
		.IFID_rs1(rs1),
		.IFID_rs2(rs2),
		.EXMEM_rd(EXMEM_rd),
		.MEMWB_rd(MEMWB_rd),
		.EXMEM_reg_write(EXMEM_reg_write),
		.MEMWB_reg_write(MEMWB_reg_write),
		.branch(branch),
		.forward_a(forward_a),
		.forward_b(forward_b)
	);

	hazard_detect_branch hazard_b (
		.IFID_rs1(rs1),
		.IFID_rs2(rs2),
		.IDEX_rd(IDEX_rd),
		.IDEX_reg_write(IDEX_reg_write),
		.EXMEM_rd(EXMEM_rd),
		.EXMEM_reg_write(EXMEM_reg_write),
		.EXMEM_mem_en(EXMEM_mem_en),
		.EXMEM_mem_write(EXMEM_mem_write),
		.branch(branch),
		.stall_branch(stall_branch)
	);

	compare_ifid comparator (
		.a_in(comp_ain),
		.b_in(comp_bin),
		.eq(comp_eq),
		.lt(comp_lt)
	);

	branch_control branch_ctrl (
		.branch(branch),
		.fun3(IFID_inst[14:12]),
		.zero(comp_eq),
		.sign(comp_lt),
		.jal(jal),
		.taken_type(taken_type)
	);

	// ALU controller
	alu_control alu_control_unit (
		.alu_op(IDEX_alu_op),
		.funct7(IDEX_fun7),
		.funct3(IDEX_fun3),
		.alu_ctrl(alu_ctrl)
	);

	// ALU forwarding logic
	forwarding_alu forwarding_a (
		.IDEX_rs1(IDEX_rs1),
		.IDEX_rs2(IDEX_rs2),
		.EXMEM_rd(EXMEM_rd),
		.MEMWB_rd(MEMWB_rd),
		.EXMEM_reg_write(EXMEM_reg_write),
		.MEMWB_reg_write(MEMWB_reg_write),
		.forward_a(IDEX_forward_a),
		.forward_b(IDEX_forward_b)
	);

	// ALU operation
	wire [31:0] alu_a;
	wire [31:0] alu_b;
	wire [31:0] IDEX_r1;
	wire [31:0] IDEX_r2;
	wire [31:0] EXMEM_alu_res;
	assign IDEX_r1 = (IDEX_forward_a == 2'b10) ? EXMEM_alu_result :
					 (IDEX_forward_a == 2'b01) ? wdata : IDEX_rdata1;
	assign IDEX_r2 = (IDEX_forward_b == 2'b10) ? EXMEM_alu_result :
					 (IDEX_forward_b == 2'b01) ? wdata : IDEX_rdata2;
	assign alu_a = IDEX_r1;
	assign alu_b = (IDEX_alu_src) ? IDEX_imm : IDEX_r2; // Use immediate if alu_src is set
	
	// ALU pipeline stage
	alu alu_pipeline (
		.a(alu_a),
		.b(alu_b),
		.alu_ctrl(alu_ctrl),
		.result(EXMEM_alu_res)
	);

	assign data_we_o = EXMEM_mem_write;
	assign data_ce_o = EXMEM_mem_en;
	assign data_addr_o = EXMEM_alu_result;
	assign data_o = EXMEM_rdata2;

	wire [31:0] pc_next;
	assign pc_next = (taken_type == 2'b01) ? (IFID_pc + imm_b) : // Branch taken
						(taken_type == 2'b10) ? (IFID_pc + imm_j) : // JAL taken
						(pc + 4); // Not taken

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			pc <= 32'h0;
		end
		else if (!stall_branch && !stall_alu && is_an_inst) begin
			pc <= pc_next;
		end
	end

	wire flush = (taken_type != 2'b00);
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			IFID_inst <= 32'h0;
			IFID_pc <= 32'h0;
		end
		else if (stall_branch || stall_alu) begin
			IFID_inst <= IFID_inst; // Hold the current instruction
			IFID_pc <= IFID_pc; // Hold the current PC
		end
		else if (flush) begin
			IFID_inst <= NOP; // Flush the pipeline with NOP instruction
			IFID_pc <= 32'h0;
		end
		else if (!stall_branch && !stall_alu) begin
			IFID_inst <= inst_i;
			IFID_pc <= pc;
		end
	end

	// IDEX stage register
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			IDEX_mem_en <= 1'b0;
			IDEX_mem_to_reg <= 1'b0;
			IDEX_mem_write <= 1'b0;
			IDEX_alu_op <= 3'b000;
			IDEX_alu_src <= 1'b0;
			IDEX_reg_write <= 1'b0;
			IDEX_Jal_reg_write <= 1'b0;
			IDEX_pc <= 32'h0;
			IDEX_rdata1 <= 32'h0;
			IDEX_rdata2 <= 32'h0;
			IDEX_rd <= 5'b0;
			IDEX_imm <= 32'h0;
			IDEX_fun3 <= 3'b000;
			IDEX_fun7 <= 7'b0000000;
			IDEX_rs1 <= 5'b0;
			IDEX_rs2 <= 5'b0;
		end
		else if (stall_alu || stall_branch) begin
			IDEX_mem_en <= 1'b0;
			IDEX_mem_to_reg <= 1'b0;
			IDEX_mem_write <= 1'b0;
			IDEX_alu_op <= 3'b100;
			IDEX_alu_src <= 1'b0;
			IDEX_reg_write <= 1'b0;
			IDEX_Jal_reg_write <= 1'b0;
			IDEX_pc <= 32'h0;
			IDEX_rdata1 <= 32'h0;
			IDEX_rdata2 <= 32'h0;
			IDEX_rd <= 5'b0;
			IDEX_imm <= 32'h0;
			IDEX_fun3 <= 3'b000;
			IDEX_fun7 <= 7'b0000000;
			IDEX_rs1 <= 5'b0;
			IDEX_rs2 <= 5'b0;
		end
		else begin
			IDEX_mem_en <= mem_en;
			IDEX_mem_to_reg <= mem_to_reg;
			IDEX_mem_write <= mem_write;
			IDEX_alu_op <= alu_op;
			IDEX_alu_src <= alu_src;
			IDEX_reg_write <= reg_write;
			IDEX_Jal_reg_write <= Jal_reg_write;
			IDEX_pc <= IFID_pc;
			IDEX_rdata1 <= rdata1;
			IDEX_rdata2 <= rdata2;
			IDEX_rd <= rd;
			IDEX_imm <= imm;
			IDEX_fun3 <= fun3;
			IDEX_fun7 <= fun7;
			IDEX_rs1 <= rs1;
			IDEX_rs2 <= rs2;
		end
	end

	// EXMEM stage register
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			EXMEM_mem_en <= 1'b0;
			EXMEM_mem_to_reg <= 1'b0;
			EXMEM_mem_write <= 1'b0;
			EXMEM_alu_result <= 32'h0;
			EXMEM_reg_write <= 1'b0;
			EXMEM_rd <= 5'b0;
			EXMEM_rdata2 <= 32'h0;
			EXMEM_pc <= 32'h0;
			EXMEM_Jal_reg_write <= 1'b0;
		end
		else begin
			EXMEM_mem_en <= IDEX_mem_en;
			EXMEM_mem_to_reg <= IDEX_mem_to_reg;
			EXMEM_mem_write <= IDEX_mem_write;
			EXMEM_alu_result <= EXMEM_alu_res;
			EXMEM_reg_write <= IDEX_reg_write;
			EXMEM_rd <= IDEX_rd;
			EXMEM_rdata2 <= IDEX_r2;
			EXMEM_pc <= IDEX_pc;
			EXMEM_Jal_reg_write <= IDEX_Jal_reg_write;
		end
	end

	// MEMWB stage register
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			MEMWB_mem_to_reg <= 1'b0;
			MEMWB_alu_result <= 32'h0;
			MEMWB_mem_data <= 32'h0;
			MEMWB_reg_write <= 1'b0;
			MEMWB_rd <= 5'b0;
			MEMWB_pc <= 32'h0;
			MEMWB_Jal_reg_write <= 1'b0;
		end
		else begin
			MEMWB_mem_to_reg <= EXMEM_mem_to_reg;
			MEMWB_alu_result <= EXMEM_alu_result;
			MEMWB_mem_data <= data_i; // Load data from memory
			MEMWB_reg_write <= EXMEM_reg_write;
			MEMWB_rd <= EXMEM_rd;
			MEMWB_pc <= EXMEM_pc;
			MEMWB_Jal_reg_write <= EXMEM_Jal_reg_write;
		end
	end

	// Write back logic
	assign wdata = (MEMWB_Jal_reg_write) ? MEMWB_pc : // JAL instruction writes PC
					(MEMWB_mem_to_reg) ? MEMWB_mem_data : // Load instruction writes memory data
					MEMWB_alu_result; // ALU result for R-type and I-type instructions

	assign w_reg_write = MEMWB_reg_write;
	assign w_rd = MEMWB_rd;

endmodule