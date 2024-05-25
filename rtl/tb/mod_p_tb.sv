`timescale 1 ns / 100 ps

// testbench for sequential reduction modulo p

module mod_p_tb #(parameter N = 256);
  reg [N-1:0] n;
  reg [N-1:0] rem;
  reg	      clk, rst_n;
 
  mod_p U0 (n, clk, rst_n, rem);

  initial begin
    clk = 0;
    rst_n = 0;
    n = 0;
  end
  
  always #10 clk = ~clk;

  initial begin
    $display();
    $display("TB: Sequential divider-based (mod p) module\n###########################################");
    
    $dumpfile("waves/mod_p.vcd");
    $dumpvars(0, mod_p_tb);

    $monitor("%t:\n n: 0x%h\n mod p:\n%d \n", $time, n, rem);

    // Test 1 - Some number already smaller than p.
    //      n: 7,000,000
    //  mod p: 7,000,000
    n = 256'd7_000_000;
    #1; rst_n = 1;

    // Test 2 - A number somewhat larger than p.
    //      n: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    //  mod p: 37
    #15000; rst_n = 0;
    n = {256{1'b1}};
    #1; rst_n = 1;

    // Test 3: Some random number
    //         n: 0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
    //     mod p: 42824390107717648298672532335567665951483711071615920846369630979332844142338
    //  (or) hex: 0x5eadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbf02
    #15000; rst_n = 0;
    n = {8{32'hDEADBEEF}};   
    #1; rst_n = 1;

    // Test 4: p mod p = 0
    //      n:  0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed
    //  mod p:  0
    #15000; rst_n = 0;
    n = 256'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffed;
    #1; rst_n = 1;
        
    #1000; rst_n = 0; #1;
    
    $finish;
  end
endmodule

