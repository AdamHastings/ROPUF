//----------------------------------------------------------------------
// This File: fifo1.sv
//
// Copyright 2003-2014 Sunburst Design, Inc.
//
// Sunburst Design (Beaverton, OR): 
//            cliffc@sunburst-design.com
//            www.sunburst-design.com
//----------------------------------------------------------------------
module fifo1 (
  output logic [7:0] dout, 
  output logic       full, empty,
  input  logic       write, read, clk, rst_n,
  input  logic [7:0] din);

  logic [7:0] fifomem [0:15];
  logic [3:0] wptr, rptr;
  logic [4:0] cnt; //BUG 4: cnt must be 4:0 to represent 0-16 (changed 3:0 to 4:0) 

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      wptr  <= '0;
      rptr  <= '0; //BUG 1: Read Pointer not Reset (Added this line)
      cnt   <= '0;
      empty <= '1;
      full  <= '0;
    end
    else 
      case ({write, read})
        2'b00: ;     // no fifo write or read
        2'b01: begin // fifo read
	         if(cnt>0) begin //BUG 2: Read Code Should Not Execute if the FIFO is Empty (Added The IF Statement)
                   full <= '0;
	           rptr <= rptr + 1;
                   cnt  <= cnt  - 1;
                   if (cnt==1) empty <= '1; //BUG 6: cnt decrment is delayed, read on with 1 should result in empty
		 end
               end
        2'b10: begin // fifo write
                 empty <= '0;
                 if (cnt<=16) begin
                   wptr <= wptr + 1;
                   cnt  <= cnt  + 1;
                 end
                 if (cnt>= 15) full <= '1; //BUG 3: cnt incr is delayed, and cnt> 15 not evaluated during write, added (cnt>= 15)    
               end
        2'b11: // fifo write & read
                 if (full) begin
                   rptr  <= rptr + 1;
                   cnt   <= cnt  - 1;
		   full <= '0; //Bug 5: Cannot Write a Full FIFO (Added This line)	    
                 end
                 else if (empty) begin
                   wptr  <= wptr + 1;
                   cnt   <= cnt  + 1;
                 end
                 else begin
                   wptr  <= wptr + 1;
                   rptr  <= rptr + 1;
                 end
      endcase

  // FIFO synchronous memory write operation
  always_ff @(posedge clk)
    if (write && ((cnt <16) || ((cnt==16) && read)))
      fifomem[wptr] <= din;

  assign dout = fifomem[rptr];

`ifndef ASSERT_MACROS

 `define ASSERT_MACROS
  
 `define assert_clk(arg, ck=clk) \
   assert property (@(posedge ck) disable iff (!rst_n) arg)

 `define assert_async_rst(arg, ck=clk) \
   assert property (@(posedge ck) arg)
       
`endif

   ERROR_FIFO_RESET_SHOULD_CAUSE_EMPTY1_FULL0_RPTR0_WPTR0_CNT0:
     `assert_async_rst(!rst_n |-> (rptr==0 && wptr==0 && empty==1 && full==0 && cnt==0));
   ERROR_FIFO_SHOULD_BE_FULL:
     `assert_clk(cnt>15 |-> full);
   ERROR_FIFO_SHOULD_NOT_BE_FULL:
     `assert_clk(cnt<16 |-> !full);
   ERROR_FIFO_DID_NOT_GO_FULL:
     `assert_clk(cnt==15 && write && !read |-> ##1 full);
   ERROR_FIFO_SHOULD_BE_EMPTY:
     `assert_clk(cnt==0 |-> empty);
   ERROR_FIFO_SHOULD_NOT_BE_EMPTY:
     `assert_clk(cnt>0 |-> !empty);
   ERROR_FIFO_DID_NOT_GO_EMPTY:
     `assert_clk(cnt==1 && read && !write |-> ##1 empty);
   ERROR_FIFO_FULL_WRITE_CAUSED_WPTR_TO_CHANGE:
     `assert_clk((full && write && !read) |-> ##1 $stable(wptr));
   ERROR_FIFO_FULL_WRITE_CAUSED_FULL_FLAG_TO_CHANGE:
     `assert_clk((full && write && !read) |-> ##1 $stable(full));
   ERROR_FIFO_EMPTY_READ_CAUSED_EMPTY_FLAG_TO_CHANGE:
     `assert_clk((empty && read && !write) |-> ##1 $stable(rptr));
   ERROR_FIFO_EMPTY_READ_CAUSED_RPTR_TO_CHANGE:
     `assert_clk((empty && read && !write) |-> ##1 $stable(empty));
   ERROR_FIFO_WORD_COUNTER_IS_NEGATIVE:
     `assert_clk((cnt >=0));
   ERROR_FIFO_READWRITE_ILLEGAL_FIFO_FULL_OR_EMPTY:
     `assert_clk(read && write && !full && !empty |-> ##1 $stable(full) && $stable(empty));
   
endmodule