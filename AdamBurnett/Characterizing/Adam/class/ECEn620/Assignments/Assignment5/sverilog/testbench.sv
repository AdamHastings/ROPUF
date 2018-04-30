`default_nettype none
`timescale 1ns/100ps 

import TransactionPkg::*;

program automatic test(mem_if.TEST mem_bus);
    
  
  Transaction Trans[]; 
  initial begin 
        
    //Initialize Score Board
    Trans = new[6]; 
        
    //Generate Random Writes      
    foreach(Trans[i]) begin
      Trans[i] = new();   
    end 
     
    mem_bus.cb.read <= 0;
    //Test Protocol Error Checker
    //This should produce three Errors
    //mwrite(0, 0);
    //mread(0);
     
    //@mem_bus.cb;
    //@mem_bus.cb
    //@mem_bus.cb
    
    //mem_bus.cb.write <= 0; 
    //mem_bus.cb.read  <= 0;
    
    //Perform Writes
    foreach(Trans[i]) begin
      write_memory(Trans[i]);
    end 
    @(mem_bus.cb);
    mem_bus.cb.write <= 0;
    
    //Rearrange Array for Reads
    Trans.shuffle();
    
    //Perform Reads and Check Results
    foreach(Trans[i]) begin
     read_memory(Trans[i]);
     Trans[i].check();
    end    
    mem_bus.cb.read <= 0;
     
    //Display the Actual Values Read  
    $display("Print Read Values");
    foreach(Trans[i]) begin
     Trans[i].print_actual_read(); 
    end 
   
    $display("Tests Performed: %d", Trans.size());  
    Transaction::print_error_count();
  
  end
  
  final begin
    $display("Test Complete.");
  end 
  
  ///////////////////////////
  //     Read Function     // 
  ///////////////////////////
  //Note: does not return read value    
  function void mread(logic [15:0] addr);
   mem_bus.cb.read <= 1;
   mem_bus.cb.address <= addr;
  endfunction 
   
  ///////////////////////////
  //    Write Function     //
  ///////////////////////////
  function void mwrite(logic [15:0] addr, logic [7:0] data);
   mem_bus.cb.write <= 1;
   mem_bus.cb.data_in <= 0;
   mem_bus.cb.address <= addr;
  endfunction       
    
     
  task automatic write_memory(ref Transaction T);
    @(mem_bus.cb);
    mwrite(T.address, T.data_to_write);
  endtask
  
  task automatic read_memory(ref Transaction T);
    @(mem_bus.cb);
    mread(T.address);
    @(mem_bus.cb);
    @(mem_bus.cb);
    T.actual_read = mem_bus.cb.data_out; 
  endtask
   
endprogram
  
  
//////////////////////
// Top-Level Module //
//////////////////////  
  
module top; 
    
  //Clock Generator 
  bit clk = 0; 
  always #50ns clk = ~clk;
  
  //Memory Interface
  mem_if mem_bus(clk);
  //Test Program 
  test t1(mem_bus);
  //Memory Model     
  my_mem mem(mem_bus);
   
endmodule