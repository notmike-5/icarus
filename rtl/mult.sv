// Sequential, N-bit x N-bit multiplier
//  - Shift-and-Add method used
//  - slower multiplications
//  - smaller footprint, less complex
module seq_mult #(parameter N = 256)
  (
   input wire		  clk, en,
   input wire		  rst_n,
   input wire [N-1:0]	  a, b, 
   
   output reg [(2*N)-1:0] prod, acc,
   output wire		  data_rdy
   );

  // states
  localparam reset = 2'h0; 
  localparam mult = 2'h1;
  localparam done = 2'h2;
  
  reg [1:0]  state, n_state;
  reg [$clog2(N):0] cnt;

  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
	cnt <= '0;
      else if ((state == reset) || (state == done))
	cnt <= '0;
      else if ((state != done) && (cnt < N))
	cnt <= cnt + 1'b1;
      else
	cnt <= cnt;  
    end

  // n_state
  assign n_state = (!rst_n) ? reset :
		   (state == done) ? reset :
		   en ? mult :
		   (state == mult) && (cnt < N) ? mult :
		   (state == mult) && (cnt == N) ? done : reset;
    
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
	state <= reset;
      else
	state <= n_state;
    end

  always @(posedge clk, negedge rst_n) 
    begin
      if (!rst_n) 
	acc <= '0;
      else
	case(state)
	  reset:
	    acc <= '0;

	  mult:
	    acc <= (a[cnt-1]) ? acc + (512'(b) << (cnt-1)) : acc;

	  default: // done
	    acc <= acc;
	endcase
    end

  assign data_rdy = (!rst_n) ? 'z :
		    (state == done);
  
  assign prod = (!rst_n) ? 'z :
		(data_rdy) ? acc : prod;
endmodule // seq_mult


// multiplication modulo p = 2^255 - 19
module mult_modp #(parameter N = 255)
  (
   input	  clk, en, 
   input	  rst_n,
   input [N-1:0]  x, y,
   output [N-1:0] prod,
   output	  dr
   );

  wire [2*N-1:0] p;
  
  seq_mult #(.N(N)) mult0 (.clk(clk), .en(en), .rst_n(rst_n), .a(x), .b(y),
			   .prod(p), .acc(), .data_rdy(dr));

  reduce redc0 (.n(p), .r(prod));
endmodule // mult_modp


// modular exponentiation modulo p = 2^255 - 19
// - Montgomery Ladder is utilized to avoid
// (simple) side-channel attacks based on timing.
// - the same number of operations (squares and 
// multiplications) are performed in each iteration.
module mod_exp #(parameter N = 255)
  (
   input	  clk, en, rst_n,
   input [N-1:0]  g, 
   input [N-1:0]  k,
   output [N-1:0] r
   );

  reg [N-1:0]	       X, Y, P0, P1;
  reg [N-1:0]	       R0, R1;
  reg [$clog2(N)-1:0]  idx, i;

  wire		       dr0, dr1; 
  reg		       data_valid, data_valid_d;
  wire		       done;
  reg		       done_d;
  
  priority_encode priority_encode0 (.en(rst_n), .n(k), .i(idx));

  mult_modp square (.clk(clk), .en(en || !done && data_valid_d), .rst_n(rst_n), .x(X), .y(X), .prod(P0), .dr(dr0));
  mult_modp multiply (.clk(clk), .en(en || !done && data_valid_d), .rst_n(rst_n), .x(X), .y(Y), .prod(P1), .dr(dr1));
    
  assign data_valid = (dr0 && dr1);
  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      data_valid_d = 'z;
    else
      data_valid_d <= data_valid;

  assign done = data_valid && (i == 0);
  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      done_d <= '0;
    else
      done_d <= done;

  always @(posedge clk or negedge rst_n, idx)
    if (!rst_n)
      i <= '0;
    else if (en)
      i <= idx;
    else if (data_valid && (i > 0))
      i <= i - 1;
    else 
      i <= i;
  
  always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      R0 <= 'z;
      R1 <= 'z;
    end 
    else if (en) begin
      R0 <= 1;
      R1 <= g;
    end 
    else if (data_valid) begin
      if (k[i] == 0) begin
	R0 <= P0;
	R1 <= P1;
      end 
      else begin
	R0 <= P1;
	R1 <= P0;
      end
    end 
    else begin
      R0 <= R0;
      R1 <= R1;
    end

  assign X = (!rst_n) ? 'z :
	     (k[i] == 0) ? R0 : R1;
  assign Y = (!rst_n) ? 'z :
	     (k[i] == 0) ? R1: R0;
  
assign r = (!rst_n) ? 'z : 
	   (done_d) ? R0 : r;
endmodule // mod_exp


module modp_inv #(parameter N = 255)
  (
   input clk, en, rst_n,
   input [N-1:0] x,
   output reg [N-1:0] r,
   output wire dr
   );

  wire [N-1:0] r0;
  
  // p_2 == p - 2 == (2**255 - 19) - 2
  
  localparam p_2 = 255'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeb;
  
  mod_exp #(.N(N)) mod_exp0 (.clk(clk), .en(en), .rst_n(rst_n), .g(x), .k(p_2), .r(r0));

  always @(r0)
    if (!rst_n)
      r = 'z;
    else
      r = r0;
endmodule // modp_inv

