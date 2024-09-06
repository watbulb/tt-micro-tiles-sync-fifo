/*
 * Copyright (c) 2024 Dayton Pidhirney (watbulb)
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns / 1ps

module tb ();

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  reg clk;
  reg rst_n;
  reg rd_en, wr_en;
  reg o_full, o_empty;
  reg [5:0] dat_in, dat_out;

  wire [7:0] ui_in = {rd_en, wr_en, dat_in};
  wire [7:0] uo_out;

  assign dat_out  = uo_out[5:0];
  assign o_full   = uo_out[6];
  assign o_empty  = uo_out[7];

  tt_um_watbulb_sync_fifo tt_um_sync_fifo(
    .ui_in   ( ui_in  ) ,
    .uo_out  ( uo_out ) ,
    .clk     ( clk    ) ,
    .rst_n   ( rst_n  )
  );

endmodule
