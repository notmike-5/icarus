// Sequential, N-bit x N-bit multiplier
//  - Shift-and-Add-based
module seq_mult #(parameter N = 256)
  (
   input wire		  clk,
   input wire		  rst_n,
   input wire [N-1:0]	  a, b, 
   
   output reg [(2*N)-1:0] prod, acc,
   output reg		  data_rdy,
   output reg [1:0]	  state		  
   );

  localparam BIT_LEN = $clog2(N);
  reg [BIT_LEN:0] cnt; // states

  localparam reset = 2'h0; 
  localparam mult = 2'h1;
  localparam done = 2'h2;  
  localparam standby = 2'h3;
  
  reg [1:0]  n_state;

  reg [N-1:0] a_cur, b_cur;
  
  always @(posedge clk or negedge rst_n, a, b)    
    if (!rst_n) begin
      a_cur <= 256'b0;
      b_cur <= 256'b0;
    end
    else if (a_cur != a || b_cur != b) begin
      a_cur <= a;
      b_cur <= b;
    end else begin
      a_cur <= a_cur;
      b_cur <= b_cur;
    end
  
  always @(posedge clk or negedge rst_n, a, b)
    begin
      if (!rst_n)
	cnt <= '0;
      else if (a_cur != a || b_cur != b)
	cnt <= '0;
      else if (cnt == N)
	cnt <= cnt;
      else
	cnt <= cnt + 1'b1;  
    end

  // n_state
  assign n_state = (!rst_n) || (cnt < N) ? mult :
		   (state == done) || (state == standby) ? standby :
		   (cnt == N) || ((a_cur >> cnt) == '0) ? done : standby;
	      
  always @(posedge clk or negedge rst_n, a, b)
    begin
      if (!rst_n)
	state <= reset;
      if (a_cur != a || b_cur != b)
	state <= reset;
      else
	state <= n_state;
    end //state

  always @(posedge clk, negedge rst_n) 
    begin
      if (!rst_n)
	data_rdy <= 0;
      else if (a_cur != a || b_cur != b)
	data_rdy <= 0;
      else if (state == done)
	data_rdy <= 1;
      else
	data_rdy <= data_rdy;
    end // data_rdy
  
  always @(posedge clk, negedge rst_n) 
    begin
      if (!rst_n) begin
	acc <= '0;
	prod <= '0;
      end
      else if (a_cur != a || b_cur != b) begin
	acc <= '0;
	prod <= '0;
      end
      else
	case(state)
	  reset: begin
	    acc <= '0;
	    prod <= '0;
	  end

	  mult: begin
	    acc <= (a_cur[cnt - 1] == 1'b1) ? acc + (512'(b_cur) << (cnt - 1)) : acc;
      	    prod <= prod;
	  end

	  done: begin
	    acc <= acc;
	    prod <= acc;
	  end

	  default: begin
	    acc <= acc;
	    prod <= prod;
	  end
	endcase
    end // acc_prod
endmodule // seq_mult


// multiplication modulo p = 2^255 - 19
module mult_modp #(parameter N = 255)
  (
   input	  clk, rst_n,
   input [N-1:0]  x, y,
   output [N-1:0] prod,
   output	  dr
   );

  wire [2*N-1:0] p;
  
  seq_mult #(.N(N)) mult0 (.clk(clk), .rst_n(rst_n), .a(x), .b(y),
			   .prod(p), .acc(), .data_rdy(dr), .state());

  reduce redc0 (.n(p), .r(prod));
  endmodule
