`include "svunit_defines.svh"
`include "clk_and_reset.svh"
`include "calculator.v"

module calculator_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "calculator_ut";
  svunit_testcase svunit_ut;

	parameter CLK_HPERIOD = 1; // pulse width
	parameter RST_PERIOD = 4;  // 4 clock
	`CLK_RESET_FIXTURE(CLK_HPERIOD,RST_PERIOD);
	logic rst;
	assign rst = !rst_n;

	parameter MDF=3; // STACK_MEM_DEPTH=2**MDF
	logic rdy;
	logic req_valid;
	logic [2:0] req_instr;
	logic [31:0] req_operand;
	logic result_valid;
	logic [31:0] result;
	logic [7:0] error;

	logic [31:0] tmp_mem[0:2**MDF-1];
	logic [31:0] tmp_result;


	integer i;

	initial req_valid = 0;
	initial req_instr = 0;
	initial req_operand = 0;

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  calculator #(MDF) my_calculator(.*);


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
	step(1);   // 1 clock step
	reset();
	`FAIL_UNLESS_EQUAL(rdy,1);
  `SVTEST_END

  //===================================
	// Test push single operand 
  //===================================
  `SVTEST(test_push_single_operand)
	`FAIL_UNLESS_EQUAL(rdy,1);
	req_valid=1; req_instr=0; req_operand=44;
	step(1);
	req_valid=0; 
	while(result_valid!=1) step(1); 
	`FAIL_UNLESS_EQUAL(result,req_operand);
	while(rdy!=1) step(1); 
	`FAIL_UNLESS_EQUAL(rdy,1);
  `SVTEST_END

  //===================================
	// Test two operands operation case 
  //===================================
  `SVTEST(test_two_operand_operation)
	while(rdy!=1) step(1); 
	req_valid=1; req_instr=0; req_operand=55;
	step(1);
	req_valid=0; 
	while(result_valid!=1) step(1); 
	`FAIL_UNLESS_EQUAL(result,req_operand);
	while(rdy!=1) step(1); 
	req_valid=1; req_instr=1; 
	step(1);
	req_valid=0; 
	while(result_valid!=1) step(1); 
	`FAIL_UNLESS_EQUAL(result,99);
  `SVTEST_END

  //===================================
	// Test three operands operation case 
  //===================================
  `SVTEST(test_three_operand_operation)
	while(rdy!=1) step(1); 
	req_valid=1; req_instr=0; req_operand=11;
	step(1);
	req_valid=0; 
	while(result_valid!=1) step(1); 
	`FAIL_UNLESS_EQUAL(result,req_operand);
	while(rdy!=1) step(1); 
	req_valid=1; req_instr=0; req_operand=22;
	step(1);
	req_valid=0; 
	while(result_valid!=1) step(1); 
	`FAIL_UNLESS_EQUAL(result,req_operand);
	while(rdy!=1) step(1); 
	req_valid=1; req_instr=1; 
	step(1);
	req_valid=0; 
	while(result_valid!=1) step(1); 
	`FAIL_UNLESS_EQUAL(result,33);
	while(rdy!=1) step(1); 
	req_valid=1; req_instr=1; 
	step(1);
	req_valid=0; 
	while(result_valid!=1) step(1); 
	`FAIL_UNLESS_EQUAL(result,132);
  `SVTEST_END

  //===================================
	// Test full stack operands operation case, +
  //===================================
  `SVTEST(test_full_operand_operation_plus_routine)
	reset();
	while(rdy!=1) step(1); 
	for(i=0;i<2**MDF;i=i+1) begin
		tmp_mem[i]=i;
		step(1);
		req_valid=1; req_instr=0; req_operand=i;
		step(1);
		req_valid=0; 
		while(result_valid!=1) step(1); 
		`FAIL_UNLESS_EQUAL(result,req_operand);
	end
	`FAIL_UNLESS_EQUAL(my_calculator.full,1);

	tmp_result=tmp_mem[2**MDF-1];
	for(i=0;i<2**MDF-1;i=i+1) begin
		tmp_result=tmp_mem[2**MDF-2-i] + tmp_result;
		step(1);
		req_valid=1; req_instr=1;  //+
		step(1);
		req_valid=0; 
		while(result_valid!=1) step(1); 
		`FAIL_UNLESS_EQUAL(result,tmp_result);
	end
  `SVTEST_END

  //===================================
	// Test full stack operands operation case, -
  //===================================
  `SVTEST(test_full_operand_operation_substract_routine)
	reset();
	while(rdy!=1) step(1); 
	for(i=0;i<2**MDF;i=i+1) begin
		tmp_mem[i]=i;
		step(1);
		req_valid=1; req_instr=0; req_operand=i;
		step(1);
		req_valid=0; 
		while(result_valid!=1) step(1); 
		`FAIL_UNLESS_EQUAL(result,req_operand);
	end
	`FAIL_UNLESS_EQUAL(my_calculator.full,1);

	tmp_result=tmp_mem[2**MDF-1];
	for(i=0;i<2**MDF-1;i=i+1) begin
		tmp_result=tmp_mem[2**MDF-2-i] + tmp_result;
		step(1);
		req_valid=1; req_instr=2; //-
		step(1);
		req_valid=0; 
		while(result_valid!=1) step(1); 
		`FAIL_UNLESS_EQUAL(result,tmp_result);
	end
  `SVTEST_END

  //===================================
	// Test full stack operands operation case, *
  //===================================
  `SVTEST(test_full_operand_operation_multiply_routine)
	reset();
	while(rdy!=1) step(1); 
	for(i=0;i<2**MDF;i=i+1) begin
		tmp_mem[i]=i;
		step(1);
		req_valid=1; req_instr=0; req_operand=i;
		step(1);
		req_valid=0; 
		while(result_valid!=1) step(1); 
		`FAIL_UNLESS_EQUAL(result,req_operand);
	end
	`FAIL_UNLESS_EQUAL(my_calculator.full,1);

	tmp_result=tmp_mem[2**MDF-1];
	for(i=0;i<2**MDF-1;i=i+1) begin
		tmp_result=tmp_mem[2**MDF-2-i] + tmp_result;
		step(1);
		req_valid=1; req_instr=3; //*
		step(1);
		req_valid=0; 
		while(result_valid!=1) step(1); 
		`FAIL_UNLESS_EQUAL(result,tmp_result);
	end
  `SVTEST_END

  //===================================
	// Test full stack operands operation case, /
  //===================================
  `SVTEST(test_full_operand_operation_divide_routine)
	reset();
	while(rdy!=1) step(1); 
	for(i=0;i<2**MDF;i=i+1) begin
		tmp_mem[i]=i;
		step(1);
		req_valid=1; req_instr=0; req_operand=i;
		step(1);
		req_valid=0; 
		while(result_valid!=1) step(1); 
		`FAIL_UNLESS_EQUAL(result,req_operand);
	end
	`FAIL_UNLESS_EQUAL(my_calculator.full,1);

	tmp_result=tmp_mem[2**MDF-1];
	for(i=0;i<2**MDF-1;i=i+1) begin
		tmp_result=tmp_mem[2**MDF-2-i] + tmp_result;
		step(1);
		req_valid=1; req_instr=4; //*
		step(1);
		req_valid=0; 
		while(result_valid!=1) step(1); 
		`FAIL_UNLESS_EQUAL(result,tmp_result);
	end
  `SVTEST_END

  //===================================
	// Test error case 
  //===================================
  `SVTEST(test_error_code)
	reset();
	while(rdy!=1) step(1); 
	req_valid=1; req_instr=0; req_operand=44;
	step(1);
	req_valid=0; 
	while(result_valid!=1) step(1); 
	`FAIL_UNLESS_EQUAL(result,req_operand);
	req_valid=1; req_instr=1; 
	step(1);
	`FAIL_UNLESS_EQUAL(error,1);
	req_valid=0; 
	step(1);
	`FAIL_UNLESS_EQUAL(error,0);

	reset();
	for(i=0;i<=2**MDF;i=i+1) begin
		while(rdy!=1) step(1); 
		req_valid=1; req_instr=0; req_operand=i;
		step(1);
		req_valid=0; 
	end
	`FAIL_UNLESS_EQUAL(error,2);
	step(1);
	`FAIL_UNLESS_EQUAL(error,0);

	while(rdy!=1) step(1); 
	req_valid=1; req_instr=5; req_operand=i;
	step(1);
	req_valid=0; 
	`FAIL_UNLESS_EQUAL(error,3);
	step(1);
	`FAIL_UNLESS_EQUAL(error,0);

  `SVTEST_END

  `SVUNIT_TESTS_END

//	initial begin
//		//$monitor("%d, %b, %b, %b, %b,%d, %d,%d,%b,%d,%x,%x,%x,%d,%d,%b,%d,%d,%d",$stime,clk, rst, rdy,req_valid,req_instr,req_operand,result,result_valid,my_calculator.op_ctl,my_calculator.op_state,my_calculator.st_state,my_calculator.alg_state,my_calculator.operand1,my_calculator.operand2,my_calculator.en,my_calculator.counter,my_calculator.dat_o,my_calculator.op_flag);
//		$monitor("%d, %d, %d, %d, %d, %d, %d, %d, %d, %d,%d",$stime,my_calculator.clk, my_calculator.rst, my_calculator.rdy,my_calculator.req_valid,my_calculator.req_instr,my_calculator.req_operand,my_calculator.result,my_calculator.result_valid,my_calculator.error,my_calculator.counter);
//		//$monitor("%d, %b, %b, %b, %b",$stime,clk, rst, en,wr);
//		//$dumpfile("calculator.vcd");
//		//$dumpvars(0,Flag_CrossDomain_unit_test);
//		$dumpvars;
//	end

endmodule
