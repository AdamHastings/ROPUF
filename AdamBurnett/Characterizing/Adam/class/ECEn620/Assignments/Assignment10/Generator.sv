
`define SV_RAND_CHECK(r) \
   do begin \
      if (!(r)) begin \
	 $display("%s:%0d: Randomization failed \"%s\"", \
		  `__FILE__, `__LINE__, `"r`");\
	 $finish; \
      end \
   end while(0) 
     
class Instruction #(ADDRESS_WIDTH=8);
   rand bit [7:0] byte0;
   rand bit [ADDRESS_WIDTH-1:0] byte1;

   bit [3:0] opcode;
   bit [1:0] src;
   bit [1:0] dst;
   
   //Don't allow the Generator to Create BR, BRZ, or HALT Inst
   constraint c_byte0 { byte0[7:4] != BR; 
                        byte0[7:4] != BRZ;
                        byte0[7:4] != HALT;
                        byte0[7:4] != 4'hA;
                        byte0[7:4] != 4'hB;
                        byte0[7:4] != 4'hC; 
                        byte0[7:4] != 4'hD; 
                        byte0[7:4] != 4'hE; };
   //Don't Randomize byte1 if single byte inst
   constraint c_byte1 { ( byte0[7:4] == NOP ||
			  byte0[7:4] == ADD ||
			  byte0[7:4] == SUB ||
			  byte0[7:4] == AND ||
			  byte0[7:4] == NOT ||
			  byte0[7:4] == HALT) -> (byte1 == 0);};
   
   function void post_randomize();
      opcode = byte0[7:4];
      src = byte0[3:2];
      dst = byte0[1:0];
   endfunction // post_randomize
   
endclass // Instruction

class Generator #(ADDRESS_WIDTH=8);
   Instruction #(ADDRESS_WIDTH) I;
   mailbox   #(Instruction #(ADDRESS_WIDTH)) mbx;
   event     handshake;
   
   function new (mailbox #(Instruction #(ADDRESS_WIDTH)) m, event hs);
      mbx = m;
      I = new ();
      handshake = hs;
   endfunction // new

   task run(int count);
      Instruction #(ADDRESS_WIDTH) i;
      repeat(count) begin
	 `SV_RAND_CHECK(I.randomize());
	 i=new I;
	 mbx.put(i);
	 wait(handshake.triggered);
      end
   endtask
endclass // Generator
