`include "svunit_defines.svh"
`include "clk_and_reset.svh"
`include "LIFO.v"

module LIFO_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "LIFO_ut";
  svunit_testcase svunit_ut;

	parameter CLK_HPERIOD = 1; // pulse width
	parameter RST_PERIOD = 4;  // 4 clock
	`CLK_RESET_FIXTURE(CLK_HPERIOD,RST_PERIOD);
	logic rst;
	assign rst = !rst_n;

	parameter MDF=3; // STACK_MEM_DEPTH=2**MDF
	parameter DATA_WIDTH=8; 
	logic wr;
	logic en;
	logic [DATA_WIDTH-1:0] dat_i;
	logic [DATA_WIDTH-1:0] dat_o;
	logic [MDF:0] counter;
	logic [1:0] error;
	logic empty;
	logic full;

	integer i;
	logic [DATA_WIDTH-1:0] temp;
	logic [DATA_WIDTH-1:0] tmp_mem[0:2**MDF-1];

	//initial clk = 0;
	//initial rst = 0;
	initial en = 0;
	initial wr = 0;
	initial dat_i = 0;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  LIFO #(MDF,DATA_WIDTH) my_LIFO(.*);


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */

  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN

  //===================================
	// Test reset
  //===================================
  `SVTEST(test_rst)
	step(1);  // 1 clock step
	reset();
	`FAIL_UNLESS_EQUAL(empty,1);
	`FAIL_UNLESS_EQUAL(full,0);

  `SVTEST_END

  //===================================
	// Test stack push, pop single case 
  //===================================
  `SVTEST(test_write_read_single_data)
	for(i=0;i<10;i=i+1) begin
		temp = $random;
		// write in
	  en=1;wr=1;dat_i=temp;
		step(1); 
		`FAIL_UNLESS_EQUAL(counter,1);
		`FAIL_UNLESS_EQUAL(empty,0);
		// read out, data shows on the top before read signals
	  en=1;wr=0;
		`FAIL_UNLESS_EQUAL(dat_o,temp);
		step(1); 
		`FAIL_UNLESS_EQUAL(counter,0);
		`FAIL_UNLESS_EQUAL(empty,1);
	end
  `SVTEST_END

  //===================================
	// Test stack push, pop full memory case 
  //===================================
  `SVTEST(test_write_read_full_stack)
	`FAIL_UNLESS_EQUAL(empty,1);
	`FAIL_UNLESS_EQUAL(full,0);
	for(i=0;i<2**MDF;i=i+1) begin
		tmp_mem[i] = $random;
		dat_i=tmp_mem[i];
		en=1;wr=1;
		step(1); 
		`FAIL_UNLESS_EQUAL(my_LIFO.stack_mem[2**MDF-i],dat_i);
	end
	`FAIL_UNLESS_EQUAL(full,1);
	`FAIL_UNLESS_EQUAL(empty,0);
	for(i=0;i<2**MDF;i=i+1) begin
		`FAIL_UNLESS_EQUAL(dat_o,tmp_mem[2**MDF-1-i]);
		en=1;wr=0;
		step(1); 
	end
	`FAIL_UNLESS_EQUAL(full,0);
	`FAIL_UNLESS_EQUAL(empty,1);
  `SVTEST_END

  //===================================
	// Test error case 
  //===================================
  `SVTEST(test_error_code)
	`FAIL_UNLESS_EQUAL(empty,1);
	`FAIL_UNLESS_EQUAL(full,0);
	`FAIL_UNLESS_EQUAL(error,0);
	for(i=0;i<2**MDF+1;i=i+1) begin
		tmp_mem[i] = $random;
		dat_i=tmp_mem[i];
		en=1;wr=1;
		step(1); 
	end
	`FAIL_UNLESS_EQUAL(full,1);
	`FAIL_UNLESS_EQUAL(error,1);
	for(i=0;i<2**MDF+1;i=i+1) begin
		`FAIL_UNLESS_EQUAL(dat_o,tmp_mem[2**MDF-1-i]);
		en=1;wr=0;
		step(1); 
	end
	`FAIL_UNLESS_EQUAL(empty,1);
	`FAIL_UNLESS_EQUAL(error,2);
  `SVTEST_END

  `SVUNIT_TESTS_END

//	initial begin
//		$monitor("%d, %d, %d, %d,%d, %d,%d,%d,%d,%d,%d",$stime,my_LIFO.clk, my_LIFO.rst, my_LIFO.en,my_LIFO.wr,my_LIFO.dat_i,my_LIFO.dat_o,my_LIFO.error,my_LIFO.empty,my_LIFO.full,my_LIFO.counter);
//		//$monitor("%d, %b, %b, %b, %b,%d, %d,%d,%d,%d,%d,%d",$stime,my_LIFO.clk, my_LIFO.rst, my_LIFO.en,wr,my_LIFO.SP,my_LIFO.stack_mem[8],temp,dat_o,dat_i,my_LIFO.counter,my_LIFO.SP);
//		//$monitor("%d, %b, %b, %b, %b",$stime,clk, rst, en,wr);
//		$dumpfile("LIFO.vcd");
//		//$dumpvars(0,Flag_CrossDomain_unit_test);
//		$dumpvars;
//	end

endmodule
