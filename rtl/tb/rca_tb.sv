// Testbench: N-bit Ripple-Carry Adder/Subtractor
module rca_tb #(parameter N = 3);
 reg [N:0]  a, b;
 wire [N:0] result, cout;
 bit	    ctrl;

 rca_add rcas (a, b, ctrl, result, cout);

 initial begin
  $dumpfile("rca_tb.vcd");
  $dumpvars(0, rca_tb);

  $monitor("%t: CTRL: %b, a: %b, b: %b  -->  Result: %b", 
	   $time, ctrl, a, b, result, cout[N]);
  
  ctrl = 1; 
  a = 1; b = 0; #10;
  a = 2; b = 4; #10;
  a = 11; b = 6; #10;
  a = 5; b = 3; #10;
  
  ctrl = 1; 
  a = 1; b = 0; #10;
  a = 2; b = 4; #10;
  a = 11; b = 6; #10;
  a = 5; b = 3; #10;
  $finish;
  
 end // initial begin
