`timescale 1 ns / 100 ps

// Testbench: Sequential, N-bit x N-bit Multiplier

module mult_tb #(parameter N = 256) ();
  reg          clk, en, rst_n;
  reg [N-1:0]  a, b;
  wire	       data_rdy;
  
  wire [2*N-1:0] prod;
  wire [2*N-1:0] acc;
  
  seq_mult U0 (clk, en, rst_n, a, b, prod, acc, data_rdy);

  initial 
    begin
      clk = 0;
      en = 0;
      rst_n = 0;
      a = 0;
      b = 0;
    end
  
  always #10 clk = ~clk;
  
  initial begin
    $display();
    $display("TB: %d-bit Multiplier (Sequential)\n###########################################", N);

    $dumpfile("waves/mult256.vcd");
    $dumpvars(0, mult_tb);

    $display("%t:\t Reset...\n", $time);
    $monitor("%t:\t\tprod: %h", $time, prod);
    
    // TEST 1: 5 x 12 
    //       = 60 (hex: 0x3c)
    #10;
    en = 1;
    a = 5;
    b = 12;
    rst_n = 1;
    $display("\n%t:\t Multiply %d x %d\n", $time, 4'(a), 4'(b));
    
    #5150;
    
    //assert property(2+2==1);

    // TEST 2: 256’f x 2 
    //       = (hex:  0x1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe)
    #100;
    a = '1;
    b = 256'h2;
    $display("\n%t:\t Multipy %h x %h\n", $time, a, b);

    #5150;
    
    // TEST 3: 0xc000000000000000000000000000000000000000000000000000000000000000  x  2
    //       = (hex: 0x1800000000000000000000000000000000000000000000000000000000000000)
    #100;
    a = 256'h2;
    b = {4'hc, 252'h0};
//    rst_n = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, a, b);
    
    #5150;
    
    // TEST 4: 0x8000000000000000000000000000000000000000000000000000000000000000  x  2
    //       = (hex: 0x10000000000000000000000000000000000000000000000000000000000000000)
    #100;
    a = {4'h8, 252'h0};
    b = 256'h2;
//    rst_n = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, a, b);
    
    #5150;
    
    // TEST 5: 256’f x 256’f
    //       = (hex: 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0000000000000000000000000000000000000000000000000000000000000001)
    #100;
    a = '1;
    b = '1;
//    rst_n = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, a, b);
    
    #5150;

    #1000;
    $display("%t:\t Reset...\n", $time);
    rst_n = 0;
    #1000;
    
    // TEST 6: interrupt multiplication
    //       = (hex: deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeee2152411021524110215241102152411021524110215241102152411021524111)
    a = 3;
    b = 4; 
    $display("\n%t:\t Multiply %d x %d\n", $time, 4'(a), 4'(b));
    rst_n = 1; #40;

    $display("\n%t:\t Multiplication interrupted.", $time); #10;
    a = 256'hDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF;
    b = '1; 
    $display("\n%t:\t Multiply %h x %h\n", $time, a, b); #5150;

    #100;
    $finish;
  end
endmodule
