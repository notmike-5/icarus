// testbench for reduction modulo q module 
module mod_q_tb #(parameter N = 256);
  reg [N-1:0] a;
  reg [N-1:0] b;
  reg	    clk, rst_n;
 
  mod_q U0 (clk, rst_n, a, b);

  initial begin
    $dumpfile("mod_q.vcd");
    $dumpvars(0, mod_q_tb);
    
    clk = 0;
    rst_n = 0;
    a = 0;
  end
  
  always #10 clk = ~clk;

  initial begin
    $monitor("%t: \n rst_n: %d \n a: %h \n b: %h \n", $time, rst_n, a, b);

    #10;
    a = 256'd5_000_000;
    rst_n = 1;

    #10000;
    a = '1;
    rst_n = 0;

    #10;
    rst_n =1;

    #10000;

    rst_n = 0;
    
    $finish;
  end
endmodule

