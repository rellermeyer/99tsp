`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:50:22 05/08/2016 
// Design Name: 
// Module Name:    xorshift 
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
module xorshift(
    input clk,
    input rst,
    input [127:0] seed,
    output [31:0] out
    );

reg [31:0] x_q, y_q, z_q, w_q, x_d, y_d, z_d, w_d;
assign out = w_q;

always @(*) begin
	x_d = y_q;
	y_d = z_q;
	z_d = w_q;
	w_d = w_q ^ (w_q >> 19) ^ (x_q ^ (x_q << 11)) ^ ((x_q ^ (x_q << 11)) >> 8);
end

always @(posedge clk) begin
	// Auto-reset if we're in the all-zero state
	if (x_q == 0 && y_q == 0 && z_q == 0 && w_q == 0) begin
		x_q <= 32'h8de97cc5;
		y_q <= 32'h6144a7eb;
		z_q <= 32'h653f6dee;
		w_q <= 32'h8b49b282;
	end else if (rst) begin
		x_q <= seed[127:96];
		y_q <= seed[95:64];
		z_q <= seed[63:32];
		w_q <= seed[31:0];
	end else begin
		x_q <= x_d;
		y_q <= y_d;
		z_q <= z_d;
		w_q <= w_d;
	end
end

endmodule
