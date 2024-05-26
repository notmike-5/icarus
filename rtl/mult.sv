// Sequential, N-bit x N-bit multiplier
//  - Shift-and-Add-based
module seq_mult #(parameter N = 256)
  (
   input wire		  clk,
   input wire		  rst,
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

  always @(posedge clk or negedge rst)
    begin
      if (!rst)
	cnt <= '0;
      else if (cnt == N)
	cnt <= cnt;
      else
	cnt <= cnt + 1'b1;  
    end

  // n_state
  assign n_state = (!rst) || (cnt < N) ? mult :
		   (state == done) || (state == standby) ? standby :
		   (cnt == N) || ((a >> cnt) == '0) ? done : standby;
	      
  always @(posedge clk or negedge rst)
    begin
      if (!rst)
	state <= reset;
      else
	state <= n_state;
    end //state

  always @(posedge clk, negedge rst) 
    begin
      if(!rst)
	data_rdy <= 0;
      else if(state == done)
	data_rdy <= 1;
      else
	data_rdy <= data_rdy;
    end // data_rdy
  
  always @(posedge clk, negedge rst) 
    begin
      if(!rst) begin
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
	    acc <= (a[cnt - 1] == 1'b1) ? acc + (512'(b) << (cnt - 1)) : acc;
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
endmodule // mult
