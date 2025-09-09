`default_nettype none
`timescale 1ns / 1ps

/* This testbench instantiates the tt_um_rr_arbiter4 module
   and drives some example request patterns.
*/
module tb ();

  // Dump the signals to a VCD file. You can view with GTKWave or Surfer.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Signals
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate DUT (Device Under Test)
  tt_um_rr_arbiter4 user_project (
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe),
      .ena    (ena),
      .clk    (clk),
      .rst_n  (rst_n)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end

  // Stimulus
  initial begin
    // Default values
    ena    = 1;
    uio_in = 8'h00;
    ui_in  = 8'h00;
    rst_n  = 0;

    // Release reset
    #10 rst_n = 1;

    // Test different request patterns
    #10 ui_in[3:0] = 4'b1000;   // only req3 active
    #20 ui_in[3:0] = 4'b0101;   // req0 and req2 active
    #30 ui_in[3:0] = 4'b1111;   // all active
    #40 ui_in[3:0] = 4'b0010;   // only req1 active
    #40 ui_in[3:0] = 4'b0000;   // no request
    #100 $finish;
  end

endmodule

