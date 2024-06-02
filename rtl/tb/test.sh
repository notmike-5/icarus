#!/usr/bin/env sh
# TODO: check success at each stage and only run successful testbenches?

BUILD_CMD='iverilog -g2005-sv -o'
echo "Initiating build..."

$BUILD_CMD half_adder_tb half_adder_tb.sv ../add.sv
$BUILD_CMD full_adder_tb full_adder_tb.sv ../add.sv
	
$BUILD_CMD half_subtractor_tb half_subtractor_tb.sv ../add.sv
$BUILD_CMD full_subtractor_tb full_subtractor_tb.sv ../add.sv
	
$BUILD_CMD rca_tb rca_tb.sv ../add.sv
$BUILD_CMD cla_tb cla_tb.sv ../add.sv
$BUILD_CMD csa_tb csa_tb.sv ../add.sv
	
$BUILD_CMD add_sub_tb add_sub_tb.sv ../add.sv 
$BUILD_CMD add_modp_tb add_modp_tb.sv ../add.sv
$BUILD_CMD sub_modp_tb sub_modp_tb.sv ../add.sv
	
$BUILD_CMD mult_tb mult_tb.sv ../mult.sv ../add.sv ../reduce.sv ../encode.sv
$BUILD_CMD divu_tb divu_tb.sv ../divu.sv
	
$BUILD_CMD reduce_tb reduce_tb.sv ../reduce.sv ../add.sv
$BUILD_CMD mod_p_tb mod_p_tb.sv ../mod_p.sv ../divu.sv
$BUILD_CMD mult_modp_tb mult_modp_tb.sv ../mult.sv ../add.sv ../reduce.sv ../encode.sv

$BUILD_CMD priority_encode_tb priority_encode_tb.sv ../encode.sv

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

# encode.sv
./priority_encode_tb
