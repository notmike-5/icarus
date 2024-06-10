`timescale 1 ns / 100 ps

// Testbench: Modular Inversion modulo p = 2^255 - 19

module modp_inv_tb #(parameter N = 255) ();
  reg            clk, en, rst_n;
  reg [N-1:0]	 x;
  wire [N-1:0]	 result;
  wire		 data_rdy;
  
  modp_inv modp_inv0 (clk, en, rst_n, x, result);

  initial 
    begin
      clk = 0; en = 0;
      rst_n = 0;
      x = 0;
    end
  
  always #10 clk = ~clk;
  
  initial begin
    $display();
    $display("TB: Modular Inversion modulo p = 2^255 - 19\n###########################################");

    $dumpfile("waves/modp_inv.vcd");
    $dumpvars(0, modp_inv_tb);

    $monitor("%t:\n\t\tx: %h\n\t\tresult: %d", $time, x, result);

    #20;
    x = 5;
    rst_n = 1;
    
    #20; en = 1; #20; en = 0;
    
    #1325000
    $finish;
  end
endmodule
