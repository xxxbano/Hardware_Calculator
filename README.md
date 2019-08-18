# Hardware_Calculator
This calculator accepts a serial of numbers and push onto a stack. When it receives an algebraic command (+, -, *, /), two values will be poped out from stack and used as operand to do the correspond calculation. The result will be pushed back to stack and shown as the result output


##### Verilog files:
- [calculator.v](rtl/calculator.v): algebraic components are not included. tested by using + only
  - error case would disable req operation.
- [LIFO.v](rtl/LIFO.v)
##### UnitTest files:
- [calculator_unit_test.sv](testbench/calculator_unit_test.sv): Find each test in \`SVTEST(mytest) 
- [LIFO_unit_test.sv](testbench/LIFO_unit_test.sv): Find each test in \`SVTEST(mytest) 
- [Test_Results](testbench/Test_Results): Test Summary

##### ToDo:
- Design algebraic compnents or instantiate these components in FPGA IP library

#### Waveform from UnitTest
##### calculator:
Reset with two operands add operation. Push 44, Push 55, Add 44+55=99.
![alt text](https://github.com/xxxbano/Hardware_Calculator/blob/master/testbench/waveform/cal_1.png "Logo Title Text 1")
Three operands add operation. Value from above 99, Push 11, Push 22, Add 11+22=33, Add 33+99=132
![alt text](https://github.com/xxxbano/Hardware_Calculator/blob/master/testbench/waveform/cal_2.png "Logo Title Text 1")
Full stack memory depth (8) operation. Push 0,1,2,3,4,5,6,7. Add reslults: 6+7=13, 13+5=18, 18+4=22, 22+3=25, 25+2=27, 27+1=28, 28+0=28.
![alt text](https://github.com/xxxbano/Hardware_Calculator/blob/master/testbench/waveform/cal_3.png "Logo Title Text 1")
Error cases. 1: operate on single operand; 2: push number onto a full stack;
![alt text](https://github.com/xxxbano/Hardware_Calculator/blob/master/testbench/waveform/cal_4.png "Logo Title Text 1")

##### LIFO:
Reset with single data push/pop operation.
![alt text](https://github.com/xxxbano/Hardware_Calculator/blob/master/testbench/waveform/stack_1.png "Logo Title Text 1")
Full stack memory depth (8) push/pop operation.
![alt text](https://github.com/xxxbano/Hardware_Calculator/blob/master/testbench/waveform/stack_2.png "Logo Title Text 1")
Error cases. 1: push on full; 0: pop on empty;
![alt text](https://github.com/xxxbano/Hardware_Calculator/blob/master/testbench/waveform/stack_3.png "Logo Title Text 1")

#### About UnitTest
The UnitTest is designed by using SVUnit in Linux

##### Setup SVUnit:
1. Download: http://agilesoc.com/open-source-projects/svunit/
2. mv svunit-code to a directory
3. setenv SVUNIT_INSTALL /directory/svunit-code 
4. add path /direcotry svunit-code/bin 
5. cd testbench; ln -s ../rtl/*.v; if no files in testbench folder 
6. run testbench: ./runUtest.csh 

If you do not have modelsim, setup vcs etc.(has limitation) in runUtest.csh file
runSVunit -s (simulator)

