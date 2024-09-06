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
  reg [DEPTH - 2:0] wr_ptr;
  reg [DEPTH - 2:0] rd_ptr;
  reg [DATA_WIDTH - 1:0] fifo_reg [DEPTH - 1:0];

  // output
  reg [DATA_WIDTH - 1:0] dat_out;
  reg o_full, o_empty;

  // Write/Read operation
  always @(posedge clk) begin
    if (!rst_n) begin
      wr_ptr <= 0;
    end else if (wr_en && !o_full) begin
      wr_ptr <= (wr_ptr + 1);
      fifo_reg[wr_ptr][DATA_WIDTH - 1:0] <= dat_in;
    end
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      rd_ptr <= 0;
    end else if (rd_en && !o_empty) begin
      rd_ptr  <= (rd_ptr + 1);
      dat_out <= fifo_reg[rd_ptr][DATA_WIDTH - 1:0];
    end
  end

  // Are we full or empty?
  assign o_full  = rst_n ? ((wr_ptr + 1) == rd_ptr) : 0;
  assign o_empty = rst_n ? ((wr_ptr == rd_ptr))     : 1;

  // Assign output pins
  assign uo_out  = rst_n ? {o_empty, o_full, dat_out} : '0;

endmodule

