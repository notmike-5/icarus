// Testbench: Adder-Subtractor (Ripple-Carry based)
module add_sub_tb #(parameter N = 4) ();
reg ctrl;
reg [N-1:0] a, b;
wire [N-1:0] result;
wire cb_bit;

add_sub #(.N(N)) addsub0 (ctrl, a, b, result, cb_bit);

initial 
  begin
   $display();
   $display("TB: Adder-Subtractor\n#######################");
   $monitor("%t: a: %b, b: %b, result: %b", 
	    $time, a, b, result);
   
   ctrl = 0; // Addin’
   a = 5; b = 3; #20;
   
   ctrl = 1; // Subtractin’
   #20;
   
   $finish();
  end

initial begin
 $dumpfile("waves/sum_add.vcd");
 $dumpvars(0, add_sub_tb);
end
endmodule
