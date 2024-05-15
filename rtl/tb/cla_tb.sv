`timescale 1 us / 10 ps

module cla_tb #(parameter N = 3)();
 reg [N-1:0] a = 0;
 reg [N-1:0] b = 0;
 wire [N:0]  sum;

 cla_add #(.N(N)) cla_instance (.a(a), .b(b), .sum(sum));

 initial 
   begin
    $display();
    $display("TB: Carry Look-ahead Adder\n##########################");
    $monitor("%t: a: %b, b: %b, sum: %b", 
	     $time, a, b, sum);
    
    a = 3'b000; b = 3'b001; #10;
    a = 3'b010; b = 3'b010; #10;
    a = 3'b101; b = 3'b110; #10;
    a = 3'b111; b = 3'b111; #10;

    $finish();
   end
 
 initial begin
  $dumpfile("waves/cla256.vcd");
  $dumpvars(0, cla_tb);
 end

endmodule
