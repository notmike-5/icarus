`timescale 1 ns / 100 ps

// testbench for sequential reduction modulo p

module mod_p_tb #(parameter N = 256);
  reg [N-1:0] n;
  reg [N-1:0] rem;
  reg	      clk, rst_n;
 
  mod_p U0 (n, clk, rst_n, rem);

  initial begin
    clk = 0;
    rst_n = 0;
    n = 0;
  end
  
  always #10 clk = ~clk;

  initial begin
    $display();
    $display("TB: Mod p module\n ###########################################");
    
    $dumpfile("waves/mod_p.vcd");
    $dumpvars(0, mod_p_tb);

    $monitor("%t:\n rst_n: %b\n n: %h\n mod p: %h \n", $time, rst_n, n, rem);

    #10;
    n = 256'd5_000_000;
    #1; rst_n = 1;

    #100000; rst_n = 0; #1;
    n = {256{1'b1}};
    #1; rst_n = 1;

    #100000; rst_n = 0;
    
    $finish;
  end
endmodule

