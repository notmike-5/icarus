`timescale 1 us / 100 ps

// Testbench: Subtractor modulo p = 2^255 - 19

module sub_modp_tb #(parameter N = 255) ();
  localparam [N-1:0] p = 2**255 - 19;
		     
  reg [N-1:0] x, y;
  wire [N-1:0] diff;
  
  sub_modp sub_modp0 (x, y, diff);

  initial 
    begin
      $display();
      $display("TB: Subtraction modluo p = 2^255 - 19 \n#######################");

      $dumpfile("waves/sub_modp_tb.vcd");
      $dumpvars(0, sub_modp_tb);

      $monitor("%t:\n\t\t\t x: %h\n\t\t\t y: %h\n\t\t\t diff (mod p): %d",
	       $time, x, y, diff);

      x = 0; y = 0; #1;      // Test: 
                             // (0 - 0) = 0  (mod p)

      x = 0; y = 1; #1;      // (0 - 1) = (p - 1)  (mod p)
      // (p - 1) = 57896044618658097711785492504343953926634992332820282019728792003956564819948_10
                             // 7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffec_16
      
      x = 0; y = 2; #1;      // (0 - 2) = (p - 2)  (mod p)
      
      x = 0; y = p; #1;      // (0 - p) = -p = p = 0  (mod p) 

$finish();
    end
endmodule
