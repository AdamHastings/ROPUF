vsim -novopt alu_testbench

add wave -r sim:/ALU/*

run 200000 ns
