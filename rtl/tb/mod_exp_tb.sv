`timescale 1 ns / 100 ps

// Testbench: Modular Exponentiation (Montgomery Ladder)

module mod_exp_tb #(parameter N = 255) ();
  reg            clk, rst_n;
  reg  [N-1:0]	 x, k;
  wire [N-1:0]	 result;
  wire		 data_rdy;
  
  mod_exp mod_exp0 (clk, rst_n, x, k, result);

  initial 
    begin
      clk = 0;
      rst_n = 0;
      x = 0; k = 0;
    end
  
  always #10 clk = ~clk;
  
  initial begin
    $display();
    $display("TB: Modular Exponentiation (Montgomery Ladder)\n###########################################");

    $dumpfile("waves/mod_exp.vcd");
    $dumpvars(0, mod_exp_tb);

    $monitor("%t:\n\t\tx: %h\n\t\t\n\t\tk: %h\n\t\tresult: %d", $time, x, k, result);
    
    // TEST 1: 5^12 = 
    #1000;
    x = 5;
    k = 12;
    rst_n = 1;
    $display("\n%t:\t %d^%d  (mod p)", $time, 4'(x), 4'(k));
    
    #10000;
    $finish;
  end
endmodule
