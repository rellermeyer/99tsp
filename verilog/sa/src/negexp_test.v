`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:44:15 05/11/2016
// Design Name:   negexp
// Module Name:   /home/lane/ut/spring2016/CS345/tsp/src/negexp_test.v
// Project Name:  tsp
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: negexp
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module negexp_test;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] inp;
	reg inp_valid;

	// Outputs
	wire [31:0] out;
	wire out_valid;
	wire [7:0] debug;

	// Instantiate the Unit Under Test (UUT)
	negexp uut (
		.clk(clk), 
		.rst(rst), 
		.inp(inp), 
		.inp_valid(inp_valid), 
		.out(out), 
		.out_valid(out_valid), 
		.debug(debug)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		inp = 0;
		inp_valid = 0;

		// Wait 100 ns for global reset to finish
		#20 clk = ~clk;
		#20 clk = ~clk;
		#20 clk = ~clk;
		#20 clk = ~clk;
		#100;
		rst = 0;
        
		// Add stimulus here
		// Set inp, inp_valid
		inp = 32'h40a00000; // 5.0
		inp_valid = 1;
		forever begin
			#20 clk = ~clk;
		end

	end
      
endmodule

