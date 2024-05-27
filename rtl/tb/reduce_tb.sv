`timescale 1 ns / 100 ps

// testbench for reduction modulo p 

module reduce_tb #(parameter N = 255);
  reg [2*N-1:0] n;
  reg [N-1:0] r;
  
  reduce U0 (n, r);

  initial begin
    $display();
    $display("TB: Quick Reduction Module\n ###########################################");
    
    $dumpfile("waves/reduce.vcd");
    $dumpvars(0, reduce_tb);

    $monitor("%t:\n n: %d\n r: %d", $time, n, r);

    #10;
    n = 2;  // a number smaller than p
    #100;
    n = {510{1'b1}};  // largest possible product
    #100;
    n = {16{32'hdeadbeef}} << 1;  // chosen patter mod p is
    #100;  // 40227885138464997724684449426672570397534900615285750892290072162437648363105
    
    $finish;
  end
endmodule
