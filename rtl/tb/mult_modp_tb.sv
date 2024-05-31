`timescale 1 ns / 100 ps

// Testbench: 255-bit x 255-bit Multiplier modulo p

module mult_modp_tb #(parameter N = 255) ();
  reg            clk, rst_n;
  reg  [N-1:0]	 x, y;
  wire [N-1:0]	 prod;
  wire		 data_rdy;
  
  mult_modp mult_mp0 (clk, rst_n, x, y, prod, data_rdy);

  initial 
    begin
      clk = 0;
      rst_n = 0;
      x = 0; y = 0;
    end
  
  always #10 clk = ~clk;
  
  initial begin
    $display();
    $display("TB: Multiplier modulo p \n###########################################");

    $dumpfile("waves/mult_modp.vcd");
    $dumpvars(0, mult_modp_tb);

    $monitor("%t:\t\tprod: %d", $time, prod);
    
    // TEST 1: 5 x 12 
    //       = 60 (hex: 0x3c)
    #10;
    x = 5;
    y = 12;
    rst_n = 1;
    $display("\n%t:\t Multiply %d x %d\n", $time, 4'(x), 4'(y));
    
    #5120;

    #100;
    rst_n = 0;

    // TEST 2:
    #100;
    x = '1;
    y = '1;
    rst_n = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, x, y);

    #5120;
    
    #100;
    rst_n = 0;
    
    // TEST 3: 
    #100;
    x = '1;
    y = '0;
    rst_n = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, x, y);
    
    #5120;

    #100;
    rst_n = 0;
    
    // TEST 3: 
    #100;
    x = '0;
    y = '1;
    rst_n = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, x, y);
    
    #5120;

    #100;
    rst_n = 0;
    
    // TEST 3: x * 255’hFFFF_FFFF_..._FFFF  
    // = 6371141355922591274545700801554153484093987033124982003387988869345867405877
    #100;
    x = 255'h328f70e62b46c116022322a0de44523a776a15e62e1618680a367362906e2c18;
    y = '1;
    rst_n = 1;
    $display("\n%t:\t Multipy %h x %h\n", $time, x, y);
    
    #5120;    
    
    #1000;
    $finish;
  end
endmodule
