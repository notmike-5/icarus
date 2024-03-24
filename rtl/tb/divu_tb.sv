// testbench for N-bit x N-bit divider
module divu_tb;
  reg          clk, rst;
  reg [255:0]  divd, dvsr;
  wire [255:0] val, rem;
  
  wire [2:0]   state;
  wire	       data_rdy;
  wire	       dbz;
  
  divu256 U0 (clk, rst, divd, dvsr, val, rem, dbz, state, data_rdy);
  
  initial begin
    $dumpfile("divu256.vcd");
    $dumpvars(0, divu_tb);
    clk = 0;
    rst = 0;
    divd = 0;
    dvsr = 0;
  end
  
  always #10 clk = ~clk;
  
  initial begin
    $monitor("%t: state: %d \ndata_rdy: %b \ndbz: %b \nval: %h \nrem: %h", $time, state, data_rdy, dbz, val, rem);
      
    $display("\n********************\nTEST 1: ’f/’f =  1 with rem 0\n********************\n");
    #10;
    divd = '1;
    dvsr = '1;
    rst = 1;
    
    #5120;

    #100;
    rst = 0;

    $display("\n********************\nTEST 2: 12/5 = 2 with rem 2\n********************\n");
    #100;
    divd = 12;
    dvsr = 5;
    rst = 1;

    #5120;
    
    #100;
    rst = 0;

    $display("\n********************\nTEST 3: divide by zero\n********************\n");
  // TEST 3: divide by zero
    #100;
    divd = 100;
    dvsr = 0;
    rst = 1;
    
    #5120;
    
    #100;
    rst = 0;

    $display("\n********************\nTEST 4: 5/7 = 0 with rem 5\n********************\n");
    #100;
    divd = 5;
    dvsr = 7;
    rst = 1;
    
    #5120;
    
    #100;
    rst = 0;

    $display("\n********************\nTEST 4: 45/9 = 5 with rem 0\n********************\n");
    #100;
    divd = 45;
    dvsr = 9;
    rst = 1;
    
    #5120;
    
    #100;
    $finish;
  end
endmodule
