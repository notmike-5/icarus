`timescale 1 ns / 100 ps

// Testbench: Full-Adder

module full_adder_tb ();
  reg a, b, cin;
  wire sum, cout;
  
  full_adder fa (a, b, cin, sum, cout);
  
  initial begin
    $display();
    $display("Full_Adder Truth Table\n======================");

    $monitor("%t: | a: %b | b: %b | cin: %b | sum: %b | cout: %b |", 
	     $time, a, b, cin, sum, cout);
    
    a = 0; b = 0; cin = 0; #1;
    a = 0; b = 0; cin = 1; #1;
    a = 0; b = 1; cin = 0; #1;
    a = 0; b = 1; cin = 1; #1;
    a = 1; b = 0; cin = 0; #1;
    a = 1; b = 0; cin = 1; #1;
    a = 1; b = 1; cin = 0; #1;
    a = 1; b = 1; cin = 1; #1;
  end
endmodule  
