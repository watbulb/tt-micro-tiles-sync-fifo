<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

A generic synchronous First-In-First-Out (FIFO) buffer. It operates on a single clock domain and allows for buffering of data from an input interface (`ui_in`) to an output interface (`uo_out`), while ensuring that data is neither overwritten when full nor read when empty.

## Parameters

- **`DATA_WIDTH`**: The width of the data in bits (default: 6).
- **`DEPTH`**: The depth of the FIFO in terms of the number of entries (default: 3).

## Details:

**Reset**:
   - The `rst_n` signal resets the FIFO, clearing its contents by resetting the write and read pointers (`wr_ptr` and `rd_ptr`).

**Data Write**:
   - Data from the `ui_in` bus is written to the FIFO when the write enable signal (`wr_en`) is asserted (bit 6 of `ui_in`).
   - The FIFO prevents writing if the buffer is full, indicated by the `o_full` signal.
   
**Data Read**:
   - Data is read from the FIFO when the read enable signal (`rd_en`) is asserted (bit 7 of `ui_in`).
   - The FIFO prevents reading if the buffer is empty, indicated by the `o_empty` signal.
   
**Control Signals**:
   - `o_full`: Indicates when the FIFO has reached its maximum capacity.
   - `o_empty`: Indicates when the FIFO has no data to read.

**FIFO Depth**:
   - The default depth is set to 3 for practical reasons for a micro-tile, but this can be modified via the `DEPTH` parameter.
   
**Data Width**:
   - The FIFO supports a 6-bit data width, which can also be adjusted via the `DATA_WIDTH` parameter.

### Performance Considerations:
- The FIFO is implemented as a circular buffer using read and write pointers (`rd_ptr` and `wr_ptr`).
- The maximum routable depth is 6 for a micro-tile architecture, though the current default is 3 to reduce congestion.
- It achieves around 70% utilization, with potential room for optimization.

## How to test

1. **Write Operation**:
   - Set the `wr_en` signal (bit 6 of `ui_in`) high and ensure `o_full` is low.
   - Apply a 6-bit data value on the lower 6 bits of `ui_in`.
   - Observe that the data is written into the FIFO.
   
2. **Read Operation**:
   - Set the `rd_en` signal (bit 7 of `ui_in`) high and ensure `o_empty` is low.
   - Observe that data is read from the FIFO and appears on the lower 6 bits of `uo_out`.

3. **Status Indicators**:
   - Fill the FIFO and observe that the `o_full` signal is asserted when the FIFO is full.
   - Read all data from the FIFO and observe that the `o_empty` signal is asserted when the FIFO is empty.