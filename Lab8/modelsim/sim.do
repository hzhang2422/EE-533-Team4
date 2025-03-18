# 加载顶层模块
vsim -voptargs="+acc" work.cpu_tb
#禁用优化
vsim -novopt work.cpu_tb

##############################################################################################################
add wave -noupdate -format Logic /cpu_tb/uut/clk
add wave -noupdate -format Logic /cpu_tb/uut/rst
add wave -noupdate -format Logic /cpu_tb/uut/flush
add wave -noupdate -format Logic /cpu_tb/uut/pause
##############################################################################################################
add wave -noupdate -divider {IF Stage}
add wave -noupdate -expand -group {IF_Stage}
add wave -noupdate -group {IF_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/if_pc
add wave -noupdate -group {IF_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/if_nextPc
add wave -noupdate -group {IF_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/if_instr
##############################################################################################################
add wave -noupdate -divider {ID Stage}
add wave -noupdate -expand -group {ID_Stage}
add wave -noupdate -group {ID_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/id_pc
add wave -noupdate -group {ID_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/id_instr
add wave -noupdate -group {ID_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/id_imm64
add wave -noupdate -group {ID_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/id_rs1Data
add wave -noupdate -group {ID_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/id_rs2Data
add wave -noupdate -group {ID_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/id_rd
add wave -noupdate -group {ID_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/id_rs1
add wave -noupdate -group {ID_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/id_rs2
add wave -noupdate -group {ID_Stage} -format Literal -radix binary /cpu_tb/uut/id_opcode
add wave -noupdate -group {ID_Stage} -format Literal -radix binary /cpu_tb/uut/id_aluc
add wave -noupdate -group {ID_Stage} -format Literal -radix binary /cpu_tb/uut/id_rs1Data_EX_PC
add wave -noupdate -group {ID_Stage} -format Literal -radix binary /cpu_tb/uut/id_rs2Data_EX_imm32_4
add wave -noupdate -group {ID_Stage} -format Literal -radix binary /cpu_tb/uut/id_pcImm_NEXTPC_rs1Imm
add wave -noupdate -group {ID_Stage} -format Literal -radix binary /cpu_tb/uut/id_writeReg
add wave -noupdate -group {ID_Stage} -format Literal -radix binary /cpu_tb/uut/id_writeMem
add wave -noupdate -group {ID_Stage} -format Literal -radix binary /cpu_tb/uut/id_readMem
##############################################################################################################
add wave -noupdate -divider {EX Stage}
add wave -noupdate -expand -group {EX_Stage}
add wave -noupdate -group {EX_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/ex_pc
add wave -noupdate -group {EX_Stage} -format Literal -radix hexadecimal /cpu_tb/uut/ex_outAlu
add wave -noupdate -group {EX_Stage} -format Literal -radix binary /cpu_tb/uut/ex_aluc
add wave -noupdate -group {EX_Stage} -format Literal -radix binary /cpu_tb/uut/ex_rs1Data_EX_PC
add wave -noupdate -group {EX_Stage} -format Literal -radix binary /cpu_tb/uut/ex_rs2Data_EX_imm32_4
add wave -noupdate -group {EX_Stage} -format Literal -radix binary /cpu_tb/uut/ex_conditionBranch
##############################################################################################################
# 重置循环计数器
set loopCount 0

# 设置监视点，每当PC等于48时增加计数器
when {/cpu_tb/uut/if_pc == 'h48} {
  set loopCount [expr $loopCount + 1]
  echo "Loop executed $loopCount times"
}

run -all
