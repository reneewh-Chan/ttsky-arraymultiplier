"""
Minimal cocotb test wrapper for standalone SystemVerilog testbench.
The actual test logic is in tb_tt_um_arraymultiplier.sv
"""

import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def run_test(dut):
    """Let the SystemVerilog testbench run to completion."""
    # Just wait - the SV testbench handles everything
    await Timer(200, units='us')  # Match the timeout in your testbench
