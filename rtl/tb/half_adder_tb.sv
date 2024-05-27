`timescale 1 ns / 100 ps

// Testbench: Half-Adder

module half_adder_tb ();
  reg a, b, cin;
  wire sum, cout;
  
  half_adder fa (a, b, sum, cout);
  
  initial begin
    $display();
    $display("Half_Adder Truth Table\n======================");

    $monitor("%t: | a: %b | b: %b | sum: %b | cout: %b |", 
	     $time, a, b, sum, cout);
    
    a = 0; b = 0; #1;
    a = 0; b = 1; #1;
    a = 1; b = 0; #1;
    a = 1; b = 1; #1;
  end
endmodule  
