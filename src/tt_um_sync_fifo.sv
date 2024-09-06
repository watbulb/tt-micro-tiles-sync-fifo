/*
 * Copyright (c) 2024 Dayton Pidhirney (watbulb)
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

/* NOTE:
 * Unfortunately, the max depth I could acheive was about 6 (100% utilization)
 * in a micro-tile Q_Q. But to reduce congestion overall I decided
 * to make the size "3", this allows for a 70% density target.
 *
 * You can scale it via the DEPTH parameter below.
 *
 * I also spent only about 3 hours on this, all to re-write it
 * because of some gate-level bug. I think it can be improved.
*/

module tt_um_watbulb_sync_fifo #(
  parameter DATA_WIDTH = 6,   // 64 decimal, 32 signed
  parameter DEPTH = 3
) (
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);
  // inputs
  wire rd_en = ui_in[DATA_WIDTH + 1];
  wire wr_en = ui_in[DATA_WIDTH];
  wire [DATA_WIDTH - 1:0] dat_in = ui_in[DATA_WIDTH - 1:0];

  // locals
  reg [DEPTH - 2:0] count;
  reg [DEPTH - 2:0] wr_ptr;
  reg [DEPTH - 2:0] rd_ptr;
  reg [DATA_WIDTH - 1:0] fifo_reg [DEPTH - 1:0];

  // output
  reg [DATA_WIDTH - 1:0] dat_out;
  reg o_full, o_empty;

  int i;
  always @(posedge clk) begin
    if (!rst_n) begin
      count       <= '0;
      wr_ptr      <= '0;
      rd_ptr      <= '0;
      o_full      <=  0;
      o_empty     <=  1;
      dat_out     <= '0;
      for (i = 0; i < DEPTH; i = i + 1) begin : l_zero_fifo_reg
        fifo_reg[i] <= '0;
      end
    end else begin
      if (o_full)
        wr_ptr  <= '0;
      if (o_empty)
        rd_ptr  <= '0;
      if (wr_en && !o_full) begin
        count   <= (count  + 1);
        wr_ptr  <= (wr_ptr + 1);
        o_empty <= 0;
        o_full  <= (count + 1) == DEPTH;
        fifo_reg[wr_ptr][DATA_WIDTH - 1:0] <= dat_in;
      end else if (rd_en && !o_empty) begin
        count   <= (count  - 1);
        rd_ptr  <= (rd_ptr + 1);
        o_empty <= (count  - 1) == '0;
        o_full  <= 0;
        dat_out[DATA_WIDTH - 1:0] <= fifo_reg[rd_ptr][DATA_WIDTH - 1:0];
      end
    end
  end

  assign uo_out = {o_empty, o_full, dat_out};

endmodule

