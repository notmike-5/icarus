`timescale 1 ns / 100 ps

// Testbench: Modular Exponentiation (Montgomery Ladder)

module mod_exp_tb #(parameter N = 255) ();
  reg            clk, en;
  reg            rst_n;
  reg [N-1:0]    x, k;
  wire [N-1:0]   result;
  wire           data_rdy;

  mod_exp mod_exp0 (clk, en, rst_n, x, k, result);

  initial
    begin
      clk = 0; en = 0;
      rst_n = 0;
      x = 0; k = 0;
    end

  always #10 clk = ~clk;

  initial begin
    $display();
    $display("TB: Modular Exponentiation (Montgomery Ladder)\n###########################################");

    $dumpfile("waves/mod_exp.vcd");
    $dumpvars(0, mod_exp_tb);

    $monitor("%t:\n\t\tx: %h\n\t\t\n\t\tk: %h\n\t\tresult: %d", $time, x, k, result);

    // TEST 1: random, small
    // 5^12 = 244140625
    #10; rst_n = 1;
    x = 5;
    k = 12;
    en = 1; #20; en = 0;
    $display("\n%t:\t %d^%d  (mod p)", $time, 4'(x), 4'(k));

    #25000;

    // TEST 2: random, bigger
    // 2^512 = 1444
    #10; rst_n = 1;
    x = 2;
    k = 512;
    en = 1; #20; en = 0;
    $display("\n%t:\t %d^%d  (mod p)", $time, 4'(x), 12'(k));

    #55000;

    // TEST 3: random, much, much bigger
    // 2^57896044618658097711785492504343953926634992332820282019728792003956564819967 = 524288
    #10; rst_n = 1;
    x = 2;
    k = 57896044618658097711785492504343953926634992332820282019728792003956564819967;
    en = 1; #20; en = 0;
    $display("\n%t:\t %d^%d  (mod p)", $time, 4'(x), 255'(k));

    #1750000;

    $finish;
  end
endmodule
