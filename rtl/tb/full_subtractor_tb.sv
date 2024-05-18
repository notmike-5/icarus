`timescale 1 ns / 100 ps

// Testbench: Full-Subtractor

module full_subtractor_tb ();
  reg a, b, bin;
  wire diff, bout;

  full_subtractor U0 (a, b, bin, diff, bout);

  initial begin
    $display();
    $display("Full_Subtractor Truth Table\n===========================");

    $monitor("%t: | a: %b | b: %b | bin: %b | diff: %b | bout: %b |", 
	     $time, a, b, bin, diff, bout);

    a = 0; b = 0; bin = 0; #1;
    a = 0; b = 0; bin = 1; #1;
    a = 0; b = 1; bin = 0; #1;
    a = 0; b = 1; bin = 1; #1;
    a = 1; b = 0; bin = 0; #1;
    a = 1; b = 0; bin = 1; #1;
    a = 1; b = 1; bin = 0; #1;
    a = 1; b = 1; bin = 1; #1;
  end
endmodule  
