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

**FIFO Depth**:
   - The default depth is set to 3 for practical reasons for a micro-tile, but this can be modified via the `DEPTH` parameter.

**FIFO Width**:
   - The FIFO supports a 6-bit data width, which can also be adjusted via the `DATA_WIDTH` parameter.

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
   
## How to test

1. **Write Operation**:
   - Set the `wr_en` signal (`ui_in[6]`) high and ensure `o_full` is low (`uo_out[6]`).
   - Apply a 6-bit data value on the lower 6 bits of `ui_in[5:0]` until `o_full` is high.
   
2. **Read Operation**:
   - Set the `rd_en` signal (`ui_in[7]`) high and ensure `o_empty` is low (`uo_out[7]`).
   - Observe that data is read from the FIFO and appears on the lower 6 bits of `uo_out[5:0]`.
   - Once all the data has been read the `o_empty` signal will go high (`uo_out[7]`).

### Inputs and Outputs Table

| Signal  | Description            |
|---------|------------------------|
| `ui[0]` | FIFO Read Enable        |
| `ui[1]` | FIFO Write Enable       |
| `ui[2]` | FIFO Data Input 1       |
| `ui[3]` | FIFO Data Input 2       |
| `ui[4]` | FIFO Data Input 3       |
| `ui[5]` | FIFO Data Input 4       |
| `ui[6]` | FIFO Data Input 5       |
| `ui[7]` | FIFO Data Input 6       |
| `uo[0]` | FIFO Empty Signal       |
| `uo[1]` | FIFO Full Signal        |
| `uo[2]` | FIFO Data Output 1      |
| `uo[3]` | FIFO Data Output 2      |
| `uo[4]` | FIFO Data Output 3      |
| `uo[5]` | FIFO Data Output 4      |
| `uo[6]` | FIFO Data Output 5      |
| `uo[7]` | FIFO Data Output 6      |
