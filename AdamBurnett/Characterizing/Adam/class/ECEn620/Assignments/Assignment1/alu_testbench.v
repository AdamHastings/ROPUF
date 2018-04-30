`default_nettype none
`timescale 1ns/100ps 

module alu_testbench (); 

  reg clk;
  wire reset;
  wire [1:0] Opcode;
  wire signed [3:0] A;
  wire signed [3:0] B;
  wire signed [4:0] C;
  
  reg signed [10:0] test_vector; 
  reg [4:0] expected_result;
  integer errors;

  always begin
    #10 clk = !clk; 
  end 
  
  ALU_4_bit ALU(clk, 
                reset, 
                Opcode, 
                A, B, C );
  
  assign A =  test_vector[3:0];
  assign B =  test_vector[7:4];
  assign reset = test_vector[8];  
  assign Opcode = test_vector[10:9];  

  initial begin
    $display("Starting Testbench:");
    clk = 0;  
    test_vector = 11'b11111111111;
    errors = 16'd0; 
    forever begin       
      @ (negedge clk) 
      //Update Test Vector 
      test_vector = test_vector + 1'b1;
      //Wait to allow wire value to propegate
      #1 //ns
      //Define Expected Results based on Current Inputs
       if(reset) begin
          expected_result = 5'b0; 
       end else begin
         case (Opcode)  
           2'b00: expected_result = A + B; 
           2'b01: expected_result = A - B; 
           2'b10: expected_result = ~A; 
           2'b11: expected_result = |B; 
         endcase
       end 

      @ (posedge clk) 
      
      #1 //ns
      
      if(expected_result != C) begin
        errors = errors + 1; 
        $display("Error @ time %d: Reset: %d Opcode: %d A: %d B: %d C: %d Expected Result: %d", $time, reset, Opcode, A, B, C, expected_result); 
      end

      if(test_vector == 11'b11111111111) begin
        $display("Test Complete: Found %d Errors", errors); 
        $finish; 
      end 

      
    end  
  end 

endmodule