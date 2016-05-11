`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:41:45 05/10/2016
// Design Name:   tsp
// Module Name:   /home/lane/ut/spring2016/CS345/tsp/src/test_tsp.v
// Project Name:  tsp
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: tsp
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_tsp;

	integer fd;
	integer c;

	// Inputs
	reg clk;
	reg rst;
	reg [7:0] specdata;
	reg has_specdata;
	wire [31:0] rng;

	// Outputs
	wire ready_to_read;
	wire [7:0] debug;
	wire [31:0] best_distance;
	wire best_distance_valid;

	// Instantiate the Unit Under Test (UUT)
	tsp uut (
		.clk(clk), 
		.rst(rst), 
		.specdata(specdata), 
		.has_specdata(has_specdata), 
		.ready_to_read(ready_to_read), 
		.debug(debug), 
		.best_distance(best_distance), 
		.best_distance_valid(best_distance_valid), 
		.rng(rng)
	);
	
	// Instantiate the RNG
	xorshift xorshift (
		.clk(clk),
		.rst(rst),
		.seed(128'h8de97cc56144a7eb653f6dee8b49b282),
		.out(rng)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		specdata = 0;
		has_specdata = 0;

		// Wait 100 ns for global reset to finish
		#20
		clk = 1;
		#20 clk = 0;
		#20 clk = 1;
		#20 clk = 0;
		#100;
		rst = 0;
		#100;
        
		// Add stimulus here
		fd = $fopen("/tmp/test.txt", "r");
		c = $fgetc(fd);
		while (c > 0) begin
			// Send c
			#20
			if (ready_to_read) begin
				specdata = (c==10)?13:c;
				has_specdata = 1;
				c = $fgetc(fd);
			end
			clk = 1;
			#20
			clk = 0;
			#20
			has_specdata = 0;
			clk = 1;
			#20
			clk = 0;
		end
		
		// Start number crunching
		forever begin
			#10 clk = ~clk;
		end

	end
      
endmodule

