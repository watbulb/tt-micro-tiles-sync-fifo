# SPDX-FileCopyrightText: © 2024 Dayton Pidhirney
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

MIN_DEPTH = 1
MAX_DEPTH = 3

@cocotb.test()
async def test_full_push_pull(dut):
    dut._log.info("Start")
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    depth = MAX_DEPTH

    """
    Try pushing and pulling every depth size between min - MAX_DEPTH
    """
    while depth >= MIN_DEPTH:
        input_sequence  = list(range(0, depth))
        output_sequence = []
        print(f"Using input sequence: {input_sequence}")

        # wait one
        await ClockCycles(dut.clk, 1, False)

        print("Initialize ...")
        # Initialize
        dut.dat_in.value = 0b0000
        dut.rd_en.value  = 0b0
        dut.wr_en.value  = 0b0
        dut.rst_n.value  = 0b0
        await ClockCycles(dut.clk, 1, False)

        """
        Write FIFO until depth is full
        """
        print(f"Writing FIFO to depth: {depth}")
        dut.rst_n.value = 0b1
        dut.rd_en.value = 0b0
        dut.wr_en.value = 0b1
        for i in range(0, depth):
            dut.dat_in.value = input_sequence[i]
            await ClockCycles(dut.clk, 1, False)
            assert dut.o_empty.value == 0b0
            if i != depth - 1: assert dut.o_full.value == 0b0

        if depth == MAX_DEPTH:
            assert dut.o_full.value == 0b1
            pass
        assert dut.o_empty.value == 0b0
        print("FIFO is FULL!")

        """
        Read FIFO until depth is empty
        """
        print(f"Reading FIFO to DEPTH: {depth}")
        dut.wr_en.value = 0b0
        dut.rd_en.value = 0b1
        for i in range(0, depth):
            await ClockCycles(dut.clk, 1, False)
            output_sequence.append(dut.dat_out.value)
            assert dut.o_full.value == 0b0
            if i != depth - 1: assert dut.o_empty.value == 0b0

        assert dut.o_full.value  == 0b0
        assert dut.o_empty.value == 0b1
        print("FIFO is EMPTY!")

        print("INPUT_SEQUENCE == OUTPUT_SEQUENCE")
        print(input_sequence)
        print(list(map(int, output_sequence)))
        assert input_sequence == list(map(int, output_sequence))

        # Reset
        dut.rd_en.value = 0b0
        await ClockCycles(dut.clk, 5, False)
        dut.rst_n.value = 0b0
        await ClockCycles(dut.clk, 5, False)
        depth -= 1
