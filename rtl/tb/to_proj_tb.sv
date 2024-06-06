`timescale 1 ns / 10 ps

// Testbench: Affine-to-Projective Point Encoder

module to_proj_tb #(parameter N = 255) ();
  reg clk, en, rst_n;
      
  reg [N-1:0] Px, Py;  
  wire [N-1:0] Rx, Ry, Rz, Rt;
  
  to_proj to_proj0 (clk, en, rst_n, Px, Py, Rx, Ry, Rz, Rt);
  
  initial begin
    clk = 0; rst_n = 0;
    en = 0;
    Px = 0; Py = 0;
  end

  always #10 clk = ~clk;
  
  initial begin
    $display();
    $display("TB: Extended (projective) Coordinate Encoder\n###########################################");
    
    $dumpfile("waves/to_proj_tb.vcd");
    $dumpvars(0, to_proj_tb);
    
    $monitor("%t:\n(%h, %h, %h, %h)", $time, Rx, Ry, Rz, Rt);

    // Test 0: (0, 1) -> (0, 1, 1, 0)
    #10; rst_n = 1; #20;
    Px = 0; Py = 1;
    en = 1; #20 en = 0;

    $display("\t\t\t\tTest 0 (neutral point): (0, 1)  -->  (0, 1, 1, 0)");
    
    #7500;

    $finish;
  end
endmodule
