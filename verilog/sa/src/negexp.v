`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:38:51 05/09/2016 
// Design Name: 
// Module Name:    negexp 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module negexp( // Input and output are in single precision floating point values
    input clk,
    input rst,
    input [31:0] inp,
    input inp_valid,
    output [31:0] out,
    output out_valid,
	 output [7:0] debug
    );

// A single stage in our setup: result = 1.0 + A * B * C
// The latency of each component is zero, at least at the moment.
reg [31:0] a_q, a_d, b_q, b_d, c_q, c_d;
reg stage_start_q, stage_start_d;

wire [31:0] fmult_tdata;
wire fmult_tvalid;
reg fmult_start_q, fmult_start_d;
reg [31:0] fmult_a_q, fmult_a_d, fmult_b_q, fmult_b_d;
floating_point_mult fmult(
	.aclk(clk),
	.s_axis_a_tvalid(fmult_start_q),
	.s_axis_b_tvalid(fmult_start_q),
	.s_axis_a_tdata(fmult_a_q),
	.s_axis_b_tdata(fmult_b_q),
	.m_axis_result_tvalid(fmult_tvalid),
	.m_axis_result_tdata(fmult_tdata)
);

reg [31:0] adder_in_q, adder_in_d;
reg adder_start_q, adder_start_d;
wire adder_valid;
wire [31:0] adder_res;
floating_point_add stage1_add(
	.aclk(clk),
	.s_axis_a_tvalid(adder_start_q),
	.s_axis_a_tdata(adder_in_q),
	.s_axis_b_tvalid(1'b1),
	.s_axis_b_tdata(32'h3f800000),
	.m_axis_result_tvalid(adder_valid),
	.m_axis_result_tdata(adder_res)
);

// The logic to repeatadly run this stage
reg [3:0] iters_left_q, iters_left_d;
reg [31:0] out_q, out_d;
reg out_valid_q, out_valid_d, finishing_q, finishing_d;

// The logic to run multiplication, which takes two steps
reg [1:0] mult_q, mult_d;

assign out = out_q;
assign out_valid = out_valid_q;

assign debug = 8'b0;//{iters_left_q, 1'b0, stage1_valid, stage2_valid, adder_valid};

// 1, 0.5, 0.3333, 0.25
localparam CONSTANT_TABLE = {32'h3f800000, 32'h3f000000, 32'h3eaaaaab, 32'h3e800000};
//`define CONSTANT(i) (CONSTANT_TABLE[(3-i)*32-1:(3-i-1)*32]&32'hffffffff)
`define CONSTANT(i) ((CONSTANT_TABLE>>((4-i)*32))&32'hffffffff)

always @(*) begin
	a_d = a_q;
	b_d = b_q;
	c_d = c_q;
	iters_left_d = iters_left_q;
	stage_start_d = 0;//stage_start_q;
	out_d = out_q;
	out_valid_d = 0;
	finishing_d = finishing_q;
	fmult_a_d = fmult_a_q;
	fmult_b_d = fmult_b_q;
	fmult_start_d = 0;
	mult_d = mult_q;
	adder_in_d = adder_in_q;
	adder_start_d = 0;

	if (mult_q == 1) begin // Multiplying a_q and b_q
		if (fmult_tvalid) begin
			mult_d = 2;
			fmult_a_d = fmult_tdata;
			fmult_b_d = c_d;
			fmult_start_d = 1;
		end
	end else if (mult_q == 2) begin // Multiplying res by c_q
		if (fmult_tvalid) begin
			// Kick off the addition
			adder_in_d = fmult_tdata;
			adder_start_d = 1;
			mult_d = 3;
		end
	end else if (iters_left_q == 0) begin
		if (finishing_q) begin
			out_d = adder_res;
			out_valid_d = 1;
			finishing_d = 0;
		end
		if (inp_valid) begin
			// We're ready to roll!
			iters_left_d = 4;
			a_d = inp;
			b_d = 32'h3f800000; // Start out at 1
			c_d = `CONSTANT(4);
			//stage_start_d = 1;
			mult_d = 1;
			fmult_a_d = a_d;
			fmult_b_d = b_d;
			fmult_start_d = 1;
		end
	end else if (adder_valid) begin
		// We have to setup the next round
		iters_left_d = iters_left_q - 1;
		b_d = adder_res;
		c_d = `CONSTANT(iters_left_q+1);
		stage_start_d = 1;
		finishing_d = 1;
		
		mult_d = 1;
		fmult_a_d = a_d;
		fmult_b_d = b_d;
		fmult_start_d = 1;
	end
end

always @(posedge clk) begin
	if (rst) begin
		iters_left_q <= 0;
		stage_start_q <= 0;
		finishing_q <= 0;
		fmult_start_q <= 0;
		adder_start_q <= 0;
	end else begin
		stage_start_q <= stage_start_d;
		a_q <= a_d;
		b_q <= b_d;
		c_q <= c_d;
		iters_left_q <= iters_left_d;
		out_q <= out_d;
		out_valid_q <= out_valid_d;
		finishing_q <= finishing_d;
		mult_q <= mult_d;
		fmult_a_q <= fmult_a_d;
		fmult_b_q <= fmult_b_d;
		fmult_start_q <= fmult_start_d;
		adder_in_q <= adder_in_d;
		adder_start_q <= adder_start_d;
	end
end

endmodule
