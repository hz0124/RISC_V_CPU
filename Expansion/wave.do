onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /riscv_soc_tb/riscv0/clk
add wave -noupdate /riscv_soc_tb/riscv0/rst
add wave -noupdate /riscv_soc_tb/riscv0/inst_i
add wave -noupdate /riscv_soc_tb/riscv0/pc
add wave -noupdate /riscv_soc_tb/riscv0/pc_next
add wave -noupdate /riscv_soc_tb/riscv0/pc_predicted
add wave -noupdate /riscv_soc_tb/riscv0/pc_next_truth
add wave -noupdate /riscv_soc_tb/riscv0/flush
add wave -noupdate /riscv_soc_tb/riscv0/hit
add wave -noupdate /riscv_soc_tb/riscv0/idx_predicted
add wave -noupdate /riscv_soc_tb/riscv0/taken_predicted
add wave -noupdate /riscv_soc_tb/riscv0/taken_type
add wave -noupdate /riscv_soc_tb/riscv0/branch_ctrl/branch
add wave -noupdate /riscv_soc_tb/riscv0/branch_ctrl/fun3
add wave -noupdate /riscv_soc_tb/riscv0/branch_ctrl/sign
add wave -noupdate /riscv_soc_tb/riscv0/branch_ctrl/zero
add wave -noupdate /riscv_soc_tb/riscv0/stall_branch
add wave -noupdate /riscv_soc_tb/riscv0/stall_alu
add wave -noupdate /riscv_soc_tb/riscv0/data_i
add wave -noupdate /riscv_soc_tb/riscv0/data_o
add wave -noupdate /riscv_soc_tb/riscv0/IFID_pc
add wave -noupdate /riscv_soc_tb/riscv0/IDEX_pc
add wave -noupdate /riscv_soc_tb/riscv0/EXMEM_pc
add wave -noupdate /riscv_soc_tb/riscv0/MEMWB_pc
add wave -noupdate /riscv_soc_tb/riscv0/wdata
add wave -noupdate /riscv_soc_tb/riscv0/rs1
add wave -noupdate /riscv_soc_tb/riscv0/rs2
add wave -noupdate /riscv_soc_tb/riscv0/rd
add wave -noupdate /riscv_soc_tb/riscv0/alu_a
add wave -noupdate /riscv_soc_tb/riscv0/alu_b
add wave -noupdate /riscv_soc_tb/riscv0/EXMEM_alu_res
add wave -noupdate /riscv_soc_tb/riscv0/IDEX_forward_a
add wave -noupdate /riscv_soc_tb/riscv0/IDEX_forward_b
add wave -noupdate /riscv_soc_tb/riscv0/IDEX_rs1
add wave -noupdate /riscv_soc_tb/riscv0/IDEX_rs2
add wave -noupdate /riscv_soc_tb/riscv0/IDEX_r1
add wave -noupdate /riscv_soc_tb/riscv0/IDEX_r2
add wave -noupdate /riscv_soc_tb/riscv0/EXMEM_alu_result
add wave -noupdate /riscv_soc_tb/riscv0/MEMWB_alu_result
add wave -noupdate -expand /riscv_soc_tb/riscv0/regfile/regfile
add wave -noupdate /riscv_soc_tb/verify
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {349 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {135 ps} {1054 ps}
