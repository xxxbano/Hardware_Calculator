/////////////////////////////
// Last In First Out module
// v0.1 2019-08-16 by Zhengfan Xia
//
// write in fall through, LIFO
/////////////////////////////
`timescale 1ns/100ps

module LIFO
	#(parameter AWF=3,  // Address Width Factor
	  parameter DW=8   // Data Width
	)
(
	input wire clk,
	input wire rst,
	input wire en,
	input wire wr,
	input wire [DW-1:0] dat_i,
	//output reg [7:0] dat_o,
	output wire [DW-1:0] dat_o,
	output reg [AWF:0] counter,
	output reg [1:0] error,
	output reg empty,
	output reg full
);


	reg [DW-1:0] stack_mem[1:2**AWF];
	reg [AWF:0] SP;

	integer i;
	initial begin
		for(i=1;i<2**AWF+1;i=i+1) begin
			stack_mem[i] = 0;
		end
	end

	// error
	// 2'b01, write full stack
	// 2'b10, read empty stack
	
	always @(posedge clk) begin
		if(rst) begin
			SP <= 2**AWF;
			error <= 0;
		end 
		else if(en) begin
			error <= 0;
			if(wr==1) begin
				if(full==1) begin
					error <= 1;
				end else begin
					stack_mem[SP] <= dat_i;
					SP <= SP - 1;
				end
			end else begin
				if(empty==1) begin
					error <= 2;
				end else begin
				 	SP <= SP + 1;
				end
			end
			//if(full==0 && wr==1) begin
			//	stack_mem[SP] <= dat_i;
			//	SP <= SP - 1;
			//end 
			//else if(empty==0 && wr==0) begin
			//	SP <= SP + 1;
			//end
		end
	end

	assign dat_o = stack_mem[SP+1];

	always @(*) begin
		if(SP==2**AWF) begin
			empty=1;
			full=0;
			counter=0;
		end 
		else if(SP==0) begin
			empty=0;
			full=1;
			counter=2**AWF;
		end else begin
			empty=0;
			full=0;
			counter=2**AWF - SP;
		end
	end




endmodule
