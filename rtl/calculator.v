/////////////////////////////
// Calculator
// v0.1 2019-08-16 by Zhengfan Xia
//
//
//
/////////////////////////////

module calculator 
	#( parameter MDF=3 // STACK_MEM_DEPTH=2**MDF
		) 
	(
	input wire clk,
	input wire rst,
	output reg rdy,
	input wire req_valid,
	input wire [2:0] req_instr,
	input wire [31:0] req_operand,
	output wire result_valid,
	output wire [31:0] result,
	output reg [7:0] error
);


	/////////////////////////////////////////////////
	// stack operation
	// push data , read two operands out
	/////////////////////////////////////////////////
	parameter DATA_WIDTH=32; 
	reg en;
	reg wr;
	reg [DATA_WIDTH-1:0] dat_i;
	wire [MDF:0] counter;
	wire [DATA_WIDTH-1:0] dat_o;
	wire [1:0] st_err;
	wire empty;
	wire full;

	LIFO #(MDF,DATA_WIDTH) i_stack(
		.clk(clk),
		.rst(rst),
		.en(en),
		.wr(wr),
		.dat_i(dat_i),
		.dat_o(dat_o),
		.counter(counter),
		.error(st_err),
		.empty(empty),
		.full(full)
	);

	reg [3:0] op_cnt; 	// count operations
	reg [31:0] operand1; // store the first operand
	reg [31:0] operand2; // store the second operand
	reg [1:0] st_ctl; // stack control
	reg       st_release; // release stack 
	reg [3:0] st_state; // stack state
	localparam st0=4'b0001;  // idle
	localparam st1=4'b0010;  // push 1 data
	localparam st2=4'b0100;  // read 2 data
	localparam st3=4'b1000;  // wait

	always @(posedge clk) begin
		if(rst) begin
			en <= 0;
			wr <= 0;
			op_cnt <= 0;
			st_state <= st0;
		end else begin
			en <= 0;
			wr <= 0;
			case(st_state)
				st0: begin// idle 
					if(st_ctl==1) st_state<=st1; 
					else if(st_ctl==2) st_state<=st2;
				end
				st1: begin // push 1 data 
					en<=1; 
					wr<=1; 
					st_state<=st3; 
				end
				st2: begin // read 2 data 
					wr<=0; 
					operand1<=dat_o; 
					operand2<=operand1; 
					op_cnt <= op_cnt + 1; 
					if(op_cnt <= 1) begin 
						en<=1; 
					end else begin
						en<=0; 
						st_state <= st3; 
						op_cnt <= 0;
					end
				end
				st3: begin // wait 
					if(st_release) st_state<=st0;
				end
				default: st_state<=st0; 
			endcase
		end
	end

	/////////////////////////////////////////////////
	// algebraic calculation
	/////////////////////////////////////////////////
	reg [31:0] alg_result; 
	reg [2:0] alg_ctl; 
	reg       alg_release; 
	reg [5:0] alg_state; 
	localparam alg0=6'b000001; // idle
	localparam alg1=6'b000010; // +
	localparam alg2=6'b000100; // -
	localparam alg3=6'b001000; // *
	localparam alg4=6'b010000; // /
	localparam alg5=6'b100000; // wait 

	always @(posedge clk) begin
		if(rst) begin
			alg_state <= alg0;
		end else begin
			case(alg_state)
				alg0: begin// idle 
					if(alg_ctl==1) alg_state<=alg1; 
					else if(alg_ctl==2) alg_state<=alg2;
					else if(alg_ctl==3) alg_state<=alg3;
					else if(alg_ctl==4) alg_state<=alg4;
				end
				alg1: begin
					alg_result <= operand1 + operand2;
					alg_state <= alg5;
				end
				alg2: begin
					// tested by using +
					// should replace by math function module
					//alg_result <= operand1 - operand2;
					alg_result <= operand1 + operand2;
					alg_state<=alg5;
				end
				alg3: begin 
					// tested by using +
					// should replace by math function module
					//alg_result <= operand1 * operand2;
					alg_result <= operand1 + operand2;
					alg_state<=alg5;
				end
				alg4: begin
					// tested by using +
					// should replace by math function module
					//alg_result <= operand1 / operand2;
					alg_result <= operand1 + operand2;
					alg_state<=alg5;
				end
				alg5: begin
					if(alg_release) alg_state<=alg0;
				end
				default: alg_state<= alg0;
			endcase
		end
	end

	/////////////////////////////////////////////////
	// main control 
	/////////////////////////////////////////////////
	reg [3:0] op_ctl;
	reg 			op_flag; // for enable algebra op
	reg       op_release;
	reg [31:0] dat_tmp;

	always @(posedge clk) begin
		if(rst) begin
			op_ctl <= 0; // idle
			op_flag <= 0; 
			rdy<=1;
		end else begin
			op_flag <= 0;  						// disable alg op
			if(op_ctl==1) op_ctl<= 0; // disable st op

			if(req_valid&&rdy&&(error==0)) begin  
				rdy<= 0;  							// disable next instr
				op_ctl <= req_instr+1;  // store instr
				dat_tmp<= req_operand;  // store operand
				// default st push, others enable alg op
				if(req_instr==1||req_instr==2||req_instr==3||req_instr==4) op_flag<= 1; 
			end else if(op_release==1) begin
				rdy<=1;
			end
		end
	end


	reg [2:0] op_state;
	localparam  OP0=3'b001; // wait req
	localparam  OP1=3'b010; // push data
	localparam  OP2=3'b100; // do algebra op 

	always @(posedge clk) begin
		if(rst) begin
			op_state <= OP0;
			st_release<=0;
			st_ctl<=0;
			alg_release<=0;
			alg_ctl<=0;
			op_release<=0;
		end else begin
			// when no operations, reset st, alg, op_release
			st_release<=0;
			alg_release<=0;
			op_release<=0;

			case(op_state)
				OP0: begin // check which operation
					if(op_ctl==1) op_state <= OP1; // go to st push
					else if(op_flag==1) op_state <= OP2; // go to alg op 
				end
				OP1: begin  // push data
					if(st_state==st0) begin  // start push if idle
						st_ctl<=1;
						dat_i<= dat_tmp; // put req_operand on the input of stack 
					end else begin
						if(st_state==st3) begin // finish push
							st_ctl<=0;
							st_release<=1;
							op_release<=1;
							op_state<=OP0;
						end
					end
				end

				OP2: begin // +
					if(st_state==st0 && alg_state==alg0) begin  // start read 2 operands if idle
						st_ctl<=2;  // stack read 2 times operation
					end else begin
						if(st_state==st3 && alg_state==alg0) begin // finish read, start algebraic operation
							st_release<=1; // release stack for push result
							st_ctl<=0;    // reset st_ctl
							if(op_ctl==2) alg_ctl<=1;   // + operation
							else if(op_ctl==3) alg_ctl<=2;   // - operation
							else if(op_ctl==4) alg_ctl<=3;   // * operation
							else if(op_ctl==5) alg_ctl<=4;   // / operation
						end else begin
							if(st_state==st0 && alg_state==alg5) begin // finish operations 
								st_ctl<=1;     // stack push operation
								dat_i<= alg_result; // put calculated result on the input of stack 
							end else begin
								if(st_state==st3) begin
									st_ctl<=0;
									st_release<=1;
									alg_ctl<=0;
									alg_release<=1;
									op_release<=1;
									op_state<=OP0;
								end
							end
						end
					end
				end
				default: begin
					op_state <= OP0;
					st_ctl<=0;
					alg_ctl<=0;
				end
			endcase
		end
	end 

	// result always on the top of the stack
	assign result = dat_o;
	assign result_valid = (op_release | rdy )&(counter>0);

	/////////////////////////////////////////////////
	// error handle, error code block operations 
	// 1: no enough operand
	// 2: write full stack
	// 3: Unknown instr 
	/////////////////////////////////////////////////

	always @(*) begin
		if(counter<2&&req_valid&&req_instr!=0) error = 1; 
		else if(full&&req_valid&&req_instr==0) error = 2; 
		else if(req_valid&&req_instr>4) error = 3; 
		else error=0;
	end
	
endmodule
