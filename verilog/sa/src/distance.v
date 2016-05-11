`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:18:02 05/09/2016 
// Design Name: 
// Module Name:    distance 
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
module distance(
    input clk,
    input rst,
    input [63:0] citya,
    input [63:0] cityb,
    input inp_valid,
    output out_valid,
    output [31:0] out
    );

reg sqrt_inp_valid_q, sqrt_inp_valid_d;
reg [31:0] sqrt_inp_q, sqrt_inp_d;
wire [15:0] sqrt_out;
wire sqrt_out_valid;
cordic_sqrt sqrt (
  .aclk(clk),
  .s_axis_cartesian_tvalid(sqrt_inp_valid_q),
  .m_axis_dout_tvalid(sqrt_out_valid),
  .s_axis_cartesian_tdata(sqrt_inp_q[23:0]),
  .m_axis_dout_tdata(sqrt_out)
);

assign out = {19'b0,sqrt_out};
assign out_valid = sqrt_out_valid;

`define X(v) (v[31:0])
`define Y(v) (v[63:32])

reg [31:0] dx_q, dx_d, dy_q, dy_d;
//reg [2:0] processing_q, processing_d;
reg dx_valid_q, dx_valid_d;

always @(*) begin
	dx_d = dx_q;
	dy_d = dy_q;
	//processing_d = processing_q;
	sqrt_inp_valid_d = 0;
	sqrt_inp_d = sqrt_inp_q;
	dx_valid_d = 0;
	
	if (dx_valid_q) begin
		sqrt_inp_d = dx_q*dx_q + dy_q*dy_q;
		sqrt_inp_valid_d = 1;
	end
	if (inp_valid) begin
		dx_d = `X(cityb)-`X(citya);
		dy_d = `Y(cityb)-`Y(citya);
		dx_valid_d = 1;
	end
	
	/*case (processing_q)
	0: begin
		if (inp_valid) begin
			processing_d = 1;
			dx_d = `X(cityb)-`X(citya);
			dy_d = `Y(cityb)-`Y(citya);
		end
	end

	1: begin
		sqrt_inp_d = dx_q*dx_q + dy_q*dy_q;
		sqrt_inp_valid_d = 1;
		processing_d = 2;
	end
	
	2: begin
		if (sqrt_out_valid) begin
			processing_d = 0;
		end
	end
	endcase*/
end

always @(posedge clk) begin
	if (rst) begin
	end else begin
		dx_q <= dx_d;
		dy_q <= dy_d;
		//processing_q <= processing_d;
		sqrt_inp_q <= sqrt_inp_d;
		sqrt_inp_valid_q <= sqrt_inp_valid_d;
		dx_valid_q <= dx_valid_d;
	end
end

endmodule
