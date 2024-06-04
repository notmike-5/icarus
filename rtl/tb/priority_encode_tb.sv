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
    
    #1; en = 1;                            // z
    n = '0; #1;                            // 0
    n = { {7{32'h0}}, {1{32'hFFFFFFFF}} }; #1; // 31  
    n = { {6{32'h0}}, {2{32'hFFFFFFFF}} }; #1; // 63
    n = { {4{32'h0}}, {4{32'hFFFFFFFF}} }; #1; // 127
    n = { {1{32'h0}}, {6{32'hFFFFFFFF}} }; #1; // 191
    n = '1;                                    // 254  
    #1; en = 0; #1;                        // z
    $finish;
  end
endmodule
