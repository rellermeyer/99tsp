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
	parameter MAX_NODE_BITS = 13, // 2^this is the max # of nodes
	parameter STRINGBUFFER_SIZE = 32,
	parameter NUMBUF_NDIGITS_BITS = 4
)(
	input clk,
	input rst,
	input [7:0] specdata,
	input has_specdata,
	output ready_to_read,
	output [7:0] debug,
	output [PRECISION-1:0] best_distance,
	output best_distance_valid,
	input [31:0] rng
);

reg wea_q, wea_d, web_q, web_d;
reg [MAX_NODE_BITS-1:0] addra_q, addra_d, addrb_q, addrb_d;
reg [PRECISION*2-1:0] dina_q, dina_d, dinb_q, dinb_d;
wire [PRECISION*2-1:0] douta, doutb;
city_ram city_ram(
	.clka(clk),
	.wea(wea_q),
	.addra(addra_q),
	.dina(dina_q),
	.douta(douta),
	.clkb(clk),
	.web(web_q),
	.addrb(addrb_q),
	.dinb(dinb_q),
	.doutb(doutb)
);

/*reg sqrt_inp_valid_q, sqrt_inp_valid_d;
reg [PRECISION-1:0] sqrt_inp_q, sqrt_inp_d;
wire [23:0] sqrt_out;
wire sqrt_out_valid;
cordic_sqrt sqrt (
  .aclk(clk),
  .s_axis_cartesian_tvalid(sqrt_inp_valid_q),
  .m_axis_dout_tvalid(sqrt_out_valid),
  .s_axis_cartesian_tdata(sqrt_inp_q),
  .m_axis_dout_tdata(sqrt_out)
);*/

reg [2*PRECISION-1:0] distcomp_inp_a_q, distcomp_inp_a_d, distcomp_inp_b_q, distcomp_inp_b_d;
reg distcomp_inp_valid_q, distcomp_inp_valid_d;
wire [PRECISION-1:0] distcomp_out;
wire distcomp_out_valid;
distance distcomp(
	.clk(clk),
	.rst(rst),
	.citya(distcomp_inp_a_q),
	.cityb(distcomp_inp_b_q),
	.inp_valid(distcomp_inp_valid_q),
	.out_valid(distcomp_out_valid),
	.out(distcomp_out)
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
	STATE_DELAY = 12,
	//STATE_COMPUTE_DX_DY = 13,
	STATE_LOADING_CITY_1 = 14,
	STATE_LOADED_FIRST_CITIES = 15,
	STATE_LOADED_SECOND_CITIES = 16,
	STATE_PIPING_DISTANCES = 17,
	STATE_WAITING_PC = 18,
	STATE_COMPUTED_TOTDIST = 19;
reg [4:0] state_q, state_d, nextstate_q, nextstate_d;

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
assign best_distance = total_dist_q;
assign best_distance_valid = (state_q == STATE_DONE_SOLVING);

reg [PRECISION*2-1:0] city1_q, city1_d, city2_q, city2_d, city3_q, city3_d, city4_q, city4_d;

`define LASTCHAR ((read_string_q>>((string_len_q-1)*8))&8'hFF)
`define X(v) (v[PRECISION-1:0])
`define Y(v) (v[PRECISION*2-1:PRECISION])

assign debug = nnodes_in_file_q[7:0];

reg [2:0] pipe_tx_ctr_q, pipe_tx_ctr_d, pipe_rx_ctr_q, pipe_rx_ctr_d;
reg [PRECISION*4*2-1:0] pipe_tx_buf_a_q, pipe_tx_buf_a_d, pipe_tx_buf_b_q, pipe_tx_buf_b_d;
reg [PRECISION*4-1:0] pipe_rx_buf_q, pipe_rx_buf_d;

// This is actually 1/T, to optimize (new-old)/T to (new-old)*T, which is much faster
reg [31:0] temperature_q, temperature_d;

wire [31:0] new_temperature;
floating_point_mult temp_mult(
	.aclk(clk),
	.s_axis_a_tdata(temperature_q),
	.s_axis_a_tvalid(1'b1),
	.s_axis_b_tdata(32'h3f800008), // 1.0000001 in single-precision IEEE753
	.s_axis_b_tvalid(1'b1),
	.m_axis_result_tdata(new_temperature),
	.m_axis_result_tvalid()
);
/*floating_point_mult_double temp_mult(
	.aclk(clk),
	.s_axis_a_tdata(temperature_q),
	.s_axis_a_tvalid(1'b1),
	.s_axis_b_tdata(64'h3FF0000002AF31DC), // 1.0000001 in double-precision IEEE753
	.s_axis_b_tvalid(1'b1),
	.m_axis_result_tdata(new_temperature),
	.m_axis_result_tvalid()
);*/

// We modulo the RNG value by the number of nodes we're handling
wire [47:0] rng_mod;
wire rngmod_tready;
div_mod rng_divider(
	.aclk(clk),
	.s_axis_divisor_tvalid(nnodes_in_file_q==0?1'b0:1'b1),
	.s_axis_divisor_tready(rngmod_tready),
	.s_axis_divisor_tdata({3'b0,nnodes_in_file_q}),
	.s_axis_dividend_tvalid(rngmod_tready),
	.s_axis_dividend_tready(),
	.s_axis_dividend_tdata(rng),
	.m_axis_dout_tvalid(),
	.m_axis_dout_tdata(rng_mod)
);

// Convert 1/T from double to single
wire [31:0] temp_single_prec;
assign temp_single_prec = new_temperature;
/*floating_point_d2s d2s(
	.aclk(clk),
	.s_axis_a_tvalid(1'b1),
	.s_axis_a_tdata(temperature_q),
	.m_axis_result_tvalid(),
	.m_axis_result_tdata(temp_single_prec)
);*/

reg [PRECISION-1:0] pc_new_q, pc_new_d, pc_old_q, pc_old_d;
reg pc_valid_q, pc_valid_d;
wire [31:0] pc_out;
wire pc_out_valid;
prob_computer probputer(
	.clk(clk),
	.rst(rst),
	.new(pc_new_q),
	.old(pc_old_q),
	.Tinv(temp_single_prec),
	.inp_valid(pc_valid_q),
	.out(pc_out),
	.out_valid(pc_out_valid)
);

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
	dinb_d = dinb_q;
	web_d = 0;
	
	//sqrt_inp_d = sqrt_inp_q;
	//sqrt_inp_valid_d = 0;
	distcomp_inp_a_d = distcomp_inp_a_q;
	distcomp_inp_b_d = distcomp_inp_b_q;
	distcomp_inp_valid_d = 0;
	total_dist_d = total_dist_q;
	delay_ctr_d = delay_ctr_q;
	/*dx_d = dx_q;
	dy_d = dy_q;*/
	city1_d = city1_q;
	city2_d = city2_q;
	city3_d = city3_q;
	city4_d = city4_q;
	
	pipe_tx_ctr_d = pipe_tx_ctr_q;
	pipe_tx_buf_a_d = pipe_tx_buf_a_q;
	pipe_tx_buf_b_d = pipe_tx_buf_b_q;
	pipe_rx_ctr_d = pipe_rx_ctr_q;
	pipe_rx_buf_d = pipe_rx_buf_q;
	
	temperature_d = temperature_q;
	
	pc_valid_d = 0;
	pc_new_d = pc_new_q;
	pc_old_d = pc_old_q;
		
	case (state_q)
	STATE_IDLE: begin
		// Do nothing, yet
		state_d = STATE_READING_FILE;
		ready_to_read_d = 0;
		nnodes_in_file_d = 0;
		has_read_prolog_d = 0;
		string_len_d = 0;
		read_string_d = 0;
		total_dist_d = 0;
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
							num_buffer_d = 0;
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
		string_len_d = 0;
		read_string_d = 0;
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
		dina_d = {read_y_q, number_q[PRECISION-1:0]};
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
		if (`LASTCHAR < 48 || `LASTCHAR > 57) begin
			//nnodes_in_file_d = 6;
			state_d = STATE_PARSING_NUMBER;//nextstate_q;
			//string_len_d = 0;
			//read_string_d = 0;
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
	/*STATE_COMPUTE_DX_DY: begin
		dx_d = `X(doutb)-`X(douta);
		dy_d = `Y(doutb)-`Y(douta);
		state_d = STATE_COMPUTE_TOTAL_DISTANCE;
	end*/
	STATE_COMPUTE_TOTAL_DISTANCE: begin
		// Load the next two cities
		distcomp_inp_a_d = douta;
		distcomp_inp_b_d = doutb;
		distcomp_inp_valid_d = 1;
		//sqrt_inp_d = dx_q*dx_q + dy_q*dy_q;//dist_squared;//(`X(doutb)-`X(douta))*(`X(doutb)-`X(douta))+(`Y(doutb)-`Y(douta))*(`Y(doutb)-`Y(douta));
		//sqrt_inp_valid_d = 1;
		state_d = STATE_WAIT_FOR_SQRT_RESULT;
		addra_d = addra_q + 1;
		if (addrb_q == 0) begin
			// Last one
			nextstate_d = STATE_COMPUTED_TOTDIST; // Start doing the SA iterations
		end else if (addrb_q+1 >= nnodes_in_file_q) begin
			// One more and then we're done
			nextstate_d = STATE_COMPUTE_TOTAL_DISTANCE;
			addrb_d = 0;
		end else begin
			nextstate_d = STATE_COMPUTE_TOTAL_DISTANCE;
			addrb_d = addrb_q + 1;
		end
	end
	STATE_WAIT_FOR_SQRT_RESULT: begin
		if (distcomp_out_valid) begin
			// Done waiting! Add to accumulator
			total_dist_d = total_dist_q + distcomp_out;
			state_d = nextstate_q;//STATE_COMPUTE_TOTAL_DISTANCE;
		end
	end
	STATE_COMPUTED_TOTDIST: begin
		state_d = STATE_DELAY;
		//temperature_d = 64'h3F1A36E2EB1C432D; // 1/10000 in double
		temperature_d = 32'h38d1b717; // 1/10000 in single
		delay_ctr_d = 50;
		nextstate_d = STATE_LOADING_CITY_1;
	end
	STATE_DONE_SOLVING: begin
		state_d = STATE_IDLE;
	end

	// Now the actual SA part - pick two cities to swap, see if they're better, repeat.
	// Pick a city to swap - there are 4 cities we need to know about overall.
	STATE_LOADING_CITY_1: begin
		// Update the temperature
		// we may need to compute e^(-(new-old)/T) = e^((old-new)/T), so start computing 1/T
		// (which is done simply by updating 1/T with 1/factor)
		temperature_d = new_temperature;

		// Pick a city to swap with the next one. (TODO: modulo)
		addra_d = rng_mod[MAX_NODE_BITS-1:0]-1;
		addrb_d = rng_mod[MAX_NODE_BITS-1:0];
		nextstate_d = STATE_LOADED_FIRST_CITIES;
		state_d = STATE_DELAY;
		delay_ctr_d = 1;
	end
	STATE_LOADED_FIRST_CITIES: begin
		// Save these values, load the next two.
		city1_d = douta;
		city2_d = doutb; // Load these into the distance computer
		addra_d = addra_q + 2;
		addrb_d = addrb_q + 2;
		nextstate_d = STATE_LOADED_SECOND_CITIES;
		state_d = STATE_DELAY;
		delay_ctr_d = 1;
	end
	STATE_LOADED_SECOND_CITIES: begin
		city3_d = douta;
		city4_d = doutb;

		// Change addra and addrb in preparation for a possible swap
		addra_d = addra_q - 1;
		addrb_d = addrb_q - 1;

		// Load these into the distance computer.
		// We have 4 distances to compute: 1-2, 3-4, and 1-3, 2-4 (2-3 equals 3-2, so we don't need to know it)
		pipe_tx_ctr_d = 4;
		pipe_tx_buf_a_d = {city1_q, douta, city1_q, city2_q};
		pipe_tx_buf_b_d = {city2_q, doutb, douta, doutb};
		pipe_rx_ctr_d = 4;
		pipe_rx_buf_d = 0;
		state_d = STATE_PIPING_DISTANCES;
	end
	STATE_PIPING_DISTANCES: begin
		if (pipe_tx_ctr_q > 0) begin
			// We have more to pipe in
			pipe_tx_ctr_d = pipe_tx_ctr_q - 1;
			distcomp_inp_a_d = pipe_tx_buf_a_q[63:0];
			pipe_tx_buf_a_d = pipe_tx_buf_a_q >> 64;
			distcomp_inp_b_d = pipe_tx_buf_b_q[63:0];
			pipe_tx_buf_b_d = pipe_tx_buf_b_q >> 64;
			distcomp_inp_valid_d = 1;
		end
		if (distcomp_out_valid && pipe_rx_ctr_q > 0) begin
			pipe_rx_ctr_d = pipe_rx_ctr_q - 1;
			pipe_rx_buf_d = (pipe_rx_buf_q << 32) | distcomp_out;
		end
		if (pipe_rx_ctr_q == 0) begin
			// We know all the distances, is old >= new?
			if (pipe_rx_buf_q[127:96]+pipe_rx_buf_q[95:64] >= pipe_rx_buf_q[63:32]+pipe_rx_buf_q[31:0]) begin
				// Swap, we don't have to do complicated math.
				dina_d = city3_q;
				wea_d = 1;
				dinb_d = city2_q;
				web_d = 1;
				state_d = STATE_LOADING_CITY_1; // Repeat

				// Update best_distance
				total_dist_d = total_dist_q + pipe_rx_buf_q[63:32]+pipe_rx_buf_q[31:0] - (pipe_rx_buf_q[127:96]+pipe_rx_buf_q[95:64]);
			end else begin
				// We have to compute e^(-(new-old)/T)
				// We don't have to add best_distance to each of these, because they're eventually subtracted from each other
				pc_valid_d = 1;
				pc_new_d = pipe_rx_buf_q[63:32]+pipe_rx_buf_q[31:0];
				pc_old_d = pipe_rx_buf_q[127:96]+pipe_rx_buf_q[95:64];
				state_d = STATE_WAITING_PC;
			end
		end
	end
	STATE_WAITING_PC: begin
		if (pc_out_valid) begin
			if (rng < pc_out) begin
				// Swap!
				dina_d = city3_q;
				wea_d = 1;
				dinb_d = city2_q;
				web_d = 1;

				// Update best_distance
				total_dist_d = total_dist_q + pc_new_q - pc_old_q;
			end
			state_d = STATE_LOADING_CITY_1; // Repeat
		end
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
		/*sqrt_inp_valid_q <= sqrt_inp_valid_d;
		sqrt_inp_q <= sqrt_inp_d;*/
		addrb_q <= addrb_d;
		delay_ctr_q <= delay_ctr_d;
		/*dx_q <= dx_d;
		dy_q <= dy_d;*/
		distcomp_inp_a_q <= distcomp_inp_a_d;
		distcomp_inp_b_q <= distcomp_inp_b_d;
		distcomp_inp_valid_q <= distcomp_inp_valid_d;
		city1_q <= city1_d;
		city2_q <= city2_d;
		city3_q <= city3_d;
		city4_q <= city4_d;
		pipe_tx_ctr_q <= pipe_tx_ctr_d;
		pipe_tx_buf_a_q <= pipe_tx_buf_a_d;
		pipe_tx_buf_b_q <= pipe_tx_buf_b_d;
		pipe_rx_ctr_q <= pipe_rx_ctr_d;
		pipe_rx_buf_q <= pipe_rx_buf_d;
		temperature_q <= temperature_d;
		dinb_q <= dinb_d;
		web_q <= web_d;
		pc_valid_q <= pc_valid_d;
		pc_new_q <= pc_new_d;
		pc_old_q <= pc_old_d;
	end
end

endmodule
