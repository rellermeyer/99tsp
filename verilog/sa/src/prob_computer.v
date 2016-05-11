`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:14:49 05/10/2016 
// Design Name: 
// Module Name:    prob_computer 
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
module prob_computer(
	input clk,
	input rst,
	input [31:0] new,
	input [31:0] old,
	input [31:0] Tinv,
	input inp_valid,
	output [31:0] out,
	output out_valid
);

// The circuitry to compute e^-((new-old)/T) = 1 / (e^((new-old)*(1/T)))
reg [31:0] diff_q, diff_d, t_q, t_d;
reg processing_q, processing_d;
wire [31:0] floatval;
wire floatval_valid;
fixed2float f2f(
	.aclk(clk),
	.s_axis_a_tvalid(processing_q),
	.s_axis_a_tdata(diff_q),
	.m_axis_result_tvalid(floatval_valid),
	.m_axis_result_tdata(floatval)
);

wire [31:0] floatval2_data;
wire floatval2_valid;
floating_point_mult m1(
	.aclk(clk),
	.s_axis_a_tvalid(processing_q),
	.s_axis_a_tdata(t_q),
	.s_axis_b_tvalid(floatval_valid),
	.s_axis_b_tdata(floatval),
	.m_axis_result_tvalid(floatval2_valid),
	.m_axis_result_tdata(floatval2_data)
);

wire [31:0] exp_res;
wire [7:0] exp_debug;
wire exp_res_valid;
negexp negexp(
	.clk(clk),
	.rst(rst),
	.inp(floatval2_data),
	.inp_valid(floatval2_valid),
	.out(exp_res),
	.out_valid(exp_res_valid),
	.debug(exp_debug)
);

wire [31:0] recip_data;
wire recip_valid;
floating_point_reciprocal recip(
	.aclk(clk),
	.s_axis_a_tvalid(exp_res_valid),
	.s_axis_a_tdata(exp_res),
	.m_axis_result_tvalid(recip_valid),
	.m_axis_result_tdata(recip_data)
);

assign out = {8'b0,1'b1,recip_data[22:0]}; // Cheap floating-to-fixed, because we know the output is in [0,1]
assign out_valid = recip_valid;

always @(*) begin
	processing_d = processing_q;
	diff_d = diff_q;
	t_d = t_q;
	if (processing_q) begin
		if (recip_valid) begin
			processing_d = 0;
		end
	end else if (inp_valid) begin
		diff_d = new - old;
		t_d = Tinv;
		processing_d = 1;
	end
end

always @(posedge clk) begin
	t_q <= t_d;
	processing_q <= processing_d;
	diff_q <= diff_d;
end

endmodule
