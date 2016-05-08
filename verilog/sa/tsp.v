`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:42:57 05/07/2016 
// Design Name: 
// Module Name:    tsp 
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
module tsp #(
	parameter PRECISION = 32,
	parameter MAX_NODE_BITS = 9, // 2^this is the max # of nodes
	parameter STRINGBUFFER_SIZE = 32,
	parameter NUMBUF_NDIGITS_BITS = 4
)(
	input clk,
	input rst,
	input [7:0] specdata,
	input has_specdata,
	output ready_to_read,
	output [7:0] debug
);

reg wea_q, wea_d;
reg [MAX_NODE_BITS-1:0] addra_q, addra_d, addrb_q, addrb_d;
reg [PRECISION*2-1:0] dina_q, dina_d;
wire [PRECISION*2-1:0] douta, doutb;
city_ram city_ram(
	.clka(clk),
	.wea(wea_q),
	.addra(addra_q),
	.dina(dina_q),
	.douta(douta),
	.clkb(clk),
	.web(1'b0),
	.addrb(addrb_q),
	.dinb(64'b0),
	.doutb(doutb)
);

reg sqrt_inp_valid_q, sqrt_inp_valid_d;
reg [PRECISION-1:0] sqrt_inp_q, sqrt_inp_d;
wire [23:0] sqrt_out;
wire sqrt_out_valid;
cordic_sqrt sqrt (
  .aclk(clk),
  .s_axis_cartesian_tvalid(sqrt_inp_valid_q),
  .m_axis_dout_tvalid(sqrt_out_valid),
  .s_axis_cartesian_tdata(sqrt_inp_q),
  .m_axis_dout_tdata(sqrt_out)
);

localparam STATE_IDLE = 0,
	STATE_READING_FILE = 1,
	STATE_PARSING_NUMBER = 2,
	STATE_CONSUMING_NUMBER = 3,
	STATE_READ_NNODES = 4,
	STATE_READ_X = 5,
	STATE_READ_Y = 6,
	STATE_SOLVE_PROBLEM = 7,
	STATE_COMPUTE_TOTAL_DISTANCE = 8,
	STATE_WAIT_FOR_SQRT_RESULT = 9,
	STATE_DONE_SOLVING = 10,
	STATE_INCR_ADDR = 11,
	STATE_DELAY = 12;
reg [3:0] state_q, state_d, nextstate_q, nextstate_d;

reg has_read_prolog_q, has_read_prolog_d;
reg [MAX_NODE_BITS-1:0] nnodes_in_file_q, nnodes_in_file_d;
reg [7:0] string_len_q, string_len_d;
reg [(STRINGBUFFER_SIZE<<3)-1:0] read_string_q, read_string_d; // a string buffer - we just store it as a big number
reg [(1<<NUMBUF_NDIGITS_BITS)*4-1:0] num_buffer_q, num_buffer_d, number_q, number_d;
reg [NUMBUF_NDIGITS_BITS-1:0] numbuf_size_q, numbuf_size_d;
reg [PRECISION-1:0] read_y_q, read_y_d;
reg [7:0] delay_ctr_q, delay_ctr_d;
reg ready_to_read_q, ready_to_read_d;
assign ready_to_read = ready_to_read_q;

reg [PRECISION-1:0] total_dist_q, total_dist_d;

`define LASTCHAR ((read_string_q>>((string_len_q-1)*8))&8'hFF)
`define X(v) (v[PRECISION-1:0])
`define Y(v) (v[PRECISION*2-1:PRECISION])

assign debug = number_q[7:0];//{sqrt_inp_q[1:0], total_dist_q[5:0]};//total_dist_q[7:0];//string_len_q;//{state_q[2:0], has_read_prolog_q, nextstate_q[2:0], 1'b0};//nnodes_in_file_q[7:0];//((read_string_q>>((string_len_q-1)*8))&8'hFF);//{string_len_q[3:0],nnodes_in_file_q[3:0]};

always @(*) begin
	has_read_prolog_d = has_read_prolog_q;
	nnodes_in_file_d = nnodes_in_file_q;
	read_string_d = read_string_q;
	string_len_d = string_len_q;
	state_d = state_q;
	nextstate_d = nextstate_q;
	num_buffer_d = num_buffer_q;
	numbuf_size_d = numbuf_size_q;
	number_d = number_q;
	ready_to_read_d = ready_to_read_q;
	wea_d = 0;
	addra_d = addra_q;
	dina_d = dina_q;
	addrb_d = addrb_q;
	read_y_d = read_y_q;
	
	sqrt_inp_d = sqrt_inp_q;
	sqrt_inp_valid_d = 0;
	total_dist_d = total_dist_q;
	delay_ctr_d = delay_ctr_q;
	
	case (state_q)
	STATE_IDLE: begin
		// Do nothing, yet
		state_d = STATE_READING_FILE;
		ready_to_read_d = 0;
	end
	STATE_READING_FILE: begin
		ready_to_read_d = 1;
			if (has_specdata) begin
				if (specdata == 13) begin
					// A newline - we need to process the current string
					if (!has_read_prolog_q) begin
						// Still reading the prolog
						if (read_string_q[23:0] == 24'h4d4944) begin // "DIMENSION", or the first 3 chars thereof
							// The last few characters will be a number
							nnodes_in_file_d = 0;
							nextstate_d = STATE_READ_NNODES;
							state_d = STATE_CONSUMING_NUMBER;
							numbuf_size_d = 0;
							ready_to_read_d = 0;
						//end else if (read_string_q[(18*8)-1:0] == 144'h4e4f49544345535f44524f4f435f45444f4e) begin // "NODE_COORD_SECTION"
						end else if (read_string_q[7:0] == 8'h4e) begin
							has_read_prolog_d = 1;
							string_len_d = 0;
							read_string_d = 0;
							addra_d = 0;
						end
						//string_len_d = 0;
						//read_string_d = 0;
					end else begin
						// This line should have 3 numbers - let's go get them (OR, it should equal "EOF", in which case we're done)
						if (read_string_q[23:0] == 24'h464f45) begin // "EOF"
							state_d = STATE_SOLVE_PROBLEM;
							ready_to_read_d = 0;
						end else begin
							// Parse X, parse Y, save to RAM.
							nextstate_d = STATE_READ_Y;
							state_d = STATE_CONSUMING_NUMBER;
							numbuf_size_d = 0;
							ready_to_read_d = 0;
						end
					end
				end else begin
					string_len_d = string_len_q + 1;
					read_string_d = read_string_q | (specdata<<(string_len_q<<3));
				end
			end
	end
	STATE_READ_NNODES: begin
		nnodes_in_file_d = number_q;
		state_d = STATE_READING_FILE;
	end
	STATE_READ_Y: begin
		read_y_d = number_q;
		// Strip the non-numbers
		//if ((((read_string_q>>((string_len_q-1)*8))&8'hFF) < 48 || ((read_string_q>>((string_len_q-1)*8))&8'hFF) > 57) && !string_len_q[7]) begin
		if (`LASTCHAR < 48 || `LASTCHAR > 57) begin
			string_len_d = string_len_q - 1;
		end else begin
			nextstate_d = STATE_READ_X;
			state_d = STATE_CONSUMING_NUMBER;
			numbuf_size_d = 0;
			num_buffer_d = 0;
		end
	end
	STATE_READ_X: begin
		// Save this X,Y into RAM
		dina_d = read_y_q;//64'hffffffffffffffff;//{read_y_q, number_q};
		wea_d = 1;
		//addra_d = addra_q + 1;
		state_d = STATE_DELAY;//INCR_ADDR;//READING_FILE;
		delay_ctr_d = 3;
		nextstate_d = STATE_INCR_ADDR;//STATE_READING_FILE;
		string_len_d = 0;
		read_string_d = 0;
	end
	STATE_INCR_ADDR: begin
		addra_d = addra_q + 1;
		state_d = STATE_READING_FILE;//nextstate_q;
	end
	STATE_CONSUMING_NUMBER: begin
		// We're taking the number off of the string buffer and putting it in our buffer
		//if (((read_string_q>>((string_len_q-1)*8))&8'hFF) < 48 || ((read_string_q>>((string_len_q-1)*8))&8'hFF) > 57) begin //read_string_q[7+string_len_q*8:0+string_len_q*8] < 48 || read_string_q[7+string_len_q*8:0+string_len_q*8] > 57) begin
		if (`LASTCHAR < 48 || `LASTCHAR > 57) begin
			//nnodes_in_file_d = 6;
			state_d = STATE_PARSING_NUMBER;//nextstate_q;
			string_len_d = 0;
			read_string_d = 0;
			number_d = 0;
		end else begin
			//nnodes_in_file_d = (nnodes_in_file_q<<3) + (nnodes_in_file_q<<1) + ((read_string_q>>((string_len_q-1)<<3))&8'hFF) - 48;//(nnodes_in_file_q<<3) + (nnodes_in_file_q<<2) + ((read_string_q>>((string_len_q-1)*8))&8'hFF) - 48;
			num_buffer_d = (num_buffer_q<<4) + `LASTCHAR - 48;//((read_string_q>>((string_len_q-1)<<3))&8'hFF) - 48;
			string_len_d = string_len_q - 1;
			numbuf_size_d = numbuf_size_q + 1;
		end
	end
	STATE_PARSING_NUMBER: begin
		if (numbuf_size_q == 0) begin
			state_d = nextstate_q;
		end else begin
			number_d = (number_q<<3) + (number_q<<1) + num_buffer_q[3:0];
			numbuf_size_d = numbuf_size_q - 1;
			num_buffer_d = num_buffer_q >> 4;
		end
	end
	
	STATE_SOLVE_PROBLEM: begin
		delay_ctr_d = 2;
		state_d = STATE_DELAY;
		nextstate_d = STATE_COMPUTE_TOTAL_DISTANCE;
		addra_d = 0;
		addrb_d = 1;
		total_dist_d = 0;
	end
	STATE_DELAY: begin
		if (delay_ctr_q == 0) begin
			state_d = nextstate_q;
		end else begin
			delay_ctr_d = delay_ctr_q - 1;
		end
	end
	STATE_COMPUTE_TOTAL_DISTANCE: begin
		// Load the next two cities
		sqrt_inp_d = douta[7:0]+1/**`X(doutb)*/;//(`X(doutb)-`X(douta))*(`X(doutb)-`X(douta))+(`Y(doutb)-`Y(douta))*(`Y(doutb)-`Y(douta));
		sqrt_inp_valid_d = 1;
		state_d = STATE_WAIT_FOR_SQRT_RESULT;
		addra_d = addra_q + 1;
		if (addrb_q+1 >= nnodes_in_file_q) begin
			// One more and then we're done
			nextstate_d = STATE_DONE_SOLVING;
			addrb_d = 0;
		end else begin
			nextstate_d = STATE_COMPUTE_TOTAL_DISTANCE;
			addrb_d = addrb_q + 1;
		end
	end
	STATE_WAIT_FOR_SQRT_RESULT: begin
		if (sqrt_out_valid) begin
			// Done waiting! Add to accumulator
			total_dist_d = total_dist_q + sqrt_out;
			state_d = nextstate_q;//STATE_COMPUTE_TOTAL_DISTANCE;
		end
	end
	STATE_DONE_SOLVING: begin
	end
	endcase
end

always @(posedge clk) begin
	if (rst) begin
		has_read_prolog_q <= 0;
		nnodes_in_file_q <= 0;
		read_string_q <= 0;
		string_len_q <= 0;
		state_q <= STATE_IDLE;
		nextstate_q <= STATE_IDLE;
		number_q <= 0;
		ready_to_read_q <= 0;
		wea_q <= 0;
		addra_q <= 0;
	end else begin
		has_read_prolog_q <= has_read_prolog_d;
		nnodes_in_file_q <= nnodes_in_file_d;
		read_string_q <= read_string_d;
		string_len_q <= string_len_d;
		state_q <= state_d;
		nextstate_q <= nextstate_d;
		num_buffer_q <= num_buffer_d;
		numbuf_size_q <= numbuf_size_d;
		number_q <= number_d;
		ready_to_read_q <= ready_to_read_d;
		wea_q <= wea_d;
		dina_q <= dina_d;
		addra_q <= addra_d;
		read_y_q <= read_y_d;
		total_dist_q <= total_dist_d;
		sqrt_inp_valid_q <= sqrt_inp_valid_d;
		sqrt_inp_q <= sqrt_inp_d;
		addrb_q <= addrb_d;
		delay_ctr_q <= delay_ctr_d;
	end
end

endmodule
