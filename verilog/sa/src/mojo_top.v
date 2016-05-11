module mojo_top(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy // AVR Rx buffer full
    );

wire rst = ~rst_n; // make reset active high

wire [7:0] serial_data;
wire serial_new_data, tx_busy;
reg [7:0] tx_data_q, tx_data_d;
reg tx_new_data_q, tx_new_data_d;
avr_interface avr_interface (
	.clk(clk),
	.rst(rst),
	.cclk(cclk),
	.spi_miso(spi_miso),
	.spi_mosi(spi_mosi),
	.spi_sck(spi_sck),
	.spi_ss(spi_ss),
	.spi_channel(spi_channel),
	.tx(avr_rx), // FPGA tx goes to AVR rx
	.rx(avr_tx),
	.channel(4'd15), // invalid channel disables the ADC
	.new_sample(),
	.sample(),
	.sample_channel(),
	.tx_data(tx_data_q),
	.new_tx_data(tx_new_data_q),
	.tx_busy(tx_busy),
	.tx_block(avr_rx_busy),
	.rx_data(serial_data),
	.new_rx_data(serial_new_data)
);

wire [31:0] rng_out;
xorshift rng (
	.clk(clk),
	.rst(rst),
	.seed(128'h8de97cc56144a7eb653f6dee8b49b282), // From /dev/urandom, should be random.
	.out(rng_out)
);

wire ready_to_read, best_distance_valid;
wire [31:0] best_distance;
wire [7:0] tsp_dbg;
tsp tsp(
	.clk(clk),
	.rst(rst),
	.specdata(serial_data),
	.has_specdata(serial_new_data),
	.ready_to_read(ready_to_read),
	.debug(tsp_dbg),
	.best_distance(best_distance),
	.best_distance_valid(best_distance_valid),
	.rng(rng_out)
);

reg [31:0] printval_q, printval_d;
reg [27:0] cntdown_q, cntdown_d;
reg [4:0] digit_cnt_q, digit_cnt_d;
reg tx_hold_q, tx_hold_d;

always @(*) begin
	tx_data_d = tx_data_q;
	tx_new_data_d = 0;
	printval_d = printval_q;
	digit_cnt_d = digit_cnt_q;
	tx_hold_d = 0;
	cntdown_d = cntdown_q - 1;

	if (serial_new_data) begin
		if (serial_data == 114 && !tx_busy) begin
			// Print the random value
			if (digit_cnt_q == 0) begin
				printval_d = rng_out;
				digit_cnt_d = 8;
			end
		end else if (tx_busy || digit_cnt_q > 0 || !ready_to_read) begin
			// We have to push this incoming character into the FIFO. But for now we ignore it.
		end else begin
			tx_data_d = serial_data;
			tx_new_data_d = 1;
		end
	end
	
	if (digit_cnt_q > 0 && !tx_busy && !tx_hold_q) begin
		// Send the bottom 4 bits at a time
		tx_new_data_d = 1;
		if (printval_q[3:0] < 10) begin
			tx_data_d = {4'b0,printval_q[3:0]} + 48;
		end else begin
			tx_data_d = {4'b0,printval_q[3:0]} + 87;
		end
		//tx_data_d = "a";
		printval_d = printval_q >> 4;
		digit_cnt_d = digit_cnt_q - 1;
		tx_hold_d = 1;
	end
	if (best_distance_valid || cntdown_q == 0) begin
		printval_d = best_distance;
		digit_cnt_d = 8;
		tx_data_d = "\r";
		tx_new_data_d = 1;
		cntdown_d = 100000000;
	end
end

always @(posedge clk) begin
	if (rst) begin
		tx_new_data_q <= 0;
		printval_q <= 0;
		digit_cnt_q <= 0;
	end else begin
		tx_data_q <= tx_data_d;
		tx_new_data_q <= tx_new_data_d;
		printval_q <= printval_d;
		digit_cnt_q <= digit_cnt_d;
		tx_hold_q <= tx_hold_d;
		cntdown_q <= cntdown_d;
	end
end

assign led = best_distance[15:8];

// these signals should be high-z when not used
assign spi_miso = 1'bz;
assign avr_rx = 1'bz;
assign spi_channel = 4'bzzzz;

//assign led = 8'b0;

endmodule