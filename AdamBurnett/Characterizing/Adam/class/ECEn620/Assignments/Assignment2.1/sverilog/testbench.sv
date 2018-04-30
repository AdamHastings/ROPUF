`default_nettype none
`timescale 1ns/100ps 
module testbench (); 
  
  logic clk;
	logic reset;
	logic write;
	logic [15:0] data_in;
	logic [2:0] address;
	logic [15:0] data_out;
   
  typedef enum { READ_REG, WRITE_REG, RESET_REG_FILE } Action; 
    
  int error_counter; 
  byte regFileResetCntDown;  
  int i, j;   
  //bit [15:0] val;
   
  typedef struct {
    string regname; 
    logic [15:0] reg_value; 
    logic [15:0] reset_value; 
    int bugs_found;
  } register; 
  
  register regmodel[8]; 
  
  initial begin
    
    clk = 0;
    error_counter = 0; 
    
    initRegModel(3'd0, "adc0_reg", 16'hffff);
    initRegModel(3'd1, "adc1_reg");
    initRegModel(3'd2, "temp_sensor0_reg");
    initRegModel(3'd3, "temp_sensor1_reg");
    initRegModel(3'd4, "analog_test", 16'hABCD);
    initRegModel(3'd5, "digital_test");
    initRegModel(3'd6, "amp_gain");
    initRegModel(3'd7, "digital_config", 16'h1);
    
    $display("Testing inital Reset!");    
    reset_regfile();  
    check_all_registers();
    
    for(i = 0; i < 8; i = i + 1) begin
      test_register(i);   
    end 
       
    foreach(regmodel[i]) begin
      $display("Register: %s Bugs Found: %d", regmodel[i].regname, regmodel[i].bugs_found); 
    end
    
    $display("Error Count: %d", error_counter); 
    
  end  
  
  
  task automatic test_register(int addr);
    logic [15:0] val = 16'h7fff;
    int i; 
    $display("*****Testing %s @ %d*****\n\n", regmodel[addr].regname, $time);
    $display("Single Bit Low Test");
    
    val = 16'h7fff;
    for(i = 0; i<16; i=i+1) begin
      $display("Testing bit %d", i);
      val = rotate_left(val); 
      write_register(addr, val);
      //Check that all registers have correct value
      check_all_registers();  
    end
    
    $display("Single Bit High Test");
    
    val = 16'h8000; 
    for(i = 0; i<16; i=i+1) begin
      $display("Testing bit %d", i);
      val = rotate_left(val); 
      write_register(addr, val);
      //Check that all registers have correct value
      check_all_registers();  
    end
    
    //Write to Inverse of Reset Value
    $display("Inverse Reset Test");
       
    write_register(addr, ~(regmodel[addr].reset_value));
    
    reset_regfile();
    check_all_registers();
    
  endtask; 
  
  function automatic logic[15:0] rotate_left(logic [15:0] sig);
    logic [15:0] tmp;
    tmp = {sig[14:0], sig[15]};
    return tmp;
  endfunction 
  
  task automatic initRegModel(logic [2:0] i, string name, logic [15:0] reset_val = 16'd0);
      //$display("in init regmodel");
      regmodel[i].regname = name; 
      regmodel[i].reset_value = reset_val;
      regmodel[i].bugs_found = 0;
  endtask;
    
  task automatic rstRegModel() ;
    foreach ( regmodel[i] ) begin
      regmodel[i].reg_value = regmodel[i].reset_value;
    end   
  endtask;
  
  task automatic reset_regfile();
    @(negedge clk)
     reset = 1; 
     rstRegModel();
    @(negedge clk)
     reset = 0;   
  endtask;
    
  task automatic write_register(input bit [2:0] addr, input logic [15:0] data);
    @(negedge clk);
     write = 1;
     data_in = data;
     address = addr; 
     regmodel[addr].reg_value = data;
    @(negedge clk);
     write = 0; 
  endtask;
  
  
  task automatic check_all_registers();
    for(int i=0; i<8; i = i+1)  begin   
      read_register(i);
    end
  endtask; 
  
  task automatic read_register(input bit [2:0] addr); 
    @(negedge clk)
     address = addr; 
    @(negedge clk)
     check_register(addr, data_out);
  endtask;
    
  task automatic check_register(logic [2:0] addr, logic [15:0] val);
    if(!(regmodel[addr].reg_value == val)) begin
      $display("Error: Register: \"%s\" Expected: %04x Actual: %04x\n", regmodel[addr].regname,  regmodel[addr].reg_value, val); 
      regmodel[addr].bugs_found = regmodel[addr].bugs_found + 1;  
      error_counter = error_counter + 1; 
      regmodel[addr].reg_value = val;
    end 
  endtask;
  
  always begin
    #5 clk = ~clk;
  end 
     
  config_reg conf( clk, reset, write, data_in, address, data_out);

   
endmodule