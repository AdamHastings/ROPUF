#Test Datapath

#Figure out how to compile
source testLib.do

vsim -novopt lc3

#Initialize the Circuit

#Set the Clock 
force -freeze sim:/lc3/clk 1 0, 0 {10ns} -r 20ns
add wave sim:/lc3/clk 
#Reset the Circuit

force -drive sim:/lc3/rst 1 0
add wave sim:/lc3/rst

#run 10 Clock Cycles
runClk 10 

#Bring Circuit out of Reset
force -drive sim:/lc3_datapath/rst 0 0

add wave -radix hex "sim:/lc3/lc3_datapath/PC"
add wave -radix hex "sim:/lc3/lc3_datapath/IR"
add wave -radix hex "sim:/lc3/lc3_datapath/MAR"
add wave -radix hex "sim:/lc3/lc3_datapath/MDR"
add wave -radix hex "sim:/lc3/lc3_datapath/N"
add wave -radix hex "sim:/lc3/lc3_datapath/Z"
add wave -radix hex "sim:/lc3/lc3_datapath/P"
add wave -radix hex "sim:/lc3/lc3_datapath/REGFILE"

add wave -radix hex "sim:/lc3/lc3_datapath/BUSS"

echo "Ensure that PC was reset correctly" 
checkValue "PC" hex 0000 

set CurrentLC3State [initState]

set instructions_executed 0
set num_instructions_to_test 10

set TestBenchState "Fetch"

while { $instructions_executed < $num_instructions_to_test } {
   #Step Clock 1 Cycle
   runClk 1
   
   #Tim
   
   #Check For State Update Events
}  

