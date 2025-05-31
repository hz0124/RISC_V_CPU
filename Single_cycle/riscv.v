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

//  instance your module  below

	reg  [31:0] pc;	
	wire [4:0]  idx_rs1;
	wire [4:0]  idx_rs2;
	wire [4:0]  idx_rd;
	wire [31:0] rdata1;
	wire [31:0] rdata2;
	wire [31:0] imm_b;
	wire [31:0] imm_s;
	wire [31:0] imm_j;
	wire [31:0] imm_l;
	wire [6:0]  opcode;
	wire [2:0]  funct3;
	wire [6:0]  funct7;
	wire [3:0]  alu_ctrl;
	wire        branch;
	wire        jal;
	wire        mem_en;
	wire        mem_to_reg;
	wire [2:0]  alu_op;
	wire        mem_write;
	wire        alu_src;
	wire        reg_write;
	wire        Jal_reg_write;
	wire [1:0]  imm_sel; 
	wire        is_an_inst;
	reg  [31:0] imm;
	wire [31:0] a_in;
	wire [31:0] b_in;
	wire [31:0] alu_out;
	wire 	    zero;
	wire 	    sign;
	wire [1:0]  taken_type;
	wire [31:0] pc_next;
	wire [31:0] pc_normal;
	wire [31:0] pc_branch;
	wire [31:0] write_back_data;

	assign inst_addr_o = pc;
	assign inst_ce_o = 1'b1; // always enable instruction memory
	assign data_ce_o = mem_en; // enable
	assign data_we_o = mem_write; // write enable for data memory
	assign data_addr_o = alu_out; // address for data memory
	assign data_o = rdata2; // data to write to memory
	assign idx_rs1 = inst_i[19:15];
	assign idx_rs2 = inst_i[24:20];
	assign idx_rd = inst_i[11:7];
	assign opcode = inst_i[6:0];
	assign funct3 = inst_i[14:12];
	assign funct7 = inst_i[31:25];
	assign pc_normal = pc + 4; // next instruction address
	assign pc_branch = pc + imm; // branch target address

	// Register file to hold the values of registers
	register_file reg_file(
		.clk(clk),
		.rst(rst),
		.regwrite(reg_write), // write if reg_write or Jal_reg_write
		.rs1(idx_rs1),
		.rs2(idx_rs2),
		.rd(idx_rd),
		.wdata(write_back_data), // data to write back
		.rdata1(rdata1), // read data from rs1
		.rdata2(rdata2)  // read data from rs2
	);
	
	// Control unit to generate control signals
	control control_unit(
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


	// Generate immediate value based on instruction type
	immgen_b immgen_b_unit(
		.inst_i(inst_i),
		.imm_o(imm_b)
	);

	immgen_s immgen_s_unit(
		.inst_i(inst_i),
		.imm_o(imm_s)
	);

	immgen_j immgen_j_unit(
		.inst_i(inst_i),
		.imm_o(imm_j)
	);

	immgen_i immgen_i_unit(
		.inst_i(inst_i),
		.imm_o(imm_l)
	);

	// Select immediate value based on instruction type
	always @(*) begin
		case (imm_sel)
			2'b00: imm = imm_l; // L-type
			2'b01: imm = imm_s; // S-type
			2'b10: imm = imm_b; // B-type
			2'b11: imm = imm_j; // J-type
			default: imm = 32'b0; // Default case for safety
		endcase
	end

	// ALU control unit to generate ALU control signals
	alu_control alu_ctrl_unit(
		.alu_op(alu_op),
		.funct3(funct3),
		.funct7(funct7),
		.alu_ctrl(alu_ctrl)
	);

	// Select inputs for ALU
	assign a_in = rdata1;
	assign b_in = (alu_src) ? imm : rdata2; // if alu_src is 1, use immediate value, else use rdata2

	// ALU unit to perform arithmetic operations
	alu alu_unit(
		.a(a_in),
		.b(b_in),
		.alu_ctrl(alu_ctrl),
		.result(alu_out),
		.zero(zero),
		.sign(sign)
	);

	// Branch control unit to determine what type of branch is taken
	branch_control branch_ctrl_unit(
		.branch(branch),
		.fun3(funct3),
		.zero(zero),
		.sign(sign),
		.jal(jal),
		.taken_type(taken_type)
	);

	// PC update logic
	assign pc_next = (taken_type == 2'b01) ? pc_branch : // branch taken
	                 (taken_type == 2'b10) ? (pc+imm_j) : // jal taken
	                 pc_normal; // not taken

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			pc <= 32'b0; // reset PC to 0
		end else if (is_an_inst) begin
			pc <= pc_next; // update PC based on branch/jump
		end
	end

	// Write back data selection
	assign write_back_data = (mem_to_reg) ? data_i : // if mem_to_reg is 1, use data from memory
	                       (Jal_reg_write) ? pc_normal : // if Jal_reg_write is 1, use next PC
	                       alu_out; // else use ALU result

	


endmodule