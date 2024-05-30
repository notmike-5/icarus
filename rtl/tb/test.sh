#!/usr/bin/env sh

echo "Initiating build..."
iverilog -g2005-sv -o half_adder_tb half_adder_tb.sv ../add.sv
iverilog -g2005-sv -o full_adder_tb full_adder_tb.sv ../add.sv

iverilog -g2005-sv -o half_subtractor_tb half_subtractor_tb.sv ../add.sv
iverilog -g2005-sv -o full_subtractor_tb full_subtractor_tb.sv ../add.sv

iverilog -g2005-sv -o rca_tb rca_tb.sv ../add.sv
iverilog -g2005-sv -o cla_tb cla_tb.sv ../add.sv
iverilog -g2005-sv -o csa_tb csa_tb.sv ../add.sv

iverilog -g2005-sv -o add_sub_tb add_sub_tb.sv ../add.sv 
iverilog -g2005-sv -o add_modp_tb add_modp_tb.sv ../add.sv
iverilog -g2005-sv -o sub_modp_tb sub_modp_tb.sv ../add.sv

iverilog -g2005-sv -o mult_tb mult_tb.sv ../mult.sv ../add.sv ../reduce.sv
iverilog -g2005-sv -o divu_tb divu_tb.sv ../divu.sv

iverilog -g2005-sv -o reduce_tb reduce_tb.sv ../reduce.sv ../add.sv
iverilog -g2005-sv -o mod_p_tb mod_p_tb.sv ../mod_p.sv ../divu.sv
iverilog -g2005-sv -o mult_modp_tb mult_modp_tb.sv ../mult.sv ../add.sv ../reduce.sv

# TODO: check success at each stage and only run successful testbenches?
echo 'Build complete.\n'

read -s -n 1 -t 5 -p $'Continue...?\n'
 
if [ $? -eq 0 ]; then
    echo "Initiating Tests..."
else
    echo "Timeout after 5 secs."
    exit
fi

# add.sv
./half_adder_tb
./full_adder_tb
./half_subtractor_tb
./full_subtractor_tb
./rca_tb
./cla_tb
./csa_tb
./add_sub_tb
./add_modp_tb 
./sub_modp_tb 

# mult.sv
./mult_tb
./mult_modp_tb 

# divu.sv
./divu_tb

# mod_p.sv
./mod_p_tb

# reduce.sv
./reduce_tb
