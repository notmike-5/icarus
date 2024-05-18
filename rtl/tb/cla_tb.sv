`timescale 1 ns / 100 ps

// Testbench: N-bit Carry Lookahead Adder

module cla_tb #(parameter N = 3) ();
  reg [N-1:0] a = 0;
  reg [N-1:0] b = 0;
  reg	      cin;
  wire [N-1:0] sum;
  wire	       cout;
  
  cla_add #(.N(N)) cla (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  initial 
    begin
      $display();
      $display("TB: Carry Lookahead Adder\n##########################");

      $dumpfile("waves/cla256.vcd");
      $dumpvars(0, cla_tb);
      
      $monitor("%t: a: %b, b: %b, sum: %b, cout: %b", 
	       $time, a, b, sum, cout);

      cin = 0;
      a = 3'b000; b = 3'b001; #1;
      a = 3'b010; b = 3'b010; #1;
      a = 3'b101; b = 3'b110; #1;
      a = 3'b111; b = 3'b111; #1;
      
      $finish();
    end
endmodule
