`timescale 1 us / 100 ps

// Testbench: Adder modulo p = 2^255 - 19

module add_modp_tb #(parameter N = 255) ();
  reg [N-1:0] x, y;
  wire [N-1:0] sum;
  
  add_modp add_modp0 (x, y, sum);

  initial 
    begin
      $display();
      $display("TB: Addition modluo p = 2^255 - 19 \n#######################");

      $dumpfile("waves/add_modp_tb.vcd");
      $dumpvars(0, add_modp_tb);

      $monitor("%t:\n\t\t\t x: %h\n\t\t\t y: %h\n\t\t\t sum (mod p): %d",
	       $time, x, y, sum);

      x = 0; y = 0; #1;    // 0+0 = 0  (mod p)
      x = 0; y = 1; #1;    // 0+1 = 1  (mod p)

      x = {255{1'b1}};
      y = {255{1'b1}}; #1;         // x+y = 36  (mod p)

      x = {255{1'b1}} - 20;
      y = {255{1'b1}} - 20; #1;    // x+y = 57896044618658097711785492504343953926634992332820282019728792003956564819945_10  (mod p)

      x = 2**255 - 19;    // p + 15 = 15  (mod p)
      y = 15; #1;

      x = 2**255 - 19;    // p + p = 0  (mod p)
      y = -19;

      x = 2**255 - 19;    // p + (p-1) = (p-1)  (mod p)
      y = -20; // 57896044618658097711785492504343953926634992332820282019728792003956564819948_10
      $finish();
    end
endmodule
