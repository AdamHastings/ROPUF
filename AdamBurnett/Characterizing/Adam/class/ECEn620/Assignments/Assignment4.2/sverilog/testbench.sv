`default_nettype none
`timescale 1ns/100ps 

program automatic test(mem_if.TEST mem_bus);

  shortint address; 
  byte data; 
  int ErrorCount = 0;
    
  typedef struct { 
      shortint address; 
      byte data_to_write; 
      bit [8:0] expected_read; 
      bit [8:0] actual_read; 
  } ScoreBoardEntry;
  
  ScoreBoardEntry ScoreBoard[]; 
  
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
     
    mem_bus.cb.read <= 0;
    //Test Protocol Error Checker
    //This should produce three Errors
    mwrite(0, 0);
    mread(0);
     
    @mem_bus.cb;
    @mem_bus.cb
    @mem_bus.cb
    
    mem_bus.cb.write <= 0; 
    mem_bus.cb.read  <= 0;
    
    //Perform Writes
    foreach(ScoreBoard[i]) begin
      write_memory(ScoreBoard[i]);
    end 
    @(mem_bus.cb);
    mem_bus.cb.write <= 0;
    
    //Rearrange Array for Reads
    ScoreBoard.shuffle();
    
    //Perform Reads and Check Results
    foreach(ScoreBoard[i]) begin
     read_memory(ScoreBoard[i]);
     check(ScoreBoard[i]);
    end    
    mem_bus.cb.read <= 0;
     
    //Display the Actual Values Read  
    $display("Print Read Values");
    foreach(ScoreBoard[i]) begin
     $display("\t%03X", ScoreBoard[i].actual_read);
    end 
   
    $display("Tests Performed: %d", ScoreBoard.size());  
    $display("Incorrect Read Errors: %d", ErrorCount);
    //$display("3.Read/Write Signal Errors: %d", mem_bus.rdwr_error_count);     

  end
  
  final begin
    $display("Test Complete.");
    $stop();
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
   mem_bus.cb.data_in <= data;
   mem_bus.cb.address <= addr;
  endfunction       
    
     
  task automatic write_memory(ref ScoreBoardEntry Entry);
    @(mem_bus.cb);
    mwrite(Entry.address, Entry.data_to_write);
  endtask
  
  task automatic read_memory(ref ScoreBoardEntry Entry);
    @(mem_bus.cb);
    mread(Entry.address);
    @(mem_bus.cb);
    @(mem_bus.cb);
    Entry.actual_read = mem_bus.cb.data_out; 
  endtask
  
  function check(ScoreBoardEntry Entry);
    if( Entry.expected_read != Entry.actual_read) begin
      $display("Found Error: %04X %04X", Entry.expected_read, Entry.actual_read); 
      ErrorCount++; 
    end      
  endfunction
 
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