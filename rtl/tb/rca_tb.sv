// Testbench: N-bit Ripple-Carry Adder/Subtractor
`timescale 1 us / 10 ps

module rca_tb #(parameter N = 4)();
 reg [N-1:0]  a, b;
 reg	      cin;
 wire [N-1:0] sum;
 wire	      cout;
 
 rca_add #(.N(N)) rca (a, b, cin, sum, cout);

 initial begin
  $display();
  $display("TB: Ripple-Carry Adder\n######################");
  $monitor("%t: a: %b, b: %b, sum: %b, cout: %b", 
	   $time, a, b, sum, cout);
 
  cin = 0; 
  a = 4'b0110; b = 4'b1100; #10;
  a = 4'b1110; b = 4'b1000; #10;
  a = 4'b0111; b = 4'b1110; #10;
  a = 4'b0010; b = 4'b1001; #10;
  
  $finish();
 end          

 initial begin
  $dumpfile("waves/rca_tb.vcd");
  $dumpvars(0, rca_tb);
 end
 
endmodule
