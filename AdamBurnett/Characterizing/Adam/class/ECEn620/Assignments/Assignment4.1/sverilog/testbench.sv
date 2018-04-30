`default_nettype none
`timescale 1ns/100ps 
  
module testbench (); 
  
  shortint address; 
  byte data; 
  
  //Clock Generator 
  bit clk = 0; 
  always #5ns clk = ~clk;
  
  //Memory Interface
  mem_if mem_bus(clk); 
      
  typedef struct { 
      shortint address; 
      byte data_to_write; 
      byte expected_read; 
      byte actual_read; 
  } ScoreBoardEntry;
  
  ScoreBoardEntry ScoreBoard[]; 
  
  int ErrorCount = 0;
    
  ///////////////////////////
  //    Test Bench Code    //
  /////////////////////////// 
   
  initial begin
       
    //Initialize Score Board
    ScoreBoard = new[6]; 
        
    //Generate Random Writes      
    foreach(ScoreBoard[i]) begin
      address = $random;
      data = $random; 
      ScoreBoard[i].address = address; 
      ScoreBoard[i].data_to_write = data; 
      ScoreBoard[i].expected_read = {^data, data};
    end 
    
    //Test Protocol Error Checker
    //This should produce three Errors
    /*mem_bus.mwrite(0, 0);
    mem_bus.mread(0);
     
    @(negedge mem_bus.clk);
    @(negedge mem_bus.clk);
    @(negedge mem_bus.clk);
    
    mem_bus.write = 0; 
    mem_bus.read = 0;*/
    
    //Perform Writes
    foreach(ScoreBoard[i]) begin
      write_memory(ScoreBoard[i]);
    end 
    @(negedge mem_bus.clk);
    mem_bus.write = 0;
    
    //Rearrange Array for Reads
    ScoreBoard.shuffle();
    
    //Perform Reads and Check Results
    foreach(ScoreBoard[i]) begin
     read_memory(ScoreBoard[i]);
     check(ScoreBoard[i]);
    end    
    mem_bus.read = 0;
     
    //Display the Actual Values Read  
    $display("Print Read Values");
    foreach(ScoreBoard[i]) begin
     $display("\t%03X", ScoreBoard[i].actual_read);
    end 
   
    $display("Tests Performed: %d", ScoreBoard.size());  
    $display("Incorrect Read Errors: %d", ErrorCount);
    $display("Read/Write Signal Errors: %d", mem_bus.rdwr_error_count);     
    
  end  
  
  task automatic write_memory(ref ScoreBoardEntry Entry);
    @(negedge mem_bus.clk);
    mem_bus.mwrite(Entry.address, Entry.data_to_write);
  endtask
  
  task automatic read_memory(ref ScoreBoardEntry Entry);
    @(negedge mem_bus.clk);
    mem_bus.mread(Entry.address);
    @(negedge mem_bus.clk);
    Entry.actual_read = mem_bus.data_out; 
  endtask
  
  function check(ScoreBoardEntry Entry);
    if( Entry.expected_read != Entry.actual_read) begin
      $display("Found Error: %03X %03X", Entry.expected_read, Entry.actual_read); 
      ErrorCount++; 
    end      
  endfunction
       
  my_mem mem(mem_bus);
   
endmodule