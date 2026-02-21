<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The design serially loads matrices A and B, then iteratively computes each matrix entry via a multiply accumulator structure datapath where k indexes the dot product.

## How to test

Use provided test benches for the top level module to evaluate main functionality and edge cases. The testbench runs 12 comprehensive tests including normal matrix multiplication with various data patterns (zeros, maximum values, identity matrices, powers of 2), boundary conditions, and robustness checks (reset during operation, data valid glitches, timeout scenarios, and improper input timing).

## External hardware
None