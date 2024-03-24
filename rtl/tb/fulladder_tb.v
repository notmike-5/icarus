// testbench for 1-bit full adder
module dut_testbench;
    reg a, b, cin;
    wire cout, sum;
    integer i;

    fulladder dut (cout, sum, cin, a, b);

    initial
    begin
        for (i = 0 ; i < 8 ; i = i + 1)
        begin
            {cin, a, b} = i ;
            #20
            $display("%b  %b  %b --> %b %b", cin, a, b, cout, sum);
        end
        $finish;
    end
endmodule
