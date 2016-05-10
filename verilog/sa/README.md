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

The algorithm is not particularly complicated. distance.v and negexp.v abstract away heavy math (sqrt(dx*dx+dy*dy) and the Taylor expansion of e^x, respectively).

xorshift.v is a self-seeding implementation of the xorshift random number generator.

mojo_top.v is the frontend to this whole mess.

tsp.v is where the fun happens. There are three stages to what it does: Parsing, computing the total distance of the given order, and trying swaps.

The first step deals with converting from a textual representation of the file to a list of cities in memory. It only checks the first three characters of a line for a match to either "DIMENSION" or "NODE", it doesn't compare against the entire shebang (though it could).

The next step computes the total length. Again, nothing special here.

Then we try swaps. When we try swaps, observe that we don't have to re-compute the entire distance every time: Since distance are rounded to integers (per the TSPLIB spec), if we have a sequence of cities 1-2-3-4 and we're considering swapping 2 and 3 (to 1-3-2-4), we need only compute the distances 1-2, 3-4, 1-3, 2-4, and compare (1-2)+(3-4) with (1-3)+(2-4).
