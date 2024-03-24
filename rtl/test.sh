#!/usr/bin/env sh

iverilog -g2005-sv -o tb/mult_tb tb/mult_tb.sv mult256.v
iverilog -g2005-sv -o tb/divu_tb tb/divu_tb.sv divu256.sv
iverilog -g2005-sv -o tb/mod_q_tb tb/mod_q_tb.sv mod_q.sv divu256.sv

printf "$?"

#source tb/mult
./tb/mod_q_tb
