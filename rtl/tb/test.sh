#!/usr/bin/env sh

iverilog -g2005-sv -o full_adder_tb full_adder_tb.sv ../add256.sv
iverilog -g2005-sv -o full_subtractor_tb full_subtractor_tb.sv ../add256.sv
iverilog -g2005-sv -o rca_tb rca_tb.sv ../add256.sv
iverilog -g2005-sv -o cla_tb cla_tb.sv ../add256.sv
iverilog -g2005-sv -o add_sub_tb add_sub_tb.sv ../add256.sv 

iverilog -g2005-sv -o mult_tb mult_tb.sv ../mult256.sv
iverilog -g2005-sv -o divu_tb divu_tb.sv ../divu256.sv
iverilog -g2005-sv -o mod_p_tb mod_p_tb.sv ../mod_p.sv ../divu256.sv

#printf "$?" # check success at each stage and only run successful testbenches?

# add256.sv
./full_adder_tb
./full_subtractor_tb
./rca_tb
./cla_tb 
./add_sub_tb

# mult256.sv
#./mult_tb

# divu256.sv
#./divu_tb

# mod_q.sv
./mod_p_tb
