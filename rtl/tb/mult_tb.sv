// testbench for n-bit x n-bit multiplier
module mult_tb;
  reg          clk, rst;
  reg  [255:0] a, b;
  wire	       data_rdy;
  wire [511:0] prod;
  wire [511:0] acc;
  wire [1:0] state;
  
  mult256 U0 (clk, rst, a, b, prod, acc, data_rdy, state);
  
  initial begin
    clk = 0;
    rst = 0;
    a = 0;
    b = 0;
  end
  
  always #10 clk = ~clk;
  
  initial begin
    //$monitor("%t: state: %d\n\t data_rdy: %b\n\t prod: %h\n\t", $time, state, data_rdy, prod);
    $monitor("%t:\t\tprod: %h", $time, prod);
      
  // TEST 1: 5 x 12 
  //       = 60 (hex: 0x3c)
    #10;
    a = 5;
    b = 12;
    rst = 1;
    $display("\n%t:\t Multiply %d x %d\n", $time, 4'(a), 4'(b));
    
    #5120;
    
    //assert property(2+2==1);

    #100;
    rst = 0;

  // TEST 2: 256’f x 2 
  //       = 0x1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe
    #100;
    a = '1;
    b = 256'h2;
    rst = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, a, b);

    #5120;
    
    #100;
    rst = 0;
    
  // TEST 3: 0xc000000000000000000000000000000000000000000000000000000000000000  x  2
  //       = (hex: 0x1800000000000000000000000000000000000000000000000000000000000000)
    #100;
    a = 256'h2;
    b = {4'hc, 252'h0};
    rst = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, a, b);
    
    #5120;
    
    #100;
    rst = 0;

  // TEST 4: 0x8000000000000000000000000000000000000000000000000000000000000000  x  2
  //       = (hex: 0x10000000000000000000000000000000000000000000000000000000000000000)
    #100;
    a = {4'h8, 252'h0};
    b = 256'h2;
    rst = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, a, b);
    
    #5120;
    
    #100;
    rst = 0;

  // TEST 5: 256’f x 256’f
  //       = (hex: )
    #100;
    a = '1;
    b = '1;
    rst = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, a, b);
    
    #5120;

    #100;
    $finish;
  end
endmodule
