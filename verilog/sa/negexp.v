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
    output out_valid
    );

// A single stage in our setup: result = 1.0 + A * B * C
// The latency of each component is zero, at least at the moment.
reg [31:0] a_q, a_d, b_q, b_d, c_q, c_d;
reg stage_start_q, stage_start_d;

//wire stage1_valid;
wire [31:0] stage1_res;
wire stage1_valid;
floating_point_mult stage1(
	.aclk(clk),
	.s_axis_a_tvalid(stage_start_q),
	.s_axis_a_tdata(a_q),
	.s_axis_b_tvalid(1),
	.s_axis_b_tdata(b_q),
	.m_axis_result_tvalid(stage1_valid),
	.m_axis_result_tdata(stage1_res)
);

//wire stage2_valid;
wire [31:0] stage2_res;
floating_point_mult stage2(
	.aclk(clk),
	.s_axis_a_tvalid(stage1_valid),
	.s_axis_a_tdata(stage1_res),
	.s_axis_b_tvalid(1),
	.s_axis_b_tdata(c_q),
	.m_axis_result_tvalid(stage2_valid),
	.m_axis_result_tdata(stage2_res)
);

wire adder_valid;
wire [31:0] adder_res;
floating_point_add stage1_add(
	.aclk(clk),
	.s_axis_a_tvalid(stage2_valid),
	.s_axis_a_tdata(stage2_res),
	.s_axis_b_tvalid(1),
	.s_axis_b_tdata(32'h3f800000),
	.m_axis_result_tvalid(adder_valid),
	.m_axis_result_tdata(adder_res)
);

// The logic to repeatadly run this stage
reg [3:0] iters_left_q, iters_left_d;
reg [31:0] out_q, out_d;
reg out_valid_q, out_valid_d;

assign out = out_q;
assign out_valid = out_valid_q;

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

	if (iters_left_q == 0) begin
		out_d = adder_res;
		out_valid_d = 1;
		if (inp_valid) begin
			// We're ready to roll!
			iters_left_d = 3;
			a_d = inp;
			b_d = `CONSTANT(4);
			c_d = 32'h3f800000; // Start out at 1
		end
	end else if (adder_valid) begin
		// We have to setup the next round
		iters_left_d = iters_left_q - 1;
		b_d = adder_res;
		c_d = `CONSTANT(iters_left_q);
	end
end

always @(posedge clk) begin
	if (rst) begin
	end else begin
		stage_start_q <= stage_start_d;
		a_q <= a_d;
		b_q <= b_d;
		c_q <= c_d;
		iters_left_q <= iters_left_d;
		out_q <= out_d;
		out_valid_q <= out_valid_d;
	end
end

endmodule
