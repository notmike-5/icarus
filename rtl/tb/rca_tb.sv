`timescale 1 ns / 100 ps

// Testbench: N-bit Ripple-Carry Adder

module rca_tb #(parameter N = 4)();
  reg [N-1:0]  a, b;
  reg	       cin;
  wire [N-1:0] sum;
  wire	       cout;
  
  rca_add #(.N(N)) rca (a, b, cin, sum, cout);

  initial begin
    $display();
    $display("TB: Ripple-Carry Adder\n######################");

    $dumpfile("waves/rca_tb.vcd");
    $dumpvars(0, rca_tb);

    $monitor("%t: a: %b, b: %b, sum: %b, cout: %b", 
	     $time, a, b, sum, cout);
    
    cin = 0; 
    a = 4'b0110; b = 4'b1100; #1;
    a = 4'b1110; b = 4'b1000; #1;
    a = 4'b0111; b = 4'b1110; #1;
    a = 4'b0010; b = 4'b1001; #1;
    
    $finish();
  end          
endmodule
