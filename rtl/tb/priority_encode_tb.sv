`timescale 1ns / 100ps

// Testbench: 255-bit Priority Encoder
//  - this can help us to identify the most significant
//    bit of a number that is set.

module priority_encode_tb #(parameter N = 255) ();
  reg en;
  reg [N-1:0] n;  
  wire [$clog2(255)-1:0] i;
  
  priority_encode priority_encode0 (en, n, i);
  
  initial begin
    en = 0;
    n = 0;
  end
  
  initial begin
    $display();
    $display("TB: Priority Encoder\n###########################################");
    
    $dumpfile("waves/priority_encode_tb.vcd");
    $dumpvars(0, priority_encode_tb);
    
    $monitor("%t:\n n: %b, i: %d", $time, n, i);
    
    #1; en = 1;         // z
    n = '0; #1;         // 0
    n = 255'hF; #1;     // 3
    n = 255'hFF; #1;    // 7
    n = 255'hFFF; #1;   // 11
    n = 255'hFFFF; #1;  // 15
    n = 255'hFFFFF; #1; // 19
    n = '1; #1;         // 254
    
    #1; en = 0; #1      // z
    $finish;
  end
endmodule
