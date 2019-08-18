module __testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "__ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  calculator_unit_test calculator_ut();
  LIFO_unit_test LIFO_ut();


  //===================================
  // Build
  //===================================
  function void build();
    calculator_ut.build();
    LIFO_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(calculator_ut.svunit_ut);
    svunit_ts.add_testcase(LIFO_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    calculator_ut.run();
    LIFO_ut.run();
    svunit_ts.report();
  endtask

endmodule
