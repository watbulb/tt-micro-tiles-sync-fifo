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
 * I also spent only about 3 hours on this. I think it can be improved.
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

  reg wr_en,  rd_en;
  reg o_full, o_empty;

  reg [DEPTH - 2:0] count;
  reg [DEPTH - 2:0] wr_ptr;
  reg [DEPTH - 2:0] rd_ptr;
  reg [DATA_WIDTH - 1:0] fifo_reg [DEPTH - 1:0];
  reg [DATA_WIDTH - 1:0] dat_out, dat_in;

  assign dat_in  = ui_in[DATA_WIDTH - 1:0];
  assign wr_en   = ui_in[DATA_WIDTH]; // yeah this is a hacky way, oh well
  assign rd_en   = ui_in[DATA_WIDTH + 1];
  assign uo_out  = rst_n ? {o_empty, o_full, dat_out} : '0;

  // Are we full or empty?
  always_comb begin
    o_full  = rst_n ? (count == DEPTH) : 0;
    o_empty = rst_n ? (count == '0)    : 1;
  end

  // Write/Read operation
  always @(posedge clk) begin
    if (wr_en && !o_full) begin
      fifo_reg[wr_ptr][DATA_WIDTH - 1:0] <= dat_in;
    end else if (rd_en && !o_empty) begin
      dat_out[DATA_WIDTH - 1:0] <= fifo_reg[rd_ptr][DATA_WIDTH - 1:0];
    end
  end

  // Count management
  always @(posedge clk) begin
    if (!rst_n) begin
      wr_ptr  <= '0;
      rd_ptr  <= '0;
      count   <= '0;
    end else begin
      if (o_full)  wr_ptr <= '0;
      if (o_empty) rd_ptr <= '0;
      if (wr_en && !o_full) begin
        count  <= (count  + 1);
        wr_ptr <= (wr_ptr + 1);
      end else if (rd_en && !o_empty) begin
        count  <= (count  - 1);
        rd_ptr <= (rd_ptr + 1);
      end
    end
  end
endmodule

