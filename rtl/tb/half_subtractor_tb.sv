`timescale 1 ns / 100 ps

// Testbench: Half-Subtractor

module half_subtractor_tb ();
  reg a, b;
  wire diff, bout;
  
  half_subtractor fa (a, b, diff, bout);
  
  initial begin
    $display();
    $display("Half_Subtractor Truth Table\n======================");

    $monitor("%t: | a: %b | b: %b | diff: %b | bout: %b |", 
	     $time, a, b, diff, bout);
    
    a = 0; b = 0; #1;
    a = 0; b = 1; #1;
    a = 1; b = 0; #1;
    a = 1; b = 1; #1;
  end
endmodule  
