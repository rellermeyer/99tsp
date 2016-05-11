99 TSP - Verilog Simulated Annealing
====================================

Welcome to my Verilog solution to the Travelling Salesman Problem!

This being Verilog, it's designed to run on hardware. The board I used to develop this solution on is the Mojo v3 board (and therefore the Xilinx ISE toolchain).

I have long ago given up on making this code run in a simulator or building it using the toolchain in this repository, which caters to a software-oriented crowd. This folder contains a Xilinx ISE project which is derived from the Mojo base project for ISE: https://github.com/embmicro/mojo-base-project. Six of the files in this folder are straight from that repo: avr_interface, cclk_detector, mojo.ucf, serial_rx, serial_tx, and spi_slave.

There are, in addition to the source files, 7 modules which must be generated:
- city_ram: Stores up to 8192 cities.
- cordic_sqrt: Computes an integer square root.
- div_mod: Divides a 32-bit integer by a 16-bit integer to get the remainder.
- fixed2float: Converts an integer to a single-precision float.
- floating_point_add: Adds two floats.
- floating_point_mult: Multiplies two floats.
- floating_point_mult_double: Multiplies two doubles.
- floating_point_recprocate: Computes the reciprocal of a floating point value.

The algorithm is not particularly complicated. distance.v and negexp.v abstract away heavy math (sqrt(dx*dx+dy*dy) and the Taylor expansion of e^x, respectively).

xorshift.v is a self-seeding implementation of the xorshift random number generator.

mojo_top.v is the frontend to this whole mess.

tsp.v is where the fun happens. There are three stages to what it does: Parsing, computing the total distance of the given order, and trying swaps.

The first step deals with converting from a textual representation of the file to a list of cities in memory. It only checks the first three characters of a line for a match to either "DIMENSION" or "NODE", it doesn't compare against the entire shebang (though it could).

The next step computes the total length. Again, nothing special here.

Then we try swaps. When we try swaps, observe that we don't have to re-compute the entire distance every time: Since distance are rounded to integers (per the TSPLIB spec), if we have a sequence of cities 1-2-3-4 and we're considering swapping 2 and 3 (to 1-3-2-4), we need only compute the distances 1-2, 3-4, 1-3, 2-4, and compare (1-2)+(3-4) with (1-3)+(2-4).

The temperature schedule is: Start at a given temperature, multiply it each iteration by a constant value (about 0.9999999). Since we only ever divide by T (and division is super expensive - over 30 cycles!), we start at a given 1/T, and multiply it each iteration by 1/factor (about 1.0000001).

However, we still have to do a reciprocal, and thus the latency of each iteration is on the order of a hundred cycles. Since iterations aren't pipelined (yet), the throughput is about 1 per 30 cycles, depending on how often it computes negexp.

But, for all of these problems, this code actually fits on a Mojo chip, so that's pretty cool.
